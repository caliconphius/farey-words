using GLMakie
using Markdown
using UnicodeFun
using Base.Iterators
using DataInterpolations:CubicHermiteSpline


struct BraidElement
    switch_idx::Integer
    ntwists::Integer
end



function Base.:-(a::BraidElement)
    BraidElement(a.switch_idx, -a.ntwists)
end

struct Id end

Base.show(io::IO, a::BraidElement) = begin 
    (s,t) = a.switch_idx; n = a.ntwists;
    print(io, "BraidElement: \\sigma[$(s)$(t)]^{$(n)}" |> UnicodeFun.to_latex)      
end

Br(t, n) = BraidElement(t, n) 




"""
twist_path(x, y, θ)
finds a point between x and y which they can twist around

"""
function twist_path(pts::Vector, a::BraidElement, ϵ::Real, nθ=15, end_repeats=15)
    cpts = convert(Vector{ComplexF64}, pts)
    idxs =  (a.switch_idx, a.switch_idx+1) ; n = abs(a.ntwists)
    (i,j) = (findall([Integer(abs(x))∈idxs for x in pts]))


    x = cpts[i]
    y = cpts[j]
    mid = (x+y)/2
    Δx = (y-x)/2
    δx = Δx / abs(Δx)
    
    δp(θ) = (Δx * cos(θ) + sign(a.ntwists) * ϵ * sin(θ) *  im)  * δx
    midp(θ) = [mid - δp(θ), mid + δp(θ)]
    dmidp(θ) = [-im * δp(θ), im * δp(θ)]
    θs = (0:nθ) * π ./ (nθ)
    midps = [midp(t) for t in θs ]
    dmidps = [dmidp(t) for t in θs ]
    
    rev_midcpts = hcat(fill(cpts, nθ+1)...)
    midcpts = hcat(fill(cpts, nθ+1)...)
    drev_midcpts = midcpts*0.0
    dmidcpts = midcpts*0.0
    twistcpts = deepcopy(cpts)


    for idx in 1:(nθ+1)
        midcpts[[i,j],idx] .= midps[idx]
        rev_midcpts[[j,i],idx] .= midps[idx]
        dmidcpts[[i,j],idx] .= dmidps[idx]
        drev_midcpts[[j,i],idx] .= dmidps[idx]
    end
    twistcpts[[i,j]] .= cpts[[j,i]] 


    twist = hcat(
        midcpts,
        rev_midcpts,
    )
    dtwist = hcat(
        dmidcpts,
        drev_midcpts
    )

    

    # endpts = n%2==0 ? rev_midcpts[:, :, end] : midcpts
    # dendp = n%2==0 ? drev_midcpts[:, :, end] : dmidcpts
    
    out = hcat(repeat(cpts, outer=[1,end_repeats]), repeat(twist, outer=[1,n÷2]))  
    dout = hcat(repeat(0*cpts, outer=[1,end_repeats]), repeat(dtwist, outer=[1,n÷2]))  
    out = n%2==0 ? out : hcat(out, midcpts)
    dout = n%2==0 ? dout : hcat(dout, dmidcpts)
    return out=>dout
end



function make_braid(sigma, N, ϵ)
    pts = [i*1.0 for i in 1:N]
    path = accumulate(sigma, init=(pts=>nothing)) do out, a
        pts = [i*1.0 for i in 1:N]
        val = [x for x in out.first[:,end]]
        a.ntwists%2 == 1 ? permute!(pts, real.(val).|>Integer) : nothing
        out = twist_path(pts, a, ϵ)
        out
    end
    newpath = hcat([p.first for p in path]...)
    dpath = hcat([p.second for p in path]...)


    newpath, dpath
end
begin

ϵ0 = .5
a = Br(1,3)
c = Br(2,-2)
d = Br(4, 2)
f = Br(5, 9)
g = Br(3, -2)


sigma = [a,c, d,-g, c, f]
npts = 6
braid, dbraid = make_braid(sigma,  npts, ϵ0);

braid
dbraid
t = LinRange(0,5, braid.size[2])
t_more = LinRange(0,5, 1000)

braid

braid_interp = (i,ts) -> CubicHermiteSpline(dbraid[i, :], braid[i,:], t, assume_linear_t=true)(ts)

data = [braid_interp(i, t_more|>reverse) for i in 1:npts]

data[1]
    

with_theme(theme_black()) do

fig1 = Figure(size = (400, 800))
fig2 = Figure(size = (800, 800))

ax = Axis(fig1[1,1], aspect = 1, xrectzoom=false, yrectzoom=false)
ax2 = Axis3(fig2[1,1], title = "Braid!", )
ylims!(ax2, -2,2)

for brd in data
    lines!(ax, real.(brd),  t_more)
    lines!(ax2, real.(brd), imag.(brd), t_more)

end
hidedecorations!(ax2)
hidespines!(ax2)
resize_to_layout!(fig1)
fig2

end
# fig1

end

