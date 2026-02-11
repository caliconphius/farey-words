
using Base.Iterators
using .FareyWords:*
FareyWords = FW

g = GroupGen(:g)
f = GroupGen(:f)
F = inverse(f)
G = inverse(g)

gg = GroupElem([G, f])
y = f * f
X = f * g * F * G


gg.final

inverse(gg)
gg

(gg * y)

flatmap(X.elems) do x
       [GroupGen(x.key), GroupGen(x.key, x.value-3)]
end |> collect


h = Klein4Group(0)
p = Klein4Group(1)
v = Klein4Group(2)

hh = K4_action(h)
pp = K4_action(p)
vv = K4_action(v)
hh(f*g)

Symbol(h)

