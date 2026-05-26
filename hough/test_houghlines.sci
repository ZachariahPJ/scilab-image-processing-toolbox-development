// ============================================================
// TEST SUITE: houghlines
// Run after loading with:
//   exec('hough.sci', -1)
//   exec('houghpeaks.sci', -1)
//   exec('houghlines.sci', -1)
// ============================================================

exec('hough.sci', -1);
exec('houghpeaks.sci', -1);
exec('houghlines.sci', -1);

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

mprintf("\n==========================================\n");
mprintf(" houghlines — Test Suite\n");
mprintf("==========================================\n\n");


// ------------------------------------------------------------
// TC-01: Basic output struct has correct fields
// A detected line must have point1, point2, theta, rho fields
// ------------------------------------------------------------
mprintf("--- TC-01: Output Struct Has Correct Fields ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
ok = %F;
if length(lines) > 0 then
    fnames = fieldnames(lines(1));
    ok = or(fnames == "point1") & or(fnames == "point2") & ...
         or(fnames == "theta")  & or(fnames == "rho");
end
report("Output struct has point1, point2, theta, rho fields", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-02: Long horizontal line is detected
// A full-width horizontal line should produce at least one segment
// ------------------------------------------------------------
mprintf("\n--- TC-02: Long Horizontal Line Detected ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
ok = (length(lines) >= 1);
report("Horizontal line produces at least one segment", ok, length(lines), 1);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-03: theta field matches the peak angle
// The theta stored in each line struct must match theta at the peak index
// ------------------------------------------------------------
mprintf("\n--- TC-03: theta Field Matches Peak Angle ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
ok = %F;
if length(lines) > 0 then
    ok = (lines(1).theta == theta(peaks(1,2)));
end
report("lines.theta matches theta at peak index", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-04: rho field matches the peak distance
// ------------------------------------------------------------
mprintf("\n--- TC-04: rho Field Matches Peak Distance ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
ok = %F;
if length(lines) > 0 then
    ok = (lines(1).rho == rho(peaks(1,1)));
end
report("lines.rho matches rho at peak index", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-05: point1 and point2 are 1x2 vectors
// ------------------------------------------------------------
mprintf("\n--- TC-05: point1 and point2 Are 1x2 Vectors ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
ok = %F;
if length(lines) > 0 then
    ok = isequal(size(lines(1).point1), [1, 2]) & ...
         isequal(size(lines(1).point2), [1, 2]);
end
report("point1 and point2 are both 1x2 vectors", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-06: Short line below MinLength is not returned
// Set MinLength very high so no segment qualifies
// ------------------------------------------------------------
mprintf("\n--- TC-06: Segment Below MinLength Not Returned ---\n");
bw = zeros(50, 50);
bw(25, 20:25) = 1;   // short 6-pixel segment
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 100);
ok = (length(lines) == 0);
report("Segment shorter than MinLength not returned", ok, length(lines), 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-07: FillGap merges two close segments into one
// Two short segments with a small gap should merge
// ------------------------------------------------------------
mprintf("\n--- TC-07: FillGap Merges Close Segments ---\n");
bw = zeros(101, 101);
bw(51, 1:40)  = 1;
bw(51, 45:101) = 1;   // gap of 4 pixels between col 40 and 45
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines_small_gap = houghlines(bw, theta, rho, peaks, "FillGap", 10, "MinLength", 10);
lines_large_gap = houghlines(bw, theta, rho, peaks, "FillGap", 2,  "MinLength", 10);
ok = (length(lines_small_gap) <= length(lines_large_gap));
report("Larger FillGap merges segments, smaller keeps them separate", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-08: Two separate lines produce two sets of segments
// ------------------------------------------------------------
mprintf("\n--- TC-08: Two Lines Produce Two Segment Sets ---\n");
bw = zeros(101, 101);
bw(25, :) = 1;
bw(75, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 2);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
ok = (length(lines) >= 2);
report("Two horizontal lines produce at least 2 segments", ok, length(lines), 2);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-09: All-zero image returns no lines
// ------------------------------------------------------------
mprintf("\n--- TC-09: All-Zero Image Returns No Lines ---\n");
bw = zeros(50, 50);
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
ok = (length(lines) == 0);
report("All-zero image returns empty lines struct", ok, length(lines), 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-10: Default FillGap and MinLength are applied
// Calling without property pairs should not error
// ------------------------------------------------------------
mprintf("\n--- TC-10: Default Parameters Applied Without Error ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
ok = %T;
try
    lines = houghlines(bw, theta, rho, peaks);
catch
    ok = %F;
end
report("No error when called with only 4 arguments", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-11: Case-insensitive property names
// ------------------------------------------------------------
mprintf("\n--- TC-11: Case-Insensitive Property Names ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
ok = %T;
try
    lines = houghlines(bw, theta, rho, peaks, "FILLGAP", 5, "MINLENGTH", 10);
catch
    ok = %F;
end
report("Uppercase property names accepted", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-12: Error on invalid property name
// ------------------------------------------------------------
mprintf("\n--- TC-12: Invalid Property Name Raises Error ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
caught = %F;
try
    lines = houghlines(bw, theta, rho, peaks, "FakeProperty", 5);
catch
    caught = %T;
end
ok = caught;
report("Unknown property name raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-13: Error on negative FillGap
// ------------------------------------------------------------
mprintf("\n--- TC-13: Negative FillGap Raises Error ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
caught = %F;
try
    lines = houghlines(bw, theta, rho, peaks, "FillGap", -5);
catch
    caught = %T;
end
ok = caught;
report("Negative FillGap raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-14: Error on negative MinLength
// ------------------------------------------------------------
mprintf("\n--- TC-14: Negative MinLength Raises Error ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
caught = %F;
try
    lines = houghlines(bw, theta, rho, peaks, "MinLength", -10);
catch
    caught = %T;
end
ok = caught;
report("Negative MinLength raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-15: Error on too few arguments (less than 4)
// ------------------------------------------------------------
mprintf("\n--- TC-15: Too Few Arguments Raises Error ---\n");
caught = %F;
try
    lines = houghlines(ones(10,10), -90:89);
catch
    caught = %T;
end
ok = caught;
report("Fewer than 4 arguments raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-16: Error on odd number of property/value arguments (5 total)
// ------------------------------------------------------------
mprintf("\n--- TC-16: Odd Property Arguments Raises Error ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
caught = %F;
try
    lines = houghlines(bw, theta, rho, peaks, "FillGap");
catch
    caught = %T;
end
ok = caught;
report("5 total arguments (odd property count) raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-17: Error on non-numeric BW
// ------------------------------------------------------------
mprintf("\n--- TC-17: Non-Numeric BW Raises Error ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
caught = %F;
try
    lines = houghlines("hello", theta, rho, peaks);
catch
    caught = %T;
end
ok = caught;
report("String BW raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-18: Error on peaks with wrong number of columns
// peaks must be Nx2
// ------------------------------------------------------------
mprintf("\n--- TC-18: Wrong Peaks Dimensions Raises Error ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
caught = %F;
try
    bad_peaks = [1, 2, 3];   // 1x3 instead of Nx2
    lines = houghlines(bw, theta, rho, bad_peaks);
catch
    caught = %T;
end
ok = caught;
report("Peaks with 3 columns raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// TC-19 fix
mprintf("\n--- TC-19: Segment Endpoints Within Image Bounds ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", 10);
[nrows, ncols] = size(bw);
all_in_bounds = %T;
if length(lines) == 0 then
    all_in_bounds = %F;
else
    for k = 1:length(lines)
        p1 = lines(k).point1;
        p2 = lines(k).point2;
        if p1(1)<1 | p1(1)>ncols | p1(2)<1 | p1(2)>nrows then
            all_in_bounds = %F;
        end
        if p2(1)<1 | p2(1)>ncols | p2(2)<1 | p2(2)>nrows then
            all_in_bounds = %F;
        end
    end
end
ok = all_in_bounds;
report("All segment endpoints lie within image bounds", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// TC-20 fix
mprintf("\n--- TC-20: All Returned Segments Meet MinLength ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
min_len = 10;
lines = houghlines(bw, theta, rho, peaks, "FillGap", 5, "MinLength", min_len);
all_long_enough = %T;
if length(lines) == 0 then
    all_long_enough = %F;
else
    for k = 1:length(lines)
        seg_len = sqrt(sum((lines(k).point2 - lines(k).point1).^2));
        if seg_len < min_len then
            all_long_enough = %F;
        end
    end
end
ok = all_long_enough;
report("All returned segments meet MinLength requirement", ok, ok, %T);
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
