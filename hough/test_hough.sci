// ============================================================
// TEST SUITE: hough + hough_line
// Run after loading both functions with:
//   exec('hough_line.sci', -1)
//   exec('hough.sci', -1)
// ============================================================

exec('hough_line.sci', -1);
exec('hough.sci', -1);

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
mprintf(" hough + hough_line — Test Suite\n");
mprintf("==========================================\n\n");


// ------------------------------------------------------------
// TC-01: Output sizes are correct with default parameters
// H must be length(rho) x length(theta), theta must be 1x180
// ------------------------------------------------------------
mprintf("--- TC-01: Default Output Sizes ---\n");
bw = zeros(100, 100);
bw(50, :) = 1;
[H, theta, rho] = hough(bw);
ok_theta = isequal(size(theta), [1, 180]);
ok_H     = (size(H, 2) == length(theta)) & (size(H, 1) == length(rho));
ok = ok_theta & ok_H;
report("H is length(rho)xlength(theta), theta is 1x180", ok, size(H), [length(rho), length(theta)]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-02: theta default range is -90 to 89 inclusive
// ------------------------------------------------------------
mprintf("\n--- TC-02: Default Theta Range ---\n");
bw = eye(10, 10);
[H, theta, rho] = hough(bw);
ok = (theta(1) == -90) & (theta($) == 89) & (length(theta) == 180);
report("theta runs from -90 to 89, 180 elements", ok, [theta(1), theta($), length(theta)], [-90, 89, 180]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-03: Horizontal line produces a peak at theta=0
// A horizontal line in the image should vote heavily at theta=0
// (which after conversion to Octave convention is theta_oct=90deg=pi/2)
// ------------------------------------------------------------
mprintf("\n--- TC-03: Horizontal Line Peak ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;    // horizontal line through the middle
[H, theta, rho] = hough(bw);
[peak_val, peak_idx] = max(H(:));
[peak_rho_idx, peak_theta_idx] = ind2sub(size(H), peak_idx);
peak_theta = theta(peak_theta_idx);
ok = (peak_theta == 0);
report("Horizontal line peaks at theta=0", ok, peak_theta, 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-04: Vertical line produces a peak at theta=90 or theta=-90
// ------------------------------------------------------------
mprintf("\n--- TC-04: Vertical Line Peak ---\n");
bw = zeros(101, 101);
bw(:, 51) = 1;    // vertical line through the middle
[H, theta, rho] = hough(bw);
[peak_val, peak_idx] = max(H(:));
[peak_rho_idx, peak_theta_idx] = ind2sub(size(H), peak_idx);
peak_theta = theta(peak_theta_idx);
ok = (peak_theta == 90 | peak_theta == -90);
report("Vertical line peaks at theta=90 or -90", ok, peak_theta, 90);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-05: All-zero image produces an all-zero accumulator
// ------------------------------------------------------------
mprintf("\n--- TC-05: All-Zero Image ---\n");
bw = zeros(50, 50);
[H, theta, rho] = hough(bw);
ok = (max(H(:)) == 0);
report("All-zero BW => all-zero accumulator", ok, max(H(:)), 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-06: Single foreground pixel produces exactly n_theta votes
// Each pixel votes once per angle, so sum(H) == n_theta
// ------------------------------------------------------------
mprintf("\n--- TC-06: Single Pixel Vote Count ---\n");
bw = zeros(50, 50);
bw(25, 25) = 1;
[H, theta, rho] = hough(bw);
ok = (sum(H(:)) == length(theta));
report("Single pixel casts exactly length(theta) votes", ok, sum(H(:)), length(theta));
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-07: Numeric input is accepted (not just boolean)
// hough should accept a double matrix and cast it internally
// ------------------------------------------------------------
mprintf("\n--- TC-07: Numeric Input Accepted ---\n");
bw = zeros(20, 20);
bw(10, :) = 1;    // double, not boolean
ok = %T;
try
    [H, theta, rho] = hough(bw);
catch
    ok = %F;
end
report("Double matrix accepted without error", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-08: ThetaResolution property changes theta spacing
// ------------------------------------------------------------
mprintf("\n--- TC-08: ThetaResolution Property ---\n");
bw = zeros(20, 20);
bw(10, :) = 1;
[H, theta, rho] = hough(bw, "ThetaResolution", 2);
expected_len = length(-90:2:88);   // step 2, excludes +90
ok = (length(theta) == expected_len) & (theta(1) == -90);
report("ThetaResolution=2 halves the number of theta values", ok, length(theta), expected_len);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-09: Theta property sets theta directly
// ------------------------------------------------------------
mprintf("\n--- TC-09: Theta Property ---\n");
bw = zeros(20, 20);
bw(10, :) = 1;
custom_theta = -45:5:45;
[H, theta, rho] = hough(bw, "Theta", custom_theta);
ok = isequal(theta, custom_theta);
report("Custom Theta vector passed through correctly", ok, theta, custom_theta);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-10: RhoResolution=1 is accepted (default, implemented)
// ------------------------------------------------------------
mprintf("\n--- TC-10: RhoResolution=1 Accepted ---\n");
bw = zeros(20, 20);
bw(10, :) = 1;
ok = %T;
try
    [H, theta, rho] = hough(bw, "RhoResolution", 1);
catch
    ok = %F;
end
report("RhoResolution=1 accepted without error", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-11: RhoResolution != 1 raises an error (not implemented)
// ------------------------------------------------------------
mprintf("\n--- TC-11: RhoResolution != 1 Raises Error ---\n");
bw = zeros(20, 20);
caught = %F;
try
    [H, theta, rho] = hough(bw, "RhoResolution", 2);
catch
    caught = %T;
end
ok = caught;
report("RhoResolution=2 raises not-implemented error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-12: Odd number of property/value arguments raises error
// ------------------------------------------------------------
mprintf("\n--- TC-12: Odd varargin Count ---\n");
bw = zeros(20, 20);
caught = %F;
try
    [H, theta, rho] = hough(bw, "ThetaResolution");
catch
    caught = %T;
end
ok = caught;
report("Odd number of property args raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-13: Unknown property name raises error
// ------------------------------------------------------------
mprintf("\n--- TC-13: Unknown Property Name ---\n");
bw = zeros(20, 20);
caught = %F;
try
    [H, theta, rho] = hough(bw, "FakeProperty", 1);
catch
    caught = %T;
end
ok = caught;
report("Unknown property name raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-14: ThetaResolution out of range raises error
// ------------------------------------------------------------
mprintf("\n--- TC-14: ThetaResolution Out of Range ---\n");
bw = zeros(20, 20);
caught = %F;
try
    [H, theta, rho] = hough(bw, "ThetaResolution", 200);
catch
    caught = %T;
end
ok = caught;
report("ThetaResolution=200 raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-15: Non-numeric BW raises error
// ------------------------------------------------------------
mprintf("\n--- TC-15: Non-Numeric Input ---\n");
caught = %F;
try
    [H, theta, rho] = hough("hello");
catch
    caught = %T;
end
ok = caught;
report("String input raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-16: 3-D input raises error
// ------------------------------------------------------------
mprintf("\n--- TC-16: 3-D Input Raises Error ---\n");
caught = %F;
try
    bw_3d = ones(10, 10, 3);
    [H, theta, rho] = hough(bw_3d);
catch
    caught = %T;
end
ok = caught;
report("3-D matrix raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-17: No arguments raises error
// ------------------------------------------------------------
mprintf("\n--- TC-17: No Arguments ---\n");
caught = %F;
try
    [H, theta, rho] = hough();
catch
    caught = %T;
end
ok = caught;
report("No arguments raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-18: rho axis is symmetric around zero
// ------------------------------------------------------------
mprintf("\n--- TC-18: rho Axis Symmetry ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
ok = (rho(1) == -rho($)) & (length(rho) == 2*ceil(sqrt((50-1)^2+(50-1)^2))+1);
report("rho axis is symmetric around 0", ok, [rho(1), rho($)], [-rho($), rho($)]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-19: Property names are case-insensitive
// ------------------------------------------------------------
mprintf("\n--- TC-19: Case-Insensitive Property Names ---\n");
bw = zeros(20, 20);
bw(10, :) = 1;
ok = %T;
try
    [H, theta, rho] = hough(bw, "THETARESOLUTION", 2);
catch
    ok = %F;
end
report("THETARESOLUTION (uppercase) accepted", ok, ok, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-20: hough_line vote total equals number of foreground pixels
//        multiplied by number of angles
// ------------------------------------------------------------
mprintf("\n--- TC-20: hough_line Total Vote Count ---\n");
bw = zeros(30, 30);
bw(10, 5)  = 1;
bw(20, 15) = 1;
bw(25, 25) = 1;   // 3 foreground pixels
theta_oct = (-(-90:1:89) + 90) * (%pi / 180);
[H, rho] = hough_line(bw, theta_oct);
n_foreground = sum(bw(:));
ok = (sum(H(:)) == n_foreground * length(theta_oct));
report("Total votes == n_pixels * n_angles", ok, sum(H(:)), n_foreground * length(theta_oct));
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
