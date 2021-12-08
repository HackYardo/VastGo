using JSON
using PlotlyJS
using Dash, DashHtmlComponents, DashCoreComponents

const KG_X=['a','b','c','d','e','f','g','h','j','k','l','m','n','o','p','q','r','s','t']
const KG_Y=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]
const KG_XY=[(i,j) for i in KG_X for j in KG_Y]

katagoCommand=`katago.exe gtp -config gtp_custom.cfg -model b6\\model.txt.gz`
katagoProcess=open(katagoCommand,"r+")

function query(sentence::String)
    while true
        if sentence=="" || "" in split(sentence," ")
            continue
        else
            println(katagoProcess,sentence)
            break
        end
    end
end
function reply()
    paragraph=""
    while true
        sentence=readline(katagoProcess)
        if sentence==""
            break
        else 
            paragraph="$paragraph$sentence\n"
        end
    end
    #println(paragraph)
    return paragraph::String
end

function board_state(paragraph::String)
    #vertex=Matrix{Char}(undef,19,19)
    vertexCol=split(paragraph,"\n")[3:21]
    xVector::Vector{Char}=[]
    yVector::Vector{Int8}=[]
    colorVector::Vector{String}=[]
    for i in range(1,length=length(vertexCol))
        j=1
        for c in vertexCol[i][4:2:40]
            if c in "XO"
                xVector=cat(xVector,[KG_X[j]],dims=1)
                yVector=cat(yVector,[20-i],dims=1)
                if c=='X'
                    colorVector=cat(colorVector,["rgb(255,255,255)"],dims=1)
                else
                    colorVector=cat(colorVector,["rgb(0,0,0)"],dims=1)
                end
            end
            j=j+1
        end
    end
    #println(vertex,"\n")
    #println("$xVector\n$yVector\n$colorVector\n")
    return xVector,yVector,colorVector
end

function cli_web(xyPlayer)
    if xyPlayer==""
        return [],[],[]
    else
        query("play B $xyPlayer")
        reply()
        query("genmove W")
        reply()
        query("showboard")
        paragraph=reply()
        xVector,yVector,colorVector=board_state(paragraph)
        return xVector,yVector,colorVector
    end
end



boardLayout=Layout(
    # boardSize are as big as setting
    # aspectmode="manual",aspectratio=1,
    width=930,
    height=836,
    paper_bgcolor="rgb(0,255,127)",
    plot_bgcolor="rgb(205,133,63)",
    xaxis_showgrid=false,
    xaxis=attr(
        # showline=true, mirror=true,linewidth=1,linecolor="black",
        # zeroline=true,zerolinewidth=1,zerolinecolor="rgb(205,133,63)",
        ticktext=['Z','A','B','C','D','E','F','G','H','J','K','L','M','N','O','P','Q','R','S','T','U'],
        tickvals=['z','a','b','c','d','e','f','g','h','j','k','l','m','n','o','p','q','r','s','t','u'] 
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
    x=['z','a','a','b','b','c','c','d','d','e','e','f','f','g','g','h','h','j','j','k','k','l','l','m','m','n','n','o','o','p','p','q','q','r','r','s','s','t','t','u'],
    y=[1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19,1,1,19,19],
    # use (z,1) and (u,19) to widen col margin
    mode="lines",
    line_width=1,
    line_color="rgb(0,0,0)",
    hoverinfo="skip",
    name="col lines"
    )
starPoint=scatter(
    x=['d','k','q','d','k','q','d','k','q'],
    y=[4,4,4,10,10,10,16,16,16],
    mode="markers",
    marker_color="rgb(0,0,0)",
    name="star points"
    )
vertex=scatter(
    x=[KG_XY[i][1] for i in range(1,length=19^2)],
    y=[KG_XY[j][2] for j in range(1,stop=361)],
    mode="markers",
    marker_size=1,
    marker_color="rgba(205,133,63,0)",
    name="vertex"
    )

topText="
### Hi, welcome to VastGo!

> A funny, green, simple, useful tool for the game of Go/Baduk/Weiqi
"

bottomText="
*powered by [Plotly Dash](https://dash-julia.plotly.com/), driven by [KataGo](https://katagotraining.org/), written in [Julia](https://julialang.org/)*
"
bottomMarkdown=dcc_markdown(bottomText)

someIssues="
### VastGo is on basic testing, there are some issues:
- [ ] KataGo starts up *twice* (may need to add a `run KataGo` button in Dash APP or thread/coroutines or I/O redicect or import/using *.jl?)
- [ ] Black stones are white and White stones are black?
- [ ] You can do nothing except placing **legal** stones and `ctrl+R` to refresh.
"

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

function trace_stones(xVector=[],yVector=[],colorVector=[])
    scatter(
        x=xVector,
        y=yVector,
        mode="markers",
        marker_color=colorVector,
        marker_size=25,
        name="stones"
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
    dcc_graph(id="board"),
    html_div(
        bottomMarkdown, 
        style=(width="100%",display="inline-block",textAlign="right"#=,float="right"=#)
        ),
    html_div(dcc_markdown(someIssues))
end

callback!(
    app,
    Output("board","figure"),
    Input("board","clickData"),
    ) do sth
        if sth != nothing
            sthJSON=JSON.json(sth)
            sthParse=JSON.parse(sthJSON)
            vector=sthParse["points"][1]
            xPlayer=vector["x"]
            yPlayer=vector["y"]
            xyPlayer="$xPlayer$yPlayer"
        else
            xyPlayer=""
        end
        xVector,yVector,colorVector=cli_web(xyPlayer)
        return plot_board(
            colLine,
            rowLine,
            starPoint,
            vertex,
            trace_stones(xVector,yVector,colorVector),
            boardLayout
            )
    end

run_server(app, "0.0.0.0", debug=true)