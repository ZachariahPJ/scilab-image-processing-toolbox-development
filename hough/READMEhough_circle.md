# `hough_circle` — Scilab Function Reference

## 1. Description

`hough_circle` computes the circular Hough transform of a binary image, detecting circles of specified radii. For each foreground pixel and each candidate radius, votes are cast into a 3-D accumulator array at all positions where a circle of that radius centred at that pixel would lie. Peaks in the accumulator correspond to circle centres in the image.

Unlike the standard line Hough transform which uses a 2-D `(rho, theta)` parameter space, the circular Hough transform uses a 3-D `(row, col, radius)` space. Each slice `accum(:,:,k)` of the output accumulator holds votes for circles of radius `r(k)`.

The function uses a pre-computed circular filter (`circle_filter`) for each radius — a `(2r+1) × (2r+1)` binary image containing only the perimeter pixels of a circle of radius `r`. This filter is stamped into the accumulator at each foreground pixel position, clipped to the image boundary.

---

## 2. Calling Sequence

```scilab
accum = hough_circle(bw, r)
```

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `bw` | 2-D numeric or boolean matrix | ✓ | Binary input image. Nonzero pixels are treated as foreground and cast votes. |
| `r` | Positive scalar or vector | ✓ | Radius or vector of radii to search for, in pixels. All values must be non-negative real numbers. |
| `accum` | 3-D numeric array | — | **Output.** Hough accumulator of size `[rows, cols, length(r)]`. `accum(:,:,k)` holds votes for circles of radius `r(k)`. High values indicate likely circle centres. |

> **Note:** When only a single radius is supplied, Scilab automatically drops the trailing singleton dimension. `size(accum)` returns `[rows, cols]` rather than `[rows, cols, 1]`. Check dimensions using `size(accum, 1)` and `size(accum, 2)` rather than comparing the full size vector to `[rows, cols, 1]`.

> **Note:** `r` may be a row vector or a column vector — both are accepted.

---

## 4. Finding Circle Centres from the Accumulator

After calling `hough_circle`, find the peak in each radius slice to locate circle centres:

```scilab
// For a single radius
accum = hough_circle(bw, r);
[peak_val, peak_idx] = max(accum(:));
[peak_row, peak_col] = ind2sub(size(accum), peak_idx);

// For multiple radii — find best radius by peak value
r_vec = [8, 10, 12, 15];
accum = hough_circle(bw, r_vec);
slice_peaks = zeros(1, length(r_vec));
for k = 1:length(r_vec)
    slice_peaks(k) = max(max(accum(:,:,k)));
end
[dummy, best_r_idx] = max(slice_peaks);
best_r = r_vec(best_r_idx);

// Find centre within the best slice
best_slice = accum(:,:,best_r_idx);
[peak_val, peak_idx] = max(best_slice(:));
[peak_row, peak_col] = ind2sub(size(best_slice), peak_idx);
mprintf("Circle centre: (%d, %d)  radius: %d\n", peak_row, peak_col, best_r);
```

> **Note:** To find the best radius, always compare the **maximum peak value** across slices, not the total sum. A larger radius filter covers more area and will always have a higher slice sum even for wrong radii. The true radius produces a sharp concentrated peak.

---

## 5. Algorithm

**Step 1 — Build circular filter:** For each radius `r(j)`, a `(2r+1) × (2r+1)` binary matrix is constructed with `1` only at pixels on the perimeter of a circle of radius `r` centred at `(r+1, r+1)`. The interior is zeroed by subtracting a morphological erosion (interior pixels that are fully surrounded by other foreground pixels), replicating the effect of `bwmorph(circ, 'remove')` from Octave.

**Step 2 — Find foreground pixels:** `find(bw)` returns the row and column indices of all nonzero pixels.

**Step 3 — Vote:** For each foreground pixel `(row, col)` and each radius `r(j)`, the circular filter is added into the accumulator slice `accum(:,:,j)` at the region centred on `(row, col)`. Index arithmetic clips the filter to the image boundary so no out-of-bounds access occurs.

---

## 6. Private Helper: `circle_filter`

```scilab
circ = circle_filter(r)
```

