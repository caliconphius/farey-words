
Base.length(x::AbstractElement) = length(x.word)

function Base.:(<<)(x::AbstractElement, n::Integer) 
    n_mod = n%length(x)
    F = x.parent
    F(flatten([x.word[n_mod+1:end],ITR.take(x.word, n_mod)])) 
end

function conj_prefix(x::FreeGroupElement)
    xi = inv(x)
    Gr = x.parent
    
    prefix = zip(x.word, xi.word) |>
        itr->ITR.takewhile((x)->x[1]==x[2], itr) |> 
        l->mapreduce(x->Gr(x[1]), *, l, init=one(Gr))

    prefix, x^prefix

end