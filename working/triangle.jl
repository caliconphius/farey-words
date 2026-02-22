
using Farey
using .KB
# inv(f::T) where T <: GPC.MonoidElement =  f.parent(KB.inv(f.word, f.parent.alphabet))

struct FreeGroup <: GPC.Group
    mon::GPC.Monoid
    ngens::Integer
end

struct CyclicGroup <: GroupsCore.Group
    order::UInt
end

struct CyclicGroupElement <: GroupsCore.GroupElement
    residual::UInt
    parent::CyclicGroup
    CyclicGroupElement(n::Integer, C::CyclicGroup) = new(n % C.order, C)
end

function ctriangle(l, n, m)
    Al = Alphabet([:c, :a, :b])

    a, b, c = Word.([i] for i in 1:length(Al))
    ε = one(a)



    eqns = [(a^l, c), (b^n, c), ((a * b)^m, c)]

    R = RewritingSystem(eqns, LenLex(Al))
    return R 

end

function freeGp(Sym)
    A = KB.Alphabet([keys(Sym)..., values(Sym)...])
    for pair in Sym
        KB.setinverse!(A, pair.first, pair.second)
    end

    f, g, F, G = KB.Word.([i] for i in 1:4)
    ε = one(f)

    R = KB.RewritingSystem(
        [(f*F,ε)],   
        KB.LenLex(A),
    )
    
    G = MON.FPMonoid(R)
    G

end

F₂ = freeGp(Dict([:f=>:F, :g=>:G]))


f, g, F, G = [F₂([i]) for i in 1:4]


KB.inv(f.word, f.parent.alphabet)


G_rws = ctriangle(2,3,6)

confl = knuthbendix(G_rws)  

Δ = MON.FPMonoid(confl)
F₂

confl
