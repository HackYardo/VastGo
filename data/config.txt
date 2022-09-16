function bot_config()

bots = Dict(
"g"   => (dir = "", 
          cmd = "gnugo --mode gtp"),
"l"   => (dir = "../networks/", 
          cmd = "leelaz --cpu-only -g -v 8 -w w6.gz"),
"k"   => (dir = "../KataGo1.11Eigen/", 
          cmd = "./katago gtp -config v8t5.cfg -model ../networks/m6.txt.gz"),
"k2"  => (dir = "../KataGo1.11Eigen/", 
          cmd = "./katago gtp -config v8t5.cfg -model ../networks/m20.txt.gz"),
"ka"  => (dir = "../KataGo1.11AVX2/", 
          cmd = "./katago gtp -config v8t5.cfg -model ../networks/m6.txt.gz"),
"ka2" => (dir = "../KataGo1.11AVX2/", 
          cmd = "./katago gtp -config v8t5.cfg -model ../networks/m20.txt.gz")
)

defaultBot = ["k"]

return defaultBot, bots

end 
