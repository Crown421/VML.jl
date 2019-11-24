using Plots
pyplot()
using VML
using BenchmarkTools
using Statistics
using SpecialFunctions

include(joinpath(dirname(dirname(@__FILE__)), "test", "common.jl"))

## remove lgamma
idx = setdiff(1:length(base_unary_real), findall(getindex.(base_unary_real, 2) .== :lgamma))
bench_unary_real = base_unary_real[idx]

# First generate some random data and test functions in Base on it
const NVALS = 1000

input = Dict(
    t=>[
        [ (randindomain(t, NVALS, domain),) for (_, _, domain) in bench_unary_real ];
        [ (randindomain(t, NVALS, domain1), randindomain(t, NVALS, domain2))
            for (_, _, domain1, domain2) in base_binary_real ]
    ]
    for t in (Float32, Float64)
)

fns = [[x[1:2] for x in bench_unary_real]; [x[1:2] for x in base_binary_real]]


function medianbench(fn, input)
    base_fn = eval(:($(fn[1]).$(fn[2]))) 
    vml_fn = eval(:(VML.$(fn[2])))
    # vml_fn! = eval(:(VML.$(fns[i][2])!))

    baseBench = @benchmark $base_fn.($(input)...)
    vmlBench = @benchmark $vml_fn($(input)...)

    return median(baseBench.times)/median(vmlBench.times)
end


types = (Float32, Float64)
res = Dict(t => 
    Dict( fn[2] => medianbench(fn, inp)
        for (fn, inp) in zip(fns, input[t]) )
    for t in types)


vals64 = collect(values(res[Float64])) 
vals32 = collect(values(res[Float32])) 
xticklabels = String.(collect(keys(res[Float64])))
yticklabels = collect(1:2:max(maximum(vals32), maximum(vals64))
order = sortperm(vals64)

# vals2 = vcat(collect(values(res[Float64])), collect(values(res[Float32])))
x = collect(1:length(vals64))
barwidth = 0.2
p = bar(x-barwidth/2, vals64[order], bar_width = 0.2 )
bar!(p, x+barwidth/2, vals32[order], bar_width = 0.2 )

