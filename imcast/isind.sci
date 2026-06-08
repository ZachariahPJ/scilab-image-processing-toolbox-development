function bool = isind(img)

  if (argn(2) ~= 1)
    error("isind: wrong number of arguments");
  end

  bool = %f;

  // isimage inlined: valid if numeric or boolean, and 2D or 3D
  im_is_valid = (or(type(img) == [1, 5, 8]) || type(img) == 4) ...
                && ndims(img) >= 2;

  if (im_is_valid && ndims(img) < 5 && size(img, 3) == 1)

    if (type(img) == 1)
      // isfloat: type 1 is double (floating point) in Scilab
      // isindex: all values are positive integers
      bool = and(img(:) == floor(img(:))) && and(img(:) > 0);

    elseif (or(inttype(img) == [11, 12]))
      // uint8 (inttype 11) or uint16 (inttype 12)
      bool = %t;

    end
  end

endfunction
