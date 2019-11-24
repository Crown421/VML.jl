include(joinpath(dirname(dirname(@__FILE__)), "test", "common.jl"))

include("bm_functions.jl")

## remove lgamma
idx = setdiff(1:length(base_unary_real), findall(getindex.(base_unary_real, 2) .== :lgamma))
bench_unary_real = base_unary_real[idx]

# First generate some random data and test functions in Base on it
const REP_NVALS = 10000

### Real inputs
# compute benchmarks
realtypes = (Float32, Float64)
res = Dict(t => 
    Dict( fn[2] => medianbench(fn, REP_NVALS,  t)
        for fn in bench_unary_real )
    for t in realtypes)
resBinary = Dict(t => 
    Dict( Symbol(fn[2], :2) => medianbench(fn, REP_NVALS,  t; unary = false)
        for fn in base_binary_real )
    for t in realtypes)
for key in keys(res)
    merge!(res[key], resBinary[key])
end

# plot benchmarks 
p = plotgroupedbench(res, realtypes[1], realtypes[2], REP_NVALS)

savefig(p, "performance.png")




complextypes = complex.(realtypes)
resComplex = Dict(t => 
    Dict( fn[2] => medianbench(fn, REP_NVALS,  t)
        for fn in base_unary_complex )
    for t in complextypes)

p = plotgroupedbench(res, realtypes[1], realtypes[2], REP_NVALS)
savefig(p, "performance_complex.png")




# 
    
# rat = [medianbench(fn, n, intype) n in nArray]







