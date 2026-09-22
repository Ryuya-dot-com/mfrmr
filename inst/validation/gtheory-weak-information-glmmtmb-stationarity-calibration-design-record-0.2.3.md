# Draft.83d2b2b1g5 independent stationarity-calibration design record

Date: 2026-08-10
Scope: mathematical state separation, coordinate audit, reference architecture,
and sealed calibration-manifest design
Decision: design schema ready; reference tolerances, stationarity rule,
calibration execution, full execution, bootstrap, inference, and D-study
decisions remain false

## Retained identities

- b1g4 instrumentation contract:
  `97dcdd0103a3eb9a714ac56008f801af57853bc816f42e5bc9ab33dd63f3ae32`
- b1g4 execution:
  `a825ab427da7e4a8160e428a7a6b00038f364b1c15049df6d5e4bf03bbbbbade`
- b1g4 adjudication:
  `40949ff311e6dbe1289cf6488aa2db3642a65ca64d6b794b47aeb5001d53acf1`
- weak-information pilot plan:
  `427addf42c73047e184857f52e9aa126e6d5eb346ab105827d14b3affef38cbd`
- sealed outer calibration manifest:
  `85d3ee963e93adfcc1d0bf505b1c34b1486f3eebfc605cf687a8e79240431676`
- b1g5 stationarity-calibration design contract:
  `278353d1668501d04dd3af4adc96dfcd39b232796057242418f89601b22b99ac`
- b1g5 sealed workload manifest:
  `0dbe9e92bed7baa27b6c5f29bed0759a789bcc02c285bd77d749a9cc9666e4d0`

The retained b1g4 execution and adjudication were reloaded and their complete
scientific hashes, upstream contract identity, accounting states, and
fail-closed readiness states were revalidated. Mutation of an adjudication
field invalidates the identity check.

## Metacognitive correction to the roadmap

The earlier roadmap placed one generic “stationarity rule” in front of the
weak-information calibration. That wording was too compressed. There are four
different estimands:

1. finite first-order stationarity;
2. second-order local curvature and factorability;
3. an unattained boundary limit in log-standard-deviation coordinates; and
4. statistical resolution of the target variance component.

The fourth has simulation truth labels; the first three do not. A zero
generating variance cannot prove that a returned fit is numerically
nonstationary, just as a positive generating variance cannot prove a regular
finite optimum. The revised gate order is therefore structural identification,
numerical stationarity/boundary, statistical component resolution, bootstrap
inference, and only then D-study decision use.

This separation also prevents two opposite errors. A full fit whose likelihood
improves toward `log(SD) = -Inf` is not called a finite stationary point, but it
is not discarded as a generic optimizer failure; it receives a boundary
handoff. Conversely, a numerically stationary fit does not thereby establish
that its Rater variance is statistically resolved.

## Mathematical coordinate audit

For `p = A z + b`, the implementation verifies `g_z = A' g_p` and
`H_z = A' H_p A`. Identity, diagonal scales from `1e-4` to `1e4`, shear, and
rotation fixtures were applied to a positive-definite three-parameter
quadratic.

| Check | Result |
| --- | --- |
| positive-definite state preserved | yes, 4/4 fixtures |
| Newton decrement preserved | yes, within `1e-10` relative tolerance |
| raw maximum gradient preserved | no, as expected |
| lme4 Cholesky-scaled maximum preserved | no, as expected |
| one negative Hessian direction preserved under congruence | yes, 4/4 fixtures |

The illustrative raw maximum changed from `0.15` to `30` under the extreme
diagonal coordinate map, while the Newton decrement remained approximately
`0.1080592`. The same extreme map made the direct relative Newton-step solve
numerically unavailable. Availability is consequently an observed state, not
a manufactured zero.

These results establish exact local coordinate algebra, not superiority of a
candidate rule in real mixed models. In particular, an affine-invariant local
quantity is still not a proof of global optimality or statistical resolution.

## Candidate and reference architecture

The candidate registry contains five metric families and eight adjacent
decimal indeterminate zones. The grid spans `1e-8` through `1e-1` and includes
the documented lme4 `2e-3` convergence anchor. It was frozen before any
replicate 201--300 result was viewed. No family or zone is selected.

