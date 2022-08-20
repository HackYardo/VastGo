using Dash, PlotlyBase



app = dash()
app.title = "A playground of Dash"
app.layout = html_div() do

#run_server(app, "0.0.0.0", 8050, debug=true)

@async run_server(app, "0.0.0.0", 8050, debug=false)

function playgroundofDash()
    while true  
        if readline() == "exit"
            break
        end
    end
end

playgroundofDash()
