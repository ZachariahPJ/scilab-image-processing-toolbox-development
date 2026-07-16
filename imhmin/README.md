# `imhmin` — Scilab Function Reference

## 1. Description

`imhmin` applies the $H$-minima transform to an image, suppressing all local minima (valleys/basins) whose depth is less than or equal to a specified threshold value $h$.

This function serves as a direct port of Octave's native image processing toolbox. By leveling low-amplitude intensity depressions and regional texture noise while preserving significant structural basins, it serves as a critical morphological filter to eliminate over-segmentation hazards prior to running watershed algorithms.

---

## 2. Calling Sequence

```scilab
im2 = imhmin(im, h)
im2 = imhmin(im, h, conn)
```

---

## 3. Dependencies

Requires the `class`, `conndef`, `connectivity`, `imcomplement`, `imreconstruct`, `intmax`, `intmin`, `iptcheckconn` and `isnumeric` functions.

---

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `im` | Matrix | Yes | The input source grayscale intensity matrix or integer array (`uint8`, `uint16`). |
| `h` | Scalar | Yes | The non-negative real depth threshold value used to fill local valleys. |
| `conn` | Scalar/Matrix | No | Neighborhood connectivity configuration profile. Accepts standard neighborhood structures or shorthand scalars (`4` or `8`). Default: Maximal neighborhood generated via `conndef`. |
| `im2` | Matrix | — | Output. The transformation result matrix matching the exact class size and data type of the input image `im`. |
---

## 5. Test Cases

### TC-01 — Partial Valley Filling

Verifies that when a local valley's depth is less than the threshold $h$, it is raised by exactly $h$, without disturbing the surrounding topology.

```scilab
img_valley = [40, 40, 40, 40, 40;
              40, 25, 10, 25, 40;
              40, 40, 40, 40, 40];

res = imhmin(img_valley, 10);
disp(res);
```

**Expected output:**
```scilab
40.  40.  40.  40.  40.
40.  25.  20.  25.  40.
40.  40.  40.  40.  40.
```

---

### TC-02 — Complete Valley Absorption

Verifies that when $h$ exceeds the contrast between the valley and its immediate surrounding ring, the entire interior is flattened uniformly to `background - h`.

```scilab
img_valley = [40, 40, 40, 40, 40;
              40, 25, 10, 25, 40;
              40, 40, 40, 40, 40];

res = imhmin(img_valley, 20);
disp(res);
```

**Expected output:**
```scilab
40.  40.  40.  40.  40.
40.  30.  30.  30.  40.
40.  40.  40.  40.  40.
```

---

### TC-03 — Boundary Identity Check ($h = 0$)

Verifies that setting the threshold to exactly zero results in no structural alteration.

```scilab
img_valley = [40, 40, 40, 40, 40;
              40, 25, 10, 25, 40;
              40, 40, 40, 40, 40];

res = imhmin(img_valley, 0);
disp(and(res == img_valley));
```

**Expected output:**
```scilab
T
```

---

### TC-04 — Integer Class Preservation

Verifies that an integer-class (`uint8`) input produces a `uint8` output, not a plain double.

```scilab
img_valley_u8 = uint8([40, 40, 40, 40, 40;
                       40, 25, 10, 25, 40;
                       40, 40, 40, 40, 40]);

res = imhmin(img_valley_u8, 10);
disp(res);
disp(type(res));
```

**Expected output(`res`):**
```scilab
40.  40.  40.  40.  40.
40.  25.  20.  25.  40.
40.  40.  40.  40.  40.
```

**Expected output(`type(res)`):** `8`

---

### TC-05 — Rejecting an Invalid CONN Argument

Verifies that a scalar connectivity value outside the valid set `{4, 6, 8, 18, 26}` is correctly rejected.

```scilab
img_valley = [40, 40, 40, 40, 40;
              40, 25, 10, 25, 40;
              40, 40, 40, 40, 40];

try
    res = imhmin(img_valley, 10, 5);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-06 — Duality Self-Consistency Check

Verifies the implementation's internal consistency against its own defining relationship: `imhmin(im,h)` must equal `imcomplement(imhmax(imcomplement(im),h))`, regardless of the specific shape used. This is a stronger check than a hand-picked expected output, since it holds by mathematical definition rather than by manual derivation.

```scilab
img_valley = [40, 40, 40, 40, 40;
              40, 25, 10, 25, 40;
              40, 40, 40, 40, 40];

res1 = imhmin(img_valley, 10);
res2 = imcomplement(imhmax(imcomplement(img_valley), 10));

disp(and(res1 == res2));
```

**Expected output:** `T`

---

### TC-07 — Saturating Arithmetic Regression Check (`uint8`)

Verifies the specific fix made to `imhmin`'s internal arithmetic: an image with a high-valued region surrounded by a low background can push the *complemented* image's marker below zero internally. Native `uint8` saturation must clamp this correctly rather than wrapping or going negative in double space.

```scilab
img_sat = uint8([5,   5,   5;
                 5, 250,   5;
                 5,   5,   5]);

res = imhmin(img_sat, 10);
disp(res);
```

**Expected output:**
```scilab
15.  15.  15.
15. 250.  15.
15.  15.  15.
```

---

### TC-08 — Explicit Connectivity Matrix Accepted

Verifies that passing an explicit `3×3` connectivity matrix (rather than a scalar code) is accepted and produces the same result as its scalar equivalent, confirming the matrix-form `CONN` path is correctly wired through to `imreconstruct`.

```scilab
img_valley = [40, 40, 40, 40, 40;
              40, 25, 10, 25, 40;
              40, 40, 40, 40, 40];

conn_matrix = ones(3,3);

res_scalar = imhmin(img_valley, 10, 8);
res_matrix = imhmin(img_valley, 10, conn_matrix);

disp(and(res_scalar == res_matrix));
```

**Expected output:** `T`
