# Analyze the MFRM design network

Analyze the MFRM design network

## Usage

``` r
mfrm_network_analysis(
  fit,
  diagnostics = NULL,
  top_n_subsets = NULL,
  min_observations = 0,
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

- top_n_subsets:

  Optional maximum number of connected-subset rows to retain before
  constructing the graph.

- min_observations:

  Minimum observations required to keep a subset row.

- include_graph:

  Logical; if `TRUE`, include the underlying `igraph` object in the
  returned bundle. Defaults to `FALSE` so outputs remain easy to
  serialize.

## Value

A bundle of class `mfrm_network_analysis` containing:

- `summary`: graph-level connectedness and vulnerability metrics

- `node_metrics`: node-level degree, strength, centrality, and cutpoint
  flags

- `edge_metrics`: edge-level weights, betweenness, and bridge flags

- `facet_summary`: facet-level aggregation of node/bridge indicators

- `cut_nodes`: articulation-point rows from `node_metrics`

- `bridge_edges`: bridge rows from `edge_metrics`

## Details

`mfrm_network_analysis()` treats the person/facet-level observation
design as an undirected weighted graph. Nodes are person or facet
levels; edges connect levels that co-occur in at least one observed
rating; edge weights are co-observation counts. The resulting network
metrics are design diagnostics, not psychometric measures of person
ability or rater quality. `plot(net, type = "centrality")`,
`plot(net, type = "facet_summary")`, and `plot(net, type = "network")`
provide immediate visual checks; use `draw = FALSE` to extract reusable
plot data.

The most useful review columns are:

- `Components`: more than one component means the design has
  disconnected measurement subsets.

- `IsArticulationPoint`: a node whose removal would increase
  disconnectedness.

- `IsBridge`: an edge whose removal would increase disconnectedness.

- `Betweenness`: a routing-dependence indicator; high values identify
  levels that carry many shortest paths through the design graph.

In incomplete rater-mediated designs, these graph summaries help
identify fragile linking structures before interpreting facet measures
or planning additional data collection.

## References

- McEwen, M. R. (2015). *Development of a Software Prototype for
  Generating and Classifying Incomplete Many-Facet-Rasch Model Rating
  Designs*. Brigham Young University.

- Csardi, G., Nepusz, T., Traag, V., Horvat, S., Zanini, F., Noom, D., &
  Muller, K. (2026). *igraph: Network Analysis and Visualization*.

## See also

[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
if (requireNamespace("igraph", quietly = TRUE)) {
  net <- mfrm_network_analysis(fit)
  net$summary
  head(net$node_metrics)
  net$cut_nodes
  plot(net, type = "centrality", draw = FALSE)
}
} # }
```
