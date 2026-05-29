function lines = houghlines(BW, theta, rho, peaks, varargin)
    // 1. Argument count check
    rhs = argn(2);
    if rhs < 4 | rhs > 8 | rhs == 5 | rhs == 7 then
        error("houghlines: requires 4, 6, or 8 input arguments");
    end

    // 2. Initialise optional parameters as empty
    fillgap = [];
    minlength = [];

    // 3. Parse property/value pairs
    for n = 5:2:(rhs-1)
        select convstr(varargin(n-4), "l")
        case "fillgap"
            fillgap = varargin(n-4+1);
        case "minlength"
            minlength = varargin(n-4+1);
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

    // 6. Initialise output and counters
    lines = struct();
    numpeaks = size(peaks, 1);
    numlines = 0;

    // 7. Find all foreground pixels
    // Use 0-based coordinates to match the hough accumulator convention.
    [allpixels_r, allpixels_c] = find(BW);

    if isempty(allpixels_r) then
        lines = struct();
        return;
    end

    allpixels_x = allpixels_c - 1; // 0-based column
    allpixels_y = allpixels_r - 1; // 0-based row

    // 8. Process each Hough peak
    for n = 1:numpeaks

        rho_p_idx = peaks(n, 1);
        theta_p_idx = peaks(n, 2);
        rho_p = rho(rho_p_idx);
        theta_p = theta(theta_p_idx);

        // Convert theta_p to the same radian convention used
        theta_oct_p = (-theta_p + 90) * (%pi / 180);

        // Compute rho for every foreground pixel at this angle
        rho_all = allpixels_x .* cos(theta_oct_p) + allpixels_y .* sin(theta_oct_p);
        rho2idx_factor = (length(rho) - 1) / (rho($) - rho(1));
        rho_all_idx = round((rho_all - rho(1)) .* rho2idx_factor) + 1;
        peak_pixels_idx = find(rho_all_idx == rho_p_idx);

        // Skip this peak if no pixels matched
        if isempty(peak_pixels_idx) then
            continue;
        end

        // Convert matched pixels back to 1-based image coordinates
        peak_pixels_x = allpixels_x(peak_pixels_idx) + 1;
        peak_pixels_y = allpixels_y(peak_pixels_idx) + 1;

        // Order pixels along the dominant axis
        x_span = max(peak_pixels_x) - min(peak_pixels_x);
        y_span = max(peak_pixels_y) - min(peak_pixels_y);

        if x_span > y_span then
            // wider than tall: primary sort by x, secondary by y
            peak_pixels_sorted = sortrows([peak_pixels_x(:), peak_pixels_y(:)], [1, 2]);
        else
            // taller than wide: primary sort by y, secondary by x
            peak_pixels_sorted = sortrows([peak_pixels_x(:), peak_pixels_y(:)], [2, 1]);
        end
        peak_pixels = peak_pixels_sorted; // columns are [x, y]

        // Compute Euclidean distance between adjacent pixels
        dist = sqrt(diff(peak_pixels(:,1)).^2 + diff(peak_pixels(:,2)).^2);

        // Split into segments at gaps larger than fillgap
        endpoint_idx = find(dist > fillgap);
        num_peak_pixels = size(peak_pixels, 1);
        endpoint_idx = [0; endpoint_idx(:); num_peak_pixels];

        for m = 2:length(endpoint_idx)
            first_pixel = peak_pixels(endpoint_idx(m-1)+1, :);
            last_pixel = peak_pixels(endpoint_idx(m), :);
            length_segment = sqrt(sum((last_pixel - first_pixel).^2));

            // Save segment only if it meets the minimum length
            if length_segment < minlength then
                continue;
            end

            numlines = numlines + 1;
            lines(numlines).point1 = first_pixel;
            lines(numlines).point2 = last_pixel;
            lines(numlines).theta = theta_p;
            lines(numlines).rho = rho_p;
        end
    end

    // 9. Return empty struct if nothing was found
    if numlines == 0 then
        lines = struct();
    end

endfunction
