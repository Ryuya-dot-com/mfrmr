# GPCM MML boundary-path deterministic challenge contract for mfrmr 0.2.3

Status: Draft.71 prospective extension calibration; deterministic challenge
expectations frozen before q=31/61/91 execution; readiness propagation,
statistical operating characteristics, confirmation, and release use prohibited

## Purpose and evidence role

Draft.70 found no positive certified path in 40 ordinary retrospective
datasets. This contract therefore tests positive-path detection separately from
owner recovery and quadrature-tolerance calibration. It extends the already
known q=5 criterion-owned positive fixture to reversed directions, rater
ownership, positive-weight support discontinuity, and q=31/61/91. Outcomes are
deterministic software-property calibration, not estimates of prevalence,
sensitivity, specificity, or false-negative rate under a sampling model.

The contract is frozen before running the new owner/direction/weight/q cells.
The original criterion-forward construction is not novel because its q=5
behavior was used in Draft.69. It remains a required reference control and is
never labelled independent confirmation.

## Frozen challenge panel

Every dataset contains 12 Persons crossed with two Raters and two Criteria on
a binary 0--1 score scale. The fitted route is aligned single-owner GPCM,
direct fixed-standard-normal MML, geometric-mean-one owner slopes,
`optimizer = "auto"`, `maxit = 50`, and q=31/61/91. For criterion ownership,
both Rater levels are fixed at -10; for rater ownership, both Criterion levels
are fixed at -10. Owner and non-owner labels, row order, starts, controls, and
anchors are unchanged across q.

For each owner, the following five deterministic challenges are required:

| Challenge | Scores by owner level | Row weight perturbation | Frozen expected direction/state at every q |
| --- | --- | --- | --- |
| `positive_forward` | first level 1, second level 0 | all 1 | first > second; exactly one certified ordered pair |
| `positive_reverse` | first level 0, second level 1 | all 1 | second > first; exactly one certified ordered pair |
| `mixed_negative` | both owner levels contain alternating 0 and 1 | all 1 | none certified |
| `zero_weight_discordant` | forward pattern plus one contradictory first-level row | contradictory row 0, all others 1 | the zero-weight row is removed; first > second remains certified |
| `epsilon_weight_discordant` | identical to zero-weight challenge | contradictory row `1e-8`, all others 1 | none certified; any positive effective weight remains in scope |

Thus the panel has 10 exact owner/challenge datasets and 30 q arms. A row with
weight zero is expected to be excluded by the declared data-preparation
contract; it is not silently treated as positive weight. The paired epsilon
row probes the exact support discontinuity of the sufficient condition, not a
practical-effect cutoff. No outcome-dependent perturbation, retry, cell
removal, alternative anchor, or tolerance widening is allowed.

## Required checks and outputs

For every arm retain fit/error/warning state, retained-row and retained-data
hash, numerical readiness, evidence readiness, audit state/completeness/scope,
fixed-versus-continuous flags, certified pair identities and directions,
target statuses, group max/min compatibility and minimum support margins,
boundary improvement, likelihood reconstruction difference, and numerical
slope-proposal rejection count.

For every exact dataset require:

- identical retained-data hashes across q;
- identical audit state, direction set, and target status across q;
- exact agreement with the frozen expected direction/state;
- zero-weight versus epsilon-weight retained-row behavior matching the table;
- finite likelihood reconstruction within the implementation tolerance; and
- unchanged `none_instrumentation_only` readiness effect with zero
  evidence-inference-ready arms.

Every planned arm remains in the denominator. A fit or audit failure is a
failed deterministic expectation, not a reason to remove the cell. Atomic
dataset checkpoints bind all three q arms to the runtime, runner, contract,
manifest, controls, and non-confirmation state. Aggregate publication requires
all ten checkpoints plus a complete relative-path/SHA-256 inventory and an
independently sourced completion validator.

## Interpretation and next gate

Passing this panel establishes only that the implementation behaves as
declared on ten deterministic constructions. It does not establish:

- completeness of the sufficient path family or a finite global MLE;
- behavior for the exact continuous-normal integral or moving additive paths;
- positive/negative classification rates in owner simulations or empirical
  data;
- a quadrature equivalence tolerance, default, sample-size rule, recovery or
  coverage result;
- valid slope uncertainty, fit, DFF, owner superiority, or estimator ranking;
  or
- readiness propagation, checklist promotion, confirmation, or release use.

Only after this deterministic challenge passes may a separate untouched-seed
owner panel estimate classification behavior and test a prospectively frozen
q61-to-q91 rule. Any later readiness-propagation contract must consume both the
deterministic challenge identity and the independent stochastic evidence; it
cannot be inferred from this panel alone.
