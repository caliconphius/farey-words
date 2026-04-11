
export word

word(x::FreeGroupElement) = x.word
parent(x::FreeGroupElement) = x.parent
word(x::AbstractMonoidElement) = x
parent(x::AbstractMonoidElement) = Monoids.eachgen(x)

# Base.length(x::AbstractElement) = length(word(x))

function Base.:(<<)(x::AbstractElement, n::Integer) 
    n_mod = n%length(x)
    F = x.parent
    F(flatten([word(x)[n_mod+1:end],ITR.take(word(x), n_mod)])) 
end

function conj_prefix(x::FreeGroupElement)
    xi = inv(x)
    Gr = x.parent
    
    prefix = zip(word(x), xi.word) |>
        itr->ITR.takewhile((x)->x[1]==x[2], itr) |> 
        l->mapreduce(x->Gr(x[1]), *, l, init=one(Gr))

    prefix, x^prefix

end

function conj_prefix(x::AbstractMonoidElement)
    xi = inv(x)
    prefix = gcp(x, xi)
    prefix, x^prefix

end