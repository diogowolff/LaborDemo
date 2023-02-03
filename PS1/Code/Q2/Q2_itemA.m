%%Observations
% I'll use HHINCOME as y, don't know if it is correct
% EDUC or EDUCD? second one is finer, has a specific NA number, might be
% useful

%% Code
% Generating the kernel matrix based with a multivariate gaussian kernel

n = size(dataset, 1);
bw_welf = std(dataset.NLINC)*(4/(6*n))^(1/8);
bw_educ = std(dataset.EDUCD)*(4/(6*n))^(1/8);
bw_age = std(dataset.AGE)*(4/(6*n))^(1/8);
bw_nchild = std(dataset.NCHILD)*(4/(6*n))^(1/8);

bw = [bw_welf bw_educ bw_age bw_nchild];

xi = [dataset.INCWELFR, dataset.EDUCD, dataset.AGE, dataset.NCHILD];

teste9 = zeros(size(xi, 1), 1);

for gridpoint = 1:size(xi, 1)
    teste9(gridpoint) = LCEstimator(dataset.EMPSTAT, [dataset.INCWELFR, dataset.EDUCD, ... 
        dataset.AGE, dataset.NCHILD], ...
    xi(gridpoint,:), bw);
end


xi_estimate = [xi teste9];

teste7 = xi_estimate(xi_estimate(:,3)==45 & xi_estimate(:,4)==1,:);
aux = [teste7(:,1), teste7(:,2), teste7(:,5)];
contour(aux)