# Draft.83d2b1 atomic G-theory ADEMP fit contract

Status: repository-only point-fit execution contract with retained concern,
2026-08-09.

Draft.83d2b1 binds every one of the 89 Draft.83d1 manifest units to exactly one
atomic success or typed failure record. It executes no backend for the 12
Draft.83d2b0 pre-fit-blocked units and attempts the remaining 77 units through
their registered balanced MoM, lme4 ML/REML, or glmmTMB ML/REML adapter.

This is a one-replicate software and failure-accounting smoke. It does not
compute bias, RMSE, effect recovery, G/Phi recovery, rank recovery, separation,
coverage, or a method-selection conclusion.

## Method identity

Every fit binds:

- registry, generator, retained-data, incidence, structural-rank, pre-fit,
  scenario, replicate, method, and backend identity;
- exact typed formula and retained rows;
- ML versus REML, Gaussian identity link, random-intercept covariance family,
  backend version, and backend control identity;
- component estimates in semantic EffectMap order;
- optimizer/computational completion, finite-component, boundary, singularity,
  and local-curvature states; and
- a deterministic point-result and atomic-row hash. Runtime is recorded but is
  excluded from the result identity.

The current scope remains independent scalar random intercepts. It does not
cover random slopes, correlated or heterogeneous residuals, multivariate
component covariance, or latent GPCM/GT-IRT likelihoods.

## Scalable adapter boundary

The older Draft.83c1/c2 helpers first materialize the dense covariance-
derivative design. Draft.83d2b1 instead fits directly on the exact
Draft.83d2b0 retained rows after scalable structural rank has passed. This
allows the 19,200-row N=300 cell to be fitted without treating dense-audit
capacity as a statistical failure.

The local likelihood information recorded here is deliberately narrower than
Draft.83c1 expected information:

- lme4 uses the positive/full-rank Hessian for its profiled random-effect
  `theta` coordinates plus a positive finite residual variance;
- glmmTMB uses the positive/full-rank inverse of `sdr$cov.fixed`, covering its
  joint fixed parameterization; and
- balanced MoM is a nonlikelihood expected-mean-square inversion, so optimizer
  and likelihood-curvature concepts are not applicable.

These are backend-local regularity diagnostics. They are not asserted to equal
the full variance-component expected-information matrix. The execution row
therefore records
`backend_*_curvature_not_full_expected_information`. A later scalable
information-operator proof remains necessary before a general likelihood-
information claim.

## MoM computational convention

For the single registered balanced-MoM unit, `OptimizerConverged=TRUE` means
that the deterministic orthogonal expected-mean-square inversion completed;
it does not imply that an iterative optimizer exists. A finite identified raw
component vector passes the point-computation gate. Negative raw components
remain valid unconstrained MoM output and are not silently clipped, but no
coefficient or interval may be formed from this slice.

## Atomic stage and failure rules

The Draft.83d1 monotone stage order is enforced exactly. Each recorded row has
one of:

```text
EstimationGatePassed = TRUE
FailureStage         = none
FailureCode          = none
```

or a failed gate with a nonempty typed stage/code. The typed stages are:

| Stage | Meaning |
| --- | --- |
| `pre_fit` | Draft.83d2b0 prohibits a backend call |
| `backend_fit` | dependency, call, or post-call extraction failed |
| `optimizer` | optimizer or required backend Hessian completion failed |
| `component_extraction` | semantic component vector is incomplete/nonfinite |
| `regularity` | boundary tolerance or lme4 singularity was reached |
| `local_curvature` | the registered backend-local curvature was unavailable, nonpositive, or rank deficient |

Raw condition messages are not placed in the flat ledger; their digest is
stored for identity and privacy-safe comparison. An unrecognized method fails
as a typed backend call failure. An identity mismatch stops the execution
rather than recording a result against the wrong dataset.

## Point-gate rule

For lme4 and glmmTMB, a point fit passes only when all of the following hold:

1. the pre-fit structural gate passed;
2. a backend fit returned;
3. the optimizer/backend Hessian completion state passed;
4. the complete semantic component vector is finite;
5. no component reaches the declared `1e-8` boundary tolerance;
6. lme4 is not singular at `1e-4`; and
7. the registered local-curvature matrix is positive and full rank at the
   declared `1e-8` rank tolerance.

This is not inference readiness. In particular, it has no calibrated weak-
information, component-relative uncertainty, or near-boundary stability rule.

## Frozen execution outcome and retained concern

The current environment records:

| Quantity | Result |
| --- | ---: |
| planned atomic rows | 89 |
| pre-fit-blocked, not attempted | 12 |
| fit attempts | 77 |
| fits returned | 77 |
| point gates passed | 57 |
| typed failures | 32 |
| exact atomic accounting | passed |
| zero false-ready gate | **failed** |

The exact-zero boundary, disconnected, and aliased controls produce zero
passed point gates. However all four ML/REML x backend routes in
`GT-BOUNDARY-NEARZERO` pass the current point gate. Their fitted Rater
variances are approximately 0.0039--0.0052 despite the nominal generating
variance `1e-10`; optimizer, finite-vector, local-curvature, and current
boundary checks alone cannot identify that one-replicate weak component.

This is a substantive negative-control result, not an implementation success
to be relabelled. The runner retains `ZeroFalseReadyPassed=FALSE`. The package
must not introduce a truth-aware special case or enlarge the numerical
boundary tolerance after seeing this result. A subsequent pre-registered
weak-information calibration must use observable fit quantities, include
positive small-but-estimable controls, and evaluate sensitivity/specificity
before it can alter the point gate.

## Readiness boundary

Atomic completion means only that every planned unit is visible as success or
typed failure. `RecoveryEvidenceReady`, `InferenceReady`,
`CoefficientEligible`, and `DecisionReady` remain false. The failed
near-boundary negative control blocks Draft.83d2 recovery promotion. Draft.84
still owns full-refit intervals, and multivariate Draft.85 remains downstream
of the univariate recovery and uncertainty gates.
