# Development branch — not for submission

This branch is now 0.2.4.9000. The notes below describe only the frozen
0.2.4 rc.6 archive; its checks do not qualify the new development changes.
Reviewed September 30, 2026: check time is an unresolved submission blocker.
The earlier zero-error/zero-warning results do not establish submission readiness.

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
  Each selected CRAN test suite completes without failures or warnings, with
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

## Check time and optional-dependency coverage

The rc.6 Win-builder notifications reported installation/check times of
128/1,538 seconds on R-release and 133/1,587 seconds on R-devel. Their logs
show the following rounded phase times:

| Phase | R-release | R-devel |
| --- | ---: | ---: |
| R code for possible problems | 309 s | 356 s |
| Examples | 82 s | 81 s |
| Tests | 13 min | 13 min |
| Vignette rebuilding | 27 s | 26 s |
| PDF manual | 68 s | 68 s |
| HTML manual | 127 s | 51 s |

These timings exceed the 10-minute check-time threshold previously applied
by CRAN incoming checks to mfrmr 0.2.3.1 on August 25, 2026. Installation is
separate. We have not yet demonstrated an optimized current-source Windows
check below 600 seconds. Test execution is the largest recorded phase; additional
static-analysis and manual costs also need measurement and reduction. Source
line count alone does not establish proportional check time.

Before submission, record source-matched full check phase timings with normal
examples, tests, vignette and manual checks enabled, and verify the final
Windows check time below 600 seconds. The local working target is 480 seconds
to allow headroom; it is not a guarantee of Windows performance. Preserve
small checks of every admitted feature and keep longer studies in the explicit
complete test tier. Skipping required checks or optional models to obtain a
shorter time will not satisfy this requirement.

The September 30 development-source local measurement (`0.2.4.9000`, not rc.6)
took 468.66 seconds including approximately 27 seconds of installation: about
442 seconds of checking on arm64 macOS/R 4.6.1. Static analysis took 58 seconds,
ordinary examples 22, tests 230, vignette rebuilding 11, PDF manual 11 and HTML
manual 12. The tests reported 4,930 passes with no failures or warnings. Normal
examples were enabled; the additional `donttest` workload was not included.
The full check found undeclared test imports from callr/pkgload; their Suggests
declarations were repaired and R's test-dependency check then passed. The
development-version NOTE remains expected. All other archive files are byte
identical; no second full check or current Windows result is claimed. Exact
archive hashes, commands, skips and the separate successful fresh-process
check are recorded in `inst/validation/cran-check-time-20260930.md`.

The September 24 Windows result skipped six tests because RTMB was 1.9 rather
than the required >= 2.0. The rc.6 September 26 results do not have those RTMB
skips; their five other skips are described above. Final evidence must record
optional-package versions and executed feature checks, including supported
RTMB and nleqslv routes and clear behavior when dependencies are unavailable.

## NOTE explanation

The local and both Win-builder NOTE entries report maintainer information and
seven updates in six months. This candidate consolidates estimation/inference corrections
and interface/reporting improvements described in NEWS. It has no remaining
local package-check errors or warnings. The initial missing-vignette-index
problem was corrected before freezing this archive.

## Remaining before submission

The earlier functional, URL, reverse-dependency and Windows results belong
to rc.6. Submission preparation is not complete: resolve the check-time excess,
complete the agreed development scope, identify the final archive and obtain
its matching full-check and optional-dependency evidence. Explain remaining
notes and timing explicitly in the final submission comments. Do not assume
that acceptance of 0.2.3.1 authorizes another over-budget submission. Detailed
development and reuse records remain in package-excluded maintainer material.
