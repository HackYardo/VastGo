topText="""
### Hello, welcome to VastGo!"""

bottomText = dcc_markdown("""
***`Have a nice day!`***""")

topDiv = html_div(
        dcc_markdown(topText), 
        style=Dict(
            "backgroundColor"=>"#111111",
            "textAlign"=>"center",
            "columnCount"=>"2",
            "color"=>"rgba(0,255,0,1)"
            )
        )
        
bottomDiv = html_div(
        bottomText, 
        style=(width="49%",display="inline-block",float="right")
        )

colorRadioitems = html_div() do
    html_label("To play first or not:"),
    dcc_radioitems(id="colorRadioitems",
        options = [
            Dict("label" => "None", "value" => "N"),
            Dict("label" => "Black", "value" => "B"),
            Dict("label" => "White", "value" => "W"),
            Dict("label" => "All", "value" => "A")
            ],
        value = "B"
        )
end
