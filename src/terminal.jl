function bot_get()
    GNUGO = (dir="", cmd="gnugo --mode gtp")
    LEELAZ = (dir="../lzweights/", cmd="leelaz --cpu-only -g -v 8 -w w6.gz")
    KATAGO = (dir="../katago1.11avx2/", cmd="./katago gtp -model \
        models/m6.txt.gz")
    botDict = Dict("gnugo"=>GNUGO, "leelazero"=>LEELAZ, "katago"=>KATAGO)
    
    botDict[ARGS[1]]
end 

#=
Why Base.PipeEndpoint() && run() or why not open()?
Because stderr is hard to talk with, source:
https://discourse.julialang.org/t/avoiding-readavailable-when-communicating-
with-long-lived-external-program/61611/25
=#
function bot_run(; dir="", cmd="")
    inp = Base.PipeEndpoint()
    out = Base.PipeEndpoint()
    err = Base.PipeEndpoint()
    
    cmdVector = split(cmd) # otherwise there will be ' in command
    command = Cmd(`$cmdVector`, dir=dir)
    cmdString = "$command"
    println("Julia will run the command:\n$cmdString")
    
    process = run(command,inp,out,err;wait=false)
    
    query(process, "name")
    name = reply(process)
    if name[1] != '='
        errInfo = readchomp(process.err)
        @info "stdout:\n$name"
        @info "stderr:\n$errInfo"
        @error "Please look at the above ↑↑↑"
        exit()
    end
    
    #println("$process")
    return process
end

function bot_end(proc::Base.Process)
    println(reply(proc))
    close(proc)
end

function isvalid(sentence::String)
    if "" in split(sentence, keepempty=true)
        return false
    else 
        return true
    end 
end 

function query(proc, sentence::String)
    println(proc, sentence)
end

function reply(proc)
    paragraph = readuntil(proc, "\n\n")
    return "$paragraph\n"
end

function name_get(proc)
    query(proc, "name")
    reply(proc)[3:end-1]
end

function version_get(proc)
    query(proc, "version")
    reply(proc)[3:end-1]
end 

function gtp_startup_info(proc)
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

function gtp_ready(proc)
    gtp_startup_info(proc)
    @info "GTP ready"
end 

function leelaz_showboard(proc)
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

function showboard_format(proc)
    paragraph, name = showboard_get(proc)
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
