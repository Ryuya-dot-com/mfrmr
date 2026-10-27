# mfrmr 0.2.4

## Changes

This update connects many-facet measurement, G/D studies and rater feedback
to shared tables, figures and reports, including exploratory bias collections.
Repeated diagnostic calculations have been reduced while preserving results.
Optional MML starting-value reviews retain all attempts and failed outcomes.
Stan export now retains the default
single-family GPCM's estimated normal population and supported fixed anchors.
Fixed-population exports also support brms. NEWS and the migration guide
explain retired plotting helpers and corrections affecting saved analyses.

## Checks

macOS arm64, R 4.6.1, 2026-10-27:
`R CMD check --as-cran --timings` completed in 548 seconds:
0 errors, 0 warnings, 0 notes. Examples took 59 seconds; tests took 132 seconds,
with 12,849 passes and four intentional CRAN skips. Vignette rebuilding and
both manuals passed.

Long workflows remain available as explicit `\dontrun{}` examples, with
instructions for running them. Short examples and representative numerical
checks remain active. The complete test suite remains available with
`NOT_CRAN=true`.

Windows checks of this revised archive are pending.

## Reverse dependencies

No reverse dependencies were listed in the CRAN package index checked on
2026-10-26.
