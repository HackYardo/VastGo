#=
This script is for managing multi-bot processes,
and will try not only one approaches:
1. include_string()
2. `julia terminal.jl bot`
3. Task()
4. stack
=#

function Base.in(a::Vector{String}, b)
    for s in a
        if s in b
            return true
        end
    end
    return false
end

function bot_config()
    include_string(Main, readchomp("data/config.txt"))
    return botDefault, botDict
end

function bot_get()
    botDefault, botDict = bot_config()
    
    botToRun = String[]
    if length(ARGS) == 0 
        botToRun = botDefault
    else
        botToRun = ARGS
    end
    unique!(botToRun)
    #println(botDict)
    #println(botToRun)
    botToRunValid = Vector{String}()
    for key in botToRun
        if haskey(botDict, key)
            push!(botToRunValid, key)
        else 
            print_info("[ Warning: ", "$key not found", :yellow)
        end
    end
    
    botDict, botToRunValid
end

function bot_run(bot::String)
    flag = true
    proc = open(`julia src/terminal.jl $bot`, "r+")
    startupInfo = readuntil(proc, "[ Info: GTP ready\n")
    print(startupInfo)
    if occursin("Error", startupInfo)
        print_info("[ ERROR: ", "$bot can not run", :red)
        proc = nothing
        flag = false
    else 
        print_info("$bot ready")
    end
    return flag, proc
end
function bot_run(botToRun::Vector{String})
    botProcDict = Dict{String, Base.Process}()
    for bot in botToRun
        flag, proc = bot_run(bot)
        if flag
            botProcDict[bot] = proc
        end
    end
    #println(botProcDict)
    if length(botProcDict) == 0
        print_info("[ ERROR: ", "no bot can run", :red)
        exit()
    end
    
    botProcDict
end 

function gtp_run(botDict, botProcDict, key)
    if haskey(botProcDict, key)
        print("= ")
        print_info("$key already running")
    elseif haskey(botDict, key)
        println("=")
        flag, proc = bot_run(key)
        if flag
            botProcDict[key] = proc
        end
    else
        print("= ")
        print_info("[ Warning: ", "$key not found", :yellow)
    end
    println()
    return botProcDict
end

function gtp_exit(botProcDict)
    println("=")
    
    botProcKey = collect(keys(botProcDict))
    for key in botProcKey
        botProc = botProcDict[key]
        println(botProc, "quit")
        readuntil(botProc, "\n\n")
        close(botProc)
        print_info("$key gone")
    end
    
    print_info("bye")

    println()
end

function gtp_quit(key1, botProcDict, key2)
    key = key2
    print("= ")
    if length(botProcDict) == 1 
        print_info("at least one bot")
        key = key1
    elseif haskey(botProcDict, key)
        botProc = botProcDict[key]
        println(botProc, "quit")
        readuntil(botProc, "\n\n")
        close(botProc)
        println()
        print_info("$key gone")

        pop!(botProcDict, key)
        key = collect(keys(botProcDict))[1]
        print_info("auto switch to $key")
    else 
        print_info("[ Warning: ", "$key not found", :yellow)
        key = key1
    end
    println()
    return key, botProcDict
end

function gtp_status(botDict, botProcDict, key)
    botDictKey = collect(keys(botDict))
    botProcKey = collect(keys(botProcDict))
    
    print("=")

    for k in botDictKey
        if k in botProcKey
            if k == key
                printstyled(" $k", color=:green, bold=true)
            else
                printstyled(" $k", color=6)
            end
        else
            print(" $k")
        end
    end

    println("\n")
end

function gtp_switch(key1, botProcDict, key2)
    print("= ")
    if ! haskey(botProcDict, key2)
        print_info("[ Warning: ", "$key2 not found", :yellow)
        key2 = key1
    else
        println()
    end
    println()
    return key2
end

function gtp_help()
    println("=")
    printstyled("status, st  ", color=6, bold=true)
    println(": list all bot")
    printstyled("  open, run ", color=6, bold=true)
    println(": run a bot")
    printstyled(" close, kill", color=6, bold=true)
    println(": quit a bot")
    printstyled("switch, turn", color=6, bold=true)
    println(": switch to a bot")
    printstyled("  exit, bye ", color=6, bold=true)
    println(": quit all bots and exit")
    printstyled("  help, ?   ", color=6, bold=true)
    println(": show this message")
    printstyled("gtp_command.", color=6, bold=true)
    println(": broadcast a GTP command to all running bots")
    println("-----Example:\nname.\ng = GNU Go\nl = Leela Zero")
    println()
end

print_info(s)    = print_info("[ Info: ", s)
print_info(a, s) = print_info(         a, s, 6)
function print_info(a, s, c)
    printstyled(a, color=c, bold=true)
    println(s)
end

# GTP with ID number
gtp_print(b::String)            = gtp_print(    [""], b)
gtp_print(a::String, b::String) = gtp_print(split(a), b)
function gtp_print(va::Vector{String}, b::String)
    println("=$(va[1]) $b\n")
end

function gtp_loop()
    botDict, botToRun = bot_get()
    botProcDict = bot_run(botToRun)
    
    key = collect(keys(botProcDict))[1]
    print_info("GTP ready ($key first)")
    while true
        sentence = readline()
        words = split(sentence)
        
        if ["exit", "bye"] in words
            gtp_exit(botProcDict)
            break
        elseif "quit" in words
            key, botProcDict = gtp_quit(key, botProcDict, key)
        elseif ["close", "kill"] in words
            key, botProcDict = gtp_quit(key, botProcDict, String(words[end]))
        elseif ["status", "st"] in words
            gtp_status(botDict, botProcDict, key)
        elseif ["switch", "turn"] in words
            key = gtp_switch(key, botProcDict, String(words[end]))
        elseif ["open", "run"] in words
            botProcDict = gtp_run(botDict, botProcDict, String(words[end]))
        elseif ["help", "?"] in words
            gtp_help()
        elseif sentence[end] == '.'
            sentence = sentence[1:end-1]
            for (bot,proc) in botProcDict
                println(proc, sentence)
                print("$bot ")
                println(readuntil(proc, "\n\n"))
            end
            println()
        else
            println(botProcDict[key], sentence)
            print(readuntil(botProcDict[key], "\n\n", keep=true))
        end
    end
end

gtp_loop()
