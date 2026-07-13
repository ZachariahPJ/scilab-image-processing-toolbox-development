function peaks = houghpeaks(H, varargin)

    numpeaks = [];
    threshold = [];
    nhoodsize = [];
    
    rhs = argn(2);
    
    if (rhs < 1) | (rhs > 6) then
        error("houghpeaks: requires between 1 and 6 input arguments");
    end

    n_args = length(varargin);

    if modulo(rhs, 2) == 0 then
        numpeaks = varargin(1);
        n_start = 2;
    else 
        n_start = 1;
    end

    for n = n_start:2:(n_args-1)
        prop_str = convstr(varargin(n), "l");

        select prop_str
        case "threshold"
            threshold = varargin(n+1);
        case "nhoodsize"
            nhoodsize = varargin(n+1);
        otherwise
            error("houghpeaks: invalid PROPERTY given");
        end
    end

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

    if ~isimage(H) | ndims(H) ~= 2 then
        error("houghpeaks: H must be a numeric 2D array");
    end
    if ~isscalar(numpeaks) | numpeaks <= 0 | numpeaks ~= round(numpeaks) then
        error("houghpeaks: NUMPEAKS must be a positive integer scalar.");
    end
    if ~isscalar(threshold) | ~isnumeric(threshold) | threshold < 0 then
        error("houghpeaks: THRESHOLD must be a non-negative numeric scalar.");
    end
    if ndims(nhoodsize) ~= 2 | ~isequal(size(nhoodsize), [1 2]) | ~isnumeric(nhoodsize) | or(nhoodsize <= 0) | or(round((nhoodsize-1)/2)*2+1 ~= nhoodsize) then
        error("houghpeaks: NHOODSIZE must be a 2-element vector of positive odd integers");
    end

    nhood = (nhoodsize - 1) / 2;
    nhoodx = nhood(1);
    nhoody = nhood(2);
    sizex = size(H, 1);
    sizey = size(H, 2);

    peaks = [];

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
