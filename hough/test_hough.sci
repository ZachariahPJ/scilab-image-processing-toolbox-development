// ============================================================
// TEST SUITE: hough
// Run after loading with:
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
mprintf(" hough — Test Suite\n");
mprintf("==========================================\n\n");


// ------------------------------------------------------------
// TC-01: Default theta runs from -90 to 89 with 180 elements
// ------------------------------------------------------------
mprintf("--- TC-01: Default Theta Range ---\n");
bw = zeros(20, 20);
bw(10, :) = 1;
[H, theta, rho] = hough(bw);
ok = (theta(1) == -90) & (theta($) == 89) & (length(theta) == 180);
report("theta runs -90 to 89, 180 elements", ok, [theta(1), theta($), length(theta)], [-90, 89, 180]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-02: H has correct dimensions (length(rho) x length(theta))
// ------------------------------------------------------------
mprintf("\n--- TC-02: H Has Correct Dimensions ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
ok = (size(H,1) == length(rho)) & (size(H,2) == length(theta));
report("H is length(rho) x length(theta)", ok, size(H), [length(rho), length(theta)]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-03: Horizontal line peaks at theta=0
// ------------------------------------------------------------
mprintf("\n--- TC-03: Horizontal Line Peak at theta=0 ---\n");
bw = zeros(101, 101);
bw(51, :) = 1;
[H, theta, rho] = hough(bw);
[peak_val, peak_idx] = max(H(:));
[peak_rho_idx, peak_theta_idx] = ind2sub(size(H), peak_idx);
ok = (theta(peak_theta_idx) == -90);
report("Horizontal line peaks at theta=-90", ok, theta(peak_theta_idx), 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-04: rho axis is symmetric around zero
// ------------------------------------------------------------
mprintf("\n--- TC-04: rho Axis Symmetric Around Zero ---\n");
bw = zeros(50, 50);
bw(25, :) = 1;
[H, theta, rho] = hough(bw);
ok = (rho(1) == -rho($));
report("rho(1) == -rho($)", ok, [rho(1), rho($)], [-rho($), rho($)]);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-05: All-zero image gives all-zero accumulator
// ------------------------------------------------------------
mprintf("\n--- TC-05: All-Zero Image ---\n");
bw = zeros(50, 50);
[H, theta, rho] = hough(bw);
ok = (max(H(:)) == 0);
report("All-zero BW gives all-zero H", ok, max(H(:)), 0);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-06: Total votes equals foreground pixels times angles
// ------------------------------------------------------------
mprintf("\n--- TC-06: Total Vote Count ---\n");
bw = zeros(30, 30);
bw(10, 5) = 1;
bw(20, 15) = 1;
bw(25, 25) = 1;
[H, theta, rho] = hough(bw);
n_fg = sum(bw(:));
ok = (sum(H(:)) == n_fg * length(theta));
report("sum(H) == n_pixels * n_angles", ok, sum(H(:)), n_fg * length(theta));
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-07: ThetaResolution=2 halves the number of theta values
// ------------------------------------------------------------
mprintf("\n--- TC-07: ThetaResolution Property ---\n");
bw = zeros(20, 20);
bw(10, :) = 1;
[H, theta, rho] = hough(bw, "ThetaResolution", 2);
expected_len = length(-90:2:88);
ok = (length(theta) == expected_len) & (theta(1) == -90);
report("ThetaResolution=2 gives correct theta length", ok, length(theta), expected_len);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-08: Custom Theta vector is passed through unchanged
// ------------------------------------------------------------
mprintf("\n--- TC-08: Custom Theta Vector ---\n");
bw = zeros(20, 20);
bw(10, :) = 1;
custom_theta = -45:5:45;
[H, theta, rho] = hough(bw, "Theta", custom_theta);
ok = isequal(theta, custom_theta);
report("Custom Theta passed through correctly", ok, theta, custom_theta);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-09: RhoResolution=1 is accepted without error
// ------------------------------------------------------------
mprintf("\n--- TC-09: RhoResolution=1 Accepted ---\n");
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
// TC-10: Property names are case-insensitive
// ------------------------------------------------------------
mprintf("\n--- TC-10: Case-Insensitive Property Names ---\n");
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
// TC-11: RhoResolution != 1 raises error
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
report("RhoResolution=2 raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-12: Odd number of property/value arguments raises error
// ------------------------------------------------------------
mprintf("\n--- TC-12: Odd Property Arguments Raises Error ---\n");
bw = zeros(20, 20);
caught = %F;
try
    [H, theta, rho] = hough(bw, "ThetaResolution");
catch
    caught = %T;
end
ok = caught;
report("Unpaired property argument raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-13: Unknown property name raises error
// ------------------------------------------------------------
mprintf("\n--- TC-13: Unknown Property Raises Error ---\n");
bw = zeros(20, 20);
caught = %F;
try
    [H, theta, rho] = hough(bw, "FakeProperty", 1);
catch
    caught = %T;
end
ok = caught;
report("Unknown property raises error", ok, caught, %T);
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
mprintf("\n--- TC-15: Non-Numeric Input Raises Error ---\n");
caught = %F;
try
    [H, theta, rho] = hough("hello");
catch
    caught = %T;
end
ok = caught;
report("String BW raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-16: 3-D input raises error
// ------------------------------------------------------------
mprintf("\n--- TC-16: 3-D Input Raises Error ---\n");
caught = %F;
try
    [H, theta, rho] = hough(ones(10, 10, 3));
catch
    caught = %T;
end
ok = caught;
report("3-D matrix raises error", ok, caught, %T);
if ok then passed = passed+1; else failed = failed+1; end


// ------------------------------------------------------------
// TC-17: No arguments raises error
// ------------------------------------------------------------
mprintf("\n--- TC-17: No Arguments Raises Error ---\n");
caught = %F;
try
    [H, theta, rho] = hough();
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
