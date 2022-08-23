#botCommand= "./katago gtp -model b6/model.txt.gz"
botCommand = "gnugo --mode gtp"
#botCommand = "leelaz --cpu-only -g -v 8 -w ../lzweights/weight.gz"

#botProcess = open(`$botCommand`, "r+")
function botget()
    GNUGO = (dir="", cmd="gnugo --mode gtp")
    LEELAZ = (dir="../Leela-Zero/", cmd="leelaz --cpu-only -g -v 8 -w lzweights/w5.gz")
    KATAGO = (dir="./", cmd="./katago gtp -model kgmodels/m6.txt.gz")
    botVector = [GNUGO, LEELAZ, KATAGO]
    
    @label Choose
    println("Choose one or type a new one:")
    println("1 $GNUGO.dir $GNUGO.cmd\n2 ../Leela-Zero/ leelaz --cpu-only -g -v 8 -w lzweights/w5.gz\n3 ./ ./katago gtp -model kgmodels/m6.txt.gz\nnew")
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

function botrun(;dir="",cmd="")
    inp = Base.PipeEndpoint()
    out = Base.PipeEndpoint()
    err = Base.PipeEndpoint()

    cmdVector = split(cmd) # otherwise there will be ' in command
    exe = cmdVector[1]
    opt = cmdVector[2:end]
    if dir == ""
        command = `$exe $opt`
    else
        command = Cmd(`./$exe $opt`,dir=dir)
    end
    cmdString = "$command"[2:end-1]
    println("The command:\n$cmdString")
    println("IF NO \"GTP ready\", TRY The command IN TERMINAL FIRST, \
        THEN CHECK bot.csv")
    process = run(command,inp,out,err;wait=false)
    #println("$process")
    return process
end
#botProcess = botrun(dir="", cmd=botCommand)
bot = botget()
botProcess = botrun(dir=bot.dir, cmd=bot.cmd)
function endbot()
    close(botProcess)
end

function query(sentence::String)
    println(botProcess,sentence)
end

function reply()
    paragraph=""
    while true
        sentence=readline(botProcess)
        if sentence==""
            break
        else 
            paragraph="$paragraph$sentence\n"
        end
    end
    println(paragraph)
    return paragraph::String
end

function play()
    if !occursin("katago",botCommand)
        println("GTP ready")
    end
    while true
        sentence = readline()
        query(sentence)
        reply()
        if occursin("quit",sentence)
            endbot()
            break
        else
            continue
        end
    end
end

play()
