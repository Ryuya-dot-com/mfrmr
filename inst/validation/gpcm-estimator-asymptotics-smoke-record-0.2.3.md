# GPCM JML/MML estimator-asymptotics smoke record for mfrmr 0.2.3

Status: five matched data cells and ten estimator fits executed; directional
smoke only; replicated pilot, incidental-bias conclusion, estimator selection,
bias correction, Bayesian implementation decision, and release promotion not
authorized.

Execution date: 2026-08-14

Environment: Windows, R 4.5.1, locally rebuilt mfrmr 0.2.3, `lpSolve` 5.6-23.
The test library was rebuilt for Windows. No Mac library, local installation
path, file bytes, serialized-object digest, SHA, or MD5 value entered the data-
identity or result decision.

## Execution

The repository-only
`gpcm-estimator-asymptotics-0.2.3.R` smoke used one generating seed, q=9 for
MML, and `maxit=100`. One maximum crossed GPCM response table supplied five
nested cells:

| Cell | Persons | Observations per Person | Rows | Connected Rater graph |
|---|---:|---:|---:|---:|
| N024-L08 | 24 | 8 | 192 | yes |
| N048-L08 | 48 | 8 | 384 | yes |
| N096-L08 | 96 | 8 | 768 | yes |
| N048-L16 | 48 | 16 | 768 | yes |
| N048-L24 | 48 | 24 | 1,152 | yes |

All five design contracts passed. The smaller cells were exact row subsets of
the larger cells, and all cells retained identical Rater, Criterion, step, and
slope truth. This relationship was checked semantically in memory rather than
through machine-specific hashes.

## Fit status

All ten fits returned objects. All five MML fits and four of five JML fits
reported optimizer convergence. The N096-L08 JML fit reached the compact smoke
iteration limit and contained one extreme Person; the corresponding MML fit
also observed that extreme response pattern but returned a finite EAP Person
summary and converged numerically.

Every fit remained `InferenceReady=FALSE`. JML retained an incomplete joint-
boundary audit and MML retained an unevaluated marginal slope-boundary state.
Therefore none of the recovery values below is inferential evidence.

## Diagnostic truth recovery

The table reports aligned RMSE over all non-Person facet coordinates, all
within-Criterion step coordinates, and the separately labelled optimizer log-
slope trace.

| Cell | Method | Facet RMSE | Step RMSE | Optimizer log-slope RMSE |
|---|---|---:|---:|---:|
| N024-L08 | JML | 0.317 | 0.546 | 0.564 |
| N024-L08 | MML | 0.229 | 0.348 | 0.371 |
| N048-L08 | JML | 0.275 | 0.310 | 0.282 |
| N048-L08 | MML | 0.242 | 0.354 | 0.169 |
| N096-L08 | JML | 0.183 | 0.289 | 0.249 |
| N096-L08 | MML | 0.128 | 0.316 | 0.140 |
| N048-L16 | JML | 0.150 | 0.209 | 0.134 |
| N048-L16 | MML | 0.117 | 0.227 | 0.152 |
| N048-L24 | JML | 0.128 | 0.167 | 0.115 |
| N048-L24 | MML | 0.107 | 0.169 | 0.116 |

The N096-L08 JML row is additionally caveated because its optimizer did not
meet the smoke convergence gate. Every optimizer slope row is explicitly
stored as `ineligible_optimizer_trace_only`.

## Interpretation

At fixed N=48, increasing exposure from 8 to 16 to 24 observations per Person
reduced facet, step, and optimizer-slope RMSE monotonically for JML. The same
direction held for MML except that the first slope movement was smaller and
not monotonic relative to every component. At fixed exposure of eight,
increasing Persons generally reduced RMSE, but the JML N=96 fit did not clear
the compact optimizer budget and the MML facet/step paths were not strictly
monotonic at every adjacent N.

This is consistent with the importance of within-Person information, but it
does not demonstrate a nonzero JML asymptotic bias or establish MML dominance.
One replicate cannot distinguish systematic bias from sample-specific
movement, and q=9 / `maxit=100` are smoke controls rather than final numerical
settings.

The next evidential step is the already guarded 20-replicate pilot. Its purpose
is to estimate coordinate-specific trends and Monte Carlo uncertainty, not to
choose an estimator after inspecting this smoke. A Bayesian comparator remains
a separate prior/model stratum and is neither required nor rejected by this
result.

```text
IncidentalBiasDecision = not_assigned_replicated_pilot_required
EstimatorSelectionAuthorized = FALSE
BiasCorrectionAuthorized = FALSE
BayesianEstimatorRequired = NA
ConfirmationAuthorized = FALSE
```
