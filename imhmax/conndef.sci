function conn = conndef(varargin)
    [lhs, rhs] = argn();

    if rhs < 1 | rhs > 2 then
        error("conndef: requires 1 or 2 arguments.");
    end

    if rhs == 2 then
        num_dims = varargin(1);
        conntype = varargin(2);

        if ~(isreal(num_dims) & isscalar(num_dims) & num_dims > 0 & fix(num_dims) == num_dims) then
            error("conndef: number of dimensions must be a positive integer.");
        end
        if type(conntype) ~= 10 then
            error("conndef: second argument must be a string (""minimal"" or ""maximal"").");
        end

        conntype_l = convstr(conntype, "l");
        sz = repmat(3, 1, num_dims);

        if conntype_l == "minimal" then
            
            sz = repmat(3, 1, num_dims);
            
            dist_matrix = zeros(1, 3^num_dims);
            dist_matrix = matrix(dist_matrix, sz);
            
            for d = 1:num_dims
                sh = ones(1, num_dims);
                sh(d) = 3;
                grid_d = matrix(1:3, sh);
                
                sz_grid = ones(1, num_dims);
                sz_grid(1:length(size(grid_d))) = size(grid_d);
                rep_factors = sz ./ sz_grid;
                
                rep_grid = repmat(grid_d, rep_factors);
                dist_matrix = dist_matrix + abs(rep_grid - 2);
            end
            
            conn = double(dist_matrix <= 1);

        elseif conntype_l == "maximal" then
            conn = ones(3^num_dims, 1);
            conn = matrix(conn, sz);

        else
            error("conndef: unknown connectivity type """ + conntype + """.");
        end
        return;
    end

    input_arg = varargin(1);

    if ~isscalar(input_arg) then
        sz_in = size(input_arg);
        if any(sz_in ~= 3) then
            error("conndef: CONN must be a matrix with all dimensions of size 3.");
        end
        if any(input_arg ~= 0 & input_arg ~= 1) then
            error("conndef: CONN array elements must be either 0 or 1.");
        end
        
        mid_idx = cell(1, length(sz_in));
        for d = 1:length(sz_in)
            mid_idx(d).entries = 2;
        end
        if input_arg(mid_idx(:)) ~= 1 then
            error("conndef: CONN center element must be 1.");
        end
        
        conn = double(input_arg);
        return;
    end

    if ~(isreal(input_arg) & (input_arg == 4 | input_arg == 8 | input_arg == 6 | input_arg == 18 | input_arg == 26)) then
        error("conndef: scalar connectivity must be 4, 8, 6, 18, or 26.");
    end

    select input_arg
    case 4 then
        conn = conndef(2, "minimal");
    case 8 then
        conn = conndef(2, "maximal");
    case 6 then
        conn = conndef(3, "minimal");
    case 18 then
        conn = ones(3, 3, 3);
        conn(1,1,1) = 0; conn(1,3,1) = 0;
        conn(3,1,1) = 0; conn(3,3,1) = 0;
        conn(1,1,3) = 0; conn(1,3,3) = 0;
        conn(3,1,3) = 0; conn(3,3,3) = 0;
    case 26 then
        conn = conndef(3, "maximal");
    end

endfunction
