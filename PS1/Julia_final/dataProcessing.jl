# using Queryverse
using DataFrames
using Dates
using Statistics
using StatsPlots
using CSV
using FileIO


### Loading data for machines that can't run Queryverse
cd("D:\\Users\\b44821\\Documents")
df = CSV.read("full_data.csv", DataFrame)
select!(df, :YEAR, :SEX, :AGE, :EDUCD, :NCHILD, :EMPSTAT, :EMPSTATD, :INCWAGE, :HHINCOME, :UHRSWORK, :WKSWORK2)

### Loading data for machines that can't run CSV
# cd("C:\\Users\\guiex\\EPGE\\Labor\\Problem Set")
# df = load("Extract1/20pct_dataset.csv", delim = ',') |> DataFrame;

# Removing missing, nothing and N/A 
[filter!(col => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), df) for col in Symbol.(names(df))];

df = df[(df.EDUCD .!= 001) .&
        (df.EDUCD .!= 999) .&
        (df.INCWAGE .!= 999998) .&
        (df.HHINCOME .>= 0) .& (df.INCWAGE .>= 0) .&
        (df.EMPSTAT .!= 0) .& (df.WKSWORK2 .!= 0) .&
        (df.EMPSTATD .!= 00) .& (df.UHRSWORK .!= 00) .&
        (df.INCWAGE .!= 9999999) .& (df.HHINCOME .!= 9999999), :]

df.WKSWORK2 = [0, 7, 20, 33, 43.5, 48.5, 51][df.WKSWORK2 .+ 1];


# price index
priceInd = CSV.read("median_consumer_price_index.csv", DataFrame)
rename!(priceInd, :MEDCPIM094SFRBCLE => :INDEX);
priceInd.DATE = Dates.year.(priceInd.DATE);
rename!(priceInd, :DATE => :YEAR);
priceInd = groupby(priceInd, :YEAR);
priceInd = combine(priceInd, :INDEX => mean => :INDEX);
transform!(priceInd, :INDEX => x -> x/priceInd[1, :INDEX]);

# deflate nominal values
leftjoin!(df, priceInd, on = :YEAR);
df[!, [:INCWAGE, :HHINCOME]] = df[!, [:INCWAGE, :HHINCOME]]./df.INDEX;


CSV.write("clean_data.csv", df)