Creates a `(2r+1) × (2r+1)` binary image with `1` only on the perimeter of a circle of radius `r` centred at `(r+1, r+1)`.

Renamed from `circle()` (the Octave original) to `circle_filter()` to avoid conflict with Scilab's built-in `circle()` graphics function.

The interior removal replicates `bwmorph(circ, 'remove')` — a pixel is classified as interior if itself and all four axis-aligned neighbours are `1`. Interior pixels are subtracted from the filled disc, leaving only the perimeter ring.

---

## 7. Test Cases

The following 20 test cases cover accumulator dimensions, geometric correctness, input types, edge cases, and error handling. Load the function before running:

```scilab
exec('hough_circle.sci', -1)
```

---

### TC-01 — Accumulator Size for Single Radius

Verifies that the accumulator has the correct number of rows and columns when a single radius is supplied.

```scilab
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, 10);
mprintf("rows=%d cols=%d\n", size(accum,1), size(accum,2));
```

**Expected output:** `rows=50 cols=50`

> Scilab drops trailing singleton dimensions so `size(accum)` returns `[50, 50]` not `[50, 50, 1]`. Check rows and columns individually with `size(accum,1)` and `size(accum,2)`.

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

Verifies that the highest accumulator value in the correct radius slice is within 2 pixels of the true circle centre.

```scilab
cx = 30; cy = 30; r_true = 10;
bw = make_circle_image(60, 60, cx, cy, r_true);
accum = hough_circle(bw, r_true);
accum_slice = accum(:,:,1);
[peak_val, peak_idx] = max(accum_slice(:));
[peak_row, peak_col] = ind2sub(size(accum_slice), peak_idx);
mprintf("Detected centre: (%d,%d)  True centre: (%d,%d)\n", peak_row, peak_col, cy, cx);
```

**Expected output:** `peak_row` within 2 of `cy=30`, `peak_col` within 2 of `cx=30`.

---

### TC-04 — Correct Radius Slice Has Highest Peak

Verifies that the slice for the true radius has the highest peak value across all slices. Uses peak value comparison, not slice sum.

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
mprintf("Best radius detected: %d  True radius: %d\n", r_vec(best_r_idx), r_true);
```

**Expected output:** `Best radius detected: 12`

---

### TC-05 — All-Zero Image Gives Zero Accumulator

Verifies that an image with no foreground pixels produces an all-zero accumulator.

```scilab
bw = zeros(50, 50);
accum = hough_circle(bw, 10);
mprintf("Max accumulator value: %d\n", max(accum(:)));
```

**Expected output:** `0`

---

### TC-06 — Accumulator Values Are Non-Negative

Verifies that no accumulator cell is negative, since votes only add to the accumulator.

```scilab
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, 10);
mprintf("Min accumulator value: %d\n", min(accum(:)));
```

**Expected output:** `0` or greater.

---

### TC-07 — Single Pixel Votes in a Ring Pattern

Verifies that a single foreground pixel casts votes in a ring shape, with at least `pi*r` nonzero accumulator cells.

```scilab
bw = zeros(50, 50);
bw(25, 25) = 1;
r_test = 8;
accum = hough_circle(bw, r_test);
n_votes = sum(accum(:) > 0);
mprintf("Nonzero cells: %d  Expected at least: %d\n", n_votes, round(%pi * r_test));
```

**Expected output:** `n_votes >= round(pi * 8) = 26`

---

### TC-08 — Two Circles Produce Two Peaks

Verifies that two circles at different positions each produce their own peak in the accumulator.

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

**Expected output:** One peak near `(25,25)` and one near `(75,75)` (within 3 pixels).

---

### TC-09 — Small Radius (r=3)

Verifies that a very small radius is handled correctly and the accumulator has the right row and column count.

```scilab
bw = make_circle_image(30, 30, 15, 15, 3);
accum = hough_circle(bw, 3);
mprintf("rows=%d cols=%d\n", size(accum,1), size(accum,2));
```

**Expected output:** `rows=30 cols=30`

---

### TC-10 — Large Radius (r=40)

Verifies that a large radius is handled correctly without error.

```scilab
bw = make_circle_image(100, 100, 50, 50, 40);
accum = hough_circle(bw, 40);
mprintf("rows=%d cols=%d\n", size(accum,1), size(accum,2));
```

**Expected output:** `rows=100 cols=100`

---

### TC-11 — Row Vector Radius Accepted

Verifies that a row vector of radii is accepted without error.

```scilab
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, [8, 10, 12]);
mprintf("Accepted without error\n");
```

**Expected output:** No error.

---

### TC-12 — Column Vector Radius Accepted

Verifies that a column vector of radii is accepted without error.

```scilab
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, [8; 10; 12]);
mprintf("Accepted without error\n");
```

**Expected output:** No error.

---

### TC-13 — Circle Near Image Border

Verifies that a circle whose centre is close to the image border is handled correctly without index errors.

```scilab
bw = make_circle_image(50, 50, 5, 5, 8);
accum = hough_circle(bw, 8);
mprintf("Completed without error\n");
```

**Expected output:** No error.

---

### TC-14 — Double Input Accepted

Verifies that a `double` matrix is accepted as `bw`.

```scilab
bw = double(make_circle_image(50, 50, 25, 25, 10));
accum = hough_circle(bw, 10);
mprintf("Double input accepted\n");
```

**Expected output:** No error.

---

### TC-15 — Boolean Input Accepted

Verifies that a boolean matrix is accepted as `bw`.

```scilab
bw = (make_circle_image(50, 50, 25, 25, 10) ~= 0);
accum = hough_circle(bw, 10);
mprintf("Boolean input accepted\n");
```

**Expected output:** No error.

---

### TC-16 — Missing Radius Raises Error

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

### TC-17 — 3-D Input Raises Error

Verifies that a 3-D matrix raises an error since only 2-D images are supported.

```scilab
try
    bw_3d = ones(10, 10, 3);
    accum = hough_circle(bw_3d, 5);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-18 — Negative Radius Raises Error

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

