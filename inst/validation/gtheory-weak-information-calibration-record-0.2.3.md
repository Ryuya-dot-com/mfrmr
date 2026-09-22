# Draft.83d2b2a G-theory weak-information calibration record

Date: 2026-08-09
Scope: repository-only one-replicate covering smoke for observable diagnostics
Result: execution/accounting passed; the existing whole-model gate failed as a
target-component resolution rule; no calibration threshold was selected

## Outcome

The frozen registry crosses five design/information strata, six generating
Rater-variance regions, and four likelihood routes. All 120 planned units were
attempted, returned, and recorded. The four method strata were then restored to
the canonical manifest order and produced this deterministic combined identity:

`71978d3ea5bd747ae53526f8bbfe3bfde5a086e0267f6e9530b088cfb4f9f336`.

The existing Draft.83d2b1 whole-model point gate passed 82 units. It also
produced 27/40 false-ready results among registered zero/near-zero target-
component routes and 3/12 false blocks among narrowly registered ordinary-
positive controls. These are
deliberate counterexamples, not thresholds or operating-characteristic
estimates.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| testthat | 3.3.2 |
| digest | 0.6.39 |
| lme4 | 2.0.6 |
| glmmTMB | 1.1.14 |
| TMB | 1.9.23 |
| Matrix | 1.7.6 |
| Platform | aarch64-apple-darwin23; Darwin 25.5.0 arm64 |

## Registry and denominators

| Quantity | Result |
| --- | ---: |
| design/information strata | 5 |
| target-variance regions | 6 |
| scenario cells | 30 |
| likelihood/backend routes per cell | 4 |
| planned/attempted/returned units | 120 / 120 / 120 |
| existing whole-model point gates passed | 82 |
| negative-control routes | 40 |
| negative-control false ready | **27** |
| positive-control routes | 12 |
| positive-control false block | **3** |
| transition routes without a binary requirement | 68 |
| atomic accounting | passed |

The 40 negative-control routes are the exact-zero and numerical-near-zero
Rater-variance cells in every design. The 12 positive-control routes are
deliberately restricted to variance 0.12 in the baseline and high-information
designs and variance 0.04 in the high-information design. The remaining 68
routes do not enter either binary error denominator.

The registry identity is:

`8a1c165d5497519f14f9839a22eed7b9e918b5120da83985613d01fd76a8be01`.

## Method-stratified execution identities

| Method stratum | Smoke SHA-256 identity |
| --- | --- |
| lme4 REML | `f39a49f65038fa6d4df7df2a81c9d2715cf5d9f64e04127843cbc406f4101104` |
| glmmTMB REML | `19959e174c87bdcce6a8adeb4b3883884d57f90dfd1b684ded724026dcc91ea8` |
| lme4 ML | `27836df498b6b4a9e1ce48e51a93017661539d106ddb7acb626d2ac5adbef3ea` |
| glmmTMB ML | `ea8006eaca77294c3e90851c05683b96310ef838ea071d422854aea23c962555` |

Every stratum contains all 30 scenarios under one registry identity. The four
strata partition the registered methods exactly. A sequential run that was
stopped after 68 of 120 units is not counted as evidence.

## False-ready and false-block decomposition

| Negative-control region | False ready / routes |
| --- | ---: |
| exact zero | 15 / 20 |
| numerical near zero (`1e-10`) | 12 / 20 |

The design-specific false-ready counts were:

| Design | Exact zero | Near zero |
| --- | ---: | ---: |
| baseline complete | 0 / 4 | 0 / 4 |
| few levels complete | 4 / 4 | 4 / 4 |
| high information | 4 / 4 | 0 / 4 |
| sparse connected | 3 / 4 | 4 / 4 |
| imbalanced hub | 4 / 4 | 4 / 4 |

All three positive-control false blocks occurred in the high-information,
variance-0.04 cell. Only one of its four routes passed the whole-model gate.
The baseline variance-0.12 and high-information variance-0.12 cells passed all
four routes.

This asymmetry is the central result. A target component can look positive
while every numerical whole-model diagnostic passes; conversely, a positive
target can be blocked by boundary or curvature behavior in a nuisance
component. Therefore `EstimationGatePassed` is neither a target-component
detection rule nor calibrated evidence of estimability.

## Observable diagnostic layer

Ten truth-blind application observables are implemented: target estimate,
target fraction of total fitted variance, target-to-residual ratio, target
grouping levels, observations per target level, the existing point gate,
boundary/singularity state, local curvature, backend estimate contrast, and
ML/REML estimate contrast. The generating variance and control role are kept
only for simulation scoring.

The full-versus-reduced component likelihood drop is registered but not yet
implemented. Because a variance-component null lies on the boundary, an
ordinary one-degree chi-square cutoff is not adopted implicitly. Full-refit
component intervals remain owned by Draft.84.

No implemented observable is currently a rule. In particular, Rater level
count or observations per Rater is not treated as a universal minimum sample
size.

## Test evidence

Six focused tests contain 56 evaluated expectations and one explicit skip for
the resource-tier 120-unit rerun. They verify the exact 5 x 6 x 4 registry,
role denominators, deterministic truth-separated generation, all five design
strata at structural pre-fit, a representative 12-fit observable smoke,
identity-preserving method contrasts, malformed-input failure, and the opt-in
full-smoke identities and counts. The full 120-unit smoke was executed
separately in four method strata for this record.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-weak-information-calibration-prototype-0.2.3.R` | `53aa8c9f6bbbd2ff018f4172ef203e912766538fafcd1f9bbcfe7dae0436ea55` |
| `gtheory-weak-information-calibration-contract-0.2.3.md` | `cdb49c22a226fd6f2a72a42a445d94f9a64b353367b6219c03f28c1e91a590a4` |
| `test-gtheory-weak-information-calibration-prototype.R` | `9c3e3744907c907a8c40c2a29b4f9d19f3188d76338f555c3c79a0fc8d283ce0` |

The record's own hash is omitted because recording it would change the file.

## Readiness and next gate

`ThresholdFrozen`, `CalibrationEvidenceReady`, `ConfirmationAuthorized`,
`RecoveryEvidenceReady`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` remain false.

The next slice is a replicated feasibility pilot, not threshold promotion. It
must pre-register replication counts and Monte Carlo standard-error targets,
preserve paired seeds across methods, decompose target-component weakness from
nuisance-component failure, and compare a small prespecified candidate-rule
set by design stratum. Only the pilot may freeze a rule, indeterminate zone,
and failure behavior. Untouched confirmation seeds must be generated only
after that freeze.
