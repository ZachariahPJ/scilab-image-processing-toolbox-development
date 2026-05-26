function [H, theta, rho] = hough(bw, varargin)

    rhs = argn(2);
    if rhs < 1 then
        error("hough: BW argument is required");
    end

    if type(bw) > 8 & type(bw) ~= 4 then
        error("hough: BW must be a logical or numeric 2-D matrix");
    end

    if ndims(bw) ~= 2 then
        error("hough: BW must be a 2-D matrix");
    end

    bw = (bw ~= 0);

    //default parameters
    theta = -90:1:89;
    theta_res = 1;

    n_args = length(varargin);
    if modulo(n_args, 2) ~= 0 then
        error("hough: PROPERTY/VALUE arguments must occur in pairs");
    end

    for idx = 1:2:n_args
        prop_str = convstr(varargin(idx), "l");
        val_data = varargin(idx+1);

        select prop_str

        case "rhoresolution"
            if val_data ~= 1 then
                error("hough: option RHORESOLUTION is not implemented");
            end

        case "thetaresolution"
            if ~(isreal(val_data) & isscalar(val_data) & val_data > 0 & val_data < 180) then
                error("hough: value THETARESOLUTION must be between 0 and 180");
            end
            theta_res = val_data;

        case "theta"
            if ~(isreal(val_data) & isvector(val_data)) then
                error("hough: values THETA must be a vector of real numbers");
            end
            theta = val_data;

        otherwise
            error(msprintf("hough: unknown property %s", varargin(idx)));

        end
    end
    if theta_res ~= 1 then
        theta = -90:theta_res:90;
        theta = theta(theta ~= 90);
    end

    theta_oct = (-theta + 90) * (%pi / 180);
    [H, rho] = hough_line(bw, theta_oct);

endfunction
