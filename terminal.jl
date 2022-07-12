#botCommand=`./katago gtp -model b6/model.txt.gz`
botCommand = `gnugo --mode gtp`
#botCommand = `leelaz --cpu-only -g -v 8 -w ../lzweights/weight.gz`

botProcess = open(botCommand, "r+")

function endbot()
    query("quit")
    reply()
    close(botProcess)
end

function query(sentence::String)
    println(botProcess,sentence)
end

function reply()
    paragraph=""
    while true
        sentence=readline(botProcess)
        if sentence==""
            break
        else 
            paragraph="$paragraph$sentence\n"
        end
    end
    println(paragraph)
    return paragraph::String
end

function play()
    if !occursin("katago","$botCommand")
        println("GTP ready")
    end
    while true
        sentence = readline()
        query(sentence)
        reply()
        if occursin("quit",sentence)
            endbot()
            break
        else
            continue
        end
    end
end

play()
