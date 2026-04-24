using ..Interfaces: AbstractMonoidElement, AbstractElement
using Base.Iterators, ..UnicodeFun
export FreeGen, FreeWord, MonoidWord, gens, eachgen, expand!, id
export gcp, element

const DEFAULT_INT = UInt64
const SEP = ""

abstract type AbstractMonoidWord <: AbstractMonoidElement end
abstract type AbstractMonoidGen <: AbstractMonoidElement end
abstract type AbstractFreeGen <: AbstractMonoidGen end
abstract type AbstractCyclicGen <: AbstractMonoidGen end

struct FreeGen{T<:Integer} <: AbstractFreeGen
  id::T
  exp::Int
  inv::Bool
  function FreeGen{T}(x::S1; p::S2=1, inv::Bool=false) where {T,S1<:Integer,S2<:Integer}
    (p == 0 || x == 0) && return new{T}(0, 0, false)

    new{T}(T(x), (abs(p)), xor(inv, (p < 0)))
  end

end

FreeGen(s...; p::Integer=1, inv::Bool=false) = FreeGen{DEFAULT_INT}(s...; p, inv)

function _exponent(g::T) where T<:AbstractFreeGen
  g.inv && return -Int(g.exp)
  Int(g.exp)
end
function FreeGen{T}(s::S) where {T,S<:AbstractFreeGen}
  FreeGen{T}(s.id; p=s.exp, inv=s.inv)
end
function FreeGen{T}(s::S; p::Integer=1, inv=false, cyclic=false) where {T,S<:AbstractString}
  ms = eachmatch(r"(?<minus>-?)(?<gen>[A-Z]|[a-z])(?<sub>\d*)\s*", s)

  isnothing(ms) && error("Invalid Generator Names $s")

  out = map(ms) do c
    x = only(c[:gen])
    d = c[:sub]
    sgn = c[:minus]
    id = islowercase(x) ? Int(x) - 0x61 + 1 :
         isuppercase(x) ? Int(x) - 0x41 + 27 : Int(x)

    id += (isempty(d) ? 0 : (parse(Int, d) + 1) * (26 * 2))
    invgen = xor(sgn == "-", inv)


    FreeGen{T}(DEFAULT_INT(id); p=p, inv=invgen)
  end |> Tuple


  !cyclic && length(out) == 1 ? only(out) : out

end

Base.one(g::T) where T<:AbstractMonoidGen = T(0)
Base.one(::Type{T}) where T<:AbstractMonoidGen = T(0)
Base.length(g::T) where T<:AbstractMonoidGen = abs(_exponent(g))
Base.inv(g::T) where T<:AbstractFreeGen = T(g.id; p=-_exponent(g))
Base.:(==)(a::T, b::T) where T<:AbstractMonoidGen = (length(a / b) == 0)



mutable struct MonoidWord{T<:AbstractMonoidGen} <: AbstractMonoidWord
  word::Vector{T}
  last::T
  exp::Int
  MonoidWord{S}(x::Vector{S}; exp=1) where {S<:AbstractMonoidGen} =
    isempty(x) ? new{S}(S[], one(S), 0) :
    new{S}([one(x[end]), x[1:end-1]...], x[end], exp)
  # parent::Monoid
end

# MonoidElement{S}(x::MonoidGen{T}) where {T, S}  = MonoidElement{S}([x])
FreeWord(x...; exp=1) = MonoidWord{FreeGen{DEFAULT_INT}}(x...; exp)

MonoidWord{S}(x::Vector{T}; exp=1) where {S<:AbstractMonoidGen,T<:Integer} = prod(S.(x))^exp

MonoidWord{S}(x::T; exp=1) where {S<:AbstractMonoidGen,T<:Integer} = MonoidWord{S}([x])

MonoidWord{T}(x::MonoidWord{S}; exp=1) where {T,S} = MonoidWord{T}([T(l) for l in gens(x)])
MonoidWord{S}(x::T; exp=1) where {S<:AbstractMonoidGen,T<:AbstractMonoidGen} = MonoidWord{S}(S[x^exp])

Base.eltype(x::MonoidWord{T}) where T = T
Base.one(x::MonoidWord{T}) where T<:AbstractMonoidGen = MonoidWord{T}(T[])
Base.one(::Type{MonoidWord{T}}) where T<:AbstractMonoidGen = MonoidWord{T}(T[])
Base.length(x::MonoidWord{T}) where T = sum([abs(x.exp) for x in gens(x)])
# Base.:(==)()
Base.:(==)(w1::T, w2::T) where T<:AbstractMonoidWord = length(w1) == length(w2) && all(map(x -> x[1] == x[2], zip(gens(w1), gens(w2))))

Base.copy!(dest::MonoidWord{T}, src::MonoidWord{T}) where T = begin
  dest.word = src.word
  dest.last = src.last
  dest.exp = src.exp
