using Dash, JSON, PlotlyJS

include("gtp.jl")
include("board.jl")
include("tab.jl")
include("visibility.jl")
include("magnet.jl")

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
    if currentColor in ["B","b"]
        return "W"
    else
        return "B"
    end
end

function console_game(colorPlayer,vertexPlayer,mode)
    #gameInfoAll=agent_showboard()
    gameState = ""
    vertexEngine = ""
    nextColor = turns_taking(colorPlayer)

    if vertexPlayer == "d0"
        gameState = "over"
    else
        if vertexPlayer in ["a0","b0"]
            query("play $colorPlayer pass")
            reply()
        else
            gameState = play_mode(colorPlayer,vertexPlayer,mode)
        end
        vertexEngine = genmove_mode(nextColor,mode)
    end

    return gameState,vertexEngine
end

function play_mode(color,vertex,mode)
    gameState = ""
    query("play $color $vertex")
    paragraph = reply()[1]
    if paragraph == '?' 
        gameState = "over" 
    elseif mode == "magnet"
        query("undo")
        reply()
        position = agent_showboard()["Position"]
        color,vertex = abc_num(color,vertex,size(position)[2])
        magnet_turn(color,vertex,position)
    else
    end
    return gameState
end

function genmove_mode(color,mode)
    gameState = ""
    query("genmove $color")
    vertex = reply()[3:end-1]
    if vertex == "resign" 
        gameState = "over" 
    elseif vertex == "pass"
    else
        if mode == "magnet"
        query("undo")
        reply()
        position = agent_showboard()["Position"]
        magnet_turn(color,vertex,position)
        else
        end
    end
    return vertex,gameState
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

engineProcess=run_engine()

app=dash()

app.title = "VastGo | A funny,green,simple,useful tool for the game of Go/Baduk/Weiqi!"

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
    Input("moveMode","value"),
    Input("SZ_X","value"),
    Input("SZ_Y","value"),
    ) do sth,clicks,colorPlayer,modeColor,modeMove,bx,by
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
        xyPlayer = ""
        clickData = "null"
        query("clear_board")
        reply()
    end

    gameInfo=Dict()
    gameState=""
    finalScore=""
    dialogDisplay=false

    if button_id == "playerColor"
        nextColor = turns_taking(colorPlayer)
        vertexEngine = genmove_mode(nextColor,modeMove)
        gameInfo["Engine Move"] = vertexEngine
        if vertexEngine == "resign" gameState = "over" end
    end

    if button_id == "board"
        gameState,engineMove = console_game(colorPlayer,xyPlayer,modeMove)
        gameInfo["Engine Move"] = engineMove
    end

    gameInfoAll = agent_showboard()

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

#server = app.server # no server field?

@async run_server(app, "0.0.0.0", 8050, debug=false)

function kata_dash()
    while true
        if readline() == "exit"
            break
        end
    end
end

kata_dash()
