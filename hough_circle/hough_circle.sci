function accum = hough_circle(bw, r)
    
    // 1. Check input arguments
    rhs = argn(2);
    if (rhs ~= 2) then
        error("hough_circle: wrong number of input arguments");
    end
    if (ndims(bw) ~= 2) then
        error("hough_circle: BW must be a 2-dimensional matrix");
    end

    // Check vector properties
    if ~(isreal(r) & (size(r,1) == 1 | size(r,2) == 1)) | or(r < 0) then
        error("hough_circle: radius arguments must be a positive vector or scalar");
    end

    // 2. Create the accumulator array
    accum = zeros(size(bw, 1), size(bw, 2), length(r));

    // 3. Find the pixels we need to look at
    [R, C] = find(bw);

    // 4. Iterate over different radius
    for j = 1:length(r)
        rad = r(j);

        // Compute a filter containing the circle we are looking for
        circ = circle(rad);

        // 5. Iterate over all interesting image points
        for i = 1:length(R)
            row = R(i);
            col = C(i);

            // Compute indices for the accumulator array
            a_rows = max(row-rad, 1) : min(row+rad, size(accum, 1));
            a_cols = max(col-rad, 1) : min(col+rad, size(accum, 2));

            // Compute indices for the circle array (the filter)
            c_rows = max(rad-row+2, 1) : min(rad-row+1+size(accum, 1), size(circ, 1));
            c_cols = max(rad-col+2, 1) : min(rad-col+1+size(accum, 2), size(circ, 2));

            // Update the accumulator array (replacing += cleanly)
            accum(a_rows, a_cols, j) = accum(a_rows, a_cols, j) + circ(c_rows, c_cols);
        end
    end
endfunction

function circ = circle(r)
    circ = zeros(round(2*r + 1), round(2*r + 1));
    col = 1:size(circ, 2);
    for row = 1:size(circ, 1)
        tmp = (row - (r+1)).^2 + (col - (r+1)).^2;
        circ(row, col) = (tmp <= r^2);
    end

    circ = bwmorph(circ, "remove");
endfunction
