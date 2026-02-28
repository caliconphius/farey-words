const DEFAULT_INT = Int

struct ContinuedFraction{T}<:Number where T<:Integer 
    leading::T
    L::Vector{T}
    length::Int
    function ContinuedFraction(first::S, L::Vector{T}) where {S<:Integer, T<:Integer}
        isempty(L) && return new{DEFAULT_INT}(DEFAULT_INT(first), DEFAULT_INT[], 2)
        L[1] == 0 && return new{DEFAULT_INT}(DEFAULT_INT(first), DEFAULT_INT[0], 2)
        last(L) == 1 && begin
            if length(L) == 1
                first+=1
                L = []
            else
                L[end-1] += 1
                L = L[1:end-1]
            end
        end

        new{DEFAULT_INT}(DEFAULT_INT(first), DEFAULT_INT.(L), length(L)+1)
    end
end
const QNumber = Union{Real, ContinuedFraction}

Base.keys(c::ContinuedFraction) = LinearIndices(1:c.length)
Base.getindex(c::ContinuedFraction, i::Integer) = i==1 ? c.leading : c.L[i-1]
Base.getindex(c::ContinuedFraction, I) = [c[i] for i in I]
Base.one(c::ContinuedFraction) = ContinuedFraction(1)
Base.isinteger(c::ContinuedFraction) = isempty(c.L)
    # Q = Rational(Q)

function positive_form(c::ContinuedFraction)
    Rational(c) |> ContinuedFraction
end


function ContinuedFraction(Q::Rational)
    Q==1//0 && return ContinuedFraction(1, [0])
    Q==-1//0 && return ContinuedFraction(-1, [0])
    leading = DEFAULT_INT(Q - Q%1)
    Q = Q%1
    L = DEFAULT_INT[]
    while Q!=0//1
        l0 = (1÷Q)
        push!(L, l0)
        Q = 1/Q - l0
    end
    ContinuedFraction(leading, L)

end

macro cf0(expr)

    :(ContinuedFraction((0) , $expr)|>positive_form)    
end

macro cf(sym::Union{Symbol, Number})
    :(ContinuedFraction($(esc(sym)))|>positive_form)
end

macro cf(expr::Base.Expr)
    expr.head==:vect && return :(ContinuedFraction($expr[1], $expr[2:end])|>positive_form)
    :(ContinuedFraction($(esc(expr)))|>positive_form)
end

# macro cf(sym, expr)
#     :(ContinuedFraction(($sym),$expr))
# end


function ContinuedFraction(Q::T) where T<:Real 
    typeof(Q)<:AbstractFloat && @warn "Converting "*(ITR.take("$(Q)",8)|>join)*"... of type $(typeof(Q)) to a rational, results may suffer from floating point errors. Write p//q for exact division"
    ContinuedFraction(Rational(Q))
end

Base.eltype(::Type{ContinuedFraction{S}}) where S<:Integer  = S
Base.length(c::ContinuedFraction) = c.length
Base.iterate(c::ContinuedFraction) = c.leading, 1

function Base.iterate(c::ContinuedFraction, state::Int)
    return state < c.length ? (c.L[state],state+1) : nothing
end

Base.IteratorSize(::Type{ContinuedFraction{S}}) where S<:Integer= Base.HasLength()
Base.firstindex(c::ContinuedFraction) = 1    
Base.lastindex(c::ContinuedFraction) = c.length

Base.Rational(x::ContinuedFraction{T}) where T<:Integer = Base.convert(Rational{T}, x)
Base.convert(::Type{T}, x::ContinuedFraction{S}) where {T<:Real, S<:Integer} = T(_rational(x))::T


function _rational(x::ContinuedFraction)
    (isempty(x.L)) && return x.leading//1
    (x.L[1]==0) && return x.leading//0
    reduce(x|>collect|>reverse) do q,l
        l + 1//q
    end 
end


function Base.show(io::IO, c::ContinuedFraction{T}) where T<: Integer
    listvals = isinteger(c) ? "]" : split("$(c[2:end])", "[")[end]
    repr = "[$(c.leading); "*listvals*" = $(Rational(c))"
    return print(io, repr)
end

Base.promote_rule(::Type{Rational{T}}, ::Type{ContinuedFraction{S}}) where {T<:Integer, S<:Integer} = Rational{promote_type(T,S)}
Base.promote_rule(::Type{T}, ::Type{ContinuedFraction{S}}) where {T<:Integer, S<:Integer} = Rational{promote_type(T,S)}
Base.promote_rule(::Type{ContinuedFraction{T}}, ::Type{S}) where {T<:Integer, S<:AbstractFloat} = Base.promote_type(Rational{T},S)


binary_ops = (:+, :-, :*, :/, :\)
binary_ops_nc = (:isequal, :isless, :^)
unary_ops = (:-, :abs, :inv)
unary_ops_nc =  (:numerator, :denominator)
let C=ContinuedFraction, Q=Rational

function Base.:^(c::C, n::Real)
    Q(c)^Q(n)
end

for op in binary_ops
    @eval Base.$op(c::$C, d::$C) = $C(Base.$op(c|>$Q, d|>$Q))::$C
end

for op in binary_ops_nc
    @eval Base.$op(c::$C, d::T) where T<:Number = Base.$op(c|>$Q, d|>$Q)
    @eval Base.$op(d::T,c::$C) where T<:Number = Base.$op(d|>$Q, c|>$Q)

end

for op in unary_ops
    @eval Base.$op(c::$C) = $C(Base.$op(c|>$Q))::$C
end

for op in unary_ops_nc
    @eval Base.$op(c::$C) = (Base.$op(c|>$Q))
end


end


function ⊕(p::Number, q::Number)
    (r, s, t, u) = ITR.flatmap(sort(Rational[p, q], rev=true)) do x
        [x.num, x.den]
    end |> collect
    

    abs(r * u - s * t) == 1 || error("$p and $q are not farey neighbours")

    return (r+t)//(s+u) |> ContinuedFraction
end

function ⊖(p::Number, q::Number)
    (r, s, t, u) = ITR.flatmap(sort(Rational[p, q], rev=true)) do x
        [x.num, x.den]
    end |> collect
    
    abs(r * u - s * t) == 1 || error("$p and $q are not farey neighbours")

    return (r-t)//(s-u) |> ContinuedFraction
end

function farey_neighbours(p::Number)
    p = ContinuedFraction(p)
    q1 = ContinuedFraction(p.leading, p[2:end-1])
    q2 = ContinuedFraction(p.leading, [p[2:end-1]..., p[end]-1])
    q1, q2, q1⊖ q2
end