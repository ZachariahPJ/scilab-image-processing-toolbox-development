function bool = isind(img)
    bool = %f;
    im_is_valid = (or(type(img) == [1, 5, 8]) || type(img) == 4) && ndims(img) >= 2;
    if (im_is_valid && ndims(img) < 5 && size(img, 3) == 1) then
        if (type(img) == 1) then
            bool = and((img == floor(img)) & (img > 0), "*");
        elseif (or(inttype(img) == [11, 12])) then
            bool = %t;
        end
    end
endfunction
