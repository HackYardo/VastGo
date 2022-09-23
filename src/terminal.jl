#import JSON3  
    # JSON3.read(), JSON3.write(), JSON3.pretty()
#include("utility.jl")  
    # match_diy(), split_undo()

Base.convert(::Type{NamedTuple}, t::Tuple)  = (dir =     t[1], cmd =     t[2])
Base.convert(::Type{NamedTuple}, d::Dict)   = (dir = d["dir"], cmd = d["cmd"])
Base.convert(::Type{NamedTuple}, v::Vector) = (dir =     v[1], cmd =     v[2])

function bot_config()
    include_string(Main, readchomp("data/config.txt"))
    #=botDict = Dict(

"g"   =>  Dict("dir" =>"",
          "cmd" => "gnugo --mode gtp"),

"l"   =>  Dict("dir" =>"../networks/",
          "cmd" => "leelaz --cpu-only -g -v 8 -w w6.gz"),

"k"   =>  Dict("dir" =>"../KataGo1.11Eigen/",
          "cmd" => "./katago gtp -config v8t5.cfg -model ../networks/m6.txt.gz"),

"k2"  =>  Dict("dir" =>"../KataGo1.11Eigen/",
          "cmd" => "./katago gtp -config v8t5.cfg -model ../networks/m20.bin.gz"),

"ka"  =>  Dict("dir" =>"../KataGo1.11AVX2/",
          "cmd" => "./katago gtp -config v8t5.cfg -model ../networks/m6.txt.gz"),

"ka2" => Dict("dir" => "../KataGo1.11AVX2/",
              "cmd" => "./katago gtp -config v8t5.cfg \
               -model ../networks/m20.bin.gz"),

"ks"  => Dict("dir" =>"../KataGo1.11Eigen/",
          "cmd" => "./katago gtp -config v8t5.cfg \
           -override-config defaultBoardSize=8,maxVisits=64 \
           -model ../networks/m6.txt.gz")
)

# These bots will run if no args:
#   shell> julia xxx.jl
botDefault = ["g", "k"]=#
    return botDefault, botDict
end

function split_undo(v::Vector{SubString{String}})::String
    s = ""
    for el in v 
        s = s * el * "\n" 
    end 
    s
end

function match_diy(r::Regex, lines::Vector)
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
function match_diy(r::Vector{Regex}, lines::Vector)
    v = Vector{String}()
    for i in r
        v = match_diy(i, lines)
        lines = v 
    end
    v 
end

function bot_get()
    mid1 = "[ Error: "
    mid2 = "wrong type"
    botDefault, botDict = bot_config()

    botToRun = ""
    if length(ARGS) == 0 
        botToRun = botDefault[1]
    else
        botToRun = ARGS[1]
    end
    
    bot = botDict[botToRun]
    #=
    type = typeof(bot)
    if type == Type{NamedTuple}
        return bot
    elseif type in [Tuple, Vector]
        return (dir = bot[1], cmd = bot[2])
    elseif type == Dict
        return (dir = bot["dir"], cmd = bot["cmd"])
    else
        printstyled("[ ERROR: ", color=:red, bold=true)
        println("wrong type")
        exit()
    end
    =#

    botValid = NamedTuple{}()

    try
        botValid = convert(NamedTuple, bot)
    catch
        printstyled(mid1, color=:red, bold=true)
        println(mid2)
        exit()
    end
    dir = botValid.dir
    cmd = botValid.cmd
    return dir, cmd
end 

function bot_ready(proc::Base.Process)
    mid1 = "!"
    mid2 = "[ Error:\n"

    query(proc, mid1)
    outInfo = reply(proc)
    
    if outInfo[1] != '?'
        errInfo = reply(proc.err)
        info = "stdout:\n$outInfo\nstderr:\n$errInfo"
        infoLines = split(info, "\n", keepempty=false)
        printstyled(mid2, color=:red, bold=true)
        for line in infoLines
            println(line)
        end
        exit()
    end

    #println("$proc")
end

