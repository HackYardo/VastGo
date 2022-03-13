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
    if magnetStones[1,1] != 0
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

function magnet_turn(color,vertex,position)
    magnetLines = magnet_lines(vertex,position)
    magnetStones = magnet_stones(color,magnetLines)
    magnet_order(magnetStones)
end

function main()
    boardSize=[19,19]
    position = rand([-1,0,1], (boardSize[1],boardSize[2]))
    print_matrix(position)
    # positionReverseY = reverse(position', dims=2)'
    # print_matrix(positionReverseY)
    vertex = [rand(1:boardSize[1]),rand(1:boardSize[2])]
    color = rand([-1,1], 1)[1]
    move = cat(vertex,color, dims=1)
    println(move)
    magnet_turn(color,vertex,position)
end

main()