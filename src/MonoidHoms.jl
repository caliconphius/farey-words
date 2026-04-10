module modhoms
using Farey
using Farey:AbstractElement
using Farey.Monoids:AbstractMonoidGen,AbstractMonoidWord
export MonoidHom
struct MonoidHom{K<: Integer, V<: AbstractElement} 
    map::Dict{K, V}
    strict::Bool
    MonoidHom(map::Dict{K,V}; strict=false) where {K,V} = new{K,V}(map, strict)
end

function MonoidHom(map::Vector{T}; strict=false) where T
    MonoidHom(Dict([UInt(first(p))=>last(p) for p in map]); strict=strict)
end

function (ϕ::MonoidHom)(x::AbstractMonoidWord)
    prod([ϕ(g) for g in Farey.Monoids.gens(x)], init=one(x))
end

function (ϕ::MonoidHom{K, V})(g::AbstractMonoidGen) where {K,V}
    
    haskey(ϕ.map, K(g.id)) || return (ϕ.strict ? error("Homomorphism defined to be strict; $g ∉ domain of homomorphism") : g)
    get(ϕ.map, K(g.id), one(g))^g.exp
end


function Base.show(io::IO, ϕ::MonoidHom{K,V}) where {K,V}
    

    
    repr_string = join(["|\t$(Monoids.genName(Monoids.MonoidGen(x); id=false)) -→  $(y)" for (x,y) in pairs(ϕ.map)], "\n")
    print(io,"""
   : Mn ---→ Mn
   """*"""
   $repr_string
   (Group Homomorphism)
    """)
end

function Base.:*(h1::MonoidHom, h2::MonoidHom)

    comp_dict = merge(pairs(h1.map), Dict([x=>h1(y) for (x,y) in pairs(h2.map)]))

    MonoidHom(comp_dict)
end

function Base.:|(h1::MonoidHom, h2::MonoidHom)
    h2*h1
end

function Base.:^(h::MonoidHom, n::Integer)
    Base.power_by_squaring(h, n)
end

end
