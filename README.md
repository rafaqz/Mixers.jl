# Mixers

<img src="https://www.giraffescanbake.com/wp-content/uploads/2016/12/Pomegranate-Martini3.gif" data-canonical-src="https://www.giraffescanbake.com/wp-content/uploads/2016/12/Pomegranate-Martini3.gif" width="300" height="420" />

[![Build Status](https://travis-ci.org/rafaqz/Mixers.jl.svg?branch=master)](https://travis-ci.org/rafaqz/Mixers.jl)
[![Coverage Status](https://coveralls.io/repos/rafaqz/Mixers.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/rafaqz/Mixers.jl?branch=master)
[![codecov.io](http://codecov.io/github/rafaqz/Mixers.jl/coverage.svg?branch=master)](http://codecov.io/github/rafaqz/Mixers.jl?branch=master)

Mixers.jl provides mixin macros, for writing, well, "DRY" code. 

Mixers useful when types share a subset of fields but have no common concrete type, or adding one would add unnecessary, annoying nesting. Generally it shouldn't be a replacement for regular composition!

The @mix and @premix macros generate custom macros that can add fields to any
struct, preserving parametric types and macros such as @with_kw from
Parameters.jl. @mix and @premix macros can also be applied to @mix macros, allowing 
a kind of mixin inheritance.

@premix inserts fields and types at the start of the definition:

```juliarepl
@premix struct Fruitjuice{P,B}
    pommegranite::P
    orange::B
end

@Fruitjuice struct Punch{L}
    vodka::L
end

julia> fieldnames(Punch)

3-element Array{Symbol,1}:
 :pommegranite
 :orange      
 :vodka       

julia> punch = Punch(20, 150, 2.5)
               
Punch{Int64,Int64,Float64}(20, 15, 12.5) 
```

@mix puts them at the end:

```juliarepl
using Parameters
using Unitful

@mix @with_kw struct Soda{J}
    soda::J = 2u"L"
end

@Soda struct Drink{M,B}
    lemon::M = 0.4u"kg"
    lime::B = 0.2u"kg"
end

julia> fieldnames(Drinks)

3-element Array{Symbol,1}:
 :lemon
 :lime     
 :soda    
```

Notice how we added that @with_kw to Soda but left it off Drinks? Inheritable
macro chains are a thing!

The only thing @mix does *not* preserve is parent abstract types, like 
`@mix struct Lemonade <: AbstractDrink`. These can't really be mixed in as types 
can only have one parent, so we keep thing simple and add type inheritance on the actual 
struct. If there is anything else @mix ignores that it shouldn't, open an issue.

One gotcha is the need to put empty curly braces on a struct with no
parametric fields, if it is going to have parametric fields after @mix or
@premix. This keeps Mixers.jl code simple, and is a clear visual reminder 
that the struct is actually parametrically typed:

```julia
@Fruitjuice struct Juice{} end
```

Lastly, @pour is a basic version of @mix. It generates simple macros that insert lines of code. 
It doesn't have to be used with structs:

```julia
@pour milk begin
    "Yum"
end

taste() = @milk

julia> taste()                                                                      
"Yum"
```
