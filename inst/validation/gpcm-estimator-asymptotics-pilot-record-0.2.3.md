# GPCM estimator-asymptotics pilot record for mfrmr 0.2.3

Date: 2026-08-14

Status: completed 20-replicate calibration pilot; descriptive numerical
evidence only. No estimator selection, bias correction, Bayesian requirement,
confirmation design, or release promotion is authorized.

## Execution

The guarded `pilot` profile in
`gpcm-estimator-asymptotics-0.2.3.R` was run under Windows with R 4.5.1, a
locally rebuilt mfrmr 0.2.3, lpSolve 5.6-23, `quad_points=31`, and
`maxit=300`. The run used 20 prespecified seeds, five nested cells, and both
JML and MML, for 200 fits. The final execution took 1,011 seconds.

No file digest, serialized-object identity, package-library path, operating
system identity, SHA, or MD5 value entered a scientific assertion. The runner
checked the realized design, response nesting, truth, and fit states directly.

- all 100 JML and all 100 MML calls returned fit objects;
- MML optimizer convergence was 100/100;
- JML optimizer convergence was 98/100;
- both JML nonconvergences were `N240-L08`, replicates 9 and 10, at the
  iteration limit;
- no fit returned an error condition;
- 17 fits retained explicit optimizer-review warnings;
- all 200 fits remained `InferenceReady=FALSE`; and
- every fit had `BoundaryState=not_evaluated`.

The readiness result is not a 200/200 empirical failure of the fitted values.
GPCM nonlinear-rank evidence and the applicable JML/MML boundary audit are not
currently promoted into a complete readiness route. `attach_diagnostics=FALSE`
does not cause this state.

## Mean within-replicate recovery RMSE

Each value below is the mean of 20 replicate-specific component RMSE values.
Slope values are optimizer log-slope traces and remain inferentially
ineligible.

| Cell | Method | Criterion facet | Rater facet | Step | Optimizer log slope |
|---|---|---:|---:|---:|---:|
| N060-L08 | JML | .2194 | .2157 | .4044 | .2984 |
| N060-L08 | MML | .1620 | .1761 | .3050 | .1824 |
| N120-L08 | JML | .2089 | .1622 | .3025 | .2034 |
| N120-L08 | MML | .1489 | .1277 | .2129 | .1170 |
| N240-L08 | JML | .2001 | .1285 | .2424 | .1648 |
| N240-L08 | MML | .1413 | .0913 | .1387 | .0898 |
| N120-L16 | JML | .1587 | .0665 | .1654 | .0758 |
| N120-L16 | MML | .1324 | .0612 | .1359 | .0658 |
| N120-L24 | JML | .1530 | .0506 | .1204 | .0624 |
| N120-L24 | MML | .1359 | .0493 | .1049 | .0534 |

At fixed exposure, moving from 60 to 240 Persons reduced step RMSE by .1620
(95% Monte Carlo interval [-.2019, -.1222]) for JML and .1663
[-.2149, -.1177] for MML. At 120 Persons, moving from 8 to 24 observations per
Person reduced step RMSE by .1821 [-.2262, -.1380] for JML and .1081
[-.1399, -.0762] for MML. Both information routes therefore improved numerical
recovery over the finite range studied.

## Paired JML-minus-MML step comparison

A positive difference means that MML had the lower within-replicate RMSE.
These are descriptive paired contrasts, not an estimator-selection rule.

| Cell | Step difference | 95% MC interval | MML lower rate |
|---|---:|---:|---:|
| N060-L08 | .0994 | [.0584, .1404] | .80 |
| N120-L08 | .0896 | [.0543, .1249] | .85 |
| N240-L08 | .1037 | [.0714, .1360] | .90 |
| N120-L16 | .0295 | [.0136, .0454] | .80 |
| N120-L24 | .0156 | [.0034, .0277] | .75 |

MML's numerical advantage was largest when each Person had only eight
observations and narrowed as within-Person exposure increased. The same broad
pattern appeared in the optimizer log-slope trace, but that trace is not a
primary inferential slope estimate.

