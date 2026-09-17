# Public adaptive MML fitting and downstream consistency

Date: 2026-09-14. Development version: 0.2.4.9000.

## Question and answer

Can the previously validated moving-node objective be used through `fit_mfrm()`
without reporting a likelihood, Hessian, Person score or replay from a different
integration rule? Can a saved calibration preserve the same scoring method in
a fresh R process?

Within the conditions below, yes. Direct MML now accepts
`mml_integration = "adaptive"` for RSM, PCM and GPCM. The fit, Hessian, posterior
Person summaries, expected-category diagnostics, refits and replay use the
selected rule. Public RSM/PCM calibration extraction, validation, freezing,
saving, loading and scoring preserve an explicit adaptive algorithm identity.
This completes the public connection left open in the
[internal gradient audit](adaptive-gradient-probe-0.2.4.md).

```r
library(mfrmr)
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(
  toy, person = "Person", facets = c("Rater", "Criterion"), score = "Score",
  method = "MML", model = "RSM", mml_integration = "adaptive"
)
review <- mml_quadrature_sensitivity(fit, toy, quad_points = c(31, 61))
summary(review)
```

The integration choice is printed in the summary and draft convergence report.
`quad_points` is still the integration order. The default remains `"fixed"`;
omitted settings in older fits retain that meaning. Unknown retained settings
fail explicitly. An integration mode is part of the information-criterion
evaluation identity, so automatic comparisons cannot silently mix modes.

## Design and evidence

The [runnable audit](adaptive-fitting-0.2.4.R) uses actual public fits, not
objects assembled from an optimizer prototype. It reuses the ten input
conditions from the [optimization probe](adaptive-optimization-probe-0.2.4.md):
short/long weighted RSM, PCM and GPCM; connected sparse PCM with a fixed rater
anchor; RSM with a rater-by-criterion interaction; GPCM with free population
variance; and RSM with a population regression. Each has eight Persons and
fractional category-frequency weights. These are deterministic numerical
probes, not random samples for estimating bias, coverage or recovery.

Each condition was fitted at Q31 and Q61 on macOS and Linux: 40 public fits.
The independent continuous-integration reference expresses the category
likelihood and normal prior separately from the package kernels. It checks
the log integral and posterior moments at the returned parameters; central
differences of this continuous objective check the terminal gradient. The
whole adaptive objective supplies a second, finite-difference Hessian check.
Using separate references matters because agreement between downstream
functions alone would not detect a shared integration error.

| Maximum absolute difference or diagnostic | macOS | Linux |
| --- | ---: | ---: |
| Reported log likelihood vs independent continuous integration | 4.55e-13 | 4.55e-13 |
| Analytic gradient vs continuous-objective central difference | 3.16e-7 | 3.18e-7 |
| Person EAP vs continuous reference | 1.81e-13 | 1.81e-13 |
| Person posterior SD vs continuous reference | 9.86e-13 | 9.87e-13 |
| Fitted-object scoring EAP vs fit EAP, same order | 0 | 7.48e-14 |
| Fitted-object scoring SD vs fit SD, same order | 0 | 2.82e-15 |
| Reported Hessian vs whole-objective numerical Hessian | 2.40e-4 | 2.26e-4 |
| Terminal analytic gradient, maximum component | 9.81e-5 | 9.81e-5 |

All 40 fits returned optimizer code 0 and passed the 1e-4 terminal-gradient
threshold. The public gradient diagnostic exactly matched the adaptive
evaluator. The Hessian comparison uses different finite-difference procedures:
the public Hessian differences the analytic gradient at the standard 1e-3
step, while the independent check differences objective values at 1e-4.
The table reports the observed discrepancy without treating that difference
as an estimate of standard-error accuracy.

Across the 120 fitted coordinates per platform, the maximum macOS/Linux
difference was 8.31e-13. The maximum Q31/Q61 coordinate change was 8.30e-13 on
macOS and 4.15e-13 on Linux. These small changes apply to these ten conditions;
Q31 is not a universal guarantee. The earlier prototype and public optimizer
can stop at slightly different points: the maximum difference from the prior
adaptive-Q61 solution was 5.18e-6, with both objective agreement and terminal
gradients checked independently.

The packaged operational example adds actual unweighted RSM/PCM/GPCM fitting.
Tests check Hessians, diagnostics, output text, invalid mode/engine combinations,
default-versus-explicit fixed fitting, retained refit controls, generated replay
code, semantic-identity tampering and unsupported ConQuest export. RSM/PCM
portable scoring is compared with fitted-object scoring after row reordering
and non-unit weighting, including EAP, posterior SD and interval endpoints.
Seeded posterior draws and the public plausible-value wrapper are reproducible.
Their notes describe the inherited integration setting. Anchor refitting and the legacy
FACETS-style workflow also retained adaptive mode in separate public-route
checks.

Fresh-process checks run the full public extraction and freezing sequence on
RSM and PCM, then read the saved fit and calibration in a child `Rscript`.
The scoring batch contains all-low and all-high response patterns. On both
platforms the restored calibration returned exactly the same estimates as
same-process scoring. Its EAP, SD and interval endpoints agreed with fitted-
object prediction to at most 8.89e-16, and both routes retained
`adaptive_quadrature_eap_v1`. These scores remain conditional on the frozen
point calibration; calibration-parameter uncertainty is not added.

