# GPCM JML asymptotically-affine transport P1y record (0.2.3)

## Decision

P1y implements a positive-only continuity transport for boundary paths already
certified by the fixed-objective JML GPCM slope-only, ordered-pair, or P1x
canonical constant-rate audits. Every fit retains the result at
`config$boundary_audit$gpcm_asymptotically_affine_transport`.

For each strict source certificate with a finite competitive analytic boundary,
the audit records that every declared curved perturbation with vanishing
additive and sum-zero expanded-log-slope residuals has the same boundary
likelihood. It does not search for new curved paths and does not convert a
negative constant-rate search into curved-path absence.

An explicit zero-rate counterexample proves the scope restriction is
necessary: bounded residuals which do not converge to zero can yield distinct
subsequential likelihood limits even though the leading normalized rate vector
is unchanged.

## Transport theorem

Let a source certificate have free additive direction `d`, expanded sum-zero
log-slope rate vector `q`, retained additive vector `b0`, and retained expanded
log slopes `ell0`. P1y admits paths of the form

```text
b(t)   = b0   + t d + r_b(t),       ||r_b(t)||_inf -> 0,
ell(t) = ell0 + t q + r_e(t),       ||r_e(t)||_inf -> 0,
sum_j r_ej(t) = 0.
```

The result follows by the source role groups:

- strict positive-rate category margins remain strict under `r_b(t) -> 0`,
  and the corresponding probabilities tend to one;
- zero-rate slopes return to their retained finite values, while tied
  additive-direction categories receive only a vanishing utility perturbation;
- leading-negative and deeper-negative slopes still tend to zero, and
  multiplying their linear additive terms by the slopes gives the same
  leading coefficient and uniform category boundary; and
- the reconstructed likelihood therefore converges to the same finite analytic
  boundary already shown competitive with the retained objective.

The transported curve need not be monotone at every finite distance. P1y
certifies its limit and existence as a boundary sequence, not a new monotonicity
or global-optimality theorem.

## Production states

| State | Meaning |
| --- | --- |
| `certified_vanishing_residual_curved_neighborhood` | At least one strict finite source certificate transports to the declared vanishing-residual curved neighborhood. |
| `no_positive_path_to_transport` | Admitted constant-rate source families completed without a positive certificate; no curved-path absence claim follows. |
| `indeterminate_source_certificate` | The fixed-objective classifier is positive but its retained certificate table cannot support the continuity transport. |
| `not_evaluated_source` | The source boundary families are incomplete or indeterminate. |
| `not_evaluated_objective_identity` | The source classifier contract or objective identity is missing or mismatched. |
| `not_required_unit_slope` | The exact unit-slope reduction has no free log-slope path. |
| `not_applicable_estimator` / `not_applicable_model` | MML or another response family is outside the theorem. |

The source registry separately retains slope-only, joint ordered-pair, and
joint canonical-rate paths, strictness, finite boundary and improvement,
source completion, and transport status. A valid positive path can transport
even if a broader source family is workload-incomplete; a negative conclusion
requires the upstream fixed-objective classification to have completed.

All states keep `bounded_nonvanishing_residual_classified`,
`rate_nonconvergent_path_classified`, `general_curved_path_classified`,
`curved_path_absence_certified`, `global_boundary_classified`,
`global_finite_maximum_certified`, `global_boundary_absence_certified`,
uncertainty eligibility, and external-comparison eligibility false.
`readiness_effect` is `none_diagnostic_only`.

## Direct vanishing-residual check

The P1x three-level rate vector `(3,-1,-2)` was evaluated with nonlinear
residuals proportional to `sin(t)/(1+t)` in both additive utilities and a
sum-zero log-slope contrast. At `t = 4,8,16,32`, the log likelihoods were

```text
-3.397888015101768
-3.297995402757655
-3.295838728402557
-3.295836866004721
```

The analytic boundary is `-3 log(3) = -3.295836866004329`; the final absolute
difference is `3.92e-13`. This verifies the curved construction independently
of the registry classification.

Production-path checks also transport one real slope-only recession
certificate and both real checkerboard joint-pair certificates. A balanced
three-level negative fit returns `no_positive_path_to_transport`, with every
curved-path absence and global flag false.

## Nonvanishing-residual counterexample

For rates `(1,0,-1)`, keep a nontrivial finite base utility on the zero-rate
level and add the bounded sum-zero log-slope residual

```text
sin(t) * (-0.25, 0.5, -0.25).
```

Along sequences where `sin(t)` tends to `+1` and `-1`, the zero-rate slope
tends to `exp(0.5)` and `exp(-0.5)`, respectively. The two likelihood limits
are

```text
-1.305035438593109
-1.709749207648044
```

and differ by `0.4047137690549349`. Thus an `O(1)` residual is not sufficient;
requiring the residual itself to vanish is essential for a common transported
boundary. This also shows why leading-rate convergence alone does not complete
the curved-path problem: zero leading-rate coordinates can contain a secondary
asymptotic hierarchy.

## Verification

