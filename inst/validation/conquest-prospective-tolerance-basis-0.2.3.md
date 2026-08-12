# ConQuest prospective numerical-budget basis for mfrmr 0.2.3

Status: future-candidate-only engineering decision, 2026-08-12. This record
defines numerical budgets before any new candidate output exists or is opened.
It does not reclassify the opened calibration, establish hidden-solution or
scientific equivalence, bind a candidate, launch ConQuest, or authorize
confirmation.

## Estimand and scope

The comparison target is the exact decimal written to the audited native
ConQuest 5.47.5 files, not an unprinted optimizer value. Every parameter is
first mapped to the registered common coordinate and identification basis.
The objective is positive deviance. These budgets apply only to the six-arm
`Binary/RSM/PCM x q31/q61` microcase under the existing observation, weight,
facet, category, constraint, likelihood, and integration contracts.

The rules are:

| Criterion | Units | Signed interval | Absolute tolerance |
| --- | --- | ---: | ---: |
| `EXT-CQ-TOL` | common model coordinate | `[-1e-5, 1e-5]` | `1e-5` |
| `EXT-CQ-TOL` | positive deviance | `[-2e-6, 2e-6]` | `2e-6` |
| `IC-INTEGRATION-TOL` | common model coordinate | `[-2e-6, 2e-6]` | `2e-6` |
| `IC-INTEGRATION-TOL` | positive deviance | `[-2e-6, 2e-6]` | `2e-6` |

All signed bounds are symmetric. The observed sign of the calibration
difference is therefore not encoded in the future rule. Every one of the 57
family, engine, and estimand-class rows is evaluated separately; a passing
maximum cannot hide a missing or failing class.

## Numerical interpretation

For a location-type logit coordinate, `1e-5` corresponds to a one-coordinate
odds multiplier `exp(1e-5) = 1.00001000005`, approximately a `0.001%` relative
change. This statement is a local scale interpretation, not a global bound on
all category probabilities or on a slope multiplied by an unbounded latent
value.

A deviance change of `2e-6` changes the corresponding likelihood ratio by at
most about one part per million because `exp(2e-6 / 2) = 1.0000010000005`.
For models with the same free dimension and Person count, common AIC, BIC, and
SABIC shift by the same deviance amount. Any eventual ordering whose margin is
not larger than the applicable combined numerical budget must remain a tie or
unresolved; tolerance passage alone cannot authorize selection.

The q31/q61 budget is narrower than the cross-engine coordinate budget because
it compares one engine, input, parameterization, and reported coordinate map
under two fixed quadrature grids. It is not an optimizer convergence threshold
and does not apply to q7/q15, which remain diagnostic or rejected.

## Calibration-informed margin

The budgets are deliberately close enough that a new run can fail:

- the historical Binary ladder's largest transformed-parameter difference was
  `5.761704441e-6`, giving less than a factor-two margin under `1e-5`;
- the retained additive exact-decimal rows have a largest direct common-
  coordinate difference of approximately `2.734e-6` on population variance;
- the broader q31--q121 polytomous ladder's largest cross-engine deviance
  difference was `1.248110e-6`, giving less than a factor-two margin under
  `2e-6`;
- ConQuest q31/q61 tokens are identical in the retained Binary, RSM, and PCM
  calibrations; and
- additive mfrmr same-point q31/q61 deviance differences are below
  `2.73e-12`, with direct retained-coordinate differences below `1.67e-11`.

These observations inform an engineering budget for a disjoint future
candidate. They cannot be evaluated as passing evidence under the rule they
helped set. The rationale type is therefore
`opened_calibration_future_candidate_only`, with
`CalibrationInformed = TRUE` and `OpenedCalibrationEligible = FALSE` on every
row.

## Deliberate non-claims

Passing these budgets establishes only narrow numerical reproducibility on the
registered exact reported-decimal estimands. It does not establish:

- an interval containing ConQuest's hidden optimizer solution;
- identical estimation algorithms or integration implementations;
- parameter recovery, standard-error coverage, or adequate sample size;
- invariance of DFF significance/classification, infit/outfit decisions,
  Person/Rater ranks, or `inference-ready` status;
- general sparse, imbalanced, extreme-score, GPCM-slope, or many-facet
  equivalence; or
- scientific interchangeability of mfrmr and ConQuest.

Those decisions retain their own predeclared gates. Independent platform or
version replication also remains required before promotion.

## Source evidence

The decision uses the following already opened calibration sources only for a
future candidate:

- `inst/validation/external-ic-pilot-record-0.2.3.md`;
- `inst/validation/conquest-reported-output-precision-contract-record-0.2.3.md`;
- `inst/validation/conquest-reported-point-likelihood-calibration-record-0.2.3.md`;
- `inst/validation/conquest-additive-tolerance-adjudication-0.2.3.md`; and
- `inst/validation/conquest-six-arm-coverage-contract-record-0.2.3.md`.

The freeze generator must bind this file's SHA-256, the canonical 57-row table
hash, and the six-arm normalizer/source-precision registry hashes. A later
candidate binding must still be created before any candidate output exists.
