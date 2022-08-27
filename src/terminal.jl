function bot_get()
    GNUGO = (dir="", cmd="gnugo --mode gtp")
    LEELAZ = (dir="../lzweights/", cmd="leelaz --cpu-only -g -v 8 -w w6.gz")
    KATAGO = (dir="../katago1.11avx2/", cmd="./katago gtp -model \
        models/m6.txt.gz")
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

    println("$proc")
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
    println("VastGo will run the command \n\t$cmd\nin the direetory\n\t$dir")
    #println(command)
    println("Please waiting...")

    process = run(command,inp,out,err;wait=false)
    
    bot_ready(process)
    
    return process
end

function bot_end(proc::Base.Process)
    println(reply(proc))
    close(proc)
end

function isvalid(sentence::String)::Bool
    if "" in split(sentence, keepempty=true)
        return false
    else 
        return true
    end 
end 

function query(proc::Base.Process, sentence::String)
    println(proc, sentence)
end

function reply(proc::Union{Base.Process, Base.PipeEndpoint})::String
    paragraph = readuntil(proc, "\n\n")
    return "$paragraph\n"
end

function name_get(proc::Base.Process)::SubString
    query(proc, "name")
    reply(proc)[3:end-1]
end

function version_get(proc::Base.Process)::SubString
    query(proc, "version")
    reply(proc)[3:end-1]
end 

function gtp_startup_info(proc::Base.Process)
    name = name_get(proc)
    if name == "Leela Zero"
        info = readuntil(proc.err, "MiB.", keep=true)
    elseif name == "KataGo"
        info = readuntil(proc.err, "GTP ready")[1:end-1]
    else
        info = name
    end
    println(info)
end 

function gtp_ready(proc::Base.Process)
    gtp_startup_info(proc)
    @info "GTP ready"
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

function showboard_get(proc::Base.Process)::Tuple
    paragraph = reply(proc)
    name = name_get(proc)
    if name == "Leela Zero"
        paragraph = paragraph * leelaz_showboard(proc)
    end
    println(paragraph)
    paragraph, name
end 

function showboard_format(proc::Base.Process)
    paragraph, name = showboard_get(proc)
end

function gaming()
    
end

function terminal()
    bot = bot_get()
    botProcess = bot_run(dir=bot.dir, cmd=bot.cmd)
    gtp_ready(botProcess)
    while true
        sentence = readline()
        if isvalid(sentence)
            query(botProcess, sentence)
        else 
            println("? invalid command\n")
            continue
        end 
        
        if occursin("quit", sentence)
            bot_end(botProcess)
            break
        elseif occursin("showboard", sentence)
            showboard_format(botProcess)
        else
            println(reply(botProcess))
        end
    end
end

terminal()
