# `imhmax` — Scilab Function Reference

## 1. Description

`imhmax` applies the $H$-maxima transform to an image, suppressing all local maxima (peaks) whose height is less than or equal to a specified threshold value $h$.

This function serves as a direct port of Octave's native image processing toolbox. By reducing low-amplitude noise spikes and minor structural fluctuations while preserving larger regional peak shapes, it acts as a primary preprocessing filter for morphological segmentation tasks, such as watershed initialization.

---

## 2. Calling Sequence

```scilab
im2 = imhmax(im, h)
im2 = imhmax(im, h, conn)
```

---

## 3. Dependencies

Requires the `imreconstruct` and `conndef` functions.

---

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `im` | Matrix | Yes | The input source grayscale intensity matrix or integer array (`uint8`, `uint16`). |
| `h` | Scalar | Yes | The non-negative real height threshold value used to shave local peaks. |
| `conn` | Scalar/Matrix | No | Neighborhood connectivity configuration profile. Accepts standard neighborhood structures or shorthand scalars (`4` or `8`). Default: Maximal neighborhood generated via `conndef`. |
| `im2` | Matrix | — | Output. The transformation result matrix matching the exact class size and data type of the input image `im`. |
---

## 5. Test Cases

The following test scripts can be executed to validate height threshold suppression behavior.

```scilab
exec('conndef.sci', -1);
exec('imreconstruct.sci', -1);
exec('imhmax.sci', -1);
```

---

### TC-01 — Partial Peak Shaving

Verifies that when a local peak height exceeds the threshold $h$, its top is shaved off flat down to the level $I_{\text{max}} - h$, creating an intensity plateau above the surrounding background.

```scilab
img_peak = [10, 10, 10, 10, 10;
            10, 25, 40, 25, 10;
            10, 10, 10, 10, 10];

res = imhmax(img_peak, 10);
disp(res);
```

**Expected output:** 
```scilab
10.  10.  10.  10.  10.
10.  25.  30.  25.  10.
10.  10.  10.  10.  10.
```

---

### TC-02 — Complete Peak Absorption

Verifies that when the threshold value $h$ is greater than or equal to the total relative height of the local peak, the peak is completely absorbed into the surrounding plateau topology and disappears.

```scilab
img_peak = [10, 10, 10, 10, 10;
            10, 25, 40, 25, 10;
            10, 10, 10, 10, 10];

res = imhmax(img_peak, 20);
disp(res);
```

**Expected output:**
```scilab
10.  10.  10.  10.  10.
10.  20.  20.  20.  10.
10.  10.  10.  10.  10.
```

---

### TC-03 — Boundary Identity Check ($h = 0$)

Verifies that setting the height filter threshold to exactly zero results in no structural alteration, returning a perfect identity duplicate matrix.

```scilab
img_peak = [10, 10, 10, 10, 10;
            10, 25, 40, 25, 10;
            10, 10, 10, 10, 10];

res = imhmax(img_peak, 0);
disp(and(res == img_peak));
```

**Expected output:**
```scilab
T
```

---

### TC-04 — Integer Class Preservation

Verifies that when the input image is an integer class (`uint8`), the output of `imhmax` preserves that same class rather than silently returning a plain double array.

```scilab
img_peak_u8 = uint8([10, 10, 10, 10, 10;
                      10, 25, 40, 25, 10;
                      10, 10, 10, 10, 10]);

res = imhmax(img_peak_u8, 10);
disp(res);
disp(type(res));
```

**Expected output(`res`):**
```scilab
10.  10.  10.  10.  10.
10.  25.  30.  25.  10.
10.  10.  10.  10.  10.
```

**Expected output(`type(res)`):** `8`  (Scilab's integer-type code, confirming the result is still `uint8`, not `double`)

---

### TC-05 — Rejecting an Invalid CONN Argument

Verifies that passing a scalar connectivity value outside the valid set `{4, 6, 8, 18, 26}` is correctly rejected rather than silently treated as a default connectivity.

```scilab
img_peak = [10, 10, 10, 10, 10;
            10, 25, 40, 25, 10;
            10, 10, 10, 10, 10];

try
    res = imhmax(img_peak, 10, 5);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-06 — Explicit CONN Actually Changes the Result

Verifies that the `CONN` argument is genuinely wired through to the underlying reconstruction rather than ignored, by checking that 4-connectivity and 8-connectivity give different results for two diagonally-adjacent peaks.

```scilab
img_diag = [10, 10, 10, 10;
            10, 30, 10, 10;
            10, 10, 30, 10;
            10, 10, 10, 10];

res_conn4 = imhmax(img_diag, 15, 4);
res_conn8 = imhmax(img_diag, 15, 8);

disp(res_conn4);
disp(res_conn8);
disp(and(res_conn4 == res_conn8));
```

**Expected output(`res_conn4`):**
```scilab
10.  10.  10.  10.
10.  15.  10.  10.
10.  10.  15.  10.
10.  10.  10.  10.
```

**Expected output(`res_conn8`):**
```scilab
10.  10.  10.  10.
10.  15.  10.  10.
10.  10.  15.  10.
10.  10.  10.  10.
```

**Expected output(final `and(...)`):** `T`