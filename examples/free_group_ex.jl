using Farey
# computing in FreeGroups/Monoids!
FreeGroup(3)

F2ab = FreeGroup(:a, :b)
F2 = FreeGroup((;:f=>:F, :g=>:G))

f, g = GPC.gens(F2)
F, G = GPC.gens(F2) .|> inv
a, b = GPC.gens(F2ab)

ϕ = Farey.Hom(F2, F2ab, (
    f=>a*b/a, 
    g=>a
)) 



ϕ(f*g*f^(g^2))

christoffel(3, 5, a, a^b)



s_seq(3//5)
u = christoffel(3//5,a,b)
u = christoffel(0//1,a,b)



Q =(3//5)
