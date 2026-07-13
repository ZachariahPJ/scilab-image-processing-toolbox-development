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
      args = varargin(2:$);
    else
      args = varargin;
    end
  end

  select convstr(method, 'l')
  case "line" then
    [accum, R] = hough_line(bw, args(:));
  case "circle" then
    accum = hough_circle(bw, args(:));
  else
    error("houghtf: unsupported method " + method);
  end
endfunction
