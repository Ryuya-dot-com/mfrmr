# GPCM JML terminal-gradient stability P1w record (0.2.3)

## Decision

P1w adds a deterministic retained-point terminal-gradient audit for the same
identified, unpenalized, no-finite-box JML GPCM objective classified by P1v.
Every fitted object receives the result at
`config$boundary_audit$gpcm_terminal_gradient_stability`.

The audit reconstructs the objective and full analytic gradient at the exact
retained optimizer vector, reconciles the stored objective and gradient norms,
checks the selected optimizer-polish stage when present, verifies up to eight
deterministically chosen free coordinates by central differences, and reports
supremum and RMS gradient norms for each free-parameter block.

The decision is deliberately local and asymmetric. A positive P1v slope-only
or competitive joint-boundary certificate is primary even if the gradient at
the finite retained vector is zero or below the implementation review
tolerance. Completed negative bounded-path searches can support only a
retained-point first-order label. They do not prove attainment of a finite
global maximum, absence of other boundary paths, structural identification,
or uncertainty eligibility.

P1x subsequently broadens the joint component to canonical general constant
log-slope rates and advances the fixed-objective classifier to v2. The P1w
precedence rule is contract-version driven, so those added positive
certificates receive the same precedence without changing the local-gradient
interpretation or any inferential flag.

P1y then transports those positive constant-rate certificates to a
vanishing-residual asymptotically-affine curved neighborhood. The terminal
gradient remains a retained-point diagnostic and is not used to widen that
curve theorem or to infer absence of unclassified curved paths.

## Fixed identity and controls

| Field | P1w identity |
| --- | --- |
| Estimator | Unpenalized fixed-effects JML |
| Objective | Identified conditional joint log-likelihood, evaluated through the optimizer's minimization objective |
| Coordinates | Exact identified optimizer free coordinates |
| Retained vector | Exact selected optimizer vector |
| Analytic check | Complete objective gradient plus stored supremum/RMS reconciliation |
| Independent check | Central differences on at most eight deterministic coordinates |
| Numeric relative step | `1e-5 * max(1, abs(parameter))` |
| Numeric scaled-difference limit | `1e-5` |
| Objective reconciliation limit | `1e-8` times objective scale |
| Stored-diagnostic reconciliation limit | `1e-10` times diagnostic scale |
| Workload guard | At most 250 free coordinates |
| Implementation gradient gate | Existing `max(1e-4, 10 * reltol)` diagnostic threshold |

The central-difference, reconciliation, dimension, and existing optimizer
thresholds are implementation controls for this audit. None is frozen as a
general scientific or release criterion.

## State contract

| State | Meaning |
| --- | --- |
| `boundary_path_gradient_nondecisive` | The fixed-objective gradient record is coherent, but a positive P1v path certificate takes precedence. |
| `boundary_path_gradient_indeterminate` | A positive P1v certificate remains primary while the retained-point gradient record is numerically incoherent. |
| `retained_point_gradient_within_implementation_tolerance` | Optimizer code zero, a coherent small retained-point gradient, and two completed negative bounded-path audits support local first-order typing only. |
| `retained_point_gradient_small_boundary_open` | The retained-point gradient is small but the P1v bounded-path classification is incomplete or identity-mismatched. |
| `terminal_gradient_exceeds_implementation_tolerance` | The coherent retained-point analytic gradient exceeds the existing implementation review threshold. |
| `small_gradient_optimizer_warning` | The retained-point gradient is small but the optimizer did not return code zero. |
| `indeterminate_numerical` | Objective, stored diagnostics, polish history, or numeric probes are incoherent and no positive boundary certificate controls the interpretation. |
| `not_evaluated_size_limit` / `not_evaluated_parameter_vector` / `not_evaluated_control` | A declared workload, retained-vector, or audit-control condition prevents evaluation. |
| `not_required_unit_slope` | The exact unit-slope reduction has no free log-slope coordinate. |
| `not_applicable_estimator` / `not_applicable_model` | The estimator or response family is outside the audit. |

All states keep `finite_interior_stationarity_certified`,
`global_finite_maximum_certified`, `global_boundary_absence_certified`,
`standard_error_eligible`, `confidence_interval_eligible`, and
`external_comparison_eligible` false. `readiness_effect` is
`none_diagnostic_only`.

## Real-fit fixture observations

Three small installed-package JML GPCM fits exercise the positive and negative
directions under the production fitting path:

| Fixture | P1v boundary result | P1w state | Gradient sup norm | Existing implementation tolerance | Maximum numeric scaled difference | Local stationarity label |
| --- | --- | --- | ---: | ---: | ---: | --- |
| Slope-only recession | positive | `boundary_path_gradient_nondecisive` | `1.8244286e-06` | `1e-04` | `2.0008254e-12` | false |
| Competitive joint boundary | positive | `boundary_path_gradient_nondecisive` | `0` | `1e-04` | `0` | false |
| Both bounded families negative | scoped negative | `retained_point_gradient_within_implementation_tolerance` | `0` | `1e-04` | `0` | true, retained point only |

