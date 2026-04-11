module Farey
const DOT = "·"
import KnuthBendix as KB
import KnuthBendix.FPMonoids as MON
import GroupsCore as GPC

include("GroupInterface.jl")

using .Interfaces:AbstractGroup, AbstractMonoid, AbstractElement, AbstractGroupElement, AbstractMonoidElement, AbstractHom
import Base.Iterators as ITR
import Match, TOML, UnicodeFun

export ITR

include( "Monoids.jl")

using .Monoids:gcp, eachgen, AbstractMonoidGen,AbstractMonoidWord
import .Monoids
export gcp, AbstractMonoidGen,AbstractMonoidWord




Base.inv(f::T) where T <: GPC.MonoidElement =  f.parent(KB.inv(f.word, f.parent.alphabet))
Base.:\(f::T, g::T) where T<: Union{AbstractGroupElement, AbstractElement} = inv(f) * g
Base.:-(f::T) where T<: AbstractElement = inv(f)
↑(f::T, g::T) where T<: AbstractElement = f ^ inv(g)


export KB, MON, GPC, Monoids
export inv, (\), (<<), (|>), (∘), (↑), (-)
export FreeGroup
export s_seq
export christoffel, Hom, palindrome, pretty_rep
export ContinuedFraction, shrink_cf, farey_word
export @cf0, @cf, ⊕, ⊖,farey_neighbours, positive_form, conj_prefix

include("FreeGroup.jl")
include("Words.jl")
include("Homomorphisms.jl")
include("ContinuedFractions.jl")
include("FareyWords.jl")


include("SuffixTrees.jl")
import .SuffixTrees as SFX
export SFX

end
