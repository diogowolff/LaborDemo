using LinearAlgebra
using Base.Threads
# using Queryverse
using CSV
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


# Loading main dataframe
df = CSV.read("data_Q2_Q3.csv", DataFrame)

# We subset the data to 50 thousand observations for a faster runtime.
Random.seed!(1234)
df = df[shuffle(1:nrow(df))[1:50000], :]

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
probs = Vector{Float64}(undef, size(D, 1));

@threads for k in 1:size(D, 1)
    probs[k] = kernel(D[k,:], D, y)
end


###########
##  (b)  ##
###########

# Removing people without wages and computing wages
Dw, probsw = D[df.EMPSTAT .== 1,:], probs[df.EMPSTAT .== 1]
w = df.INCWAGE ./ (df.UHRSWORK .* df.WKSWORK2);
w[isnan.(w)] .= 0
w = w[df.EMPSTAT .== 1]

gw = Vector{Float64}(undef, size(Dw, 1))
gx = Matrix{Float64}(undef, size(Dw, 1), 2)

@threads for k in 1:size(Dw, 1) # @threads
    gw[k] = kernel(probsw[k], probsw, w)
    gx[k,:] = kernel(probsw[k], probsw, Dw[:, 1:2])
end

ew = w .- gw;
ex = Dw[:,1:2] .- gx;

gamma = inv(ex'*ex)*(ex'*ew)

###########
##  (c)  ##
###########

# We subset the data to 10 thousand observations for a faster runtime.
df = df[shuffle(1:nrow(df))[1:10000], :]

X = Matrix([ones(nrow(df)) df.AGE df.NCHILD]);
Z = Matrix([df.AGE df.EDUCD]);
nly = df.HHINCOME .- df.INCWAGE;

sm(x) = ( 1/(1 + exp(1/2 - x)) )*0.01 + x*0.99# probability smoother


function loglike(pars)
    alpha = pars[1:3]
    beta = pars[4]
    D = X*alpha + nly*beta - Z*gamma
    
    probs = Vector{Float64}(undef, size(D, 1));
    @threads for k in 1:size(D, 1)
        probs[k] = kernel(D[k], D, y)
    end

    probs[probs .< 0] .= 0
    probs[probs .> 1] .= 1
    # probs = sm.(probs)

    return - sum(y.*log.(1 .- probs) .+ (1 .- y).*(log.(probs)))
end

# Global Optimization (rough)
ranges = [(-250, 250), (-250, 250), (-250, 250), (-250, 250)]
initPars = bboptimize(loglike; SearchRange = ranges, NumDimensions = 4) # [220.5697197319912, -4.814626102848045, -5.243655948924608, 7.838865426929552e-5]

# Local optimization
a = optimize(loglike, initPars, NelderMead(), Optim.Options(show_trace = true)) # [282.38594054567596, -7.372918134082949, -2.144872661981191, 0.0002601856818396992]
# a = optimize(loglike, initPars, LBFGS(), Optim.Options(show_trace = true))

opt = Optim.minimizer(a)


###########
##  (d)  ##
###########

alpa, beta = opt[1:3], opt[4];
D = X*alpa + nly*beta - Z*gamma;
y = y[sortperm(D)];
D = sort!(D);

@threads for k in 1:size(D, 1)
    probs[k] = kernel(D[k], D, y)
end

k = length(probs);

plot(D, probs, ylabel = "probability", xlabel = "α'x + βy - z'γ")
plot!(size=(600,400))
savefig("testing.pdf")








################
## EXTRA CODE ##
################

### EXTRA 1: Plotting probs density conditional on EMPSTAT
density(probs[df.EMPSTAT .== 1], label="Employed", legend=:topleft, xlabel = "Estimated probability", ylabel = "density")
density!(probs[df.EMPSTAT .== 2], label="Unemployed", legend=:topleft)
density!(probs[df.EMPSTAT .== 3], label="NILF", legend=:topleft)
plot!(size=(600,400))
savefig("prob_empstat.pdf")

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