module SuffixTrees
    using FixedSizeArrays
    using ..Monoids
    using ..Interfaces:AbstractElement,AbstractMonoidElement
    using Farey:FreeGroupElement
    include("alphabet.jl")


    abstract type AbstractNode end
    abstract type AbstractTree end
    const ALPHABET_SIZE = 2 * 0xff
    const FINAL_CHAR = (ALPHABET_SIZE)
    const FINAL_SYM = "#"
    
#
mutable struct SuffixNode <: AbstractNode
    position::Int
    len::Int
    parent::Int
    suffix::Bool
    label::String
    next::FixedSizeArray{Int}
    slink::Int

    function SuffixNode(
        position::Int,
        parent::Int,
        suffix::Bool,
        label::String;
        len::Int=-1,
        slink::Int=0
    )
        next = FixedSizeVector{Int}(undef, ALPHABET_SIZE)
        next .= 0
        new(position, len, parent, suffix, label, next, slink)

    end
end


#
        # function iterate(tr::SuffixTree{T})
        #     root = tr[0]
        #     edge = find(>(0), root.next)
        #     tr.len==0 && return (tr[0], nothing)
        #     return (tr[0], (;node = 0, edge = edge, pos = 0))
        # end

        # function iterate(tr::SuffixTree{T}, state)
        #     state.edge === nothing  && return nothing 
        #     node = tr[state.node].parent
        #     pos = node.position
        #         node = tr[state.node].next[state.edge]

        #     next_edge = findnext(>(0), tr[state.node].next, state.edge+1)
        #         # next_edge === nothing
        #     # nxtNd = findnext(>(0), tr[state.node].next)

        # end

        # function iterate(tr::SuffixTree{T}, state)

        #   depth = 1
        #   parent = 0
        #   stack = []
        #   spaceb = " |  "
        #   spaced = " ⊕  "
        #   [pushfirst!(stack, (0, x...)) for x in children(root)]
        #   while !isempty(stack)
        #     (parent, cr, ndix) = popfirst!(stack)
        #     cr==FINAL_CHAR && continue
        #       nd = tr[ndix]

        #       edgename =  nd.position > tr.lw ?  error("Oh no,,, I have added an implementation error :(") : 
        #               nd.len>-1           ?   repr(Gr(tr.word[nd.position:nd.position+nd.len-1])) : 
        #                                       repr(Gr(tr.word[nd.position:end]))*Char(FINAL_CHAR)


        #       # subword = Gr(tr.word[node_word(tr, ndix):nd.position-1])*edge


        #       chdn = children(nd)
        #       if parent < depth-1
        #           out *=  (spaceb)^(parent+1)*
        #                   (spaced)^(depth-parent-2)*
        #                   "\n"
        #       end
        #       out *=  (spaceb)^(parent+1)*
        #               "\n"

        #       depth = parent+1
        #       spacer =(spaceb)^(parent) 
        #       nodename = "<$(nd.label)>"

        #       if isempty(chdn)
        #           edgearrow = " ⋅--($edgename)-"
        #       else
        #           edgearrow = " ⨁--($edgename)-"
        #           suff = nd.next[FINAL_CHAR]
        #           if suff>0
        #             nodename *= "--($FINAL_SYM)-<$(tr[suff].label)>"
        #           end
        #         [pushfirst!(stack, (depth, x...)) for x in chdn]
        #       end
        #       out *=  spacer*
        #               edgearrow*
        #               nodename*"\n"
        #   end
        # end

        # length(itr::Accumulate) = length(itrtr.itr)
        # size(itr::Accumulate) = size(itr.itr)

        # IteratorSize(::Type{<:Accumulate{<:Any,I}}) where {I} = IteratorSize(I)
        # IteratorEltype(::Type{<:Accumulate}) = EltypeUnknown()
mutable struct SuffixTree{T} <: AbstractTree where {T}
    word::T
    tree::Vector{SuffixNode}
    len::Int
    lw::Int

    function SuffixTree{T}(
        word::T,
        tree::Vector{SuffixNode},
        len::Int
    ) where T

        new{T}(word, tree, len, length(word))

    end

end

function Base.getindex(tr::AbstractTree, i::Integer)
    tr.tree[i+1]
end

function Base.getindex(tr::AbstractTree, i::AbstractUnitRange)
    tr.tree[i.+1]
end

function edgelength(nd::SuffixNode, idx)
    nd.len > -1 ? nd.len : idx - nd.position
end

function edgelength(tr::AbstractTree, nd::SuffixNode)
    nd.len > -1 ? nd.len  : tr.lw - nd.position+1
