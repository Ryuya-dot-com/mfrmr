# CRAN check runtime: September 30, 2026

This is release-engineering evidence for roadmap D3/D4, not new statistical
qualification. The Windows check-only ceiling remains 600 seconds; the local
480-second target is provisional and is not a cross-platform guarantee.

## Source and measurement

Baseline source: `161db708`. Its normally built source archive is
`validation-results/cran-time-20260930/baseline/mfrmr_0.2.4.9000.tar.gz`, SHA256
`53a35272dd6c73ab56eb7fadd9af9946f07352504046fa29b197c165f4709a90`.
Archive R, C++, tests, help and NAMESPACE were compared with the source;
DESCRIPTION differences are the normal build fields/whitespace transformations.
All 15 vignettes were built. Build elapsed time was 160.808 seconds and
installation with tests took 25.383 seconds, separate from check time.

Environment: R 4.6.1, arm64 macOS 27.0.1, R's BLAS, testthat 3.3.2;
`OMP_NUM_THREADS`, `OPENBLAS_NUM_THREADS`, `VECLIB_MAXIMUM_THREADS` each 1.
RTMB 2.0 and nleqslv 3.3.7 are available and their selected model tests execute.
The full session and thread records accompany each measurement.

`cran-test-timing-20260930.R` runs the installed package's own test selector
under `NOT_CRAN=false`. File timing includes top-level setup; per-test times
and all expectations are retained. It accepts an explicit file filter for
affected-path measurements, which are not presented as whole-suite runs.

The initial reporter used an unresolved relative output directory; writing its
first file timing failed after all four adaptive-fitting tests had completed.
That attempt is retained in `baseline/instrumentation-first-file/`. The path
was corrected and the remaining files ran in a separate process. Combined
baseline elapsed time is **296.307 seconds** (40.706 + 255.601), including two
runner overheads; it is not a single uninterrupted full check. There were
4,396 passing expectations, no failed expectations/test errors, ten warnings
about the absent RSM/PCM slope column, and four skips: the installed archive's
compiled-source inspection and three explicitly CRAN-skipped extended GPCM
workflows. These skips do not stand for RTMB or corrected-JML validation.

## Changes and affected-path results

Profiling, before edits, found that 78% of the local calibration review time
was spent computing a fresh adaptive-information Hessian. Production scoring
still performs this check; no cache of readiness decisions was added.
The scoring-prior test matrix now computes one real review of its unchanged
calibration, reuses that result only inside two scoring/output tests, and
asserts exact fit identity on every reuse. Source-failure and integration-grid
tests still run fresh checks. Every prior/record-size condition remains tested.

Design recommendations previously built structural-review appendix tables
through `summary()` even though recommendation decisions use only run aggregates.
They now call the same unrounded aggregation directly. Existing failed-run,
connectivity, workload and threshold cases remain in the check. A regression
also refuses incidental appendix construction and compares the decision tables
with the summary-input route. An initial assertion incorrectly required all
raw-input and summary-input metadata to be identical; their existing planning
metadata/facet defaults differ. The corrected assertion supplies explicit
facets and compares all decision tables and thresholds.

Adaptive tests reuse one identical integration-point refit within their file.
No sample size, integration order, numerical tolerance or failure criterion
was relaxed. Empty slope tables now return no keys, eliminating the RSM/PCM
warning; real sensitivity calls must complete without warnings.

| Installed test file | Baseline elapsed | After change elapsed |
| --- | ---: | ---: |
| adaptive-fitting | 40.706 s (includes initial runner overhead) | 38.229 s |
| adaptive-quadrature-review | 8.805 s | 10.723 s |
| design-evaluation-denominators | 25.205 s | 13.777 s |
| scoring-prior | 79.188 s | 16.576 s |

These are single observations, not stable platform speed guarantees. The
affected run also exercised two-family quadrature sensitivity, the GMFRM
public workflow and corrected-JML public workflow: **691 passes, zero failures,
warnings or skips**, 93.071 seconds. The last decision-table regression passed
separately after this run. The unaffected baseline tests are not claimed as a
second complete candidate run.

