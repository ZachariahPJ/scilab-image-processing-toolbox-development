function im2 = imreconstruct(marker, mask, varargin)

    nargin_ = argn(2)

    if nargin_ < 2 | nargin_ > 3 then
        error("imreconstruct: invalid call, expected 2 or 3 input arguments")
    end

    if typeof(marker) ~= typeof(mask) then
        error("imreconstruct: MARKER and MASK must be of same class")
    end

    if nargin_ > 2 then
        conn_mask = conndef(varargin(1))
    else
        conn_mask = conndef(length(size(marker)), "maximal")
    end

    im2 = _fast_hybrid_reconstruction(marker, mask, conn_mask)
endfunction

function v = _min_value_for_type(t)
    if t == "boolean" then
        v = 0
    elseif t == "int8" then
        v = -128
    elseif t == "int16" then
        v = -32768
    elseif t == "int32" then
        v = -2147483648
    elseif t == "int64" then
        v = -9223372036854775808
    elseif t == "uint8" | t == "uint16" | t == "uint32" | t == "uint64" then
        v = 0
    else
        v = -%inf
    end
endfunction

function strides = _strides_from_dims(dims)
    nd = length(dims)
    strides = zeros(1, nd)
    strides(1) = 1
    for k = 2:nd
        strides(k) = strides(k - 1) * dims(k - 1)
    end
endfunction

function idx0 = _interior_offsets_rec(dim, dims, strides)
    if dim == 1 then
        n = dims(1) - 2
        idx0 = strides(1) * (1:n)'
    else
        n = dims(dim) - 2
        sub = _interior_offsets_rec(dim - 1, dims, strides)
        idx0 = []
        for k = 1:n
            idx0 = [idx0; sub + k * strides(dim)]
        end
    end
endfunction

function y = _pad_array(x, nd, pad_val)
    sz = size(x)
    sz = sz(1:nd)
    padded_sz = sz + 2
    n_total = prod(padded_sz)
    y = matrix(pad_val * ones(1, n_total), padded_sz)
    strides = _strides_from_dims(padded_sz)
    idx0 = _interior_offsets_rec(nd, padded_sz, strides)
    y(idx0 + 1) = x(:)
endfunction

function y = _unpad_array(x, nd)
    padded_sz = size(x)
    padded_sz = padded_sz(1:nd)
    sz = padded_sz - 2
    strides = _strides_from_dims(padded_sz)
    idx0 = _interior_offsets_rec(nd, padded_sz, strides)
    y = matrix(x(idx0 + 1), sz)
endfunction

function subs = _ind2sub_generic(lin_idx, dims)
    nd = length(dims)
    subs = zeros(1, nd)
    rem = lin_idx - 1
    for i = 1:nd
        subs(i) = modulo(rem, dims(i)) + 1
        rem = floor(rem / dims(i))
    end
endfunction

function [neg_off, pos_off, all_off] = _neighbourhood_offsets(conn_mask, nd, strides)
    mask_dims_full = size(conn_mask)
    mask_dims = mask_dims_full(1:nd)
    centre = ones(1, nd) * 2

    found = find(conn_mask)
    neg_off = []
    pos_off = []
    for k = 1:length(found)
        subs = _ind2sub_generic(found(k), mask_dims)
        delta = subs - centre
        if or(delta ~= 0) then
            off = sum(delta .* strides(1:nd))
            if off < 0 then
                neg_off = [neg_off, off]
            elseif off > 0 then
                pos_off = [pos_off, off]
            end
        end
    end
    all_off = [neg_off, pos_off]
endfunction

function im2 = _fast_hybrid_reconstruction(marker_in, mask_in, conn_mask)
    orig_type = typeof(marker_in)
    nd = length(size(marker_in))

    pad_val = _min_value_for_type(orig_type)

    padded_marker = _pad_array(double(marker_in), nd, pad_val)
    padded_mask   = _pad_array(double(mask_in), nd, pad_val)

    padded_sz = size(padded_marker)
    padded_sz = padded_sz(1:nd)
    strides = _strides_from_dims(padded_sz)

    [neg_off, pos_off, all_off] = _neighbourhood_offsets(conn_mask, nd, strides)

    interior0 = _interior_offsets_rec(nd, padded_sz, strides)
    raster_idx = interior0 + 1
    antiraster_idx = raster_idx($:-1:1)

    for kk = 1:length(raster_idx)
        p = raster_idx(kk)
        vals = padded_marker(p)
        if length(neg_off) > 0 then
            vals = max([vals, padded_marker(p + neg_off)])
        end
        if vals > padded_mask(p) then
            vals = padded_mask(p)
        end
        padded_marker(p) = vals
    end

    queue = []
    for kk = 1:length(antiraster_idx)
        p = antiraster_idx(kk)
        vals = padded_marker(p)
        if length(pos_off) > 0 then
            neigh_vals = padded_marker(p + pos_off)
            vals = max([vals, neigh_vals])
        else
            neigh_vals = []
        end
        if vals > padded_mask(p) then
            vals = padded_mask(p)
        end
        padded_marker(p) = vals

        if length(pos_off) > 0 then
            neigh_mask = padded_mask(p + pos_off)
            picks = (neigh_vals < vals) & (neigh_vals < neigh_mask)
            if or(picks) then
                queue(length(queue) + 1) = p
            end
        end
    end

    head = 1
    while head <= length(queue)
        p = queue(head)
        head = head + 1
        for k = 1:length(all_off)
            q = p + all_off(k)
            if padded_marker(q) < padded_marker(p) & padded_mask(q) ~= padded_marker(q) then
                padded_marker(q) = min(padded_marker(p), padded_mask(q))
                queue(length(queue) + 1) = q
            end
        end
    end

    result = _unpad_array(padded_marker, nd)

    if orig_type == "boolean" then
        im2 = (result ~= 0)
    elseif orig_type == "int8" then
        im2 = int8(result)
    elseif orig_type == "int16" then
        im2 = int16(result)
    elseif orig_type == "int32" then
        im2 = int32(result)
    elseif orig_type == "int64" then
        im2 = int64(result)
    elseif orig_type == "uint8" then
        im2 = uint8(result)
    elseif orig_type == "uint16" then
        im2 = uint16(result)
    elseif orig_type == "uint32" then
        im2 = uint32(result)
    elseif orig_type == "uint64" then
        im2 = uint64(result)
    else
        im2 = result
    end
endfunction
