function res = isimage(img)
    res = (type(img) == 1 | type(img) == 4 | type(img) == 8) & (ndims(img) == 2 | ndims(img) == 3);
endfunction
