# using Queryverse
using DataFrames
using Dates
using Statistics
using StatsPlots
using CSV
# using FileIO

### Loading data for machines that can't run Queryverse
cd("D:\\Users\\b44821\\OneDrive - Fundacao Getulio Vargas - FGV\\Documentos")
df = CSV.read("full_data.csv", DataFrame)

### Loading data for machines that can't run CSV
# df = load("data_woman_age.csv", delim = ',') |> DataFrame

select!(df, :YEAR, :SEX, :AGE, :EDUCD, :NCHILD, :EMPSTAT, :EMPSTATD, :INCWAGE, :HHINCOME, :INCTOT, :UHRSWORK, :WKSWORK2)

df = df[(25 .<= df.AGE .<= 55) .& (df.SEX .== 2), :];

df = df[(df.EDUCD .!= 001) .&
        (df.EDUCD .!= 999) .&
        (df.INCWAGE .!= 999998) .&
        (df.INCWAGE .>= 0) .&
        (df.EMPSTAT .!= 0) .&
        (df.EMPSTATD .!= 00) .&
        (df.INCWAGE .!= 9999999) .& (df.HHINCOME .!= 9999999) .&
        .!((df.EMPSTAT .!= 1) .& (df.INCWAGE .> 0)) .&
        (df.HHINCOME .- df.INCWAGE .> 0), :]

df.WKSWORK2 = [0, 7, 20, 33, 43.5, 48.5, 51][df.WKSWORK2 .+ 1];

[filter!(col => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), df) for col in Symbol.(names(df))];

# price index
priceInd = CSV.read("median_consumer_price_index.csv", DataFrame)
rename!(priceInd, :MEDCPIM094SFRBCLE => :INDEX);
priceInd.DATE = Dates.year.(priceInd.DATE);
rename!(priceInd, :DATE => :YEAR);
priceInd = groupby(priceInd, :YEAR);
priceInd = combine(priceInd, :INDEX => mean => :INDEX);
transform!(priceInd, :INDEX => (x -> x/priceInd[1, :INDEX]) => :INDEX);

# deflate nominal values
leftjoin!(df, priceInd, on = :YEAR);
df[!, [:INCWAGE, :HHINCOME]] = df[!, [:INCWAGE, :HHINCOME]]./df.INDEX;

# save("data_Q2_Q3.csv", df)
CSV.write("data_Q2_Q3.csv", df) # Final dims should be 7884758×12