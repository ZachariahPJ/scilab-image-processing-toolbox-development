# `houghpeaks` — Scilab Function Reference

## 1. Description

`houghpeaks` identifies the locations of the strongest lines in a Hough accumulator matrix `H` returned by `hough`. Each peak in `H` corresponds to a line in the original image. The function returns the row and column indices of these peaks in `H`, which can be mapped back to actual `(rho, theta)` coordinates using the vectors returned by `hough`.

The algorithm works iteratively. At each step it finds the current maximum in `H`, records it as a peak, then zeros out a neighbourhood around it so the next iteration finds a genuinely different line. This neighbourhood suppression prevents the same line from being detected multiple times.

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
| `'NHoodSize'` | `1×2` vector of positive odd integers | — | Size of the neighbourhood zeroed around each detected peak. **Default: computed from `size(H)/50`, rounded up to nearest odd integer, minimum `[3,3]`.** |
| `peaks` | Integer matrix (`P×2`) | — | **Output.** Each row is `[rho_index, theta_index]`. `P ≤ numpeaks`. Returns `[]` if no peaks pass the threshold. |

> **Note:** Property names are case-insensitive. `'threshold'` and `'THRESHOLD'` are both valid.

> **Note:** `peaks` contains indices into `H`, not actual `rho` and `theta` values. To retrieve the line parameters use `rho(peaks(n,1))` and `theta(peaks(n,2))`.

---

## 4. How It Works

### 4.1 Argument Detection

The function must distinguish between `houghpeaks(H, numpeaks)` and `houghpeaks(H, 'Threshold', value)`. It does this by checking whether the total input count is even or odd: an even count means `numpeaks` was supplied as the second positional argument; an odd count means the second argument is a property name string.

### 4.2 Peak Detection Loop

The loop runs up to `numpeaks` times:

1. `[maxval, maxind] = max(H(:))` — find the current strongest cell.
2. If `maxval <= 0` or `maxval < threshold` — stop. No more valid peaks exist.
3. `[x0, y0] = ind2sub(size(H), maxind)` — record as the next peak.
4. Zero out `H(x0±nhoodx, y0±nhoody)` so this peak cannot be found again.
5. If the zeroed neighbourhood wraps past the theta boundary, also zero the anti-symmetric mirror region on the opposite side.

### 4.3 Zero Accumulator Guard

When `H` is all zeros, the default threshold is `0.5 * max(H(:)) = 0`. The break condition `maxval < threshold` becomes `0 < 0` which is false, so without a separate guard the loop would incorrectly record a peak at `(1,1)`. The condition is therefore `maxval <= 0 | maxval < threshold`, which correctly exits for all-zero accumulators.

---

## 5. Test Cases

The following 15 test cases cover default behaviour, property handling, geometric correctness, and error conditions. Load the required files before running:

```scilab
exec('hough_line.sci', -1)
exec('hough.sci', -1)
exec('houghpeaks.sci', -1)
```

---

### TC-01 — Default Returns One Peak

Verifies that with only `H` supplied, exactly one `1×2` peak row is returned.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
disp(size(peaks))
```

**Expected output:** `[1, 2]`

---

### TC-02 — Horizontal Line Peak at theta=0

Verifies that a horizontal line produces a peak at the theta index corresponding to `0` degrees.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
mprintf("Peak theta = %d degrees\n", theta(peaks(1,2)));
```

**Expected output:** `Peak theta = 0 degrees`

---

### TC-03 — numpeaks Limits Output

Verifies that `numpeaks=1` returns only one peak even when two strong lines exist.

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

### TC-04 — Two Lines Give Two Peaks

Verifies that two well-separated horizontal lines produce two peaks when `numpeaks=2`.

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

### TC-05 — High Threshold Suppresses All Peaks

Verifies that a threshold above the maximum accumulator value returns empty peaks.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 5, "Threshold", 999999);
disp(isempty(peaks))
```

**Expected output:** `%T`

---

### TC-06 — All-Zero Accumulator Returns Empty

Verifies that an all-zero `H` returns empty peaks. Exercises the `maxval <= 0` guard.

```scilab
H = zeros(100, 180);
peaks = houghpeaks(H, 5);
disp(isempty(peaks))
```

**Expected output:** `%T`

---

### TC-07 — Large NHoodSize Merges Adjacent Peaks

Verifies that a large neighbourhood causes two very close lines to be detected as one peak.

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

### TC-08 — Peak Indices Within H Bounds

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

### TC-09 — No Duplicate Peaks in Output

Verifies that neighbourhood zeroing prevents the same peak from appearing more than once.

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

**Expected output:** `%F`

---

### TC-10 — Case-Insensitive Property Names

Verifies that uppercase property names such as `'THRESHOLD'` are accepted.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1, "THRESHOLD", 0);
mprintf("Accepted without error\n");
```

**Expected output:** No error.

---

### TC-11 — Invalid Property Name Raises Error

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

### TC-12 — Negative Threshold Raises Error

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

### TC-13 — Non-Integer numpeaks Raises Error

Verifies that a non-integer `numpeaks` raises an error.

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

### TC-14 — Even NHoodSize Raises Error

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

### TC-15 — No Arguments Raises Error

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

## 6. Porting Notes and Challenges

**`nargin` → `argn(2)`:** Standard replacement. Scilab uses `argn(2)` for input argument count.

**`varargin{n}` → `varargin(n)`:** Scilab uses round brackets for all indexing including varargin lists. Curly braces are not valid.

**`strcmpi(a, b)` → `convstr(a, "l")`:** Scilab has no `strcmpi`. Property strings are lowercased with `convstr` before matching in a `select` block, making comparisons case-insensitive.

**`nargin/2 == round(nargin/2)` → `modulo(rhs, 2) == 0`:** The even/odd check for detecting whether `numpeaks` was supplied was replaced with the cleaner `modulo` equivalent.

**`nhoodsize += 1` → `nhoodsize = nhoodsize + 1`:** Scilab does not support compound assignment operators.

**`isimage(H)` / `isnumeric(x)` → `type(x) <= 8`:** Neither function exists in Scilab. All validation checks use Scilab type codes where values 1–8 cover all numeric types.

**`any(x)` → `or(x)`:** Scilab has no `any`. The direct equivalent for vectors is `or()`.

**`all(x)` → `and(x)`:** Scilab has no `all`. The direct equivalent for vectors is `and()`.

**`!` → `~`, `||` / `&&` → `|` / `&`:** All logical operators replaced with Scilab equivalents. Short-circuit operators are not reliable in Scilab.

**`endif` / `endfor` → `end`:** Scilab uses a unified `end` for all block terminators.

**Zero accumulator edge case:** When `H` is all zeros, the default threshold is `0.5 * 0 = 0`. The original break condition `maxval < threshold` becomes `0 < 0` which is false, so the loop would incorrectly record a peak at `(1,1)`. Fixed by changing the condition to `maxval <= 0 | maxval < threshold`, which correctly exits when the accumulator has no positive values.