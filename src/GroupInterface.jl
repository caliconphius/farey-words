module Interfaces
import ..GPC
abstract type AbstractMonoid<:GPC.Monoid end
abstract type AbstractMonoidElement<:GPC.MonoidElement end
abstract type AbstractGroup<:AbstractMonoid end
abstract type AbstractGroupElement<:GPC.GroupElement end
const AbstractElement = Union{AbstractMonoidElement, AbstractGroupElement}
end
