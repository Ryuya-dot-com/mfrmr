# Unreleased 0.2.4 candidate — not for submission

The substantive scope and source are selected as of October 19, 2026. The
current source archive's SHA256 is
`f1b2b55187780047b80a0d80b5e63254cbbc3767e701111ff2d578bb85cea949`.
It includes the final CML variance, normal-tail interval and help/workflow
corrections, including a repaired person-data example and replayable G-study
sampling-covariance example. API and inferential qualifications, defaults and migration
behavior are settled within the [documented scope](ROADMAP.md). The version
and date identify an unpublished candidate, not a CRAN release.

The archive builds and installs locally, retaining all 17 unchanged tutorials
and their index from the preceding standard build. All executable package R
code is unchanged from the selected substantive source. One test reuses
identical information for the same fit across confidence-level checks; a new
test verifies the saved G-study example. No numerical accuracy, convergence
criterion or supported design is reduced.

The current archive completes an ordinary macOS/R 4.6.1 `--as-cran --timings`
check with **0 errors, 0 warnings and 2 notes**. Normal and `donttest` examples,
10,956 ordinary test assertions (three declared On-CRAN skips), static analysis,
vignette rebuilding and PDF/HTML manuals pass. The notes concern unavailable
external time verification and `xcrun_db` residue. Remote incoming queries
were disabled; external links and reverse dependencies were checked separately.

With no concurrent heavy validation, the complete command took 671.055 seconds.
Excluding the rounded 32-second installation gives **639.055 check-only seconds**
(638.555--639.555 allowing for installation rounding). The 480-second local
headroom target is not met. This is a valid local workload measurement, not a
Windows result or evidence of satisfying the package's 600-second Windows
ceiling. Required phases include static analysis (71 seconds), normal examples
(41), `donttest` examples (161), tests (277), vignette rebuilding (18) and PDF/HTML
manuals (15/14). No check scope or numerical accuracy was reduced.

The preceding delivery archive
(`bf1e9f0d02b94456e8ba6b8923c4d2ad61d3a78d2233673aa3378e06829c6db2`)
had two errors in the same incomplete standardized-contrast example. Supplying
its required person-level data fixed the example. The current complete check
supersedes that combined ordinary-check/scoped-repair evidence. The earlier
557.794-second measurement remains invalid for cost qualification because its
example workloads aborted and concurrent work occurred.

Current-artifact saved-result checks pass in fresh sessions with optional
dependencies present and hidden. The local documentation site is refreshed
with source-matched reuse; its pages have no embedded example errors, broken
local links or missing non-logo image alternatives.

The complete installed `NOT_CRAN=true` suite ran against the corrected-example
archive (`84f065bfc6387dfc31add5bee0db8ba3eef699bfe681086e8054f3fb1cd21432`).
It recorded 36,715 passing assertions and nine errors/warnings caused by two
test files using source-tree paths for packaged CSV data. The final archive
fixes those paths and permits platform rounding in the saved-example test;
these are its only changes from that archive. All 253 assertions in the three
affected installed test files then pass without failures, errors, warnings or
skips. Combining the unchanged full-suite results with those reruns gives
36,873 passing assertions, zero failures/errors/warnings and 57 declared skips
for repository-only sources, documentation and validation artifacts. Function
definitions and the graphics function used by tests are restored after both
runs. This is a complete run plus scoped repairs, not a second clean full run.

The current CRAN source index contains 25,435 packages and no reverse Depends,
Imports, LinkingTo, Suggests or Enhances for mfrmr. Non-CRAN consumers are outside
this check. URL review covers 340 occurrences / 163 distinct references, including
128 HTTP(S) URLs, with status exclusions disabled. Three new documentation URLs
return 404 on the older hosted site; their current local pages are present and
checked, but deployment and hosted verification remain required. Three other
findings are PubMed browser verification (203), an Annenberg access refusal (403)
and a Geyer-page connection timeout. Separate official-page/index retrieval
confirms those references; these are attributed access findings, not a clean
automated URL result. No blanket URL exclusions were added.

