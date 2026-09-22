# Draft.83d2b2b1g7 stationarity-calibration preauthorization audit contract

Status: completed repository-only preauthorization audit, 2026-08-10. This
contract corrects workload accounting, freezes candidate-state and optimizer-
profile aggregation semantics, and audits high-accuracy reference coverage.
It does not authorize generation or inspection of calibration replicates
201--300 or confirmation replicates 501--700.

## Why this audit is required

Draft.83d2b2b1g5 sealed one common six-profile count for all four method
lanes. The actual prospective registries are backend-specific: the b1g
glmmTMB stabilization DAG has six profiles, while the b1e lme4 sensitivity
registry has three. The b1g5 identity and historical record remain immutable;
b1g7 supersedes only the prospective workload accounting used by a future
runner.

The b1g6 high-accuracy replay also covered glmmTMB REML only. Passing that
gate cannot be generalized silently to glmmTMB ML or to either lme4
likelihood lane. The authorization audit must therefore fail closed before a
reserved seed is opened.

## Corrected workload

Each method lane contains 3,000 dataset-method units and two model roles. The
candidate-fit count below is a planned upper bound if every registered
backend profile is evaluated; it is not an observed runtime count.

| Method lane | Profiles per role | Candidate-fit upper bound | Reference problems | Reference mechanics |
| --- | ---: | ---: | ---: | --- |
| glmmTMB ML | 6 | 36,000 | 6,000 | nonreserved replay not run |
| glmmTMB REML | 6 | 36,000 | 6,000 | b1g6 nonreserved replay passed |
| lme4 ML | 3 | 18,000 | 6,000 | not implemented |
| lme4 REML | 3 | 18,000 | 6,000 | not implemented |
| total | backend-specific | 108,000 | 24,000 | 1 of 4 lanes ready |

The former 144,000 candidate-fit total therefore overcounted the prospective
upper bound by 36,000. Dataset count (3,000), dataset-method units (12,000),
and high-accuracy reference problems (24,000) are unchanged.

## Profile aggregation contract

Profile aggregation occurs within one `dataset_method_model_role` ledger.
Every profile registered for that backend must have one row. Among returned
finite objectives, the smallest objective is selected. An exact tie is
resolved by the frozen registry priority. If no finite objective is
available, the role is `not_evaluable`.

The stationarity metric, the later calibration loss, and generating truth may
not choose an optimizer profile. This prevents a diagnostic from selecting
the numerical path on which that same diagnostic looks most favorable. No
objective is compared across backends, likelihood modes, datasets, or model
roles.

This rule is a deterministic profile aggregator, not a global-optimum claim.
Official lme4 documentation exposes optimizer, control, derivative-check, and
boundary-restart settings, and `allFit()` is explicitly a multi-optimizer
comparison. Official glmmTMB documentation likewise treats optimizer/control
identity, restarts, alternative optimizers, and Hessian diagnostics as
distinct numerical evidence. Those sources support retaining backend-
specific profiles; they do not establish statistical equivalence among them.

## Candidate-state algebra

For frozen nonnegative cutpoints `u < l`, a truth-blind first-order score is:

| Score | First-order state |
| --- | --- |
| nonfinite or negative | `not_evaluable` |
| `score <= u` | `stationary_zone` |
| `u < score < l` | `indeterminate_zone` |
| `score >= l` | `nonstationary_zone` |

Application state is then constructed in this order:

1. an unevaluable boundary probe gives `not_evaluable`;
2. a supported boundary limit gives `boundary_handoff`;
3. an inconclusive boundary probe gives `indeterminate`;
4. an unevaluable first-order or curvature result gives `not_evaluable`;
5. a nonstationary score or indefinite Hessian gives
   `numerically_ineligible`;
6. an intermediate score, a spectrally positive but nonfactorable Hessian, or
   a near-singular/semidefinite Hessian gives `indeterminate`; and
7. only a stationary-zone score with factorable positive-definite curvature
   gives `numerically_eligible`.

This is numerical eligibility only. It is not evidence that a target variance
component is statistically resolved, and it cannot use the generating
variance. The production candidate boundary probe is not yet implemented, so
the algebra being frozen does not make the rule executable.

## Checkpoint and retention boundary

The atomic checkpoint is one dataset-method unit containing every backend
profile, both model roles, and both high-accuracy reference problems. The
prospective ledger requires 12,000 method-unit checkpoints and 3,000 dataset
completion markers. Candidate fit objects, random-effect modes, and duplicated
source data are not retained in scientific sidecars.

No future runner may silently change the unit of accounting, drop failed
profiles, pool method lanes, or construct successful-only denominators.
ADEMP-style analysis requires the estimand, data-generating mechanism,
estimator, performance measures, and complete failure accounting to be fixed
before simulation results are inspected.

## Authorization result

The following narrow audit states are true:

- `PreauthorizationAuditReady`;
- `BackendProfileAccountingReady` and `WorkloadCorrectionReady`;
- `CandidateStateAlgebraReady`;
- `PrimaryProfileAggregationReady`; and
- `B1g6ReceiptBound`.

The following remain false:

- `CalibrationAuthorizationReady` and `CalibrationExecutionAuthorized`;
- `ReferenceMethodCoverageComplete`;
- `AcceptancePolicyFrozen`;
- `RunnerImplementationReady` and the production boundary probe;
- `StationarityThresholdFrozen` and `StationarityCriterionReady`;
- full execution, confirmation, inference, coefficient, and decision
  readiness.

Before a separate immutable authorization can open replicate 201, glmmTMB ML
must pass a nonreserved reference replay, likelihood-faithful lme4 ML/REML
reference mechanics must be implemented and pass nonreserved controls, the
candidate acceptance/indeterminate policy and Monte Carlo decision rules must
be frozen, and an exact-resume runner must pass nonreserved mechanics tests.

## Sources

- lme4 `lmerControl` documentation:
  https://lme4.github.io/lme4/reference/lmerControl.html
- lme4 `allFit` documentation:
  https://lme4.github.io/lme4/reference/allFit.html
- glmmTMB control documentation:
  https://glmmtmb.github.io/glmmTMB/reference/glmmTMBControl.html
- glmmTMB troubleshooting guidance:
  https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html
- Morris, T. P., White, I. R., and Crowther, M. J. (2019). Using simulation
  studies to evaluate statistical methods. *Statistics in Medicine*, 38,
  2074--2102. https://doi.org/10.1002/sim.8086
