# `colorgradient` — Scilab Function Reference

## 1. Description

`colorgradient` generates a smooth, multi-color gradient colormap by linearly interpolating between a set of user-defined anchor colors. It is useful for custom visualizations where standard colormaps do not adequately highlight specific data ranges.

Interpolation is performed independently across the **Red**, **Green**, and **Blue** channels, ensuring seamless transitions between anchor colors.

---

## 2. Calling Sequence

```scilab
map = colorgradient(C)
map = colorgradient(C, w)
map = colorgradient(C, w, n)
colorgradient(...)   // applies gradient directly to current figure's colormap
```

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `C` | Matrix (`m × 3`) | ✓ | Anchor colors. Each row is an RGB triplet with values in `[0, 1]`. |
| `w` | Vector (`m−1`) | — | Relative weights controlling the length of each color transition. Defaults to `ones(m-1, 1)` (equal spacing). |
| `n` | Integer | — | Total number of rows in the output colormap. Defaults to the current colormap size (typically 64). |
| `map` | Matrix (`n × 3`) | — | **Output.** The generated colormap. Returned only when an output variable is assigned; otherwise applied directly via `colormap()`. |

> **Note:** If `w` is a scalar, it is interpreted as `n` and equal weights are assumed.

---

## 4. Test Cases

The following test cases verify the correctness of the `colorgradient` implementation. Run them directly in the Scilab console.

---

### Test Case 1 — Basic Two-Color Gradient (Blue → Red)

Verifies linear interpolation between two primary colors.

```scilab
map = colorgradient([0,0,1; 1,0,0], 1, 10)
```

**Expected output:** A `10×3` matrix where:
- Row 1 is `[0, 0, 1]` (pure blue)
- Row 10 is `[1, 0, 0]` (pure red)
- The red channel (column 1) increases by `≈0.111` per row
- The blue channel (column 3) decreases by `≈0.111` per row

---

### Test Case 2 — Multi-Anchor Gradient (Traffic Light)

Verifies correct handling of more than two anchor colors.

```scilab
map = colorgradient([0,1,0; 1,1,0; 1,0,0], [1,1], 21)
```

**Expected output:** A `21×3` matrix where:
- Rows 1–11 transition from green `[0,1,0]` to yellow `[1,1,0]`
- Rows 11–21 transition from yellow `[1,1,0]` to red `[1,0,0]`
- Row 11 (midpoint) is exactly `[1, 1, 0]`

---

### Test Case 3 — Default Arguments (Grayscale)

Verifies that default values for `w` and `n` are applied correctly.

```scilab
map = colorgradient([1,1,1; 0,0,0])
```

**Expected output:** A `64×3` matrix (default `n`) transitioning from white to black. All three columns in each row hold equal values (e.g., row 32 ≈ `[0.5, 0.5, 0.5]`).

---

### Test Case 4 — Weighted Intervals

Verifies that `w` correctly stretches specific color transitions.

```scilab
map = colorgradient([1,1,1; 0,1,0; 0,0,0], [4, 1], 50)
```

**Expected output:** A `50×3` matrix where:
- The white → green transition occupies approximately **40 rows** (4/5 of the map)
- The green → black transition occupies approximately **10 rows** (1/5 of the map)

---

### Test Case 5 — Error Handling (Dimension Mismatch)

Verifies that invalid input is caught and reported clearly.

```scilab
colorgradient([1,0,0; 0,1,0], [1, 2, 3], 10)
```

**Expected output:** Scilab throws an error:
```
Must have one weight for each color interval
```

---

## 5. Visualization Example

The following snippet applies a custom gradient to the active figure and displays it as a colorbar. Use this to visually verify the function's output.

```scilab
// Generate a 100-step Blue → Red gradient
my_map = colorgradient([0,0,1; 1,0,0], 1, 100);

// Apply to the current figure
f = gcf();
f.color_map = my_map;

// Display a colorbar
colorbar(0, 1);
```

**Tip:** Combine with `surf()` or `Sgrayplot()` to see the gradient applied to real data:

```scilab
t = linspace(0, 2*%pi, 100);
[X, Y] = meshgrid(t, t);
Z = sin(X) .* cos(Y);

my_map = colorgradient([0,0,1; 1,1,1; 1,0,0], [1,1], 128);
f = gcf();
f.color_map = my_map;

Sgrayplot(t, t, Z);
colorbar(min(Z(:)), max(Z(:)));
```

---

## 6. See Also

- [`colormap`](https://help.scilab.org/colormap) — Get or set the current figure's colormap
- [`colorbar`](https://help.scilab.org/colorbar) — Display a colorbar legend
- [`linspace`](https://help.scilab.org/linspace) — Generate linearly spaced vectors