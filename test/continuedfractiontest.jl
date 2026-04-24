#
# export ContinuedFraction, shrink_cf, farey_word, CF
# export @cf0, @cf, ⊕, ⊖, farey_neighbours, positive_form, conj_prefix
Q1 = ContinuedFraction(3 // 5)
@test Q1.L == [1, 1, 2]

Q2 = ContinuedFraction(0, [2, 2, -1])
Q3 = CF(0, [2, 2, -1])
@test Q2.L == [2, 2, -1]
@test Rational(Q2) == 1//3
@test Q2 == Q3
