# Draft.83d2b2b1g2 deterministic glmmTMB fixed-coordinate alignment contract

Status: repository-only corrective covering-smoke contract, 2026-08-10. The
full 18,000-fit stabilization manifest, calibration, threshold selection,
bootstrap, inference, and D-study decisions remain unauthorized.

## Upstream negative result

Draft.83d2b2b1g1 completed all 20 base-route checkpoints and all 10 dataset
markers, but two returned BFGS fit objects could not be snapshotted under its
strict contract. Their `last.par.best[lfixed()]` values were not bitwise
identical to `fit$fit$par`. This led to one full start-snapshot failure, one
reduced start-snapshot failure, and two dependent child full fits classified
as parent unavailable.

The observed maximum difference is evidence about b1g1, not an alignment
tolerance. It must not determine this contract, a convergence threshold, or a
future acceptance boundary.

## Deterministic alignment operation

For every returned glmmTMB fit, including fits whose fixed coordinates already
match exactly, the runner must perform the same operation before `parList`:

1. copy `fit$obj$env$last.par.best` to `raw_joint` immediately after fitting;
2. copy `raw_joint` to `aligned_joint`;
3. replace exactly the logical positions given by `fit$obj$env$lfixed()` with
   `fit$fit$par`;
4. require bitwise identity of `aligned_joint[lfixed()]` and `fit$fit$par`;
5. call `fit$obj$env$parList(x = fit$fit$par, par = aligned_joint)`; and
6. hash the raw joint state, aligned joint state, fixed-index vector, top-level
   parameter vector, and canonical ten-block start representation.

No norm, epsilon, observed discrepancy, optimizer-specific exception,
rounding, clipping, or post-fit objective comparison can change this rule.
Random-mode coordinates are copied from `last.par.best` without modification.
The operation constructs one deterministic complete start list from the
backend's reported top-level vector and immediate random-mode snapshot. It
does not assert that the combined joint vector is itself a conditional optimum:
the random modes are not reoptimized after fixed-coordinate replacement. It
is not another optimization step and is not evidence that the fit is adequate.

## Full-denominator paired covering smoke

The exact same outcome-independent 120 pair identities used by b1g1 are run
under a new contract and separate checkpoint root. All five designs, both
`exact_zero` and `reference_1200`, replicate 101, ML and REML, and all six
profiles remain represented. Checkpoints are not imported from b1g1.

Comparison with b1g1 is by the complete ordered 120-row denominator. It records
return-state changes, stabilization-state changes, raw likelihood-drop typed
agreement, top-level parameter-hash agreement where both fits returned, raw
fixed-coordinate mismatches, and post-alignment exactness. Rows exposed by the
correction are retained; no complete-case-only comparison may support a claim.

## Authorization and interpretation

This contract can establish only that deterministic alignment, dependency
transfer, atomic checkpointing, and no-fit resume work on the covering smoke.
It cannot reinterpret aligned snapshots as optimizer maxima beyond what the
backend reports, certify gradients or Hessians, select an optimizer or start
rule, repair the b1e numerical-sensitivity failure, or authorize the full
manifest.

`AlignmentSmokeExecutionAuthorized=TRUE` is therefore compatible with all of
`FullExecutionAuthorized`, `NumericalStabilizationReady`,
`NumericalSensitivityEvidenceReady`, `CalibrationEvidenceReady`,
`ThresholdFrozen`, `InferenceReady`, and `DecisionReady` remaining false.
