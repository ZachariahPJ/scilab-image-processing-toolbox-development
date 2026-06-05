function [H, rho] = hough_line(bw, theta_oct)
    [nrows, ncols] = size(bw);

    D = sqrt((nrows - 1)^2 + (ncols - 1)^2);
    rho_max = ceil(D);
    rho = (-rho_max:1:rho_max);

    n_rho = length(rho);
    n_theta = length(theta_oct);
    H = zeros(n_rho, n_theta);

    [row_idx, col_idx] = find(bw);
    x = col_idx - 1;
    y = row_idx - 1;
    n_pts = length(x);

    if n_pts == 0 then
        return;
    end

    theta_deg = 90 - (theta_oct * (180 / %pi));

    cos_theta = cosd(theta_deg(:)); 
    sin_theta = sind(theta_deg(:));

    for p = 1:n_pts
        rho_vals = x(p) * cos_theta' + y(p) * sin_theta';
        rho_rounded = round(rho_vals);
        
        rho_indices = rho_rounded + rho_max + 1;
        
        for k = 1:n_theta
            if (rho_indices(k) >= 1) & (rho_indices(k) <= n_rho) then
                H(rho_indices(k), k) = H(rho_indices(k), k) + 1;
            end
        end
    end
endfunction
