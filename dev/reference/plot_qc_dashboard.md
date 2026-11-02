# Plot a QC dashboard with ggplot2

Plot a QC dashboard with ggplot2

## Usage

``` r
plot_qc_dashboard(
  fit,
  diagnostics = NULL,
  threshold_profile = "standard",
  thresholds = NULL,
  abs_z_min = 2,
  prob_max = 0.3,
  rater_facet = NULL,
  interrater_exact_warn = 0.5,
  interrater_corr_warn = 0.3,
  fixed_p_max = 0.05,
  random_p_max = 0.05,
  top_n = 20,
  draw = TRUE,
  preset = c("standard", "publication", "compact", "monochrome")
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).

- threshold_profile:

  Threshold profile name (`strict`, `standard`, `lenient`).

- thresholds:

  Optional named threshold overrides.

- abs_z_min:

  Absolute standardized-residual cutoff for unexpected panel.

- prob_max:

  Maximum observed-category probability cutoff for unexpected panel.

- rater_facet:

  Optional rater facet used in inter-rater panel.

- interrater_exact_warn:

  Warning threshold for inter-rater exact agreement.

- interrater_corr_warn:

  Warning threshold for inter-rater correlation.

- fixed_p_max:

  Warning cutoff for fixed-effect facet chi-square p-values.

- random_p_max:

  Warning cutoff for random-effect facet chi-square p-values.

- top_n:

  Maximum elements displayed in displacement panel.

- draw:

  If `TRUE`, print the `ggplot` object.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

## Value

Invisibly, a `ggplot` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
to retrieve its reusable plotting data and notes.

## Details

The dashboard draws nine QC panels in a 3\\\times\\3 grid:

|  |  |  |
|----|----|----|
| Panel | What it shows | Key reference lines |
| 1\. Category counts | Observed (bars) vs model-expected counts (line) | – |
| 2\. Infit vs Outfit | Scatter of element MnSq values | heuristic 0.5, 1.0, 1.5 bands |
| 3\. \|ZSTD\| histogram | Distribution of absolute standardised residuals | \|ZSTD\| = 2 |
| 4\. Unexpected responses | Standardised residual vs \\-\log\_{10} P\_{\mathrm{obs}}\\ | `abs_z_min`, `prob_max` |
| 5\. Fair-average gaps | Boxplots of (Observed - FairM) per facet | zero line |
| 6\. Displacement | Top absolute displacement values | \\\pm 0.5\\ logits |
| 7\. Inter-rater agreement | Exact agreement with expected overlay per pair | `interrater_exact_warn` |
| 8\. Fixed chi-square | Fixed-effect \\\chi^2\\ per facet | `fixed_p_max` |
| 9\. Separation & Reliability | Bar chart of separation index per facet | – |

`threshold_profile` controls warning overlays. Three built-in profiles
are available: `"strict"`, `"standard"` (default), and `"lenient"`. Use
`thresholds` to override any profile value with named entries.

For `GPCM`, the dashboard now reuses the residual-based diagnostics
stack and marks the fair-average panel unavailable rather than silently
reusing the Rasch-only compatibility calculation.

## Plot types

This function draws a fixed 3\\\times\\3 panel grid (no `plot_type`
argument). For individual panel control, use the dedicated helpers:
[plot(x, type =
"unexpected")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"fair_average")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"displacement")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"agreement")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md).

## Interpreting output

Recommended panel order for fast review:

1.  **Category counts + Infit/Outfit** (row 1): first-pass model
    screening. Category bars should roughly track the expected line;
    Infit/Outfit points are often reviewed against the heuristic 0.5–1.5
    band.

2.  **Unexpected responses + Displacement** (row 2): element-level
    outliers. Sparse points and small displacements are desirable.

3.  **Inter-rater + Chi-square** (row 3): facet-level comparability.
    Read these as screening panels: higher agreement suggests stronger
    scoring consistency, and significant fixed chi-square indicates
    detectable facet spread under the current model.

4.  **Separation/Reliability** (row 3): approximate screening precision.
    Higher separation indicates more statistically distinct strata under
    the current SE approximation.

Treat this dashboard as a screening layer; follow up with dedicated
helpers ([`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)) for detailed
diagnosis.

## Typical workflow

1.  Fit and diagnose model.

2.  Run [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
    one-page triage.

3.  Drill into flagged panels using dedicated functions.

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

[plot(x, type =
"unexpected")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"fair_average")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"displacement")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"agreement")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_visual_summaries.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_qc_dashboard", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Use the diagnostics saved with this fit
diagnostics <- example_fit$diagnostics

# Read the interpretation status before reviewing the quality-control (QC) panels
review <- summary(diagnostics)
review$decision

# Draw the dashboard and save its data
qc <- plot(fit, type = "qc", diagnostics = diagnostics)

# Inspect the counts behind the category panel
plot_data(qc, "category_stats")[, c("Category", "Count", "ExpectedCount")]
# Use focused plots such as plot(diagnostics, type = "marginal_fit") to investigate a panel
} # }
```
