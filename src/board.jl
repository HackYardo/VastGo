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
        #tickfont = attr(size = 25) 
        ),
    yaxis_showgrid=false,
    yaxis=attr(
        # showline=true, mirror=true,linewidth=1,linecolor="black",
        zeroline=false,
        ticktext=["$i" for i in 0:20],
        tickvals = [i for i in 0:20]
        )
    )

function trace_line(boardsizeX, boardsizeY)
    range1 = [i for i in 1:boardsizeY for j in 1:3]
    range2 = repeat([1, boardsizeX, nothing], boardsizeY)
    range3 = [i for i in 1:boardsizeX for j in 1:3]
    range4 = repeat([1, boardsizeY, nothing], boardsizeX)
    scatter(
        x = cat(range1, range4, dims=1),
        y = cat(range2, range3, dims=1),
        mode="lines",
        line_width=1,
        line_color="rgb(0,0,0)",
        hoverinfo="skip",
        name="board lines"
        )
end 
function trace_anchor(m, n)
    scatter(
    x = [0, n],
    y = [m, 0],
    mode = "text",
    textposition = "inside",
    text = "+",
    textfont = attr(size = 10, color = "rgba(0,0,0,1)"),
    hoverinfo = "skip",
    name = "anchors"
    )
end

function star_count(boardsize)
    starNum=0
    if boardsize<7
        starNum=0
    else
        if boardsize==7 || boardsize%2==0
            starNum=2
        else
            starNum=3
        end
    end
    #println(starNum)
    return starNum
end
function star_margin(boardsize)
    marginStar=4
    if boardsize<=12 marginStar=3 end
    #println(marginStar)
    return marginStar
end
function star_cross(boardsize,starNum,starMargin)
    starCross = Int[]
    if starNum != 0
        if starMargin==3
            starCross = [3, boardsize-2]
        else
            starCross = [4,boardsize-3]
        end
        if starNum==3
            starCross = cat(starCross, [div(boardsize+1, 2)], dims=1)
        end
    end
    #println(starCross)
    return starCross
end
function trace_star(boardsizeX, boardsizeY)
    xBoard=boardsizeX
    yBoard=boardsizeY
    rowNum=star_count(xBoard)
    colNum=star_count(yBoard)
    rowMargin=star_margin(xBoard)
    colMargin=star_margin(yBoard)
    xCross = star_cross(xBoard,rowNum,rowMargin)
    yCross = star_cross(yBoard,colNum,colMargin)
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
function trace_text()
    u = ['\u23f2', Char(0x1f3f3), "Synch","ronize"#=,
        '\u2713', '\u2717', '\u26aa', '\u26ab'=#]
    scatter(
        x = [1, 2.25, 4, 6, 8, 10, 12, 14],
        y = [0, 0, 0, 0, 0, 0, 0, 0],
        mode = "text",
        textposition = "inside",
        text = u,
        textfont = attr(
            size = [60, 32, 22, 22, 25, 25, 25, 25], 
            color = [
            "rgb(0,0,0)", "rgb(255,255,255)",
            "rgb(0,0,0)", "rgb(255,255,255)",
            "rgb(0,0,0)", "rgb(255,255,255)",
            "rgb(0,0,0)", "rgb(255,255,255)"]
        ),
        name = "text"
    )
end

function trace_stone(xVector, yVector, colorVector)
    scatter(
        x = xVector,
        y = yVector,
        mode="markers",
        marker_color= colorVector,
        marker_size=25,
        name="stones"
        )
end

function plot_board(m, n, stone)
    Plot(
        [trace_anchor(m, n),
        trace_line(m, n),
        trace_star(m, n),
        stone,
        trace_text()],
        boardLayout
        )
end

board = plot_board(19, 19, 
    trace_stone(
        repeat([i for i in 1:19], 19), 
        [i for i in 19:-1:1 for j in 1:19], 
        repeat("rgba(0,0,0,0)",361)
        )
    )

boardGraph = dcc_graph(id = "boardGraph", 
    figure = board
    )
infoTextarea = dcc_textarea(id = "infoTextarea",
    style = Dict("height" => 361, "width" => 800)
    )
