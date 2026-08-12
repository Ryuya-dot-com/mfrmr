# ConQuest reported-point common-likelihood calibration for mfrmr 0.2.3

Status: opened additive calibration evaluated on a common likelihood,
2026-08-12. This calibration does not select a self-passing tolerance. A
successor contract freezes a disjoint-future-candidate table; no candidate is
bound, no equivalence is inferred, and no external run or confirmation is
authorized.

## Why this slice is necessary

The maximum coordinate difference is not, by itself, a principled tolerance.
It mixes parameter scale, local curvature, optimizer termination, quadrature,
and the exact decimals written by ConQuest. Before using the opened RSM/PCM
calibration to inform a future-only engineering budget, the reported point must
be evaluated on one independently implemented likelihood.

The calibration first revalidates the source-bound four-arm review and compares
all four retained wide inputs cell-for-cell with the deterministic fixture. It
then reconstructs each sum-zero Rater, Criterion, and step vector from the
exact ConQuest decimal tokens. Population variance is evaluated on a
log-variance free coordinate. It then computes the same q31 or q61 marginal
deviance used by the source-bound mfrmr oracle, Richardson gradients and
Hessians, and q31/q61 deviances at one identical reported coordinate vector.

## Four-arm result

| Arm | Common deviance increase at reported point | Reported gradient sup norm | mfrmr gradient sup norm | Hessian minimum eigenvalue | Curvature distance |
| --- | ---: | ---: | ---: | ---: | ---: |
| RSM q31 | `4.744152e-10` | `8.973471e-5` | `9.952980e-6` | `10.154189` | `3.084015e-5` |
| RSM q61 | `4.740741e-10` | `8.973474e-5` | `1.001269e-5` | `10.154189` | `3.084016e-5` |
| PCM q31 | `3.088871e-10` | `8.236592e-5` | `2.581763e-6` | `9.678776` | `2.504020e-5` |
| PCM q61 | `3.087735e-10` | `8.247964e-5` | `2.611953e-6` | `9.678776` | `2.504023e-5` |

All eight reported/reference Hessians are positive definite. Reported-point
condition numbers are below `55.19`; reported Newton decrements are below
`3.09e-5`. The exact ConQuest deviance tokens differ from common deviance at
the reconstructed reported coordinates by about `2.22e-7` for RSM and
`4.31e-7` for PCM. This is compatible with a six-decimal export, but it does
not establish a file rounding rule or recover the hidden optimizer solution.

The observed coordinate differences up to about `2.74e-6` therefore do not
represent a materially different likelihood optimum in this calibration. That
is descriptive scale evidence for a future candidate, not a threshold and not
a general result about sparse, extreme, or GPCM designs.

## Same-point integration result

The q31 and q61 exact reported parameter tokens are identical within model.
When that single coordinate vector is evaluated on both quadrature grids, the
absolute deviance differences are:

| Model | Same-point q31/q61 absolute deviance difference |
| --- | ---: |
| RSM | `2.387424e-12` |
| PCM | `2.728484e-12` |

This removes optimizer-point drift from the integration diagnostic. It remains
one opened, same-platform calibration and does not freeze
`IC-INTEGRATION-TOL`.

## Big-picture correction: the next core has six arms

The prospective registry contains Binary, RSM, and PCM estimands, with q31 and
q61 integration rows for both ConQuest and mfrmr. A complete clean candidate
therefore requires exactly six family-by-node arms, not only the four additive
RSM/PCM arms:

`Binary/RSM/PCM x q31/q61`.

The prospective binding now rejects a four-arm `RSM;PCM` declaration. It
requires all three families in the candidate, source-precision coverage, and
normalizer coverage before a run can be structurally authorized. The later
Binary contract now supplies the missing 18 pre-result rows, bringing the
canonical implementation registry to 54 coordinates. Binary native q31/q61
outputs are still absent, so implementation coverage must not be read as
result coverage.

## What is and is not ready

| Question | Disposition |
| --- | --- |
| Exact reported-decimal reconstruction | ready for the 36 additive rows |
| Common-likelihood evaluation mechanics | ready for the 4 additive arms |
| Additive same-point integration scale | calibration observed |
| Binary reported-output normalizer | implemented for 18 pre-result rows |
| Binary retained native q31/q61 evidence | missing |
| 57 prospective tolerance values | frozen later for a disjoint candidate only |
| Clean six-arm candidate identity | not bound |
| Hidden ConQuest solution equivalence | unavailable |
| DFF, fit, or ranking decision invariance | not evaluated by this microcase |

The next action is not a large simulation. The estimand-level bounds and exact
six-arm candidate are now bound. Execution remains held until the historical
polytomous reference-generator requirement is reconciled with current v3
`review` readiness without promoting local rank to global identification.
Binary q31/q61 native outputs must be retained if that core is later run.

## Source binding and verification

| Artifact | SHA-256 |
| --- | --- |
| `conquest-reported-point-likelihood-calibration-0.2.3.R` | `738c2059631cae0c4c549621a55a57df8b233f9e131f1fc57cd4c9a7e3393ab8` |
| `test-conquest-reported-point-likelihood-calibration.R` | `c15ef07b34f11c86d95f611b6b5e7934cefd40be8562d8032d453397fe3e63b8` |
| Reported-output row content | `ecd3fd026e43c44d072b4975c5ea5d323ea3f53eef83ebc2ea41e2cb55de852d` |

The focused calibration test completes with 42 expectations, zero failures,
zero errors, zero skips, and zero warnings. Mutation controls reject q31/q61
token drift, input/review detachment, and any hidden-solution promotion. The
complete ConQuest-labelled slice completes with 729 expectations and no
failures, errors, skips, or warnings. A clean source tarball with built
vignettes passes `R CMD check --no-manual` with `Status: OK`.

## Machine disposition

| Field | Value |
| --- | --- |
| `OpenedCalibrationCommonLikelihoodReady` | `TRUE` |
| `SourceBoundReviewVerified` | `TRUE` |
| `DeterministicInputIdentityVerified` | `TRUE` |
| `ReportedPointHessiansPositiveDefinite` | `TRUE` |
| `SamePointIntegrationEvaluated` | `TRUE` |
| `CandidateFamiliesRequired` | `Binary;RSM;PCM` |
| `CandidateNodesRequired` | `31;61` |
| `CandidateArmsRequired` | `6` |
| `CalibrationEligibleUnderSuccessorTolerance` | `FALSE` |
| `FutureCandidateToleranceFrozen` | `TRUE` |
| `SuccessorCandidateBound` | `TRUE` |
| `CandidateExecutionAuthorized` | `FALSE` |
| `ComparisonReady` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
