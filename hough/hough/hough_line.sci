function [H, rho] = hough_line(bw, theta_oct)
    
    // 1. Image dimensions
    [nrows, ncols] = size(bw);

    // 2. Build the rho axis
    D = sqrt((nrows - 1)^2 + (ncols - 1)^2);
    rho_max = ceil(D);
    rho = (-rho_max:1:rho_max)';

    n_rho = length(rho);
    n_theta = length(theta_oct);

    // 3. Initialise the accumulator
    H = zeros(n_rho, n_theta);

    // 4. Find foreground pixel coordinates (1-based Scilab indices)
    [row_idx, col_idx] = find(bw);
    row_idx = row_idx - 1;
    col_idx = col_idx - 1;
    n_pts = length(row_idx);

    // 5. Precompute cos and sin for all angles
    cos_theta = cos(theta_oct(:)');
    sin_theta = sin(theta_oct(:)');

    // 6. Accumulator voting loop
    rho_offset = rho_max + 1;
    for p = 1:n_pts
        rho_vals = col_idx(p) * cos_theta + row_idx(p) * sin_theta;
        rho_rounded = round(rho_vals);
        rho_indices = rho_rounded + rho_offset;
        valid = (rho_indices >= 1) & (rho_indices <= n_rho);
        for k = 1:n_theta
            if valid(k) then
                H(rho_indices(k), k) = H(rho_indices(k), k) + 1;
            end
        end
    end

endfunction
