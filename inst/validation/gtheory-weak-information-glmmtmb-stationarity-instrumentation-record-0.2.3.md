# Draft.83d2b2b1g4 scale-aware stationarity instrumentation record

Date: 2026-08-10
Scope: exact 120-pair b1g2 covering-smoke replay with retained derivatives
Decision: measurement schema ready; stationarity criterion, full execution,
calibration, inference, and D-study decisions remain false

## Frozen identities

- b1g2 alignment contract:
  `7632a74709576c78d4e89b9fd015952dbde5be98313b99ed380af7c5436e1177`
- b1g2 execution:
  `e2716a4ae71784e218d15f2509ed8c15326c1b7c6bc9acf78826a81822581482`
- b1g3 adjudication:
  `c7c35d5b961c578b6234a1f29f628f13dac357bc1b046e012832d28ca7f3d4de`
- b1g4 instrumentation contract:
  `97dcdd0103a3eb9a714ac56008f801af57853bc816f42e5bc9ab33dd63f3ae32`
- b1g4 execution:
  `a825ab427da7e4a8160e428a7a6b00038f364b1c15049df6d5e4bf03bbbbbade`
- b1g4 threshold-free adjudication:
  `40949ff311e6dbe1289cf6488aa2db3642a65ca64d6b794b47aeb5001d53acf1`

The initial implementation audit exposed two bookkeeping distinctions before
the retained identity was formed. Existing gradient hashes excluded name
attributes whereas the new vector sidecar retained them; comparison hashes
were therefore normalized to the existing unnamed-numeric convention without
changing the retained named vector. The audit also showed that a positive
finite-difference eigenvalue is not sufficient for a numerical Cholesky factor,
so spectral positivity and Cholesky availability were separated. Neither
change used an observed magnitude to select a threshold, profile, scenario, or
row. The corrected contract received a new hash and the complete 240-fit smoke
was rerun in a new checkpoint root.

## Exact accounting, fit replay, and resume

All five designs, both frozen variance cases, replicate 101, ML and REML, all
six profiles, 120 full/reduced pairs, and 240 backend fits returned. Every
returned fit has a content-addressed raw derivative sidecar. All 240 repeated
outer-gradient hashes and all 240 repeated Richardson-Jacobian hashes agree
exactly with the pre-existing diagnostic calculations.

Against b1g2, mismatch counts are zero for full and reduced top-level parameter
hashes, objectives, reported log likelihoods, and raw nested likelihood drops.
Thus post-fit instrumentation did not change any fitted result in the retained
ledger.

The initial corrected run computed 20 base routes. A no-fit resume reused all
20, computed zero, and reproduced the same scientific execution hash. The
initial and resumed RDS file hashes differ only because timing and reuse status
are deliberately excluded from scientific identity. Summed base-route elapsed
time was 198.63 seconds (median 4.671, maximum 36.681). Runtime is descriptive
and does not authorize the full manifest.

## Gradient surfaces and scale observables

Raw outer gradients and the project-defined objective/parameter relative
vectors are available for all 240 fits. The raw maximum absolute gradient
ranges from approximately `2.51e-7` to `2.80e-2`, with median `1.99e-4`. The
objective/parameter relative maximum ranges from `3.16e-10` to `1.45e-5`, with
median `8.54e-8`. These are coordinate-dependent descriptive ranges, not
cutoffs.

Outer and `sdreport` gradient vectors are bitwise equal in 238 fits. The two
nonzero maximum absolute differences are `2.16e-7` for the full cold-BFGS REML
fit in `baseline_complete/reference_1200`, and `2.09e-8` for the reduced BFGS
self-restart ML fit in `imbalanced_hub/reference_1200`. These are the two
surface-hash discrepancies already identified by b1g3, now quantified from
retained vectors.

The lme4-compatible maximum scaled gradient is available for 221 fits and
ranges from `8.52e-8` to `1.46e-2` (median `2.28e-5`). The componentwise lme4
minimum-gradient maximum has the same minimum, a maximum `1.47e-3`, and median
`1.83e-5`. The Newton decrement is available for 221 fits and ranges from
`1.39e-7` to `1.46e-2` (median `3.23e-5`). These lme4-compatible and
Newton-whitened quantities remain separate; no one is promoted to the
stationarity definition.

