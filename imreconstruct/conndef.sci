function conn_mask = conndef(varargin)

    nargin_ = argn(2)
    if nargin_ < 1 | nargin_ > 2 then
        error("conndef: invalid call, expected 1 or 2 input arguments")
    end

    if nargin_ == 1 then
        conn = conndef_dispatch(varargin(1))
    else

        ndims_ = round(varargin(1))
        if ndims_ < 1 then
            error("conndef: NDIMS must be a positive integer")
        end

        type = varargin(2)

        try
            conn = connectivity_new_ndims_type(ndims_, type)
        catch
            e_what = lasterror()
            error("conndef: TYPE " + e_what)
        end
    end

    conn_mask = double(conn.mask)
endfunction
