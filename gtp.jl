#katagoCommand=`./katago gtp -config gtp_custom.cfg -model b6/model.txt.gz`
#engineProcess=open(katagoCommand,"r+")
#=
function query()
    sentence=""
    while true
        sentence=readline()
        if sentence=="" || "" in split(sentence," ")
            continue
        else
            println(engineProcess,sentence)
            break
        end
    end
    return sentence::String
end
=#
function reply()
    paragraph=""
    while true
        sentence=readline(engineProcess)
        if sentence==""
            break
        else 
            paragraph="$paragraph$sentence\n"
        end
    end
    println(paragraph)
    return paragraph::String
end

function color_stones(board)
    colorStones::Vector{String}=[]
    for vertex in board
        if vertex == 0
            colorStones=cat(colorStones,["rgba(0,0,0,0)"],dims=1)
        elseif vertex == -1
            colorStones=cat(colorStones,["rgba(0,0,0,1)"],dims=1)
        elseif vertex == 1
            colorStones=cat(colorStones,["rgba(255,255,255,1)"],dims=1)
        else
            continue
        end
    end
    return colorStones
end

function odd_key_even_value(dictString;c=": ")
    d=Dict{String,Any}()
    k=""
    j=1
    if dictString[1]=='='
        dictString=dictString[3:end]
        c=[' ',':']
    end
    if dictString[1]=='R'
        return Dict("Rules"=>odd_key_even_value(dictString[9:end-1];c=[':',',','"']))
    end
    for i in split(dictString,c;keepempty=false)
        if j==1
            k=i
            j=0
        else
            if i in ["false","true"]
                i=parse(Bool,i)
            elseif tryparse(Int8,i) != nothing
                i=tryparse(Int8,i)
            elseif tryparse(Float64,i) != nothing
                i=tryparse(Float64,i)
            else
            end
            d[k]=i
            j=1
        end
    end
    return d
end

function agent_showboard(paragraph)
    paragraphVector=split(paragraph,"\n",keepempty=false)
    boardInfo=Dict{String,Any}()
    n=0
    for c in paragraphVector[2]
        if c in 'A':'T'
            n=n+1
        end
    end
    m=3
    b=Vector{Int8}()
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
    boardInfo["BoardColor"]=colorStones
    boardInfo["BoardSize"]=[m-3,n]
    for line in cat([paragraphVector[1]],paragraphVector[m:end],dims=1)
        boardInfo=merge(boardInfo,odd_key_even_value(line))
    end
    println(boardInfo,"\n")
    return boardInfo
end

function play()
    while true
        sentence=query()
        paragraph=reply()
        if sentence=="quit"
            break
        elseif sentence=="showboard"
            boardInfo=agent_showboard(paragraph)
        else
            continue
        end
    end
end

#play()