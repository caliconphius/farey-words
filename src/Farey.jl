module Farey
const DOT = "·"
import KnuthBendix as KB
import KnuthBendix.FPMonoids as MON
import GroupsCore as GPC

include("GroupInterface.jl")

using .Interfaces: AbstractGroup, AbstractMonoid, AbstractElement, AbstractGroupElement, AbstractMonoidElement, AbstractHom
import Base.Iterators as ITR
import Match, TOML, UnicodeFun

export ITR

include("Monoids.jl")
import .Monoids
using .Monoids: gcp, eachgen, AbstractMonoidGen, AbstractMonoidWord, AbstractCyclicGen, AbstractFreeGen, id
export gcp, AbstractMonoidGen, AbstractMonoidWord




# Base.inv(f::T) where T <: GPC.MonoidElement =  f.parent(KB.inv(f.word, f.parent.alphabet))

function Base.:-(f::T) where T<:AbstractElement
  w::T = inv(f)
  Monoids.expand!(w)
  w
end
↑(f::T, g::T) where T<:AbstractElement = f^inv(g)
Base.:/(x::AbstractElement, y::AbstractElement) = x * inv(y)
Base.:\(x::AbstractElement, y::AbstractElement) = inv(x) * (y)
Base.:^(x::AbstractElement, y::AbstractElement) = inv(y) * x * (y)
# Base.:(==)(x::T, y::T)::Bool = Base.isequal(x,y)


export KB, MON, GPC, Monoids
export inv, (\), (<<), (|>), (∘), (↑), (-)
export FreeGroup
export s_seq
export christoffel, Hom, palindrome, pretty_rep
export ContinuedFraction, shrink_cf, farey_word, CF
export @cf0, @cf, ⊕, ⊖, farey_neighbours, positive_form, conj_prefix

include("FreeGroup.jl")
include("Words.jl")
include("Homomorphisms.jl")
include("ContinuedFractions.jl")
include("FareyWords.jl")


include("SuffixTrees.jl")
import .SuffixTrees as SFX
export SFX

end
