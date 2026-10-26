# Analyze the MFRM design network

Analyze the MFRM design network

## Usage

``` r
mfrm_network_analysis(
  fit = NULL,
  diagnostics = NULL,
  top_n_subsets = NULL,
  min_observations = 0,
  include_graph = FALSE,
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

A bundle of class `mfrm_network_analysis` containing:

- `summary`: graph-level connectedness and vulnerability metrics

- `node_metrics`: node-level degree, strength, graph-theoretic
  centrality, and cutpoint flags

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
ability or rater quality. This is the package's
assignment/co-observation network: unlike the score-relation networks
returned by
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md)
and
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md),
it exposes disconnected co-observation components. Graph connectedness
alone does not establish model identification. `SourceSubsets`,
`RetainedSubsets` and `ScopeComplete` record whether subset filters
retained the full observed design. Connectedness of selected subsets
cannot be generalized to omitted subsets. Recreate older design reviews
from the existing fit and matching diagnostics to record this coverage.
`plot(net, type = "centrality")`, `plot(net, type = "facet_summary")`,
and `plot(net, type = "network")` provide immediate visual checks; use
`draw = FALSE` to extract reusable plot data.

The most useful review columns are:

- `Components`: more than one component means separate co-observation
  regions, including known levels without observed links.

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
do not establish linking. See
[`vignette("mfrmr-networks-and-reporting")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-networks-and-reporting.md)
for a panel example.

## See also

[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_operational")
if (requireNamespace("igraph", quietly = TRUE)) {
  net <- mfrm_network_analysis(data = ratings, person = "Person",
    facets = "Rater", score = "Score")
  net$summary
  plot(net, type = "network", draw = FALSE)
}
```
