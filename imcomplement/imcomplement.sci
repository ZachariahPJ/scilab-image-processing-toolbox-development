function B = imcomplement(A)

  [lhs, rhs] = argn();

  if rhs ~= 1 then
    error("imcomplement: Requires exactly 1 input argument.");
  end

  if type(A) == 1 then
    B = 1 - A;

  elseif type(A) == 4 then
    B = ~A;

  elseif type(A) == 8 then
    integer_type = inttype(A);

    if integer_type == 1 | integer_type == 2 | integer_type == 4 then
      B = bitcmp(A);
    elseif integer_type == 11 then
      B = uint8(255) - A;
    elseif integer_type == 12 then
      B = uint16(65535) - A;
    elseif integer_type == 14 then
      B = uint32(4294967295) - A;
    else
      error("imcomplement: Unsupported integer type class.");
    end

  else
    error("imcomplement: A must be an image but is of unsupported type.");
  end

endfunction
