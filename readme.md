![static](./board.svg)
future
![dynamic](./dynamic.gif)
current 

## About

**!!!NOTE: Still in the very early [stage](#features), don't expect to be stable.**

> The repo is about the game of [Go/Baduk/Weiqi](https://www.usgo.org/learn-play), [GoTextProtocol(GTP)](http://www.lysator.liu.se/~gunnar/gtp/), [SmartGameFormat(.sgf)](https://www.red-bean.com/sgf/), [KataGo](https://katagotraining.org/), [Leela-Zero](https://zero.sjeng.org/), [GNU Go](https://www.gnu.org/software/gnugo/), [Julia](https://julialang.org/), [PlotlyJS.jl](https://plotly.com/julia/), [Dash.jl](https://dash-julia.plotly.com/), [Markdown](https://commonmark.org/), [ScalableVectorGraphics(.svg)](https://developer.mozilla.org/en-US/docs/Web/SVG), [Regular Expression](https://ryanstutorials.net/linuxtutorial/grep.php), etc.

VastGo is
- A multi-platform Go GUI that can run on Windows, Linux, Android and perhaps FreeBSD, MacOS, IOS, HarmonyOS. 
- Based on Dash.jl, PlotlyJS.jl, JSON.jl and modern or classic GTP engines.
- Written in pure julia and under the MIT [license](#license).

Design:
```
            DATA
Players <<<======>>> components
             ||          /\
            c||b         ||
            a||a        c||b
            l||c        a||a
            l||k        l||c
             ||s        l||k
             ||          ||s
             \/          ||
          functions <<<======>>> Bots
                        DATA
```

Ideas:

Idea | Detail
--- | ---
funny | nonstandard Go, *BEAT AI RIGHT NOW*
green | use playtime data to first review, *LESS EXCESSIVE COMPUTING LESS CO₂* 
simple | don't know Go, use GTP command `showboard`, *LESS CODE LESS GOTCHA*
useful | *RICH and POWERFUL PLOT*: move-score-tree curve, 3D ownership, spline... line style, f'(x), f"(x)

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

## Features

[features](./features.md)
[versions](./versions.md)
***Be careful: avoid repetition to existing site/software, i.e. [boardspace](https://www.boardspace.net/english/index.shtml)/[kahv](https://go.kahv.io/)/[littlegolem](https://www.littlegolem.net/jsp/main/), and can be played/analyzed by corresponding bot/AI***

## Usage

<details>
	<summary>Hard/Software requirements</summary>
  
**Hardware:**
- Free HardDisk >= 2GB
- Total Memory >= 8GB

**Julia, packages and this repo:**
1. download and add [julia](https://julialang.org/) into path
2. run julia in cmd/shell/terminal and you will enter julia-REPL mode
```shell
cmd> julia 
```  
3. enter julia-pkg mode
```julia
julia> ]
```
4. install packages
```julia
(@v1.7) pkg> add Dash PlotlyJS JSON LinearAlgebra
```
5. download this repo

**KataGo, Leela-Zero, GNU Go:**
For example:
- KataGo: download its [engine](https://github.com/lightvector/KataGo/releases/) and a [network](https://katagotraining.org/networks)
- Linux(Debian/Ubuntu): 
 1. `sudo apt update -y`
 2. `sudo apt install leela-zero gnugo`
 3. download a [network](https://zero.sjeng.org/) of Leela-Zero

</details>

<details>
  <summary>in terminal——run gtp.jl</summary>

1. edit the first line of `gtp.jl` to indicate the KataGo release, the network and the config(inside KataGo releases) 
2. run `gtp.jl`
```shell
cmd> julia gtp.jl 
```
3. wait until
```shell
GTP ready ...
```
4. type following strings to play a Go game
```shell
1 play B k10    # (id) command arguments
2 genmove W    # see GoTextProtocol for details
3 showboard
genmove B
5 play W c3
10 showboard
...
3 final_score
quit
```
</details>

<details>
  <summary>in browser——run kata_dash.jl</summary>

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
- Why so slow? 
  - Julia's compiler sort of optimises code, and it takes time.
  - Reuse the compiled work via [sysimage](https://julialang.github.io/PackageCompiler.jl/dev/examples/plots.html#examples-plots).
- Why Julia?
  - [Evan Miller](https://www.evanmiller.org/why-im-betting-on-julia.html) 
- Why Plotly(JS) Dash?
  - More [interactive](https://docs.juliaplots.org/latest/backends/) features than the others.

## LICENSE
[LICENSE](./LICENSE.md) 
[THIRDPARTY](./THIRDPARTY.md)

## Contribute
```julia
@label issues = https://github.com/HackYardo/VastGo/issues
@label discussions = https://github.com/HackYardo/VastGo/discussions

if sourceCode in contribution
  @goto issues
else
  @goto discussions
end
```

## Doc
- [my Markdown Cheat Sheet](./Markdown.md)
- [GTP Check list](./GTP-check-list.txt)
- [Structures of Go, Go APP, VastGo](./structure.md)
- static Go board state matrix
- [Julia Style Cheat Sheet](./JuliaStyleCheatSheet.md)
