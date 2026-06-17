function conn = conndef(num_dims, conntype)
  [lhs, rhs] = argn();

  if rhs == 1 then
    if ~(or(type(num_dims) == [1,5,8]) && isscalar(num_dims)) then
      error("conndef: single argument must be a numeric scalar (4,8,6,18,26).");
    end
    select num_dims
      case 4 then
        conn = conndef(2, "minimal");
      case 8 then
        conn = conndef(2, "maximal");
      case 6 then
        conn = conndef(3, "minimal");
      case 18 then
        conn = ones(3, 3, 3) == 1;
        conn(1,1,1) = %f; conn(1,3,1) = %f;
        conn(3,1,1) = %f; conn(3,3,1) = %f;
        conn(1,1,3) = %f; conn(1,3,3) = %f;
        conn(3,1,3) = %f; conn(3,3,3) = %f;
        conn(2,2,2) = %t;
      case 26 then
        conn = conndef(3, "maximal");
      else
        error("conndef: scalar connectivity must be 4, 8, 6, 18, or 26.");
    end
    return;
  end

  if rhs ~= 2 then
    error("conndef: requires 1 or 2 arguments.");
  end

  if ~(or(type(num_dims) == [1,5,8]) && isscalar(num_dims) ..
       && num_dims > 0 && fix(num_dims) == num_dims) then
    error("conndef: number of dimensions must be a positive integer.");
  end

  if type(conntype) ~= 10 then
    error("conndef: second argument must be a string (""minimal"" or ""maximal"").");
  end

  conntype_l = convstr(conntype, "l");
  total = 3^num_dims;
  sz = repmat(3, 1, num_dims);

  if num_dims == 1 then
    conn = [%t; %t; %t];

  elseif conntype_l == "minimal" then
    if num_dims == 2 then
      conn = [0 1 0; 1 1 1; 0 1 0] == 1;
    else
      conn = zeros(total, 1) == 1;
      
      for dim = 1:num_dims
        for pos = 1:3 
          idx = repmat(2, 1, num_dims);
          idx(dim) = pos;
          conn(nd2lin(sz, idx)) = %t;
        end
      end
      conn = matrix(conn, sz);
    end

  elseif conntype_l == "maximal" then
    conn = ones(total, 1) == 1;
    conn = matrix(conn, sz);

  else
    error("conndef: unknown connectivity type """ + conntype + """.");
  end
endfunction

function lin = nd2lin(sz, idx)
  lin = idx(1);
  stride = 1;
  for k = 2:length(sz)
    stride = stride * sz(k-1);
    lin = lin + (idx(k) - 1) * stride;
  end
endfunction
