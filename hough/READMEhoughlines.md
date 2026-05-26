# `houghlines` — Scilab Function Reference

## 1. Description

`houghlines` extracts line segments from a binary image using the peaks detected by `houghpeaks` in the Hough accumulator. It is the final step in the standard Hough transform pipeline:

```
hough       →   houghpeaks   →   houghlines
(accumulate)    (find peaks)     (extract segments)
```

For each peak in the accumulator, the function identifies all foreground pixels in the image that are consistent with the corresponding `(rho, theta)` line. It then orders those pixels along the dominant axis, splits them into segments at gaps wider than `FillGap`, and returns only segments longer than `MinLength`.

Each returned line segment is a struct with four fields: the coordinates of its two endpoints, and the `(theta, rho)` of the Hough line it belongs to.

---

## 2. Calling Sequence

```scilab
lines = houghlines(BW, theta, rho, peaks)
lines = houghlines(BW, theta, rho, peaks, 'FillGap', value)
lines = houghlines(BW, theta, rho, peaks, 'MinLength', value)
lines = houghlines(BW, theta, rho, peaks, 'FillGap', f, 'MinLength', m)
```

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `BW` | 2-D numeric or boolean matrix | ✓ | Binary input image. Must be the same image used to compute `H` with `hough`. |
| `theta` | Numeric vector | ✓ | Theta axis in degrees, returned by `hough`. |
| `rho` | Numeric vector | ✓ | Rho axis in pixels, returned by `hough`. |
| `peaks` | `P×2` integer matrix | ✓ | Peak indices returned by `houghpeaks`. Each row is `[rho_idx, theta_idx]`. |
| `'FillGap'` | Positive scalar | — | Maximum gap in pixels between two segments to be merged into one. **Default: 20.** |
| `'MinLength'` | Positive scalar | — | Minimum Euclidean length in pixels for a segment to be kept. **Default: 40.** |
| `lines` | Struct array | — | **Output.** Each element has fields `point1`, `point2`, `theta`, `rho`. Returns empty struct if no segments qualify. |

> **Note:** The total number of input arguments must be 4, 6, or 8. Passing 5 or 7 arguments (an unpaired property name) raises an error.

> **Note:** Property names are case-insensitive. `'fillgap'` and `'FILLGAP'` are both valid.

---

## 4. Output Struct Fields

Each element of the returned `lines` struct array has these four fields:

| Field | Type | Description |
| :--- | :--- | :--- |
| `point1` | `1×2` vector `[x, y]` | Start point of the segment in 1-based image coordinates. |
| `point2` | `1×2` vector `[x, y]` | End point of the segment in 1-based image coordinates. |
| `theta` | Scalar (degrees) | Angle of the Hough line this segment belongs to, in degrees. |
| `rho` | Scalar (pixels) | Distance from the origin of the Hough line this segment belongs to. |

---

## 5. Algorithm

For each peak `(rho_p, theta_p)`:

**Step 1 — Angle conversion:** `theta_p` is converted from the MATLAB/Octave degree convention to the internal radian convention used when building `H` in `hough.sci`:
```
theta_oct = (-theta_p + 90) * (pi / 180)
```
This conversion must match exactly what `hough` used, otherwise the rho values computed here will not align with the accumulator and no pixels will be matched.

**Step 2 — Pixel matching:** The rho value every foreground pixel would have at `theta_oct` is computed as:
```
rho = x * cos(theta_oct) + y * sin(theta_oct)
```
where `x = col - 1` and `y = row - 1` are 0-based coordinates. Pixels whose rounded rho index matches `rho_p_idx` are considered to lie on this line.

**Step 3 — Ordering:** Matched pixels are sorted along the dominant axis (the one with the larger coordinate span) to ensure consecutive pixels in the list are spatially adjacent.

**Step 4 — Gap detection:** The Euclidean distance between consecutive ordered pixels is computed. Any gap larger than `FillGap` splits the pixel sequence into separate segments.

**Step 5 — Length filtering:** Only segments whose straight-line distance from first to last pixel is at least `MinLength` are kept and added to the output.

---

## 6. Test Cases

The following 20 test cases cover struct output, geometric correctness, parameter effects, edge inputs, and error handling. Load all required files before running:

