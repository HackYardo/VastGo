using Dash, PlotlyBase

include("utility.jl")

const COMPONENT = r"^[dh][a-z]{2,3}_.{1,}"

#pkgNames_strFile(Dash)

lines = readlines("../nvg/namesofDash.txt")
vector = match_diy(COMPONENT, lines)
vectorNullValid = cat(vector[1:19], vector[23:end], dims=1)
ground = Vector{Component}()
for cpnStr in vectorNullValid
    push!(ground, include_string(Main, "$cpnStr()"))
    #println(typeof(component),'\n',component)
    #println()
end

app = dash()
app.title = "A playground of Dash components"
app.layout = html_div() do 
    ground
end

#run_server(app, "0.0.0.0", 8050, debug=true)

@async run_server(app, "0.0.0.0", 8050, debug=false)

function playgroundofDash()
    while true  
        if readline() == "exit"
            break
        end
    end
end

playgroundofDash()
