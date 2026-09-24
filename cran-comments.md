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
The archive retains fifteen prebuilt articles and 43 figures with alternative
text. A later publication review established that seven articles were fully
evaluated and eight followed their CRAN-safe computation guard; the earlier
description of all fifteen as executed was incorrect. The rc.5 follow-through
below supplies the missing executed outputs. Two updated scoring explanations are reflected in the article HTML;
no numerical output was fabricated or recomputed for those prose changes.

## Hosted CI and publication candidate, 2026-09-24

The expanded source at `4f5ed87c11a1d01ee27547fa3d3e5d0c14aa1b04` passes
macOS release, Windows release, Ubuntu release, Ubuntu devel and Ubuntu oldrel-1:
https://github.com/Ryuya-dot-com/mfrmr/actions/runs/35948657009

Each environment completes `R CMD check --no-manual` with zero errors, warnings
and notes, and passes the international-input and moved-folder replay checks.
The workflow uses the representative CRAN test tier, not the separately retained
full numerical regression suite. Archive and check-log hashes are verified from
each downloaded receipt against that commit and tree. These are hosted package
checks, not a new complete `--as-cran` check or CRAN acceptance.

The publication archive is `mfrmr_0.2.4.tar.gz`, SHA256
`d1b7503790b275aefe02ab2d99ad4c9e79d35918ddda582c8f3c36a1e259b40b`.
It differs from the selected local archive only in the README installation/status
wording and automatic Packaged timestamp. All code, tests, Rd, data, saved
examples and fifteen prebuilt tutorials are byte-identical. The later publication
commit updates repository-only status records as well; its distinct SHA is not
represented as a second five-environment run. Applicable local and hosted checks
are reused for unchanged content. The rc.4 publication review found the documentation issues corrected below;
rc.5 now completes the archive and public-site verification.

## Before CRAN submission

Online incoming/URL and current reverse-dependency checks, and Win-builder remain
outstanding. GitHub publication, CRAN submission and CRAN acceptance are separate
external states. No CRAN submission or acceptance is claimed.


## Documentation correction after rc.4 publication review

The live-site review found empty alternative text for 23 figures in four older
tutorials. The earlier source archive also held computation-skipped versions of
eight older tutorials. Four Rmd files now add figure descriptions (including a
conditional residual-PCA plot); all R chunk bodies are unchanged. Re-extracting the eight older
sources with evaluation enabled gives the same parsed expressions as their new
tutorial scripts; the older stored scripts had commented out guarded chunks.
The other seven extraction scripts are retained byte for byte. The eight older articles were
rendered with computation enabled in about 30 seconds. Seven costly extended
workflow articles retain their previously executed output.

The rc.5 archive SHA256 is
`d988e5023f404895bca6ff184b037a7511680289634aeb4fcb31d2a20a7cb5c6`.
It contains fifteen executed tutorials and 68 figures with nonempty alternative
text. Its member comparison against rc.4 admits only README/NEWS, the four Rmd
sources and embedded copies, eight article HTML outputs, their corresponding executable extraction scripts and automatic packaging time. R/native implementation, Rd help, tests,
data, example fits and public interfaces remain byte-identical. A focused
`R CMD check --no-manual --no-examples --no-tests --timings` passes with zero
errors, warnings and notes, including rebuilding all article sources under their
CRAN guards. Its first attempt omitted the existing user-library directory and
stopped on three unavailable Suggests; restoring that library path resolved the
environment issue without installing packages or disabling dependency checks.
Unchanged numerical and five-environment evidence is reused with that scope.
Final publication verification is recorded in the maintained release ledger.


The verified rc.5 tag points to `3cd50b89edaee6b949aa6cc02ab82b27c4be6e71`,
which is integrated into main. Both release assets were re-downloaded and matched
byte for byte. Fifteen live pages and representative images match the deployed
site; all 68 tutorial images have descriptive alternatives. The original hosted
site build is retained for unchanged content. Four changed articles, home/NEWS,
Markdown copies and the search index were rebuilt separately with the same
pkgdown version. The other 388 reference/article HTML pages preserve their
output apart from source-link updates. No CRAN submission has been made.
