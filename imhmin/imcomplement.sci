function B = imcomplement(A)

  [lhs, rhs] = argn();

  if rhs ~= 1 then
    error("imcomplement: Requires exactly 1 input argument.");
  end

  select type(A)
    
    case 4 then
      B = ~A;

    case 1 then
      B = 1.0 - A;

    case 8 then
      integer_type = inttype(A);
      
      select integer_type
          
        case 11 then
          B = uint8(255) - A;
          
        case 12 then
          B = uint16(65535) - A;
          
        case 14 then
          B = uint32(4294967295) - A;
          
        case 1 then
          B = bitnot(A);
          
        case 2 then
          B = bitnot(A);
          
        case 4 then
          B = bitnot(A);
          
        else
          error("imcomplement: Unsupported integer type class.");
      end

    else
      error("imcomplement: Input A must be a numeric or logical matrix array.");
  end

endfunction
