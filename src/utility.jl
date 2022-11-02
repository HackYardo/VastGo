#=
"""
`sourcefile utility.jl`

Some utilities.

# Examples
```
julia> include("path/to/utility.jl")
utility

help?> utility
```
"""
=#

const UTILITY  = @__FILE__
const SRC      = dirname(UTILITY)
const REPO     = dirname(SRC)
const CONFIG   = joinpath(REPO, "data", "config.toml")
function const_path()
    println(SRC)
    println(REPO)
    println(CONFIG)
end

"""
`average(v::Vector)`

`sum`(v)/`length`(v)

# Examples

```
julia> v = [1,3,5]; average(v)
3.0
```
"""
average(vector) = sum(vector)/length(vector) 

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
        nameVector = String.(names(pkg))
        for name in nameVector
            println(io, name)
        end
    end
end

"""
`collectrows(A::AbstractMatrix)`

`collect`.(`eachrow`(A))
"""
collectrows(A::AbstractMatrix) = collect.(eachrow(A))
#collectcol(A::AbstractMatrix) = collect.(eachcol(A'))'

"""
`split_undo(v::Vector{SubString{String}})::String`

Undo `split`(str, "\n").
"""
function split_undo(v::Vector{SubString{String}})::String
    s = ""
    for el in v 
        s = s * el * '\n'
    end 
    s
end

"""
`json_pretty(sth)`

Convert a .json to a pretty string.

> JSON3 needed.

"""
function json_pretty(sth)
    io = IOBuffer()
    JSON3.pretty(io, JSON3.write(sth))
    String(take!(io))
end 

"""
```
function print_diy(
    str1::String, str2::String;
    ln::Bool=true, flag::Bool=true, c::Union{Int64,Symbol}=6, b::Bool=true
    )

    if ln
        str2 = str2 * '\n'
    end
    if flag
        printstyled(str1, color=c, bold=b)
        print(str2)
    else
        print(str1)
        printstyled(str2, color=c, bold=b)
    end
end
```
"""
function print_diy(s::String, str::String; ln::Bool=true, c::Symbol=:cyan)
#= color
Symbol
    :red, :green, :yellow, :blue, :magenta
Int
    1,2,3,4,5
=#
    if ln
        str = str * '\n'
    end

    if length(s) == 1
        if s == "i"
            s = "[ Info: "
        elseif s == "e"
            s = "[ Error: "
            c = :red
            str = str * '\n'
        else
            s = "[ Warning: "
            c = :yellow
        end
        printstyled(s, color=c, bold=true)
        print(str)
    else
        print(s)
        printstyled(str, color=c, bold=true)
    end
end

"""
`isprogram(program::String, dir::String="")::Bool`

Decide if a string is a program via `Sys`.`which`().

# Examples

```
julia> isprogram("julia")
true

julia> isprogram("./julia", "../julia/bin/")
true
```
"""
function isprogram(program::String, dir::String="")::Bool
    flag = true
    
    if '/' in program
        program = normpath(joinpath(dir, program))
    end
    
    if Sys.which(program) == nothing
        flag = false
    end
    
    flag
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
    print("""
        const_path
        average
        findindex
        match_diy
        pkgNames_strFile
        collectrows
        split_undo
        json_pretty
        print_diy
        isprogram
        """)
end

if abspath(PROGRAM_FILE) == UTILITY
    utility()
end
