function abc_num(color,vertex,boardSizeY) # move_syntax_converter: gtp & num
    if color in [-1,1]
        if color == -1
            color = 'B'
        else
            color = 'W'
        end
        vertex = string(GTP_X[vertex[2]+1],boardSizeY+1-vertex[1])
    else
        if color in ['B','b',"B","b"]
            color = -1
        else
            color = 1
        end
        i = 2
        while true
            if GTP_X[i] == vertex[1] || uppercase(GTP_X[i]) == vertex[1]
                break
            end
            # println(GTP_X[i],' ',UI_X[i],' ',vertex[1])
            i = i+1
        end
        i = i-1
        vertex = [boardSizeY+1-parse(Int,vertex[2:end]),i]
    end
    return color,vertex
end

function console_game(xyPlayer,colorPlayer)
    #gameInfoAll=showboard_magnet()
    gameState=""
    engineMove=""
    nextColor=turns_taking(colorPlayer)

    if xyPlayer=="d0"
        gameState="over"
    else
        if xyPlayer in ["a0","b0"]
            query("play $colorPlayer pass")
            reply()
            #println("before pass")
        else
            query("play $colorPlayer $xyPlayer")
            paragraph=reply()
            if paragraph[1]=='?' gameState="over" end
        end
        query("genmove $nextColor")
        #println("after pass")
        engineMove=reply()[3:end-1]
        if engineMove=="resign" gameState="over" end
    end
    return gameState,engineMove
end

function showboard_magnet()
    query("showboard")
    paragraph=reply()
    paragraphVector=split(paragraph,"\n",keepempty=false)
    boardInfo=Dict{String,Any}()
    n=0
    for c in paragraphVector[2]
        if c in 'A':'T'
            n=n+1
        end
    end
    m=3
    b=[]
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
    # println(b)
    boardInfo["BoardColor"]=colorStones
    boardInfo["BoardSize"]=[n,m-3]
    for line in cat([paragraphVector[1]],paragraphVector[m:end],dims=1)
        boardInfo=merge(boardInfo,odd_key_even_value(line))
    end
    boardInfo["checkBoard"]=cat(paragraphVector[2:m-1],[JSON3.write(boardInfo["Rules"])],dims=1)
    query("printsgf")
    sgfInfo=reply()[3:end]
    boardInfo["sgf"]=sgfInfo
    return boardInfo
end

function print_matrix(matrix)
    println(size(matrix),' ',typeof(matrix))
    for i in 1:size(matrix)[1]
        for j in matrix[i,:]
            print(j,'\t')
        end
        println()
    end
end

function print_dict(dictionary)
    println(typeof(dictionary))
    for (key,value) in pairs(dictionary) # or: for entry in dictionary
        println(typeof(key),':',typeof(value)," | ",key," => ",value)
    end
end

function magnet_lines(vertex,position)
    magnetLines = Dict() 
    # key,value: direction,line
    # direction: see magnet_stones()
    if vertex[1]+1 <= size(position)[1]
        magnetLines[1] = position[vertex[1]+1:end,vertex[2]]
    end
    if vertex[1]-1 >= 1
        magnetLines[3] = reverse(position[1:vertex[1]-1,vertex[2]])
    end
    if vertex[2]-1 >= 1
        magnetLines[4] = reverse(position[vertex[1],1:vertex[2]-1])
    end
    if vertex[2]+1 <= size(position)[2]
        magnetLines[2] = position[vertex[1],vertex[2]+1:end]
    end
     print_dict(magnetLines)
    return magnetLines
end

function magnet_stones(color,magnetLines)
    magnetStones = [1,0,0,color] 
    # 1st: 0 => "to remove", 1 => "to play"
    # 2nd: direcion, 0 => "no direction", 1-4 => "down,right,up,left" 
    # 3rd: distance  
    for (direct,line) in pairs(magnetLines)
        i = 1
        first = true
        for point in line
            if point == 0
                i = i+1
                if i > length(line) && !first
                    magnetStones = cat(magnetStones,[1,direct,i-1,color], dims=2)
                    break
                end
            elseif point == -color
                if i == 1
                    break
                elseif first 
                    magnetStones = cat([0,direct,i,-color],magnetStones, dims=2)
                    magnetStones = cat(magnetStones,[1,direct,1,-color], dims=2)
                    break
                else
                    magnetStones = cat(magnetStones,[1,direct,i-1,color], dims=2)
                    break
                end
            else
                if first
                    if i == length(line) 
                        break
                    elseif line[i+1] !=0
                        break
                    else
                        magnetStones = cat([0,direct,i,color],magnetStones, dims=2)
                        first = false  
                        i = i+1
                    end
                else    
                    magnetStones = cat(magnetStones,[1,direct,i-1,color], dims=2)
                    break
                end
            end
        end
        println(direct,' ',first,' ',i)
    end
    print_matrix(magnetStones)
    return magnetStones
