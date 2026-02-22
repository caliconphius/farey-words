using Farey

# Given a rational number
Q1 = 23//350
Q2 = 3//5
Q3 = 21//16


# compute the continued fraction
c1 = ContinuedFraction(Q1) # c1 = [0; 15, 4, 1, 1, 2] = 23//350
c2 = ContinuedFraction(Q2) # c2 = [0; 1, 1, 2] = 3//5

# shorthand syntax 
# !!WARNING!! Only use this if you are assigning a single expression as below
# can cause issues with macro expansion otherwise

c3 = @cf Q3 # c3 = [1; 3, 5] = 21//16
@cf [1, 3, 5] # same
@cf0 [1, 3, 5] # = [0; 1, 3, 5] = 16//21

# can compute with these continued fractions as though they were rational numbers

c1 + c2 # = [0; 1, 1, 1, 116] = 233//350
c2 / c3 # = [0; 2, 5, 3] = 16//35 e.t.c...

# Can also do operations with other types of numbers 
# but by default converts the continued fraction to a rational or float

c2 * 1//2 # = 3//10
c3 + 1 # = 37//16
c1 / 0.01 # = 6.571...


# Some functionality for Farey sums and other special rational number operations
# type \oplus and \ominus followed by `tab` to get ⊕ and ⊖

# farey sum p//q ⊕ r//s = (p+r)//(q+s) if ps - qr = ±1

Q4 = @cf 5//8 # [0; 1, 1, 1, 2] = 5//8
Q2⊕Q4 # = [0; 1, 1, 1, 1, 2] = 8//13

# farey diff p//q ⊖ r//s = (p+r)//(q+s) if ps - qr = 1
# if you input a pair such that the above expr is negative
# will return the positive difference

Q2⊖Q4 # = [0; 1, 2] = 2//3

# return the two nearest neighbours (q1, q2) to Q1 on the stern-broca tree as well as their
# 'farey difference' (q1⊖q2)
farey_neighbours(Q1)
# = ([0; 15, 4, 2] = 9//137, [0; 15, 4, 1, 2] = 14//213, [0; 15, 5] = 5//76)