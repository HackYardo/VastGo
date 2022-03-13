function magnet_stones()
    m[p[1],p[2]]=0
    i = 1
    moveVector = move 
    first = true
    while p[2] < boardSize[2]
        next = m[p[1],p[2]+i]
        if next == 0
            continue
        elseif next == -c
            if i == 1
                break
            elseif first == true
                moveVector = cat(moveVector,[p[1],p[2]+1,-c], dims=2)
                m[p[1],p[2]+i] = 0
                break
            else
                moveVector = cat(moveVector,[p[1],p[2]+i-1,c], dims=2)
                break
            end
        else # move_next == c
            if p[2]+i == boardSize[2]
                break
            elseif first == true 
                m[p[1],p[2]+i] = 0  
                first == false  
            else    
                moveVector = cat(moveVector,[p[1],p[2]+i-1,c], dims=2)
                break
            end
        end
        i = 1 + i
    end
    println(m)
    println(moveVector)
    println(first)
    println(i)
end

function main()
    boardSize=[19,19]
    position = rand([-1,0,1], (boardSize[1],boardSize[2]))
    println(position)
    point = [0,0]
    p[1] = rand(1:boardSize[1])
    p[2] = rand(1:boardSize[2])
    c = rand([-1,1], 1)
    move = cat(p,c, dims=1)
    println(move)
    magnet_stones(m,)
end

main()