end

function edgelength(tr::AbstractTree, nd::Int)
    edgelength(tr, tr[nd])
end

text(tr::SuffixTree{S}, pos::Int) where S<:AbstractElement = pos > tr.lw ? FINAL_CHAR : genId(word(tr.word)[pos])::Int

text(tr::SuffixTree{S}, pos::Int) where S<:FreeGroupElement = pos > tr.lw ? FINAL_CHAR : Int(word(tr.word)[pos])::Int

text(tr::SuffixTree{S}, pos::Int) where S<:AbstractString = pos > tr.lw ? FINAL_CHAR : Int(tr.word[pos])::Int

function text(tr::SuffixTree{S})::Vector{Int} where S<:FreeGroupElement
    Int[Int(x) for x in tr.word.word]
end

function text(tr::SuffixTree{S})::Vector{Int} where S<:AbstractMonoidElement
    Int[genId(x) for x in Monoids.eachgen(tr.word)]
end

function genId(x::AbstractMonoidElement)::Int
    x.id < 0xff || error("$(x.id) ($x) is an invalid index for building suffix trees (ALPHABET_SIZE = $ALPHABET_SIZE)")
    x.exp == 1 && return Int(x.id)
    x.exp == -1 && return 0xff + Int(x.id) -1

end

function text(tr::SuffixTree{S})::Vector{Int} where S<:AbstractString
    Int[Int(x) for x in tr.word]
end

function next(tr::SuffixTree, t::Int, len::Int; idx::Int=0)::Tuple{Int, Int}
    txt = text(tr)
    edge = 1
    lx = length(x)
    while true

    nxt = tr[idx].next[x[edge]]
    nxt == 0 && return (0, 0)
    len = min(edgelength(tr, nxt), lx - edge+1)-1
    pos = tr[nxt].position
    (txt[pos:pos+len]==x[edge:edge+len]) || return (0, 0)
    
    idx = nxt
    edge+len < lx || break
    edge += len+1
    end
    

    return idx, edge
end
function walktree(tr::SuffixTree, x::Vector{Int}; idx::Int=0)::Tuple{Int, Int}
    txt = text(tr)
    edge = 1
    lx = length(x)
    while true

    nxt = tr[idx].next[x[edge]]
    nxt == 0 && return (0, 0)
    len = min(edgelength(tr, nxt), lx - edge+1)-1
    pos = tr[nxt].position
    (txt[pos:pos+len]==x[edge:edge+len]) || return (0, 0)
    
    idx = nxt
    edge+len < lx || break
    edge += len+1
    end
    

    return idx, edge
end

function next(tr::SuffixTree,  pos::Int;idx::Int=0)::Int 
    edge = text(tr, pos)
    tr[idx].next[edge]
end

    # function walktree(tr::SuffixTree, itr::I)::Int where I
    #     node = 0
    #     edge = 0
    #     len = 0
    #     for x in itr
    #         if len == 0
    #             edge = x
    #             nxt  = tr[node].next[x]
    #             nxt == 0 && return node
    #             node = nxt
    #             len  = edgelength(tr, nxt)
    #         else
                
    #         end

    #     end
    #     return node
    # end
    
# function πw(tr, txt::Vector{Int})::Int

#     node, edge = walktree(tr, txt)
#     node == 0 ? -1 : nodepath(tr, node)
# end

function wordtext(syms::Vector{Int}, init::String)::String
    prod(Char.(syms + 1), init=init)
end

function suffixes(tr::SuffixTree)
    filter(nd -> nd.suffix, tr.tree)
end


function arrow(nd::AbstractNode, tr::AbstractTree)
    nd.len > -1 ? tr.word[nd.position:nd.position+nd.len-1] :
    tr.word[nd.position:end]
end

function Base.push!(tr::AbstractTree, nd::AbstractNode)
    push!(tr.tree, nd)
    tr.len += 1
    tr.len
end


function nodepath(tr::AbstractTree, idx::Int)
    nodepath(tr, tr[idx])
end

function nodepath(tr::AbstractTree, node::AbstractNode)
    wordl = node.position

    while node.parent != 0
        node = tr[node.parent]
        wordl -= node.len
    end
    wordl
end

function issuffix(tr::AbstractTree, idx::Int)::Bool
    nd = tr[idx]
    nd.suffix || nd.next[FINAL_CHAR] > 0       
end

function children(nd::AbstractNode)
    out = [(k, nd.next[k]) for k in findall(nd.next .!= 0)]
    reverse!(out)
end

