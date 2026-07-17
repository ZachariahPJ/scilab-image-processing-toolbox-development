function conn_mask=conndef(varargin)

    nargin_ = argn(2)
    if nargin_ < 1 | nargin_ > 2 then
        error("conndef: invalid call, expected 1 or 2 input arguments")
    end

    if nargin_ == 1 then
        conn = conndef_dispatch(varargin(1))
    else

        ndims_raw = varargin(1)

        if ~isnumeric(ndims_raw) then
            error("conndef: octave_base_value::uint_value (): wrong type argument " + "`"+_octave_type_name(ndims_raw)+"`")
        end
        if ~isscalar(ndims_raw) | ~isreal(ndims_raw) then
            error("conndef: NDIMS must be a positive integer")
        end
        if ndims_raw ~= round(ndims_raw) then
            error("conndef: conversion of " + string(ndims_raw) + " to unsigned int value failed")
        end

        ndims_ = round(ndims_raw)
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

function tname = _octave_type_name(val)
    t = typeof(val)
    if t == "string" then
        tname = "string"
    elseif t == "boolean" then
        tname = "bool"
    elseif t == "list" then
        tname = "cell"
    elseif t == "st" then
        tname = "struct"
    else
        tname = t
    end
endfunction
