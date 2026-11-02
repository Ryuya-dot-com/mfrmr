# List compatibility aliases, migration status and preferred names

List compatibility aliases, migration status and preferred names

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

A data.frame with one row per compatibility name and columns:

- `Alias`

- `PreferredName`

- `Surface`

- `Lifecycle`

- `RetainedFor`

- `RemovalPlan`

- `Notes`

## Details

This helper records compatibility names used in older scripts and
downstream handoffs, including aliases removed from exports. It answers
two questions:

1.  Which old names are still accepted?

2.  Which package-native names should new code use instead?

`Lifecycle = "retained_alias"` means the alias is still accepted;
`"removed_export"` means scripts must use the replacement. Private
helpers that were never public are excluded. See
[mfrmr_api_migration_030](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_api_migration_030.md)
for the complete 0.3.0 development migration, including merged
operations.

## Typical workflow

1.  Call `compatibility_alias_table()` when reading older scripts or
    reports.

2.  Use `PreferredName` when updating older analysis code.

3.  Prefer the package-native name in all new outputs and scripts.

## See also

[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_compatibility_layer.md),
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/run_mfrm_facets.md),
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_dff.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/reporting_checklist.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fair_average_table.md),
[plot(x, type =
"fair_average")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)

## Examples

``` r
compatibility_alias_table()
#>                                Alias                       PreferredName
#> 1                        mfrmRFacets                     run_mfrm_facets
#> 2                        analyze_dif                         analyze_dff
#> 3                   mfrm_cluster_pam                        mfrm_cluster
#> 4          mfrm_response_imputations             review_mfrm_imputations
#> 5  mfrm_response_imputations(impute) review_mfrm_imputations(impute_ids)
#> 6                    import_mirt_fit                      import_irt_fit
#> 7                     import_tam_fit                      import_irt_fit
#> 8                     import_erm_fit                      import_irt_fit
#> 9              read_facets_fit_table                 read_facets_results
#> 10              mfrmr_interval_guide                  mfrmr_output_guide
#> 11         visual_reporting_template                  mfrmr_output_guide
#> 12            gpcm_capability_matrix                  mfrmr_output_guide
#> 13     mfrm_calibration_capabilities                  mfrmr_output_guide
#> 14                     anchor_review                 review_mfrm_anchors
#> 15                  precision_review             precision_review_report
#> 16                     keep_original                     category_policy
#> 17                              JMLE                                 JML
#> 18                       ReadyForAPA                          DraftReady
#> 19                                SE                             ModelSE
#> 20                   Fair(M) Average                     AdjustedAverage
#> 21                   Fair(Z) Average         StandardizedAdjustedAverage
#> 22                             FairM                     AdjustedAverage
#> 23                             FairZ         StandardizedAdjustedAverage
#>        Surface      Lifecycle
#> 1     function removed_export
#> 2     function removed_export
#> 3     function removed_export
#> 4     function removed_export
#> 5     argument removed_export
#> 6     function removed_export
#> 7     function removed_export
#> 8     function removed_export
#> 9     function removed_export
#> 10    function removed_export
#> 11    function removed_export
#> 12    function removed_export
#> 13    function removed_export
#> 14    function removed_export
#> 15    function removed_export
#> 16    argument retained_alias
#> 17    argument retained_alias
#> 18      column retained_alias
#> 19      column retained_alias
#> 20      column retained_alias
#> 21      column retained_alias
#> 22 plot_metric retained_alias
#> 23 plot_metric retained_alias
#>                                                    RetainedFor
#> 1                                       older workflow scripts
#> 2                            earlier DIF-oriented package code
#> 3         earlier feature-clustering scripts and saved results
#> 4  earlier assigned-score imputation scripts and saved results
#> 5        event-ID selection in earlier imputation-review calls
#> 6                             external mirt fit import scripts
#> 7                              external TAM fit import scripts
#> 8                              external eRm fit import scripts
#> 9                     external FACETS fit-table import scripts
#> 10                    confidence-interval route lookup scripts
#> 11                    figure-reporting template lookup scripts
#> 12               GPCM workflow/score capability lookup scripts
#> 13              portable calibration capability lookup scripts
#> 14                       fitted anchor-review field extraction
#> 15               diagnostics precision-review field extraction
#> 16  existing score-category policy in fitting and input review
#> 17                                    historical method labels
#> 18                                     older reporting scripts
#> 19                                 older measure-table scripts
#> 20                               FACETS-style table continuity
#> 21                               FACETS-style table continuity
#> 22                                legacy plot metric shortcuts
#> 23                                legacy plot metric shortcuts
#>                                                                           RemovalPlan
#> 1                     Removed in the 0.3.0 development series; use run_mfrm_facets().
#> 2  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 3  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 4  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 5  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 6  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 7  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 8  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 9  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 10 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 11 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 12 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 13 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 14 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 15 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 16                                                              No scheduled removal.
#> 17                                                              No scheduled removal.
#> 18                                                              No scheduled removal.
#> 19                                                              No scheduled removal.
#> 20                                                              No scheduled removal.
#> 21                                                              No scheduled removal.
#> 22                                                              No scheduled removal.
#> 23                                                              No scheduled removal.
#>                                                                                                                                                                     Notes
#> 1                                                                                                      Use run_mfrm_facets(); the former workflow alias has been removed.
#> 2                                                                                                          Use analyze_dff(); the former DIF alias is no longer exported.
#> 3                                                                                         Use mfrm_cluster(method = 'pam'); the underlying Gower/PAM result is unchanged.
#> 4                                                                          Same supplied-completion checks and result class; this function does not generate imputations.
#> 5                                                                         Use event-ID values in impute_ids, not a logical switch; the old wrapper is no longer exported.
#> 6                                                Use import_irt_fit(fit, model, ..., source = 'mirt') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.
#> 7                                                 Use import_irt_fit(fit, model, ..., source = 'tam') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.
#> 8                                                 Use import_irt_fit(fit, model, ..., source = 'erm') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.
#> 9                                                                    Use read_facets_results(file, ...) and pass it directly to facets_fit_review(fit, facets_fit = ...).
#> 10                                                                             Use mfrmr_output_guide('intervals', category); returned interval-guide table is unchanged.
#> 11                                                                     Use mfrmr_output_guide('visual_templates', category); returned figure-template table is unchanged.
#> 12                                                   Use mfrmr_output_guide('gpcm_capabilities', status = ..., view = ...); returned GPCM capability matrix is unchanged.
#> 13                                                      Use mfrmr_output_guide('calibration_capabilities'); returned portable-calibration capability matrix is unchanged.
#> 14                                                                                  Read fit$config$anchor_review directly, or call review_mfrm_anchors() before fitting.
#> 15                                                                         Read diagnostics$precision_review directly, or call precision_review_report(fit, diagnostics).
#> 16 In fit_mfrm(), describe_mfrm_data() and review_mfrm_anchors(): TRUE maps to preserve and FALSE to collapse. Defaults are unchanged; conflicting explicit choices fail.
#> 17                                                                                                  Accepted by fit wrappers, but user-facing summaries and docs use JML.
#> 18                                                                                                   Backward-compatible reporting flag; values match DraftReady exactly.
#> 19                                                                                             Backward-compatible standard-error column; ModelSE is the preferred label.
#> 20                                                                                                    Legacy adjusted-average column retained alongside the native label.
#> 21                                                                                       Legacy standardized adjusted-average column retained alongside the native label.
#> 22                                                                                          Accepted by plot(x, type = "fair_average") as a shortcut for AdjustedAverage.
#> 23                                                                              Accepted by plot(x, type = "fair_average") as a shortcut for StandardizedAdjustedAverage.
compatibility_alias_table("functions")
#>                            Alias           PreferredName  Surface
#> 1                    mfrmRFacets         run_mfrm_facets function
#> 2                    analyze_dif             analyze_dff function
#> 3               mfrm_cluster_pam            mfrm_cluster function
#> 4      mfrm_response_imputations review_mfrm_imputations function
#> 6                import_mirt_fit          import_irt_fit function
#> 7                 import_tam_fit          import_irt_fit function
#> 8                 import_erm_fit          import_irt_fit function
#> 9          read_facets_fit_table     read_facets_results function
#> 10          mfrmr_interval_guide      mfrmr_output_guide function
#> 11     visual_reporting_template      mfrmr_output_guide function
#> 12        gpcm_capability_matrix      mfrmr_output_guide function
#> 13 mfrm_calibration_capabilities      mfrmr_output_guide function
#> 14                 anchor_review     review_mfrm_anchors function
#> 15              precision_review precision_review_report function
#>         Lifecycle                                                 RetainedFor
#> 1  removed_export                                      older workflow scripts
#> 2  removed_export                           earlier DIF-oriented package code
#> 3  removed_export        earlier feature-clustering scripts and saved results
#> 4  removed_export earlier assigned-score imputation scripts and saved results
#> 6  removed_export                            external mirt fit import scripts
#> 7  removed_export                             external TAM fit import scripts
#> 8  removed_export                             external eRm fit import scripts
#> 9  removed_export                    external FACETS fit-table import scripts
#> 10 removed_export                    confidence-interval route lookup scripts
#> 11 removed_export                    figure-reporting template lookup scripts
#> 12 removed_export               GPCM workflow/score capability lookup scripts
#> 13 removed_export              portable calibration capability lookup scripts
#> 14 removed_export                       fitted anchor-review field extraction
#> 15 removed_export               diagnostics precision-review field extraction
#>                                                                           RemovalPlan
#> 1                     Removed in the 0.3.0 development series; use run_mfrm_facets().
#> 2  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 3  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 4  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 6  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 7  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 8  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 9  Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 10 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 11 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 12 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 13 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 14 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#> 15 Removed from exports in the 0.3.0 development series; see mfrmr_api_migration_030.
#>                                                                                                                       Notes
#> 1                                                        Use run_mfrm_facets(); the former workflow alias has been removed.
#> 2                                                            Use analyze_dff(); the former DIF alias is no longer exported.
#> 3                                           Use mfrm_cluster(method = 'pam'); the underlying Gower/PAM result is unchanged.
#> 4                            Same supplied-completion checks and result class; this function does not generate imputations.
#> 6  Use import_irt_fit(fit, model, ..., source = 'mirt') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.
#> 7   Use import_irt_fit(fit, model, ..., source = 'tam') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.
#> 8   Use import_irt_fit(fit, model, ..., source = 'erm') or source = 'auto'; returned mfrm_imported_fit bundle is unchanged.
#> 9                      Use read_facets_results(file, ...) and pass it directly to facets_fit_review(fit, facets_fit = ...).
#> 10                               Use mfrmr_output_guide('intervals', category); returned interval-guide table is unchanged.
#> 11                       Use mfrmr_output_guide('visual_templates', category); returned figure-template table is unchanged.
#> 12     Use mfrmr_output_guide('gpcm_capabilities', status = ..., view = ...); returned GPCM capability matrix is unchanged.
#> 13        Use mfrmr_output_guide('calibration_capabilities'); returned portable-calibration capability matrix is unchanged.
#> 14                                    Read fit$config$anchor_review directly, or call review_mfrm_anchors() before fitting.
#> 15                           Read diagnostics$precision_review directly, or call precision_review_report(fit, diagnostics).
compatibility_alias_table("fields")
#> [1] Alias         PreferredName Surface       Lifecycle     RetainedFor  
#> [6] RemovalPlan   Notes        
#> <0 rows> (or 0-length row.names)
compatibility_alias_table("columns")
#>              Alias               PreferredName Surface      Lifecycle
#> 18     ReadyForAPA                  DraftReady  column retained_alias
#> 19              SE                     ModelSE  column retained_alias
#> 20 Fair(M) Average             AdjustedAverage  column retained_alias
#> 21 Fair(Z) Average StandardizedAdjustedAverage  column retained_alias
#>                      RetainedFor           RemovalPlan
#> 18       older reporting scripts No scheduled removal.
#> 19   older measure-table scripts No scheduled removal.
#> 20 FACETS-style table continuity No scheduled removal.
#> 21 FACETS-style table continuity No scheduled removal.
#>                                                                               Notes
#> 18             Backward-compatible reporting flag; values match DraftReady exactly.
#> 19       Backward-compatible standard-error column; ModelSE is the preferred label.
#> 20              Legacy adjusted-average column retained alongside the native label.
#> 21 Legacy standardized adjusted-average column retained alongside the native label.
```
