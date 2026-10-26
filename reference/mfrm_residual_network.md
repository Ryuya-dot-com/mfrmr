# Explore residual associations and groups of facet levels

After reviewing a fitted measurement model, locate facet levels whose
standardized residuals move together across persons. For example,
explore criteria that share unexplained variation, or raters with
similar residual profiles. This descriptive, signed correlation network
complements
[`q3_statistic()`](https://ryuya-dot-com.github.io/mfrmr/reference/q3_statistic.md),
residual PCA and case review.

## Usage

``` r
mfrm_residual_network(
  fit,
  diagnostics = NULL,
  facet = "Rater",
  min_pairs = 5L,
  missing = c("pairwise", "complete"),
  min_abs = 0,
  clusters = NULL,
  linkage = c("average", "complete")
)

# S3 method for class 'mfrm_residual_network'
summary(object, ...)

# S3 method for class 'mfrm_residual_network'
print(x, ...)
```

## Arguments

- fit:

  A supported
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  result, with ordinary observation-level standardized residuals
  available from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- diagnostics:

  Optional matching diagnostics; computed once if omitted.

- facet:

  A single fitted facet. Its levels, not persons, are the nodes and the
  objects clustered. Defaults to `"Rater"`.

- min_pairs:

  Minimum shared persons for a correlation, at least three.

- missing:

  `"pairwise"` uses the available persons for each pair. `"complete"`
  uses only persons with finite aggregated residuals at every selected
  facet level. No residual is imputed. Clustering requires `"complete"`
  so all distances describe the same sample.

- min_abs:

  Absolute correlation threshold for displayed edges, in `[0, 1]`;
  default zero retains every nonzero available association. This is a
  display choice, not a significance threshold. It never changes the
  correlations or the clustering distance.

- clusters:

  Optional integer number of groups from 2 to the number of levels.
  `NULL` skips clustering. The number is supplied, not estimated.

- linkage:

  `"average"` (default) or `"complete"` agglomerative linkage.

- object:

  An `mfrm_residual_network`.

- ...:

  Reserved; unused arguments are rejected.

- x:

  An `mfrm_residual_network`.

## Value

An `mfrm_residual_network` with `nodes`, all `pairs`, displayed `edges`,
the correlation `matrix`, aggregated `residuals`, `cell_counts`,
`person_usage`, `settings`, `clustering` (status, distance, tree and
membership), source model metadata and interpretation `notes`.
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns saved
figure data;
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
connect the result to reporting. Complete RDS archives include person
identifiers: review sharing permissions.

## Statistical definition

Finite `StdResidual` values are averaged without weighting within each
Person-by-facet-level cell. Pearson correlations across persons define
the network. Thus repeated ratings are not treated as independent
persons. `cell_counts` records differing amounts of evidence behind
those means. Missing overlap and zero variance produce unavailable
(`NA`) associations, with reasons in `pairs`; they never become zero
edges. All nodes, including isolates, remain in the output. Positive
edges indicate co-movement and negative edges counter-movement after the
fitted model. These are marginal residual correlations, not
conditional/partial correlations or raw Yen Q3.

Unequal assignments, aggregation, estimated Person effects and finite
samples can induce residual structure, including negative correlations.
Inspect overlap and the rating design before explaining an edge as a
substantive relationship. Threshold sensitivity is not a calibrated
test. No edge p-values, uncertainty intervals or stability estimates are
supplied.

## Machine learning and interpretation

Hierarchical agglomerative clustering is unsupervised learning: it
merges similar nodes without known outcome labels. With complete-person
Pearson correlations, `sqrt(2 * (1 - r))` is Euclidean distance between
centered, unit-length residual profiles. Average linkage uses the mean
between-group distance; complete linkage uses the maximum. Strong
negative correlation means dissimilar profiles, not similarity based on
absolute correlation. A supplied `clusters` cuts the resulting
[`stats::hclust()`](https://rdrr.io/r/stats/hclust.html) tree with
[`stats::cutree()`](https://rdrr.io/r/stats/cutree.html). Changing
`min_abs` cannot change these groups.

Clustering remains unavailable if any level lacks sufficient
common-person variation; the graph and failure reason are still
returned. Pairwise deletion can yield an indefinite correlation matrix,
so it is not used to manufacture clustering distances. Common-person
deletion can select a different population and greatly reduce the
sample; inspect `person_usage`.

Groups are exploratory residual-profile similarities, not latent
classes, demonstrated rubric dimensions, rater competence or automatic
grounds for excluding a rater. This procedure is not exploratory graph
analysis (EGA): Golino and Epskamp (2017) used a graphical-LASSO
partial-correlation network and community detection. It is also not a
jointly estimated residual-network measurement model. Compare
substantive explanations, inspect cases and check sensitivity to sample,
linkage and group count. For validation, repeat preprocessing,
measurement fitting and clustering within independent or appropriately
resampled data; resampling saved residuals alone omits calibration
uncertainty. The appropriate resampling unit follows the rating design,
including dependencies across persons, tasks and raters.

## Where random forests belong

Wesolowski (2019) first used k-means on differential-rater-functioning
indices to construct rater types, then random forests to predict those
labels. That study motivates a supervised follow-up, not random forests
as the clustering algorithm implemented here. Its features and targets
differ from these residual correlations. In this supervised use, a
forest combines predictions from bootstrap samples and random candidate
feature subsets; it requires a declared prediction target and
out-of-sample assessment.

A classifier predicting exploratory groups can reproduce the grouping
rule without establishing external validity. Fit feature
transformations, measurement models and cluster discovery within
training data, keep a separate test set and define how new units receive
reference labels. Split at the intended generalization unit (for example
new raters, persons or tasks); row-wise splitting of repeated ratings
can leak information. Out-of-bag error alone does not validate labels
constructed on all data. Report class balance, confusion matrices,
discrimination/calibration where appropriate and independent substantive
outcomes. Feature importance is predictive, not causal. This function
does not fit a random forest; use established ML packages for a
separately designed prediction study.

## References

Wesolowski, B. C. (2019). Predicting operational rater-type
classifications using Rasch measurement theory and random forests: A
music performance assessment perspective. *Journal of Educational
Measurement, 56*, 610–625.
[doi:10.1111/jedm.12227](https://doi.org/10.1111/jedm.12227) .

Golino, H. F., & Epskamp, S. (2017). Exploratory graph analysis: A new
approach for estimating the number of dimensions in psychological
research. *PLOS ONE, 12*, e0174035.
[doi:10.1371/journal.pone.0174035](https://doi.org/10.1371/journal.pone.0174035)
.

## See also

[`mfrm_cluster_kmeans()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_kmeans.md),
[`mfrm_cluster_hierarchical()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_hierarchical.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 300)
net <- mfrm_residual_network(fit, facet = "Criterion", missing = "complete",
                             clusters = 2)
net$pairs                 # association, shared-person count, unavailability
#>     Level1       Level2 ResidualCor  N Reason Displayed
#> 1 Accuracy      Content -0.24351341 48             TRUE
#> 2 Accuracy     Language -0.47046424 48             TRUE
#> 3 Accuracy Organization -0.05276933 48             TRUE
#> 4  Content     Language -0.42513633 48             TRUE
#> 5  Content Organization -0.35361668 48             TRUE
#> 6 Language Organization -0.38506732 48             TRUE
net$clustering$status     # check before interpreting groups
#> [1] "available"
plot(net, type = "matrix", draw = FALSE)
report <- mfrm_report(net)
build_summary_table_bundle(report)$table_index
#>                  Table Rows Cols              Role
#> 1             settings    1   11      study_design
#> 2                nodes    4    4 study_diagnostics
#> 3                pairs    6    6 study_diagnostics
#> 4           clustering    1    2 study_diagnostics
#> 5         source_model    1    3      study_design
#> 6 interpretation_notes    6    1       study_notes
#>                                                            Description
#> 1       Residual definition, sample, threshold and clustering settings
#> 2        All facet levels, displayed degree and exploratory membership
#> 3   All residual pairs, including overlap and unavailable associations
#> 4                  Clustering availability and interpretation boundary
#> 5 Source measurement model; residuals are conditional on its estimates
#> 6          Interpretation boundaries to retain with tables and figures
```
