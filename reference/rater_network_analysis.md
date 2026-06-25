# Analyze rater agreement, disagreement, and severity-direction networks

Analyze rater agreement, disagreement, and severity-direction networks

## Usage

``` r
rater_network_analysis(
  fit,
  diagnostics = NULL,
  rater_facet = NULL,
  context_facets = NULL,
  mode = c("agreement", "disagreement", "severity_direction"),
  weight_metric = NULL,
  min_pair_n = 1,
  min_weight = 0,
  score_diff_tolerance = 0,
  severity_continuity = 0.5,
  exact_warn = 0.5,
  corr_warn = 0.3,
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

  Name of the rater-like facet. If omitted, mfrmr uses the same
  heuristic as
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md).

- context_facets:

  Facets defining shared scoring contexts. By default, the person facet
  and all non-rater facets are used.

- mode:

  Network definition. `"agreement"` builds an undirected network whose
  edge weights represent observed agreement. `"disagreement"` builds an
  undirected network whose edge weights represent observed disagreement.
  `"severity_direction"` builds a directed network: an edge from rater A
  to rater B means A assigned higher scores than B in shared contexts
  and is therefore relatively more lenient under the usual
  higher-score-is-better rating convention.

- weight_metric:

  Pair-level weight used for `"agreement"` or `"disagreement"` networks.
  Defaults to `Exact` for agreement and `MAD` for disagreement.
  Available pair columns include `Exact`, `Adjacent`, `Corr`, `MAD`,
  `OneMinusExact`, and `AbsMeanDiff`.

- min_pair_n:

  Minimum number of shared contexts required for a rater pair to
  contribute an edge.

- min_weight:

  Minimum edge weight retained in the graph.

- score_diff_tolerance:

  Score-difference tolerance for directed severity networks. With the
  default `0`, any higher score contributes to the outgoing leniency
  edge. Larger values reproduce thresholded disagreement displays such
  as "only differences greater than 3 marks".

- severity_continuity:

  Continuity constant added to incoming and outgoing strengths before
  computing the finite severity index
  `-log((OutStrength + c) / (InStrength + c))`.

- exact_warn, corr_warn:

  Passed to
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  to keep pair flags consistent with the tabular agreement view.

- include_graph:

  If `TRUE`, include the underlying `igraph` object in the returned
  bundle.

## Value

A bundle of class `mfrm_rater_network` containing:

- `summary`:

  One-row graph summary.

- `node_metrics`:

  Rater-level degree, strength, centrality, and severity-direction
  summaries.

- `edge_metrics`:

  Retained rater-pair network edges.

- `pair_metrics`:

  All eligible pairwise agreement and directional comparison metrics
  before edge thresholding.

- `caveats`:

  Interpretation notes and sparse-design warnings.

- `source_interrater`:

  The underlying
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  output used for agreement statistics.

## Details

This function implements a package-native rater-effect network view
complementary to MFRM output. It follows the pairwise-network logic used
in Lamprianou's rater-effect network work: nodes are raters, edges
summarize pairwise relationships among raters in shared scoring
contexts, and directed disagreement edges can be interpreted as relative
leniency/severity indicators. These network summaries are descriptive
diagnostics, not Rasch logit estimates and not formal fit statistics.

For `mode = "severity_direction"`, outgoing strength means the rater
more often assigned higher scores than comparison raters; incoming
strength means comparison raters more often assigned higher scores than
this rater. The reported `SeverityIndex` is positive for relatively
severe raters and negative for relatively lenient raters, but it is on a
network-analysis scale and should not be read as an MFRM severity logit.

## References

Lamprianou, I. (2018). Investigation of rater effects using Social
Network Analysis and Exponential Random Graph Models. *Educational and
Psychological Measurement, 78*(3), 430-459.

Lamprianou, I. (2025). Network Analysis for the investigation of rater
effects in language assessment: A comparison of ChatGPT vs human raters.
*Research Methods in Applied Linguistics, 4*, 100205.

## See also

[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md),
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md),
[`plot.mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bundle.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
if (requireNamespace("igraph", quietly = TRUE)) {
  rn <- rater_network_analysis(fit, mode = "severity_direction")
  rn$summary
  head(rn$node_metrics)
  plot(rn, type = "severity", draw = FALSE)
}
} # }
```
