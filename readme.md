![static](./board.svg)
A static Go board ❄️
![dynamic](./dynamic.gif)
A dynamic Go board 🍃

> The repo is about the game of [Go/Baduk/Weiqi](https://senseis.xmp.net/?Weiqi), [KataGo](https://katagotraining.org/), [GoTextProtocol(GTP)](http://www.lysator.liu.se/~gunnar/gtp/), [SmartGameFormat(.sgf)](https://www.red-bean.com/sgf/), [Markdown](https://commonmark.org/), [Julia](https://julialang.org/),[Plotly(JS)](https://plotly.com/julia/)/[Dash.jl](https://dash-julia.plotly.com/), [ScalableVectorGraphics(.svg)](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics), [Regular Expression](https://ryanstutorials.net/linuxtutorial/grep.php), etc.

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

## What's new here?
The [nonstandard Go](#nonstandard-go) and their free mixing.

## What can the repo do today/tomorrow?
### Standard Go
- [ ] basic game features
  - [x] static Go board 19x19
  - [x] mouse-click event to play stones
  - [x] dynamic Go board
  - [ ] GTP to call Go engines and manage games
  - [ ] final_score *(exercise evaluating the ends)*
  - [ ] final_status_list *(exercise evaluating groups of stones)* 
  - [ ] judge game-end, if `RU[]` in sgf is not empty
  - [ ] completely play games
  - [ ] load/save sgf
  - [ ] time setting
  - [ ] handicap
- [ ] features from [GNUGo](https://www.gnu.org/software/gnugo/gnugo_19.html#SEC200)    
  - [ ] eval_eye
  - [ ] owl_attack, owl_defend
  - [ ] initial_influence
- [ ] features from modern Go-playing artificial intelligence engines
  - [ ] winrate
  - [ ] order, principal variation 
  - [ ] visits
- [ ] features from KataGo [1](https://github.com/lightvector/KataGo/tree/master/cpp/configs) [2](https://github.com/lightvector/KataGo/tree/master/docs)
  - [x] ruleSet, komi (-150,150)
  - [ ] scoreLead, ownership, ownershipStdev *(exercise evaluating positions)*
  - [x] boardSize (2x2,19x19) 
  - [ ] boardSize (2x2,29x29)?
  - [ ] playoutDoublingAdvantage (-3,3), dynamic
  - [ ] wideRootNoise (0,1)
  - [ ] resignThreshold (-1,1), resignMinScoreDifference, resignConsecTurns
  - [ ] kata-raw-nn SYMMETRY (0,7)+("all")
  - [ ] opening books on 7x7 board
  - [ ] evalsgf, runownershiptests, analysis 
- [ ] features from KaTrain
  - [ ] weak bot
  - [ ] style bot 
- [ ] features from [yishn](https://github.com/yishn)
  - [ ] KataJigo 
- [ ] features from [waterfire](https://waterfire.us/joseki.htm)
  - [ ] Kogo's Joseki Dictionary
- [ ] advanced features 
  - [ ] CLI in web-app 
    - [x] add, behind the Go board
    - [ ] test all commands
    - [ ] use extra file to store the history and show in TaxtArea
    - [ ] `up/down` to find commands
    - [ ] placehold commands and `tab` to complete commands
  - [ ] navigate, move history, autoplay, guess mode *(exercise memorizing games)* 
  - [ ] exercise mode
  - [ ] self-adaptive stoneSize(traceSize) when zoom in/out
  - [ ] square board response to windowSize
  - [ ] game tree
  - [ ] games containe
  - [ ] multiple boards preview
  - [ ] load/save analyzed svg
  - [ ] svg2sgf, sgf2svg
  - [ ] Go games book, pdf
  - [ ] fuzzy stone placement
  - [ ] select data to analyze
  - [ ] small to big KataGo models
  - [ ] rank, rating, ladder match 
  - [ ] opening book of modern Go community? *(exercise opening and dissecting sequences)*
### Nonstandard Go
- [ ] expanded features
  - [ ] [Random Start Go](https://senseis.xmp.net/?RandomStartGo), need a moveNumber *(exercise fighting or ending games)*
  - [ ] reuse captures by each other, need to limit the number of stones, maybe 180 *(exercise counting liberties)*
  - [ ] [First Capture Go](https://senseis.xmp.net/?AtariGo) *(exercise capturing)*
  - [ ] [ChessWhiz](https://senseis.xmp.net/?ChessWhiz) *(exercise making/breaking eye shapes)* 
  - [ ] [Dots Go](https://senseis.xmp.net/?DotsGo) *(exercise trading or ko fighting)*
  - [ ] [One Color Go](https://senseis.xmp.net/?OneColourGo)
  - [ ] [Phantom Go](https://senseis.xmp.net/?PhantomGo)
  - [ ] [Blind Go](https://senseis.xmp.net/?BlindGo)
  - [ ] [Fog Of War Go](https://senseis.xmp.net/?FogOfWar)
  - [ ] [Multi-color Go](https://senseis.xmp.net/?MultiColorGo)
  - [ ] [Pair Go](https://senseis.xmp.net/?PairGo)
  - [ ] [Double Go](https://senseis.xmp.net/?DoubleGo)
  - [ ] Quantum Go [1](https://lifein19x19.com/viewtopic.php?f=9&t=18360) [2](https://senseis.xmp.net/?QuantumGo) [3](https://arxiv.org/abs/2007.12186)
  - [ ] [Topological Go](https://senseis.xmp.net/?TopologicalGo)?
  - [ ] [Toroidal Go](https://senseis.xmp.net/?ToroidalGo)
  - [ ] [Magnet Go](https://senseis.xmp.net/?ElectricGo)
  - [ ] [Neurotic Go](https://senseis.xmp.net/?NeuroticGo)
  - [ ] [Alice in Wonderland](https://www.britannica.com/topic/Alices-Adventures-in-Wonderland) mode(all rules random and need to guess)
### Non Go
- [ ] not merely Go
  - [ ] Five In A Row
  - [ ] Checkers
  - [ ] Reversi
- [ ] not merely Go board and stones
  - [ ] Chess with Stockfish 

***Be careful: avoid repetition to existing site/software, i.e. [boardspace](https://www.boardspace.net/english/index.shtml)/[kahv](https://go.kahv.io/)/[littlegolem](https://www.littlegolem.net/jsp/main/), and can be played/analyzed by corresponding bot/AI***

## Usage

<details>
	<summary>see the static 19x19 board——run board.jl</summary>
  
1. download, install and add [julia](https://julialang.org/) into path
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
(@v1.7) pkg> add PlotlyJS
```
5. download and run `board.jl`
```julia
julia> include("path/to/fileName.jl") 
```  
</details>

<details>
  <summary>play with KataGo in CLI——run gtp.jl</summary>

1. download a KataGo [release](https://github.com/lightvector/KataGo/releases/) and a [network](https://katagotraining.org/networks) and `gtp.jl`, then put them in one file fold
2. edit the first line of `gtp.jl` to indicate the KataGo release, the network and the config(inside KataGo releases) 
3. run `gtp.jl`
```shell
cmd> julia gtp.jl 
```
4. wait until
```shell
GTP ready, beginning main protocol loop
```
5. type following strings to play a Go game
```shell
play B k10
genmove W
showboard
genmove B
play W c3
showboard
...
final_score
quit
```
</details>

<details>
  <summary>play with KataGo in browser——run kata_dash.jl</summary>

1. run `kata_dash.jl`
```shell
cmd> julia kata_dash.jl
```
2. wait until
```julia
[ Info: Listening on: 0.0.0.0:8050
```
3. open one(**only one**) browser and type `localhost:8050` in the address bar
</details>

## Q&A 
- Why running board.jl takes so long? 
  - Julia needs more time to first plot.
  - You can use [sysimage](https://julialang.github.io/PackageCompiler.jl/dev/examples/plots.html#examples-plots) to accelerate.
- Why Julia?
  - [Evan Miller](https://www.evanmiller.org/why-im-betting-on-julia.html) 
- Why Plotly(JS) Dash?
  - More interactive features than the others. [Details](https://docs.juliaplots.org/latest/backends/)

## LICENSE
[LICENSE](./LICENSE.md)

## Doc
- [my Markdown Cheat Sheet](./Markdown.md)
- [my GTP Cheat Sheet](./GTP-cheat-sheet.txt)
- [Structures of Go, Go APP, VastGo](./structure.md)
- static Go board state matrix
- [Julia Style Cheat Sheet](./JuliaStyleCheatSheet.md)
