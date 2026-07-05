function im2 = imhmin(im, h, varargin)

  [lhs, rhs] = argn();

  if rhs == 3 then
    conn = conndef(varargin(1));
  elseif rhs == 2 then
    conn = conndef(ndims(im), "maximal");
  else
    error("imhmin: requires 2 or 3 arguments.");
  end

  if ~(or(type(im) == [1,5,8]) || type(im) == 4) then
    error("imhmin: IM must be a real and nonsparse numeric array.");
  end

  if ~(or(type(h) == [1,5,8]) && isscalar(h) && isreal(h) && h >= 0) then
    error("imhmin: H must be a non-negative scalar number.");
  end

  im = imcomplement(im);
  im2 = imreconstruct((im - h), im, conn);
  im2 = imcomplement(im2);

endfunction