function Base.show(io::IO, nd::AbstractNode)

    finish = nd.len == -1 ? "#" : nd.len + nd.position

    sl = nd.slink > 0 ? "-SL→⋅ $(nd.slink)" : "----⋅"
    nodename = join([
            # "{\n",
            "Node:  <$(nd.label)>",
            "⋅----⋅",
            "⋅<$(nd.parent)>",
            " ╲",
            "  ⋅→-{$(nd.position):$(finish)}-<$(nd.label)>",
            "⋅$sl",
            # "|-SL→ $slink;\n"
            # "}\n" 
        ], "\n")
    print(io, nodename)
end

    function subword(tr::SuffixTree{S}, idx::Int) where S
        nd = tr[idx]
        subword(tr, nd)
    end

function subword(tr::SuffixTree{S}, nd::AbstractNode) where S<:AbstractString

    edge = nd.position > tr.lw ? "" :
        nd.len > -1 ? "$(tr.word[nd.position:nd.position+nd.len-1])" :
        "$(tr.word[nd.position:end])"
    "$((tr.word[nodepath(tr, nd):nd.position-1])|>prod)" * edge
end

function printpath(tr::SuffixTree{S}, idx::Int) where S
    nd = tr[idx]
    label1 = nd.label

    # out = "\n⋅→-<$(nd.label)>\n↓\n"
    wd = subword(tr, nd)
    out = (nd.suffix ? "" : " ↓ ($(length(children(nd))) suffixes)\n|" * " "^(length(repr(wd))) * join(["  + ($(tr.word[tr[k].position:end])$FINAL_SYM)\n" for (_, k) in children(nd)], "|" * " "^(length(repr(wd))))) * "$FINAL_SYM\n⋅-⊕\n"

    # out = "⋅-{$(edgeword(tr, idx))}→-<$(nd.label)> \n"
    # out*= "⋅--{$(edgeword(tr, idx))}: $(subword(tr, idx))\n"
    while true
        # $(subword(tr, nd))
        edg = edgeword(tr, nd)
        out = "\n| $wd" * out
        # out = "\n"*out
        out = "\n⋅→-<$(nd.label)>" * out
        out = "\n|" * out
        out = " + ($(edg))" * out
        # out = "\n|"*out

        nd.parent != 0 || break
        nd = tr[nd.parent]
        wd = subword(tr, nd)
        out = "  : $(edg[1])...\n⋅-" * "-"^(length(repr(wd))) * "→" * out


    end
    out = "\nPath: <root>→-<$(label1)> : '$(subword(tr, idx))'\n⋅→-<root>\n|" * out


    out
end

function finish(tr::SuffixTree{S}, idx::Int) where S
    nd = tr[idx]
    nd.len == -1 && return tr.lw
    nd.position + nd.len - 1
end



    # function Base.show(io::IO, tr::SuffixTree{S}) where S<:AbstractString
    #     word = tr.word
    #     out = """Suffix Tree of '$(word)'\n"""
    #     root = tr[0]
    #     depth = 1
    #     parent = 0
    #     stack = []
    #     spaceb = " |  "
    #     spaced = " ⊕ "
    #     [pushfirst!(stack, (0, x...)) for x in children(root)]
    #     while !isempty(stack)
    #         (parent, cr, ndix) = popfirst!(stack)

    #         nd = tr[ndix]

    #         edge =  nd.position > tr.lw ?   Char.(FINAL_CHAR) :
    #                 nd.len>-1           ?   "$(word[nd.position:nd.position+nd.len-1])" : 
    #                                         "$(word[nd.position:end])~"

    #         subword = "$(word[node_word(tr, ndix):nd.position-1])"*edge

    #         edgename = edge

    #         chdn = children(nd)
    #         if parent < depth-1
    #             out *=  (spaceb)^(parent+1)*
    #                     (spaced)^(depth-parent-2)*
    #                     "\n"
    #         end
    #         out *=  (spaceb)^(parent+1)*
    #                 "\n"

    #         depth = parent+1
    #         spacer =(spaceb)^(parent) 

    #         if isempty(chdn)
    #             edgearrow = " ⋅--($edgename)-"
    #         else
    #             edgearrow = " ⨁--($edgename)-"
    #             [pushfirst!(stack, (depth, x...)) for x in chdn]
    #         end
    #         out *=  spacer*
    #                 edgearrow*
    #                 "<$(nd.label)>:[$(nd.position)]\n"

    #     end

    #     print(io, out)
    # end

