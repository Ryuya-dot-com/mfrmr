# Build an MFRM network review

Build an MFRM network review

## Usage

``` r
build_mfrm_network_review(
  fit,
  diagnostics = NULL,
  sparse_design = NULL,
  peer_review_design = NULL,
  top_n_subsets = NULL,
  min_observations = 0,
  top_n = 10,
  include_graph = FALSE
)
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

  Number of central/cut/bridge rows to retain in the review.

- include_graph:

  Logical; if `TRUE`, keep the underlying `igraph` object in the nested
  `source_network` bundle.

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

## Details

`build_mfrm_network_review()` is a synthesis layer over
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md).
It keeps the measurement model and graph view in separate lanes: MFRM
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

## See also

[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md),
[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md),
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md),
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
if (requireNamespace("igraph", quietly = TRUE)) {
  review <- build_mfrm_network_review(fit)
  summary(review)
  build_summary_table_bundle(review)
}
} # }
```
