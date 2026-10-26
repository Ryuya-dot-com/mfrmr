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
  In addition to four previously revised examples, 80 consumer examples now
  reuse synthetic fits and matching diagnostics, with regeneration code.
  Primary results/report/export examples fit their displayed input data.
  Fixed-grid MML also reduces repeated grouping without changing numerical
  controls. Updated Windows timings and R-devel checks remain outstanding.

macOS arm64, R 4.6.1: a preceding candidate passed a full
`R CMD check --as-cran --timings` with 0 errors, 0 warnings and 1 NOTE for
macOS `xcrun_db` temporary-file detritus. The command took 551 seconds,
including installation. Examples, tests, vignette rebuilding and PDF/HTML
manuals passed. Subsequent changes affect example inputs, help, test setup
and appendix-selection summaries. The latter now filter each requested preset
before counting tables, correcting pooled counts and reducing repeated work.
Five affected test files pass 1,558 assertions on macOS R 4.6.1; the focused
regression passes 121 assertions on macOS R 4.5.2 and after installing the
updated archive on macOS R 4.6.1. Exported CSV counts also match the selections.
The saved-example test file,
including fresh regeneration, passes 192 assertions on both macOS R 4.5.2 and
R 4.6.1. Ordinary checks omit regeneration and pass 119 assertions with one
intentional skip. This is scoped follow-up validation, not a second full
package check. Remote incoming and system-clock checks were disabled in the
full local check after DNS failures.

## Reverse dependencies

No reverse dependencies were listed in the CRAN package index checked on
2026-10-26.
