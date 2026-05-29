# `hough` — Scilab Function Reference

## 1. Description

`hough` computes the Hough transform of a binary or numeric 2-D image, detecting straight lines by accumulating votes in a `(rho, theta)` parameter space. Each foreground pixel in the input image votes for every line that could pass through it. Cells in the accumulator matrix `H` with high vote counts correspond to lines that exist in the image.

This implementation is a direct port of the Octave `image` package `hough.m`. The original Octave version internally called a compiled C++ function `hough_line.cc` to perform the accumulation. In this Scilab port, `hough` handles all argument parsing and unit conversion, then delegates the accumulator computation to a companion function `hough_line.sci` which must be loaded alongside it.

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
| `bw` | 2-D numeric or boolean matrix | ✓ | Input binary image. Nonzero pixels are treated as foreground and cast votes into the accumulator. |
| `'ThetaResolution'` | Scalar in `(0, 180)` | — | Angular spacing of the theta axis in degrees. **Default: 1.** |
| `'Theta'` | Real vector | — | Explicit theta vector in degrees. Overrides `ThetaResolution` when supplied. |
| `'RhoResolution'` | Scalar | — | Rho bin spacing in pixels. Only the value `1` is currently supported. |
| `H` | Matrix (`length(rho) × length(theta)`) | — | **Output.** Hough accumulator. Each cell `H(i,j)` counts the number of foreground pixels consistent with a line at `rho(i)` and `theta(j)`. |
| `theta` | Row vector (degrees) | — | **Output.** Theta axis values in degrees. Default range is `-90:1:89` (180 values). |
| `rho` | Column vector (pixels) | — | **Output.** Rho axis values in pixels, symmetric around zero. Range is `[-ceil(D), ceil(D)]` where `D` is the image diagonal. |

> **Note:** Property names are case-insensitive. `'thetaresolution'` and `'ThetaResolution'` are treated identically.

> **Note:** `hough_line.sci` must be loaded before calling `hough`. Run `exec('hough_line.sci', -1)` first.

---

## 4. How It Works

### 4.1 Argument Parsing

`hough` processes optional property/value pairs from `varargin`. It detects whether an odd or even number of extra arguments was supplied and raises an error if any property name is unpaired. Property names are converted to lowercase using `convstr` before matching, making them case-insensitive.

### 4.2 Angle Convention Conversion

The theta axis in the output is in MATLAB/Octave degrees, measured clockwise from the vertical axis. Before passing to `hough_line`, every theta value is converted to the Octave internal convention — counter-clockwise radians from the horizontal axis:

```
theta_oct = (-theta + 90) * (pi / 180)
```

For example, `theta = 0°` (horizontal line) becomes `theta_oct = pi/2`, where `cos(pi/2) = 0` and `sin(pi/2) = 1`, so the rho formula `rho = col*cos + row*sin` correctly gives `rho = row` — the row index of the horizontal line.

### 4.3 Accumulator Construction

`hough` delegates the actual vote accumulation to `hough_line`, passing the boolean image and the converted angle vector. `hough_line` returns the accumulator `H` and the rho axis vector `rho`. See the `hough_line` reference for details of the accumulation algorithm.

---

## 5. Dependency

```
hough.sci   (argument parsing, unit conversion)
    │
    └── hough_line.sci   (accumulator voting loop)
```

`hough_line` must be loaded first. It can also be called directly when angles have already been converted to the Octave radian convention.

---

## 6. Test Cases

The following 17 test cases cover output dimensions, geometric correctness, property handling, and error conditions. Load both files before running:

```scilab
exec('hough_line.sci', -1)
exec('hough.sci', -1)
```

---

### TC-01 — Default Theta Range

Verifies that the default theta axis runs from `-90` to `89` with exactly 180 elements.

```scilab
bw = zeros(20, 20);
bw(10, :) = 1;
[H, theta, rho] = hough(bw);
mprintf("theta(1)=%d  theta($)=%d  length=%d\n", theta(1), theta($), length(theta));
```

**Expected output:** `theta(1)=-90  theta($)=89  length=180`

---

### TC-02 — H Has Correct Dimensions

Verifies that `H` has `length(rho)` rows and `length(theta)` columns.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
mprintf("H size: %d x %d\n", size(H,1), size(H,2));
mprintf("Expected: %d x %d\n", length(rho), length(theta));
```

**Expected output:** Both lines match.

---

### TC-03 — Horizontal Line Peak at theta=0

Verifies that a horizontal line in the image produces the strongest peak at `theta = 0` degrees.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
[peak_val, peak_idx] = max(H(:));
[peak_rho_idx, peak_theta_idx] = ind2sub(size(H), peak_idx);
mprintf("Peak theta = %d degrees\n", theta(peak_theta_idx));
```

**Expected output:** `Peak theta = 0 degrees`

---

### TC-04 — rho Axis Symmetric Around Zero

