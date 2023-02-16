using LinearAlgebra
using Base.Threads
using Queryverse
using DataFrames
using Statistics
using Distributions
using Random
using Base.Threads
using Plots; pyplot()
using Optim
# using StatsPlots
# using FileIO
# using JLD2
using BlackBoxOptim

# copying main dataframe
df2 = copy(df)

# question-specific cleaning
deleteat!(df2, (df2.INCWAGE .> 0) .& (df2.EMPSTAT .== 3))
deleteat!(df2, df2.HHINCOME .< 0)

###########
##  (a)  ##
###########

# Definitions for Kernel regression
D = Matrix([df2[!, [:AGE, :EDUCD, :NCHILD]] df2[!,:HHINCOME] .- df2[!,:INCWAGE]]);
y = .!in.(df2.EMPSTAT, 3)
w = df2.INCWAGE ./ (df2.UHRSWORK .* df2.WKSWORK2);

# Kernel
function kernel(point, X, Y)
    n = size(X, 1)
    d = size(X, 2)
    if d > 1
        bw = std.(eachcol(X))*(4/((d+2)*n))^(1/(d + 4))
        Zx = X .- point'
        Kx = map(x -> pdf2(MvNormal(zeros(d), I), x./bw), eachrow(Zx))
    else
        bw = 1.059*n^(-0.2)*std(X)
        Zx = X .- point
        Kx = map(x -> pdf2(Normal(0,1), x/bw), Zx)
    end
    return Kx'*Y./sum(Kx)
end

# Adding column with probs

# probs = map(x -> kernel(x, D[1:1000,:], y[1:1000]), eachrow(D[1:1000,:]))
probs = Vector{Float64}(undef, nrow(df2));
@threads for k in 1:nrow(df2)
    probs[k] = kernel(D[k,:], D, y)
end


### PLOTTING PROBAS
# Computing Kernel over grid
# gridAGE = range(minimum(D[:,1]), maximum(D[:,1]));
# gridEDUCD = range(minimum(D[:,2]), maximum(D[:,2]));
# gridNCHILD = range(minimum(D[:,3]), maximum(D[:,3]));
# gridNLINC = range(minimum(D[:,4]), maximum(D[:,4]), length = 100);
#
# indexes = [(age, educd, nlinc) for age in 1:length(gridAGE),
#                                     educd in 1:length(gridEDUCD),
#                                     nlinc in 1:length(gridNLINC)];
#
# values = Array{Float64}(undef, size(indexes));
#
### Main loop
# @threads for (age, educd, nlinc) in indexes
#     values[age, educd, nlinc] = kernel([gridAGE[age], gridEDUCD[educd], 1, gridNLINC[nlinc]], D, y)
#     if age == educd print(age) end
# end
#
# function plotSolution(values, grid1, grid2; camera = (-30,30), which = "value")
#     function zAxis(x_grid1, y_grid2)
#         xx = findf2irst(x -> x == x_grid1, grid1)
#         yy = findf2irst(y -> y == y_grid2, grid2)
#         return values[xx, yy]
#     end
#
#     return plot(grid1, grid2, zAxis, st=:surface, camera = (-30, 30))
#     zlims!(0, 1)
# end
#
# plot(values[:,1,:], st=:surface, camera = (150,30))
# zlims!(0, 1)

###########
##  (b)  ##
###########

# gw = map(x -> kernel(x, probas, w), probas);
# gx = cat(map(x -> kernel(x, probas, D[:, 1:2]), probas)..., dims = 1);

gw = Vector{Float64}(undef, nrow(df2))
gx = Matrix{Float64}(undef, nrow(df2), 2)

@threads for k in 1:nrow(df2)
    gw[k] = kernel(probs[k], probs, w)
    gx[k,:] = kernel(probs[k], probs, D[:, 1:2])
end

ew = w .- gw;
ex = D[:,1:2] .- gx;

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

X = Matrix([ones(nrow(df2)) df2.AGE df2.NCHILD]);
Z = Matrix([df2.EDUCD df2.AGE]);
nly = df2.HHINCOME .- df2.INCWAGE;

sm(x) = 1/(1 + exp(10*(1/2 - x))) # probability smoother

function loglike(pars)
    alpha = pars[1:3]
    beta = pars[4]
    D = Z*gamma - X*alpha - nly*beta # troquei sinal
    
    probs = Vector{Float64}(undef, size(D, 1));
    @threads for k in 1:size(D, 1)
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