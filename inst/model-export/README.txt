Bayesian RSM/PCM model exported by mfrmr

Run Rscript run.R from this directory. Export itself requires neither Stan nor
brms. Estimation requires CmdStanR and CmdStan; the brms format also needs brms.
Review and adjust the run script for your computing resources. The scripts
request four chains and retain diagnostics. Inspect divergences, R-hat,
effective sample sizes and posterior predictive fit before interpreting draws.

For the Stan format, run.R saves fit.rds before reporting and writes
parameter-summary.csv (equal-tailed 95% credible bounds, endpoint Monte Carlo
SEs, R-hat and bulk/tail ESS) and sampler-diagnostics.csv (chain divergences,
maximum-tree-depth hits and E-BFMI). posterior-summary.rds retains both tables,
the interval level and interpretation notes. The parameter table distinguishes
reported parameters from free sampling coordinates. Run Rscript run.R --summarize
to replace these three reports using fit.rds without compiling or sampling;
CmdStanR/posterior are needed, but a CmdStan toolchain is not. Draws are unchanged.
This option is specific to the Stan run script, not the brms script.

Computed bounds remain visible when diagnostics warn. interval_computed means
finite bounds, not reliable sampling or calibrated coverage. Endpoint Monte
Carlo SE measures simulation error, distinct from posterior uncertainty.
endpoint_mcse_fraction divides the larger endpoint MCSE by interval width; no
universal acceptable fraction is imposed. Good precision for one target cannot
repair divergent transitions or poor exploration of other coordinates. Inspect
all coordinates and chains. Constant draws have NA diagnostics and fraction:
check whether a constraint fixes that component or sampling is stuck.

model-data.rds is a base-R list containing data, design matrices, mappings and
prior settings. levels.csv contains original Person and facet labels. Category
1 is the lowest source score; categories.csv provides the complete ladder,
including any unobserved declared categories. steps[g, k] is the offset for
transition k to k+1 for owner g; model-data.rds$step_owners gives owner labels.
Locations include the original sign separately: higher values decrease the
adjacent log odds for a facet with Sign = -1. The brms helper
extract_mfrm_parameters(fit) returns parameters on this same scale.

Both formats implement:
  log(P(Y=k+1) / P(Y=k)) = theta + signed facet locations - step[k].
This is the logistic metric (L-metric), with scaling constant D = 1 and no
extra 1.7 or 1.702 normal-ogive approximation factor. Increasing ability by
one unit increases adjacent-category log odds by one, holding other values
fixed. This response-link convention is distinct from the ability prior.
Abilities independently follow normal(0,1), retaining the source MML population
scale without centering the observed Persons. Centered facet locations and
each owner's steps sum to zero. Steps need not be ordered. Centered components
use an orthonormal contrast basis with independent normal coordinates scaled
by sqrt(m/(m-1)); each of the m components then has the marginal prior SD
recorded in model-data.rds$priors. A centered singleton is fixed at zero.
Uncentered locations have independent normal priors with the recorded SD.

These structural priors are explicit Bayesian additions to MML. Posterior
credible intervals do not reproduce or validate MML confidence intervals.
Inspect prior sensitivity. To change priors coherently in either format, change
the location_sd and step_sd coordinate scales in model-data.rds$stan_data;
the priors field is descriptive metadata and should be updated as well.

The brms custom family uses the same adjacent-category likelihood, constraints
and priors as the direct Stan model. Its posterior_epred() returns category
probabilities. posterior_predict() and log_lik() are also supplied and survive
saving/reloading the fitted object. Predictions and pointwise log likelihoods
condition on sampled abilities for existing Persons; these are not new-Person
predictions or leave-one-Person-out validation. Repeated rows retain the
source model's conditional-independence assumption.

The exporter supports ordinary unanchored, unit-weight RSM/PCM MML sources
without population regression, interactions, dummy facets or shrinkage.
Two-family GPCM has a separate Stan-only export; this RSM/PCM bundle does not
implement it. JML, testlet and random-rater export remain unsupported. Export does not
certify source convergence or subsequent sampling. Only retained observations
are exported; omitted input rows and the original optimizer are not replayed.

The bundle contains ratings and original labels. Review before sharing.
Official documentation:
https://mc-stan.org/cmdstanr/
https://mc-stan.org/learn-stan/diagnostics-warnings.html
https://mc-stan.org/posterior/reference/mcse_quantile.html
https://paulbuerkner.com/brms/articles/brms_customfamilies.html
