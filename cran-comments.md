## Submission

This is an update from mfrmr 0.2.3.1 to 0.2.4. The maintainer and license are
unchanged.

The release adds portable calibration and scoring for eligible one-scale RSM
and PCM MML fits under a fixed standard-normal scoring basis. Calibration
review, validation, freezing, persistence, and scoring are separate public
operations. Portable calibration for GPCM and JML is not supported in this
release; their documented fitted-model workflows remain available.

The release also corrects missing-result handling and uncertainty summaries,
retains residual subgroup comparisons as descriptive observed-minus-expected
scores, and documents how to update saved analyses. Portable score intervals
condition on the saved calibration and scoring prior; they do not include
calibration-estimation uncertainty. New inferential FairZ and omnibus
differential-functioning methods are outside this release.

## Test environments

The 0.2.4 candidate passed checks in five environments on 2026-09-21:

- macOS with R 4.6.1;
- Windows with R 4.6.1;
- Ubuntu with R-devel (2026-09-19 r90572);
- Ubuntu with R 4.6.1, including the full package test suite; and
- Ubuntu with R 4.5.3.

All five jobs completed with 0 errors, 0 warnings, and 0 notes. Tests, examples,
vignette rebuilding, and fresh-process installed-package scoring passed.
Ubuntu release ran the complete suite: 19,438 passing expectations, no
failures, 42 test warnings, and 44 recorded skips. The other four environments
each ran the CRAN-light suite: 673 passing expectations, no failures or test
warnings, and three intentional skips. The 42 complete-suite warnings concern
sparse category support, plot-label space, and the restriction of
information-criterion ranking to MML fits. Their messages and counts match the
preceding development source's complete arm64 macOS run; they are not
package-check warnings.

The candidate also corrects printing of selected D-study table rows or
columns, preserving their calculation and interpretation information. G/D
coefficient calculations are unchanged. The correction was found by running
the documented examples with `--run-donttest`; its regression tests and the
additional examples pass.

The exact 0.2.4 source archive passes `R CMD check --as-cran` on arm64 macOS
with R 4.6.1: 0 errors, 0 warnings, and 1 NOTE. This includes the additional
`--run-donttest` examples, 673 passing lightweight test expectations with three
intentional CRAN skips, vignette rebuilding, and PDF/HTML manual generation.

CRAN incoming feasibility notes seven updates in the past six months. This
update includes corrections to result availability, uncertainty interpretation
and reuse of saved analyses, alongside the portable-calibration workflow.

The CRAN source-package index was checked again on 2026-09-21. It reports
mfrmr 0.2.3.1 and no reverse Depends, Imports, LinkingTo, Suggests, or Enhances
relationships, so there is no reverse-dependent package suite to run.

External proprietary software is not required to install, check, or use the
package.
