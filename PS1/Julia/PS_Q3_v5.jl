using LinearAlgebra
using Base.Threads
#using Queryverse
using CSV
using DataFrames
using Statistics
using Distributions
using Random
using Plots; pyplot()
using Optim
using StatsPlots
using ForwardDiff

# Loading data
cd("D:\\Users\\B44821\\Documents\\Labor PS")
# df = load("data_woman_age_subsample.csv", delim = ',') |> DataFrame;

df = CSV.read("data_woman_age_large_clean.csv", DataFrame)

df = dfo[shuffle(1:nrow(dfo))[1:10000], :];

# Setting up variables
X = Matrix([ones(nrow(df)) df.AGE df.NCHILD]);
Z = Matrix([df.EDUCD df.AGE]);
P = df.EMPSTAT .∉ 3;
w = df.INCWAGE ./ (df.UHRSWORK .* df.WKSWORK2);
nly = df.HHINCOME .- df.INCWAGE;

Ncdf(x) = cdf(Normal(), x);
Npdf(x) = pdf(Normal(), x);
dNpdf(x) = -x/(2*pi)*exp(-x^2/2)

smoother(x) = 1/(1 + exp(5*(1/2 - x)))
dsmoother(x) = (5*exp(5*(1/2 - x)))/(1 + exp(5*(1/2 - x)))^2

recover_rho(x) = 2/(1+exp(-x))-1 # function to force rho to be between -1 and 1

