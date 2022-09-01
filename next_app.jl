using Dash
using PlotlyBase  # Layout(), scatter(), Plot()
import JSON3  # JSON3.read(), JSON3.write(), JSON3.pretty()
include("src/board.jl")  
    # VERTEX
    # trace_stone(), plot_board()
    # boardGraph, infoTextarea
include("src/gotextprotocol.jl")  
    # include("utility.jl") 
        # findindex()
    # bot_get(), bot_run(), query(), reply()
    # gtp_ready(), gtp_loop(), showboard_get(), showboard_format()
include("src/menu.jl")  
    # topText, bottomText
    # colorRadioitems
include("src/controller.jl")
    # boardinfo()

bot = bot_get()
botProcess = bot_run(dir=bot.dir, cmd=bot.cmd)
gtp_ready(botProcess)

app = dash()
app.title = "VastGo"
app.layout = html_div() do
    topDiv,
    colorRadioitems,
    boardGraph,
    infoTextarea,
    bottomDiv
end

callback!(app,
    Output("infoTextarea", "value"),
    Output("boardGraph", "figure"),
    Input("boardGraph", "clickData"),
    Input("colorRadioitems", "value"),
    ) do sth, color

    ctx = callback_context()
    if length(ctx.triggered) == 0
        button_id = "none"
    else
        button_id = split(ctx.triggered[1].prop_id, ".")[1]
    end
    
    if sth != nothing
        sthJSON = JSON3.write(sth)
        sthDict = JSON3.read(sthJSON, Dict)
        point=sthDict["points"][1]
        x = VERTEX[point["x"]]
        y = point["y"]
    end
    
    boardinfo(botProcess, button_id, color, x, y)
end

@async run_server(app, "0.0.0.0", debug=false)

function next_app()
    gtp_loop(botProcess)
end

next_app()
