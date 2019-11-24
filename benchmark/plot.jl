vals64 = collect(values(res[Float64])) 
vals32 = collect(values(res[Float32])) 

t1 = Float32
t2 = Float64

yt = reduce(hcat, [collect(values(res[t])) for t in (t1, t2)  ])
xticklabels = string.(collect(keys(res[t2])))
ymax = maximum(yt)
yticklabels = vcat(1, collect(0:div(ymax, 5):ymax))
order = sortperm(yt[:, 2])

p = StatsPlots.groupedbar(xticklabels[order], yt[order, :],
    color = [:gold :purple],
    ylabel = "performance ratio", label = string.([t1 t2]), #title = "Performance for n = $NVALS", 
    tickfontsize = 12, titlefontsize = 16, guidefontsize = 14, legendfontsize = 14,
    dpi = 100, xlims = [0.5, length(xticklabels)],
    xrotation = 60, 
    yticks = yticklabels
)

plot!(p, [0, length(xticklabels)+0.5], [1, 1], 
    color = :black, label = "", linewidth = 2, linestyle = :dash)