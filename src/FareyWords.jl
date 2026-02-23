using Base.Iterators


function christoffel(X::Number, a::GPC.MonoidElement,b::GPC.MonoidElement)
    Q = ContinuedFraction(X) 

    # @Match.Match Rational(Q) begin
        
    # end

    if Q.leading!=0 && !(Rational(Q)===1//1)
        a, b = (b, a)
        Q::ContinuedFraction = 1/Q 
    end
    Ω0 = a
    Ω∞ = b
    Ω1 = Ω0*Ω∞

    for (k,l) in enumerate(Q.L)
        Ω1 =  k%2==1 ? Ω0^l*Ω∞ : Ω∞*Ω0^l
        Ω∞ = Ω0
        Ω0 = Ω1
    end


    triple = (Ω0=Ω0, Ω∞=Ω∞, Ω=Ω1)
    Rational(X)==0//1 ? triple.Ω0 :
    Rational(X)==1//0 ? triple.Ω∞ :
    triple.Ω
         

end

function christoffel(p::Int, q::Int, a::GPC.GroupElement,b::GPC.GroupElement)
    x0, x1 = p<0 ? (b, inv(a)) : (a,b)
    christoffel(p//q, x0, x1)
end

christoffel(Q::Number, G::GPC.Group) = christoffel(Q, G.(1:2)...)

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



# function s_seq(L::Vector{Int})
#     Ω0 = only([L[1]+1])
#     Ω1 = only([L[1]])
    
#     if length(L)==1
#          return Ω1 
#     end
#     L[2] -= 1

#     # Ω1 = flatten((L[1]+1, cycle(L[1], L[2]-1)))
#     Ω = Ω1
#     Ω_induct = ((Ω0, Ω1, Ω), (k,l)) -> 
#         (
#             Ω1,
#             (k%2==1) ? 
#                 flatten((Ω0, cycle(Ω1, l))) : 
#                 flatten((cycle(Ω1, l), Ω0)),
#             Ω0
#         )

#     Ω = foldl(Ω_induct, enumerate(L[2:end]), init=(Ω0, Ω1, Ω))

#     Ω .|> collect
# end 



# function palindrome_word(N::Int, f1::GroupGen = f, f2::GroupGen = g)::GroupElem
#     prod(fill(f1*f2, N÷2)) * (N%2==1 ? f : id)
# end



function s_seq(c::ContinuedFraction)
    _M2 = FreeGroup("a", "b")
    _m1, _m2 = [_M2(x) for x in 1:_M2.ngens]
    ContinuedFraction(c)
    c.leading==0 || @warn "Farey is currently only implemented for positive rationals <= 1, results for numbers outside this range may be inaccurate"
    ω = christoffel(c, _m1, _m2)^2
    ω
    replace(ω.parent.monoid(ω.word) |> repr , r"[\*\^]" =>  s"") |>
        x-> replace(x, r"ab"=>s"a1b") |>
        x-> replace(x, r"a|b"=>s"") |>
        collect .|> x->Int(x) - 0x0030

 end

 function s_seq(c::Number)
    s_seq(ContinuedFraction(c))
 end

function farey_word(c::Number, f, g)
    s = s_seq(c)
    accumulate(s, init=(f=>g, nothing)) do x, y
        a, b = [x[1]...]
        an = palindrome(a,b, y)
        nextpair = y%2 == 0 ? (inv(a)=>inv(b)) : (inv(b)=>inv(a))
        nextpair, an
    end .|> last |> prod
    
 end

function sigma(S::Vector{Int}, m::Int)::Vector{Int}
    flatmap(S) do x
        vcat(repeat([m+1], x),[m])
    end |> collect
end

function tau(S::Vector{Int}, m::Int)::Vector{Int}
    flatmap(S) do x
        vcat(repeat([m], x),[m+1])
    end |> collect |> reverse
end