The first two observations are the key safeguard: a zero or small gradient on
a finite receding sequence is not relabelled as a finite interior solution.

## Verification

Four focused files pass 315 expectations with zero failures, skips, warnings,
or errors:

| Test surface | Expectations |
| --- | ---: |
| P1w terminal-gradient stability | 83 |
| P1v fixed-objective boundary classifier | 60 |
| Existing JML GPCM slope boundary | 98 |
| Existing JML GPCM joint boundary | 74 |

Nine additional release/readiness/scope/documentation guard files pass 1,077
expectations with zero failures or errors. Three expected skips remain: two
require the uninstalled optional `diffobj` package, and one is the separately
opt-in P1p stored-result pilot. The checklist still parses to 106 rows; the
GPCM transformed-score row remains `review` with `pilot_required` criteria.
The only environment note is the existing warning that local `testthat` was
built under R 4.5.3 while the checks ran under R 4.5.1.

## FACETS and wider evidence consequence

P1w leaves the FACETS comparison-role contract unchanged. FACETS PCM/JMLE
versus mfrmr PCM/JML remains the sole possible future direct common-estimand
FACETS lane. Non-unit GPCM/JML remains truth-first, with FACETS PCM only as an
explicitly misspecified control and FACETS Table 7 discrimination
diagnostic-only. This work launches no external program and authorizes no
tolerance freeze, equivalence decision, recovery rule, broad simulation,
inference promotion, or confirmation.

## Machine-readable disposition

```text
FixedObjectiveTerminalGradientAuditImplemented = TRUE
EstimatorIdentityBound = TRUE
RetainedObjectiveReconstructed = TRUE
CompleteAnalyticGradientReconstructed = TRUE
DeterministicNumericCoordinateChecksImplemented = TRUE
OptimizerDiagnosticReconciliationImplemented = TRUE
OptimizerPolishReconciliationImplemented = TRUE
ParameterBlockNormsReported = TRUE
PositiveBoundaryCertificateHasPrecedence = TRUE
ScopedNegativeSupportsRetainedPointFirstOrderOnly = TRUE
ImplementationThresholdFrozenForScientificClaims = FALSE
FiniteInteriorStationarityCertified = FALSE
GlobalFiniteMaximumCertified = FALSE
GlobalBoundaryAbsenceCertified = FALSE
ReadinessEffect = none_diagnostic_only
ExternalComparisonAuthorized = FALSE
RecoveryClaimAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

## Identity and verification

| Artifact | SHA-256 |
| --- | --- |
| `R/core-jml-gpcm-terminal-gradient.R` | `9ab72ae7e2524b9a29ae4505f3275238f9f1532d5c947fc59db25c2cf519a88e` |
| `R/core-jml-gpcm-boundary-classification.R` | `fc28b5b61e366d127a24aacf2d408240e577fcb67cfc0ea903a55d8a67bf5997` |
| `R/mfrm_core.R` | `c54302de50ea7048b3959aa700b9a91f3485975597f8b6a8be70293ddf1fd76f` |
| `R/api-estimation.R` | `eaaaaa805df19d0b39564d5f05f1b66a440a4228ca934af7db9aa57c31507e86` |
| `man/fit_mfrm.Rd` | `f2ba74fca78850897d343daa84f39e1388406b8bcf6684dfd3e85c043993f420` |
| `tests/testthat/test-jml-gpcm-terminal-gradient-stability.R` | `d0199bcf388bbf114d6ecb329a683d39dfe739945de855710f691c68060f67e4` |
| `tests/testthat/test-jml-gpcm-fixed-objective-boundary-classification.R` | `f8067ca7ea1794decbc7362b147f8a4c932a8607d7be17b77dc01c2cd675cdaf` |
| `tests/testthat/test-jml-gpcm-slope-boundary.R` | `2c9bd9306e806c55a64788c607428476d6756fc5d50e96d36cdeb2ec7c7f03ff` |
| `tests/testthat/test-jml-gpcm-joint-boundary.R` | `8b61e97eef9216d58bd0698bdcc348fe535e124e4a2c821bed8aa9ee84dd5ebb` |
| `NEWS.md` | `b1aee634f86ae599e4eea02b22e19bbbf0be5af86069769be592f32aa7e69d5c` |
| `ROADMAP.md` | `71c11b7810a41787abf67701a4fa4e3424ff4b75139ca6e9ad63b0e7a962aeaf` |
| `inst/validation/README.md` | `c9cc2f77097a3a680c8159560722eb4ac2f79de9fb916facbf07707465eec002` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `4e307852e8e9402c0306951cc721a8dfffcba3876b2e103e9de86c3a5c55db40` |
