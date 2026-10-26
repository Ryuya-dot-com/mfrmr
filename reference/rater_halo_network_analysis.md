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

`rater_halo_network_analysis()` reshapes rating data so that each
rater-by-criterion combination is a node. Edges are correlations between
those node score vectors across shared contexts. Edges connecting two
nodes from the same rater but different criteria are labelled `"halo"`;
all other retained edges are labelled `"non_halo"`.

This response-profile network does not evaluate assignment connectedness
or establish a common scale. Its degree, strength, betweenness, and
closeness columns are graph-theoretic centrality summaries after
adjusted-p, `min_abs_weight`, and sign filters are applied.

Per-rater `ReviewStatus` combines same-rater cross-criterion mean
weight, incident non-halo comparison weight, and the number of retained
halo edges. A `"warning"` means these criteria converge strongly enough
to prioritize follow-up; `"review"` means at least one screening
criterion is elevated. Neither label is a causal halo diagnosis, and the
default review thresholds are package conventions rather than validated
decision rules. Strong negative same-rater correlations are anomalous
but are not evidence of a positive halo pattern; consult signed
correlations in `pair_metrics` and `MeanSignedHaloWeight`.

The key descriptive comparison is the distribution of halo-edge weights
versus non-halo-edge weights. A larger halo-edge distribution is
consistent with a halo pattern, but this function deliberately reports
it as a screening diagnostic. `MeanHaloWeight` and `MeanNonHaloWeight`
use all finite absolute correlations meeting `min_pair_n`, before
adjusted-p, `min_abs_weight`, and sign filtering; the corresponding
`MeanRetained*` columns describe the filtered graph. Candidate and
unavailable pair counts accompany these available-pair means. An
incomplete comparison cannot receive an unqualified no-flag assessment.

`WelchT`, `WelchDF` and `WelchP` remain as unavailable compatibility
columns. The correlations share observations, raters and nodes; an
independent-sample test of their difference is not supplied. Pairwise
correlation tail areas screen association under their sampling
assumptions, not halo itself. For each pair, these tail areas require
`"Person"` in `context_facets` and no repeated Person among its shared
contexts. Otherwise the correlation is retained but `PValue` and
`PAdjusted` are unavailable. `N` counts shared contexts, `Persons`
counts distinct Persons when traceable, and `PValueStatus` explains
availability. Repeating a Person across tasks does not create
independent observations. No clustered test is substituted. Distinct
identifiers do not establish independence: sampling dependence, fixed
rater effects, ties and small-sample approximations still require
review. Adjustments use the family of available pairwise p-values;
counts of available and unavailable p-values are separate from
correlation counts.

With `alpha < 1`, an unavailable p-value excludes that pair from the
graph and prevents an unqualified `"ok"` review for an affected rater.
`alpha = 1` explicitly requests a descriptive graph without the p
filter; it does not make the missing p-values available or validate
review flags. No retained graph edges is not evidence that halo is
absent; retain the originally specified thresholds. Recreate older
network results from the existing fit and matching diagnostics before
summary, plotting or export.

The node vectors contain observed scores, not model residuals. Repeated
ratings within a context-by-node cell are averaged using observation
weights; the selected correlation then compares available context means.
Ability differences, related criteria and the assignment design can
produce strong associations without a causal halo effect. Graph
centrality here is distinct from middle-category use measured by
[`rater_centrality_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_centrality_table.md).

A horn effect refers to an unfavorable impression spreading to ratings
on other criteria. It is not a negative criterion correlation or simply
high rater severity: lowering several criteria together can still
produce positive correlations. Neither the sign of a network edge nor
Infit/Outfit classifies halo versus horn; this function provides no such
classification.

Direct halo models are a separate approach. Jin and Chiu (2022)
introduce the MRFM-H mixture Rasch facets model; Jin and Eckes (2025)
distinguish general-impression and inadequate-criterion-discrimination
mechanisms in MRFM-H(GI) and MRFM-H(ID). These models are not
implemented here. Network summaries do not estimate their latent classes
or adjust measurements for those mechanisms. See
[mfrmr_methods_reference](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md)
for choosing the target.

Save the complete result with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) before repeated
plotting. `plot(out, type = "edge_distribution")` shows available
absolute correlations before edge filters; `type = "halo_summary"` uses
the selected `metric`. `type = "matrix"` shows signed retained
correlations on a -1 to 1 scale, with grey unavailable/filtered entries.
These views support
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md);
the network view uses base graphics or custom graphics from
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).
Plot payloads retain settings, caveats and denominators outside the
figure. Export the result's data frames with
[`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html); this
standalone bundle is not an automatically included section of
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md).

## Dependence-aware halo contrasts

`halo_contrast` is the unweighted mean of signed same-rater correlations
minus the mean of the declared between-rater reference correlations. It
uses the original available pair set before p-value/sign/edge filtering;
it may therefore differ from the legacy retained-edge summary. Report
the actual criterion/overlap mix in `contrast_pairs`; the default
removes same-criterion reference edges but does not balance unequal
criterion-pair counts.

Bootstrap resampling draws whole persons, keeping all their contexts,
raters and criteria together, and recomputes every fixed pair. Repeated
draws of a person remain repeated observations. This preserves
within-person dependence and shared-edge sampling dependence. It assumes
independent, representative person clusters and conditions on the
observed raters, criteria and pair set. It does not generalize to a
population of raters, account for clustering of persons within schools,
establish causal halo, or validate missingness assumptions. A person
context must be retained for resampling.

`bootstrap_draws` retains every attempted replicate and its status. If
any required correlation becomes undefined (e.g. constant bootstrap
scores), the interval is withheld rather than conditioning on successful
replicates or silently changing the target edge set. Few persons/sparse
overlap can make this method unsuitable. Percentile intervals are
approximate, pointwise and not selection-adjusted. No independent-edge
Welch p-value is supplied.

## Relation to MFRM and published network analyses

These are observed-score relationships, not fitted residuals or adjusted
Rasch parameters. Lamprianou (2025) compares agreement, directional and
rater-by-criterion networks with MFRM; a close empirical correspondence
is not numerical equivalence. Signed alpha edges and weighted
directional SWS/PUS indices are available here;
[`fit_rater_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md)
supplies binary ERGM estimation. Halo-edge associations can reflect
trait covariance and rubric overlap; `rater_halo_network_analysis()`
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
[`plot.mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bundle.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 300
)
if (requireNamespace("igraph", quietly = TRUE)) {
  halo <- rater_halo_network_analysis(fit)
  halo$summary
  head(halo$halo_summary_by_rater)
  plot(halo, type = "edge_distribution", draw = FALSE)
}
```
