## Submission

This is an update from mfrmr 0.2.2 to 0.2.3. The maintainer and license are
unchanged.

The release strengthens numerical diagnostics, fail-closed inference
readiness, extreme-score handling, and the bounded generalized partial-credit
workflow.

## Test environments

- Local: macOS Tahoe 26.5.2, arm64, R 4.6.1 (2026-06-24),
  `R CMD check --as-cran --run-donttest`
- Win-builder: R-oldrelease 4.5.3 (2026-03-11 ucrt)
- Win-builder: R-release 4.6.1 (2026-06-24 ucrt)
- Win-builder: R-devel (2026-08-17 r90424 ucrt)

## R CMD check results

The exact source tarball submitted to Win-builder completed with 0 errors,
0 warnings, and 0 notes on all four environments listed above. The local check
also ran the `donttest` examples. Package tests, vignette rebuilding, and PDF
and HTML manual checks completed successfully.

External proprietary software is not required to install, check, or use the
package.
