
struct FreeGroup<: GPC.Group 
    ngens::UInt
    monoid::GPC.Monoid
    alphabet::KB.Alphabet
    FreeGroup(ngens::Integer, mon::GPC.Monoid) = new(ngens, mon, mon.alphabet)
end

struct FreeGroupElement <: GPC.GroupElement 
    word::KB.Words.Word{UInt}
    elem::GPC.MonoidElement
    parent::FreeGroup
    function FreeGroupElement(word::KB.Words.AbstractWord, F::FreeGroup)
        element = F.monoid(word)
        MON.normalform!(element)
        new(element.word, element, F)
    end
end

(F::FreeGroup)(x::KB.Words.AbstractWord) = FreeGroupElement(x, F)
(F::FreeGroup)(x::FreeGroupElement) = FreeGroupElement(x.word, F)
(F::FreeGroup)(x::GPC.MonoidElement) = FreeGroupElement(x.word, F)
(F::FreeGroup)(i::Integer) = FreeGroupElement(F.monoid([i]).word, F)
(F::FreeGroup)(v::Vector) = FreeGroupElement(F.monoid(v).word, F)


Base.one(C::FreeGroup)::FreeGroupElement = C(one(C.monoid))
Base.one(x::FreeGroupElement)::FreeGroupElement = one(x.parent)
Base.similar(x::FreeGroupElement) = one(x)


GPC.isfinite(C::FreeGroup) = false

GPC.gens(C::FreeGroup) = [C(i) for i in 1:C.ngens]

GPC.parent(c::FreeGroupElement) = c.parent
function Base.:(==)(g::FreeGroupElement, h::FreeGroupElement)
    return parent(g) === parent(h) && g.word == h.word
end

function Base.inv(g::FreeGroupElement)
    return (C = parent(g); C(inv(g.elem)))
end

function Base.:(*)(g::FreeGroupElement, h::FreeGroupElement)
    h_elem = g.elem.parent(h.word)
    C = parent(g)
    return C(g.elem*h_elem)
end



function Base.:(^)(m::FreeGroupElement, n::Integer)::FreeGroupElement
    n < 0 && return inv(m)^-n
    return Base.power_by_squaring(m, n)
end

function FreeGroup(Sym::NamedTuple)
    N = length(keys(Sym))
    gens = [Symbol.(keys(Sym))..., Symbol.(values(Sym))...]
    A = KB.Alphabet(gens)
    for pair in pairs(Sym)
        KB.setinverse!(A, pair.first, pair.second)
    end

    f = KB.Word([1])
    F = [KB.inv(1, A)] |> KB.Word
    ε = one(f)

    R = KB.RewritingSystem(
        [(f*F,ε)],   
        KB.LenLex(A),
    )
    
    G = MON.FPMonoid(R)
    FreeGroup(N, G)

end

function FreeGroup(gens::Vararg{Union{Symbol, String}})
    FreeGroup((;(Symbol(s)=>Symbol(s,"⁻") for s in gens)...))
end

function FreeGroup(N::Integer; lett="g")
    syms = (;(Symbol(lett, i)=>Symbol(lett, i,"⁻") for i in 1:N)...)
    FreeGroup(syms)
end 

function Base.show(io::IO, C::FreeGroup)
    if get(io, :compact, false)::Bool
        repr_string =  "Free group: ⟨"*join(repr.(GPC.gens(C)), ",")*"⟩"
    else
        gens = join(repr.(GPC.gens(C)), ",")
        invs = join(repr.(inv.(GPC.gens(C))), ",")
        repr_string =  """Free Group on $(C.ngens) generators \t: ⟨$gens⟩
        With inverse symbols \t\t: [$(invs)]"""
    end
    print(io,repr_string )
end
function Base.show(io::IO, c::FreeGroupElement)
    return print(io, pretty_rep(c))
end

function pretty_rep(c::FreeGroupElement)
    unpretty = repr(c.parent.monoid(c.word))
    pretty =    replace(unpretty, "*" =>  ".") |> 
                x -> replace(x, r"([0-9]+)" =>  s"{\1}") |> 
                UnicodeFun.to_latex
    pretty
end
