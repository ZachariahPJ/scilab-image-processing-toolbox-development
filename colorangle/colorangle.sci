function angles = colorangle (rgb1, rgb2)
    if (argn(2) ~= 2) then
        error("Octave:invalid-input-arg", "print_usage ()");
    end

    rgb1 = check_rgb (rgb1, "RGB1");
    rgb2 = check_rgb (rgb2, "RGB2");
    
    if (size(rgb1, 1) ~= size(rgb2, 1) & (size(rgb1, 1) ~= 1 & size(rgb2, 1) ~= 1)) then
        error ("Octave:invalid-input-arg", ..
               "colorangle: RGB1 and RGB2 must have one or same number of colors");
    end

    norm1 = sqrt (sum(rgb1 .^ 2, 2));
    norm2 = sqrt (sum(rgb2 .^ 2, 2));

    if (size(rgb1, 1) == size(rgb2, 1)) then
        dot_products = sum(rgb1 .* rgb2, 2);
    elseif (size(rgb1, 1) > size(rgb2, 1)) then
        dot_products = rgb1 * rgb2';
    else
        dot_products = rgb2 * rgb1';
    end
    
    angles = acos (dot_products ./ (norm1 .* norm2)) * 180 / %pi;

    angles(norm1 == 0 & norm2 == 0) = 0;

    angles = real (angles);
endfunction

function rgb = check_rgb (rgb, name)
    if (type(rgb) > 8 | ~isreal(rgb)) then
         error("Octave:invalid-input-arg", "colorangle: " + name + " must be a real numeric array");
    end
    
    if (size(rgb, "*") == 3) then
        rgb = rgb(:)';
    elseif (size(rgb, 2) ~= 3) then
        error ("Octave:invalid-input-arg", ..
               "colorangle: " + name + " must be a 3 element or Nx3 array");
    end
endfunction
