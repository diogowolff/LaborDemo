function [m] = NWEstimator(y, x, x0, h)
    scaled_vector = (x - x0)./h;
    
    kernel_values = Kernel(scaled_vector);
    
    numerator = sum(kernel_values .* y);
    
    if isnan(numerator / sum(kernel_values))
        m = 0;
    else 
        m = numerator / sum(kernel_values);
    end
end

