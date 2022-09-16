function int_rgb(intCollect, m, n)
    rgbCollect = Matrix{String}("rgba(0,0,0.0)", m, n)
    for el in intCollect
        if el == -1
            push!(rgbCollect, "rgba(0,0,0,1)")
        elseif el == 1 
            push!(rgbCollect, "rgba(255,255,255,1)")
        else 
        end
    end
    return rgbCollect
end

function preset(value, m, n)
    position = Matrix{Int}(0, m, n)
    if value == "random"
        position = rand([0,-1,1], (m,n))
    elseif value == "dots"
        position = dotsPosition[1:m, 1:n]
    else
    end
    
    return int_rgb(position, m, n)
end 