function reprtree(tr::AbstractTree)
    root = tr[0]
    depth = 1
    parent = 0
    stack = []
    [pushfirst!(stack, (0, x...)) for x in children(root)]

    out = "Suffix Tree: $(prod(Char.(tr.word)))\n"
    # out *=  " ⨁-⋅-⋅-⋅-⋅-⋅-⋅-⋅-⋅-⋅-⨁\n"
    out *= " ⊕-⋅{root}\n"
    # out *=  " |\n"
    # out *=  "( )\n"
    ltxt = 1
    spacea = " ↓" * " "^(ltxt)
    spaceb = " |" * " "^(ltxt)
    spaced = " ⊕" * " "^(ltxt)

    while !isempty(stack)
        (parent, cr, ndix) = popfirst!(stack)

        nd = tr[ndix]

        edge = nd.position > tr.lw ? "" :
            nd.len > -1 ? "$((tr.word[nd.position:nd.position+nd.len-1]))" :
            "$((tr.word[nd.position:end]))"


        suffix = nd.suffix ? "$FINAL_SYM" : "..."
        subword = "$(Char.(tr.word[node_word(tr, ndix):nd.position-1])|>prod)" * edge * suffix
        slink = (nd.slink == 0 ? "?" : nd.slink)
        edgename = edge

        chdn = children(nd)
        if parent < depth - 1
            out *=
                (spaceb)^(parent + 1) *
                (spaced)^(depth - parent - 1) *
                # (spaced)^(depth-parent-1)*
                "\n"
        end
        out *=
            (spaceb)^(parent + 1) *
            # spacea*
            "\n"

        # out *= (space)^(parent)*" ↓\n"#*(spaced)^(depth-parent)*"\n"
        depth = parent + 1
        spacer = (spaceb)^(parent)
        spacerd = (spaced)^(parent)
        if isempty(chdn)
            edgearrow = " ⋅-($edgename)→ ⋅"
            sep = spacer * " |" * " "^(length(edgename) + 5)
        else
            edgearrow = " ⨁-($edgename)- ⋅"
            sep = spacer * spaceb * " |" * " "^(length(edgename) + 2)
            [pushfirst!(stack, (depth, x...)) for x in chdn]
        end
        nodename = join([
                # "{\n",
                "<$(nd.label) : {$subword}>\n",
                "|-SL→ $slink\n",
                "⋅----\n",
                # "|-SL→ $slink;\n"
                # "}\n" 
            ], sep)
        out *= spacer *
            edgearrow *
            nodename

    end

    out *= " ⊕\n"
    out

end

function extend_suffix!(
    tr::SuffixTree{S},
    c::Integer,
    idx::Int;
    active_node::Int=0,
    active_e::Int=0,
    active_len::Int=0,
    rem::Int=0
) where S

    needs_link = 0
    txt = [text(tr)..., FINAL_CHAR]
    rem += 1

    while rem > 0
        active_e = (active_len == 0) ? idx : active_e
        edge = txt[active_e]
        nxt = (active_e == 0) ? 0 : tr[active_node].next[edge]

        edg_l = edgelength(tr[nxt], idx)
        if (nxt == 0)
            let nd = SuffixNode(idx, active_node, true, "$(tr.len+1)")
                leaf = push!(tr, nd)

                tr[active_node].next[edge] = leaf
                if (needs_link > 0)
                    tr[needs_link].slink = active_node
                end
                needs_link = active_node
            end
        elseif (active_len >= edg_l)
            active_e += edg_l
            active_len -= edg_l
            active_node = nxt
            continue
        elseif (txt[tr[nxt].position+active_len] == c)
            active_len += 1
            if (needs_link > 0)
                tr[needs_link].slink = active_node
            end

            return active_node, active_e, active_len, rem
        else
            let splitnd = SuffixNode(tr[nxt].position, active_node, false, "$(tr.len+1)"; len=active_len)
                split = push!(tr, splitnd)
                tr[active_node].next[edge] = split

                leafnd = SuffixNode(idx, split, true, "$(tr.len+1)")

                leaf = push!(tr, leafnd)
                tr[split].next[c] = leaf
                tr[nxt].position += active_len
                if tr[nxt].len > -1
                    tr[nxt].len -= active_len
                end
                tr[split].next[txt[tr[nxt].position]] = nxt

                tr[nxt].parent = split

                if (needs_link > 0)
                    tr[needs_link].slink = split
                end
                needs_link = split

            end
        end

        rem -= 1
        if (active_node == 0 && active_len > 0)
            active_len -= 1
            active_e = idx - rem + 1
        else
            # active_node = tr[active_node].slink > 0 ? tr[active_node].slink : 0
            active_node = tr[active_node].slink
        end

    end

    return active_node, active_e, active_len, rem
