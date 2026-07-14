function imout = im2single(img, varargin)
    [nargout, nargin] = argn();

    if (nargin < 1 | nargin > 2) then
        error("im2single: invalid call, use: im2single(img) or im2single(img, ""indexed"")");
    elseif (nargin == 2 & ~(convstr(varargin(1), 'l') == "indexed")) then
        error("im2single: second input argument must be the string ""indexed""");
    end

    if (length(varargin) == 0) then
        imout = imcast(img, "single");
    else
        imout = imcast(img, "single", varargin(1));
    end
endfunction