### TC-19 — Matrix Radius Raises Error

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

---

### TC-20 — Full Circle Gets More Votes Than Partial Arc

Verifies that a complete circle accumulates a higher peak value than a partial arc of the same radius, since more pixels vote for the same centre.

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

mprintf("Full circle peak: %d  Partial arc peak: %d\n", peak_full, peak_arc);
```

**Expected output:** `peak_full > peak_arc`

---

## 8. Porting Notes and Challenges

**`nargin` → `argn(2)`:** Standard replacement.

**`!` → `~`, `||` → `|`:** Scilab logical operators used throughout.

**`any(r < 0)` → `or(r < 0)`:** Scilab has no `any()`. The vector logical check uses `or()`.

**`!ismatrix(bw)` → `ndims(bw) ~= 2`:** Scilab has no `ismatrix`. Since `ismatrix` in Octave returns true for any 2-D array, the equivalent is `ndims(bw) ~= 2`.

**`accum(...) += circ(...)`:** Scilab has no compound assignment operators. Replaced with `accum(...) = accum(...) + circ(...)`.

**`circle()` → `circle_filter()`:** The helper function was renamed to avoid conflict with Scilab's built-in `circle()` graphics function which draws circles on plot axes.

**`bwmorph(circ, 'remove')`:** Scilab has no `bwmorph`. The `'remove'` operation keeps only border pixels — those with at least one background 4-connected neighbour. Implemented manually: a pixel is interior if itself and all four axis-aligned neighbours are `1`. Interior pixels are subtracted from the filled disc leaving the perimeter ring.

**`endfor` / `endif` / `endfunction` → `end` / `endfunction`:** All block terminators replaced with Scilab's unified `end`.

**Trailing singleton dimension:** When `length(r) == 1`, Scilab automatically squeezes the trailing dimension so `zeros(rows, cols, 1)` becomes a `rows × cols` matrix. Tests checking accumulator size must use `size(accum, 1)` and `size(accum, 2)` individually rather than comparing against `[rows, cols, 1]`.

**Radius slice comparison:** To identify the best-matching radius across multiple slices, compare the maximum peak value in each slice — not the total sum. A larger radius filter stamps more pixels into the accumulator, so the slice sum always favours larger radii regardless of whether the radius is correct. The peak value is concentrated at the true circle centre and reliably identifies the correct radius.