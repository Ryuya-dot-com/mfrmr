# GPCM JML/MML estimator-asymptotics contract for mfrmr 0.2.3

Status: repository-only diagnostic contract; no estimator selection, bias
correction, Bayesian implementation decision, numerical threshold, or release
promotion.

## Essential question

Numerical convergence does not answer whether GPCM structural estimates are
stable as information grows. This diagnostic separates two sequences:

1. increase the number of Persons while holding each Person's exposure fixed;
2. increase observations per Person while holding the number of Persons fixed.

The first sequence targets the Neyman--Scott-type concern. Under JML, adding
Persons also adds one fixed ability coordinate per Person, so fixed-exposure
structural bias need not disappear. The second sequence asks whether increasing
within-Person information reduces ordinary small-information and incidental-
parameter effects. MML integrates Person ability and is therefore expected to
behave differently, conditional on its normal population model.

## Matched design

Each replicate first generates one maximum design under the current aligned
single-owner GPCM:

- six Raters, four Criteria, and four ordered categories;
- Criterion owns both its step vector and relative slope;
- the log slopes are centered and range from -0.30 to 0.30;
- every maximum-design Person is observed by all six Raters on all four
  Criteria.

Five unique cells are then cut from that same response table. The smoke uses:

| Cell | Persons | Raters per Person | Observations per Person |
|---|---:|---:|---:|
| N024-L08 | 24 | 2 | 8 |
| N048-L08 | 48 | 2 | 8 |
| N096-L08 | 96 | 2 | 8 |
| N048-L16 | 48 | 4 | 16 |
| N048-L24 | 48 | 6 | 24 |

The pilot changes the Person counts to 60, 120, and 240 but keeps the same
8/16/24 exposure levels. Rotating Rater subsets preserve a connected Rater
graph. The middle, eight-observation cell belongs to both sequences and is fit
only once per estimator.

Because all cells are nested subsets of a single generated maximum table,
structural truth and retained cell responses do not change when a larger cell
contains a smaller one. No file hash, serialized-object digest, package path,
or machine identity is used to assert this relationship.

## Estimator lanes

Every cell is fitted twice:

- GPCM JML: Persons are jointly estimated fixed effects;
- default GPCM MML: Persons are integrated under the fitted intercept-only
  normal population model.

JML and MML Person estimates are not compared. Recovery targets are Rater and
Criterion locations, within-owner step contrasts, and relative log slopes.
Optimizer slope values are stored separately as numerical traces. They cannot
enter inferential recovery when the fitted primary slope is boundary-typed or
comparison-ineligible. For MML, the generating population mean zero and
variance one are retained as distribution-level truth; they are not replaced
by the realized finite-sample mean and variance of the simulated Persons.

## Required outputs

The runner retains:

- exact realized rows and observations per Person;
- Rater-graph connectivity;
- fit return, optimizer convergence, readiness, boundary state, extreme-Person
  count, warnings, errors, and runtime;
- coordinate-level truth, estimate, and aligned recovery error for eligible
  structural rows;
- separate MML population-intercept and population-variance recovery; and
- a separately labelled, inferentially ineligible optimizer-log-slope trace.

All failed fits remain in the status denominator. Warnings are captured into
the result rather than discarded.

## Decision rule

The one-replicate smoke checks plumbing and may provide directional evidence
only. It cannot establish a bias limit or select JML, MML, or Bayesian
estimation.

The guarded pilot contains 20 replicates. Before interpreting it, the analysis
must retain coordinate-specific bias/RMSE trends and Monte Carlo uncertainty;
a pooled signed bias across sum-zero coordinates is prohibited because it can
cancel algebraically. Component summaries therefore expose MAE and RMSE, while
signed error remains only at the coordinate level. Confirmation seeds and
replication counts remain unassigned.

The smoke retains the following fields:

```text
IncidentalBiasDecision = not_assigned_replicated_pilot_required
EstimatorSelectionAuthorized = FALSE
BiasCorrectionAuthorized = FALSE
BayesianEstimatorRequired = NA
ConfirmationAuthorized = FALSE
```

After the guarded pilot has executed, only the factual pilot state advances:

```text
IncidentalBiasDecision = pilot_completed_no_prespecified_decision_rule
EstimatorSelectionAuthorized = FALSE
BiasCorrectionAuthorized = FALSE
BayesianEstimatorRequired = NA
ConfirmationAuthorized = FALSE
```

This state permits descriptive interpretation of the prespecified trends. It
does not create a post-hoc estimator-selection threshold or authorize release.
