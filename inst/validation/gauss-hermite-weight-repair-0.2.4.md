# Gauss–Hermite weight repair and numerical consequences

Date: 2026-09-14 (Asia/Tokyo). Development version: 0.2.4.9000.

The shared weight-generation defect is repaired and checked on macOS and
Linux. This closes the reproduced Q61/Q121/Q181 zero-weight mechanism in
the tested environments. It does **not** certify quadrature adequacy for
arbitrary response patterns, interval coverage, or release readiness.

## Questions and design

1. **Where are positive weights lost?** Compare the old eigensolver's first-row
   eigenvector components with the weights after squaring. Compare the repaired
   rule with a 100-digit construction, using relative errors for tiny weights.
   Normal moments and absolute errors alone cannot answer this question.
2. **Can the loss affect an analysis?** First hold model parameters fixed and
   compare likelihoods, gradients, EAP and posterior SD. Then separately
   reoptimize from identical starts. Probe short/long and central/extreme
   response patterns against a qualified continuous integral, so integration
   error is not confused with optimizer movement.
3. **Do all consumers receive the repair?** Trace the shared generator through
   optimization, diagnostics, scoring, and calibration persistence; exercise
   the public calibration lifecycle with distinct fit and scoring orders.
4. **Does existing external agreement survive?** Replay the existing small
   matched TAM comparison without altering its fixture or historical results.

These are numerical regression checks and deliberately adversarial microcases.
They are not randomly replicated parameter-recovery or coverage experiments.

## Cause and implementation

On both tested runtimes the old Q61/Q121/Q181 rule has respectively 4/36/74
zero first-row eigenvector entries **before squaring**, and the same numbers
of zero weights afterward. These cases are not weights below the binary64
representable range. The attribution is to loss in the returned eigensolver
components; this audit does not identify an internal LAPACK branch.

The corrected `gauss_hermite_normal()` retains the standard-normal
Golub–Welsch node construction. It obtains weights from

`w(x_i) = 1 / sum_{k=0}^{n-1} p_k(x_i)^2`, where `p_k = He_k / sqrt(k!)`.