end


function _build_tree!(tr::SuffixTree{S}) where S
    rem::Int = 0
    nde::Int = 0
    edg::Int = 0
    suflen::Int = 0
    word = text(tr)
    for (idx, c) = enumerate(word)
        nde, edg, suflen, rem =
            extend_suffix!(
                tr, c, idx;
                active_node=nde,
                active_e=edg,
                active_len=suflen,
                rem=rem,
            )
    end

    nde, edg, suflen, rem =
        extend_suffix!(
            tr, FINAL_CHAR, tr.lw + 1;
            active_node=nde,
            active_e=edg,
            active_len=suflen,
            rem=rem,
        )

end

function SuffixTree(w::S)::SuffixTree{S} where S
    root = SuffixNode(1, 0, false, "root"; len=0)
    tr = SuffixTree{S}(w, SuffixNode[root], 0)

    _build_tree!(tr)
    tr

end


function Base.show(io::IO, tr::SuffixTree)
    #   Gr = tr.word.parent
    out = """Suffix Tree of $(tr.word)\n"""
    root = tr[0]
    depth = 1
    parent = 0
    stack = []
    spaceb = " |  "
    spaced = " ⊕  "
    [pushfirst!(stack, (0, x...)) for x in children(root)]
    while !isempty(stack)
        (parent, cr, ndix) = popfirst!(stack)
        cr == FINAL_CHAR && continue
        nd = tr[ndix]

        edgename = nd.position > tr.lw ? error("Oh no,,, I have added an implementation error :(") :
                nd.len > -1 ? "$(tr.word[nd.position:nd.position+nd.len-1])⋅⋅⋅" :
                "$(tr.word[nd.position:end])$FINAL_SYM"

        edgelabel = "$(tr.word[nd.position])"
        finish = nd.len > -1 ? nd.position + nd.len : "#"

        # subword = Gr(tr.word[node_word(tr, ndix):nd.position-1])*edge


        chdn = children(nd)
        if parent < depth - 1
            out *= (spaceb)^(parent + 1) *
                (spaced)^(depth - parent-1) *
                "\n"
        end
        #   out *=  (spaceb)^(parent+1)*
        # "\n"

        depth = parent + 1
        spacer = (spaceb)^(parent)
        nodename = "<$(nd.label)>"#*"[$(nd.position):$finish]"

        if isempty(chdn)
            # out *= spacer * " |\n"
            out *= "$(spacer)$spaceb \n"
            edgearrow = " ⋅→-($edgename)-⋅"
            #   edgearrow = " ⋅-$edgename-" 
            out *= spacer *
                edgearrow *
                nodename * " : $(subword(tr, ndix))$FINAL_SYM\n"
            out *= "$(spacer)$spaceb \n"
                # out *= "$(spacer)$(spaceb) ⋅-→⋅($edgename) \n"#*"[$(tr[suff].position):#]\n"
                # out *= "$(spacer)$(spaceb) |   ╲ \n"
                # out *= "$(spacer)$(spaceb) |    ⋅$(nodename) = $(subword(tr, ndix))\n"
                # out *= "$(spacer)$(spaceb) |   \n"
        else

            # out *= spacer * " |   ($edgelabel)\n"
            out *= spacer * " ⋅" * "\n"
            out *= spacer * " |╲ " * "\n"
            out *= spacer * " | ⋅-($edgename)" * "\n"
            out *= spacer * " |  ╲ " * "\n"
            out *= spacer * " |   ⋅ $nodename" * " : $(subword(tr, ndix))...\n"
            out *= spacer * "$spaceb ↓\n"
            # out *= "$(spacer) |  ⋅\n"
            suff = nd.next[FINAL_CHAR]
            if suff > 0
                # nodename *= "\n$spacer$spaceb\n$spacer$spaceb ⋅--[$FINAL_SYM]→-<$(tr[suff].label)>[$(tr[suff].position)]"

                out *= "$(spacer)$(spaceb) ⋅→-⋅($FINAL_SYM)-⋅<$(tr[suff].label)> : $(subword(tr, tr[ndix].next[FINAL_CHAR]))$FINAL_SYM\n"#*"[$(tr[suff].position):#]\n"
                out *= "$(spacer)$(spaceb) |   \n"
                filter!(x->x[2]!=FINAL_CHAR, chdn)
            end

            [pushfirst!(stack, (depth, x...)) for x in chdn]
        end

    end
    out *= spaced^(depth)
    print(io, out)