Verifies that `rho(1) == -rho($)` — the rho axis is symmetric.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
mprintf("rho(1)=%d  rho($)=%d\n", rho(1), rho($));
```

**Expected output:** Equal magnitude, opposite sign.

---

### TC-05 — All-Zero Image Gives Zero Accumulator

Verifies that an image with no foreground pixels produces an all-zero accumulator.

```scilab
bw = zeros(50, 50);
[H, theta, rho] = hough(bw);
mprintf("max(H) = %d\n", max(H(:)));
```

**Expected output:** `max(H) = 0`

---

### TC-06 — Total Vote Count

Verifies that the total number of votes equals the number of foreground pixels multiplied by the number of angles.

```scilab
bw = zeros(30, 30);
bw(10, 5) = 1; bw(20, 15) = 1; bw(25, 25) = 1;
[H, theta, rho] = hough(bw);
mprintf("sum(H)=%d  expected=%d\n", sum(H(:)), 3 * length(theta));
```

**Expected output:** Both values equal.

---

### TC-07 — ThetaResolution Property

Verifies that `ThetaResolution = 2` produces a theta vector with half the default number of elements.

```scilab
bw = zeros(20, 20);
bw(10, :) = 1;
[H, theta, rho] = hough(bw, "ThetaResolution", 2);
mprintf("length(theta)=%d  expected=%d\n", length(theta), length(-90:2:88));
```

**Expected output:** Both values equal.

---

### TC-08 — Custom Theta Vector

Verifies that a user-supplied `Theta` vector is passed through to the output unchanged.

```scilab
bw = zeros(20, 20);
bw(10, :) = 1;
custom_theta = -45:5:45;
[H, theta, rho] = hough(bw, "Theta", custom_theta);
disp(isequal(theta, custom_theta))
```

**Expected output:** `%T`

---

### TC-09 — RhoResolution=1 Accepted

Verifies that the only supported `RhoResolution` value is accepted without error.

```scilab
bw = zeros(20, 20);
bw(10, :) = 1;
[H, theta, rho] = hough(bw, "RhoResolution", 1);
mprintf("Accepted without error\n");
```

**Expected output:** No error.

---

### TC-10 — Case-Insensitive Property Names

Verifies that uppercase property names such as `'THETARESOLUTION'` are accepted.

```scilab
bw = zeros(20, 20);
bw(10, :) = 1;
[H, theta, rho] = hough(bw, "THETARESOLUTION", 2);
mprintf("Accepted without error\n");
```

**Expected output:** No error.

---

### TC-11 — RhoResolution != 1 Raises Error

Verifies that any unsupported `RhoResolution` value raises an error.

```scilab
bw = zeros(20, 20);
try
    [H, theta, rho] = hough(bw, "RhoResolution", 2);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-12 — Odd Property Arguments Raises Error

Verifies that an unpaired property name raises an error.

```scilab
bw = zeros(20, 20);
try
    [H, theta, rho] = hough(bw, "ThetaResolution");
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
    [H, theta, rho] = hough(bw, "FakeProperty", 1);
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
    [H, theta, rho] = hough(bw, "ThetaResolution", 200);
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
    [H, theta, rho] = hough(ones(10, 10, 3));
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

## 7. Porting Notes and Challenges

**`nargin` → `argn(2)`:** Scilab uses `argn(2)` to get the input argument count. `nargin` is not available in Scilab.

**`validateattributes`:** No equivalent exists in Scilab. Replaced with explicit `type()` and `ndims()` checks. Scilab type codes: `type(x) <= 8` covers all numeric types; `type(x) == 4` covers boolean. Both are valid inputs for `bw`.

**`logical(bw)`:** Scilab has no `logical()` cast. Replaced with `(bw ~= 0)`, which produces a boolean matrix where any nonzero value becomes `%T`.

**`varargin{idx}` → `varargin(idx)`:** Scilab uses round brackets for all indexing including varargin lists. Curly brace indexing is not valid.

**`switch/case/endswitch` → `select/case/end`:** Scilab uses `select` instead of `switch` and a unified `end` to close the block rather than `endswitch`.

**`tolower(s)` → `convstr(s, "l")`:** Scilab's built-in for converting a string to lowercase. Used to make property name matching case-insensitive.

**`rem(a, b)` → `modulo(a, b)`:** Both compute the remainder but `modulo` is the standard Scilab function name.

**`&&` / `||` → `&` / `|`:** Scilab does not reliably support short-circuit scalar operators. Element-wise `&` and `|` are used throughout and behave correctly for scalar logical expressions inside `if` conditions.

**`hough_line.cc`:** The original Octave function called a compiled C++ MEX-like file for the accumulator loop. No equivalent compiled function exists in Scilab. The accumulator is reimplemented in `hough_line.sci` using standard Scilab functions (`find`, `cos`, `sin`, `round`) and a pixel voting loop.

**`endfor` / `endif` → `end`:** All Octave block terminators replaced with Scilab's unified `end` keyword.