using Mixers,
      Test,
      MacroTools,
      Parameters,
      Unitful

# @premix macro

q = quote @premix struct Premixdrinks{M,B}
       milkshake::M
       beer::B
    end
end

Mixers.defmacro(q, true)

@premix struct Premixdrinks{M,B}
   milkshake::M
   beer::B
end

@Premixdrinks mutable struct Drinks{J}
   juice::J
end

@test fieldnames(Drinks) == (:milkshake, :beer, :juice)
d = Drinks(1.9, 13, 7)
@test d.milkshake == 1.9

# Redeclaring doesn't error:
@Premixdrinks mutable struct Drinks{J}
   juice::J
end


# @mix macro
@mix struct Juice{P,S}
   mango::P
   lime::S
end
@mix struct NoJuice end

# Can also use with a parent struct <: Smoothie
abstract type Cocktail end
@Juice struct Daiquiri{S,M} <: Cocktail
    sugar::S
    rum::M
end
@test fieldnames(Daiquiri) == (:sugar, :rum, :mango, :lime)

# Type parameters work as expected
@test_throws MethodError Daiquiri(:none, 1.5, 2, "lots") 
dq = Daiquiri(:none, 1.5, 2, :lots)
@test dq.mango == 2
@test dq.lime == :lots
@test dq.sugar == :none
@test dq.rum == 1.5


# Empty things stay empty
@NoJuice struct Empty end 
@test fieldnames(Empty) == () 


# Empty things with {} can have type parameters added
abstract type AbstractPunch end
@Juice struct Punch{} <: AbstractPunch end
@test fieldnames(Punch) == (:mango, :lime)



# Inheritance
abstract type AbstractBeverage{G} end
abstract type AbstractGlass end
struct Lowball <: AbstractGlass end

@premix struct Liquid{L}
    liquid::L
end
@Liquid mutable struct Beverage{S,G<:AbstractGlass} <: AbstractBeverage{G}
    salt::S
    glass::G
end
@test fieldnames(Beverage) == (:liquid, :salt, :glass)
@test Beverage <: AbstractBeverage



# macro composition
@mix @with_kw struct Softdrinks{C,L}
    cola::C = 1.5u"L"
    lemonade::L = 2.0u"L"
end

# @with_kw works with no local macro
@Softdrinks struct Fridge{} end

fridge = Fridge()
@test fridge.cola == 1.5u"L"
@test fridge.lemonade == 2.0u"L"

# @with_kw is merged with local macro
@Softdrinks @with_kw struct Esky{B} 
    beer::B = 6u"L"
end

esky = Esky()
@test esky.lemonade == 2.0u"L"
@test esky.beer == 6u"L"


# Nested @mix
@Softdrinks @mix struct BagODrinks{J}
    juice::J = 3u"L"
end

@BagODrinks struct Icebox{I}
    ice::I = 5u"kg" 
end

@test fieldnames(Icebox) == (:ice, :juice, :cola, :lemonade)

icebox = Icebox()
@test icebox.cola == 1.5u"L"
@test icebox.lemonade == 2.0u"L"
@test icebox.juice == 3u"L"
@test icebox.ice == 5u"kg"



# @pour
@pour hello begin
    "Hello world"
end
function sayhi()
   @hello
end
@test sayhi() == "Hello world"                                                                      
