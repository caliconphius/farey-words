using Farey
# computing in FreeGroups/Monoids!

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
