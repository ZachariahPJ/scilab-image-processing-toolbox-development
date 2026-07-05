# `houghlines` — Scilab Function Reference

## 1. Description

`houghlines` extracts line segments from a binary image using the peaks detected by `houghpeaks` in the Hough accumulator. It is the final step in the standard Hough transform pipeline:

```
hough       →   houghpeaks   →   houghlines
(accumulate)    (find peaks)     (extract segments)
```

For each peak in the accumulator, the function identifies all foreground pixels in the image that are consistent with the corresponding `(rho, theta)` line. It orders those pixels along the dominant axis, splits them into segments at gaps wider than `FillGap`, and returns only segments longer than `MinLength`.

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

## 3. Dependencies
Requires the `isimage`, `isnumeric`, `hough`, `hough_line` and `houghpeaks` function.

---

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `BW` | 2-D numeric or boolean matrix | ✓ | Binary input image. Must be the same image used to compute `H` with `hough`. |
| `theta` | Numeric vector (degrees) | ✓ | Theta axis returned by `hough`. |
| `rho` | Numeric vector (pixels) | ✓ | Rho axis returned by `hough`. |
| `peaks` | `P×2` integer matrix | ✓ | Peak indices returned by `houghpeaks`. Each row is `[rho_idx, theta_idx]`. |
| `'FillGap'` | Positive scalar | — | Maximum gap in pixels between two segments to be merged into one. **Default: 20.** |
| `'MinLength'` | Positive scalar | — | Minimum Euclidean length in pixels for a segment to be kept. **Default: 40.** |
| `lines` | Struct array | — | **Output.** Each element has fields `point1`, `point2`, `theta`, `rho`. Returns empty struct if no segments qualify. |

> **Note:** The total number of input arguments must be 4, 6, or 8. Passing 5 or 7 arguments raises an error because property names and values must always come in pairs.

---

## 5. Test Cases

The following 16 test cases cover geometric correctness, struct output, parameter effects, and error handling. Load all required files before running:

```scilab
exec('hough_line.sci', -1)
exec('hough.sci', -1)
exec('houghpeaks.sci', -1)
exec('houghlines.sci', -1)
```

---

### TC-01 — Horizontal Line Detected

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

### TC-02 — Output Struct Has Correct Fields

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

### TC-03 — theta Field Matches Peak Angle

Verifies that `lines(1).theta` equals the theta value at the detected peak index.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
mprintf("lines.theta=%f  theta(peak)=%f\n", lines(1).theta, theta(peaks(1,2)));
```

**Expected output:** Both values equal.

---

### TC-04 — rho Field Matches Peak Distance

Verifies that `lines(1).rho` equals the rho value at the detected peak index.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
mprintf("lines.rho=%f  rho(peak)=%f\n", lines(1).rho, rho(peaks(1,1)));
```

**Expected output:** Both values equal.

---

### TC-05 — Segment Below MinLength Not Returned

Verifies that a short pixel group is excluded when `MinLength` is set above its length.

```scilab
bw = zeros(50, 50);
bw(25, 20:25) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 100);
mprintf("Segments found: %d\n", length(lines));
```

**Expected output:** `0`

---

### TC-06 — All Returned Segments Meet MinLength

Verifies that every returned segment has Euclidean length at least `MinLength`.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
min_len = 10;
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", min_len);
all_ok = %T;
for k = 1:length(lines)
    if sqrt(sum((lines(k).point2 - lines(k).point1).^2)) < min_len then
        all_ok = %F;
    end
end
disp(all_ok)
```

**Expected output:** `%T`

---

### TC-07 — FillGap Merges Close Segments

Verifies that a larger `FillGap` produces fewer or equal segments than a smaller one for the same image.

```scilab
bw = zeros(101, 101);
bw(51, 1:40)   = 1;
bw(51, 45:101) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines_merged = houghlines(bw, theta, rho, peaks, "FillGap", 10, "MinLength", 10);
lines_split  = houghlines(bw, theta, rho, peaks, "FillGap", 2,  "MinLength", 10);
mprintf("Merged: %d  Split: %d\n", length(lines_merged), length(lines_split));
```

**Expected output:** `lines_merged` count ≤ `lines_split` count.

---

### TC-08 — Two Lines Produce Two Segments

Verifies that two horizontal lines each produce at least one segment.

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

### TC-10 — Segment Endpoints Within Image Bounds

Verifies that all `point1` and `point2` coordinates lie within the image dimensions.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
[nrows, ncols] = size(bw);
all_ok = %T;
for k = 1:length(lines)
    p1 = lines(k).point1; p2 = lines(k).point2;
    if p1(1)<1 | p1(1)>ncols | p1(2)<1 | p1(2)>nrows then all_ok = %F; end
    if p2(1)<1 | p2(1)>ncols | p2(2)<1 | p2(2)>nrows then all_ok = %F; end
end
disp(all_ok)
```

**Expected output:** `%T`

---

### TC-11 — Default Parameters Applied Without Error

Verifies that calling with only 4 arguments uses `FillGap=20` and `MinLength=40` without error.

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

### TC-12 — Case-Insensitive Property Names

Verifies that uppercase property names such as `'FILLGAP'` are accepted.

```scilab
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FILLGAP", 5, "MINLENGTH", 10);
mprintf("Accepted without error\n");
```

**Expected output:** No error.

---

### TC-13 — Invalid Property Name Raises Error

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

### TC-14 — Negative FillGap Raises Error

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

### TC-16 — Unpaired Property Argument Raises Error

Verifies that 5 total arguments (one unpaired property name) raises an error.

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