function im2 = imhmax(im, h, varargin)

  [lhs, rhs] = argn();

  // --- 1. ARGUMENT & PARAMETER SANITIZATION ---
  if rhs < 2 | rhs > 3 then
    error("imhmax: requires 2 or 3 arguments.");
  end

  // Check image array validity
  if ~(or(type(im) == [1,5,8]) || type(im) == 4) then
    error("imhmax: IM must be a real and non-sparse numeric array.");
  end

  // Check dynamic threshold h validity
  if ~(or(type(h) == [1,5,8]) && isscalar(h) && isreal(h) && h >= 0) then
    error("imhmax: H must be a non-negative real scalar number.");
  end

  // Resolve connectivity definitions
  if rhs == 3 then
    conn = varargin(1);
    if ~(or(type(conn) == [1,5,8]) || type(conn) == 4) then
      error("imhmax: CONN must be a valid connectivity scalar or matrix array.");
    end
  else
    conn = conndef(ndims_local(im), "maximal");
  end

  // --- 2. CORE H-MAXIMA CALCULATION ---
  marker = double(im) - double(h);
  mask = double(im);

  // Call your stable fast FIFO queue reconstruction implementation
  im2_dbl = imreconstruct(marker, mask, conn);

  // --- 3. CLASS TYPE RESTORATION ---
  // Ensure returned matrix data types exactly mirror input specifications
  if type(im) == 8 then
    select inttype(im)
      case 11 then im2 = uint8(im2_dbl);
      case 12 then im2 = uint16(im2_dbl);
      case 2 then im2 = int16(im2_dbl);
    end
  elseif type(im) == 4 then
    im2 = (im2_dbl <> 0);
  else
    im2 = im2_dbl;
  end

endfunction

function n = ndims_local(A)
  n = length(size(A));
endfunction
