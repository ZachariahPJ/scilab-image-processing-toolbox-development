# `lab2xyz` Function Documentation

## Description

Transform a colormap or image from CIE L*a*b* to CIE XYZ color space.

A color in the CIE L*a*b* (or CIE Lab) space consists of lightness L* and two color-opponent dimensions a* and b*. The white point is taken as D65. The CIE L*a*b* color space is a colorimetric color space, meaning its values do not depend on display device hardware, and it is designed to incorporate the human perception of color differences.

A color in the CIE XYZ color space consists of three values X, Y and Z, which are likewise colorimetric.

The underlying function accepts both `single` and `double` inputs and always returns output of type `double`, regardless of the input type. In this Scilab port, only `double` input is accepted; `single` is not a distinct numeric type in Scilab and is therefore not supported. The shape of the input (a single triplet, an `Nx3` colormap, or an `MxNx3`/`MxNx3xK` image) is preserved in the output.

The input values of L* are normally in the interval [0, 100] and the values of a* and b* in the interval [-127, 127]. Values outside these intervals are not rejected or clamped — the function follows the conversion formula as given, so out-of-range input produces mathematically consistent, but not physically meaningful, output.

## Input parameter
`lab` - Input values of type `double`. The shape of the input is conserved in the output.
The input values of L* are normally in the interval [0, 100] and the values of a* and b* in the interval [-127, 127].

## Dependencies
  1. colorspace_conversion_input_check 
  2. colorspace_conversion_revert
  3. iscolormap
  4. intmax

## Syntax
```scilab
xyz = lab2xyz(lab)
```

## Detailed description

This function converts Lab color values to XYZ color values. It calculates intermediate values from the L, a, and b components, and uses a conditional function `f` to handle the non-linear transformation: values are raised to the third power where the cubed input exceeds `(6/29)^3`, and a linear formula is applied otherwise. The output values are scaled using the D65 reference white point to obtain the final XYZ values.

## Test cases

1.     lab2xyz ([53.24, 80.09, 67.20])
    Result: `[0.412437171   0.212665582   0.019335931]`

2.     lab2xyz ([97.14, -21.55, 94.48])
    Result: `[0.770066731   0.927843128   0.138522754]`

3.     lab2xyz ([32.30, 79.19, -107.86])
    Result: `[0.180466443   0.072188401   0.95037856]`

4.     lab2xyz ([100, 0.00, 0.00])
    Result: `[0.95047   1.   1.08883]`

5.     lab2xyz ([68.11, 48.39, 22.83])
    Result: `[0.527644949   0.381214079   0.248283392]`

6.     lab2xyz ([60.32, 98.24, -60.83])
    Result: `[0.592841994   0.284800743   0.969605429]`

7.     lab2xyz (sparse ([100, 0.00, 0.00]))
    Result: `[0.95047   1.   1.08883]`

8.     lab2xyz([5 4 3])
    Result: `[0.0062376   0.0055353   0.0039296]`

9.     lab2xyz([0 1 0 1 1])
    Result: `error`

10.     lab2xyz("India")
    Result:  `error:  lab2xyz: Lab of invalid data type string`

11.     lab2xyz([5, 0, 0])
    Result: `[0.005262   0.005535   0.006028]`
    
    (Low L forces all three channels onto the linear branch of f, i.e. in^3 <= (6/29)^3)

12.     lab2xyz([6, 60, 0])
    Result: `[0.028220   0.006643   0.007233]`
    
    (Large a pushes only the X channel onto the cubic branch of f, while Y and Z, which do not depend on a, remain on the linear branch — verifies the branch selection is applied per channel)

13.     lab2xyz([100, 0, 0; 50, 0, 0])
    Result: `[0.95047   1.   1.08883; 0.175061   0.184184   0.200543]`

    (Nx3 colormap input with two rows — verifies row-wise/vectorized handling)

14.     lab2xyz(cat(3, [50 50; 50 50], [0 0; 0 0], [0 0; 0 0]))
    Result: `an MxNx3 array where every pixel equals [0.175061   0.184184   0.200543]`

    (Image input, MxNx3 — verifies the image shape is detected and preserved)