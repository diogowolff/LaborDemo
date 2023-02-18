using LinearAlgebra
using Base.Threads
using Queryverse
using CSV
using DataFrames
using Statistics
using Distributions
using Random
using Plots; pyplot()
using Optim
using StatsPlots
using ForwardDiff
using BlackBoxOptim


# copying main dataframe
df3 = df[!, [:AGE, :EDUCD, :NCHILD, :EMPSTAT, :INCWAGE, :HHINCOME, :UHRSWORK, :WKSWORK2]]


nominalValues = [:HHINCOME, :INCTOT, :INCWAGE, :INCWELFR, :INCSS];

df = df[(df3.EDUCD .!= 001) .&
        (df3.EDUCD .!= 999) .&
        (df3.INCWAGE .!= 999998) .&
        (df3.HHINCOME .>= 0) .&
        (df3.EMPSTAT .!= 0) .& (df3.WKSWORK2 .!= 0) .&
        (df3.EMPSTATD .!= 00) .& (df3.UHRSWORK .!= 00) .&
        (sum(eachcol(df[!, nominalValues] .== 9999999)) .== 0)
        , :]
df3[!, nominalValues] = df3[!, nominalValues]./df3.INDEX;

# DATA WOMAN CLEAN

df3 = df3[df3.INCWAGE > 0, :]
# df3 = df3[shuffle(1:nrow(df3))[1:100000], :];

# Setting up variables
X = Matrix([ones(nrow(df3)) df3.AGE df3.NCHILD]);
Z = Matrix([df3.EDUCD df3.AGE]);
P = df3.EMPSTAT .∉ 3;
w = df3.INCWAGE ./ (df3.UHRSWORK .* df3.WKSWORK2);
nly = df3.HHINCOME .- df3.INCWAGE;

Ncdf(x) = cdf(Normal(), x);
Npdf(x) = pdf(Normal(), x);

smoother(x) = 1/(1 + exp(5*(1/2 - x))) # probability smoother

recover_rho(x) = 2/(1 + exp(-x))-1 # function to force rho to be between -1 and 1

function loglike(pars)
    function prob(P, w, nly, Z, X)
        if P == 0
            return Ncdf((X'*alpa + beta*nly - Z'*gamma)/std_eta)
        else
            return (1/std_ksi) * Npdf((w - Z'*gamma)/std_ksi) * Ncdf((w - X'*alpa - beta*nly - rho*std_eps/std_ksi*(w - Z'*gamma))/(std_eps*sqrt(1 - rho^2)))
            #                                        std_eta in the slide
        end
    end

    alpa, beta, gamma = pars[1:3], pars[4], pars[5:6]
    std_eps, std_ksi, rho = pars[7:9]

    std_eps = std_eps^2 # force std_eps to be positive
    std_ksi = std_ksi^2 # force std_ksi to be positive
    rho = recover_rho(rho) # force rho to be between -1 and 1

    std_eta = sqrt(std_eps^2 + std_ksi^2 - 2*rho*std_eps*std_ksi)
    
    probabilities = smoother.(prob.(P, w, nly, eachrow(Z), eachrow(X)))

    return - sum(log.(probabilities))
end

initPars = [-2.0, 2.0, -2.0, -2.0, 2.0, 2.0, 5, 5, 0.1]
initPars = [0.368133, -4.75198, -2.71201, -0.0188729, 0.0977555, 0.0280349, 0.846266^2, 1.0285^2, recover_rho(-2.91285)] ## bboptimize result
initPars = [-0.892754, -3.54437, -1.15664, -2.4652, 0.022961, 0.280399, 1.65999, 4.19041, -0.370113] # blackbox find
initPars = [-0.892754, -3.54437, -1.15664, -2.4652, 0.0871849189610284, 0.04764383492844194, 1.65999, 1.2183231235962169, -0.370113] # improved with LBFGS
initPars = [-0.892754, -3.54437, -1.15664, -2.4652, 0.0871849189610284, 0.04764383492844194, 1.65999, 1.2183231235962169, -0.370113] # improved with nelder NelderMead
initPars = [-1.84878, -3.61491, -2.01312, 0.000663976, 0.0865954, 0.0493046, 3.76602, 1.23001, -0.627425]

MLest = optimize(loglike, initPars, NelderMead(), Optim.Options(show_trace = false, iterations = 10000)) |> Optim.minimizer

ranges = [(-5.0, 5.0), (-5.0, 5.0), (-5.0, 5.0), (-5.0, 5.0), (-5.0, 5.0), (-5.0, 5.0), (0.00001, 5.0), (0.00001, 5.0), (-0.99999, 0.99999), ]
res = bboptimize(loglike; SearchRange = ranges, NumDimensions = 9, MaxTime = 100)


# od = OnceDifferentiable(loglike, initPars; autodiff = :forward)

params = DataFrame(names = ["alpa_const", "alpa_age", "alpa_nchild", "beta_NLinc", "gamma_educd", "gamma_age", "std_eps", "std_ksi", "rho"],
                   params = [MLest[1:6]..., MLest[7]^2, MLest[8]^2, recover_rho(MLest[9])])


