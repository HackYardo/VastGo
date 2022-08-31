using Dash
using PlotlyBase  # Layout(), scatter(), Plot()
import JSON3  # JSON3.read(), JSON3.write(), JSON3.pretty()
include("src/board.jl")  
    # VERTEX
    # trace_stone(), plot_board(), plot_board!()
include("src/gotextprotocol.jl")  
    # include("utility.jl")  # findindex()
    # bot_get(), bot_run(), query(), reply()
    # gtp_ready(), gtp_loop(), showboard_get(), showboard_format()
include("src/menu.jl")  # topText, bottomText, 

function color_rgba(color)
    colorDict = Dict(
        "" => "rgba(0,0,0,0)",
        "W" => "rgba(255,255,255,1)",
        "B" => "rgba(0,0,0,1)",
        "A" => "rgba(255,0,0,1)",
        "C" => "rgba(0,255,0,1)",
        "D" => "rgba(0,0,255,1)",
        "S" => "rgba(255,255,0,1)",
        "G" => "rgba(255,0,255,1)",
        "R" => "rgba(0,255,255,1)"
        )
    colorDict[color]
end

function color_turn(color)
    colorVector = ["B", "W"]
    idx = findindex(color, colorVector)[1]
    if idx == length(colorVector)
        idx = 0 
    end
    colorVector[idx + 1]
end 
function move_replenish(proc, color)
    query(proc, "genmove $color")
    reply(proc)[3:end-1]
end

function gtp_turn(proc::Base.Process, color, vertex)
    query(proc, "play $color $vertex")
    reply(proc)
    
    color = color_turn(color)
    query(proc, "genmove $color")
    reply(proc)[3:end-1]
end

function boardinfo!(proc, button_id, color, vertex)
    botVertex = move_replenish(botProcess, color)
    query(botProcess, "showboard")
    board = showboard_format(botProcess, ifprint=false)
    info = board.i * "last move at: $botVertex\n"
    
    botVertex = "none\n"
    vertex = "none"
    
    botVertex = gtp_turn(botProcess, "B", vertex)
    
    query(proc, "showboard")
    board = showboard_format(proc, ifprint=false)
    
    info = board.i * "last move at: $botVertex\n"
    
    return info, plot_board!(trace_stones(board.x,board.y,board.c))
end

board = plot_board()

bot = bot_get()
botProcess = bot_run(dir=bot.dir, cmd=bot.cmd)
gtp_ready(botProcess)

app=dash()
app.title = "VastGo"
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
    chooseColor,
    dcc_graph(id = "board", figure=board),
    dcc_textarea(id = "info", 
        style = Dict("height" => 256, "width" => 800)
        ),
    html_div(id="seeDebugData"),
    dcc_graph(figure = Plot(longVector)),
    html_div(
        bottomText, 
        style=(width="49%",display="inline-block",float="right")
        )
end

callback!(app,
    Output("info", "value"),
    Output("board", "figure"),
    Input("board", "clickData"),
    Input("ChooseColor", "value"),
    ) do sth, color

    ctx = callback_context()
    if length(ctx.triggered) == 0
        button_id = "none"
    else
        button_id = split(ctx.triggered[1].prop_id, ".")[1]
    end

    #io = IOBuffer()  # for JSON3.pretty()
    
    vertex = "none"
    if sth != nothing
        sthJSON = JSON3.write(sth)
        sthDict = JSON3.read(sthJSON, Dict)
        point=sthDict["points"][1]
        x = VERTEX[point["x"]]
        y = point["y"]
        vertex = "$x$y"
    end
    
    boardinfo!(botProcess, button_id, color, vertex)
end

@async run_server(app, "0.0.0.0", debug=false)

function next_app()
    gtp_loop(botProcess)
end

next_app()
