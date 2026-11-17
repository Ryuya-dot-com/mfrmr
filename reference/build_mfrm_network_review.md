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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

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
  [`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md).

- min_observations:

  Minimum observations required to keep a subset row; passed to
  [`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md).

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
  [`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md)

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

Combines MFRM estimates with a separate review of assignment
connectivity and fragile links. See "Reading the graph" in
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md)
for components, articulation points, bridges and betweenness.

Review status is a conservative descriptive screen, not a
literature-derived cutoff for fit, separation, recovery or rater
quality. Use it to prioritize inspection of links, anchors or additional
observations before common-scale claims; the graph does not replace the
measurement results.

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

Supply `data`, `person`, `facets` and `score` for a prefit graph, or use
`basis = "planned"` for an assignment roster. Observed-only data cannot
reveal absent assignments; a fit supplies only retained rows. Graph
connectivity is not full model identification, and filtering does not
establish linking. See "Before fitting" in
[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
for unscored/isolate rows, the inclusion audit and source versus
retained component counts.

## See also

[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md),
[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md),
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md),
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)

`build_mfrm_network_review()`

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
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
