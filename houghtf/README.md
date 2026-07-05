# `houghtf` — Scilab Function Reference

## 1. Description

`houghtf` is a generalised Hough transform dispatcher that routes to the appropriate detection backend based on a method string. It provides a single unified entry point for both straight-line detection (via `hough_line`) and circular feature detection (via `hough_circle`), making it easier to switch between transform types without changing calling code.

```
houghtf(bw, ...)
    │
    ├── method = "line"   →  hough_line(bw, theta_oct)
    │
    └── method = "circle" →  hough_circle(bw, r)
```

If no method string is supplied, `"line"` is used by default.

---

## 2. Calling Sequence

```scilab
[accum, R] = houghtf(bw)
[accum, R] = houghtf(bw, theta_oct)
[accum, R] = houghtf(bw, "line")
[accum, R] = houghtf(bw, "line", theta_oct)
accum      = houghtf(bw, "circle", r)
```

---

## 3. Dependencies
Requires the `hough_line` and `hough_circle` functions.

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `bw` | 2-D numeric or boolean matrix | ✓ | Binary input image. Nonzero pixels are foreground. |
| `method` | String | — | `"line"` (default) or `"circle"`. Case-insensitive. |
| `theta_oct` | Real vector (radians) | — | Angles in **radians** in Octave convention for the line method. Default: `-90:1:89` degrees converted to radians. |
| `r` | Positive scalar or vector | — | Radius or radii in pixels for the circle method. Required when `method = "circle"`. |
| `accum` | Matrix or 3-D array | — | **Output.** Hough accumulator. For lines: `length(rho) × length(theta)`. For circles: `rows × cols × length(r)`. |
| `R` | Column vector or `[]` | — | **Output.** Rho axis for the line method. Empty `[]` for the circle method. |
