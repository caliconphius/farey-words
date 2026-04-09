module Monoids

using ..Interfaces:AbstractMonoidElement, AbstractElement
using Base.Iterators, ..UnicodeFun
export MonoidGen, MonoidElement, gens, eachgen, expand!
export gcp, element

const DEFAULT_INT = UInt64

    abstract type AbstractMonoidWord <: AbstractMonoidElement end
    abstract type AbstractMonoidGen <: AbstractMonoidElement end

    struct MonoidGen{T<:Integer}<:AbstractMonoidGen
        id::T
        exp::Int
        MonoidGen{T}(x::Integer; p::Integer=1) where T = new{T}(p==0 ? 0 : T(x), x==0 ? 0 : p)

    end

    MonoidGen(s...; p = 1) = MonoidGen{DEFAULT_INT}(s...; p)

    function MonoidGen(s::AbstractString; p::Integer=1)
        ms = eachmatch(r"([A-Z]|[a-z])(\d*)\s*", s)

        isnothing(ms) && error("Invalid Generator Names $s")
        
        out = map(ms) do c
        x = only(c[1])
        d = c[2]
        id = isuppercase(x) ? Int(x)-0x41 + 1 :
             islowercase(x) ? Int(x)-0x61 + 27 : Int(x)

        id = id + (isempty(d) ? 0 : parse(Int, d)*26*2)

        MonoidGen(DEFAULT_INT(id); p=p)
        end |> Tuple

        length(out)==1 ? only(out) : out
        
    end

    Base.one(g::MonoidGen{T}) where T = MonoidGen{T}(0*g.id)
    Base.:-(g::MonoidGen{T}) where T = MonoidGen{T}(g.id, p=-g.exp)
    Base.inv(g::MonoidGen{T}) where T = MonoidGen{T}(g.id, p=-g.exp)
    Base.isequal(a::MonoidGen{T}, b::MonoidGen{T}) where T = a.id==b.id && (a/b).id==0


    
    mutable struct MonoidElement{T<:Integer}<:AbstractMonoidWord
        word::Vector{MonoidGen{T}}
        last::MonoidGen{T}
        exp::Int
        MonoidElement{T}(x::Vector{S}; exp=1) where {T, S<:AbstractMonoidGen} = 
            isempty(x) ?    MonoidElement{T}([MonoidGen{T}(0)]) : 
                            new{T}([one(x[end]), x[1:end-1]...], x[end], exp)
        # parent::Monoid
    end

    # MonoidElement{S}(x::MonoidGen{T}) where {T, S}  = MonoidElement{S}([x])
    MonoidElement(x...; exp=1)  = MonoidElement{DEFAULT_INT}(x...; exp)

    MonoidElement{S}(x::Vector{T}; exp=1) where {S<:Integer, T<:Number}  = prod(map(MonoidGen, S.(x)))^exp

    MonoidElement{T}(x::MonoidElement{T}; exp=1) where T  = x^exp::MonoidElement{T}
    MonoidElement{T}(x::MonoidGen{S}; exp=1) where {T, S}  = MonoidElement{T}([x^exp])
    Base.one(x::MonoidElement{T}) where T = MonoidElement{T}([one(x.last)])
    Base.length(x::MonoidElement{T}) where T = sum([abs(x.exp) for x in gens(x)])

    Base.copy!(dest::MonoidElement{T}, src::MonoidElement{T}) where T = begin
        dest.word = src.word
        dest.last = src.last
        dest.exp = src.exp
    end
    Base.promote_rule(::Type{MonoidGen{T}}, ::Type{S}) where {T<:Integer, S<:AbstractMonoidWord} = S
    Base.promote_rule(::Type{S}, ::Type{MonoidGen{T}}) where {T<:Integer, S<:AbstractMonoidWord} = S

    Base.promote_rule(::Type{MonoidGen{S}}, ::Type{MonoidGen{T}}) where {T<:Integer, S<:Integer} = MonoidGen{promote_type{T,S}}
    
    function Base.convert(::Type{T}, x::MonoidGen{S}) where {T<:AbstractMonoidWord, S<:Integer}
        T(x)::T
    end

    function Base.:*(a::T, b::S) where {T<:AbstractMonoidElement,S<:AbstractMonoidElement}
        _mul(promote(a,b)...)
    end

    function _mul(a::MonoidGen{T}, b::MonoidGen{T})::Union{MonoidGen, MonoidElement} where T
        
        ((a.id*b.id) == 0 || a.id == b.id) && 
            return MonoidGen(max(a.id, b.id); p = a.exp+b.exp)
        
        MonoidElement([a,b])
    end

    
    Base.inv(x::MonoidElement{T}) where T  = 
        MonoidElement{T}(collect(gens(x, 1)); exp=-x.exp)

    Base.:^(x::MonoidElement{T}, n::Integer) where T = MonoidElement{T}(collect(gens(x, 1)); exp=n*x.exp)

    Base.:^(x::MonoidGen{T}, n::Integer) where T = MonoidGen{T}(x.id; p=n*x.exp)

    Base.:/(x::AbstractElement, y::AbstractElement) = x * inv(y)
    Base.:\(x::AbstractElement, y::AbstractElement) = inv(x) * (y)
    Base.:^(x::AbstractElement, y::AbstractElement) = inv(y) * x * (y)

    function gens(x::MonoidElement)
        p = x.exp
        elem = flatten((x.word[2:end],[ x.last]))
        p > 0 ? cycle(elem, p) : 
                cycle(elem, -p)     |>
                Iterators.reverse   |>
                z -> map(e->-e, z)
    end

    function gens(x::MonoidGen)
        [x]
    end

    function gens(x::MonoidElement, p::Int)
        elem = flatten((x.word[2:end],[ x.last]))
        p > 0 ? cycle(elem, p) : 
                cycle(elem, -p)     |>
                Iterators.reverse   |>
                z -> map(e->-e, z)
    end

    function eachgen(x::MonoidElement)
        flatmap(c->cycle([MonoidGen(c.id; p = sign(c.exp))], abs(c.exp)), gens(x))
    end

    function _mul(a::MonoidElement{T}, b::MonoidElement{T})::MonoidElement{T} where T
        word = MonoidGen{T}[]
        final = one(a.last)
        for (gen) in (flatten((gens(a), gens(b))))
            if final.id == 0 
                final = gen
            elseif (final.id == gen.id )
                final = final * gen
                if final.exp == 0 && !isempty(word)
                    final = pop!(word)
                end

            else
                push!(word, final)
                final = gen
            end
        end
        final.id!=0 && push!(word, final)
        MonoidElement(word)
    end

    function expand!(w::AbstractMonoidElement)
        wexp = one(w) * w
        copy!(w, wexp)
        w
    end


    function genName(c::MonoidGen{T}; upperinv=false) where T
        if c.id == 0 
        "1"
        else
        idnum = c.id % (2 * 26)
        name = 
            idnum in 1:26 ? "$('A' + idnum - 1)" : 
            "$('a' + idnum - 27)"
            
        
        if c.id-idnum != 0 
            name *= "$(UnicodeFun.to_subscript(Int(c.id÷(26*2))))"
        end
        
        if c.exp>0
        "$name$(c.exp==1 ? "" : UnicodeFun.to_superscript(c.exp))"
        else
        upperinv && return "$(uppercase(name))$(c.exp==-1 ? "" : UnicodeFun.to_superscript(-c.exp))"

        "$name$(c.exp==-1 ? UnicodeFun.to_superscript("-") : UnicodeFun.to_superscript(c.exp))"
        end
        end
    end
    

    function Base.show(io::IO,  c::MonoidGen{T}) where T
        print(io, "$(genName(c))")
    end

    function Base.show(io::IO,  x::MonoidElement{T}) where T
        elem = x.exp==1 ? join(["$(genName(c))" for c in gens(x, 1)], ".") : "($(join(["$(genName(c))" for c in gens(x, 1)], ".")))$(UnicodeFun.to_superscript(x.exp))"
        print(io, elem*"")
    end

    function prettyrepr(x::MonoidElement{T}) where T
        elem = x.exp==1 ? join(["$(genName(c; upperinv=true))" for c in gens(x, 1)], ".") : "($(join(["$(genName(c; upperinv=true))" for c in gens(x, 1)], ".")))$(UnicodeFun.to_superscript(x.exp))"
        elem
    end


    function Base.getindex(x::MonoidElement{T}, i::Integer) where T
        i <= length(x) || error("BoundsError: index $i out of bounds for word of length [$(length(x))]")
        first(drop(eachgen(x), i-1))
    end



    function Base.getindex(x::MonoidElement{T}, idxs::AbstractUnitRange) where T
        i = idxs.start
        j = idxs.stop
        # max(i,j) <= length(x) || error("BoundsError: index $(max(i,j)) out of bounds for word of length [$(length(x))]")

        zip(idxs, drop(eachgen(x), i-1)) |> z->mapreduce(last, *, z, init=one(x))
    end

    function Base.lastindex(x::MonoidElement)
        length(x)
    end

    function gcp(a::S, b::T) where {S, T<:AbstractElement}
        gcp(promote(a,b)...)
    end


    function gcp(a::MonoidGen{T}, b::MonoidGen{T}) where T
        a.id!=b.id && (a.exp*b.exp < 0) ? one(a) :
        MonoidGen{T}(a.id; p = sign(a.exp)*min(abs.((a.exp, b.exp))...))
    end

    function gcp(a::MonoidElement{T}, b::MonoidElement{T}) where T
        itr = Iterators.Stateful(zip(gens(a), gens(b)))

        elems = ([first(c) for c in takewhile(c->isequal(c...), itr)])
        Iterators.reset!(itr)
        nxt = first(dropwhile(c->isequal(c...), itr))
        isnothing(nxt) && return MonoidElement(elems)
        
        MonoidElement(elems) * gcp(nxt...)    
    end

    function element(s::AbstractString)::MonoidElement{DEFAULT_INT}
        ms = eachmatch(r"(?<gen>[A-Z]|[a-z]\d*)(?:[\s\^](?<power>-?\d*))?[\s\*]*", s)
        
        matches = map(ms) do m
            exp =  m[:power]
            pow = isnothing(exp) || isempty(exp) ? 1 : parse(Int, exp)
            MonoidGen(m[:gen]; p=pow)
        end

        prod(matches)

    end


    # Base.eltype(::Type{MonoidElement{S}}) where S<:Integer  = S
    # Base.length(c::ContinuedFraction) = c.length
    # Base.iterate(c::ContinuedFraction) = c.leading, 1

    # function Base.iterate(c::ContinuedFraction, state::Int)
    #     return state < c.length ? (c.L[state],state+1) : nothing
    # end

    # Base.IteratorSize(::Type{ContinuedFraction{S}}) where S<:Integer= Base.HasLength()
    # Base.firstindex(c::ContinuedFraction) = 1    
    # Base.lastindex(c::ContinuedFraction) = c.length

end