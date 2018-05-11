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
    macros = []
    findhead(x -> push!(macros, x.args[1]), ex, :macrocall)
    @capture(firsthead(ex, :type).args[2], mixname_{mixtypes__} | mixname_ )
    mixfields = firsthead(ex, :block).args

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
    firsthead(ex, :curly) do x
        x.args = vcat(x.args[1], mergetypes(x.args[2:end], mixtypes, prepend))
    end
    firsthead(ex, :block) do x
        x.args = vcat(x.args[1], mergefields(x.args[2:end], mixfields, prepend))
    end
    for mac in reverse(macros)
        ex = Expr(:macrocall, mac, ex)
    end
    esc(ex)
end

function findhead(f, ex, sym) 
    found = false
    if :head in fieldnames(ex)
        if ex.head == sym
            f(ex)
            found = true
        end
        found |= any(findhead.(f, ex.args, sym))
    end
    return found
end

firsthead(ex, sym) = firsthead(x->x, ex, sym) 
function firsthead(f, ex, sym) 
    if :head in fieldnames(ex)
        if ex.head == sym 
            return f(ex)
        else
            for arg in ex.args
                x = firsthead(f, arg, sym)
                x == nothing || return x
            end
        end
    end
    return nothing
end

mergetypes(f1, f2, prepend) = prepend ? union(f2, f1) : union(f1, f2)
mergefields(t1, t2, prepend) = prepend ? vcat(t2, t1) : vcat(t1, t2) 

end # module
