function iptcheckconn(varargin)
    nargin_ = argn(2)

    if nargin_ < 3 | nargin_ > 4 then
        error("iptcheckconn: invalid call, expected 3 or 4 input arguments")
    end

    conn = varargin(1)
    func = varargin(2)
    var  = varargin(3)

    pos = 0
    if nargin_ > 3 then
        pos = varargin(4)
        if ~(isnumeric(pos) & isscalar(pos)) | pos < 1 then
            error("iptcheckconn: POS must be a positive integer")
        end
    end

    has_error = %f
    try
        conn = conndef(conn)
    catch
        err_msg = lasterror()
        has_error = %t
    end

    if has_error then
        token = "CONN "
        n = strindex(err_msg, token)
        if isempty(n) then
            error("iptcheckconn: CONN is invalid but failed to parse error")
        end
        err_msg = part(err_msg, (n(1) + length(token)):length(err_msg))
        if pos == 0 then
            error(func + ": " + var + " " + err_msg)
        else
            error(sprintf("%s: %s, at pos %i, %s", func, var, int32(pos), err_msg))
        end
    end
endfunction
