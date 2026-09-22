# Draft.83d2b2b1g11 stationarity acceptance-policy record

Status: completed repository-only policy freeze, 2026-08-10. No calibration
or confirmation response was generated, opened, summarized, or used to choose
a rule.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| upstream b1g10 contract | `419fbf43fd1b86ab494aa96224916c0bfa9c1e1ef2668f8877d9d39659bcc7e0` |
| four-lane reference receipt | `777e7550a188f89515854738e3b7e42ef418037de4c9f7166a67d61e6dfa2e9e` |
| b1g11 policy | `7962e47df285812d8c785f206d51925b44a13d02037b7b40a619cb80ce833a62` |
| b1g11 selection audit | `cfdaa73ddc0beb6cc6ca3fbdc2cd7c73bd899bf9e6bebaab675ccc7bd88b16f7` |
| b1g11 contract object | `1dcc877da78d3975271b33629b3d67bd9f0f48d675fb1ed62e5704baa46b8b1a` |
| source artifact | `32ac04314fa7b65bb298a3eeeb343a35a17def477d3f8cc2799c1655efaa2267` |
| contract artifact | `f2b7ffdf75a3c48472b8908f71c0245e0a1bacaaf941a0eebd541a0b3acb7326` |
| focused test artifact | `4c79b8270147fe534a1b044b0950b8769d3f5318871442a684c9a296c6c2150c` |

## Policy result

The 24-candidate primary grid is intact: three primary-eligible score families
crossed with eight adjacent threshold zones. Newton decrement has first family
priority because its squared value is invariant under nonsingular affine
reparameterization when positive-definite curvature exists. The other two
families remain coordinate-sensitive practical comparators, not equivalent
metrics.

The policy keeps numerical safety, boundary routing, abstention, and
computational failure separate. It rejects any calibration candidate with an
observed false-ready finite claim or false boundary handoff. It also requires
correct decisive coverage for all 20 method x model-role x reference-class
combinations, so an always-indeterminate rule cannot be selected.

No weighted loss is estimated from data. Remaining candidates are ordered by
worst primary-cell one-sided exact-binomial upper bounds, followed by frozen
metric and zone priorities. A complete negative calibration is an admissible
scientific result and freezes no threshold.

## Monte Carlo audit

The independent exact-binomial implementation returned:

| Events / trials | One-sided 95% upper bound |
| --- | ---: |
| 0 / 25 | 0.1129281450068 |
| 0 / 100 | 0.0295130496070 |
| 0 / 200 | 0.0148670392313 |

The exact minimum zero-event denominator for an upper bound no greater than
0.05 is 59. A zero denominator returns unavailable rather than zero. The
policy also records that these bounds are descriptive calibration scores and
cannot be advertised as unconditional post-selection 95% intervals.

## State-algebra audit

Synthetic controls verified that:

- one safety false-ready event defeats otherwise favorable metrics;
- a false boundary handoff is distinct from finite false-unready;
- missed boundaries, indeterminate states, not-evaluable states, and reference
  unresolved states retain separate counts;
- every primary rate remains at scenario x method x model-role resolution;
- a truth column, incomplete 24-candidate ledger, duplicate row, or reference
  label that changes across candidates is rejected;
- a safe decisive candidate beats an unsafe candidate and an always-
  indeterminate candidate; and
- when all candidates contain a safety event, selection returns
  `negative_calibration_no_stationarity_threshold` and no candidate ID.

## Reference-receipt replay

The retained nonreserved caches were locally available. Their native
integrity validators passed for glmmTMB REML, glmmTMB ML, and the joint lme4
ML/REML execution. Exact execution hashes matched all four receipt rows.
`ReferenceMethodCoverageComplete=TRUE` remains a narrow reference-mechanics
claim and does not rank backends or likelihood modes.

## Verification

Nine focused tests with 102 expectations pass. They cover candidate and
receipt identities, retained receipt validation, exact-binomial mechanics,
state classification, cell-denominator integrity, truth-blind failures,
selection and negative-result paths, contract mutation rejection, source
routing, and all readiness guardrails.

## Readiness interpretation

The following narrow flags are true:

- `AcceptancePolicyFrozen`;
- `MonteCarloDecisionPolicyFrozen`; and
- `ReferenceMethodCoverageComplete`.

The following remain false:

- `ProductionBoundaryProbeReady` and `RunnerImplementationReady`;
- `CalibrationAuthorizationReady` and `CalibrationExecutionAuthorized`;
- `CalibrationDataGenerated` and `CalibrationResultsViewed`;
- `StationarityThresholdFrozen` and `StationarityCriterionReady`; and
- confirmation, inference, coefficient, and decision readiness.

The next admissible slice is the production boundary probe. It must translate
glmmTMB log-SD and lme4 nonnegative-theta boundaries without using first-order
zero as sufficient evidence, retain inconclusive/non-evaluable states, and
reduce exactly to the already verified full/reduced objective endpoints. Only
after that probe passes may an exact-resume runner be implemented and a new
authorization identity reconsider opening replicate 201.
