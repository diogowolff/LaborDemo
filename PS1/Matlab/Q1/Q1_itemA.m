%% Subsetting

dataset_1a = dataset(dataset.AGE >= 15 & dataset.AGE <= 65 & dataset.SEX == 2  ...
    & dataset.EMPSTAT > 0, ...
    {'YEAR', 'INCWAGE', 'UHRSWORK', 'EMPSTAT'});


%% Generating the timeseries required
yearly_means = groupsummary(dataset_1a(:,{'YEAR', 'INCWAGE', 'UHRSWORK'}), ...
    "YEAR", "mean");

yearly_means_conditional_on_working = groupsummary(...
    dataset_1a(dataset_1a.EMPSTAT == 1,{'YEAR', 'UHRSWORK'}), ...
    "YEAR", "mean");

yearly_mean_emp = groupsummary(... 
    dataset_1a(dataset_1a.EMPSTAT > 0 & dataset_1a.EMPSTAT < 3, ...
    {'YEAR', 'EMPSTAT'}), "YEAR", "mean");


%% Generating the plots - yes they're ugly
plot(yearly_means.YEAR, yearly_means.mean_INCWAGE); % income
plot(yearly_means.YEAR, yearly_means.mean_UHRSWORK); % work hours unconditional
plot(yearly_means.YEAR, yearly_means_conditional_on_working.mean_UHRSWORK); % work hours conditional            
plot(yearly_means.YEAR, 2 - yearly_mean_emp.mean_EMPSTAT); % employment rates
