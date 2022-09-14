include("utility.jl")  # match_diy(), split_undo()

function bot_get()
    bots = Dict(
"g"   => (dir = "", 
          cmd = "gnugo --mode gtp"),
"l"   => (dir = "../networks/", 
          cmd = "leelaz --cpu-only -g -v 8 -w w6.gz"),
"k"   => (dir = "../KataGo1.11Eigen/", 
          cmd = "./katago gtp -config v8t5.cfg -model ../networks/m6.txt.gz"),
"k2"  => (dir = "../KataGo1.11Eigen/", 
          cmd = "./katago gtp -config v8t5.cfg -model ../networks/m20.txt.gz"),
"ka"  => (dir = "../KataGo1.11AVX2/", 
          cmd = "./katago gtp -config v8t5.cfg -model ../networks/m6.txt.gz"),
"ka2" => (dir = "../KataGo1.11AVX2/", 
          cmd = "./katago gtp -config v8t5.cfg -model ../networks/m20.txt.gz")
)

    defaultBot = ["k"]

    id = ARGS[1]
    
    bots[id]
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
    print("VastGo will run the command: ")
    printstyled("$cmd\n", color=6)
    print("in the directory: ")
    printstyled("$dir\n", color=6)
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
        println(readuntil(proc.err, "MiB.", keep=true))
    elseif name == "KataGo"
        println(readuntil(proc.err, "loop", keep=true))
    else
    end
end 

function gtp_ready(proc::Base.Process)
    gtp_startup_info(proc)
    printstyled("[ Info: ", color=6, bold=true)
    println("GTP ready")
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

    (m = m, n = n, x = x, y = y, c = c, i = info)
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

    (m = m, n = n, x = x, y = y, c = c, i = info)
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

    (m = m, n = n, x = x, y = y, c = c, i = info)
end

function showboard_get(proc::Base.Process; ifprint = true)
    paragraph = reply(proc)
    name = name_get(proc)
    if name == "Leela Zero"
        paragraph = paragraph * leelaz_showboard(proc)
    end
    if ifprint
        println(paragraph)
    end
    paragraph, name
end 

function showboard_format(proc::Base.Process; ifprint=true)
    board = NamedTuple()
    paragraph, name = showboard_get(proc; ifprint = false)
    if name == "GNU Go"
        board = gnugo_showboardf(paragraph)
    elseif name == "Leela Zero"
        board = leelaz_showboardf(paragraph)
    elseif name == "KataGo"
        board = katago_showboardf(paragraph)
    else
    end
    if ifprint
        println(dump(board))
        println()
    end 
    board 
end

function gtp_loop(proc::Base.Process)
    while true
        sentence = readline()
        if "exit" in split(sentence)
            if process_running(proc)
                query(proc, "quit")
                reply(proc)
            end
            println("= \n")
            break
        elseif process_exited(proc)
            println("= \n")
            continue
        elseif gtp_valid(sentence)
            query(proc, sentence)
        else 
            println("? invalid command\n")
            continue
        end 
        
        if "quit" in split(sentence)
            bot_end(proc)
        elseif "showboard" in split(sentence)
            proc |> showboard_get
        elseif "showboardf" in split(sentence)
            proc |> showboard_format
        else
            println(reply(proc))
        end
    end
end
