// intmin.sci
//
// Scilab port of Octave's intmin.cc oct-file.
//
//   Imin = intmin()
//   Imin = intmin(type)
//   Imin = intmin(var)
//
// Return the smallest integer that can be represented by a specific
// integer type. The input is either a string naming an integer type,
// or an existing integer variable. Default type is "int32".
//
// Supported types: int8, int16, int32, int64,
//                   uint8, uint16, uint32, uint64
//
// Example:
//   x = int8(1);
//   intmin(x)
//     ans = -128

function m = intmin(varargin)
    [lhs, rhs] = argn(0);
    if rhs > 1 then
        error("intmin: wrong number of input arguments");
    end

    cname = "int32";

    if rhs == 1 then
        v = varargin(1);
        if type(v) == 10 then
            // string argument naming the type
            cname = v;
        elseif type(v) == 8 then
            // existing integer variable: type 8 covers all int/uint types in Scilab
            cname = typeof(v);
        else
            error("intmin: argument must be a string or integer variable");
        end
    end

    select cname
    case "uint8" then 
        m = uint8(0);
    case "uint16" then 
        m = uint16(0);
    case "uint32" then 
        m = uint32(0);
    case "uint64" then 
        m = uint64(0);
    case "int8" then 
        m = int8(-128);
    case "int16" then 
        m = int16(-32768);
    case "int32" then 
        m = int32(-2147483648);
    case "int64" then 
        m = int64(-9223372036854775808);
    else
        error("intmin: not defined for '" + cname + "' objects");
    end
endfunction
