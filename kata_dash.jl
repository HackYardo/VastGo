using Dash, JSON, PlotlyJS

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

function run_engine()
    katagoCommand=`./katago gtp -config gtp_custom.cfg -model b6/model.txt.gz`
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
    println(sentence)
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
    println(paragraph)
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

function turns_taking(currentColor)
    if currentColor=="B"
        return "W"
    else
        return "B"
    end
end

function console_game(xyPlayer,colorPlayer)
    #gameInfoAll=agent_showboard()
    gameState=""
    engineMove=""
    nextColor=turns_taking(colorPlayer)

    if xyPlayer=="d0"
        gameState="over"
    else
        if xyPlayer in ["a0","b0"]
            query("play $colorPlayer pass")
            reply()
            #println("before pass")
        else
            query("play $colorPlayer $xyPlayer")
            paragraph=reply()
            if paragraph[1]=='?' gameState="over" end
        end
        query("genmove $nextColor")
        #println("after pass")
        engineMove=reply()[3:end-1]
        if engineMove=="resign" gameState="over" end
    end
    return gameState,engineMove
end

function checkRule(wholeRule)
    boardsize=wholeRule[1]
    query("boardsize $boardsize")
    reply()
    komi=wholeRule[2]
    query("komi $komi")
    reply()
    for c in wholeRule[3]
        query("kata-set-rule $c")
        reply()
    end
    currentBoard=agent_showboard()
    checkBoardVector=currentBoard["checkBoard"]
    checkBoard=""
    for c in checkBoardVector
        checkBoard="$checkBoard$c\n"
    end
    return checkBoard
end

function mode_color(colorVector,colorPlayer,modeColor)
    if modeColor=="blind"
        colorVector=["rgba(0,0,0,0)" for v in 1:length(colorVector)]
    elseif modeColor=="phantom"
        if colorPlayer=="B"
            for i in 1:length(colorVector)
                if colorVector[i] == "rgba(255,255,255,1)"
                    colorVector[i]="rgba(255,255,255,0)"
                end
            end
        else
            for j in 1:length(colorVector)
                if colorVector[j] == "rgba(0,0,0,1)"
                    colorVector[j]="rgba(0,0,0,0)"
                end
            end
        end
    elseif modeColor=="oneColour"
        for k in 1:length(colorVector)
            if colorVector[k] =="rgba(255,255,255,1)"
                colorVector[k]="rgba(0,0,0,1)"
            end
        end
    else
    end
    return colorVector
end
function color_stones(board)
    colorStones::Vector{String}=[]
    for vertex in board
        if vertex == 0
            colorStones=cat(colorStones,["rgba(0,0,0,0)"],dims=1)
        elseif vertex == -1
            colorStones=cat(colorStones,["rgba(0,0,0,1)"],dims=1)
        elseif vertex == 1
            colorStones=cat(colorStones,["rgba(255,255,255,1)"],dims=1)
        else
            continue
        end
    end
    return colorStones
end
function odd_key_even_value(dictString;c=": ")
    d=Dict{String,Any}()
    k=""
    j=1
    if dictString[1]=='='
        dictString=dictString[3:end]
        c=[' ',':']
    end
    if dictString[1]=='R'
        return Dict("Rules"=>odd_key_even_value(dictString[9:end-1];c=[':',',','"']))
    end
    for i in split(dictString,c;keepempty=false)
        if j==1
            k=i
            j=0
        else
            if i in ["false","true"]
                i=parse(Bool,i)
            elseif tryparse(Int8,i) != nothing
                i=tryparse(Int8,i)
            elseif tryparse(Float64,i) != nothing
                i=tryparse(Float64,i)
            else
            end
            d[k]=i
            j=1
        end
    end
    return d
end
#=
function wait_showboard()
    flag=true
    paragraphVector=[]
    while flag
        query("showboard")
        paragraph=reply()
        #println(paragraph)
        paragraphVector=split(paragraph,"\n",keepempty=false)
        if length(paragraphVector)>2
            flag=false
        end
        sleep(ℯ/π)
    end
    return paragraphVector
