  module Palindromes
  using Farey
  using Farey:AbstractMonoidWord
  ispalindrome(w) = (w==reverse(w))
  # function conj_prefix(x)
  #     xi = inv(x)
  #     Gr = x.parent

  #     prefix = zip(x.word, xi.word) |>
  #         itr->ITR.takewhile((x)->x[1]==x[2], itr) |>
  #         l->mapreduce(x->Gr(x[1]), *, l, init=one(Gr))

  #     prefix, x^prefix

  # end
  function pal_suff(w::T) where T<:AbstractMonoidWord
      (w==one(w)) && return w
      for i in 1:length(w)-1
          wsuff = w[i:length(w)]
          ispalindrome(wsuff) && return wsuff
      end

  end

#   function Pal(w::Farey.FreeGroupElement)
#       out = one(w)
#       Gr = w.parent
#       for g in reverse(w).word
#           out = g==1 ? G0(out)*Gr(g) : D0(out)*Gr(g)
#       end
#       out
#   end


  letters(ww::Farey.FreeGroupElement) = ww[1:length(ww)]
  letters(ww::AbstractMonoidWord) = eachgen(ww)

function Pal(w::T; ids=(T(1), T(2))) where T<: AbstractMonoidWord

    idg, idd = ids
    G0 =
    out = one(w)
    for x in eachgen(w)
        out = x==idg ? G0(out)*Gr(g) : D0(out)*Gr(g)
    end
    out
end

  function lcp(w1, w2)
      mapreduce((a)->a[1], *, ITR.takewhile(a->a[1]==a[2], zip(letters.((w1,w2))...)), init=one(w1))
  end

  function lcs(w1, w2)
      reverse(mapreduce((a)->a[1], *, ITR.takewhile(a->a[1]==a[2], zip(letters.(reverse.((w1,w2)))...)), init=one(w1)))
  end

  function pref_array(w1, w2)
      [lcp(w1, w2[length(w2)-i:length(w2)]) for i in 1:length(w2)-1]
  end

  function suff_array(w1, w2)
      [lcs(w1, w2[1:i]) for i in 2:length(w2)]
  end

  pal_conj(w) = (w/pal_suff(w)) * reverse(w)

end
