#=
This script is for managing multi-bot processes,
and will try not only one approaches:
1. include_string()
2. `julia terminal.jl bot`
3. Task()
4. stack
=#

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