The CRAN selector additionally includes existing `gmfrm-em`,
`gmfrm-public-workflow` and `jml-public-workflow` files. Their measured times
were respectively 5.625, 1.657 and 5.801 seconds. The EM file adds 345 passing
expectations, including literal product probabilities, independent numerical
derivatives, likelihood/gradient agreement, owner identity and EM ascent.
Corrected JML executes the solver, covariance, replay and refusal paths with
nleqslv present. These small checks complement, and do not replace, the
complete CI numerical/coverage studies.

## Assembled check

The candidate archive is
`validation-results/cran-time-20260930/candidate/mfrmr_0.2.4.9000.tar.gz`, SHA256
`bd49956f1ccb8a1cef93afa2afe904703a29a998c2ea9504ec9f9c238312b326`.
All 711 comparable code/test/help/vignette-source/NAMESPACE/NEWS files agree
with the working source, including the corrected regression. Its complete
vignette build took 162.454 seconds, recorded separately from checking.

Command: `R CMD check --as-cran --timings --output=<candidate> <archive>` with
the library/thread settings above, `NOT_CRAN=false`, `_R_CHECK_TIMINGS_=0`,
and `_R_CHECK_DONTTEST_EXAMPLES_=false`. The last setting makes this a normal
example profile comparable to the retained Windows logs (which contain no
extra `examples with --run-donttest` phase). Ordinary examples, all selected
tests, vignette rebuilding, static analysis and both manuals remain enabled.
The opt-in `donttest` workload is not included in this time comparison and
is not claimed as validated here. R's native phase times report rounded
CPU/elapsed seconds; `/usr/bin/time -lp` records process totals.

The assembled command took **468.66 seconds**, with 387.88 user CPU seconds
and 12.68 system CPU seconds. Removing the rounded 27-second installation
phase gives approximately **441.66 seconds of checking**. The subtraction has
the phase log's rounding uncertainty; it is not a millisecond-accurate
check-only measurement. The local 480-second working target is met.

| Phase | CPU seconds (rounded) | Elapsed seconds (rounded) |
| --- | ---: | ---: |
| Installation (outside check-only total) | 26 | 27 |
| CRAN incoming feasibility | 4 | 60 |
| R code for possible problems | 58 | 58 |
| Ordinary examples | 22 | 22 |
| Tests | 230 | 230 |
| Vignette rebuilding | 10 | 11 |
| PDF manual | 11 | 11 |
| HTML manual | 12 | 12 |
| Other check overhead (difference) | not separately attributed | about 38 |

The test phase passed **4,930 expectations, zero test failures/warnings**.
There were four skips: three explicitly CRAN-skipped extended GPCM workflows
and one calibration fresh-process test whose library-path guard evaluated
false in the combined check. The compiled-source inspection ran here (unlike
the installed-only baseline). The fresh-process file was then run explicitly
against this check-installed package: **238 passes, no warnings/failures/skips**,
2.604 seconds. This supplies separate evidence for the guarded path; it does
not rewrite the original check's skip count. The installed-tests timing runner
cannot directly locate tests inside a normal check installation; that failed
invocation is retained, and the successful rerun uses the check's external
`tests/` directory. No optional-model absence caused these skips.

The initial assembled status was **one WARNING and one NOTE**, not a clean
submission result. The WARNING was undeclared `callr`/`pkgload` test imports;
the NOTE reports maintainer information and the development version component
`9000`. Add `callr` and `pkgload` to Suggests (measured versions 3.8.0/1.5.3).
R's own `tools:::.check_packages_used_in_tests()` then reports no undeclared
test dependencies. No runtime dependency or estimation behavior changed.

The metadata-repaired archive in
`validation-results/cran-time-20260930/metadata-repair/` has SHA256
`d0e161f41fa4d6916d5da65d1198b00bf543d57bb8b6cf10d1a5d4f724d4ba83`.
It was normally rebuilt from the measured archive with the corrected source
DESCRIPTION and `--no-build-vignettes --no-manual`, reusing the unchanged
vignette outputs already built and checked above. Archive comparison confirms
that **DESCRIPTION is the only changed file; the other 795 files are byte
identical**. Do not report a second complete zero-warning check: the full
phase evidence is reused with the focused metadata repair, not repeated.
Machine-readable phase/totals, dependency versions, archive comparison and
raw logs are retained beside their respective archives.

## Decision and next work

