# mfrmr 0.2.4

## Resubmission

Recompressing a bundled model-data file changed its checksum and caused the
posterior reader to stop in examples and tests. Its original bytes have been
restored, with a regression test for equal data stored in a different encoding.
Integrity checks remain active; no estimates or posterior draws were recalculated.

Ordinary tests retain live estimation, independent numerical checks and
representative measurement, G/D-study and feedback workflows. Repeated
multi-start and profile-interval scenarios remain in the complete
`NOT_CRAN=true` suite; data sizes and numerical tolerances are unchanged.
Adaptive integration also batches category moments and avoids unused work.

The DESCRIPTION term "generalizability" refers to generalizability theory.

## Checks

macOS arm64, R 4.6.1, 2026-10-28: `R CMD check --as-cran --timings`:
0 errors, 0 warnings, 0 notes; 495 seconds elapsed, including 166 seconds for
incoming feasibility. Examples took 54 seconds; tests took 77 seconds with two
workers, down from 87 seconds on the preceding candidate. The posterior reader,
reports and plots pass. The overall time increased from 458 seconds because
incoming feasibility took longer (previously 119 seconds).

The revised candidate's Windows R-devel check is pending. These Mac timings
do not establish Windows compliance with the ten-minute criterion.

## Reverse dependencies

No strong reverse dependencies were listed for mfrmr at submission preparation.
