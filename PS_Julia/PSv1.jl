using LinearAlgebra
# using CSV
using DataFrames
using Queryverse
using Statistics
using Distributions
using Base.Threads
using Plots; pyplot()
using FileIO
using JLD2

# Loading data
cd("C:\\Users\\guiex\\EPGE\\Labor\\Problem Set")

df = load("data_clean.csv", delim = ',') |> DataFrame

# Definitions for Kernel regression
d = 3;
Z = Matrix(df[!, [:AGE, :EDUCD, :NCHILD]]);
n = size(Z)[1];
y = (df[!, :EMPSTAT]) .∉ 3;

# Computing optimal bandwidth
sds = map(std, eachcol(Z));
bws = sds*(4/((d+2)*n))^(1/(d + 4));

# Multivariate normal pdf
F(x) = pdf(MvNormal(zeros(d), I), x);

# Kernel
function mhat(point, bws)
    Zx = Z .- point'
    Kx = map(x -> F(x./bws), eachrow(Zx))
    return Kx'*y/sum(Kx)
end

# Computing Kernel over grid
gridAGE = range(minimum(Z[:,1]), maximum(Z[:,1]));
gridEDUCD = range(minimum(Z[:,2]), maximum(Z[:,2]));
gridNCHILD = range(minimum(Z[:,3]), maximum(Z[:,3]));

indexes = [(age, educd, nchild) for age in 1:length(gridAGE),
                                    educd in 1:length(gridEDUCD),
                                    nchild in 1:length(gridNCHILD)];

values = Array{Float64}(undef, size(indexes));

# Main loop
@threads for (age, educd, nchild) in indexes
    values[age, educd, nchild] = mhat([gridAGE[age], gridEDUCD[educd], gridNCHILD[nchild]], bws)
end

# Save array for later use
FileIO.save("values.jld2", "values", values)


plot(values[:,:,1], st=:surface, camera = (150,30))