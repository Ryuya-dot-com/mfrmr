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

The ICC correction in the current 0.2.4 candidate passed hosted checks on
2026-09-21 in four environments:

- macOS with R 4.6.1;
- Windows with R 4.6.1;
- Ubuntu with R-devel (2026-09-19 r90572); and
- Ubuntu with R 4.5.3.

Each completed environment had 0 package-check errors, warnings, and notes,
756 passing lightweight test expectations, no test failures/warnings, and
three intentional skips. Examples, vignette rebuilding, two international-input
cases, and eight archive-replay cases passed. Checked source contents were
verified against the candidate, accounting for Windows line endings.

The Ubuntu-release full-suite job was intentionally cancelled after review of
the verification scope. It is not reported as a pass. The preceding candidate's
completed full run (19,438 passes, 42 test warnings, 44 skips) remains evidence
for that earlier source, not a completed full run of this revision. Ordinary
CI now uses the lightweight suite; a full run is an explicit manual choice for
broad changes or a batched release review.

The ICC correction withdraws the unsupported transformation of separate
component-profile bounds, retains bootstrap failure/convergence diagnostics,
and withholds incomplete intervals. Saved ICC interval analyses require
recalculation; point estimates alone do not establish interval validity.

The candidate also corrects printing of selected D-study table rows or
columns, preserving their calculation and interpretation information. G/D
coefficient calculations are unchanged. The correction was found by running
the documented examples with `--run-donttest`; its regression tests and the
additional examples pass.

The exact 0.2.4 source archive passes `R CMD check --as-cran` on arm64 macOS
with R 4.6.1: 0 errors, 0 warnings, and 1 NOTE. This includes the additional
`--run-donttest` examples, 756 passing lightweight test expectations with three
intentional CRAN skips, vignette rebuilding, and PDF/HTML manual generation.

CRAN incoming feasibility notes seven updates in the past six months. This
update includes corrections to result availability, uncertainty interpretation
and reuse of saved analyses, alongside the portable-calibration workflow.

The CRAN source-package index was checked again on 2026-09-21. It reports
mfrmr 0.2.3.1 and no reverse Depends, Imports, LinkingTo, Suggests, or Enhances
relationships, so there is no reverse-dependent package suite to run.

External proprietary software is not required to install, check, or use the
package.
