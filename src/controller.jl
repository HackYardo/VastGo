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

function info_final(proc::Base.Process)
    query(proc, "final_score")
    finalScore = reply(proc)
    query(proc, "final_status_list seki")
    finalSeki = reply(proc)
    query(proc, "final_status_list dead")
    finalDead = reply(proc)
    
    "Final Score $finalScore Seki: $finalSeki Pre-Captured: $finalDead"
end

function boardinfo(proc, button_id, m, n, color, x, y)
    botColor = color_turn(color)
    botVertex = "= none\n"
    if !(x in 1:n) || !(y in 1:m) 
        vertex = "none"
    else 
        xChar = VERTEX[x]
        vertex = "$xChar$y"
    end
    info = ""
    
    if button_id == "Color"
        query(proc, "genmove $botColor")
        botVertex = reply(proc)
    elseif button_id == "boardGraph"
        if x == 1 && y == 0
            query(proc, "play $color pass")
            reply(proc)
            query(proc, "genmove $botColor")
            botVertex = reply(proc)
        elseif x == 2.25 && y == 0
            info = info_final(proc)
        elseif vertex != "none"
            query(proc, "play $color $vertex")
            reply(proc)
            query(proc, "genmove $botColor")
            botVertex = reply(proc)
        else
        end
        
        if "resign" in split(botVertex)
            info = info_final(proc)
        end
    else
    end

    query(proc, "showboard")
    board = showboard_format(proc, ifprint=false)
    info = board.i * "Bot move $botVertex" * info
    
    return info, plot_board(board.m, board.n, trace_stone(board.x,board.y,board.c))
end
