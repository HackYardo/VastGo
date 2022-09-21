#=
This script is for managing multi-bot processes,
and will try not only one approaches:
1. include_string()
2. `julia terminal.jl bot`
3. Task()
4. stack
=#

function gtp_exit(botProcDict)
    println("=")

    for (key,value) in botProcDict
        println(value, "quit")
        print_info("$key gone")
    end
    
    println()
end

function gtp_status(botDict, botProcDict)
    print("=")
    botDictKey = collect(keys(botDict))
    for key in botDictKey
        if haskey(botProcDict, key)
            printstyled(" $key", color=6)
        else
            print(" $key")
        end
    end
    println("\n")
end

function gtp_run()

end

function gtp_kill()

end

function gtp_switch()

end

function gtp_help()

end

struct Bot 
  dir::String 
  cmd::String
end

mutable struct BotSet
  dict::Dict{String, Bot}
  default::Vector{String}
end 

Base.convert(::Type{Bot}, t::NamedTuple) = Bot(t.dir, t.cmd)
Base.convert(::Type{Bot}, t::Tuple) = Bot(t[1], t[2])
Base.convert(::Type{Bot}, d::Dict) = Bot(d["dir"], d["cmd"])
Base.convert(::Type{Bot}, v::Vector) = Bot(v[1], v[2])

function bot_config()
    include_string(Main, readchomp("data/config.txt"))
    return botDefault, botDict
end

function bot_get()
    botDefault, botDict = bot_config()
    botSet = BotSet(botDict, botDefault)
    
    botToRun = String[]
    if length(ARGS) == 0 
        botToRun = botDefault
    else
        botToRun = ARGS
    end
    
    botDict, botToRun
end

function bot_run()
    botDict, botToRun = bot_get()
    
    botProcDict = Dict{String, Base.Process}()
    for bot in botToRun
        botProcDict[bot] = open(`julia src/terminal.jl $bot`, "r+")
    end
    #println(botProcDict)
    
    botDict, botProcDict
end 

function bot_startup_info(botProcDict)
    for (key,value) in botProcDict
         print(readuntil(botProcDict[key], "[ Info: GTP ready\n"))
        print_info("$key ready")
    end
end

function print_info(s::String)
    printstyled("[ Info: ", color=6, bold=true)
    println(s)
end

function gtp_loop()
    botDict, botProcDict = bot_run()
    botProcKey = collect(keys(botProcDict))
    
    bot_startup_info(botProcDict)
    
    key = botProcKey[1]
    botProc = botProcDict[key]
    print_info("GTP ready (talk to $key first)")
    while true
        sentence = readline()
        sentenceVector = split(sentence)
        if "exit" in sentenceVector
            gtp_exit(botProcDict)
            break
        elseif "status" in sentenceVector
            gtp_status(botDict, botProcDict)
        elseif "switch" in sentenceVector
            key = sentenceVector[end]
            botProc = botProcDict[key]
            println("= $key\n")
        else
            println(botProc, sentence)
            print(readuntil(botProc, "\n\n", keep=true))
        end
    end
end

gtp_loop()
