using TOML
#import JSON3  # JSON3.read(), JSON3.write(), JSON3.pretty()
#include("utility.jl")  # match_diy(), split_undo()

const FILE   = @__FILE__
const SRC    = dirname(FILE)
const VASTGO = normpath(joinpath(SRC, ".."))
const DATA   = joinpath(VASTGO, "data")
const CONFIG = joinpath(DATA, "config.toml")

function findindex(element, collection)::Vector{Int64}
    m = 1
    n = Vector{Int64}()
    for el in collection
        if el == element
            n = cat(n, m, dims=1)
        end
        m = m + 1
    end
    n
end

function split_undo(v::Vector{SubString{String}})::String
    s = ""
    for el in v 
        s = s * el * "\n" 
    end 
    s
end

function match_diy(r::Regex, lines::Vector)::Vector{String}
    mlines = match.(r, lines)
    v = Vector{String}()
    for line in mlines
        if isnothing(line)
            continue
        else 
            v = cat(v, line.match, dims=1)
        end
    end
    v 
end
function match_diy(r::Vector{Regex}, lines::Vector)::Vector{String}
    v = Vector{String}()
    for i in r
        v = match_diy(i, lines)
        lines = v 
    end
    v 
end

function print_info(str1::String, str2::String; ln::Bool=true, flag::Bool=true, c::Union{Int64,Symbol}=6, b::Bool=true)
    if ln
        str2 = str2 * '\n'
    end
    if flag
        printstyled(str1, color=c, bold=b)
        print(str2)
    else 
        print(str1)
        printstyled(str2, color=c, bold=b)
    end
end

function bot_key(default::String)::String
    if length(ARGS) != 0 
        default = ARGS[1]
    end
    default
end

function bot_config(path::String)::Tuple{Dict, Bool}
    flag = true
    #botConfig = Dict()
    botConfig = Dict(
        "default" => ["g"], 
        "g"       => Dict(
            "cmd" => "gnugo --mode gtp", 
            "dir" => ""
        )
    )
    
    if ispath(path)
            botConfig = TOML.tryparsefile(path)
            if botConfig isa TOML.ParserError
                errType = botConfig.type
                errRow = botConfig.line 
                errCol = botConfig.column
                
                info = errType * " at " * path * ':' * errRow * ',' * errCol
                printstyled("[ Error: ", info, c=:red)
                flag = false
            end
    else
        info = "config file not found: " * path
        print_info("[ Error: ", info, c=:red)
        flag = false
    end
    
    botConfig, flag
end

function bot_raw(botConfig::Dict)::Tuple{String,String}
    dirRaw = ""
    cmdRaw = ""
    
    botDefault = botConfig["default"][1]
    botDict = delete!(botConfig, "default")
    key = bot_key(botDefault)
    if haskey(botDict, key)
        bot = botDict[key]
        if typeof(bot) == Dict{String,Any} && haskey(bot, "dir") && haskey(bot, "cmd")
            cmdRaw = bot["cmd"]
            dirRaw = bot["dir"]
            if ! ( cmdRaw isa String || dirRaw isa String )
                info = cmdRaw * " or " * dirRaw * " of " * key * " is not String: " * CONFIG
                print_info("[ Error: ", info, c=:red)
            end 
        else 
            info = bot * " Dict format or key err : " * CONFIG
            print_info("[ Error: ", info, c=:red)
        end 
    else 
        info = key * " not found: " * CONFIG
        print_info("[ Error: ", info, c=:red)
    end
    
    dirRaw, cmdRaw
end
function bot_get(botConfig::Dict)::Tuple{Cmd, Bool}
    flag = true
    cmd = ``
    
    dirRaw, cmdRaw = bot_raw(botConfig)
    if dirRaw == "" && cmdRaw == ""
        flag = false
    else
        dir = ispath(dirRaw) ? dirRaw : normpath(joinpath(VASTGO, dirRaw))
        cmdVector = Cmd(convert(Vector{String}, split(cmdRaw)))  # otherwise there will be ' in command
        cmd = Cmd(cmdVector, dir=dir, ignorestatus=true)
    
        print_info("VastGo will run the command: ", cmdRaw, flag=false, b=false)
        print_info("in the directory: ", dir, flag=false, b=false)
    end 
    
    cmd, flag
end

