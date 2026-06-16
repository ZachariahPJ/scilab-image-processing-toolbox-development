# `hough_circle` — Scilab Function Reference

## 1. Description

`hough_circle` computes the circular Hough transform of a binary image, detecting circles of specified radii. For each foreground pixel and each candidate radius, votes are cast into a 3-D accumulator array at all positions where a circle of that radius centred at that pixel would lie. Peaks in the accumulator correspond to circle centres in the image.

Unlike the straight-line Hough transform which uses a 2-D `(rho, theta)` parameter space, the circular Hough transform uses a 3-D `(row, col, radius)` space. Each slice `accum(:,:,k)` of the output accumulator holds votes for circles of radius `r(k)`.

The function uses a pre-computed circular filter (`circle`) for each radius — a `(2r+1) × (2r+1)` binary image containing only the perimeter pixels of a circle of radius `r`. This filter is stamped into the accumulator at each foreground pixel position, clipped to the image boundary so no out-of-bounds access occurs.

---

## 2. Calling Sequence

```scilab
accum = hough_circle(bw, r)
```

---

## 3. Dependencies

Requires the `bwmorph` function.

---

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `bw` | 2-D numeric or boolean matrix | ✓ | Binary input image. Nonzero pixels are treated as foreground and cast votes. |
| `r` | Positive scalar or vector | ✓ | Radius or vector of radii to search for, in pixels. All values must be non-negative real numbers. May be a row or column vector. |
| `accum` | 3-D numeric array | — | **Output.** Hough accumulator of size `[rows, cols, length(r)]`. `accum(:,:,k)` holds votes for circles of radius `r(k)`. High values indicate likely circle centres. |

---

## 5. Test Cases

The following 12 test cases cover accumulator dimensions, geometric correctness, edge inputs, and error handling. Load the function before running:

```scilab
exec('hough_circle.sci', -1)
```

---

### TC-01 — Accumulator Size for Single Radius

Verifies that the accumulator has the correct row and column count for a single radius. Scilab drops trailing singleton dimensions so the check uses `size(accum,1)` and `size(accum,2)` individually.

```scilab
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, 10);
mprintf("rows=%d  cols=%d\n", size(accum,1), size(accum,2));
```

**Expected output:** `rows=50  cols=50`

---

### TC-02 — Accumulator Size for Multiple Radii

Verifies that the accumulator has the correct 3-D size when multiple radii are supplied.

```scilab
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, [5, 10, 15]);
disp(size(accum))
```

**Expected output:** `[50, 50, 3]`

---

### TC-03 — Peak Near True Circle Centre

Verifies that the highest accumulator value in the radius slice is within 2 pixels of the true circle centre.

```scilab
cx = 30; cy = 30; r_true = 10;
bw = make_circle_image(60, 60, cx, cy, r_true);
accum = hough_circle(bw, r_true);
accum_slice = accum(:,:,1);
[peak_val, peak_idx] = max(accum_slice(:));
[peak_row, peak_col] = ind2sub(size(accum_slice), peak_idx);
mprintf("Detected: (%d,%d)  True: (%d,%d)\n", peak_row, peak_col, cy, cx);
```

**Expected output:** `peak_row` within 2 of `cy=30`, `peak_col` within 2 of `cx=30`.

---

### TC-04 — Correct Radius Slice Has Highest Peak

Verifies that when searching over multiple radii, the slice for the true radius has the highest peak value.

```scilab
cx = 25; cy = 25; r_true = 12;
bw = make_circle_image(50, 50, cx, cy, r_true);
r_vec = [8, 12, 16];
accum = hough_circle(bw, r_vec);
slice_peaks = zeros(1, 3);
for k = 1:3
    slice_peaks(k) = max(max(accum(:,:,k)));
end
[dummy, best_r_idx] = max(slice_peaks);
mprintf("Best radius: %d  True radius: %d\n", r_vec(best_r_idx), r_true);
```

**Expected output:** `Best radius: 12`

---

### TC-05 — All-Zero Image Gives Zero Accumulator

Verifies that an image with no foreground pixels produces an all-zero accumulator.

```scilab
bw = zeros(50, 50);
accum = hough_circle(bw, 10);
mprintf("max(accum) = %d\n", max(accum(:)));
```

**Expected output:** `max(accum) = 0`

---

### TC-06 — Two Circles Produce Two Distinct Peaks

Verifies that two circles at well-separated positions each produce their own peak.

```scilab
bw = zeros(100, 100);
bw = bw + make_circle_image(100, 100, 25, 25, 10);
bw = bw + make_circle_image(100, 100, 75, 75, 10);
bw = (bw > 0);
accum = hough_circle(bw, 10);
accum_copy = accum(:,:,1);
[v1, idx1] = max(accum_copy(:));
[r1, c1] = ind2sub(size(accum_copy), idx1);
accum_copy(max(r1-12,1):min(r1+12,100), max(c1-12,1):min(c1+12,100)) = 0;
[v2, idx2] = max(accum_copy(:));
[r2, c2] = ind2sub(size(accum_copy), idx2);
mprintf("Peak 1: (%d,%d)  Peak 2: (%d,%d)\n", r1, c1, r2, c2);
```

**Expected output:** One peak near `(25,25)` and one near `(75,75)`, both within 3 pixels.

---

### TC-07 — Full Circle Gets More Votes Than Partial Arc

Verifies that a complete circle accumulates a higher peak value than a half-arc of the same radius.

```scilab
bw_full = make_circle_image(60, 60, 30, 30, 12);
accum_full = hough_circle(bw_full, 12);
[peak_full, dummy] = max(accum_full(:));
bw_arc = zeros(60, 60);
for angle_deg = 0:1:179
    x = round(30 + 12 * cosd(angle_deg));
    y = round(30 + 12 * sind(angle_deg));
    if x >= 1 & x <= 60 & y >= 1 & y <= 60 then
        bw_arc(y, x) = 1;
    end
end
accum_arc = hough_circle(bw_arc, 12);
[peak_arc, dummy] = max(accum_arc(:));
mprintf("Full: %d  Arc: %d\n", peak_full, peak_arc);
```

**Expected output:** `peak_full > peak_arc`

---

### TC-08 — Circle Near Image Border Handled Without Error

Verifies that clipping works correctly when the circle centre is close to the image boundary.

```scilab
bw = make_circle_image(50, 50, 5, 5, 8);
accum = hough_circle(bw, 8);
mprintf("Completed without error\n");
```

**Expected output:** No error.

---

### TC-09 — Missing Radius Raises Error

Verifies that calling with only one argument raises an error.

```scilab
try
    accum = hough_circle(zeros(50,50));
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-10 — 3-D Input Raises Error

Verifies that a 3-D matrix raises an error since only 2-D images are supported.

```scilab
try
    accum = hough_circle(ones(10,10,3), 5);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-11 — Negative Radius Raises Error

Verifies that a negative radius value raises an error.

```scilab
try
    accum = hough_circle(zeros(50,50), -5);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-12 — Matrix Radius Raises Error

Verifies that a 2-D matrix passed as `r` raises an error since only scalars and vectors are accepted.

```scilab
try
    accum = hough_circle(zeros(50,50), [5,10; 15,20]);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`
