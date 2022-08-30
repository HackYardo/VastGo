using Dash
using PlotlyBase
import JSON3  # JSON3.read(), JSON3.write(), JSON3.pretty()
include("src/utility.jl")  # match_diy(), split_undo()

const VERTEX = cat([c for c in 'A':'H'], [c for c in 'J':'T'], dims=1)

function bot_get()
    GNUGO = (dir="", cmd="gnugo --mode gtp --boardsize 3")
    LEELAZ = (dir="../lzweights/", cmd="leelaz --cpu-only -g -v 8 -w w6.gz")
    KATAGO = (dir="../katago1.11avx2/", cmd="./katago gtp -config \
        custom_gtp.cfg -model models/m6.txt.gz")
    botDict = Dict("g"=>GNUGO, "l"=>LEELAZ, "k"=>KATAGO)
    
    botDict[ARGS[1]]
end 

function bot_ready(proc::Base.Process)
    query(proc, "!")
    outInfo = reply(proc)
    
    if outInfo[1] != '?'
        errInfo = reply(proc.err)
        @info "stdout:\n$outInfo"
        @info "stderr:\n$errInfo"
        @error "Please look at the above ↑↑↑"
        exit()
    end

    #println("$proc")
end

#=
Why Base.PipeEndpoint() && run() or why not open()?
Because stderr is hard to talk with, source:
https://discourse.julialang.org/t/avoiding-readavailable-when-communicating-
with-long-lived-external-program/61611/25
=#
function bot_run(; dir="", cmd="")::Base.Process
    inp = Base.PipeEndpoint()
    out = Base.PipeEndpoint()
    err = Base.PipeEndpoint()
    
    cmdVector = split(cmd) # otherwise there will be ' in command
    command = Cmd(`$cmdVector`, dir=dir)
    println("VastGo will run the command: $cmd\nin the directory: $dir")
    #println(command)

    process = run(command,inp,out,err;wait=false)
    bot_ready(process)
    
    return process
end

function bot_end(proc::Base.Process)
    println(reply(proc))
    close(proc)
end

function gtp_valid(sentence::String)::Bool
    if "" in split(sentence, keepempty=true)
        return false
    else 
        return true
    end 
end 

function query(proc::Base.Process, sentence::String)
    println(proc, sentence)
end

function reply(proc::Union{Base.Process, Base.PipeEndpoint})
    paragraph = readuntil(proc, "\n\n")
    return "$paragraph\n"
end

function name_get(proc::Base.Process)
    query(proc, "name")
    reply(proc)[3:end-1]
end

function version_get(proc::Base.Process)
    query(proc, "version")
    reply(proc)[3:end-1]
end 

function gtp_startup_info(proc::Base.Process)
    name = name_get(proc)
    if name == "Leela Zero"
        info = readuntil(proc.err, "MiB.", keep=true)
    elseif name == "KataGo"
        info = readuntil(proc.err, "loop", keep=true)
    else
        info = name
    end
    println(info)
end 

function gtp_ready(proc::Base.Process)
    gtp_startup_info(proc)
    @info "GTP ready"
end 

function leelaz_showboard(proc::Base.Process)
    readuntil(proc.err, "Passes:")
    paragraphErr = "Passes:" * readuntil(proc.err, "\n") * "\n"
    while true
        line = readline(proc.err)
        if line == ""
            continue
        end
        paragraphErr = paragraphErr * line * "\n"
        if occursin("White time:", line)
            break
        end
    end
    paragraphErr
end