Newton decrement is the primary affine-invariant candidate. The lme4
componentwise-minimum and objective-relative metrics remain practical
candidates. Raw gradient is retained as a coordinate-dependent negative-control
benchmark; relative Newton step is a sensitivity candidate. Missing Cholesky,
curvature, or solve results remain `not_evaluable` for the metric that requires
them.

The reference ladder has eight stages: objective reconstruction, AD-versus-
Richardson comparison, deterministic multi-start envelope, strict solver
ladder, damped Newton polishing, curvature inertia, profiled boundary sequence,
and final adjudication. No stage is sufficient alone. Reference disagreement
is `reference_unresolved`, not silently resolved by majority vote.

The reference architecture is frozen, but its floating-point tolerances are
not. This is intentional. Calling a solver consensus “truth” without first
showing tolerance and replay stability would replace one uncalibrated
convergence flag with another.

## Sealed workload

| Quantity | Count |
| --- | ---: |
| outer scenarios | 30 |
| replicates per scenario | 100 (IDs 201--300) |
| independent datasets | 3,000 |
| paired methods per dataset | 4 |
| base scenario x replicate x method units | 12,000 |
| full/reduced model roles per unit | 2 |
| candidate profiles per model role | 6 |
| prospective candidate fits | 144,000 |
| high-accuracy reference problems | 24,000 |

Thus the prospective schedule contains 144,000 candidate fits and 24,000
reference problems. `ReferenceToleranceFrozen=FALSE`,
`StationarityThresholdFrozen=FALSE`, and
`CalibrationExecutionAuthorized=FALSE` remain explicit contract states.

The b1g5 manifest is a workload/identity manifest only. Every row has numerical
calibration execution and statistical-resolution use set to false. No dataset,
fit, derivative, boundary profile, threshold, or operating characteristic was
generated or viewed in this slice.

Binary numerical false-ready and false-unready rates will be conditional on a
resolved reference state and reported by scenario x method. Boundary handoff,
candidate indeterminate, candidate non-evaluation, and reference unresolved
retain separate counts. These numerical errors will never be pooled with the
statistical false-ready/false-block errors already defined for target-component
resolution.

## Source audit

The contract is grounded in primary papers and current official package
documentation: Kristensen et al. (2016) for TMB automatic differentiation and
Laplace likelihood, lme4 documentation/source for curvature scaling, glmmTMB
troubleshooting for restart/alternate-optimizer and Hessian diagnostics, Nash
and Varadhan (2011) plus Nash (2014) for multi-method optimization checking,
`numDeriv` for Richardson derivatives, and Self and Liang (1987) for
nonregular boundary likelihoods.

The read-only Zotero audit found no exact local records for the three numerical
reference searches, so official and publisher sources were used for those
claims. Ten G-theory search results were present, including Jiang et al. (2020),
Wind et al. (2023), and Jiang et al. (2024); they remain contextual and were not
misused as numerical-optimization authorities.

## Verification and artifact hashes

The focused test passed 41 expectations without skip, warning, failure, or
error. It covers state separation, affine gradient/Hessian transformations,
Newton-decrement invariance, Hessian inertia, coordinate-dependent negative
controls, failure-aware error accounting, exact workload counts, manifest
mutation rejection, authorization false states, and retained b1g4 artifact
revalidation.

- contract Markdown:
  `8b699b411cd49b9214603d5e67a5e34545c42135e69df54d76dd0b8676e9a073`
- design source:
  `f66cf3ce87238f9bb1a7c33bc4a3b9dcf0f7a36ed8133789307684c4413c4f8e`
- test source:
  `55aaf167b7841061245b29e0880e690263d9e56bc72a7d5b55d5869a0eaa839a`

The record's own hash is omitted because recording it would change the file.

## Next gate

Before calibration execution, b1g6 must freeze and test the high-accuracy
reference tolerances and solver ladder on analytic objectives and a new,
nonreserved replay set. It must prespecify boundary-profile stopping,
floating-point escalation, disagreement behavior, checkpoint/storage budget,
and per-stratum reference-unresolved ceilings. It may not use b1g4 magnitudes
to tune candidate cutoffs and may not view replicates 201--300.

Only after b1g6 passes can a new identity authorize numerical calibration.
Statistical-resolution and nuisance-boundary bootstrap calibration remain later,
separate gates.
