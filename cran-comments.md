# mfrmr 0.2.4

## Changes

This update connects many-facet measurement, G/D studies and rater feedback
to shared tables, figures and reports. It adds supported single-family GPCM
and fixed-anchor exports to Stan/brms. NEWS and the migration guide explain
retired plotting helpers and corrections affecting saved analyses.

## Checks

macOS arm64, R 4.6.1, 2026-10-27:
`R CMD check --as-cran --timings` completed in 532 seconds with no errors
or NOTEs. Examples took 61 seconds (maximum per topic: 0.77 seconds);
tests took 130 seconds, with 12,542 passes, no failures or warnings, and
four intentional CRAN skips. Vignette rebuilding and both manuals passed.

The one WARNING concerned the modification time of an unchanged vignette
source. This was corrected, and a subsequent packaging-only check was clean.
Apart from build timestamps, all archived file contents match the full run.
Examples and tests were not repeated for that metadata correction.

Long workflows remain available as explicit `\dontrun{}` examples, with
instructions for running them. Short examples and representative numerical
checks remain active. The complete test suite remains available with
`NOT_CRAN=true`.

Windows checks of this revised archive are pending.

## Reverse dependencies

No reverse dependencies were listed in the CRAN package index checked on
2026-10-26.
