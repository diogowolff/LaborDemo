%% Data transformations

dataset.Wage = dataset.INCWAGE ./ (dataset.UHRSWORK .* dataset.WKSWORK2);

%% First-step kernels for Robinson

gy = zeros(n, 1);
gx = zeros(n, 2);

bw_wage = .9*min(std(dataset.Wage), iqr(dataset.Wage))/n^(1/5);

for gridpoint = 1:n
    gy(gridpoint) = NWEstimator(dataset.Wage, dataset.EmpProb, ...
    dataset.EmpProb(gridpoint), bw_wage);
    gx(gridpoint, 1) = NWEstimator(dataset.EDUCD, dataset.EmpProb, ...
    dataset.EmpProb(gridpoint), bw_educ);
    gx(gridpoint, 2) = NWEstimator(dataset.AGE, dataset.EmpProb, ...
    dataset.EmpProb(gridpoint), bw_age);
end

%% Computation of residuals

ey = dataset.Wage - gy;
ex = [dataset.EDUCD, dataset.AGE] - gx;

%% OLS estimate

gamma = inv(ex'*ex)*ex'*ey;

%% Recovering estimated M

M_est = gy - gx*gamma;