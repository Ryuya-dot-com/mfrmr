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
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md).

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

- draw:

  If `TRUE`, draw with base graphics. If `FALSE`, return an
  `mfrm_plot_data` object with reusable plot tables and metadata.

- ...:

  Reserved for generic compatibility.

## Value

An `mfrm_plot_data` object. When `draw = TRUE`, the object is returned
invisibly after drawing.

## Details

These plots are intended as simulation-review graphics. They do not
replace the row-level `x$recovery` table or the ADEMP metadata; they
make the main recovery estimands easier to inspect during
model-development and design checks. Coverage is displayed only for
groups with valid centered structural intervals, conditional on
availability. Summary/coverage routes refresh aggregates from saved
rows; their `data$availability_table` preserves all selected groups,
including those omitted from drawing. Inspect counts, availability
rates, MCSEs and `CIReasons` there and in `summary(x)`. A wholly
unavailable coverage plot gives an informative error; it does not draw
missing coverage as zero. See
[`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md)
for the target and the treatment of legacy saved intervals. A zero
mean-aligned bias is an identification identity, not evidence of
unbiased estimation.

## See also

[`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md),
[`summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-results.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
rec <- saved$recovery
plot(rec, type = "summary", metric = "rmse", draw = FALSE)
#> <mfrm_plot_data>
#>   name     : recovery_simulation
#>   title    : Parameter recovery: RMSE
#>   subtitle : Summary by parameter type, facet, and comparison scale
#>   notes    :
#>     [note] MCSE uses independent simulation trials, with a ratio
#>     linearization for unequal numbers of available parameter rows; fewer
#>     than two contributing trials gives NA.
#>     [note] Coverage95 is conditional on available centered facet intervals.
#>     Report ExpectedRows, CoverageRows, CoverageAvailabilityRate and
#>     FailedReps alongside it; unavailable intervals are not counted as
#>     noncoverage.
#>     [note] Mean-aligned location Bias and complete identified log-slope
#>     group Bias are zero by construction; they are not evidence of truth
#>     centering and receive BiasStatus = not_assessed. RMSE describes
#>     within-group relative recovery.
#>     [note] Some fitted models did not report convergence; inspect
#>     `rep_overview` before interpreting recovery summaries.
#>     [note] Some planned targets have no supported centered structural
#>     interval. RawSE preserves source uncertainty, including Person-score
#>     uncertainty, without treating it as an interval for this target.
#>   data     :
#>     $type : character [1]
#>     $metric : character [1]
#>     $metric_label : character [1]
#>     $comparison : character [1]
#>     $parameter_type : NULL
#>     $facet : NULL
#>     $plot_table : data.frame [4 x 41]
#>     $availability_table : data.frame [4 x 39]
#>     $plot_name : character [1]
#>   legend   : 0 entries
#>   ref lines: 0
#> Use `plot_data()` to extract the saved values and notes.
#> For supported views, `as_ggplot()` redraws this saved result.
```
