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
  draw = TRUE
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

  Optional custom plot title.

- palette:

  Optional named color overrides (`higher`, `lower`, `bar`).

- label_angle:

  X-axis label angle for `"severity"` bar plot.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, draw with base graphics.

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

## See also

[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md),
[`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
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
}
```
