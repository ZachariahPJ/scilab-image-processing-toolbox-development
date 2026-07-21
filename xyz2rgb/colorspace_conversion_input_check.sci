function [in_arg, cls, sz, is_im, is_nd, is_int] = colorspace_conversion_input_check (func, arg_name, in_arg, only_floats)
  cls = typeof(in_arg);
  if typeof(in_arg) == "sparse" then
  in_arg = full(in_arg);
  cls = typeof(in_arg); 
end

  sz = size (in_arg);

 f=iscolormap(in_arg);
  if ~f then
    if ~or(strcmp(["uint8", "int8", "uint16", "double"],cls)==0) 
      error(msprintf ("%s: %s of invalid data type %s", func, arg_name, cls));
    elseif (only_floats &&  ~or(strcmp (["single", "double"],cls)==0)) 
      error(msprintf ("%s: %s of invalid data type %s", func, arg_name, cls));
    elseif (size (in_arg, 3) ~= 3 && ~(size (in_arg) == [1, 3] || size (in_arg) == [3, 1])) 
      error(msprintf("%s %s must be a colormap or %s image", func, arg_name, arg_name));
 elseif (~or(type(in_arg)==1 || type(in_arg)==2 || type(in_arg)==8) || or(imag(in_arg) <> 0)) 
      error(msprintf("%s: %s must be numeric and real", func, arg_name));
    end
    is_im = %t;   
    nd = ndims (in_arg);
    if (nd == 2 || nd == 3)
      is_nd = %f;
    elseif (nd == 4)
      is_nd = %t;
      in_arg = permute (in_arg, [1 2 4 3]);
    elseif (nd > 4)
      error(msprintf ("%s: invalid %s with more than 4 dimensions", func, arg_name));
    end
    in_arg = matrix (in_arg, [prod(size(in_arg))/3 3]);
  else
    is_im = %f;
    is_nd = %f;
  end

 
  if (type (in_arg)==8)
    in_arg = double (in_arg) / double (intmax (cls));
    is_int = %t;
  else
    is_int = %f;
  end

endfunction

