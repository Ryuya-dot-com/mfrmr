## Unreleased 0.2.4 candidate

This candidate extends the 0.2.3.1 baseline with portable calibration and
new-Person scoring, exploratory external-feature PCA/clustering, assigned-score
multiple imputation, fixed-facet sandwich intervals, screening evaluation,
multivariate observed-score G/D-studies, and two bounded RSM extensions:
shared normal raters and Person-local testlets. Maintainer and license are
unchanged. RTMB is optional and required only for shared-rater estimation.
External proprietary software is not required. A local native ConQuest run
has verified the documented synthetic comparison workflow within its scope.

The measurement scale, conditioning and missingness assumptions are explicit.
Unassigned ratings are not imputed. Rubin pooling is restricted to eligible
non-Person fixed-facet targets. Extended-model Person intervals condition on
the fitted calibration; normal calibration/individual-rater bounds require
an explicit request. General coverage, calibrated screening accuracy,
multidimensional MFRM and arbitrary G-theory structures are not claimed.

## Current local archive, 2026-09-24

Selected archive: `mfrmr_0.2.4.tar.gz`, SHA256
`27f9ca8697263e79d1f2c14b7c959aded97ef676fdd96c52c1430e99318ece54`.
Environment: arm64 macOS, R 4.6.1. This is a local preparation draft, not a
submission or acceptance claim.

The initial `R CMD check --as-cran --timings` run returned two errors, one
warning and three notes. Ordinary examples (25 seconds), examples including
`donttest` (152 seconds), and PDF/HTML manual checks passed. The CRAN test tier
reported 3,014 passed expectations, one stale guide-wording expectation and
four skips. Article rebuilding exposed two inline expressions that referenced
uncomputed objects when the existing CRAN evaluation guard was active.

The repairs update that test expectation, apply the same guard to the inline
expressions, declare the already-used test dependency `withr` in Suggests,
and retain the prebuilt vignette index with the reused articles. The affected
test file passes 41 expectations without failure, warning or skip; the affected
article renders under the CRAN setting. Both inline expressions preserve their
computed values when execution is enabled and handle unavailable dependencies.
No statistical implementation, help example, numerical setting or saved result
changed during these repairs.

The selected repaired archive passes
`R CMD check --as-cran --no-examples --no-tests --no-manual --timings`
with zero errors, zero warnings and two notes. This includes declared test
and vignette dependencies, installed help, the vignette index and rebuilding
all fifteen articles (11 seconds). PDF compilation is separately repeated on
the repaired source and succeeds. The four earlier test skips comprise three
explicit CRAN exclusions and one fresh-process library-path condition; existing
source-specific GPCM and installed portable-API evidence is retained.

The two remaining notes concern unavailable remote clock verification and an
`xcrun_db` temporary file. Incoming remote queries were disabled; package-index
access also failed in the restricted-network environment. Installed dependencies
satisfied the checks. These notes are retained, not treated as a clean online
CRAN result.

Archive comparison confirms that the repair changes only DESCRIPTION metadata,
`build/vignette.rds`, one test expectation and the two copies of the affected
article source. All R/native code, Rd examples, data, saved results, executed
article HTML/figures and extracted tutorial R are byte-identical to the initial
checked archive. The example and test execution results are reused on that
basis, with the failed expectation resolved separately; this is not a claim
that the final run reran every example or test. The measured package-controlled
components total approximately 301 seconds, combining the initial example/test
timings and repaired article rebuild. That includes the initial failed test
run and is not a new complete clean-run total or a cross-platform time bound.

Earlier full-regression evidence, targeted integration repairs and fresh-session
replay remain applicable to unchanged statistical code. Seven fast help examples
now read coherent packaged synthetic fits, scores, diagnostics and bootstrap
results; expensive recomputation is shown as comments with a complete recipe.
All fifteen executed articles and their 43 figures with alternative text are
retained. Two updated scoring explanations are reflected in the article HTML;
no numerical output was fabricated or recomputed for those prose changes.

## Before submission or publication

Matching hosted five-environment CI, online repository/URL and current reverse-
dependency checks, and Win-builder remain outstanding for this source. Earlier
candidate CI does not qualify it. GitHub publication, CRAN submission and CRAN
acceptance are separate external states; none was performed in this local pass.
