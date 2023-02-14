dataset_4 = dataset(dataset.SEX == 1 & dataset.MARST < 3 & dataset.AGE >= 25 & ...
    dataset.AGE <= 55 & dataset.YEAR == 2015 & dataset.EMPSTAT == 1, :);

dataset_4.NLINC = dataset_4.HHINCOME - dataset_4.INCWAGE;
dataset_4.Wage = dataset_4.INCWAGE ./ (dataset_4.UHRSWORK .* dataset_4.WKSWORK2);
dataset_4.WorkTot = (dataset_4.UHRSWORK .* dataset_4.WKSWORK2);

dataset_4 = dataset_4(:, {'EDUC', 'Wage', 'NLINC', 'WorkTot', 'INCTOT'});

options = optimoptions(@fmincon,'Display','iter');

gs = GlobalSearch;

problem = createOptimProblem('fmincon', 'x0', [100, 0, -3000], 'objective',...
    @(x) GMM(x, dataset_4), 'lb', [-100,-100, 0], 'ub', [1000, 2000, 20000], ...
    'options',options);

x = run(gs, problem);