The measurement gap is closed locally, and the first repairs reduce the
selected test workload by about 66 seconds despite adding three model files.
This is a single-run comparison (different reporters and the documented skip
difference), not a precision benchmark. The test phase remains 230 seconds,
above its provisional 120-second allocation, while the combined local target
is met; do not drop mathematical checks solely to meet a per-phase allocation.

At the end of this local phase, Windows remained unmeasured; the subsequent
Windows result is recorded below. Historical Windows static-analysis
and manual costs are substantial, so extrapolating this Mac's total or only
optimizing tests cannot establish the Windows ceiling. Before another broad
test/study, use the 58/230/23-second local static/test/manual profile and the
retained Windows breakdown to decide targeted profiling or a current-source
Windows timing run. D3/D4, final scope/version freeze and submission readiness
remain open. No CRAN upload, GitHub push or release-tag change was made.

## Windows timing preparation and qualification repair

The next measurement uses the existing `R-CMD-check` workflow with an explicit
`windows_timing` dispatch input. Only Windows R-release runs in this mode.
The existing source-tarball runner enables `--as-cran --timings`, static
analysis, normal examples, selected tests, vignette rebuilding and both manuals;
`NOT_CRAN=false`, the three thread settings equal 1 and the additional donttest
profile remains separate. RTMB >= 2.0 and nleqslv are required rather than
silently skipping their models. The workflow retains the source archive,
phase/total times, dependencies, session, checks and source/hash identity even
when the check fails or exceeds its time budget. TinyTeX supplies manual tools.
Its 60-minute job limit permits recording a time overrun; it is not the
600-second check qualification threshold.

Inspection found that the old shared readiness parser qualified only the
sum of examples, tests and vignettes, omitting static analysis, manuals and
other overhead. Its regression fixture incorrectly accepted 1,120 seconds
of timed phases because the selected subset was 420 seconds. This is repaired.
The parser now accepts Windows `[309s]` / `[13m]` as well as Unix CPU/elapsed
tokens. Check-only qualification requires a total elapsed measurement, timed
installation subtraction, all six required phases and an upper rounding bound
below 600 seconds. A partial phase log cannot demonstrate success, although
enough timed phases can already demonstrate an overrun. An R reminder to run
`--run-donttest` no longer counts as proof that those examples executed.

Focused checks cover seconds/minutes, rounding at the ceiling, omitted phases,
the legacy false-positive fixture and donttest detection. Runner-control tests
mock the build/check boundary to verify the exact profile, retained evidence
on a time overrun or WARNING, and restored environment; they do not rebuild
the package or rerun numerical studies. The affected workflow-contract test
passes 60 assertions; both YAML files parse and source-version metadata agree.

The repository readiness-protocol file produced 854 passing assertions and
eight failures in pre-existing scope/prose checks. Evaluating its public-scope,
GPCM-scope and prose-status functions before and after these timing changes
gives identical results (retained in
`validation-results/windows-cran-timing-20260930/preexisting-readiness.rds`).
The concerns are an obsolete literal README boundary expectation, a missing
corrected-JML structural-inference row in the older supplementary roadmap,
and a numerical pass count in cran-comments. These remain D2 reconciliation
work; no expectations were weakened to claim an entirely passing repository
review. They are outside the archive's selected tests and do not establish
an estimator defect or excuse a failed package check.

This preparation is not a Windows result or a final release qualification.
The dedicated validation branch and measured run will be recorded below.

### First Windows attempt and scope reconciliation

Commit `3887eb00` was pushed to
`validation/0.2.4-cran-time-20260930` and dispatched as
[run 36648171479](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36648171479).
The run stopped before building or checking: TinyTeX installed successfully,
but the following forced Bash step could not resolve Windows `tlmgr`.
Use the runner's native shell for that step, as in the upstream action example.
This is an infrastructure failure, with no package timing or test outcome.
The complete first-attempt log is retained in
`validation-results/windows-cran-timing-20260930/first-run.log`.

