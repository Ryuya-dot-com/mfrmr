# Facet-quality dashboard for facet-level screening

Build a compact dashboard for one facet at a time, combining facet
severity, misfit, central-tendency screening, and optional bias counts.

## Usage

``` r
facet_quality_dashboard(
  fit,
  diagnostics = NULL,
  facet = NULL,
  bias_results = NULL,
  severity_warn = 1,
  misfit_warn = NULL,
  central_tendency_max = NULL,
  bias_count_warn = 1L,
  bias_abs_t_warn = 2,
  bias_abs_size_warn = 0.5,
  bias_p_max = 0.05
)

# S3 method for class 'mfrm_facet_dashboard'
summary(object, digits = 3, top_n = 10, ...)

# S3 method for class 'mfrm_facet_dashboard'
plot(x, y = NULL, type = c("severity", "flags"), ...)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  for the same `fit`. Mismatched or outdated diagnostics are rejected.
  Recompute diagnostics after refitting; the model itself does not need
  to be fitted again.

- facet:

  Optional facet name. When `NULL`, the function tries to infer a
  rater-like facet and otherwise falls back to the first modeled facet.

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
  or a named list of such outputs. Non-matching bundles are skipped
  quietly.

- severity_warn:

  Absolute estimate cutoff used to flag severity outliers.

- misfit_warn:

  `NULL` (default) uses both bounds returned by
  [`mfrm_misfit_thresholds()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_misfit_thresholds.md),
  including any session options. A numeric value instead uses that upper
  cutoff and its reciprocal as the lower cutoff; it does not preserve
  the current lower bound. For example, `1.5` selects about 0.67–1.5,
  whereas the unmodified package defaults are 0.5–1.5.

- central_tendency_max:

  Legacy opt-in absolute estimate cutoff for marking facet estimates
  near the fitted origin. The default `NULL` disables this flag because
  origin proximity is not evidence that a rater avoids extreme score
  categories. Use
  [`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/data_quality_report.md)
  for observed category-use screening and
  [`rater_centrality_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/rater_centrality_table.md)
  for model-based indirect centrality indices.

- bias_count_warn:

  Minimum flagged-bias row count required to flag a level.

- bias_abs_t_warn:

  Absolute `t` cutoff used when deriving bias-row flags from a raw bias
  bundle.

- bias_abs_size_warn:

  Absolute bias-size cutoff used when deriving bias-row flags from a raw
  bias bundle.

- bias_p_max:

  Probability cutoff used when deriving bias-row flags from a raw bias
  bundle.

- object:

  Output from `facet_quality_dashboard()`.

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of flagged levels to preview.

- ...:

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Display
  controls from
  [`plot_facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_facet_quality_dashboard.md).

  For [`summary()`](https://rdrr.io/r/base/summary.html): Reserved for
  generic compatibility.

- x:

  A result from `facet_quality_dashboard()`.

- y:

  Ignored; present for generic compatibility.

- type:

  `"severity"` or `"flags"`.

## Value

An object of class `mfrm_facet_dashboard` (also inheriting from
`mfrm_bundle` and `list`). The object summarizes one target facet:
`overview` reports the facet-level screening totals, `summary` provides
aggregate estimates and flag counts, `detail` contains one row per facet
level with the computed screening indicators, `ranked` orders levels by
review priority, `flagged` keeps only levels requiring follow-up,
`bias_sources` records which bias-result bundles contributed to the
counts, `settings` stores the resolved thresholds, and `notes` gives
short interpretation messages about how to read the dashboard.

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_facet_dashboard`.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object carrying the dashboard payload and screening cautions
accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).

## Details

The dashboard screens individual facet elements across four
complementary criteria:

- **Severity**: elements with \\\|\mathrm{Estimate}\| \>\\
  `severity_warn` logits are flagged as unusually severe or lenient.

- **Misfit**: elements with Infit or Outfit MnSq outside the configured
  heuristic review band are flagged. The band defaults to the package
  pair returned by
  [`mfrm_misfit_thresholds()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_misfit_thresholds.md)
  (Linacre 0.5-1.5); pass `misfit_warn = 1.5` to keep the older
  symmetric \\\[1/\\`misfit_warn`\\,\\\\`misfit_warn`\\\]\\ form
  (0.67-1.5).

- **Reference proximity (legacy `CentralTendencyFlag` label)**: when
  `central_tendency_max` is supplied, elements with
  \\\|\mathrm{Estimate}\| \<\\ `central_tendency_max` logits are marked.
  This only describes proximity to the fitted origin and must not be
  interpreted as central-category use or restriction of range. Those are
  response-pattern questions; see
  [`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/data_quality_report.md)
  and
  [`rater_centrality_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/rater_centrality_table.md)
  for their distinct descriptive indices.

- **Bias**: elements involved in \\\ge\\ `bias_count_warn`
  screen-positive interaction cells (from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md))
  are flagged.

A **flag density** score counts how many enabled criteria each element
triggers. Elements flagged on multiple criteria warrant priority review
and may motivate training or a documented data-quality review; the
dashboard does not justify automatic row, person, or rater exclusion.

Default thresholds are screening heuristics. Prespecify and justify any
application-specific alternatives rather than treating them as universal
validity or acceptance criteria. `MissingMetrics` lists unavailable
estimate, SE, Infit or Outfit values. A severity or misfit flag is `NA`
when it cannot be evaluated (an observed misfit exceedance still flags
even if the other fit index is unavailable). `FlagCount` counts observed
flags only; zero is not a complete pass. `IncompleteLevels` counts
levels with any missing diagnostic. Bias counts describe supplied
results only, not tests of absence of bias. Fit-readiness restrictions
are retained in `fit_readiness`, `interpretation_status` and `notes`.
Review overlap with
[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/subset_connectivity_report.md)
and category use with
[`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/data_quality_report.md)
before interpreting between-rater differences.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize a
facet-quality dashboard

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot a
saved facet-quality dashboard

## Output

The returned object is a bundle-like list with class
`mfrm_facet_dashboard` and components:

- `facet`: character scalar naming the dashboard's target facet

- `facet_source`: character scalar describing whether the target facet
  was inferred from the fit configuration or supplied explicitly

- `overview`: one-row structural overview

- `summary`: one-row screening summary

- `detail`: level-level detail table

- `ranked`: detail ordered by flag density / severity

- `flagged`: flagged levels only

- `bias_sources`: per-bundle bias aggregation metadata

- `settings`: resolved threshold settings

- `notes`: short interpretation notes

- `diagnostics`: the `mfrm_diagnostics` bundle the dashboard was built
  from (echoed for downstream helpers that need to traverse the same
  diagnostics object)

- `bias_results`: the `mfrm_bias` bundle (or list of bundles) when
  `bias_results` was supplied; `NULL` otherwise

## Saved-result reuse

Supplied screening results must describe this fitted analysis. Results
from another fit or older results without identity metadata are refused.
See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_compatibility_layer.md)
to recreate them from the saved fit and matching diagnostics without
refitting the model.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md),
[plot(x, type =
"qc")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

`facet_quality_dashboard()`, [plot(x, type =
"facet_dashboard")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("facet_quality_dashboard", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy <- toy[toy$Person %in% unique(toy$Person)[1:8], ]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
dash <- facet_quality_dashboard(fit, diagnostics = diag)
summary(dash)
} # }
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("summary.mfrm_facet_dashboard", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
summary(facet_quality_dashboard(fit, diagnostics = diag))
} # }
```
