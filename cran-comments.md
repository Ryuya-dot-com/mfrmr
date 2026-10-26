# mfrmr 0.2.4

## Changes

This update connects many-facet measurement, generalizability and decision
studies, and rater feedback to shared tables, figures and reports. It also
adds supported single-family GPCM and fixed-anchor exports to Stan/brms,
with saved posterior summaries available for reporting.

Retired standalone drawing helpers are replaced by `plot()` methods.
NEWS and the migration guide document the replacements and corrections
that require rebuilding older results.

## Checks

macOS arm64, R 4.6.1: `R CMD check --as-cran --timings` completed with
0 errors, 0 warnings and 2 NOTEs. Examples, tests, vignette rebuilding and
PDF/HTML manuals passed.

- `confint.mfrm_fit` took 5.007 seconds elapsed (4.997 seconds CPU), just over
  the example timing threshold.
- The macOS temporary directory contained an `xcrun_db` file.

Remote incoming and system-clock checks were disabled locally after DNS
failures; online repository queries were also unavailable in that run.

Standard R CMD checks passed on macOS and Windows with R-release, and on
Ubuntu with R-release, R-devel and R-oldrel. These checks excluded PDF manual
building and `donttest` examples.

## Reverse dependencies

No reverse dependencies were listed in the CRAN package index checked on
2026-10-26.
