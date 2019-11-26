using Plots
pyplot()
using StatsPlots
using VML
using BenchmarkTools
using Statistics
using SpecialFunctions


function medianbench(fn, nvals, intype; unary = true)
    input = unary ? (randindomain(intype, nvals, fn[3]), ) : (randindomain(intype, nvals, fn[3]), randindomain(intype, nvals, fn[3]))
    base_fn = eval(:($(fn[1]).$(fn[2]))) 
    vml_fn = eval(:(VML.$(fn[2])))

    baseTimes = (@benchmark $base_fn.($(input)...)).times
    vmlTimes = (@benchmark $vml_fn($(input)...)).times

    return median(baseTimes)/median(vmlTimes)
end

function plotgroupedbench(res, t1, t2, REP_NVALS)

    yt = reduce(hcat, [collect(values(res[t])) for t in (t1, t2)  ])
    xticklabels = string.(collect(keys(res[t2])))
    ymax = maximum(yt)
    yticklabels = vcat(1, collect(0:div(ymax, 5):ymax))
    order = sortperm(yt[:, 2])

    p = StatsPlots.groupedbar(xticklabels[order], yt[order, :],
        size = (1100, 550),
        color = [:gold :purple],
        ylabel = "performance ratio", label = string.([t1 t2]), title = "Performance for n = $REP_NVALS", 
        tickfontsize = 12, titlefontsize = 16, guidefontsize = 14, legendfontsize = 14,
        dpi = 100, xlims = [0, length(xticklabels)],
        xrotation = 60, 
        yticks = yticklabels
    )

    plot!(p, [0, length(xticklabels)+0.5], [1, 1], 
        color = :black, label = "", linewidth = 2, linestyle = :dash)

    return p
end