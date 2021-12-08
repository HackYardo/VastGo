katagoCommand=`katago.exe gtp -config gtp_custom.cfg -model b6\\model.txt.gz`
katagoProcess=open(katagoCommand,"r+")

const SGF_X=['a','b','c','d','e','f','g','h','i','j','k','m','n','o','p','q','r','s','t']
const SGF_Y=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]
const SGF_XY=[(i,j) for i in SGF_X for j in SGF_Y]

function query()
    sentence=""
    while true
        sentence=readline()
        if sentence=="" || "" in split(sentence," ")
            continue
        else
            println(katagoProcess,sentence)
            break
        end
    end
    return sentence::String
end
function reply()
    paragraph=""
    while true
        sentence=readline(katagoProcess)
        if sentence==""
            break
        else 
            paragraph="$paragraph$sentence\n"
        end
    end
    println(paragraph)
    return paragraph::String
end
function board_state(paragraph::String)
    #vertex=Matrix{Char}(undef,19,19)
    vertexCol=split(paragraph,"\n")[3:21]
    xVector::Vector{Char}=[]
    yVector::Vector{Int8}=[]
    colorVector::Vector{String}=[]
    for i in range(1,length=length(vertexCol))
        j=1
        for c in vertexCol[i][4:2:40]
            if c in "XO"
                xVector=cat(xVector,[SGF_X[j]],dims=1)
                yVector=cat(yVector,[20-i],dims=1)
                if c=='X'
                    colorVector=cat(colorVector,["rgb(255,255,255)"],dims=1)
                else
                    colorVector=cat(colorVector,["rgb(0,0,0)"],dims=1)
                end
            end
            j=j+1
        end
    end
    #println(vertex,"\n")
    #println("$xVector\n$yVector\n$colorVector\n")
    return xVector,yVector,colorVector
end
function play()
    while true
        sentence=query()
        paragraph=reply()
        if sentence=="quit"
            break
        elseif sentence=="showboard"
            xVector,yVector,colorVector=board_state(paragraph)
        else
            continue
        end
    end
end
function main()
    play()
end

main()