end
=#
function agent_showboard()
    query("showboard")
    paragraph=reply()
    paragraphVector=split(paragraph,"\n",keepempty=false)
    boardInfo=Dict{String,Any}()
    n=0
    for c in paragraphVector[2]
        if c in 'A':'T'
            n=n+1
        end
    end
    m=3
    b=Vector{Int8}()
    while paragraphVector[m][1] in "1 "
        for c in paragraphVector[m]
            if c=='X'
                b=cat(b,[-1],dims=1)
            elseif c=='O'
                b=cat(b,[1],dims=1)
            elseif c=='.'
                b=cat(b,[0],dims=1)
            else
                continue
            end
        end
        m=m+1
    end
    colorStones=color_stones(b)
    boardInfo["Board"]=b
    boardInfo["BoardColor"]=colorStones
    boardInfo["BoardSize"]=[n,m-3]
    for line in cat([paragraphVector[1]],paragraphVector[m:end],dims=1)
        boardInfo=merge(boardInfo,odd_key_even_value(line))
    end
    boardInfo["checkBoard"]=cat(paragraphVector[2:m-1],[json(boardInfo["Rules"],2)],dims=1)
    query("printsgf")
    sgfInfo=reply()[3:end]
    boardInfo["sgf"]=sgfInfo
    return boardInfo
end