Final integration, execution-cost qualification, matching Windows/remote checks
and hosted URL/site verification remain open. No hosted-site publication or
CRAN submission has been performed.

The following integration record belongs to the earlier source and is retained
with its original archive identity; its timings do not measure the current
archive.

# Historical October 19 candidate integration

Candidate preparation dated October 19, 2026. The current
[roadmap](ROADMAP.md) accepts the implemented release claims and connected user
workflows within their declared scope, including native RSM/PCM conditional
estimation, same-fit population-SD MML contrasts and anchor migration. Broader
inference research remains incomplete. Execution-cost and final platform
qualification remain open; this candidate is not ready for CRAN submission. The date
in DESCRIPTION and CITATION identifies candidate preparation, not publication.

The October 19 macOS/R 4.6.1 ordinary `--as-cran` check completed normal and
`donttest` examples, representative tests, vignette rebuilding and PDF/HTML
manuals. Its initial result was **1 error, 1 warning and 4 notes**. The error
was an obsolete test expectation that omitted CML from the available methods.
The warning concerned duplicated `x`/`object` help entries. A help-width note
identified a caption default that would be truncated in the PDF manual.
All three are corrected. Focused tests against the corrected installation,
installed help-usage and code/documentation checks, line-width checks, and
regeneration of the affected PDF/HTML help pass. The caption returns exactly
the same text. The corrected archive retains the unchanged executed tutorials
and their index; saved CML/MML plots and reports replay without estimation.
This combines an initial complete check with scoped corrections, rather than
a new clean complete check of the corrected archive.

The corrected source archive's SHA256 is
`fc05132fb29fa744b5781ec724af377d2e8256d72cca831464d1a4c9c5286a82`.
Initial check-only elapsed time was **676.979 seconds**, excluding the rounded
32-second installation; the complete command took 708.979 seconds. The
recorded 600-second delivery ceiling and 480-second headroom target remain
unmet. The slow MINQUE example took 36.716 seconds. The other retained notes
concern unavailable external time verification and temporary `xcrun_db`
residue. Remote incoming queries were disabled. This run did not execute the
exhaustive `NOT_CRAN=true` suite or a matching Windows check. No publication or
CRAN submission has been performed.

The records below belong to earlier sources and do not qualify this candidate.

# Historical October 16 development integration

The October 16 local macOS/R 4.6.1 complete ordinary check includes normal and
`donttest` examples, representative tests, vignette rebuilding and PDF/HTML
manuals. The initial run reports **1 error, 0 warnings and 5 notes**. Its error
contains two obsolete test expectations: the balanced crossed default is now
MLS, and six registered S3 methods were absent from the expected-method list.
The other 10,010 assertions passed, with three declared skips. Both expectations
are corrected; the two affected installed test files then pass all 60 assertions.
The static-analysis note about unqualified `nlminb`/`qchisq` calls is also fixed
with explicit `stats::` calls. Focused usage checks and a separate session with
`stats` not attached pass. The corrected archive preserves the unchanged
vignette outputs and matches the corrected source. This is combined evidence,
not a new clean complete check of that archive.

The remaining initial notes concern the development version, unavailable
external time verification, a slow example and temporary `xcrun_db` residue.
Remote incoming queries were disabled and repository indexes were unavailable.
Check-only elapsed time was **690.694 seconds**, excluding the rounded 33-second
installation; the complete command took 723.694 seconds. This exceeds both
the local 600-second ceiling and the 480-second headroom target. The incomplete
MINQUE sampling-covariance example took 37.561 seconds in the ordinary example
pass and also executes in the `donttest` pass. Cost qualification remains open
for final delivery, after required feature work; the elapsed time alone does
not establish a statistical defect or an unusable analysis workflow. Successful
numerical checks are retained. The
October 15 result of 557.371 check-only seconds belongs to its earlier source
and is not substituted for this measurement.

