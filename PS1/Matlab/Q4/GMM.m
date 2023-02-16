function [val] = GMM(param, table)
%param1 = B0;  param2 = gammaL ;  param3 = gammaC
%data should look like
% [x, w, y, L, C]

% Some assumptions: Consumption is total income
% only intensive margin -> only people that work
% T = 40h for everyone per week


% what's a good x? more than one -> need more moments
    data = table2array(table);
    n = size(data, 1);

    moment_L = 1/n*sum(data(:, 1).*(param(2).*data(:, 2) + data(:, 1).*param(1).*(data(:, 2).*40*52 + ...
        data(:, 3) - param(3) - param(2).*data(:, 2)) - data(:, 2).*data(:, 4)));
    moment_C = 1/n*sum(data(:, 1).*(data(:, 3) + data(:, 2).*40*52 - data(:, 2).*param(2) + ...
        data(:, 1).*param(1).*(param(3) - data(:, 3) - data(:, 2).*data(:, 4) + data(:, 2).*param(2)) - data(:, 5)));
    moment_eps = 1/n*sum((data(:, 3) + data(:, 2).*40*52 - data(:, 2).*param(2) + ...
        data(:, 1).*param(1).*(param(3) - data(:, 3) - data(:, 2).*data(:, 4) + data(:, 2).*param(2)) - ...
        data(:, 5))./(data(:, 3) + data(:, 2).*40*52 - data(:, 2).*param(2) - param(3)));

    val = [moment_L; moment_C; moment_eps]'*[moment_L; moment_C; moment_eps];
end

