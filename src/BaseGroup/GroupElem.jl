mutable struct GrpElem{G<:Group} 
    Group::G
    front::Union{Id, Vector{Gen{G}}}
    final::Union{Id, Gen{G}}
end


Base.convert(::Type{GrpElem{G}}, x::Gen{G}) where G<:Group = GrpElem(x)
function GrpElem(F::G, s::String) where G<:Group
    gens = parseString(s,F)
    id = GrpElem(F)
    for g in gens
        push!(id,g)
    end
end
    
function Base.:*(x::GrpElem{G}, y::GrpElem{G})::GrpElem{G} where G<:Group
    y.Group<x.Group || error("$(y.Group) is not a subgroup of $(x.Group)")
    elem_x = GrpElem(x)
    push!(elem_x, y)
    elem_x
end



GrpElem(F::G) where G<:Group = GrpElem{G}(F, Id(), F())
GrpElem(X::Gen{G}) where G<:Group = GrpElem{G}(X.Group, Id(), X)



function Base.sizeof(x::GrpElem{G}) where G<:Group
    x.front===Id() || return sizeof(x.front)+1 

    x.final===Id() ? 0 : 1
end


function Base.push!(x::GrpElem{G}, g::Gen{G})::GrpElem{G} where G<:Group
    x_end = x.final
    @match (x_end.name, g.name) begin
        (Id(), _) => GrpElem(g)
        (_, Id()) => x
        (t, t) => x.value==y.value ? x.final = popfirst!(x.front) : x.final = x.Group(t, x.value+y.value)
        (_,_) =>  begin 
            x.front==Id() ? setfield!(x, :front, [x.final]) : push!(x.front, x.final) 
            setfield!(x, :final, g) 
        end
    end
end

function Base.show(io::IO, y::GrpElem{G}) where G
    print(io, join(gen_format.([(y.front)..., y.final]), cfg.element_sep))
end

Base.eltype(::Type{GrpElem{G}}) where G<:Group = Gen{G}
Base.iterate(x::GrpElem{G}) where G<:Group = flatten((x.front, x.final))
Base.length(x::GrpElem{G}) where G<:Group = sizeof(x)
    