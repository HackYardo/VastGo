#=
    This code is for realizing Regex in action.
    Just copy text from https://katagotraining.org/networks/ to a file,
    then run the code in terminal: 
        cmd> julia models.jl path/to/file
    Some issues:
        - init plot without init callback
        - line.shape, line.dash, and both relevant to line.mode
        - text from Leela-Zero and SAI
        - auto scale square ratio layout
        - auto copy text from KLS webpage
=#

using Dash, PlotlyBase

function check(r::Regex, s::AbstractString)
    !(match(r,s) === nothing)
end

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

function linedash_lenghtlist(value)
    if value == "length list"
        return false 
    else 
        return true
    end 
end 

function linedash_choose(dashOption, lengthList)
    if linedash_lenghtlist(dashOption)
        return dashOption
    else 
        return lengthList
    end
end

function pattern_regex(r::Regex)
    "$r"
end

function dropdown_multiTrue(value)
    str = ""
    t = typeof(value)
    if t <: AbstractArray || t <: AbstractVector
        if length(value) == 0 
            str = "markers"
        else 
            for v in value
                str = str * "$v+"
            end
            str = str[1:end-1]
        end
    elseif value isa String
        str = "markers"
        #str = value
        #println("2")
    else
        printstyled("Warning: "; color=:yellow)
        println("Type may not support:")
        println(t)
    end
    #println(typeof(value), '\n', value)
    #println(typeof(str), '\n', str)
    return str
end

function trace(l)
    #lmode = dropdown_multiTrue(l.mode)
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
        x = [500000],
        y = [1],
        mode = l.mode,
        line = attr(shape=l.shape, smoothing=l.smoothing, dash=l.dash),
        name = "random"
        )
    ]
    for name in keys(traces)
        trace = cat(trace, 
            scatter(
                x = traces[name].x,
                y = traces[name].y,
                mode = l.mode,
                line = attr(shape=l.shape, smoothing=l.smoothing, dash=l.dash),
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
app.title = "Networks' Training-Rating Plot | of  KataGo, Leela-Zero and SAI"
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
    dcc_input(id="lsmoothing",
        type="number",
        min=0,
        step=0.1,
        max=1.3,
        value=1.0  # default init value
    ),
    dcc_dropdown(id="ldash",
        options=[
            (label="solid", value="solid"),
            (label="length list", value="length list"),
            (label="5px,10px,15px", value="5px,10px,15px"),
            (label="longdashdot", value="longdashdot"),
            (label="longdash", value="longdash"),
            (label="dashdot", value="dashdot"),
            (label="dash", value="dash"),
            (label="dot", value="dot")
        ],
        value="solid"  # default init option
    ),
    dcc_input(id="ldashlength",
        placeholder="e.g. 5px,10px,15px",
        type="text",
        pattern=pattern_regex(r"^(\d{1,}px)(,\d{1,}px){0,}(,\d{1,}px)$"),
        debounce=true,
        disabled=true
    ),
    dcc_graph(id="curve") 
end

callback!(app,
    Output("curve", "figure"),
    Input("xstyle", "value"),
    Input("ystyle", "value"),
    Input("lmode", "value"),
    Input("lshape", "value"),
    Input("lsmoothing", "value"),
    Input("ldash", "value"),
    Input("ldashlength", "value"),
    ) do x, y, lm, lsh, lsm, ld, ldl
    lm = dropdown_multiTrue(lm)
    ld = linedash_choose(ld, ldl)
    l = (mode=lm, shape=lsh, smoothing=lsm, dash=ld)
    plot(x, y, l)
end

callback!(app,
    Output("ldashlength", "disabled"),
    Input("ldash", "value"),
    ) do val 
    linedash_lenghtlist(val)
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
