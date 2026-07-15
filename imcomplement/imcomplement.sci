function B = imcomplement(A)
    [nargout, nargin] = argn();

    if (nargin ~= 1) then
        error("imcomplement: invalid call, use: imcomplement(A)");
    end

    if (type(A) == 1) then
        B = 1 - A;
    elseif (type(A) == 4) then
        B = ~A;
    elseif (type(A) == 8) then
        incls = class(A);
        if (intmin(incls) < 0) then
            B = bitcmp(A);
        else
            B = intmax(incls) - A;
        end
    else
        error("imcomplement: A must be an image but is of class """ + typeof(A) + """");
    end
endfunction
