# `hough` — Scilab Function Reference

## 1. Description

`hough` computes the Hough transform of a binary or numeric 2-D image, detecting straight lines by accumulating votes in a `(rho, theta)` parameter space. Each foreground pixel in the input image votes for every line that could pass through it. Cells in the accumulator matrix `H` with high vote counts correspond to lines that exist in the image.

The function is a direct port of the Octave `image` package `hough.m`, which internally called the compiled `hough_line.cc`. In this Scilab implementation, the accumulator loop is built directly into `hough` using only standard Scilab built-in functions, with no external dependencies.

The angle convention follows Octave and MATLAB: `theta` is measured clockwise from the vertical axis in degrees. Internally this is converted to counter-clockwise radians from the horizontal axis before the rho formula is applied.

---

## 2. Calling Sequence

```scilab
[H, theta, rho] = hough(bw)
[H, theta, rho] = hough(bw, 'ThetaResolution', res)
[H, theta, rho] = hough(bw, 'Theta', theta_vec)
[H, theta, rho] = hough(bw, 'RhoResolution', 1)
```

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `bw` | 2-D numeric or boolean matrix | ✓ | Input binary image. Nonzero pixels are treated as foreground and cast votes. |
| `'ThetaResolution'` | Scalar in `(0, 180)` | — | Angular spacing of the theta axis in degrees. **Default: 1.** |
| `'Theta'` | Real vector | — | Explicit theta vector in degrees, overrides `ThetaResolution`. |
| `'RhoResolution'` | Scalar | — | Rho bin spacing. Only value `1` is currently supported. |
| `H` | Matrix (`length(rho) × length(theta)`) | — | **Output.** Hough accumulator. Each cell counts votes for a line at that `(rho, theta)`. |
| `theta` | Row vector | — | **Output.** Theta axis values in degrees, default `-90:1:89`. |
| `rho` | Column vector | — | **Output.** Rho axis values in pixels, symmetric around zero. |

> **Note:** Property names are case-insensitive. `'thetaresolution'` and `'ThetaResolution'` are treated identically.

---

## 4. Algorithm

For each foreground pixel at 0-based coordinates `(row, col)`, the rho value for every angle `theta` is computed as:

```
rho = col * cos(theta_rad) + row * sin(theta_rad)
```

where `theta_rad = (-theta + 90) * pi / 180` converts from the MATLAB/Octave degree convention to radians. The result is rounded to the nearest integer and used as a row index into `H`. After all pixels are processed, peaks in `H` identify the strongest lines in the image.

---

## 5. Test Cases

The following 20 test cases cover output dimensions, geometric correctness, property handling, and error conditions. Load both files before running:

```scilab
exec('hough.sci', -1)
```

---

### TC-01 — Default Output Sizes

Verifies that with default parameters, `theta` has 180 elements and `H` has the correct dimensions.

```scilab
bw = zeros(100, 100);
bw(50, :) = 1;
[H, theta, rho] = hough(bw);
disp(size(H))
disp(size(theta))
```

**Expected output:** `size(theta)` is `[1, 180]`. `size(H)` is `[length(rho), 180]`.

---

### TC-02 — Default Theta Range

Verifies that the default theta axis runs from `-90` to `89` with 180 elements.

```scilab
bw = eye(10, 10);
[H, theta, rho] = hough(bw);
mprintf("theta(1)=%d, theta(end)=%d, length=%d\n", theta(1), theta($), length(theta));
```

**Expected output:** `theta(1) = -90`, `theta($) = 89`, `length(theta) = 180`.

---

### TC-03 — Horizontal Line Peak at theta=0

Verifies that a horizontal line in the image produces a peak at `theta = 0`.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
[peak_val, peak_idx] = max(H(:));
[peak_rho_idx, peak_theta_idx] = ind2sub(size(H), peak_idx);
mprintf("Peak theta = %d degrees\n", theta(peak_theta_idx));
```

**Expected output:** Peak theta is `0` degrees.

---

### TC-04 — Vertical Line Peak at theta=90

Verifies that a vertical line produces a peak at `theta = 90` or `theta = -90`.

```scilab
bw = zeros(101, 101);
bw(:, 51) = 1;
[H, theta, rho] = hough(bw);
[peak_val, peak_idx] = max(H(:));
[peak_rho_idx, peak_theta_idx] = ind2sub(size(H), peak_idx);
mprintf("Peak theta = %d degrees\n", theta(peak_theta_idx));
```

**Expected output:** Peak theta is `90` or `-90` degrees.

---

### TC-05 — All-Zero Image

Verifies that an all-zero input image produces an all-zero accumulator.

```scilab
bw = zeros(50, 50);
[H, theta, rho] = hough(bw);
mprintf("Max H value = %d\n", max(H(:)));
```

**Expected output:** `Max H value = 0`

---

### TC-06 — Single Pixel Vote Count

Verifies that a single foreground pixel casts exactly `length(theta)` votes — one per angle.

```scilab
bw = zeros(50, 50);
bw(25, 25) = 1;
[H, theta, rho] = hough(bw);
mprintf("Total votes = %d, length(theta) = %d\n", sum(H(:)), length(theta));
```

**Expected output:** `Total votes == length(theta)`

---

### TC-07 — Numeric (Double) Input Accepted

Verifies that a `double` matrix is accepted without error and cast to boolean internally.

```scilab
bw = zeros(20, 20);
bw(10, :) = 1;
[H, theta, rho] = hough(bw);
mprintf("Passed without error\n");
```

**Expected output:** No error. `H` is a valid accumulator matrix.

---

### TC-08 — ThetaResolution Property

Verifies that `ThetaResolution = 2` halves the number of theta values.

```scilab
bw = zeros(20, 20);
bw(10, :) = 1;
[H, theta, rho] = hough(bw, 'ThetaResolution', 2);
mprintf("length(theta) = %d\n", length(theta));
```

**Expected output:** `length(theta)` equals `length(-90:2:88)`.

---

### TC-09 — Custom Theta Vector

Verifies that a user-supplied theta vector is passed through to the output unchanged.

```scilab
bw = zeros(20, 20);
bw(10, :) = 1;
custom_theta = -45:5:45;
[H, theta, rho] = hough(bw, 'Theta', custom_theta);
disp(isequal(theta, custom_theta))
```

**Expected output:** `%T`

---

### TC-10 — RhoResolution=1 Accepted

Verifies that `RhoResolution = 1` (the only supported value) is accepted without error.

```scilab
bw = zeros(20, 20);
bw(10, :) = 1;
[H, theta, rho] = hough(bw, 'RhoResolution', 1);
mprintf("Passed without error\n");
```

**Expected output:** No error.

---

### TC-11 — RhoResolution != 1 Raises Error

Verifies that any `RhoResolution` value other than `1` raises a not-implemented error.

```scilab
bw = zeros(20, 20);
try
    [H, theta, rho] = hough(bw, 'RhoResolution', 2);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-12 — Odd varargin Count Raises Error