end
Base.promote_rule(::Type{FreeGen{S}}, ::Type{FreeGen{T}}) where {T<:Integer,S<:Integer} = FreeGen{promote_type(T, S)}
Base.promote_rule(::Type{MonoidWord{S}}, ::Type{T}) where {T<:AbstractMonoidGen,S<:AbstractMonoidGen} = MonoidWord{promote_type(T, S)}


Base.promote_rule(::Type{MonoidWord{S}}, ::Type{MonoidWord{T}}) where {T,S} = MonoidWord{promote_type(T, S)}

# function Base.convert(::Type{MonoidWord{T}}, x::S) where {T, S<:AbstractFreeGen}
#     MonoidWord{T}([x])::MonoidWord{T}

#     # x.inv ? -g : g
# end

function Base.convert(::Type{T}, x::S) where {T<:AbstractMonoidWord,S<:AbstractFreeGen}
  T(x)
end

function Base.convert(::Type{MonoidWord{S}}, x::MonoidWord{T})::MonoidWord{S} where {T,S}
  MonoidWord{S}([S(l) for l in gens(x; p=1)]; exp=x.exp)::MonoidWord{S}

end


function _exponent(g::T) where T<:AbstractMonoidWord
  Int(g.exp)
end


function (::Type{T})(x::S) where {T<:Integer,S<:AbstractMonoidGen}
  T(id(x))::T
end

function Base.:*(a::T, b::S) where {T<:AbstractMonoidElement,S<:AbstractMonoidElement}
  x, y = promote(a, b)
  _mul(x, y)
end

function _mul(a::T, b::T)::Union{FreeGen,MonoidWord} where T<:AbstractFreeGen

  ((a.id * b.id) == 0 || a.id == b.id) &&
    return T(max(a.id, b.id); p=_exponent(a) + _exponent(b))

  MonoidWord{T}(T[a, b])
end

Base.reverse(x::T) where T<:AbstractMonoidWord = T(reverse(collect(gens(x; p=1))); exp=x.exp)

Base.inv(x::T) where T<:AbstractMonoidWord =
  T(collect(gens(x; p=-1)); exp=x.exp)

Base.:^(x::T, n::Integer) where T<:AbstractMonoidWord = T(collect(gens(x; p=1)); exp=n * x.exp)

Base.:^(x::FreeGen{T}, n::Integer) where T = FreeGen{T}(x.id; p=n * x.exp, inv=x.inv)

# function gens(x::AbstractMonoidWord)
#     p = x.exp
#     elem = flatten((x.word[2:end],[ x.last]))
#     p > 0 ? cycle(elem, p) :
#             cycle(elem, -p)     |>
#             Iterators.reverse   |>
#             z -> map(e->-e, z)
# end

function gens(x::T) where T<:AbstractFreeGen
  id(x) == 0 ? T[] : T[x]
end


function gens(x::T) where T<:AbstractCyclicGen
  id(x) == 0 ? T[] : T[x]
end


function gens(x::MonoidWord{T}; p=nothing) where T
  p = isnothing(p) ? x.exp : p
  elem = flatten((x.word[2:end], [x.last]))
  p > 0 ? cycle(elem, p) :
  cycle(elem, abs(p)) |>
  elem -> map(e -> -e, elem) |>
          Iterators.reverse
end

function eachgen(x::MonoidWord{T}) where T<:AbstractFreeGen
  flatmap(c -> cycle([T(c.id; inv=c.inv)], (c.exp)), gens(x))
end

function eachgen(x::MonoidWord{T}) where T<:AbstractCyclicGen
  flatmap(c -> cycle([T(id(c), inv=c.gen.inv)], abs(c.exp)), gens(x))
end

function eachgen(c::T) where T<:AbstractFreeGen
  cycle([T(c.id; inv=c.inv)], (c.exp))
end

function eachgen(c::T) where T<:AbstractCyclicGen
  cycle([T(id(c))^sign(c.exp)], abs(c.exp))
end

Base.iterate(c::T) where T<:AbstractMonoidElement = Iterators.peel(eachgen(c))


function Base.iterate(c::T, state::I) where {T<:AbstractMonoidElement,I}
  return Iterators.peel(state)
end

Base.IteratorSize(::Type{S}) where S<:AbstractMonoidElement = Base.HasLength()
Base.firstindex(c::S) where S<:AbstractMonoidElement = 1
Base.lastindex(c::S) where S<:AbstractMonoidElement = length(c)

function _mul(a::MonoidWord{T}, b::MonoidWord{T})::MonoidWord{T} where T<:AbstractMonoidGen
  word = T[]
  final = one(T)
  for (gen) in (flatmap(gens, [(a), (b)]))
    if id(final) == 0
      final = gen
    elseif (id(final) == id(gen))
      final = final * gen
      if final.exp == 0 && !isempty(word)
        final = pop!(word)
      end

    else
      push!(word, final)
      final = gen
    end
  end
  id(final) == 0 || push!(word, final)
  MonoidWord{T}(word)
