# Run exploratory residual PCA summaries

Legacy-compatible residual diagnostics can be inspected in two ways:

1.  overall residual PCA on the person x combined-facet matrix

2.  facet-specific residual PCA on person x facet-level matrices

## Usage

``` r
analyze_residual_pca(
  diagnostics,
  mode = c("overall", "facet", "both"),
  facets = NULL,
  pca_max_factors = 10L,
  parallel = FALSE,
  parallel_reps = 200L,
  parallel_quantile = 0.95,
  parallel_method = c("residual_permutation", "model_bootstrap"),
  seed = NULL
)

# S3 method for class 'mfrm_residual_pca'
plot(x, type = "scree", mode = "overall", ...)
```

## Arguments

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- mode:

  For `analyze_residual_pca()`: `"overall"`, `"facet"`, or `"both"`.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):
  `"overall"` (default) or `"facet"`. Do not also supply `mode` when
  using a prefixed `type` such as `"facet_scree"`.

- facets:

  Optional subset of facets. This selects the facet-specific analyses
  and the facets combined to define columns in the overall PCA.

- pca_max_factors:

  Maximum number of components retained for loadings, subject to matrix
  dimensions; `"auto"` caps this at 10. Variance tables retain the full
  eigenvalue spectrum, not only those loading columns.

- parallel:

  Logical; if `TRUE`, add a simulation reference to the PCA tables.

- parallel_reps:

  Number of permutations or simulated-and-refitted data sets when
  `parallel = TRUE`. Each model-bootstrap replicate requires a full fit.

- parallel_quantile:

  Upper reference quantile used as the exploratory comparison cutoff.
  The default (`0.95`) follows the common parallel analysis convention.

- parallel_method:

  Reference method. `"residual_permutation"` (default) permutes
  standardized residuals within each column, preserving residual
  distributions and missingness. `"model_bootstrap"` generates ratings
  and refits a supported RSM/PCM MML model; supply the original fit, not
  detached diagnostics. See Model-generated reference below for
  restrictions.

- seed:

  Optional integer seed for reproducible simulation. When supplied, the
  caller's random-number state is restored after the calculation.

- x:

  A result from `analyze_residual_pca()`.

- type:

  `"scree"`, `"parallel_scree"`, `"parallel_excess"`, or `"loadings"`.
  Existing `"overall_*"` and `"facet_*"` spellings remain supported.

- ...:

  `facet` selects a facet for `mode = "facet"` (default: the first
  available facet); `component = 1` selects a loading component;
  `top_n = 20` limits displayed loadings. `preset` is `"standard"`,
  `"publication"`, `"compact"`, or `"monochrome"`; `draw = FALSE`
  returns data without drawing.

## Value

A named list with:

- `mode`: resolved mode used for computation

- `facet_names`: facets analyzed

- `overall`: overall PCA bundle (or `NULL`)

- `by_facet`: named list of facet PCA bundles

- `overall_table`: variance table for overall PCA

- `by_facet_table`: stacked variance table across facets

- `parallel_settings`, `parallel_overall_table`,
  `parallel_by_facet_table`, and `parallel_status`: returned for every
  call; the parallel tables are populated when `parallel = TRUE`

- `bootstrap_trials`, `bootstrap_settings`: attempted replicate/scope
  records and generation settings for the model bootstrap; otherwise
  `NULL`.

- `errors`: explanations for unavailable overall or facet PCA analyses;
  unavailable analyses have empty variance tables.

- `warnings`: named list of non-fatal PCA warnings captured from the
  underlying PCA engine. These indicate exploratory boundary conditions,
  not confirmatory evidence.

- `InferenceTier`, `SupportsFormalInference`,
  `PrimaryReportingEligible`, `ReportingUse`, and `DecisionUse`:
  machine-readable guards that keep this route exploratory and prohibit
  an automatic dimensionality or subscore decision.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object whose `plot_data(p)` payload contains:

