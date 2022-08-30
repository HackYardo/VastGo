using Dash
using PlotlyBase  # Layout(), scatter(), Plot()
import JSON3  # JSON3.read(), JSON3.write(), JSON3.pretty()
include("src/board.jl")  
    # VERTEX
    # trace_stone(), plot_board(), plot_board!()
include("src/gotextprotocol.jl")  
    # bot_get(), bot_run(), query(), reply()
    # gtp_ready(), gtp_loop(), showboard_get(), showboard_format()


topText="""
### Hello, welcome to VastGo!

`Have a nice day!`"""

bottomText="""
***based on [Plotly Dash](https://dash-julia.plotly.com/), 
written in [Julia](https://julialang.org/)***"""

bottomDiv=dcc_markdown(bottomText)


function color_turn(playerNumber=2,boardSize=19*19,
    chooseColor=["rgb(255,255,255)","rgb(0,0,0)"])

end

function gtp_turn(proc::Base.Process, x, y)
    query(proc, "play B $x$y")
    reply(proc)
    query(proc, "genmove W")
    reply(proc)
    query(proc, "showboard")
    board = showboard_format(proc)
    return board
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
    dcc_graph(id="board2", figure=board),
    dcc_textarea(id = "info", 
        style = Dict("height" => 256, "width" => 800)
        ),
    html_div(id="seeDebugData"),
    dcc_graph(figure = Plot(longVector)),
    html_div(
        bottomDiv, 
        style=(width="49%",display="inline-block",float="right")
        )
end

callback!(app,
    Output("info", "value"),
    Output("board2","figure"),
    Input("board2","clickData"),
    ) do sth
    io = IOBuffer()
    if sth != nothing
        sthJSON = JSON3.write(sth)
        sthParse = JSON3.read(sthJSON, Dict)
        vector=sthParse["points"][1]
        
        #xPlayerIndex = parse(Int, vector["x"])
        xPlayer = VERTEX[vector["x"]]
        yPlayer = vector["y"]
    else
        xPlayer = ""
        yPlayer = ""
    end
    
    board = gtp_turn(botProcess, xPlayer, yPlayer)
    
    return board.i, plot_board!(trace_stones(board.x, board.y, board.c))
end

@async run_server(app, "0.0.0.0", debug=false)

function next_app()
    gtp_loop(botProcess)
end

next_app()
