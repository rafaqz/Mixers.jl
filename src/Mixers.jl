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
macro mix(name, block)
    define(name, block, false)
end

"""
Just like @mix but generated macro insert fields and types 
at the *start* of the definition.
"""
macro premix(name, block)
    define(name, block, true)
end

function define(def, block, prepend)
    @capture(def, mixname_{mixtypes__} | mixname_)
    @capture(block, begin mixfields__ end)
    mixtypes = mixtypes == nothing ? [] : esc(mixtypes)
    mixfields = mixfields == nothing ? [] : esc(mixfields)
    return quote
        macro $(esc(mixname))(ex)
            prepend = $prepend
            mixfields = $mixfields
            mixtypes = $mixtypes
            return mixed(ex, mixtypes, mixfields, prepend)
        end
    end
end

function mixed(ex, mixtypes, mixfields, prepend)

    matchhead(ex, :curly) do x
        x.args = vcat(x.args[1], mergetypes(x.args[2:end], mixtypes, prepend))
    end
    matchhead(ex, :block) do x
        x.args = vcat(x.args[1], mergefields(x.args[2:end], mixfields, prepend))
    end

    esc(ex)
end

function matchhead(f, ex, sym) 
    if :head in fieldnames(ex)
        ex.head == sym && f(ex)
        matchhead.(f, ex.args, sym) 
    end
end

mergetypes(f1, f2, prepend) = prepend ? union(f2, f1) : union(f1, f2)
mergefields(t1, t2, prepend) = prepend ? vcat(t2, t1) : vcat(t1, t2) 

end # module
