abstract type  Group end
# function inverse(g::G<:Group)
#     error("inverse not yet implemented")
# end


struct FreeGroup<:Group 
    gens::Vector{Symbol}
end



struct ID end

eltype(::Type{<:AbstractArray{T}}) where {T} = T
@enum Klein4Group begin
    h
    p
    v
end

function hom()
    
end

# struct Semidirect
#     e1::GroupElem
#     e2::Klein4Group
# end



struct GroupGen
    key::Union{ID,Symbol}
    value::Integer 
    GroupGen(x::Symbol,y::Integer) = x!=:id ?  new(x,y) : new(:id, 0)
    GroupGen(x) = x!=:id ?  new(x,1) : new(:id, 0)
end

struct GroupElem
    elems::Vector{GroupGen}
    final::GroupGen
    function GroupElem(x)
        y = filter(s->s.key!=:id, x)
        length(y)==0 ? new([id], id) : new(y, y[end])
    end
end

function inverse(s::GroupGen, FLAG::Bool=true)::GroupGen
    FLAG ? GroupGen(s.key, -s.value) : s
end


g = GroupGen(:g)
f = GroupGen(:f)
F = inverse(f)
G = inverse(g)


struct Hom
    mapping::Dict{Symbol, Union{GroupGen,GroupElem}}
end

# struct ID1 end

id = GroupGen(:id, 0)

function (ϕ::Hom)(g::GroupGen)
    (ϕ::Hom)(GroupElem([g]))
end

function (ϕ::Hom)(g::GroupElem)
    reduce(*,flatmap(g.elems) do x
        fill(inverse(ϕ.mapping[x.key], x.value<0), abs(x.value))
    end, init=id)
end

function K4_action(k::Klein4Group)
    getindex(Dict([
        h::Klein4Group => Hom(Dict([:f => F, :g => G])),
        p::Klein4Group => Hom(Dict([:f => G, :g => F])),
        v::Klein4Group => Hom(Dict([:f => g, :g => f])),
    ]), k)  
end   

GroupGen(x) = GroupGen(x, 1)

function inverse(g::GroupElem, FLAG::Bool = true)::GroupElem
    GroupElem(map(Base.Fix2(inverse, FLAG), reverse(g.elems)))
end 

function Base.:*(x::GroupGen, y::GroupGen)::Union{GroupGen, GroupElem}
    if x.key == y.key
        return GroupElem([GroupGen(x.key, x.value+y.value)])
    else
        return GroupElem([x,y])
    end        


end


function Base.:*(x::GroupElem, y::GroupGen)::GroupElem
    if x.final.key == y.key
        new_end = x.final * y
        return GroupElem([x.elems[1:end-1]..., new_end])

    else
        return GroupElem([x.elems..., y])
    end        

end

function Base.:*(x::GroupElem, y::GroupElem)::GroupElem
    v = copy(y.elems)
    reduce(Base.:*, v, init=x)
end

function Base.:*(x::Klein4Group, y::Klein4Group)::Klein4Group

end


inv_map = Dict([:f=>:F, :g=>:G])

Base.show(io::IO, ::MIME"text/plain", x::GroupGen) = print(io, "$(x.key)[$(x.value)]")
function Base.show(io::IO, ::MIME"text/plain", y::GroupElem)
    element = reduce(Base.:*, map(x-> "$(x.value>0 ? x.key : inv_map[x.key])"*"$(abs(x.value) ≠ 1 ? x.value : "")", y.elems), init="")
    print(io, "Element: $element")
end