end

function magnet_order(magnetStones)
    if string(typeof(magnetStones)) == "Vector{Int64}"
        newMagnetStones = magnetStones
    else    
        i = 1
        while magnetStones[1,i] == 0
            i = i+1
        end
        color = magnetStones[end,i]
        foreMagnetStones = magnetStones[:,1:i-1]
        backMagnetStones = magnetStones[:,i]
        i = i+1
        for c in magnetStones[end,i:end]
            if c == color
                foreMagnetStones = cat(foreMagnetStones,magnetStones[:,i], dims=2)
            else
                backMagnetStones = cat(backMagnetStones,magnetStones[:,i], dims=2)
            end
            i = i+1
        end
        newMagnetStones = cat(foreMagnetStones,backMagnetStones, dims=2)
    end
    print_matrix(newMagnetStones)
    return newMagnetStones
end

function magnet_act(position,vertex,magnetStones)
    j = 1
    while magnetStones[1,j] == 0
        if magnetStones[2,j] == 1
            position[vertex[1]+magnetStones[3,j],vertex[2]] = 0
        elseif magnetStones[2,j] == 2
            position[vertex[1],vertex[2]+magnetStones[3,j]] = 0
        elseif magnetStones[2,j] == 3
            position[vertex[1]-magnetStones[3,j],vertex[2]] = 0
        else
            position[vertex[1],vertex[2]-magnetStones[3,j]] = 0
        end
        j = j+1
    end
    m = 1
    n = 1
    positionString = ""
    for m in 1:size(position)[1]
        for n in 1:size(position)[2]
            if position[m,n] == 0
                continue
            else
                if position[m,n] == 1
                    colorPlayer,xyPlayer = abc_num(1,[m,n],size(position)[2])
                else
                    colorPlayer,xyPlayer = abc_num(-1,[m,n],size(position)[2])
                end
                positionString = string(positionString,' ',colorPlayer,' ',xyPlayer)
            end
        end
    end
    positionString = positionString[2:end]
    #println(positionString)
    if j != 1
        query("set_position $positionString") # auto clear_board before set_position
        reply()
    end
    if string(typeof(magnetStones)) == "Vector{Int64}"
        color = magnetStones[4,j]
        xy = vertex
        colorPlayer,xyPlayer = abc_num(color,xy,size(position)[2])
        query("play $colorPlayer $xyPlayer")
        reply()        
    else
        while j <= size(magnetStones)[2]
            color = magnetStones[4,j]
            xy = ""
            if magnetStones[2,j] == 1
                xy = [vertex[1]+magnetStones[3,j],vertex[2]]
            elseif magnetStones[2,j] == 2
                xy = [vertex[1],vertex[2]+magnetStones[3,j]]
            elseif magnetStones[2,j] == 3
                xy = [vertex[1]-magnetStones[3,j],vertex[2]]
            else
                xy = [vertex[1],vertex[2]-magnetStones[3,j]]
            end
            colorPlayer,xyPlayer = abc_num(color,xy,size(position)[2])
            query("play $colorPlayer $xyPlayer")
            reply()
            j = j+1
        end
    end
    #println("magnet_act done")
end

function magnet_turn(color::Int64,vertex,position)
    magnetLines = magnet_lines(vertex,position)
    magnetStones = magnet_stones(color,magnetLines)
    newMagnetStones = magnet_order(magnetStones)
    magnet_act(position,vertex,newMagnetStones)
    #print_matrix(newMagnetStones)
    return newMagnetStones
end

function magnet_turn(color::String,vertex,position)
    color,vertex = abc_num(color,vertex,size(position)[2])
    magnet_turn(color,vertex,position)
end

function magnetgo()
    while true
        gameInfoAll = showboard_magnet()
        boardSize = gameInfoAll["BoardSize"]
        position = reshape(gameInfoAll["Board"],boardSize[1],:)'
        # position = rand([-1,0,1], (boardSize[1],boardSize[2]))
        # print_matrix(position)
        # positionReverseY = reverse(position', dims=2)'
        # print_matrix(positionReverseY)
        # vertex = [rand(1:boardSize[1]),rand(1:boardSize[2])]
        # color = rand([-1,1], 1)[1]
    # while true
        colorPlayer = readline()[1] 
        # [1]: typeof(readline()) == String, != Char
        if colorPlayer == 'q'
            query("quit")
            reply()
            break
        end
        xyPlayer = readline() 
        color,vertex = abc_num(colorPlayer,xyPlayer,boardSize[2])
        move = cat(color,vertex, dims=1)
        # println(move)
        magnet_turn(color,vertex,position)
    end
end
