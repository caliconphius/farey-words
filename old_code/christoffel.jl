
using Base.Iterators


function cont_fraction(Q::Rational)::Vector{Int}
    L = []
    while Q!=0//1
        l0 = (1÷Q)
        push!(L, l0)
        Q = 1/Q - l0
    end
    L

end

function cont_to_quot(L::Vector{Int})::Rational
    reduce((a,b)->1//(a+b), reverse(L[1:end-1]), init=1//L[end])
    
end

function s_seq(L::Vector{Int})::Tuple{Vararg{Array{Int},3}}
    Ω0 = only([L[1]+1])
    Ω1 = only([L[1]])
    
    if length(L)==1
         return Ω1 
    end
    L[2] -= 1

    # Ω1 = flatten((L[1]+1, cycle(L[1], L[2]-1)))
    Ω = Ω1
    Ω_induct = ((Ω0, Ω1, Ω), (k,l)) -> 
        (
            Ω1,
            (k%2==1) ? 
                flatten((Ω0, cycle(Ω1, l))) : 
                flatten((cycle(Ω1, l), Ω0)),
            Ω0
        )

    Ω = foldl(Ω_induct, enumerate(L[2:end]), init=(Ω0, Ω1, Ω))

    Ω .|> collect
end 

function palindrome_word(N::Int, f1::GroupGen = f, f2::GroupGen = g)::GroupElem
    prod(fill(f1*f2, N÷2)) * (N%2==1 ? f : id)
end

function farey_word(Q::Rational)::GroupElem
    L = cont_fraction(Q)
    S = s_seq(L)
    full_s_seq = vcat(S, S)
    

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



begin
L = [1,2]
@show cont_to_quot(L)
ω = s_seq(L) .|> collect 
Ω = ω[2]    
end
tau(Ω, 1)
s_seq([1,2,2]) .|> collect 
s_seq([1,1,2]) .|> collect 

GroupGen(:f)

