# Export a measurement model to Stan or brms

Write a self-contained Bayesian model bundle without running an
estimator. Supply either a fitted native MML `mfrm_fit` (`fit`) or a
long-format rating `data` table with a model specification list (`spec`)
so ordinary RSM/PCM and one-family GPCM bundles can be written directly
without MML optimization, Hessian evaluation, or EAP scoring. Supports
ordinary RSM/PCM and fixed-population one-family GPCM in both formats.
Estimated-population one-family GPCM (both `fit` and `spec` routes) and
two-family GPCM (`fit` route) use Stan. Fixed facet/group and step
anchors are retained. Sources must be unit-weight, with a fixed
standard-normal Person population or (Stan only, one-family GPCM) an
estimated intercept-only normal population, and no facet interactions or
post-fit shrinkage. Unsupported specifications fail before files are
written.

## Usage

``` r
export_mfrm_model(
  fit = NULL,
  output_dir,
  format = c("stan", "brms"),
  location_prior_sd = 1,
  step_prior_sd = 1,
  overwrite = FALSE,
  acknowledge_sensitive = FALSE,
  log_slope_prior_sd = 1,
  population_prior = list(mean = c(0, 1), log_sd = c(0, 0.5)),
  data = NULL,
  spec = NULL,
  write_json = FALSE,
  run_cmdstan = FALSE,
  cmdstan_args = list()
)
```

## Arguments

- fit:

  Optional native RSM/PCM or GPCM MML `mfrm_fit` returned by
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).
  Supply either `fit`, or `data` together with `spec`.

- output_dir:

  Destination directory. The bundle includes observed ratings and
  original level labels; review it before sharing.

- format:

  Either `"stan"` (CmdStanR) or `"brms"` (custom family).

- location_prior_sd:

  Positive marginal prior SD for each varying facet location; fixed or
  uniquely determined locations have zero prior SD.

- step_prior_sd:

  Positive marginal prior SD for each varying step offset.

- overwrite:

  Replace bundle files that already exist? Defaults to `FALSE`.

- acknowledge_sensitive:

  Suppress the reminder that ratings and original identifiers are
  included. Defaults to `FALSE`.

- log_slope_prior_sd:

  Positive marginal prior SD of each component log slope for GPCM
  export. Defaults to 1; inspect prior sensitivity. Not used by RSM/PCM
  models.

- population_prior:

  Normal prior parameters for an estimated Person population: a named
  list with `mean = c(location, scale)` for its mean and
  `log_sd = c(location, scale)` for the log of its standard deviation.
  Each scale must be positive. Defaults give `mu ~ normal(0, 1)` and
  `log(sigma) ~ normal(0, 0.5)`. Unused for fixed-population exports.

- data:

  Optional long-format rating `data.frame` used with `spec` to export
  directly from rating data without fitting an MML model first.

- spec:

  Optional named list defining the measurement model when `data` is
  supplied (the same 33-key `spec` shared with
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/describe_mfrm_data.md),
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/review_mfrm_anchors.md),
  and
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)).
  Required entries are `person`, `facets`, and `score`. Supported
  optional entries match
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md):
  `model` (`"RSM"` default, `"PCM"`, or `"GPCM"`), `method` (`"MML"`
  only), `step_facet` (required for `"GPCM"`, not applicable to
  `"RSM"`), `slope_facet` (one declared facet for `"GPCM"`),
  `gpcm_mml_identification` (`"free_population"` default or
  `"fixed_standard_normal"`, `"GPCM"` only), `anchors`, `group_anchors`,
  `anchor_policy` (`"error"` default before writing files, `"warn"`, or
  `"silent"`), `min_common_anchors`, `min_obs_per_element`,
  `min_obs_per_category`, `noncenter_facet` (`"Person"` default),
  `centering_scope` (`"facet"` default or `"remainder"`),
  `positive_facets`, `rating_min`, `rating_max`, `category_policy`
  (`"collapse"` or `"preserve"`), `keep_original`, `missing_codes`,
  `weight` (unit weights only), and `repeated_ratings` (`"review"`
  default or `"independent"`). Unsupported model extensions
  (`population_formula`, `facet_interactions`, `dummy_facets`) or
  numerical `control` entries fail closed before files are written.

- write_json:

  Logical; if `TRUE` (for `format = "stan"` only), also write
  CmdStanR-compatible `model-data.json` alongside `model-data.rds` and
  the CSV label/category maps, without requiring `cmdstanr` or
  `jsonlite`. Defaults to `FALSE`.

