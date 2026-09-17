# Differentiating the moving-node adaptive MML objective

Date: 2026-09-14. Development version: 0.2.4.9000.

## Question and implementation

Can adaptive refits retain the integral agreement of the
[numerical optimization prototype](adaptive-optimization-probe-0.2.4.md)
while avoiding a separate objective evaluation for every finite-difference
coordinate? Does the gradient differentiate the actual finite adaptive sum,
including its parameter-dependent nodes?

Within these ten conditions, yes: all coordinate comparisons passed on both
platforms, refits retained agreement with independent integration, and the
analytic implementation needed fewer marginal evaluations. This completes the
internal gradient calculation; it does not complete a public adaptive fitter.

`R/core-adaptive-quadrature.R` now contains an internal value/gradient evaluator.
It shares the one-Person probability, posterior-score and curvature kernel with
the existing public integration review. The fixed-grid public fitter does not
select this evaluator. No adaptive `mfrm_fit` object or covariance report is
manufactured by the validation code.

The implementation reuses the actual sparse adjacent-logit constraint design:
signed facets, fixed anchors, interaction constraints and owned/shared step
constraints enter in their optimizer coordinates. Category accumulation gives
the derivative of each category logit. GPCM differentiates its entire sloped
predictor, including the steps. The normal-prior derivatives include population
regression coefficients and log residual variance. Sparse designs are prepared
once; probabilities are dense only for the current Person. No dependency was
added. This is an R implementation; no large-data performance claim is made.

