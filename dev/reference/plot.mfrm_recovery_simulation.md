# Plot parameter-recovery simulation results

Plot parameter-recovery simulation results

## Usage

``` r
# S3 method for class 'mfrm_recovery_simulation'
plot(
  x,
  y = NULL,
  type = c("summary", "coverage", "errors", "scatter", "replications"),
  metric = c("rmse", "bias", "mae", "correlation", "coverage", "mcse_bias", "mcse_rmse",
    "raw_rmse", "raw_bias", "mean_se", "se_available"),
  parameter_type = NULL,
  facet = NULL,
  comparison = c("aligned", "unaligned"),
  marginal = c("auto", "histogram", "none"),
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/simulate_mfrm_recovery.md).

- y:

  Reserved for S3 generic compatibility.

- type:

  Plot route: `"summary"` draws a metric from
  `summary(x)$recovery_summary`, `"coverage"` draws 95% coverage by
  parameter group, `"errors"` draws row-level recovery-error
  distributions, `"scatter"` draws truth against estimated values, and
  `"replications"` summarizes run status.

- metric:

  Summary metric used when `type = "summary"`. Supported values are
  `"rmse"`, `"bias"`, `"mae"`, `"correlation"`, `"coverage"`,
  `"mcse_bias"`, `"mcse_rmse"`, `"raw_rmse"`, `"raw_bias"`, `"mean_se"`,
  and `"se_available"`.

- parameter_type:

  Optional parameter type filter, such as `"person"`, `"facet"`,
  `"step"`, `"slope"`, or `"population"`.

- facet:

  Optional facet filter.

- comparison:

  Error/estimate scale for row-level routes. `"aligned"` uses
  `EstimateAligned` / `ErrorAligned`; `"unaligned"` uses `Estimate` /
  `ErrorRaw` on the same comparison scale.

- marginal:

  Marginal histogram display for `type = "scatter"`: `"auto"` (default;
  shown when at least 8 finite pairs are plotted), `"histogram"`, or
  `"none"`.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, print the `ggplot` object. If `FALSE`, return the `ggplot`
  object invisibly without drawing.

- ...:

  Reserved for generic compatibility.

## Value

Invisibly, a `ggplot` object carrying reusable plot tables and metadata
accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).

## Details

These plots are intended as simulation-review graphics. They do not
replace the row-level `x$recovery` table or the ADEMP metadata; they
make the main recovery estimands easier to inspect during
model-development and design checks. Coverage is displayed only for
groups with valid centered structural intervals, conditional on
availability. Summary/coverage routes refresh aggregates from saved
rows; their `availability_table` component preserves all selected
groups, including those omitted from drawing. Inspect counts,
availability rates, MCSEs and `CIReasons` via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
and in `summary(x)`. A wholly unavailable coverage plot gives an
informative error; it does not draw missing coverage as zero. See
[`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/simulate_mfrm_recovery.md)
for the target and the treatment of legacy saved intervals. A zero
mean-aligned bias is an identification identity, not evidence of
unbiased estimation.

## See also

[`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/simulate_mfrm_recovery.md),
[`base::summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot.mfrm_recovery_simulation", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-recovery.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
rec <- saved$result
plot(rec, type = "summary", metric = "rmse", draw = FALSE)
} # }
```
