// ============================================================
// TEST SUITE: houghpeaks
// Run after loading with:
//   exec('hough.sci', -1)
//   exec('houghpeaks.sci', -1)
// ============================================================

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
// TC-01: Default single peak is returned
// With no arguments other than H, exactly 1 peak is returned
// ------------------------------------------------------------
mprintf("--- TC-01: Default Returns One Peak ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
ok = (size(peaks, 1) == 1);
report("Default numpeaks=1 returns exactly 1 row", ok, size(peaks,1), 1);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-02: Peak output has two columns [rho_idx, theta_idx]
// ------------------------------------------------------------
mprintf("\n--- TC-02: Peak Output Has Two Columns ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
ok = (size(peaks, 2) == 2);
report("peaks matrix has exactly 2 columns", ok, size(peaks,2), 2);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-03: Horizontal line peak is at theta index for theta=0
// theta=0 corresponds to a horizontal line
// ------------------------------------------------------------
mprintf("\n--- TC-03: Horizontal Line Peak Theta Index ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H);
peak_theta = theta(peaks(1, 2));
ok = (peak_theta == 0);
report("Horizontal line peak at theta=0", ok, peak_theta, 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-04: numpeaks limits the number of returned peaks
// ------------------------------------------------------------
mprintf("\n--- TC-04: numpeaks Limits Output ---\n");
bw = zeros(101, 101);
bw(25, :) = 1;
bw(75, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1);
ok = (size(peaks, 1) == 1);
report("numpeaks=1 returns only 1 peak even if 2 exist", ok, size(peaks,1), 1);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-05: Two lines produce two peaks when numpeaks=2
// ------------------------------------------------------------
mprintf("\n--- TC-05: Two Lines Give Two Peaks ---\n");
bw = zeros(101, 101);
bw(25, :) = 1;
bw(75, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 2);
ok = (size(peaks, 1) == 2);
report("Two horizontal lines return 2 peaks", ok, size(peaks,1), 2);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-06: Threshold suppresses weak peaks
// Set threshold very high so no peak passes
// ------------------------------------------------------------
mprintf("\n--- TC-06: High Threshold Suppresses All Peaks ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 5, "Threshold", 999999);
ok = isempty(peaks);
report("Threshold higher than max(H) returns empty peaks", ok, size(peaks), [0 0]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-07: Threshold=0 allows all peaks through
// ------------------------------------------------------------
mprintf("\n--- TC-07: Threshold=0 Allows All Peaks ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 1, "Threshold", 0);
ok = (size(peaks, 1) == 1);
report("Threshold=0 does not suppress valid peaks", ok, size(peaks,1), 1);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-08: Custom NHoodSize suppresses nearby peaks
// Two close lines with a large nhoodsize should merge into 1 peak
// ------------------------------------------------------------
mprintf("\n--- TC-08: Large NHoodSize Merges Close Peaks ---\n");
bw = zeros(101, 101);
bw(50, :) = 1;
bw(51, :) = 1;   // very close to row 50
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 2, "NHoodSize", [51, 51]);
ok = (size(peaks, 1) == 1);
report("Large NHoodSize merges adjacent peaks into one", ok, size(peaks,1), 1);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-09: Small NHoodSize allows close peaks to coexist
// ------------------------------------------------------------
mprintf("\n--- TC-09: Small NHoodSize Keeps Close Peaks ---\n");
bw = zeros(101, 101);
bw(30, :) = 1;
bw(70, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 2, "NHoodSize", [3, 3]);
ok = (size(peaks, 1) == 2);
report("Small NHoodSize keeps two well-separated peaks", ok, size(peaks,1), 2);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-10: All-zero H returns empty peaks
// ------------------------------------------------------------
mprintf("\n--- TC-10: All-Zero H Returns Empty ---\n");
H = zeros(100, 180);
peaks = houghpeaks(H, 5);
ok = isempty(peaks);
report("All-zero accumulator returns empty peaks", ok, size(peaks), [0 0]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-11: numpeaks larger than actual peaks returns only what exists
// ------------------------------------------------------------
mprintf("\n--- TC-11: numpeaks Larger Than Available Peaks ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;   // only one strong line
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 10);
ok = (size(peaks, 1) <= 10);
report("numpeaks=10 returns at most 10 rows", ok, size(peaks,1) <= 10, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-12: Peak indices are within valid bounds of H
// ------------------------------------------------------------
mprintf("\n--- TC-12: Peak Indices Within Bounds of H ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
peaks = houghpeaks(H, 3);
[nrho, ntheta] = size(H);
ok = (and(peaks(:,1) >= 1) & and(peaks(:,1) <= nrho) & ...
      and(peaks(:,2) >= 1) & and(peaks(:,2) <= ntheta));
report("All peak indices fall within H dimensions", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-13: Property names are case-insensitive
// ------------------------------------------------------------
mprintf("\n--- TC-13: Case-Insensitive Property Names ---\n");
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
// TC-14: Error on invalid property name
// ------------------------------------------------------------
mprintf("\n--- TC-14: Invalid Property Name Raises Error ---\n");
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
// TC-15: Error on negative threshold
// ------------------------------------------------------------
mprintf("\n--- TC-15: Negative Threshold Raises Error ---\n");
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
// TC-16: Error on non-integer numpeaks
// ------------------------------------------------------------
mprintf("\n--- TC-16: Non-Integer numpeaks Raises Error ---\n");
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
// TC-17: Error on zero numpeaks
// ------------------------------------------------------------
mprintf("\n--- TC-17: Zero numpeaks Raises Error ---\n");
H = ones(50, 180);
caught = %F;
try
    peaks = houghpeaks(H, 0);
catch
    caught = %T;
end
ok = caught;
report("numpeaks=0 raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-18: Error on even NHoodSize (must be odd)
// ------------------------------------------------------------
mprintf("\n--- TC-18: Even NHoodSize Raises Error ---\n");
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
// TC-19: Error on no arguments
// ------------------------------------------------------------
mprintf("\n--- TC-19: No Arguments Raises Error ---\n");
caught = %F;
try
    peaks = houghpeaks();
catch
    caught = %T;
end
ok = caught;
report("No arguments raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-20: Neighbourhood zeroing prevents duplicate peaks
// ------------------------------------------------------------
mprintf("\n--- TC-20: No Duplicate Peaks in Output ---\n");
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
