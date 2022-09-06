function mode_visual(colorVector,colorPlayer,modeColor)
    if modeColor=="blind"
        colorVector=["rgba(0,0,0,0)" for v in 1:length(colorVector)]
    elseif modeColor=="phantom"
        if colorPlayer=="B"
            for i in 1:length(colorVector)
                if colorVector[i] == "rgba(255,255,255,1)"
                    colorVector[i]="rgba(255,255,255,0)"
                end
            end
        else
            for j in 1:length(colorVector)
                if colorVector[j] == "rgba(0,0,0,1)"
                    colorVector[j]="rgba(0,0,0,0)"
                end
            end
        end
    elseif modeColor=="ghost"
        if colorPlayer=="W"
            for i in 1:length(colorVector)
                if colorVector[i] == "rgba(255,255,255,1)"
                    colorVector[i]="rgba(255,255,255,0)"
                end
            end
        else
            for j in 1:length(colorVector)
                if colorVector[j] == "rgba(0,0,0,1)"
                    colorVector[j]="rgba(0,0,0,0)"
                end
            end
        end
    elseif modeColor=="oneColour"
        for k in 1:length(colorVector)
            if colorVector[k] =="rgba(255,255,255,1)"
                colorVector[k]="rgba(0,0,0,1)"
            end
        end
    else
    end
    return colorVector
end
