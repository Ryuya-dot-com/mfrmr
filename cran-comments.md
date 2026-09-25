# mfrmr 0.2.4 — submission preparation

This is a preparation draft. No CRAN submission has been made for this source.
Local integration and five-platform GitHub CI are complete as of September 26,
2026. The matching website is deployed. Earlier Win-builder uploads are different
sources and do not validate this archive; no new upload was made in this step.

## Changes

This update consolidates reusable calibration and new-Person scoring,
external-feature PCA/clustering, assigned-score multiple imputation,
fixed-facet intervals, screening evaluation, multivariate observed-score
G/D studies, and shared-rater and Person-local testlet RSM workflows.
GPCM additions include covariance-aware slope comparisons, fitted-model
bootstrap inference and calibration uncertainty in probability/information
curves. Existing API names and defaults remain compatible where documented.

The help separates model structure, numerical eligibility and statistical
performance. Approximate inference is not a general finite-sample guarantee;
observed probability-interval undercoverage and unqualified bootstrap
repeated-sample accuracy remain explicit. Proprietary external software is
not required. RTMB is optional for shared-rater estimation. Unassigned ratings
are not imputed, and multidimensional MFRM/arbitrary G-theory structures are
not claimed.

## Frozen local archive

`mfrmr_0.2.4.tar.gz`, SHA256:
`0f1f21c042512318a3b3c8ffbce246bcdab21db1d3dc2dce2cf5e091c58155e1`

The archive contains 15 matching article source/output/index entries and
72 figures with alternative text. Three changed articles were executed or
rendered using exact-input saved fits; twelve unchanged HTML articles were
retained byte-for-byte. Internal validation records and local paths are
excluded from the package/user-visible article text.

## Local checks

Environment: arm64 macOS, R 4.6.1.

- The initial exhaustive local check used `NOT_CRAN=true` and
  `R CMD check --as-cran --no-vignettes --timings`. It passed 23,290 test
  expectations, found three failures, and had zero test warnings and 45 skips.
  It was not a clean full-suite pass.
- An input-routing defect in `mfrm_results()` and an outdated test double
  caused those failures. All affected reporting paths pass 428 focused
  expectations; the corrected GPCM readiness test passes 88. No numerical
  estimator, covariance formula, interval or acceptance rule was changed.
- The final archive differs from that checked archive only in the input-routing
  function, two test files, NEWS/date and a restored vignette index. All other
  archive bytes agree. The final installed routing repair is also verified.
- Of the 45 skips, source-documentation/S3 checks are covered separately
  (574 passing expectations), and fresh-session calibration replay passes
  separately (12). The remaining 32 require deliberately excluded research
  artifacts; they are not represented as newly executed checks.
- Ordinary examples, `--run-donttest` examples and PDF/HTML manuals passed
  in the initial run. They were not repeated after the bounded repair.
- The exact final archive passes
  `R CMD check --as-cran --no-examples --no-tests --no-manual --timings`:
  **0 errors, 0 warnings, 1 NOTE**. All fifteen vignettes rebuild in CRAN mode.
  The installed vignette index and all fifteen referenced outputs are verified.

The remaining NOTE reports the maintainer and seven updates in six months.
The initial missing-index NOTE detail is resolved. A preliminary sandboxed
attempt stopped before tests because repository names could not be resolved;
its log is retained separately from the completed network-enabled checks.
No upload or submission was involved in those read-only repository queries.

## Cross-platform checks and website

Source commit `6f541bfa3ff5eb6f59e513ee4a375956e9119eb7` passes
[five-platform CI](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36155335441):

- macOS arm64, R 4.6.1.
- Windows, R 4.6.1 UCRT.
- Ubuntu, R 4.6.1 and R 4.5.3.
- Ubuntu, R-devel (2026-09-23 r90586).

All five independently built source packages report `Status: OK` (zero errors,
warnings or notes). These are ordinary checks with `--no-manual` and
`NOT_CRAN=false`, not five new exhaustive or `--as-cran` runs. Each also passes
the international-input and moved-folder replay checks. These CI archives are
identified separately from the frozen local archive above.

The [site build](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36155335057)
and [Pages deployment](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36159750653)
succeed. Published GPCM help and tutorial source links match the checked commit.
The follow-up result-recording commit changes only package-excluded documents;
package sources and CI configuration are unchanged.

## Before submission

Match tagged release assets to this checked source and perform any further
pre-submission Windows checks on the chosen archive.
Keep CRAN submission and acceptance distinct from local checks or GitHub
publication. Historical check logs and detailed evidence remain in the
repository's validation record; they are not bundled in the submitted package.
