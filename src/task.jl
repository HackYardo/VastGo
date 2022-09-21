#=
This script is for managing multi-bot processes,
and will try not only one approaches:
1. include_string()
2. `julia terminal.jl bot`
3. Task()
4. stack
=#
#=
function gtp_exit()
    println("=\n")
    exit()
end

function gtp_ps()

end

function gtp_run()

end

function gtp_kill()

end

function gtp_switch()

end

function gtp_help()

end

g = `gnugo --mode gtp`
botDict = Dict(
"a" => (dir = "", cmd = g),
"b" => (dir = "", cmd = g),
"c" => (dir = "", cmd = g)
)
botToRun = ["a", "b"]
function str_exe(s)
    include_string(Main, s)
    s 
end
botProcDict = Dict{String, Base.Process}()
for bot in botToRun
botCmd = botDict[bot].cmd
str_exe("""botProcDict["$bot"] = open($botCmd, "r+")""")
end
println(botProcDict)
println(botProcDict["a"], "name")
println(botProcDict["b"], "version")
println(readline(botProcDict["a"]))
println(readline(botProcDict["b"]))
=#


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
    
    botProcDict
end 

function print_info(s::String)
    printstyled("[ Info: ", color=6, bold=true)
    println(s)
end

function gtp_loop()
    botProcDict = bot_run()
    botProcKey = collect(keys(botProcDict))
    
    for key in botProcKey
        print(readuntil(botProcDict[key], "[ Info: GTP ready\n"))
        print_info("$key ready")
    end
    
    botProc = botProcDict[botProcKey[1]]
    print_info("GTP ready, bot: $(botProcKey[1])")
    while true
        sentence = readline()
        sentenceVector = split(sentence)
        if "exit" in sentenceVector
            println("=")
            println(botProcDict["k"], "quit")
            print_info("k quit")
            println(botProcDict["g"], "quit")
            print_info("g quit")
            println()
            break
        elseif "switch" in sentenceVector
            botProc = botProcDict[sentenceVector[end]]
            println("= $botProc\n")
        else
            println(botProc, sentence)
            print(readuntil(botProc, "\n\n", keep=true))
        end
    end
end

gtp_loop()
