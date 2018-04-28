# Mixers

[![Build Status](https://travis-ci.org/rafaqz/Mixers.jl.svg?branch=master)](https://travis-ci.org/rafaqz/Mixers.jl)
[![Coverage Status](https://coveralls.io/repos/rafaqz/Mixers.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/rafaqz/Mixers.jl?branch=master)
<img src="https://www.giraffescanbake.com/wp-content/uploads/2016/12/Pomegranate-Martini3.gif" data-canonical-src="https://www.giraffescanbake.com/wp-content/uploads/2016/12/Pomegranate-Martini3.gif" width="150" height="210" />

Mixer provides mixin macros, for writing, well, "DRY" code.

The @mix and @premix macros generate custom macros that can add fields to any
composite struct, preserving parametric types. They can be chained togeth, and
even play well with @with_kw from Parameters.jl. 

```juliarepl
@mix drinks{M,B} begin
     milkshake::M
     beer::B
end

@drinks struct Drinks{J}
    cola::J
end

julia> d = Drinks(1.9, 13, 7)
                  
Drinks{Float64,Int64,Int64}(1.9, 13, 7)                

julia> fieldnames(d)

3-element Array{Symbol,1}:
 :cola    
 :milkshake
 :beer     
```

@premix inserts fields and types at the start of the definition:

```juliarepl
@premix fruitjuice{P,B} begin
   pommegranite::P
   orange::B
end

@fruitjuice struct Punch{L}
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

@pour generates simple macros that insert lines of code:

```julia
@pour milk begin
    "Yum"
end

taste() = @milk

julia> taste()                                                                      
"Yum"
```
