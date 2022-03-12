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
function agent_showboard(paragraph)
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
    boardInfo["BoardSize"]=[m-3,n]
    for line in cat([paragraphVector[1]],paragraphVector[m:end],dims=1)
        boardInfo=merge(boardInfo,odd_key_even_value(line))
    end
    boardInfo["checkBoard"]=cat(paragraphVector[2:m-1],[json(boardInfo["Rules"],2)],dims=1)
    return boardInfo
end

whatGameLabel=html_summary("What's the game of Go/Baduk/Weiqi?")
whatGameInfo=dcc_markdown() do
    "
    \nA turn-based abstract strategy board game, in which the aim is to control more domains than the opponent.
    \nIt was invented in China more than **2,500 years** ago and is believed to be the oldest board game continuously played to the present day. ***1 2***
    \n***Turn-based***: players take turns to play
    \n***Abstract***: not rely on a theme or simulate the real world
    \n***Strategy***: players' choices determine the outcome
    \n***Board Game***: a tabletop game that involves counters or pieces moved or placed on a pre-marked surface or \"board\" 
    \n***Tabletop Game***: played on a table or other flat surface, such as board games, card games
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

#=#TODO
TimeSetting:
Players: other colors: ;Teams:
#SetupMode: DotsGo-miai, DotsGo-ko, ...
ColorMode: FogofWar
=#

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
    dcc_input(id="SZ_X",value=19,type="number"),
    dcc_input(id="SZ_Y",value=19,type="number"),
    dcc_markdown(""),

    html_label("Komi:",title="Integer or half-integer indicating compensation given to White for going second."),
    dcc_input(id="KM",value=7.0,type="number"),
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
    \n***a*** If hover over the rule items, more details will be displayed.
    \n***b*** If modify the obstacles, X, Y, the board will be cleared.
    \n**Appendix C References**:
    \n***1*** [A Brief History of Go](https://www.usgo.org/brief-history-go). *American Go Association*, 2022
    \n***2*** Peter Shotwell. [The Game of Go: Speculations on its Origins and Symbolism in Ancient China](https://www.usgo.org/sites/default/files/bh_library/originsofgo.pdf). *American Go Association*, 2008.
    \n***3*** David J Wu. KataGo's Supported Go Rules (Version 2), 2021. https://lightvector.github.io/KataGo/rules.html. (not include the Fuzhou-button)
    "
end

ruleCheck=html_div() do
    dcc_markdown("**Rule Check**:"),
    html_button("SUBMIT",id="submitRule"),
    dcc_textarea(placeholder="To check if the whole rule is valid...",id="confirmRule")
end

startGame=html_div(style = Dict("columnCount" => 2)) do
    whatGame,
    howPlay,
    dcc_markdown(
        "
        \n### Start Now:
        \nJust skip the rule items below and go to the `While` tab to play a game.
        \nOr check the items and click the `SUBMIT` to check the rule before a game.
        \nA game will over after 1 resign or 2 passes(not include the button-pass), and you will see the outcome.
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

    html_label("Color mode:",title="Search on https://senseis.xmp.net/ for more details"),
    dcc_radioitems(id="colorMode",
        options = [
            Dict("label" => "blind", "value" => "blind"),
            Dict("label" => "phantom", "value" => "phantom"),
            Dict("label" => "one-color", "value" => "oneColor"),
            Dict("label" => "standard", "value" => "standard")
            ],
        value = "standard"
        ),

    html_label("Fixed obstacles:",title="The obstacles are placed on the board on the vertices the GTP prefers, e.g. 2"),
    dcc_input(id="fObstacle",value="0",type="number"),
    html_label("Placed obstacles:",title="The obstacles are placed on the board on the vertices the engine prefers, e.g. 2"),
    dcc_input(id="pObstacles",value="0",type="number"),
    html_label("Set obstacles:",title="The obstacles are placed on the board on the vertices the player prefers, e.g. k10 q16"),
    dcc_input(id="sObstacles",value="",type="text"),

    rulesetDiv,
    ruleCheck,
    appendixDiv,
    dcc_markdown("**Debug:**"),
    html_div(id="rulesetBtn"),
    html_div(id="ruleSmt")
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
                children=[]
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
    query("showboard")
    paragraph=reply()
    currentBoard=agent_showboard(paragraph)
    checkBoardVector=currentBoard["checkBoard"]
    checkBoard=""
    for c in checkBoardVector
        checkBoard="$checkBoard$c\n"
    end
    return checkBoard
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
    wholeRule=["$sx $sy","$km",["ko $ko","scoring $sc","tax $t","hasButton $b","suicide $su","whiteHandicapBonus $w"]]
    currentBoard=checkRule(wholeRule)
    "$wholeRule",currentBoard
end

run_server(app, "0.0.0.0", debug=true)