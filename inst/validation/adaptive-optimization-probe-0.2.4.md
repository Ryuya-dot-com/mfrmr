# Adaptive-quadrature optimization: bounded numerical prototype

Date: 2026-09-14. Package version: 0.2.4.9000.

## Question and answer

The previous [fixed-parameter review](adaptive-quadrature-review-0.2.4.md)
showed that positive Hermite weights and even Q301 can miss a narrow posterior.
Does adapting the integration at every optimization proposal also reduce
dependence of the estimated calibration on quadrature order and starting values?

In the ten numerical designs below, yes. Adaptive Q15/Q31/Q61 found almost the
same solution from the fixed-Q31 starting point. At the adaptive Q61 solutions,
an independently expressed continuous integral agreed with the likelihood and
posterior summaries, and its numerical derivatives agreed with derivatives of
the adaptive objective. Different initial values exposed a stopping-criterion
issue; a targeted follow-up reduced the remaining gradients.

This is an executable research prototype in `inst/validation`, **not a new
`fit_mfrm()` engine**. It returns ordinary optimization lists and never fabricates
an `mfrm_fit` by inserting new parameters into stale fixed-grid diagnostics.
Public fitting, scoring, readiness, checkpoints, and calibration artifacts are
unchanged.

## Design and reason for each comparison

All designs have eight Persons, two Raters, two Criteria and four categories.
The inputs are deterministic weighted category-frequency tables, obtained from
explicit logits with nonzero facet effects and steps. Each Person/cell has total
weight 2 or 80, giving total weight 8 or 320 per Person in complete designs.
GPCM uses slopes 0.7 and 1/0.7. The short/long comparison isolates increasing
posterior concentration without adding parameters or random sampling noise.

| Designs | Purpose |
| --- | --- |
| Short and long RSM, PCM, fixed-standard-normal GPCM (six designs) | Shared versus owner-specific steps, estimated relative slopes, and weak versus concentrated individual likelihoods |
| Long PCM, connected incomplete layout, R1 anchored at −0.4 | Preserve the exact anchor and owner-specific steps when one of four cells is absent per Person |
| Long RSM with Rater × Criterion interaction | Ensure the interaction remains in the adaptive likelihood |
| Long GPCM with estimated population SD | Differentiate the integration after the prior scale changes, retaining the existing identification constraints |
| Long RSM with population regression `~ X` | Recompute Person-specific prior means and the shared residual variance during optimization |

The weighted tables deliberately contain multiple category rows for the same
Person/facet cell. The package's duplicate-cell warning is retained in the
[condition ledger](adaptive-optimization-probe-0.2.4-conditions.csv), once per
source design and platform. This is a compact power-likelihood calculation for
numerical testing, not an endorsement of accidental duplicates in applied data.
Weights are fractional expected frequencies, not simulated integer response
counts. None of these designs is a parameter-recovery or coverage experiment.

For each design, the retained candidates are fixed Q31/Q61/Q181/Q301 and
adaptive Q15/Q31/Q61 started at the fixed-Q31 estimate, plus adaptive Q31 started
at the package's ordinary initial vector. This gives 80 candidates per platform:
40 fixed and 40 adaptive. Constraints and prepared response rows are identical
within each design. No candidate is dropped because its coordinates disagree.

