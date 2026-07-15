function J = imreconstruct(marker, mask, conn)
    
    [lhs, rhs] = argn();
    if rhs < 2 | rhs > 3 then
        error("imreconstruct: requires between 2 and 3 input arguments.");
    end

    if ~(or(type(marker) == [1,5,8]) | type(marker) == 4) then
        error("imreconstruct: MARKER must be a numeric or logical matrix.");
    end
    if ~(or(type(mask) == [1,5,8]) | type(mask) == 4) then
        error("imreconstruct: MASK must be a numeric or logical matrix.");
    end

    same_class = %f;
    if type(marker) == type(mask) then
        if type(marker) == 8 then
            if inttype(marker) == inttype(mask) then
                same_class = %t;
            end
        else
            same_class = %t;
        end
    end
    if ~same_class then
        error("imreconstruct: MARKER and MASK must be of same class");
    end

    if or(size(marker) <> size(mask)) then
        error("imreconstruct: MARKER and MASK must be the same size");
    end

    if rhs < 3 then
        conn = 8;
    end

    marker_dbl = double(marker);
    mask_dbl = double(mask);
    [rows, cols] = size(marker_dbl);

    J = min(marker_dbl, mask_dbl);

    if isscalar(conn) then
        if conn == 4 then
            Nminus = [-1 0; 0 -1];
            Nplus  = [1 0; 0 1];
            Nall   = [-1 0; 1 0; 0 -1; 0 1];
        else
            Nminus = [-1 -1; -1 0; -1 1; 0 -1];
            Nplus  = [0 1; 1 -1; 1 0; 1 1];
            Nall   = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
        end
    else
        [conn_rows, conn_cols] = size(conn);
        if conn_rows <> 3 | conn_cols <> 3 then
            error("imreconstruct: CONN matrix must be 3x3 for 2-D images.");
        end
        Nminus = [];
        Nplus = [];
        Nall = [];
        for dr = -1:1
            for dc = -1:1
                if dr == 0 & dc == 0 then
                    continue;
                end
                if conn(dr+2, dc+2) <> 0 then
                    Nall = [Nall; dr dc];
                    if dr < 0 | (dr == 0 & dc < 0) then
                        Nminus = [Nminus; dr dc];
                    else
                        Nplus = [Nplus; dr dc];
                    end
                end
            end
        end
    end

    for r = 1:rows
        for c = 1:cols
            v = J(r,c);
            for k = 1:size(Nminus, 1)
                rr = r + Nminus(k,1);
                cc = c + Nminus(k,2);
                if rr >= 1 & rr <= rows & cc >= 1 & cc <= cols then
                    if J(rr,cc) > v then
                        v = J(rr,cc);
                    end
                end
            end
            J(r,c) = min(v, mask_dbl(r,c));
        end
    end

    max_elements = rows * cols;
    queue_r = zeros(1, max_elements);
    queue_c = zeros(1, max_elements);
    q_tail = 0;
    for r = rows:-1:1
        for c = cols:-1:1
            v = J(r,c);
            for k = 1:size(Nplus, 1)
                rr = r + Nplus(k,1);
                cc = c + Nplus(k,2);
                if rr >= 1 & rr <= rows & cc >= 1 & cc <= cols then
                    if J(rr,cc) > v then
                        v = J(rr,cc);
                    end
                end
            end
            J(r,c) = min(v, mask_dbl(r,c));

            push_pixel = %f;
            for k = 1:size(Nplus, 1)
                rr = r + Nplus(k,1);
                cc = c + Nplus(k,2);
                if rr >= 1 & rr <= rows & cc >= 1 & cc <= cols then
                    if J(rr,cc) < J(r,c) & J(rr,cc) < mask_dbl(rr,cc) then
                        push_pixel = %t;
                    end
                end
            end
            if push_pixel then
                q_tail = q_tail + 1;
                queue_r(q_tail) = r;
                queue_c(q_tail) = c;
            end
        end
    end

    head = 1;
    while head <= q_tail
        r = queue_r(head);
        c = queue_c(head);
        head = head + 1;

        for k = 1:size(Nall, 1)
            rr = r + Nall(k,1);
            cc = c + Nall(k,2);
            if rr >= 1 & rr <= rows & cc >= 1 & cc <= cols then
                if J(rr,cc) < J(r,c) & mask_dbl(rr,cc) ~= J(rr,cc) then
                    J(rr,cc) = min(J(r,c), mask_dbl(rr,cc));

                    if q_tail >= length(queue_r) then
                        queue_r = [queue_r, zeros(1, max_elements)];
                        queue_c = [queue_c, zeros(1, max_elements)];
                    end

                    q_tail = q_tail + 1;
                    queue_r(q_tail) = rr;
                    queue_c(q_tail) = cc;
                end
            end
        end
    end

    if type(marker) == 8 then
        select inttype(marker)
        case 1  then
            J = int8(J);
        case 11 then
            J = uint8(J);
        case 2  then
            J = int16(J);
        case 12 then
            J = uint16(J);
        case 4  then
            J = int32(J);
        case 14 then
            J = uint32(J);
        case 8  then
            J = int64(J);
        case 18 then
            J = uint64(J);
        end
    elseif type(marker) == 4 then
        J = (J <> 0);
    end
endfunction
