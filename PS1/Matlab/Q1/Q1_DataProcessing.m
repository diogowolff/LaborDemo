clear

addpath('../../Data');

%% Loading datasets required

%opts = detectImportOptions('usa_00002.csv');
%opts.DataLines = [2, Inf];
dataset = readtable('usa_00002.csv');

%dataset2005 = dataset(dataset.YEAR == 2005, :);

% median CPI deseasonalized
price_index = table2timetable(readtable('MEDCPIM094SFRBCLE.csv'));

timeframe = timerange('2005-01-01', '2020-01-01');
index_2005 = price_index(timeframe, :);
index_base_2005 = table2array(index_2005)./table2array(index_2005(1, :));
yearly_index = index_base_2005(1+12*(0:14),:);

index_timeseries = array2table([(2005:2019)', yearly_index], ...
    'VariableNames',{'YEAR','INDEX'});

dataset = outerjoin(dataset, index_timeseries);
dataset.INCWAGE = dataset.INCWAGE./dataset.INDEX;

%% DANGER ZONE!! Cleaning some weird things

unemp_with_wage = dataset.EMPSTAT ~= 1 & dataset.INCWAGE > 0 & dataset.INCWAGE<999998;

dataset = dataset(~unemp_with_wage & ...
    dataset.HHINCOME >= 0, :);