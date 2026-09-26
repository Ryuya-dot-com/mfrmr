# Plot facet variability diagnostics using base R

Plot facet variability diagnostics using base R

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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_chisq_table.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
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

  If `TRUE`, draw with base graphics.

- title:

  Plot title. Omit it to keep the default, supply one character string
  to replace it, or use `NULL` (or `""`) to suppress it. This changes
  only the heading; numerical results, reference lines, subtitles and
  interpretation notes remain. Both `main` and `title` explicitly
  supplied is an error, even if equal or `NULL`. Positional legacy
  arguments retain their order; use the exact name `title`.

## Value

A plotting-data object of class `mfrm_plot_data`.

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

Set `options(mfrmr.plot_preset = "publication")` to choose a session
default for plotting functions that expose the common `preset` argument.
The supported values are `"standard"`, `"publication"`, `"compact"` and
`"monochrome"`. Precedence is an explicit call argument, then the
session option, then `"standard"`. For example, `preset = "standard"`
overrides a session set to `"monochrome"`. Explicit `preset = NULL`
retains the earlier package-default behavior; it does not read the
session option. Invalid session values cause an error only when that
option is needed.

The category-curve, data-quality, fit-review, connectivity and network
routes of [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
report bundles use the same option through `...`. Plots without a common
`preset` argument, including extended-model plots with their own
`palette` controls, keep their own settings. This option selects a
preset, not a universal theme or a guarantee that all renderers
implement every appearance control identically.

New plot payloads retain the resolved preset for supported saved-data
rendering. Converting an existing payload with
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
uses its saved appearance, even after the session option changes. A call
that creates a new plot from a fit or statistical result uses the
current default. For a reproducible script, supply `preset` explicitly
or set the option in that script. Saving only the fitted model does not
save a session option. No global ggplot theme is changed.

Restore previous settings with
`old <- options(mfrmr.plot_preset = "monochrome")` followed by
`options(old)`. Use `options(mfrmr.plot_preset = NULL)` to remove the
option. The preset changes appearance, not estimates, confidence levels
or diagnostic thresholds.

## See also

[`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_chisq_table.md),
[`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
p <- plot_facets_chisq(fit, draw = FALSE)
if (interactive()) {
  plot_facets_chisq(
    fit,
    draw = TRUE,
    plot_type = "fixed",
    preset = "publication",
    main = "Facet Chi-square (Customized)",
    palette = c(fixed_ok = "#2b8cbe", fixed_flag = "#cb181d"),
    label_angle = 45
  )
}
# }
```
