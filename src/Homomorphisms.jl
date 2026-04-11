struct GroupHom end
struct MonoidHom end
const AnyHom = Union{GroupHom, MonoidHom}

struct Hom{G1<:AbstractGroup, G2<:AbstractGroup} 
    dom::G1
    codom::G2
    image::Dict{UInt, KB.Words.AbstractWord}

    function Hom(H1::G1, H2::G2, ϕ::NTuple{N, Pair}) where {G1<:AbstractGroup, G2<:AbstractGroup, N} 

        image = ITR.flatmap(ϕ) do pair
            x, y = pair
            (only(H1(x).word) => H2(y).word),
            (only(inv(H1(x)).word) => inv(H2(y)).word)
        end |> Dict
        

        isempty(symdiff(keys(image), (GPC.gens(H1)∪inv.(GPC.gens(H1))).|>x->Int(only(x.word)))) || error("Invalid homomorphism definition")

        new{G1, G2}(H1, H2, image)
    end

end


function (ϕ::Hom{G1, G2})(g::Farey.FreeGroupElement) where {G1<:AbstractGroup, G2<:AbstractGroup} 
    # g.parent==ϕ.dom || error("$g is not in the domain of $ϕ = $(ϕ.dom)")
    mapping = ϕ.image
    prod([ϕ.codom(mapping[x]) for x in g.word], init=one(g.parent))
end

function Base.:|>(ϕ1::Hom{G2,G3}, ϕ2::Hom{G1, G2})::Hom{G1,G3} where {G1<:AbstractGroup, G2<:AbstractGroup, G3<:AbstractGroup} 

    #TODO! Add check that codom ϕ1 = dom ϕ2
    Hom(ϕ2.dom, ϕ1.codom, Tuple(
        g=>ϕ2(ϕ2.dom(h)) for (g,h) in pairs(ϕ1.image)
    ))

end

function Base.:∘(ϕ1::Hom{G1,G2}, ϕ2::Hom{G2, G3})::Hom{G1,G3} where {G1<:AbstractGroup, G2<:AbstractGroup, G3<:AbstractGroup}  
    ϕ2|>ϕ1
end

function Base.:(*)(ϕ1::Hom{G2,G3}, ϕ2::Hom{G1, G2})::Hom{G1,G3} where {G1<:AbstractGroup, G2<:AbstractGroup, G3<:AbstractGroup} 
    ϕ1∘ϕ2
end



function Base.:(^)(m::Hom{G1,G1}, n::Integer)::Hom{G1,G1} where {G1<:AbstractGroup, }
    n == 0 && return Hom(m.dom, m.codom, [g=>g for g in GPC.gens(m.dom)]|>Tuple)
    n==1 && return m
    n < 0 && error("inverses not implemented")
    return Base.power_by_squaring(m, n)
end


function Base.:(^)(m::Hom{G1,G2}, g::AbstractGroupElement)::Hom{G1,G2} where {G1<:AbstractGroup,G2<:AbstractGroup }
    return Hom(m.dom, m.codom, [x=>(m.codom(y)^g).word for (x,y) in m.image]|>Tuple)
end

function Base.show(io::IO, ϕ::Hom{G1, G2}) where  {G1<:AbstractGroup, G2<:AbstractGroup} 
    gen_image = [g=>ϕ(g) for g in GPC.gens(ϕ.dom)]

    
    repr_string = join(["|\t$(ϕ.dom(x)) -→  $(repr(ϕ.codom(y), context=IOContext(io, :compact=>true)))" for (x,y) in gen_image], "\n")
    print(io,"""
   :$(repr(ϕ.dom, context=IOContext(io, :compact=>true))) ---→ $(repr(ϕ.codom, context=IOContext(io, :compact=>true)))
   """*"""
   $repr_string
   (Group Homomorphism)
    """)
end




# const Aut{G} = Hom{G, G} where G


