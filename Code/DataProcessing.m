clear

addpath('../Data');

%% Loading datasets required

dataset = readtable('usa_00002.csv');

% median CPI deseasonalized
price_index = table2timetable(readtable('MEDCPIM094SFRBCLE.csv'));


%% Data wrangling

sample = dataset(1:10000, :);

timeframe = timerange('2005-01-01', '2020-01-01');
index_2005 = price_index(timeframe, :);
index_base_2005 = table2array(index_2005)./table2array(index_2005(1, :));
yearly_index = index_base_2005(1+12*(0:14),:);

index_timeseries = array2table([(2005:2019)', yearly_index], ...
    'VariableNames',{'YEAR','INDEX'});

dataset = outerjoin(dataset, index_timeseries);