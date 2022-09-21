#=
This script is for managing multi-bot processes,
and will try not only one approaches:
1. include_string()
2. `julia terminal.jl bot`
3. Task()
4. stack
=#

using Distributed

function gtp_exit(botProcDict)
    println("=")

    @distributed for (key,botProc) = botProcDict
        println(botProc, "quit")
        readuntil(botProc, "\n\n")
        close(botProc)
        print_info("$key gone")
    end
    
    println()
end

function gtp_quit()

    println(botProc, "quit")
    readuntil(botProc, "\n\n")
    close(botProc)

    println("= ")

    print_info("$key gone")

    pop!(botProcDict, key)
    if length(botProcDict) == 0
        print_info("no bot left, `run` a bot or `exit`\n")
    else
        botProcKey = collect(keys(botProcDict))
        key = botProcKey[1]
        botProc = botProcDict[key]
        print_info("auto switch to $key\n")
        return key, botProc
    end
end

function gtp_status(botDictKey, botProcKey)
    print("=")

    for key in botDictKey
        if key in botProcKey
            printstyled(" $key", color=6)
        else
            print(" $key")
        end
    end

    println("\n")
end

function gtp_run(botDict, botProcDict, key)
    if haskey(botProcDict, key)
        println("= already running\n")
    elseif haskey(botDict, key)
        botProcDict[key] = bot_run(key)
    else
        println("= not found\n")
    end
end

function gtp_kill()

end

function gtp_switch()

end

function gtp_help()

end

function bot_config()
    include_string(Main, readchomp("data/config.txt"))
    botDictKey = collect(keys(botDict))
    return botDefault, botDictKey
end

function bot_get()
    botDefault, botDictKey = bot_config()

    botToRun = String[]
    if length(ARGS) == 0 
        botToRun = botDefault
    else
        botToRun = ARGS
    end
    
    botDictKey, botToRun
end

function bot_run(bot::String)
    open(`julia src/terminal.jl $bot`, "r+")
end
function bot_run(botToRun::Vector{String})
    botProcDict = Dict{String, Base.Process}()
    @distributed for bot = botToRun
        botProcDict[bot] = bot_run(bot)
    end
    #println(botProcDict)
    
    botProcDict
end 

function bot_startup_info(botProcDict)
    for (key,value) in botProcDict
        printstyled(readuntil(botProcDict[key], "[ Info: GTP ready\n"))
        print_info("$key ready")
    end
end

print_info(s::String)            = print_info("[ Info: ", s)
print_info(a::String, s::String) = print_info(         a, s, 6)
function print_info(a::String, s::String, c::Int)
    printstyled("a", color=c, bold=true)
    println(s)
end

gtp_print(b::String)            = gtp_print(    [""], b)
gtp_print(a::String, b::String) = gtp_print(split(a), b)
function gtp_print(va::Vector{String}, b::String)
    println("=$(va[1]) $b\n")
end

function gtp_loop()
    botDictKey, botToRun = bot_get()
    botProcDict = bot_run(botToRun)
    botProcKey = collect(keys(botProcDict))
    
    bot_startup_info(botProcDict)
    
    key = botProcKey[1]
    botProc = botProcDict[key]
    print_info("GTP ready ($key first)")
    while true
        sentence = readline()
        words = split(sentence)
        if "exit" in words
            gtp_exit(botProcDict)
            break
        elseif "quit" in words

        elseif "status" in words
            gtp_status(botDictKey, botProcKey)
        elseif "switch" in words
            key = words[end]
            botProc = botProcDict[key]
            println("= $key\n")
        elseif "run" in words
            gtp_run(botDict, botProcDict, words[end])
        else
            println(botProc, sentence)
            print(readuntil(botProc, "\n\n", keep=true))
        end
    end
end

gtp_loop()
