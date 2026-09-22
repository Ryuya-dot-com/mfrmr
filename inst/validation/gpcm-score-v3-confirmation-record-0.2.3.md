# mfrmr 0.2.3 GPCM score v3 disjoint-confirmation result

Status: completed once and rejected, 2026-08-11. The frozen v3 rule was applied
without retry or post-result setting changes. No general `NUM-SCORE-TOL`,
boundary, finite extreme-slope maximum, inference, or release promotion is
authorized.

## Exact execution

A fresh noninteractive process first reproduced the default
`no_go_not_issued` state. It then selected a new absent target, issued an
in-memory target-bound `go_issued_not_executed` record after all eleven gates
passed, and immediately consumed that record once. The six sealed scenarios
ran under the fixed package payload, design, quadrature, optimizer, stopping
settings, point constructions, and numerical rules. No retry was performed.

- result RDS SHA-256:
  `7836d859cca48e9a3641d94edda000218bb9c9f2903d801d7b9c9f03da017f2e`
- runner identity:
  `5b228934ebf6497cae87b442e79697eb457b6dc425abf6fb5bd15372f870242d`
- manifest:
  `f33605d4843f823bb39f0cdb3c3942d3a6c6964e637ebdbcc88663b935c1792b`
- result dimensions: 96 evidence rows, 560 coordinate rows, 24 point rows,
  and 376 entrywise Jacobian rows

All six fits returned finite vectors and optimizer code zero. Every fit
remained `FitReadiness = review` and `InferenceReady = FALSE`; three emitted
the explicit `converged_gradient_review` warning. Code zero did not promote
any estimate.

## Negative decision

The decision is `rejected` with `CompleteDenominator = TRUE`. There were no
structural-oracle, independent analytic-score, evaluation-completeness,
finite-difference, expanded-log-Jacobian, or positive-slope-Jacobian failures.
Maximum combined ratios were:

| Component | Maximum ratio |
| --- | ---: |
| independent analytic score | 0.2946403 |
| finite difference where applicable | 0.002291738 |
| expanded-log Jacobian | 0.2028742 |
| positive-slope Jacobian | 0.2822680 |

The sole failed decision clause was `ConstructedPointsFinite`. For the
Criterion-owned six-level workload fixture, the constructed
`finite_slope_stress_forward` point was intended to lie on the inclusive
boundary `max(abs(z)) = 3`. Sum-zero expansion produced the representable value
`3.0000000000000009`, exceeding three by
`8.8817841970012523e-16`. The frozen raw comparison therefore classified it as
`extreme_slope_review_handoff` and correctly withheld finite differences.

At that point the independent analytic score still agreed with the package;
the largest listed log-slope absolute difference was about `5.82e-11` against
scores as large as `4.79e4`. Maximum log- and positive-slope Jacobian ratios
were 0.2028742 and 0.2822680. These values do not rescue v3: the frozen
inclusive-region implementation failed its disjoint confirmation and cannot
be altered retrospectively.

Three retained solutions also entered the allowed non-promoting extreme
handoff. Together with the constructed point this produced 16 extreme evidence
rows. All had `SourceInferenceReady = FALSE`.

## Execution-record limitation

Post-execution review found that the consumed authorization row was validated
in memory but was not embedded in the saved result bundle. The result retains
the runner identity and manifest but not the target-bound authorization row or
its process ID. This does not change the negative decision, but it means the
artifact would not have been sufficient acceptance evidence even if its
scientific decision had passed. No post-hoc reconstructed authorization is
treated as the consumed record.

## Consequence and next lineage

V3 remains useful negative calibration evidence but is not a candidate-ready
general numerical gate. The opened confirmation fixtures must never be reused
as independent v3 confirmation. They may inform a prospective v4 calibration
that defines representation-aware inclusive-boundary classification before
any new result is opened. V4 must also embed the exact consumed authorization
record in its output.

Any v4 boundary allowance must be derived from floating-point error analysis,
not selected merely to include this observed excess. It should distinguish a
mathematically constructed boundary from genuinely out-of-envelope retained
solutions, preserve analytic/Jacobian checks everywhere, and be frozen before
new disjoint fixtures are generated. A later v4 confirmation requires another
structurally disjoint fixture set. Large simulation is neither required nor
authorized by this failure.