Newton relative steps are available for 218 fits, range from `1.73e-8` to
`8.61e-2`, and have median `7.70e-6`. Three reduced REML
`high_information/reference_1200` BFGS-family fits have numerical Cholesky
factors and Newton decrements but no stable direct `solve(H, g)` step; the
unavailable steps remain `NA` rather than zero.

## Curvature availability

The symmetric Richardson Hessian is spectrally positive in 224/240 fits: 113
full and 111 reduced. Numerical Cholesky factors are available in 221/240: 110
full and 111 reduced. The three discrepant fits are the full ML BFGS-family
profiles for `high_information/exact_zero`. Their smallest Richardson
eigenvalues are approximately `1.70e-12` to `2.78e-12`, largest eigenvalues
about `1.31e4`, and reciprocal condition estimates about `1.12e-18`.
Accordingly they are not treated as numerically factorable despite positive
computed eigenvalues.

All six scaled profiles are available in 33 of the 40 route/model strata; four
are available in two strata and three in five strata. The denominator is never
reduced to the 33 complete strata.

## Cross-profile behavior

For each of 40 route/model strata, the smallest raw-gradient profile matches
the smallest observed-objective profile in 18 strata. The objective/parameter
relative metric also matches in 18, the lme4-compatible scaled metric in 26,
the Newton decrement in 29, and the Newton relative step in 27. The respective
full/reduced counts are 8/10, 8/10, 15/11, 16/13, and 14/13.

This incomplete concordance is substantively important: minimizing one
gradient summary is not equivalent to minimizing the observed objective, and
neither operation establishes a global maximum. The cross-profile summaries
therefore remain measurement evidence and may not select an optimizer.

## Metacognitive decision

b1g4 closes the observability gap identified by b1g3: future calibration can
now work from actual parameter, gradient, and curvature vectors rather than
irreversible scalar summaries. It does not close the inferential gap. In
particular:

- no observed b1g4 value becomes a stationarity tolerance;
- non-PD, numerically unfactorable, and boundary-target fits need explicit
  states rather than a single binary convergence flag;
- agreement across six profiles is useful but is not a global-optimum proof;
- the exact-zero target still lies outside the finite full-model
  log-standard-deviation coordinate space; and
- boundary-bootstrap operating characteristics remain separate from local
  stationarity measurement.

The next slice should prospectively define a calibration design with both
false-ready and false-unready targets, an independent high-accuracy reference,
and explicit handling of spectral-PD/Cholesky/step-solve availability. It must
not tune a cutoff on these 240 fits. Full-manifest stabilization execution
should be reconsidered only after that rule and its computational budget are
frozen.

## Fail-closed status

The narrow claims `RawDerivativeSidecarsReady`,
`ScaleAwareObservablesReady`, `ScaleAwareMeasurementSchemaReady`, and
`CrossProfileMeasurementReady` are true. The following remain false:

- `StationarityThresholdFrozen` and `StationarityCriterionReady`;
- `NumericalEligibilitySufficientRuleFrozen`;
- `FullExecutionAuthorized`;
- numerical stabilization/sensitivity readiness;
- calibration, threshold, bootstrap, and confirmation readiness; and
- inference, coefficient, and D-study decision readiness.

## Verification and artifact hashes

The unguarded unit tier passed 25 expectations plus one guarded skip. The exact
enabled tier passed 37 expectations. Artifact hashes are:

- contract Markdown:
  `ac4666ece0a569c3aa04677adecb4f8ffe52c9cab9ad84d3ec14154940d945cd`
- instrumentation/adjudication source:
  `c9490347cf43a16529cef37d7c131e3c4ab692d909f101fc7101ea49290b661f`
- test source:
  `46be58e1454df54e7c95be8aa7bb94a7b59493e2bb18e8331e1a0148fc26b9c8`
- initial corrected execution RDS:
  `e4935df0a9a0b7dec4b87c8d789de48ea711fd2cb241c55d1b1d49d1911a9b07`
- no-fit-resume execution RDS:
  `20e4892e78cd5913ccff6c4c364f256fe6a1fc77b5353dbb3f2be05611bcdc54`
- threshold-free adjudication RDS:
  `30bc5572ea0ac32ec752c2786e349bac76ee77e2af3fd38ff09634f6aba943dd`
