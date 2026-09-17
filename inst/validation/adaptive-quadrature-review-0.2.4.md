# Adaptive integration review at fixed calibration parameters

Date: 2026-09-14. Development version: 0.2.4.9000.

## Question and scope

Can users detect inaccurate posterior integration after the tiny Gauss–Hermite
weight repair, including narrow central posteriors that an edge-mass warning
misses? Can the same comparison be obtained from a fitted object and from a
saved calibration without changing the reported scores?

The answer in the tested conditions is yes: the optional review below compares
the actual fixed grid with posterior-mode/curvature-adapted grids at unchanged
parameters and prior. It is a diagnostic, not a new fitting or scoring engine.
The [weight-repair audit](gauss-hermite-weight-repair-0.2.4.md) remains the
separate record of the earlier generator change and external TAM comparison.

## Implementation and interpretation

`adaptive_quad_points = c(31, 61)` is now accepted by:

- `mml_quadrature_sensitivity()` and its GPCM alias;
- `predict_mfrm_units()`;
- `score_mfrm_calibration()`.

Defaults retain existing behavior. When requested, `quadrature_review` retains
unrounded per-Person log-marginal likelihood contributions, EAP and posterior
SD on the fixed and adaptive grids, signed differences, changes between
adaptive orders, mode/local width, root residual, and computation status.
`summary()` preserves that table and supplies `quadrature_overview` with counts
and maximum absolute differences. Failed Persons are retained as `unavailable`
with `Detail`; Persons without scored responses have no integration row and
remain in the ordinary disposition review. `computed` is not an accuracy
classification. The first adaptive order has no previous-order difference.

The shared implementation reuses the R log-probability kernel and the repaired
standard-normal Hermite rule; it adds no dependency. For standardized ability
`z = (theta - mu) / sigma`, nonnegative observation weights and positive GPCM
slopes give the strictly concave log posterior derivatives

```text
score(z)       = sigma * sum(w * a * (y - E[K])) - z
information(z) = 1 + sigma^2 * sum(w * a^2 * Var[K])
```

The mode is found by `stats::uniroot()` with explicit convergence failure.
For mode `m`, local scale `s = 1/sqrt(information(m))`, and standard-normal
Hermite nodes/weights `(t, wq)`, adaptive nodes are `z = m + s*t`. Their log
integration terms are

```text
log(wq) + log_likelihood(mu + sigma*z) + log(phi(z)) - log(phi(t)) + log(s)
```

The density ratio and Jacobian preserve the original prior and integral.
Observation weights retain their likelihood-power interpretation; fractional
weights do not make the resulting contribution a normalized response-pattern
probability. GPCM slopes multiply the complete predictor, including steps.

Only numerical comparisons are added. Estimates, intervals, posterior draws,
readiness, fitted parameters and frozen artifact identities remain unchanged.
The sensitivity helper still performs its separate fixed-grid refits. Its
adaptive comparison holds each refit's parameters fixed, so it separates
integration changes from parameter movement. User-supplied latent regression
remains outside that sensitivity helper's existing scope; fitted-object
prediction can review its conditional normal scoring prior.

## Numerical design and independent reference

The [runnable audit](adaptive-quadrature-review-0.2.4.R) uses 84 deliberately
chosen fixed-parameter conditions, with fixed Q301 and adaptive Q15/Q31/Q61:

| Family | Conditions | Question addressed |
| --- | ---: | --- |
| Repeated four-category RSM | 36: length 4/100/1000 × difficulty −16/0/8/16 × balanced/all-high/all-low | Does the review detect central concentration and far-tail shifts from long or extreme patterns? |
| Heterogeneous RSM/PCM/GPCM | 48: model × length 12/240 × balanced/all-high × narrow/wide prior × unit/fractional weights | Are owner-specific steps, slopes, predictor offsets, prior transformations and likelihood weights handled consistently? |

The heterogeneous cases use nonzero predictor offsets and steps, GPCM slopes
0.5/1/2, priors N(−1.5, 0.4²) and N(2, 2.5²), and weights cycling through
0.25/0/1.75/3. Zero weights are an internal mathematical probe; these cases do
not change the public scoring API's strictly positive weight requirement.
These are numerical probes, not samples from a data-generating process and
not estimates of error rates in applied datasets.

The reference independently expresses the category logits without the package
probability kernel or Hermite rule. It finds a mode with `stats::optimize()`,
then uses `stats::integrate()` on each side of the peak in local posterior
coordinates. This avoids giving an ordinary integrator an interval that is
almost everywhere zero relative to a narrow peak, a limitation explicitly
described in the [R integrate documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/integrate.html).
Integration is repeated on local ranges ±32 and ±64; strict log concavity gives
tangent-exponential bounds on the omitted marginal mass. The audit requires
range agreement below 1e-8 for log marginal/EAP/SD, reported relative mass
integration error below 1e-9, and omitted relative mass bound below 1e-12.
These checks qualify this reference calculation; they are not public scoring
acceptance thresholds or formal bounds on every posterior moment's error.

## Results

On macOS, all 252 numerical rows were computed. The two reference ranges gave
identical retained log-marginal/EAP/SD values at double precision; the largest
reported relative mass integration error was 8.45e-12 and the largest log
relative tail bound was −106.52. Adaptive Q61 maximum absolute errors were:

