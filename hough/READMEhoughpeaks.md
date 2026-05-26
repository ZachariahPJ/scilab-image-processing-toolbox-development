# `houghpeaks` — Scilab Function Reference

## 1. Description

`houghpeaks` identifies the locations of the strongest lines in a Hough accumulator matrix `H` returned by `hough`. Each peak in `H` corresponds to a line in the original image. The function returns the row and column indices of these peaks in `H`, which can then be mapped back to `(rho, theta)` coordinates using the `rho` and `theta` vectors from `hough`.

The algorithm works iteratively. At each step it finds the current maximum in `H`, records it as a peak, then zeros out a neighbourhood around it so that the next iteration finds a genuinely different line. This neighbourhood suppression prevents the same line from being detected multiple times.

The Hough accumulator is anti-symmetric in the theta direction — a line near the edge of the theta axis has a mirror image on the opposite edge. The function accounts for this by also zeroing the mirrored neighbourhood when a peak is found near the theta boundary.

---

## 2. Calling Sequence

```scilab
peaks = houghpeaks(H)
peaks = houghpeaks(H, numpeaks)
peaks = houghpeaks(H, numpeaks, 'Threshold', value)
peaks = houghpeaks(H, numpeaks, 'NHoodSize', [rows, cols])
peaks = houghpeaks(H, numpeaks, 'Threshold', t, 'NHoodSize', [r, c])
```

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `H` | Numeric 2-D matrix | ✓ | Hough accumulator returned by `hough`. Rows correspond to rho, columns to theta. |
| `numpeaks` | Positive integer scalar | — | Maximum number of peaks to return. **Default: 1.** |
| `'Threshold'` | Non-negative scalar | — | Minimum accumulator value for a peak to be accepted. **Default: `0.5 * max(H(:))`.** |
| `'NHoodSize'` | `1×2` vector of positive odd integers | — | Size of the neighbourhood zeroed around each peak. **Default: computed from `size(H)/50`, rounded up to the nearest odd integer, minimum `[3,3]`.** |
| `peaks` | Integer matrix (`P×2`) | — | **Output.** Each row is `[rho_index, theta_index]` — the row and column index into `H` of a detected peak. `P ≤ numpeaks`. |

> **Note:** Property names are case-insensitive. `'threshold'` and `'THRESHOLD'` are both valid.

> **Note:** `peaks` contains indices into `H`, not actual `rho` and `theta` values. To get the angle and distance of a detected line use: `rho(peaks(n,1))` and `theta(peaks(n,2))`.

---

## 4. Algorithm

The peak detection loop runs up to `numpeaks` times:

1. Find `[maxval, maxind] = max(H(:))` — the current strongest cell.
2. If `maxval <= 0` or `maxval < threshold`, stop — no more valid peaks exist.
3. Record `[row, col] = ind2sub(size(H), maxind)` as the next peak.
4. Zero out `H(row±nhoodx, col±nhoody)` so this peak cannot be found again.
5. If the neighbourhood wraps around the theta boundary, also zero the anti-symmetric mirror region.

---

## 5. Test Cases

The following 20 test cases cover default behaviour, property handling, edge inputs, and error conditions. Load the required files before running:

```scilab
exec('hough_line.sci', -1)   // if hough.sci calls hough_line
exec('hough.sci', -1)
exec('houghpeaks.sci', -1)
```

---

### TC-01 — Default Returns One Peak

Verifies that with only `H` supplied, exactly one peak is returned by default.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
disp(size(peaks, 1))
```

**Expected output:** `1`

---

### TC-02 — Peak Output Has Two Columns

Verifies that the output matrix always has exactly two columns `[rho_index, theta_index]`.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
disp(size(peaks, 2))
```

**Expected output:** `2`

---

### TC-03 — Horizontal Line Peak at theta=0

Verifies that a horizontal line in the image produces a peak at the theta index corresponding to `theta = 0`.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
mprintf("Peak theta = %d degrees\n", theta(peaks(1,2)));
```

**Expected output:** `Peak theta = 0 degrees`

---

### TC-04 — numpeaks Limits Output

Verifies that `numpeaks=1` returns only one peak even when two strong lines exist in the image.

```scilab
bw = zeros(101, 101);
bw(25, :) = 1;
bw(75, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
disp(size(peaks, 1))
```

**Expected output:** `1`

---

### TC-05 — Two Lines Give Two Peaks

Verifies that two well-separated horizontal lines each produce their own peak when `numpeaks=2`.

```scilab
bw = zeros(101, 101);
bw(25, :) = 1;
bw(75, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 2);
disp(size(peaks, 1))
```

**Expected output:** `2`

---

### TC-06 — High Threshold Suppresses All Peaks

Verifies that setting `Threshold` higher than the maximum accumulator value returns an empty peak matrix.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 5, "Threshold", 999999);
disp(isempty(peaks))
```

**Expected output:** `%T`

---

### TC-07 — Threshold=0 Allows All Peaks

Verifies that `Threshold=0` does not suppress any valid peak.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1, "Threshold", 0);
disp(size(peaks, 1))
```

**Expected output:** `1`

---

### TC-08 — Large NHoodSize Merges Close Peaks

Verifies that a large neighbourhood suppresses adjacent peaks, causing two very close lines to appear as one.

```scilab
bw = zeros(101, 101);
bw(50, :) = 1;
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 2, "NHoodSize", [51, 51]);
disp(size(peaks, 1))
```

**Expected output:** `1`

---

### TC-09 — Small NHoodSize Keeps Separated Peaks

Verifies that a small neighbourhood allows two well-separated peaks to both be detected.

```scilab
bw = zeros(101, 101);
bw(30, :) = 1;
bw(70, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 2, "NHoodSize", [3, 3]);
disp(size(peaks, 1))
```

**Expected output:** `2`

---

### TC-10 — All-Zero H Returns Empty

Verifies that an all-zero accumulator produces no peaks. When `max(H(:)) == 0` the default threshold is also zero, so the `maxval <= 0` guard must trigger the early exit.

```scilab
H = zeros(100, 180);
peaks = houghpeaks(H, 5);
disp(isempty(peaks))
```

**Expected output:** `%T`

---

### TC-11 — numpeaks Larger Than Available Peaks

Verifies that requesting more peaks than exist returns only as many as are available without error.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 10);
disp(size(peaks, 1) <= 10)
```

