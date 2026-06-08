function imout = imcast(img, outcls, varargin)
    [lhs, rhs] = argn();

    // --- 1. INPUT VALIDATION & ARGUMENT PARSING ---
    if (rhs < 2 || rhs > 3) then
        error("imcast: wrong number of arguments.");
    elseif (rhs == 3) then
        param = varargin(1);
        if typeof(param) <> "string" || convstr(param, "l") <> "indexed" then
            error("imcast: third argument must be the string ""indexed""");
        end
    end

    // Normalize target class string to lowercase
    outcls = convstr(outcls, "l");

    // Determine the Scilab type of the input image
    incls_type = type(img);
    incls_str = "";
    
    if incls_type == 1 then
        incls_str = "double";
    elseif incls_type == 4 then
        incls_str = "logical";
    elseif incls_type == 8 then
        select inttype(img)
        case 11 then incls_str = "uint8";
        case 12 then incls_str = "uint16";
        case 14 then incls_str = "int16";
        else
            error("imcast: unsupported integer input class.");
        end
    else
        error("imcast: unknown image class type.");
    end

    // Direct exit if the source and target classes match perfectly
    if (outcls == incls_str) || (outcls == "single" && incls_str == "double") then
        imout = img;
        return;
    end

    // --- 2. INDEXED IMAGES PATH ---
    if (rhs == 3) then
        if ~isind(img) then
            error("imcast: input should have been an indexed image but it is not.");
        end

        if (outcls == "single" || outcls == "double") then
            if incls_type == 8 then
                imout = double(img) + 1; // 1-based index conversion for integers
            else
                imout = double(img);
            end

        else
            // Set dynamic upper bounds limits based on target class configurations
            select outcls
            case "uint8" then target_max = 255;
            case "uint16" then target_max = 65535;
            case "int16" then target_max = 32767;
            else
                error("imcast: unsupported integer type " + outcls);
            end

            if incls_type == 8 then
                // Check if the input range overflows the target class limit
                if max(double(img)) > target_max then
                    error(msprintf("imcast: IMG has too many colours %d for the range of values in %s", max(double(img)), outcls));
                end
            elseif incls_type == 1 then
                imax = max(img) - 1;
                if imax > target_max then
                    error(msprintf("imcast: IMG has too many colours %d for the range of values in %s", imax, outcls));
                end
                img = img - 1;
            end
            
            select outcls
            case "uint8" then imout = uint8(img);
            case "uint16" then imout = uint16(img);
            case "int16" then imout = int16(img);
            end
        end

    // --- 3. STANDARD IMAGES PATH ---
    else
        problem = %f;
        
        select incls_str
        case "double" then
            select outcls
            case "uint8" then imout = uint8(img * 255);
            case "uint16" then imout = uint16(img * 65535);
            case "int16" then imout = int16(img * 65535 - 32768);
            case "double" then imout = double(img);
            case "single" then imout = double(img);
            case "logical" then imout = (img <> 0);
            else problem = %t;
            end

        case "uint8" then
            select outcls
            case "double" then imout = double(img) / 255;
            case "single" then imout = double(img) / 255;
            case "uint16" then imout = uint16(img) * 257;
            case "int16" then imout = int16(double(img) * 257 - 32768);
            case "logical" then imout = (img <> 0);
            else problem = %t;
            end

        case "uint16" then
            select outcls
            case "double" then imout = double(img) / 65535;
            case "single" then imout = double(img) / 65535;
            case "uint8" then imout = uint8(double(img) / 257);
            case "int16" then imout = int16(double(img) - 32768);
            case "logical" then imout = (img <> 0);
            else problem = %t;
            end

        case "logical" then
            select outcls
            case "double" then imout = double(img);
            case "single" then imout = double(img);
            case "uint8" then 
                imout = zeros(img); 
                imout(img) = 255;
                imout = uint8(imout);
            case "uint16" then 
                imout = zeros(img); 
                imout(img) = 65535;
                imout = uint16(imout);
            case "int16" then 
                imout = ones(img) * -32768; 
                imout(img) = 32767;
                imout = int16(imout);
            else problem = %t;
            end

        case "int16" then
            select outcls
            case "double" then imout = (double(img) + 32768) / 65535;
            case "single" then imout = (double(img) + 32768) / 65535;
            case "uint8" then imout = uint8((double(img) + 32768) / 257);
            case "uint16" then imout = uint16(double(img) + 32768);
            case "logical" then imout = (img <> 0);
            else problem = %t;
            end
        end
        
        if (problem) then
            error("imcast: unsupported TYPE """ + outcls + """");
        end
    end
endfunction
