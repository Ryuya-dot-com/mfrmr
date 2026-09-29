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

Windows remains unmeasured for this source. Historical Windows static-analysis
and manual costs are substantial, so extrapolating this Mac's total or only
optimizing tests cannot establish the Windows ceiling. Before another broad
test/study, use the 58/230/23-second local static/test/manual profile and the
retained Windows breakdown to decide targeted profiling or a current-source
Windows timing run. D3/D4, final scope/version freeze and submission readiness
remain open. No CRAN upload, GitHub push or release-tag change was made.
