module Farey
const DOT = "·"
import Match, TOML, UnicodeFun
import KnuthBendix as KB
import KnuthBendix.FPMonoids as MON
import GroupsCore as GPC

Base.inv(f::T) where T <: GPC.MonoidElement =  f.parent(KB.inv(f.word, f.parent.alphabet))


import Base.Iterators as ITR

export ITR
export KB, MON, GPC, inv
export FreeGroup
export s_seq
export christoffel, Hom, palindrome, pretty_rep
export ContinuedFraction, shrink_cf, farey_word, @cf0, @cf, ⊕, ⊖,farey_neighbours
include("FreeGroup.jl")
include("Words.jl")
include("Homomorphisms.jl")
include("ContinuedFractions.jl")
include("FareyWords.jl")

export (<<)

end