Six focused files pass 429 expectations with zero failures, skips, warnings,
or errors:

| Test surface | Expectations |
| --- | ---: |
| P1y asymptotically-affine transport | 60 |
| P1x general constant-rate boundary | 54 |
| JML GPCM joint boundary | 74 |
| P1v/v2 fixed-objective classifier | 60 |
| P1w terminal-gradient stability | 83 |
| JML GPCM slope-only boundary | 98 |

Nine additional release/readiness/scope/documentation guard files pass 1,077
expectations with zero failures or errors. Three expected skips remain: two
require the uninstalled optional `diffobj` package and one is the separately
opt-in P1p stored-result pilot. The checklist remains 106 rows; the joint
boundary row remains `review` with `pilot_required` criteria. The existing
local `testthat` R-version build warning is unchanged.

## FACETS and claim consequence

P1y changes no FACETS role. FACETS PCM/JMLE versus mfrmr PCM/JML remains the
only possible future direct common-estimand FACETS lane. Non-unit GPCM/JML
remains truth-first, FACETS PCM remains a deliberately misspecified control,
and FACETS Table 7 discrimination remains diagnostic-only. No external run,
tolerance, recovery rule, broad simulation, inference promotion, or
confirmation is authorized.

## Machine-readable disposition

```text
AsymptoticallyAffineTransportImplemented = TRUE
TransportContract = mfrmr-jml-gpcm-asymptotically-affine-transport-0.2.3-v1
SlopeOnlySourceSupported = TRUE
OrderedPairSourceSupported = TRUE
CanonicalConstantRateSourceSupported = TRUE
VanishingAdditiveResidualRequired = TRUE
VanishingSumZeroLogSlopeResidualRequired = TRUE
SameBoundaryLimitCertifiedForTransportedPaths = TRUE
BoundedNonvanishingResidualClassified = FALSE
RateNonconvergentPathClassified = FALSE
GeneralCurvedPathClassified = FALSE
CurvedPathAbsenceCertified = FALSE
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
| `R/core-jml-gpcm-asymptotically-affine-transport.R` | `a83ec8d08fa33efa1c9ff0318a2c57971049fe217a289e6902823375b95e0b59` |
| `R/core-jml-gpcm-joint-boundary.R` | `e1d2b7bb3cfb9e00789dcfa7d6cbb87c8de61adb65b59d533651e446d1660dcd` |
| `R/core-jml-gpcm-boundary-classification.R` | `fc28b5b61e366d127a24aacf2d408240e577fcb67cfc0ea903a55d8a67bf5997` |
| `R/core-jml-gpcm-terminal-gradient.R` | `9ab72ae7e2524b9a29ae4505f3275238f9f1532d5c947fc59db25c2cf519a88e` |
| `R/mfrm_core.R` | `c54302de50ea7048b3959aa700b9a91f3485975597f8b6a8be70293ddf1fd76f` |
| `R/api-estimation.R` | `eaaaaa805df19d0b39564d5f05f1b66a440a4228ca934af7db9aa57c31507e86` |
| `man/fit_mfrm.Rd` | `f2ba74fca78850897d343daa84f39e1388406b8bcf6684dfd3e85c043993f420` |
| `tests/testthat/test-jml-gpcm-asymptotically-affine-transport.R` | `b6acfc7751eeb4bdfd1bfc6433f4e91848fb3d02db09f5b45a247c48fff40ce1` |
| `tests/testthat/test-jml-gpcm-general-rate-boundary.R` | `7570ad5f6a85057875a7b7ad8d24c199a00eeabc877d97391c8188a4aa6f28d4` |
| `tests/testthat/test-jml-gpcm-joint-boundary.R` | `8b61e97eef9216d58bd0698bdcc348fe535e124e4a2c821bed8aa9ee84dd5ebb` |
| `tests/testthat/test-jml-gpcm-fixed-objective-boundary-classification.R` | `f8067ca7ea1794decbc7362b147f8a4c932a8607d7be17b77dc01c2cd675cdaf` |
| `tests/testthat/test-jml-gpcm-terminal-gradient-stability.R` | `d0199bcf388bbf114d6ecb329a683d39dfe739945de855710f691c68060f67e4` |
| `tests/testthat/test-jml-gpcm-slope-boundary.R` | `2c9bd9306e806c55a64788c607428476d6756fc5d50e96d36cdeb2ec7c7f03ff` |
| `NEWS.md` | `b1aee634f86ae599e4eea02b22e19bbbf0be5af86069769be592f32aa7e69d5c` |
| `ROADMAP.md` | `71c11b7810a41787abf67701a4fa4e3424ff4b75139ca6e9ad63b0e7a962aeaf` |
| `inst/validation/README.md` | `c9cc2f77097a3a680c8159560722eb4ac2f79de9fb916facbf07707465eec002` |
| `inst/validation/release-evidence-checklist-0.2.3.csv` | `4e307852e8e9402c0306951cc721a8dfffcba3876b2e103e9de86c3a5c55db40` |
