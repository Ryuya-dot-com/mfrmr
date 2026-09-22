# Analyze the hierarchical structure of a rating design

One-stop review that combines the nesting, cross-tabulation, ICC, and
design-effect reports into a single object. Designed to be reused by the
publication-workflow surface: its summary feeds into
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
and its tables are picked up by
[`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md)
for reproducibility bundles.

## Usage

``` r
analyze_hierarchical_structure(
  data,
  facets = NULL,
  person = "Person",
  score = "Score",
  compute_icc = TRUE,
  ci_method = c("none", "boot"),
  ci_level = 0.95,
  ci_boot_reps = 1000L,
  ci_boot_seed = NULL,
  igraph_layout = TRUE,
  icc_ci_method = NULL,
  icc_ci_level = NULL,
  icc_ci_boot_reps = NULL,
  icc_ci_boot_seed = NULL,
  missing = c("error", "omit")
)
```

## Arguments

- data:

  Data frame in long format, or an `mfrm_fit` (its `prep$data` is used).

- facets:

  Character vector of facet column names. When `data` is an `mfrm_fit`,
  defaults to `fit$prep$facet_names`.

- person:

  Person column name. Defaults to `"Person"`.

- score:

  Score column name. Defaults to `"Score"`.

- compute_icc:

  Logical; if `TRUE` and `lme4` is available, adds ICC and design-effect
  tables.

- ci_method:

  ICC confidence-interval method passed through to
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md).
  One of `"none"` (default, point estimate only) or `"boot"`. The former
  `"profile"` method is refused because it did not calculate an ICC
  profile-likelihood interval. Deprecated alias: `icc_ci_method` (kept
  for backward compatibility, emits a lifecycle warning).

- ci_level:

  Confidence level when `ci_method != "none"`; default `0.95`.
  Deprecated alias: `icc_ci_level`.

- ci_boot_reps:

  Number of bootstrap replicates when `ci_method = "boot"`. Default
  `1000`. Deprecated alias: `icc_ci_boot_reps`.

- ci_boot_seed:

  Optional RNG seed for reproducible bootstrap CIs. Deprecated alias:
  `icc_ci_boot_seed`.

- igraph_layout:

  Logical; if `TRUE` and `igraph` is available, adds a connectivity
  component summary using a bipartite graph over person x facet levels.

- icc_ci_method, icc_ci_level, icc_ci_boot_reps, icc_ci_boot_seed:

  Deprecated compatibility spellings of the `ci_*` arguments above.
  Supplying a non-`NULL` value routes through
  [`lifecycle::deprecate_warn()`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)
  and overrides the canonical `ci_*` argument.

- missing:

  Missing-value policy for the ICC and design-effect tables, passed to
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md).
  Invalid input or model errors stop the requested ICC analysis.
  Nesting, cross-tabulation, and connectivity tables describe the
  supplied design, including rows excluded from the ICC model. When
  `data` is a fit, ICC row counts start from its stored fitted rows;
  they cannot recover exclusions made before fitting the MFRM.

## Value

A list of class `mfrm_hierarchical_structure` with:

- `nesting`: output of
  [`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md).

- `crosstabs`: list of pairwise observation-count data.frames (long
  format, suitable for heatmap plotting).

- `icc`: output of
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
  when requested.

- `design_effect`: output of
  [`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md)
  when requested.

- `connectivity`: named list with bipartite-graph component summary when
  `igraph` is available.

- `summary`: one-row summary used by downstream reporting helpers.

- `facets`: character vector of facet names that were reviewed (echoed
  for downstream reporting helpers that need to label rows by review
  scope).

## Interpreting output

- `nesting`: a
  [`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md)
  object with every facet pair classified as Crossed / Partially /
  Near-perfectly / Fully nested.

- `crosstabs`: list of `(LevelA, LevelB, N)` long-format tables, one per
  facet pair. Plot via
  `plot(x, type = "crosstab", pair = "FacetA__FacetB")`.

