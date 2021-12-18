using JSON
using PlotlyJS
using Dash

const UI_X=['a','b','c','d','e','f','g','h','j','k','l','m','n','o','p','q','r','s','t'];
const UI_Y=Vector(1:19);
const UI_XY=[(i,j) for i in reverse(UI_Y) for j in UI_X];

function run_engine()
    katagoCommand=`katago.exe gtp -config gtp_custom.cfg -model b6\\model.txt.gz`
    katagoProcess=open(katagoCommand,"r+")
    return katagoProcess
end
function end_engine()
    query("quit",engineProcess)
    reply(engineProcess)
    close(engineProcess)
end
function query(sentence::String)
    println(engineProcess,sentence)
end
function reply()
    paragraph=""
    while true
        sentence=readline(engineProcess)
        if sentence==""
            break
        else 
            paragraph="$paragraph$sentence\n"
        end
    end
    #println(paragraph)
    return paragraph::String
end
function gtp_io(sentence)
    if sentence != "" && !("" in split(sentence," "))
        if sentence[end]=='.' && sentence[end-1] != ' '
            sentence=sentence[1:end-1]
            query(sentence)
            paragraph=reply()
            return "$sentence\n$paragraph"
        else
            return ""
        end
    else
        return ""
    end
end
function board_state()
    query("showboard")
    paragraph=reply()
    query("printsgf")
    sgf=reply()[3:end]
    paragraphVector=split(paragraph,"\n")
    #vertex=Matrix{Char}(undef,19,19)
    vertexCol=paragraphVector[3:21]
    #xVector::Vector{Char}=[]
    #yVector::Vector{Int8}=[]
    colorVector::Vector{String}=[]
    moveNumHash=paragraphVector[1][3:end]
    turn=paragraphVector[22]
    rule=paragraphVector[23]
    capturesB=paragraphVector[24]
    capturesW=paragraphVector[25]
    for i in range(1,length=length(vertexCol))
        j=1
        for c in vertexCol[i][4:2:40]
            if c in "X.O"
                #xVector=cat(xVector,[UI_X[j]],dims=1)
                #yVector=cat(yVector,[20-i],dims=1)
                if c=='X'
                    colorVector=cat(colorVector,["rgba(0,0,0,1)"],dims=1)
                elseif c=='O'
                    colorVector=cat(colorVector,["rgba(255,255,255,1)"],dims=1)
                else
                    colorVector=cat(colorVector,["rgba(255,255,255,0)"],dims=1)
                end
            end
            j=j+1
        end
    end
    #println(vertex,"\n")
    #println("$xVector\n$yVector\n$colorVector\n")
    positionInfo="
    - $turn
    - $capturesB
    - $capturesW
    - $rule
    - $moveNumHash

    SGF:
    $sgf
    "
    return colorVector,positionInfo
end
function gtp_component(sentence)
    query(sentence)
    paragraph=reply()
end
function cli_web(xyPlayer)
    if xyPlayer==""
        query("clear_board")
        reply()
    else
        query("play B $xyPlayer")
        reply()
        query("genmove W")
        reply()
    end
    return board_state()
end

function plot_board(colLine,rowLine,starPoint,stone,boardLayout)
    Plot(
        [colLine,
        rowLine,
        starPoint,
        stone
        ],
        boardLayout
        )
end

function trace_stones(colorVector)
    scatter(
        x=[UI_XY[i][2] for i in range(1,length=19^2)],
        y=[UI_XY[j][1] for j in range(1,stop=361)],
        mode="markers",
        marker_color=colorVector,
        marker_size=25,
        name="stones"
        )
end

function boardLayout()
    Layout(
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
end
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

topText="### Hi, welcome to VastGo!
A funny, green, simple, useful tool for the game of Go/Baduk/Weiqi"

bottomText="*Have a nice game!*"

bottomMarkdown=dcc_markdown(bottomText)

someIssues="
### VastGo is on basic testing, there are some issues need to solve:
- [x] KataGo starts up ***twice*?**(may need to add a `run KataGo` button in Dash APP or thread/coroutines or I/O redicect or import/using *.jl?)
  - The [reason](https://community.plotly.com/t/why-global-code-runs-twice/12514).
- [ ] You can do nothing except placing **legal** stones and `ctrl+R` to refresh.
- [ ] Can not run in multiple tabs/browsers (how to know global or local states?)
- [ ] Rules, SGF and Click are too long, and have no 'space' to segment.
- [x] Can not work in new version Dash because 
  - ArgumentError: PlotlyJS.SyncPlot doesn’t have a defined `StructTypes.StructType`
  - The repo using old version Dash because DashDaq added
  - The [reason](https://github.com/plotly/Dash.jl/issues/153)
- [ ] Can not use DashBootstrapComponents to change app layout
  - Weird syntax and few documents/examples
  - Auto delete some spaces in GTP-output
"

engineProcess=run_engine();

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
    html_div(
        [
        dcc_graph(id="board"),
        html_div(
            [
            dcc_textarea(
                id="gtpO",
                #placeholder = "Enter a value...",
                #value="This is a TextArea component",
                style=Dict("width"=>"900px","height"=>"800px")
                );
            dcc_input(
                id="gtpI",
                placeholder="GTP commands end with a '.'",
                value="",
                type="text",
                style=Dict("width"=>"900px","height"=>"30px")
                )
            ],
            style=Dict("float"=>"right")
            )
        ],
        style=Dict("columnCount"=>"2")
        ),
    html_div(
        bottomMarkdown, 
        style=(width="100%",display="inline-block",textAlign="right"#=,float="right"=#)
        ),
    dcc_markdown(id="Info"),
    html_div(dcc_markdown(someIssues))
end

callback!(
    app,
    Output("gtpO","value"),
    Input("gtpI","value"),
    ) do gtpInput
        gtp_io(gtpInput)
    end

callback!(
    app,
    Output("Info","children"),
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
            clickData="$sthJSON"
        else
            xyPlayer=""
            clickData="null"
        end
        colorVector,positionInfo=cli_web(xyPlayer)
        info="
        $positionInfo
        
        Click:
        $clickData
        "
        return info, plot_board(
            colLine,
            rowLine,
            starPoint,
            trace_stones(colorVector),
            boardLayout()
            )
    end

run_server(app, "0.0.0.0", debug=true)
