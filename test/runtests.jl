using Mixers
using Base.Test

@premix premixdrinks{M,B} begin
   milkshake::M
   beer::B
end
@premixdrinks mutable struct Drinks{J}
   juice::J
end
d = Drinks(1.9, 13, 7)
@test fieldnames(d) == [:milkshake, :beer, :juice]
d.milkshake = 5.5

# Redeclaring doesn't error:
@premixdrinks mutable struct Drinks{J}
   juice::J
end

@mix addfruits{P,B} begin
   pommegranite::P
   banana::B
end

abstract type Food end
@addfruits struct GoodFood{B,Pu} <: Food
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

@mix nofruits begin end
@nofruits type BadFood{W,Pu} <: Food
    weetbix::W
    pumpkin::Pu
end

bf = BadFood(0, -1000.0)
@test fieldnames(bf) == [:weetbix, :pumpkin]
@nofruits immutable NoFood end 
@test fieldnames(NoFood) == []

abstract type AbstractPunch end
@addfruits type Punch{} <: AbstractPunch end
@test fieldnames(Punch(1,2)) == [:pommegranite, :banana]


@pour hello begin
    "Hello world"
end
function sayhi()
   @hello
end
@test sayhi() == "Hello world"                                                                      

abstract type AbstractBeverage{G} end
abstract type AbstractGlass end
type Lowball <: AbstractGlass end
@premix liquid{L} begin
    liquid::L
end
@liquid mutable struct Beverage{S,G<:AbstractGlass} <: AbstractBeverage{G<:AbstractGlass}
    salt::S
    glass::G
end
@test fieldnames(Beverage(250.0,2.0,Lowball())) == [:liquid, :salt, :glass]
