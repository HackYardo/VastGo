using TOML
#import JSON3  
    # JSON3.read(), JSON3.write(), JSON3.pretty()
#include("utility.jl")  
    # match_diy(), split_undo()

#Base.convert(::Type{NamedTuple}, t::Tuple)  = (dir =     t[1], cmd =     t[2])
#Base.convert(::Type{NamedTuple}, d::Dict)   = (dir = d["dir"], cmd = d["cmd"])
#Base.convert(::Type{NamedTuple}, v::Vector) = (dir =     v[1], cmd =     v[2])

function bot_config()::Tuple
    #include_string(Main, readchomp("data/config.txt"))
    botConfig = open("data/config.toml", "r") do io
        TOML.parse(io)
    end

    botDefault = botConfig["default"]
    botDict = delete!(botConfig, "default")
    #println(typeof(botDict))
    return botDefault, botDict
end

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

function bot_get()::Tuple{String, String, Bool}
    dir = ""
    cmd = ""
    flag = true
    botDefault, botDict = bot_config()

    key = ""
    if length(ARGS) == 0 
        key = botDefault[1]
    else
        key = ARGS[1]
    end

    bot = botDict[key]
    if bot isa NamedTuple && hasproperty(bot, :dir) && hasproperty(bot, :cmd)
        dir = bot.dir
        cmd = bot.cmd
    elseif (bot isa Tuple || bot isa Vector) && length(bot) > 1
        dir = bot[1]
        cmd = bot[2]
    elseif bot isa Dict && "dir" in keys(bot) && "cmd" in keys(bot)
        dir = bot["dir"]
        cmd = bot["cmd"]
    else
        printstyled("[ Error: ", color=:red, bold=true)
        println("wrong type")
        flag = false
    end

    return dir, cmd, flag
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
            println(readuntil(proc.err, "Mib.", keep=true))
        end
        if name == "KataGo"
            println(readuntil(proc.err, "loop", keep=true))
        end
        printstyled("[ Info: ", color=6, bold=true)
        println("GTP ready")
    end

    return flag
end

#=
Why Base.PipeEndpoint() && run() or why not open()?
Because stderr is hard to talk with, source:
https://discourse.julialang.org/t/avoiding-readavailable-when-communicating-
with-long-lived-external-program/61611/25
=#
function bot_run(dir::String, cmd::String)::Tuple{Base.Process, Bool}
    flag = true
    inp = Base.PipeEndpoint()
    out = Base.PipeEndpoint()
    err = Base.PipeEndpoint()
    
    cmdVector = split(cmd) # otherwise there will be ' in command
    command = Cmd(`$cmdVector`, dir=dir)
    print("VastGo will run the command: ")
    printstyled(cmd, color=6)
    println()
    print("in the directory: ")
    printstyled(dir, color=6)
    println()

    process = Base.Process(``, Ptr{Nothing}())
    try
        process = run(command, inp, out, err; wait=false)
        flag = bot_ready(process)
    catch
        printstyled("[ Error: ", color=:red, bold=true)
        println("no such file or directory")
        flag = false
    end

    return process, flag
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

function gtp_loop((proc, sentence)::Tuple{Base.Process, String})::Bool
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

function terminal()
    dir, cmd, get = bot_get()
    if get
        proc, run = bot_run(dir, cmd)
        while run
            sentence = readline()
            run = (proc, sentence) |> gtp_loop
            #sentence == "quit" ? break : continue #**save 1s, 1.5a, 80Mib**
        end
    end
end

terminal()
