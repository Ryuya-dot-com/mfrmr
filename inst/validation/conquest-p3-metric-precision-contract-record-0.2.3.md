# ConQuest P3 metric and precision contract record for mfrmr 0.2.3

Status: P3 item-only metric classes, raw-token interval policy, integration
states, complete denominators, and stop/invalidation rules frozen for
independent offline review; no execution authorized, 2026-08-15.

- Specification: `0.2.3-conquest-p3-metric-precision-contract-v1`
- Contract: `mfrmr_conquest_p3_metric_precision_contract_v1`
- Review status:
  `P3_fixtures_metrics_precision_and_denominator_ready_for_independent_offline_review`

This is a prospective repository-only contract. It was written without
launching ConQuest, fitting either engine, or opening successor candidate
output. It does not change the P3 fixture execution identity and does not
authorize a comparison, support claim, or scientific-equivalence statement.

## Why P3 has a separate numerical contract

The earlier P2/Candidate-003 budgets are not transferred merely because both
portfolios use ConQuest. P3 changes the estimand, identification map, free
slope coordinates, and integration sensitivity. In the pre-output fixture
oracle, the largest q61-to-q121 log-likelihood movement is about `3.31e-6`, or
`6.62e-6` on the positive-deviance scale. Reusing P2's `2e-6` deviance budget
would therefore label known finite-integration movement as a cross-engine
failure.

P3 instead freezes eleven explicit budgets. None is informed by successor
candidate output or by a transferred opened calibration:

| Metric family | Units | Absolute budget | Basis |
| --- | --- | ---: | --- |
| mapped A/C/regression coordinate | common mapped coordinate | 1e-5 | 1e-8 optimizer-control scale with a prospective 1000-fold separation |
| population location | latent-trait coordinate | 1e-5 | same prospective engineering separation |
| population scale | log standard deviation | 1e-5 | scale-invariant comparison |
| population regression | latent trait per X unit | 1e-5 | recovered common coordinate |
| Item location | latent-trait coordinate | 1e-5 | all four sum-zero values retained |
| relative slope | centered log slope | 1e-5 | all four values retained, including the constrained value |
| Item transition | latent-trait transition | 1e-5 | all twelve values retained |
| cross-engine q121 deviance | positive deviance | 1e-5 | evaluated only after integration eligibility |
| q61-to-q121 coordinate movement | common mapped coordinate | 1e-5 | final finite-ladder gate |
| q61-to-q121 deviance movement | positive deviance | 1e-5 | pre-output `6.62e-6` envelope rounded outward |
| q121-to-continuous deviance | positive deviance | 1e-7 | pre-output maximum about `1.43e-9`, rounded outward |

These are failure-classification budgets, not claims that smaller numerical
differences are substantively negligible. Every coordinate must pass; a mean,
correlation, or favorable aggregate cannot hide a failed atomic outcome.

## Conditional-probability consequence

The probability grids use standard latent coordinates `-3;-1;0;1;3`, all four
Items, and all four categories: 80 cells per arm. The independent A/C matrices
give maximum within-Item pairwise coefficient L1 spans of 9 for PCM and 12 for
GPCM. Transporting the `1e-5` mapped-coordinate budget through the softmax
likelihood-ratio bound gives:

| Family | Maximum log-kernel span | Absolute probability bound |
| --- | ---: | ---: |
| PCM | 9e-5 | 9.000405e-5 |
| GPCM | 1.2e-4 | 1.200072e-4 |

The probability bound is a conservative consequence check and cannot override
a failed coordinate, semantic, precision, or integration gate.

## Raw-token interval policy

Every required native decimal token is retained as text. A syntactically valid
token defines its printed value plus or minus half a unit in its last reported
place. Two tokens receive one of three numerical classifications:

1. `eligible` only when the largest possible interval difference is within the
   frozen metric budget;
2. `numerical_disagreement` only when the smallest possible interval difference
   exceeds the budget; or
