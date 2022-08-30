using JSON
using PlotlyBase
using Dash

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
		ticktext=cat(['Z'], 
			[c for c in 'A':'H'], [c for c in 'J':'U'], dims=1),
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
	y = [0, 20],
	mode = "markers",
	marker_color = "rgba(0,0,0,0)",
	name = "anchors"
	)
starPoint=scatter(
	x = repeat([4, 10, 16], 3),
	y = [i for i in [4, 10, 16] for j in 1:3],
	mode="markers",
	marker_color="rgb(0,0,0)",
	name="star points"
	)
vertex=scatter(
	x = repeat([i for i in 1:19], 19),
	y = [i for i in 19:-1:1 for j in 1:19],
	mode="markers",
	marker_size = 36,
	marker_color="rgba(0,0,0,0)",
	name="vertex"
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

topText="""
### Hello, welcome to VastGo!

> Have a nice day!
"""

bottomText="
*based on [Plotly Dash](https://dash-julia.plotly.com/), \
written in [Julia](https://julialang.org/)*
"

bottomDiv=dcc_markdown(bottomText)

function plot_board()
	Plot(
		[anchorPoint,
		colLine,
		rowLine,
		starPoint,
		vertex
		],
		boardLayout
		)
end
board = plot_board()
function plot_board!(stone,boardLayout)
	Plot(
		stone,
		boardLayout
		)
end
function color_turn(playerNumber=2,boardSize=19*19,
	chooseColor=["rgb(255,255,255)","rgb(0,0,0)"])

end
function trace_stones(xArray=[],yArray=[])
	scatter(
		x=xArray,
		y=yArray,
		mode="markers",
		marker_color= "rgba(255,255,255,1)",
		marker_size=25,
		name="W stones"
		)
end

app=dash()

app.layout=html_div() do
	html_div(
		dcc_markdown(topText), 
		style=Dict(
			"backgroundColor"=>"#111111",
			"textAlign"=>"center",
			"columnCount"=>"2",
			"color"=>"rgba(0,255,0,1)"
			)
		),
	dcc_graph(id="board2", figure=board),
	html_div(id="seeDebugData"),
	dcc_graph(figure = Plot(longVector)),
	html_div(
		bottomDiv, 
		style=(width="49%",display="inline-block",float="right")
		)
end

callback!(
	app,
	Output("board2","figure"),
	Input("board2","clickData"),
	) do sth
		if sth != nothing
			sthJSON=JSON.json(sth)
			sthParse=JSON.parse(sthJSON)
			vector=sthParse["points"][1]
			xArray=[vector["x"]]
			yArray=[vector["y"]]
		else
			xArray=[]
			yArray=[]
		end
		return plot_board!(
			trace_stones(xArray,yArray),
			boardLayout
			)
	end

run_server(app, "0.0.0.0", debug=true)