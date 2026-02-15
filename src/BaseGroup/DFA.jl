using Automa

begin #Tokenizer
    tokens = [
        :lparens => re"\(",
        :rparens => re"\)", 
        :lbracket => re"\[",
        :rbracket => re"\]", 
        :comma => re",",
        :quot => re"\"",
        :space => re" +",
        :letters => re"[a-zA-Z]+",
        :number => re"[1-9]+"
    ]
    @eval @enum Token error $(first.(tokens)...)
    make_tokenizer((error, 
        [Token(i) => j for (i,j) in enumerate(last.(tokens))]
    )) |> eval

    collect(tokenize(Token, "[11211,1342,4]"))

end

([1,2,3].|>x->"$x") |> x->join(x,",")

@enum Fgens f g h

struct FreeGroup{N}
    ngens::UInt
    gens::Enum
end

struct Seq
           name::String
           seq::String
end

machine = let
           header = onexit!(onenter!(re"[1-9]+", :mark_pos), :header)
           seqline = onexit!(onenter!(re"[ACGT]+", :mark_pos), :seqline)
           record = onexit!(re"" * header * '\n' * rep1(seqline * '\n'), :record)
           compile(rep(record))
end;

actions = Dict(
           :mark_pos => :(pos = p),
           :header => :(header = String(data[pos:p-1])),
           :seqline => :(append!(buffer, data[pos:p-1])),
           :record => :(push!(seqs, Seq(header, String(buffer))))
       );

@eval function parse_fasta(data)
    pos = 0
    buffer = UInt8[]
    seqs = Seq[]
    header = ""
    $(generate_code(machine, actions))
    return seqs
end

parse_fasta("$([1,1,1]...)\nA\n")