- `icc`: per-facet variance shares. See
  [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
  for the two-scale interpretation.

- `design_effect`: per-facet design-effect approximations and
  descriptive equivalent row counts; not precision estimates for the
  full design.

- `connectivity`: number of bipartite components linking Person x facet
  levels. A single component is required for a common measurement scale;
  multiple components indicate a disconnected design.

## Typical workflow

1.  Optional: fit the MFRM with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Call `analyze_hierarchical_structure(fit)` (or on the raw data).

3.  Read `summary(x)` for the condensed view.

4.  Feed the object to
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    and
    [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md)
    to record the review in publication bundles.
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
    uses the fit-level `FacetSampleSizeFlag` to add a Methods sentence
    automatically.

## References

McEwen, M. R. (2018). *The effects of incomplete rating designs on
results from many-facets-Rasch model analyses* (Doctoral thesis, Brigham
Young University). <https://scholarsarchive.byu.edu/etd/6689/>

Linacre, J. M. (2026). *A User's Guide to FACETS, Version 4.5.0*.
Winsteps.com.

Kish, L. (1965). *Survey Sampling*. New York: Wiley.

Koo, T. K., & Li, M. Y. (2016). A guideline of selecting and reporting
intraclass correlation coefficients for reliability research. *Journal
of Chiropractic Medicine, 15*(2), 155-163.

## See also

[`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md),
[`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

## Examples

``` r
toy <- load_mfrmr_data("example_core")
hs <- analyze_hierarchical_structure(toy,
                                     facets = c("Rater", "Criterion"),
                                     compute_icc = FALSE,
                                     igraph_layout = FALSE)
summary(hs)
#> mfrm_hierarchical_structure
#> 
#> Summary:
#>  NFacets NestedPairs CrossedPairs ICCAvailable ConnectivityComponents
#>        2           0            3        FALSE                     NA
#> 
#> Nesting review:
#>  FacetA    FacetB NestingIndex_AinB NestingIndex_BinA Direction
#>  Person     Rater                 0                 0   crossed
#>  Person Criterion                 0                 0   crossed
#>   Rater Criterion                 0                 0   crossed

# \donttest{
# Full review when lme4 and igraph are available.
if (requireNamespace("lme4", quietly = TRUE) &&
    requireNamespace("igraph", quietly = TRUE)) {
  hs_full <- analyze_hierarchical_structure(toy,
                                            facets = c("Rater", "Criterion"))
  summary(hs_full)
  plot(hs_full, type = "icc")
}
#> mfrm_hierarchical_structure
#> 
#> Summary:
#>  NFacets NestedPairs CrossedPairs ICCAvailable ConnectivityComponents
#>        2           0            3         TRUE                      1
#> 
#> Nesting review:
#>  FacetA    FacetB NestingIndex_AinB NestingIndex_BinA Direction
#>  Person     Rater                 0                 0   crossed
#>  Person Criterion                 0                 0   crossed
#>   Rater Criterion                 0                 0   crossed
#> 
#> ICC (lme4 variance-components):
#> mfrm_facet_icc
#>   ICC rows: 768 input, 768 used, 0 excluded.
#>      Facet   Variance    ICC Interpretation InterpretationScale ICC_CI_Lower
#>     Person 0.34626071 0.3511           Poor  Koo-Li reliability           NA
#>      Rater 0.02667343 0.0270  Trivial share      Variance share           NA
#>  Criterion 0.02188365 0.0222  Trivial share      Variance share           NA
#>   Residual 0.59144865 0.5997    Large share      Variance share           NA
#>  ICC_CI_Upper ICC_CI_Level ICC_CI_Method ICC_CI_Status InputRows UsedRows
#>            NA         0.95          none Not requested       768      768
#>            NA         0.95          none Not requested       768      768
#>            NA         0.95          none Not requested       768      768
#>            NA         0.95          none Not requested       768      768
#>  ExcludedRows
#>             0
#>             0
#>             0
#>             0
#> 
#> Design-effect approximations:
#> mfrm_facet_design_effect (per-facet approximation)
#>   EffectiveN is a descriptive row count, not full-design precision.
#>   ICC rows: 768 input, 768 used, 0 excluded.
#>      Facet AvgClusterSize    ICC DesignEffect EffectiveN InputRows UsedRows
#>      Rater            192 0.0270        6.157      124.7       768      768
#>  Criterion            192 0.0222        5.240      146.6       768      768
#>  ExcludedRows
#>             0
#>             0
#> 
#> Bipartite connectivity (via igraph):
#>   Components: 1 
#>   Largest component: 56 
#>   Isolates: 0 

# }
```
