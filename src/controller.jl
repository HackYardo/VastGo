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

function boardinfo(proc, button_id, color, vertex)
    botColor = color_turn(color)
    botVertex = "none"
    
    if button_id == "colorRadioitems"
        query(proc, "genmove $botColor")
        botVertex = reply(proc)[3:end-1]
    elseif button_id == "boardGraph"
        query(proc, "play $color $vertex")
        reply(proc)
        query(proc, "genmove $botColor")
        botVertex = reply(proc)[3:end-1]
    else
    end
    
    query(proc, "showboard")
    board = showboard_format(proc, ifprint=false)
    info = board.i * "Bot moves at: $botVertex\n"
    
    return info, plot_board(trace_stones(board.x,board.y,board.c))
end
