using LinearAlgebra
using Base.Threads
using Queryverse
using DataFrames
using Dates
using Statistics
# using Distributions
# using Random
# using Plots; pyplot()
using Optim
# using StatsPlots
# using FileIO
# using JLD2
using BlackBoxOptim
using Roots
using IntervalRootFinding
using StaticArrays

### Loading df for machines that can't run Queryverse
# cd("Documents/Labor/ProblemSet")
# df = CSV.read("Extract3/data_woman_age_clean.csv", DataFrame)

### Loading df for machines that can't run FileIO
cd("C:\\Users\\guiex\\EPGE\\Labor\\Problem Set")
df = load("Extract1/20pct_dataset.csv", delim = ',') |> DataFrame;

select!(df, Not([:SAMPLE, :CBSERIAL, :HHWT, :CLUSTER, :STRATA, :GQ, :PERNUM, :PERWT, :RACE, :RACED]));
nominalValues = [:HHINCOME, :INCTOT, :INCWAGE, :INCWELFR, :INCSS];
[filter!(col => x -> x != 9999999, df) for col in nominalValues];
[filter!(col => x -> x != 0, df) for col in [:EMPSTAT, :WKSWORK2]];
[filter!(col => x -> x != 00, df) for col in [:EMPSTATD, :UHRSWORK]];
filter!(:EDUCD => x -> x != 001, df);
filter!(:EDUCD => x -> x != 999, df);
filter!(:INCWAGE => x -> x != 999998, df);
filter!(:HHINCOME => x -> x >= 0, df);
df.WKSWORK2 = ifelse.(df.WKSWORK2 .== 0, 0, (13*(2*df.WKSWORK2.-1) .+ 1)/2);
# [filter!(col => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), df) for col in Symbol.(names(df))];

priceInd = load("Extract1/median_consumer_price_index.csv", delim = ',') |> DataFrame;
rename!(priceInd, :MEDCPIM094SFRBCLE => :INDEX);
priceInd.DATE = Dates.year.(priceInd.DATE);
rename!(priceInd, :DATE => :YEAR);
priceInd = groupby(priceInd, :YEAR);
priceInd = combine(priceInd, :INDEX => mean => :INDEX);
transform!(priceInd, :INDEX => x -> x/priceInd[1, :INDEX]);

leftjoin!(df, priceInd, on = :YEAR);
df[!, nominalValues] = df[!, nominalValues]./df.INDEX;




##### Q4

df = df[df.YEAR .== 2015,:]
# deleteat!(df, df.HHINCOME .< 0) # botar no R
df = df[(df.SEX .== 1) .& (df.MARST .< 3) .& (df.AGE .>= 25) .& (df.AGE .<= 55) .& (df.EMPSTAT .== 1),:];

# option to subset df for faster runtime
# df = df[shuffle(1:nrow(df))[1:10000],:]

df.NLINC = df.HHINCOME - df.INCWAGE;
df.Wage = df.INCWAGE ./ (df.UHRSWORK .* df.WKSWORK2);
df.WorkTot = (df.UHRSWORK .* df.WKSWORK2);

# Some assumptions: Consumption is total income
# only intensive margin -> only people that work
# T = 40h for everyone per week

df = df[!, [:EDUC, :Wage, :NLINC, :WorkTot, :INCTOT]]


n = size(df, 1)
x, w, y, L, C = Vector.(eachcol(df)) # |> x -> Vector.(x)

function GMM((B0, gammaL, gammaC))
    obj = [1/n*sum(x.*(gammaL.*w .+ x.*B0.*(w.*40*52 .+ y .- gammaC .- gammaL.*w) .- w.*L)), # moment for consumption
           1/n*sum(x.*(y .+ w.*40*52 .- w.*gammaL .+ x.*B0.*(gammaC .- y .- w.*L .+ w.*gammaL) .- C)), # moment for leisure
           1/n*sum((y .+ w.*(40*52) .- w.*gammaL .+ x.*B0.*(gammaC .- y .- w.*L .+ w.*gammaL) .- C)./(y .+ w.*(40*52) .- w.*gammaL .- gammaC))] # moment for epsilon
    return obj'*obj
end

ranges = [(-100, 100), (-10, 5000), (0, 100000)]
res = bboptimize(GMM; SearchRange = ranges, NumDimensions = 3) #, MaxTime = 10)
a = best_candidate(res)
GMM(a)

b = optimize(GMM, a, LBFGS(), Optim.Options(show_trace = true)) |> Optim.minimizer

c = optimize(GMM, a, NelderMead(), Optim.Options(show_trace = true)) |> Optim.minimizer

GMM(a)