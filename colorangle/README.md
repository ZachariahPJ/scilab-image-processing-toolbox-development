# `colorangle` — Scilab Function Reference

## 1. Description

The `colorangle` function calculates the geometric angle (in degrees) between two colors in the RGB color space. Each color is treated as a 3D vector extending from the origin $(0,0,0)$ representing black. The function supports automatic size matching (broadcasting). You can compare a single color vector against a list of multiple colors, or compare two lists of colors of equal size. It also handles floating-point rounding adjustments and provides a fallback value of 0 instead of NaN if both inputs are black vectors to maintain MATLAB/Octave compatibility.

---

## 2. Calling Sequence

```scilab
angles = colorangle(rgb1, rgb2)
```

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `rgb1` | `1×3` vector or `Nx3` matrix | ✓ | First RGB color or batch of colors. Values are typically in `[0, 1]` but any real numeric range is accepted. |
| `rgb2` | `1×3` vector or `Nx3` matrix | ✓ | Second RGB color or batch of colors. Must have the same number of rows as `rgb1`, or one of the two must be a single row. |
| `angles` | Scalar or `Nx1` column vector | — | **Output.** Angle(s) in degrees between corresponding rows of `rgb1` and `rgb2`. |

## 4. Test Cases

The following 6 test cases cover geometric correctness, broadcasting, edge inputs, and error handling.

---

### TC-01 — Orthogonal Vectors (90°)

Verifies that two primary colors at right angles to each other produce exactly 90°.

```scilab
angles = colorangle([1, 0, 0], [0, 1, 0])
```

**Expected output:** `90.0`

Pure red `[1,0,0]` and pure green `[0,1,0]` share no components, so their dot product is zero and the angle between them is 90°.

---

### TC-02 — Identical Vectors (0°)

Verifies that two identical colors produce an angle of 0°. This also exercises the floating-point clamping guard, since the raw cosine can exceed `1.0` slightly due to rounding.

```scilab
angles = colorangle([1, 1, 1], [1, 1, 1])
```

**Expected output:** `0.0`

---

### TC-03 — Matrix Broadcasting

Verifies that a single `1×3` color is correctly broadcast across an `Nx3` matrix of colors.

```scilab
rgb_mat    = [1, 0, 0; 0, 1, 0; 1, 1, 1];
single_rgb = [1, 0, 0];
angles = colorangle(rgb_mat, single_rgb)
```

**Expected output:**
```
  0.000000
 90.000000
 54.735610
```

Row 1 is identical to the reference → 0°. Row 2 is orthogonal → 90°. Row 3 (white) sits at the equal-angle diagonal → ≈54.74°.

---

### TC-04 — One Black Vector

Verifies that pairing any color with pure black `[0,0,0]` returns `NaN`. Black has zero norm, making the angle geometrically undefined;

```scilab
angles = colorangle([0, 0, 0], [1, 1, 1])
```

**Expected output:** `Nan`

---

### TC-05 — Both Black Vectors

Verifies that two black vectors also return `0` rather than `NaN`.

```scilab
angles = colorangle([0, 0, 0], [0, 0, 0])
```

**Expected output:** `0`

---

### TC-06 — Error: Dimension Mismatch

Verifies that two `Nx3` matrices with different row counts raise an error.

```scilab
colorangle(ones(2, 3), ones(4, 3))
```

**Expected output:** Scilab throws the error:
```
colorangle: RGB1 and RGB2 must have one or the same number of colors
```
