// ============================================================
// TEST SUITE: colorangle
// ============================================================
exec('colorangle.sci', -1);

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
mprintf(" colorangle — Automated Test Suite\n");
mprintf("==========================================\n\n");

// --- TC-01: Orthogonal Vectors (90 Degrees) ---
mprintf("--- TC-01: Orthogonal Vectors ---\n");
deg = colorangle([1, 0, 0], [0, 1, 0]);
ok = abs(deg - 90) < 1e-5;
report("Pure Red vs Pure Green is 90 degrees", ok, deg, 90);
if ok then passed = passed + 1; else failed = failed + 1; end

// --- TC-02: Identical Vectors (0 Degrees) ---
mprintf("\n--- TC-02: Identical Vectors ---\n");
deg = colorangle([1, 1, 1], [1, 1, 1]);
ok = abs(deg - 0) < 1e-5;
report("White vs White is 0 degrees", ok, deg, 0);
if ok then passed = passed + 1; else failed = failed + 1; end

// --- TC-03: Matrix Broadcasting ---
mprintf("\n--- TC-03: Matrix Broadcasting ---\n");
rgb_mat = [1, 0, 0; 0, 1, 0; 1, 1, 1];
single_rgb = [1, 0, 0];
deg = colorangle(rgb_mat, single_rgb);
expected = [0; 90; 54.735610];
ok = and(abs(deg - expected) < 1e-3);
report("1x3 row broadcasted across Nx3 matrix correctly", ok, deg, expected);
if ok then passed = passed + 1; else failed = failed + 1; end

// --- TC-04: Single Black Vector Guard (The NaN Check) ---
mprintf("\n--- TC-04: Single Black Vector Edge Case ---\n");
deg = colorangle([0, 0, 0], [1, 1, 1]);
if isnan(deg) then
    ok = 1;
else
    ok = 0;
end
report("One black vector returns NaN", ok, deg, 0);
if ok then passed = passed + 1; else failed = failed + 1; end

// --- TC-05: Double Black Vector Guard ---
mprintf("\n--- TC-05: Both Black Vectors ---\n");
deg = colorangle([0, 0, 0], [0, 0, 0]);
ok = (deg == 0);
report("Two black vectors return 0 instead of NaN", ok, deg, 0);
if ok then passed = passed + 1; else failed = failed + 1; end

// --- TC-06: Dimension Mismatch Error Handling ---
mprintf("\n--- TC-06: Dimension Error Handling ---\n");
caught = %F;
try
    colorangle(ones(2,3), ones(4,3));
catch
    caught = %T;
end
ok = caught;
report("Mismatched matrices throw an error", ok, caught, %T);
if ok then passed = passed + 1; else failed = failed + 1; end

// ============================================================
// Summary
// ============================================================
total = passed + failed;
mprintf("\n==========================================\n");
mprintf(" Results: %d / %d passed\n", passed, total);
if failed == 0 then
    mprintf(" All tests passed successfully.\n");
else
    mprintf(" %d test(s) FAILED.\n", failed);
end
mprintf("==========================================\n\n");
