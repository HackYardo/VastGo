function create()
	mkpath("VastGo/navigator.nvg")
	close(open("VastGo/navigator.nvg","w"))
end

function save(position)
	navigator = open("VastGo/navigator.nvg","a")
	println(navigator,position)
	close(navigator)
end

function load()
	navigator = open("VastGo/navigator.nvg","r")
	positions = readlines(navigator)
		