function loglike(pars) # ::Vector{BigFloat}
    function prob(P, w, nly, Z, X)
        if P == 0
            return Ncdf((X'*alpa + beta*nly - Z'*gamma)/std_eta)
        else
            return (1/std_ksi) * Npdf((w - Z'*gamma)/std_eta) * Ncdf((w - X'*alpa - beta*nly - rho*std_eps/std_ksi*(w - Z'*gamma))/(std_eps*sqrt(1 - rho^2)))
            #                                        std_eta in the slide
        end
    end

    alpa, beta, gamma = pars[1:3], pars[4], pars[5:6]
    std_eps_par, std_ksi_par, rho_par = pars[7:9]

    #std_eps = std_eps_par^2 # force std_eps to be positive
    #std_ksi = std_ksi_par^2 # force std_ksi to be positive
    #rho = recover_rho(rho_par) # force rho to be between -1 and 1

    var_eta = std_eps^2 + std_ksi^2 - 2*rho*std_eps*std_ksi

    std_eta = sqrt(var_eta)
    
    probabilities = smoother.(prob.(P, w, nly, eachrow(Z), eachrow(X)))

    return - sum(log.(probabilities))
end

initPars = [-2.0, 2.0, -2.0, -2.0, 2.0, 2.0, 4, 4, 0.1]

initPars = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5, 5, 0.0]

MLest = optimize(loglike, g!, initPars, LBFGS(), Optim.Options(show_trace = true, iterations = 10000)) |> Optim.minimizer

function g!(storage, x)
    storage = ForwardDiff.gradient(loglike, x)
end

od = OnceDifferentiable(loglike, initPars; autodiff = :forward)

MLest2 = optimize(loglike, g!, initPars, LBFGS(), Optim.Options(show_trace = true, iterations = 10000)) |> Optim.minimizer


params = DataFrame(names = ["alpa_const", "alpa_age", "alpa_nchild", "beta_NLinc", "gamma_educd", "gamma_age", "std_eps", "std_ksi", "rho"], params = [MLest[1:6]..., MLest[7]^2, MLest[8]^2, recover_rho(MLest[9])])




# DERIVATIVES

function g!(x)

    alpa, beta, gamma = x[1:3], x[4], x[5:6]
    std_eps_par, std_ksi_par, rho_par = x[7:9]

    compuTerm(param1, param0) = -sum(P .* P1dS ./ P1S .* param1 .+ (1 .- P) .* P0dS ./ P0S .* param0)

    # Probabilities
    P0 = Ncdf.((X*alpa + beta*nly - Z*gamma)/std_eta)
    P1 = (1/std_ksi) * Npdf.((w - Z*gamma)/std_ksi) .* Ncdf.((w - X*alpa - beta*nly - rho*std_eps/std_ksi*(w - Z*gamma))/(std_eps*sqrt(1 - rho^2)))

    P0S, P1S = smoother.(P0), smoother.(P1)
    P0dS, P1dS = dsmoother.(P0), dsmoother.(P1)

    # Terms
    A = (X*alpa + beta*nly - Z*gamma)/std_eta
    B = (w - Z*gamma)/std_eta
    C = (w - X*alpa - beta*nly - rho*std_eps./std_ksi.*(w - Z*gamma))./(std_eps*sqrt(1 - rho^2))

    # Derivatives of probs
    rho_P0 = Npdf.(A) .* (X*alpa + beta*nly .- Z*gamma)./(std_eta^2) .* (2*std_eps*std_ksi)
    rho_P1 = 1/std_ksi .* Npdf.(B) .* Npdf.(C) .* (- rho/std_ksi*(w - Z*gamma) * std_ksi*sqrt(1-rho^2) +
        (w - X*alpa - beta*nly - rho*std_eps/std_ksi*(w - Z*gamma))*std_eps*rho/sqrt(1 - rho^2))/(std_eps^2*(1 - rho^2))

    std_eps_P0 = Npdf.(A) .* (X*alpa + beta*nly - Z*gamma)/(std_eta^2) .* (2*rho*std_ksi)
    std_eps_P1 = 1/std_ksi .* Npdf.(B) .* Npdf.(C) .* (- rho/std_ksi*(w - Z*gamma)*std_ksi*sqrt(1-rho^2) - (w - X*alpa - beta*nly - rho*std_eps/std_ksi*(w - Z*gamma))*sqrt(1 - rho^2))/(std_eps^2*(1 - rho^2))

    alpa1_P0 = dNpdf.(A).*X[:,1]./std_eta;
    alpa1_P1 = -Npdf.(B).*Npdf.(C).*X[:,1]./(std_eps*sqrt(1-rho^2)*std_ksi);

    alpa2_P0 = dNpdf.(A).*X[:,2]./std_eta;
    alpa2_P1 = -Npdf.(B).*Npdf.(C).*X[:,2]./(std_eps*sqrt(1-rho^2)*std_ksi);

    alpa3_P0 = dNpdf.(A).*X[:,3]./std_eta;
    alpa3_P1 = -Npdf.(B).*Npdf.(C).*X[:,3]./(std_eps*sqrt(1-rho^2)*std_ksi);

    beta_P0 = dNpdf.(A).*nly./std_eta;
    beta_P1 = -Npdf.(B).*Npdf.(C).*nly./(std_eps*sqrt(1-rho^2)*std_ksi);

    gamma1_P0 = -dNpdf.(A).*Z[:,1]./std_eta;
    gamma1_P1 = (-dNpdf.(B).*Ncdf.(C).*Z[:,1]./std_ksi + Npdf.(B).*Npdf.(C).*Z[:,1].*
        (rho/(std_ksi*sqrt(1-rho^2))))./std_ksi;

    gamma2_P0 = -dNpdf.(A).*Z[:,2]./std_eta;
    gamma2_P1 = (-dNpdf.(B).*Ncdf.(C).*Z[:,2]./std_ksi + Npdf.(B).*Npdf.(C).*Z[:,2].* 
        (rho/(std_ksi*sqrt(1-rho^2))))./std_ksi;

    std_ksi_P0 = -Npdf.(A).*(2*X*alpa + beta*nly - Z*gamma).*((2*std_ksi - 2*rho*std_eps)/(std_ksi^2- 2*rho*std_eps*std_ksi + std_eps^2)^2);
    std_ksi_P1 = (dNpdf.(B).*Ncdf.(C).*(Z*gamma - w)./std_ksi^2 +
        Npdf.(B).*Npdf.(C).*(w-Z*gamma).*(rho*std_eps/std_ksi^2) )./std_ksi -
        Npdf.(B).*Ncdf.(C)./std_ksi^2;

    storage = ones(9)
    storage[1] = compuTerm(alpa1_P1, alpa1_P0)
    storage[2] = compuTerm(alpa2_P1, alpa2_P0)
    storage[3] = compuTerm(alpa3_P1, alpa3_P0)
    storage[4] = compuTerm(beta_P1, beta_P0)
    storage[5] = compuTerm(gamma1_P1, gamma1_P0)
    storage[6] = compuTerm(gamma2_P1, gamma2_P0)
    storage[7] = compuTerm(std_eps_P1, std_eps_P0)
    storage[8] = compuTerm(std_ksi_P1, std_ksi_P0)
    storage[9] = compuTerm(rho_P1, rho_P0)
    return storage
end











###
f(x) = (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2

function g!(storage, x)
    storage[1] = -2.0 * (1.0 - x[1]) - 400.0 * (x[2] - x[1]^2) * x[1]
    storage[2] = 200.0 * (x[2] - x[1]^2)
end

a = optimize(f, g!, [0.0, 0.0], LBFGS())

Optim.minimizer(a)