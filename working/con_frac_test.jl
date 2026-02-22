using Farey

qk = k->(5 + 6*k) // (12*(k+1))|>ContinuedFraction
# qk = k->(7 + 8*k) // (16*(k+1))

Qs(K) = [
    qk(k) for k in 1:K
];

Ls = [ContinuedFraction(q) for q in Qs(50)]

begin
write("out.txt", "")
io = open("out.txt", "a")
for (k, l) in enumerate(Qs(50))
write(io, """
k = $(k)
$(qk(k)) = (5+6*$k) / (12*($k+1))

""") 
end
close(io)
end