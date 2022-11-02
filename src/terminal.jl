using TOML
include("utility.jl")  # match_diy(), split_undo(), print_diy()

function bot_config()::Dict
    botConfig = Dict()
    #=botConfig = Dict(  # + 0.1s
        "default" => ["g"], 
        "g"       => Dict(
            "cmd" => "gnugo --mode gtp", 
            "dir" => ""
        )
    )=#
    
    if ispath(CONFIG)
        botConfig = TOML.tryparsefile(CONFIG)
        if botConfig isa TOML.ParserError
            errType = botConfig.type
            errRow = botConfig.line
            errCol = botConfig.column

            info = "$errType at " * CONFIG * ":$errRow,$errCol"
            print_diy("e", info)
            botConfig = Dict()
        end
    else
        print_diy("e", "config file not found: " * CONFIG)
    end
    
    botConfig
end

function bot_list(botConfig::Dict)::Tuple{Vector{String},Dict}
    botDefault = String[]
    botDict = Dict()

    if haskey(botConfig, "default")
        botDefault = botConfig["default"]
        if typeof(botDefault) == Vector{String}
            if length(ARGS) != 0 
                botDefault = ARGS
            end
            botDictRaw = delete!(botConfig, "default")
            if botDictRaw isa Dict
                botDict = botDictRaw
            else
                print_diy("e", "$botDictRaw is not a Dict: " * CONFIG)
            end
        else
            print_diy("e", "format err: " * CONFIG * ":default")
        end
    else
        print_diy("e", "not found: " * CONFIG * ":default")
    end

    botDefault, botDict
end

bot_raw(keys::Vector{String}, dict::Dict) = bot_raw(keys[1], dict)
function bot_raw(key::String, dict::Dict)::Tuple{String,String}
    dir = ""
    cmd = ""

    postfix = CONFIG * ":[\"" * key * "\"]"

    if haskey(dict, key)
        bot = dict[key]
        if bot isa Dict && haskey(bot, "dir") && haskey(bot, "cmd")
            cmdRaw = bot["cmd"]
            dirRaw = bot["dir"]
            if cmdRaw isa String && dirRaw isa String
                cmd = cmdRaw
                dir = dirRaw
            else
                print_diy("e", "Dict keys are not String: " * postfix)
            end
        else
            print_diy("e", "Dict format err: " * postfix)
        end
    else
        print_diy("e", "not found: " * postfix)
    end

    dir, cmd
end

function bot_get()::Cmd
    cmd = ``

    botConfig = bot_config()
    if length(botConfig) == 0
        return cmd
    end

    botDefault, botDict = bot_list(botConfig)
    if length(botDefault) == 0 || length(botDict) == 0
        return cmd
    end

    dirRaw, cmdRaw = bot_raw(botDefault, botDict)
    if cmdRaw == ""
        return cmd
    end

    dir = ispath(dirRaw) ? dirRaw : normpath(joinpath(REPO, dirRaw))
    cmdVector = convert(Vector{String}, split(cmdRaw))
      # otherwise there will be ' in command
    cmd = Cmd(Cmd(cmdVector), dir=dir, ignorestatus=true)
    print_diy("VastGo will run the command: ", cmdRaw)
    print_diy("in the directory: ", dirRaw)
    
    if isprogram(cmdVector[1], dir)
        return cmd
    else 
        return ``
    end
end

function bot_ready(proc::Base.Process)::Bool
    flag = true
    query(proc, "name")
    outInfo = reply(proc)

    if length(outInfo) > 1 && outInfo[1] == '='
        name = outInfo[3:end-1]
        if name == "Leela Zero"
            println(readuntil(proc.err, "MiB.", keep=true))
        end
        if name == "KataGo"
            println(readuntil(proc.err, "loop", keep=true))
        end
        print_diy("i", "GTP ready")
    else
        errInfo = reply(proc.err)
        infoRaw = "stdout:\n" * outInfo * '\n' * "stderr:\n" * errInfo
        info = split_undo(split(infoRaw, '\n', keepempty=false))[1:end-1]
        print_diy("e", '\n' * info)
        #=for line in infoLines
            println(line)
        end=#
        flag = false
    end

    flag
end

