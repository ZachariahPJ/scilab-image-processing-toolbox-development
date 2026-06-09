function imout = im2single(img, varargin)
    
    [lhs, rhs] = argn();
    if (rhs < 1 || rhs > 2) then
        error("im2single: wrong number of input arguments.");
    end

    if (rhs == 2) then
        param = varargin(1);
        
        if typeof(param) <> "string" || convstr(param, "l") <> "indexed" then
            error("im2single: second input argument must be the string ""indexed""");
        end
        
        imout = imcast(img, "single", "indexed");
    else
        imout = imcast(img, "single");
    end

endfunction
