## Unarchival resubmission (`mfrmr` 0.3.2)

`mfrmr` (`0.2.4`) was archived on `2026-11-24` while our `0.3.1` submission
(`2026-11-22`, which resolved the `MKL` check issue) was awaiting manual review
after triggering the Windows `> 10 min` checktime flag.

In `0.3.2`, we both retain the verified `MKL` fix and execute the planned
companion-package split (`mfrmr` C++ statistical core + companion `tidymfrm`
plotting/reporting layer) to reduce the package check workload:

1. **Resolved `MKL` numerical tolerance issue (`0.2.4` Additional_issues):**
   Replaced exact bit-equality `expect_identical()` checks across separate
   matrix refits with `expect_equal(..., tolerance = 1e-12)` and rounded /
   tolerance-guarded assertions so ULP differences under Intel MKL vs
   OpenBLAS/Accelerate never fail.
2. **Consolidated API and reduced check workload (`22` core functions):**
   Consolidated `mfrmr` down to 22 focused exported functions plus standard S3
   methods (`predict()`, `coef()`, `vcov()`, `confint()`, `anova()`, `plot()`),
   moved narrative workflow/reporting layers (`flextable`, `kableExtra`,
   `officer` in `Suggests`) to the companion package `tidymfrm`, and implemented
   core MFRM (`JML`, `JML_jeffreys`, `MML`, `CML`), pairwise `RajuSA-Welch` bias,
   and split-element DFF solvers in `cpp11` C++ (defaulting to `threads = 1L` in
   compliance with CRAN policy). All file-writing examples and tests write
   strictly inside `tempdir()`.

## Test environments and R CMD check results

- **Local macOS arm64 (`aarch64-apple-darwin23`), R 4.6.1, `cpp11` 0.5.4:**
  `R CMD check --as-cran --timings` completed in 105.79 seconds elapsed
  with **0 errors, 0 warnings, and 1 note** for the local `xcrun_db` temporary
  directory. The check used installed dependencies with incoming checks disabled.
  Source tarball SHA-256:
  `1f075da9d063ecf5b7542c3961def5a10caf5dc576532de5b4e6fe32b953bf7c`.

## Notes

- **`Suggests: cmdstanr` (`Additional_repositories`):** `cmdstanr` is available
  from `https://stan-dev.r-universe.dev`; all Stan code paths are guarded by
  `requireNamespace("cmdstanr", quietly = TRUE)`.
- The terms "G-Study" and "D-Study" in `DESCRIPTION` refer to generalizability
  theory studies (Brennan, 2001).

## Reverse dependencies

There are currently no reverse dependencies on CRAN.
