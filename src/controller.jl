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

function boardinfo(proc, button_id, color, x, y)
    botColor = color_turn(color)
    botVertex = "= none\n"
    if !(x in 1:19) || !(y in 1:19) 
        vertex = "none"
    else 
        xChar = VERTEX[x]
        vertex = "$xChar$y"
    end
    finalScore = "= none\n"
    
    if button_id == "Color"
        query(proc, "genmove $botColor")
        botVertex = reply(proc)
    elseif button_id == "boardGraph"
        if vertex == "A0"
            query(proc, "play $color pass")
            reply(proc)
            query(proc, "genmove $botColor")
            botVertex = reply(proc)
        elseif x in 1:19 && y in 1:19
            query(proc, "play $color $vertex")
            reply(proc)
            query(proc, "genmove $botColor")
            botVertex = reply(proc)
        else
        end
    else
    end

    query(proc, "showboard")
    board = showboard_format(proc, ifprint=false)
    info = board.i * "Bot move $botVertex"
    
    if vertex == "C0"
        query(proc, "final_score")
        finalScore = reply(proc)
        info = info * "Final Score $finalScore"
    end
    
    return info, plot_board(trace_stone(board.x,board.y,board.c))
end
