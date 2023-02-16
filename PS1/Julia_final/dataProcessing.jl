using Queryverse
using DataFrames
using Dates
using Statistics
# using StatsPlots
# using FileIO
# using CSV


### Loading data for machines that can't run Queryverse
# cd("Documents/Labor/ProblemSet")
# df = CSV.read("Extract3/data_woman_age_clean.csv", DataFrame)

### Loading data for machines that can't run FileIO
cd("C:\\Users\\guiex\\EPGE\\Labor\\Problem Set")
df = load("Extract1/20pct_dataset.csv", delim = ',') |> DataFrame;

# data cleaning
select!(df, Not([:SAMPLE, :CBSERIAL, :HHWT, :CLUSTER, :STRATA, :GQ, :PERNUM, :PERWT, :RACE, :RACED]));
# nominalValues = [:HHINCOME, :INCTOT, :INCWAGE, :INCWELFR, :INCSS];

df = df[(df.EDUCD .!= 001) .&
        (df.EDUCD .!= 999) .&
        (df.INCWAGE .!= 999998) .&
        (df.HHINCOME .>= 0) .&
        (df.EMPSTAT .!= 0) .& (df.WKSWORK2 .!= 0) .&
        (df.EMPSTATD .!= 00) .& (df.UHRSWORK .!= 00) .&
        (sum(eachcol(df[!, [:HHINCOME, :INCTOT, :INCWAGE, :INCWELFR, :INCSS]] .== 9999999)) .== 0)
        , :]

# [filter!(col => x -> x != 9999999, df) for col in nominalValues];
# [filter!(col => x -> x != 0, df) for col in [:EMPSTAT, :WKSWORK2]];
# [filter!(col => x -> x != 00, df) for col in [:EMPSTATD, :UHRSWORK]];

# filter!(:EDUCD => x -> x != 001, df);
# filter!(:EDUCD => x -> x != 999, df);
# filter!(:INCWAGE => x -> x != 999998, df);
# filter!(:HHINCOME => x -> x >= 0, df);

df.WKSWORK2 = ifelse.(df.WKSWORK2 .== 0, 0, (13*(2*df.WKSWORK2.-1) .+ 1)/2);
# [filter!(col => x -> !any(f -> f(x), (ismissing, isnothing, isnan)), df) for col in Symbol.(names(df))];

# price index
priceInd = load("Extract1/median_consumer_price_index.csv", delim = ',') |> DataFrame;
rename!(priceInd, :MEDCPIM094SFRBCLE => :INDEX);
priceInd.DATE = Dates.year.(priceInd.DATE);
rename!(priceInd, :DATE => :YEAR);
priceInd = groupby(priceInd, :YEAR);
priceInd = combine(priceInd, :INDEX => mean => :INDEX);
transform!(priceInd, :INDEX => x -> x/priceInd[1, :INDEX]);

# deflate nominal values
leftjoin!(df, priceInd, on = :YEAR);
df[!, nominalValues] = df[!, nominalValues]./df.INDEX;