clear

addpath('../../Data');

%% Loading datasets required

dataset = readtable('small_dataset.csv');


%% DANGER ZONE!! Cleaning some weird things

unemp_with_wage = dataset.EMPSTAT ~= 1 & dataset.INCWAGE > 0 & dataset.INCWAGE<999998;

dataset = dataset(~unemp_with_wage & ...
    dataset.HHINCOME >= 0, :);