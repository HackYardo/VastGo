using Dash, PlotlyBase

include("utility.jl")

const COMPONENT = r"^[dh][a-z]{2,3}_.{1,}"

# pkgNames_strFile(Dash)
vector = file_match(COMPONENT, "../Navigator/namesofDash.txt")
string = vector[8]
string = "$string()"
symbal = quote
    string
end
cpm = eval(symbal)
eval(:(meta = cpm))
println(typeof(meta),'\n',meta)

println()
str = "html_h1()"
#str = Symbol(str)
str = eval(:(str))
qte = quote
    mid = str
end
eval(qte)
println(typeof(mid),'\n',mid)

println()
normal = dcc_textarea()
println(typeof(normal),'\n',normal)

app = dash()
app.title = "A playground of Dash components"
app.layout = html_div() do
    meta,
    normal
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
