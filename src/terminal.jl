function botget()
    GNUGO = (dir="", cmd="gnugo --mode gtp")
    LEELAZ = (dir="../lzweights/", cmd="leelaz --cpu-only -g -v 8 -w w6.gz")
    KATAGO = (dir="../KataGo/", cmd="./katago gtp -model kgmodels/m6.txt.gz")
    botVector = [GNUGO, LEELAZ, KATAGO]
    
    @label Choose
    println("Choose one or type a new one:\nid dir cmd")
    j = 1
    for i in botVector
        println(j,' ',i.dir,' ',i.cmd)
        j = j + 1 
    end
    println("new\n")
    choose = readline()
    bot = (dir="", cmd="")
    if occursin(choose, "123")
        bot = botVector[parse(Int, choose)]
    elseif choose == "new"
        println("Where is the GTP engine?")
        dir = readline()
        println("What's the command to run it?")
        cmd = readline()
        bot = (dir=dir, cmd=cmd)
    else 
        println("Please try again...")
        @goto Choose 
    end 
    
    return bot
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
    println("IF NO \"GTP ready\", TRY The command IN TERMINAL FIRST, \
        THEN CHECK data/bot.csv\n")
    process = run(command,inp,out,err;wait=false)
    #println("$process")
    return process
end

function get_name(proc)
    query(proc, "name")
    println("name")
    reply(proc)
end

function get_version(proc)
    query(proc, "version")
    println("version")
    reply(proc)
end 

function gtp_startup_info(proc)
    name = get_name(proc)
    version = get_version(proc)
    info = ""
    if occursin("Leela Zero", name)
        info = readuntil(proc.err, "B.", keep=true)
    elseif occursin("KataGo", name)
        info = readuntil(proc.err, "GTP ready")
    else
    end
    (info = info, name = name, version = version)
end 

function gtp_ready(proc)
    startup = gtp_startup_info(proc)
    println(startup.info)
    println(startup.name)
    println(startup.version)
    #=
    if !occursin("KataGo", startup.name)
        println("GTP ready")
    end
    =#
    println("GTP ready")
end 

function botend(p::Base.Process)
    close(p)
end

function query(proc, sentence::String)
    println(proc, sentence)
end

function reply(proc)
    #=
    paragraph=""
    while true
        sentence=readline(proc)
        if sentence==""
            break
        else 
            paragraph="$paragraph$sentence\n"
        end
    end
    =#
    paragraph = readuntil(proc, "\n\n")
    #println(paragraph, '\n')
    return "$paragraph\n"
end

function play()
    bot = botget()
    botProcess = botrun(dir=bot.dir, cmd=bot.cmd)
    gtp_ready(botProcess)
    while true
        sentence = readline()
        query(botProcess, sentence)
        paragraph = reply(botProcess)
        println(paragraph)
        if occursin("quit", sentence)
            botend(botProcess)
            break
        else
            continue
        end
    end
end

play()
