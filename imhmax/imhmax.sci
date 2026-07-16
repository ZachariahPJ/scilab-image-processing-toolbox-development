function im2 = imhmax(im, h, varargin)
    
    nargin_ = argn(2)
    if nargin_ == 3 then
        conn = varargin(1)
        iptcheckconn(conn, "imhmax", "CONN")
    elseif nargin_ == 2 then
        conn = conndef(ndims(im), "maximal")
    else
        error("imhmax: invalid call, expected 2 or 3 input arguments")
    end
    
    if ~isnumeric(im) | ~isreal(im) | issparse(im) then
        error("imhmax: IM must be a real and nonsparse numeric array")
    end
    
    if ~isnumeric(h) | ~isscalar(h) | ~isreal(h) | (h < 0) then
        error("imhmax: H must be a non-negative scalar number")
    end
    
    im2 = imreconstruct(im - h, im, conn)
    
endfunction
