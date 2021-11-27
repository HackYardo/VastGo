using PlotlyJS

boardLayout=Layout(
	# boardSize are as big as setting
	# aspectmode="manual",aspectratio=1,
	width=1000,height=920,
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
	name="row lines"
	)

colLine=scatter(
	x=['z','a','a','b','b','c','c','d','d','e','e','f','f','g','g','h','h','i','i','j','j','k','k','m','m','n','n','o','o','p','p','q','q','r','r','s','s','t','t','u'],
	y=[1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19],
	# use (z,1) and (u,19) to widen col margin
	mode="lines",
	line_width=1,
	line_color="rgb(0,0,0)",
	name="col lines"
	)

starPoint=scatter(
	x=['d','j','q','d','j','q','d','j','q'],
	y=[4,4,4,10,10,10,16,16,16],
	mode="markers",
	marker_color="rgb(0,0,0)",
	name="star points"
	)

#boardStone=
	# colors are as many as players: black,white,...
whiteStone=scatter(
	x=['k','k'],
	y=[10,11],
	mode="markers",
	marker_color="rgb(255,255,255)",
	marker_size=16,
	name="White stones"
	)
blackStone=scatter(
	mode="markers+text",
	x=['d','r'],
	y=[3,5],
	marker=attr(
		color="rgb(0,0,0)",
		size=16
		),
	text=["1","3"],textposition="inside",textfont=attr(color="rgba(255,255,255,1)",size=24),
	name="Black stones"
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
		line=attr(
			width=0)
		),
	name="ownership"
	)

board=plot([colLine, rowLine, starPoint, whiteStone, blackStone, ownership], boardLayout)



# Sublime Text 代码层次导航：ctrl F2 打标签，shitf ctrl [] 折叠/展开，F2 浏览标签
#	或者 ctrl M 跳括号
#	ctrl G 跳转到行数
#	ctrl U 跳转到上一个改变
#	MENU Edit Code Folding