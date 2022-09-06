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
include("src/magnet.jl")
include("src/visibility.jl")

bot = bot_get()
botProcess = bot_run(dir=bot.dir, cmd=bot.cmd)
gtp_ready(botProcess)

app = dash()
app.title = "VastGo"
app.layout = html_div() do
    dcc_tabs([
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
            children=[#=reviewGame=#]
            )
        ])
end
#=
callback!(app,
    Output("RuleCurrent", "value"),
    Input("RuleOK", "n_clicks"),
    State("Rule", "value"),
    State("KM", "value"),
    ) do n, v, k
    
end=#

# the main callback, used to refresh board
callback!(app,
    Output("infoTextarea", "value"),
    Output("boardGraph", "figure"),
    Input("boardGraph", "clickData"),
    Input("RuleOK", "n_clicks"),
    State("Color", "value"),
    State("BoardSizeM", "value"),
    State("BoardSizeN", "value"),
    State("ModeVisual", "value"),
    State("ModeMove", "value"),
    ) do sth, n_c, color, m, n, modeV, modeM

    ctx = callback_context()
    if length(ctx.triggered) == 0
        button_id = "none"
    else
        button_id = split(ctx.triggered[1].prop_id, ".")[1]
    end
    
    x = 0
    y = 0
    if sth != nothing
        point = JSON3.read(JSON3.write(sth), Dict)["points"][1]
        x = point["x"]
        y = point["y"]
    end
    
    boardinfo(botProcess, button_id, m, n, color, x, y)
end

@async run_server(app, "0.0.0.0", debug = false)

function next_app()
    gtp_loop(botProcess)
end

next_app()
