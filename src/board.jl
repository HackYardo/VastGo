const VERTEX = cat([c for c in 'A':'H'], [c for c in 'J':'T'], dims=1)

boardLayout=Layout(
    # boardSize are as big as setting
    # aspectmode="manual",aspectratio=1,
    width=800*1.08,
    height=800,
    paper_bgcolor="rgb(0,255,127)",
    plot_bgcolor="rgb(205,133,63)",
    xaxis_showgrid=false,
    xaxis=attr(
        # showline=true, mirror=true,linewidth=1,linecolor="black",
        # zeroline=true,zerolinewidth=1,zerolinecolor="rgb(205,133,63)",
        zeroline = false,
        ticktext = cat(['Z'], VERTEX, ['U'], dims=1),
        tickvals = [i for i in 0:20] 
        ),
    yaxis_showgrid=false,
    yaxis=attr(
        # showline=true, mirror=true,linewidth=1,linecolor="black",
        zeroline=false,
        ticktext=["$i" for i in 0:20],
        tickvals = [i for i in 0:20]
        )
    )
rowLine=scatter(
    x = repeat([1, 19, nothing], 19),
    y = [i for i in 1:19 for j in 1:3],
    mode="lines",
    line_width=1,
    line_color="rgb(0,0,0)",
    hoverinfo="skip",
    name="row lines"
    )
colLine=scatter(
    x = [c for c in 1:19 for j in 1:3],
    y = repeat([1, 19, nothing], 19),
    mode="lines",
    line_width=1,
    line_color="rgb(0,0,0)",
    hoverinfo="skip",
    name="col lines"
    )
anchorPoint = scatter(
    # use (z,1) and (u,19) to widen col margin
    x = [0, 20],
    y = [20, 0],
    mode = "text",
    textposition = "inside",
    text = ["+"],
    textfont = attr(size = 10, color = [
        "rgba(0,0,0,1)"]),
    name = "anchors"
    )
starPoint=scatter(
    x = repeat([4, 10, 16], 3),
    y = [i for i in [4, 10, 16] for j in 1:3],
    mode="markers",
    marker_color="rgb(0,0,0)",
    name="star points"
    )
ownership=scatter(
    x=['i','k','r'],
    y=[10,11,5],
    mode="markers",
    marker=attr(
        symbol="diamond",
        color=["rgba(127,127,127,0.6)",
        "rgba(255,255,255,0.6)","rgba(0,0,0,0.6)"],
        size=50,
        # opacity=0.6,
        line=attr(width=0)
        ),
    name="ownership"
    )
longVector = scatter(
    x = [1, 2, 3, 1, 2, 3, 1, 2, 3],
    y = [3, 3, 3, 2, 2, 2, 1, 1, 1],
    mode = "markers",
    marker = attr(
        symbol = "circle",
        color = [
        "rgba(24,64,125,1)", "rgba(0,0,0,0)", "rgba(0,0,0,0)", 
        "rgba(0,0,0,0)", "rgba(0,0,0,1)", "rgba(0,0,0,0)", 
        "rgba(0,0,0,0)", "rgba(255,255,255,1)", "rgba(0,0,0,0)"
        ],
        size = 50
    ),
    name = "longVector"
)
buttons = scatter(
    x = [1, 3, 5],
    y = [0, 0, 0],
    mode = "text",
    textposition = "inside",
    text = ["pass", "resign", "sync"],
    textfont = attr(size = 20, color = [
        "rgba(0,0,0,1)", 
        "rgba(255,255,255,1)", 
        "rgba(0,0,0,1)"]),
    name = "buttons"
)

function plot_board(stones)
    Plot(
        [anchorPoint,
        colLine,
        rowLine,
        starPoint,
        buttons,
        stones],
        boardLayout
        )
end

function trace_stones(xVector, yVector, colorVector)
    scatter(
        x = xVector,
        y = yVector,
        mode="markers",
        marker_color= colorVector,
        marker_size=25,
        name="stones"
        )
end

board = plot_board(trace_stones(
    repeat([i for i in 1:19], 19), 
    [i for i in 19:-1:1 for j in 1:19], 
    repeat("rgba(0,0,0,0)",361)
    ))

boardGraph = dcc_graph(id = "boardGraph", 
    figure = board
    )
infoTextarea = dcc_textarea(id = "infoTextarea",
    style = Dict("height" => 256, "width" => 800)
    )
