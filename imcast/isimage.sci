function retval = isimage(img)
    retval = (type(img) == 1 | type(img) == 4 | type(img) == 8) & ~issparse(img) & ~isempty(img) & isreal(img);
endfunction
