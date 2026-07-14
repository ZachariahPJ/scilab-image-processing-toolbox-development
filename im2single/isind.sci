function bool = isind(img)
    [nargout, nargin] = argn();

    if (nargin ~= 1) then
        error("isind: invalid call, use: isind(img)");
    end

    bool = %f;

    if (isimage(img) & ndims(img) < 5 & size(img, 3) == 1) then
        if (type(img) == 1) then
            bool = isindex(img);
        elseif or(typeof(img) == ["uint8", "uint16"]) then
            bool = %t;
        end
    end
endfunction

