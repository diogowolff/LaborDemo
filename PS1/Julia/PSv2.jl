using LinearAlgebra
using Base.Threads
using Queryverse
using DataFrames
using Statistics
using Distributions
using Random
using Base.Threads
using Plots; pyplot()
# using StatsPlots
# using FileIO
# using JLD2

# Loading data
cd("C:\\Users\\guiex\\EPGE\\Labor\\Problem Set")
dfo = load("Extract3\\data_woman_age_clean.csv", delim = ',') |> DataFrame;

deleteat!(dfo, dfo[!,:HHINCOME] .< 0);

n = nrow(dfo);

### subsetting
df = dfo[shuffle(1:n)[1:100000],:]
n = nrow(df);
###

# Definitions for Kernel regression
Z = Matrix([df[!, [:AGE, :EDUCD, :NCHILD]] df[!,:HHINCOME] .- df[!,:INCWAGE]]);
y = df[!, :EMPSTAT] .∉ 3;
w = vec(df[!,:INCWAGE]);

# Kernel
function kernel(point, X, Y)
    n = size(X, 1)
    d = size(X, 2)
    if d > 1
        bw = std.(eachcol(X))*(4/((d+2)*n))^(1/(d + 4))
        Zx = X .- point'
        Kx = map(x -> pdf(MvNormal(zeros(d), I), x./bw), eachrow(Zx))
    else
        bw = 1.059*n^(-0.2)*std(X)
        Zx = X .- point
        Kx = map(x -> pdf(Normal(0,1), x/bw), Zx)
    end
    return Kx'*Y/sum(Kx)
end

# Adding column with probs

# probas = map(x -> kernel(x, Z[1:1000,:], y[1:1000]), eachrow(Z[1:1000,:]))
probas = Vector{Float64}(undef, n)
@threads for k in 1:n
    probas[k] = kernel(Z[k,:], Z, y)
end

# FileIO.save("probas.jld2", "probas", probas)

# Estimating gamma

# gw = map(x -> kernel(x, probas, w), probas);
gw = Vector{Float64}(undef, n)
@threads for k in 1:n
    gw[k] = kernel(probas[k], probas, w)
end

# gx = cat(map(x -> kernel(x, probas, Z[:, 1:2]), probas)..., dims = 1);
gx = Matrix{Float64}(undef,n,2)
@threads for k in 1:n
    gx[k,:] = kernel(probas[k], probas, Z[:, 1:2])
end

### testing
# gxtest = map(x -> kernel(x, probas, y), gridPROBAS);
# plot(gridPROBAS, gxtest)
###

ew = w .- gw;
ex = Z[:,1:2] .- gx;

gamma = inv(ex'*ex)*(ex'*ew);

# Estimating M

indep = w .- Z[:,1:2]*gamma;

gridPROBAS = range(0.5, round(maximum(probas)), step = 0.001);
M = map(x -> kernel(x, probas, indep), gridPROBAS);

plot(gridPROBAS, M)