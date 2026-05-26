# `colorangle` — Scilab Function Reference

## 1. Description

`colorangle` computes the angle in degrees between two RGB colors, treating each color as a coordinate vector in 3-D space. The angle is calculated using the dot product formula:

```
angle = acos( (A · B) / (‖A‖ × ‖B‖) )
```

A small angle means the two colors are perceptually similar in hue direction; an angle of 90° means they are orthogonal (e.g. pure red vs pure green); 180° means they are directly opposite.

Both single color triplets and batches of colors (as `Nx3` matrices) are accepted. If one input is a single `1×3` color and the other is `Nx3`, the single color is broadcast across all rows of the larger input automatically.

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

> **Note:** If either color is the zero vector `[0, 0, 0]` (black), the angle is returned as `0` rather than `NaN`. This matches MATLAB and Octave behaviour, treating black as a degenerate case.

---

## 4. Test Cases

The following 6 test cases cover geometric correctness, broadcasting, edge inputs, and error handling. Run them after loading the function with `exec('colorangle.sci', -1)`.

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

Verifies that pairing any color with pure black `[0,0,0]` returns `0` rather than `NaN`. Black has zero norm, making the angle geometrically undefined; `0` is returned for MATLAB/Octave compatibility.

```scilab
angles = colorangle([0, 0, 0], [1, 1, 1])
```

**Expected output:** `0`

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

---

## 5. Porting Notes and Challenges

Several Octave and MATLAB functions used in the original source have no direct equivalent in Scilab and required workarounds:

**`isnumeric(x)`** — Not available in Scilab. Replaced with `type(x) <= 8`, using Scilab's `type()` integer codes where values 1–8 cover all real numeric types (double, integer variants). Values above 8 indicate strings, booleans, or other non-numeric types.

**`numel(x)`** — Not available in Scilab. Replaced with `size(x, '*')`, which returns the total number of elements in a matrix — the direct equivalent.

**`sumsq(X, 2)`** — Not available in Scilab. Replaced with `sum(X .^ 2, 2)`, which squares each element and sums along the column dimension (per row).

**`dot(A, B, 2)`** — Scilab's `dot()` does not accept a dimension argument. Replaced with `sum(A .* B, 2)`, the element-wise equivalent for row-wise dot products.

**`rad2deg(x)`** — Not available in Scilab. Replaced with `x * 180 / %pi`, using Scilab's built-in `%pi` constant.

**`warning("off", ..., "local")`** — Scilab has no local warning suppression. The divide-by-zero `NaN` that this suppressed in Octave is instead handled explicitly: any row where either norm is zero has its angle forced to `0` via a logical mask after the `acos` call.

**`&&` and `||` operators** — These short-circuit scalar operators from Octave are not reliable in all Scilab versions. Replaced throughout with `&` and `|`, which work correctly for both scalar and element-wise logical expressions in Scilab.

**Broadcasting** — Octave handles `dot(rgb1, rgb2, 2)` with implicit broadcasting when one input is `1×3` and the other is `Nx3`. Scilab requires this to be done manually. The single row is replicated with `ones(N, 1) * rgb1` before the dot product is computed, so the operation always reduces to the same-size element-wise case.
