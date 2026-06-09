# `imcast` — Scilab Function Reference

## 1. Description

`imcast` is an internal utility function that handles image data type conversions and scaling operations. It changes the underlying numeric representation of an input image array `img` to a target data class specified by the string `outcls` (e.g., `"uint8"`, `"uint16"`, `"int16"`, `"single"`, or `"double"`).

This implementation is a direct port of the GNU Octave `image` package `imcast.m`. It supports two distinct conversion modes based on the number of inputs:

1.  Standard Image Conversions (2 arguments): Scales the dynamic range of pixel intensities between integer bounds (such as `0` to `255` for `uint8`) and floating-point intensity intervals (`0.0` to `1.0`). Signed `int16` bounds are automatically mapped with symmetric zero-shifts.

2.  Indexed Image Conversions (3 arguments): Triggered by passing the string `"indexed"` as the third parameter. This mode bypasses structural feature normalization, verifies index validity via the `isind` companion function, and applies `+1` or `-1` integer offset adjustments when changing between floating-point and unsigned integer representations.

---

## 2. Calling Sequence

```scilab
imout = imcast(img, outcls)
imout = imcast(img, outcls, 'indexed')
```

---

## 3. Dependencies

Requires the `isind` function.

---

## 4. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `img` | Matrix | ✓ | Input image array to convert. Can be a double precision floating-point (`constant`), integer class array, or boolean matrix. |
| `outcls` | String | ✓ | Target data class destination. Supported strings: `"double"`, `"single"`, `"uint8"`, `"uint16"`, `"int16"`, and `"logical"`. |
| `indexed` | String | — | Explicit conversion modifier configuration flag. When supplied, treats the input array as color lookup markers rather than normalized grayscale values. |
| `imout` | Matrix | — | Output. Converted and rescaled output matrix matching the specific bit depth structure requirements of `outcls.` |
---

## 5. Test Cases

The following 6 test cases verify standard array normalization, bit depth rescaling, index offsets, and error checking paths. Load both files before running:

```scilab
exec('isind.sci', -1)
exec('imcast.sci', -1)
```

---

### TC-01 — Standard uint8 to double Normalization

Verifies that standard images scale from integer ranges down to floating-point intervals bounded between `0.0` and `1.0`.

```scilab
img_u8 = uint8([0, 255; 51, 102]);
res = imcast(img_u8, "double");
disp(res);
```

**Expected output:** 
```scilab
0.    1. 
0.2   0.4
```

---

### TC-02 — Standard double to uint16 Range Expansion

Verifies that fractional floating-point values are multiplied out to fill the target integer color bit depth space.

```scilab
img_dbl = [0.0, 1.0; 0.5, 0.25];
res = imcast(img_dbl, "uint16");
disp(res);
```

**Expected output:**
```scilab
0      65535
32768  16384
```

---

### TC-03 — Indexed Integer to Floating-Point Shift

Verifies that an indexed image conversion from an integer matrix adds a `+1` baseline adjustment offset.

```scilab
img_idx_u8 = uint8([1, 2; 3, 4]);
res = imcast(img_idx_u8, "double", "indexed");
disp(res);
```

**Expected output:**
```scilab
2.  3.
4.  5.
```

---

### TC-04 — Indexed Floating-Point to Integer Shift

Verifies that an indexed image conversion from floating-point matrices to an integer class shifts the values down by `-1`.

```scilab
img_idx_dbl = [2.0, 3.0; 4.0, 5.0];
res = imcast(img_idx_dbl, "uint8", "indexed");
disp(res);
```

**Expected output:**
```scilab
1  2
3  4
```

---

### TC-05 — Color Palette Capacity Overflow Error

Verifies that an error is raised when an indexed image contains values that exceed the capacity of the destination integer data type.

```scilab
try
    img_large_idx = [1000, 2000]; // Exceeds uint8 upper bound capacity limit (255)
    res = imcast(img_large_idx, "uint8", "indexed");
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`

---

### TC-06 — Invalid Configuration Parameter Argument Error

Verifies that an error is raised if the third argument is present but does not equal `"indexed"`.

```scilab
try
    img_u8 = uint8([1, 2; 3, 4]);
    res = imcast(img_u8, "double", "invalid_string_flag");
    mprintf("No error raised\n");
catch
    mprintf("Error raised correctly\n");
end
```

**Expected output:** `Error raised correctly`
