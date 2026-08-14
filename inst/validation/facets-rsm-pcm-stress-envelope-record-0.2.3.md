# FACETS RSM/PCM stress-envelope record for mfrmr 0.2.3

## Question

Do the already-open pilot seeds support a first truth-first check of large,
sparse, and 10--30-facet JML designs without turning optimizer completion or
FACETS availability into an accuracy claim?

## Frozen pilot envelope

`facets-rsm-pcm-stress-envelope-0.2.3.R` defines six scenarios and crosses
them with RSM and PCM. The one-seed run used base seed 451001; RSM and PCM used
design seeds 451002 and 451003. These seeds were already open before this
stress run. Confirmation seeds remained inaccessible.

| Scenario | Persons | Rows | Total facets | Role |
| --- | ---: | ---: | ---: | --- |
| `MFS-LARGE-F5` | 1,000 | 40,000 | 5 | row and level capacity |
| `MFS-SPARSE-DISTRIBUTED-F5` | 1,000 | 10,000 | 5 | connected distributed sparse graph |
| `MFS-SPARSE-WEAK-BRIDGE-F5` | 1,000 | 10,000 | 5 | two rater blocks joined by six bridge Persons |
| `MFS-DISCONNECTED-F5` | 1,000 | 10,000 | 5 | structural negative control |
| `MFS-MANY-F10` | 200 | 6,400 | 10 | facet-count growth |
| `MFS-MANY-F30` | 200 | 12,800 | 30 | facet-count growth |

The runner retains parameter identities, truth, estimates, errors, Bias, MAE,
and RMSE. A single seeded error summary is descriptive recovery, not a Monte
Carlo bias estimate. Recovery rows from a fit that misses the numerical gate
remain in the denominator with `RecoveryEligible = FALSE` and cannot support a
performance claim.

## External execution state

All 12 FACETS launches returned code 5 before producing a report. This was not
classified as nonconvergence or numerical disagreement. A subsequent 640-row,
53-element fixed-information control that had succeeded earlier on 2026-08-14
also returned code 5. Probes at 800, 1,200, 1,960, 2,000, and 2,040 rows did the
same. The common failure therefore cannot be attributed to the new row count,
element count, sparse topology, or facet count from this evidence. It is an
unresolved local FACETS execution-state failure.

The [official FACETS page](https://www.winsteps.com/facets.htm) describes the
full version as supporting far larger
analyses and the free MINIFAC version as limited to 2,000 responses. Neither
description identifies the observed code-5 state, and the successful 640-row
control later failed unchanged. No license-capacity diagnosis is inferred.
The external large/sparse/many-facet comparison remains unexecuted.

## Independent mfrmr result

The first stress adapter incorrectly allowed a FACETS entrance failure to
prevent mfrmr fitting. The corrected adapter runs mfrmr independently and uses
a typed `mfrmr_estimability_error`, rather than message matching, for the
disconnected negative control. Both disconnected RSM and PCM designs were
rejected before optimization at nullity one, so neither became falsely ready.

At `maxit = 400`, only the 10-facet PCM case passed the package's complete
numerical gate. Three sparse fits reached the iteration limit. Six other fits
returned optimizer code zero but retained a terminal-gradient sup norm above
the fixed `1e-4` review threshold.

| Scenario | Model | Gradient at 400 | Code at 400 | Gradient at 800 | Code at 800 | Gate at 800 |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Large F5 | RSM | 0.000783974 | 0 | 0.000783974 | 0 | review |
| Large F5 | PCM | 0.001173623 | 0 | 0.001173623 | 0 | review |
| Sparse distributed F5 | RSM | 0.475658 | 1 | 0.000186109 | 0 | review |
| Sparse distributed F5 | PCM | 0.00388592 | 1 | 0.000399110 | 0 | review |
| Sparse weak bridge F5 | RSM | 0.000152096 | 0 | 0.000152096 | 0 | review |
| Sparse weak bridge F5 | PCM | 0.380122 | 1 | 0.0000600776 | 0 | pass |
| Many F10 | RSM | 0.000121420 | 0 | 0.000121420 | 0 | review |
| Many F10 | PCM | 0.0000588971 | 0 | 0.0000588971 | 0 | pass |
| Many F30 | RSM | 0.000212349 | 0 | 0.000212349 | 0 | review |
| Many F30 | PCM | 0.000180062 | 0 | 0.000180062 | 0 | review |

Increasing the ceiling to 800 converted all three iteration-limit fits to code
zero and made weak-bridge PCM numerically eligible. For the seven cases already
at code zero under 400, every retained estimate was exactly unchanged at 800;
increasing `maxit` cannot affect a route that has already stopped.

The three explicit optimizer routes for 10-facet RSM did not clear the gate.
The best retained gradients were 0.000121420 for the auto/L-BFGS-B route and
0.000146024 for explicit BFGS. The bounded polish histories reached essentially
the same objective (`-logLik` about 6962.948) with maximum final-stage parameter
changes below `5e-8` for the selected fits. This points to a mismatch between
the optimizer stopping surface and the common raw-gradient review, not a
simple lack of iterations or a preference for BFGS.

## Interpretation and next step

No readiness threshold was relaxed. The one-seed recovery values for the two
ready PCM cases remain diagnostic only, and the other finite estimates remain
review-only. In particular, this run does not establish JML bias, large-design
accuracy, FACETS equivalence, or a FACETS replacement boundary.

The next bounded question is whether the terminal free-coordinate gradient is
the correct scale for a dataset-size-invariant readiness gate. That review
must compare analytic and independent numeric scores, expanded element score
residuals, objective change, and parameter change at the retained solution.
Only after that audit may the package keep, rescale, or supplement the `1e-4`
gate. More seeds or a larger `maxit` would not answer this question.