end

function edgeword(tr::SuffixTree{S}, idx::Int) where S
    nd = tr[idx]
    subwd = nd.len > -1 ? tr.word[nd.position:nd.position+nd.len-1] :
            tr.word[nd.position:end]
    subwd
end

function edgeword(tr::SuffixTree{S}, nd::AbstractNode) where S
    subwd = nd.len > -1 ? tr.word[nd.position:nd.position+nd.len-1] :
            tr.word[nd.position:end]
    subwd
end


function subword(tr::SuffixTree{S}, node::AbstractNode) where S<:AbstractElement
    word = edgeword(tr, node)

    while node.parent != 0
        word = edgeword(tr, node.parent) * word
        node = tr[node.parent]
    end
    word
end


function reprtree(tr::SuffixTree{S}) where S<:AbstractElement
    Gr = tr.word.parent
    root = tr[0]
    depth = 1
    parent = 0
    stack = []
    [pushfirst!(stack, (0, x...)) for x in children(root)]

    out = "Suffix Tree: $(Gr(tr.word))\n"
    # out *=  " ⨁-⋅-⋅-⋅-⋅-⋅-⋅-⋅-⋅-⋅-⨁\n"
    out *= " ⊕-⋅{root}\n"
    # out *=  " |\n"
    # out *=  "( )\n"
    ltxt = 1
    spacea = " ↓" * " "^(ltxt)
    spaceb = " |" * " "^(ltxt)
    spaced = " ⊕" * " "^(ltxt)

    while !isempty(stack)
        (parent, cr, ndix) = popfirst!(stack)

        nd = tr[ndix]

        edge = nd.position > tr.lw ? one(Gr) :
            nd.len > -1 ? (Gr(tr.word[nd.position:nd.position+nd.len-1])) :
            (Gr(tr.word[nd.position:end]))


        suffix = nd.suffix ? "" : "_"
        subwd = Gr(tr.word[node_word(tr, ndix):nd.position-1]) * edge
        subword = isempty(subwd.word) ? suffix : repr(subwd) * suffix
        # subwordname
        slink = (nd.slink == 0 ? "?" : nd.slink)
        edgename = isempty(edge.word) ? "$(Char(FINAL_CHAR))" : repr(edge)

        chdn = children(nd)
        if parent < depth - 1
            out *=
                (spaceb)^(parent + 1) *
                (spaced)^(depth - parent - 1) *
                # (spaced)^(depth-parent-1)*
                "\n"
        end
        out *=
            (spaceb)^(parent + 1) *
            # spacea*
            "\n"

        depth = parent + 1
        spacer = (spaceb)^(parent)
        spacerd = (spaced)^(parent)
        if isempty(chdn)
            edgearrow = " ⋅-($edgename)→"
            sep = spacer * spaceb * " "^(length(edgename) + 4)
        else
            edgearrow = " ⨁-($edgename)-"
            sep = spacer * spaceb * " | " * " "^(length(edgename) + 1)
            [pushfirst!(stack, (depth, x...)) for x in chdn]
        end
        nodename = join([
                "<$(nd.label)>\n",
                # "|\n",
                "⋅-$("-"^length(subword))⋅\n",
                "|$subword |\n",
                "⋅-$("-"^length(subword))⋅\n",
            ], sep)
        out *= spacer *
            edgearrow *
            nodename

    end

    out *= " ⊕\n"
    print(out)

end


