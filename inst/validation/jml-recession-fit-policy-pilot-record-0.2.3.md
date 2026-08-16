# JML recession fit-policy pilot record for mfrmr 0.2.3

## Decision

Draft.61 selects `bounded_single_10s` as the sole implementation candidate for
the JML recession audit. This is not a production change and does not resolve
the replay blocker. The candidate must still be implemented minimally and pass
the affected unit, target-scale, full-regression, and package-check evidence.
Runtime criteria and confirmation remain unfrozen and unauthorized.

The selection is consequence-based rather than elapsed-time-based. Both
bounded candidates reproduce the OS-bounded native-zero reference on all six
full-fit routes and preserve optimizer outputs. With the same positive-target
call sequence and the same declared maximum native bound of 20 seconds per
target, the single-ten-second policy uses no more solver attempts in any of 18
matched fit/replicate cells and fewer attempts in six.

## Prespecified fit-level comparison

The pilot reconstructs the six exact Draft.59 routes from their stored input
identities: complete, balanced-sparse, and random-sparse designs crossed with
RSM and bounded GPCM. Four policies are applied through validation-only
namespace wrappers, with three fresh-process repetitions per route and policy.

| Policy | Native rule per capacity/strictness stage | Parent fit deadline | Role |
| --- | --- | ---: | --- |
| `production_original_2s` | one 2-second attempt | 120 seconds | current production calibration |
| `bounded_retry_2s_8s` | 2 seconds, then 8 seconds after an unaccepted stage | 180 seconds | implementation candidate |
| `bounded_single_10s` | one 10-second attempt | 180 seconds | implementation candidate |
| `os_bounded_native_zero` | native zero | 180 seconds | attribution reference only |

The wrapper replaces only the target LP policy after optimization. It records
every target call and solver attempt, then restores the namespace binding. The
underlying fit inputs, model route, optimizer, likelihood, identification,
readiness derivation, and original-scale certificates are unchanged. A parent
deadline independently bounds every fresh process.

The following rule was frozen before execution. A candidate qualifies only if
all fit results are safe, every route is stable across repetitions, all route
outcomes match the reference, and optimizer identities are invariant. If both
candidates qualify, `bounded_single_10s` is selected only when:

1. target-call sequences are identical in every matched fit/replicate cell;
2. both candidates have the same maximum positive-target native bound;
3. the single-attempt policy has no more solver attempts in every cell; and
4. it has fewer solver attempts in at least one cell.

Elapsed time is expressly prohibited from selecting the policy.

## Execution result

All 72 scheduled fits complete and retain exact input identity. No parent
deadline fires, no fit fails, and all final results are fail-closed safe.

| Result | Count |
| --- | ---: |
| scheduled fits | 72 |
| completed workers | 72 |
| successful fits | 72 |
| parent kills | 0 |
| safe results | 72 |
| target calls | 199 |
| solver attempts | 269 |
| recorded stage-attempt rows | 209 |
| stable policy-by-route cells | 23 / 24 |
| qualified implementation candidates | 2 |

All 72 fits preserve their optimizer-result hashes. The only unstable cell is
the current two-second policy on random-sparse RSM. It produces one certified
joint recession outcome and two `not_evaluated_solver` outcomes. The current
policy is stable on the other five routes but matches the reference on only
four of six routes.

Balanced-sparse RSM exposes a distinct stable false negative: all current-
policy repetitions finish with the joint audit not evaluated and boundary
incomplete, while both candidates and the reference certify recession. Thus
stability alone is not correctness. Complete RSM/GPCM and sparse GPCM routes
match the reference under the current policy.

| Policy | Stable routes | Reference matches | Target calls | Solver attempts | Fit-pilot qualified |
| --- | ---: | ---: | ---: | ---: | --- |
| current 2 seconds | 5 / 6 | 4 / 6 | 46 | 60 | no |
| retry 2 then 8 seconds | 6 / 6 | 6 / 6 | 51 | 77 | yes |
| single 10 seconds | 6 / 6 | 6 / 6 | 51 | 66 | yes |
| OS-bounded native zero | 6 / 6 | reference | 51 | 66 | attribution only |

At two seconds, six capacity attempts and five strictness attempts return
status 1 under the retry policy; none is accepted. The subsequent retries
produce accepted original-scale results. The single-ten-second and reference
routes have no failed stage attempts. Every certification is recomputed on the
original, unnormalized target problem.

## Prespecified dominance result

The paired dominance table contains 18 route-by-repetition cells. Target-call
sequences agree in 18/18 cells. The single-ten-second policy has no more solver
attempts in 18/18 cells and fewer in 6/18, for totals of 66 versus 77. Both
policies expose the same maximum positive-target native bound of 20 seconds.
The frozen consequence rule therefore selects `bounded_single_10s`.

This selection rejects unnecessary restarts at an equal declared bound. It
does not claim that ten seconds is a calibrated runtime ceiling, that a
ten-second solve always succeeds, or that one observed elapsed-time profile
generalizes to other machines or designs.

## Adversarial interpretation

The result supports five bounded conclusions.

1. The production two-second audit can be both unstable and stably reference-
   inconsistent at full-fit level without changing optimizer results.
2. Both bounded candidates repair the observed six-route semantic discrepancy
   while retaining original-scale certificates and fail-closed behavior.
