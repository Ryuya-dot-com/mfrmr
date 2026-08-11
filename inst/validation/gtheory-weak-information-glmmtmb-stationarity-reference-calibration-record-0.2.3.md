# Draft.83d2b2b1g6 stationarity-reference calibration record

Status: completed repository-only analytic calibration and nonreserved replay,
2026-08-10. This record does not authorize calibration replicate 201--300,
the full stabilization manifest, bootstrap operating-characteristic work,
inference, a G/Phi coefficient, or a D-study decision.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| b1g5 upstream design | `278353d1668501d04dd3af4adc96dfcd39b232796057242418f89601b22b99ac` |
| b1g5 upstream manifest | `0dbe9e92bed7baa27b6c5f29bed0759a789bcc02c285bd77d749a9cc9666e4d0` |
| b1g6 reference contract | `60e04706736c0e7273dfa321d0d41a3a9ed4bb8362a0b7d428f8507653ecce9a` |
| b1g6 nonreserved manifest | `87b42667d3dbeb2ecd045b23b32cf23a5f9919b0d26ac75c5771baf691770d3a` |
| b1g6 execution | `28f155c91065cb56ebe695234eab7867392e25fe413ab362717e760f5e775e72` |

The retained replay is
`/private/tmp/mfrmr-gtwta-reference-replay-v4.rds`. It is a local validation
cache, not a package artifact or release result. The execution environment was
R 4.6.1, glmmTMB 1.1.14, TMB 1.9.23, and numDeriv 2016.8-1.1.

## Numerical-method correction made before replay

The first diagnostic replay made all four objectives agree across nlminb,
BFGS, and Nelder--Mead, but ordinary numDeriv Richardson gradients disagreed
with TMB AD gradients by about `1.9e-6` to `1.17e-5`. The discrepancy was not
silently accepted and no threshold was selected from it.

A subsequent diagnostic step ladder showed a roundoff/truncation error valley near
`1.2e-5` to `2.4e-5`. The original fixed
`2^12 epsilon^(2/3) = 1.501943e-7` comparison omitted the scale of a composed
Laplace objective near 2,200 and therefore understated subtraction error.
The corrected contract:

- evaluates a symmetric central-difference ladder at
  `epsilon^(1/3) * 2^(-4:8)` times each parameter scale;
- chooses an interior step using only stability between adjacent
  finite-difference gradients, never the AD gradient;
- constructs a componentwise resolution envelope from both neighboring-step
  changes and `2 epsilon max(1, |f|) / h` roundoff;
- compares AD and the selected finite difference using the larger of the
  binary64 floor and four times that independently estimated resolution;
- preserves ordinary numDeriv Richardson output as a supplemental diagnostic,
  not the pass gate;
- requires numerical Hessian symmetry; and
- resets TMB's `last.par.best` random-effect starting state before every
  objective and gradient evaluation, removing evaluation-order dependence
  induced by the default warm start; and
- binds the actual inner method (`newton`), inner control (`maxit=1000`,
  `trace=FALSE`), and `expression(last.par.best[random])` start expression in
  every content-addressed sidecar.

This follows the distinction between automatic derivatives of a Laplace
objective and finite differences of a numerically evaluated composed
objective. It also follows the computational-noise principle that a useful
difference interval must balance cancellation/noise against truncation rather
than tend mechanically to zero. See Kristensen et al. (2016), Moré and Wild
(2012), and Shi et al. (2022).

An adversarial regression replaces one correct analytic gradient component by
an error of `1e-3`. Its independently selected finite-difference step and
finite-difference table remain bitwise unchanged, while derivative agreement
correctly fails. Thus the AD result cannot tune its own audit.

## Analytic calibration

All six fixed analytic objectives pass derivative and state recovery:

- correlated positive-definite quadratic: `finite_local_minimum`;
- twelve-order ill-conditioned quadratic: `finite_stationary_flat` under the
  frozen numerical curvature resolution, despite mathematical positive
  definiteness;
- flat quartic: `finite_stationary_flat`;
- saddle: `finite_saddle_or_max`;
- Rosenbrock: `finite_local_minimum`; and
- softplus log-SD escape: `boundary_limit`.

The ill-conditioned fixture deliberately distinguishes a mathematical fact
from what binary64 curvature can resolve. No analytic fixture contributes a
mixed-model operating characteristic.

## Nonreserved replay result

Only baseline-complete replicates 901 and 902 were generated. They do not
overlap schema 2--3, feasibility 101--125, calibration 201--300, or
confirmation 501--700.

| Scenario | Role | Reference state | Objective | max raw gradient | Newton decrement | selected step exponent | max AD/FD tolerance ratio |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| exact zero, R0901 | full | finite local minimum | 2250.4217 | 1.5624e-4 | 3.6337e-6 | 2 | 0.1857 |
| exact zero, R0901 | reduced | finite local minimum | 2251.6042 | 1.9631e-5 | 5.0953e-7 | 2 | 0.2394 |
| variance 0.12, R0902 | full | finite local minimum | 2211.8726 | 4.0677e-6 | 9.0250e-7 | 1 | 0.2379 |
| variance 0.12, R0902 | reduced | finite local minimum | 2213.0866 | 6.3099e-5 | 1.4626e-6 | 2 | 0.3307 |

All four objectives pass three-algorithm objective consensus, componentwise
AD/finite-difference agreement, numerical Hessian symmetry, positive-definite
curvature, and content-addressed sidecar validation. Raw gradient and Newton
decrement remain separate: a raw gradient larger than the reference stop is
not silently rewritten when the curvature-scaled Newton decrement resolves
the local state.

Both full-model boundary profiles move to worse objectives as Rater log-SD is
reduced, so they support a finite interior rather than a boundary limit. Each
of the twelve fixed-log-SD profile points is nuisance-reoptimized by nlminb and
damped Newton polishing; all have positive-definite free-coordinate curvature
and pass the frozen free-coordinate stationarity rule. Boundary truth is not
inferred from the generating zero variance.

## Gate interpretation

`NonreservedReplayReady=TRUE` and `ReferenceToleranceFrozen=TRUE` now mean
only that the intensive reference mechanics have passed their analytic and
nonreserved controls. The following remain false:

- `StationarityThresholdFrozen` and `StationarityCriterionReady`;
- `CalibrationExecutionAuthorized`, `CalibrationDataGenerated`, and
  `CalibrationResultsViewed`;
- `FullExecutionAuthorized`;
- `BootstrapOperatingCharacteristicsReady`;
- `InferenceReady`, `CoefficientEligible`, and `DecisionReady`.

The next admissible slice is a new immutable authorization that opens only the
reserved 201--300 calibration band, applies the b1g5 candidate families to the
b1g6 high-accuracy reference states, and freezes false-ready, false-unready,
and indeterminate behavior without using confirmation replicates 501--700.

## Sources

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
- Nash, J. C. (2014). On best practice optimization methods in R. *Journal of
  Statistical Software*, 60(2). https://doi.org/10.18637/jss.v060.i02
- TMB model-object documentation:
  https://kaskr.github.io/adcomp/ModelObject.html
- numDeriv manual:
  https://cran.r-project.org/web/packages/numDeriv/numDeriv.pdf