function leelaz_showboardf(paragraph)  # f: _format
    lines = split(paragraph, "\n")
    
    infoUp = lines[2:3]
    infoDown = lines[25:27]
    infoAll = cat(infoUp, infoDown, dims=1)
    info = split_undo(infoAll)

    m = n = 19
    linesPosition = lines[5:23]
    c = Vector{String}()
    for line in linesPosition
        line = split(line, [' ', ')', '('])
        for char in line
            if char == "O"
                push!(c, "rgba(255,255,255,1)")
            elseif char == "X"
                push!(c, "rgba(0,0,0,1)")
            elseif char in [".", "+"]
                push!(c, "rgba(0,0,0,0)")
            else 
                continue
            end
        end
    end
    x = repeat([p for p in 1:n], m)
    y = [p for p in m:-1:1 for q in 1:n]

    (x = x, y = y, c = c, i = info)
end

function gnugo_showboardf(paragraph)  # f: _format
    r = r"captured \d{1,}"
    lines = split(paragraph, '\n')
    
    l = length(lines[2]) + 2
    captured = Vector{String}()

    m = length(lines) - 4
    n = length(split(lines[2]))
    #position = zeros(Int64, m, n)
    i = m
    j = 1
    linesPosition = lines[3:2+m]

    c = Vector{String}()

    for line in linesPosition
        if length(line) > l + 20
            captured = cat(captured, match_diy([r, r"\d{1,}"], [line]), dims=1)
        end
        line = split(line)[2:n+1]
        for char in line
            if char == "O"
                #position[i,j] = 1
                push!(c, "rgba(255,255,255,1)")
                j = j + 1
            elseif char == "X"
                #position[i,j] = -1
                push!(c, "rgba(0,0,0,1)")
                j = j + 1
            elseif char in [".", "+"]
                push!(c, "rgba(0,0,0,0)")
                j = j + 1
            elseif j == n
                break
            else 
                continue
            end
        end
        j = 1
        i = i - 1
    end 
    #println(position)

    x = repeat([p for p in 1:n], m)
    y = [p for p in m:-1:1 for q in 1:n]
    
    blackCaptured = captured[1]
    whiteCaptured = captured[2]

    info = """
    B stones captured: $blackCaptured
    W stones captured: $whiteCaptured
    """

    (x = x, y = y, c = c, i = info)
end

function katago_showboardf(paragraph)
    lines = split(paragraph, "\n")

    infoUp = lines[1][3:end]

    n = length(split(lines[2]))
    m = 3
    c = Vector{String}()
    while lines[m][1] in "1 "
        for char in split(lines[m][4:end], [' ', '1', '2', '3'])
            if char == "O"
                push!(c, "rgba(255,255,255,1)")
            elseif char == "X"
                push!(c, "rgba(0,0,0,1)")
            elseif char == "."
                push!(c, "rgba(0,0,0,0)")
            else 
                continue
            end
        end
        m=m+1
    end
    m = m - 3
    x = repeat([p for p in 1:n], m)
    y = [p for p in m:-1:1 for q in 1:n]

    infoDown = lines[m+3:m+6]
    infoAll = cat(infoUp, infoDown, dims=1)
    info = split_undo(infoAll)

    (x = x, y = y, c = c, i = info)
end

function showboard_get(proc::Base.Process)
    paragraph = reply(proc)
    name = name_get(proc)
    if name == "Leela Zero"
        paragraph = paragraph * leelaz_showboard(proc)
    end
    println(paragraph)
    paragraph, name
end 

function showboard_format((paragraph, name))
    board = NamedTuple()
    if name == "GNU Go"
        board = gnugo_showboardf(paragraph)
    elseif name == "Leela Zero"
        board = leelaz_showboardf(paragraph)
    elseif name == "KataGo"
        board = katago_showboardf(paragraph)
    else
    end
    println(dump(board))
    println()
    board 
end

function gtp_loop(proc::Base.Process)
    while true
        sentence = readline()
        if gtp_valid(sentence)
            query(proc, sentence)
        else 
            println("? invalid command\n")
            continue
        end 
        
        if "quit" in split(sentence)
            bot_end(proc)
            break
        elseif "showboard" in split(sentence)
            proc |> showboard_get |> showboard_format
        else
            println(reply(proc))
        end
    end
