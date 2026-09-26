# Plot unexpected responses using base R

Plot unexpected responses using base R

## Usage

``` r
plot_unexpected(
  x,
  diagnostics = NULL,
  abs_z_min = 2,
  prob_max = 0.3,
  top_n = 100,
  rule = c("either", "both"),
  plot_type = c("scatter", "severity"),
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
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  when `x` is `mfrm_fit`.

- abs_z_min:

  Absolute standardized-residual cutoff.

- prob_max:

  Maximum observed-category probability cutoff.

- top_n:

  Maximum rows used from the unexpected table.

- rule:

  Flagging rule (`"either"` or `"both"`).

- plot_type:

  `"scatter"` or `"severity"`.

- main:

  Compatibility title argument. Omitted or `NULL` keeps the default
  title. Existing calls remain supported without a deprecation warning.
  For new code, prefer `title`; do not supply both arguments.

- palette:

  Optional named color overrides (`higher`, `lower`, `bar`).

- label_angle:

  X-axis label angle for `"severity"` bar plot.

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

This helper visualizes flagged observations from
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md).
An observation is "unexpected" when its standardised residual and/or
observed-category probability exceed user-specified cutoffs.

The **severity index** is a composite ranking metric that combines the
absolute standardised residual \\\|Z\|\\ and the negative log
probability \\-\log\_{10} P\_{\mathrm{obs}}\\. Higher severity indicates
responses that are more surprising under the fitted model.

The `rule` parameter controls flagging logic:

- `"either"`: flag if \\\|Z\| \ge\\ `abs_z_min` **or**
  \\P\_{\mathrm{obs}} \le\\ `prob_max`.

- `"both"`: flag only if **both** conditions hold simultaneously.

Under common thresholds, many well-behaved runs will produce relatively
few flagged observations, but the flagged proportion is design- and
model-dependent. Treat the output as a screening display rather than a
calibrated goodness-of-fit test.

## Plot types

- `"scatter"` (default):

  X-axis: standardized residual \\Z\\. Y-axis:
  \\-\log\_{10}(P\_{\mathrm{obs}})\\ (negative log of observed-category
  probability; higher = more surprising). Points colored orange when the
  observed score is *higher* than expected, teal when *lower*. Dashed
  lines mark `abs_z_min` and `prob_max` thresholds. Clusters of points
  in the upper corners indicate systematic misfit patterns worth
  investigating.

- `"severity"`:

  Ranked bar chart of the composite severity index for the `top_n` most
  unexpected responses. Bar length reflects the combined unexpectedness;
  labels identify the specific person-facet combination. Use for QC
  triage and case-level prioritization.

## Interpreting output

Scatter plot: farther from zero on x-axis = larger residual mismatch;
higher y-axis = lower observed-category probability. A uniform scatter
with few points beyond the threshold lines indicates fewer locally
surprising responses under the current thresholds.

Severity plot: focuses on the most extreme observations for targeted
case review. Look for recurring persons or facet levels among the top
entries—repeated appearances may signal rater misuse, scoring errors, or
model misspecification.

## Typical workflow

1.  Fit model and run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

2.  Start with `"scatter"` to assess global unexpected pattern.

3.  Switch to `"severity"` for case prioritization.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

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

[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md),
[`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
p <- plot_unexpected(fit, abs_z_min = 1.5, prob_max = 0.4, top_n = 10, draw = FALSE)
if (interactive()) {
  plot_unexpected(
    fit,
    abs_z_min = 1.5,
    prob_max = 0.4,
    top_n = 10,
    plot_type = "severity",
    preset = "publication",
    main = "Unexpected Response Severity (Customized)",
    palette = c(higher = "#d95f02", lower = "#1b9e77", bar = "#2b8cbe"),
    label_angle = 45
  )
}
# }
```
