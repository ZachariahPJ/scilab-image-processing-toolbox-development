# `xyz2rgb` Function Documentation

## Description
Convert a color, colormap, or image from the CIE XYZ color space to sRGB.

CIE XYZ is a device-independent, colorimetric representation of color: the same X, Y, Z triplet describes the same perceived color regardless of the display or printer used to reproduce it. `xyz2rgb` converts XYZ values into the nonlinear sRGB space (D65 white point) used by most screens, applying the standard XYZ→linear-RGB matrix transform followed by the sRGB gamma encoding curve.

Because raw XYZ values can map to linear RGB values outside the displayable range, the resulting sRGB output is clamped to `[0, 1]` before being returned, then rounded to two decimal places. The shape of the input (a single triplet, an `Nx3` colormap, or an `MxNx3`/`MxNx3xK` image) is preserved in the output, and if the input was an integer type, the output is cast back to that same type.

## Calling Sequence
```
rgb = xyz2rgb(xyz)
```

## Input Parameters

- `xyz`: A numeric matrix representing a single XYZ triplet `[X Y Z]`, a colormap `Nx3`, or an image with shape `MxNx3` or `MxNx3xK`.
  - Supported types: `double`, `uint8`, `int8`, `uint16`
  - Values are assumed to be normalized in the range [0, 1] for floating-point inputs.
  - Input values `single` is not accepted in Scilab

## Dependencies
* colorspace_conversion_input_check
* colorspace_conversion_revert
* iscolormap
* intmax

## Output Parameters

- `rgb`: A matrix of the same shape as `xyz` containing the corresponding RGB values. The output is:
  - Clamped to [0, 1]
  - Rounded to two decimal places
  - Converted to the original input data type (if it was integer)

## Test cases

1.     xyz2rgb ([0, 0, 0])
   Result: `[0 0 0]`
2.     xyz2rgb ([0.4125, 0.2127, 0.0193])
   Result: `[1 0 0]`
3.     xyz2rgb ([0.7700, 0.9278, 0.1385])
   Result: `[1 1 0]`
4.     xyz2rgb ([0.5276, 0.3812, 0.2482])
   Result: `[1 0.5 0.5]`
5.     xyz2rgb ([1, 1, 1])
   Result: `[1 0.98 0.96]`
   
   (Linear RGB exceeds 1 on the R channel before gamma correction; verifies clamping on the high end)
6.     xyz2rgb ([0.002, 0.002, 0.002])
   Result: `[0.03 0.02 0.02]`
   
   (Linear RGB values fall below the 0.0031308 threshold; verifies the linear, non-gamma branch)
7.     xyz2rgb ([-0.1, 0.2, 0.3])
   Result: `[0 0.73 0.56]`
   
   (Negative XYZ input produces a negative linear RGB value on the R channel; verifies clamping on the low end)
8.     xyz2rgb ()
   Result: `error`