using LinearAlgebra
using Base.Threads
using CSV
using DataFrames
using Statistics
using Distributions
using Random
using Plots; pyplot()
using Optim
using StatsPlots
using BlackBoxOptim

# copying main dataframe
df = CSV.read("data_Q2_Q3.csv", DataFrame)

# Setting up variables
X = Matrix([ones(nrow(df)) df.AGE df.NCHILD]);
Z = Matrix([df.AGE df.EDUCD]);
P = df.EMPSTAT .∉ 3;
w = df.INCWAGE ./ (df.UHRSWORK .* df.WKSWORK2);
w[isnan.(w)] .= 0
nly = df.HHINCOME .- df.INCWAGE; # non-labor income

Ncdf(x) = cdf(Normal(), x);
Npdf(x) = pdf(Normal(), x);

sm(x) = ( 1/(1 + exp(1/2 - x)) )*0.01 + x*0.99 # probability smoother

# negative log likelihood to be minimized
function loglike(pars)
    alpa, beta, gamma = pars[1:3], pars[4], pars[5:6]
    std_eps, std_ksi, rho = pars[7:9]

    std_eta = sqrt(std_eps^2 + std_ksi^2 - 2*rho*std_eps*std_ksi)

    probabilities = (1 .- P) .* Ncdf.((X*alpa .+ beta*nly .- Z*gamma)./std_eta) .+
                    P .* (1/std_ksi) .* Npdf.((w .- Z*gamma)./std_eta) .*
                    Ncdf.((w .- X*alpa .- beta*nly .- (rho*std_eps/std_ksi).*(w - Z*gamma))./(std_eps*sqrt(1 - rho^2)))
    
    return - mean(log.(sm.(probabilities)))
end

# Global optimization
ranges = [(-500, 500), (-500, 500), (-500, 500), (-500, 500), (-500, 500),
          (-500, 500), (0.001, 200), (0.001, 200), (-0.999, 0.999)];

res = bboptimize(loglike; SearchRange = ranges, NumDimensions = 9)

# Checking
initPars = best_candidate(res)

lower = [-Inf, -Inf, -Inf, -Inf, -Inf, -Inf, 0.001, 0.001, -0.999]
upper = [Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, 0.999]

results = optimize(loglike, lower, upper, initPars, Fminbox(LBFGS()),
                   Optim.Options(show_trace = true)) |> Optim.minimizer