The adaptive objective calls the existing internal integration reviewer at
each proposed parameter vector. A one-node fixed comparator is computed only
to reuse that reviewer; it does not enter the optimized objective. BFGS receives
`gr = NULL` and finite-difference step 1e-4, so the **whole adaptive objective**
is differenced, including recomputed modes and local scales. It does not reuse
the existing fixed-grid analytical gradient. See the [R optim documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html)
for numerical differentiation and the objective-based relative stopping rule.
Differentiating the adaptive approximation is also the distinction described
in the [SAS NLMIXED integral-approximation documentation](https://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/statug_nlmixed_sect024.htm).

All candidates are compared on a common adaptive-Q61 objective, with Person
EAP/SD recomputed at their respective parameters using that same integration.
Thus the reported EAP/SD movement isolates calibration-parameter movement;
it is not the total difference between the public fixed-grid score and an
adaptive score. Fixed-Q31, fixed-Q301 and adaptive-Q61 solutions are additionally
evaluated with the independent continuous integral. Their own approximate
objective values are retained but are not used interchangeably to rank fits.

## Results

macOS R 4.6.1 and Linux R 4.3.2 both completed all 80 candidate fits with optimizer
code zero. That code alone did not establish a small terminal gradient.
The table shows macOS maximum absolute differences in expanded facet, step and
interaction coordinates from the adaptive-Q61 solution; slopes and population
parameters are separate columns in the full run ledger.

| Design | Fixed Q31 | Fixed Q301 | Adaptive Q31, same start |
| --- | ---: | ---: | ---: |
| RSM short | 3.06e-5 | 1.03e-8 | 5.04e-9 |
| PCM short | 6.66e-5 | 1.99e-6 | 1.58e-10 |
| GPCM short | 7.70e-4 | 6.13e-7 | 3.33e-11 |
| RSM long | 0.1278 | 0.00803 | 1.03e-11 |
| PCM long | 0.1399 | 0.00969 | 1.19e-11 |
| GPCM long | 0.1418 | 0.02259 | 1.66e-11 |
| PCM incomplete/anchored | 0.1447 | 0.00703 | 2.91e-11 |
| RSM interaction | 0.1299 | 0.00837 | 2.99e-9 |
| GPCM population SD | 0.00906 | 0.00200 | 1.72e-8 |
| RSM population regression | 0.00211 | 0.00225 | 9.60e-9 |

On the common surface, fixed Q31's negative-log-likelihood excess reached 3.429;
Q301's reached 0.430. The latter was the population-regression design: estimated
residual SD was 1.10941 at fixed Q301 versus 0.884370 at adaptive Q31/Q61.
Fixed Q61 and Q181 gave 1.02169 and 1.02084, illustrating why agreement between
two nearby fixed-grid estimates is not by itself a guarantee of adequate
integration. The incomplete PCM anchor remained exactly −0.4.

At all ten adaptive-Q61 solutions, maximum absolute errors against continuous
integration across the two platforms were:

| Quantity | Maximum absolute difference |
| --- | ---: |
| Total negative log likelihood | 4.55e-13 |
| Person EAP | 4.02e-14 |
| Person posterior SD | 2.92e-15 |
| Central-difference gradient, adaptive versus continuous objective | 4.55e-9 |

The local numerical Hessians were positive definite in these designs. The
reference uses the independently expressed logits and mode-centered continuous
integration from the preceding audit, repeats local ranges ±32 and ±64, and
checks integration-error estimates and log-concavity tail-mass bounds.
Agreement is evidence for these calculations, not a universal error bound,
proof of a global optimum, or qualification of Hessian-based standard errors.

The 30 common-surface checks per platform also confirmed the adaptive-Q61
likelihood at fixed-Q31 and fixed-Q301 parameter vectors. The largest common
gradient at a fixed-Q31 solution was about 36.43 despite its own optimizer's
code zero. This separates accurate optimization of a coarse discrete objective
from stationarity of the better-integrated objective.

## Initial values and terminal gradients

From the same starting point, macOS adaptive Q15/Q31 versus Q61 expanded
measurement-coordinate differences were at most 1.73e-8. Starting Q31 from the
ordinary initial vector produced differences up to 5.73e-6 and small objective
differences, but the maximum terminal gradient was 0.00263. Four long-design
runs on each platform retained gradients above 1e-4.

The follow-up used the same numerical objective and BFGS with relative tolerance
1e-14 instead of 1e-12 for those four candidates. All 40 adaptive candidates
then had checked terminal gradients below 1e-4; the maximum was 8.53e-5.
Gradient step halving from 5e-5 to 2.5e-5 changed these gradients by at most
2.51e-7. Objective values did not deteriorate. Final free-coordinate differences
from the Q61 reference were at most 3.95e-6, including the alternative starts.
These are recorded numerical residuals, not a package-owned practical stability
classification. The 1e-4 follow-up target was selected after reviewing the
initial residuals; it is not a prospectively calibrated scientific cutoff.

Across macOS and Linux, adaptive-Q61 free coordinates differed by at most
1.86e-8. The frequency inputs, all candidate coordinates, initial and follow-up
residuals, independent reference checks and warnings are retained below. The
first persistence check failed for the regression fixture because a locally
created formula captured the mutable audit frame. Giving that pure formula
`baseenv()` fixed the fixture; the affected design was rerun on both platforms.
The corrected check confirms that source fits remain unchanged. This was not
a calibration-parameter mutation by the optimizer.

## Boundary before public implementation

The prototype demonstrates a usable numerical objective but does not complete
the public fitting contract. Numerical finite differences required up to 655
objective calls per candidate even with eight Persons. A public engine needs
consistent integration identity and behavior across the optimizer, terminal
gradient/Hessian checks, estimability and GPCM boundary checks, Person summaries,
quadrature sensitivity, checkpoints and portable-calibration extraction. The
existing callers were traced in `core-optimizer.R`, `core-estimability.R`,
`core-mml-gpcm-slope-boundary.R`, `mfrm_core.R`, prediction, tables, sensitivity
and fixed-calibration code. Copying a new optimum into the old fit structure
would leave some of those calculations on the wrong integration basis.

Analytical moving-node derivatives, large-dataset performance, broader starting
values/boundaries, adaptive intervals/draws, and public persistence/replay tests
remain open. This turn does not rerun TAM/ConQuest comparisons, validate linking
or anchor invariance, change G-theory, or establish estimator recovery or
interval coverage. The sparse anchored numerical case is not evidence for
linking disconnected components.

No production R, packaged test, or Rd file changed: all 482 such files still
match the previously checked archive, SHA256
`15f7c6d5003ba20381c385ae45ad40783b3bcac4a02724cf9a7e151f52917cfb`.
Package checks were therefore not repeated for this validation-only change.
The new prototype's own numerical checks and follow-up checks passed on both
platforms; final per-design results replace the corrected fixture's earlier
failed serialization check.

## Reproduction and retained evidence

From the development root:

```r
pkgload::load_all()
source("inst/validation/adaptive-optimization-probe-0.2.4.R")
out <- tempfile("adaptive-optimization-")
run_adaptive_optimization_probe(out)
review_adaptive_optimization_probe(out)
```

The optional `cases` argument restricts the first function to named designs
for a focused rerun. Linux used the existing Ubuntu 22.04.4 arm64 image
`mfrmr-prerelease-qa:20260913`, R 4.3.2, OpenBLAS 0.3.20/LAPACK 3.10.0 and the
previously installed diagnostic-enabled package. macOS used R 4.6.1 and
LAPACK 3.12.1. This adds no dependency.

- [Prototype](adaptive-optimization-probe-0.2.4.R) and [source hashes](adaptive-optimization-probe-0.2.4-source.csv)
- [Inputs](adaptive-optimization-probe-0.2.4-inputs.csv), [candidate runs](adaptive-optimization-probe-0.2.4-runs.csv) and [free coordinates](adaptive-optimization-probe-0.2.4-coordinates.csv)
- [Independent solution checks](adaptive-optimization-probe-0.2.4-checks.csv) and [common objective checks](adaptive-optimization-probe-0.2.4-common.csv)
- [Terminal-gradient follow-up](adaptive-optimization-probe-0.2.4-terminal.csv) and [conditions](adaptive-optimization-probe-0.2.4-conditions.csv)