Differentiating modes implicitly and propagating curvature changes follows the
general approach in [Stringer, sections 3.1 and 3.4](https://arxiv.org/html/2310.01589v2).
The ordinal-response derivative calculation here was implemented for mfrmr's
parameterization, rather than importing the paper's Bernoulli-model code.
In physical ability coordinates, let `h(theta, psi)` be a Person's log likelihood
plus log normal prior, `m` its mode, `H = -h_theta,theta(m)`, and `s = H^(-1/2)`.
For standard-normal Hermite nodes/weights `(tq, wq)`:

```text
theta_q     = m + s*tq
log_joint_q = log(wq) + h(theta_q, psi) - log(phi(tq)) + log(s)
dm/dpsi     = h_theta,psi(m) / H
dlog(s)     = -(H_psi(m) + H_theta(m)*dm/dpsi) / (2*H)
dtheta_q    = dm/dpsi + s*tq*dlog(s)
dlog_joint_q = h_psi(theta_q) + h_theta(theta_q)*dtheta_q + dlog(s)
```

Posterior-weighted summation gives the gradient of the log finite sum; the
objective and gradient negate this for minimization. The likelihood score,
curvature and curvature derivative use conditional category moments through
order three. Holding the nodes fixed would omit terms in the last line.
These are derivatives of an approximation, not exact continuous-integral
derivatives at arbitrary quadrature orders.

## Design and checks

The [runnable probe](adaptive-gradient-probe-0.2.4.R) reuses the previous ten
saved source fits. The conditions are short/long weighted RSM, PCM and GPCM,
connected sparse PCM with a fixed rater anchor, RSM with an interaction,
GPCM with free population variance, and RSM with a population regression.
Each fixture has eight Persons and fractional category-frequency weights.
These deliberately constructed likelihoods are numerical probes, not ten
random samples or an estimator-recovery experiment.

- At each of five orders (1, 3, 15, 31, 61), evaluate the ordinary initial
  vector, fixed-Q31 fit, previous adaptive-Q61 solution, and a deterministic
  perturbation of that solution. Compare every analytic gradient coordinate
  with whole-objective central differences at steps 1e-4 and 5e-5, retaining
  both the step change and the Richardson extrapolation. Low orders help expose
  omitted node-motion derivatives; Q1 is an internal derivative probe, not a
  new public scoring option.
- Refit using analytic gradients at Q15/Q31/Q61 from fixed-Q31 parameters,
  and Q31 from the ordinary initial vector. At Q31, repeat the two starts with
  the previous numerical-gradient objective in the same process. All use
  BFGS, `reltol = 1e-12`, `maxit = 200`; numerical gradients use step 1e-4.
  An exact parameter-key cache shares analytic value/gradient work and copies
  the key because the optimizer may reuse its callback buffer.
- Check the terminal analytic gradient. When its maximum absolute component
  exceeds 1e-4, polish the same objective with `reltol = 1e-14`. Retain original
  and final gradients, evaluation counts, times and objective improvement.
  This reuses the previous engineering follow-up rule; it is not a universal
  statistical adequacy threshold.
- At each final analytic-Q61 solution, compare log marginal likelihood, EAP,
  posterior SD and gradient with the previous independent continuous
  integration reference. Compare a numerical derivative of the analytic
  gradient with a whole-objective finite-difference Hessian; record the
  smallest Hessian eigenvalue. This is a local curvature check, not a proof of
  global optimality or interval coverage.
- Extend the packaged regression test with facet and step anchors, an
  interaction, population regression, GPCM population scale, nonunit weights,
  zero-weight prior-only calculations and invalid inputs. Derivatives are
  evaluated away from a solution, so fixture-fit convergence is not assumed.
- Repeat the existing 84 fixed-parameter integration conditions and the nine
  relevant test files after sharing the probability kernel. These include
  ordinary and frozen-artifact scoring and fresh-process artifact reading.

The derivative comparison requires maximum absolute error below 1e-6, the
independent continuous-gradient comparison below 1e-5, and Hessian comparison
below 1e-3. These tolerances are executable validation checks in this probe.

## Results

Both macOS (R 4.6.1) and Linux (R 4.3.2) completed 200 objective/parameter-point
comparisons, containing 1,200 gradient-coordinate comparisons, and 60 refits
(40 analytic and 20 numerical-gradient refits). All executable checks passed.

| Maximum absolute discrepancy | macOS | Linux |
| --- | ---: | ---: |
| Gradient versus whole adaptive objective differences | 1.67e-8 | 9.20e-9 |
| Objective versus existing adaptive reviewer | 0 | 0 |
| Q61 objective versus independent continuous integration | 4.55e-13 | 4.55e-13 |
| Q61 gradient versus continuous-integral differences | 3.17e-7 | 3.21e-7 |
| Q61 EAP versus continuous integration | 3.98e-14 | 2.91e-14 |
| Q61 posterior SD versus continuous integration | 2.34e-15 | 1.53e-15 |
| Hessian from analytic-gradient differences versus whole-objective differences | 3.61e-5 | 2.30e-5 |

All ten Hessians were locally positive definite; the smallest eigenvalue was
1.26535. All source fitted objects remained serialization-identical after the
probe. Across platforms, the largest final analytic-Q61 free-coordinate
difference was 1.38e-8; across all four analytic refit plans it was 1.75e-8.
The largest final analytic coordinate difference from the previous numerical
Q61 baseline was 3.96e-6, including the different-start runs.

An analytic gradient does not remove termination-tolerance effects. Four of
40 analytic refits and four of 20 numerical refits on each platform required
the declared polish. Before polishing, the largest gradient component was
about 0.002633 despite optimizer convergence code zero. After polishing,
all codes remained zero and the largest component was 8.44e-5 for analytic
refits and 8.56e-5 for numerical refits. These results support checking the
terminal gradient separately from the optimizer's return code.

For the 20 matched Q31 comparisons on each platform:

| Computation before optional polish | macOS | Linux |
| --- | ---: | ---: |
| Total analytic value/gradient evaluations | 943 | 934 |
| Total numerical-gradient objective evaluations | 4,464 | 4,463 |
| Median numerical / analytic evaluation-count ratio | 4.45 | 4.85 |
| Median numerical / analytic elapsed-time ratio | 4.85 | 4.74 |

Counts refer to complete marginal evaluations, not individual probability
kernel calls or floating-point operations; an analytic evaluation also computes
the gradient. Timings are one run per pair on the eight-Person fixtures, with
other validation jobs running, not a controlled or large-data benchmark.
The retained [refit ledger](adaptive-gradient-probe-0.2.4-runs.csv) includes
separate initial and polished counts/times. The full
[coordinate comparisons](adaptive-gradient-probe-0.2.4-derivatives.csv) and
[reference/curvature checks](adaptive-gradient-probe-0.2.4-checks.csv) retain
the numerical evidence, including values close to zero.

The kernel refactor reproduced all 252 rows of the previous 84-condition
integration audit identically on each platform. The nine targeted test files
passed 80 blocks / 816 assertions on each platform, with zero failures,
errors, warnings or skips. Their [test ledger](adaptive-gradient-probe-0.2.4-tests.csv)
includes the existing public scoring and fresh-process artifact routes.
Both targeted runs used installed packages. The first added test attempt
incorrectly assigned the shared-step scope to a PCM fixture; passing its actual
scope to the existing constraint builder corrected that test configuration.

macOS `R CMD build` and `R CMD check --no-manual` completed with 0 errors,
0 warnings and 0 notes, including rebuilt vignettes. The lightweight check
passed 579 assertions with three declared CRAN-only skips. The checked archive
is `/tmp/mfrmr-adaptive-gradient/mfrmr_0.2.4.9000.tar.gz`, SHA256
`2a1d00788b7400092cc4fba89aa6db333c22ca11539d2ac6e03de87dc18d23f8`.
All 482 packaged R/test/Rd files match the working tree byte-for-byte.
Linux used the existing Ubuntu 22.04.4 arm64 image
`mfrmr-prerelease-qa:20260913`, with OpenBLAS/LAPACK, and the same archive.
[Source and input hashes](adaptive-gradient-probe-0.2.4-source.csv) identify
the implementation, validation scripts, test, and ten source-fit RDS inputs
per platform. Raw refits and platform comparisons are under
`/tmp/mfrmr-adaptive-gradient/`.

## Public integration remaining

The new internal evaluator supplies the value and moving-node gradient needed
for adaptive optimization. Public fitting still uses its existing fixed-grid
engine. Connecting the new evaluator requires the same integration choice to
reach final likelihood and information criteria, Hessian/covariance and
estimability checks, posterior scoring/draws and diagnostics, and saved/replayed
fit identities. Portable calibration also needs an explicit scoring contract
for such fits. The current fixed-parameter review and its defaults remain in
place; numerical refit results are separate validation artifacts.

This work does not reclassify TAM/ConQuest equivalence, recovery or coverage,
linking/anchor transport, or G-theory validity. The broad Windows/CI and external
comparison grids have not been rerun in this stage.

## Reproduction

From the development root with dependencies installed:

```r
pkgload::load_all()
source("inst/validation/adaptive-optimization-probe-0.2.4.R")
input <- tempfile("adaptive-input-")
run_adaptive_optimization_probe(input)
source("inst/validation/adaptive-gradient-probe-0.2.4.R")
run_adaptive_gradient_probe(input, tempfile("adaptive-gradient-"))
testthat::test_local(filter = "^adaptive-quadrature-review$")
```

The probe writes full-precision coordinate comparisons, refit results and
reference checks to CSV, with raw optimizer objects in per-case RDS files.
