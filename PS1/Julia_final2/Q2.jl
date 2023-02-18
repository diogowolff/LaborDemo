using LinearAlgebra
using Base.Threads
using Queryverse
using DataFrames
using Statistics
using Distributions
using Random
using Plots; pyplot()
using Optim
using StatsPlots
# using FileIO
using JLD2
using BlackBoxOptim

# copying main dataframe
df = load("data_Q2_Q3.csv") |> DataFrame;

df = df[shuffle(1:nrow(df))[1:10000], :]

###########
##  (a)  ##
###########

# Definitions for Kernel regression
D = Matrix([df[!, [:AGE, :EDUCD, :NCHILD]] df[!,:HHINCOME] .- df[!,:INCWAGE]]);
y = df.EMPSTAT .!= 3;

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
    return Kx'*Y./sum(Kx)
end

# Estimating conditional probabilities

probs = map(x -> kernel(x, D, y), eachrow(D))


# probs = Vector{Float64}(undef, nrow(df));
# @threads for k in 1:size(D, 1)
#     probs[k] = kernel(D[k,:], D, y)
# end


###########
##  (b)  ##
###########

# Removing people NILF and computing wages
Dy, w, probsy = D[y,:], probs[y]
w = df.INCWAGE ./ (df.UHRSWORK .* df.WKSWORK2);
w = w[y]

gw = Vector{Float64}(undef, size(Dy, 1))
gx = Matrix{Float64}(undef, size(Dy, 1), 2)

for k in 1:size(Dy, 1) # @threads
    gw[k] = kernel(probsy[k], probsy, wy)
    gx[k,:] = kernel(probsy[k], probsy, Dy[:, 1:2])
end

ew = wy .- gw;
ex = Dy[:,1:2] .- gx;

gamma = inv(ex'*ex)*(ex'*ew)

### PLotting M
# M = gw .- gx*gamma
# DD = [probs M]
# DD = DD[sortperm(DD[:, 1]), :]
# plot(DD[:,1], DD[:,2])
###

###########
##  (c)  ##
###########

X = Matrix([ones(nrow(df)) df.AGE df.NCHILD]);
Z = Matrix([df.AGE df.EDUCD]);
nly = df.HHINCOME .- df.INCWAGE;

sm(x) = 1/(1 + exp(10*(1/2 - x))) # probability smoother

function loglike(pars)
    alpha = pars[1:3]
    beta = pars[4]
    D = Z*gamma - X*alpha - nly*beta # troquei sinal
    
    probs = Vector{Float64}(undef, size(D, 1));
    for k in 1:size(D, 1) # @threads
        probs[k] = kernel(D[k], D, y)
    end

    probs[probs .< 0] .= 0
    probs[probs .> 1] .= 1
    probs = sm.(probs)

    # if sum(1 .- (0 .< probs .< 1)) != 0 return Inf end

    return - sum(y.*log.(probs) .+ (1 .- y).*(log.(1 .- probs)))
end

### Local optimization
# a = optimize(loglike, [-0.892754, -3.54437, -1.15664, -2.4652], Optim.Options(show_trace = true))
# a = optimize(loglike, [2.59586, 1.52545, 4.14018, -0.000230074], BFGS(), Optim.Options(show_trace = true))
# Optim.minimizer(a)

### Global Optimization
ranges = [(-300, 400), (-10, 10), (-10, 10), (-10, 10)]
res = bboptimize(loglike; SearchRange = ranges, NumDimensions = 4, MaxTime = 2700)


# Best candidate: [82.924, 6.61095, -5.62199, -0.0881276]





################
## EXTRA CODE ##
################    (Please ignore in a first read)


### EXTRA 1: Plotting probabilities

# Function to compute 3D Plots
function plotProb(values, grid1, grid2)
    function zAxis(x_grid1, y_grid2)
        xx = findfirst(x -> x == x_grid1, grid1)
        yy = findfirst(y -> y == y_grid2, grid2)
        return values[xx, yy]
    end

    return plot(grid1, grid2, zAxis, st=:surface, camera = (-60, 30))
    zlims!(0.5, 1)
end

# Setting up grids
gridEDUCD = range(quantile(D[:,2], 0.1), quantile(D[:,2], 0.9));
gridNLINC = range(0, quantile(D[:,4], 0.9), length = 100);
indexes = [(educd, nlinc) for educd in 1:length(gridEDUCD), nlinc in 1:length(gridNLINC)];
values = Array{Float64}(undef, size(indexes));

## Computing Kernel for AGE = 35, NCHILD = 1
for (educd, nlinc) in indexes
    values[educd, nlinc] = kernel([35, gridEDUCD[educd], 0, gridNLINC[nlinc]], D, y)
end

plotProb(values, gridEDUCD, gridNLINC)
plot!(size=(600,400))
savefig("prob_35_0.pdf")

## Computing Kernel for AGE = 45, NCHILD = 3
for (educd, nlinc) in indexes
    values[educd, nlinc] = kernel([50, gridEDUCD[educd], 3, gridNLINC[nlinc]], D, y)
end

plotProb(values, gridEDUCD, gridNLINC)
plot!(size=(600,400))
savefig("prob_50_3.pdf")