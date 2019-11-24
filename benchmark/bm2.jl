function ratiomean(bT, vT)
    iP = Iterators.product(1:length(bT), 1:length(vT))
    s = 0.0
    for idx in iP
        s += bT[idx[1]]/vT[idx[2]]
    end
    return s/length(iP)
end

function ratiostd(bT, vT, rm)
    iP = Iterators.product(1:length(bT), 1:length(vT))
    s = 0.0
    for idx in iP
        s += ((bT[idx[1]]/vT[idx[2]]) - rm)^2
    end
    return sqrt(s/length(iP))
end


p = fill(NaN, 45)
for (i, n) in enumerate([i*10^j for i=1:9, j = 2:6][:])
    bT = (@benchmark cos.(rand($n))).times;
    vT = (@benchmark VML.cos(rand($n))).times;
    println(median(bT))
    println(median(vT))

    p[i] = pvalue(MannWhitneyUTest(bT, vT))

    if p[i] < 0.05
        break
    end

end




rat = fill(NaN, 45)
for (i, n) in enumerate([i*10^j for i=1:9, j = 2:6][:])
    bT = (@benchmark sin.(rand($n))).times;
    vT = (@benchmark VML.sin(rand($n))).times;

    rat[i] = median(bT) / median(vT)

end








Makie.barplot(1:33, collect(values(res[Float64])), 
    axis = (ticks = (
        labels = (String.(collect(keys(res[Float64]))), ["a", "b", "c"]),
        ranges = (1:33, 1:3), # ranges don't get adapted to number of labels, so one needs to supply them
    ),
),)



vals = collect(values(res[Float64])) 
xticklabels = String.(collect(keys(res[Float64])))
yticklabels = collect(1:2:maximum(vals))
order = sortperm(vals)
w = Makie.barplot(1:32, vals[order],
    width = 0.3, color = :darkgreen, 
    names = (axisnames = ("", "Performance Ratio"),))
w[Axis][:ticks][:ranges] = (1:32, yticklabels)
w[Axis][:ticks][:labels] = (xticklabels[order], string.(yticklabels))
w[Axis][:ticks][:rotation] = (2*pi/5, 0.0)
w[Axis][:ticks][:align] = ((:right, :center), (:right, :center))
w[Axis][:ticks][:gap] = (10, 10)
w[Axis][:names][:axisnames] = ("", "Performance Ratio")

    w = Makie.scatter(
        rand(10), rand(10),
            ticks = (
                ranges = ([0, 1], [0, 1]),
                labels = (["a", "b"], ["a", "b"])
            ),
    )



results = Dict(Float32 => zeros(3, length(fns)), Float64 => zeros(3, length(fns)))
for t in (Float32, Float64), i = 1:length(fns)

    base_fn = eval(:($(fns[i][1]).$(fns[i][2]))) 
    vml_fn = eval(:(VML.$(fns[i][2])))
    # vml_fn! = eval(:(VML.$(fns[i][2])!))

    baseBench = @benchmark $base_fn.($(input[t][i])...)
    vmlBench = @benchmark $vml_fn($(input[t][i])...)

    baseTime = median(baseBench.times)
    baseTimeVar = varm(baseBench.times, baseTime)
    vmlTime = median(vmlBench.times)
    vmlTimeVar = varm(vmlBench.times, vmlTime)

    ratio = baseTime/vmlTime
    # ratioVar = (baseTime/vmlTime)^2 * (baseTimeVar/baseTime^2 + vmlTimeVar/vmlTime^2)
    worstRatio = (baseTime - sqrt(baseTimeVar)) / (vmlTime + sqrt(vmlTimeVar))
    bestRatio = (baseTime + sqrt(baseTimeVar)) / (vmlTime - sqrt(vmlTimeVar))

    results[t][:, i] = [ratio, worstRatio, bestRatio]
end
