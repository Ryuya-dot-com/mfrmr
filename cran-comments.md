## Unreleased 0.2.4 candidate

This candidate extends the 0.2.3.1 baseline with portable calibration and
new-Person scoring, exploratory external-feature PCA/clustering, assigned-score
multiple imputation, fixed-facet sandwich intervals, screening evaluation,
multivariate observed-score G/D-studies, and two bounded RSM extensions:
shared normal raters and Person-local testlets. Maintainer and license are
unchanged. RTMB is optional and required only for shared-rater estimation.

The measurement scale, conditioning and missingness assumptions are explicit.
Unassigned ratings are not imputed. Rubin pooling is restricted to eligible
non-Person fixed-facet targets. Extended-model Person intervals condition on
the fitted calibration; normal calibration/individual-rater bounds are explicit
approximations rather than automatic output. Diagnostics and model-aware maps
remain descriptive. General coverage, calibrated screening accuracy,
multidimensional MFRM and arbitrary G-theory structures are not claimed.

Saved-analysis instructions distinguish reprinting, recomputing, rescoring
and refitting. Existing ICC, shrinkage/replay and result-availability repairs
are retained. External proprietary software is not required.

## Verification of the local candidate, 2026-09-24

Selected archive: `mfrmr_0.2.4.tar.gz`, SHA256
`776465bc7b637d0b1859988485f9ac711ebc60c521aa476b4ef22c6a6497f134`.
Local environment: arm64 macOS, R 4.6.1.

The complete packaged test tier (`NOT_CRAN=true`) returned 22,364 successful
expectations, two failures, 42 warnings and 44 skips. The failures were missing
CRAN execution guards in seven tutorials and an order-dependent PCA plotting
test spy. Expected category/readiness warnings are now asserted explicitly;
a larger graphics device resolves unintended test-label crowding. Source-only
documentation checks additionally corrected internal wording in the README.
The affected and source-documentation checks pass 1,590 expectations across
eight files, with no failure, error, warning or skip. The original failed run
is retained separately and is not relabelled as a clean full-suite run.

Twelve installed-suite skips concern source documentation/help and were checked
from source. The remaining 32 depend on repository-only GPCM/external research
artifacts, excluded from the package. Existing source-specific evidence is
reused; those studies were not repeated for this candidate.

All fifteen tutorials were built with computation enabled. All 43 figures have
alternative text. Their executed HTML and images are retained in the selected
archive; only hidden CRAN-guard setup changed afterwards, with all 21
true/false/unset branches checked and matching source/extracted R files updated.
The final packaging reused those outputs with `--no-build-vignettes`.

The checked archive (`9eceab3943bf5ae6d6e76fda2b95787272e77a6d62f1fac931ea3b630658f3c0`)
passes `R CMD check --no-manual --no-vignettes --no-tests` with zero errors,
warnings and notes, including ordinary Rd examples. The selected archive only
removes one trailing space from tutorial prose and its matching embedded source,
plus the generated packaging timestamp. All code, tests, HTML/images, Rd, data
and extracted tutorial R are byte-identical. Its check result is reused on that
explicit basis; no new check result is claimed for the repackaging.
Executable R expressions and compiled-code sources match the full packaged run.
Two missing stats imports were corrected and verified independently in a fresh
session without stats attached. Thus this is a full-run-plus-targeted-repairs
verification, not a claim that the final check reran all tests or tutorials.

The installed package retains 204 exports, 262 registered S3 methods and 269
Rd topics, with usage matching code. Fresh-session replay preserves nine
workflow objects and both model export/report scripts with refitting blocked.
Ordinary/portable-calibration and optional-dependency checks remain applicable
to their unchanged executable paths.

## Checks still required before submission

The expanded candidate has not yet passed hosted five-environment CI. Earlier
candidate CI does not qualify this source. CRAN incoming checks, online URLs,
current reverse dependencies, PDF-manual compilation and Win-builder were not
rerun for this archive. Package-index access was unavailable in the local
restricted-network environment; installed dependencies satisfied the check.
The release decision, GitHub publication and CRAN submission are separate
from this local verification. This file is a preparation draft, not a claim
that a submission has been made or accepted.
