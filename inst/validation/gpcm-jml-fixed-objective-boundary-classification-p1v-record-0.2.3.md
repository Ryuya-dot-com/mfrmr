# GPCM JML fixed-objective boundary classification P1v record (0.2.3)

## Decision

P1v implements an estimator-specific classification over the existing JML
GPCM slope-only and joint additive/log-slope boundary audits. The classifier
is attached to every fitted object's internal boundary audit as
`gpcm_fixed_objective_classification`.

The positive and negative directions are deliberately asymmetric. A positive
sufficient certificate establishes the stated path result. Completed negative
searches establish only that no path was certified in those bounded families;
they do not establish a finite global maximum, global boundary absence, or
nonlinear structural identification. A finite optimizer iterate is retained
as a numerical trace, not relabelled as an attained finite MLE.

This closed the P1u semantic follow-up for the two path families implemented
at P1v. P1x subsequently advanced the classifier contract to v2 by extending
the joint family to canonical general constant log-slope rates. Curved or
rate-nonconvergent paths, unrestricted nonlinear additive motion, and
arbitrary sparse/category topologies remain outside the classifier.

## Fixed estimator and objective identity

| Field | Classified identity |
| --- | --- |
| Estimator | Unpenalized fixed-effects JML |
| Objective | Identified conditional joint log-likelihood |
| Person treatment | Fixed unknown coordinates estimated jointly |
| Slope identification | Sum-zero expanded log slopes |
| Penalty | None |
| Finite parameter box | No |

The supplied JML/PJML memorandum was used with the source-audited correction
already recorded in `gpcm-literature-to-contract-0.2.3.md`: mfrmr's current
JML route passes no finite parameter box to `optim()`. It is therefore not the
bounded JMLE described in the memorandum and is not the same estimator as
Wijayanto-style penalized JML. Rirt finite-box JML and Muraki-style MML also
remain separate objective/parameter-space families.

## State contract

| State | Meaning |
| --- | --- |
| `certified_slope_only_recession` | A monotone constant sum-zero slope-only recession path is certified at fixed retained additive coordinates. |
| `certified_competitive_joint_boundary` | A sufficient competitive joint additive/constant-log-slope-rate asymptotic boundary candidate is certified; global status stays open. |
| `certified_slope_and_joint_boundary` | Both positive certificates are present under the same objective identity. |
| `finite_retained_point_no_path_certified` | Both bounded path families completed without a positive certificate; only the retained optimizer trace is finite. |
| `indeterminate_numerical` | Likelihood reconstruction or numerical path computation prevents a negative conclusion. |
| `not_evaluated` | A workload, dependency, design, mapping, or other execution requirement prevented complete classification. |
| `not_evaluated_objective_identity` | Component audits cannot be shown to belong to the required JML-GPCM objective. |
| `not_required_unit_slope` | The exact unit-slope reduction has no free relative log-slope coordinate. |
| `not_applicable_estimator` / `not_applicable_model` | The requested objective or response family is outside this classifier. |

Every state separately retains component audit states, finite retained-point
status, positive-certificate flags, bounded-family completion, numerical
indeterminacy, and objective identity. A completed negative result sets
`audited_path_family_result_classified` but not
`fixed_objective_boundary_presence_classified`. The following global and
inferential flags remain invariantly false for free-slope JML GPCM:

- `global_boundary_classified`;
- `global_finite_maximum_certified`;
- `global_boundary_absence_certified`;
- `standard_error_eligible` and `confidence_interval_eligible`; and
- `external_comparison_eligible`.

`readiness_effect` is `none_diagnostic_only`. Existing slope parameter typing
and fit readiness are unchanged.

## Focused verification

Three focused files pass 232 expectations with zero failures or skips:

| Test surface | Expectations | Covered result |
| --- | ---: | --- |
| Fixed-objective classifier | 60 | slope, joint, combined, scoped-negative, numerical, workload, incomplete-positive, objective-mismatch, MML, non-GPCM, and unit-slope states |
| Existing JML GPCM slope boundary | 98 | real-fit slope recession, direct objective path, invariance, limits, negative control, and parameter typing |
| Existing JML GPCM joint boundary | 74 | real-fit joint candidate, direct objective path, invariance, scoped negative, workload, and MML non-reuse |

The tests use the installed package from a clean native rebuild. The local
`testthat` package reports only its pre-existing R-version build warning.

Nine additional release/readiness/scope/documentation guard files pass 1,077
expectations with zero failures. Three expected skips remain: two require the
uninstalled optional `diffobj` package, and one is the separately opt-in P1p
stored-result pilot. The checklist still parses to 106 rows; both JML-GPCM
boundary rows remain `review` with `pilot_required` criteria.

## FACETS and wider evidence consequence

P1v does not change the FACETS comparison-role contract. Direct FACETS
common-estimand comparison remains PCM/JMLE only. Unit-slope GPCM remains an
internal PCM reduction, non-unit GPCM remains truth-first, and FACETS Table 7
discrimination remains diagnostic-only. No external execution, tolerance,
recovery rule, broad simulation, candidate, confirmation, or GPCM promotion
is authorized.

## Machine-readable disposition

```text
FixedObjectiveBoundaryClassifierImplemented = TRUE
EstimatorIdentityBound = TRUE
JmlSlopeRecessionTyped = TRUE
JmlCompetitiveJointBoundaryTyped = TRUE
ScopedNegativeTyped = TRUE
FiniteOptimizerTraceIsFiniteMaximum = FALSE
NumericalIndeterminacySeparated = TRUE
WorkloadNonEvaluationSeparated = TRUE
GlobalBoundaryClassified = FALSE
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
| `R/core-jml-gpcm-boundary-classification.R` | `fc28b5b61e366d127a24aacf2d408240e577fcb67cfc0ea903a55d8a67bf5997` |
| `R/mfrm_core.R` | `c54302de50ea7048b3959aa700b9a91f3485975597f8b6a8be70293ddf1fd76f` |
| `R/api-estimation.R` | `eaaaaa805df19d0b39564d5f05f1b66a440a4228ca934af7db9aa57c31507e86` |
| `man/fit_mfrm.Rd` | `f2ba74fca78850897d343daa84f39e1388406b8bcf6684dfd3e85c043993f420` |
| `tests/testthat/test-jml-gpcm-fixed-objective-boundary-classification.R` | `f8067ca7ea1794decbc7362b147f8a4c932a8607d7be17b77dc01c2cd675cdaf` |
| `tests/testthat/test-jml-gpcm-slope-boundary.R` | `2c9bd9306e806c55a64788c607428476d6756fc5d50e96d36cdeb2ec7c7f03ff` |
| `tests/testthat/test-jml-gpcm-joint-boundary.R` | `8b61e97eef9216d58bd0698bdcc348fe535e124e4a2c821bed8aa9ee84dd5ebb` |
