clear 

dataset4 = readtable('usa_00002.csv');

unemp_with_wage = dataset4.EMPSTAT ~= 1 & dataset4.INCWAGE > 0 & dataset4.INCWAGE<999998;

dataset4 = dataset4(~unemp_with_wage & ...
    dataset4.HHINCOME >= 0, :);

dataset_4 = dataset4(dataset4.SEX == 1 & dataset4.MARST < 3 & dataset4.AGE >= 25 & ...
    dataset4.AGE <= 55 & dataset4.YEAR == 2015 & dataset4.EMPSTAT == 1, :);

dataset_4.NLINC = dataset_4.HHINCOME - dataset_4.INCWAGE;
dataset_4.Wage = dataset_4.INCWAGE ./ (dataset_4.UHRSWORK .* dataset_4.WKSWORK2 );
dataset_4.WorkTot = (dataset_4.UHRSWORK .* dataset_4.WKSWORK2);

dataset_4 = dataset_4(:, {'EDUC', 'Wage', 'NLINC', 'WorkTot', 'INCTOT'});

options = optimoptions(@fmincon,'Display','iter');

gs = GlobalSearch;

problem = createOptimProblem('fmincon', 'x0', [.5, 1110, 0], 'objective',...
    @(x) GMM(x, dataset_4), 'lb', [0,-100, 0], 'ub', [1, 2000, 20000], ...
    'options',options);

x = run(gs, problem);

GMM([1, 1110, 0], dataset_4)
