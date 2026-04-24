using Farey
using Farey: AbstractElement, AbstractMonoidElement, AbstractHom
# using Farey.Monoids:AbstractFreeGen,AbstractMonoidWord, gens, MonoidWord, id
export MonoidHom

struct MonoidHom{K,V} <: AbstractHom
  map::Dict{K,V}
  strict::Bool
  MonoidHom{K,V}(map::Dict{K,V}; strict=false) where {K<:Integer,V<:AbstractMonoidElement} = new{K,V}(map, strict)
end



function MonoidHom(map::Vector{Pair{T,S}}; strict=false) where {T,S}

  map_d = Dict([Int(first(p)) => last(p) for p in map])
  MonoidHom{Int,S}(map_d; strict=strict)
end

function (ϕ::MonoidHom{K,V})(x::T) where {K,V,T<:AbstractMonoidWord}
  prod([ϕ(g) for g in gens(x)], init=one(x))
end

function (ϕ::MonoidHom{K,V})(g::T) where {K,V,T<:AbstractFreeGen}
  g.id == 0 && return one(g)
  haskey(ϕ.map, K(g.id)) || return (ϕ.strict ? error("Homomorphism defined to be strict; $g ∉ domain of homomorphism") : (g))
  ϕg = (get(ϕ.map, K(g.id), g)^(g.exp))
  g.inv ? -(ϕg) : ϕg

end


function (ϕ::MonoidHom{K,V})(g::T) where {K,V,T<:AbstractCyclicGen}
  (ϕ.strict) &&
    return error("Strict homomorphisms error on generators of finite order ($g with order $(g.order))")
  ID = Monoids.id(g)
  ID == 0 && return one(g)

  haskey(ϕ.map, K(ID)) || return g


  ϕg = (get(ϕ.map, K(ID), g))
  g.exp < 0 ? inv(ϕg)^abs(g.exp) : ϕg^abs(g.exp)

end

function Base.show(io::IO, ϕ::MonoidHom{K,V}) where {K,V}


  prs = sort(pairs(ϕ.map), by=x -> first(x))
  repr_string = isempty(ϕ.map) ? "(id)" : join(["|\t$(Monoids.genName(Monoids.FreeGen(x); id=false)) -→  $(y)" for (x, y) in prs], "\n")
  print(io, """
: Mn ---→ Mn
""" * """
  $repr_string
  (Group Homomorphism)
      """)
end


Base.promote_rule(::Type{MonoidHom{K1,S}}, ::Type{MonoidHom{K2,T}}) where {K1,K2,T,S} = MonoidHom{promote_type(K1, K2),promote_type(T, S)}

function Base.convert(::Type{MonoidHom{K,T}}, x::S) where {K,T,S<:AbstractHom}
  MonoidHom{K,T}(convert(Dict{K,T}, x.map); strict=x.strict)
end

Base.:*(h1::T, h2::S) where {T<:AbstractHom,S<:AbstractHom} = *(promote(h1, h2)...)

function Base.:*(h1::MonoidHom{K,V}, h2::MonoidHom{K,V}) where {K,V}


  comp_dict = merge(pairs(h1.map), Dict([x => h1(y) for (x, y) in pairs(h2.map)]))
  MonoidHom{K,V}(comp_dict)
end

function Base.:|(h1::S, h2::T) where {S<:AbstractHom,T<:AbstractHom}
  h2 * h1
end

function Base.:|(x::AbstractElement, h2::T) where {T<:AbstractHom}

  h2(x)
end

function Base.:^(h::MonoidHom{K,V}, n::Integer) where {K,V}

  Base.power_by_squaring(h, n)::MonoidHom{K,V}
end
