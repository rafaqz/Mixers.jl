module Mixers

using MacroTools

export @mix, @premix, @pour

"""
Generates simple macros for inserting any lines anywhere.
"""
macro pour(name, definition)
    return quote
        macro $(esc(name))()
            esc($(Expr(:quote, definition)))
        end
    end
end

"""
Generates a mixin macro that preserve parametric types.
Fields and parametric types are appended to the struct.
Identical parametric types are merged.
"""
macro mix(ex)
    defmacro(ex, false)
end

"""
Just like @mix but generated macro insert fields and types
at the *start* of the definition.
"""
macro premix(ex)
    defmacro(ex, true)
end

function defmacro(ex, prepend)
    # get chained macros
    macros = chain_macros!([], ex)

    # get name and parametric types
    @capture(firsthead(ex, :type).args[2], mixname_{mixtypes__} | mixname_ )
    # get fields
    mixfields = firsthead(ex, :block).args

    # deal with empty values
    if mixtypes == nothing mixtypes = [] end
    if mixfields == nothing mixfields = [] end

    @esc macros mixname mixtypes mixfields
    return quote
        macro $mixname(ex)
            macros = $macros
            mixtypes = $mixtypes
            mixfields = $mixfields
            prepend = $prepend
            return mix(ex, macros, mixtypes, mixfields, prepend)
        end
    end
end

function mix(ex, macros, mixtypes, mixfields, prepend)
    # merge type parameters
    firsthead(ex, :curly) do x
        x.args = vcat(x.args[1], mergetypes(x.args[2:end], mixtypes, prepend))
    end
    # merge fields
    firsthead(ex, :block) do x
        x.args = vcat(x.args[1], mergefields(x.args[2:end], mixfields, prepend))
    end

    localmacros = chain_macros!([], ex)

    # get struct without macros
    firsthead(x -> ex = x, ex, :type)

    # wrap local and mixed macros around the struct
    for mac in reverse(union(localmacros, macros))
        ex = Expr(:macrocall, mac, ex)
    end

    esc(ex)
end

function chain_macros!(macros, ex)
    if :head in fieldnames(ex)
        if ex.head == :macrocall
            push!(macros, ex.args[1])
            chain_macros!(macros, ex.args[2])
        end
    end
    macros
end

firsthead(ex, match) = firsthead(x->x, ex, match)

function firsthead(f, ex, match)
    if :head in fieldnames(ex)
        if ex.head == match
            return f(ex)
        else
            for arg in ex.args
                x = firsthead(f, arg, match)
                x == nothing || return x
            end
        end
    end
    return nothing
end

mergetypes(f1, f2, prepend) = prepend ? union(f2, f1) : union(f1, f2)
mergefields(t1, t2, prepend) = prepend ? vcat(t2, t1) : vcat(t1, t2)

end # module
