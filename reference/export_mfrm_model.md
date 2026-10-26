# Export a measurement model to Stan or brms

Write a self-contained Bayesian model bundle without running an
estimator. Supports ordinary RSM/PCM and one-family GPCM MML fits in
both formats, and two-family GPCM in Stan. Fixed facet/group and step
anchors are retained. Sources must be unit-weight, with a fixed
standard-normal Person population and no facet interactions or post-fit
shrinkage. Unsupported specifications fail before files are written.

## Usage

``` r
export_mfrm_model(
  fit,
  output_dir,
  format = c("stan", "brms"),
  location_prior_sd = 1,
  step_prior_sd = 1,
  overwrite = FALSE,
  acknowledge_sensitive = FALSE,
  log_slope_prior_sd = 1
)
```

## Arguments

- fit:

  A native RSM/PCM or GPCM MML `mfrm_fit` returned by
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

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

## Value

Invisibly, a list with `format`, `model`, `output_dir` and named
`files`. No model is fitted and no software is installed.

## Details

The default one-family GPCM estimates its population mean and variance
and cannot currently be exported. Choosing
`gpcm_mml_identification = "fixed_standard_normal"` changes the model;
it is not a file-format conversion. Keep the original fit when its
estimated population is intended.

Both formats retain the category ladder, facet signs, facet centering
and RSM/PCM step ownership of the source specification. RSM/PCM
adjacent-category log odds are `theta + signed facet locations - step`.
Steps follow their declared within-owner sum targets (zero by default)
and are **not ordered**. A binary ladder has its single offset fixed at
its target. Ability parameters have independent standard-normal priors;
realized abilities are not centered across the observed Persons.

All supported exports preserve the native logistic metric (L-metric),
with scaling constant \\D = 1\\. No extra 1.7 or 1.702 factor is used.
Standard-normal ability priors do not imply a normal-ogive response
link. The "Logistic metric (D = 1)" section of
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
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
1.7 multiplier in their Appendix is absent. One-family GPCM supports
both formats. Its single owner's log slopes sum to zero (geometric mean
one); its slope also multiplies the entire predictor. A singleton slope
owner is fixed at one.

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
by both formats. `levels.csv` maps original labels to generated
parameters; `categories.csv` maps Stan/brms categories to the source
score scale. `run.R` fits the exported model and saves draws,
diagnostics and replicated ratings. Run it from the bundle directory,
after installing CmdStanR/CmdStan and, for the brms format, brms.
Neither is required to export a bundle. Both formats support
`Rscript run.R --summarize` to regenerate summaries from `fit.rds`
without compiling or sampling. Keep `model-data.rds`, `summarize.R` and
the brms `model.R` with the saved fit. Read `summary-decision.csv`
first, then `sampling-review.csv` for the checks, criteria and next
actions. `parameter-summary.csv` joins original labels to estimates,
references and score-direction notes. `value_role` distinguishes
estimated values, fixed anchors and constraint-determined values. Fixed
values have no estimated SD or interval (`NA`); they do not establish
zero external calibration uncertainty. Varying parameters retain
equal-tailed 95% credible bounds, endpoint MCSE, R-hat and bulk/tail
ESS, even during review, with `interval_status` beside the values.
`interval_computed` means finite bounds for a varying parameter, not
reliable sampling or coverage. `sampler-diagnostics.csv` contains
per-chain diagnostics; `posterior-summary.rds` retains all four tables
and interpretation notes.

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
imposed. Read the matching summary and model-data files with
[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md)
to use [`summary()`](https://rdrr.io/r/base/summary.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html), stored
credible intervals and
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
without either sampling backend. Keep `fit.rds` for joint-draw
calculations. Generated brms callbacks support `log_lik()`,
`posterior_predict()` and `posterior_epred()`; the last returns category
probabilities.

Log likelihood and replicated ratings condition on the sampled abilities
of existing Persons. They do not provide leave-one-Person-out validation
or predictions for new Persons. Exporting does not qualify the original
fit's convergence, inference, or an external sampler's diagnostics.
Repeated ratings retain the source conditional-independence assumption.

## References

Uto, M., & Ueno, M. (2020). A generalized many-facet Rasch model and its
Bayesian estimation using Hamiltonian Monte Carlo. *Behaviormetrika,
47*, 469-496.
[doi:10.1007/s41237-020-00115-7](https://doi.org/10.1007/s41237-020-00115-7)
. Equation 9, Sections 6-7 and Appendix.

## See also

[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_core")
# Illustrative fixed reference; applications need justified calibration values.
anchor <- data.frame(Facet = "Rater",
                     Level = as.character(ratings$Rater[1]), Anchor = 0)
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                 model = "GPCM", method = "MML", step_facet = "Criterion",
                 slope_facet = "Criterion",
                 gpcm_mml_identification = "fixed_standard_normal", anchors = anchor,
                 anchor_policy = "silent")
# Export runs without Stan or brms. The example data are synthetic.
stan <- export_mfrm_model(fit, tempfile("mfrmr-stan-"), "stan",
                           acknowledge_sensitive = TRUE)
brms <- export_mfrm_model(fit, tempfile("mfrmr-brms-"), "brms",
                           acknowledge_sensitive = TRUE)
names(stan$files)
#> [1] "model-data.rds"   "levels.csv"       "categories.csv"   "model.stan"      
#> [5] "run.R"            "README.txt"       "slope-levels.csv" "steps.csv"       
#> [9] "summarize.R"     
bundle <- readRDS(stan$files[["model-data.rds"]])
bundle$categories # Generated categories mapped to original scores
#>   Category InternalScore Score
#> 1        1             1     1
#> 2        2             2     2
#> 3        3             3     3
#> 4        4             4     4
bundle$priors
#> $ability
#> [1] "independent normal(0, 1)"
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
# Run each bundle's run.R separately if external sampling is wanted.
unlink(c(stan$output_dir, brms$output_dir), recursive = TRUE)
```
