# xyz2lab - Scilab Function

## Description

`lab = xyz2lab (xyz)` transforms a colormap or image from the CIE XYZ color
space to the CIE L\*a\*b\* color space.

A color in the CIE XYZ color space consists of three values X, Y and Z.
Those values are designed to be colorimetric, meaning that their values do
not depend on the display device hardware.

A color in the CIE L\*a\*b\* (or CIE Lab) space consists of lightness L\* and
two color-opponent dimensions a\* and b\*. The whitepoint used is D65. Like
XYZ, the L\*a\*b\* colorspace is colorimetric, but it is additionally designed
to be closer to how humans perceive differences between colors.

Input values of class `single` and `double` are accepted. The shape and the
class of the input are conserved.

The return values of L\* are normally in the interval `[0, 100]` and the
values of a\* and b\* in the interval `[-127, 127]`.

This function is a Scilab port of the `xyz2lab` function from the Octave
`image` package.

## Calling Sequence

```
lab = xyz2lab(xyz)
```

## Input parameter

`xyz` - Matrix or array. A numeric array where the last dimension has size
3, representing XYZ color values. May be a single color (1x3), a colormap
(Nx3), or an image (MxNx3).

## Dependencies

* `colorspace_conversion_input_check()`
* `colorspace_conversion_revert()`
* `iscolormap`
* `intmax`

## Detailed description

1. Input Validation & Preprocessing
   * Ensures `xyz` has valid dimensions.
   * Normalizes XYZ by dividing by the D65 reference white.

2. Non-linear transformation
   * Applies a piecewise transformation to each XYZ channel: linear below
     the threshold `epsilon = (6/29)^3`, cube root above it.

3. Lab Computation
   * Computes L\*, a\*, b\* using the standard CIE formulas.

4. Output Formatting
   * Reshapes and restores the original input format (matrix/array
     dimensions and type).

## See also

`lab2xyz`, `rgb2lab`, `xyz2rgb`, `rgb2hsv`, `rgb2ind`, `rgb2ntsc`

## Test cases

**1. Single color, standard case**
```
xyz2lab([0.4125, 0.2127, 0.0193])
```
Result: `[53.243735   80.093121   67.238781]`

**2. Single color, standard case**
```
xyz2lab([0.7700, 0.9278, 0.1385])
```
Result: `[97.138247  -21.555908   94.482485]`

**3. Single color, standard case**
```
xyz2lab([0.5276, 0.3812, 0.2482])
```
Result: `[68.108965   48.382794   22.841896]`

**4. D65 white point** (should map to pure white: L=100, a=0, b=0)
```
xyz2lab([0.95047, 1, 1.08883])
```
Result: `[100   0   0]`

**5. Black point** (exercises the linear branch of the piecewise transform)
```
xyz2lab([0, 0, 0])
```
Result: `[0   0   0]`

**6. Small values near the epsilon threshold** (mixed/edge branch behaviour)
```
xyz2lab([0.1, 0.1, 0.1])
```
Result (approx): `[37.84   3.96   2.60]`

**7. Colormap input (Nx3 matrix, multiple colors at once)**
```
xyz2lab([0.4125, 0.2127, 0.0193; 0.7700, 0.9278, 0.1385])
```
Result:`
[53.243735   80.093121   67.238781;
 97.138247  -21.555908   94.482485]
`

**8. Out-of-range XYZ values** (Y > 1 is valid for XYZ, unlike normalized
RGB; should not error)
```
xyz2lab([1.2, 1.5, 1.1])
```
Result: runs without error, `L > 100`.

**9. Wrong number of input arguments**
```
xyz2lab(1, 2)
```
Result: `Wrong number of input arguments.`

**10. Invalid data type**
```
xyz2lab("hello")
```
Result: `xyz2lab: XYZ of invalid data type string`