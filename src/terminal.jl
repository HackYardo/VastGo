function botget()
    GNUGO = (dir="", cmd="gnugo --mode gtp")
    LEELAZ = (dir="../lzweights/", cmd="leelaz --cpu-only -g -v 8 -w w6.gz")
    KATAGO = (dir="../KataGo/", cmd="./katago gtp -model kgmodels/m6.txt.gz")
    botDict = Dict("gnugo"=>GNUGO, "leelazero"=>LEELAZ, "katago"=>KATAGO)
    
    botDict[ARGS[1]]
end 

#=
Why Base.PipeEndpoint() && run() or why not open()?
Because stderr is hard to talk with, source:
https://discourse.julialang.org/t/avoiding-readavailable-when-communicating-with-long-lived-external-program/61611/25
=#
function botrun(; dir="", cmd="")
    inp = Base.PipeEndpoint()
    out = Base.PipeEndpoint()
    err = Base.PipeEndpoint()
    
    cmdVector = split(cmd) # otherwise there will be ' in command
    command = Cmd(`$cmdVector`, dir=dir)
    cmdString = "$command"
    println("Julia will run the command:\n$cmdString")
    println("IF NO \"GTP ready\", PLEASE TRY The command IN Cmd/Shell/Terminal, \
        OR CHECK data/bot.csv")
    process = run(command,inp,out,err;wait=false)
    #println("$process")
    return process
end

function botend(p::Base.Process)
    println(reply(p))
    close(p)
end

function name_get(proc)
    query(proc, "name")
    reply(proc)
end

function version_get(proc)
    query(proc, "version")
    reply(proc)
end 

function gtp_startup_info(proc)
    name = name_get(proc)
    if occursin("Leela Zero", name)
        info = readuntil(proc.err, "B.", keep=true)
    elseif occursin("KataGo", name)
        info = readuntil(proc.err, "GTP ready")
    else
        info = name[3:end-1]
    end
    println(info)
end 

function gtp_ready(proc)
    gtp_startup_info(proc)
    println("GTP ready")
end 

function showboard_format(p::Base.Process)
    println(reply(p))
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

function terminal()
    bot = botget()
    botProcess = botrun(dir=bot.dir, cmd=bot.cmd)
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
            botend(botProcess)
            break
        elseif occursin("showboard", sentence)
            showboard_format(botProcess)
        else
            println(reply(botProcess))
        end
    end
end

terminal()
