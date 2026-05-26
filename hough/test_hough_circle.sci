// ============================================================
// TEST SUITE: hough_circle
// Run after loading with:
//   exec('hough_circle.sci', -1)
// ============================================================

exec('hough_circle.sci', -1);

passed = 0;
failed = 0;

function report(name, ok, got, expected)
    if ok then
        mprintf("  [PASS] %s\n", name);
    else
        mprintf("  [FAIL] %s\n", name);
        mprintf("         Expected: "); disp(expected);
        mprintf("         Got:      "); disp(got);
    end
endfunction

// Helper: draw a circle on a blank image
function bw = make_circle_image(rows, cols, cx, cy, r)
    bw = zeros(rows, cols);
    for angle_deg = 0:1:359
        x = round(cx + r * cosd(angle_deg));
        y = round(cy + r * sind(angle_deg));
        if x >= 1 & x <= cols & y >= 1 & y <= rows then
            bw(y, x) = 1;
        end
    end
endfunction

mprintf("\n==========================================\n");
mprintf(" hough_circle — Test Suite\n");
mprintf("==========================================\n\n");


// ------------------------------------------------------------
// TC-01: Accumulator has correct 3-D size for single radius
// size(accum) must be [rows, cols, 1]
// ------------------------------------------------------------
mprintf("--- TC-01: Accumulator Size for Single Radius ---\n");
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, 10);
ok = (size(accum,1) == 50) & (size(accum,2) == 50);
report("accum is 50x50 for single radius", ok, [size(accum,1), size(accum,2)], [50, 50]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-02: Accumulator has correct 3-D size for multiple radii
// size(accum) must be [rows, cols, length(r)]
// ------------------------------------------------------------
mprintf("\n--- TC-02: Accumulator Size for Multiple Radii ---\n");
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, [5, 10, 15]);
ok = isequal(size(accum), [50, 50, 3]);
report("accum is 50x50x3 for 3 radii", ok, size(accum), [50, 50, 3]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-03: Peak of accumulator is near the true circle centre
// For a clean circle the highest vote should be close to (cy,cx)
// ------------------------------------------------------------
mprintf("\n--- TC-03: Peak Near True Circle Centre ---\n");
cx = 30; cy = 30; r_true = 10;
bw = make_circle_image(60, 60, cx, cy, r_true);
accum = hough_circle(bw, r_true);
accum_slice = accum(:,:,1);   // extract 2-D slice first
[peak_val, peak_idx] = max(accum_slice(:));
[peak_row, peak_col] = ind2sub(size(accum_slice), peak_idx);
// Allow a tolerance of 2 pixels
ok = (abs(peak_row - cy) <= 2) & (abs(peak_col - cx) <= 2);
report("Peak within 2px of true centre", ok, [peak_row, peak_col], [cy, cx]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-04: Correct radius slice has the highest total votes
// The slice corresponding to the true radius should accumulate
// more votes than slices for wrong radii
// ------------------------------------------------------------
mprintf("\n--- TC-04: Correct Radius Slice Has Most Votes ---\n");
cx = 25; cy = 25; r_true = 12;
bw = make_circle_image(50, 50, cx, cy, r_true);
r_vec = [8, 12, 16];
accum = hough_circle(bw, r_vec);
slice_peaks = zeros(1, 3);
for k = 1:3
    slice_peaks(k) = max(max(accum(:,:,k)));
end
[dummy, best_r_idx] = max(slice_peaks);
ok = (r_vec(best_r_idx) == r_true);
report("Slice for r=12 has most total votes", ok, r_vec(best_r_idx), r_true);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-05: All-zero image gives all-zero accumulator
// ------------------------------------------------------------
mprintf("\n--- TC-05: All-Zero Image Gives Zero Accumulator ---\n");
bw = zeros(50, 50);
accum = hough_circle(bw, 10);
ok = (max(accum(:)) == 0);
report("All-zero BW produces all-zero accumulator", ok, max(accum(:)), 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-06: Accumulator values are non-negative
// ------------------------------------------------------------
mprintf("\n--- TC-06: Accumulator Values Are Non-Negative ---\n");
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, 10);
ok = (min(accum(:)) >= 0);
report("All accumulator values >= 0", ok, min(accum(:)), 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-07: Single foreground pixel produces votes in a ring
// A single pixel should vote along the circumference of a circle
// centred on itself — the ring in the accumulator should have
// the same number of nonzero cells as the circle filter has 1s
// ------------------------------------------------------------
mprintf("\n--- TC-07: Single Pixel Votes in a Ring Pattern ---\n");
bw = zeros(50, 50);
bw(25, 25) = 1;
r_test = 8;
accum = hough_circle(bw, r_test);
n_votes = sum(accum(:) > 0);
// The circle filter has approximately 2*pi*r nonzero pixels
// We allow a loose check: at least pi*r nonzero cells
ok = (n_votes >= round(%pi * r_test));
report("Single pixel produces ring of votes", ok, n_votes, round(2*%pi*r_test));
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-08: Two circles at different positions produce two peaks
// ------------------------------------------------------------
mprintf("\n--- TC-08: Two Circles Produce Two Peaks ---\n");
bw = zeros(100, 100);
bw = bw + make_circle_image(100, 100, 25, 25, 10);
bw = bw + make_circle_image(100, 100, 75, 75, 10);
bw = (bw > 0);
accum = hough_circle(bw, 10);

// Find top 2 peaks by successively zeroing the neighbourhood
accum_copy = accum(:,:,1);
[v1, idx1] = max(accum_copy(:));
[r1, c1] = ind2sub(size(accum_copy), idx1);
// Zero out neighbourhood of first peak
accum_copy(max(r1-12,1):min(r1+12,100), max(c1-12,1):min(c1+12,100)) = 0;
[v2, idx2] = max(accum_copy(:));
[r2, c2] = ind2sub(size(accum_copy), idx2);

// Both peaks should be within 3px of their true centres
peak1_ok = (abs(r1-25)<=3 & abs(c1-25)<=3) | (abs(r1-75)<=3 & abs(c1-75)<=3);
peak2_ok = (abs(r2-25)<=3 & abs(c2-25)<=3) | (abs(r2-75)<=3 & abs(c2-75)<=3);
ok = peak1_ok & peak2_ok;
report("Two circles detected at correct positions", ok, [r1,c1;r2,c2], [25,25;75,75]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-09: Small radius gives correct accumulator slice size
// ------------------------------------------------------------
mprintf("\n--- TC-09: Small Radius (r=3) ---\n");
bw = make_circle_image(30, 30, 15, 15, 3);
accum = hough_circle(bw, 3);
ok = (size(accum,1) == 30) & (size(accum,2) == 30);
report("r=3 gives correct accumulator rows/cols [30,30]", ok, [size(accum,1), size(accum,2)], [30, 30]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-10: Large radius gives correct accumulator slice size
// ------------------------------------------------------------
mprintf("\n--- TC-10: Large Radius (r=40) ---\n");
bw = make_circle_image(100, 100, 50, 50, 40);
accum = hough_circle(bw, 40);
ok = (size(accum,1) == 100) & (size(accum,2) == 100);
report("r=40 gives correct accumulator rows/cols [100,100]", ok, [size(accum,1), size(accum,2)], [100, 100]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-11: Radius vector as row vector is accepted
// ------------------------------------------------------------
mprintf("\n--- TC-11: Row Vector Radius Accepted ---\n");
bw = make_circle_image(50, 50, 25, 25, 10);
ok = %T;
try
    accum = hough_circle(bw, [8, 10, 12]);
catch
    ok = %F;
end
report("Row vector [8,10,12] accepted without error", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-12: Radius vector as column vector is accepted
// ------------------------------------------------------------
mprintf("\n--- TC-12: Column Vector Radius Accepted ---\n");
bw = make_circle_image(50, 50, 25, 25, 10);
ok = %T;
try
    accum = hough_circle(bw, [8; 10; 12]);
catch
    ok = %F;
end
report("Column vector [8;10;12] accepted without error", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-13: Circle near image border is handled without error
// ------------------------------------------------------------
mprintf("\n--- TC-13: Circle Near Image Border ---\n");
bw = make_circle_image(50, 50, 5, 5, 8);   // centre close to corner
ok = %T;
try
    accum = hough_circle(bw, 8);
catch
    ok = %F;
end
report("Circle near border handled without error", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-14: Numeric (double) input is accepted
// ------------------------------------------------------------
mprintf("\n--- TC-14: Numeric Double Input Accepted ---\n");
bw = double(make_circle_image(50, 50, 25, 25, 10));
ok = %T;
try
    accum = hough_circle(bw, 10);
catch
    ok = %F;
end
report("Double BW matrix accepted without error", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-15: Boolean input is accepted
// ------------------------------------------------------------
mprintf("\n--- TC-15: Boolean Input Accepted ---\n");
bw = (make_circle_image(50, 50, 25, 25, 10) ~= 0);
ok = %T;
try
    accum = hough_circle(bw, 10);
catch
    ok = %F;
end
report("Boolean BW matrix accepted without error", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-16: Error on wrong number of arguments
// ------------------------------------------------------------
mprintf("\n--- TC-16: Wrong Argument Count Raises Error ---\n");
caught = %F;
try
    accum = hough_circle(zeros(50,50));
catch
    caught = %T;
end
ok = caught;
report("Missing radius raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-17: Error on 3-D input image
// ------------------------------------------------------------
mprintf("\n--- TC-17: 3-D Input Raises Error ---\n");
caught = %F;
try
    bw_3d = ones(10, 10, 3);
    accum = hough_circle(bw_3d, 5);
catch
    caught = %T;
end
ok = caught;
report("3-D BW input raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-18: Error on negative radius
// ------------------------------------------------------------
mprintf("\n--- TC-18: Negative Radius Raises Error ---\n");
caught = %F;
try
    accum = hough_circle(zeros(50,50), -5);
catch
    caught = %T;
end
ok = caught;
report("Negative radius raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-19: Error on non-vector radius (matrix)
// ------------------------------------------------------------
mprintf("\n--- TC-19: Matrix Radius Raises Error ---\n");
caught = %F;
try
    accum = hough_circle(zeros(50,50), [5,10; 15,20]);
catch
    caught = %T;
end
ok = caught;
report("Matrix radius raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-20: Peak vote count increases with circle completeness
// A full circle should get more votes than a partial arc
// ------------------------------------------------------------
mprintf("\n--- TC-20: Full Circle Gets More Votes Than Arc ---\n");
// Full circle
bw_full = make_circle_image(60, 60, 30, 30, 12);
accum_full = hough_circle(bw_full, 12);
[peak_full, dummy] = max(accum_full(:));

// Partial arc: only top half of the same circle
bw_arc = zeros(60, 60);
for angle_deg = 0:1:179   // only top 180 degrees
    x = round(30 + 12 * cosd(angle_deg));
    y = round(30 + 12 * sind(angle_deg));
    if x >= 1 & x <= 60 & y >= 1 & y <= 60 then
        bw_arc(y, x) = 1;
    end
end
accum_arc = hough_circle(bw_arc, 12);
[peak_arc, dummy] = max(accum_arc(:));

ok = (peak_full > peak_arc);
report("Full circle peak > partial arc peak", ok, [peak_full, peak_arc], "full > arc");
if ok then passed = passed+1; else failed = failed+1; end


// ============================================================
// Summary
// ============================================================
total = passed + failed;
mprintf("\n==========================================\n");
mprintf(" Results: %d / %d passed\n", passed, total);
if failed == 0 then
    mprintf(" All tests passed.\n");
else
    mprintf(" %d test(s) FAILED.\n", failed);
end
mprintf("==========================================\n\n");
