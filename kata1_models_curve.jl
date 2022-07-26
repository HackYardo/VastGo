#=
    This code is for realizing Regex in action.
    Just copy text from https://katagotraining.org/ to a file,
    then run the code in terminal: 
        cmd> julia models.jl path/to/file
=#

using Dash, PlotlyBase

file = ARGS[1]

function get_trace(file::String)
    lines = readlines(file)
    linesMatch = match.(r"^k.{2,}\d{3,}\.\d",lines)
    linesWithoutNothing = []
    nameVector = []
    xVector = []
    yVector = []
    traces = Dict()
    for line in linesMatch
        if isnothing(line)
            continue
        else
            lineSplit = split(line.match)
            nnStructure = match(r"b.{3,5}\d",lineSplit[1]).match
            dataRows = parse(Int64, match(r"d.{2,}",lineSplit[1]).match[2:end])
            elo = parse(Float64, lineSplit[end])
            nameVector = cat(nameVector, nnStructure, dims=1)
            xVector = cat(xVector, dataRows, dims=1)
            yVector = cat(yVector, elo, dims=1)
        end
    end
    linesWithoutNothing = (name=nameVector, x=xVector, y=yVector)
    #println(length(linesWithoutNothing.x))
    #println(linesWithoutNothing.y[end-2:end])
    
    return linesWithoutNothing
end

get_trace(file)

function get_number()
    file = readlines("kata1curve.csv")[2:end-1]
    newfile = [0,0.0]
    for line in file
        newline = split(line,",")
        a = parse(Int64,newline[1])
        b = parse(Float64,newline[2])
        newfile = cat(newfile,[a,b],dims=2)
    end
    println(newfile)
    return newfile
end

function trace()
    v = get_number()
    scatter(
        x = v[1,:],
        y = v[2,:],
        mode = "markers",
        name = "kata1 data-elo curve"
    )
end

function layout(style)
    Layout(xaxis_type=style)
end
function plot(style)
    Plot(
        trace(),
        layout(style)
    )
end

#= example code
function plot(style)
    x = range(1, stop=200, length=30)
    Plot(
        scatter(x=x, y=x.^3, range_x=[0.8, 250], mode="markers"),
        Layout(
            yaxis_type="linear",
            xaxis_type=style,
            xaxis_range=[log10(0.8), log10(250)]
        )
    )
end=#

app = dash()
app.title = "KataGo models' plot"
app.layout = html_div() do
    dcc_dropdown(id="style",
        options=[
            (label="log", value="log"),
            (label="linear", value="linear")
        ],
        multi=false,
        value="linear"  # default(init) option
    ),
    dcc_graph(id="curve") 
end

callback!(app,
    Output("curve","figure"),
    Input("style","value"),
    ) do val
    plot(val)
end
    
run_server(app,"0.0.0.0",8050,debug=true)