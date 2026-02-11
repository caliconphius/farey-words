module switch
macro switch(s, exprs)
    return :(getindex(Dict($exprs), $s))
end
export switch

end
