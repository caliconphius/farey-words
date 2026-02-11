abstract type  Group end
const GenList = Vector{Symbol}
const Maybe{T} = Union{Nothing, T}


function inverse(g::G<:Group)
    error("inverse not yet implemented")
end


struct FreeGroup<:Group 
    gens::GenList
    invs::GenList
    function FreeGroup(gens::GenList, invs::Maybe{GenList})
        if num == 0 && den == 0
            error("invalid rational: 0//0")
        end
        num = flipsign(num, den)
        den = flipsign(den, den)
        g = gcd(num, den)
        num = div(num, g)
        den = div(den, g)
        new(num, den)
    end
end




struct Gen{G<:Group}
    name::Symbol
    value::Integer
    function Gen{G}(name, F::G)  where {G<:Group}
         name ∉ F.gens ? new(name, 1) : error("symbol outside of group")
    end
end



struct ID end








