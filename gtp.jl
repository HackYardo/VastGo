katagoCommand=`katago.exe gtp -config gtp_custom.cfg -model b6\\model.txt.gz`
katagoProcess=open(katagoCommand,"r+")

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
			paragraph="$paragraph\n$sentence"
		end
	end
	return paragraph::String
end
function play()
	while true
		sentence=query()
		if sentence=="quit"
			break
		else
			paragraph=reply()
			println(paragraph)
		end
	end
end
function main()
	play()
end

main()