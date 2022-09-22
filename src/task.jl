#=
This script is for managing multi-bot processes,
and will try not only one approaches:
1. include_string()
2. `julia terminal.jl bot`
3. Task()
4. stack
=#

struct Bot 
  dir::String 
  cmd::String
end

mutable struct BotSet
  dict::Dict{String, Bot}
  default::Vector{String}
end 

Base.convert(::Type{Bot}, t::NamedTuple) = Bot(   t.dir,    t.cmd)
Base.convert(::Type{Bot}, t::Tuple)      = Bot(    t[1],     t[2])
Base.convert(::Type{Bot}, d::Dict)       = Bot(d["dir"], d["cmd"])
Base.convert(::Type{Bot}, v::Vector)     = Bot(    v[1],     v[2])

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
    
    println()
end

function gtp_quit(key, botProcDict)
    print("= ")
    if length(botProcDict) == 1 
        print_info("as least one bot")
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
        print_info("not found")
    end
    println()
    return key, botProcDict
end

function gtp_status(botDict, botProcDict)
    botDictKey = collect(keys(botDict))
    botProcKey = collect(keys(botProcDict))
    
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
        println("= already running")
    elseif haskey(botDict, key)
        println("=")
        flag, proc = bot_run(key)
        if flag
            botProcDict[key] = proc
        end
    else
        println("= not found")
    end
    println()
    return botProcDict
end

function gtp_switch(key1, botProcDict, key2)
    print("=")
    if ! haskey(botProcDict, key2)
        print(" not found")
        key2 = key1
    end
    println("\n")
    return key2
end

function gtp_help()
    println("=")
    printstyled("status", color=6, bold=true)
    println("  list all bot")
    printstyled("run   ", color=6, bold=true)
    println("  run a bot")
    printstyled("kill  ", color=6, bold=true)
    println("  quit a bot")
    printstyled("switch", color=6, bold=true)
    println("  switch to a bot")
    printstyled("exit  ", color=6, bold=true)
    println("  quit all bots and exit")
    println()
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
            print_info("$key not found")
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
        print_info("$bot can not run")
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

print_info(s)    = print_info("[ Info: ", s)
print_info(a, s) = print_info(         a, s, 6)
function print_info(a, s, c)
    printstyled(a, color=c, bold=true)
    println(s)
end

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
        
        if "exit" in words
            gtp_exit(botProcDict)
            break
        elseif "quit" in words
            key, botProcDict = gtp_quit(key, botProcDict)
        elseif "kill" in words
            key, botProcDict = gtp_quit(String(words[end]), botProcDict)
        elseif "status" in words
            gtp_status(botDict, botProcDict)
        elseif "switch" in words
            key = gtp_switch(key, botProcDict, String(words[end]))
        elseif "run" in words
            botProcDict = gtp_run(botDict, botProcDict, String(words[end]))
        elseif "help" in words
            gtp_help()
        else
            println(botProcDict[key], sentence)
            print(readuntil(botProcDict[key], "\n\n", keep=true))
        end
    end
end

gtp_loop()
