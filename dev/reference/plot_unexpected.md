# Plot unexpected responses with ggplot2

Plot unexpected responses with ggplot2

## Usage

``` r
plot_unexpected(
  x,
  diagnostics = NULL,
  abs_z_min = 3,
  prob_max = 0.3,
  top_n = 100,
  rule = c("residual", "either", "both"),
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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
  or
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  when `x` is `mfrm_fit`.

- abs_z_min:

  Absolute standardized-residual cutoff (default 3).

- prob_max:

  Maximum observed-category probability cutoff.

- top_n:

  Maximum rows used from the unexpected table.

- rule:

  Flagging rule: `"residual"` (default), `"either"`, or `"both"`.

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

This helper visualizes flagged observations from
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md).
An observation is "unexpected" when its standardised residual and/or
observed-category probability exceed user-specified cutoffs.

The **severity index** is a composite ranking metric that combines the
absolute standardised residual \\\|Z\|\\ and the negative log
probability \\-\log\_{10} P\_{\mathrm{obs}}\\. Higher severity indicates
responses that are more surprising under the fitted model.

Saved table bundles retain their recorded rule and thresholds. A fully
evaluated screen with no flags returns an empty display and its summary.
The `rule` parameter controls flagging logic:

- `"residual"`: flag by the absolute standardized residual alone.

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
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).

2.  Start with `"scatter"` to assess global unexpected pattern.

3.  Switch to `"severity"` for case prioritization.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-visual-diagnostics.md).

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

[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md),
[plot(x, type =
"fair_average")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"displacement")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"qc")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_unexpected", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "unexpected", abs_z_min = 1.5, prob_max = 0.4, top_n = 10, draw = FALSE)
if (interactive()) {
  plot(fit, type = "unexpected", abs_z_min = 1.5, prob_max = 0.4,
    top_n = 10, view = "severity", preset = "publication",
    main = "Unexpected Response Severity (Customized)",
    palette = c(higher = "#d95f02", lower = "#1b9e77", bar = "#2b8cbe"),
    label_angle = 45)
}
} # }
```
