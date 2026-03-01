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

function (ϕ::Hom{G1, G2})(g::AbstractElement) where {G1<:AbstractGroup, G2<:AbstractGroup} 
    # g.parent==ϕ.dom || error("$g is not in the domain of $ϕ = $(ϕ.dom)")
    mapping = ϕ.image
    prod([ϕ.codom(mapping[x]) for x in g.word])
end

function Base.:∘(ϕ1::Hom{G2,G3}, ϕ2::Hom{G1, G2})::Hom{G1,G3} where {G1<:AbstractGroup, G2<:AbstractGroup, G3<:AbstractGroup} 

    #TODO! Add check that codom ϕ1 = dom ϕ2
    Hom(ϕ2.dom, ϕ1.codom, Tuple(
        g=>ϕ2(ϕ2.dom(h)) for (g,h) in pairs(ϕ1.image)
    ))

end

function Base.:|>(ϕ1::Hom{G1,G2}, ϕ2::Hom{G2, G3})::Hom{G1,G3} where {G1<:AbstractGroup, G2<:AbstractGroup, G3<:AbstractGroup}  
    ϕ2∘ϕ1
end



function Base.show(io::IO, ϕ::Hom{G1, G2}) where  {G1<:AbstractGroup, G2<:AbstractGroup} 
    gen_image = [g=>ϕ(g) for g in GPC.gens(ϕ.dom)]

    
    repr_string = join(["|\t$(ϕ.dom(x)) -→  $(repr(ϕ.codom(y), context=IOContext(io, :compact=>true)))" for (x,y) in gen_image], "\n")
    print(io,"""
   ϕ : $(repr(ϕ.dom, context=IOContext(io, :compact=>true))) ---→ $(repr(ϕ.codom, context=IOContext(io, :compact=>true)))
   """*"""
   $repr_string
   (Group Homomorphism)
    """)
end




# const Aut{G} = Hom{G, G} where G


