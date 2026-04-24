module Interfaces
import ..GPC
abstract type AbstractElement <:GPC.GroupElement end
abstract type AbstractMonoid<:GPC.Monoid end
abstract type AbstractMonoidElement<:AbstractElement end
abstract type AbstractGroup<:AbstractMonoid end
abstract type AbstractGroupElement<:AbstractElement end
abstract type AbstractHom end


end
