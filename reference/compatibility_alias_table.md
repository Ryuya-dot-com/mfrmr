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

Internal soft-deprecated helpers are deliberately excluded here. This
table is only for retained user-facing aliases that remain part of the
public surface.

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
#>             Alias               PreferredName     Surface      Lifecycle
#> 1     mfrmRFacets             run_mfrm_facets    function retained_alias
#> 2     analyze_dif                 analyze_dff    function retained_alias
#> 3            JMLE                         JML    argument retained_alias
#> 4     ReadyForAPA                  DraftReady      column retained_alias
#> 5              SE                     ModelSE      column retained_alias
#> 6 Fair(M) Average             AdjustedAverage      column retained_alias
#> 7 Fair(Z) Average StandardizedAdjustedAverage      column retained_alias
#> 8           FairM             AdjustedAverage plot_metric retained_alias
#> 9           FairZ StandardizedAdjustedAverage plot_metric retained_alias
#>                         RetainedFor           RemovalPlan
#> 1            older workflow scripts No scheduled removal.
#> 2 earlier DIF-oriented package code No scheduled removal.
#> 3          historical method labels No scheduled removal.
#> 4           older reporting scripts No scheduled removal.
#> 5       older measure-table scripts No scheduled removal.
#> 6     FACETS-style table continuity No scheduled removal.
#> 7     FACETS-style table continuity No scheduled removal.
#> 8      legacy plot metric shortcuts No scheduled removal.
#> 9      legacy plot metric shortcuts No scheduled removal.
#>                                                                                     Notes
#> 1                      Compatibility wrapper for the legacy-compatible one-shot workflow.
#> 2 DFF naming is preferred for many-facet workflows; the older DIF name is still accepted.
#> 3                   Accepted by fit wrappers, but user-facing summaries and docs use JML.
#> 4                    Backward-compatible reporting flag; values match DraftReady exactly.
#> 5              Backward-compatible standard-error column; ModelSE is the preferred label.
#> 6                     Legacy adjusted-average column retained alongside the native label.
#> 7        Legacy standardized adjusted-average column retained alongside the native label.
#> 8                      Accepted by plot_fair_average() as a shortcut for AdjustedAverage.
#> 9          Accepted by plot_fair_average() as a shortcut for StandardizedAdjustedAverage.
compatibility_alias_table("functions")
#>         Alias   PreferredName  Surface      Lifecycle
#> 1 mfrmRFacets run_mfrm_facets function retained_alias
#> 2 analyze_dif     analyze_dff function retained_alias
#>                         RetainedFor           RemovalPlan
#> 1            older workflow scripts No scheduled removal.
#> 2 earlier DIF-oriented package code No scheduled removal.
#>                                                                                     Notes
#> 1                      Compatibility wrapper for the legacy-compatible one-shot workflow.
#> 2 DFF naming is preferred for many-facet workflows; the older DIF name is still accepted.
compatibility_alias_table("fields")
#> [1] Alias         PreferredName Surface       Lifecycle     RetainedFor  
#> [6] RemovalPlan   Notes        
#> <0 rows> (or 0-length row.names)
compatibility_alias_table("columns")
#>             Alias               PreferredName Surface      Lifecycle
#> 4     ReadyForAPA                  DraftReady  column retained_alias
#> 5              SE                     ModelSE  column retained_alias
#> 6 Fair(M) Average             AdjustedAverage  column retained_alias
#> 7 Fair(Z) Average StandardizedAdjustedAverage  column retained_alias
#>                     RetainedFor           RemovalPlan
#> 4       older reporting scripts No scheduled removal.
#> 5   older measure-table scripts No scheduled removal.
#> 6 FACETS-style table continuity No scheduled removal.
#> 7 FACETS-style table continuity No scheduled removal.
#>                                                                              Notes
#> 4             Backward-compatible reporting flag; values match DraftReady exactly.
#> 5       Backward-compatible standard-error column; ModelSE is the preferred label.
#> 6              Legacy adjusted-average column retained alongside the native label.
#> 7 Legacy standardized adjusted-average column retained alongside the native label.
```
