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
// TC-01: Accumulator has correct row and column count
// For a single radius Scilab drops the trailing singleton
// dimension so check size(accum,1) and size(accum,2) separately
// ------------------------------------------------------------
mprintf("--- TC-01: Accumulator Size for Single Radius ---\n");
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, 10);
ok = (size(accum,1) == 50) & (size(accum,2) == 50);
report("accum is 50 rows x 50 cols for single radius", ok, [size(accum,1), size(accum,2)], [50, 50]);
if ok then passed = passed+1; else failed = failed+1; end

// ------------------------------------------------------------
// TC-02: Accumulator has correct 3-D size for multiple radii
// ------------------------------------------------------------
mprintf("\n--- TC-02: Accumulator Size for Multiple Radii ---\n");
bw = make_circle_image(50, 50, 25, 25, 10);
accum = hough_circle(bw, [5, 10, 15]);
ok = isequal(size(accum), [50, 50, 3]);
report("accum is 50x50x3 for 3 radii", ok, size(accum), [50, 50, 3]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-03: Peak is within 2 pixels of the true circle centre
// ------------------------------------------------------------
mprintf("\n--- TC-03: Peak Near True Circle Centre ---\n");
cx = 30; cy = 30; r_true = 10;
bw = make_circle_image(60, 60, cx, cy, r_true);
accum = hough_circle(bw, r_true);
accum_slice = accum(:,:,1);
[peak_val, peak_idx] = max(accum_slice(:));
[peak_row, peak_col] = ind2sub(size(accum_slice), peak_idx);
ok = (abs(peak_row - cy) <= 2) & (abs(peak_col - cx) <= 2);
report("Peak within 2px of true centre", ok, [peak_row, peak_col], [cy, cx]);
if ok then passed = passed+1; else failed = failed+1; end

// ------------------------------------------------------------
// TC-04: Correct radius slice has the highest peak value
// Uses peak value comparison, not slice sum
// ------------------------------------------------------------
mprintf("\n--- TC-04: Correct Radius Slice Has Highest Peak ---\n");
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
report("Slice for r=12 has highest peak value", ok, r_vec(best_r_idx), r_true);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-05: All-zero image gives all-zero accumulator
// ------------------------------------------------------------
mprintf("\n--- TC-05: All-Zero Image ---\n");
bw = zeros(50, 50);
accum = hough_circle(bw, 10);
ok = (max(accum(:)) == 0);
report("All-zero BW gives all-zero accumulator", ok, max(accum(:)), 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-06: Two circles produce two distinct peaks
// ------------------------------------------------------------
mprintf("\n--- TC-06: Two Circles Produce Two Peaks ---\n");
bw = zeros(100, 100);
bw = bw + make_circle_image(100, 100, 25, 25, 10);
bw = bw + make_circle_image(100, 100, 75, 75, 10);
bw = (bw > 0);
accum = hough_circle(bw, 10);
accum_copy = accum(:,:,1);
[v1, idx1] = max(accum_copy(:));
[r1, c1] = ind2sub(size(accum_copy), idx1);
accum_copy(max(r1-12,1):min(r1+12,100), max(c1-12,1):min(c1+12,100)) = 0;
[v2, idx2] = max(accum_copy(:));
[r2, c2] = ind2sub(size(accum_copy), idx2);
peak1_ok = (abs(r1-25)<=3 & abs(c1-25)<=3) | (abs(r1-75)<=3 & abs(c1-75)<=3);
peak2_ok = (abs(r2-25)<=3 & abs(c2-25)<=3) | (abs(r2-75)<=3 & abs(c2-75)<=3);
ok = peak1_ok & peak2_ok;
report("Two circles detected at correct positions", ok, [r1,c1;r2,c2], [25,25;75,75]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-07: Full circle gets more votes than a partial arc
// ------------------------------------------------------------
mprintf("\n--- TC-07: Full Circle Beats Partial Arc ---\n");
bw_full = make_circle_image(60, 60, 30, 30, 12);
accum_full = hough_circle(bw_full, 12);
[peak_full, dummy] = max(accum_full(:));
bw_arc = zeros(60, 60);
for angle_deg = 0:1:179
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

// ------------------------------------------------------------
// TC-08: Circle near image border handled without error
// ------------------------------------------------------------
mprintf("\n--- TC-08: Circle Near Image Border ---\n");
bw = make_circle_image(50, 50, 5, 5, 8);
ok = %T;
try
    accum = hough_circle(bw, 8);
catch
    ok = %F;
end
report("Circle near border handled without error", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end

// ------------------------------------------------------------
// TC-09: Error on wrong number of arguments
// ------------------------------------------------------------
mprintf("\n--- TC-09: Missing Radius Raises Error ---\n");
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
// TC-10: Error on 3-D input image
// ------------------------------------------------------------
mprintf("\n--- TC-10: 3-D Input Raises Error ---\n");
caught = %F;
try
    accum = hough_circle(ones(10,10,3), 5);
catch
    caught = %T;
end
ok = caught;
report("3-D BW input raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-11: Error on negative radius
// ------------------------------------------------------------
mprintf("\n--- TC-11: Negative Radius Raises Error ---\n");
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
// TC-12: Error on matrix radius (must be scalar or vector)
// ------------------------------------------------------------
mprintf("\n--- TC-12: Matrix Radius Raises Error ---\n");
caught = %F;
try
    accum = hough_circle(zeros(50,50), [5,10; 15,20]);
catch
    caught = %T;
end
ok = caught;
report("Matrix radius raises error", ok, caught, %T);
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
