function peaks = houghpeaks(H, varargin)

    // 1. Check total argument constraints via argn
    rhs = argn(2);
    if (rhs < 1) | (rhs > 6) then
        error("houghpeaks: requires between 1 and 6 input arguments");
    end

    numpeaks = [];
    threshold = [];
    nhoodsize = [];

    // n_args tracks only the optional parameters inside varargin
    n_args = length(varargin);

    // If total inputs (including H) is even (2, 4, or 6)
    if modulo(rhs, 2) == 0 then
        numpeaks = varargin(1);
        n_start = 2;
    else // Odd number of total inputs (1, 3, or 5)
        n_start = 1;
    end

    // 4. Parse property/value pairs
    for n = n_start:2:(n_args-1)
        prop_str = convstr(varargin(n), "l");
        val_data = varargin(n+1);

        select prop_str
        case "threshold"
            threshold = val_data;
        case "nhoodsize"
            nhoodsize = val_data;
        otherwise
            error("houghpeaks: invalid PROPERTY given");
        end
    end

    // 5. Apply defaults for any parameter still empty
    if isempty(numpeaks) then
        numpeaks = 1;
    end
    if isempty(threshold) then
        threshold = 0.5 * max(H(:));
    end
    if isempty(nhoodsize) then
        nhoodsize = size(H) / 50;
        nhoodsize = nhoodsize + 1;
        nhoodsize = 2 * ceil((nhoodsize - 1) / 2) + 1;
        nhoodsize = max(nhoodsize, 3);
    end

    // 6. Validate all parameters
    if type(H) > 8 | ndims(H) ~= 2 then
        error("houghpeaks: H must be a numeric 2D array");
    end
    if ~isscalar(numpeaks) | numpeaks <= 0 | numpeaks ~= round(numpeaks) then
        error("houghpeaks: NUMPEAKS must be a positive integer scalar.");
    end
    if ~isscalar(threshold) | type(threshold) > 8 | threshold < 0 then
        error("houghpeaks: THRESHOLD must be a non-negative numeric scalar.");
    end
    if ndims(nhoodsize) ~= 2 | ~isequal(size(nhoodsize), [1 2]) | type(nhoodsize) > 8 | or(nhoodsize <= 0) | or(round((nhoodsize-1)/2)*2+1 ~= nhoodsize) then
        error("houghpeaks: NHOODSIZE must be a 2-element vector of positive odd integers");
    end

    // 7. Precompute neighbourhood half-sizes and image dimensions
    nhood = (nhoodsize - 1) / 2;
    nhoodx = nhood(1);
    nhoody = nhood(2);
    sizex = size(H, 1);
    sizey = size(H, 2);

    peaks = [];

    // 8. Peak detection loop
    for n = 1:numpeaks
        [maxval, maxind] = max(H(:));
        [x0, y0] = ind2sub(size(H), maxind);

        if maxval < threshold then
            break;
        end

        peaks(n, :) = [x0, y0];

        xmin = max(x0 - nhoodx, 1);
        xmax = min(x0 + nhoodx, sizex);
        ymin = max(y0 - nhoody, 1);
        ymax = min(y0 + nhoody, sizey);
        H(xmin:xmax, ymin:ymax) = 0;

        if (y0 + nhoody > sizey) | (y0 - nhoody < 1) then
            xmin2 = sizex - xmax + 1;
            xmax2 = sizex - xmin + 1;
            if (y0 + nhoody > sizey) then
                ymin2 = 1;
                ymax2 = y0 + nhoody - sizey;
            else
                ymin2 = y0 - nhoody + sizey;
                ymax2 = sizey;
            end
            H(xmin2:xmax2, ymin2:ymax2) = 0;
        end
    end
endfunction
