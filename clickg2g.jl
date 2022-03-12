using JSON
using PlotlyJS
using Dash

const SGF_X=['a','b','c','d','e','f','g','h','i','j','k','m','n','o','p','q','r','s','t']
const SGF_Y=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]
const SGF_XY=[(i,j) for i in SGF_X for j in SGF_Y]

boardLayout=Layout(
	# boardSize are as big as setting
	# aspectmode="manual",aspectratio=1,
	width=930,
	height=820,
	paper_bgcolor="rgb(0,255,127)",
	plot_bgcolor="rgb(205,133,63)",
	xaxis_showgrid=false,
	xaxis=attr(
		# showline=true, mirror=true,linewidth=1,linecolor="black",
		# zeroline=true,zerolinewidth=1,zerolinecolor="rgb(205,133,63)",
		ticktext=['Z','A','B','C','D','E','F','G','H','J','K','L','M','N','O','P','Q','R','S','T','U'],
		tickvals=['z','a','b','c','d','e','f','g','h','i','j','k','m','n','o','p','q','r','s','t','u'] 
		# if tickvals is a number array, row/col lines will become a line  
		),
	yaxis_showgrid=false,
	yaxis=attr(
		# showline=true, mirror=true,linewidth=1,linecolor="black",
		zeroline=false,
		ticktext=['0','1','2','3','4','5','6','7','8','9',"10","11","12","13","14","15","16","17","18","19","20"],
		tickvals=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
		)
	)
rowLine=scatter(
	x=['a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t'],
	y=[1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19],
	# use fold lines to plot row/col lines
	mode="lines",
	line_width=1,
	line_color="rgb(0,0,0)",
	hoverinfo="skip",
	name="row lines"
	)
colLine=scatter(
	x=['z','a','a','b','b','c','c','d','d','e','e','f','f','g','g','h','h','i','i','j','j','k','k','m','m','n','n','o','o','p','p','q','q','r','r','s','s','t','t','u'],
	y=[1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19],
	# use (z,1) and (u,19) to widen col margin
	mode="lines",
	line_width=1,
	line_color="rgb(0,0,0)",
	hoverinfo="skip",
	name="col lines"
	)
starPoint=scatter(
	x=['d','j','q','d','j','q','d','j','q'],
	y=[4,4,4,10,10,10,16,16,16],
	mode="markers",
	marker_color="rgb(0,0,0)",
	name="star points"
	)
vertex=scatter(
	x=[SGF_XY[i][1] for i in range(1,length=19^2)],
	y=[SGF_XY[j][2] for j in range(1,stop=361)],
	mode="markers",
	marker_size=1,
	marker_color="rgba(205,133,63,0)",
	name="vertex"
	)
ownership=scatter(
	x=['i','k','r'],
	y=[10,11,5],
	mode="markers",
	marker=attr(
		symbol="diamond",
		color=["rgba(127,127,127,0.6)","rgba(255,255,255,0.6)","rgba(0,0,0,0.6)"],
		size=50,
		# opacity=0.6,
		line=attr(width=0)
		),
	name="ownership"
	)

topText="
### Hello, welcome to VastGoMaterial!

> A funny, green, simple, useful tool for the game of Go/Baduk/Weiqi
"

bottomText="
*powered by [Plotly Dash](https://dash-julia.plotly.com/), driven by [KataGo](https://katagotraining.org/), written in [Julia](https://julialang.org/)*
"

bottomDiv=dcc_markdown(bottomText)

function plot_board(colLine,rowLine,starPoint,vertex,stone,boardLayout)
	plot(
		[colLine,
		rowLine,
		starPoint,
		vertex,
		stone
		],
		boardLayout
		)
end
function color_turn(playerNumber=2,boardSize=19*19,chooseColor=["rgb(255,255,255)","rgb(0,0,0)"])

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
	dcc_graph(id="board2"),
	html_div(id="seeDebugData"),
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
		return plot_board(
			colLine,
			rowLine,
			starPoint,
			vertex,
			trace_stones(xArray,yArray),
			boardLayout
			)
	end

run_server(app, "0.0.0.0", debug=true)