function bot_ready(proc::Base.Process)::Bool
    flag = true
    query(proc, "name")
    outInfo = reply(proc)
    name = outInfo[3:end-1]
    
    if outInfo[1] != '='
        errInfo = reply(proc.err)
        info = "stdout:\n$outInfo\nstderr:\n$errInfo"
        infoLines = split(info, "\n", keepempty=false)
        printstyled("[ Error:\n", color=:red, bold=true)
        for line in infoLines
            println(line)
        end
        flag = false
    else
        if name == "Leela Zero"
            println(readuntil(proc.err, "MiB.", keep=true))
        end
        if name == "KataGo"
            println(readuntil(proc.err, "loop", keep=true))
        end
        print_info("[ Info: ", "GTP ready")
    end

    return flag
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
        print_info("[ Error: ", "no such file, directory or program", c=:red)
        flag = false
    end
    
    if flag
        flag = bot_ready(proc)
    end
    
    return proc, flag
end

query((proc, sentence)::Tuple{Base.Process, String}) = query(proc, sentence)
function query(proc::Base.Process, sentence::String)
    println(proc, sentence)
end

function reply(proc::Union{Base.Process, Base.PipeEndpoint})::String
    paragraph = readuntil(proc, "\n\n") * "\n"
    paragraph
end

function name_get(proc::Base.Process)::String
    query(proc, "name")
    name = reply(proc)[3:end-1]
    name
end

function version_get(proc::Base.Process)::String
    query(proc, "version")
    version = reply(proc)[3:end-1]
    version
end 

function leelaz_showboard(proc::Base.Process)::String
    readuntil(proc.err, "Passes:")
    paragraphErr = "Passes:" * readuntil(proc.err, "\n") * "\n"
    while true
        line = readline(proc.err)
        if line == ""
            continue
        end
        paragraphErr = paragraphErr * line * "\n"
        if occursin("White time:", line)
            break
        end
    end
    paragraphErr
end

function leelaz_showboardf(paragraph::String)::NamedTuple  # f: _format
    lines = split(paragraph, "\n")
    
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

    (x = x, y = y, c = c, i = info)
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

    (x = x, y = y, c = c, i = info)
end

function katago_showboardf(paragraph::String)::NamedTuple
    lines = split(paragraph, "\n")

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

    (x = x, y = y, c = c, i = info)
end

function showboard_get(proc::Base.Process)::String
    paragraph = reply(proc)
    name = name_get(proc)
    if name == "Leela Zero"
        paragraph = paragraph * leelaz_showboard(proc)
    end
    #println(paragraph)
    paragraph
end 

function showboard_format(proc::Base.Process)::String
    paragraph = showboard_get(proc)
    name = name_get(proc)
    board = NamedTuple()
    if name == "GNU Go"
        board = gnugo_showboardf(paragraph)
    elseif name == "Leela Zero"
        board = leelaz_showboardf(paragraph)
    elseif name == "KataGo"
        board = katago_showboardf(paragraph)
    else
    end
    #println(dump(board))
    boardf = "=\n$board\n"

    boardf
end

function gtp_qr((proc, sentence)::Tuple{Base.Process, String})
    query(proc, sentence)
    println(reply(proc))
end

function gtp_quit((proc, sentence)::Tuple{Base.Process, String})
    query(proc, sentence)
    println(reply(proc))
    close(proc)
end

function gtp_showboard((proc, sentence)::Tuple{Base.Process, String})
    query(proc, sentence)
    proc |> showboard_get |> println
end

function gtp_showboardf((proc, sentence)::Tuple{Base.Process, String})
    sentence = sentence[1:end-1]
    (proc, sentence) |> query
    proc |> showboard_format |> println
end

function gtp_analyze((proc, sentence)::Tuple{Base.Process, String})
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
end

function gtp_loop(proc::Base.Process, sentence::String)::Bool
    flag = true
    funs =  [    gtp_quit, gtp_showboard, gtp_showboardf, gtp_analyze]
    words = ["",   "quit",   "showboard",   "showboardf",   "analyze"]
    sentenceVector = split(sentence, [' ','-'], keepempty=true)

    cross = sentenceVector ∩ words
    word = "qr"
    fun = gtp_qr
    if length(cross) != 0
        word = cross[1]
        if word == ""
            println("? invalid command\n")
        else
            fun = funs[findindex(word, words)[1]-1]
            (proc, sentence) |> fun

            if word == "quit"
                flag = false
            end
        end
    else
        (proc, sentence) |> fun
    end

    return flag
end

function main()
    cfg, set = bot_config(CONFIG)
    if set
        cmd, get = bot_get(cfg)
        if get
            proc, run = bot_run(cmd)
            while run
                sentence = readline()
                run = gtp_loop(proc, sentence)
                #sentence == "quit" ? break : continue #**save 1s, 1.5a, 80MiB**
            end
        end
    end
end

if abspath(PROGRAM_FILE) == FILE
    main()
end
