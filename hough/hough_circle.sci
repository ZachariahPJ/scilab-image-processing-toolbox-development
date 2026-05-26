function accum = hough_circle(bw, r)
    
    // 1. Input validation
    rhs = argn(2);
    if rhs ~= 2 then
        error("hough_circle: wrong number of input arguments");
    end

    if ndims(bw) ~= 2 then
        error("hough_circle: BW must be a 2-dimensional matrix");
    end

    if ~isvector(r) | ~isreal(r) | or(r < 0) then
        error("hough_circle: radius arguments must be a positive vector or scalar");
    end

    // 2. Initialise the 3-D accumulator
    accum = zeros(size(bw, 1), size(bw, 2), length(r));

    // 3. Find foreground pixel coordinates (1-based)
    [R, C] = find(bw);

    // 4. Outer loop: iterate over each radius
    for j = 1:length(r)
        rad = r(j);

        // Build the circular filter for this radius
        circ = circle_filter(rad);

        // 5. Inner loop: iterate over each foreground pixel
        for i = 1:length(R)
            row = R(i);
            col = C(i);

            // Accumulator index range (clipped to image bounds)
            a_rows = max(row-rad, 1) : min(row+rad, size(accum, 1));
            a_cols = max(col-rad, 1) : min(col+rad, size(accum, 2));

            // Corresponding filter index range (clipped to filter bounds)
            c_rows = max(rad-row+2, 1) : min(rad-row+1+size(accum,1), size(circ,1));
            c_cols = max(rad-col+2, 1) : min(rad-col+1+size(accum,2), size(circ,2));

            // Accumulate votes — += not available in Scilab
            accum(a_rows, a_cols, j) = accum(a_rows, a_cols, j) + circ(c_rows, c_cols);
        end
    end

endfunction

// circle_filter function
function circ = circle_filter(r)

    // Create a filled disc: pixels within radius r of the centre are 1
    sz = round(2*r + 1);
    circ = zeros(sz, sz);
    col = 1:sz;

    for row = 1:sz
        tmp = (row - (r+1)).^2 + (col - (r+1)).^2;
        circ(row, col) = (tmp <= r^2);
    end

    circ_eroded = zeros(sz, sz);
    for row = 2:sz-1
        for col = 2:sz-1

            if circ(row,col) == 1 & ...
               circ(row-1,col) == 1 & ...
               circ(row+1,col) == 1 & ...
               circ(row,col-1) == 1 & ...
               circ(row,col+1) == 1 then
                circ_eroded(row, col) = 1;
            end
        end
    end

    // Perimeter = filled disc minus interior
    circ = circ - circ_eroded;

endfunction
