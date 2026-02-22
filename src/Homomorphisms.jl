struct GroupHom end
struct MonoidHom end
const AnyHom = Union{GroupHom, MonoidHom}

struct Hom{G1<:GPC.Group, G2<:GPC.Group, TYP<:AnyHom} 
    dom::G1
    codom::G2
    image::Dict{Int, KB.Words.AbstractWord}
    # function Hom(H1::G1, H2::G2, ϕ::NTuple{N, Pair}) where {G1<:GPC.Monoid, G2<:GPC.Monoid, N} 

    #     image = ITR.map(ϕ) do x, y
    #         @show length(H1(x).word) > 1 && error("$x is not a generator of $(repr(H1, context=IOContext(io, :compact=>true)))")
    #         (only(H1(x).word)|>Int => H2(y).word) =>
    #         (only(inv(H1(x)).word)|>Int => inv(H2(y)).word)
    #     end
    #     image = Dict(join([first.(image)]))
        
    #     new{G1, G2, MonoidHom}(H1, H2, image)
    # end
    function Hom(H1::G1, H2::G2, ϕ::NTuple{N, Pair}) where {G1<:GPC.Group, G2<:GPC.Group, N} 

        image = ITR.flatmap(ϕ) do pair
            x, y = pair
            # length(H1(x).word) > 1 && error("$x is not a generator of $(repr(H1, context=IOContext(io, :compact=>true)))")
            (only(H1(x).word)|>Int => H2(y).word),
            (only(inv(H1(x)).word)|>Int => inv(H2(y)).word)
        end |> Dict
        

        isempty(symdiff(keys(image), (GPC.gens(H1)∪inv.(GPC.gens(H1))).|>x->Int(only(x.word)))) || error("Invalid homomorphism definition")

        new{G1, G2, GroupHom}(H1, H2, image)
    end

end

function (ϕ::Hom{G1, G2, TYP})(g::GPC.MonoidElement) where {G1<:GPC.Group, G2<:GPC.Group, TYP<:GroupHom} 
    # g.parent==ϕ.dom || error("$g is not in the domain of $ϕ = $(ϕ.dom)")
    mapping = ϕ.image
    prod([ϕ.codom(mapping[x]) for x in g.word])
end

function Base.show(io::IO, ϕ::Hom{G1, G2, TYP}) where  {G1<:GPC.Group, G2<:GPC.Group, TYP<:GroupHom} 
    gen_image = [g=>ϕ(g) for g in GPC.gens(ϕ.dom)]
    repr_string = join(["|\t $(ϕ.dom(x)) -→ $(ϕ.codom(y)) \t|" for (x,y) in gen_image], "\n")
    print(io,"""
   ϕ : $(repr(ϕ.dom, context=IOContext(io, :compact=>true))) ---→ $(repr(ϕ.codom, context=IOContext(io, :compact=>true)))
   """*"""
   $repr_string
   (Group Homomorphism)
    """)
end

function Base.show(io::IO, ϕ::Hom{G1, G2, TYP}) where  {G1<:GPC.Group, G2<:GPC.Group, TYP<:MonoidHom} 
    repr_string = join(["|\t $(ϕ.dom(x)) -→ $(ϕ.codom(y)) \t|" for (x,y) in pairs(ϕ.image)], "\n")
    print(io,"""
   ϕ : $(repr(ϕ.dom, context=IOContext(io, :compact=>true))) ---→ $(repr(ϕ.codom, context=IOContext(io, :compact=>true)))
   """*"""
   $repr_string
   (Monoid Homomorphism)
    """)
end




# const Aut{G} = Hom{G, G} where G


