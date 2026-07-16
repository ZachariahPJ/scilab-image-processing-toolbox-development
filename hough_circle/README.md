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

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `bw` | 2-D numeric or boolean matrix | ✓ | Binary input image. Nonzero pixels are treated as foreground and cast votes. |
| `r` | Positive scalar or vector | ✓ | Radius or vector of radii to search for, in pixels. All values must be non-negative real numbers. May be a row or column vector. |
| `accum` | 3-D numeric array | — | **Output.** Hough accumulator of size `[rows, cols, length(r)]`. `accum(:,:,k)` holds votes for circles of radius `r(k)`. High values indicate likely circle centres. |

---

## 5. Test Cases

The following 12 test cases cover accumulator dimensions, geometric correctness, edge inputs, and error handling.

**Note on Octave equivalents:** `circle` is a local/private subfunction defined inside `hough_circle.sci` (or `hough_circle.m` in Octave) — it is only visible within that file, and Octave does not expose it as a standalone callable function the way Scilab does after `exec`-ing the file. For any test case that needs to call `circle` directly (TC-03, TC-04, TC-05), the Octave equivalent requires a **separately defined helper function**, `local_circle`, added to the Octave test script. This helper reconstructs the same mask-building formula used inside the ported subfunction, purely so the test can independently verify vote counts — it is **not** a call into Octave's actual internal circle-building code, since that code isn't reachable from outside the file in either language. Treat any test using `local_circle` as a structural self-consistency check on the Scilab port's own formula, not as direct proof that it matches Octave's real internal implementation byte-for-byte.

---

### TC-01 — Output Dimensions for a Scalar Radius

Verifies that the accumulator array has the correct shape when a single radius is supplied — matching the image size, with a single layer along the third dimension.

```scilab
bw = zeros(20, 20);
bw(10, 10) = 1;
r = 5;
accum = hough_circle(bw, r);
disp(size(accum));
```

**Expected output:**
```scilab
20  20
```

---

### TC-02 — Output Dimensions for a Radius Vector

Verifies that passing multiple radii produces one accumulator layer per radius.

```scilab
bw = zeros(20, 20);
bw(10, 10) = 1;
r = [3 5 7];
accum = hough_circle(bw, r);
disp(size(accum));
```

**Expected output:**
```scilab
20  20  3
```

---

### TC-03 — Single-Point Vote Count Matches the Standalone Circle Mask

Verifies that a single edge point produces exactly as many votes as `circle(r)`'s own outline has pixels — a structural check that doesn't require hand-deriving the exact circle shape, since `circle` is a local subfunction we can call directly once the file is sourced.

```scilab
bw = zeros(21, 21);
bw(11, 11) = 1;
r = 5;
accum = hough_circle(bw, r);
circ_ref = circle(r);
disp(nnz(accum(:,:,1)) == nnz(circ_ref));
```

**Expected output:** `T`

**Octave equivalent:**
```matlab
function circ = local_circle(r)
  circ = zeros(round(2*r + 1), round(2*r + 1));
  col = 1:size(circ, 2);
  for row = 1:size(circ, 1)
    tmp = (row - (r+1)).^2 + (col - (r+1)).^2;
    circ(row, col) = (tmp <= r^2);
  end
  circ = bwmorph(circ, "remove");
end

bw = zeros(21, 21);
bw(11, 11) = 1;
r = 5;
accum = hough_circle(bw, r);
circ_ref = local_circle(r);
disp(nnz(accum(:,:,1)) == nnz(circ_ref));
```

---

### TC-04 — Independent Radius Layers

Verifies that each radius's accumulator layer only reflects votes for its own radius, unaffected by the other radii in the same call.

```scilab
bw = zeros(31, 31);
bw(16, 16) = 1;
r = [4 8];
accum = hough_circle(bw, r);
c4 = circle(4);
c8 = circle(8);
disp(nnz(accum(:,:,1)) == nnz(c4));
disp(nnz(accum(:,:,2)) == nnz(c8));
```

**Expected output:** `T` and `T`

**Octave equivalent:**
```matlab
bw = zeros(31, 31);
bw(16, 16) = 1;
r = [4 8];
accum = hough_circle(bw, r);
c4 = local_circle(4);
c8 = local_circle(8);
disp(nnz(accum(:,:,1)) == nnz(c4));
disp(nnz(accum(:,:,2)) == nnz(c8));
```

---

### TC-05 — Additive Accumulation for Two Non-Overlapping Points

Verifies that two edge points far enough apart (and far enough from the image border) each contribute their full, unclipped vote count, and that the totals simply add rather than interfere.

```scilab
bw = zeros(41, 41);
bw(10, 10) = 1;
bw(30, 30) = 1;
r = 5;
accum = hough_circle(bw, r);
total_votes = sum(accum(:,:,1));
expected_votes = 2 * nnz(circle(5));
disp(total_votes == expected_votes);
```

**Expected output:** `T`

**Octave equivalent:**
```matlab
bw = zeros(41, 41);
bw(10, 10) = 1;
bw(30, 30) = 1;
r = 5;
accum = hough_circle(bw, r);
total_votes = sum(sum(accum(:,:,1)));
expected_votes = 2 * nnz(local_circle(5));
disp(total_votes == expected_votes);
```

---

### TC-06 — Rejecting the Wrong Number of Input Arguments

Verifies that calling the function with only one argument is correctly rejected.

```scilab
bw = zeros(10, 10);
try
    accum = hough_circle(bw);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-07 — Rejecting a Non-2D BW Input

Verifies that a 3-dimensional input array is correctly rejected.

```scilab
bw3d = zeros(5, 5, 2);
try
    accum = hough_circle(bw3d, 3);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-08 — Rejecting a Negative Radius

Verifies that a negative radius value is correctly rejected rather than silently producing an empty or malformed circle.

```scilab
bw = zeros(10, 10);
bw(5, 5) = 1;
try
    accum = hough_circle(bw, -3);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`
