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
  include_graph = FALSE,
  alpha_level = c("interval", "ordinal", "nominal", "ratio"),
  alpha_categories = NULL
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
  `OneMinusExact`, and `AbsMeanDiff`. `KrippendorffAlpha` retains signed
  alpha edges in agreement mode. Directed mode accepts
  `DirectionalHigherProp` (default, count/N) or `DirectionalMagnitude`
  (sum of positive score differences/N, for Lamprianou's weighted
  indices).

- min_pair_n:

  Minimum number of shared contexts required for a rater pair to
  contribute an edge.

- min_weight:

  Minimum edge weight retained in the graph. This is an analysis
  threshold: it changes graph topology and all graph-derived centrality
  summaries, not only the displayed edges.

- score_diff_tolerance:

  Score-difference tolerance for directed severity networks. With the
  default `0`, any higher score contributes to the outgoing leniency
  edge. This is an analysis tolerance: increasing it changes directional
  counts, strengths, and `SeverityIndex`; it is not a plot-only filter.

- severity_continuity:

  Continuity constant added to incoming and outgoing strengths before
  computing the finite severity index
  `-log((OutStrength + c) / (InStrength + c))`. The default `0.5` is a
  package finite-value correction. Setting `c = 0` gives the uncorrected
  published form but can produce non-finite values for zero strengths.

- exact_warn, corr_warn:

  Passed to
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  to keep pair flags consistent with the tabular agreement view.

- include_graph:

  If `TRUE`, include the underlying `igraph` object in the returned
  bundle.

- alpha_level, alpha_categories:

  Measurement level and category order for `KrippendorffAlpha`; see
  [`krippendorff_alpha_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/krippendorff_alpha_table.md).
  The default interval level follows Lamprianou (2025); ordinal alpha
  requires a declared order.

## Value

A bundle of class `mfrm_rater_network` containing:

- `summary`:

  One-row graph summary.

- `node_metrics`:

  Rater-level degree, strength, graph-theoretic centrality, and
  severity-direction summaries.

- `edge_metrics`:

  Retained rater-pair network edges.

- `pair_metrics`:

  All estimated pairwise agreement and directional comparison metrics,
  including `EligiblePair`, before `min_weight` filtering.

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
They describe score relationships conditional on observed shared
contexts; they do not test the assignment graph's connectedness or
establish a common measurement scale.

`Degree`, `Strength`, `Betweenness`, and `Closeness` are graph-theoretic
quantities computed after `min_pair_n`, `min_weight`, and (for directed
networks) `score_diff_tolerance` are applied. They are not rating-scale
central tendency or restriction-of-range measures. Use
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md)
for assignment/co-observation connectedness.

For `mode = "severity_direction"`, outgoing strength means the rater
more often assigned higher scores than comparison raters; incoming
strength means comparison raters more often assigned higher scores than
this rater. The reported `SeverityIndex` is positive for relatively
severe raters and negative for relatively lenient raters, but it is on a
network-analysis scale and should not be read as an MFRM severity logit.
A rater without any retained directional comparisons has an unavailable
index, not a balanced index. Except for signed alpha, zero or negative
undirected weights remain in the pair table but do not form graph edges.
Graph distances summarize reachable pairs only, so they do not describe
distance across disconnected components. Recreate older network results
from the existing fit and matching diagnostics with the original
settings before summary, plotting or export.

## Signed agreement and weighted network fit

Pairwise alpha uses only shared finite scoring contexts and
pair-specific marginals. Negative alpha is retained, zero remains a
non-edge, and undefined expected disagreement remains `NA` with
`AlphaStatus`. Alpha is not a correlation. `Weight` is its magnitude for
drawing; `SignedWeight` retains its sign. `Strength` is absolute
strength; `PositiveStrength`, `NegativeStrength` (magnitude) and
`SignedStrength` separate its meanings. Path centralities are withheld
for signed alpha. These are pairwise coefficients, not the multi-rater
alpha for the whole study. Repeated rater-context cells follow the
existing weighted-mean score-profile aggregation. Shared contexts are
then equally weighted; row weights are not treated as independent
replicates or precision weights for alpha/SWS/PUS.

With `DirectionalMagnitude`, `network_fit` implements equations 1–3 of
Lamprianou (2025). Let w_ij be the sum of positive score differences
from i to j, T_ij the number of shared contexts (including ties), and
S_i = sum_j(w_ij/T_ij) / sum_j(w_ji/T_ij). Severity is -log(S_i). SWS_i
= sum_j(w_ij S_j/S_i + w_ji S_i/S_j) / sum_j(T_ij) - 1. PUS_i =
mean_j(w_ij w_ji / T_ij^2), over compared partners including
zero-disagreement partners. `network_fit` uses all eligible pairs before
`min_weight` filtering, with no continuity correction. This differs from
the filtered, optionally corrected `node_metrics$SeverityIndex`.
`score_diff_tolerance` omits differences at or below the tolerance,
retaining the full difference above it; zero is the unmodified
definition. Report tolerance, eligible contexts, rubric range and units.
Higher scores here mean numerically higher; interpret leniency only
after checking rubric direction.

Zero incoming/outgoing strength can give infinite severity. SWS is
unavailable when any required ratio is undefined or nonpositive; PUS can
still be zero. Negative SWS values are preserved: the subtraction of one
does not guarantee nonnegativity. Under a positive score multiplier a,
severity is unchanged, SWS + 1 scales by a and PUS by a^2. These are
descriptive inconsistency indices, not standardized Rasch MnSq,
universally expectation-one statistics, or calibrated tests. No
universal cutoffs or p-values are attached. A high PUS can reflect
balanced reversals; low PUS may reflect sparse disagreement. Check
overlap and score range before interpreting either.

## Relation to MFRM and published network analyses

These are observed-score relationships, not fitted residuals or adjusted
Rasch parameters. Lamprianou (2025) compares agreement, directional and
rater-by-criterion networks with MFRM; a close empirical correspondence
is not numerical equivalence. Signed alpha edges and weighted
directional SWS/PUS indices are available here;
[`fit_rater_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md)
supplies binary ERGM estimation. Halo-edge associations can reflect
trait covariance and rubric overlap;
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
offers person-cluster bootstrap contrasts instead of an independent-edge
test. Use
[`mfrm_residual_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md)
for residual associations and
[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
for prefit assignment links. See
[`vignette("mfrmr-networks-and-reporting")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-networks-and-reporting.md)
for complementary views, paired overlap, direction and interpretation.
[`plot.mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bundle.md)
documents custom layouts and display-only filters, which do not change
the computed network.

## References

Lamprianou, I. (2018). Investigation of rater effects using Social
Network Analysis and Exponential Random Graph Models. *Educational and
Psychological Measurement, 78*(3), 430-459.

Lamprianou, I. (2025). Network Analysis for the investigation of rater
effects in language assessment: A comparison of ChatGPT vs human raters.
*Research Methods in Applied Linguistics, 4*, 100205.

## See also

[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[plot(x, type =
"agreement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md),
[`plot.mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bundle.md)

## Examples

``` r
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
if (requireNamespace("igraph", quietly = TRUE)) {
  rn <- rater_network_analysis(fit, mode = "severity_direction")
  rn$summary
  head(rn$node_metrics)
  plot(rn, type = "severity", draw = FALSE)
}
```
