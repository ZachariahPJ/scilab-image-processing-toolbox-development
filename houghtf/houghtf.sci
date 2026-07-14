function [accum, R] = houghtf(bw, varargin)
    
  method = "line";
  args = list();

  [nargout, nargin] = argn();

  if (nargin == 0) then
    error("houghtf: not enough input arguments");
  end

  if (~ismatrix(bw)) then
    error("houghtf: BW must be a 2-dimensional matrix");
  end

  if (nargin > 1) then
    if (type(varargin(1)) == 10) then
      method = varargin(1);
      if (length(varargin) > 1) then
        args = varargin(2:$);
      else
        args = list();
      end
    else
      args = varargin;
    end
  end

  n_args = length(args);

  select convstr(method, 'l')
  case "line" then
    if n_args == 0 then
      [accum, R] = hough_line(bw);
    else
      [accum, R] = hough_line(bw, args(1));
    end
  case "circle" then
    if n_args == 0 then
      accum = hough_circle(bw);
    else
      accum = hough_circle(bw, args(1));
    end
  else
    error("houghtf: unsupported method '" + method + "'");
  end
endfunction
