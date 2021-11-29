![easyUI](./easyUI.svg)

> A repo about the game of [Go/WeiQi/Baduk](https://senseis.xmp.net/?Weiqi), [KataGo](https://katagotraining.org/), [GoTextProtocol(GTP)](http://www.lysator.liu.se/~gunnar/gtp/), [SmartGameFormat(.sgf)](https://www.red-bean.com/sgf/), [Markdown](https://commonmark.org/), [Plotly(JS)](https://plotly.com/julia/)/[Dash.jl](https://dash-julia.plotly.com/), [ScalableVectorGraphics(.svg)](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics), [Regular Expression](https://ryanstutorials.net/linuxtutorial/grep.php), etc...

## Why create this?
Look at the table:
Go GUI | Language
--- | ---
[Sabaki](https://sabaki.yichuanshen.de/) | JavaScript
[q5Go](https://github.com/bernds/q5Go) | C++
[Lizzie](https://github.com/featurecat/lizzie) | Java
[KaTrain](https://github.com/sanderland/katrain) | Python
[Lizgoban](https://github.com/kaorahi/lizgoban) | JavaScript
[BadukAI](https://aki65.github.io/) | Python
[Ogatak](https://github.com/rooklift/ogatak) | JavaScript

🚀🚀🚀 ***Julia must have one too!*** 🚀🚀🚀

## What can the repo do today/tomorrow?
- [ ] basic game features
  - [x] static Go board 19x19
  - [ ] mouse-click event to play stones
  - [ ] dynamic Go board
  - [ ] GTP to call Go engines and manage games
  - [ ] judge game-end
  - [ ] completely play games
  - [ ] load/save sgf
  - [ ] time setting
  - [ ] handicap
- [ ] features from GTP
  - [ ] final_score
  - [ ] final_status_list  
- [ ] features from [GNUGo](https://www.gnu.org/software/gnugo/gnugo_19.html#SEC200)    
  - [ ] eval_eye
  - [ ] owl_attack, owl_defend
  - [ ] initial_influence
- [ ] features from modern Go-playing artificial intelligence engines
  - [ ] winrate
  - [ ] order, principal variation 
  - [ ] visits
- [ ] features from KataGo [1](https://github.com/lightvector/KataGo/tree/master/cpp/configs) [2](https://github.com/lightvector/KataGo/tree/master/docs)
  - [ ] ruleSet, komi (-150,150)
  - [ ] scoreLead, ownership, ownershipStdev
  - [ ] boardSize (2x2,19x19) 
  - [ ] boardSize (2x2,29x29)?
  - [ ] playoutDoublingAdvantage (-3,3), dynamic
  - [ ] wideRootNoise (0,1)
  - [ ] resignThreshold (-1,1), resignMinScoreDifference, resignConsecTurns
  - [ ] kata-raw-nn SYMMETRY (0,7)+("all")
  - [ ] opening books on 7x7 board
  - [ ] evalsgf, runownershiptests, analysis 
- [ ] features from KaTrain
  - [ ] weak bot 
- [ ] features from [yishn](https://github.com/yishn)
  - [ ] KataJigo 
- [ ] features from [waterfire](https://waterfire.us/joseki.htm)
  - [ ] Kogo's Joseki Dictionary
- [ ] advanced features 
  - [ ] navigate, move history
  - [ ] self-adaptive stoneSize(traceSize) when zoom in/out
  - [ ] square board response to windowSize
  - [ ] game tree
  - [ ] games container
  - [ ] multiple boards preview
  - [ ] load/save analyzed svg
  - [ ] svg2sgf, sgf2svg
  - [ ] Go games book, pdf
  - [ ] fuzzy stones placing
  - [ ] select data to analyze
  - [ ] rank, rating, ladder match 
  - [ ] opening book of modern Go community?
- [ ] expanded features
  - [ ] random opening
  - [ ] reuse captures by each other
  - [ ] [First Capture Go](https://senseis.xmp.net/?AtariGo)
  - [ ] [ChessWhiz](https://senseis.xmp.net/?ChessWhiz)
  - [ ] [One Color Go](https://senseis.xmp.net/?OneColourGo)
  - [ ] [Blind Go](https://senseis.xmp.net/?BlindGo)
  - [ ] [Fog Of War Go](https://senseis.xmp.net/?FogOfWar)
  - [ ] [Multi-color Go](https://senseis.xmp.net/?MultiColorGo)
  - [ ] [Pair Go](https://senseis.xmp.net/?PairGo)
  - [ ] [Double Go](https://senseis.xmp.net/?DoubleGo)
  - [ ] [Quantum Go](https://arxiv.org/abs/1603.04751)
  - [ ] [Topological Go](https://senseis.xmp.net/?TopologicalGo)?
  - [ ] [Toroidal Go](https://senseis.xmp.net/?ToroidalGo)
  - [ ] [1000-Volt-Go](https://senseis.xmp.net/?ElectricGo)
  - [ ] [Neurotic Go](https://senseis.xmp.net/?NeuroticGo)
- [ ] not merely Go
  - [ ] Five In A Row
  - [ ] Checkers
  - [ ] Reversi
- [ ] not merely Go board and stones
  - [ ] Chess with Stockfish 
**Be careful**: avoid repetition to existing site/software, i.e. [kahv](https://go.kahv.io/), and can be played/analyzed by corresponding bot/AI

## How to run "board.jl"?
1. download and install [julia](https://julialang.org/) 
2. run julia in your cmd/shell/terminal and you will enter julia-REPL mode
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
julia> include("path/to/fileName.jl") 
```

## Q&A 
- Why running board.jl takes so long? 
  - Julia needs more time to first plot.
  - You can use [sysimage](https://julialang.github.io/PackageCompiler.jl/dev/examples/plots.html#examples-plots) to accelerate.
- Why Julia?
  - [Evan Miller](https://www.evanmiller.org/why-im-betting-on-julia.html) 
- Why Plotly(JS) Dash?
  - More interactive features than the others. [Details](https://docs.juliaplots.org/latest/backends/)
## LICENSE
license=license_of([KataGo](https://github.com/lightvector/KataGo/blob/master/LICENSE)) ∪ license_of([Dash.jl](https://github.com/plotly/Dash.jl/blob/dev/LICENSE))
## Doc
- [my Markdown Cheat Sheet](./Markdown.md)
- my GTP Cheat Sheet
- static Go board state matrix
