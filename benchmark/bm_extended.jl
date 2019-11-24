include(joinpath(dirname(dirname(@__FILE__)), "test", "common.jl"))

include("bm_functions.jl")

using HypothesisTests

function medianandtest(fn, nvals, intype; unary = true)
    input = unary ? (randindomain(intype, nvals, fn[3]), ) : (randindomain(intype, nvals, fn[3]), randindomain(intype, nvals, fn[3]))
    base_fn = eval(:($(fn[1]).$(fn[2]))) 
    vml_fn = eval(:(VML.$(fn[2])))
    vml_funm = eval(:(VML.$(Symbol(fn[2],:!))))

    baseBench = @benchmark $base_fn.($(input)...)
    vmlBench = @benchmark $vml_fn($(input)...)

    ratio = median(baseBench.times)/median(vmlBench.times)
    p = pvalue(MannWhitneyUTest(baseBench.times, vmlBench.times))

    return (ratio, p)
end

function computesizedep(fn, intype, nArray; unary = true)
    result = [medianandtest(fn, n, intype; unary = unary) for n in nArray]

    return hcat(getindex.(tes,1), getindex.(tes,2))
end


nArray = [i*10^j for i=1:9, j = 3:6][:]







realtypes = (Float32, Float64)
res = Dict(t => 
    Dict( fn[2] => computesizedep(fn, REP_NVALS,  t)
        for fn in bench_unary_real )
    for t in realtypes)
# resBinary = Dict(t => 
#     Dict( Symbol(fn[2], :2) => medianbench(fn, REP_NVALS,  t; unary = false)
#         for fn in base_binary_real )
#     for t in realtypes)