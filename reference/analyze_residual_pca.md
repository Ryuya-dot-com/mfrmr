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
  parallel_method = c("residual_permutation"),
  seed = NULL
)
```

## Arguments

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- mode:

  `"overall"`, `"facet"`, or `"both"`.

- facets:

  Optional subset of facets for facet-specific PCA.

- pca_max_factors:

  Maximum number of retained components.

- parallel:

  Logical; if `TRUE`, add residual-permutation parallel analysis to the
  PCA tables.

- parallel_reps:

  Number of residual permutations used when `parallel = TRUE`.

- parallel_quantile:

  Upper null quantile used as the exploratory comparison cutoff. The
  default (`0.95`) follows the common parallel analysis convention.

- parallel_method:

  Parallel-analysis null method. Currently `"residual_permutation"` is
  implemented: standardized residuals are permuted within each residual
  column, preserving each column's residual distribution and missingness
  pattern while breaking residual association.

- seed:

  Optional integer seed for reproducible residual permutations.

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

- `errors`: named list of any per-facet PCA errors that were caught and
  turned into `NA_real_` rows in the variance tables (e.g.,
  [`psych::principal()`](https://rdrr.io/pkg/psych/man/principal.html)
  failure on a near-singular residual matrix). The list is empty when
  every facet PCA succeeded.

- `warnings`: named list of non-fatal PCA warnings captured from the
  underlying PCA engine. These indicate exploratory boundary conditions,
  not confirmatory evidence.

## Details

The function works on standardized residual structures derived from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
When a fitted object from
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
is supplied, diagnostics are computed internally.

Conceptually, this follows the Rasch residual-PCA tradition of examining
structure in model residuals after the primary Rasch dimension has been
extracted. In `mfrmr`, however, the implementation is an **exploratory
many-facet adaptation**: it works on standardized residual matrices
built as person x combined-facet or person x facet-level layouts, rather
than reproducing FACETS/Winsteps residual-contrast tables one-to-one.

Residual PCA should therefore be reported as residual-structure
evidence, not as a formal proof of unidimensionality. It also should not
be described as DIMTEST or UNIDIM: those essential-unidimensionality
tests require a separate item-response-layer definition that is not
uniquely determined by a many-facet long data set. In applied MFRM
reporting, residual PCA is best triangulated with global residual fit,
element fit, and Q3-style local-dependence screens.

Output tables use:

- `Component`: principal-component index (1, 2, ...)

- `Eigenvalue`: eigenvalue for each component

- `Proportion`: component variance proportion

- `Cumulative`: cumulative variance proportion

When `parallel = TRUE`, the variance tables additionally include
data-driven null summaries:

- `ParallelMean`: mean permuted-residual eigenvalue

- `ParallelCutoff`: `parallel_quantile` cutoff of permuted eigenvalues

- `ExcessOverParallelCutoff`: observed eigenvalue minus the cutoff

- `ExceedsParallelCutoff`: whether the observed eigenvalue exceeds the
  permutation cutoff

The default `parallel_reps = 200` is intended as a practical review
setting. For stable final reporting of the 95% cutoff, use a larger
value when the residual matrix size makes that computationally
reasonable.

For `mode = "facet"` or `"both"`, `by_facet_table` additionally includes
a `Facet` column.

`summary(pca)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(pca)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_residual_pca`. Available types include `"overall_scree"`,
`"facet_scree"`, `"overall_parallel_scree"`, `"facet_parallel_scree"`,
`"overall_parallel_excess"`, `"facet_parallel_excess"`,
`"overall_loadings"`, and `"facet_loadings"`.

## Interpreting output

Use `overall_table` first:

- early components with noticeably larger eigenvalues or proportions
  suggest stronger residual structure that may deserve follow-up. Small
  early components can be described as evidence consistent with the
  specified one-dimensional facet structure only when fit and
  local-dependence screens tell the same story.

Then inspect `by_facet_table`:

- helps localize which facet contributes most to residual structure.

Finally, inspect loadings via
[`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md)
to identify which variables/elements drive each component.

## References

The residual-PCA idea follows the Rasch residual-structure literature,
especially Linacre's discussions of principal components of Rasch
residuals. The current `mfrmr` implementation should be interpreted as
an exploratory extension for many-facet workflows rather than as a
direct reproduction of a single FACETS/Winsteps output table.

The optional parallel analysis follows Horn's data-driven eigenvalue
comparison logic and later recommendations to compare observed
eigenvalues with high quantiles of an empirical null distribution.
Because `mfrmr` applies it to standardized Rasch-family residual
matrices, the null distribution is generated by within-column residual
permutation rather than by simulating raw item scores.

- Horn, J. L. (1965). A rationale and test for the number of factors in
  factor analysis. *Psychometrika*, 30, 179-185.

- Glorfeld, L. W. (1995). An improvement on Horn's parallel analysis
  methodology for selecting the correct number of factors to retain.
  *Educational and Psychological Measurement*, 55, 377-393.

- Hayton, J. C., Allen, D. G., & Scarpello, V. (2004). Factor retention
  decisions in exploratory factor analysis: A tutorial on parallel
  analysis. *Organizational Research Methods*, 7, 191-205.

- Timmerman, M. E., & Lorenzo-Seva, U. (2011). Dimensionality assessment
  of ordered polytomous items with parallel analysis. *Psychological
  Methods*, 16, 209-220.

- Linacre, J. M. (1998). *Structure in Rasch residuals: Why principal
  components analysis (PCA)?* Rasch Measurement Transactions, 12(2),
  636.

- Linacre, J. M. (1998). *Detecting multidimensionality: Which residual
  data-type works best?* Journal of Outcome Measurement, 2(3), 266-283.

- Eckes, T. (2005). Examining rater effects in TestDaF writing and
  speaking performance assessments: A many-facet Rasch analysis.
  *Language Assessment Quarterly*, 2(3), 197-221.

- Yamashita, T. (2024). An application of many-facet Rasch measurement
  to evaluate automated essay scoring: A case of ChatGPT-4.0. *Research
  Methods in Applied Linguistics*, 3(3), 100133.

- Uto, M. (2021). A multidimensional generalized many-facet Rasch model
  for rubric-based performance assessment. *Behaviormetrika*, 48(2),
  425-457.

- Aryadoust, V., Ng, L. Y., & Sayama, H. (2021). A comprehensive review
  of Rasch measurement in language assessment: Recommendations and
  guidelines for research. *Language Testing*, 38(1), 6-40.

- Tseng, W.-T. (2016). Measuring English vocabulary size via
  computerized adaptive testing. *Computers & Education*, 97, 69-85.

## Typical workflow

1.  Fit model and run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    with `residual_pca = "none"` or `"both"`.

2.  Call `analyze_residual_pca(..., mode = "both")`.

3.  Review `summary(pca)`, then plot scree/loadings.

4.  Cross-check with fit/misfit diagnostics before conclusions.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`plot_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_residual_pca.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "both")
pca <- analyze_residual_pca(diag, mode = "both")
pca2 <- analyze_residual_pca(fit, mode = "both")
summary(pca)
p <- plot_residual_pca(pca, mode = "overall", plot_type = "scree", draw = FALSE)
p$data$plot
head(p$data)
pca_pa <- analyze_residual_pca(diag, mode = "overall", parallel = TRUE, parallel_reps = 10)
head(pca_pa$overall_table)
head(pca$overall_table)
} # }
```
