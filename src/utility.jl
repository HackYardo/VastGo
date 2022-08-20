#=
"""
`sourcefile utility.jl`

Some utilities.

# Examples
```
julia> include("path/to/utility.jl")
utility

julia> utility()
utilityfunction1
utilityfunction2
...
```
"""
=#

"""
`average(v::Vector)`

`sum`(v)/`length`(v)

# Examples

```
julia> v = [1,3,5]; average(v)
3.0
```
"""
function average(vector)
    sum(vector)/length(vector) 
end

"""
`findindex(element, collection)`

# Examples

```
julia> c = ["a",1,"1","o",0,"a"]; findindex("a",c)
2-element Vector{Any}:
 1
 6
```
"""
function findindex(element, collection)
    m = 1 
    n = []
    for el in collection
        if el == element
            n = cat(n, m, dims=1)
        end 
        m = m + 1
    end 
    return n 
end 

"""
`pkgNames_strFile(Pkg::Module)`

Print `names`(Pkg) into a file.

# Examples

```
using Pkg
pkgNames_strFile(Pkg)
```

Or:
```
using Pkg1, Pkg2
pkgNames_strFile.([Pkg1, Pkg2])
```

Then open "namesofPkg.txt"...
"""
function pkgNames_strFile(pkg)
    open("namesof$pkg.txt", "w") do io
        names = String.(names(pkg))
        for name in names
            println(io, name)
        end
    end
end

"""
`utility()`

Some utilities.

# Examples
```
julia> utility()
utilityfunction1
utilityfunction2
...
```
"""
function utility()
    println("average\nfindindex\npkgNames_strFile")
end
