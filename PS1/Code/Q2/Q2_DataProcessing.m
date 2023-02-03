clear

addpath('../../Data');

%% Loading datasets required

dataset = readtable('small_dataset.csv');

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
% dataset(:,INCWAGE) = dataset(:,INCWAGE)./dataset(:,INDEX);   % Wages in
% real terms

%% DANGER ZONE!! Removing some data points that don't have data

dataset = dataset(dataset.INCWAGE ~= 999999 & dataset.INCWAGE > 0 & ...
    dataset.HHINCOME > 0, :);



%% More deleting of datapoints

dataset = dataset(dataset.AGE >= 25 & dataset.AGE <= 55 & dataset.SEX == 2 & ...
    dataset.MARST < 3 & dataset.HHINCOME ~= 9999999, :);

dataset.NLINC = dataset.HHINCOME - dataset.INCWAGE;