# List retained compatibility aliases and preferred names

List retained compatibility aliases and preferred names

## Usage

``` r
compatibility_alias_table(
  scope = c("all", "functions", "arguments", "fields", "columns", "plot_metrics")
)
```

## Arguments

- scope:

  Which alias surface to return: `"all"`, `"functions"`, `"arguments"`,
  `"fields"`, `"columns"`, or `"plot_metrics"`.

## Value

A data.frame with one row per retained alias and columns:

- `Alias`

- `PreferredName`

- `Surface`

- `Lifecycle`

- `RetainedFor`

- `RemovalPlan`

- `Notes`

## Details

This helper is a compact public registry of the compatibility aliases
that `mfrmr` intentionally keeps visible for older scripts and
downstream handoffs. It is meant to answer two questions quickly:

1.  Which old names are still accepted?

2.  Which package-native names should new code use instead?

Non-exported soft-deprecated helpers are deliberately excluded here.
This table is only for retained user-facing aliases that remain part of
the public surface.

## Typical workflow

1.  Call `compatibility_alias_table()` when reading older scripts or
    reports.

2.  Use `PreferredName` when updating older analysis code.

3.  Prefer the package-native name in all new outputs and scripts.

## See also

[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md),
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
[`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md)

## Examples

``` r
compatibility_alias_table()
#>                                Alias                       PreferredName
#> 1                        mfrmRFacets                     run_mfrm_facets
#> 2                        analyze_dif                         analyze_dff
#> 3                       mfrm_cluster                    mfrm_cluster_pam
#> 4          mfrm_response_imputations             review_mfrm_imputations
#> 5  mfrm_response_imputations(impute) review_mfrm_imputations(impute_ids)
#> 6                      keep_original                     category_policy
#> 7                               JMLE                                 JML
#> 8                        ReadyForAPA                          DraftReady
#> 9                                 SE                             ModelSE
#> 10                   Fair(M) Average                     AdjustedAverage
#> 11                   Fair(Z) Average         StandardizedAdjustedAverage
#> 12                             FairM                     AdjustedAverage
#> 13                             FairZ         StandardizedAdjustedAverage
#>        Surface      Lifecycle
#> 1     function retained_alias
#> 2     function retained_alias
#> 3     function retained_alias
#> 4     function retained_alias
#> 5     argument retained_alias
#> 6     argument retained_alias
#> 7     argument retained_alias
#> 8       column retained_alias
#> 9       column retained_alias
#> 10      column retained_alias
#> 11      column retained_alias
#> 12 plot_metric retained_alias
#> 13 plot_metric retained_alias
#>                                                    RetainedFor
#> 1                                       older workflow scripts
#> 2                            earlier DIF-oriented package code
#> 3         earlier feature-clustering scripts and saved results
#> 4  earlier assigned-score imputation scripts and saved results
#> 5        event-ID selection in earlier imputation-review calls
#> 6   existing score-category policy in fitting and input review
#> 7                                     historical method labels
#> 8                                      older reporting scripts
#> 9                                  older measure-table scripts
#> 10                               FACETS-style table continuity
#> 11                               FACETS-style table continuity
#> 12                                legacy plot metric shortcuts
#> 13                                legacy plot metric shortcuts
#>              RemovalPlan
#> 1  No scheduled removal.
#> 2  No scheduled removal.
#> 3  No scheduled removal.
#> 4  No scheduled removal.
#> 5  No scheduled removal.
#> 6  No scheduled removal.
#> 7  No scheduled removal.
#> 8  No scheduled removal.
#> 9  No scheduled removal.
#> 10 No scheduled removal.
#> 11 No scheduled removal.
#> 12 No scheduled removal.
#> 13 No scheduled removal.
#>                                                                                                                                                                     Notes
#> 1                                                                                                      Compatibility wrapper for the legacy-compatible one-shot workflow.
#> 2                                                                                 DFF naming is preferred for many-facet workflows; the older DIF name is still accepted.
#> 3                                                                   Identical Gower/PAM implementation and result class; the preferred name makes the algorithm explicit.
#> 4                                                                          Same supplied-completion checks and result class; this function does not generate imputations.
#> 5                                                       Use event-ID values in impute_ids, not a logical switch; the old wrapper retains impute and its positional order.
#> 6  In fit_mfrm(), describe_mfrm_data() and review_mfrm_anchors(): TRUE maps to preserve and FALSE to collapse. Defaults are unchanged; conflicting explicit choices fail.
#> 7                                                                                                   Accepted by fit wrappers, but user-facing summaries and docs use JML.
#> 8                                                                                                    Backward-compatible reporting flag; values match DraftReady exactly.
#> 9                                                                                              Backward-compatible standard-error column; ModelSE is the preferred label.
#> 10                                                                                                    Legacy adjusted-average column retained alongside the native label.
#> 11                                                                                       Legacy standardized adjusted-average column retained alongside the native label.
#> 12                                                                                                     Accepted by plot_fair_average() as a shortcut for AdjustedAverage.
#> 13                                                                                         Accepted by plot_fair_average() as a shortcut for StandardizedAdjustedAverage.
compatibility_alias_table("functions")
#>                       Alias           PreferredName  Surface      Lifecycle
#> 1               mfrmRFacets         run_mfrm_facets function retained_alias
#> 2               analyze_dif             analyze_dff function retained_alias
#> 3              mfrm_cluster        mfrm_cluster_pam function retained_alias
#> 4 mfrm_response_imputations review_mfrm_imputations function retained_alias
#>                                                   RetainedFor
#> 1                                      older workflow scripts
#> 2                           earlier DIF-oriented package code
#> 3        earlier feature-clustering scripts and saved results
#> 4 earlier assigned-score imputation scripts and saved results
#>             RemovalPlan
#> 1 No scheduled removal.
#> 2 No scheduled removal.
#> 3 No scheduled removal.
#> 4 No scheduled removal.
#>                                                                                                   Notes
#> 1                                    Compatibility wrapper for the legacy-compatible one-shot workflow.
#> 2               DFF naming is preferred for many-facet workflows; the older DIF name is still accepted.
#> 3 Identical Gower/PAM implementation and result class; the preferred name makes the algorithm explicit.
#> 4        Same supplied-completion checks and result class; this function does not generate imputations.
compatibility_alias_table("fields")
#> [1] Alias         PreferredName Surface       Lifecycle     RetainedFor  
#> [6] RemovalPlan   Notes        
#> <0 rows> (or 0-length row.names)
compatibility_alias_table("columns")
#>              Alias               PreferredName Surface      Lifecycle
#> 8      ReadyForAPA                  DraftReady  column retained_alias
#> 9               SE                     ModelSE  column retained_alias
#> 10 Fair(M) Average             AdjustedAverage  column retained_alias
#> 11 Fair(Z) Average StandardizedAdjustedAverage  column retained_alias
#>                      RetainedFor           RemovalPlan
#> 8        older reporting scripts No scheduled removal.
#> 9    older measure-table scripts No scheduled removal.
#> 10 FACETS-style table continuity No scheduled removal.
#> 11 FACETS-style table continuity No scheduled removal.
#>                                                                               Notes
#> 8              Backward-compatible reporting flag; values match DraftReady exactly.
#> 9        Backward-compatible standard-error column; ModelSE is the preferred label.
#> 10              Legacy adjusted-average column retained alongside the native label.
#> 11 Legacy standardized adjusted-average column retained alongside the native label.
```
