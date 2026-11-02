# mfrmr 0.2.4 — historical submission notes

These notes describe the 2026-10-28 revision toward the subsequently published
0.2.4 release. They are retained as history, not as check results or submission
comments for the current 0.2.4.9000 development source or the planned 0.3.0.

## Resubmission draft: cumulative check-time reduction

Following Uwe Ligges's request to reduce check time, we compared the revised
package with the originally submitted archive, whose CRAN incoming Windows
check took approximately 23 minutes. The most recent Windows-checked revision
took 840 seconds (14 minutes) on win-builder R-release, with
0 errors, 0 warnings and 0 notes. Examples, tests, vignette rebuilding and the
PDF/HTML manual checks all remained enabled.

| Stage | Original archive: CRAN incoming (Windows, R-devel) | Previous revision: win-builder (Windows, R-release) |
| --- | ---: | ---: |
| Checking R code for possible problems | 475 s | 250 s |
| Examples | 123 s | 86 s |
| Tests | 268 s | 151 s |

On win-builder R-release, using the same R version (4.6.1) as the previous
revision's result, the original archive took 1,349 seconds. Relative to this
run, the observed reduction is 509 seconds (8 min 29 s; 37.7%). Because these
are separate server runs, they do not isolate the effect of the code changes
from differences in server load. The comparison with the CRAN incoming check
additionally differs in R version.

Win-builder result for the previous revision:
https://win-builder.r-project.org/4u3R5a4CJDTI
Installation took 102 seconds; tests reported 6,546 passes and 17 skips.
The 14-minute check time still exceeds the 10-minute target; we would be
grateful to know whether the remaining runtime is acceptable.

The latest local candidate differs from the Windows-checked revision in help
organization, test selection and scheduling, vignette execution, and the minimum
cpp11 version, as described below. It has passed R CMD check on macOS but has
not yet been checked on win-builder, so
the 840-second result should not be attributed to it.

## Changes already included in the Windows-checked revision

Empty-anchor setup, grouped observation counts and several diagnostic paths
now avoid unnecessary work. Residual PCA, Q3, residual plots and halo analysis
no longer compute unrelated parameter-covariance, reliability and marginal-fit
summaries. Full diagnostics, diagnostic identity checks and guards against
unsupported models are retained. Duplicate internal implementations have been
consolidated and unused internal entry points removed; public APIs and S3
behavior are unchanged.

Testlet fitting and scoring now avoid redundant log-sum-exp centering. RSM and
PCM MML calculations reuse response probabilities for identical rating
conditions on a shared quadrature grid, while retaining observation-specific
scores and weights. Native cumulative-probability loops now traverse matrices
in storage order without changing the order of additions within each cell.
Integration orders, convergence criteria and numerical tolerances have not
been relaxed. Comparisons against saved outputs cover testlet predictions and
RSM/PCM fits, including weights, uneven patterns of missing ratings and a fixed
anchor.
In these comparisons, parameters, likelihoods, gradients, covariance matrices,
diagnostics and summaries are identical; only the recorded elapsed times
differ.

## Additional changes in the latest local candidate

Worked examples retain their data-to-model-to-result sequence. Short primary
examples still run automatically; longer examples remain in the help pages
in `\dontrun{}` blocks, accompanied by a reason and an explicit
`example("topic", run.dontrun = TRUE)` command for execution. In the current
archive, help pages for 59 related S3 methods have been merged into their parent
topics, reducing the number of Rd files from 323 to 264 while preserving all
517 aliases, usage sections, argument descriptions and example code. All 26
affected optional example workflows were checked successfully.

The ordinary CRAN test selection (50 files) now runs serially. The public-workflow
smoke test now includes the former adaptive-likelihood tests. Fourteen
detailed test files in the extended suite and five longer test blocks are not
run during CRAN checks but remain available, with their assertions and
numerical tolerances unchanged. The standard tests still include
representative estimation and diagnostic calculations, independent numerical
checks, and regression tests for the posterior-file reader and checksum
rejection. The test stage of the current archive took 41 seconds on macOS.

The reported counts describe the selected checks, not all tests retained in
the package. On the same Mac, the previous revision reported 6,548 passes and
16 skips, compared with 5,257 passes and 13 skips for the current selection.
Files excluded by the CRAN filter are not loaded and therefore do not appear
as skipped tests. The retained full packaged suite is available with
`NOT_CRAN=true`; its numerical assertions and tolerances are unchanged.
The earlier Windows counts also include platform-dependent checks and skips.

The generalizability theory (G-theory) vignette no longer evaluates its code
during CRAN checks. The distributed HTML vignette, including its evaluated
results and figures, is unchanged.

The minimum cpp11 version in LinkingTo is now 0.5.4, the version used to
compile and check the current archive with R 4.6.1.

Relative to the previous revision, the current archive does not change
R function bodies in the package namespace, native source code, NAMESPACE or
saved numerical data. The earlier numerical comparisons therefore still apply
within that unchanged scope and are supplemented by a
new standard check; the full research validation suite has not been re-run.

## Check of the current archive

macOS arm64, R 4.6.1, cpp11 0.5.4: `R CMD check --as-cran --timings` completed
in 251.0 seconds with 0 errors, 0 warnings and 1 note. The original archive
took 271.2 seconds on the same Mac. These local timings do not establish the
current archive's runtime on Windows.

Checking R code for possible problems took 73 seconds, examples 25 seconds,
tests 41 seconds and vignette rebuilding 14 seconds; the PDF and HTML manual
checks took 13 and 15 seconds, respectively. Tests reported 5,257 passes,
13 skips, and no failures or uncaptured warnings.

Remote incoming queries were disabled for this local run; the package
description prose is unchanged. The term "generalizability" in DESCRIPTION
refers to generalizability theory.

The note concerns `xcrun_db` in the temporary directory. Running Apple's
`xcrun --find clang++` alone in an empty temporary directory created the same
file without loading the package, indicating that the note arises from the
macOS toolchain rather than from mfrmr.

## Reverse dependencies

As of 2026-10-28, the CRAN package page lists no reverse dependencies.
