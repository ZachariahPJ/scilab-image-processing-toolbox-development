# `imreconstruct` — Scilab Function Reference

## 1. Description

`imreconstruct` performs morphological geodesic reconstruction of a marker image under a mask image.

The function serves as a critical port of Octave's native image toolbox, utilizing Luc Vincent's high-performance fast reconstruction algorithm. It uses a dual-pass sequential raster scan (forward and backward) to initialize boundaries, followed by a fast FIFO (First-In, First-Out) queue propagation framework. This implementation ensures optimal convergence speed compared to iterative dilation loops and fully supports standard 2-D grayscale intensity profiles, logical binary arrays, and unsigned integer data types (`uint8`, `uint16`).

---

## 2. Calling Sequence

```scilab
J = imreconstruct(marker, mask)
J = imreconstruct(marker, mask, conn)
```

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `marker` | Matrix | Yes | The source starter matrix containing the seed coordinates or peak reductions. |
| `mask` | Matrix | Yes | The bounding constraint matrix that limits the geodesic propagation extent. |
| `conn` | Scalar | No | Neighborhood connectivity configuration. Can be `4` (4-way cross) or `8` (8-way square). Default: `8`. |
| `J` | Matrix | — | Output. The fully stable reconstructed array matching the input data class. |
---

## 4. Test Cases

The following test scripts can be executed to validate geodesic tracking accuracy across intensity shifts and connectivity splits.

```scilab
exec('imreconstruct.sci', -1);
```

---

### TC-01 — Grayscale Peak Suppression (Emulating `imhmax`)

Verifies that clipping a local maximum peak inside a grayscale marker forces the engine to reconstruct a flat intensity plateau bounded precisely by the surrounding slope values of the mask.

```scilab
mask_gray   = [10, 10, 10, 10, 10;
               10, 20, 30, 20, 10;
               10, 10, 10, 10, 10];
               
marker_gray = [10, 10, 10, 10, 10;
               10, 20, 20, 20, 10;
               10, 10, 10, 10, 10];

res = imreconstruct(marker_gray, mask_gray, 8);
disp(res);
```

**Expected output:** 
```scilab
10.  10.  10.  10.  10.
10.  20.  20.  20.  10.
10.  10.  10.  10.  10.
```

---

### TC-02 — Binary Component Re-inflation

Verifies that a single logical `%t` seed point intersecting a connected component inside a binary mask completely re-inflates the entire parent shape via FIFO spatial queue propagation.

```scilab
mask_binary = [%f, %f, %f, %f, %f;
               %f, %t, %t, %t, %f;
               %f, %t, %t, %t, %f;
               %f, %f, %f, %f, %f];
               
marker_seed = [%f, %f, %f, %f, %f;
               %f, %f, %f, %f, %f;
               %f, %f, %t, %f, %f;
               %f, %f, %f, %f, %f];

res = imreconstruct(marker_seed, mask_binary);
disp(res);
```

**Expected output:**
```scilab
F F F F F
F T T T F
F T T T F
F F F F F
```

---

### TC-03 — 4-Way vs 8-Way Diagonal Segmentation

Verifies that a 4-way cross connectivity parameter cannot cross diagonal pixel shifts (treating them as isolated elements), whereas an 8-way square bridges them seamlessly.

```scilab
mask_diagonal = [%t, %f, %f;
                 %f, %t, %f;
                 %f, %f, %t];
                 
marker_corner = [%t, %f, %f;
                 %f, %f, %f;
                 %f, %f, %f];

res_conn4 = imreconstruct(marker_corner, mask_diagonal, 4);
res_conn8 = imreconstruct(marker_corner, mask_diagonal, 8);

disp(res_conn4);
disp(res_conn8);
```

**Expected output(`res_conn4`):**
```scilab
T F F
F F F
F F F
```

**Expected output(`res_conn8`):**
```scilab
T F F
F T F
F F T
```
