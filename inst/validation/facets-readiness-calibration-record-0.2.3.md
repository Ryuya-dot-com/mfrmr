# Opened-seed JML readiness calibration for mfrmr 0.2.3

Status: descriptive calibration completed on 2026-08-15. No threshold was
selected, no fit readiness was changed, no confirmation seed was opened,
FACETS was not launched, and no FACETS replacement claim is authorized.

## Question

Does the fixed raw-gradient cutoff identify meaningful residual movement across
row growth, facet-count growth, and sparse topology, or does a
replication-invariant scale based on mean element residuals and
boundary-conditioned correlated displacement better describe the retained JML
point?

## Frozen opened-pilot scope

`facets-readiness-calibration-0.2.3.R` accepts only the six already-open base
seeds `451001`, `452001`, `452101`, `452201`, `452301`, and `452401`. It crosses
them with RSM and PCM and the six existing stress designs. The full run contains
72 cases:

- 12 cases each for 40,000-row capacity, 10 facets, 30 facets, distributed
  sparsity, weak-bridge sparsity, and the disconnected negative control;
- `maxit = 800` for every mfrmr fit;
- exact objective/gradient reconstruction and 1/2/10-fold likelihood
  replication transport;
- matrix-free observed-information displacement with relative residual
  tolerance `1e-8`, maximum 500 iterations, and Person-boundary conditioning;
- no external FACETS process and no numeric acceptance threshold.

The runner is dry-run by default. Execution does not retain fits unless
explicitly requested. Errors, warnings, typed structural rejection, optimizer
state, boundary-map state, audit state, and complete-case state remain separate.

## Execution result

The disconnected RSM and PCM controls were rejected before optimization in all
12 cases using typed `mfrmr_estimability_error` conditions. They were not
converted into numeric failures or false-ready cases.

The remaining 60 cases returned fits. Fifty-nine reported optimizer convergence;
weak-bridge PCM at base seed `452401` retained code 1 after its bounded polishing
stages and remains `optimizer_review`. Its small conditional displacement does
not override optimizer precedence.

For all 60 returned fits:

- stored and reconstructed objectives agreed;
- selected analytic and numeric gradients agreed;
- 1/2/10-fold likelihood replication transported correctly;
- the Person boundary-coordinate map was certified;
- the boundary-conditioned matrix-free solve converged; and
- the largest explicit relative linear-system residual was `9.95e-9`.

The 60 cases comprise 35 interior observations, 24 complete
boundary-conditioned observations, and one boundary case retained as
`optimizer_review`. No audit failure was relabelled as a small displacement.

## Scale comparison

Only 6 of 60 returned fits passed the fixed raw `1e-4` gradient gate. Every one
of those six changed gate result under exact likelihood replication, even
though constant replication leaves the MLE set unchanged. An always-failing
raw gate is not counted as positive invariance evidence.

Across the 60 returned fits, Spearman association with the
boundary-conditioned displacement was `0.590` for raw gradient and `0.842` for
the maximum absolute mean element residual. These are descriptive associations,
not threshold-selection statistics.

| Scenario | Model | Raw gate pass | Boundary cases | Maximum mean residual | Maximum conditional displacement | Maximum relative objective improvement |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Large F5 | RSM | 0/6 | 0 | 0.00002151 | 0.00044068 | 9.67e-12 |
| Large F5 | PCM | 0/6 | 1 | 0.00001076 | 0.00016457 | 2.80e-12 |
| Many F10 | RSM | 2/6 | 0 | 0.00000693 | 0.00004139 | 1.48e-12 |
| Many F10 | PCM | 1/6 | 0 | 0.00000764 | 0.00006497 | 2.37e-12 |
| Many F30 | RSM | 0/6 | 0 | 0.00000609 | 0.00004600 | 1.01e-12 |
| Many F30 | PCM | 0/6 | 0 | 0.00000359 | 0.00002788 | 3.54e-13 |
| Sparse distributed F5 | RSM | 1/6 | 6 | 0.00013386 | 0.00073471 | 1.08e-9 |
| Sparse distributed F5 | PCM | 0/6 | 6 | 0.00000887 | 0.00005481 | 3.97e-12 |
| Sparse weak bridge F5 | RSM | 1/6 | 6 | 0.00016953 | 0.00588241 | 2.80e-8 |
| Sparse weak bridge F5 | PCM | 1/6 | 6 | 0.00001015 | 0.00013494 | 1.08e-11 |

The displacement distribution over all 60 returned fits had median
`4.09e-5`, 90th percentile `1.51e-4`, 95th percentile `4.55e-4`, and maximum
`0.005882` logits. The maximum came from weak-bridge RSM at base seed `452301`;
base seed `452001` in the same cell reached `0.003738` logits. This repeated tail
is materially larger than the balanced, large, and PCM observations and must
remain topology-visible.

Thirty facets did not create a large local movement: all 12 F30 cases failed
the raw gate while their maximum conditional displacement stayed below
`4.61e-5` logits. Similarly, all 12 large cases failed the raw gate although
their maxima were `0.000441` and `0.000165` logits for RSM and PCM. The raw gate
therefore confounds accumulated score scale with meaningful parameter movement.

## Interpretation boundary

This calibration supports three conclusions only:

1. a fixed raw-gradient cutoff cannot remain the sole readiness scale;
2. mean element residual is a more promising replication-invariant screen in
   this opened sample; and
3. the final decision still needs correlated conditional displacement because
   weak-bridge RSM has a repeated upper tail that balanced designs do not show.

The observed maxima do not select their own cutoff and cannot retroactively pass
these 72 cases. Boundary classification, optimizer convergence, and structural
identification remain precedence gates. The next bounded task is to freeze a
future-only candidate decision rule and a disjoint confirmation design before
opening any confirmation response. That rule should report at least
`interior`, `boundary_limited`, `weak_link_sensitive`, `optimizer_review`, and
`structurally_unidentified` states rather than collapsing them to one Boolean.
