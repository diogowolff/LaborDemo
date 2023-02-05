function [m] = NWEstimator(y, x, x0, h_vec)
    scaled_vector = (x - x0)./h_vec;
    
    kernel_values = Kernel(vecnorm(scaled_vector, 2, 2));
    
    
    treatment_indicator = y == 1;
    
    numerator = sum(kernel_values .* treatment_indicator);
    
    if isnan(numerator / sum(kernel_values))
        m = 0;
    else 
        m = numerator / sum(kernel_values);
end

