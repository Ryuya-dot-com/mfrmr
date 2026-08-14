# Public GPCM-MML quadrature-sensitivity diagnostic

Status: public explicit diagnostic implemented; no stability threshold,
standard-error eligibility, readiness, or release promotion

Review date: 2026-08-14

## Question

Can a user distinguish optimizer convergence from finite-quadrature stability
without manually rebuilding the GPCM-MML fit contract? The diagnostic must
answer how much the fitted result moves when q changes, not declare that a
particular q is universally sufficient.

## Public contract

`gpcm_mml_quadrature_sensitivity()`:

- accepts a bounded GPCM-MML fit and the original response data explicitly;
- requires the reference fit's q and at least one alternative q;
- reuses the stored model, identification, anchor, optimizer, and population
  settings for the alternative fit;
- compares canonical prepared response rows semantically and independently of
  row order;
- evaluates every observed additive non-Person facet cell on one common theta
  grid, preserving the complete-predictor GPCM slope action;
- reports NLL change per Person, relative-slope and raw slope-SE change,
  population-SD and raw SD-SE change, gradient, Hessian curvature, fitted
  probability change, and the unchanged readiness record;
- retains refit warnings and messages without catching errors; and
- supports `summary()`, `print()`, `as.data.frame()`, and `apa_table()`.

It runs only when explicitly called. `summary(fit)` and `diagnose_mfrm(fit)` do
not initiate hidden refits.

The first version is deliberately limited to the additive GPCM and the default
intercept-only free-population identification or the fixed-standard-normal
alternative. Facet-interaction and user-supplied latent-regression models fail
closed rather than receiving an incomplete probability comparison.

No file bytes, serialization identity, SHA, MD5, or package-library path enters
the same-data contract.

## Fixed q=31/q=41 execution

The public function was run on the first 12 Persons of `example_core`, using
Criterion as both the step and slope owner, `maxit = 150`, q=31 as the
reference, q=41 as the denser grid, and 81 common theta points.

| Quantity | Absolute q41-q31 change |
| --- | ---: |
| NLL per Person | 0.00057 |
| Maximum relative slope | 0.00531 |
| Maximum raw observed-information slope SE | 0.00425 |
| Population SD | 0.00292 |
| Raw population-SD SE | 0.00023 |
| Maximum fitted category probability | 0.00185 |

Both fits recorded optimizer convergence and full-rank positive-definite local
Hessians. The summary nevertheless retained
`StabilityClassification = "not_assigned_continuous_evidence_only"` and
`ReadinessEffect = "none_diagnostic_only"`.

## Coarse-grid stress contrast

The package test uses the same 12-Person subset at q=5/q=7. Both fits again
converged and had full-rank positive-definite Hessians, but the changes were
substantively larger in the numerical sense:

| Quantity | Absolute q7-q5 change |
| --- | ---: |
| NLL per Person | 0.23579 |
| Maximum relative slope | 0.15295 |
| Maximum raw observed-information slope SE | 0.05736 |
| Population SD | 0.42725 |
| Raw population-SD SE | 0.03324 |
| Maximum fitted category probability | 0.06489 |

This contrast is a software and interpretation fixture, not a calibration of
an acceptable difference. It shows why optimizer convergence and local
positive curvature cannot substitute for quadrature review.

## Readiness boundary

At both practical grids the public fits remained `FitReadiness = "review"` and
`InferenceReady = FALSE`. The retained reasons concern design-rank and global
boundary evidence, including `mml_gpcm_slope_boundary_not_evaluated`.

Consequently:

1. Small q=31/q=41 movement is supportive local numerical evidence for this
   dataset only.
2. It is not proof that q=31 is sufficient for another sample, design, or
   response pattern.
3. Large coarse-grid movement can occur even when convergence codes and local
   Hessians look satisfactory.
4. Raw observed-information SE comparisons remain diagnostic traces while
   public `SEEligible` values are false.
5. Global boundary readiness and quadrature stability remain separate
   scientific questions.

StabilityThresholdFrozen = FALSE

PublicSEEligibilityOverridden = FALSE

ReadinessOverridden = FALSE

AutomaticRefitFromSummary = FALSE

ReleaseAuthorized = FALSE
