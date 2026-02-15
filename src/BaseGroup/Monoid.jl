struct Monoid{T} end

function s_seq_rev(Q::Rational)
    
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

tau(m::Int) = Base.Fix2(tau, m)

