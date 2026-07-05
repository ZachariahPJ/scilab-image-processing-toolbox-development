function bool = isind(img)
    [lhs, rhs] = argn();

    if (rhs <> 1) then
        error("isind: wrong number of arguments.");
    end

    bool = %f;

    if (isimage(img) && ndims(img) < 5 && size(img, 3) == 1) then
        if (type(img) == 1) then
            bool = and((img == floor(img)) & (img > 0), "*");
        elseif (or(inttype(img) == [11, 12])) then
            bool = %t;
        end
    end
endfunction

