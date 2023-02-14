clear

addpath('../../Data');

%% Loading datasets required

%opts = detectImportOptions('usa_00002.csv');
%opts.DataLines = [2, Inf];
dataset = readtable('20pct_dataset.csv');
dataset = dataset(dataset.YEAR == 2005, :);

%% DANGER ZONE!! Cleaning some weird things

unemp_with_wage = dataset.EMPSTAT ~= 1 & dataset.INCWAGE > 0 & dataset.INCWAGE<999998;

dataset = dataset(~unemp_with_wage & ...
    dataset.HHINCOME >= 0, :);