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

Requires the `imcomplement`, `imreconstruct` and `conndef` functions.

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

The following test scripts can be executed to validate valley threshold filling behavior.

```scilab
exec('conndef.sci', -1);
exec('imreconstruct.sci', -1);
exec('imcomplement.sci', -1);
exec('imhmin.sci', -1);
```

---

### TC-01 — Partial Valley Filling

Verifies that when a local valley basin depth exceeds the threshold $h$, its floor is filled up flat to the level $I_{\text{min}} + h$, creating an intensity plateau at the base.

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

Verifies that when the threshold value $h$ is greater than or equal to the total relative depth of the local basin, the valley is completely filled up to the surrounding ridge topology level and vanishes.

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
40.  25.  25.  25.  40.
40.  40.  40.  40.  40.
```

---

### TC-03 — Boundary Identity Check ($h = 0$)

Verifies that setting the depth filter threshold to exactly zero results in no topological alteration, returning a perfect identity duplicate matrix.

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