Verifies that an odd number of property/value arguments raises an error.

```scilab
bw = zeros(20, 20);
try
    [H, theta, rho] = hough(bw, 'ThetaResolution');
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-13 — Unknown Property Raises Error

Verifies that an unrecognised property name raises an error.

```scilab
bw = zeros(20, 20);
try
    [H, theta, rho] = hough(bw, 'FakeProperty', 1);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-14 — ThetaResolution Out of Range Raises Error

Verifies that a `ThetaResolution` value outside `(0, 180)` raises an error.

```scilab
bw = zeros(20, 20);
try
    [H, theta, rho] = hough(bw, 'ThetaResolution', 200);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-15 — Non-Numeric Input Raises Error

Verifies that passing a string as `bw` raises an error.

```scilab
try
    [H, theta, rho] = hough("hello");
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-16 — 3-D Input Raises Error

Verifies that a 3-D matrix raises an error since only 2-D images are supported.

```scilab
try
    bw_3d = ones(10, 10, 3);
    [H, theta, rho] = hough(bw_3d);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-17 — No Arguments Raises Error

Verifies that calling `hough` with no arguments raises an error.

```scilab
try
    [H, theta, rho] = hough();
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-18 — rho Axis is Symmetric Around Zero

Verifies that the rho axis is symmetric, with `rho(1) == -rho($)`.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
mprintf("rho(1)=%d, rho(end)=%d\n", rho(1), rho($));
```

**Expected output:** `rho(1)` and `rho($)` are equal in magnitude and opposite in sign.

---

### TC-19 — Property Names are Case-Insensitive

Verifies that uppercase property names are handled correctly.

```scilab
bw = zeros(20, 20);
bw(10, :) = 1;
try
    [H, theta, rho] = hough(bw, 'THETARESOLUTION', 2);
    mprintf("Uppercase property accepted\n");
catch
    mprintf("Error raised\n");
end
```

**Expected output:** `Uppercase property accepted`

---

### TC-20 — Total Vote Count Equals Pixels Times Angles

Verifies that the sum of all votes in `H` equals the number of foreground pixels multiplied by the number of angles.

```scilab
bw = zeros(30, 30);
bw(10, 5)  = 1;
bw(20, 15) = 1;
bw(25, 25) = 1;
[H, theta, rho] = hough(bw);
n_fg = sum(bw(:));
mprintf("sum(H)=%d, n_fg*n_theta=%d\n", sum(H(:)), n_fg * length(theta));
```

**Expected output:** `sum(H(:)) == n_fg * length(theta)`

---

## 6. Porting Notes and Challenges

**`nargin` → `argn(2)`:** Scilab uses `argn(2)` to get the input argument count. `nargin` is not available.

**`validateattributes`:** No equivalent in Scilab. Replaced with explicit `type()` and `ndims()` checks. Scilab type codes: `type <= 8` covers all numeric types; `type == 4` covers boolean.

**`logical(bw)`:** Scilab has no `logical()` cast. Replaced with `(bw ~= 0)`, which produces a boolean matrix.

**`varargin{idx}` → `varargin(idx)`:** Scilab uses round brackets for all indexing, including cell-like lists. Curly braces are not used.

**`switch/case/endswitch` → `select/case/end`:** Scilab uses `select` instead of `switch` and a single `end` to close the block.

**`tolower` → `convstr(s, "l")`:** Scilab's equivalent for converting a string to lowercase.

**`rem` → `modulo`:** Both compute the remainder but `modulo` is the standard Scilab name.

**`&&` / `||` → `&` / `|`:** Scilab does not reliably support short-circuit `&&` and `||` operators. Element-wise `&` and `|` are used throughout.

**`hough_line.cc`:** The original Octave function called a compiled C++ MEX-like file for the accumulator loop. Since no equivalent compiled function exists in Scilab, the accumulator is implemented directly in Scilab using `find`, `cos`, `sin`, `round`, and a pixel loop.