3. `reported_resolution_limited` when the intervals straddle the boundary.

Missing, unparsable, nonfinite, and display-reconstructed values have separate
typed states. Hidden digits are never filled in. A displayed value that looks
close cannot substitute for an absent raw export token.

## Integration precedence

The complete q ladder remains `31;61;121`, but its roles are not symmetric:

- q31-to-q61 coordinate and deviance movements must be finite and recorded;
  their magnitude is diagnostic and has no pass threshold;
- q61-to-q121 coordinate and deviance movements must pass their `1e-5` final
  integration budgets; and
- q121 deviance must be within `1e-7` of an independently reconstructed
  continuous target for each engine.

Failure at either final layer is `integration_unresolved`. It is not relabeled
as optimizer or cross-engine disagreement. The only permitted expansion is the
already prespecified ladder/continuous diagnostic on the same arm; it cannot
open a wider design.

The gate precedence is model identity, optimizer/readiness, raw-token validity,
integration eligibility, then cross-engine numerical metrics. Thus a later
small difference cannot repair an earlier failure.

## Metric and atomic denominators

The metric registry contains 23 rule types. They keep mapped kernel
coordinates, population location, log population scale, regression, Item
location, centered log slope, unit-slope state, transitions, matched-constant
deviance, probability, q movement, continuous-target movement, raw precision,
semantic identity, decision consequence, and non-overlap disposition separate.

| Scope | Metric rows | Atomic outcomes |
| --- | ---: | ---: |
| PCM unit-slope intercept arm | 19 | 260 |
| GPCM non-unit intercept arm | 19 | 293 |
| GPCM non-unit covariate arm | 20 | 305 |
| Three documented non-overlap/unsupported rows | 3 | 3 |

| Denominator | Count |
| --- | ---: |
| Metric-level denominator | 61 |
| Full P3 atomic denominator | 861 |

Raw-token completeness alone contributes 84, 102, and 108 outcomes across the
three numerical arms: two engines, three q snapshots, and every free coordinate
plus deviance. Failed, missing, resolution-limited, integration-limited, and
ineligible outcomes remain in the denominator.

The many-facet slope-owner, unsupported JML `scoresfree`, and multidimensional
rows receive exactly one documented non-overlap disposition each. They receive
no numerical metric. TAM may later supply optional pairwise evidence, but every
rule explicitly forbids a two-against-one vote and forbids using a third engine
to override an oracle or semantic failure.

## Stop and invalidation rules

All fourteen P3 outcomes declared by the successor registry have one stop rule.
Only `eligible` can enter numerical metrics. Runtime, semantic, identification,
nonconvergence, mfrmr readiness, boundary, precision, integration, numerical,
implementation, unknown, and documented-nonoverlap states remain typed and
retained. An implementation defect invalidates the entire execution slice;
other failures have the smallest declared affected scope. Wider-design
expansion is false for every outcome.

The contract review has the following state:

| Gate | Value |
| --- | --- |
| `MetricSpecificRulesFrozen` | `TRUE` |
| `RawTokenRulesFrozen` | `TRUE` |
| `IntegrationRulesFrozen` | `TRUE` |
| `CompleteDenominatorFrozen` | `TRUE` |
| `StopAndInvalidationRulesFrozen` | `TRUE` |
| `IndependentReviewPassed` | `FALSE` |
| `ExternalExecutionAuthorized` | `FALSE` |
| `ComparisonPassed` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |

## Remaining gates

This contract closes P3 construction only. An independent offline review must
still inspect the fixture identities, A/C orientation, constraint maps, budget
bases, token parser boundary cases, denominator arithmetic, outcome precedence,
and non-overlap ceilings. P0 and P1 reviews also remain open. Even after those
reviews, P3 external execution remains blocked until the smallest frozen P2
external slice has been classified without an unresolved infrastructure
defect.

No hash or byte-for-byte identity is a scientific acceptance criterion. No
public README or NEWS claim follows from this internal contract.