#=
Why Base.PipeEndpoint() && run() or why not open()?
Because stderr is hard to talk with, source:
https://discourse.julialang.org/t/avoiding-readavailable-when-communicating-
with-long-lived-external-program/61611/25
=#
function bot_run(dir, cmd)::Base.Process
    mid1 = "VastGo will run the command: "
    mid2 = "in the directory: "
    mid3 = "[ Error:\n"
    mid4 = "no such file or directory"

    inp = Base.PipeEndpoint()
    out = Base.PipeEndpoint()
    err = Base.PipeEndpoint()
    
    cmdVector = split(cmd) # otherwise there will be ' in command
    command = Cmd(`$cmdVector`, dir=dir)
    print(mid1)
    printstyled(cmd, color=6)
    println()
    print(mid2)
    printstyled(dir, color=6)
    println()
    #println(command)
    proc = Base.Process[]
    try
        process = run(command,inp,out,err;wait=false)
        push!(proc, process)
    catch
        printstyled(mid3, color=:red, bold=true)
        println(mid4)
        exit()
    end
    process = proc[1]
    
    bot_ready(process)
    
    return process
end

function bot_end(proc::Base.Process)
    println(reply(proc))
    close(proc)
end

function gtp_valid(sentence::String)::Bool
    if "" in split(sentence, keepempty=true)
        return false
    else 
        return true
    end 
end 

query((proc, sentence)) = query(proc, sentence)
function query(proc::Base.Process, sentence::String)
    println(proc, sentence)
end

function reply(proc::Union{Base.Process, Base.PipeEndpoint})
    mid = "\n\n"
    paragraph = readuntil(proc, mid)
    return "$paragraph\n"
end

function name_get(proc::Base.Process)
    mid = "name"

    query(proc, mid)
    reply(proc)[3:end-1]
end

function version_get(proc::Base.Process)
    mid = "version"

    query(proc, mid)
    reply(proc)[3:end-1]
end 

function gtp_startup_info(proc::Base.Process)
    name = name_get(proc)
    if name == "Leela Zero"
        mid = "MiB."
        println(readuntil(proc.err, mid, keep=true))
    elseif name == "KataGo"
        mid = "loop"
        println(readuntil(proc.err, mid, keep=true))
    else
    end
end 

function gtp_ready(proc::Base.Process)
    mid1 = "[ Info: "
    mid2 = "GTP ready"
    gtp_startup_info(proc)
    printstyled(mid1, color=6, bold=true)
    println(mid2)
end 

function leelaz_showboard(proc::Base.Process)
    mid1 = "Passes:"
    mid2 = "\n"
    mid3 = "White time:"

    readuntil(proc.err, mid1)
    paragraphErr = mid1 * readuntil(proc.err, mid2) * mid2
    while true
        line = readline(proc.err)
        if line == ""
            continue
        end
        paragraphErr = paragraphErr * line * mid2
        if occursin(mid3, line)
            break
        end
    end
    paragraphErr
end

function leelaz_showboardf(paragraph)  # f: _format
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

function gnugo_showboardf(paragraph)  # f: _format
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

function katago_showboardf(paragraph)
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

function showboard_get(proc::Base.Process)
    paragraph = reply(proc)
    name = name_get(proc)
    if name == "Leela Zero"
        paragraph = paragraph * leelaz_showboard(proc)
    end
    #println(paragraph)
    paragraph
end 

function showboard_format(proc::Base.Process)
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
    "=\n$board\n"
end

function gtp_analyze(proc::Base.Process)
    println(readline(proc))
    println(readline(proc))
    query(proc, "z")
    reply(proc)
    println()
end

#=
function gtp_loop(procs::Vector{Base.Process})
    
    proc = procs[1]
    while true 
        sentence = readline()
        if ! gtp_valid(sentence)
            println("? invalid command\n")
            continue
        end 
        sentenceVector = split(sentence)
        if "switch" in sentenceVector
            include_string("proc = $(sentenceVector[2])")
        end
            
end =#
function gtp_loop(proc::Base.Process)
    while true
        sentence = readline()
        sentenceVector = split(sentence)
        if ! gtp_valid(sentence)
            println("? invalid command\n")
        elseif "quit" in sentenceVector
            query(proc, sentence)
            bot_end(proc)
            break
        elseif "showboard" in sentenceVector
            query(proc, sentence)
            proc |> showboard_get |> println
        elseif "showboardf" in sentenceVector
            (proc, sentence[1:end-1]) |> query
            proc |> showboard_format |> println
        elseif occursin("analyze", sentence)
            query(proc, sentence)
            gtp_analyze(proc)
        else
            query(proc, sentence)
            println(reply(proc))
        end
    end
end

function terminal()
    dir, cmd = bot_get()
    botProcess = bot_run(dir, cmd)
    gtp_ready(botProcess)
    gtp_loop(botProcess)
end

terminal()