The recurrence evaluates `exp(-x_i^2/4) * p_k(x_i)` to avoid overflowing
the squared sum, then restores the scale in logarithms. Nodes are symmetrized
and weights normalized. No epsilon substitution, clipping, new dependency,
or relaxation of calibration positivity was introduced. The relationship
between orthonormal recurrences, the Jacobi matrix, and quadrature weights is
described in [DLMF §3.5(vi)](https://dlmf.nist.gov/3.5.vi).
[SciPy's documented Hermite construction](https://docs.scipy.org/doc/scipy/reference/generated/scipy.special.roots_hermitenorm.html)
also separates eigenvalue-based nodes from analytical weight evaluation;
the production repair does not call or copy SciPy's implementation.

The independent Python check refines physicists' Hermite roots at 100 decimal
digits and uses derivative-based weights. Each refined root must have a
Newton correction below `1e-90`. It does not reuse R's eigenvector or
Christoffel squared-sum weight calculation. Python/mpmath is a validation
dependency only.

| Order | Old zero weights | New zero weights | Smallest new weight | Maximum relative weight error, macOS |
| --- | ---: | ---: | ---: | ---: |
| 31 | 0 | 0 | 2.6060e-22 | 5.78e-14 |
| 61 | 4 | 0 | 9.3712e-47 | 4.99e-13 |
| 121 | 36 | 0 | 7.8994e-97 | 1.05e-12 |
| 181 | 74 | 0 | 1.6466e-147 | 1.99e-12 |
| 301 | 162 | 0 | 1.2423e-249 | 3.51e-12 |

All integer orders 1–201 and orders 241, 301, 351, 381 returned positive,
finite, normalized weights on both runtimes. Q381 reaches subnormal values
(minimum approximately `5.15e-318`); its maximum relative error is about
`9.24e-8`, so Q301 accuracy must not be extrapolated to it. A Q400 regression
check verifies explicit refusal when all weights cannot be represented as
positive finite doubles. The API does not promise arbitrarily high orders.

Permanent tests include symmetry, normal moments through degree 8,
high-precision tail-weight ratios, and a tilted-normal integral whose
posterior has mean 14 and variance 1. The tilted case detects the consequence
of lost tail weights that central moments can miss. The regression file is
also included in the lightweight package-check selection for future OS CI.

## Likelihood, gradients, and scoring consequences

The operational example is one dataset with 48 Persons and 282 ratings.
RSM and PCM were checked at Q31/Q61/Q121/Q181. At fixed parameters, macOS
old/new maximum differences were `5.12e-13` in negative log likelihood,
`1.37e-13` in gradient coordinates, `1.83e-14` in EAP and `1.05e-14` in
posterior SD. In eight separate old/new direct-optimization pairs from
identical initial vectors, all optimizer codes were zero; the maximum
coordinate change was `6.38e-11`. These results establish continuity for
this ordinary example, not universal negligibility of the defect.

The numerical stress grid has **36 conditions**: 4/100/1,000 unit-weight
ratings; difficulties −16/0/8/16; balanced 0–3 responses, all-high or all-low.
The fixed model is a four-category RSM with zero steps and a N(0,1) prior.
Each condition is evaluated at five orders (31/61/121/181/301), with the old
and new rules: 360 evaluations per platform. These repeated-rating patterns
test numerical limits; they do not represent a prevalence estimate of user
datasets or a realistic fitted-data study.

The continuous reference centers the integrand at its independently located
mode and integrates each side. Results on [−40,40] and [−45,45] must agree
within `1e-8` for NLL, EAP, SD and the difficulty gradient. Because
`d² log f / d theta² = -1 - n Var(K | theta) < 0`, tangent exponentials at
the endpoints bound omitted tails relative to the marginal probability.
The largest reported relative mass-integration error was `4.24e-12`; all
log relative tail bounds were below −584. The initial crude normal-tail
bound was too loose for long, very unlikely patterns; it was replaced by
this log-concavity bound before retaining the continuous comparisons.
This reference is qualified for these fixed-RSM probes, not general GPCM
or arbitrary population models.

For **100 highest-category ratings at difficulty 16**, the continuous EAP is
approximately **17.90358**. At Q181 the old rule gives **25.95815** with
numerically zero posterior SD: the retained endpoint dominates after the
intermediate tail nodes have lost their weights. The new rule gives
**17.90328**, with SD error approximately `4.65e-4`. At Q301, the new EAP
error is `1.83e-7` and SD error `3.44e-7`.

Conversely, **1,000 balanced ratings at difficulty 0** remain insufficiently
resolved even by the corrected Q301 grid: absolute NLL error is about
**0.9371** and SD error **0.02827**, while the EAP remains essentially zero.
Thus symmetry, a plausible EAP, a converged optimizer, and positive weights
do not certify adequate quadrature. The maximum absolute centered-finite-
difference gradient discrepancy in the corrected stress grid was `1.73e-5`
(step `1e-4`); remaining discrepancies against the continuous gradient are
reported separately as integration error, not hidden as optimizer failures.

Across the corrected 180 evaluations, macOS/Linux maximum differences were
`1.03e-12` in NLL, `3.98e-13` in EAP, `2.90e-14` in SD, and `9.77e-15` in
gradient. Agreement across platforms does not remove the integration error
against the continuous reference.

Additional macOS checks held fitted parameters fixed for an RSM with
`~ Group` latent regression and a bounded GPCM with its default estimated
population scale. Q31/Q61/Q121/Q181 old/new EAP differences were below
`1.71e-14`; fitted-object scoring at Q181 was finite. Both source fits kept
`InferenceReady = FALSE`; review-only scoring did not promote their status.

## Shared callers and persisted identities

The generator feeds direct and EM optimization and checkpoint identity
(`core-optimizer.R`), fitted Person EAP and diagnostic rebuild paths
(`mfrm_core.R`), estimability/information audits (`core-estimability.R`),
GPCM slope-boundary checks (`core-mml-gpcm-slope-boundary.R`), iteration
tables (`api-tables.R`), fitted-object scoring (`api-prediction.R`), and
calibration extraction (`core-fixed-calibration.R`). Likelihood, gradient,
and C++ dispatch receive the same nodes/weights through these callers.

New calibrations and checkpoints identify
`gauss_hermite_standard_normal_recurrence_v2`. Calibration review also
recognizes the previous `...golub_welsch_v1` identity, while still requiring
positive, finite, normalized stored weights. Valid old frozen calibrations
use their stored grids unchanged. An actual Q31 calibration saved with the
pre-repair installed package was loaded by the repaired package; the object
and scored estimates were identical. Old optimizer checkpoints are not
silently resumed under a changed quadrature identity.

The public lifecycle was exercised for RSM and PCM on both platforms:
same-data Q31/Q61 review → exact Q61 source fit → extraction with scoring
Q31/Q61/Q121/Q181 → review → validation → freezing → saving/loading → scoring.
All eight combinations per platform passed review. Portable and fitted-object
EAP differences were at most `3.11e-15` on macOS and `4.45e-16` on Linux.
Readiness, model-scope, and calibration-uncertainty restrictions are unchanged.

## External and package regression checks

The existing additive TAM runner was reused with its current-head bridge.
TAM 4.3.25 and the bound `tam.mml.mfr` function hash matched the retained
contract. All four RSM/PCM × Q31/Q61 runs completed without warnings or
messages. Maximum coordinate difference was `9.90e-8`; maximum absolute
deviance difference was `2.23e-7`. Q61 deviance differences were below
`1.71e-12`. This preserves the small fixture's agreement; it does not rerun
the broader historical stress grid, ConQuest, or establish equivalence.

Targeted regression results: macOS **10 files, 158 blocks, 1,100 passing
assertions**; Linux **5 files, 48 blocks, 504 passing assertions**. Final
targeted results have zero failures, errors, warnings, or skips. Installed
public calibration tests include saving an artifact and scoring in a fresh
R process. An existing documentation test initially assumed every R
installation contained the top-level README; both the old and new R4.3.2
packages omitted it. The test now uses the source README when available,
or explicitly skips that source-document check if it is unavailable.

macOS `R CMD build` and `R CMD check --no-manual` pass, with **0 errors,
0 warnings, 0 notes**. The lightweight check has 478 passing assertions
and three declared on-CRAN skips. This turn did not rerun the entire broad
regression suite or Windows CI. The earlier five-platform CI result predates
this repair and is not evidence for the repaired source.

The final checked source archive is
`/tmp/mfrmr-gh-repair/final/mfrmr_0.2.4.9000.tar.gz`, SHA256
`01ba6198250f6333f833f20446ec14abc45d75a7e3ec85782e0e23cc11d905ad`.
All listed production files and packaged tests match the working-tree bytes.
Linux used the same production code; its final documentation test was rerun
from the updated source against that installed package.

## Reproduction and retained evidence

Runtime: macOS Tahoe 26.6.2 arm64, R4.6.1, LAPACK3.12.1/libRblas; Linux
Ubuntu22.04.4 arm64, R4.3.2, LAPACK3.10.0/OpenBLAS0.3.20; Python mpmath1.3.0
at 100 decimal digits. Raw outputs and installed packages are under
`/tmp/mfrmr-gh-repair`; durable CSVs below retain the observed numerical rows.

```r
pkgload::load_all(".")
source("inst/validation/gauss-hermite-weight-repair-0.2.4.R")
run_gh_weight_audit("/tmp/mfrmr-gh-audit")
run_gh_population_audit("/tmp/mfrmr-gh-audit")
```

```sh
python3 inst/validation/gauss-hermite-weight-reference-0.2.4.py \
  /tmp/mfrmr-gh-audit/nodes-weights.csv /tmp/mfrmr-gh-audit/reference.csv
```

Retained: [generation](gauss-hermite-weight-repair-0.2.4-rules.csv),
[independent reference](gauss-hermite-weight-repair-0.2.4-reference.csv),
[fixed parameters](gauss-hermite-weight-repair-0.2.4-fixed-parameters.csv),
[reoptimization](gauss-hermite-weight-repair-0.2.4-refits.csv),
[response patterns](gauss-hermite-weight-repair-0.2.4-patterns.csv),
[calibration](gauss-hermite-weight-repair-0.2.4-calibration.csv),
[population/GPCM](gauss-hermite-weight-repair-0.2.4-other-models.csv),
[TAM runs](gauss-hermite-weight-repair-0.2.4-tam.csv),
[TAM coordinates](gauss-hermite-weight-repair-0.2.4-tam-coordinates.csv),
[tests](gauss-hermite-weight-repair-0.2.4-tests.csv),
[source hashes](gauss-hermite-weight-repair-0.2.4-source.csv).

The remaining numerical question is how to detect and remedy inadequate
fixed grids for narrow or far-tail posteriors while preserving the fitted
objective and scoring identity. G-theory, full-refit linking/anchor
uncertainty, coverage confirmation, and broader external comparisons retain
their previously recorded open status. No historical failed comparison was
reclassified or attributed to lost weights by this repair.