#=
Why Base.PipeEndpoint() && run() or why not open()?
Because stderr is hard to talk with, source:
https://discourse.julialang.org/t/avoiding-readavailable-when-communicating-
with-long-lived-external-program/61611/25
=#
function bot_run(cmd::Cmd)::Tuple{Base.Process, Bool}
    flag = true
    inp = Base.PipeEndpoint()
    out = Base.PipeEndpoint()
    err = Base.PipeEndpoint()
                   
    proc = Base.Process(``, Ptr{Nothing}())
    try
        proc = run(cmd, inp, out, err; wait=false)
    catch
        print_diy("e", "no such file, directory or program")
        flag = false
    end
    
    if flag
        flag = bot_ready(proc)
    end
    
    proc, flag
end

function query(proc::Base.Process, sentence::String)
    println(proc, sentence)
end

function reply(proc::Union{Base.Process, Base.PipeEndpoint})::String
    #paragraph = readuntil(proc, "\n\n") * '\n'  # + 0.25s ?
    paragraph = ""
    while true
        line = readline(proc)
        line == "" ? break : paragraph = paragraph * line * '\n'
    end
    paragraph
end

function name_get(proc::Base.Process)::String
    query(proc, "name")
    reply(proc)[3:end-1]
end

function version_get(proc::Base.Process)::String
    query(proc, "version")
    reply(proc)[3:end-1]
end 

function leelaz_showboard(proc::Base.Process)::String
    readuntil(proc.err, "Passes:")
    paragraphErr = "Passes:" * readuntil(proc.err, "\n") * '\n'
    while true
        line = readline(proc.err)
        line == "" ? continue : paragraphErr = paragraphErr * line * '\n'
        if occursin("White time:", line)
            break
        end
    end
    paragraphErr
end

function leelaz_showboardf(paragraph::String)::NamedTuple  # f: _format
    lines = split(paragraph, '\n')
    
    infoUp = lines[2:3]
    infoDown = lines[25:27]
    infoAll = cat(infoUp, infoDown, dims=1)
    info = split_undo(infoAll)

    m = n = 19
    linesPosition = lines[5:23]
    c = Vector{String}()
    for line in linesPosition
        line = split(line, [' ', ')', '('])
        for char in line
            if char == "O"
                push!(c, "rgba(255,255,255,1)")
            elseif char == "X"
                push!(c, "rgba(0,0,0,1)")
            elseif char in [".", "+"]
                push!(c, "rgba(0,0,0,0)")
            else 
                continue
            end
        end
    end
    x = repeat([p for p in 1:n], m)
    y = [p for p in m:-1:1 for q in 1:n]

    (x=x, y=y, c=c, i=info)
end

function gnugo_showboardf(paragraph::String)::NamedTuple  # f: _format
    r = r"captured \d{1,}"
    lines = split(paragraph, '\n')
    
    l = length(lines[2]) + 2
    captured = Vector{String}()

    m = length(lines) - 4
    n = length(split(lines[2]))
    #position = zeros(Int64, m, n)
    i = m
    j = 1
    linesPosition = lines[3:2+m]

    c = Vector{String}()

    for line in linesPosition
        if length(line) > l + 20
            captured = cat(captured, match_diy([r, r"\d{1,}"], [line]), dims=1)
        end
        line = split(line)[2:n+1]
        for char in line
            if char == "O"
                #position[i,j] = 1
                push!(c, "rgba(255,255,255,1)")
                j = j + 1
            elseif char == "X"
                #position[i,j] = -1
                push!(c, "rgba(0,0,0,1)")
                j = j + 1
            elseif char in [".", "+"]
                push!(c, "rgba(0,0,0,0)")
                j = j + 1
            elseif j == n
                break
            else 
                continue
            end
        end
        j = 1
        i = i - 1
    end 
    #println(position)

    x = repeat([p for p in 1:n], m)
    y = [p for p in m:-1:1 for q in 1:n]
    
    blackCaptured = captured[1]
    whiteCaptured = captured[2]

    info = """
    B stones captured: $blackCaptured
    W stones captured: $whiteCaptured
    """

    (x=x, y=y, c=c, i=info)
end