The five-environment ordinary CI matrix passes on its identified development
commit. It uses `--no-manual` and does not measure a complete Windows check.
The current saved-result and optional-dependency presence/absence review also
passes locally. These are separate evidence scopes, not a single final-source
release check. Complete Windows timing remains deferred until the intended
features are assembled; the final matching Windows check must still satisfy
the required ceiling.

No final submission archive, CRAN submission or release acceptance is claimed.
The older records below identify rc.6 and September 30 development sources;
retain their original attribution rather than using them as the final
candidate's submission comments. Current source identities, logs and evidence
reuse decisions are retained locally.

# Historical mfrmr 0.2.4 rc.6 submission preparation

Preparation draft, updated September 26, 2026. This source has not been
submitted to CRAN. Both rc.6 Win-builder results have been retrieved and
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
manual 12. The selected tests completed without failures or warnings. Normal
examples were enabled; the additional `donttest` workload was not included.
The full check found undeclared test imports from callr/pkgload; their Suggests
declarations were repaired and R's test-dependency check then passed. The
development-version NOTE remains expected. All other archive files are byte
identical; no second complete local check is claimed. Exact
archive hashes, commands, skips and the separate successful fresh-process
check are recorded in `inst/validation/cran-check-time-20260930.md`.

The subsequent development-source Windows R 4.6.1 check took 1,561.889 seconds
including a rounded 90-second installation, or approximately 1,472 seconds
of checking. Static analysis took 214 seconds, ordinary examples 73, tests
about 900, vignette rebuilding 27 and HTML manual generation 76. The result
was one ERROR, one WARNING and three NOTEs. The failed test was a README
wording check, subsequently corrected and checked locally. Indexed PDF
generation lacked makeindex; an isolated Windows run identified that missing
tool, which has been added to CI setup. A subsequent manual-only Windows run
successfully generated the indexed PDF in 20.55 seconds. V8 was absent, so HTML math rendering
was not checked; it is now requested for subsequent timing runs. These repairs
do not turn the original result into a clean check or resolve the 600-second
ceiling. No complete rerun or current-source Win-builder result is claimed.
The timing profile explicitly disabled `_R_CHECK_DONTTEST_EXAMPLES_`, so its
example measurement excludes that additional workload. Final submission checks
must reconcile this override with the normal `--as-cran` behavior; marking code
as `donttest` does not establish that CRAN will skip it.

A subsequent adaptive-MML optimization reduces repeated matrix calculations
without changing integration rules or tolerances. Targeted numerical and API
checks pass. A local retained-calibration comparison improved from 4.367 to
3.395 seconds (median of three runs per implementation); this does not measure
the complete suite or establish the required Windows runtime.

The September 24 Windows result skipped six tests because RTMB was 1.9 rather
than the required >= 2.0. The rc.6 September 26 results do not have those RTMB
skips; their five other skips are described above. Final evidence must record
optional-package versions and executed feature checks, including supported
RTMB and nleqslv routes and clear behavior when dependencies are unavailable.

## Historical rc.6 NOTE explanation

The rc.6 local and both Win-builder NOTE entries report maintainer information and
seven updates in six months. That candidate consolidates estimation/inference corrections
and interface/reporting improvements described in NEWS. Its final recorded
local package check had no errors or warnings. The initial missing-vignette-index
problem was corrected before freezing this archive.

## Remaining before submission

The earlier functional, URL, reverse-dependency and Windows results belong
to rc.6. Submission preparation is not complete: resolve the check-time excess,
complete the agreed development scope, identify the final archive and obtain
its matching full-check and optional-dependency evidence. Explain remaining
notes and timing explicitly in the final submission comments. Do not assume
that acceptance of 0.2.3.1 authorizes another over-budget submission. Detailed
development and reuse records remain in package-excluded maintainer material.
