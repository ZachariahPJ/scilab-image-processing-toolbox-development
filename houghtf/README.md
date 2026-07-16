# `houghtf` — Scilab Function Reference

## 1. Description

`houghtf` is a dispatcher function for Hough transform computations. It provides a single entry point that routes execution to one of two underlying transform engines based on a method string: `hough_line` (default) or `hough_circle`.

This function acts as a clean interface wrapper that sanitizes user input parameters (validating argument count, matrix dimensionality, and method selection) and delegates the actual transform computation down to the core engine backends, `hough_line.sci` and `hough_circle.sci`. It handles two structural dispatch profiles:

**Default / Line Method (`"line"`, or omitted):** Delegates to `hough_line`, which computes a Standard Hough Transform accumulator for detecting straight lines in a binary image, returning both the accumulator matrix and the associated `rho` bin centers.

**Circle Method (`"circle"`):** Triggered explicitly by passing the string modifier `"circle"`. Delegates to `hough_circle`, which computes a Circular Hough Transform accumulator for one or more candidate radii, returning only the accumulator array (no bin output).

If the first element of the optional argument list is not a string, it is not consumed as a method selector — instead, the entire optional argument list is treated as method-specific arguments and passed straight through to `hough_line` (the default method).

---

## 2. Calling Sequence

```scilab
[accum, R] = houghtf(bw)
[accum, R] = houghtf(bw, thetas)
[accum, R] = houghtf(bw, "line")
[accum, R] = houghtf(bw, "line", thetas)
accum      = houghtf(bw, "circle", r)
```

---

## 3. Dependencies

Requires the `hough_line`, `hough_circle` and `bwmorph` functions.

---

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `bw` | Matrix | ✓ | Input 2-dimensional binary/logical image matrix to transform. |
| `method` | String | — | Transform selector: `"line"` (default) or `"circle"`. Case-insensitive. If omitted or if the first optional argument is not a string, defaults to `"line"`. |
| `thetas` | Vector | — | (Line method only) Angle vector in radians to evaluate. Defaults to `-%pi/2 : %pi/180 : %pi/2` if omitted. |
| `r` | Scalar/Vector | — | (Circle method only) Radius or radii to evaluate. **Required** — `hough_circle` errors if not supplied, since it strictly expects exactly 2 input arguments. |
| `accum` | Matrix | — | Output. The Hough accumulator array. 2-D for line method; 3-D (rows × cols × `length(r)`) for circle method. |
| `R` | Vector | — | Output. (Line method only) The `rho` bin center values corresponding to accumulator rows. |

---

## 5. Test Cases

### TC-01 — Explicit "line" Method with Custom Thetas

Verifies accumulator values for a single-point image against hand-computed `rho`/bin values.

```scilab
bw = zeros(3,3);
bw(2,2) = 1;
thetas = [0, %pi/4, %pi/2];
[J, bins] = houghtf(bw, "line", thetas);
disp(J);
disp(bins);
```

**Expected output:**
```scilab
0.  0.  0.
0.  0.  0.
0.  0.  0.
0.  0.  0.
1.  1.  1.
0.  0.  0.
0.  0.  0.

bins = -3.  -2.  -1.  0.  1.  2.  3.
```

---

### TC-02 — Default Method Dispatch via Non-String First Argument

Verifies that passing a non-string first optional argument bypasses method selection (stays on `"line"`) and forwards it as `thetas`. Must match TC-01 exactly.

```scilab
bw = zeros(3,3);
bw(2,2) = 1;
thetas = [0, %pi/4, %pi/2];
[J1, bins1] = houghtf(bw, "line", thetas);
[J2, bins2] = houghtf(bw, thetas);
disp(J1 == J2);
disp(bins1 == bins2);
```

**Expected output:** `%t` for all elements of both comparisons.

---

### TC-03 — "circle" Method with Scalar Radius

Verifies accumulator values for a single-point image with a small radius against a hand-computed diamond-ring pattern.

```scilab
bw = zeros(5,5);
bw(3,3) = 1;
accum = houghtf(bw, "circle", 1);
disp(accum);
```

**Expected output:**
```scilab
0.  0.  0.  0.  0.
0.  0.  1.  0.  0.
0.  1.  0.  1.  0.
0.  0.  1.  0.  0.
0.  0.  0.  0.  0.
```

---

### TC-04 — "circle" Method with Radius Vector

Verifies that the accumulator's third dimension matches `length(r)` when multiple radii are supplied.

```scilab
bw = zeros(10,10);
bw(5,5) = 1;
accum = houghtf(bw, "circle", [1, 2]);
disp(size(accum));
```

**Expected output:** `10.  10.  2.`

---

### TC-05 — No Input Arguments

Verifies the guard clause for missing arguments.

```scilab
try
    houghtf();
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-06 — Non-2D Input Matrix

Verifies that a non-2-dimensional `bw` argument is rejected before dispatch.

```scilab
try
    bw3d = zeros(3,3,2);
    houghtf(bw3d);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-07 — Unsupported Method String

Verifies rejection of an unrecognized method identifier.

```scilab
try
    bw = zeros(5,5);
    houghtf(bw, "triangle");
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-08 — "circle" Method Missing Required Radius Argument

Verifies that omitting the radius on the circle path correctly propagates `hough_circle`'s own argument-count error (since `hough_circle` strictly requires exactly 2 inputs), rather than silently succeeding or failing elsewhere.

```scilab
try
    bw = zeros(5,5);
    accum = houghtf(bw, "circle");
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-09 — Case-Insensitive Method Dispatch

Verifies that `"LINE"`, `"Line"`, and `"line"` all route identically.

```scilab
bw = zeros(3,3);
bw(2,2) = 1;
thetas = [0, %pi/4, %pi/2];
[J1, bins1] = houghtf(bw, "line", thetas);
[J2, bins2] = houghtf(bw, "LINE", thetas);
disp(J1 == J2);
disp(bins1 == bins2);
```

**Expected output:** `%t` for all elements of both comparisons.

---

### TC-10 — Default Thetas Dimension Check

Verifies that omitting `thetas` entirely on the line path produces the expected default angle sweep length (`-%pi/2 : %pi/180 : %pi/2` → 181 values) and a correctly sized accumulator.

```scilab
bw = zeros(5,5);
bw(3,3) = 1;
[J, bins] = houghtf(bw);
disp(size(J));
```

**Expected output:** `13.  181.`


