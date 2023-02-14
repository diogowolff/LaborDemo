%% Create variables required

emp = dataset.EMPSTAT == 1;

dataset.wageaux = zeros(n);

for i = 1:n
    if emp(i)
        dataset.wageaux(i) = dataset.Wage(i);
    else
        dataset.wageaux(i) = [dataset.EDUCD(i), dataset.AGE(i)]*gamma + M_est(i);
    end
end

%% Run the log-likelihood

result3 = fmuninc(@(x) LogLik(x, [cte, dataset.AGE, dataset.NCHILD], dataset.EMPSTAT, ...
        [dataset.EDUCD, dataset.AGE], gamma, dataset.wageaux);, [1, 1, 1, 1, 1, 1, .5]);