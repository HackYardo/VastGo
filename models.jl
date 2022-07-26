file = ARGS[1]

function get_trace(file::String)
    lines = readlines(file)
    linesMatch = match.(r"^k.{2,}\d{3,}\.\d",lines)
    linesWithoutNothing = []
    for line in linesMatch
        if isnothing(line)
            continue
        else
            lineSplit = split(line.match)
            name = match(r"b.{3,5}\d",lineSplit[1]).match
            dataRows = match(r"d.{2,}",lineSplit[1]).match[2:end]
            #line = (lineSplit[1],lineSplit[5])
            line = (name,dataRows,lineSplit[end])
            linesWithoutNothing = cat(linesWithoutNothing,line,dims=1)
        end
    end
    println(length(linesWithoutNothing))
    println(linesWithoutNothing[end-2:end])
end

get_trace(file)
    