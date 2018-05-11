using Revise
using Mixers
using Base.Test
using MacroTools
using Parameters

# @premix

@premix struct Premixdrinks{M,B}
   milkshake::M
   beer::B
end

@Premixdrinks mutable struct Drinks{J}
   juice::J
end

d = Drinks(1.9, 13, 7)
@test fieldnames(d) == [:milkshake, :beer, :juice]
d.milkshake = 5.5

# Redeclaring doesn't error:
@Premixdrinks mutable struct Drinks{J}
   juice::J
end

# @mix

@mix struct Addfruits{P,B}
   pommegranite::P
   banana::B
end

abstract type Food end
@Addfruits struct GoodFood{B,Pu} <: Food
    beans::B
    pudding::Pu
end
@test fieldnames(GoodFood) == [:beans, :pudding, :pommegranite, :banana]

@test_throws MethodError GoodFood(:none, 1.5, 2, "lots") 
gf = GoodFood(:none, 1.5, 2, :lots)
@test gf.pommegranite == 2
@test gf.banana == :lots
@test gf.beans == :none
@test gf.pudding == 1.5

@mix struct Nofruits end
@Nofruits type BadFood{W,Pu} <: Food
    weetbix::W
    pumpkin::Pu
end

bf = BadFood(0, -1000.0)
@test fieldnames(bf) == [:weetbix, :pumpkin]
@Nofruits immutable NoFood end 
@test fieldnames(NoFood) == []

abstract type AbstractPunch end
@Addfruits type Punch{} <: AbstractPunch end
@test fieldnames(Punch(1,2)) == [:pommegranite, :banana]
    

# Inheritance

abstract type AbstractBeverage{G} end
abstract type AbstractGlass end
type Lowball <: AbstractGlass end
@premix struct Liquid{L}
    liquid::L
end
@Liquid mutable struct Beverage{S,G<:AbstractGlass} <: AbstractBeverage{G<:AbstractGlass}
    salt::S
    glass::G
end
@test fieldnames(Beverage(250.0,2.0,Lowball())) == [:liquid, :salt, :glass]

# macro composition

@mix @with_kw struct Softdrinks
    cola::Float64 = 1.5
    lemonade::Float64 = 2.0
end

@Softdrinks struct Fridge end
@Softdrinks struct Esky 
    beer::Int = 6
end

# @pour

@pour hello begin
    "Hello world"
end
function sayhi()
   @hello
end
@test sayhi() == "Hello world"                                                                      


abstract type AbstractJarvisTemp end

@mix @with_kw struct JT{T}
    tmax::T = 1
    tref::T = 2
    t0::T  = 2
end

struct JarvisNoTemp <: AbstractJarvisTemp end
@JT mutable struct JarvisTemp1{} <: AbstractJarvisTemp end
@JT mutable struct JarvisTemp2{} <: AbstractJarvisTemp end

abstract type AbstractJarvisTemp end

@mix struct JT{T}
    tmax::T = 1.0u"°C"
    tref::T = 1.0u"°C"
    t0::T = 1.0u"°C"
end

struct JarvisNoTemp <: AbstractJarvisTemp end
@JT mutable struct JarvisTemp1{} <: AbstractJarvisTemp end
@JT mutable struct JarvisTemp2{} <: AbstractJarvisTemp end