**Expected output:** `%T`

---

### TC-12 — Peak Indices Within Bounds of H

Verifies that all returned peak indices are valid row and column indices into `H`.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 3);
[nrho, ntheta] = size(H);
ok = and(peaks(:,1) >= 1) & and(peaks(:,1) <= nrho) & ...
     and(peaks(:,2) >= 1) & and(peaks(:,2) <= ntheta);
disp(ok)
```

**Expected output:** `%T`

---

### TC-13 — Case-Insensitive Property Names

Verifies that uppercase property names such as `'THRESHOLD'` are accepted without error.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1, "THRESHOLD", 0);
mprintf("Accepted without error\n");
```

**Expected output:** No error raised.

---

### TC-14 — Invalid Property Name Raises Error

Verifies that an unrecognised property name raises an error.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
try
    peaks = houghpeaks(H, 1, "FakeProperty", 1);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-15 — Negative Threshold Raises Error

Verifies that a negative `Threshold` value raises an error.

```scilab
H = ones(50, 180);
try
    peaks = houghpeaks(H, 1, "Threshold", -1);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-16 — Non-Integer numpeaks Raises Error

Verifies that a non-integer value for `numpeaks` raises an error.

```scilab
H = ones(50, 180);
try
    peaks = houghpeaks(H, 2.5);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-17 — Zero numpeaks Raises Error

Verifies that `numpeaks = 0` raises an error since at least one peak must be requested.

```scilab
H = ones(50, 180);
try
    peaks = houghpeaks(H, 0);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-18 — Even NHoodSize Raises Error

Verifies that an even `NHoodSize` raises an error since both elements must be odd integers.

```scilab
H = ones(50, 180);
try
    peaks = houghpeaks(H, 1, "NHoodSize", [4, 4]);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-19 — No Arguments Raises Error

Verifies that calling `houghpeaks` with no arguments raises an error.

```scilab
try
    peaks = houghpeaks();
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-20 — No Duplicate Peaks in Output

Verifies that neighbourhood zeroing prevents the same peak from appearing more than once in the output.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 3);
n_peaks = size(peaks, 1);

has_duplicates = %F;
for i = 1:n_peaks
    for j = i+1:n_peaks
        if isequal(peaks(i,:), peaks(j,:)) then
            has_duplicates = %T;
        end
    end
end
disp(has_duplicates)
```

**Expected output:** `%F` — no duplicate rows in the peak matrix.

---

## 6. Porting Notes and Challenges

**`nargin` → `argn(2)`:** Standard replacement throughout.

**`varargin{n}` → `varargin(n)`:** Scilab uses round brackets for all indexing including varargin lists.

**`strcmpi(a, b)` → `convstr(a, "l") == b`:** Scilab has no `strcmpi`. Case-insensitive comparison is done by converting the property string to lowercase with `convstr` before matching.

**`nargin/2 == round(nargin/2)` → `modulo(rhs, 2) == 0`:** The original even/odd check was replaced with the cleaner `modulo` equivalent.

**`nhoodsize += 1` → `nhoodsize = nhoodsize + 1`:** Scilab does not support compound assignment operators like `+=`.

**`isimage(H)` → `type(H) <= 8`:** Scilab has no `isimage`. Replaced with a numeric type code check.

**`isnumeric(x)` → `type(x) <= 8`:** Same pattern as above.

**`any(x)` → `or(x)`:** Scilab has no `any`. The direct equivalent is `or()` for vectors.

**`all(x)` → `and(x)`:** Scilab has no `all`. The direct equivalent is `and()` for vectors.

**`!` → `~`:** Scilab logical NOT operator.

**`||` / `&&` → `|` / `&`:** Scilab does not reliably support short-circuit operators.

**`endif` / `endfor` → `end`:** Scilab uses a unified `end` for all block terminators.

**Zero accumulator edge case:** When `H` is all zeros, the default threshold computes to `0.5 * 0 = 0`. The original `maxval < threshold` check becomes `0 < 0` which is false, so the loop would incorrectly record a peak at `(1,1)`. Fixed by changing the break condition to `maxval <= 0 | maxval < threshold`.