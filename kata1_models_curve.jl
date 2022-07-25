using Dash, PlotlyBase

x = range(1, stop=200, length=30)
function p(style)
    Plot(
    scatter(x=x, y=x.^3, range_x=[0.8, 250], mode="markers"),
    Layout(
        yaxis_type="linear",
        xaxis_type=style,
        xaxis_range=[log10(0.8), log10(250)]
    )
)
end

app=dash()
app.title="kata1"
app.layout=html_div() do
    dcc_dropdown(id="style",
        options=[
            (label="log",value="log"),
            (label="linear",value="linear")
        ],
        multi=false,
        value="linear"
    ),
    dcc_graph(id="curve") 
end

callback!(app,
    Output("curve","figure"),
    Input("style","value"),) do val
    p(val)
end
    
run_server(app,"0.0.0.0",8050,debug=true)