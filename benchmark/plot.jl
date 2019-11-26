
vals = reduce(hcat, collect(values(resSD64)))
labels = collect(keys(resSD64))

p = plot(layout = (2,2))
idx = floor.(Int, collect(range(0,31, length = 5)))


# order by size
for i in 1:length(idx)-1
    specidx = idx[i]+1:idx[i+1]
    specvals = vals[:, specidx]
    order = sortperm(mean(specvals, dims = 1)[:], rev = true)
    plot!(p, nArray, specvals[:, order], labels = permutedims(string.(labels[specidx])), 
    subplot = i, 
    xscale = :log10, yscale = :log10,
    linewidth = 2,
    yticks = (1:3:12, string.(collect(1:3:12))),
    # xticks = (1:15, nArray)
    )
end

p