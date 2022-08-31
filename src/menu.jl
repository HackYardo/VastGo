topText="""
### Hello, welcome to VastGo!"""

bottomText = dcc_markdown("""
***`Have a nice day!`***""")

turn = html_div() do
    html_label("To play first or not:"),
    dcc_radioitems(id="ChooseColor",
        options = [
            Dict("label" => "None", "value" => "N"),
            Dict("label" => "Black", "value" => "B"),
            Dict("label" => "White", "value" => "W"),
            Dict("label" = > "All", "value" => "A")
            ],
        value = "B"
        )
end
