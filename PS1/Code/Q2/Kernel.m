function [value] = Kernel(z)
    ind = abs(z) < 1;
    value = ((15/16).*(1-z.^2).^2).*ind;
end

