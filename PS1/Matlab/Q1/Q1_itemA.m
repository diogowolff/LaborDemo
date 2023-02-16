%% Subsetting

dataset_1a = dataset(dataset.AGE >= 15 & dataset.AGE <= 65 & dataset.SEX == 2  ...
    & dataset.EMPSTAT > 0, ...
    {'YEAR_dataset', 'INCWAGE', 'UHRSWORK', 'EMPSTAT', 'WKSWORK2'});

dataset_1a.WeeksWork = dataset_1a.WKSWORK2 .* 10;
dataset_1a.Wage = dataset_1a.INCWAGE ./ (dataset_1a.UHRSWORK .* dataset_1a.WeeksWork);


%% Generating the timeseries required
yearly_means = groupsummary(dataset_1a(:,{'YEAR_dataset', 'Wage', 'UHRSWORK'}), ...
    "YEAR_dataset", "mean");

yearly_means_conditional_on_working = groupsummary(...
    dataset_1a(dataset_1a.EMPSTAT == 1,{'YEAR_dataset', 'UHRSWORK'}), ...
    "YEAR_dataset", "mean");

yearly_mean_emp = groupsummary(... 
    dataset_1a(dataset_1a.EMPSTAT > 0 & dataset_1a.EMPSTAT < 3, ...
    {'YEAR_dataset', 'EMPSTAT'}), "YEAR_dataset", "mean");


%% Generating the plots - yes they're ugly
plot(yearly_means.YEAR_dataset, yearly_means.mean_Wage); % income
plot(yearly_means.YEAR_dataset, yearly_means.mean_UHRSWORK); % work hours unconditional
plot(yearly_means.YEAR_dataset, yearly_means_conditional_on_working.mean_UHRSWORK); % work hours conditional            
plot(yearly_means.YEAR_dataset, 2 - yearly_mean_emp.mean_EMPSTAT); % employment rates
