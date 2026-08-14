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

## Fixed-point stationarity audit

The stress script now reconstructs the retained JML objective and analytic
gradient, compares selected coordinates with independent central differences,
and separately expands observed-minus-expected score residuals to every Person
and facet level. It then makes a one-coordinate local curvature probe at the
largest analytic gradient. This is a read-only diagnostic: it changes no fit,
readiness state, or threshold and does not apply the FACETS stopping rule.

All ten connected `maxit = 800` fits reproduced their stored objectives. The
maximum analytic-versus-numeric scaled-gradient difference was
`3.76e-7`, below the audit's implementation-only `1e-6` check. The table shows
why the unscaled gradient alone is not an adequate scientific interpretation
of the retained point.

| Scenario | Model | Free gradient | Worst block | Expanded element residual | Maximum mean residual | Local parameter change | Relative objective improvement |
| --- | --- | ---: | --- | ---: | ---: | ---: | ---: |
| Large F5 | RSM | 0.000783974 | Criterion | 0.000776387 | 0.000007318 | 0.000000156 | 1.50e-15 |
| Large F5 | PCM | 0.001173623 | Criterion | 0.001164372 | 0.000010762 | 0.000000250 | 3.38e-15 |
| Sparse distributed F5 | RSM | 0.000186108 | Rater | 0.000139769 | 0.000012724 | 0.000000339 | 2.95e-15 |
| Sparse distributed F5 | PCM | 0.000399110 | Aux04 | 0.000326811 | 0.000003522 | 0.000000067 | 1.21e-15 |
| Sparse weak bridge F5 | RSM | 0.000152096 | Aux04 | 0.000094719 | 0.000005523 | 0.000000027 | 1.76e-16 |
| Sparse weak bridge F5 | PCM | 0.000060078 | Rater | 0.000079963 | 0.000002960 | 0.000000111 | 5.24e-16 |
| Many F10 | RSM | 0.000121420 | Person | 0.000121420 | 0.000003794 | 0.000041419 | 3.61e-13 |
| Many F10 | PCM | 0.000058897 | Step | 0.000071147 | 0.000001737 | 0.000000364 | 1.57e-15 |
| Many F30 | RSM | 0.000212349 | Person | 0.000310539 | 0.000003318 | 0.000015296 | 1.23e-13 |
| Many F30 | PCM | 0.000180062 | Aux29 | 0.000118628 | 0.000001854 | 0.000000024 | 1.41e-16 |

The largest one-coordinate Newton-equivalent change was about `4.15e-5`
logits, and the largest relative objective improvement was about `3.62e-13`.
Several smaller objective changes are at floating-point resolution and should
not be ranked. The useful result is the envelope: no reviewed fit showed a
material local change, while the raw gradient increased with the amount of
information accumulated in a coordinate. The analytic gradient is therefore
implemented coherently, but a fixed raw-score cutoff is not dataset-size or
weight invariant and should not remain the sole numerical-readiness scale.

An exact replication transport supplies the decisive negative control. At a
fixed parameter vector, multiplying every likelihood weight by an integer
multiplies the complete objective and gradient by that integer and leaves the
MLE set unchanged. For the ready 10-facet PCM fit, the same retained point had
raw gradient `0.0000588971` at one copy, `0.0001177943` at two copies, and
`0.0005889714` at ten copies. The current raw gate therefore changed from
pass to review at two copies even though the estimand and maximizing parameter
set were identical. Reconstructed objective and gradient scaling agreed within
`1.03e-12`; the audit uses a separate implementation-only `1e-10` tolerance.
It records the counterfactual gate result but deliberately does not rewrite the
fit readiness state.

## Correlated information displacement

A second diagnostic computes the complete dense observed-information Hessian
by central differences of the analytic gradient and solves the correlated
Newton system. It is bounded to 300 free coordinates, so this run covers the
balanced 10- and 30-facet cases but not the roughly 1,000-coordinate large and
sparse cases. The Hessian is used for numerical displacement only, not standard
errors, intervals, or a readiness decision.

| Scenario | Model | Free coordinates | Minimum eigenvalue | Condition number | Full displacement | Diagonal displacement | Full/diagonal | Relative objective improvement |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Many F10 | RSM | 221 | 2.9058 | 1485.3 | 0.000041387 | 0.000041419 | 0.9992 | 7.39e-13 |
| Many F10 | PCM | 231 | 1.9630 | 2214.7 | 0.000021800 | 0.000021568 | 1.0107 | 1.37e-13 |
| Many F30 | RSM | 241 | 13.5888 | 616.5 | 0.000015960 | 0.000015296 | 1.0434 | 3.11e-13 |
| Many F30 | PCM | 251 | 9.5166 | 853.3 | 0.000012490 | 0.000012236 | 1.0208 | 9.57e-14 |

All four Hessians were positive definite under the diagnostic relative
eigenvalue tolerance. Predicted quadratic objective improvements agreed with
directly reevaluated improvements. Exact 1/2/10-fold likelihood scaling left
the full parameter-displacement vector unchanged within `1e-12`. In these
balanced facet-count cases, correlated directions therefore increased the
maximum local displacement by at most about 4.3%; there is no hidden large
weak-direction movement behind the raw-gradient review. These four observed
values are calibration evidence and are not a selected displacement cutoff.
Repeating every Hessian at free-coordinate difference steps `3e-4`, `1e-3`,
and `3e-3` changed the maximum displacement by at most `1.35e-6` relatively;
the largest relative range of the minimum eigenvalue was also `1.35e-6`.
The dense reference is therefore numerically stable enough to test a later
matrix-free implementation, without turning its observed maxima into rules.

## Interpretation and next step

No readiness threshold was relaxed. The one-seed recovery values for the two
ready PCM cases remain diagnostic only, and the other finite estimates remain
review-only. In particular, this run does not establish JML bias, large-design
accuracy, FACETS equivalence, or a FACETS replacement boundary.

The retained-point, replication, and moderate-size information audits answer
the immediate implementation and invariance questions but do not freeze a
replacement rule. The next bounded task is to extend the full-displacement
calculation to the roughly 1,000-coordinate large and sparse cases without
materializing a dense Hessian. A Hessian-vector conjugate-gradient prototype
must first reproduce the four dense solutions above and fail closed on weak or
non-positive curvature. Mean element score residual remains an interpretable
secondary quantity. Only after the sparse/topology cases are covered should
the package calibrate or replace the `1e-4` raw-gradient gate. More seeds or a
larger `maxit` would not answer this question.
