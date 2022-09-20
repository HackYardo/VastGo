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
botToRun = ["a", "a", "b"]
function strExe(s)
    include_string(Main, s)
    s 
end
for bot in botToRun
botCmd = botDict[bot].cmd
include_string(Main, 
    """$bot = open($botCmd, "r+")""")
end
println(str_var("a"))
