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

## 3. Dependencies
Requires the `isimage`, `isnumeric`, `hough` and `hough_line` function.

---

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `H` | Numeric 2-D matrix | ✓ | Hough accumulator returned by `hough`. Rows correspond to rho, columns to theta. |
| `numpeaks` | Positive integer scalar | — | Maximum number of peaks to return. **Default: 1.** |
| `'Threshold'` | Non-negative scalar | — | Minimum accumulator value for a peak to be accepted. **Default: `0.5 * max(H(:))`.** |
| `'NHoodSize'` | `1×2` vector of positive odd integers | — | Size of the neighbourhood zeroed around each detected peak. **Default: computed from `size(H)/50`, rounded up to nearest odd integer, minimum `[3,3]`.** |
| `peaks` | Integer matrix (`P×2`) | — | **Output.** Each row is `[rho_index, theta_index]`. `P ≤ numpeaks`. Returns `[]` if no peaks pass the threshold. |

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

### TC-02 — Horizontal Line Peak at theta=-90

Verifies that a horizontal line produces a peak at the theta index corresponding to `-90` degrees.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
mprintf("Peak theta = %d degrees\n", theta(peaks(1,2)));
```

**Expected output:** `Peak theta = -90 degrees`

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

### TC-06 — All-Zero Accumulator Returns Initial Index Grid

Verifies that an all-zero H falls back onto the lowest un-suppressed memory layout index, returning a repeating grid of `[1,1]` coordinates rather than an empty matrix.

```scilab
H = zeros(100, 180);
peaks = houghpeaks(H, 5);
expected_peaks = ones(5, 2);
disp(isequal(peaks, expected_peaks))
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

Verifies that neighborhood zeroing prevents the same peak coordinate from appearing more than once when multiple unique lines exist in the image image.

```scilab
bw = zeros(101, 101);
bw(25, :) = 1;
bw(51, :) = 1;
bw(75, :) = 1;
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