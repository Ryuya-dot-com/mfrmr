# Draft.83d2b2b1g2 deterministic alignment covering-smoke record

Date: 2026-08-10
Scope: repository-only corrective smoke on already viewed simulation factors
Decision: alignment mechanics ready; full execution and numerical readiness
remain false

## Frozen identities

- corrected b1g design contract:
  `8feb8695c655c0621d61863e00d82fffe7fd5d7b619761decefaed6e89b0c326`
- corrected b1g manifest:
  `92435f41b0dab7e13bf1febcf6e043fc1ae8d4a2cb7d159401dd1d78b4c9ff3e`
- b1g1 runner contract:
  `3ae866b7b7179917400e6c5e5b9dd3fcf01b6ff70c6fc914564b80836c83f192`
- b1g1 smoke execution:
  `c743de38ec7d5ff6606c5b1df7960caea4bca149b470063e8496db83b5ab439d`
- b1g2 alignment runner contract:
  `7632a74709576c78d4e89b9fd015952dbde5be98313b99ed380af7c5436e1177`
- b1g2 smoke execution:
  `e2716a4ae71784e218d15f2509ed8c15326c1b7c6bc9acf78826a81822581482`
- b1g1--b1g2 full-denominator comparison:
  `651b6f07cb7977b7d1245b1048e0b7b905c4999f8da43bfbcd30180d9581d435`

The execution identity excludes timing, checkpoint location, and
computed-versus-reused status. The initial and no-fit-resume RDS files
therefore have different file hashes but the same scientific execution hash.

## Exact accounting and resume

The run covered all 5 designs, both frozen variance cases, replicate 101, ML
and REML, and all 6 profiles: 10 datasets, 20 atomic base routes, 120
full/reduced pairs, and 240 planned backend fits. All 20 checkpoints and all 10
dataset markers validated. The initial run computed 20 base routes; the resume
reused 20 and computed zero. Ordered atomic rows and the scientific execution
hash were identical on resume.

All 120 full fits and all 120 reduced fits returned and were snapshotted. All
80 dependent routes verified exact parent-signature transfer. The two b1g1
pre-alignment mismatches recurred in the same scientific locations:

- full, cold BFGS, REML, `baseline_complete/reference_1200`, maximum fixed
  difference `2.802368e-10`;
- reduced, BFGS self-restart, ML, `imbalanced_hub/reference_1200`, maximum
  fixed difference `6.490930e-11`.

The alignment rule was not selected from either number. It was applied to all
240 returned fits, and all 240 aligned fixed-coordinate vectors were bitwise
identical to `fit$fit$par`. By construction, random-mode coordinates were
copied unchanged from the immediate `last.par.best` snapshot. The resulting
joint vectors are deterministic complete starts; because random modes were not
reoptimized after fixed-coordinate replacement, they are not claimed to be
conditional joint optima.

## Full-denominator comparison with b1g1

All 120 ordered pair identities were compared; complete-case selection was not
used. Four pair returns were recovered and none were lost: three full returns
and one reduced return. These are exactly the b1g1 full snapshot failure, its
two dependent child full fits, and the b1g1 reduced snapshot failure.

Four mutually exclusive states changed:

- the full cold-BFGS snapshot failure and its two children became returned
  pairs with nonfinite objective or likelihood;
- the reduced BFGS self-restart snapshot failure became
  `returned_diagnostic_complete`, with raw likelihood drop `28.30337`.

The typed raw-likelihood-drop comparison consequently has one mismatch: b1g1
recorded `NA_real_` because the reduced snapshot failed, whereas b1g2 exposes a
finite value. This is a recovered observation, not drift among common returned
fits. Across the 117 common returned full fits and 119 common returned reduced
fits, top-level parameter hashes, objectives, and log likelihoods had zero
mismatches.

## Diagnostics retained as negative evidence

The b1g2 primary state counts are:

- 14 `nonfinite_objective_or_likelihood`;
- 21 `finite_material_negative_drop`; and
- 85 `returned_diagnostic_complete`.

There are no generation, parent-unavailable, fit, optimizer-code, gradient,
Hessian-availability, or likelihood-identity *primary states*. State precedence
does not erase individual diagnostic failures: one full fit has optimizer code
1 beneath an earlier nonfinite state, and only 113/120 full and 111/120 reduced
fits have both sdreport and Richardson positive-definite Hessian flags.
The maximum outer-gradient absolute values are approximately `0.02798` (full)
and `0.01722` (reduced), and the minimum signed relative Richardson
eigenvalues are approximately `-7.09e-7` and `-3.11e-7`.

All 21 material negative drops remain in `exact_zero`; none occurs in
`reference_1200`. Nonfinite objective/likelihood states are 5 in `exact_zero`
and 9 in `reference_1200`. Thus alignment removes a representation failure but
does not solve the underlying likelihood, gradient, curvature, or boundary
behavior.

The summed base-route elapsed time was 144.145 seconds (median 3.3535, maximum
26.999). A roughly three-hour extrapolation to the full manifest is only a
planning estimate; runtime feasibility does not authorize that run.

## Fail-closed adjudication

`AlignmentMechanicsReady=TRUE` and
`FullDenominatorComparisonReady=TRUE` are narrow claims. The following remain
false:

- `FullExecutionAuthorized`;
- `NumericalStabilizationReady`;
- `NumericalSensitivityEvidenceReady`;
- `CalibrationEvidenceReady`;
- `BootstrapOperatingCharacteristicsReady`;
- `ThresholdFrozen` and `ConfirmationAuthorized`;
- `InferenceReady`, `CoefficientEligible`, and `DecisionReady`.

Before a full 18,000-fit run, the roadmap must freeze a separate, prospective
adjudication of nonfinite likelihoods, signed likelihood drops, gradients, and
curvature. Deterministic alignment is now a validated transport rule, not a
numerical-adequacy criterion.

## Artifact hashes

- alignment contract Markdown:
  `553bbf27ebb16f768fed172de5ec9dc3a58a7a2a925a893f7322ca5a1d2fc19b`
- alignment runner source:
  `894d78f03196d58ab87cfd51e6390a41c05d1cc0dcdec19cc6e6aa256d4a1de0`
- alignment test source:
  `edbeec2d97140f0fe8725381264400a6a1278c279afce6bba7a74c5f7da2a7d7`
- initial smoke RDS:
  `3b3f537ff3905976a83b75ffd0b87b5c88a207984aca22fa809ea6e78e1df7a2`
- no-fit-resume RDS:
  `adc7c4ac5ae2d94f419b89c4c460578928a2b5390f88de4dcb9b3a215f8de73f`
- comparison RDS:
  `dc69ed1f763471c6715a911648c4ef79c685e7fa50642b2d9d222d3b77d9b4cb`
