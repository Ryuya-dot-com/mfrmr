Bayesian RSM/PCM/GPCM model exported by mfrmr

Run Rscript run.R from this directory after installing CmdStanR and CmdStan;
the brms format also needs brms. Export itself runs no estimator. Review the
priors and runner settings before sampling. The bundle includes observed
ratings and original labels; review it before sharing.

The likelihood is adjacent-category logistic (D = 1):
  log(P(Y=k+1) / P(Y=k)) = effective_slope *
    (theta + signed facet locations - step[k]).
RSM/PCM use effective_slope = 1. A one-family GPCM uses its owner's slope,
whose log slopes sum to zero (geometric mean one). For two-family GPCM the
product of both slopes multiplies the entire predictor; only the first
family's log slopes sum to zero. Two-family GPCM is Stan-only. Abilities are
independent normal(0,1), without centering the realized Persons.

Fixed facet locations, group means and step anchors retain their source
values, units and centering convention. model-data.rds$constraints records
them. locations = location_offset + location_basis * location_free, and
the stacked step vector = step_offset + step_basis * step_free. Step rows
are ordered first by owner, then transition. These affine maps enforce the
constraints exactly, including parameters determined by the remaining sum.
Steps need not be ordered. There is no sampling of fixed coordinates.

Normal priors are specified on orthonormal free contrasts, centered at zero.
The affine prior mean shares the required remaining total equally among the
free levels in each centered block. Coordinate SDs are scaled so each varying
location, step or component log slope has the requested marginal prior SD.
Independent uncentered coordinates use that SD directly. Fixed or uniquely
determined levels instead have zero prior SD. These are declared priors on
the free subspace, not an automatic conditional prior from an earlier fit.
levels.csv and steps.csv give prior means, marginal SDs and Fixed indicators;
slope-levels.csv maps GPCM component slopes to their owners.

All inference conditions on the supplied anchors and group means. Their
zero posterior spread does not mean the earlier calibration was known without
error. This export does not propagate uncertain external calibration.
Person anchors and JML sources remain outside this MML exporter. Population
regression, non-unit weights, interactions, dummy facets, post-fit shrinkage,
testlets and random-rater models are not supported. This export does not add
a native step-anchor fitting argument or enable anchored two-family fitting.

The Stan run script saves fit.rds, predictive-draws.rds and interval/diagnostic
summaries. Rscript run.R --summarize rebuilds those summaries without sampling.
Equal-tail credible bounds, endpoint MCSE, R-hat and bulk/tail ESS retain their
separate meanings. Constant draws have unavailable sampling diagnostics;
compare them with the fixed-coordinate maps. Inspect all free coordinates,
chain diagnostics, prior sensitivity and posterior predictive fit. A finite
interval is not evidence of convergence or calibrated coverage.

The brms script saves fit.rds, parameters.rds and predictive-draws.rds; its
custom log_lik(), posterior_predict() and posterior_epred() callbacks survive
saved replay. row_id identifies the retained rating design, including its
step/slope owners. Predictions condition on sampled abilities of the existing
Persons and retained design rows; they are not new-Person predictions or
leave-one-Person-out scores. Repeated ratings retain conditional independence.

These proper structural priors are Bayesian additions to the response model;
posterior summaries do not reproduce MML estimates or confidence intervals.
Neither exporting nor completing chains validates the source fit's inference.
For prior sensitivity, change location_sd, step_sd or log_slope_sd in stan_data
and update the descriptive priors and mapping tables consistently.

https://mc-stan.org/cmdstanr/
https://mc-stan.org/learn-stan/diagnostics-warnings.html
https://paulbuerkner.com/brms/articles/brms_customfamilies.html
