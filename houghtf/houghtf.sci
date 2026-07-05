function [accum, R] = houghtf(bw, varargin)
    
    rhs = argn(2);
    if rhs == 0 then
        error("houghtf: BW argument is required");
    end

    if ndims(bw) ~= 2 then
        error("houghtf: BW must be a 2-dimensional matrix");
    end

    method = "line";
    args = list();

    if rhs > 1 then
        first_arg = varargin(1);
        if type(first_arg) == 10 & isscalar(first_arg) then
            method = first_arg;
            for i = 2:length(varargin)
                args($+1) = varargin(i);
            end
        else
            for i = 1:length(varargin)
                args($+1) = varargin(i);
            end
        end
    end

    R = [];

    select convstr(method, "l")

    case "line"
        if length(args) == 0 then
            default_theta = -90:1:89;
            [accum, R] = hough_line(bw, default_theta);
        elseif length(args) == 1 then
            [accum, R] = hough_line(bw, args(1)(1));
        else
            error("houghtf: too many arguments for line method");
        end

    case "circle"
        if length(args) == 0 then
            error("houghtf: circle method requires a radius argument");
        elseif length(args) == 1 then
            accum = hough_circle(bw, args(1)(1));
        else
            error("houghtf: too many arguments for circle method");
        end

    otherwise
        error(msprintf("houghtf: unsupported method ""%s""", method));

    end
endfunction