function showtree(tr::SuffixTree)
    #   Gr = tr.word.parent
    out = """Suffix Tree of $(tr.word)\n"""
    root = tr[0]
    depth = 1
    parent = 0
    stack = []
    spaceb = " |   "
    spaced = " ⊕   "
    [pushfirst!(stack, (0, x...)) for x in children(root)]
    while !isempty(stack)
        (parent, cr, ndix) = popfirst!(stack)
        cr == FINAL_CHAR && continue
        nd = tr[ndix]

        edgename = nd.position > tr.lw ? error("Oh no,,, I have added an implementation error :(") :
                nd.len > -1 ? "$(tr.word[nd.position:nd.position+nd.len-1])⋅⋅⋅" :
                "$(tr.word[nd.position:end])$FINAL_SYM"

        edgelabel = "$(tr.word[nd.position])"
        finish = nd.len > -1 ? nd.position + nd.len : "#"

        # subword = Gr(tr.word[node_word(tr, ndix):nd.position-1])*edge


        chdn = children(nd)
        if parent < depth - 1
            out *= (spaceb)^(parent + 1) *
                (spaced)^(depth - parent-1) *
                "\n"
        end
        #   out *=  (spaceb)^(parent+1)*
        "\n"

        depth = parent + 1
        spacer = (spaceb)^(parent)
        nodename = "<$(nd.label)>"#*"[$(nd.position):$finish]"

        if isempty(chdn)
            # out *= spacer * " |\n"
            edgearrow = " ⋅→-$edgelabel-⋅ "
            #   edgearrow = " ⋅-$edgename-" 
            out *= spacer *
                edgearrow *
                nodename * "\n"
            out *= "$(spacer)$spaceb  ($(edgename))\n"
        else

            # out *= spacer * " |   ($edgelabel)\n"
            out *= spacer * " ⋅→-$edgelabel-⋅ $nodename" * "\n"
            out *= spacer * "$spaceb ↓ ($(edgename))\n"
            out *= "$(spacer)$(spaceb) |\n"
            suff = nd.next[FINAL_CHAR]
            if suff > 0
                # nodename *= "\n$spacer$spaceb\n$spacer$spaceb ⋅--[$FINAL_SYM]→-<$(tr[suff].label)>[$(tr[suff].position)]"
                out *= "$(spacer)$(spaceb) ⋅→-$FINAL_SYM-⋅ <$(tr[suff].label)>\n"#*"[$(tr[suff].position):#]\n"
                out *= "$(spacer)$(spaceb)$(spaceb)  ($FINAL_SYM)\n"
                out *= "$(spacer)$(spaceb) |\n"
            end

            [pushfirst!(stack, (depth, x...)) for x in chdn]
        end

    end
    out *= spaced^(depth)
    print(out)
end

function dotfile!(tr::SuffixTree, fname::AbstractString; cscheme="rdylgn11", direction = "TB", to_string=Monoids.prettyrepr)
    nodes = []
    edges = []
    nsyms = unique(text(tr))
    push!(nsyms, FINAL_CHAR)
    cmap(nd) = floor(length(COLORS)/length(nsyms)*findfirst(==(text(tr, nd.position)), nsyms))|>Int|>x->COLORS[x%length(COLORS)+1]


    edgename(nd) = nd.position > tr.lw ? "$FINAL_SYM" :
                nd.len > -1 ? "$(to_string(tr.word[nd.position:nd.position+nd.len-1]))" :
                "$(to_string(tr.word[nd.position:end]))$FINAL_SYM" |>x->replace(x, "."=>"")
    node_word(nd) = "{$(to_string(subword(tr, nd))|>x->replace(x, "."=>""))}"
    # edgelabel = "$(tr.word[nd.position])"
    # finish = nd.len > -1 ? nd.position + nd.len : "#"
# label=\"$(nd.label)\", 
    nodes = [
        "n$(nd.label) "*
        "[label=\"$(nd.label) : \n"*
        "$(node_word(nd))\", "*
        "shape=\"$(nd.suffix ? "rectangle" : "circle")\", "*
        "group=\"$(nd.parent)\","*
        "fontcolor=\"$(TEXTCOLORS[parse(Int,nd.label)%length(TEXTCOLORS)+1])\"];\n"
         for nd in tr.tree[2:end]
            
    ]
    edges = ["n$(nd.parent) -> n$(nd.label) [label=\"($(edgename(nd)))\", fontcolor=\"$(cmap(nd))\", color=\"$(cmap(nd))\"];\n" for nd in tr.tree[2:end]]
    dot_temp = """
    digraph G {
    graph [rankdir="$(direction)", center=true, nodesep="0.5",margin="1",width="1"];
    node [height="0.05",margin="0.01",shape="rectangle",width="0.05"];
    edge [arrowsize="0.5"];
    $(join(nodes))
    $(join(edges))
    }
    """

    open("$fname.dot", "w") do IO
    print(IO, dot_temp)
    end

end