- `plot`: `"scree"`, `"parallel_scree"`, `"parallel_excess"`, or
  `"loadings"`

- `mode`: `"overall"` or `"facet"`

- `facet`: facet name (or `NULL`)

- `title`: plot title text

- `data`: underlying table used for plotting

- `InferenceTier`, `SupportsFormalInference`,
  `PrimaryReportingEligible`, `ReportingUse`, and `DecisionUse`:
  machine-readable exploratory-screening guards

## Details

Performs exploratory eigenvalue/loading PCA on pairwise-complete
standardized residual correlation matrices (`overall`
Person-by-combined-facet and/or `facet` Person-by-facet-level).
Undefined pairwise correlations or non-PSD matrices are recorded in
`errors` without zero-filling or smoothing.

With `parallel = TRUE`, `"residual_permutation"` permutes standardized
residuals within columns; `"model_bootstrap"` simulates conditionally
independent ratings and refits unanchored unit-weight RSM/PCM MML models
with fixed `N(0, 1)` ability, retaining all attempted replicates in
`bootstrap_trials` and withholding cutoffs (`ParallelMean`,
`ParallelCutoff`, `ExcessOverParallelCutoff`, `ExceedsParallelCutoff`)
if any replicate fails. Reference quantiles are exploratory
componentwise screens rather than multiplicity-calibrated dimensionality
tests; pass `residual_pca = "none"` to
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
when calling `analyze_residual_pca()` separately.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
saved residual PCA

Display a saved residual PCA or its saved parallel-analysis comparison.
Plotting does not generate a new parallel reference.

## Fitting before a separate PCA

Use `diagnose_mfrm(fit, residual_pca = "none")` when PCA will be
requested separately with `analyze_residual_pca(..., mode = "both")`,
avoiding duplicate PCA calculation. Inspect the tables/plots above with
the model's fit diagnostics.

## Reading PCA plots

Start with overall mode, then facet views. `"scree"` shows eigenvalues;
`"parallel_scree"` adds saved means/cutoffs, and `"parallel_excess"`
plots observed-minus-cutoff. First compute references with
`parallel = TRUE`; inspect `parallel_status`/`bootstrap_trials` and
distinguish permutation from refitted bootstrap. `"loadings"` selects
largest absolute loadings; read both signs and magnitudes. These reuse
the exploratory evidence described above; multiple views neither provide
independent evidence nor prove dimensionality.

## References

The residual-PCA idea follows the Rasch residual-structure literature,
especially Linacre's discussions of principal components of Rasch
residuals. The current `mfrmr` implementation should be interpreted as
an exploratory extension for many-facet workflows rather than as a
direct reproduction of a single FACETS/Winsteps output table.

The optional parallel analysis follows Horn's data-driven eigenvalue
comparison logic and later recommendations to compare observed
eigenvalues with high quantiles of a reference distribution. Here that
reference is generated by within-column permutation of standardized
residuals by default. The optional model bootstrap instead regenerates
ratings and refits the supported model. The cited factor-retention
literature does not calibrate either many-facet residual comparison as a
fitted-model test.

