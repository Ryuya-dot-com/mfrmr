# maxit-ceiling stable-slice audit for 0.2.3

Status: release-spine row 8 deterministic stable slice, 2026-08-11. This record
advances `maxit_ceiling_contract` from `not_run` to `review`; it does not close
the row because the checklist requires candidate-linked confirmation as well
as unit evidence.

## Contract

`maxit` is a computational budget, not evidence of convergence and not a
result-selection parameter. The repository contract has four rules:

1. declare a positive, strictly increasing ceiling sequence before fitting;
2. every analyzed attempt must be a prefix of that sequence and retain one
   common specification hash;
3. iteration-limited, numerically reviewed/failed, or non-inference-ready
   attempts are never eligible; and
4. if a run is selected, it must be the first eligible run, not a later run
   with more attractive coefficients, fit, significance, or agreement.

The public default example remains `(400, 800, 1600)`. A study may prespecify
a different increasing sequence; the validator records that sequence instead
of pretending one ceiling schedule is universally optimal.

## Separation of responsibilities

Current runtime code governs each individual fit. An iteration-limited fit is
blocked, `InferenceReady=FALSE`, and carries an explicit instruction not to
interpret or select it. The repository-only
`mfrmr_review_maxit_attempts()` validator governs a sequence of attempts used
as release evidence. It detects skipped ceilings, changed specification
hashes, inconsistent readiness fields, multiple selections, a selected
ineligible attempt, and selection of a later ready run when an earlier ready
run existed.

This does not claim that the package can observe analyses performed outside
the recorded workflow. For release evidence, absence of a valid registry is
itself failure; for ordinary users, the public documentation states the same
policy and each fit still fails closed on its own numerical state.

## Evidence

| Evidence | Result |
| --- | --- |
| maxit registry contract | 50 expectations, 0 failures, 0 warnings, 0 skips |
| actual current RSM/JML sequence `(1, 120)` | attempt 1 `blocked/failed/iteration_limit`; attempt 2 `ready/ready/converged`; only attempt 2 eligible and selected |
| central readiness propagation | 93 expectations, including actual PCM JML/MML `maxit=1` blocked and `maxit=120` ready paths |
| result propagation | 74 expectations, including an actual iteration-limited MML fit remaining non-reportable |
| edge behavior and next-action guidance | 47 expectations, including deterministic RSM/JML iteration-limit state and prespecified-sequence guidance |

The registry's negative fixtures reject:

- `(400, 1600)` against the declared `(400, 800, 1600)` prefix;
- a specification-hash change between attempts;
- selection of a blocked iteration-limit attempt;
- selection of attempt 2 when attempt 1 was already eligible;
- multiple selected attempts; and
- a tampered `ready/TRUE/ready` record carrying
  `ConvergenceStatus=iteration_limit`.

The source-specific documentation test verifies the computational-ceiling
label, the `(400, 800, 1600)` example, invariance of data/model/method, the
first-eligible-run rule, the prohibition on preferred-result selection, and
the release-gate ban on passing a blocker through repeated ad hoc reruns.

## Bound development identities

| Artifact | SHA-256 |
| --- | --- |
| `maxit-ceiling-contract-0.2.3.R` | `82f8bf79939c1d900b7bad3bf8bf3bdefaf2230ba0b5085d8c9b1e4a67bb5784` |
| `../../tests/testthat/test-maxit-ceiling-contract.R` | `bab1bdd9980482088f85c8fc2fc548719578a38e6b1f8ed2196f79f58ea7f518` |
| `../../R/api-estimation.R` | `781b22805aeaca213943d04cbf42d131a5c96daaefa343c1e6369418bd41465b` |
| `../../R/core-readiness.R` | `58437622f8154310cd7073b0a704c6fc18cce039c62264d27f101b3134fe111f` |
| `../../tests/testthat/test-readiness-propagation.R` | `053ed8836b9ea2a2fbc5103d160485fafb861aa29781557646fe0533428c199b` |
| `../../tests/testthat/test-results-readiness-propagation.R` | `da8242c7753e2a5ed35da4d32a1141b254772ffd98959e8f9ea936f7d4b290f6` |
| `../../tests/testthat/test-edge-cases.R` | `53ebcc2d92586540997755fe880a2af99d3261576f5dd13a32583692391f7529` |
| `release-gate-spec-0.2.3.md` | `663c9411c19635ce9c11cacf882b71c3d73f0f12a67214740f22d7da68b536de` |

These identities bind development evidence only.

## Decision and stopping boundary

Checklist row 8 changes from `not_run` to `review`. Its unit/structural slice
is complete, and there is no reason to add more optimizer scenarios or start a
simulation. Return to this row only when the exact candidate attempt registry
exists; the candidate must pass the same contract without changing its
sequence, thresholds, state vocabulary, or selection rule.

The next mathematical work should therefore address rows 5--6 only through a
prespecified general score/Jacobian calibration design. It must not infer a
general stationarity tolerance from the exact-reduction or maxit fixtures.
