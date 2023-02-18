function [val] = GMM(param, table)
%param1 = Bage;  param2 = gammaL ;  param3 = gammaC; param4 = Bchild;
%param5 = Bcons
%data should look like
% [age, w, y, L, C, nchild]

% Some assumptions: Consumption is total income
% only intensive margin -> only people that work
% T = 40h for everyone per week


% what's a good x? more than one -> need more moments
    data = table2array(table);
    n = size(data, 1);
    
    xtb = [data(:, 1), data(:, 6), ones(n, 1)] * [param(1); param(4); param(5)];

    moment_Lage = 1/n*sum(data(:, 1).*(param(2).*data(:, 2) + xtb.*(data(:, 2).*24*365 + ...
        data(:, 3) - param(3) - param(2).*data(:, 2)) - data(:, 2).*data(:, 4)));
    moment_Lnchild = 1/n*sum(data(:, 5).*(param(2).*data(:, 2) + xtb.*(data(:, 2).*24*365 + ...
        data(:, 3) - param(3) - param(2).*data(:, 2)) - data(:, 2).*data(:, 4)));
    moment_Lones = 1/n*sum(ones(n,1).*(param(2).*data(:, 2) + xtb.*(data(:, 2).*24*365 + ...
        data(:, 3) - param(3) - param(2).*data(:, 2)) - data(:, 2).*data(:, 4)));
    
    moment_Cage = 1/n*sum(data(:, 1).*(data(:, 3) + data(:, 2).*24*365 - data(:, 2).*param(2) + ...
        xtb.*(param(3) - data(:, 3) - data(:, 2).*data(:, 4) + data(:, 2).*param(2)) - data(:, 5)));
    moment_Cnchild = 1/n*sum(data(:, 5).*(data(:, 3) + data(:, 2).*24*365 - data(:, 2).*param(2) + ...
        xtb.*(param(3) - data(:, 3) - data(:, 2).*data(:, 4) + data(:, 2).*param(2)) - data(:, 5)));
    moment_Cones = 1/n*sum(ones(n,1).*(data(:, 3) + data(:, 2).*24*365 - data(:, 2).*param(2) + ...
        xtb.*(param(3) - data(:, 3) - data(:, 2).*data(:, 4) + data(:, 2).*param(2)) - data(:, 5)));

    val = [moment_Lage; moment_Lnchild; moment_Lones; moment_Cage; moment_Cnchild; moment_Cones]'* ...
        [moment_Lage; moment_Lnchild; moment_Lones; moment_Cage; moment_Cnchild; moment_Cones];
    
end

