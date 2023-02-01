
%% Generating the timeseries required
yearly_means = groupsummary(dataset(:,{'YEAR_dataset', 'INCWAGE', 'UHRSWORK'}), ...
    "YEAR_dataset", "mean");

yearly_means_conditional_on_working = groupsummary(...
    dataset(dataset.EMPSTAT == 1,{'YEAR_dataset', 'UHRSWORK'}), ...
    "YEAR_dataset", "mean");

yearly_workhours_women_15_65 = groupsummary(...
    dataset(dataset.AGE >= 15 & dataset.AGE <= 65 & dataset.SEX == 2 & ...
            dataset.EMPSTAT > 0 & dataset.EMPSTAT < 3, ...
    {'YEAR_dataset', 'EMPSTAT'}), "YEAR_dataset", "mean");


%% Generating the plots - yes they're ugly
plot(yearly_means.YEAR_dataset, yearly_means.mean_INCWAGE); % income
plot(yearly_means.YEAR_dataset, yearly_means.mean_UHRSWORK); % work hours unconditional
plot(yearly_means.YEAR_dataset, yearly_means_conditional_on_working.mean_UHRSWORK); % work hours conditional            
plot(yearly_means.YEAR_dataset, 2 - yearly_workhours_women_15_65.mean_EMPSTAT); % employment rates
