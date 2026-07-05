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
---

### TC-04 — Binary Spiral Propagation

Verifies that a single seed at one end of a connected corridor floods the entire corridor via the propagation queue, including a dead-end tail that cannot be reached by a single raster or antiraster pass alone — this specifically exercises the FIFO propagation step, not just the two-pass scan.

```scilab
mask_spiral   = [%t, %t, %t, %t, %t;
                  %f, %f, %f, %f, %t;
                  %t, %t, %t, %f, %t;
                  %t, %f, %f, %f, %t;
                  %t, %t, %t, %t, %t];

marker_spiral = [%t, %f, %f, %f, %f;
                  %f, %f, %f, %f, %f;
                  %f, %f, %f, %f, %f;
                  %f, %f, %f, %f, %f;
                  %f, %f, %f, %f, %f];

res = imreconstruct(marker_spiral, mask_spiral);
disp(res);
```

**Expected output(`res`):**
```scilab
T T T T T
F F F F T
T T T F T
T F F F T
T T T T T
```
---

### TC-05 — Grayscale Spiral Propagation

Verifies that the propagation step correctly raises grayscale values (not just booleans) along a corridor that requires multiple direction reversals to fully traverse.

```scilab
mask_gray_spiral   = [50, 50, 50, 50, 50;
                       10, 10, 10, 10, 50;
                       50, 50, 50, 10, 50;
                       50, 10, 10, 10, 50;
                       50, 50, 50, 50, 50];

marker_gray_spiral = [50, 10, 10, 10, 10;
                       10, 10, 10, 10, 10;
                       10, 10, 10, 10, 10;
                       10, 10, 10, 10, 10;
                       10, 10, 10, 10, 10];

res = imreconstruct(marker_gray_spiral, mask_gray_spiral);
disp(res);
```

**Expected output(`res`):**
```scilab
50. 50. 50. 50. 50.
10. 10. 10. 10. 50.
50. 50. 50. 10. 50.
50. 10. 10. 10. 50.
50. 50. 50. 50. 50.
```
---

### TC-06 — Disconnected Region Isolation

Verifies that reconstruction only grows the mask component actually connected to the marker, leaving a disconnected foreground region untouched — the output should differ from both `marker` (which under-fills the seed's own component) and `mask` (whose second blob never gets reached).

```scilab
mask_two_blobs   = [%t, %t, %f, %t, %t;
                     %t, %t, %f, %t, %t;
                     %f, %f, %f, %f, %f;
                     %t, %t, %f, %t, %t;
                     %t, %t, %f, %t, %t];

marker_one_seed  = [%t, %f, %f, %f, %f;
                     %f, %f, %f, %f, %f;
                     %f, %f, %f, %f, %f;
                     %f, %f, %f, %f, %f;
                     %f, %f, %f, %f, %f];

res = imreconstruct(marker_one_seed, mask_two_blobs);
disp(res);
```

**Expected output(`res`):**
```scilab
T T F F F
T T F F F
F F F F F
F F F F F
F F F F F
```