# `imcomplement` — Scilab Function Reference

## 1. Description

`imcomplement` computes the complement (or inverse) of an image matrix.

This function serves as a direct, self-contained port of Octave's native image processing toolbox. The transformation mimics dark-to-light photographic film inversion: dark areas become bright, and bright areas become dark. In morphological workflows, it provides the core mathematical foundation for duality operations (such as transforming a reconstruction-by-dilation engine into a reconstruction-by-erosion engine for functions like `imhmin`).

---

## 2. Calling Sequence

```scilab
B = imcomplement(A)
```

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `A` | Matrix | ✓ | The source image matrix. Can be floating-point double precision, boolean, or integer arrays (`uint8`, `uint16`, `int8`, `int16`). |
| `B` | Matrix | — | Output. The inverted complement matrix matching the exact class size and variable type of input `A`. |

### Behavior by Data Type:
1. Boolean / Logical: Evaluates as element-wise inversion (`~A`). True values become False, and vice-versa.
2. Floating-Point (`double`): Scales linearly against a unitary threshold: $B = 1.0 - A$.
3. Unsigned Integers (`uint8`, `uint16`): Subtracts pixel values from the absolute maximum bit boundary of that class type (e.g., $255 - A$ for `uint8`).
4. Signed Integers (`int8`, `int16`): Computes the bitwise complement using `bitnot(A)`.
---

## 4. Test Cases

The following test scripts can be executed to validate inversion accuracy across varying data type structures.

```scilab
exec('imcomplement.sci', -1);
```

---

### TC-01 — Boolean Logical Inversion

Verifies that boolean array masks are correctly inverted element-by-element.

```scilab
bool_mat = [%t, %f; %f, %t];
res = imcomplement(bool_mat);
disp(res);
```

**Expected output:** 
```scilab
F T
T F
```

---

### TC-02 — Floating-Point Dynamic Complement

Verifies that standard floating-point matrices are correctly scaled against a standard intensity max bound of $1.0$.

```scilab
float_mat = [0.0, 0.25; 0.70, 1.0];
res = imcomplement(float_mat);
disp(res);
```

**Expected output:**
```scilab
1.    0.75
0.3   0.
```

---

### TC-03 — Integer Bit-Bound Saturation (`uint8`)

Verifies that unsigned integer classes are subtracted from their absolute native upper data bound (255) rather than falling into negative tracking spaces.

```scilab
ui8_mat = uint8([0, 55; 200, 255]);
res = imcomplement(ui8_mat);
disp(res);
```

**Expected output:**
```scilab
255  200
55   0
```
