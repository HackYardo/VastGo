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
julia> c = ["a",1,"1","o",0,'a']; findindex('a', c)
1-element Vector{Int64}:
 6
```
"""
function findindex(element, collection)
    m = 1 
    n = Vector{Int64}()
    for el in collection
        if el == element
            n = cat(n, m, dims=1)
        end 
        m = m + 1
    end 
    n 
end 

"""
`match_diy(r::Regex, lines::Vector)`
`match_diy(r::Vector{Regex}, lines::Vector)`

Return a vector of the matched strings.

# Examples

```
shell> cat f.txt
000
010
210

julia> r = r"^0.{1,}"; match_diy(r, readlines("f.txt"))
2-element Vector{AbstractString}:
 "000"
 "010"

julia> r = [r, r"^2.{1,}"]; match_diy(r, readlines("f.txt"))
String[]
```
"""
function match_diy(r::Regex, lines::Vector)
    mlines = match.(r, lines)
    v = Vector{String}()
    for line in mlines
        if isnothing(line)
            continue
        else 
            v = cat(v, line.match, dims=1)
        end
    end
    v 
end
function match_diy(r::Vector{Regex}, lines::Vector)
    v = Vector{String}()
    for i in r
        v = match_diy(i, lines)
        lines = v 
    end
    v 
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
    println("average\nfindindex\nfile_match\npkgNames_strFile")
end
