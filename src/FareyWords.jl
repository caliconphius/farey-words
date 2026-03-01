using Base.Iterators


function christoffel(X::Number, a::AbstractElement, b::AbstractElement)

    if abs(X) > 1
        a, b = (b, a)
        X = one(X)/X
    end

    b = X < 0 ? inv(b) : b

    X==0 && return a
    
    Q = ContinuedFraction(X) |> positive_form
    
    Ω0 = a
    Ω∞ = b
    Ω1 = Ω0*Ω∞

    for (k,l) in enumerate(Q.L)
        Ω1 =  k%2==1 ? Ω0^l*Ω∞ : Ω∞*Ω0^l
        Ω∞ = Ω0
        Ω0 = Ω1
    end


    Ω1
    # triple = (Ω0=Ω0, Ω∞=Ω∞, Ω=Ω1)
    # triple.Ω
end

christoffel(Q::Number, G::AbstractMonoid) = christoffel(Q, G.(1:2)...)

function christoffel(p::Int, q::Int, rest...)
    Ω = christoffel(p//q, rest...)
    return q < 0 ? inv(Ω) : Ω
end


function palindrome(f, g, n)
    (f*g)^(n÷2) * f^(n%2)
end

function shrink_cf(c::Number)
    c = ContinuedFraction(c)
    c = c.leading!=0 ? one(c)/c : c
    q = c.L
    length(q) == 1 && return one(c)
    q[2] == 1 ? 
        ContinuedFraction(0, q[3:end]) : 
        ContinuedFraction(0, [q[2]-1, q[3:end]...])  
end




function s_seq(c::ContinuedFraction)
    _M2 = FreeGroup("a", "b")
    _m1, _m2 = [_M2(x) for x in 1:_M2.ngens]
    c = positive_form(c)
    0<=Rational(c)<=1 || error("Farey words/S sequences are currently only implemented for positive rationals <= 1, results for numbers outside this range may be inaccurate")
    Rational(c)==0//1 && return [2]
    ω = christoffel(c, _m1, _m2)^2
    Rational(c)==0//1 && return [2]
    ω.parent.monoid(ω.word)                     |>
        repr                                    |>
        x-> replace(x, "a*b"=>"a^1*b")          |>
        x-> replace(x, r"a\^(\d+)\*b"=>s"\1")   |>
        x-> split(x, "*")                      .|>
        x-> parse(Int, x)
end


function s_seq(c::Number)
    0<=c<=1 || error("Farey words/S sequences are currently only implemented for positive rationals <= 1, results for numbers outside this range may be inaccurate")
    s_seq(ContinuedFraction(c))
end

function farey_word(c::Number, f, g)
    s = s_seq(c)
    out = accumulate(s, init=(f=>g, nothing)) do x, y
        a, b = [x[1]...]
        an = palindrome(a,b, y)
        nextpair = y%2 == 0 ? (inv(a)=>inv(b)) : (inv(b)=>inv(a))
        nextpair, an
    end .|> last |> prod
    out
    
 end


function σ(m::Int, F1::FreeGroup, F2::FreeGroup)
    Hom(F1, F2, (
        1=>F2(1)^(m+1) * F2(2),
        2=>F2(1)^(m) * F2(2)
    ))
end

# function sigma(S::Vector{Int}, m::Int)::Vector{Int}
#     flatmap(S) do x
#         vcat(repeat([m+1], x),[m])
#     end |> collect
# end

# function tau(S::Vector{Int}, m::Int)::Vector{Int}
#     flatmap(S) do x
#         vcat(repeat([m], x),[m+1])
#     end |> collect |> reverse
# end


