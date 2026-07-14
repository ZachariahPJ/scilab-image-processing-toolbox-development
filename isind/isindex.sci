function retval = isindex(ind, n)
    [nargout, nargin] = argn();

    if (nargin < 1 | nargin > 2) then
        error("isindex: invalid call, use: isindex(ind) or isindex(ind, n)");
    end

    if (type(ind) == 10) then
        ind = double(ind);
    end

    retval = (type(ind) == 4) | is_index_vector(ind);

    if (retval & nargin == 2) then
        max_val = max(ind);
        if (max_val > n) then
            retval = %f;
        end
    end
endfunction

function bool = is_index_vector(ind)
    bool = isreal(ind) & or(size(ind) == 1 | size(ind) == max(size(ind))) & ...
        and(ind == round(ind)) & and(ind >= 1);
endfunction
