#=
    This code is for realizing Regex in action.
    Just copy text from https://katagotraining.org/networks/ to a file,
    then run the code in terminal: 
        cmd> julia models.jl path/to/file
=#

using Dash, PlotlyBase

function findindex(element, collection)
    m = 1 
    n = []
    for el in collection
        if el == element
            n = cat(n, m, dims=1)
        end 
        m = m + 1
    end 
    return n 
end 

function get_trace()
    file = ARGS[1]
    lines = readlines(file)
    linesMatch = match.(r"^k.{2,}\d{3,}\.\d",lines)
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
    names = unique(nameVector)
    for name in names 
        p = findindex(name, nameVector)
        m = []
        n = []
        for q in p
            m = cat(m, xVector[q], dims=1)
            n = cat(n, yVector[q], dims=1)
        end
        traces[name] = (x=m, y=n)
    end
    #println(keys(traces))
    return traces
end

#= example code from plotly.com
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

function trace(lstyle)
    traces = get_trace()
    trace = [ scatter(
        x = [1],
        y = [0],
        mode = lstyle,
        name = "random"
        )
    ]
    for name in keys(traces)
        trace = cat(trace, 
            scatter(
                x = traces[name].x,
                y = traces[name].y,
                mode = lstyle,
                name = name
            ), 
            dims = 1
        )
    end 
    return trace
end

function layout(xstyle,ystyle)
    Layout(xaxis_type=xstyle, yaxis_type=ystyle)
end

function plot(xstyle,ystyle,lstyle)
    Plot(
        [trace(lstyle)[i] for i in 1:length(trace(lstyle))],
        layout(xstyle,ystyle)
    )
end

app = dash()
app.title = "KataGo models' plot"
app.layout = html_div() do
    html_label("Xaxis:"),
    dcc_dropdown(id="xstyle",
        options=[
            (label="log", value="log"),
            (label="linear", value="linear")
        ],
        multi=false,
        value="log"  # default init option
    ),
    html_label("Yaxis:"),
    dcc_dropdown(id="ystyle",
        options=[
            (label="log", value="log"),
            (label="linear", value="linear")
        ],
        multi=false,
        value="linear"  # default init option
    ),
    html_label("Line:"),
    dcc_dropdown(id="lstyle",
        options=[
            (label="markers", value="markers"),
            (label="lines", value="lines")
        ],
        multi=true,
        value="markers"  # default init option
    ),
    dcc_graph(id="curve") 
end

callback!(app,
    Output("curve", "figure"),
    Input("xstyle", "value"),
    Input("ystyle", "value"),
    Input("lstyle", "value"),
    ) do x, y, l
    plot(x, y, l)
end
    
@async run_server(app, "0.0.0.0", 8050, debug=false)

function models()
    while true  
        if readline() == "exit"
            break
        end
    end
end

models()
