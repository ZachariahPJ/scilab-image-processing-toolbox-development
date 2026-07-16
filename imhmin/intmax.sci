// intmax.sci
//
// Scilab port of Octave's intmax.cc oct-file.
//
//   Imax = intmax()
//   Imax = intmax(type)
//   Imax = intmax(var)
//
// Return the largest integer that can be represented by a specific
// integer type. The input is either a string naming an integer type,
// or an existing integer variable. Default type is "int32".
//
// Supported types: int8, int16, int32, int64,
//                   uint8, uint16, uint32, uint64
//
// Example:
//   x = int8(1);
//   intmax(x)
//     ans = 127

function m = intmax(varargin)
    [lhs, rhs] = argn(0);
    if rhs > 1 then
        error("intmax: wrong number of input arguments");
    end

    cname = "int32";

    if rhs == 1 then
        v = varargin(1);
        if type(v) == 10 then
            // string argument naming the type
            cname = v;
        elseif isnum(v) & (typeof(v) == "int8"  | typeof(v) == "int16" | ..
                            typeof(v) == "int32" | typeof(v) == "int64" | ..
                            typeof(v) == "uint8"  | typeof(v) == "uint16" | ..
                            typeof(v) == "uint32" | typeof(v) == "uint64") then
            // existing integer variable: use its class name
            cname = typeof(v);
        else
            error("intmax: argument must be a string or integer variable");
        end
    end

    select cname
    case "uint8"  then m = uint8(255);
    case "uint16" then m = uint16(65535);
    case "uint32" then m = uint32(4294967295);
    case "uint64" then m = uint64(18446744073709551615);
    case "int8"   then m = int8(127);
    case "int16"  then m = int16(32767);
    case "int32"  then m = int32(2147483647);
    case "int64"  then m = int64(9223372036854775807);
    else
        error("intmax: not defined for '" + cname + "' objects");
    end
endfunction
