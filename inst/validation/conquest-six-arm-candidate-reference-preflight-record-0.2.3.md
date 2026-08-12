# ConQuest candidate-002 numerical-reference preflight for mfrmr 0.2.3

Status: all six source-bound mfrmr numerical references ready; external
execution handoff not frozen, 2026-08-12. No ConQuest process was launched and
no expected ConQuest output existed or was opened.

## Identity and scope

| Field | Value |
| --- | --- |
| Candidate ID | `mfrmr-0.2.3-conquest-six-arm-002` |
| Reference source commit | `8ee7958f7af08141df156b333fe1fc732e2b2bc6` |
| Reference-artifact bundle SHA-256 | `0d23be47efce2965c8f4fa76c93d6aa569bc5aa313bce6550286ac2d9f7942a8` |
| Reference-source bundle SHA-256 | `c0dfb7cf32a27e652bfed6ae644a7fe2aa606970f04a8d4a43d0ba1a71b11e2c` |
| Candidate input/model binding | `mfrmr_conquest_six_arm_candidate_binding_v2` |
| Numerical-reference contract | `mfrmr_conquest_six_arm_candidate_reference_v1` |

The reference fits were generated from a `git archive` of the exact
pre-binding commit, loaded as the mfrmr 0.2.3 namespace. This avoids silently
using later working-tree code for an earlier-bound candidate. The 16 retained
reference artifacts are SHA-256-bound: four per Binary arm (summary,
population, item, and item map) and two per additive RSM/PCM arm (summary and
parameter table). Person-level candidate files remain ignored.

## Numerical-reference result

| Arm | free dimension | deviance | terminal gradient sup norm | independent oracle | local full rank | inference-ready |
| --- | ---: | ---: | ---: | --- | --- | --- |
| Binary q31 | 8 | 424.738979414154 | 1.50e-7 | not separately implemented | not retained | no |
| Binary q61 | 8 | 424.738979414154 | 1.50e-7 | not separately implemented | not retained | no |
| RSM q31 | 7 | 930.984395777999 | 4.96e-6 | pass | 7/7 | no |
| RSM q61 | 7 | 930.984395777996 | 4.96e-6 | pass | 7/7 | no |
| PCM q31 | 9 | 930.504779568474 | 1.30e-6 | pass | 9/9 | no |
| PCM q61 | 9 | 930.504779568471 | 1.30e-6 | pass | 9/9 | no |

The additive references pass their independent adjacent-category probability
and marginal-likelihood oracles, quadrature-weight check, and exhaustive
512-pattern local score-rank audit. The Binary references currently have the
weaker but explicit basis
`converged_finite_internal_coordinate_consistency`: finite objective and
coordinates, centered six-item constraint, internally identical summary and
parameter exports, and terminal gradient below `1e-5`. This asymmetry is
reported rather than hidden; no Binary independent-oracle or local-rank claim
is manufactured.

All six fits retain `InferenceReady = FALSE`. For RSM/PCM the reason remains
`design_rank_not_evaluated`, because local first-order rank is not a proof of
global or continuous-integral identification. That does not prevent the
points from serving as non-inferential arithmetic references. Conversely,
passing a later cross-engine comparison cannot promote inference readiness.

## Prospective q31/q61 integration check

| Family | maximum coordinate difference | coordinate limit | deviance difference | deviance limit | result |
| --- | ---: | ---: | ---: | ---: | --- |
| Binary | 1.13e-14 | 2e-6 | 0 | 2e-6 | pass |
| RSM | 1.65e-11 | 2e-6 | 2.96e-12 | 2e-6 | pass |
| PCM | 1.66e-11 | 2e-6 | 2.96e-12 | 2e-6 | pass |

These are mfrmr within-engine checks under the already frozen prospective
budget. They do not inspect ConQuest results and do not establish cross-engine
equivalence.

## Machine disposition

| Field | Value |
| --- | --- |
| `NumericalReferenceReady` | `TRUE` |
| `InferenceReady` | `FALSE` |
| `NumericalReferencePromotesInference` | `FALSE` |
| `CandidateExecutionAuthorized` | `FALSE` |
| `ExecutionHoldReason` | `candidate_execution_handoff_not_frozen` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |

The next gate is a small execution-handoff contract that rechecks the exact
executable, candidate/source/bundle identities, numerical references, 50
empty output paths, working directory, and console-capture mapping immediately
before launch. It may authorize only this six-arm run; it may not authorize a
sparse extension, GPCM extension, simulation, confirmation, or release.

## Verification and source identities

The focused preflight completed with 37 expectations and the complete
ConQuest-labelled slice with 785 expectations; both had zero failures, errors,
skips, or warnings. The affected claim-disposition and release-readiness
slices also passed. A source tarball passed `R CMD check --no-manual` under R
4.6.1 with `Status: OK`; sandboxed CRAN/Bioconductor index warnings did not
become a check warning or note. Package-check passage does not authorize
ConQuest execution.

| Artifact | SHA-256 |
| --- | --- |
| `conquest-six-arm-candidate-reference-preflight-0.2.3.R` | `094923f1228785f16cb5297bcfe17cb78e9bc7931847f4603e82f03ed024e0f8` |
| `conquest-six-arm-candidate-binding-0.2.3.R` | `48901c758a37abe13fcff74bbb2742aac6c9177f030841e5b7ad8603330253a6` |
| `tests/testthat/test-conquest-six-arm-candidate-reference-preflight.R` | `70a94af23701fb1033c7593efb7c5863b3b4109f0d2fdc8047b8171731bc8914` |
