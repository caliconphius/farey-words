module modhoms
using Farey
using Farey:AbstractElement, AbstractMonoidElement, AbstractHom
using Farey.Monoids:AbstractMonoidGen,AbstractMonoidWord, gens, MonoidWord
export MonoidHom

struct MonoidHom{K,V} <: AbstractHom
    map::Dict{K, V}
    strict::Bool
    MonoidHom(map::Dict{K,V}; strict=false) where {K<:Integer,V<:AbstractMonoidElement} = new{K,V}(map, strict)
end



function MonoidHom(map::Vector{Pair{T,S}}; strict=false) where {T,S<:AbstractMonoidElement}
    
    map_d = Dict([UInt(first(p))=>last(p) for p in map])
    MonoidHom(map_d; strict=strict)
end

function (ϕ::MonoidHom{K,V})(x::T) where {K,V,T<:AbstractMonoidWord}
    prod([ϕ(g) for g in gens(x)], init=one(x))
end

function (ϕ::MonoidHom{K, V})(g::T) where {K,V,T<:AbstractMonoidGen}
    g.id==0 && return one(g)
    haskey(ϕ.map, K(g.id)) || return (ϕ.strict ? error("Homomorphism defined to be strict; $g ∉ domain of homomorphism") : (g))
    (get(ϕ.map, K(g.id), g)^g.exp)
end


function Base.show(io::IO, ϕ::MonoidHom{K,V}) where {K,V} 
    

    prs = sort(pairs(ϕ.map),  by=x->first(x))
    repr_string = isempty(ϕ.map) ? "(id)" : join(["|\t$(Monoids.genName(Monoids.MonoidGen(x); id=false)) -→  $(y)" for (x,y) in prs], "\n")
    print(io,"""
   : Mn ---→ Mn
   """*"""
   $repr_string
   (Group Homomorphism)
    """)
end

function Base.:*(h1::T, h2::S) where {T<:AbstractHom,S<:AbstractHom}
    
    
    comp_dict = merge(pairs(h1.map), Dict([x=>h1(y) for (x,y) in pairs(h2.map)]))
    MonoidHom(comp_dict)
end

function Base.:|(h1::MonoidHom, h2::MonoidHom) 
    
    h2*h1
end

function Base.:|(x::AbstractElement, h2::MonoidHom) 
    
    h2(x)
end

function Base.:^(h::MonoidHom, n::Integer) 
    
    Base.power_by_squaring(h, n)
end

end
