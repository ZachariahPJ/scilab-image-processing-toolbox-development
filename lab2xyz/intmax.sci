function maxval = intmax(x)
    max_values = struct("int8", 127, "int16", 32767, "int32", 2147483647, "int64", 9223372036854775807, ...
                        "uint8", 255, "uint16", 65535, "uint32", 4294967295, "uint64", 18446744073709551615);


    if type(x) == 10 
        typename = x;
    elseif type(x) == 8  
        typename = typeof(x);
    else
        error("Input must be an integer type or a string specifying the type.");
    end


    if isfield(max_values, typename)
        maxval = max_values(typename);
    else
        error("Unsupported integer type: " + typename);
    end
endfunction