| Conditions | Log marginal | EAP | Posterior SD |
| --- | ---: | ---: | ---: |
| Repeated RSM | 1.10e-11 | 3.77e-11 | 5.51e-11 |
| Heterogeneous RSM | 1.14e-9 | 3.53e-9 | 3.64e-9 |
| Heterogeneous PCM | 6.95e-10 | 2.41e-9 | 2.45e-9 |
| Heterogeneous GPCM | 2.06e-13 | 6.16e-13 | 1.75e-12 |

Q31 was less accurate in some heterogeneous cases: maximum EAP error 3.09e-6
and SD error 2.55e-6. Q15 errors reached 3.57e-4 and 4.45e-4 respectively.
This supports retaining changes between adaptive orders instead of treating
one completed adaptive calculation as certified accuracy.

The motivating central RSM case has 1000 responses balanced over categories
0–3, zero difficulty/steps, and N(0,1) prior:

| Quantity | Fixed Q301 | Adaptive Q61 | Continuous reference |
| --- | ---: | ---: | ---: |
| Log marginal | −1388.92295546 | −1389.86004067 | −1389.86004067 |
| EAP | approximately 0 | approximately 0 | approximately 0 |
| Posterior SD | 0.0000095978 | 0.0282825628 | 0.0282825628 |

The EAP's symmetry hides substantial SD and likelihood errors. Across all
84 conditions, fixed Q301 errors reached 1.175 in log marginal, 0.148 in EAP,
and 0.098 in posterior SD. Positive representable weights and a large fixed
order therefore do not by themselves establish adequate integration.

Linux R 4.3.2 also computed all 252 rows, with the same substantive results.
Across platforms, adaptive log marginal/EAP/SD differed by at most 1.01e-11,
1.21e-12 and 1.40e-13 respectively. The same condition and order appear in
each platform's full observation table:
[macOS](adaptive-quadrature-review-0.2.4-macos.csv) and
[Linux](adaptive-quadrature-review-0.2.4-linux.csv).

## Regression coverage and limits

The tests exercise the narrow/tail references, invalid/nonrepresentable
orders, retention of an unavailable Person, transformed priors, and zero
internal weights. Public-route checks cover RSM/PCM fitted/artifact scoring,
GPCM sensitivity/prediction, nonunit weights, reordered identifiers, omitted
Persons, and latent-regression scoring. They check that estimates, draws,
readiness and artifacts are preserved. Numerical tables are aligned by Person
and order; tiny fixed-grid accumulation differences after artifact node sorting
are checked by absolute error, not relative error against near-zero deltas.
The saved-artifact route is also exercised in a fresh R process using only
public functions.

| Environment | Targeted files | Test blocks | Passing assertions | Failures / errors / warnings / skips |
| --- | ---: | ---: | ---: | --- |
| macOS, R 4.6.1 | 9 | 79 | 780 | 0 / 0 / 0 / 0 |
| Linux, R 4.3.2 | 9 | 79 | 780 | 0 / 0 / 0 / 0 |

The [test ledger](adaptive-quadrature-review-0.2.4-tests.csv) retains the final
test result for each block. macOS used source loading except that the public
calibration file ran against the installed package, including its fresh-process
test. Linux used the installed package throughout. The macOS development run's
initial fresh-process skip was resolved by that installed-package run; initial
test-only failures from unaligned Person ordering and relative comparisons of
near-zero differences were corrected before retaining the final results.
Linux used the existing `mfrmr-prerelease-qa:20260913` image, Ubuntu 22.04.4
arm64 with OpenBLAS/LAPACK. No new dependency or network service was added.

macOS `R CMD build` and `R CMD check --no-manual` pass with 0 errors, 0 warnings,
and 0 notes, including rebuilt vignettes and the new lightweight regression
test. The checked archive is
`/tmp/mfrmr-adaptive-review/final/mfrmr_0.2.4.9000.tar.gz`, SHA256
`15f7c6d5003ba20381c385ae45ad40783b3bcac4a02724cf9a7e151f52917cfb`.
All 482 existing source R, packaged test, and Rd files in it were compared
byte-for-byte with the working tree.
The lightweight package check has 543 passing assertions and three declared
CRAN-only skips. [Source hashes](adaptive-quadrature-review-0.2.4-source.csv)
identify the implementation, tests, help, vignette and numerical audit script.

This turn does not introduce adaptive optimization, gradient/Hessian support
for moving nodes, adaptive intervals/draws, or a universal adequacy threshold.
Fixed-parameter agreement cannot establish estimator recovery, interval
coverage, calibration transport, anchor/link validity, G-theory validity, or
TAM/ConQuest equivalence. The broad external stress grids and full Windows/CI
suite were not rerun or reclassified. In particular, a future adaptive fitter
must account for parameter-dependent modes/scales rather than reuse the
fixed-grid gradient unchanged.

## Reproduction

From the development root with package dependencies installed:

```r
pkgload::load_all()
source("inst/validation/adaptive-quadrature-review-0.2.4.R")
run_adaptive_quadrature_audit(tempfile("adaptive-review-"))
testthat::test_local(filter = "^(adaptive-quadrature-review|prediction|gpcm-mml-quadrature-sensitivity)$")
```

The portable-calibration vignette demonstrates the optional review on an
actual newly scored batch. Archive its full `quadrature_review` alongside the
score batch when reporting numerical checks; the compact overview alone does
not preserve individual adaptive-order changes or failure reasons.
