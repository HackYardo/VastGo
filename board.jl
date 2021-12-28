using PlotlyJS

function const_generate()
    sgfX=cat(Vector('a' : 'k'),Vector('m' : 't'),dims=1)
    sgfY=[c for c in reverse(sgfX)]
    sgfXY=[string(sgfX[i],sgfY[j]) for j in 1:19 for i in 1:19]

    gtpX=cat(['z'],Vector('a' : 'h'),Vector('j' : 'u'),dims=1)
    gtpY=Vector(0:20)
    gtpXY=["$j$i" for i in reverse(gtpY) for j in gtpX]

    uiX=[uppercase(gtpX[i]) for i in 1:length(gtpX)]
    uiY=[string(gtpY[j]) for j in 1:length(gtpY)]
    uiXY=[(j,i) for i in reverse(uiY) for j in uiX]
    return sgfX,sgfY,sgfXY,gtpX,gtpY,gtpXY,uiX,uiY,uiXY
end

const SGF_X,SGF_Y,SGF_XY,GTP_X,GTP_Y,GTP_XY,UI_X,UI_Y,UI_XY=const_generate()

function layout_board()
    Layout(
    # boardSize are as big as setting
    # aspectmode="manual",aspectratio=1,,
    #aspectmode="data",
    #width=930,height=836,
    paper_bgcolor="rgb(0,255,127)",
    plot_bgcolor="rgb(205,133,63)",
    #plot_ratio=1,
    #margin=attr(l=0,r=0,t=0,b=0),
    xaxis_showgrid=false,
    xaxis=attr(
        # showline=true, mirror=true,linewidth=1,linecolor="black",
        # zeroline=true,zerolinewidth=1,zerolinecolor="rgb(205,133,63)",
        ticktext=UI_X,
        tickvals=GTP_X
        # if tickvals is a number array, row/col lines will become a line  
        ),
    yaxis_showgrid=false,
    yaxis=attr(
        # showline=true, mirror=true,linewidth=1,linecolor="black",
        zeroline=false,
        ticktext=UI_Y,
        tickvals=GTP_Y
        )
    )
end

function line_fold(axisFold,axisCount)
    lineFold=[axisFold[1],axisFold[end]]
    N=length(axisCount)-1
    for n in 1:N
        if n%2==0
            lineFold=cat(lineFold,[axisFold[1]],[axisFold[end]],dims=1)
        else
            lineFold=cat(lineFold,[axisFold[end]],[axisFold[1]],dims=1)
        end
    end
    return lineFold
end
function trace_line(boardSize)
    xLine=GTP_X[2:boardSize[1]+1]
    yLine=GTP_Y[2:boardSize[2]+1]
    rowX=line_fold(xLine,yLine)
    rowY=[yItem for yItem in yLine for j in 1:2]
    #colX=[xItem for xItem in xLine for i in 1:2]
    colX=cat(['z'],[xLine[1]],[xItem for xItem in xLine for i in 1:2],[xLine[end]],[GTP_X[boardSize[1]+2]],dims=1)
    #colYLine=cat(line_fold(yLine,xLine),[boardSize[1]%2==0 ? yLine[1] : yLine[end]],dims=1)
    colYDotLine=cat([0],[nothing],line_fold(yLine,xLine),[nothing],[GTP_Y[boardSize[2]+2]],dims=1)
    #println(colYDotLine)
    rowLine=scatter(
        #x=['a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t','t','a','a','t'],
        #y=[1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19],
        # use fold lines to plot row/col lines
        x=rowX,
        y=rowY,
        mode="lines",
        line_width=1,
        line_color="rgb(0,0,0)",
        name="row lines"
        )
    colLine=scatter(
        #x=['z','a','a','b','b','c','c','d','d','e','e','f','f','g','g','h','h','i','i','j','j','k','k','m','m','n','n','o','o','p','p','q','q','r','r','s','s','t','t','u'],
        #y=[1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19],
        # use (z,1) and (u,19) to widen col margin, if the board is 19x19
        x=colX,
        y=colYDotLine,
        mode="lines",
        line_width=1,
        line_color="rgb(0,0,0)",
        #marker_size=1,
        #marker_color="rgb(0,0,0)",
        name="col lines"
        )
    return colLine,rowLine
end

function star_count(axisNum)
    starNum=0
    if axisNum<7
        starNum=0
    else
        if axisNum==7 || axisNum%2==0
            starNum=2
        else
            starNum=3
        end
    end
    #println(starNum)
    return starNum
end
function star_margin(axisNum)
    marginStar=4
    if axisNum<=12 marginStar=3 end
    #println(marginStar)
    return marginStar
end
function star_cross(axisSize,starNum,starMargin)
    starCross=[]
    if starNum != 0
        if starMargin==3
        starCross=[4,axisSize-1]
        else
        starCross=[5,axisSize-2]
        end
        if starNum==3
            starCross=cat(starCross,[div(axisSize+1,2)+1],dims=1)
        end
    end
    #println(starCross)
    return starCross
end
function trace_star(boardSize)
    xBoard=boardSize[1]
    yBoard=boardSize[2]
    rowNum=star_count(xBoard)
    colNum=star_count(yBoard)
    numStar=rowNum*colNum
    rowMargin=star_margin(xBoard)
    colMargin=star_margin(yBoard)
    xCrossIndex=star_cross(xBoard,rowNum,rowMargin)
    yCrossIndex=star_cross(yBoard,colNum,colMargin)
    xCross=[GTP_X[i] for i in xCrossIndex]
    yCross=[GTP_Y[j] for j in yCrossIndex]
    xStar=[xItem for xItem in xCross for k in 1:colNum]
    yStar=repeat(yCross,rowNum)
    #println("$xStar\n$yStar")
    scatter(
        x=xStar,
        y=yStar,
        mode="markers",
        marker_color="rgb(0,0,0)",
        name="star points"
        )
end

#boardStone=
    # colors are as many as players: black,white,...
whiteStone=scatter(
    x=['k','d','r'],
    y=[10,16,3],
    mode="markers",
    marker_color="rgb(255,255,255)",
    marker_size=30,
    name="White stones"
    )
blackStone=scatter(
    mode="markers+text",
    x=['q','d','c'],
    y=[16,3,6],
    marker=attr(
        color="rgb(0,0,0)",
        size=30
        ),
    text=["1","361"],textposition="inside",textfont=attr(color="rgba(255,255,255,1)",size=[24,12]),
    name="Black stones"
    )

ownership=scatter(
    x=['q','q','r','k'], # i ?
    y=[6,16,3,10],
    mode="markers",
    marker=attr(
        symbol="diamond",
        color=["rgba(127,127,127,0.6)","rgba(0,0,0,0.6)","rgba(255,255,255,0.6)","rgba(0,0,0,0.6)"],
        size=36,
        # opacity=0.6,
        line=attr(
            width=0)
        ),
    name="ownership"
    )

function plot_board(boardSize)
    plot(
        [
        trace_line(boardSize)[1],
        trace_line(boardSize)[2],
        trace_star(boardSize),
        whiteStone,
        blackStone,
        ownership
        ],
        layout_board()
    )
end

function main()
        boardSize="19 19"
        plot_board([parse(Int8,split(boardSize)[i]) for i in 1:2])
end

main()
