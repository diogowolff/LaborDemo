%% Running the log-lik

cte = ones(n,1);

results = fminunc(@(x) LogLik(x, [cte, dataset.AGE, dataset.NCHILD], dataset.EMPSTAT, ...
        [dataset.EDUCD, dataset.AGE], gamma), [0,0,0,0]);
