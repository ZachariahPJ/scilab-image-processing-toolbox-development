# `hough_line` — Scilab Function Reference

## 1. Description

`hough_line` is the accumulator engine of the Hough transform. It takes a binary image and a vector of angles in radians, and returns the Hough accumulator matrix `H` and the corresponding `rho` axis.

This function replicates the behaviour of `hough_line.cc` from the Octave `image` package, reimplemented entirely in standard Scilab. It is called internally by `hough.sci` and can also be used directly when angle conversion has already been handled externally.

For each foreground pixel at 0-based coordinates `(row, col)`, the perpendicular distance from the origin to the line at each angle is computed as:

```
rho = col * cos(theta) + row * sin(theta)
```

The result is rounded to the nearest integer and used to increment the corresponding cell in the accumulator `H`. After all pixels are processed, high values in `H` indicate strong line candidates at those `(rho, theta)` coordinates.

---

## 2. Calling Sequence

```scilab
[H, rho] = hough_line(bw, theta_oct)
```

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `bw` | 2-D boolean or numeric matrix | ✓ | Binary input image. Nonzero pixels are treated as foreground and cast votes into the accumulator. |
| `theta_oct` | Real vector (radians) | ✓ | Angles to test, in **radians**, measured counter-clockwise from the horizontal axis (Octave convention). |
| `H` | Matrix (`length(rho) × length(theta_oct)`) | — | **Output.** Hough accumulator. `H(i,k)` is the number of foreground pixels consistent with a line at `rho(i)` and `theta_oct(k)`. |
| `rho` | Row vector | — | **Output.** Rho axis values in pixels, ranging from `-ceil(D)` to `+ceil(D)` where `D` is the image diagonal length. |

> **Note:** `theta_oct` must be in radians in Octave convention. If you have theta in degrees in MATLAB/Octave convention, convert first with: `theta_oct = (-theta_deg + 90) * (%pi / 180)`
---

## 4. Relationship to `hough`

`hough_line` is the low-level engine. It expects angles already converted to radians in Octave convention and performs no argument parsing or validation.

`hough` is the high-level front-end. It handles all argument parsing, property/value pairs, and angle unit conversion before passing the prepared inputs to `hough_line`.

```
User calls hough()
    │
    ├── validates bw
    ├── parses ThetaResolution / Theta / RhoResolution
    ├── converts theta: (-theta + 90) * (pi/180)
    │
    └── calls hough_line(bw, theta_oct)
            │
            ├── builds rho axis
            ├── finds foreground pixels with find()
            ├── precomputes cos and sin
            └── runs accumulator voting loop
                    │
                    └── returns [H, rho]
```

If you already have angles in radians in Octave convention, `hough_line` can be called directly without going through `hough`.

---

## 5. Example Usage

```scilab
// Create a simple 5x5 diagonal line matrix
bw = [1 0 0 0 0;
      0 1 0 0 0;
      0 0 1 0 0;
      0 0 0 1 0;
      0 0 0 0 1];

// Define test angles in radians
theta = [-0.5, 0, 0.5];

// Compute Hough Line accumulator
[H, rho] = hough_line(bw, theta);

// Display Accumulator Dimensions (Expect 1x13 for a 5x5 image)
disp("Rho vector size:");
disp(size(rho));
```
**Expected output:**
```
1.   13.

0.   0.   0.
0.   0.   0.
2.   1.   1.
2.   1.   1.
1.   1.   0.
0.   1.   1.
