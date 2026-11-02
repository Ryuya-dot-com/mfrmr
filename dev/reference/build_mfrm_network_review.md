# Build an MFRM network review

Build an MFRM network review

## Usage

``` r
build_mfrm_network_review(
  fit = NULL,
  diagnostics = NULL,
  sparse_design = NULL,
  peer_review_design = NULL,
  top_n_subsets = NULL,
  min_observations = 0,
  top_n = 10,
  include_graph = FALSE,
  data = NULL,
  person = NULL,
  facets = NULL,
  score = NULL,
  basis = c("observed", "planned"),
  weight = NULL
)

# S3 method for class 'mfrm_network_review'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).

- sparse_design:

  Optional sparse-design metadata. Supply either the generated data
  frame that carries the `mfrm_sparse_design` attribute, the attribute
  itself, or a data frame with sparse design columns such as
  `SparseDesignActive`, `DesignDensity`, `MinCommonPersonsPerRaterPair`,
  and `ZeroCommonRaterPairs`.

- peer_review_design:

  Optional peer-review design metadata. Supply either the generated data
  frame that carries the `mfrm_peer_review_design` attribute, the
  attribute itself, or its `overview` data frame.

- top_n_subsets:

  Optional maximum number of connected-subset rows to retain before
  constructing the graph; passed to
  [`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_network_analysis.md).

- min_observations:

  Minimum observations required to keep a subset row; passed to
  [`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_network_analysis.md).

- top_n:

  For `build_mfrm_network_review()`: Number of central/cut/bridge rows
  to retain in the review.

  For [`summary()`](https://rdrr.io/r/base/summary.html): Number of
  central/cut/bridge rows to keep in the compact summary.

- include_graph:

  Logical; if `TRUE`, keep the underlying `igraph` object in the nested
  `source_network` bundle.

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

- object:

  Output from `build_mfrm_network_review()`.

- digits:

  Number of digits for printed numeric values.

- ...:

  Reserved for generic compatibility.

## Value

A bundle of class `mfrm_network_review` containing:

- `overview`: connectedness and front-door review status

- `network_summary`: graph-level metrics from
  [`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_network_analysis.md)

- `facet_summary`: facet-level vulnerability summaries

- `top_central_nodes`, `top_cut_nodes`, `top_bridge_edges`: follow-up
  rows

- `sparse_review`: optional sparse-design linking review

- `peer_review`: optional peer-review assignment and linkage diagnostics

- `reporting_map`: boundary between MFRM, design network, sparse design,
  peer-review design, and rater-effect network routes

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.mfrm_network_review`.

## Details

`build_mfrm_network_review()` is a synthesis layer over
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_network_analysis.md).
It keeps the measurement model and graph view in separate sections: MFRM
estimates remain the measurement results, while the network review
summarizes co-observation connectedness and linking vulnerability in the
observed design. This is especially useful for sparse or incomplete
rater-mediated designs, where common-person links, connected subsets,
articulation points, and bridge edges can explain why an otherwise
estimable model depends on fragile design links.

The review status is deliberately conservative and descriptive. It is
not a literature-derived adequacy cut point for fit, separation,
recovery, or rater quality. Use it to decide which design links,
anchors, or additional observations need inspection before making
common-scale claims.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize an
MFRM network review

## References

- Wind, S. A., & Jones, E. (2018). The stabilizing influences of linking
  set size and model-data fit in sparse rater-mediated assessment
  networks. *Educational and Psychological Measurement*.
  doi:10.1177/0013164417703733.

- Wind, S. A., Jones, E., & Grajeda, S. (2023). Does sparseness matter?
  Examining the use of generalizability theory and many-facet Rasch
  measurement in sparse rating designs. *Applied Psychological
  Measurement*, 47(5-6), 351-364. doi:10.1177/01466216231182148.

- DeMars, C. E., Shapovalov, Y. A., & Hathcoat, J. D. (2023).
  *Many-Facet Rasch Designs: How Should Raters be Assigned to
  Examinees?* NCME presentation.

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

[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_network_analysis.md),
[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/subset_connectivity_report.md),
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_summary_table_bundle.md),
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/rater_network_analysis.md),
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/rater_halo_network_analysis.md)

`build_mfrm_network_review()`

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("build_mfrm_network_review", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
if (requireNamespace("igraph", quietly = TRUE)) {
  review <- build_mfrm_network_review(fit)
  summary(review)
  build_summary_table_bundle(review)
}
} # }
```
