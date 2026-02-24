
Base.length(x::AbstractElement) = length(x.word)

function Base.:(<<)(x::AbstractElement, n::Integer) 
    n_mod = n%length(x)
    F = x.parent
    F(flatten([x.word[n_mod+1:end],ITR.take(x.word, n_mod)])) 
end



# function prefix(w::AbstractElement, )
    
# end