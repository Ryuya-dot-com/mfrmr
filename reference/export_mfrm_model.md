# Export a measurement model to Stan or brms

Write a self-contained Bayesian model bundle (`model.stan` / `model.R`,
`model-data.rds`, optional `model-data.json`, label/category CSV maps,
and `run.R` / `summarize.R`) from either a native MML `fit` or
long-format `data`

- `spec`, using the native logistic metric (\\D = 1\\).

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

- fit, data, spec:

  Supply either a fitted MML
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  `fit` (ordinary RSM/PCM, one-family GPCM, or Stan-only two-family
  GPCM) or long-format `data` with a shared `spec` list (unit weights,
  no `population_formula`, `facet_interactions`, `dummy_facets`, or
  post-fit shrinkage; `anchor_policy` defaults to `"error"`).

- output_dir, format, overwrite, acknowledge_sensitive:

  Destination directory (includes observed ratings and IDs), target
  backend (`"stan"` or `"brms"`), overwrite flag (`FALSE`), and privacy
  reminder toggle (`FALSE`).

- location_prior_sd, step_prior_sd, log_slope_prior_sd,
  population_prior:

  Marginal normal prior SDs on orthonormal/free location, step, and GPCM
  log-slope coordinates (`1` defaults), plus
  `list(mean = c(0, 1), log_sd = c(0, 0.5))` for estimated
  intercept-only GPCM Person populations in Stan.

- write_json, run_cmdstan, cmdstan_args:

  For `format = "stan"`, write CmdStanR `model-data.json` (`FALSE`
  default), optionally compile/sample via `cmdstanr` immediately
  (`FALSE` default), and pass validated `$sample()` arguments (`seed`,
  `chains`, `iter_warmup`, `iter_sampling`, `adapt_delta`,
  `max_treedepth`, etc.).

## Value

Invisibly, a list with `format`, `model`, `output_dir`, `files`, and
(when `run_cmdstan = TRUE`) `$posterior`.

## Details

Centered blocks use orthonormal contrast bases so each constrained
coordinate has the requested marginal prior SD (`Fixed` anchors and
group/step constraints enter as exact affine offsets with `NA` posterior
SDs). Generated summaries (`posterior-summary.rds` and checksum-bound
`posterior-draws.rds`) screen `>= 4` chains, `R-hat < 1.01`, bulk/tail
`ESS >= 100` per chain, `0` divergences/treedepth hits, and
`E-BFMI >= 0.3`, connecting to
[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md)
and
[`predict.mfrm_posterior_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_posterior_summary.md)
(Uto & Ueno, 2020,
[doi:10.1007/s41237-020-00115-7](https://doi.org/10.1007/s41237-020-00115-7)
).

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md),
[`predict.mfrm_posterior_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_posterior_summary.md)

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
