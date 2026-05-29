// ============================================================
// TEST SUITE: houghpeaks
// Run after loading with:
//   exec('hough_line.sci', -1)
//   exec('hough.sci', -1)
//   exec('houghpeaks.sci', -1)
// ============================================================

exec('hough_line.sci', -1);
exec('hough.sci', -1);
exec('houghpeaks.sci', -1);

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
mprintf(" houghpeaks — Test Suite\n");
mprintf("==========================================\n\n");


// ------------------------------------------------------------
// TC-01: Default returns exactly one peak
// ------------------------------------------------------------
mprintf("--- TC-01: Default Returns One Peak ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
ok = (size(peaks, 1) == 1) & (size(peaks, 2) == 2);
report("Default call returns 1 row, 2 columns", ok, size(peaks), [1, 2]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-02: Horizontal line peak is at theta=0
// ------------------------------------------------------------
mprintf("\n--- TC-02: Horizontal Line Peak at theta=0 ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
ok = (theta(peaks(1,2)) == 0);
report("Horizontal line peak at theta=0", ok, theta(peaks(1,2)), 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-03: numpeaks limits the number of returned peaks
// ------------------------------------------------------------
mprintf("\n--- TC-03: numpeaks Limits Output ---\n");
bw = zeros(101, 101);
bw(25, :) = 1;
bw(75, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
ok = (size(peaks, 1) == 1);
report("numpeaks=1 returns only 1 peak", ok, size(peaks,1), 1);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-04: Two lines give two peaks when numpeaks=2
// ------------------------------------------------------------
mprintf("\n--- TC-04: Two Lines Give Two Peaks ---\n");
bw = zeros(101, 101);
bw(25, :) = 1;
bw(75, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 2);
ok = (size(peaks, 1) == 2);
report("Two horizontal lines return 2 peaks", ok, size(peaks,1), 2);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-05: High threshold suppresses all peaks
// ------------------------------------------------------------
mprintf("\n--- TC-05: High Threshold Suppresses All Peaks ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 5, "Threshold", 999999);
ok = isempty(peaks);
report("Threshold above max(H) returns empty peaks", ok, isempty(peaks), %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-06: All-zero H returns empty peaks
// ------------------------------------------------------------
mprintf("\n--- TC-06: All-Zero H Returns Empty ---\n");
H = zeros(100, 180);
peaks = houghpeaks(H, 5);
ok = isempty(peaks);
report("All-zero accumulator returns empty peaks", ok, isempty(peaks), %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-07: Large NHoodSize merges adjacent peaks into one
// ------------------------------------------------------------
mprintf("\n--- TC-07: Large NHoodSize Merges Close Peaks ---\n");
bw = zeros(101, 101);
bw(50, :) = 1;
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 2, "NHoodSize", [51, 51]);
ok = (size(peaks, 1) == 1);
report("Large NHoodSize merges adjacent peaks", ok, size(peaks,1), 1);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-08: Peak indices are within valid bounds of H
// ------------------------------------------------------------
mprintf("\n--- TC-08: Peak Indices Within H Bounds ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 3);
[nrho, ntheta] = size(H);
ok = and(peaks(:,1) >= 1) & and(peaks(:,1) <= nrho) & ...
     and(peaks(:,2) >= 1) & and(peaks(:,2) <= ntheta);
report("All peak indices within H dimensions", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-09: No duplicate peaks in output
// ------------------------------------------------------------
mprintf("\n--- TC-09: No Duplicate Peaks ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 3);
n_peaks = size(peaks, 1);
has_duplicates = %F;
for i = 1:n_peaks
    for j = i+1:n_peaks
        if isequal(peaks(i,:), peaks(j,:)) then
            has_duplicates = %T;
        end
    end
end
ok = ~has_duplicates;
report("No duplicate peak locations in output", ok, has_duplicates, %F);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-10: Case-insensitive property names
// ------------------------------------------------------------
mprintf("\n--- TC-10: Case-Insensitive Property Names ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
ok = %T;
try
    peaks = houghpeaks(H, 1, "THRESHOLD", 0);
catch
    ok = %F;
end
report("THRESHOLD (uppercase) accepted without error", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-11: Invalid property name raises error
// ------------------------------------------------------------
mprintf("\n--- TC-11: Invalid Property Raises Error ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
caught = %F;
try
    peaks = houghpeaks(H, 1, "FakeProperty", 1);
catch
    caught = %T;
end
ok = caught;
report("Unknown property raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-12: Negative threshold raises error
// ------------------------------------------------------------
mprintf("\n--- TC-12: Negative Threshold Raises Error ---\n");
H = ones(50, 180);
caught = %F;
try
    peaks = houghpeaks(H, 1, "Threshold", -1);
catch
    caught = %T;
end
ok = caught;
report("Negative threshold raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-13: Non-integer numpeaks raises error
// ------------------------------------------------------------
mprintf("\n--- TC-13: Non-Integer numpeaks Raises Error ---\n");
H = ones(50, 180);
caught = %F;
try
    peaks = houghpeaks(H, 2.5);
catch
    caught = %T;
end
ok = caught;
report("numpeaks=2.5 raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-14: Even NHoodSize raises error
// ------------------------------------------------------------
mprintf("\n--- TC-14: Even NHoodSize Raises Error ---\n");
H = ones(50, 180);
caught = %F;
try
    peaks = houghpeaks(H, 1, "NHoodSize", [4, 4]);
catch
    caught = %T;
end
ok = caught;
report("Even NHoodSize raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-15: No arguments raises error
// ------------------------------------------------------------
mprintf("\n--- TC-15: No Arguments Raises Error ---\n");
caught = %F;
try
    peaks = houghpeaks();
catch
    caught = %T;
end
ok = caught;
report("No arguments raises error", ok, caught, %T);
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