function plot_board(boardSize,stones)
    Plot(
        [
        trace_line(boardSize)[1],
        trace_line(boardSize)[2],
        trace_star(boardSize),
        trace_synchroboard(),
        trace_resign(),
        trace_stones(boardSize,stones)
        ],
        layout_board()
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
    colX=cat(['z'],[xLine[1]],[xItem for xItem in xLine for i in 1:2],[xLine[end]],[GTP_X[boardSize[1]+2]],dims=1)
    colYDotLine=cat([0],[nothing],line_fold(yLine,xLine),[nothing],[GTP_Y[boardSize[2]+2]],dims=1)
    rowLine=scatter(
        x=rowX,
        y=rowY,
        mode="lines",
        line_width=1,
        line_color="rgb(0,0,0)",
        hoverinfo="skip",
        name="row lines"
        )
    colLine=scatter(
        x=colX,
        y=colYDotLine,
        mode="lines",
        line_width=1,
        line_color="rgb(0,0,0)",
        hoverinfo="skip",
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
    return starNum
end
function star_margin(axisNum)
    marginStar=4
    if axisNum<=12 marginStar=3 end
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
    scatter(
        x=xStar,
        y=yStar,
        mode="markers",
        marker_color="rgb(0,0,0)",
        name="star points"
        )
end
function trace_stones(boardSize,colorVector)
    xLine=GTP_X[2:boardSize[1]+1]
    yLine=reverse(GTP_Y[2:boardSize[2]+1])
    scatter(
        x=repeat(xLine,boardSize[2]),
        y=[yLine[i] for i in 1:boardSize[2] for j in 1:boardSize[1]],
        mode="markers",
        marker_color=colorVector,
        marker_size=25,
        name="stones"
        )
end
function trace_synchroboard()
    scatter(
        x=['a','b'],
        y=[0,0],
        mode="markers+text",
        marker=attr(
            color="rgb(205,133,63)",
            size=1
            ),
        text=["PA","SS"],
        textposition="inside",
        textfont=attr(color="rgb(255,255,255)",size=25),
        name="buttons"
        )
end
function trace_resign()
    scatter(
        x=['d'],
        y=[0],
        mode="markers+text",
        marker=attr(
            color="rgb(205,133,63)",
            size=1
            ),
        text=["Resign"],
        textposition="inside",
        textfont=attr(color="rgb(0,0,0)",size=25),
        name="resign"
        )
end
function layout_board()
    Layout(
    width=930,
    height=836,
    #aspectratio=attr(x=1,y=1),
    paper_bgcolor="rgb(0,255,127)",
    plot_bgcolor="rgb(205,133,63)",
    xaxis=attr(
        showgrid=false,
        ticktext=UI_X,
        tickvals=GTP_X
        ),
    yaxis_showgrid=false,
    yaxis=attr(
        zeroline=false,
        ticktext=UI_Y,
        tickvals=GTP_Y
        )
    )
end

topText="**Hi, welcome to VastGo!**
\n\nA funny, green, simple, useful tool for the game of Go/Baduk/Weiqi"

bottomText="*Have a nice game!*"

bottomMarkdown=dcc_markdown(bottomText)

someIssues="
### VastGo is on basic testing, there are some issues need to solve:
- [x] KataGo starts up ***twice*?**(may need to add a `run KataGo` button in Dash APP or thread/coroutines or I/O redicect or import/using *.jl?)
  - The [reason](https://community.plotly.com/t/why-global-code-runs-twice/12514).
- [x] You can do nothing except placing **legal** stones and `ctrl+R` to refresh.
  - Now you can redefine a game in the `Begin` tab.
- [ ] Can not run in multiple tabs/browsers (how to know global or local states?)
- [x] Rules(GameInfo), SGF and Click are too long, and have no 'space' to segment.
  - Use `dcc_textarea` instead of `dcc_markdown` or `html_div`.
- [x] Can not work in new version Dash because 
  - ArgumentError: PlotlyJS.SyncPlot doesn't have a defined `StructTypes.StructType`
  - The repo using old version Dash because DashDaq added
  - The [reason](https://github.com/plotly/Dash.jl/issues/153)
- [ ] Can not use DashBootstrapComponents to change app layout
  - Weird syntax and few documents/examples
  - Auto delete some spaces in GTP-output
- [ ] The board can not refresh autoly after change the size or obstacles.
  - Type `clear_board.` in GTP commands input or click `PASS` in the board plot instead.
- [x] The whb in showboard not be displayed now.
- [ ] The number of obstacles doesn't fit boardSize.
- [x] Can not pass more than one time.
  - Reason: Dash.jl's clickEvent doesn't response to it.
  - There are two pass buttons, **PA** and **SS**.
- [ ] **asyn**: `reply() != query()`
  - [ ] KataGo returns answer 2 before answer 1 sonmetimes[?](https://github.com/lightvector/KataGo/blob/master/docs/GTP_Extensions.md)
  - [ ] Dash.jl sends two commands at once sometimes.
  - [ ] The same two `clickData` does not run `callback!()` twice.
"
#----------------------------------------
# The up is tab1, the down is tab2
#----------------------------------------

whatGameLabel=html_summary("What's the game of Go/Baduk/Weiqi?")
whatGameInfo=dcc_markdown() do
    "
    \n>  A turn-based abstract strategy board game, in which the aim is to control more domains than the opponent.
    \n>  It was invented in China more than **2,500 years** ago and is believed to be the oldest board game continuously played to the present day. ***1 2***
    \n>***Turn-based***: players take turns to play
    \n>***Abstract***: not rely on a theme or simulate the real world
    \n>***Strategy***: players' choices determine the outcome
    \n>***Board Game***: a tabletop game that involves counters or pieces moved or placed on a pre-marked surface or \"board\" 
    \n>***Tabletop Game***: played on a table or other flat surface, such as board games, card games
    "
    end
whatGame=html_details() do
    whatGameLabel,
    whatGameInfo
    end

howPlayLabel=html_summary("How to play?")
howPlayInfo=dcc_markdown() do #TODO
    "
    \nJust try!
    "
    end
howPlay=html_details() do
    howPlayLabel,
    howPlayInfo
    end

rulesetReference=dcc_markdown() do
    "**Rule Sets** ***3***:"
end
rulesetButtons=html_div(style = Dict("columnCount" => 4)) do
    html_button("Fuzhou-like Rules",id="fRule"),
    html_button("Chinese-like Rules",id="cRule"),
    html_button("Japaness-like Rules",id="jRule"),
    html_button("Tromp-Taylor Rules",id="tRule"),
    html_button("OGS/KGS \"Chinese\"-like Rules",id="oRule"),
    html_button("AGA-like Rules",id="aRule"),
    html_button("New Zealand-like Rules",id="zRule"),
    html_button("Stone-Scoring Rules",id="sRule")
end
rulesetChecklists=html_div(style = Dict("columnCount" => 2)) do
    
    html_label("X,Y:",title="Integers indicating the board size."),
    dcc_input(id="SZ_X",value=19,type="number",min=2,step=1,max=19),
    dcc_input(id="SZ_Y",value=19,type="number",min=2,step=1,max=19),
    dcc_markdown(""),

    html_label("Komi:",title="Integer or half-integer indicating compensation given to White for going second."),
    dcc_input(id="KM",value=7.0,type="number",min=-150,step=0.5,max=150),
    dcc_markdown(""),

    html_label("KoRule:",title="The variant of the rule prohibiting repetition. https://senseis.xmp.net/?KoRules"),
    dcc_radioitems(id="ko",
        options = [
            Dict("label" => "Simple", "value" => "SIMPLE"),
            Dict("label" => "Positional Superko", "value" => "POSITIONAL"),
            Dict("label" => "Situational Superko", "value" => "SITUATIONAL")
            ],
        value = "POSITIONAL",
        ),
    
    html_label("ScoringRule:",title="Defines what the score of a finished game is. Area (count stones and surrounded empty points, \"Chinese\"-like); Territory (count captures and surrounded empty points, \"Japanese\"-like). https://senseis.xmp.net/?Scoring"),
    dcc_radioitems(id="score",
        options = [
            Dict("label" => "Area", "value" => "AREA"),
            Dict("label" => "Territory", "value" => "TERRITORY")
            ],
        value = "AREA",
        ),
    
    html_label("TaxRule:",title="Minor adjustments to scoring rule, indicating what, if any, empty points may not be scored. None (surrounded empty points always count); Seki (empty points surrounded by groups in seki do not count); All (all groups are taxed up to 2 of their surrounded empty points - i.e. empty points surrounded by groups in seki do not count, and living groups are taxed 2 points each)."),
    dcc_radioitems(id="tax",
        options = [
            Dict("label" => "None", "value" => "NONE"),
            Dict("label" => "Seki", "value" => "SEKI"),
            Dict("label" => "All", "value" => "ALL")
            ],
        value = "NONE",
        ),

    html_label("Button:",title="Whether a half-point is awarded to the first player to be able to pass. (e.g. slightly rewarding endgame efficiency, partially reconciling area and territory scoring)."),
    dcc_radioitems(id="buttonRule",
        options = [
            Dict("label" => "Used", "value" => "true"),
            Dict("label" => "Not Used", "value" => "false")
            ],
        value = "true",
        ),
    
    html_label("MultiStoneSuicide:",title="Whether suicide of multiple stones is allowed. (in these rules, a suicide move that kills only the stone just played and nothing else, leaving the board unchanged, is never allowed)"),
    dcc_radioitems(id="sui",
        options = [
            Dict("label" => "Allowed", "value" => "true"),
            Dict("label" => "Disallowed", "value" => "false")
            ],
        value = "false",
        ),
    
    html_label("WhiteHandicapBonus:",title="How many bonus points white receives during handicap games when black gets N stones. KataGo supports handicap games, but for simplicity, this rules document does NOT describe them. These checkboxes are included merely to provide a convenience reference as how this quirk of handicap game scoring differs between rulesets."),
    dcc_radioitems(id="whb",
        options = [
            Dict("label" => "0", "value" => "0"),
            Dict("label" => "N-1", "value" => "N-1"),
            Dict("label" => "N", "value" => "N")
            ],
        value = "0",
        )
end
rulesetDiv=html_div() do
    rulesetReference,
    rulesetButtons,
    rulesetChecklists
end

appendixDiv=dcc_markdown() do
    "
    \n**Appendix A Synonyms**:
    \nseki==symbiotic, handicap==obstacle, grid nodes==vertices
    \n**Appendix B Tips**:
    \n**a** If hover over the rule items, more details will be displayed.
    \n**b** If modify the obstacles, X, Y, the board will be cleared.
    \n**c** Button can't be used in territory-scoring.
    \n**Appendix C References**:
    \n***1*** [A Brief History of Go](https://www.usgo.org/brief-history-go). *American Go Association*, 2022
    \n***2*** Peter Shotwell. [The Game of Go: Speculations on its Origins and Symbolism in Ancient China](https://www.usgo.org/sites/default/files/bh_library/originsofgo.pdf). *American Go Association*, 2008.
    \n***3*** David J Wu. KataGo's Supported Go Rules (Version 2), 2021. https://lightvector.github.io/KataGo/rules.html. (not include the Fuzhou-button)
    "
end

ruleCheck=html_div() do
    dcc_markdown("**Rule Check**:"),
    html_button("SUBMIT",id="submitRule"),
    html_div(),
    dcc_textarea(
        placeholder="To check if the whole rule is valid...",
        id="confirmRule",
        style=Dict("width"=>"390px","height"=>"360px")
        ),
    html_div(),
    html_button("OK",id="okRule")
end

startGame=html_div(style = Dict("columnCount" => 2)) do
    whatGame,
    howPlay,
    dcc_markdown(
        "
        \n### Start Now:
        \nJust skip the rule items below and go to the `While` tab to play a game.
        \nOr check the items and click the `SUBMIT` to check the rule before a game.
        \nA game will over after 1 resign or 2 consecutive passes(not include the button-pass), and you will see the outcome.
        \n***Warning***: If you make a illegal move, the game will over.
        "
        ),

    html_label("To play first or not:"),
    dcc_radioitems(id="playerColor",
        options = [
            Dict("label" => "Black", "value" => "B"),
            Dict("label" => "White", "value" => "W")
            ],
        value = "B"
        ),

    html_label("Nonstandard Go——Visibility:",title="Search on https://senseis.xmp.net/ for more details"),
    dcc_radioitems(id="colorMode",
        options = [
            Dict("label" => "blind", "value" => "blind"),
            Dict("label" => "phantom", "value" => "phantom"),
            Dict("label" => "war fog", "value" => "warFog"),
            Dict("label" => "one colour", "value" => "oneColour"),
            Dict("label" => "standard", "value" => "standard")
            ],
        value = "standard"
        ),

    html_label("Fixed obstacles:",title="The obstacles are placed on the board on the vertices the GTP prefers, e.g. 2"),
    dcc_input(id="fObstacle",value="0",type="number",min=0,step=1,max=9),
    html_label("Placed obstacles:",title="The obstacles are placed on the board on the vertices the engine prefers, e.g. 2"),
    dcc_input(id="pObstacles",value="0",type="number",min=0,step=1,max=20),
    html_label("Set obstacles:",title="The obstacles are placed on the board on the vertices the player prefers, e.g. k10 q16"),
    dcc_input(id="sObstacles",value="",type="text"),

    rulesetDiv,
    ruleCheck,
    appendixDiv,
    dcc_markdown("**Debug:**"),
    html_div(id="rulesetBtn"),
    html_div(id="ruleSmt")
end

playGame=html_div() do
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
    dcc_textarea(id="Info",style=Dict("width"=>"900px","height"=>"300px",#="cols"=>2=#)),
    dcc_confirmdialog(id="finalDialog",message="",displayed=false),
    html_div(dcc_markdown(someIssues))
end

engineProcess=run_engine()

app=dash()

app.layout = html_div() do
    dcc_tabs(
        [
            dcc_tab(
                label="Begin",
                children=[startGame]
            ),
            dcc_tab(
                label="While",
                children=[playGame]
            ),
            dcc_tab(
                label="After",
                children=[]
            )
        ]
    )
end

callback!(
    app,
    Output("rulesetBtn","children"),
    Output("KM","value"),
    Output("ko","value"),
    Output("score","value"),
    Output("tax","value"),
    Output("buttonRule","value"),
    Output("sui","value"),
    Output("whb","value"),
    Input("fRule","n_clicks"),
    Input("cRule","n_clicks"),
    Input("jRule","n_clicks"),
    Input("tRule","n_clicks"),
    Input("oRule","n_clicks"),
    Input("aRule","n_clicks"),
    Input("zRule","n_clicks"),
    Input("sRule","n_clicks"),
) do btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8
    ctx = callback_context()

    if length(ctx.triggered) == 0
        button_id = "No clicks yet"
    else
        button_id = split(ctx.triggered[1].prop_id, ".")[1]
    end

    if button_id=="fRule"
        return "$button_id",7.0,"POSITIONAL","AREA","NONE","true","false","N"
    elseif button_id=="cRule"
        return "$button_id",7.5,"SIMPLE","AREA","NONE","false","false","N"
    elseif button_id=="jRule"
        return "$button_id",6.5,"SIMPLE","TERRITORY","SEKI","false","false","0"
    elseif button_id=="tRule"
        return "$button_id",7.5,"POSITIONAL","AREA","NONE","false","true","N"
    elseif button_id=="oRule"
        return "$button_id",7.5,"POSITIONAL","AREA","NONE","false","false","N"
    elseif button_id=="aRule"
        return "$button_id",7.5,"SITUATIONAL","AREA","NONE","false","false","N-1"
    elseif button_id=="zRule"
        return "$button_id",7.5,"SITUATIONAL","AREA","NONE","false","true","0"
    elseif button_id=="sRule"
        return "$button_id",7.5,"SIMPLE","AREA","ALL","false","false","N"
    else
        return "$button_id",7.0,"POSITIONAL","AREA","ALL","true","false","N"
    end
end

callback!(app,
    Output("ruleSmt","children"),
    Output("confirmRule","value"),
    Input("submitRule","n_clicks"),
    State("SZ_X","value"),
    State("SZ_Y","value"),
    State("KM","value"),
    State("ko","value"),
    State("score","value"),
    State("tax","value"),
    State("buttonRule","value"),
    State("sui","value"),
    State("whb","value"),
    ) do clicks,sx,sy,km,ko,sc,t,b,su,w
    ctx = callback_context()
    if length(ctx.triggered) == 0
        button_id = "Not submit yet"
    else
        button_id = split(ctx.triggered[1].prop_id, ".")[1]
    end
    if button_id=="submitRule"
        wholeRule=["$sx $sy","$km",["ko $ko","scoring $sc","tax $t","hasButton $b","suicide $su","whiteHandicapBonus $w"]]
        currentBoard=checkRule(wholeRule)
        return "$wholeRule",currentBoard
    else
        return button_id,""
    end
end

#---------------------------------------
# The up is tab2, the down is tab1
#---------------------------------------

callback!(
    app,
    Output("gtpO","value"),
    Input("gtpI","value"),
    ) do gtpInput
    gtp_io(gtpInput)
end

callback!(
    app,
    Output("finalDialog","message"),
    Output("finalDialog","displayed"),
    Output("Info","value"),
    Output("board","figure"),
    Input("board","clickData"),
    Input("okRule","n_clicks"),
    Input("playerColor","value"),
    Input("colorMode","value"),
    ) do sth,clicks,colorPlayer,modeColor
    ctx = callback_context()

    if length(ctx.triggered) == 0
        button_id = "No clicks yet"
    else
        button_id = split(ctx.triggered[1].prop_id, ".")[1]
    end

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
        query("clear_board")
        reply()
    end

    gameInfo=Dict()
    #gameInfo["Engine Move"]=""
    gameState=""
    finalScore=""
    dialogDisplay=false
    if button_id=="playerColor"
        if colorPlayer=="B"
            query("genmove W")
        else
            query("genmove B")
        end
        engineMove=reply()[3:end-1]
        gameInfo["Engine Move"]=engineMove
        if engineMove=="resign" gameState="over" end
    end
    if button_id == "board"
        gameState,engineMove=console_game(xyPlayer,colorPlayer)
        gameInfo["Engine Move"]=engineMove
    end
    
    gameInfoAll=agent_showboard()
    if gameState=="over" || occursin("RE[",gameInfoAll["sgf"])
        query("final_score")
        finalScore=reply()[3:end-1]
        dialogDisplay=true
        #query("final_status_list dead,seki")
        #finalStatus=reply()[3:end-1]
        #gameInfo["Final Score"]=finalScore
    end

    for k in ["Next player","MoveNum","W stones captured","B stones captured"]
        push!(gameInfo, k => gameInfoAll[k])
    end
    whbs="Handicap bonus score"
    if whbs in keys(gameInfoAll)
        push!(gameInfo, whbs => gameInfoAll[whbs])
    end

    boardSize=gameInfoAll["BoardSize"]
    #boardSize=[parse(Int8,split(boardSizeString)[i]) for i in 1:2]
    colorVector=gameInfoAll["BoardColor"]
    if modeColor != "standard"
        if "Engine Move" in keys(gameInfo) && gameInfo["Engine Move"] != "" && modeColor in ["phantom","warFog"]
            gameInfo["Engine Move"]=""
        end
        colorVector=mode_color(colorVector,colorPlayer,modeColor)
    end

    gameInfo=json(gameInfo,2)

    sgfInfo=gameInfoAll["sgf"]

    info=" GameInfo:\n$gameInfo SGF:\n$sgfInfo\n ClickInfo:\n$clickData"

    return finalScore,dialogDisplay,info, plot_board(boardSize,colorVector)
end

run_server(app, "0.0.0.0", debug=true)
