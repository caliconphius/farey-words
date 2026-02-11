module Switch
const SwitchExpr{T} = Pair{T, Expr} #where T<:Union{Symbol, Enum}
struct TypeInferred end
const Maybe{T} = Union{Nothing, T}


@enum testEnum begin
    Aaa
    Bbb
    Vvv
end

macro switch(variable::Expr, syms...)
    :(@switch ::TypeInferred ::Type{$(typeof(variable))} $(esc(variable)) $syms)
end

macro switch(::TypeInferred, enumType::Type{<:Enum}, variable, syms...) 
    
    default_return::Expr = isnothing(default) ? :(error("No default or behaviour for state $(esc(variable)) set")) : default

    enum_instances = :(instances(typeof(variable)) .|> Symbol)
    
    if length(syms) == 1 && syms[1] isa Expr && syms[1].head === :block
        syms = syms.args[1]
    end

    enum_instances = instances(enumType)



    ex = reduce(syms, init=default_return) do pair, expression
        isa(pair, LineNumberNode) && return expression

        pair.first ∈ enum_instances || pair.first == :_ ?
             :($(esc(variable)) == $(pair.first) ? $(pair.second) : $expression) :
        # else
            error("$(pair.first) is not a valid instance for $enumType")
        
    end
    
    ex
end

end

using .Switch 
instances(Switch.testEnum)

@macroexpand Switch.@switch $Switch.Aaa begin
    Aaa => 1
end


qq = :(begin
        Aaa => 1
        Aaa => 1
    end)
# end

dump(qq)
