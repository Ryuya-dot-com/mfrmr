# GPCM latent-distribution stress contract for mfrmr 0.2.3

Status: repository-only 12-replicate calibration pilot. No estimator
selection, Bayesian comparator, confirmation design, capability promotion, or
release threshold is authorized.

## Essential question

The preceding estimator-asymptotics pilot found lower numerical structural
recovery error for normal-population MML than for JML, especially when each
Person had only eight observations. That result used the same normal ability
distribution that MML fitted. This stress asks whether that numerical advantage
survives when the fitted normal population is wrong.

It does not ask whether one distribution is substantively realistic, whether a
Bayesian prior is preferable, or whether the current readiness gate should be
relaxed.

## Coupled generating distributions

Three deterministic support distributions have mean zero and population
variance one:

| Distribution | Role |
|---|---|
| `normal` | correctly specified reference |
| `skewed_gamma2` | centered and standardized gamma-shape-2 stress |
| `symmetric_mixture` | centered and standardized two-normal mixture stress |

All support vectors have the same length and are quantile ordered. Within each
replicate they use the same sampling seed. Consequently, Person ranks are
quantile-coupled, while the generated Rater, Criterion, step, slope, and design
truth must be exactly identical across distributions. Failure of any coupling
assertion stops execution.

MML always fits its current intercept-only normal population. JML continues to
treat Persons as fixed effects. For nonnormal generators, fitted MML population
mean and variance are compared with the generating moments only; they are not
labelled correctly specified model-parameter recovery.

## Design

The pilot fixes:

- 120 Persons, six Raters, four Criteria, and four categories;
- Criterion-owned steps and geometric-mean-one Criterion slopes with centered
  log slopes from -0.30 to 0.30;
- two observations-per-Person regimes: two Raters x four Criteria = 8, and six
  Raters x four Criteria = 24;
- JML and direct normal-population MML;
- `quad_points=31`, `maxit=300`; and
- 12 prespecified seeds beginning at 883001.

The eight-observation cell is a response-row subset of the corresponding
24-observation cell within each distribution and replicate.

## Comparisons

The runner retains three distinct paired comparisons:

1. stress distribution minus normal within estimator and exposure;
2. JML minus MML within distribution and exposure; and
3. 24-observation minus 8-observation recovery within distribution and
   estimator.

Component RMSE is formed within replicate before Monte Carlo means, standard
errors, and t intervals are calculated. Coordinate-specific signed error is
retained separately. Signed errors are never pooled across sum-zero facet,
step, or log-slope coordinates.

Optimizer log-slope values remain a separately labelled numerical trace. They
cannot authorize primary slope inference while the current GPCM boundary route
is incomplete.

## Failure and identity rules

- Every attempted fit remains in the status denominator.
- Warnings and errors are retained explicitly.
- A failed design, support-moment, or truth-coupling assertion stops execution.
- The runner preserves the caller's RNG state.
- No SHA, MD5, file bytes, serialized-object identity, package path, operating
  system identity, or machine identity enters a scientific assertion.

## Non-decision rule

This calibration pilot has no prespecified estimator-selection or Bayesian
activation threshold. Its completed state remains:

```text
DistributionRobustnessDecision = pilot_completed_no_prespecified_decision_rule
EstimatorSelectionAuthorized = FALSE
BayesianComparatorAuthorized = FALSE
ConfirmationAuthorized = FALSE
CapabilityPromotionAuthorized = FALSE
```

A Bayesian comparison, if later justified, must be a separate prior/model
stratum with explicit prior predictive and sensitivity checks. It must not be
introduced merely because a misspecified normal MML fit has a larger error in
one inspected condition.
