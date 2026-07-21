function rv = colorspace_conversion_revert (rv, cls, sz, is_im, is_nd, is_int, keep_class)
  if is_im then
    if (is_nd)
      rv = matrix (rv, [sz(1:2) sz(4) sz(3)]);
      rv = permute (rv, [1 2 4 3]);
    else
      rv = matrix (rv, sz);
    end
  end
  if is_int && ~keep_class then
    rv = rv*intmax(cls);
  end
endfunction
