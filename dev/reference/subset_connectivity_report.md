# Build a subset connectivity report (preferred alias)

Build a subset connectivity report (preferred alias)

## Usage

``` r
subset_connectivity_report(
  fit = NULL,
  diagnostics = NULL,
  top_n_subsets = NULL,
  min_observations = 0,
  data = NULL,
  person = NULL,
  facets = NULL,
  score = NULL,
  basis = c("observed", "planned"),
  weight = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).

- top_n_subsets:

  Optional maximum number of subset rows to keep.

- min_observations:

  Minimum observations required to keep a subset row.

- data:

  Optional raw assignment/rating data, supplied instead of `fit`.

- person, facets:

  Names of the person column and one or more facet columns in `data`.
  Include only Rater in `facets` to inspect person-rater links without a
  common Criterion node obscuring separate panels.

- score:

  Numeric score column for `basis = "observed"`. Recode study-specific
  missing markers to `NA` first; no category recoding or estimation is
  done.

- basis:

  `"observed"` includes rows with complete identifiers and nonmissing
  finite scores; `"planned"` includes complete assignment rows without
  scores. Planned networks require `score = NULL` and `weight = NULL`.

- weight:

  Optional numeric weight column for observed raw data. Missing and
  zero-weight rows do not create edges. Edge weights still count rows,
  not sampling weights. Negative or infinite weights are refused.

## Value

A named list with subset-connectivity components. Class:
`mfrm_subset_connectivity`.

## Details

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_subset_connectivity` (`type = "subset_observations"`,
`"facet_levels"`, or `"linking_matrix"` / `"coverage_matrix"` /
`"design_matrix"` / `"network"`). The network route returns reusable
node and edge tables with `draw = FALSE`; drawing uses `igraph` when
available.

## Interpreting output

- `summary`: number and size of connected subsets.

- subset table: whether data are fragmented into disconnected
  components.

- facet-level columns: where connectivity bottlenecks occur.

## Typical workflow

1.  Run `subset_connectivity_report(fit)`.

2.  Inspect graph coverage alongside `identification_audit`. A common
    criterion can connect panels whose person/rater locations remain
    confounded.

3.  Use the model rank and population assumptions to assess linking; a
    single co-observation component is not a FACETS identification
    subset.

## Before fitting

Supply `data`, `person`, `facets` and `score` instead of `fit`. Known
levels from incomplete/unscored rows remain as nodes, including
isolates. A planned assignment roster can be examined with
`basis = "planned"`; absent assignments cannot be reconstructed from an
observed-only file. `row_usage` records each input row's inclusion and
first exclusion reason. With a fit, only its retained rows are available
here; review original missing assignments before fitting. No prefit
result supplies an identification audit or model-readiness decision.
`settings$is_disjoint` describes the source graph, even when subset
filters omit components; compare source/retained subset counts. Filters
do not establish linking. See [online networks and reporting
guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-networks-and-reporting.html)
for a panel example.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_network_analysis.md),
[`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/measurable_summary_table.md),
[`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/data_quality_report.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_linking_and_dff.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("subset_connectivity_report", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
out <- subset_connectivity_report(fit)
summary(out)
p_sub <- plot(out, draw = FALSE)
p_design <- plot(out, type = "design_matrix", draw = FALSE)
p_net <- plot(out, type = "network", draw = FALSE)
p_sub$data$plot
p_design$data$plot
p_net$data$edges
out$summary[, c("Subset", "Observations", "ObservationPercent")]
} # }
```
