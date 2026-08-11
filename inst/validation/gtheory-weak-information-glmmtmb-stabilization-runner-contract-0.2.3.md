# Draft.83d2b2b1g1 glmmTMB stabilization runner and smoke contract

Status: repository-only runner implementation and viewed-data covering-smoke
authorization, 2026-08-10. Full 18,000-fit execution remains unauthorized.

## Corrected upstream identity

This runner accepts only corrected Draft.83d2b2b1g contract
`8feb8695c655c0621d61863e00d82fffe7fd5d7b619761decefaed6e89b0c326`
and manifest
`92435f41b0dab7e13bf1febcf6e043fc1ae8d4a2cb7d159401dd1d78b4c9ff3e`.
The correction snapshots the complete post-fit TMB state and calls
`parList(x=fit$fit$par, par=joint_best)`; a bare or single-argument
`parList()` call is prohibited.

## Outcome-independent covering smoke

The smoke is selected only by manifest factors:

- all five registered `DesignId` values;
- `VarianceId` equal to `exact_zero` or `reference_1200`;
- replicate 101;
- both ML and REML; and
- all six frozen stabilization profiles.

This gives 10 datasets, 20 base routes, 120 full/reduced pairs, and 240 fits.
No b1e likelihood value, convergence result, gradient, Hessian, boundary state,
or optimizer comparison enters selection. The other 8,880 pairs remain in the
full manifest but are not authorized by this contract.

## Atomic unit and dependency semantics

One base route—one dataset, likelihood identity, and method across all six
profiles—is the atomic checkpoint. Both cold roots and all four children are
computed together. An interruption before completion discards/recomputes that
base route; a valid six-row checkpoint can be reused without storing fit
objects.

Cold roots are evaluated before children. A child receives only the parent's
immediate post-fit start snapshot for the same model role. The parent final
signature hash and child input signature hash must be identical. If either
parent full or reduced fit/start is unavailable, only the corresponding child
model fails; the paired row remains present and is classified without cold
fallback.

Each dataset marker binds the two ML/REML base-route checkpoint hashes. Final
accounting requires 20 valid base-route checkpoints, 10 valid dataset markers,
120 unique pair rows, six rows per base route, and 12 rows per dataset.

## Derivative and fit record

Immediately after each returned fit, before any derivative re-evaluation, the
runner records:

1. `last.par.best` joint-state hash;
2. exact equality of its fixed coordinates and `fit$fit$par`;
3. canonical ten-block start signature and top-level parameter hash; and
4. the final start values in memory only for dependent fits.

It then records optimizer code/objective/log likelihood, outer and sdreport
gradient summaries, `pdHess`, inverse-covariance curvature, and the frozen
Richardson Jacobian/eigenspectrum. Raw Jacobians, gradients, start values, and
fit objects are represented by hashes/summary scalars in checkpoints; timing
is excluded from the scientific execution hash.

The mutually exclusive row state is the first applicable of:

1. `generation_or_prefit_failure`;
2. `parent_fit_or_start_unavailable`;
3. `full_and_reduced_fit_failure`;
4. `full_fit_failure`;
5. `reduced_fit_failure`;
6. `nonfinite_objective_or_likelihood`;
7. `optimizer_nonzero`;
8. `gradient_unavailable`;
9. `hessian_unavailable`;
10. `nonpositive_hessian`;
11. `likelihood_identity_failure`;
12. `finite_material_negative_drop`; or
13. `returned_diagnostic_complete`.

`returned_diagnostic_complete` does not mean numerically adequate: no gradient,
Hessian, or objective-change cutoff exists yet.

## Authorization and non-claims

This contract sets `SmokeExecutionAuthorized=TRUE` and
`FullExecutionAuthorized=FALSE`. It prohibits early stopping, adaptive
fallback, calibration generation, threshold selection, bootstrap, inference,
and D-study decisions.

Even a complete smoke can establish only runner mechanics, dependency
accounting, checkpoint/restart behavior, and empirical runtime feasibility.
It cannot set `NumericalStabilizationReady` or
`NumericalSensitivityEvidenceReady`, select an optimizer/start rule, or
authorize the remaining 18,000-fit full-manifest run.
