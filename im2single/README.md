# `im2single` — Scilab Function Reference

## 1. Description

`im2single` is a standard image type conversion function that re-scales and casts image arrays into single-precision floating-point equivalents (mapped natively inside Scilab as a `double`/`constant` precision class matrix).

This function acts as a clean interface wrapper that sanitizes user input parameters and delegates processing down to the core engine backend, `imcast.sci`. It handles two structural image profiles:

Standard Image Intensities (1 input argument): Linearly normalizes standard images into floating-point intensities scaled strictly between `0.0` and `1.0`. Integer bit-depth ranges (like `uint8` or `uint16`) are dynamically scaled, while signed representations (like `int16`) are shifted symmetrically to preserve zero-center alignment.

Indexed Image Palettes (2 input arguments): Triggered explicitly by passing the string modifier `"indexed"`. This mode preserves raw color mapping lookup coordinates rather than re-scaling intensities. It applies a `+1` structural element index offset to satisfy standard 1-based matrix indexing when up-converting from integer matrix classes.

---

## 2. Calling Sequence

```scilab
imout = im2single(img)
imout = im2single(img, 'indexed')
```

---

## 3. Dependencies

Requires the `isimage`, `isindex`, `isind`, `intmin`, `intmax` and `imcast` functions.

---

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `img` | Matrix | ✓ | Input image array to convert. Can be standard double/constant matrices, boolean masks, or integer matrix arrays (`uint8`, `uint16`, `int16`). |
| `indexed` | String | — | Explicit configuration modifier flag. When supplied, treats the input array as an unscaled index pointer matrix. |
| `imout` | Matrix | — | Output. The single-precision floating-point transformed array scaled appropriately to the target data specifications. |
---

## 5. Test Cases

The following test script validates argument processing, standard intensity scaling, integer mapping translations, and exception intercept boundaries.

---

### TC-01 — Double Floating-Point Passthrough Matrix

Verifies that standard floating-point arrays are handled gracefully as a non-modifying baseline passthrough.

```scilab
img_dbl = [0.0, 0.5; 0.25, 1.0];
res = im2single(img_dbl);
disp(res);
```

**Expected output:** 
```scilab
0.    0.5 
0.25  1.
```

---

### TC-02 — Boolean Mask Array to Float Representation

Verifies that logical matrices are mapped directly to binary float values of `0.0` (False) and `1.0` (True).

```scilab
img_bool = [%f, %t; %t, %f];
res = im2single(img_bool);
disp(res);
```

**Expected output:**
```scilab
0.  1.
1.  0.
```

---

### TC-03 — Standard Unsigned uint8 Rescaling Matrix

Verifies that standard 8-bit integer intensities are normalized down from integer space (`0` to `255`) to floating-point intervals bounded between `0.0` and `1.0`.

```scilab
img_u8 = uint8([0, 255; 51, 102]);
res = im2single(img_u8);
disp(res);
```

**Expected output:**
```scilab
0.   1.
0.2  0.4
```

---

### TC-04 — Standard Signed int16 Zero-Translation Matrix

Verifies that signed data boundaries are offset correctly by `32768` to translate the absolute minimum intensity bounds up to a clean `0.0` to `1.0` span.

```scilab
img_i16 = int16([-32768, 32767]);
res = im2single(img_i16);
disp(res);
```

**Expected output:**
```scilab
0.  1.
```

---

### TC-05 — Indexed Unsigned Matrix 1-Based Offset Shift

Verifies that when evaluating an indexed integer matrix array, a structural layout offset of `+1` is added to map coordinates cleanly to floating-point color lookup configurations.

```scilab
img_idx_u8 = uint8([1, 5; 10, 15]);
res = im2single(img_idx_u8, "indexed");
disp(res);
```

**Expected output:**
```scilab
2.   6.
11.  16.
```

---

### TC-06 — Allowed Arbitrary Structural Options String Bypass

Verifies that an error is promptly thrown if the second tracking token is an invalid string modifier rather than the explicit identifier `"indexed"`.

```scilab
try
    img_u8 = uint8([0, 255; 51, 102]);
    res = im2single(img_u8, "corrupt_string_modifier_flag");
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-07 — Correctly Intercepted and Blocked Corrupt Indexed Matrices

Verifies that floating-point arrays passed as indexed images are successfully rejected if they violate index constraints (e.g., containing negative elements or non-integer fractions).

```scilab
try
    invalid_idx_float = [-5.0, 2.5; 3.0, 4.0]; 
    res = im2single(invalid_idx_float, "indexed");
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`
