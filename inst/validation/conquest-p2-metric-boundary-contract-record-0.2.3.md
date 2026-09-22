# ConQuest P2 metric and boundary contract record for mfrmr 0.2.3

Status: boundary quantities, metric-specific rules, complete denominators, and
stop/expansion rules frozen for independent offline review, 2026-08-15.

- Specification: `0.2.3-conquest-p2-metric-boundary-contract-v1`
- Contract: `mfrmr_conquest_p2_metric_boundary_contract_v1`
- Machine status:
  `P2_fixtures_metrics_boundaries_ready_for_independent_offline_review`

This contract was completed without launching ConQuest, fitting mfrmr, or
opening successor output. It authorizes no execution, numerical pass,
readiness promotion, scientific equivalence, or wider design expansion.

## What is frozen

The contract has four distinct layers:

| Layer | Rows | Purpose |
| --- | ---: | --- |
| Boundary/quantity states | 11 | Keep raw-score, native finite/unbounded, adjusted-display, posterior, missing, and inapplicable quantities distinct |
| Metric rules | 18 | Fix orientation, unit, signed/absolute budget, prerequisites, required outcome, and failure type |
| Metric-level denominator | 147 | Retain every P2 fixture-by-metric result, including typed ineligibility and failure |
| Stop/expansion outcomes | 15 | Fix the permitted diagnostic response to every allowed successor outcome and both control outcomes |

These are semantic field contracts, not file-byte or digest acceptance rules.
A future implementation may change irrelevant serialization without changing
the contract, but any altered estimand, prerequisite, budget, denominator,
outcome, or claim ceiling requires a new reviewed contract version.

## Boundary and quantity typing

The extreme-Person inventory distinguishes three observed-score states
(`nonextreme`, `minimum`, and `maximum`) and eight quantitative states:

- a finite native estimate;
- native estimates unbounded low, high, or in both directions;
- a finite adjusted display value;
- a finite posterior summary;
- not estimated or missing; and
- not applicable.

Only a finite native estimate can enter the parameter-coordinate metric, and
only when estimand, coordinate transformation, and raw precision match. An
unbounded native estimate is compared as a direction/state, never by replacing
infinity with a large finite value. An adjusted display value can be compared
only as a labelled display policy and cannot substitute for the native
estimate. No state can promote mfrmr readiness.

The extreme fixture requires 432 typed records: 48 engine-independent raw-score
states plus `48 Persons x 2 engines x 4 layers` for native estimate, adjusted
display, posterior EAP, and posterior SD. No Person disappears because an
engine uses a different boundary convention.

## Numeric budgets

The coordinate and deviance budgets are reused only for the unchanged RSM/PCM
exact-reported-decimal estimands and q31/q61 ladder:

| Metric | Orientation | Signed interval | Absolute budget |
| --- | --- | ---: | ---: |
| Common coordinate, cross-engine | ConQuest minus mfrmr | `[-1e-5, 1e-5]` | `1e-5` |
| Matched-constant deviance, cross-engine | ConQuest minus mfrmr | `[-2e-6, 2e-6]` | `2e-6` |
| Common coordinate, within engine | q61 minus q31 | `[-2e-6, 2e-6]` | `2e-6` |
| Matched-constant deviance, within engine | q61 minus q31 | `[-2e-6, 2e-6]` | `2e-6` |

Reuse does not extend to a changed estimator, hidden optimizer solution,
different precision stratum, different integration ladder, or unmatched
deviance constant. All numeric rows require retained raw tokens and reported
resolution. The two deviance metrics remain ineligible until the constant
basis is independently established for the exact row.

### Conditional probabilities

Conditional probabilities are evaluated at the five fixed theta anchors
`-2.25, -0.50, 0, 0.75, 2.40`, all 4 Raters, all 3 Criteria, and all 4
categories: 240 cells per fixture. They are not Person posterior predictions.

