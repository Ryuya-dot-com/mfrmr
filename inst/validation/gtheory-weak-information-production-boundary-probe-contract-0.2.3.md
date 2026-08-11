# Draft.83d2b2b1g12 production boundary-probe contract

Status: completed repository-only mechanics slice, 2026-08-10. This contract
implements the lower-cost boundary probe that a future calibration runner may
compare with the frozen high-accuracy references. It does not open reserved
replicate 201, select a stationarity rule, or authorize calibration,
confirmation, inference, coefficients, or D-study decisions.

## Mathematical contract

Let (Q(\eta,t)) denote the backend-native objective to be minimized, where
(t) is the target variance-component coordinate and (\eta) contains every
remaining outer parameter. The retained profile is not
(Q(\widehat\eta, t)). At every registered point it approximates

\[
  q(t)=\inf_{\eta} Q(\eta,t)
\]

by reoptimizing (\eta), warm-started from the preceding point. This prevents
a frozen nuisance estimate from manufacturing an apparent boundary direction.

The two backends do not share a literal boundary coordinate:

- lme4 uses nonnegative relative-standard-deviation coordinates
  (t=\theta=\sigma_b/\sigma_e\), so the boundary is the finite point
  (\theta=0);
- glmmTMB uses an unconstrained log-standard-deviation coordinate
  (t=\lambda=\log\sigma_b), so zero variance is the nonfinite limit
  (\lambda\to-\infty).

The lme4 grid retains fractions
`1, .75, .5, .25, .1, .025, 0`. The glmmTMB grid retains log-SD offsets
`0, 4, 8, 12, 16, 20`. These coordinate-specific paths are mapped to a common
scientific boundary only through the separately fitted reduced-model
objective. The final full-model profile point must agree with that objective
within the binary64-derived relative tolerance
(2^8\epsilon^{2/3}). A full/reduced mismatch can never be classified as
boundary support.

## State rule

All objectives use the backend's native minimization scale. Raw objective
values are not pooled or compared between backends or between likelihood
modes.

| Probe state | Required evidence | Application route |
| --- | --- | --- |
| `boundary_limit_supported` | every nuisance optimization converged, the terminal objective matched the reduced fit, and the profile improved monotonically and materially toward the boundary; an already-active starting point must also match the reduced fit | `boundary_handoff` |
| `finite_interior_supported` | every nuisance optimization converged, the terminal objective matched the reduced fit, and the profile worsened monotonically and materially toward the boundary | `continue_first_order_curvature` |
| `boundary_probe_inconclusive` | a finite profile was flat, nonmonotone, directionally immaterial, or failed the reduced-endpoint identity | `indeterminate` |
| `not_evaluable` | any required point failed to return a finite, converged nuisance optimum | `not_evaluable` |
| `not_applicable` | the reduced model has no target component | `not_applicable` |

Small target gradients, Hessian warnings, singular-fit messages, and optimizer
messages are not sufficient boundary evidence. In particular,
`FirstOrderBoundarySufficiencyClaim=FALSE`. Statistical nonregularity and the
future bootstrap operating-characteristic contract remain separate from this
numerical routing rule.

## Solver and failure accounting

The production path intentionally costs less than the multistart,
multialgorithm high-accuracy reference. Each nuisance problem first uses one
warm-started box-constrained L-BFGS-B fit. If it returns finite parameters but
an unsuccessful code, exactly one same-point `nlminb` restart is permitted.
The probe records `SolverId`, optimizer code, message, objective, target value,
and parameter hash for every point. Neither a finite objective nor apparent
arrival at an optimum overrides a nonzero final solver code.

This fallback is part of the frozen candidate mechanics, not an adaptive
post-result repair. An initial nonfinite objective or thrown error fails
closed without trying to reinterpret the point.

## Verification

Seven analytic controls recover finite-interior, boundary-limit,
already-active boundary, flat, endpoint-mismatch, and non-evaluable states.
The real Gaussian fixture also checks all four backend-likelihood lanes:

| Lane | Result | Full/reduced endpoint absolute difference |
| --- | --- | ---: |
| lme4 ML | `finite_interior_supported` | `1.9895e-13` |
| lme4 REML | `finite_interior_supported` | `2.7001e-13` |
| glmmTMB ML | `finite_interior_supported` | `4.5701e-10` |
| glmmTMB REML | `finite_interior_supported` | `6.5340e-09` |

The lme4 REML first profile point exercised the registered one-restart
fallback; all other reported points used the primary solver. No generating
variance, candidate cutoff, calibration response, or high-accuracy reference
label entered any application decision.

## Readiness boundary

`ProductionBoundaryProbeReady=TRUE` is narrow. It coexists with
`RunnerImplementationReady=FALSE`, `CalibrationAuthorizationReady=FALSE`,
`CalibrationExecutionAuthorized=FALSE`, `StationarityThresholdFrozen=FALSE`,
and `StationarityCriterionReady=FALSE`.

The next admissible slice is the exact-resume atomic runner. It must bind this
probe, all 24 b1g11 candidates, the four high-accuracy reference lanes, every
failed-profile state, the sealed 201--300 manifest, and the already corrected
108,000-candidate / 24,000-reference denominator identities before opening any
reserved response.

## Sources

- Bates, D., Maechler, M., Bolker, B., and Walker, S. (2015). Fitting linear
  mixed-effects models using lme4. *Journal of Statistical Software*, 67(1),
  1--48. https://doi.org/10.18637/jss.v067.i01
- lme4 `lmer` documentation:
  https://lme4.github.io/lme4/reference/lmer.html
- lme4 `isSingular` documentation:
  https://lme4.github.io/lme4/reference/isSingular.html
- glmmTMB troubleshooting documentation:
  https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html
- glmmTMB `diagnose` documentation:
  https://glmmtmb.github.io/glmmTMB/reference/diagnose.html
- Self, S. G., and Liang, K.-Y. (1987). Asymptotic properties of maximum
  likelihood estimators and likelihood ratio tests under nonstandard
  conditions. *Journal of the American Statistical Association*, 82,
  605--610. https://doi.org/10.1080/01621459.1987.10478472
