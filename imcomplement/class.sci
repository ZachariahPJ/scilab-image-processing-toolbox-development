function name = class(A)
    select type(A)
    case 1 then
        name = "double";
    case 4 then
        name = "logical";
    case 10 then
        name = "char";
    case 8 then
        select inttype(A)
        case 1  then name = "int8";
        case 11 then name = "uint8";
        case 2  then name = "int16";
        case 12 then name = "uint16";
        case 4  then name = "int32";
        case 14 then name = "uint32";
        case 8  then name = "int64";
        case 18 then name = "uint64";
        end
    else
        error("class: unsupported type");
    end
endfunction
