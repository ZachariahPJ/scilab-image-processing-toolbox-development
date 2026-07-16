function im2 = imhmin(im, h, varargin)

    nargin_ = argn(2)
    if nargin_ == 3 then
        conn = varargin(1)
        iptcheckconn(conn, "imhmin", "CONN")
    elseif nargin_ == 2 then
        conn = conndef(ndims(im), "maximal")
    else
        error("imhmin: invalid call, expected 2 or 3 input arguments")
    end

    if ~isnumeric(im) | ~isreal(im) | issparse(im) then
        error("imhmin: IM must be a real and nonsparse numeric array")
    end
    
    if ~isnumeric(h) | ~isscalar(h) | ~isreal(h) | (h < 0) then
        error("imhmin: H must be a non-negative scalar number")
    end

    im = imcomplement(im)
    im2 = imreconstruct(im - h, im, conn)
    im2 = imcomplement(im2)
    
endfunction