The eight repository assertion failures identified above were then addressed:
README states the eligible portable MML/JML scopes explicitly, the redundant
pass count is retained internally rather than in cran-comments, and current
GPCM review reads the 0.2.4 internal plan. That plan maps all three unavailable
capability areas to decisions and required evidence. Counting historical
checklist rows no longer stands in for matching actual missing capabilities.
The older records were not rewritten. A negative test removes the corrected-JML
row and confirms that review still fails. The four affected readiness tests
pass 55 assertions; the other readiness tests were not needlessly repeated.
Runner control tests pass 22 assertions, including evidence retention after
an actual check WARNING as well as a time overrun. No package estimator or
numerical experiment changed in this follow-up.

Further source-identity review found that the general evidence lookup also
fell back to 0.2.0 when current development records were absent. For 0.2.4 and
later it now accepts only the requested version or its matching `.9000` base
release. Historical files remain available for historical reviews. Tests cover
an absent current record, a matching base-release record, an unrelated future
release and the retained historical behavior; the affected lookup, GPCM and
source-review tests pass 45 assertions. Overall readiness remains `concern`,
including missing current evidence artifacts. No new frozen evidence is claimed.

README's summary of model support is also corrected: one-family and
experimental two-family GPCM are separate rows; same-data posterior response
diagnostics are distinguished from ordinary fit diagnostics; multivariate
G/D-study support is no longer described as the simplified main-effects route.
These edits match existing help and leave formal inference limitations visible.

## Measured Windows result: ceiling not met

[Run 36648663039](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36648663039)
checked commit `4c32dd9e09eb14a00aca35eac9ab3a0dbf0d0b0e`. Its archive SHA256 is
`cca39a547345dd6a1c4d2d8ec619c3b555efb25e05be38917aa695423e00050f`.
The archive, check directory and machine-readable timing/session/dependency
records are retained in `validation-results/windows-cran-timing-20260930/measured/`;
the full workflow log is `measured-run.log` beside that directory.

Environment: GitHub's Windows runner, R 4.6.1 UCRT, RTMB 2.0, nleqslv 3.3.7,
codetools 0.2-20 and testthat 3.3.2. The recorded CRAN selector and single-thread
settings were used. This is a hosted Windows measurement, not a Win-builder
service result or a new statistical study.

| Work | Elapsed seconds |
| --- | ---: |
| Archive build, outside checking | 135.660 |
| Check command including installation | 1,561.889 |
| Installation, rounded native log | 90 |
| **Check-only estimate** | **1,471.889 (rounding range 1,471.389–1,472.389)** |
| Static R-code analysis | 214 |
| Ordinary examples | 73 |
| Selected tests | about 900 (`15m`, minute-rounded) |
| Vignette rebuilding | 27 |
| Indexed PDF manual attempt | 15, failed |
| HTML manual | 76, math-rendering check skipped |
| CRAN incoming feasibility | 35 |
| Other check overhead and fallback PDF generation | about 132 |

The result is **1 ERROR, 1 WARNING and 3 NOTEs**, not a time-only failure.
Tests reported 4,929 passes, one failed assertion, no test warnings and the
same four documented skips. RTMB/nleqslv absence did not remove model tests.
The failed assertion was the public-calibration documentation check: this
turn's README edit changed `fixed standard-normal` to a hyphenated wording.
It was repaired as readable prose and that documentation test now passes
19 assertions locally; no estimator/tolerance was changed or failure hidden.

Indexed PDF generation warned, while its no-index fallback succeeded.
The retained log contains no explicit LaTeX error explaining that failure;
an index/tool-wrapper cause is a hypothesis requiring an isolated Windows
manual run. Do not report the manual as fixed. The HTML NOTE identifies absent
V8; V8 is now requested by the timing CI so the next complete run will include
math-rendering checks. The remaining NOTEs concern the development version
and a leftover TeX file from the failed manual. The initial run did not exercise
HTML math rendering and does not qualify a complete clean manual check.

The check-only ceiling is exceeded by about 872 seconds (2.45 times the
budget). Tests alone exceed it. Local 442-second performance therefore did
not transfer to this Windows runner. Fixing the README assertion and manual
toolchain cannot establish the budget. Next: isolate the indexed-manual
failure without repeating the full check; profile the Windows test phase
by file/test against the retained source, reuse local profiles to identify
redundant fitting, and measure affected repairs before another assembled run.
Static analysis and other overhead together are also material; even deleting
the test phase would leave only about 28 seconds of headroom on this run,
before repairing the incomplete manual checks. D3/D4 remain open.
