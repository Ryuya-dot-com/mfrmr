# Build facet variability diagnostics with fixed/random reference tests

Build facet variability diagnostics with fixed/random reference tests

## Usage

``` r
facets_chisq_table(
  fit,
  diagnostics = NULL,
  fixed_p_max = 0.05,
  random_p_max = 0.05,
  top_n = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).
  Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_compatibility_layer.md)
  for migration of saved diagnostics.

- fixed_p_max:

  Warning cutoff for fixed-effect chi-square p-values.

- random_p_max:

  Warning cutoff for random-effect chi-square p-values.

- top_n:

  Optional maximum number of facet rows to keep.

## Value

A named list with:

- `table`: facet-level chi-square diagnostics

- `summary`: one-row summary

- `thresholds`: applied p-value thresholds

## Details

This helper summarizes facet-level variability with fixed and random
chi-square indices for spread and heterogeneity checks.

## Interpreting output

- `table`: facet-level fixed/random chi-square and p-value flags.

- `summary`: full-family available/unavailable counts and
  screen-positive counts, before `top_n` limits displayed rows.

- `thresholds`: p-value criteria used for flagging.

Use this table together with inter-rater and displacement diagnostics to
distinguish global facet effects from local anomalies.

## Typical workflow

1.  Run `facets_chisq_table(fit, ...)`.

2.  Inspect `summary(chi)` then facet rows in `chi$table`.

3.  Visualize with [plot(x, type =
    "facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md).

## Output columns

The `table` data.frame contains:

- Facet:

  Facet name.

- Levels:

  Number of estimated levels in this facet.

- MeanMeasure, SD:

  Mean and standard deviation of level measures.

- FixedChiSq, FixedDF, FixedProb:

  Fixed-effect chi-square test (null hypothesis: all levels equal).
  Significant result means the facet elements differ more than
  measurement error alone.

- RandomChiSq, RandomDF, RandomProb, RandomVar:

  FACETS-form random spread index and reference tail area. It does not
  establish normality or random sampling: with equal SEs and positive
  adjusted variance the statistic is identically eligible-level count
  minus one, regardless of distributional shape. Full covariance is not
  propagated.

- FixedFlag, RandomFlag:

  Logical flags for significance.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interrater_agreement_table.md),
[plot(x, type =
"facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("facets_chisq_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
chi <- facets_chisq_table(fit)
summary(chi)
p_chi <- plot(chi, draw = FALSE)
p_chi$data$plot
} # }
```
