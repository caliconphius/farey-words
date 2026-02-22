using Farey
Q = 23//350
c = ContinuedFraction(Q)
# F2 = FreeGroup([:f=>:F, :g=>:G]|>Dict)
# f,g = GPC.gens(F2) 
# F,G = GPC.gens(F2) .|> inv


# F2ab = FreeGroup((;:a=>:A, :b=>:B))
F2ab = FreeGroup(:a, :b)
F2 = FreeGroup((;:f=>:F, :g=>:G))
F2 = FreeGroup(:f, :g)
# F2 = FreeGroup(2)

f, g = GPC.gens(F2)
F, G = GPC.gens(F2) .|> inv
a, b = GPC.gens(F2ab)

ϕ = Farey.Hom(F2, F2ab, (
    f=>F2ab([1,2,3]), 
    g=>1
)) 





christoffel(3, 5, a, a^b)
s_seq(3//5)
u = christoffel(3//5,a,b).Ω
u = christoffel(0//1,a,b).Ω
(u.word)

Q =(3//5)

L = cont_fraction(Q)
a^0 |> typeof
Ω0 = F2(1)
Ω1 = F2(2)

s = Ω0^(l-1) 
s.parent
s.parent.monoid
l = 1
(Ω0^(l-1)) * Ω1
for (k,l) in enumerate(reverse(L))
    Ω0new = k%2==1 ? Ω0^(l-1) * Ω1 : Ω1 * Ω0^(l-1)
    Ω1new = k%2==1 ? Ω0^l * Ω1 : Ω1 * Ω0^l
    Ω0 = Ω0new
    Ω1 = Ω1new
end


begin
L = [3,4]
@show cont_to_quot(L)
ω = s_seq(L) .|> collect 
Ω = ω[2]    
end
# tau(Ω, 1)
s_seq([1,2,2]) .|> collect 
s_seq([1,1,2]) .|> collect 