# ImplicitTrees


    # struct Alphabet  end


    # struct ImplicitRange{T} where T<:Integer
    #     idxs::Union{T, AbstractUnitRange{T}}
    # end

    # function meet(i::AbstractUnitRange{S}, j::AbstractUnitRange{S}) where S<:Integer
    #     intersect(i, j)::AbstractUnitRange{S}
    # end

    # function meet(i::S, j::AbstractUnitRange{S})::AbstractUnitRange{S} where S<:Integer
    #     intersect(i:j.stop, j)
    # end

    # function meet(i::AbstractUnitRange{S}, j::S)::AbstractUnitRange{S} where S<:Integer
    #     intersect(i, j:i.stop)
    # end

    # function meet(i::S, j::S)::S where S<:Integer
    #     max(i,j)
    # end


    # function meet(i::ImplicitRange{S}, j::ImplicitRange{S})::ImplicitRange{S} where S<:Integer
    #     meet(j.idxs,i.idxs)
    # end


    # mutable struct ImplicitNode{T} where T<: Integer
    #         edge::ImplicitRange{T}
    #         parent::T
    #         next::FixedSizeArray{T}
    #         label::AbstractString
    #         slink::T
    #         function ImplicitNode(
    #         edge::S,
    #         label::AbstractString;
    #         parent::T=0,
    #         slink::T=0
    #         ) where {S, T}
    #         next = FixedSizeVector{Int}(undef, ALPHABET_SIZE)
    #         next .= 0

    #         new{T}(ImplicitRange(edge), parent, next, label, slink)
                
    #         end
    # end

    # mutable struct ImplicitTree{T<:Integer, S}<:AbstractTree where S
    #     tree::Vector{ImplicitNode{T}}
    #     word::S
    #     len::Int
    # end

    # function extend_suffix!(
    #     tr::ImplicitTree{S, T},
    #     c::T,
    #     idx::T;
    #     active_node::T=0,
    #     active_e::T=0,
    #     active_len::T=0,
    #     rem::T=0
    # ) where {S, T}

    #     needs_link = 0
    #     txt = [text(tr)..., FINAL_CHAR]
    #     rem += 1

    #     while rem > 0
    #         active_e = (active_len == 0) ? idx : active_e
    #         edge = txt[active_e]
    #         nxt = (active_e == 0) ? 0 : tr[active_node].next[edge]

    #         edg_l = edgelength(tr[nxt], idx)
    #         if (nxt == 0)
    #             let nd = SuffixNode(idx, active_node, true, "$(tr.len+1)")
    #                 leaf = push!(tr, nd)

    #                 tr[active_node].next[edge] = leaf
    #                 if (needs_link > 0)
    #                     tr[needs_link].slink = active_node
    #                 end
    #                 needs_link = active_node
    #             end
    #         elseif (active_len >= edg_l)
    #             active_e += edg_l
    #             active_len -= edg_l
    #             active_node = nxt
    #             continue
    #         elseif (txt[tr[nxt].position+active_len] == c)
    #             active_len += 1
    #             if (needs_link > 0)
    #                 tr[needs_link].slink = active_node
    #             end

    #             return active_node, active_e, active_len, rem
    #         else
    #             let splitnd = SuffixNode(tr[nxt].position, active_node, false, "$(tr.len+1)"; len=active_len)
    #                 split = push!(tr, splitnd)
    #                 tr[active_node].next[edge] = split

    #                 leafnd = SuffixNode(idx, split, true, "$(tr.len+1)")

    #                 leaf = push!(tr, leafnd)
    #                 tr[split].next[c] = leaf
    #                 tr[nxt].position += active_len
    #                 if tr[nxt].len > -1
    #                     tr[nxt].len -= active_len
    #                 end
    #                 tr[split].next[txt[tr[nxt].position]] = nxt

    #                 tr[nxt].parent = split

    #                 if (needs_link > 0)
    #                     tr[needs_link].slink = split
    #                 end
    #                 needs_link = split

    #             end
    #         end

    #         rem -= 1
    #         if (active_node == 0 && active_len > 0)
    #             active_len -= 1
    #             active_e = idx - rem + 1
    #         else
    #             # active_node = tr[active_node].slink > 0 ? tr[active_node].slink : 0
    #             active_node = tr[active_node].slink
    #         end

    #     end

    #     return active_node, active_e, active_len, rem
    # end


    # end


    # # function suffix_tree(w::String)::SuffixTree{String}
    # #     word = text(w)
    # #     lw = length(word)
    # #     root = ImplicitNode(0, -1, false, "root";len=0)
    # #     tr = ImplicitTree(w, ImplicitNode[root],0)

    # #     rem::Int = 0
    # #     active_node::Int = 0
    # #     active_e::Int = 0
    # #     active_len::Int = 0
    # #     for (idx, c) = enumerate(word)
    # #         active_node, active_e, active_len, rem = extend_suffix!(tr, c, idx, active_node, active_e, active_len, rem)

    # #     end

    # #     active_node, active_e, active_len, rem = extend_suffix!(tr, FINAL_CHAR, lw+1, active_node, active_e, active_len, rem)

    # #     tr

    # # end

    # #   function text(w::AbstractElement)::Vector{Int}
    # #       [Int(x) for x in w.word]
    # #   end
end





