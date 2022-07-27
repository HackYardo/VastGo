#=
    This code is for realizing Regex in action.
    Just copy text from https://katagotraining.org/networks/ to a file,
    then run the code in terminal: 
        cmd> julia models.jl path/to/file
    Some issues:
        - plot without init callback
        - line shapes, line dash
        - range break
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

function dropdown_multi(value)
    str = ""
    if typeof(value) <: Array
        for v in value
            str = str * "$v+"
        end
        str = str[1:end-1]
    elseif value isa String
        str = value
    else
        printstyled("Warning: "; color=:yellow)
        println("Type may not support:")
        println(typeof(value))
        str = value
    end
    return str
end

function trace(l)
    #lmode = dropdown_multi(l.mode)
    #println(typeof(l.mode),'\n',l.mode)
    #l = (mode=string(l.mode), shape=string(l.shape), dash=string(l.dash))
    #=
    m = length(l.mode)
    if m == 1
        l.mode = l.mode[1]
    elseif 2 <= m <= 3
        o = ""
        for n in l.mode
            o = o * "$n+"
        end
        l.mode = [o[1:end-1]]
    elseif m == 0 
        l.mode = ["markers"]
    else
    end
    println(typeof(l.mode),'\n',l.mode)
    =#
    traces = get_trace()
    trace = [ scatter(
        x = [1],
        y = [0],
        mode = l.mode,
        line = attr(shape=l.shape,dash=l.dash),
        name = "random"
        )
    ]
    for name in keys(traces)
        trace = cat(trace, 
            scatter(
                x = traces[name].x,
                y = traces[name].y,
                mode = l.mode,
                line = attr(shape=l.shape,dash=l.dash),
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
        [trace for trace in trace(lstyle)],
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
        value="log"  # default init option
    ),
    html_label("Yaxis:"),
    dcc_dropdown(id="ystyle",
        options=[
            (label="log", value="log"),
            (label="linear", value="linear")
        ],
        value="linear"  # default init option
    ),
    html_label("Line:"),
    dcc_dropdown(id="lmode",
        options=[
            (label="markers", value="markers"),
            (label="lines", value="lines")
        ],
        multi=true,
        value="markers"  # default init option
    ),
    dcc_dropdown(id="lshape",
        options=[
            (label="linear", value="linear"),
            (label="hv", value="hv"),
            (label="vh", value="vh"),
            (label="hvh", value="hvh"),
            (label="vhv", value="vhv"),
            (label="spline", value="spline")
        ],
        value="spline"  # default init option
    ),
    dcc_dropdown(id="ldash",
        options=[
            (label="solid", value="solid"),
            (label="5px,10px,2px,1px", value="5px,10px,2px,1px"),
            (label="longdashdot", value="longdashdot"),
            (label="longdash", value="longdash"),
            (label="dashdot", value="dashdot"),
            (label="dash", value="dash"),
            (label="dot", value="dot")
        ],
        value="solid"  # default init option
    ),
    dcc_graph(id="curve") 
end

callback!(app,
    Output("curve", "figure"),
    Input("xstyle", "value"),
    Input("ystyle", "value"),
    Input("lmode", "value"),
    Input("lshape", "value"),
    Input("ldash", "value"),
    ) do x, y, lms, ls, ld
    lm = dropdown_multi(lms)
    l = (mode=lm, shape=ls, dash=ld)
    plot(x, y, l)
end
    
run_server(app, "0.0.0.0", 8050, debug=true)
#=
@async run_server(app, "0.0.0.0", 8050, debug=false)

function models()
    while true  
        if readline() == "exit"
            break
        end
    end
end

models()=#
