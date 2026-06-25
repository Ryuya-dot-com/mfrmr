# Analyze rater-by-criterion halo-effect networks

Analyze rater-by-criterion halo-effect networks

## Usage

``` r
rater_halo_network_analysis(
  fit,
  diagnostics = NULL,
  rater_facet = NULL,
  criterion_facet = NULL,
  context_facets = NULL,
  method = c("spearman", "pearson", "kendall"),
  min_pair_n = 5,
  alpha = 0.05,
  p_adjust = "bonferroni",
  min_abs_weight = 0,
  halo_weight_review = 0.5,
  halo_contrast_review = 0.1,
  min_retained_halo_edges = 1,
  positive_only = TRUE,
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

- rater_facet:

  Name of the rater-like facet.

- criterion_facet:

  Name of the criterion, rubric, task, or item-like facet used to form
  rater-by-criterion nodes.

- context_facets:

  Facets defining rows in the reshaped wide matrix. Defaults to the
  person facet plus any facets other than the rater and criterion
  facets.

- method:

  Correlation method used for rater-by-criterion node pairs.

- min_pair_n:

  Minimum shared contexts required to estimate a node-pair relationship.

- alpha:

  Adjusted p-value threshold for retaining edges. Set to `1` to retain
  all finite correlations after `min_abs_weight` filtering.

- p_adjust:

  Multiple-comparison adjustment passed to
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html). The
  default `"bonferroni"` follows the conservative screening used in
  Lamprianou's halo-network example.

- min_abs_weight:

  Minimum absolute correlation retained as a graph edge.

- halo_weight_review:

  Same-rater cross-criterion mean absolute correlation at or above which
  a rater is marked for review.

- halo_contrast_review:

  Minimum difference between a rater's mean halo edge weight and
  incident non-halo edge weight for a stronger review flag.

- min_retained_halo_edges:

  Minimum retained halo edges required before a strong `"warning"`
  status is assigned.

- positive_only:

  If `TRUE`, negative correlations are kept in `pair_metrics` but
  excluded from the graph edge table.

- include_graph:

  If `TRUE`, include the underlying `igraph` object.

## Value

A bundle of class `mfrm_halo_network` containing:

- `summary`:

  One-row halo-network summary and halo/non-halo contrast.

- `node_metrics`:

  Rater-by-criterion node strength and centrality.

- `edge_metrics`:

  Retained graph edges.

- `pair_metrics`:

  All estimated node-pair correlations before edge filtering.

- `halo_summary_by_rater`:

  Per-rater summaries of same-rater criterion-pair edges, including
  `ReviewStatus` and `ReviewReason`.

- `caveats`:

  Interpretation notes.

## Details

`rater_halo_network_analysis()` reshapes rating data so that each
rater-by-criterion combination is a node. Edges are correlations between
those node score vectors across shared contexts. Edges connecting two
nodes from the same rater but different criteria are labelled `"halo"`;
all other retained edges are labelled `"non_halo"`.

Per-rater `ReviewStatus` combines same-rater cross-criterion mean
weight, incident non-halo comparison weight, and the number of retained
halo edges. A `"warning"` means these criteria converge strongly enough
to prioritize follow-up; `"review"` means at least one screening
criterion is elevated. Neither label is a causal halo diagnosis.

The key descriptive comparison is the distribution of halo-edge weights
versus non-halo-edge weights. A larger halo-edge distribution is
consistent with a halo pattern, but this function deliberately reports
it as a screening diagnostic. The included Welch test is descriptive
only because edge weights are clustered by rater and node.

## References

Lai, E. R., Wolfe, E. W., & Vickers, D. (2015). Differentiation of
illusory and true halo in writing scores. *Educational and Psychological
Measurement, 75*(1), 102-125.

Lamprianou, I. (2025). Network Analysis for the investigation of rater
effects in language assessment: A comparison of ChatGPT vs human raters.
*Research Methods in Applied Linguistics, 4*, 100205.

## See also

[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md),
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[`plot.mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bundle.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
if (requireNamespace("igraph", quietly = TRUE)) {
  halo <- rater_halo_network_analysis(fit)
  halo$summary
  head(halo$halo_summary_by_rater)
  plot(halo, type = "edge_distribution", draw = FALSE)
}
} # }
```
