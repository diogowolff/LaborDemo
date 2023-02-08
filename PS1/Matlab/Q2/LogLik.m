function [value] = LogLik(param, datax, datay, dataz, gamma)
    eps = datax*[param(1); param(2); param(3)] + datay.*param(4) - ...
            dataz*gamma;
    
    n = size(datax,1);

    Feps = zeros(n, 1);
    bw = .9*min(std(eps), iqr(eps))/n^(1/5);

    for point = 1:n
        Feps(point) = NdimNWEstimator(datay, eps, eps(point), bw);
    end
    
    value = sum(datay.*(1-Feps) + (1-datay).*Feps);
end

