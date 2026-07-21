// Copyright (C) 2018 - IIT Bombay - FOSSEE
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
// Author: Nancy Infancia M, Government College of Technology
// Organization: FOSSEE, IIT Bombay
// Email: toolbox@scilab.in


function xyz = lab2xyz (lab)

  if (argn(2) ~= 1)
    error("Wrong no. of inputs");
  end

  [lab, cls, sz, is_im, is_nd, is_int] ...
    = colorspace_conversion_input_check ("lab2xyz", "Lab", lab, 1);

  D65 = [0.95047, 1, 1.08883];
 
  L = lab(:,1);
  a = lab(:,2);
  b = lab(:,3);

  L_prime = (L + 16) ./ 116;

  x = D65(1) .* f (L_prime + a./500);
  y = D65(2) .* f (L_prime);
  z = D65(3) .* f (L_prime - b./200);

  xyz = [x, y, z];

  xyz = colorspace_conversion_revert (xyz, cls, sz, is_im, is_nd, is_int, 1);

endfunction

function out = f (in)
  epsilon = (6/29)^3;
  kappa = 1/116 * (29/3)^3;

  out = in;
  mask = in.^3 > epsilon;
  out(mask) = in(mask).^3;
  out(~ mask) = (in(~ mask) - 16/116)./kappa;
endfunction
