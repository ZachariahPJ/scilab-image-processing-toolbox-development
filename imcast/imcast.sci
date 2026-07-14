function imout = imcast(img, outcls, varargin)
    [nargout, nargin] = argn();

    if (nargin < 2 | nargin > 3) then
        error("imcast: invalid call, use: imcast(img, outcls) or imcast(img, outcls, ""indexed"")");
    elseif (nargin == 3 & ~(convstr(varargin(1), 'l') == "indexed")) then
        error("imcast: third argument must be the string ""indexed""");
    end

    incls = typeof(img);
    if (incls == "constant") then
        incls = "double";
    end

    if (outcls == incls) then
        imout = img;
        return
    end

    if (nargin == 3) then
        if (~isind(img)) then
            error("imcast: input should have been an indexed image but it is not.");
        end

        if (outcls == "single" | outcls == "double") then
            if (or(typeof(img) == ["uint8", "uint16", "int16"])) then
                imout = double(img) + 1;
            else
                imout = double(img);
            end
        else
            if (or(typeof(img) == ["uint8", "uint16", "int16"]) & intmax(incls) > intmax(outcls) & max(img(:)) > intmax(outcls)) then
                error(msprintf("imcast: IMG has too many colours ''%d'' for the range of values in %s", max(img(:)), outcls));
            elseif (type(img) == 1) then
                imax = max(img(:)) - 1;
                if (imax > intmax(outcls)) then
                    error(msprintf("imcast: IMG has too many colours ''%d'' for the range of values in %s", imax, outcls));
                end
                img = img - 1;
            end

            select outcls
            case "uint8" then
                imout = uint8(img);
            case "uint16" then
                imout = uint16(img);
            case "int16" then
                imout = int16(img);
            else
                error("imcast: unsupported class """ + outcls + """");
            end
        end

    else
        problem = %f;

        select incls
        case "double" then
            select outcls
            case "uint8" then
                imout = uint8(img * 255);
            case "uint16" then
                imout = uint16(img * 65535);
            case "int16" then
                imout = int16(double(img * uint16(65535)) - 32768);
            case "double" then
                imout = double(img);
            case "single" then
                imout = double(img);
            case "logical" then
                imout = (img == %t);
            else
                problem = %t;
            end

        case "single" then
            select outcls
            case "uint8" then
                imout = uint8(img * 255);
            case "uint16" then
                imout = uint16(img * 65535);
            case "int16" then
                imout = int16(double(img * uint16(65535)) - 32768);
            case "double" then
                imout = double(img);
            case "single" then
                imout = double(img);
            case "logical" then
                imout = (img == %t);
            else
                problem = %t;
            end

        case "uint8" then
            select outcls
            case "double" then
                imout = double(img) / 255;
            case "single" then
                imout = double(img) / 255;
            case "uint16" then
                imout = uint16(img) * 257;
            case "int16" then
                imout = int16((double(img) * 257) - 32768);
            case "logical" then
                imout = (img == %t);
            else
                problem = %t;
            end

        case "uint16" then
            select outcls
            case "double" then
                imout = double(img) / 65535;
            case "single" then
                imout = double(img) / 65535;
            case "uint8" then
                imout = uint8(img / 257);
            case "int16" then
                imout = int16(double(img) - 32768);
            case "logical" then
                imout = (img == %t);
            else
                problem = %t;
            end

        case "boolean" then
            select outcls
            case "double" then
                imout = double(img);
            case "single" then
                imout = double(img);
            case "uint8" then
                imout = repmat(intmin(outcls), size(img,1), size(img,2));
                imout(find(img)) = intmax(outcls);
            case "uint16" then
                imout = repmat(intmin(outcls), size(img,1), size(img,2));
                imout(find(img)) = intmax(outcls);
            case "int16" then
                imout = repmat(intmin(outcls), size(img,1), size(img,2));
                imout(find(img)) = intmax(outcls);
            else
                problem = %t;
            end

        case "int16" then
            select outcls
            case "double" then
                imout = (double(img) + 32768) / 65535;
            case "single" then
                imout = (double(img) + 32768) / 65535;
            case "uint8" then
                imout = uint8((double(img) + 32768) / 257);
            case "uint16" then
                imout = uint16(double(img) + 32768);
            case "logical" then
                imout = (img == %t);
            else
                problem = %t;
            end

        else
            error(msprintf("imcast: unknown image of class ""%s""", incls));
        end

        if (problem) then
            error(msprintf("imcast: unsupported TYPE ""%s""", outcls));
        end
    end
endfunction
