# `isind` — Scilab Function Reference

## 1. Description

`isind` determines whether an input matrix qualifies as a valid indexed image. An indexed image consists of a 2-D matrix of integers or positive floating-point values whose elements serve as indices pointing directly into a colormap lookup table.

This implementation is a direct port of the GNU Octave `image` package `isind.m`. The function inlines logical validation checks corresponding to internal Octave engine primitives like `isimage`, `isfloat`, and `isindex` using native Scilab type code mapping algorithms. It enforces dimension restrictions ensuring the array is strictly 2-D (or a 3-D matrix with a third dimension slice depth of exactly 1) and verifies value boundaries based on data class.

---

## 2. Calling Sequence

```scilab
bool = isind(img)
```

---

## 3. Dependencies

Requires the `isimage` function.

---

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `img` | Matrix | ✓ | Input image array to evaluate. Can be double (`constant`), integer, or boolean. |
| `bool` | Boolean | — | Output. Returns `%t` if the input is a valid indexed image, and `%f` otherwise. |

---

## 5. Test Cases

The following 7 test cases cover output verification, data class handling, boundary validations, and error conditions. Load the function file before running:

```scilab
exec('isind.sci', -1)
```

---

### TC-01 — Valid uint8 Array Grid

Verifies that an unsigned 8-bit integer matrix is correctly validated as an indexed image.

```scilab
img_uint8 = uint8([0, 5; 10, 20]);
res = isind(img_uint8);
mprintf("Result = %s\n", string(res));
```

**Expected output:** `Result = T`

---

### TC-02 — Valid uint16 Array Grid

Verifies that an unsigned 16-bit integer matrix is correctly validated as an indexed image.

```scilab
img_uint16 = uint16([1, 2; 3, 4]);
res = isind(img_uint16);
mprintf("Result = %s\n", string(res));
```

**Expected output:** `Result = T`

---

### TC-03 — Valid Positive Integer Float Map

Verifies that a floating-point matrix containing only real, positive integers evaluates to true.

```scilab
img_float_valid = [1.0, 2.0; 3.0, 4.0];
res = isind(img_float_valid);
mprintf("Result = %s\n", string(res));
```

**Expected output:** `Result = T`

---

### TC-04 — Invalid Fractional Decimal Float Map

Verifies that a floating-point matrix containing fractional values is rejected.

```scilab
img_float_frac = [1.5, 2.0; 3.0, 4.5];
res = isind(img_float_frac);
mprintf("Result = %s\n", string(res));
```

**Expected output:** `Result = F`

---

### TC-05 — Invalid Zero or Negative Value Bounds

Verifies that floating-point matrices containing zero or negative boundaries are rejected.

```scilab
img_float_neg = [0.0, 1.0; -2.0, 3.0];
res = isind(img_float_neg);
mprintf("Result = %s\n", string(res));
```

**Expected output:** `Result = F`

---

### TC-06 — Invalid 3-D Multichannel RGB Array Layout

Verifies that a 3-D matrix representing a multichannel RGB image is rejected.

```scilab
img_3d = zeros(5, 5, 3);
res = isind(img_3d);
mprintf("Result = %s\n", string(res));
```

**Expected output:** `Result = F`

---

### TC-07 — Wrong Number of Arguments Raises Error

Verifies that calling isind with an incorrect number of arguments raises an error.

```scilab
try
    res = isind();
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`
