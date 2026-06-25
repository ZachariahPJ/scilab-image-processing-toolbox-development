# `hough_line` — Scilab Function Reference

## 1. Description

`hough_line` is the accumulator engine of the Hough transform. It takes a binary image and a vector of angles in radians, and returns the Hough accumulator matrix `H` and the corresponding `rho` axis.

This function replicates the behaviour of `hough_line.cc` from the Octave `image` package, reimplemented entirely in standard Scilab. It is called internally by `hough.sci` and can also be used directly when angle conversion has already been handled externally.

For each foreground pixel at 0-based coordinates `(row, col)`, the perpendicular distance from the origin to the line at each angle is computed as:

```
rho = col * cos(theta) + row * sin(theta)
```

The result is rounded to the nearest integer and used to increment the corresponding cell in the accumulator `H`. After all pixels are processed, high values in `H` indicate strong line candidates at those `(rho, theta)` coordinates.

---

## 2. Calling Sequence

```scilab
[H, rho] = hough_line(bw, theta_oct)
```

---

## 3. Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `bw` | 2-D boolean or numeric matrix | ✓ | Binary input image. Nonzero pixels are treated as foreground and cast votes into the accumulator. |
| `theta_oct` | Real vector (radians) | ✓ | Angles to test, in **radians**, measured counter-clockwise from the horizontal axis (Octave convention). |
| `H` | Matrix (`length(rho) × length(theta_oct)`) | — | **Output.** Hough accumulator. `H(i,k)` is the number of foreground pixels consistent with a line at `rho(i)` and `theta_oct(k)`. |
| `rho` | Row vector | — | **Output.** Rho axis values in pixels, ranging from `-ceil(D)` to `+ceil(D)` where `D` is the image diagonal length. |

---

## 4. Relationship to `hough`

`hough_line` is the low-level engine. It expects angles already converted to radians in Octave convention and performs no argument parsing or validation.

`hough` is the high-level front-end. It handles all argument parsing, property/value pairs, and angle unit conversion before passing the prepared inputs to `hough_line`.

```
User calls hough()
    │
    ├── validates bw
    ├── parses ThetaResolution / Theta / RhoResolution
    ├── converts theta: (-theta + 90) * (pi/180)
    │
    └── calls hough_line(bw, theta_oct)
            │
            ├── builds rho axis
            ├── finds foreground pixels with find()
            ├── precomputes cos and sin
            └── runs accumulator voting loop
                    │
                    └── returns [H, rho]
```

If you already have angles in radians in Octave convention, `hough_line` can be called directly without going through `hough`.

---

## 5. Example Usage

```scilab
// Create a simple 5x5 diagonal line matrix
bw = [1 0 0 0 0;
      0 1 0 0 0;
      0 0 1 0 0;
      0 0 0 1 0;
      0 0 0 0 1];

// Define test angles in radians
theta = [-0.5, 0, 0.5];

// Compute Hough Line accumulator
[H, rho] = hough_line(bw, theta);

// Display Accumulator Dimensions (Expect 1x13 for a 5x5 image)
disp("Rho vector size:");
disp(size(rho));
```

**Expected output:**
```
1.   13.

0.   0.   0.
0.   0.   0.
2.   1.   1.
2.   1.   1.
1.   1.   0.
0.   1.   1.
```

---

## 6. Test Cases

The following 5 test cases cover accumulator dimensions, geometric correctness, and edge inputs. Load the function before running:

```scilab
exec('hough_line.sci', -1)
```

---

### TC-01 — All-Zero Image Gives Zero Accumulator

Verifies that an image with no foreground pixels produces an all-zero accumulator with valid dimensions.

```scilab
I1 = zeros(5, 5);
[J1, bins1] = hough_line(I1);
mprintf("max(J1) = %d\n", max(J1(:)));
mprintf("bins span: [%d, %d]  size(J): [%d %d]\n", bins1(1), bins1($), size(J1,1), size(J1,2));
```

**Expected output:** `max(J1) = 0`, bins and accumulator dimensions consistent with a 5×5 image diagonal.

---

### TC-02 — Single Pixel Casts Exactly One Vote Per Theta

Verifies that a single foreground pixel at `(3,3)` casts exactly one vote into one rho-bin for each supplied theta, leaving all other bins at zero.

```scilab
I2 = zeros(5, 5);
I2(3, 3) = 1;
thetas2 = [0; %pi/4; %pi/2];
[J2, bins2] = hough_line(I2, thetas2);
mprintf("Total votes: %d\n", sum(J2));
mprintf("Votes per theta column: %d  %d  %d\n", sum(J2(:,1)), sum(J2(:,2)), sum(J2(:,3)));
```

**Expected output:** `Total votes: 3`, each column sum equals `1`.

---

### TC-03 — Horizontal Line Concentrates All Votes in One Rho-Bin

Verifies that at `theta = 0`, every pixel in a horizontal row maps to the same rho value, so all votes accumulate in a single bin and all other bins remain zero.

```scilab
I3 = zeros(7, 7);
I3(4, :) = 1;
thetas3 = [0];
[J3, bins3] = hough_line(I3, thetas3);
rho_val  = 3;
bin_idx3 = (rho_val - bins3(1)) + 1;
mprintf("Votes in expected bin: %d\n", J3(bin_idx3, 1));
mprintf("Votes elsewhere: %d\n", sum(J3(:)) - J3(bin_idx3, 1));
```

**Expected output:** `Votes in expected bin: 7`, `Votes elsewhere: 0`.

---

### TC-04 — Default Theta Range Produces Correct Accumulator Dimensions

Verifies that when `theta` is omitted, the output bins vector and accumulator matrix have dimensions consistent with the formula `2·ceil(diag) + 1`, where `diag` is the image diagonal length.

```scilab
r4 = 10; c4 = 15;
I4 = zeros(r4, c4);
[J4, bins4] = hough_line(I4);
diag_len = sqrt((r4-1)^2 + (c4-1)^2);
nr_bins_expected = 2*ceil(diag_len) + 1;
thetas_default = (-%pi/2 : %pi/180 : %pi/2)';
mprintf("bins length — got: %d expected: %d\n", length(bins4), nr_bins_expected);
mprintf("accum rows — got: %d expected: %d\n", size(J4,1), nr_bins_expected);
mprintf("accum cols — got: %d expected: %d\n", size(J4,2), length(thetas_default));
```

**Expected output:** All three `got` values equal the corresponding `expected` values.

---

### TC-05 — Main Diagonal at θ=π/4 Assigns Each Pixel to a Distinct Bin

Verifies that for a 6×6 main diagonal image at `theta = π/4`, the total vote count equals the number of foreground pixels and no two pixels share the same rho-bin (peak bin count = 1).

```scilab
n5 = 6;
I5 = zeros(n5, n5);
for k = 1:n5
    I5(k, k) = 1;
end
thetas5 = [%pi/4];
[J5, bins5] = hough_line(I5, thetas5);
mprintf("Total votes: %d  (expected %d)\n", sum(J5), n5);
mprintf("Max bin count: %d  (expected 1)\n", max(J5(:)));
```

**Expected output:** `Total votes: 6`, `Max bin count: 1`.
