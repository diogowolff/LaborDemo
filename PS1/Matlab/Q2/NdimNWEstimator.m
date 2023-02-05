function [m] = NdimNWEstimator(y, x, x0, h_vec)
    scaled_vector = (x - x0)./h_vec;
    
    kernel_values = Kernel(vecnorm(scaled_vector, 2, 2));
    
    
    treatment_indicator = y == 1;

    % THIS FUNCTION IS MADE ONLY FOR USING IN A) IT DOESN'T WORK IN GENERAL!!!!! 
    
    numerator = sum(kernel_values .* treatment_indicator);
    
    if isnan(numerator / sum(kernel_values))
        m = 0;
    else 
        m = numerator / sum(kernel_values);
    end
end

