# Recommend a design condition from simulation results

Recommend a design condition from simulation results

## Usage

``` r
recommend_mfrm_design(
  x,
  facets = c("Rater", "Criterion"),
  min_separation = 2,
  min_reliability = 0.8,
  max_severity_rmse = 0.5,
  max_misfit_rate = 0.1,
  min_convergence_rate = 1,
  prefer = c("n_person", "raters_per_person", "n_rater", "n_criterion"),
  max_ratings = NULL,
  max_ratings_per_rater = NULL,
  require_connected = TRUE
)
```

## Arguments

- x:

  Output from
  [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  or
  [`summary.mfrm_design_evaluation()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md).

- facets:

  Non-empty vector of facets that must satisfy the planning thresholds.
  By default, use the stored non-person facet names; for older objects
  without these names, use the non-person facets in the summary.

- min_separation:

  Minimum acceptable mean separation.

- min_reliability:

  Minimum acceptable mean reliability.

- max_severity_rmse:

  Maximum acceptable severity recovery RMSE.

- max_misfit_rate:

  Maximum acceptable mean misfit rate.

- min_convergence_rate:

  Minimum acceptable convergence rate.

- prefer:

  Ranking priority among design variables. Earlier entries are optimized
  first when multiple designs pass. Custom public aliases from
  `sim_spec` are also accepted, as are the role keywords `person`,
  `rater`, `criterion`, and `assignment`.

- max_ratings:

  Optional upper bound on total rating rows in each evaluated
  replication. Supply a non-negative whole number, or `NULL` (default)
  to impose no limit.

- max_ratings_per_rater:

  Optional upper bound on rating rows assigned to any one rater-like
  facet level in each evaluated replication. Supply a non-negative whole
  number, or `NULL` (default) to impose no limit.

- require_connected:

  Logical; require both generated Person-facet assignment graphs to be
  connected in every recorded replication (default `TRUE`). This covers
  both non-person facets regardless of which performance metrics are
  selected through `facets`. Set `FALSE` only to explicitly omit this
  structural screen; the recorded status is retained.

## Value

A list of class `mfrm_design_recommendation` with:

- `facet_table`: facet-level threshold checks, including design-variable
  alias columns when applicable

- `design_table`: design-level aggregated checks, including
  design-variable alias columns when applicable, `MaxRatings`,
  `MaxRatingsPerRater`, and workload checks `RatingsPass` and
  `RaterWorkloadPass`. Its `Pass` requires the facet-level checks,
  active workload limits, and `ConnectivityPass`. Component maxima,
  `DisconnectedReps`, `ConnectivityStatus`, and the separate
  `LinkReviewStatus` / `LinkReviewReason` explain structural checks.

- `recommended`: the first passing design after ranking

- `thresholds`: thresholds used in the recommendation

- `design_variable_aliases`: accepted public aliases for design
  variables

- `design_descriptor`: role-based design-variable metadata

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of mutable/locked design
  variables

- `planning_schema`: structured planning metadata

- `caveats`: fixed-effects and connectivity interpretations and
  suggested post-fit reviews

## Details

This helper converts a design-study summary into a simple planning
table.

A design is marked as recommended when all requested facets satisfy all
selected thresholds simultaneously. Each design must have results for
every requested facet. Missing facets are reported in `FacetsMissing`
and prevent that design from passing; `FacetsRequired` always counts the
requested facets, not the available rows. Designs with none of the
requested facets have no facet-check rows and cannot be recommended. A
requested facet absent from the entire summary produces an error. If
multiple designs pass, the helper returns the smallest one according to
`prefer` (by default: fewer persons first, then fewer ratings per
person, then fewer raters, then fewer criteria). The convergence
threshold uses all recorded replications, including failures that
returned no facet metrics, as summarized by
[`summary.mfrm_design_evaluation()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md).
Threshold checks use unrounded metrics. Summaries saved by earlier
versions may contain only rounded values; rebuild them with
`summary(original_evaluation)` before requesting a recommendation. The
original evaluation can be reused without generating or fitting new
data.

The connectivity screen uses generated assignments, including failed
fits and diagnostic runs. `ConnectivityStatus` is `"disconnected"` if
any recorded graph is disconnected, `"connected"` if both graphs are
connected in every replication, and `"not_assessed"` otherwise. With the
default `require_connected = TRUE`, only `"connected"` passes. Older
saved objects without component counts cannot pass this screen;
re-summarizing alone cannot recover the missing assignment evidence.

This is a conservative screen for comparisons supported by shared-person
assignments, not a test of full model identification or adequate
precision. MML population assumptions can supply information beyond
these connections; disabling the screen does not validate that
assumption-based comparison. Connections may be indirect, so a rater
pair without common persons is not by itself evidence of a disconnected
design. `LinkReviewStatus` and `LinkReviewReason` carry the separate
sparse-design overlap review: `"review"` flags a missing overlap count,
a pair without common persons, or a pair below its recorded target;
`"ok"` means those recorded checks pass, and `"not_assessed"` means no
sparse overlap target was assessed. They do not change `Pass`; overlap
counts alone do not establish precision or a universal minimum.

Workload limits apply to the maxima across all recorded replications,
including failed fits and diagnostic runs. One rating is one generated
person-rater-criterion row, not a bundle of criteria or a weighted
count. For example, two raters each scoring three criteria for ten
persons use 60 ratings, with 30 per rater. Counts use the actual
assignment, including linking persons and uneven or incomplete
skeletons. A design cannot pass an active limit when its corresponding
count is missing. Older evaluation objects can be re-summarized for
total counts, but per-rater counts require an evaluation that recorded
`MaxRatingsPerRater`.

These checks describe the evaluated assignments. With randomized
assignments, an observed maximum does not guarantee that future
assignments will respect the same limit. The limits constrain workload,
not monetary cost or scoring time. Ranking among passing designs still
follows `prefer`.

## Typical workflow

1.  Run
    [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md).

2.  Review
    [`summary.mfrm_design_evaluation()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md)
    and
    [`plot.mfrm_design_evaluation()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_design_evaluation.md).

3.  Use `recommend_mfrm_design(...)` to identify the smallest acceptable
    design.

## See also

[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[summary.mfrm_design_evaluation](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md),
[plot.mfrm_design_evaluation](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_design_evaluation.md)

## Examples

``` r
# \donttest{
sim_eval <- suppressWarnings(evaluate_mfrm_design(
  n_person = c(8, 12),
  n_rater = 2,
  n_criterion = 2,
  raters_per_person = 2,
  reps = 1,
  maxit = 30,
  seed = 123
))
rec <- recommend_mfrm_design(
  sim_eval, max_ratings = 48, max_ratings_per_rater = 24
)
rec$recommended
#> # A tibble: 0 × 26
#> # ℹ 26 variables: design_id <chr>, n_person <int>, n_rater <int>,
#> #   n_criterion <int>, raters_per_person <int>, FacetsChecked <chr>,
#> #   FacetsMissing <chr>, MinSeparation <dbl>, MinReliability <dbl>,
#> #   MaxSeverityRMSE <dbl>, MaxMisfitRate <dbl>, MinConvergenceRate <dbl>,
#> #   MaxRatings <int>, MaxRatingsPerRater <int>, MaxRaterComponents <int>,
#> #   MaxCriterionComponents <int>, DisconnectedReps <int>,
#> #   LinkReviewStatus <chr>, LinkReviewReason <chr>, FacetsPassing <int>, …
# }
```
