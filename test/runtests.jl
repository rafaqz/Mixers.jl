using Revise
using Mixers
using Base.Test
using MacroTools
using Parameters
using Unitful

# @premix macro

@premix struct Premixdrinks{M,B}
   milkshake::M
   beer::B
end

@Premixdrinks mutable struct Drinks{J}
   juice::J
end

d = Drinks(1.9, 13, 7)
@test fieldnames(d) == [:milkshake, :beer, :juice]
@test d.milkshake == 1.9

# Redeclaring doesn't error:
@Premixdrinks mutable struct Drinks{J}
   juice::J
end

# @mix macro

@mix struct Fruits{P,B}
   pommegranite::P
   banana::B
end

# Can also use with a parent type <: Food
abstract type Food end
@Fruits struct GoodFood{B,Pu} <: Food
    beans::B
    pudding::Pu
end
@test fieldnames(GoodFood) == [:beans, :pudding, :pommegranite, :banana]

# Type parameters work as expected
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

# Empty things stay empty
@Nofruits immutable NoFood end 
@test fieldnames(NoFood) == []

# Empty things with {} can have type parameters added
abstract type AbstractPunch end
@Fruits type Punch{} <: AbstractPunch end
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
@test Beverage <: AbstractBeverage


# macro composition
@mix @with_kw struct Softdrinks
    cola::Float64 = 1.5u"L"
    lemonade::Float64 = 2.0u"L"
end

# @with_kw works with no local macro
@Softdrinks struct Fridge end

# @with_kw is merged with local macro
@Softdrinks @with_kw struct Esky 
    beer::Int = 6u"L"
end

@Softdrinks @mix struct AllDrinks
    juice::Int = 6u"L"
end

# mix chaining and @with_kw macro chaining
@AllDrinks struct Icebox
    ice::Int = 100 
end

# mix chaining and @with_kw macro chaining
@AllDrinks struct Icebox
    ice::Int = 100 
end

@AllDrinks struct Icebox
    ice::Int = 5u"kg" 
end


# @pour
@pour hello begin
    "Hello world"
end
function sayhi()
   @hello
end
@test sayhi() == "Hello world"                                                                      
