# mfrmr 0.2.4

## Changes

This update connects many-facet measurement, G/D studies and rater feedback
to shared tables, figures and reports, including exploratory bias collections.
Repeated diagnostic calculations have been reduced while preserving results.
Optional MML starting-value reviews retain all attempts and failed outcomes.
RSM/PCM interaction models support EM/hybrid, with likelihood-ascent checks
and an additional direct-optimization polishing step for gradient stalls.
Stan export now retains the default
single-family GPCM's estimated normal population and supported fixed anchors.
Fixed-population exports also support brms. NEWS and the migration guide
explain retired plotting helpers and corrections affecting saved analyses.

## Checks

macOS arm64, R 4.6.1, 2026-10-27:
`R CMD check --as-cran --timings`: 0 errors, 0 warnings, 0 notes;
603 seconds elapsed (examples 63 seconds; tests 146 seconds).

A subsequent correction counts reported planning targets by their identities
rather than splitting labels containing commas. The final archive installs
and passes all 72 targeted reporting assertions. No estimation code or built
documentation changed; the full check was not repeated after this correction.
Windows checks of this archive are pending.

Long workflows have explicit `\dontrun{}` examples with execution instructions;
short examples and representative numerical tests remain active. The complete
test suite is available with `NOT_CRAN=true`.

## Reverse dependencies

No reverse dependencies were listed in the CRAN package index checked on
2026-10-26.
