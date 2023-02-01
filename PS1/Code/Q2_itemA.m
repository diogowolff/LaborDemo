%%Observations
% I'll use HHINCOME as y, don't know if it is correct
% EDUC or EDUCD? second one is finer, has a specific NA number, might be
% useful

%% Code
% Generating the kernel matrix based with a multivariate gaussian kernel

n = size(dataset, 1);
bw_inc = std(dataset.HHINCOME)*(4/(6*n))^(1/8);
bw_educ = std(dataset.EDUC)*(4/(6*n))^(1/8);
bw_age = std(dataset.AGE)*(4/(6*n))^(1/8);
bw_nchild = std(dataset.NCHILD)*(4/(6*n))^(1/8);

grid_inc = min(dataset.HHINCOME):100000:max(dataset.HHINCOME);
grid_educ = min(dataset.EDUC):1:max(dataset.EDUC);
grid_age = min(dataset.AGE):1:max(dataset.AGE);
grid_nchild = min(dataset.NCHILD):1:max(dataset.NCHILD);

[x1,x2,x3,x4] = ndgrid(grid_inc,grid_educ,grid_age,grid_nchild);
x1 = x1(:,:)';
x2 = x2(:,:)';
x3 = x3(:,:)';
x4 = x4(:,:)';
xi = [x1(:) x2(:) x3(:) x4(:)];

result = 

teste3 = mvksdensity(table2array(dataset(, {'HHINCOME', 'EDUC', 'AGE', 'NCHILD'})), ...
    xi, 'Bandwidth', [bw_inc bw_educ bw_age bw_nchild]);
