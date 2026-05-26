function angles = colorangle(rgb1, rgb2)
    rhs = argn(2);
    if rhs ~= 2 then
        error("colorangle: requires exactly 2 input arguments (rgb1, rgb2)");
    end

    rgb1 = check_rgb(rgb1, "RGB1");
    rgb2 = check_rgb(rgb2, "RGB2");

    r1 = size(rgb1, 1);
    r2 = size(rgb2, 1);

    if r1 ~= r2 & r1 ~= 1 & r2 ~= 1 then
        error("colorangle: RGB1 and RGB2 must have one or the same number of colors");
    end

    if r1 == 1 & r2 > 1 then
        rgb1 = ones(r2, 1) * rgb1;
    elseif r2 == 1 & r1 > 1 then
        rgb2 = ones(r1, 1) * rgb2;
    end

    norm1 = sqrt(sum(rgb1 .^ 2, 2));
    norm2 = sqrt(sum(rgb2 .^ 2, 2));

    dot_products = sum(rgb1 .* rgb2, 2);

    cosines = dot_products ./ (norm1 .* norm2);
    cosines = min(max(real(cosines), -1), 1);

    angles = acos(cosines) * 180 / %pi;

    zero_mask = (norm1 == 0) | (norm2 == 0);
    angles(zero_mask) = 0;

    angles = real(angles);
endfunction


function rgb = check_rgb(rgb, name)
    if type(rgb) > 8 | ~isreal(rgb) then
        error(msprintf("colorangle: %s must be a real numeric array", name));
    end
    if size(rgb, '*') == 3 then
        rgb = rgb(:)';
    elseif size(rgb, 2) ~= 3 then
        error(msprintf("colorangle: %s must be a 3-element or Nx3 array", name));
    end
    rgb = double(rgb);
endfunction