## Verification and reproduction

The effective regression ledger covers 23 files, 350 test blocks and 2,909
passing assertions on each platform, with no failures, warnings or skips.
It combines the latest run of each file; it is not a claim that the entire
repository suite was run. Three initial display assertions depended on line
wrapping and were corrected to normalize whitespace. An existing non-unit-
weight IC test now expects both the IC-ineligibility and readiness warnings.
The covariance callback signatures were aligned after an R static-check note.
Affected tests were rerun against the installed archive. Re-evaluation of the
40 stored fits confirmed unchanged likelihoods and gradients, and exact
agreement with the analytic-gradient Hessian route after that signature fix.
The final scope review found that the nonlinear identification classifier
still described a normalized fixed-grid response-pattern model. Its
probability identities and rank certificates have not been established for
pattern-dependent adaptive nodes. Both response-pattern audits and the
classifier now decline this transfer explicitly. Actual public GPCM fits
test the incomplete state, and stored-fit re-evaluation checks the same guards
across the ten conditions. This changes the interpretation of identification
evidence, not the fitted objective or its derivatives.

Platforms: macOS Tahoe 26.6.2, arm64, R 4.6.1, reference R BLAS/LAPACK 3.12.1;
Ubuntu 22.04.4, arm64, R 4.3.2, OpenBLAS 0.3.20/LAPACK 3.10.0. The Linux checks
use the existing local `mfrmr-prerelease-qa:20260913` image. Windows and the full
multi-OS CI matrix were not rerun in this increment.

From the development root with the checked package installed:

```r
library(mfrmr)
source("inst/validation/adaptive-fitting-0.2.4.R")
run_adaptive_fitting_audit(
  "/tmp/mfrmr-adaptive-optimization/audit", "/tmp/adaptive-public-audit"
)
run_adaptive_fitting_fresh_process("/tmp/adaptive-public-fresh")
```

The input directory contains `inputs.csv` and the ten source RDS files from
`run_adaptive_optimization_probe()`. If those temporary files are unavailable,
run that function from `adaptive-optimization-probe-0.2.4.R` first. The current
audit preserves warnings in a separate ledger; the 40 recorded duplicate-cell
warnings come from the deliberately repeated category-frequency rows. They
are not suppressed to declare real duplicate ratings suitable for inference.

Durable evidence: [40 fits](adaptive-fitting-0.2.4-results.csv),
[240 coordinates](adaptive-fitting-0.2.4-coordinates.csv),
[conditions](adaptive-fitting-0.2.4-conditions.csv),
[fresh processes](adaptive-fitting-0.2.4-fresh.csv),
[final numerical re-evaluation](adaptive-fitting-0.2.4-recheck.csv),
[test ledger](adaptive-fitting-0.2.4-tests.csv), and
[source hashes](adaptive-fitting-0.2.4-source.csv).
Detailed temporary artifacts are under `/tmp/mfrmr-adaptive-api`.
The final archive is
`/tmp/mfrmr-adaptive-api/final-v4/mfrmr_0.2.4.9000.tar.gz`, SHA-256
`22bfc7719df93ae7446cfd97b865481e4baa0322222826052fb78754b5860f1b`.
Its 483 R/test/Rd files and ten native-source/source-vignette files match
this checkout byte for byte. Repository-only validation scripts and records
are excluded from the package archive by the existing `.Rbuildignore`.
The macOS `R CMD check --no-manual` completed with no errors, warnings or
notes; its packaged light tests passed 652 assertions with three intentional
CRAN skips. Linux also passed those 652 assertions with the same three skips,
and completed with no errors or warnings and one installed-size note
(9.3 MB: R code 6.1 MB, help 1.5 MB), retained rather than suppressed.

## Remaining scope

Adaptive fitting currently supports the direct engine without checkpoints.
EM/hybrid and checkpoint requests fail explicitly. Adaptive fits with nonlinear
coordinates do not receive a completed probability-map identification audit.
GPCM's existing fixed-node
slope-boundary certificate does not apply when nodes move; adaptive GPCM
records an incomplete boundary audit and remains review-only for formal
parameter inference. No finite-maximum certificate has been established here.
The existing ConQuest comparison export requires fixed integration.

Portable calibration remains limited to its supported RSM/PCM fixed-normal-
prior models. The artifact stores the base Hermite rule and a distinct scoring
algorithm identity; Person-specific nodes are recalculated from each scoring
pattern. There is no silent conversion of old fixed-grid artifacts. Grid-edge
mass and stable quadrature orders remain diagnostics, not accuracy guarantees.

This increment did not rerun the broad TAM/ConQuest equivalence studies,
G-theory experiments, linking-transport studies, or estimator-recovery and
coverage simulations. A connected sparse anchored case does not establish
anchor transportability or repair disconnected designs. The earlier
[Hermite-weight repair](gauss-hermite-weight-repair-0.2.4.md) remains in place;
adaptive integration addresses posterior concentration and does not replace
that weight calculation. Large-data performance, extreme-data stability and
general release readiness require their own evidence.
