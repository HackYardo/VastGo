topText="""
### Hello, welcome to VastGo!"""
topDiv = html_div(
        dcc_markdown(topText), 
        style=Dict(
            "backgroundColor"=>"#111111",
            "textAlign"=>"center",
            "columnCount"=>"2",
            "color"=>"rgba(0,255,0,1)"
            )
        )
        
bottomText = dcc_markdown("""
***`Have a nice day!`***""")
bottomDiv = html_div(
        bottomText, 
        style=(width="49%",display="inline-block",float="right")
        )

whatgamesummary = html_summary("What's the game of Go/Baduk/Weiqi?")
whatgamemarkdown = dcc_markdown() do
    "
    \n>A turn-based abstract strategy board game, in which the aim is to 
    control more domains than the opponent. It was invented in China more 
    than **2,500 years** ago and is believed to be the oldest board game 
    continuously played to the present day.¹⁻²
    \n> **Turn-based**: players take turns to play
    \n> **Abstract**: not rely on a theme or simulate the real world
    \n> **Strategy**: players' choices determine the outcome
    \n> **Board Game**: a tabletop game that involves counters or pieces 
    moved or placed on a pre-marked surface or \"board\" 
    \n> **Tabletop Game**: played on a table or other flat surface, such 
    as board games, card games
    "
end
whatgame = html_details([whatgamesummary,whatgamemarkdown])

howplaysummary = html_summary("How to play?")
howplaymarkdown = dcc_markdown() do
    "
    \n> [THE EASY WAY](https://www.usgo.org/learn-play) or 
    [THE HARD WAY](https://lightvector.github.io/KataGo/rules.html)
    \n> **With bots**:
    \n ![withbot](assets/withbot.png)
    \n> **Free and Open Source Software** (FOSS):
    \n> **GUIs**: Sabaki, Lizzie, KaTrain, GoReviewPartner, LizGoban, q5Go, 
    LizzieYzy, Ogatak, LeelaGUI, BadukAI, Drago, VastGo
    \n> **GTP Engines**:  KataGo, Leela-Zero, SAI, MiniGo, ELF, PhoenixGo, 
    Leela, Pachi, GNU Go, AQ, Ray
    \n> **Models**: [KataGo's](https://katagotraining.org/), 
    [Leela-Zero's](https://zero.sjeng.org/), 
    [SAI's](http://sai.unich.it/)
    \n> My favorites: Sabaki for editing, BadukAI for phones 
    and VastGo otherwise.
    "
end
howplay = html_details([howplaysummary,howplaymarkdown])

isfunnysummary = html_summary("Is it funny?")
isfunnymarkdown = dcc_markdown() do
    "
    \n> **Yes**: 
    \n>easy rules, complex tactics
    \n>rare draws ([~1‱](https://senseis.xmp.net/?NoResult))
    \n>flexible 
    \n> **No**: 
    \n>silent
    \n>AI advantages
    \n>elementary (no ∞∂∫∇, only +-*/)
    "
end
isfunny = html_details([isfunnysummary,isfunnymarkdown])

gotchasummary = html_summary("Gotcha")
gotchamarkdown = dcc_markdown(
    "
    \n> **Don't know terms**?
    \n> [Sensei's Library](https://senseis.xmp.net/) (SL)
    \n> **Can't find FOSS**?
    \n> SL, [Github](https://github.com), [Bing](https://www.bing.com)
    "
    )
gotcha = html_details([gotchasummary,gotchamarkdown])

whatguisummary = html_summary("About")
whatguimarkdown = dcc_markdown(
"
\n> version: 0.0.1 
\n> [readme](https://github.com/HackYardo/VastGo)
\n> [discuss without code](https://github.com/HackYardo/VastGo/discussions)
\n> [source code issues](https://github.com/HackYardo/VastGo/issues)
\n> [contributors](https://github.com/HackYardo/VastGo/graphs/contributors)
\n> [LICENSE](https://github.com/HackYardo/VastGo/blob/master/LICENSE.md)
"
)
whatgui = html_details([whatguisummary,whatguimarkdown])

guideDiv = html_div([whatgame,isfunny,howplay,gotcha,whatgui])

ruleDiv = html_div() do
    html_label("To play first or not: "),
    dcc_radioitems(id="Color",
        options = [
            Dict("label" => "None", "value" => "N"),
            Dict("label" => "Black", "value" => "B"),
            Dict("label" => "White", "value" => "W"),
            Dict("label" => "All", "value" => "A")
            ],
        value = "B"
        ),
    dcc_markdown(""),
    
    html_label("Board Size M,N: "),
    dcc_input(id="BoardSizeM",
        value=19,
        type="number",
        min=2,step=1,max=19),
    dcc_input(id="BoardSizeN",value=19,type="number",min=2,step=1,max=19),
    dcc_markdown(""),
    
    html_label("Komi: "),
    dcc_input(id="KM",value=7.0,type="number",min=-150,step=0.5,max=150),
    dcc_markdown(""),
    
    html_button("OK", id = "RuleOK"),
    dcc_markdown("")
end

startGame=html_div(style = Dict("columnCount" => 2)) do
    guideDiv,
    ruleDiv
end

playGame = html_div() do 
    topDiv,
    boardGraph,
    infoTextarea,
    bottomDiv
end 