- run_cmdstan:

  Logical; if `TRUE` (for `format = "stan"` only), compile and sample
  the exported Stan bundle immediately via `cmdstanr` using the bundle's
  `run.R` helper, persist `fit.rds`, `predictive-draws.rds`,
  `posterior-summary.rds`, `posterior-draws.rds`, and CSV diagnostic
  tables, and attach the validated `mfrm_posterior_summary` object as
  `$posterior`. Requires both the `cmdstanr` package and a configured
  CmdStan installation; fails before writing files when either is
  absent. Defaults to `FALSE`.

- cmdstan_args:

  Optional named list of sampling arguments forwarded to `cmdstanr`'s
  `$sample()` when `run_cmdstan = TRUE` (allowed entries: `seed`,
  `chains`, `parallel_chains`, `iter_warmup`, `iter_sampling`,
  `adapt_delta`, `max_treedepth`, `refresh`, `show_messages`,
  `show_exceptions`, `init`). `data` and `output_dir` are bound to the
  exported bundle and cannot be overridden. Defaults to
  [`list()`](https://rdrr.io/r/base/list.html).

## Value

Invisibly, a list with `format`, `model`, `output_dir` and named `files`
(plus `posterior`, a validated
[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/read_mfrm_posterior.md)
object with joint draws attached, when `run_cmdstan = TRUE`). When
`run_cmdstan = FALSE` (default), no model is fitted and no external
software is required.

## Details

The default one-family GPCM estimates its population mean and variance.
Its intercept-only population can be exported to Stan, retaining the
native metric, relative-slope constraint and supported fixed anchors.
The generated model uses `theta = mu + sigma * z`, with independent
standard-normal `z`. The population mean and SD are sampled, not fixed
at their MML estimates. `population_prior` adds explicit Bayesian
priors: by default sigma has median 1 and a central 95% prior interval
of approximately 0.38 to 2.66. These are starting assumptions, not a
population-size recommendation; inspect prior predictions and
sensitivity for your rubric and anchors. The displayed Person prior SD
includes uncertainty in both mu and sigma, not only sigma. Population
regression, estimated-mean models with a fixed SD, and
estimated-population brms or two-family exports are not supported.
Choosing `gpcm_mml_identification = "fixed_standard_normal"` changes the
model; it is not a file-format conversion or a workaround for these
exclusions.

Both formats retain the category ladder, facet signs, facet centering
and RSM/PCM step ownership of the source specification. RSM/PCM
adjacent-category log odds are `theta + signed facet locations - step`.
Steps follow their declared within-owner sum targets (zero by default)
and are **not ordered**. A binary ladder has its single offset fixed at
its target. Fixed-population ability parameters have independent
standard-normal priors; realized abilities are not centered across the
observed Persons in either population mode.

All supported exports preserve the native logistic metric (L-metric),
with scaling constant \\D = 1\\. No extra 1.7 or 1.702 factor is used.
Standard-normal ability priors do not imply a normal-ogive response
link. The "Logistic metric (D = 1)" section of
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
explains the scale and the adjustments needed before comparing other
parameterizations.

Centered locations and steps use an orthonormal contrast basis.
Independent normal coordinates are scaled so each constrained component
has the requested marginal SD. A centered singleton is fixed at zero.
Uncentered locations have independent normal priors. These proper
structural priors are additions to MML: the Bayesian posterior is not a
reproduction of MML point estimates or frequentist confidence intervals.
Review prior sensitivity for the application.

Two-family GPCM is available with `format = "stan"` only. Its effective
slope is the product of the two component slopes and multiplies the
entire adjacent-category predictor, including locations and steps. The
first family's log slopes sum to zero; the second family's log slopes
are free on the fixed N(0,1) ability scale. Normal priors on
orthonormal/free log-slope coordinates give each component the specified
marginal log-slope SD. `slope-levels.csv` maps the generated
`component_slopes` and `log_component_slopes` to their owners and
levels. This preserves the source likelihood, not an MML interval or the
exact priors/program of Uto and Ueno (2020). In particular, the extra
1.7 multiplier in their Appendix is absent. Additional fixed additive
facets and separate step/noncentered roles are supported from an
existing two-family fit. Extended bundles retain these roles in
`model-data.rds$model_roles` and in the posterior reader. The
geometric-mean-one reference is the source fit's `slope_reference`.
Exporting a fit with another reference and fresh independent log-slope
priors changes the Bayesian model; it is not a prior-preserving
coordinate transformation. Direct `data`/`spec` export and new-Person
posterior scoring remain unsupported for two-family models. One-family
GPCM supports both formats. Its single owner's log slopes sum to zero
(geometric mean one); its slope also multiplies the entire predictor. A
singleton slope owner is fixed at one.

Fixed non-Person facet anchors, group means and step anchors are exact
affine constraints. The export preserves whole-facet versus remainder
centering and each step owner's target. Priors on the remaining free
contrasts are centered so each free level shares its block's remaining
total equally. These priors are defined on the constrained subspace, not
obtained by conditioning an earlier unanchored posterior. `levels.csv`
and `steps.csv` in these bundles record the affine prior means, marginal
SDs and fixed-coordinate indicators; `model-data.rds$constraints`
retains the source constraints. One-family bundles use the same affine
representation even without anchors. Anchors are fixed inputs: zero
posterior spread does not establish certainty about their earlier
calibration. Uncertain external calibration is not propagated. Retained
step constraints are exported; this does not add a step-anchor fitting
argument. Native two-family fitting retains its anchor exclusion. Person
anchors require JML in native fitting and remain outside this MML
exporter.

`model-data.rds` records the design matrices, priors and mappings used
by both formats. When `write_json = TRUE` (`format = "stan"` only),
`model-data.json` also serializes `model-data.rds$stan_data` using
CmdStanR's JSON array/scalar rules so external Stan runners can read the
data without R; keep `model-data.rds` and the CSV files for label
mappings and
[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/read_mfrm_posterior.md).
`levels.csv` maps original labels to generated parameters;
`categories.csv` maps Stan/brms categories to the source score scale.
`run.R` fits the exported model and saves draws, diagnostics and
replicated ratings. Run it from the bundle directory, after installing
CmdStanR/CmdStan and, for the brms format, brms. Neither is required to
export a bundle. Both formats support `Rscript run.R --summarize` to
regenerate summaries from `fit.rds` without compiling or sampling. Keep
`model-data.rds`, `summarize.R` and the brms `model.R` with the saved
fit. Read `summary-decision.csv` first, then `sampling-review.csv` for
the checks, criteria and next actions. `parameter-summary.csv` joins
original labels to estimates, references and score-direction notes.
`value_role` distinguishes estimated values, fixed anchors and
constraint-determined values. Fixed values have no estimated SD or
interval (`NA`); they do not establish zero external calibration
uncertainty. Varying parameters retain equal-tailed 95% credible bounds,
endpoint MCSE, R-hat and bulk/tail ESS, even during review, with
`interval_status` beside the values. `interval_computed` means finite
bounds for a varying parameter, not reliable sampling or coverage.
`sampler-diagnostics.csv` contains per-chain diagnostics;
`posterior-summary.rds` retains all four tables and interpretation
notes, and `posterior-draws.rds` stores the matching base-R
chain-by-iteration parameter draws bound by checksum for contrasts and
arbitrary credible levels.

The screen checks at least four chains, R-hat below 1.01, bulk/tail ESS
at least 100 per chain, zero divergences/tree-depth hits and E-BFMI at
least 0.3. Missing diagnostics require review; fixed coordinates are
excluded using model constraints, not sample variance. Tree-depth hits
flag efficiency separately from divergences. These checks follow the
[Stan diagnostic
guidance](https://mc-stan.org/learn-stan/diagnostics-warnings.html) and
are not a certificate of validity. Review all varying coordinates, model
fit and priors. The larger endpoint MCSE divided by interval width
measures simulation precision; no universal acceptable fraction is
imposed. Read the matching summary, joint draws and model-data files
with
[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/read_mfrm_posterior.md)
to use [`summary()`](https://rdrr.io/r/base/summary.html),
[`confint()`](https://rdrr.io/r/stats/confint.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) and
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_report.md)
without either sampling backend. Keep `fit.rds` for posterior predictive
replay and backend-specific tools. Generated brms callbacks support
`log_lik()`, `posterior_predict()` and `posterior_epred()`; the last
returns category probabilities.

Log likelihood and replicated ratings condition on the sampled abilities
of existing Persons. They do not provide leave-one-Person-out validation
or predictions for new Persons; use
[`predict.mfrm_posterior_summary()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict.mfrm_posterior_summary.md)
to score new Persons against the saved calibration posterior without
updating calibration parameters. Exporting does not qualify the original
fit's convergence, inference, or an external sampler's diagnostics.
Repeated ratings retain the source conditional-independence assumption.

## References

Uto, M., & Ueno, M. (2020). A generalized many-facet Rasch model and its
Bayesian estimation using Hamiltonian Monte Carlo. *Behaviormetrika,
47*, 469-496.
[doi:10.1007/s41237-020-00115-7](https://doi.org/10.1007/s41237-020-00115-7)
. Equation 9, Sections 6-7 and Appendix.

## See also

[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/export_mfrm_results.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/read_mfrm_posterior.md),
[`predict.mfrm_posterior_summary()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict.mfrm_posterior_summary.md)

## Examples

``` r
# Each row in example_core is one integer rating (Person x Rater x Criterion).
ratings <- load_mfrmr_data("example_core")
# Illustrative fixed reference; applications need justified calibration values.
anchor <- data.frame(Facet = "Rater",
                     Level = as.character(ratings$Rater[1]), Anchor = 0)
# Direct specification export builds the Stan bundle and CmdStan JSON data
# without running native MML optimization, Stan, or brms.
spec <- list(
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  model = "GPCM",
  step_facet = "Criterion",
  slope_facet = "Criterion",
  anchors = anchor
)
stan <- export_mfrm_model(
  output_dir = tempfile("mfrmr-stan-"),
  format = "stan",
  acknowledge_sensitive = TRUE,
  data = ratings,
  spec = spec,
  write_json = TRUE
)
names(stan$files) # Inspect levels.csv, categories.csv, model-data.rds/json, and README.txt
#>  [1] "model-data.rds"   "model-data.json"  "levels.csv"       "categories.csv"  
#>  [5] "model.stan"       "run.R"            "README.txt"       "slope-levels.csv"
#>  [9] "steps.csv"        "summarize.R"     
bundle <- readRDS(stan$files[["model-data.rds"]])
bundle$categories # Generated categories mapped to original scores
#>   Category InternalScore Score
#> 1        1             1     1
#> 2        2             2     2
#> 3        3             3     3
#> 4        4             4     4
bundle$population # Estimated mean/SD and their priors
#> $mode
#> [1] "estimated_normal"
#> 
#> $formula
#> [1] "~1"
#> 
#> $parameterization
#> [1] "noncentered"
#> 
#> $prior
#> $prior$mean
#> [1] 0 1
#> 
#> $prior$log_sd
#> [1] 0.0 0.5
#> 
#> 
#> $person_levels
#>  [1] "P001" "P002" "P003" "P004" "P005" "P006" "P007" "P008" "P009" "P010"
#> [11] "P011" "P012" "P013" "P014" "P015" "P016" "P017" "P018" "P019" "P020"
#> [21] "P021" "P022" "P023" "P024" "P025" "P026" "P027" "P028" "P029" "P030"
#> [31] "P031" "P032" "P033" "P034" "P035" "P036" "P037" "P038" "P039" "P040"
#> [41] "P041" "P042" "P043" "P044" "P045" "P046" "P047" "P048"
#> 
#> $source_identification
#> [1] "free_population_scale_with_geometric_mean_one_relative_slopes"
#> 
bundle$priors
#> $ability
#> [1] "normal(population_mean, population_sd); conditionally independent"
#> 
#> $location_marginal_sd
#> [1] 1
#> 
#> $step_marginal_sd
#> [1] 1
#> 
#> $log_slope_marginal_sd
#> [1] 1
#> 
#> $anchor_basis
#> [1] "Conditional on fixed anchors and group means; normal free contrasts about the affine prior means."
#> 
#> $population
#> $population$mean
#> [1] 0 1
#> 
#> $population$log_sd
#> [1] 0.0 0.5
#> 
#> 
unlink(stan$output_dir, recursive = TRUE)

# An existing native MML fit can also be exported directly:
if (FALSE) { # \dontrun{
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                model = "GPCM", method = "MML", step_facet = "Criterion",
                slope_facet = "Criterion", anchors = anchor,
                anchor_policy = "silent")
from_fit <- export_mfrm_model(fit, tempfile("mfrmr-fit-stan-"), "stan",
                              acknowledge_sensitive = TRUE)
unlink(from_fit$output_dir, recursive = TRUE)
} # }
```
