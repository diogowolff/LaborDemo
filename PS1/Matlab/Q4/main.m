clear 

<<<<<<< Updated upstream
dataset4 = readtable('usa_00002.csv');

unemp_with_wage = dataset4.EMPSTAT ~= 1 & dataset4.INCWAGE > 0 & dataset4.INCWAGE<999998;

dataset4 = dataset4(~unemp_with_wage & ...
    dataset4.HHINCOME >= 0, :);

dataset_4 = dataset4(dataset4.SEX == 1 & dataset4.MARST < 3 & dataset4.AGE >= 25 & ...
    dataset4.AGE <= 55 & dataset4.YEAR == 2015 & dataset4.EMPSTAT == 1, :);

dataset_4.NLINC = dataset_4.HHINCOME - dataset_4.INCWAGE;
dataset_4.Wage = dataset_4.INCWAGE ./ (dataset_4.UHRSWORK .* dataset_4.WKSWORK2 );
dataset_4.WorkTot = (dataset_4.UHRSWORK .* dataset_4.WKSWORK2);
=======
%addpath('../../Data');

%dataset4 = readtable('usa_00002.csv');

%unemp_with_wage = dataset4.EMPSTAT ~= 1 & dataset4.INCWAGE > 0 & dataset4.INCWAGE<999998;

%dataset4 = dataset4(~unemp_with_wage & ...
%    dataset4.HHINCOME >= 0, :);

%dataset_4 = dataset4(dataset4.SEX == 1 & dataset4.MARST < 3 & dataset4.AGE >= 25 & ...
%    dataset4.AGE <= 55 & dataset4.YEAR == 2015 & dataset4.EMPSTAT == 1, :);


load('dataset_4.mat');

dataset_4.WeeksWork = dataset_4.WKSWORK2;
dataset_4.WeeksWork(dataset_4.WeeksWork == 1) = dataset_4.WeeksWork(dataset_4.WeeksWork == 1) .* 7;
dataset_4.WeeksWork(dataset_4.WeeksWork == 2) = dataset_4.WeeksWork(dataset_4.WeeksWork == 2) .* 10;
dataset_4.WeeksWork(dataset_4.WeeksWork == 3) = dataset_4.WeeksWork(dataset_4.WeeksWork == 3) .* 11;
dataset_4.WeeksWork(dataset_4.WeeksWork == 4) = dataset_4.WeeksWork(dataset_4.WeeksWork == 4) .* 11;
dataset_4.WeeksWork(dataset_4.WeeksWork == 5) = dataset_4.WeeksWork(dataset_4.WeeksWork == 5) + 44;
dataset_4.WeeksWork(dataset_4.WeeksWork == 6) = dataset_4.WeeksWork(dataset_4.WeeksWork == 6) + 45;

dataset_4.NLINC = dataset_4.HHINCOME - dataset_4.INCWAGE;
dataset_4.Wage = dataset_4.INCWAGE ./ (dataset_4.UHRSWORK .* dataset_4.WeeksWork );
dataset_4.WorkTot = (dataset_4.UHRSWORK .* dataset_4.WeeksWork);
>>>>>>> Stashed changes

dataset_4clean = dataset_4(:, {'AGE', 'Wage', 'NLINC', 'WorkTot', 'HHINCOME', 'NCHILD'});

options = optimoptions(@fmincon,'Display','iter');

gs = GlobalSearch;

<<<<<<< Updated upstream
problem = createOptimProblem('fmincon', 'x0', [.5, 1110, 0], 'objective',...
    @(x) GMM(x, dataset_4), 'lb', [0,-100, 0], 'ub', [1, 2000, 20000], ...
=======
problem = createOptimProblem('fmincon', 'x0', [.5, 1000, 10000, 2, 2], 'objective',...
    @(x) GMM(x, dataset_4clean), 'lb', [-5,-100, 0, -5, -5], 'ub', [50, 40000, 20000, 50, 50], ...
>>>>>>> Stashed changes
    'options',options);

x = run(gs, problem);

<<<<<<< Updated upstream
GMM([1, 1110, 0], dataset_4)
=======

bagevar = -10.0:.01:10.25;
auxmat = [bagevar', repmat(x(2:5), 2026, 1)];

for i = 1:2026
   test_bage(i, :) =  GMM(auxmat(i,:), dataset_4clean);
end




gammal = -2000:5:3000;
auxmat2 = [repmat(x(1), 1001, 1), gammal', repmat(x(3:5), 1001, 1)];

for i = 1:1001
   test_gaml(i, :) =  GMM(auxmat2(i,:), dataset_4clean);
end



gammac = -500:1:1500;
auxmat3 = [repmat(x(1:2), 2001, 1), gammac', repmat(x(4:5), 2001, 1)];

for i = 1:2001
   test_gamc(i, :) =  GMM(auxmat3(i,:), dataset_4clean);
end





bchvar = -14.25:.01:12.25;
auxmat4 = [repmat(x(1:3), 2651, 1), bchvar', repmat(x(5), 2651, 1)];

for i = 1:2651
   test_bch(i, :) =  GMM(auxmat4(i,:), dataset_4clean);
end




bct = -37:.01:23;
auxmat5 = [repmat(x(1:4), 6001, 1), bct'];

for i = 1:6001
   test_bct(i, :) =  GMM(auxmat5(i,:), dataset_4clean);
end



subplot(3,2,1);
plot(bagevar, test_bage)
title('B age')

subplot(3,2,3);
plot(bchvar, test_bch)
title('B children')

subplot(3,2,5);
plot(bct, test_bct)
title('B constant')

subplot(3,2,2);
plot(gammal, test_gaml)
title('Gamma L')

subplot(3,2,4);
plot(gammac, test_gamc)
title('Gamma C')



>>>>>>> Stashed changes
