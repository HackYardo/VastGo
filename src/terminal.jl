import JSON3  # JSON3.read(), JSON3.write(), JSON3.pretty()
include("utility.jl")  # match_diy()

function bot_get()
    GNUGO = (dir="", cmd="gnugo --mode gtp --boardsize 3")
    LEELAZ = (dir="../lzweights/", cmd="leelaz --cpu-only -g -v 8 -w w6.gz")
    KATAGO = (dir="../katago1.11avx2/", cmd="./katago gtp -config \
        custom_gtp.cfg -model models/m6.txt.gz")
    botDict = Dict("g"=>GNUGO, "l"=>LEELAZ, "k"=>KATAGO)
    
    botDict[ARGS[1]]
end 

function bot_ready(proc::Base.Process)
    query(proc, "!")
    outInfo = reply(proc)
    
    if outInfo[1] != '?'
        errInfo = reply(proc.err)
        @info "stdout:\n$outInfo"
        @info "stderr:\n$errInfo"
        @error "Please look at the above ↑↑↑"
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
function bot_run(; dir="", cmd="")::Base.Process
    inp = Base.PipeEndpoint()
    out = Base.PipeEndpoint()
    err = Base.PipeEndpoint()
    
    cmdVector = split(cmd) # otherwise there will be ' in command
    command = Cmd(`$cmdVector`, dir=dir)
    println("VastGo will run the command: $cmd\nin the directory: $dir")
    #println(command)

    process = run(command,inp,out,err;wait=false)
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

function query(proc::Base.Process, sentence::String)
    println(proc, sentence)
end

function reply(proc::Union{Base.Process, Base.PipeEndpoint})
    paragraph = readuntil(proc, "\n\n")
    return "$paragraph\n"
end

function name_get(proc::Base.Process)
    query(proc, "name")
    reply(proc)[3:end-1]
end

function version_get(proc::Base.Process)
    query(proc, "version")
    reply(proc)[3:end-1]
end 

function gtp_startup_info(proc::Base.Process)
    name = name_get(proc)
    if name == "Leela Zero"
        info = readuntil(proc.err, "MiB.", keep=true)
    elseif name == "KataGo"
        info = readuntil(proc.err, "loop", keep=true)
    else
        info = name
    end
    println(info)
end 

function gtp_ready(proc::Base.Process)
    gtp_startup_info(proc)
    @info "GTP ready"
end 

function leelaz_showboard(proc::Base.Process)
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

function showboard_get(proc::Base.Process)
    paragraph = reply(proc)
    name = name_get(proc)
    if name == "Leela Zero"
        paragraph = paragraph * leelaz_showboard(proc)
    end
    println(paragraph)
    paragraph, name
end 

function gnugo_showboardf(paragraph)  # f: _format
    r = r"captured \d{1,}"
    lines = split(paragraph, '\n')
    
    l = length(lines[2]) + 2
    v = Vector{String}()

    m = length(lines) - 4
    n = length(split(lines[2]))
    position = zeros(Integer, m, n)
    i = m
    j = 1
    linesPosition = lines[3:2+m]
    traceMatrix = (
        x = Matrix{Integer}(undef, m, n), 
        y = Matrix{Integer}(undef, m, n), 
        c = Matrix{String}(undef, m, n)
        )
    for line in linesPosition
        if length(line) > l + 20
            v = cat(v, match_diy([r, r"\d{1,}"], [line]), dims=1)
        end
        line = split(line)[2:n+1]
        for char in line
            traceMatrix.x[i,j] = i 
            traceMatrix.y[i,j] = j
            if char == "O"
                position[i,j] = 1
                traceMatrix.c[i,j] = "rgba(255,255,255,1)"
                j = j + 1
            elseif char == "X"
                position[i,j] = -1
                traceMatrix.c[i,j] = "rgba(0,0,0,1)"
                j = j + 1
            elseif char in [".", "+"]
                traceMatrix.c[i,j] = "rgba(0,0,0,0)"
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
    println(position)
    println(traceMatrix.x)
    println(traceMatrix.y)
    println(traceMatrix.c)
    positionForJSON = collectcol(position)
    #=
    println(positionForJSON)
    #println(v)
    
    boardJSON = JSON3.write(
        (position = positionForJSON, blackCaptured = v[1], whiteCaptured=v[2])
        )
    board = (namedtuple = JSON3.read(boardJSON, NamedTuple), 
        dict = JSON3.read(boardJSON, Dict), 
        json = boardJSON
        )
    println(board.namedtuple)
    println(board.dict)
    println(board.json)
    JSON3.pretty(board.json)
    #buff = IOBuffer()
    #redirect_stdout(JSON3.pretty(board.json), buff)
    #println(buff)
    =#
    
    #return board
end
collectrows(x::AbstractMatrix) = collect.(eachrow(x))
collectcol(A::AbstractMatrix) = collect.(eachcol(A'))'
function showboard_format(proc::Base.Process)
    paragraph, name = showboard_get(proc)
    if name == "GNU Go"
        #gnugo_showboardf(paragraph)
    elseif name == "Leela Zero"
    elseif name == "KataGo"
    end
end

function gtp_loop(proc::Base.Process)
    while true
        sentence = readline()
        if gtp_valid(sentence)
            query(proc, sentence)
        else 
            println("? invalid command\n")
            continue
        end 
        
        if occursin("quit", sentence)
            bot_end(proc)
            break
        elseif occursin("showboard", sentence)
            showboard_format(proc)
        else
            println(reply(proc))
        end
    end
end

function terminal()
    bot = bot_get()
    botProcess = bot_run(dir=bot.dir, cmd=bot.cmd)
    gtp_ready(botProcess)
    gtp_loop(botProcess)
end

terminal()
