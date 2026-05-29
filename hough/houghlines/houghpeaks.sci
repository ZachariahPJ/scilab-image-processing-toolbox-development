function peaks = houghpeaks(H, varargin)

    // 1. Argument count check
    rhs = argn(2);
    if rhs < 1 | rhs > 6 then
        error("houghpeaks: requires between 1 and 6 input arguments");
    end

    // 2. Initialise optional parameters as empty
    numpeaks = [];
    threshold = [];
    nhoodsize = [];

    // 3. Detect whether second argument is numpeaks or a property name
    if modulo(rhs, 2) == 0 then
        numpeaks = varargin(1);
        n_start = 2;
    else
        n_start = 1;
    end

    // 4. Parse property/value pairs
    for n = n_start:2:(rhs-1)
        select convstr(varargin(n), "l")
        case "threshold"
            threshold = varargin(n+1);
        case "nhoodsize"
            nhoodsize = varargin(n+1);
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

    // 8. Peak detection loop
    // At each iteration:
    //   a) find the current maximum in H
    //   b) stop if it is below threshold
    //   c) record it as a peak
    //   d) zero out its neighbourhood so the next iteration finds a different peak
    //   e) use Hough anti-symmetry to also zero the mirrored region
    peaks = [];

    for n = 1:numpeaks
        [maxval, maxind] = max(H(:));
        [x0, y0] = ind2sub(size(H), maxind);

        if maxval <= 0 | maxval < threshold then
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
            if y0 + nhoody > sizey then
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
