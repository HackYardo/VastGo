topText="**Hi, welcome to VastGo!**
\n\nHave a nice game!"

bottomText=""

bottomMarkdown=dcc_markdown(bottomText)

someIssues="
### VastGo is on basic testing, there are some issues need to solve:
- [x] KataGo starts up ***twice*?**(may need to add a `run KataGo` button in Dash APP or thread/coroutines or I/O redicect or import/using *.jl?)
  - The [reason](https://community.plotly.com/t/why-global-code-runs-twice/12514).
- [x] You can do nothing except placing **legal** stones and `ctrl+R` to refresh.
  - Now you can redefine a game in the `Begin` tab.
- [ ] Can not run in multiple tabs/browsers (how to know global or local states?)
- [x] Rules(GameInfo), SGF and Click are too long, and have no 'space' to segment.
  - Use `dcc_textarea` instead of `dcc_markdown` or `html_div`.
- [x] Can not work in new version Dash because 
  - ArgumentError: PlotlyJS.SyncPlot doesn't have a defined `StructTypes.StructType`
  - The repo using old version Dash because DashDaq added
  - The [reason](https://github.com/plotly/Dash.jl/issues/153)
- [ ] Can not use DashBootstrapComponents to change app layout
  - Weird syntax and not many documents/examples
  - Auto delete some spaces in GTP-output
- [x] The board can not refresh autoly after change the size or obstacles.
  - Type `clear_board.` in GTP commands input or click `PASS` in the board plot instead.
  - Just add a `callback! Input`.
- [x] The whb in showboard not be displayed now.
- [ ] The number of obstacles doesn't fit boardSize.
- [x] Can not pass more than one time.
  - Reason: `Dash.jl`'s clickEvent doesn't response to it.
  - There are two pass buttons, **PA** and **SS**.
- [ ] **asyn**: `reply() != query()`
  - [ ] KataGo returns answer 2 before answer 1 sonmetimes[?](https://github.com/lightvector/KataGo/blob/master/docs/GTP_Extensions.md)
  - [ ] `Dash.jl` sends two commands at once sometimes.
  - [x] The same two `clickData` does not run `callback!()` twice.
      - It's a Dash's feature and doesn't need to solve."
#----------------------------------------
# The up is tab1, the down is tab2
#----------------------------------------

whatGameLabel=html_summary("What's the game of Go/Baduk/Weiqi?")
whatGameInfo=dcc_markdown() do
    "
    \n>  A turn-based abstract strategy board game, in which the aim is to control more domains than the opponent.
    \n>  It was invented in China more than **2,500 years** ago and is believed to be the oldest board game continuously played to the present day.¹⁻²
    \n>***Turn-based***: players take turns to play
    \n>***Abstract***: not rely on a theme or simulate the real world
    \n>***Strategy***: players' choices determine the outcome
    \n>***Board Game***: a tabletop game that involves counters or pieces moved or placed on a pre-marked surface or \"board\" 
    \n>***Tabletop Game***: played on a table or other flat surface, such as board games, card games
    "
    end
whatGame=html_details() do
    whatGameLabel,
    whatGameInfo
    end

howPlayLabel=html_summary("How to play?")
howPlayInfo=dcc_markdown() do #TODO
    "
    \n>Just try!
    "
    end
howPlay=html_details() do
    howPlayLabel,
    howPlayInfo
    end

rulesetReference=dcc_markdown() do
    "**Rule Sets**³:"
end
rulesetButtons=html_div(style = Dict("columnCount" => 4)) do
    html_button("Fuzhou-like Rules",id="fRule"),
    html_button("Chinese-like Rules",id="cRule"),
    html_button("Japaness-like Rules",id="jRule"),
    html_button("Tromp-Taylor Rules",id="tRule"),
    html_button("OGS/KGS \"Chinese\"-like Rules",id="oRule"),
    html_button("AGA-like Rules",id="aRule"),
    html_button("New Zealand-like Rules",id="zRule"),
    html_button("Stone-Scoring Rules",id="sRule")
end
rulesetChecklists=html_div(style = Dict("columnCount" => 2)) do
    
    html_label("X,Y:",title="Integers indicating the board size."),
    dcc_input(id="SZ_X",value=19,type="number",min=2,step=1,max=19),
    dcc_input(id="SZ_Y",value=19,type="number",min=2,step=1,max=19),
    dcc_markdown(""),

    html_label("Komi:",title="Integer or half-integer indicating compensation given to White for going second."),
    dcc_input(id="KM",value=7.0,type="number",min=-150,step=0.5,max=150),
    dcc_markdown(""),

    html_label("KoRule:",title="The variant of the rule prohibiting repetition. https://senseis.xmp.net/?KoRules"),
    dcc_radioitems(id="ko",
        options = [
            Dict("label" => "Simple", "value" => "SIMPLE"),
            Dict("label" => "Positional Superko", "value" => "POSITIONAL"),
            Dict("label" => "Situational Superko", "value" => "SITUATIONAL")
            ],
        value = "POSITIONAL",
        ),
    
    html_label("ScoringRule:",title="Defines what the score of a finished game is. Area (count stones and surrounded empty points, \"Chinese\"-like); Territory (count captures and surrounded empty points, \"Japanese\"-like). https://senseis.xmp.net/?Scoring"),
    dcc_radioitems(id="score",
        options = [
            Dict("label" => "Area", "value" => "AREA"),
            Dict("label" => "Territory", "value" => "TERRITORY")
            ],
        value = "AREA",
        ),
    
    html_label("TaxRule:",title="Minor adjustments to scoring rule, indicating what, if any, empty points may not be scored. None (surrounded empty points always count); Seki (empty points surrounded by groups in seki do not count); All (all groups are taxed up to 2 of their surrounded empty points - i.e. empty points surrounded by groups in seki do not count, and living groups are taxed 2 points each)."),
    dcc_radioitems(id="tax",
        options = [
            Dict("label" => "None", "value" => "NONE"),
            Dict("label" => "Seki", "value" => "SEKI"),
            Dict("label" => "All", "value" => "ALL")
            ],
        value = "NONE",
        ),

    html_label("Button:",title="Whether a half-point is awarded to the first player to be able to pass. (e.g. slightly rewarding endgame efficiency, partially reconciling area and territory scoring)."),
    dcc_radioitems(id="buttonRule",
        options = [
            Dict("label" => "Used", "value" => "true"),
            Dict("label" => "Not Used", "value" => "false")
            ],
        value = "true",
        ),
    
    html_label("MultiStoneSuicide:",title="Whether suicide of multiple stones is allowed. (in these rules, a suicide move that kills only the stone just played and nothing else, leaving the board unchanged, is never allowed)"),
    dcc_radioitems(id="sui",
        options = [
            Dict("label" => "Allowed", "value" => "true"),
            Dict("label" => "Disallowed", "value" => "false")
            ],
        value = "false",
        ),
    
    html_label("WhiteHandicapBonus:",title="How many bonus points white receives during handicap games when black gets N stones. KataGo supports handicap games, but for simplicity, this rules document does NOT describe them. These checkboxes are included merely to provide a convenience reference as how this quirk of handicap game scoring differs between rulesets."),
    dcc_radioitems(id="whb",
        options = [
            Dict("label" => "0", "value" => "0"),
            Dict("label" => "N-1", "value" => "N-1"),
            Dict("label" => "N", "value" => "N")
            ],
        value = "0",
        )
end
rulesetDiv=html_div() do
    rulesetReference,
    rulesetButtons,
    rulesetChecklists
end

appendixDiv=dcc_markdown() do
    "
    \n**Appendix A Synonyms**:
    \nsituation==position+turn, position==board+stones, ko==repeat, seki==symbiotic, handicap==obstacle, grid nodes==vertices
    \n**Appendix B Tips**:
    \n**a** If hover over the rule items, more details will be displayed.
    \n**b** If modify the obstacles, X, Y, the board will be cleared.
    \n**c** Button can't be used in territory-scoring.
    \n**d** There are two pass buttons, **PA** and **SS**, used for consecutive passes.
    \n**Appendix C References**:
    \n***1*** [A Brief History of Go](https://www.usgo.org/brief-history-go). *American Go Association*, 2022
    \n***2*** Peter Shotwell. [The Game of Go: Speculations on its Origins and Symbolism in Ancient China](https://www.usgo.org/sites/default/files/bh_library/originsofgo.pdf). *American Go Association*, 2008.
    \n***3*** David J Wu. KataGo's Supported Go Rules (Version 2), 2021. https://lightvector.github.io/KataGo/rules.html. (not include the Fuzhou-like Rules)
    "
end

ruleCheck=html_div() do
    dcc_markdown("**Rule Check**:"),
    html_button("SUBMIT",id="submitRule"),
    html_div(),
    dcc_textarea(
        placeholder="To check if the whole rule is valid...",
        id="confirmRule",
        style=Dict("width"=>"390px","height"=>"360px")
        ),
    html_div(),
    html_button("OK",id="okRule")
end

startGame=html_div(style = Dict("columnCount" => 2)) do
    whatGame,
    howPlay,
    dcc_markdown(
        "
        \n### Start Now:
        \nJust skip the rule items below and go to the `While` tab to play a game.
        \nOr check the items and click the `SUBMIT` to check the rule before a game.
        \nA game will over after 1 resign or 2 consecutive passes*(not include the button-pass)*, and you will see the outcome.
        "
        ),

    html_label("To play first or not:"),
    dcc_radioitems(id="playerColor",
        options = [
            Dict("label" => "Black", "value" => "B"),
            Dict("label" => "White", "value" => "W")
            ],
        value = "B"
        ),

    html_label("Nonstandard Go, Move&Position:",title="Search on https://senseis.xmp.net/ for more details"),
    dcc_radioitems(id="moveMode",
        options = [
        Dict("label" => "magnet", "value" => "magnet"),
        Dict("label" => "quantum", "value" => "quantum"),
        Dict("label" => "skid", "value" => "skid"),
        Dict("label" => "standard", "value" => "standard")
        ],
        value = "standard"
        ),

    html_label("Nonstandard Go——Visibility:",title="Search on https://senseis.xmp.net/ for more details"),
    dcc_radioitems(id="colorMode",
        options = [
            Dict("label" => "blind", "value" => "blind"),
            Dict("label" => "phantom", "value" => "phantom"),
            Dict("label" => "war fog", "value" => "warFog"),
            Dict("label" => "one colour", "value" => "oneColour"),
            Dict("label" => "standard", "value" => "standard")
            ],
        value = "standard"
        ),

    html_label("Fixed obstacles:",title="The obstacles are placed on the board on the vertices the GTP prefers, e.g. 2"),
    dcc_input(id="fObstacle",value="0",type="number",min=0,step=1,max=9),
    html_label("Placed obstacles:",title="The obstacles are placed on the board on the vertices the engine prefers, e.g. 2"),
    dcc_input(id="pObstacles",value="0",type="number",min=0,step=1,max=20),
    html_label("Set obstacles:",title="The obstacles are placed on the board on the vertices the player prefers, e.g. k10 q16"),
    dcc_input(id="sObstacles",value="",type="text"),

    rulesetDiv,
    ruleCheck,
    appendixDiv,
    dcc_markdown("**Debug:**"),
    html_div(id="rulesetBtn"),
    html_div(id="ruleSmt")
end

playGame=html_div() do
    html_div(
        dcc_markdown(topText), 
        style=Dict(
            "backgroundColor"=>"#111111",
            "textAlign"=>"center",
            "columnCount"=>"2",
            "color"=>"rgba(0,255,0,1)"
            )
        ),
    html_div(
        [
        dcc_graph(id="board"),
        html_div(
            [
            dcc_textarea(
                id="gtpO",
                #placeholder = "Enter a value...",
                #value="This is a TextArea component",
                style=Dict("width"=>"900px","height"=>"800px")
                );
            dcc_input(
                id="gtpI",
                placeholder="GTP commands end with a '.'",
                value="",
                type="text",
                style=Dict("width"=>"900px","height"=>"30px")
                )
            ],
            style=Dict("float"=>"right")
            )
        ],
        style=Dict("columnCount"=>"2")
        ),
    html_div(
        bottomMarkdown, 
        style=(width="100%",display="inline-block",textAlign="right"#=,float="right"=#)
        ),
    dcc_textarea(id="Info",style=Dict("width"=>"900px","height"=>"300px",#="cols"=>2=#)),
    dcc_confirmdialog(id="finalDialog",message="",displayed=false),
    html_div(dcc_markdown(someIssues))
end