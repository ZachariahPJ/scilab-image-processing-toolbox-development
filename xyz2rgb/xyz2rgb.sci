// Copyright (C) 2018 - IIT Bombay - FOSSEE
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
// Author:Nancy Infancia M, Government college of technology.
// Organization: FOSSEE, IIT Bombay
// Email: toolbox@scilab.in


function rgb = xyz2rgb (xyz)

  if (argn(2)~= 1)
    error("Wrong number of inputs");
  end

  [xyz, cls, sz, is_im, is_nd, is_int] = ...
    colorspace_conversion_input_check("xyz2rgb", "XYZ", xyz, 1);

  matrix_xyz2rgb_D65 = ...
    [3.240479, -1.537150, -0.498535;
    -0.969256, 1.875992, 0.041556;
    0.055648, -0.204043, 1.057311];

  rgb_lin = xyz * matrix_xyz2rgb_D65';

  rgb = rgb_lin;
  mask = rgb_lin <= 0.0031308;
  rgb(mask) = 12.92 .* rgb_lin(mask);
  rgb(~mask) = 1.055 .* (rgb_lin(~mask) .^ (1.0/2.4)) - 0.055;

  rgb = colorspace_conversion_revert(rgb, cls, sz, is_im, is_nd, is_int, 0);
endfunction
