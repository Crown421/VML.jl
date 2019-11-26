### This is very much WIP
# to recreate the plots this file needs to run twice, once with each of the following lines uncommented.
t = Float32
# t = Float64
# You will also need about 13Gb of free RAM. 


include(joinpath(dirname(dirname(@__FILE__)), "test", "common.jl"))

idx = setdiff(1:length(base_unary_real), findall(getindex.(base_unary_real, 2) .== :lgamma))
bench_unary_real = base_unary_real[idx]

include("bm_functions.jl")

using FileIO
using JLD2

# using HypothesisTests

function medianandtest(fn, nvals, intype; unary = true)
    input = unary ? (randindomain(intype, nvals, fn[3]), ) : (randindomain(intype, nvals, fn[3]), randindomain(intype, nvals, fn[3]))
    base_fn = eval(:($(fn[1]).$(fn[2]))) 
    vml_fn = eval(:(VML.$(fn[2])))
    # vml_funm = eval(:(VML.$(Symbol(fn[2],:!))))

    baseBench = (@benchmark $base_fn.($(input)...)).times
    vmlBench = (@benchmark $vml_fn($(input)...)).times

    ratio = median(baseBench)/median(vmlBench)
    # p = pvalue(MannWhitneyUTest(baseBench.times, vmlBench.times))
    # return (ratio, p)

    # helps a little with memory/ cache issues 
    baseBench = nothing
    vmlBench = nothing

    return ratio
end

function computesizedep(fn, intype, nArray; unary = true)
    println(fn[2])
    println(Sys.free_memory()/2^20)
    result = [medianandtest(fn, n, intype; unary = unary) for n in nArray]
    println(Sys.free_memory()/2^20)
    # return hcat(getindex.(result,1), getindex.(result,2))
    return result
end

function sizedep(t, bench_unary_real) 
    nArray = [i*10^j for i=1:2:9, j = 3:5][:]

    resSD = Dict{Symbol, Array{Float64, 1}}()
    for fn in bench_unary_real
        resSD[fn[2]] = computesizedep(fn, t, nArray)
    end

    save("part$t.jld2", "resSD$t", resSD)
end

sizedep(t, bench_unary_real) 

# realtypes = (Float32, Float64)
# resSD = Dict(t => 
#     Dict( fn[2] => computesizedep(fn, t, nArray)
#         for fn in bench_unary_real )
#     for t in realtypes)

# resBinary = Dict(t => 
#     Dict( Symbol(fn[2], :2) => medianbench(fn, REP_NVALS,  t; unary = false)
#         for fn in base_binary_real )
#     for t in realtypes)


