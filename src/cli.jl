using Dash

katagoCommand=`./katago gtp -config gtp_custom.cfg -model b6/model.txt.gz`
katagoProcess=open(katagoCommand,"r+")
engineProcess=katagoProcess

function query(sentence::String)
    println(engineProcess,sentence)
end
function reply()
    paragraph=""
    while true
        sentence=readline(engineProcess)
        if sentence==""
            break
        else 
            paragraph="$paragraph$sentence\n"
        end
    end
    #println(paragraph)
    return paragraph::String
end

function gtp_io(sentence)
    if sentence != "" && !("" in split(sentence," "))
        if sentence[end]=='.' && sentence[end-1] != ' '
            sentence=sentence[1:end-1]
            query(sentence)
            paragraph=reply()
            return "$sentence\n$paragraph"
        else
            return ""
        end
    else
        return ""
    end
end

app = dash()

app.layout = html_div() do
    html_div(
        [
        dcc_textarea(style=Dict("width"=>"930px","height"=>"836px")),
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
        )
    end

callback!(
    app,
    Output("gtpO","value"),
    Input("gtpI","value"),
    ) do gtpInput
        gtp_io(gtpInput)
    end;

run_server(app, "0.0.0.0", 8050, debug=true);