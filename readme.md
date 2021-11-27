![easyUI](./easyUI.svg)

[myMarkdownCheatSheet](./Markdown.md)

> This is a repo about the game of [Go/WeiQi/Baduk](https://senseis.xmp.net/?Weiqi), [KataGo](https://katagotraining.org/), [GoTextProtocol(GTP)](http://www.lysator.liu.se/~gunnar/gtp/), [SmartGameFormat(.sgf)](https://www.red-bean.com/sgf/), [Common MarkDown](https://commonmark.org/), [Julia](https://julialang.org/) , [Plotly(JS)](https://plotly.com/julia/)/[Dash.jl](https://dash-julia.plotly.com/), [ScalableVectorGraphics](.svg)(https://en.wikipedia.org/wiki/Scalable_Vector_Graphics), [Regular Expression](https://ryanstutorials.net/linuxtutorial/grep.php), etc...

I created this repo because my hard disk was somewhat ***broken***.

## How to run "board.jl"?
1. install [julia](https://julialang.org/) 
2. run julia in your shell/cmd/terminal and you will enter julia-REPL mode
```shell
cmd> julia 
```  
3. enter julia-pkg mode
```julia
julia> ]
```
4. install [PlotlyJS.jl](https://github.com/JuliaPlots/PlotlyJS.jl)
```julia
(@v1.6) pkg> add PlotlyJS
```
5. download board.jl file
6. run board.jl
```julia
julia> include("path/to/file.jl") 
```

### Q&A
- Q: Why running board.jl takes so long? 
  - A: Julia needs a bit more time to first plot, use [sysimage](https://julialang.github.io/PackageCompiler.jl/dev/examples/plots.html#examples-plots) to accelerate.
