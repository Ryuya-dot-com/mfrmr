# Draft.83d2b2a G-theory weak-information calibration contract

Status: repository-only registry and observable-diagnostic smoke, 2026-08-09.

Draft.83d2b2a responds to the Draft.83d2b1 near-boundary concern by defining an
independent calibration problem. It does not select a threshold. It registers
zero, near-zero, small-positive, moderate-positive, and ordinary-positive Rater
variance controls across five information/design settings and evaluates four
likelihood routes.

The generating truth is available only to simulation scoring. Every candidate
application diagnostic is computable from the observed design and returned
fit without reading `TargetVariance`, `TruthRegion`, or `EvaluationRole`.

## Why the point-fit gate is insufficient

The Draft.83d2b1 point gate asks whether the whole fitted model returned,
converged, produced finite components, remained away from an absolute numerical
boundary, and had acceptable backend-local curvature. It was never calibrated
as a component-specific evidence rule.

Two errors are therefore possible:

- a target Rater component generated at zero can be estimated positively while
  every whole-model numerical diagnostic passes; and
- a genuinely positive target component can be declared failed because a
  different nuisance component reaches a boundary or the whole-model curvature
  diagnostic fails.

Draft.83d2b2a records both errors separately. It does not redefine
`EstimationGatePassed` post hoc.

## Frozen calibration registry

The registry crosses five design strata with six target-variance regions:

| Design | Persons | Raters | Criteria | Observations/Person | Assignment |
| --- | ---: | ---: | ---: | ---: | --- |
| baseline complete | 100 | 4 | 4 | 16 | complete, balanced |
| few levels complete | 100 | 2 | 2 | 4 | complete, balanced |
| high information | 300 | 8 | 4 | 32 | complete, balanced |
| sparse connected | 100 | 8 | 4 | 16 | connected cycle |
| imbalanced hub | 100 | 8 | 4 | 8 | connected hub, high imbalance |

| Region | Rater variance | Calibration role |
| --- | ---: | --- |
| exact boundary | 0 | negative control: not resolved |
| numerical near boundary | `1e-10` | negative control: not resolved |
| small positive | 0.0025 | transition; no required binary result |
| small positive | 0.01 | transition; no required binary result |
| moderate positive | 0.04 | transition except high-information positive control |
| ordinary positive | 0.12 | positive control in baseline and high-information designs |

This yields 30 scenario cells and 120 one-replicate method units across lme4
ML/REML and glmmTMB ML/REML. The smoke replication count is one only for schema,
replay, and diagnostic availability. `PilotReplications`,
`ConfirmationReplications`, the precision plan, and all thresholds remain
missing or `not_frozen`.

The positive-control subset is deliberately narrow. A true positive variance
with only two Rater levels is not automatically expected to be empirically
resolved, and is not counted as a false block by assertion.

## Observable candidate diagnostics

The implemented smoke records:

1. target component variance estimate;
2. target estimate as a fraction of the total fitted variance;
3. target-to-residual variance ratio;
4. retained target grouping-level count;
5. retained observations per target level;
6. the existing whole-model point-gate result;
7. whole-model boundary/singularity state;
8. minimum backend-local curvature eigenvalue/state;
9. matched-backend relative estimate difference within ML or REML; and
10. within-backend ML/REML relative estimate difference.

A full-versus-reduced component likelihood drop is registered but not yet
implemented. Its boundary null law is nonstandard and must not use an ordinary
one-degree chi-square cutoff without a separate contract. Full-refit component
intervals remain deferred to Draft.84.

All implemented values are candidate diagnostics, not a conjunctive rule. In
particular, grouping levels and observations per level are design descriptors,
not universal sample-size cutoffs.

## Denominators and labels

The smoke reports:

- fit-return and atomic accounting over all selected units;
- existing whole-model gate passes;
- false ready over `negative_control_not_resolved` units; and
- false block over the narrowly registered `positive_control_resolved` units.

Transition cells do not enter either error denominator. They are used to study
the shape and overlap of candidate diagnostics before pilot thresholds are
chosen.

Method strata may be executed independently to meet runtime limits, but they
must share one registry identity, contain all 30 scenarios, partition the four
methods exactly, and be recombined in manifest order. Partial execution is not
a completed smoke.

## Frozen one-replicate concern result

All 120 fits return and atomic accounting passes. The existing whole-model
point gate passes 82 units. Among the 40 registered negative-control routes it
produces 27 false-ready results:

| Truth region | False ready / routes |
| --- | ---: |
| exact zero | 15 / 20 |
| numerical near zero | 12 / 20 |

Among 12 positive-control routes it produces three false blocks, all in the
high-information variance-0.04 cell. This reinforces that the whole-model gate
is neither target-component detection nor calibrated evidence.

These one-replicate counts are not operating-characteristic estimates and
cannot define a threshold, minimum number of Raters, or sample-size
recommendation.

## Pilot and confirmation boundary

The next feasibility pilot must:

- add independent replications and target Monte Carlo precision for both error
  rates;
- preserve paired seeds across methods;
- distinguish target-component weakness from nuisance-component failure;
- assess calibration by design stratum rather than pool Persons, Raters,
  exposure, topology, and imbalance;
- compare prespecified candidate rules on the pilot only; and
- freeze one rule, indeterminate zone, and failure behavior before untouched
  confirmation seeds are generated.

Missingness, bounded scores, and local dependence are later transport strata,
not mixed into the first Gaussian weak-information calibration. A rule that
works only by reading simulation truth is invalid. A rule tuned after looking
at confirmation results invalidates confirmation.

`ThresholdFrozen`, `CalibrationEvidenceReady`, `ConfirmationAuthorized`,
`RecoveryEvidenceReady`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` remain false.