```scilab
exec('hough.sci', -1)
exec('houghpeaks.sci', -1)
exec('houghlines.sci', -1)
```

---

### TC-01 — Output Struct Has Correct Fields

Verifies that each element of the returned struct has the four required fields.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
disp(fieldnames(lines(1)))
```

**Expected output:** A list containing `"point1"`, `"point2"`, `"theta"`, `"rho"`.

---

### TC-02 — Long Horizontal Line Detected

Verifies that a full-width horizontal line produces at least one segment.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
mprintf("Segments found: %d\n", length(lines));
```

**Expected output:** At least `1` segment.

---

### TC-03 — theta Field Matches Peak Angle

Verifies that the `theta` stored in each line struct matches the theta value at the detected peak index.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
mprintf("lines.theta=%f  theta(peak)=%f\n", lines(1).theta, theta(peaks(1,2)));
```

**Expected output:** Both values are equal.

---

### TC-04 — rho Field Matches Peak Distance

Verifies that the `rho` stored in each line struct matches the rho value at the detected peak index.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
mprintf("lines.rho=%f  rho(peak)=%f\n", lines(1).rho, rho(peaks(1,1)));
```

**Expected output:** Both values are equal.

---

### TC-05 — point1 and point2 Are 1×2 Vectors

Verifies that both endpoint fields are `1×2` coordinate vectors `[x, y]`.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
disp(size(lines(1).point1))
disp(size(lines(1).point2))
```

**Expected output:** `[1, 2]` for both.

---

### TC-06 — Segment Below MinLength Not Returned

Verifies that a short segment is excluded when `MinLength` is set higher than the segment length.

```scilab
bw = zeros(50, 50);
bw(25, 20:25) = 1;   // 6-pixel segment
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 100);
mprintf("Segments found: %d\n", length(lines));
```

**Expected output:** `0`

---

### TC-07 — FillGap Merges Close Segments

Verifies that a larger `FillGap` merges segments separated by a small gap, while a smaller value keeps them separate.

```scilab
bw = zeros(101, 101);
bw(51, 1:40)   = 1;
bw(51, 45:101) = 1;   // 4-pixel gap between col 40 and 45
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines_merged = houghlines(bw, theta, rho, peaks, "FillGap", 10, "MinLength", 10);
lines_split  = houghlines(bw, theta, rho, peaks, "FillGap", 2,  "MinLength", 10);
mprintf("Merged: %d  Split: %d\n", length(lines_merged), length(lines_split));
```

**Expected output:** `lines_merged` has fewer or equal segments than `lines_split`.

---

### TC-08 — Two Lines Produce Two Segment Sets

Verifies that two horizontal lines each contribute at least one segment.

```scilab
bw = zeros(101, 101);
bw(25, :) = 1;
bw(75, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 2);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
mprintf("Segments found: %d\n", length(lines));
```

**Expected output:** At least `2` segments.

---

### TC-09 — All-Zero Image Returns No Lines

Verifies that an image with no foreground pixels produces an empty output.

```scilab
bw = zeros(50, 50);
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
mprintf("Segments found: %d\n", length(lines));
```

**Expected output:** `0`

---

### TC-10 — Default Parameters Applied Without Error

Verifies that calling with only the four required arguments uses `FillGap=20` and `MinLength=40` without error.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks);
mprintf("Completed without error\n");
```

**Expected output:** No error.

---

### TC-11 — Case-Insensitive Property Names

Verifies that uppercase property names are accepted.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FILLGAP", 5, "MINLENGTH", 10);
mprintf("Uppercase properties accepted\n");
```

**Expected output:** No error.

---

### TC-12 — Invalid Property Name Raises Error

Verifies that an unrecognised property name raises an error.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
try
    lines = houghlines(bw, theta, rho, peaks, "FakeProperty", 5);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-13 — Negative FillGap Raises Error

Verifies that a non-positive `FillGap` value raises an error.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
try
    lines = houghlines(bw, theta, rho, peaks, "FillGap", -5);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-14 — Negative MinLength Raises Error

Verifies that a non-positive `MinLength` value raises an error.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
try
    lines = houghlines(bw, theta, rho, peaks, "MinLength", -10);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-15 — Too Few Arguments Raises Error

Verifies that fewer than 4 arguments raises an error.

```scilab
try
    lines = houghlines(ones(10,10), -90:89);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-16 — Odd Property Argument Count Raises Error

