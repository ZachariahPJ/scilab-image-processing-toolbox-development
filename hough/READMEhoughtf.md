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

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `bw` | 2-D numeric or boolean matrix | ✓ | Binary input image. Nonzero pixels are foreground. |
| `method` | String | — | `"line"` (default) or `"circle"`. Case-insensitive. |
| `theta_oct` | Real vector (radians) | — | Angles in **radians** in Octave convention for the line method. Default: `-90:1:89` degrees converted to radians. |
| `r` | Positive scalar or vector | — | Radius or radii in pixels for the circle method. Required when `method = "circle"`. |
| `accum` | Matrix or 3-D array | — | **Output.** Hough accumulator. For lines: `length(rho) × length(theta)`. For circles: `rows × cols × length(r)`. |
| `R` | Column vector or `[]` | — | **Output.** Rho axis for the line method. Empty `[]` for the circle method. |

> **Note:** The method string is detected by checking whether the second argument is a string (`type == 10`). If the second argument is numeric it is treated as `theta_oct` and the method defaults to `"line"`.

> **Note:** `theta_oct` must be in **radians** in Octave convention (counter-clockwise from horizontal). If you have theta in MATLAB/Octave degrees, convert first: `theta_oct = (-theta_deg + 90) * (%pi / 180)`.

---

## 4. How It Works

### 4.1 Argument Parsing

`houghtf` inspects the second argument using `type()` to decide how to route:

- If `type(varargin(1)) == 10` (string) — it is a method name; remaining arguments are passed to the backend.
- Otherwise — all extra arguments are treated as backend parameters and `"line"` is used.

This allows both `houghtf(bw, theta)` and `houghtf(bw, "line", theta)` to work correctly.

### 4.2 Line Method

Calls `hough_line(bw, theta_oct)`. If no theta is supplied, a default spanning `-90:1:89` degrees converted to Octave radians is used:

```scilab
default_theta = (-(-90:1:89) + 90) * (%pi / 180);
```

Returns `[accum, R]` where `accum` is the `length(R) × length(theta_oct)` accumulator and `R` is the rho axis.

### 4.3 Circle Method

Calls `hough_circle(bw, r)`. A radius argument is required — omitting it raises an error. Returns `accum` as a 3-D array of size `[rows, cols, length(r)]`. `R` is set to `[]`.