The `N240-L08` step contrast was .1014 [.0677, .1351] when restricted to the
18 replicates in which both methods converged, versus .1037 in the all-returned-
fit analysis above. The two JML iteration-limit cases therefore did not explain
the paired step-recovery difference.

## Coordinate-specific step error

Pooled signed bias is prohibited because the within-owner step coordinates
sum to zero and can cancel algebraically. The table therefore reports the
mean absolute coordinate-specific mean error and the number of the 12 step
coordinates whose 20-replicate mean-error interval excluded zero.

| Cell | Method | Mean absolute coordinate error | Maximum | Intervals excluding zero |
|---|---|---:|---:|---:|
| N060-L08 | JML | .1879 | .3324 | 6/12 |
| N120-L08 | JML | .1765 | .3455 | 8/12 |
| N240-L08 | JML | .1663 | .2917 | 8/12 |
| N120-L16 | JML | .0818 | .1540 | 7/12 |
| N120-L24 | JML | .0539 | .1151 | 7/12 |
| N060-L08 | MML | .0476 | .1341 | 0/12 |
| N120-L08 | MML | .0432 | .1215 | 0/12 |
| N240-L08 | MML | .0311 | .0886 | 0/12 |
| N120-L16 | MML | .0236 | .0498 | 0/12 |
| N120-L24 | MML | .0214 | .0393 | 0/12 |

For JML, increasing Persons from 60 to 240 while retaining eight observations
per Person did not remove the coordinate-specific step signal. Increasing
within-Person exposure reduced its magnitude much more clearly. This is
consistent with an incidental-parameter concern under sparse Person exposure,
but N up to 240 and one generating regime do not establish a nonzero
asymptotic limit.

## MML population scale

The generating population truth was mean zero and variance one. It was not
replaced by the realized finite-sample moments of the simulated Persons.

| Cell | Mean bias | Mean RMSE | Variance bias | Variance RMSE |
|---|---:|---:|---:|---:|
| N060-L08 | -.0069 | .2872 | -.1067 | .2914 |
| N120-L08 | -.0103 | .2506 | -.0862 | .2296 |
| N240-L08 | -.0126 | .2607 | -.0501 | .1341 |
| N120-L16 | -.0047 | .2409 | -.0662 | .1804 |
| N120-L24 | -.0017 | .2426 | -.0330 | .1674 |

All population mean-error and variance-error intervals included zero. The
variance RMSE improved with both Persons and exposure. Population-mean RMSE,
however, remained around .24--.29 and did not show a clear information trend.
Consequently, correct optimizer convergence is not sufficient evidence that
every MML population-scale coordinate is already precise.

## Adjudication

1. **Optimizer problem:** present but localized. Two JML fits reached the
   iteration limit and terminal-gradient review warnings were more common for
   JML. MML returned optimizer convergence in every fit.
2. **JML incidental/weak-information signal:** present descriptively. Sparse
   fixed exposure retained coordinate-specific JML step error as Persons
   increased, while added within-Person exposure reduced it substantially.
3. **Readiness threshold:** not shown to be numerically too strict. The current
   route is incomplete for free-slope GPCM, so its uniform false result cannot
   discriminate good from poor simulated conditions. Lowering a tolerance
   would not repair missing rank/boundary evidence.
4. **Bayesian necessity:** neither established nor rejected. A prior can
   regularize sparse coordinates, but this pilot used a correctly specified
   normal MML population and did not study prior sensitivity or population
   misspecification.

The pilot supports using MML as the more stable numerical sensitivity lane for
this aligned single-owner GPCM design. It does not authorize replacing JML,
automatically selecting MML, or claiming that Bayesian estimation is required.

```text
IncidentalBiasDecision = pilot_completed_no_prespecified_decision_rule
EstimatorSelectionAuthorized = FALSE
BiasCorrectionAuthorized = FALSE
BayesianEstimatorRequired = NA
ConfirmationAuthorized = FALSE
```

The next essential question is whether the MML advantage survives population-
distribution misspecification. That requires a separate, small stress design
before any Bayesian comparison: normal, skewed, and finite-mixture ability
distributions with the same response design and structural truth.
