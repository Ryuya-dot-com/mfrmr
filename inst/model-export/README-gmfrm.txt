Bayesian two-family GMFRM model exported by mfrmr

Run Rscript run.R from this directory after installing CmdStanR and CmdStan.
Export itself requires neither. The script requests four chains and retains
diagnostics. Review its resource settings and inspect divergences, R-hat,
effective sample sizes and posterior predictive fit before interpreting draws.

run.R saves fit.rds before reporting. parameter-summary.csv contains explicit
equal-tailed 95% credible bounds, endpoint Monte Carlo SEs (mcse_lower and
mcse_upper), R-hat and bulk/tail ESS. It includes both reported parameters and
free sampling coordinates, distinguished by role. sampler-diagnostics.csv
records divergences, maximum-tree-depth hits and E-BFMI for each chain.
posterior-summary.rds contains both tables, the interval level and notes.
Run Rscript run.R --summarize to rebuild these reports from fit.rds without
compiling or sampling; this needs CmdStanR/posterior but not a CmdStan toolchain.
It replaces the three report files and leaves the fitted draws unchanged.

Bounds remain visible when diagnostics warn. interval_computed means finite
endpoints, not satisfactory sampling or validated coverage. Endpoint MCSE is
simulation error of a reported bound; posterior SD describes uncertainty under
the model. endpoint_mcse_fraction is the larger endpoint MCSE divided by interval
width, not a coverage measure. Choose useful precision for your application;
no universal cutoff is imposed. Good target-specific precision does not repair
divergent transitions or poor exploration elsewhere. Increasing retained draws
does not by itself solve those problems or remove prior sensitivity. Constant
draws have NA diagnostics and fraction: check whether a model constraint fixes
that component or sampling is stuck. Review all free coordinates and chains.

The response likelihood retains the source specification:
  log(P(Y=k+1) / P(Y=k)) = a_first * a_second *
    (theta + signed facet locations - step[k]).
The product of slopes multiplies the whole adjacent-category predictor.
This is the logistic metric (L-metric), with scaling constant D = 1; no extra
1.7 or 1.702 factor is introduced. A one-unit ability increase changes each
adjacent-category log odds by a_first * a_second, holding other values fixed.
This response-link convention is distinct from the ability prior.
Abilities have independent normal(0,1) priors;
realized abilities are not centered across Persons. The first owner's log
slopes sum to zero, so its slopes have geometric mean one. Second-owner log
slopes are free. Locations retain their source signs and centering; each step
owner's offsets sum to zero and need not be ordered.

model-data.rds contains the design matrices, priors and mappings. levels.csv
maps Person and location labels; slope-levels.csv maps component_slopes and
log_component_slopes to owners and levels. Category 1 is the lowest source
score; categories.csv retains unused declared categories. steps[g,k] is the
offset for transition k to k+1; model-data.rds$step_owners identifies g.

The default marginal prior SD is 1 for locations, step offsets and component
log slopes. Centered blocks use orthonormal coordinates with SD multiplied by
sqrt(m/(m-1)); their constrained components have the declared marginal SD and
are dependent. Uncentered blocks use independent normal coordinates. These
are explicit proper Bayesian priors, not MML penalties or an empirical
coverage correction. Change location_sd, step_sd or log_slope_sd in
model-data.rds$stan_data for prior sensitivity; update $priors metadata too.

The model follows the product-slope response equation in Uto and Ueno (2020),
equation 9, DOI 10.1007/s41237-020-00115-7, while preserving the fitted mfrmr
constraints. It does not reproduce the article's Appendix program: that code
includes a 1.7 multiplier and applies densities to constrained components in
a different parameterization. The priors here are defined directly on free
normal coordinates; no lognormal density or Jacobian for an exponential
parameter change is needed. The exponentials are derived quantities.

Posterior credible intervals do not reproduce or validate MML confidence
intervals. This export does not establish sampling coverage, global
identification, convergence or the adequacy of the selected priors. Log
likelihood and replicated ratings condition on sampled abilities of existing
Persons; they are not new-Person predictions or leave-one-Person-out scores.
Repeated ratings retain the source conditional-independence assumption.

This format supports native, unanchored, unit-weight two-family GPCM MML
sources with fixed N(0,1), second-owner steps, and no population regression,
interactions, dummy facets or shrinkage. One-family GPCM and GPCM brms export
remain unsupported. Retained ratings are exported, not omitted input rows or
the original MML optimization. The bundle includes ratings and original labels;
review it before sharing.

Official documentation: https://mc-stan.org/cmdstanr/
https://mc-stan.org/learn-stan/diagnostics-warnings.html
https://mc-stan.org/posterior/reference/mcse_quantile.html
