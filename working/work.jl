# using Farey
using Base.Iterators
# F2 = @freeGroup f g
# (f,g) = generator_list(F2)

# f*g
# f/g

begin
L = [1,2,2]
@show cont_to_quot(L)
ω = s_seq(L) .|> collect 
Ω = ω[2]    
end
tau(Ω, 1)
s_seq([1,2,2]) .|> collect 
s_seq([1,1,2]) .|> collect 

GroupGen(:f)
