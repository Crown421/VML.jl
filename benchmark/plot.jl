# after running bm_extended.jl in two seperate julia session, this script will create the plots.
# It will likely need a new julia session. 

using Plots
using Statistics
pyplot()

resSD32 = load("partFloat32.jld2")["resSDFloat32"]
resSD32 = load("partFloat32.jld2")["resSDFloat32"]

function plotextendedbm(resSD)

    nArray = [i*10^j for i=1:2:9, j = 3:5][:]

    vals = reduce(hcat, collect(values(resSD)))
    labels = collect(keys(resSD))

    p = plot(layout = (2,2), size =(1100, 800))
    idx = floor.(Int, collect(range(0,31, length = 5)))

    # order by size
    for i in 1:length(idx)-1
        specidx = idx[i]+1:idx[i+1]
        specvals = vals[:, specidx]
        order = sortperm(mean(specvals, dims = 1)[:], rev = true)
        plot!(p, nArray, specvals[:, order], labels = permutedims(string.(labels[specidx])), 
        subplot = i,
        xlabel = "input array size", ylabel = "performance ratio",
        xscale = :log10, yscale = :log10,
        linewidth = 2,
        yticks = (1:3:12, string.(collect(1:3:12))),
        # xticks = (1:15, nArray)
        )
    end

    return p
end


p = plotextendedbm(resSD64)
savefig(p, "performance_ex64.png")

p = plotextendedbm(resSD32)
savefig(p, "performance_ex32.png")