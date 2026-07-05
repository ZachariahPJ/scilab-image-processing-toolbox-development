function ret = colorgradient(C, w, n)
    lhs = argn(1);
    rhs = argn(2);

    if rhs < 1 | rhs > 3 then
        error("Usage: colorgradient(C, [w], [n])");
    end

    if rhs == 1 then
        n = size(colormap(), 1);
        w = ones(size(C, 1) - 1, 1);
    elseif rhs == 2 then
        if length(w) == 1 then
            n = w;
            w = ones(size(C, 1) - 1, 1);
        else
            n = size(colormap(), 1);
        end
    end

    if (length(w) + 1 ~= size(C, 1)) then
        error("Must have one weight for each color interval");
    end

    w = 1 + round((n - 1) * cumsum([0; w(:)]) / sum(w));
    map = zeros(n, 3);

    for i = 1:length(w)-1
        if w(i) ~= w(i+1) then
            map(w(i):w(i+1), 1) = linspace(C(i,1), C(i+1,1), w(i+1)-w(i)+1)';
            map(w(i):w(i+1), 2) = linspace(C(i,2), C(i+1,2), w(i+1)-w(i)+1)';
            map(w(i):w(i+1), 3) = linspace(C(i,3), C(i+1,3), w(i+1)-w(i)+1)';
        end
    end

    if lhs == 0 then
        colormap(map);
    else
        ret = map;
    end
endfunction
