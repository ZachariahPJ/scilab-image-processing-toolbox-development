function lines = houghlines(BW, theta, rho, peaks, varargin)
    
    // 1. Argument count check
    rhs = argn(2);
    if rhs < 4 | rhs > 8 | rhs == 5 | rhs == 7 then
        error("houghlines: requires 4, 6, or 8 input arguments");
    end

    // 2. Initialise optional parameters as empty
    fillgap = [];
    minlength = [];

    n_args = length(varargin);

    // 3. Parse property/value pairs from varargin list object safely
    for n = 5:2:(rhs-1)
        prop_str = convstr(varargin(n-4), "l");
        val_data = varargin(n-4+1);

        select prop_str
        case "fillgap"
            fillgap = val_data;
        case "minlength"
            minlength = val_data;
        otherwise
            error("houghlines: invalid PROPERTY given");
        end
    end

    // 4. Apply defaults
    if isempty(fillgap) then
        fillgap = 20;
    end
    if isempty(minlength) then
        minlength = 40;
    end

    // 5. Validate all inputs
    if (type(BW) > 8 & type(BW) ~= 4) | (ndims(BW) ~= 2) then
        error("houghlines: BW must be a logical or numeric 2D array");
    end
    if (type(theta) > 8) | (~isvector(theta)) then
        error("houghlines: THETA must be a numeric vector");
    end
    if (type(rho) > 8) | (~isvector(rho)) then
        error("houghlines: RHO must be a numeric vector");
    end

    if isempty(peaks) then
        lines = struct();
        return;
    end

    if (type(peaks) > 8) | (size(peaks, 2) ~= 2) then
        error("houghlines: PEAKS must be a n-by-2 numeric array");
    end
    if (type(fillgap) > 8) | (~isreal(fillgap)) | (fillgap <= 0) | (~isscalar(fillgap)) then
        error("houghlines: FILLGAP must be a positive scalar number");
    end
    if (type(minlength) > 8) | (~isreal(minlength)) | (minlength <= 0) | (~isscalar(minlength)) then
        error("houghlines: MINLENGTH must be a positive scalar number");
    end

    // 6. Initialise structural output to handle multi-index arrays dynamically
    lines = struct();
    numpeaks = size(peaks, 1);
    numlines = 0;

    // 7. Find all foreground pixels (1-based to match Octave coordinate reference offsets)
    [allpixels_r, allpixels_c] = find(BW);
    if isempty(allpixels_r) then
        return;
    end

    origin = [1, 1];
    allpixels_x = allpixels_c - origin(1);
    allpixels_y = allpixels_r - origin(2);

    // 8. Process each Hough peak individually
    for n = 1:numpeaks
        rho_p_idx = peaks(n, 1);
        theta_p_idx = peaks(n, 2);
        rho_p = rho(rho_p_idx);
        theta_p = theta(theta_p_idx);

        // Using degree-based cosd/sind calculation to prevent pi-rounding errors
        rho_all = allpixels_x .* cosd(theta_p) + allpixels_y .* sind(theta_p);
        rho2idx_factor = (length(rho) - 1) / (rho($) - rho(1));
        rho_all_idx = round((rho_all - rho(1)) .* rho2idx_factor) + 1;
        peak_pixels_idx = find(rho_all_idx == rho_p_idx);

        // Convert back to image space coordinate boundaries
        peak_pixels_x = allpixels_x(peak_pixels_idx) + origin(1);
        peak_pixels_y = allpixels_y(peak_pixels_idx) + origin(2);

        if isempty(peak_pixels_x) then
            continue;
        end

        x_span = max(peak_pixels_x) - min(peak_pixels_x);
        y_span = max(peak_pixels_y) - min(peak_pixels_y);
        
        if (x_span > y_span) then
            peak_pixels_yx = sortrows([peak_pixels_y(:), peak_pixels_x(:)], [1, 2]);
        else
            peak_pixels_yx = sortrows([peak_pixels_y(:), peak_pixels_x(:)], [2, 1]);
        end
        // Re-ordering back to [X, Y] columns
        peak_pixels = [peak_pixels_yx(:, 2), peak_pixels_yx(:, 1)];

        // Compute euclidean distance between adjacent ordered elements
        dist = sqrt(diff(peak_pixels(:, 1)).^2 + diff(peak_pixels(:, 2)).^2);

        endpoint_idx = find(dist > fillgap);
        num_peak_pixels = size(peak_pixels, 1);
        endpoint_idx = [0; endpoint_idx(:); num_peak_pixels];

        for m = 2:length(endpoint_idx)
            first_pixel = peak_pixels(endpoint_idx(m-1)+1, :);
            last_pixel = peak_pixels(endpoint_idx(m), :);
            length_segment = sqrt(sum((last_pixel - first_pixel).^2));

            if (length_segment < minlength) then
                continue;
            end

            numlines = numlines + 1;
            
            // Assign fields safely to dynamic rows
            lines(numlines).point1 = first_pixel;
            lines(numlines).point2 = last_pixel;
            lines(numlines).theta  = theta_p;
            lines(numlines).rho    = rho_p;
        end
    end
endfunction
