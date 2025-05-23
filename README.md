![static](assets/board.png)

## About

> [!CAUTION]
> As Plotly Dash Official only supports Python since 2022, this project is archived. Potential options would be Makie.jl or NiceGUI.py. If the project come back, its new name will be VastBaduk.

**Note: Still in the very early [stage](doc/versions.md#001-just-work), don't expect to be stable.**

> *The README is in both [English](./README.md) and [简体中文](./README_CN.md). The repo is on both [Github](https://github.com/HackYardo/VastGo) and [Gitee](https://gitee.com/vastgo/VastGo).* And it's about the game of [Go/Baduk/Weiqi](https://www.britgo.org/files/rules/GoQuickRef.pdf), [GoTextProtocol(GTP)](http://www.lysator.liu.se/~gunnar/gtp/), [SmartGameFormat(.sgf)](https://www.red-bean.com/sgf/), [KataGo](https://katagotraining.org/), [Leela-Zero](https://zero.sjeng.org/), [GNU Go](https://www.gnu.org/software/gnugo/), [Julia](https://julialang.org/), [PlotlyJS.jl](https://plotly.com/julia/), [Dash.jl](https://dash-julia.plotly.com/), [Markdown](https://commonmark.org/), [ScalableVectorGraphics(.svg)](https://developer.mozilla.org/en-US/docs/Web/SVG), [Regular Expression](https://ryanstutorials.net/linuxtutorial/grep.php), etc. 

VastGo is
- A multi-platform Go GUI that can run on Windows, Linux, Android and perhaps FreeBSD, MacOS, IOS, HarmonyOS. 
- Based on Dash.jl, PlotlyJS.jl, JSON3.jl and modern or classic GTP engines.
- Written in pure julia and under the MIT license.

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
- **funny**: nonstandard Go, *BEAT AI RIGHT NOW*
- **green**: uses playtime data to first review, *LESS EXCESSIVE COMPUTING LESS CO₂* 
- **simple**: doesn't know Go, uses GTP command `showboard`, *LESS CODE LESS GOTCHA*
- **useful**: game tree - score curve, 3D ownership, spline style, f'(x), f"(x), *RICH AND POWERFUL PLOT*
- **compatible**: SBKV for winrate and OGSC for score, *THE SAME SGF AS Sabaki AND Ogatak* 

## Features
- [some nonstandard Go modes and their free mixtures](doc/features.md#nonstandard-go)
- [the wish list](doc/features.md)
- [the road map](doc/versions.md)

*Be careful: avoid repetition to existing site/software, i.e. [boardspace](https://www.boardspace.net/english/index.shtml)/[kahv](https://go.kahv.io/)/[littlegolem](https://www.littlegolem.net/jsp/main/), and can be played/analyzed by corresponding bot/AI*

## Usage

<details>
  <summary>Status</summary>

software | computer | phone
--- | --- | ---
julia | >= 1.6.7 | 1.6.7 - 1.7.2 or 1.9.x
KataGo | **PASS** | **PASS**
Leela-Zero | *fail* | *fail*
GNU Go | *fail* | *fail*

mode | boardsize | stateinfo 
--- | --- | --- 
Blind Go | **2² - 19²** | **PASS** 
One Color Go | **2² - 19²** | **PASS** 
Phantom Go | **2² - 19²** | **PASS** 
Magnet Go | *19²* | *captures*, *move history*

</details>

<details>
	<summary>Hard/Software requirements</summary>
  
**Hardware:**
- Free HardDisk >= 5GB
- Total Memory  >= 8GB

**Julia, packages and this repo:**
1. download and add [julia](https://julialang.org/) into path
2. run julia in cmd/shell/terminal and you will enter julia REPL-mode
```shell
shell> julia 
```
3. enter julia Pkg REPL-mode
```shell
julia> ]
```
4. install packages
```julia
(@v1.9) pkg> add Dash PlotlyJS JSON3 PackageCompiler PlotlyBase
```
5. download this repo

**KataGo, Leela-Zero, GNU Go:**
(If you don't have them yet...)
- KataGo: download its [engine](https://github.com/lightvector/KataGo/releases/) and a [network](https://katagotraining.org/networks)
- Linux(Debian/Ubuntu): 
  1. `sudo apt update -y`
  2. `sudo apt install leela-zero gnugo`
  3. download a [network](https://zero.sjeng.org/) of Leela-Zero

</details>

<details>
  <summary>in terminal——run src/terminal.jl</summary>

1. edit `data/config.toml` to indicate **the command** of running a bot, **the directory** where to run the command and **a name** to call it, e.g.
```toml
["ko"]
cmd = "./katago gtp -model elo9000.txt.gz"
dir = "../KataGoOpenCL/"
```
**Note: DO NOT use `-q` in Leela-Zero's command, since `showboard` will GONE.**

2. run `src/terminal.jl` with a bot's name, e.g.
```shell
shell> julia src/terminal.jl ko
```
3. wait until
```julia
[ Info: GTP ready 
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
  <summary>in browser——run app.jl</summary>

1. run `app.jl`
```shell
shell> julia app.jl
```
2. wait until
```julia
[ Info: Listening on: 0.0.0.0:8050
```
3. open one(**only one**) browser and type `localhost:8050` in the address bar to play
4. type `exit` in terminal to exit the program
</details>

<details>
  <summary>on Android</summary>

Because Android phones are arm and not x86-64, you need more steps:
1. download and install [Termux](https://github.com/termux/termux-app/)
2. install [ubuntu in termux](https://github.com/MFDGaming/ubuntu-in-termux)
3. download [julia for Generic Linux on ARM](https://julialang.org/downloads/platform/#linux_and_freebsd), **Note: instead of x86-64, use aarch64 or armv7l**
4. download and compile KataGo engine via [9 commands](https://github.com/lightvector/KataGo/blob/master/Compiling.md#linux)

Now the same as on x86-64. 
</details>

<details>
  <summary>uninstall</summary>
  
**uninstall julia, packages and this repo:**
- Julia does not install anything outside the directory it was cloned into. Julia can be completely uninstalled by deleting this directory. 
- Julia packages are installed in `~/.julia` by default, and can be uninstalled by deleting `~/.julia`.
- Delete this repo.

**uninstall KataGo, Leela-Zero, GNU Go:**
(If you don't use them anymore...)
1. `sudo apt remove leela-zero gnugo`
2. `sudo apt autoremove`
3. delete KataGo's engine
4. delete KataGo's and Leela-Zero's networks

</details>

## Q&A 
- Why create this?
  - C++ has [q5Go](https://github.com/bernds/q5Go).
  - Java has [LizzieYzy](https://github.com/yzyray/lizzieyzy).
  - JavaScript has [Sabaki](https://sabaki.yichuanshen.de/),  [LizGoban](https://github.com/kaorahi/lizgoban),  [Ogatak](https://github.com/rooklift/ogatak).
  - Python has [KaTrain](https://github.com/sanderland/katrain),  [BadukAI](https://aki65.github.io/).
  - 🚀🚀🚀 ***Julia must have one too!*** 🚀🚀🚀
- Why so slow? 
  - Julia's compiler sort of optimises code, and it takes time.
  - Reuse the compiled work via [sysimage](https://julialang.github.io/PackageCompiler.jl/dev/examples/plots.html).
- Why Julia?
  - [Evan Miller](https://www.evanmiller.org/why-im-betting-on-julia.html) 
- Why Plotly(JS) Dash?
  - More [interactive](https://docs.juliaplots.org/latest/backends/) features than the others.

## LICENSE
[LICENSE](./LICENSE.md) 
[THIRDPARTY](./THIRDPARTY.md)

## Contribute
```julia
if sourceCode in contribution
    @goto Issues
else
    @goto Discussions
end

@label Issues
    browser("https://github.com/HackYardo/VastGo/issues")
@label Discussions
    browser("https://github.com/HackYardo/VastGo/discussions")
```

## Doc
- [my Markdown Cheat Sheet](doc/Markdown.md)
- [GTP Check list](doc/GTP-check-list.txt)
- [Structures of Go, Go APP, VastGo](doc/structure.md)
- static Go board state matrix
- [Julia Style Cheat Sheet](doc/JuliaStyleCheatSheet.md)
