function [value] = LogLik(param, datax, datay, dataz, gamma, w)
    % covar matrix = [covar(1)^2, covar(3)*covar(1)*covar(2)]
    %                [covar(3)*covar(1)*covar(2), covar(2)^2]
    covar = [param(5); param(6); param(7)];

    nump0 = datax*[param(1); param(2); param(3)] + datay.*param(4) - ...
            dataz*gamma;
    sigmav = covar(1)^2 + covar(2)^2 - 2*covar(1)*covar(2)*covar(3);

    Pr0 = normcdf(nump0 ./ sigmav);

    
    middle = (w - dataz*gamma)./sigmav;
    nump1 = w - datax*[param(1); param(2); param(3)] - datay.*param(4) - ...
            covar(3)*covar(1)/covar(2).*(w - dataz*gamma);
    denp1 = covar(1)*sqrt(1-covar(3)^2);

    Pr1 = normpdf(middle).*normcdf(nump1./denp1)./covar(2);
    
value = sum(datay.*log(Pr1) + (1-datay).*log(Pr0));
%value = [middle, nump1./denp1];
end

