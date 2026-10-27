# mfrmr 0.2.4

## Changes

This update connects many-facet measurement, G/D studies and rater feedback
to shared tables, figures and reports. It adds supported single-family GPCM
and fixed-anchor exports to Stan/brms. NEWS and the migration guide explain
retired plotting helpers and corrections affecting saved analyses.

## Checks

macOS arm64, R 4.6.1, 2026-10-27:
`R CMD check --as-cran --timings mfrmr_0.2.4.tar.gz` completed with
0 errors, 0 warnings and 1 NOTE. Remote incoming, system-clock and strict
Suggests checks were enabled; tests used `NOT_CRAN=false`.

The NOTE concerns a reference URL in `compute_facet_design_effect.Rd`:
<https://www150.statcan.gc.ca/n1/pub/12-001-x/2004002/article/7751-eng.pdf>.
The connection timed out after 60 seconds without receiving data. A separate
retry also timed out; the URL has not been changed on that evidence alone.

Total elapsed time was 755 seconds, including 232 seconds for incoming checks
and 34 seconds for installation. Examples took 141 seconds; all 273 recorded
topics were below 5 seconds individually (maximum 3.08 seconds).
Tests took 170 seconds: 14,604 passes, no failures or warnings, and four
intentional CRAN skips. Vignette rebuilding and PDF/HTML manuals passed.

Updated Windows and R-devel checks remain pending.

## Reverse dependencies

No reverse dependencies were listed in the CRAN package index checked on
2026-10-26.
