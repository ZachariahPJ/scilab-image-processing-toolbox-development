# `conndef` — Scilab Function Reference

## 1. Description

`conndef` is a utility function used to generate binary connectivity masks (structuring elements) for mathematical morphology operations (such as dilation and erosion) and neighborhood processing.The function acts as a precise Scilab port of Octave's native image packaging toolbox. It supports creating standardized custom pixel neighborhoods across arbitrary spatial dimensions ($N$-dimensions). In accordance with Octave conventions, neighborhood centers are evaluated as %t (True) to ensure the reference pixel is explicitly included within calculated neighborhood boundaries.

---

## 2. Calling Sequence

```scilab
conn = conndef(num_dims, conntype)
conn = conndef(type_scalar)
```

---

## 3. Dependencies

Requires the `connectivity` function.

---

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `num_dims` | Scalar | Constant | Total number of dimensions for the target neighborhood matrix (must be a positive integer). |
| `conntype` | String | Constant | The geometric neighborhood constraint profile type. Must be either `"minimal"` or `"maximal"`. |
| `type_scalar` | Scalar | Constant | Alternative short-hand parameter representing a predefined explicit neighborhood size (`4`, `8`, `6`, `18`, or `26`). |
| `conn` | Matrix | — | Output. A logical/boolean multidimensional matrix containing the generated structural neighborhood element mask. |
---

## 5. Test Cases

The following test script file can be used to validate parameter execution paths, multidimensional block assembly, and shape geometries against standard configuration targets.

---

### TC-01 — 2-D "minimal" (4-Connected Neighborhood Cross)

Verifies that passing a dimension count of 2 with a `"minimal"` configuration flag generates a standard 2-D cross mask where only pixels sharing a full edge are true.

```scilab
res = conndef(2, "minimal");
disp(res);
```

**Expected output:** 
```scilab
0   1   0 
1   1   1
0   1   0
```

---

### TC-02 — 2-D "maximal" (8-Connected Neighborhood Square)

Verifies that passing a dimension count of 2 with a `"maximal"` configuration flag generates a solid 3x3 array bounding all neighboring corner elements.

```scilab
res = conndef(2, "maximal");
disp(res);
```

**Expected output:**
```scilab
1   1   1 
1   1   1
1   1   1
```

---

### TC-03 — Scalar Short-Hand Translation Mapping

Verifies that passing standard direct scalar integers (like `4` or `8`) automatically maps backwards to evaluate their multi-argument equivalents.

```scilab
res_4 = conndef(4);
res_8 = conndef(8);
disp(res_4);
```

**Expected output:**
```scilab
0   1   0 
1   1   1
0   1   0
```

---

### TC-04 — 3-D "minimal" (6-Connected Volumetric Star Cross)

Verifies that a 3-D volumetric minimal neighborhood generates a $3 \times 3 \times 3$ logical cube containing a 3D axial star mapping.

```scilab
res = conndef(3, "minimal");
disp(res(:,:,2));
```

**Expected output:**
```scilab
0   1   0
1   1   1
0   1   0
```

---

### TC-05 — Predefined 3-D 18-Connected Short-Hand Shape

Verifies the creation of the specialized 3D 18-connectivity neighborhood envelope, which retains faces and edges but excludes the eight furthest corners.

```scilab
res = conndef(18);
disp(res(:,:,1));
```

**Expected output:**
```scilab
0   1   0
1   1   1
0   1   0
```

---

### TC-06 — Rejecting Negative Matrix Spatial Limits

Verifies that input verification parameters intercept out-of-bounds configurations and throw an exception error layout cleanly.

```scilab
try
    res = conndef(-2, "minimal");
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

---

**Expected output:** `Error raised correctly`

### TC-07 — Rejecting Illegal Type Parameter Keyword Strings

Verifies that input sanitizers block unrecognized string arguments passed into the function framework.

```scilab
try
    res = conndef(2, "corrupt_type_string");
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-08 — 1-D "minimal"/"maximal" Edge Case

Verifies the single-dimension edge case reshapes correctly into a column vector rather than erroring, since Scilab's reshape requires at least two dimensions internally.

```scilab
res_min = conndef(1, "minimal");
res_max = conndef(1, "maximal");
disp(res_min);
disp(res_max);
```

**Expected output(`res_min`):**
```scilab
1.
1.
1.
```

**Expected output(`res_max`):**
```scilab
1.
1.
1.
```

---

### TC-09 — Accepting a Valid Connectivity Matrix Directly

Verifies that passing an already-built connectivity matrix (rather than a dimension count and type string) is validated and returned as-is, exercising the center-element and symmetry checks on a matrix known to be valid.

```scilab
conn_in = [0 1 0; 1 1 1; 0 1 0];
res = conndef(conn_in);
disp(res);
```

**Expected output:**
```scilab
0   1   0
1   1   1
0   1   0
```

---

### TC-10 — Rejecting a Matrix Not Symmetric About Its Center

Verifies that a connectivity matrix which is not point-symmetric about its center element is correctly rejected rather than silently accepted.

```scilab
try
    res = conndef([0 1 1; 1 1 1; 1 1 1]);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-11 — Rejecting a Matrix Whose Center Element Is Not 1

Verifies that a connectivity matrix with a valid shape and valid 0/1 values, but a false/zero center element, is correctly rejected.

```scilab
try
    res = conndef([1 1 1; 1 0 1; 1 1 1]);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-12 — Rejecting a Matrix With Non-Binary Values

Verifies that a connectivity matrix containing a value other than 0 or 1 is correctly rejected.

```scilab
try
    res = conndef([1 2 1; 1 1 1; 1 1 1]);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-13 — Rejecting an Invalid Scalar Connectivity Code

Verifies that a scalar outside the valid set `{4, 6, 8, 18, 26}` is correctly rejected.

```scilab
try
    res = conndef(10);
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`