3. The single-ten-second candidate dominates the retry candidate only under
   the prespecified equal-bound attempt-count rule.
4. Three repetitions and six routes select an implementation candidate; they
   do not freeze capacity, recovery, coverage, or platform-general runtime.
5. The bounded-GPCM routes exercise only the conditional-additive recession
   layer. General nonlinear slope and curved-path geometry remain open.

The pilot does not qualify GLPK, normalization, status 1 acceptance, or native
timeout zero in production. It does not alter a public API, fitted-object
schema, likelihood, estimator, readiness rule, public roadmap, or release
claim.

## Evidence identity

The authoritative external bundle is
`mfrmr/archive/artifacts/validation-bundles-0.2.3/jml-recession-fit-policy-20260806-v1`.

| Artifact or identity | SHA-256 |
| --- | --- |
| Fit-policy runner | `45325e3df7490f0913fbf931269d3fafa11afef6144714abfe2e8a5628c85100` |
| Isolated worker | `3d7a3f036e061d26dba20b92dcb80f554eb68676a4d852d397aef14b2b5485d9` |
| Plan | `02b5cc0a8045276a13c931c923745da6758f03aa8347a574131e201825c367ee` |
| Prespecification | `0d29fd6988d0e6f7f3304ce9c669c8c6a9a0f54ea5a43cde9c9628e7b6750283` |
| Route registry | `56d7f642c0d6485f78a6efb6a7ed9df22febc651e3152ca7a50182451cf8beb7` |
| Policy registry | `ad43f62d3acaea221188e7723a4718f87f5088bffa1a2fa56172236d00dce1c0` |
| Schedule | `f845d0f1e7c71e90a9093d2fb01ed7bf70b5763ae0761d8c108f3338154201d6` |
| Source identity | `eef20f746edbffc7831bcba417561796c2813048086915252d125874e074f988` |
| Capability identity | `a5c2b1d7b57b67c2f646b6989fb7c87a576017841cdebf545f11dc4f1ffd5ac4` |
| Upstream identity | `a6a610be025af59bd356803b3448982572cf200616aa7a19637f2fbcb5c0569b` |
| Result identity | `52b4a5ffa4bf239a81c991219b819d24884c4f67c63ec87e675a8741a6bffe91` |
| Target-call identity | `a19679c4841c6f6226520a3f733e5e4f975e48e25d794971399162e545e29d07` |
| Attempt identity | `2885944fe7c245d89d227d7c68a2ee908f566108da389671e103701355bafbd7` |
| Cell-stability identity | `6bea21fccb91b9a9417a0733a5acc9fb54190abf50eedde98fc53e2e5bb697e0` |
| Policy-summary identity | `732f74f64b09ece26c9f64de821dc3fd1d658e232d0e9f481f5f346aaca63598` |
| Dominance identity | `e3bb41805e26b730158543603eaea4361cc021a21a28dbf180607b563668a90c` |
| Installed mfrmr | `ab03e1293272a7e77fe3167e28ff42b639912315ff574a76c304d39b82766103` |
| Execution | `d4786b196687501c91d27f1fef443a45b840f4dc5d71dd099f1231c6a91a12f0` |
| Artifact inventory | `f79fc66f03930b63a7f6d994a4cf730df9e32019ca8c5a2eedb8fa3838fb8dde` |
| Completion-marker file | `006d8f2a96be2ae63c75af16f8f39c6cdce3b221969cdc4df61df99c13c0e9c8` |
| Run-summary file | `19c087836910f1eb0069ce04129a1cd1e1f648c0362eaac9b6a943760dafa6c0` |
| Fit-results file | `91b899b45240fed337ef3e4d5c409d0a6a28db82bc8803ccbb1018b48ec7aea4` |
| Target-calls file | `845f8669c84a04f1a034c774211080199768ce1616160889b836daf112db5bee` |
| Stage-attempts file | `41796d29eae2eb4f0968cbf58c5417cc2c95a3ae6e4ae711090f9eeef0f1b071` |
| Policy-summary file | `0d43dcf60fe4b232d2b4ac0811111073df8c0f68e29a20985309990d1d87bcd0` |
| Dominance file | `b5c60ec11e348b7a044de2a3d6a9b5009e1407e9e7e6f4a8c59a371c48267455` |
| Pilot RDS file | `06da27e20e8efefb21543f6e1712faa9ffa32cbe616568959f47059e2a4d3704` |

The completion marker independently validates 19 artifacts. The source and
execution identities are recomputed by a separate verifier. Public
`ROADMAP.md` and `NEWS.md` remain unchanged.

## Next controlled decision

Draft.62 should implement the single-ten-second candidate as one explicit,
versioned internal JML recession-audit policy. Before modification, every
production call path and test that assumes a two-second native timeout must be
enumerated. The change must preserve the current fail-closed interpretation of
nonzero solver status, the original-scale certificate, optimizer behavior,
and all public schemas.

After implementation, rerun the complete affected boundary/readiness unit
surface, the six-route fit-policy comparison without a validation override,
the Draft.59 target-scale routes, the full non-CRAN regression, and the package
check. A production change may be retained only if native execution reproduces
the selected candidate's semantic and optimizer identities. Only that later
evidence can resolve the replay blocker. Runtime/capacity thresholds,
confirmation authorization, general nonlinear GPCM work, residual-PCA
computability, and ADEMP recovery/coverage remain separate open decisions.
