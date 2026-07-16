function nd = connectivity_ndims_from_dims(dims)
    if dims(2) == 1 then
        if dims(1) == 1 then
            nd = 0
        else
            nd = 1
        end
    else
        nd = length(dims)
    end
endfunction


function conn = connectivity_new_mask(mask_arg)
    conn = struct("mask", mask_arg)

    numel = prod(size(mask_arg))
    dims  = size(mask_arg)
    nd    = connectivity_ndims_from_dims(dims)

    for i = 1:nd
        if dims(i) ~= 3 then
            error("is not 1x1, 3x1, 3x3, or 3x3x...x3")
        end
    end

    center = floor(numel / 2)
    if mask_arg(center + 1) == 0 then
        error("center is not true")
    end

    for i = 0:(center - 1)
        if mask_arg(i + 1) ~= mask_arg(numel - i) then
            error("is not symmetric relative to its center")
        end
    end
endfunction


function conn = connectivity_new_num(conn_num)

    conn = struct("mask", [])

    if conn_num == 4 then
        md = ones(3, 3)
        md(1) = 0
        md(3) = 0
        md(7) = 0
        md(9) = 0
        conn.mask = md

    elseif conn_num == 6 then
        md = zeros(3, 3, 3)
        md(5)  = 1
        md(11) = 1
        md(13) = 1
        md(14) = 1
        md(15) = 1
        md(17) = 1
        md(23) = 1
        conn.mask = md

    elseif conn_num == 8 then
        conn.mask = ones(3, 3)

    elseif conn_num == 18 then
        md = ones(3, 3, 3)
        md(1)  = 0
        md(3)  = 0
        md(7)  = 0
        md(9)  = 0
        md(19) = 0
        md(21) = 0
        md(25) = 0
        md(27) = 0
        conn.mask = md

    elseif conn_num == 26 then
        conn.mask = ones(3, 3, 3)

    else
        error("must be in the set [4 6 8 18 26] (was " + string(conn_num) + ")")
    end
endfunction


function conn = connectivity_new_ndims_type(ndims_, type)
    conn = struct("mask", [])

    if ndims_ == 1 then
        sz = [3, 1]
    else
        sz = ones(1, ndims_) * 3
    end

    n = prod(sz)

    if type == "maximal" then
        conn.mask = matrix(ones(1, n), sz)

    elseif type == "minimal" then
        md = matrix(zeros(1, n), sz)

        center0 = floor(3^ndims_ / 2)
        md(center0 + 1) = 1

        for dim = 0:(ndims_ - 1)
            stride = 3^dim
            md(center0 + stride + 1) = 1
            md(center0 - stride + 1) = 1
        end
        conn.mask = md

    else
        error("must be ""maximal"" or ""minimal""")
    end
endfunction


function conn = conndef_dispatch(val)

    is_log = (typeof(val) == "boolean")
    is_num = (typeof(val) == "constant")

    if is_log | (is_num & ~or(val ~= 0 & val ~= 1)) then
        if is_log then
            mask_arg = double(val)
        else
            mask_arg = val
        end
        try
            conn = connectivity_new_mask(mask_arg)
        catch
            e_what = lasterror()
            error("conndef: CONN " + e_what)
        end

    elseif is_num & (prod(size(val)) == 1) then
        if double(val) < 1 then
            error("conndef: if CONN is a scalar it must be a positive number")
        end
        try
            conn = connectivity_new_num(round(val))
        catch
            e_what = lasterror()
            error("conndef: CONN " + e_what)
        end

    else
        error("conndef: CONN must either be a logical array or a numeric scalar")
    end
endfunction
