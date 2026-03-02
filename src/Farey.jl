module Farey
const DOT = "·"
import KnuthBendix as KB
import KnuthBendix.FPMonoids as MON
import GroupsCore as GPC
import Chevie as CHV

include("GroupInterface.jl")

using .Interfaces:AbstractGroup, AbstractMonoid, AbstractElement, AbstractGroupElement, AbstractMonoidElement
import Match, TOML, UnicodeFun


Base.inv(f::T) where T <: GPC.MonoidElement =  f.parent(KB.inv(f.word, f.parent.alphabet))
Base.:\(f::T, g::T) where T<: AbstractElement = inv(f) * g


import Base.Iterators as ITR

export ITR
export KB, MON, GPC, CHV
export inv, (\), (<<), (|>), (∘)
export FreeGroup
export s_seq
export christoffel, Hom, palindrome, pretty_rep
export ContinuedFraction, shrink_cf, farey_word
export @cf0, @cf, ⊕, ⊖,farey_neighbours, positive_form

include("FreeGroup.jl")
include("Words.jl")
include("Homomorphisms.jl")
include("ContinuedFractions.jl")
include("FareyWords.jl")
include("BraidGroups.jl")


end