end

expand!(f::T) where T<:AbstractElement = f
function expand!(w::AbstractMonoidWord)
  wexp = one(w) * w
  copy!(w, wexp)
  w
end



function genName(c::T; upperinv=false, id=false) where T<:AbstractFreeGen
  id = false
  if c.id == 0
    "1"
  else
    idnum = (c.id - 1) % (2 * 26)
    name =
      idnum in 0:25 ? "$('a' + idnum)" :
      "$('A' + idnum - 26)"


    if (-1 + Int((c.id - 1) ÷ (26 * 2))) >= 0
      name *= "$(UnicodeFun.to_subscript(-1+Int((c.id-1)÷(26*2))))"
    end

    if id
      name *= "{:$(c.id)}"
    end

    if !c.inv
      "$name$(c.exp==1 ? "" : UnicodeFun.to_superscript(c.exp))"
    else
      upperinv && return "$(uppercase(name))$(c.exp==1 ? "" : UnicodeFun.to_superscript(c.exp))"

      "$name$(UnicodeFun.to_superscript(_exponent(c)))"
    end
  end
end

function Base.show(io::IO, mime::MIME"text/plain", c::T) where T<:AbstractFreeGen
  print(io, "$(typeof(c)) with\nid{$(id(c))} : \n")
  show(io, c)
end

function Base.show(io::IO, mime::MIME"text/plain", c::T) where T<:AbstractCyclicGen
  println(io, "$(typeof(c)) with\nid = {$(id(c))} of $(c.order==0 ? "" : "order $(c.order)") : ")
  show(io, c)
end

function Base.show(io::IO, c::T) where T<:AbstractMonoidGen
  print(io, "$(genName(c; id=true))")
end

function Base.show(io::IO, x::AbstractMonoidWord)
  elem = x.exp == 1 ? join(["$(genName(c; id=false))" for c in gens(x; p=1)], "$SEP") : "($(join(["$(genName(c))" for c in gens(x; p=1)], "$SEP")))$(UnicodeFun.to_superscript(x.exp))"
  print(io, elem * "")
end

# the 3-argument show used by display(obj) on the REPL
function Base.show(io::IO, mime::MIME"text/plain", x::AbstractMonoidWord)
  println(io, "Length $(length(x)) MonoidWord{$(eltype(x))}:")
  # you can add IO options if you want
  show(io, x)
end

function prettyrepr(x::MonoidWord{T}) where T
  elem = x.exp == 1 ? join(["$(genName(c; upperinv=true, id=false))" for c in gens(x; p=1)], "$SEP") : "($(join(["$(genName(c; upperinv=true))" for c in gens(x; p=1)], "$SEP")))$(UnicodeFun.to_superscript(x.exp))"
  elem
end


function Base.getindex(x::MonoidWord{T}, i::Integer) where T
  i <= length(x) || error("BoundsError: index $i out of bounds for word of length [$(length(x))]")
  first(drop(eachgen(x), i - 1))
end



function Base.getindex(x::MonoidWord{T}, idxs::AbstractUnitRange) where T
  i = idxs.start
  j = idxs.stop
  # max(i,j) <= length(x) || error("BoundsError: index $(max(i,j)) out of bounds for word of length [$(length(x))]")

  zip(idxs, drop(eachgen(x), i - 1)) |> z -> mapreduce(last, *, z, init=one(x))
end

function Base.lastindex(x::T) where T<:AbstractMonoidWord
  length(x)
end

function gcp(a::S, b::T) where {S,T<:AbstractElement}
  gcp(promote(a, b)...)
end


function gcp(a::T, b::S) where {T<:AbstractFreeGen,S<:AbstractFreeGen}
  a.id !== b.id || (xor(a.inv, b.inv)) ? one(a) :
  T(a.id; p=min(a.exp, b.exp), inv=a.inv)
end


function gcp(a::MonoidWord{T}, b::MonoidWord{T}) where T
  wgcp = one(T)

  for (g, h) in zip(gens(a), gens(b))
    if g !== h
      wgcp *= gcp(g::T, h::T)
      break
    end
    wgcp *= g
  end
  wgcp
end

function element(s::AbstractString)
  # ms = eachmatch(r"(?<minus>-?)(?<gen>(?:[A-Z]|[a-z])\d*)(?:[\s\^](?<power>-?\d+))?[\s\*]*", s)
  ms = eachmatch(r"(?<gen>-?(?:[A-Z]|[a-z])\d*)(?:[\s\^](?<power>-?\d+))?[\s\*]*", s)

  matches = map(ms) do m
    exp = m[:power]
    pow = (isnothing(exp) || isempty(exp)) ? 1 : parse(Int, exp)


    name = m[:gen]
    FreeGen(name; p=pow)
  end

  prod(matches, init=one(matches[1]))

end
