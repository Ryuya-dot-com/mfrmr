# Plot facet variability diagnostics with ggplot2

Plot facet variability diagnostics with ggplot2

## Usage

``` r
plot_facets_chisq(
  x,
  diagnostics = NULL,
  fixed_p_max = 0.05,
  random_p_max = 0.05,
  plot_type = c("fixed", "random", "variance"),
  main = NULL,
  palette = NULL,
  label_angle = 45,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  title = NULL
)
```

## Arguments

- x:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
  or
  [`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_chisq_table.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  when `x` is `mfrm_fit`.

- fixed_p_max:

  Warning cutoff for fixed-effect chi-square p-values.

- random_p_max:

  Warning cutoff for random-effect chi-square p-values.

- plot_type:

  `"fixed"`, `"random"`, or `"variance"`.

- main:

  Compatibility title argument. Omitted or `NULL` keeps the default
  title. Existing calls remain supported without a deprecation warning.
  For new code, prefer `title`; do not supply both arguments.

- palette:

  Optional named color overrides (`fixed_ok`, `fixed_flag`, `random_ok`,
  `random_flag`, `variance`).

- label_angle:

  X-axis label angle for bar-style plots.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, print the `ggplot` object.

- title:

  Plot title. Omit it to keep the default, supply one character string
  to replace it, or use `NULL` (or `""`) to suppress it. This changes
  only the heading; numerical results, reference lines, subtitles and
  interpretation notes remain. Both `main` and `title` explicitly
  supplied is an error, even if equal or `NULL`. Positional legacy
  arguments retain their order; use the exact name `title`.

## Value

Invisibly, a `ggplot` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
to retrieve its reusable plotting data and notes.

## Details

Facet chi-square tests assess whether the elements within each facet
differ significantly.

**Fixed-effect chi-square** tests the null hypothesis \\H_0: \delta_1 =
\delta_2 = \cdots = \delta_J\\ (all element measures are equal). A
flagged result (\\p \<\\ `fixed_p_max`) suggests detectable
between-element spread under the fitted model, but it should be
interpreted alongside design quality, sample size, and other
diagnostics.

**Random-effect chi-square** tests whether element heterogeneity exceeds
what would be expected from measurement error alone, treating element
measures as random draws. A flagged result is screening evidence that
the facet may not be exchangeable under the current model.

**Random variance** is the estimated between-element variance component
after removing measurement error. It quantifies the magnitude of true
heterogeneity on the logit scale.

## Plot types

- `"fixed"` (default):

  Bar chart of fixed-effect chi-square by facet. Bars colored red when
  the null hypothesis is rejected at `fixed_p_max`. A flagged (red) bar
  means the facet shows spread worth reviewing under the fitted model.

- `"random"`:

  Bar chart of random-effect chi-square by facet. Bars colored red when
  rejected at `random_p_max`.

- `"variance"`:

  Bar chart of estimated random variance (logit\\^2\\) by facet.
  Reference line at 0. Larger values indicate greater true heterogeneity
  among elements.

## Interpreting output

Colored flags reflect configured p-value thresholds (`fixed_p_max`,
`random_p_max`). For the fixed test, a flagged (red) result suggests
facet spread worth reviewing under the current model. For the random
test, a flagged result is screening evidence that the facet may
contribute non-trivial heterogeneity beyond measurement error.

## Typical workflow

1.  Review `"fixed"` and `"random"` panels for flagged facets.

2.  Check `"variance"` to contextualize heterogeneity.

3.  Cross-check with inter-rater and element-level fit diagnostics.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/facets_chisq_table.md),
[plot(x, type =
"agreement")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"qc")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_facets_chisq", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "facets_chisq", draw = FALSE)
if (interactive()) {
  plot(fit, type = "facets_chisq", draw = TRUE, view = "fixed",
    preset = "publication", main = "Facet Chi-square (Customized)",
    palette = c(fixed_ok = "#2b8cbe", fixed_flag = "#cb181d"),
    label_angle = 45)
}
} # }
```
