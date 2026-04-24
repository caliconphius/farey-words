
export CyclicGen
struct CyclicGen{S<:AbstractFreeGen}<:AbstractCyclicGen
    gen::S
    exp::Int
    order::Int
    function CyclicGen{S}(x::S1; p::S2=1, inv::Bool = false, order::S3=0) where
        {S, S1<:Integer, S2<:Integer, S3<:Integer}
        order == 1 && error("Order must either be 0 (for infinite order) or ≥2)")
        p = inv ? -p : p
        exp = order==0 ? p : mod(p, order)

        (exp==0 || x==0) && return new{S}(S(0), 0, 0)


        new{S}(S(x; p=exp), exp, order)


    end


end
CyclicGen(x...; order=0) = CyclicGen{FreeGen{DEFAULT_INT}}(x...; order)

CyclicGen{T}(s::S; p::Integer=1, inv=false, order=0) where {T, S<:AbstractString} = T(s; p=p, inv=inv, cyclic=true) |> (g->length(g)==1 ? CyclicGen{T}(only(g); order=order) : CyclicGen{T}.(g; order=order))

CyclicGen{S}(x::T; order = 0) where {S<:AbstractFreeGen,T<:AbstractFreeGen} = CyclicGen{S}(x.id; p= x.exp, inv=x.inv, order=order)
CyclicGen{S}(x::T) where {S<:AbstractFreeGen,T<:AbstractCyclicGen} = x::T
Base.one(x::T) where T<: AbstractCyclicGen = T(0)

function genName(c::T; id=false) where T<:AbstractCyclicGen
    name  = "$(genName(c.gen))"
    id || return name
    # c.order == 0 ? name : "$name$(c.order==0 ? "" : "$(to_subscript("($(c.order))"))")"
    name
end


Base.promote_rule(::Type{T}, ::Type{CyclicGen{S}}) where {T<:AbstractFreeGen, S<:AbstractFreeGen} = CyclicGen{promote_type(T,S)}

function Base.convert(::Type{CyclicGen{T}}, x::S)::CyclicGen{T} where {T<:AbstractFreeGen, S<:AbstractFreeGen}
    g = CyclicGen{T}(x)
end


Base.inv(g::T) where T<:AbstractCyclicGen = T(id(g);p = g.order-g.exp, order = g.order)
Base.isequal(g::T, h::T) where T<:AbstractCyclicGen = isequal(g.gen,h.gen) && g.order==h.order && g.exp==h.exp

function _mul(a::T, b::T)::Union{T, AbstractMonoidWord} where T<:AbstractCyclicGen
    ((id(a)*id(b)) == 0) && return T(a.gen*b.gen;order= max(a.order, b.order))

    (id(a) == id(b) &&
     a.order==b.order) &&
        return T(a.gen*b.gen; a.order)

        MonoidWord{T}(T[a,b])
end

function Base.convert(::Type{T}, x::S) where {T<:AbstractMonoidWord, S<:AbstractCyclicGen}
    T(x)
end



Base.:^(x::T, n::Integer) where T <:AbstractCyclicGen= T(id(x); p=abs(n)*x.exp, order=x.order)

function id(g::T) where T<:AbstractFreeGen
    g.id
end

function id(g::T) where T<:AbstractCyclicGen
    g.gen.id
end

function gcp(a::T, b::S) where {T<:AbstractCyclicGen, S<:AbstractCyclicGen}
    (id(a)!==id(b)||a.order!==b.order) ?
        one(a) :
    (a.order==0 && a.exp*b.exp < 0) ?
        one(a) :
        T(id(a); p = min(abs.((a.exp, b.exp))...), inv=false)
end