end



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
		),
	yaxis_showgrid=false,
	yaxis=attr(
		# showline=true, mirror=true,linewidth=1,linecolor="black",
		zeroline=false,
		ticktext=["$i" for i in 0:20],
		tickvals = [i for i in 0:20]
		)
	)
rowLine=scatter(
	x = repeat([1, 19, nothing], 19),
	y = [i for i in 1:19 for j in 1:3],
	mode="lines",
	line_width=1,
	line_color="rgb(0,0,0)",
	hoverinfo="skip",
	name="row lines"
	)
colLine=scatter(
	x = [c for c in 1:19 for j in 1:3],
	y = repeat([1, 19, nothing], 19),
	mode="lines",
	line_width=1,
	line_color="rgb(0,0,0)",
	hoverinfo="skip",
	name="col lines"
	)
anchorPoint = scatter(
	# use (z,1) and (u,19) to widen col margin
	x = [0, 20],
	y = [0, 20],
	mode = "markers",
	marker_color = "rgba(0,0,0,0)",
	name = "anchors"
	)
starPoint=scatter(
	x = repeat([4, 10, 16], 3),
	y = [i for i in [4, 10, 16] for j in 1:3],
	mode="markers",
	marker_color="rgb(0,0,0)",
	name="star points"
	)
vertex=scatter(
	x = repeat([i for i in 1:19], 19),
	y = [i for i in 19:-1:1 for j in 1:19],
	mode="markers",
	marker_size = 36,
	marker_color="rgba(0,0,0,0)",
	name="vertex"
	)
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
longVector = scatter(
	x = [1, 2, 3, 1, 2, 3, 1, 2, 3],
	y = [3, 3, 3, 2, 2, 2, 1, 1, 1],
	mode = "markers",
	marker = attr(
		symbol = "circle",
		color = [
		"rgba(24,64,125,1)", "rgba(0,0,0,0)", "rgba(0,0,0,0)", 
		"rgba(0,0,0,0)", "rgba(0,0,0,1)", "rgba(0,0,0,0)", 
		"rgba(0,0,0,0)", "rgba(255,255,255,1)", "rgba(0,0,0,0)"
		],
		size = 50
	),
	name = "longVector"
)

topText="""
### Hello, welcome to VastGo!

> Have a nice day!
"""

bottomText="
*based on [Plotly Dash](https://dash-julia.plotly.com/), \
written in [Julia](https://julialang.org/)*
"

bottomDiv=dcc_markdown(bottomText)

function plot_board()
	Plot(
		[anchorPoint,
		colLine,
		rowLine,
		starPoint,
		vertex
		],
		boardLayout
		)
end
board = plot_board()
function plot_board!(vertex)
	Plot(
		[anchorPoint,
		colLine,
		rowLine,
		starPoint,
		vertex],
		boardLayout
		)
end
function color_turn(playerNumber=2,boardSize=19*19,
	chooseColor=["rgb(255,255,255)","rgb(0,0,0)"])

end
function trace_stones(vx=[],vy=[],vc=[])
	scatter(
		x=vx,
		y=vy,
		mode="markers",
		marker_color= vc,
		marker_size=25,
		name="stones"
		)
end

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
	dcc_textarea(id = "info"),
	html_div(id="seeDebugData"),
	dcc_graph(figure = Plot(longVector)),
	html_div(
		bottomDiv, 
		style=(width="49%",display="inline-block",float="right")
		)
end

callback!(
	app,
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
	query(botProcess, "play B $xPlayer$yPlayer")
	reply(botProcess)
	query(botProcess, "genmove W")
	reply(botProcess)
    query(botProcess, "showboard")
	paragraph, name = showboard_get(botProcess)
	board = showboard_format((paragraph, name))
	
	return plot_board!(
		trace_stones(board.x, board.y, board.c)
		)
end

@async run_server(app, "0.0.0.0", debug=false)

function next_app()
    gtp_loop(botProcess)
end

next_app()