Verifies that passing 5 total arguments (one unpaired property name) raises an error.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
try
    lines = houghlines(bw, theta, rho, peaks, "FillGap");
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-17 — Non-Numeric BW Raises Error

Verifies that passing a string as `BW` raises an error.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
try
    lines = houghlines("hello", theta, rho, peaks);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-18 — Wrong Peaks Dimensions Raises Error

Verifies that a peaks matrix with the wrong number of columns raises an error.

```scilab
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
try
    bad_peaks = [1, 2, 3];
    lines = houghlines(bw, theta, rho, bad_peaks);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-19 — Segment Endpoints Within Image Bounds

Verifies that all `point1` and `point2` coordinates lie within the dimensions of the input image.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
[nrows, ncols] = size(bw);
all_in_bounds = %T;
if length(lines) == 0 then
    all_in_bounds = %F;
else
    for k = 1:length(lines)
        p1 = lines(k).point1;
        p2 = lines(k).point2;
        if p1(1)<1 | p1(1)>ncols | p1(2)<1 | p1(2)>nrows then
            all_in_bounds = %F;
        end
        if p2(1)<1 | p2(1)>ncols | p2(2)<1 | p2(2)>nrows then
            all_in_bounds = %F;
        end
    end
end
disp(all_in_bounds)
```

**Expected output:** `%T`

---

### TC-20 — All Returned Segments Meet MinLength

Verifies that every returned segment has a Euclidean length of at least `MinLength`.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
min_len = 10;
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", min_len);
all_long_enough = %T;
if length(lines) == 0 then
    all_long_enough = %F;
else
    for k = 1:length(lines)
        seg_len = sqrt(sum((lines(k).point2 - lines(k).point1).^2));
        if seg_len < min_len then
            all_long_enough = %F;
        end
    end
end
disp(all_long_enough)
```

**Expected output:** `%T`

---

## 7. Porting Notes and Challenges

**`nargin` → `argn(2)`:** Standard replacement throughout.

**`varargin{n}` → `varargin(n)`:** Scilab uses round brackets for all indexing including varargin lists.

**`strcmpi` → `convstr(..., "l")`:** No `strcmpi` in Scilab. Property strings are lowercased before matching in a `select` block.

**`isimage` / `isnumeric` → `type() <= 8`:** Neither function exists in Scilab. All validation checks use the numeric type code instead.

**`!` → `~`, `||` → `|`, `&&` → `&`, `!=` → `~=`:** All logical operators replaced with Scilab equivalents.

**`struct([])` → `struct()`:** Octave initialises an empty struct with `struct([])`. In Scilab, `struct()` is used. Cell array syntax `{}` inside struct initialisation is not supported and causes a `%ce_1_s` overloading error.

**`numlines += 1` → `numlines = numlines + 1`:** Scilab does not support compound assignment operators.

**`rho(end)` → `rho($)`:** Scilab uses `$` as the end-of-array operator.

**`cosd(theta_p)` → `cos(theta_oct_p)` with angle conversion:** This was the most significant porting bug. The Octave original uses `cosd`/`sind` with the degree value of `theta_p` directly. However, `hough.sci` builds the accumulator using the converted angle `theta_oct = (-theta + 90) * pi/180`. The pixel matching formula in `houghlines` must use the exact same converted angle, otherwise the computed rho values never align with the accumulator indices and no pixels are matched. The fix is:
```scilab
theta_oct_p = (-theta_p + 90) * (%pi / 180);
rho_all = allpixels_x .* cos(theta_oct_p) + allpixels_y .* sin(theta_oct_p);
```

**Pixel sort and reorder bug:** The original port built the sort matrix as `[y, x]`, then tried to swap columns back to `[x, y]` after sorting. For a horizontal line where all `y` values are identical, `sortrows` collapsed 101 rows down to 1 unique row, making the segment appear to have zero length. The fix builds the sort matrix directly as `[x, y]` and sorts on the correct column index, avoiding the swap entirely:
```scilab
peak_pixels_sorted = sortrows([peak_pixels_x(:), peak_pixels_y(:)], [1, 2]);
peak_pixels = peak_pixels_sorted;
```

**`endif` / `endfor` → `end`:** All block terminators unified to Scilab's `end`.