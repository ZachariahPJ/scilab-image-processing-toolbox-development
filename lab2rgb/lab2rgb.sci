// Copyright (C) 2018 - IIT Bombay - FOSSEE
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
// Author:Nancy Infancia M, Government college of technology
// Organization: FOSSEE, IIT Bombay
// Email: toolbox@scilab.in


function rgb = lab2rgb (lab)

  if (nargin ~= 1)
    error("Wrong no.of inputs");
  end

  [lab, cls, sz, is_im, is_nd, is_int] ...
    = colorspace_conversion_input_check ("lab2rgb", "Lab", lab, 1);

  xyz = lab2xyz (lab);

  rgb = xyz2rgb (xyz);
 
  rgb = colorspace_conversion_revert (rgb, cls, sz, is_im, is_nd, is_int, 1);

endfunction
