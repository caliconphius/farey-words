using Chevie
W = coxgroup(:B,2)
W = coxgroup(:A,3)
W(1)
W(2)
# W(3)


B = BraidMonoid(W)
BKL = DualBraidMonoid(W)
BKL


Δ = B.δ 
s = B(1)
t = B(2)



s * Δ

p = Presentation(B, vars=Symbol.(collect("abcd"))) 
p |> simplify
p |> display_balanced


centralizer_gens(s) |> shrink




# Brieskorn Saito