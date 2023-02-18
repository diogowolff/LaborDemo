using Base.Threads
using LinearAlgebra
#using Queryverse
# using DataFrames
# using Statistics
using Distributions
using Random
using Plots; pyplot()
using StatsPlots
using Optim
using BlackBoxOptim
# using ForwardDiff

df4 = copy(df);

df4 = df4[df4.YEAR .== 2015,:];
# deleteat!(df4, df4.HHINCOME .< 0) # botar no R
df4 = df4[(df4.SEX .== 1) .& (df4.MARST .< 3) .& (df4.AGE .>= 25) .& (df4.AGE .<= 55) .& (df4.EMPSTAT .== 1),:];

# option to subset df4 for faster runtime
# df4 = df4[shuffle(1:nrow(df4))[1:10000],:]

df4.NLINC = df4.HHINCOME - df4.INCWAGE;
df4.Wage = df4.INCWAGE ./ (df4.UHRSWORK .* df4.WKSWORK2);
df4.WorkTot = (df4.UHRSWORK .* df4.WKSWORK2);

# Some assumptions: Consumption is total income
# only intensive margin -> only people that work
# T = 40h for everyone per week

df4 = df4[!, [:EDUC, :Wage, :NLINC, :WorkTot, :INCTOT]];


n = size(df4, 1);
x, w, y, L, C = Vector.(eachcol(df4)); # |> x -> Vector.(x)

function GMM((B0, gammaL, gammaC))
    obj = [1/n*sum(x.*(gammaL.*w .+ x.*B0.*(w.*40*52 .+ y .- gammaC .- gammaL.*w) .- w.*L)), # moment for consumption
           1/n*sum(x.*(y .+ w.*40*52 .- w.*gammaL .+ x.*B0.*(gammaC .- y .- w.*L .+ w.*gammaL) .- C)), # moment for leisure
           1/n*sum((y .+ w.*(40*52) .- w.*gammaL .+ x.*B0.*(gammaC .- y .- w.*L .+ w.*gammaL) .- C)./(y .+ w.*(40*52) .- w.*gammaL .- gammaC))] # moment for epsilon
    return obj'*obj
end

ranges = [(-100, 100), (-100, 5000), (0, 100000)]
res = bboptimize(GMM; SearchRange = ranges, NumDimensions = 3) #, MaxTime = 10)
a = best_candidate(res)
GMM(a)

b = optimize(GMM, a, LBFGS(), Optim.Options(show_trace = true)) |> Optim.minimizer

c = optimize(GMM, a, NelderMead(), Optim.Options(show_trace = true)) |> Optim.minimizer

GMM(a)