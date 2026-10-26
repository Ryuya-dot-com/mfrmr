# mfrmr 0.2.4

## Changes

This update connects many-facet measurement, G/D studies and rater feedback
to shared tables, figures and reports. It adds supported single-family GPCM
and fixed-anchor exports to Stan/brms. NEWS and the migration guide explain
retired plotting helpers and corrections affecting saved analyses.

## Checks

Windows Server 2022, R-oldrelease 4.5.3 (win-builder): the preceding candidate
completed with 1 ERROR and 1 NOTE. Incoming URL checks passed. Installation
and check times were 254 and 3,840 seconds.

- The ERROR was an immutability test comparing serialized bytes. R 4.5 can
  materialize deferred character names while reading a fit, changing its
  serialized representation without changing values or attributes. The test
  now compares against an independent object snapshot with exact equality.
  The affected test file passes on macOS with both R 4.5.2 and R 4.6.1.
- The NOTE concerned 22 examples exceeding 10 seconds (maximum 25.34 seconds).
  Four examples reuse synthetic fits with regeneration code. Further changes
  reduce repeated grouping in fixed-quadrature MML gradients without changing
  the likelihood, integration accuracy or convergence controls. Updated
  Windows timings and R-devel results are not yet available.

macOS arm64, R 4.6.1: the updated implementation passed a full
`R CMD check --as-cran --timings` with 0 errors, 0 warnings and 1 NOTE for
macOS `xcrun_db` temporary-file detritus. The command took 551 seconds,
including installation. Examples, tests, vignette rebuilding and PDF/HTML
manuals passed. The subsequent source change is limited to the portability
test described above, checked separately on both R versions. Remote incoming
and system-clock checks were disabled locally after DNS failures.

## Reverse dependencies

No reverse dependencies were listed in the CRAN package index checked on
2026-10-26.
