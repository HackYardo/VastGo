#=
This script is for managing multi-bot processes,
and will try not only one approaches:
1. include_string()
2. `julia terminal.jl bot`
3. Task()
4. stack
=#

include("terminal.jl")
    # bot_config(), bot_list()
    # utility.jl
        # SRC, print_diy()

function Base.in(a::Vector{String}, b)
    for s in a
        if s in b
            return true
        end
    end
    return false
end

function bots_get()
    botDictKey = String[]
    botToRunValid = String[]

    botDefault, botDict = bot_list(bot_config())
    if length(botDefault) * length(botDict) == 0
        return botDictKey, botToRun
    end

    botDictKey = collect(keys(botDict))

    botToRun = length(ARGS) == 0 ? botDefault : ARGS
    unique!(botToRun)
    for key in botToRun
        if key in botDictKey
            push!(botToRunValid, key)
        else
            print_diy("w", "not found: " * CONFIG * ":[\"" * key * "\"]")
        end
    end
    
    botDictKey, botToRunValid
end

function bots_ready(bot::String, proc::Base.Process)::Bool 
    while true
        line = readline(proc)

        if line == ""
            print_diy("e", bot * " can not run", ln=false)
            return false
        elseif line[7:9] == ": G"
            print_diy("i", bot * " ready")
            return true
        else 
            println(line)
        end
    end
end

function bots_run(bot::String)
    open(Cmd(`julia terminal.jl $bot`, dir=SRC), "r+")
end
function bots_run(botToRun::Vector{String})
    botProcDict = Dict{String, Base.Process}()
    
    @sync for bot in botToRun
        @async begin
            proc = bots_run(bot)
            if bots_ready(bot, proc)
                botProcDict[bot] = proc
            end
        end
    end
    
    botProcDict
end

function gtps_run(botDictKey, botProcDict, key)
    if haskey(botProcDict, key)
        print("= ")
        print_diy("w", key * " already running")
    elseif key in botDictKey
        println("=")
        proc = bots_run(key)
        if proc != nothing
            botProcDict[key] = proc
        end
    else
        print("= ")
        print_diy("w", key * " not found")
    end
    println()
    return botProcDict
end

function gtps_exit(botProcDict)
    gtps_broadcast(botProcDict, "quit")
    close.(collect(values(botProcDict)))
end

function gtps_quit(key, botProcDict, sentence)
    flag = true
    key2 = key
    if length(sentence) > 5
        key2 = sentence[6:end]
    end
    
    if sentence == "quit."
        gtps_exit(botProcDict)
        flag = false
    elseif haskey(botProcDict, key2)
        proc = botProcDict[key2]
        if key2 == key
            println(proc, "quit")
            print(readuntil(proc, "\n\n"))
            close(proc)
            pop!(botProcDict, key)
            if length(botProcDict) == 0
                flag = false
                println()
            else 
                key = collect(keys(botProcDict))[1]
                print_diy("i", "auto switch to " * key)
            end 
            println()
        else 
            gtps_exit(Dict(key2 => proc))
            pop!(botProcDict, key2)
        end
    else 
        print("= ")
        print_diy("w", key * " not found")
        println()
    end
    
    key, botProcDict, flag
end

function gtps_status(botDictKey, botProcDict, key)
    botProcKey = collect(keys(botProcDict))
    
    print('=')

    for k in botDictKey
        if k in botProcKey
            if k == key
                printstyled(' ' * k, color=:green, bold=true)
            else
                printstyled(' ' * k, color=6)
            end
        else
            print(' ' * k)
        end
    end

    println('\n')
end

function gtps_switch(key1, botProcDict, key2)
    print("= ")
    if ! haskey(botProcDict, key2)
        print_diy("w", key2 * " not found")
        key2 = key1
    else
        println()
    end
    println()
    return key2
end

function gtps_help()
    println("=")
    print_diy("status, st  ", ": list all bots", lr=true)
    print_diy("  open, run ", ": run a bot", lr=true)
    print_diy("switch, turn", ": switch to a bot", lr=true)
    print_diy("  help, ?   ", ": show this message", lr=true)
    print_diy("gtp_command.", ": broadcast a GTP command to all running bots", lr=true)
    println("-----Example:")
    print_diy("name.\n", "g = GNU Go\nl = Leela Zero", lr=true)
    println()
end

function gtps_broadcast(botProcDict, sentence)
    @sync for (bot,proc) in botProcDict
        @async begin
            println(proc, sentence)
            println(bot, ' ', readuntil(proc, "\n\n"))
        end
    end
    println()
end

function gtps_qr(proc, sentence)
    println(proc, sentence)
    print(readuntil(proc, "\n\n", keep=true))
end

# GTP with ID number
gtps_print(b::String)            = gtps_print(    [""], b)
gtps_print(a::String, b::String) = gtps_print(split(a), b)
function gtps_print(va::Vector{String}, b::String)
    println('=', va[1], b, '\n')
end

function task()
    flag = true

    botDictKey, botToRun = bots_get()
    if length(botDictKey) * length(botToRun) == 0
        return nothing
    end

    botProcDict = bots_run(botToRun)
    if length(botProcDict) == 0
        print_diy("e", "no bot can run", ln=false)
        return nothing
    end
    
    key = collect(keys(botProcDict))[1]
    print_diy("i", "GTP ready (" * key * " first), type ? or list_commands for help")
    while flag
        sentence = readline()
        words = split(sentence)
        
        if occursin("quit", sentence)
            key, botProcDict, flag = gtps_quit(key, botProcDict, sentence)
        elseif ["status", "st"] in words
            gtps_status(botDictKey, botProcDict, key)
        elseif ["switch", "turn"] in words
            key = gtps_switch(key, botProcDict, String(words[end]))
        elseif ["open", "run"] in words
            botProcDict = gtps_run(botDictKey, botProcDict, String(words[end]))
        elseif ["help", "?"] in words
            gtps_help()
        elseif  length(sentence) > 1 && sentence[end] == '.'
            sentence = sentence[1:end-1]
            gtps_broadcast(botProcDict, sentence)
            #gtps_qr.(collect(values(botProcDict)), sentence)
        else
            gtps_qr(botProcDict[key], sentence)
        end
    end
end

if abspath(PROGRAM_FILE) == joinpath(SRC, "task.jl")
    task()
end
