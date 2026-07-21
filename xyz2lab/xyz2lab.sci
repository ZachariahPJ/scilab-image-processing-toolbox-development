// Copyright (C) 2018 - IIT Bombay - FOSSEE
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
// Author: Nancy Infancia M,Government college of technology
// Organization: FOSSEE, IIT Bombay
// Email: toolbox@scilab.in

function lab=xyz2lab(xyz)

  if (argn(2) ~= 1)
    error("Wrong no. of inputs");
  end

  [xyz, cls, sz, is_im, is_nd, is_int] ...
    = colorspace_conversion_input_check ("xyz2lab", "XYZ", xyz, 1);
 
  D65 = [0.95047, 1, 1.08883];

  xyz_D65 = xyz ./ (ones(size(xyz, 1), 1) * D65);
  
  epsilon = (6/29)^3;
  kappa = 1/116 * (29/3)^3;
  xyz_prime = xyz_D65;
  mask = xyz_D65 <= epsilon;
  xyz_prime(mask) = kappa .* xyz_D65(mask) + 16/116;
  xyz_prime(~ mask) = xyz_D65(~ mask) .^(1/3);
  x_prime = xyz_prime(:,1);
  y_prime = xyz_prime(:,2);
  z_prime = xyz_prime(:,3);

  L = 116 .* y_prime - 16;
  a = 500 .* (x_prime - y_prime);
  b = 200 .* (y_prime -  z_prime);

  lab = [L, a, b];

  lab = colorspace_conversion_revert (lab, cls, sz, is_im, is_nd, is_int, 1);
endfunction
