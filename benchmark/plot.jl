vals64 = collect(values(res[Float64])) 
vals32 = collect(values(res[Float32])) 
xticklabels = String.(collect(keys(res[Float64])))
ymax = max(maximum(vals32), maximum(vals64))
yticklabels = vcat(1, collect(0:div(ymax, 5):ymax))
order = sortperm(vals64)

# vals2 = vcat(collect(values(res[Float64])), collect(values(res[Float32])))
x = collect(1:length(vals64))
barwidth = 0.4
p = bar(x .- barwidth/2, vals64[order], bar_width = barwidth,
    color = :purple,
    ylabel = "performance ratio", label = "Float64", #title = "Performance for $NVALS", 
    tickfontsize = 12, titlefontsize = 16, guidefontsize = 14, legendfontsize = 14,
    dpi = 100,
    xlims = [x[1] - barwidth, x[end] + barwidth],
    xrotation = 60, 
    xticks = (x, xticklabels), yticks = yticklabels)
bar!(p, x .+ barwidth/2, vals32[order], bar_width = barwidth,
    color = :gold,
    label = "Float32" )
plot!(p, [x[1] - barwidth, x[end] + barwidth], [1, 1], 
    color = :black, label = "", linewidth = 2, linestyle = :dash)