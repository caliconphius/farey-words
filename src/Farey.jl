module Farey
const DOT = "·"
import Match, TOML, UnicodeFun
# import Chevie as CHV
import StarAlgebras as SA
import KnuthBendix as KB
import KnuthBendix.FPMonoids as MON
# import KnuthBendix:inv
import GroupsCore as GPC

import KnuthBendix.Words as WD

Base.inv(f::T) where T <: GPC.MonoidElement =  f.parent(KB.inv(f.word, f.parent.alphabet))


import Base.Iterators as ITR

export ITR
export KB, MON, GPC, WD, SA, inv
# export CHV, SA
export FreeGroup
export s_seq, sigma, tau
export christoffel, Hom, palindrome, pretty_rep
export ContinuedFraction, shrink_cf, farey_word, @cf0, @cf, ⊕, ⊖,farey_neighbours

include("FreeGroup.jl")
include("Homomorphisms.jl")
include("ContinuedFractions.jl")
include("FareyWords.jl")



end
