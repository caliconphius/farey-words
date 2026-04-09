module Interfaces
import ..GPC
abstract type AbstractElement <: GPC.MonoidElement end
abstract type AbstractMonoid<:GPC.Monoid end
abstract type AbstractMonoidElement<:AbstractElement end
abstract type AbstractGroup<:AbstractMonoid end
abstract type AbstractGroupElement<:GPC.GroupElement end


end
