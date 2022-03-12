boardSize=[19,19]
m = rand([-1,0,1,0,0,0], (boardSize[1],boardSize[2]))
println(m)
p = rand(boardSize[1]:boardSize[2], 2)
c = rand([-1,1], 1)
m = cat(p,c, dims=1)
println(m)
m[p[1],p[2]]=0
i = 1
m_vector = m 
while p[2] < boardSize[2]
	m[p[1],p[2]+i] == c
	i = 1 + i
	while m[p[1],p[2]+i] in [-1,1]