For both RSM and PCM, the maximum pairwise L1 difference between category rows
of the independently reconstructed A matrix is 15. Given the `1e-5` free-
coordinate budget, the maximum log-kernel difference span is `1.5e-4`. The
conservative likelihood-ratio bound therefore freezes
`expm1(1.5e-4) = 0.0001500113` as the absolute probability budget. This rule is
derived prospectively from the model map; it is not fitted to external output.
All 240 cells, their keys, and normalization checks must be present. A maximum
computed after dropping cells is not eligible.

### EAP and posterior SD

The 48 EAP and 48 posterior-SD entries remain in the complete denominator for
every numerical fixture, but their current state is
`typed_ineligible_pending_posterior_identity`. No numeric budget is invented.
They become numerically eligible only after a pre-output contract proves the
same prior/population distribution, retained response set, weights,
quadrature or common continuous reconstruction, and summary definition, and
then freezes a separate independently justified budget. Parameter closeness
cannot substitute for that proof.

### Ordering, readiness, and decisions

Rater ordering contains all six pairs and Criterion ordering all three pairs.
The `2e-5` tie band is twice the cross-engine coordinate budget: it is a
numerical ordering-stability classification, not a substantive-equivalence
threshold. Both engines must give the same ordered/tied classification for
every pair.

Readiness and decision consequences are categorical exact comparisons.
External agreement cannot turn an mfrmr `review`, exclusion, or blocked state
into ready. Every retained package/reporting decision must match its
prospectively registered decision identity.

## Complete denominator

Each of the eleven numerical P2 fixtures has thirteen core metric rows. Their
atomic denominator is:

| Atomic result class | Count |
| --- | ---: |
| Cross-engine common coordinates | 167 |
| Within-engine common coordinates | 334 |
| Cross/within-engine deviances | 33 |
| Conditional-probability cells | 2,640 |
| EAP entries | 528 |
| Posterior-SD entries | 528 |
| Rater/Criterion pair classifications | 99 |
| Readiness and decision states | 22 |
| Core subtotal | 4,351 |
| Paired missingness rows | 288 |
| Extreme quantity records | 432 |
| Two negative-control outcomes | 2 |
| Full P2 atomic denominator | 5,073 |

The planned-absence and explicit-missing pair must reproduce the same 288
retained semantic rows and continuous target exactly. The unused intermediate
category and disconnected-design controls must both reject before numerical
comparison. Failed, ineligible, missing, boundary-mismatched, and
resolution-limited results remain in the denominator.

## Stop, diagnostic, and expansion policy

The stop registry covers all thirteen allowed numeric-row states from the
successor registry plus `expected_typed_rejection` and
`unexpected_control_acceptance`. Only `eligible` can enter numeric metrics.
Even an eligible row cannot widen the design before independent review.

- runtime failure permits only the smallest runtime sentinel;
- semantic execution failure permits only same-arm diagnosis;
- model-identity or structural failure permits no numeric comparison;
- nonconvergence and mfrmr review remain observed outcomes, not deleted rows;
- reported-resolution limits cannot be filled with inferred hidden digits;
- integration uncertainty can use only the prespecified q ladder;
- numerical disagreement permits same-fixture diagnosis only;
- an implementation defect stops the affected execution slice;
- `unknown` must be classified before rerun or metric evaluation; and
- unexpected negative-control acceptance invalidates the entire execution
  slice.

No wider design expansion is currently authorized.

## Current gate state

The machine review reports all four contract layers ready while retaining:

| Gate | Value |
| --- | --- |
| `BoundaryQuantitiesTyped` | `TRUE` |
| `MetricSpecificRulesFrozen` | `TRUE` |
| `CompleteDenominatorFrozen` | `TRUE` |
| `StopAndExpansionRulesFrozen` | `TRUE` |
| `IndependentReviewPassed` | `FALSE` |
| `ExternalExecutionAuthorized` | `FALSE` |
| `ComparisonPassed` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |

The separate minimum-diagnostic authorization contract now freezes a narrower
pre-execution fatal-gate audit and the exact paired RSM/PCM slice. A fresh
runtime sentinel and completed maintainer attestation must still be bound in a
later explicit authorization record before that slice can run. Independent
P0/P1/P2 review remains mandatory before interpreting the result, widening the
design, or promoting evidence.
