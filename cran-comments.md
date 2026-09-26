# Development branch — not for submission

This branch is now 0.2.4.9000. The notes below describe only the frozen
0.2.4 rc.6 archive; its checks do not qualify the new development changes.

# mfrmr 0.2.4 — submission preparation

Preparation draft, updated September 26, 2026. This source has not been
submitted to CRAN. Both current Win-builder results have been retrieved and
reviewed: zero errors, zero warnings and one explained NOTE in each environment.

## Changes

This update consolidates reusable calibration and scoring, external-feature
PCA/clustering, assigned-score multiple imputation, fixed-facet uncertainty,
rater-feedback tools, multivariate observed-score G/D studies, shared-rater
and Person-specific testlet RSMs, and GPCM MML inference/reporting improvements.
Existing API names and defaults remain compatible where documented in NEWS.

Approximate inference is explicitly distinguished from general coverage
assurances. Known probability-interval undercoverage and unqualified bootstrap
repeated-sample accuracy are documented. Proprietary external software is not
required; RTMB is optional. Examples provide executable saved synthetic results
where full estimation would be costly, with recalculation instructions available.

## Candidate identity

The public [rc.6 candidate](https://github.com/Ryuya-dot-com/mfrmr/releases/tag/v0.2.4-rc.6)
contains the frozen local `mfrmr_0.2.4.tar.gz`, SHA256:
`0f1f21c042512318a3b3c8ffbce246bcdab21db1d3dc2dce2cf5e091c58155e1`.
The archive and checksum were verified after publication by downloading both.
All checks below are identified by source/archive; earlier Windows uploads
are not attributed to this candidate.

## Check results

- Five-platform [GitHub CI](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36155335441)
  passes at implementation commit `6f541bfa`: macOS arm64/R 4.6.1,
  Windows/R 4.6.1 UCRT, Ubuntu/R 4.6.1, R 4.5.3 and R-devel
  (2026-09-23 r90586). Each independently built package reports **0 errors,
  0 warnings and 0 notes**. These ordinary checks use `--no-manual` and
  `NOT_CRAN=false`; they are not five exhaustive or `--as-cran` checks.
- The exact attached archive passes the local arm64 macOS/R 4.6.1
  `--as-cran --no-examples --no-tests --no-manual` check with **0 errors,
  0 warnings and 1 NOTE**. All 15 vignettes rebuild. Its examples/manuals
  and exhaustive tests were checked before the final limited repairs:
  three failures were corrected and affected paths passed 516 focused
  expectations. Documentation and fresh-session checks passed separately.
  Unchanged evidence was reused; no second exhaustive pass is claimed.
- Win-builder [R-release](https://win-builder.r-project.org/58oV2XD8gB7Q/00check.log)
  (R 4.6.1 UCRT) and [R-devel](https://win-builder.r-project.org/jNhW5RFMe5gs/00check.log)
  (2026-09-21 r90579 UCRT) each report **0 errors, 0 warnings and 1 NOTE**.
  Installation, examples, tests, vignette rebuilding and PDF/HTML manuals pass.
  Each selected CRAN test suite has 3,683 passes, zero failures/warnings and
  five skips: one fresh-process case, three deliberate CRAN skips and one
  compiled-source case. This is not the exhaustive local suite. The logs and
  Windows binaries are archived locally before the temporary links expire.
  Binary metadata, namespace, NEWS, 15 article sources and the test driver
  agree with the submitted candidate; the service does not publish its source
  archive hash, so attribution also uses the recorded upload and user notification.
- URL review of the archive finds no problems in 152 occurrences / 76 distinct
  references, with HTTP-status exclusions disabled.
- The current CRAN source index (25,196 packages) lists no reverse Depends,
  Imports, LinkingTo, Suggests or Enhances. Non-CRAN consumers are outside
  this index check.

## NOTE explanation

The local and both Win-builder NOTE entries report maintainer information and
seven updates in six months. This candidate consolidates estimation/inference corrections
and interface/reporting improvements described in NEWS. It has no remaining
local package-check errors or warnings. The initial missing-vignette-index
problem was corrected before freezing this archive.

## Remaining before submission

The planned package, URL, CRAN reverse-dependency and Windows checks are
complete; no code correction is required by these Windows results. Settle the
final release/submission decision. If package content changes,
identify a new archive and check the affected scope rather than attributing
these results to changed bytes. Detailed development and reuse records are
kept in the repository's package-excluded validation journal.