- Horn, J. L. (1965). A rationale and test for the number of factors in
  factor analysis. *Psychometrika*, 30, 179-185.
  [doi:10.1007/BF02289447](https://doi.org/10.1007/BF02289447) .

- Glorfeld, L. W. (1995). An improvement on Horn's parallel analysis
  methodology for selecting the correct number of factors to retain.
  *Educational and Psychological Measurement*, 55, 377-393.
  [doi:10.1177/0013164495055003002](https://doi.org/10.1177/0013164495055003002)
  .

- Hayton, J. C., Allen, D. G., & Scarpello, V. (2004). Factor retention
  decisions in exploratory factor analysis: A tutorial on parallel
  analysis. *Organizational Research Methods*, 7, 191-205.

- Timmerman, M. E., & Lorenzo-Seva, U. (2011). Dimensionality assessment
  of ordered polytomous items with parallel analysis. *Psychological
  Methods*, 16, 209-220.

- Linacre, J. M. (1998). *Structure in Rasch residuals: Why principal
  components analysis (PCA)?* Rasch Measurement Transactions,
  12(2), 636. <https://www.rasch.org/rmt/rmt122m.htm>

- Linacre, J. M. (1998). *Detecting multidimensionality: Which residual
  data-type works best?* Journal of Outcome Measurement, 2(3), 266-283.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[plot(x, type =
"residual_pca")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

`analyze_residual_pca()`,
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

## Examples

``` r
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- diagnose_mfrm(fit, residual_pca = "none")
pca <- analyze_residual_pca(diag, mode = "both")
# A fitted model is also accepted: analyze_residual_pca(fit, mode = "both").
summary(pca)
#> Residual PCA summary
#> 
#> Overview
#>  Analysis Facets Overall components Facet component rows
#>      both      2                 16                    8
#> 
#> Residual eigenvalues
#>  PC Eigenvalue Proportion
#>   1      2.114      0.132
#>   2      1.833      0.115
#>   3      1.706      0.107
#>   4      1.519      0.095
#>   5      1.290      0.081
#>   6      1.157      0.072
#>   7      1.098      0.069
#>   8      1.054      0.066
#>   9      0.949      0.059
#>  10      0.846      0.053
#> Residual PCA is exploratory residual-structure screening (overall and/or by facet), not a standalone dimensionality test or an automatic decision about dimensions or subscores. 
p <- plot(pca, type = "scree", mode = "overall", draw = FALSE)
head(plot_data(p, "data"))
#>   Component Eigenvalue Proportion Cumulative
#> 1         1   2.113557 0.13209732  0.1320973
#> 2         2   1.832887 0.11455546  0.2466528
#> 3         3   1.706239 0.10663995  0.3532927
#> 4         4   1.519039 0.09493995  0.4482327
#> 5         5   1.289992 0.08062450  0.5288572
#> 6         6   1.157287 0.07233045  0.6011876
# Optional permutation reference repeats the PCA calculation.
# example("analyze_residual_pca", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
pca_pa <- analyze_residual_pca(diag, mode = "overall", parallel = TRUE, parallel_reps = 10)
head(pca_pa$overall_table)
} # }
head(pca$overall_table)
#>   Component Eigenvalue Proportion Cumulative
#> 1         1   2.113557 0.13209732  0.1320973
#> 2         2   1.832887 0.11455546  0.2466528
#> 3         3   1.706239 0.10663995  0.3532927
#> 4         4   1.519039 0.09493995  0.4482327
#> 5         5   1.289992 0.08062450  0.5288572
#> 6         6   1.157287 0.07233045  0.6011876
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_residual_pca", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings_all <- load_mfrmr_data("example_core")
selected_people <- unique(ratings_all$Person)[1:24]
ratings <- ratings_all[
  ratings_all$Person %in% selected_people, , drop = FALSE]
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                method = "JML")
diag <- diagnose_mfrm(fit, residual_pca = "overall")
pca <- analyze_residual_pca(diag, mode = "overall")
plt <- plot(pca, type = "scree", draw = FALSE)
head(plot_data(plt, "data"))
# Ten replicates illustrate the display, not a stable reference cutoff.
pca_pa <- analyze_residual_pca(diag, mode = "overall", parallel = TRUE,
                               parallel_reps = 10, seed = 2026)
pa <- plot(pca_pa, type = "parallel_scree", draw = FALSE)
head(plot_data(pa, "data"))
plt_load <- plot(pca, type = "loadings", component = 1, draw = FALSE)
head(plot_data(plt_load, "data"))
if (interactive()) {
  plot(pca, type = "scree", preset = "publication")
}
} # }
```
