using Farey



A = KB.Alphabet([:f, :g, :h, :F, :G, :H])
KB.setinverse!(A, :f, :F)
KB.setinverse!(A, :g, :G)
KB.setinverse!(A, :h, :H)

f, g, h, F, G, H= KB.Word.([i] for i in 1:6)
ε = one(f)

R = KB.RewritingSystem(
    [(f*F,ε)],   
    KB.LenLex(A),
)


id = one(F₃)

typeof(f) <: GP.GroupWord
GC
SA.star(x::GPC.GroupElement) = inv(x)

F₂ = FreeGroup(2)
rg_basis = [one(F₃), Iterators.flatten([[x*id, inv(x)*id] for x in F₃.gens])...]
B = SA.DiracBasis(rg_basis)
RG = SA.StarAlgebra(F₃, B)

(zid, zf, zF, zg, zG, zh, zH) = RG.(B)

zid + zf * (zg+ zG)

fB = SA.FixedBasis(basis(RG); n = 4)

