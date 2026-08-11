# Draft.83d2b2b1g8 glmmTMB ML reference-coverage contract

Status: completed repository-only nonreserved replay contract, 2026-08-10.
This contract opens only glmmTMB ML on nonreserved replicates 901 and 902. It
does not modify b1g6, open calibration 201--300 or confirmation 501--700,
select a stationarity rule, or authorize inference.

## Likelihood identity

The official `glmmTMB()` interface defines `REML=FALSE` as maximum-likelihood
estimation and `REML=TRUE` as restricted maximum likelihood. b1g8 therefore
binds all of the following into the contract, manifest, atomic rows, and
sidecars:

- `Backend="glmmTMB"`;
- `MethodId="glmmTMB_ml"`;
- `Likelihood="ML"`; and
- `GlmmTMBREMLArgument=FALSE`.

The audited surface is the glmmTMB/TMB Laplace marginal negative-log-
likelihood objective produced under `REML=FALSE`. It is not the b1g6 REML
objective with a relabelled method field. ML and REML absolute objective values
are not compared to select an estimator.

## Frozen high-accuracy mechanics

b1g8 reuses, by exact function hash, the b1g6 tolerance policy, deterministic
three-algorithm/nine-run solver ladder, anchored TMB random-effect start,
AD-independent central-difference interval, numerical-Hessian audit, damped
Newton polishing, curvature classification, target-theta mapping, and
nuisance-reoptimized boundary profile. No b1g6 function or tolerance is
changed.

The derivative interval remains selected from adjacent finite-difference
stability without consulting the AD gradient. The componentwise tolerance
therefore adapts to the numerical resolution of the ML objective rather than
copying a viewed REML discrepancy. Generating variance and b1g4 diagnostic
magnitudes cannot label stationarity or alter a cutoff.

## Nonreserved manifest

The same generated datasets used by b1g6 are retained so likelihood mode is
the intended change:

| Scenario | Replicate | Method | Model roles |
| --- | ---: | --- | --- |
| exact-zero Rater variance | 901 | glmmTMB ML | full, reduced |
| Rater variance 0.12 | 902 | glmmTMB ML | full, reduced |

The two datasets produce four objectives and 36 planned solver runs. Their
generator hashes must equal the paired b1g6 REML replay. ML and REML polished
objectives must remain numerically distinct, demonstrating that the method
field is not cosmetic.

## Boundary and readiness gates

Every full-model boundary profile contains six prespecified target log-SD
offsets. At every point, nuisance coordinates are reoptimized and must pass
their stationarity and curvature checks. A full-model result is acceptable
only as `finite_interior_supported` or `boundary_limit_supported`; an
unavailable or reduced-model-unmatched boundary profile blocks ML replay
readiness.

`NonreservedMLReplayReady=TRUE` requires exact four-row accounting, returned
fits, three-algorithm consensus, derivative agreement, resolved reference
state, acceptable boundary state, explicit ML identity, and content-addressed
sidecars. Passing raises reference-method coverage from one to two of four
lanes:

| Method lane | State after passing b1g8 |
| --- | --- |
| glmmTMB ML | b1g8 nonreserved pass |
| glmmTMB REML | b1g6 nonreserved pass |
| lme4 ML | reference mechanics not implemented |
| lme4 REML | reference mechanics not implemented |

Consequently `GlmmTMBMethodCoverageReady` may be true while
`ReferenceMethodCoverageComplete`, `CalibrationAuthorizationReady`,
`CalibrationExecutionAuthorized`, stationarity, confirmation, inference,
coefficient, and decision readiness remain false.

## Sources

- glmmTMB model-fitting reference:
  https://glmmtmb.github.io/glmmTMB/reference/glmmTMB.html
- glmmTMB optimizer/control reference:
  https://glmmtmb.github.io/glmmTMB/reference/glmmTMBControl.html
- glmmTMB troubleshooting guidance:
  https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html
- Kristensen, K., Nielsen, A., Berg, C. W., Skaug, H., and Bell, B. M.
  (2016). TMB: Automatic differentiation and Laplace approximation. *Journal
  of Statistical Software*, 70(5). https://doi.org/10.18637/jss.v070.i05
- Moré, J. J., and Wild, S. M. (2012). Estimating derivatives of noisy
  simulations. *ACM Transactions on Mathematical Software*, 38(3).
  https://doi.org/10.1145/2168773.2168777
- Shi, H.-J. M., Xie, Y., Xuan, M. Q., and Nocedal, J. (2022). Adaptive
  finite-difference interval estimation for noisy derivative-free
  optimization. *SIAM Journal on Scientific Computing*, 44(4), A2302--A2321.
  https://doi.org/10.1137/21M1452470
