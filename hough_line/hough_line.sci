function [J, bins] = hough_line(I, thetas)
    
    [nargout, nargin] = argn();
    if nargin < 1 | nargin > 2 then
        error("Wrong number of input arguments.");
    end
    if nargin == 1 then
        thetas = (-%pi/2 : %pi/180 : %pi/2)';
    else
        thetas = thetas(:); 
    end

    [r, c] = size(I);
    thetas_length = length(thetas);

    diag_length = sqrt((r - 1)^2 + (c - 1)^2);
    nr_bins = 2 * ceil(diag_length) + 1;
    
    bins = (1:nr_bins) - ceil(nr_bins / 2.0);
    bins_length = length(bins);

    J = zeros(bins_length, thetas_length);
    [row_idx, col_idx] = find(I);
    n_pts = length(row_idx);

    if n_pts == 0 then
        return;
    end

    cT = cos(thetas);
    sT = sin(thetas);

    for p = 1:n_pts
        x = row_idx(p) - 1; 
        y = col_idx(p) - 1; 

        rho_vals = cT * x + sT * y;
        rho = floor(rho_vals + 0.5);

        bin_idx = (rho - bins(1)) + 1; 

        for i = 1:thetas_length
            if (bin_idx(i) > 1) & (bin_idx(i) <= bins_length) then
                J(bin_idx(i), i) = J(bin_idx(i), i) + 1;
            end
        end
    end
endfunction
