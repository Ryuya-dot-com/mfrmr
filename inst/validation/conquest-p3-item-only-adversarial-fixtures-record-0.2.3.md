# ConQuest P3 item-only adversarial fixture record for mfrmr 0.2.3

Status: disjoint deterministic P3 PCM/GPCM fixtures, independently constructed
A/C coefficient maps, unit-slope reduction, and finite/continuous marginal-
likelihood oracles complete; metric freeze and independent review pending,
2026-08-15.

- Specification: `0.2.3-conquest-p3-item-only-adversarial-fixtures-v1`
- Contract: `mfrmr_conquest_p3_item_only_adversarial_fixtures_v1`
- Fixture set: `mfrmr-0.2.3-conquest-p3-item-only-disjoint-001`
- Prospective execution identity:
  `mfrmr-0.2.3-conquest-p3-item-only-execution-001`

This construction was completed without launching ConQuest or fitting mfrmr.
No candidate output exists, and no observed output was used to choose a
fixture, node count, tolerance, or acceptance rule. The previously opened
item-only microcase remains prerequisite structural evidence only; it is not a
confirmation row in this denominator.

## Fixed fixture axis

All three arms use the same 96-Person by 4-Item response array: 384 retained
rows, items `I1`--`I4`, categories `0:3`, and Person identifiers
`P3P001`--`P3P096`. The covariate is balanced at `X=-1/+1`. Responses are the
deterministic function `(PersonIndex + 2 * ItemIndex) %% 4`, so each item has
24 observations in every category. This ensures that a transition cannot be
silently dropped because it is unobserved.

The frozen truth uses population intercept `0.20`, variance `0.81`, and, only
for the covariate arm, slope `0.40`. Item locations are
`(-0.65, -0.15, 0.25, 0.55)` and sum to zero. Each Item owns a distinct
three-transition step vector whose row sum is zero. The PCM arm fixes all item
slopes to one. Both GPCM arms use `(0.50, 0.80, 1.25, 2.00)`, which are
nonconstant, positive, and have geometric mean one.

| Registry row | Family | Population | Expected free dimension |
| --- | --- | --- | ---: |
| `P3-PCM-UNIT-SLOPE-INTERCEPT` | PCM, fixed unit slopes | `~1` | 13 |
| `P3-GPCM-NONUNIT-INTERCEPT` | GPCM, free item slopes | `~1` | 16 |
| `P3-GPCM-NONUNIT-COVARIATE` | GPCM, free item slopes | `~1+X` | 17 |

Each row has a distinct arm identity under the new prospective execution
identity. All candidate-output and execution/comparison flags remain false.

## Independent constraints and A/C maps

The row key is the full 16-cell `Item::category` support. The PCM contract uses
an `A` matrix of size `16 x 11`: three sum-zero Item-location coordinates and
eight Item-specific sum-zero step coordinates. Its one-column `C` matrix is a
fixed unit category score, not a free slope coordinate. Adding the population
intercept and variance gives dimension `11 + 0 + 2 = 13`.

For GPCM, ConQuest's fixed-standard-normal latent coordinate absorbs mfrmr's
free population location and scale. The mapped `A` matrix is `16 x 12`: four
unrestricted mapped Item offsets plus eight mapped Item-step coordinates. The
`C` matrix is `16 x 4`, with one free mapped `Tau` score per Item. The
intercept-only arm has no free mapped regression coefficient, giving
`12 + 4 + 0 = 16`; the `X` arm adds one, giving 17.

These totals were also derived independently in mfrmr coordinates:

- PCM: population 2 + Item locations 3 + Item steps 8 = 13;
- GPCM intercept: population 2 + Item locations 3 + relative log slopes 3 +
  Item steps 8 = 16; and
- GPCM covariate: the same coordinates plus one population slope = 17.

The mapped GPCM parameters reproduce the separately retained overlap map:
`z=(theta-beta0)/sigma`, `Tau=sigma*a`, mapped Item offset
`a*(delta-beta0)`, mapped step `a*step`, and mapped regression
`beta_X/sigma`. A future native ConQuest A/C export must be reconciled to this
orientation and row key. A matching label, dimension, or byte digest is not a
substitute for that semantic reconciliation.

## Probability and reduction oracles

The direct adjacent-category GPCM kernel and the independent matrix kernel were
evaluated for three arms, five ability values, four Items, and four categories:
240 probability cells. The maximum absolute difference was
`2.220446e-16`.

The unit-slope PCM arm was also reduced to the complete-predictor GPCM formula
without changing locations or transitions. All 80 probability differences
were exactly zero. The non-unit arms are separate controls; therefore passing
the PCM reduction cannot mask a missing or incorrectly owned slope.

## Finite and continuous likelihood targets

The finite standard-normal Gauss--Hermite ladder is `31;61;121`. Its nodes and
weights are built independently by a Golub--Welsch eigensystem, and the tests
check total mass, mean zero, and variance one. Direct-probability and mapped-
matrix marginal log likelihoods were identical at every node count.

| Registry row | q31 | q61 | q121 | Continuous target | q121 minus target |
| --- | ---: | ---: | ---: | ---: | ---: |
| PCM unit slope, `~1` | -620.923108160084 | -620.923110193405 | -620.923110193553 | -620.923110193551 | -1.137e-12 |
| GPCM non-unit, `~1` | -626.524762605058 | -626.523941289768 | -626.523944598663 | -626.523944599377 | 7.140e-10 |
| GPCM non-unit, `~1+X` | -633.501474922886 | -633.501657176473 | -633.501660353699 | -633.501660353008 | -6.919e-10 |

The continuous targets use adaptive whole-line integration of the direct
probability oracle, Person by Person. The mapped representation independently
reproduced every continuous total exactly at printed double precision. These
values establish targets and expose integration movement; they do not yet
define a pass tolerance for a future fitted candidate.

The construction review returns
`P3_item_only_fixtures_A_C_and_likelihood_oracles_ready_for_metric_freeze`.
It deliberately preserves the following gates:

| Gate | Value |
| --- | --- |
| `MetricSpecificRulesFrozen` | `FALSE` |
| `IndependentReviewPassed` | `FALSE` |
| `ExternalExecutionAuthorized` | `FALSE` |
| `ComparisonPassed` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |

## Adversarial limits and next action

The tests fail closed when the fixed response array, non-unit slope truth,
execution state, dependency contract, or registry stratum is altered. They
also prohibit a ConQuest process call, a machine-specific executable path, and
SHA-based scientific acceptance in this construction layer.

This record closes only P3 fixture/oracle construction. The separate
`conquest-p3-metric-precision-contract-record-0.2.3.md` now freezes raw-token,
parameter, probability, q-movement, complete-denominator, and stop/invalidation
rules without retroactively changing this construction layer's false metric
flag. It also keeps `integration_unresolved` distinct from optimizer and
cross-engine disagreement. P0/P1 independent review, the smallest classified
P2 external slice, and all later authorization gates remain open.

## Artifacts

- `conquest-p3-item-only-adversarial-fixtures-0.2.3.R` owns the deterministic
  fixtures, constraint audit, A/C maps, probability/reduction checks, and
  finite/continuous likelihood oracles.
- `test-conquest-p3-item-only-adversarial-fixtures.R` exercises all three arms,
  dependency and semantic mutations, the full node ladder, and execution-free
  behavior.
- This record reports the semantic and numerical construction evidence without
  creating a public support claim.
