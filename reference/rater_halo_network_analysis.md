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
  include_graph = FALSE,
  bootstrap = 0L,
  conf_level = 0.95,
  seed = NULL,
  halo_reference = c("different_criteria", "all")
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
  facets. Include `"Person"` for the independent-Person association
  screen; without it, correlations remain descriptive.

- method:

  Correlation method used for rater-by-criterion node pairs.

- min_pair_n:

  Minimum shared contexts required to estimate a node-pair relationship.

- alpha:

  Adjusted p-value threshold for retaining edges. Set to `1` to disable
  p-value filtering, including when inference is unavailable;
  shared-count, weight and sign filters still apply. This changes
  retained-edge counts, graph topology, and graph centrality, but not
  the full-pair halo/non-halo distribution summaries.

- p_adjust:

  Multiple-comparison adjustment passed to
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html). The
  default `"bonferroni"` follows the conservative screening used in
  Lamprianou's halo-network example.

- min_abs_weight:

  Minimum absolute correlation retained as a graph edge. Like `alpha`,
  this is an analysis filter for the retained graph, not merely a
  display filter.

- halo_weight_review:

  Same-rater cross-criterion mean absolute correlation at or above which
  a rater is marked for review. This is a package screening default, not
  a validated halo cut point.

- halo_contrast_review:

  Minimum difference between a rater's mean halo edge weight and
  incident non-halo edge weight for a stronger review flag. This is a
  package screening default, not a validated halo cut point.

- min_retained_halo_edges:

  Minimum retained halo edges required before a strong `"warning"`
  status is assigned.

- positive_only:

  If `TRUE`, negative correlations are kept in `pair_metrics` but
  excluded from the graph edge table and retained-edge counts.
  Unfiltered distribution and per-rater summaries use absolute
  correlations regardless of this setting; inspect
  `MeanSignedHaloWeight` before interpreting a review flag.

- include_graph:

  If `TRUE`, include the underlying `igraph` object.

- bootstrap:

  Number of person-cluster resamples for the halo contrast; `0`
  (default) requests no interval. At least 199 when requested; use 999
  or more for reporting and assess Monte Carlo stability.

- conf_level:

  Confidence level for the pointwise percentile interval.

- seed:

  Optional seed, preserving the caller's RNG state.

- halo_reference:

  `"different_criteria"` compares within-rater cross-criterion
  correlations with between-rater cross-criterion correlations. `"all"`
  also includes same-criterion between-rater edges, matching the paper's
  descriptive all-non-halo reference.

## Value

A bundle of class `mfrm_halo_network` containing:

- `summary`:

  One-row halo-network summary and halo/non-halo contrast.

- `node_metrics`:

  Rater-by-criterion node strength and graph-theoretic centrality.

- `edge_metrics`:

  Retained graph edges.

- `pair_metrics`:

  All estimated node-pair correlations with explicit retention flags for
  each graph filter, shared-context and Person counts, and p-value
  availability reasons. `RetainedByP` is `TRUE` for every pair when the
  p filter is disabled by `alpha = 1`.

- `halo_summary_by_rater`:

  Per-rater summaries of same-rater criterion-pair edges, including
  `ReviewStatus` and `ReviewReason`.

- `caveats`:

  Interpretation notes.

## Details

Correlates weight-averaged observed context scores across
rater-by-criterion nodes (`halo` = same-rater cross-criterion;
`non_halo` = between-rater). `MeanHaloWeight`, `MeanNonHaloWeight`, and
signed `halo_contrast` use all pairs meeting `min_pair_n` before `alpha`
/ `min_abs_weight` / `positive_only` graph filters (`MeanRetained*`
describes the filtered graph; inspect `MeanSignedHaloWeight` and
`ReviewStatus` / `ReviewReason`).

Pairwise `PValue` / `PAdjusted` require `"Person"` in `context_facets`
with no repeated Persons (`PValueStatus` explains `NA`, and `Welch*`
columns remain `NA` because edges share observations). Optional
`bootstrap` resamples whole Person clusters across the fixed
`contrast_pairs` set, withholding percentile bounds if any required pair
correlation is undefined (`bootstrap_draws`). Observed-score networks
screen association rather than fitting latent halo mixture models (Jin &
Chiu, 2022; Jin & Eckes, 2025).

## Related network methods

See "Relation to MFRM and published network analyses" in
[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md)
for agreement/directional networks, ERGM, residual associations,
assignment links and their relation to MFRM. For layouts and
display-only filters, see "Network display controls" in
[`plot.mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md).

## References

Lai, E. R., Wolfe, E. W., & Vickers, D. (2015). Differentiation of
illusory and true halo in writing scores. *Educational and Psychological
Measurement, 75*(1), 102-125.

Lamprianou, I. (2025). Network Analysis for the investigation of rater
effects in language assessment: A comparison of ChatGPT vs human raters.
*Research Methods in Applied Linguistics, 4*, 100205.

Jin, K.-Y., & Chiu, M. M. (2022). A mixture Rasch facets model for
rater's illusory halo effects. *Behavior Research Methods, 54*,
2750-2764.
[doi:10.3758/s13428-021-01721-3](https://doi.org/10.3758/s13428-021-01721-3)
. Direct model, not implemented here.

Jin, K.-Y., & Eckes, T. (2025). When raters generalize: Examining
sources of halo effects with mixture Rasch facets models. *Behavior
Research Methods, 57*, Article 149.
[doi:10.3758/s13428-025-02667-6](https://doi.org/10.3758/s13428-025-02667-6)
. Direct models, not implemented here.

## See also

[`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md),
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
[`plot.mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)

## Examples

``` r
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
if (requireNamespace("igraph", quietly = TRUE)) {
  halo <- rater_halo_network_analysis(fit)
  halo$summary
  head(halo$halo_summary_by_rater)
  plot(halo, type = "edge_distribution", draw = FALSE)
}
```
