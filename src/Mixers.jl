module Mixers

using MacroTools

export @mix, @premix, @pour, @stack

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
    macros = chained_macros(ex)

    # get name and parametric types
    @capture(firsthead(ex, :struct).args[2], mixname_{mixtypes__} | mixname_ )
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

    localmacros = chained_macros(ex)

    # get struct without macros
    firsthead(x -> ex = x, ex, :struct)

    # wrap local and mixed macros around the struct
    for mac in reverse(union(localmacros, macros))
        ex = Expr(:macrocall, mac, LineNumberNode(79, "Mixers.jl"), ex)
    end
    esc(ex)
end


chained_macros(ex) = chained_macros!(Symbol[], ex) 
chained_macros!(macros, ex) = macros
chained_macros!(macros, ex::Expr) = begin
    if ex.head == :macrocall
        push!(macros, ex.args[1])
        length(ex.args) > 2 && chained_macros!(macros, ex.args[3])
    end
    macros
end

firsthead(ex, match) = firsthead(x->x, ex, match)
firsthead(f, ex::Expr, match) = 
    if ex.head == match
        return f(ex)
    else
        for arg in ex.args
            x = firsthead(f, arg, match)
            x == nothing || return x
        end
        return nothing
    end
firsthead(f, ex, match) = nothing

mergetypes(t1, t2, prepend) = prepend ? union(t2, t1) : union(t1, t2)
mergefields(f1, f2, prepend) = prepend ? vcat(f2, f1) : vcat(f1, f2)


"""
Stack the fields of multiple structs and create a new one.
The first argument is the name of the new struct followed by the
ones to be stacked. Parametric types are not supported and
the fieldnames needs to be unique.
"""
macro stack(into, structs...)
    fields = []
    for _struct in structs
        names = fieldnames(getfield(__module__, _struct))
        types = fieldtypes(getfield(__module__, _struct))
        for (n, t) in zip(names, types)
            push!(fields, :($n::$t))
        end
    end

    esc(
        quote
            struct $into
                $(fields...)
            end
        end
    )
end

end # module
