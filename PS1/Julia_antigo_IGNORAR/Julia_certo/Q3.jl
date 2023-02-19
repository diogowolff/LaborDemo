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
# using ForwardDiff
using BlackBoxOptim
using JLD2

# copying main dataframe
cd("D:\\Users\\b44821\\OneDrive - Fundacao Getulio Vargas - FGV\\Documentos")
df = CSV.read("data_Q2_Q3.csv", DataFrame)

# Setting up variables
X = Matrix([ones(nrow(df)) df.AGE df.NCHILD]);
Z = Matrix([df.EDUCD df.AGE]); # trocado em rel Q2
P = df.EMPSTAT .∉ 3;
w = df.INCWAGE ./ (df.UHRSWORK .* df.WKSWORK2);
w[isnan.(w)] .= 0
nly = df.HHINCOME .- df.INCWAGE;

Ncdf(x) = cdf(Normal(), x);
Npdf(x) = pdf(Normal(), x);

sm(x) = ( 1/(1 + exp(1/2 - x)) )*0.01 + x*0.99 # probability sm

# recover_rho(x) = 2/(1 + exp(-x))-1 # function to force rho to be between -1 and 1

function loglike(pars)
    alpa, beta, gamma = pars[1:3], pars[4], pars[5:6]
    std_eps, std_ksi, rho = pars[7:9]

    # std_eps = std_eps^2 # force std_eps to be positive
    # std_ksi = std_ksi^2 # force std_ksi to be positive
    # rho = recover_rho(rho) # force rho to be between -1 and 1

    std_eta = sqrt(std_eps^2 + std_ksi^2 - 2*rho*std_eps*std_ksi)

    probabilities = (1 .- P) .* Ncdf.((X*alpa .+ beta*nly .- Z*gamma)./std_eta) .+
                    P .* (1/std_ksi) .* Npdf.((w .- Z*gamma)./std_eta) .*
                    Ncdf.((w .- X*alpa .- beta*nly .- (rho*std_eps/std_ksi).*(w - Z*gamma))./(std_eps*sqrt(1 - rho^2)))
    
    return - mean(log.(sm.(probabilities)))
end

# Ranges in which to search. Determined through previous tests with wider ranges
ranges = [(-500, 500), (-50, 50), (-50, 50), (-50, 50), (-50, 50), (-50, 50), (0, 20), (0, 20), (-1, 1)];

res = bboptimize(loglike; SearchRange = ranges, NumDimensions = 9, MaxTime = 1000)
opt = best_candidate(res) # [-230.35708203127217, -5.940527165006209, -10.437009832268076, 34.02515345109012, 0.9128651219842667, -2.534321156255178, 13.217371057037958, 13.204292563222857, -0.7183898852022552]

save_object("Q3v2.jld2", res)

b = optimize(loglike, opt, LBFGS(), Optim.Options(show_trace = true, iterations = 10000)) |> Optim.minimizer

c = optimize(loglike, opt, NelderMead(), Optim.Options(show_trace = true, iterations = 10000)) |> Optim.minimizer

initPars = [155.63353029473535, 81.57539655029177, -9.099055156112172, 96.4011978647705, -91.4225382140427, -185.95332711438886, 81.05006695914284, 47.426926385851196, 0.28499418799781706]



function plotutil(x, i)
    vars = [155.63353029473535, 81.57539655029177, -9.099055156112172, 96.4011978647705, -91.4225382140427, -185.95332711438886, 81.05006695914284, 47.426926385851196, 0.28499418799781706]
    vars[i] = x - vars[i]
    return loglike(vars)
end

for var in 1:length(initPars)
    plot(x -> plotutil(x, var))
end

plot(x -> plotutil(x, 3))




# our version
initPars = [-26.8094, 5.69398, 19.5361, 18.6278, 9.07518, -43.887, 47.7428, 24.2738, -0.319955]
initPars = [157.423, 9.19816, -142.163, 88.0506, -186.613, -55.9878, 33.5756, 56.5174, -0.568708]


# original slide:
initPars = [188.285, 87.9363, -7.88152, 10.0153, 16.444, -180.893, 49.0478, 53.6942, -0.928273]
initPars = [188.285, 87.9363, -7.88152, 10.0153, 16.444, -180.893, 49.0478, 53.6942, -0.928273] # (after running through LBFGS)


# Verifying that the point is indeed a global minimum with LBFGS and Nelder Mead
b = optimize(loglike, initPars, LBFGS(), Optim.Options(show_trace = true, iterations = 10000)) |> Optim.minimizer

c = optimize(loglike, initPars, NelderMead(), Optim.Options(show_trace = true, iterations = 10000)) |> Optim.minimizer



# od = OnceDifferentiable(loglike, initPars; autodiff = :forward)

# params = DataFrame(names = ["alpa_const", "alpa_age", "alpa_nchild", "beta_NLinc", "gamma_educd", "gamma_age", "std_eps", "std_ksi", "rho"],
#                    params = [MLest[1:6]..., MLest[7]^2, MLest[8]^2, recover_rho(MLest[9])])

loglike(initPars)


initPars = [-2.0, 2.0, -2.0, -2.0, 2.0, 2.0, 5, 5, 0.1]
initPars = [-0.892754, -3.54437, -1.15664, -2.4652, 0.022961, 0.280399, 1.65999, 4.19041, -0.370113] # blackbox find
initPars = [-0.892754, -3.54437, -1.15664, -2.4652, 0.0871849189610284, 0.04764383492844194, 1.65999, 1.2183231235962169, -0.370113] # improved with LBFGS
initPars = [-0.892754, -3.54437, -1.15664, -2.4652, 0.0871849189610284, 0.04764383492844194, 1.65999, 1.2183231235962169, -0.370113] # improved with nelder NelderMead
initPars = [-1.84878, -3.61491, -2.01312, 0.000663976, 0.0865954, 0.0493046, 3.76602, 1.23001, -0.627425]