function katago_showboardf(paragraph::String)::NamedTuple
    lines = split(paragraph, '\n')

    infoUp = lines[1][3:end]

    n = length(split(lines[2]))
    m = 3
    c = Vector{String}()
    while lines[m][1] in "1 "
        for char in split(lines[m][4:end], [' ', '1', '2', '3'])
            if char == "O"
                push!(c, "rgba(255,255,255,1)")
            elseif char == "X"
                push!(c, "rgba(0,0,0,1)")
            elseif char == "."
                push!(c, "rgba(0,0,0,0)")
            else 
                continue
            end
        end
        m=m+1
    end
    m = m - 3
    x = repeat([p for p in 1:n], m)
    y = [p for p in m:-1:1 for q in 1:n]

    infoDown = lines[m+3:m+6]
    infoAll = cat(infoUp, infoDown, dims=1)
    info = split_undo(infoAll)

    (x=x, y=y, c=c, i=info)
end

function showboard_get(proc::Base.Process)::Tuple{String,String}
    paragraph = reply(proc)
    name = name_get(proc)
    if name == "Leela Zero"
        paragraph = paragraph * leelaz_showboard(proc)
    end
    #println(paragraph)
    paragraph, name
end 

function showboard_format(proc::Base.Process)::NamedTuple
    paragraph, name = showboard_get(proc)
    board = NamedTuple()

    if name == "GNU Go"
        board = gnugo_showboardf(paragraph)
    end
    if name == "Leela Zero"
        board = leelaz_showboardf(paragraph)
    end
    if name == "KataGo"
        board = katago_showboardf(paragraph)
    end
    #println(dump(board))
    #board = "=\n$board\n"

    board
end

function gtp_qr(proc::Base.Process, sentence::String)::Bool
    query(proc, sentence)
    println(reply(proc))
    true
end

function gtp_showboard(proc::Base.Process, sentence::String)::Bool
    query(proc, sentence)
    paragraph, name = showboard_get(proc)
    println(paragraph)
    true
end

function gtp_showboardf(proc::Base.Process, sentence::String)::Bool
    println('=')
    sentence = sentence[1:end-1]
    query(proc, sentence)
    println(showboard_format(proc))
    println()

    true
end

function gtp_analyze(proc::Base.Process, sentence::String)::Bool
    query(proc, sentence)
    line = readline(proc)
    println(line)
    flag = line[1]
    if flag == '='
        println(readline(proc))
    end
    query(proc, "stop_analyze")
    reply(proc)
    println()

    true
end

function gtp_valid(proc::Base.Process, sentence::String)::Bool
    println("? invalid command\n")
    true
end

function gtp_quit(proc::Base.Process, sentence::String)::Bool
    gtp_qr(proc, sentence)
    close(proc)
    false
end

function gtp_loop(proc::Base.Process, sentence::String)::Bool
    sentenceVector = split(sentence, [' ','-'], keepempty=true)
    words = [       "",   "quit",   "showboard",   "showboardf",   "analyze"]
    funs =  [gtp_valid, gtp_quit, gtp_showboard, gtp_showboardf, gtp_analyze]
    fun = gtp_qr

    i = 1
    for word in words
        if word in sentenceVector
            fun = funs[i]
            break
        end
        i = i + 1
    end

    fun(proc, sentence)
end

function terminal()
    cmd = bot_get()
    if cmd != ``
        proc, run = bot_run(cmd)
        while run
            sentence = readline()
            run = gtp_loop(proc, sentence)
            #sentence == "quit" ? break : continue # - 1s
            #gtp_loop(proc, "showboardf")
            #run = gtp_loop(proc, "quit")
        end
    end
end

if abspath(PROGRAM_FILE) == joinpath(SRC, "terminal.jl")
    terminal()
end

#= Speedup

using Profile
@profile include("path/to/terminal.lj")  # run() can not use
julia> quit

open("some.txt", "w") do io
    Profile.print(IOContext(io, :displaysize => (24, 500)), combine=true)
end
Profile.clear()

overhead*count  :line  ;fun    speedupable  seconds
8*126   :63     ;print_diy.printstyled   ~
25*55   :195    ;bot_run.run             x
184*184 :214    ;reply.readuntil         v  0/0.25
15*19   :461    ;main.readline           X
18*18   :427    ;gtp_loop.[fun...]       ~  0.12 (simplify)
8*131   :431    ;gtp.loop.intersect      v  0.16
8*5     :398    ;gtp_showboard.println   ?
bot_showboardf.return.Tuple>>Dict        V  0.03
bot_config.botConfig.init=Dict()         V  0.10
utility.jl.print_diy.c.Int>>Symbol       V  0.30

TODO: speedup showboardf()
=#
