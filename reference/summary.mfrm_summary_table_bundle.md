# Summarize a summary-table bundle for manuscript QC

Summarize a summary-table bundle for manuscript QC

## Usage

``` r
# S3 method for class 'mfrm_summary_table_bundle'
summary(object, digits = 3, top_n = 8, ...)
```

## Arguments

- object:

  Output from
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md).

- digits:

  Number of digits used for numeric summaries.

- top_n:

  Maximum number of table-profile rows to keep.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_summary_table_bundle`.

## Details

This summary is designed to answer a manuscript-facing question: which
reporting tables are available, how large are they, which roles do they
serve, and which of them contain numeric content suitable for quick
plotting or appendix export.

## Interpreting output

- `overview`: source class, returned-table count, note count, and
  whether a numeric table is available for plotting.

- `role_summary`: counts and total size by reporting role.

- `table_catalog`: complete returned-table registry with plot/export
  bridges.

- `table_profile`: table-level dimensions, numeric-column counts, and
  missing values for the largest returned tables.

- `plot_index`: which returned tables are plot-ready and which
  bundle-level numeric QC routes they support.

- `appendix_presets`: conservative `all` / `recommended` / `compact`
  plus section-aware `methods` / `results` / `diagnostics` / `reporting`
  appendix-export presets derived from table roles.

- `appendix_role_summary`: counts of returned tables by reporting role
  under the same conservative appendix routing used by the bundle
  catalog.

- `appendix_section_summary`: counts of returned tables by
  manuscript-facing appendix section.

- `selection_handoff_table_summary`: workflow-only table-level appendix
  handoff crosswalk when present in the bundle.

- `selection_handoff_preset_summary`: workflow-only appendix handoff
  overview aggregated at the preset level when present in the bundle.

- `selection_handoff_bundle_summary`: workflow-only appendix handoff
  overview aggregated at the bundle-by-section level when present in the
  bundle.

- `selection_handoff_role_summary`: workflow-only appendix handoff
  overview aggregated at the reporting-role level when present in the
  bundle.

- `selection_handoff_role_section_summary`: workflow-only appendix
  handoff overview aggregated at the reporting-role by appendix-section
  level when present in the bundle.

- `selection_summary`, `selection_table_summary`,
  `selection_table_preset_summary`, `selection_role_summary`,
  `selection_section_summary`, and `selection_catalog`: preset-filtered
  appendix selection surfaces when workflow-only handoff tables are
  embedded in the bundle.

- `reporting_map`: where to go next for plotting, APA formatting, and
  export.

- `notes`: carried forward source-level caveats from the originating
  summary.

## Typical workflow

1.  Build `bundle <- build_summary_table_bundle(summary(...))`.

2.  Run `summary(bundle)` to see reporting coverage.

3.  Use `plot(bundle, type = "table_rows")` or
    `plot(bundle, type = "numeric_profile", which = ...)` for quick QC.

## See also

[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
bundle <- build_summary_table_bundle(fit)
summary(bundle)
#> Summary Table Bundle Summary
#> 
#> Overview
#>                 Title SourceClass     SummaryClass TablesAvailable
#>  Model Summary Tables    mfrm_fit summary.mfrm_fit              15
#>  TablesReturned AppendixPreset Notes NumericTables AnyNumericTable
#>              12           none     2            10            TRUE
#>  RecommendedAppendixTables CompactAppendixTables
#>                          8                     5
#> 
#> Role summary
#>                  Role Tables TotalRows TotalCols
#>          run_overview      1         1        87
#>         reporting_map      1         6         3
#>     population_coding      1         0         6
#>      population_basis      1         1        16
#>   person_distribution      1         1        10
#>    facet_distribution      1         2         7
#>    extreme_person_low      1        10        20
#>   extreme_person_high      1        10        20
#>  extreme_facet_levels      1         8         3
#>   estimation_settings      1         1        28
#>    category_structure      1         1         5
#>      analysis_caveats      1         0         8
#> 
#> Table catalog
#>                Table Rows Cols                 Role
#>             overview    1   87         run_overview
#>  population_overview    1   16     population_basis
#>    population_coding    0    6    population_coding
#>       facet_overview    2    7   facet_distribution
#>      person_overview    1   10  person_distribution
#>        step_overview    1    5   category_structure
#>    settings_overview    1   28  estimation_settings
#>        reporting_map    6    3        reporting_map
#>              caveats    0    8     analysis_caveats
#>       facet_extremes    8    3 extreme_facet_levels
#>          person_high   10   20  extreme_person_high
#>           person_low   10   20   extreme_person_low
#>                                                                                                                                     Description
#>                                                                              One-row model fit, convergence, and information-criteria overview.
#>                                                                                   Population-model basis, posterior basis, and omission review.
#>                                                    Latent-regression categorical covariate levels, contrasts, and encoded model-matrix columns.
#>                                                                                               Per-facet spread, range, and level-count summary.
#>                                                                                     Distribution of person measures and posterior SD summaries.
#>                                                                                                       Threshold range and monotonicity summary.
#>                                                                              Estimation settings that affect identification and interpretation.
#>                                                                                    Companion outputs to cite for manuscript-oriented reporting.
#>  Structured fit-level caveats such as retained zero-count categories, score-category recoding, and latent-regression population-model warnings.
#>                                                                                               Facet levels with the largest absolute estimates.
#>                                                                                                   Highest person measures from the current fit.
#>                                                                                                    Lowest person measures from the current fit.
#>  PlotReady NumericColumns               DefaultPlotTypes ExportReady
#>       TRUE             40 numeric_profile, first_numeric        TRUE
#>       TRUE              5 numeric_profile, first_numeric        TRUE
#>      FALSE              1                                       TRUE
#>       TRUE              6 numeric_profile, first_numeric        TRUE
#>       TRUE              9 numeric_profile, first_numeric        TRUE
#>       TRUE              4 numeric_profile, first_numeric        TRUE
#>       TRUE              5 numeric_profile, first_numeric        TRUE
#>      FALSE              0                                       TRUE
#>      FALSE              0                                       TRUE
#>       TRUE              1 numeric_profile, first_numeric        TRUE
#>       TRUE              7 numeric_profile, first_numeric        TRUE
#>       TRUE              7 numeric_profile, first_numeric        TRUE
#>  ApaTableReady                       RecommendedBridge AppendixSection
#>           TRUE              apa_table() / plot(bundle)         methods
#>           TRUE              apa_table() / plot(bundle)         methods
#>           TRUE apa_table() / export_summary_appendix()         methods
#>           TRUE              apa_table() / plot(bundle)         results
#>           TRUE              apa_table() / plot(bundle)         results
#>           TRUE              apa_table() / plot(bundle)         results
#>           TRUE              apa_table() / plot(bundle)         methods
#>           TRUE apa_table() / export_summary_appendix()        workflow
#>           TRUE apa_table() / export_summary_appendix()     diagnostics
#>           TRUE              apa_table() / plot(bundle)     exploratory
#>           TRUE              apa_table() / plot(bundle)     exploratory
#>           TRUE              apa_table() / plot(bundle)     exploratory
#>  RecommendedAppendix CompactAppendix PreferredAppendixOrder
#>                 TRUE            TRUE                     10
#>                 TRUE            TRUE                     20
#>                 TRUE           FALSE                     36
#>                 TRUE            TRUE                     40
#>                 TRUE           FALSE                     50
#>                 TRUE            TRUE                     60
#>                 TRUE           FALSE                     80
#>                FALSE           FALSE                    900
#>                 TRUE            TRUE                    132
#>                FALSE           FALSE                    910
#>                FALSE           FALSE                    920
#>                FALSE           FALSE                    930
#>                                                                                     AppendixRationale
#>                                                     Always include the main run-identification table.
#>                               Include whenever population-model interpretation is part of the report.
#>                 Include when categorical population covariates were encoded through the model matrix.
#>                                                  Core facet spread and scale-location appendix table.
#>                                          Useful for full appendices but omitted from compact presets.
#>                                                               Core threshold/category appendix table.
#>                                         Methods/settings appendix table; recommended but not compact.
#>                                     Bridge metadata, useful for workflow but not manuscript appendix.
#>  Recommended fit-level caveat table for score-support, population-model, and other analysis warnings.
#>                                            Exploratory extreme table; available only in full exports.
#>                                            Exploratory extreme table; available only in full exports.
#>                                            Exploratory extreme table; available only in full exports.
#> 
#> Table profile
#>                Table Rows Cols NumericColumns MissingValues
#>          person_high   10   20              7            10
#>           person_low   10   20              7            10
#>       facet_extremes    8    3              1             0
#>        reporting_map    6    3              0             0
#>       facet_overview    2    7              6             0
#>             overview    1   87             40            14
#>    settings_overview    1   28              5             5
#>  population_overview    1   16              5             5
#>                  Role
#>   extreme_person_high
#>    extreme_person_low
#>  extreme_facet_levels
#>         reporting_map
#>    facet_distribution
#>          run_overview
#>   estimation_settings
#>      population_basis
#>                                                         Description
#>                       Highest person measures from the current fit.
#>                        Lowest person measures from the current fit.
#>                   Facet levels with the largest absolute estimates.
#>        Companion outputs to cite for manuscript-oriented reporting.
#>                   Per-facet spread, range, and level-count summary.
#>  One-row model fit, convergence, and information-criteria overview.
#>  Estimation settings that affect identification and interpretation.
#>       Population-model basis, posterior basis, and omission review.
#> 
#> Plot index
#>                Table PlotReady NumericColumns               DefaultPlotTypes
#>             overview      TRUE             40 numeric_profile, first_numeric
#>  population_overview      TRUE              5 numeric_profile, first_numeric
#>    population_coding     FALSE              1                               
#>       facet_overview      TRUE              6 numeric_profile, first_numeric
#>      person_overview      TRUE              9 numeric_profile, first_numeric
#>        step_overview      TRUE              4 numeric_profile, first_numeric
#>    settings_overview      TRUE              5 numeric_profile, first_numeric
#>        reporting_map     FALSE              0                               
#>              caveats     FALSE              0                               
#>       facet_extremes      TRUE              1 numeric_profile, first_numeric
#>          person_high      TRUE              7 numeric_profile, first_numeric
#>           person_low      TRUE              7 numeric_profile, first_numeric
#> 
#> Appendix presets
#>       Preset Tables PlotReadyTables RolesCovered
#>          all     12               9           12
#>  recommended      8               6            8
#>      compact      5               4            5
#>      methods      4               3            4
#>      results      3               3            3
#>  diagnostics      1               0            1
#>    reporting      0               0            0
#>                               SectionsCovered
#>  methods, results, workflow, diagnostics, ...
#>                 methods, results, diagnostics
#>                 methods, results, diagnostics
#>                                       methods
#>                                       results
#>                                   diagnostics
#>                                              
#>                                                              KeyTables
#>  overview, population_overview, population_coding, facet_overview, ...
#>  overview, population_overview, population_coding, facet_overview, ...
#>      overview, population_overview, facet_overview, step_overview, ...
#>    overview, population_overview, population_coding, settings_overview
#>                         facet_overview, person_overview, step_overview
#>                                                                caveats
#>                                                                       
#>                                                                    PrimaryUse
#>                  Complete appendix handoff with every returned summary table.
#>             Manuscript appendix without bridge-only or preview-only surfaces.
#>    Reviewer-facing compact appendix focused on core design and fit summaries.
#>       Methods appendix subset focused on design, scoring basis, and settings.
#>       Results appendix subset focused on fit, precision, and scale summaries.
#>  Diagnostics appendix subset focused on caveats, flags, and precision checks.
#>  Reporting appendix subset focused on manuscript/checklist coverage surfaces.
#> 
#> Appendix role summary
#>                  Role Tables PlotReadyTables RecommendedTables CompactTables
#>          run_overview      1               1                 1             1
#>         reporting_map      1               0                 0             0
#>     population_coding      1               0                 1             0
#>      population_basis      1               1                 1             1
#>   person_distribution      1               1                 1             0
#>    facet_distribution      1               1                 1             1
#>    extreme_person_low      1               1                 0             0
#>   extreme_person_high      1               1                 0             0
#>  extreme_facet_levels      1               1                 0             0
#>   estimation_settings      1               1                 1             0
#>    category_structure      1               1                 1             1
#>      analysis_caveats      1               0                 1             1
#>  SectionsCovered           KeyTables
#>          methods            overview
#>         workflow       reporting_map
#>          methods   population_coding
#>          methods population_overview
#>          results     person_overview
#>          results      facet_overview
#>      exploratory          person_low
#>      exploratory         person_high
#>      exploratory      facet_extremes
#>          methods   settings_overview
#>          results       step_overview
#>      diagnostics             caveats
#> 
#> Appendix section summary
#>  AppendixSection Tables PlotReadyTables RecommendedTables CompactTables
#>          methods      4               3                 4             2
#>          results      3               3                 3             2
#>      exploratory      3               3                 0             0
#>         workflow      1               0                 0             0
#>      diagnostics      1               0                 1             1
#>  RolesCovered
#>             4
#>             3
#>             3
#>             1
#>             1
#> 
#> Reporting map
#>                                  Area CoveredHere
#>                     Coverage overview         yes
#>  Table catalog / manuscript selection         yes
#>         Numeric QC and quick plotting         yes
#>                 APA / appendix bridge         yes
#>                  Source-level caveats     partial
#>                                                                           CompanionOutput
#>                                                   summary(bundle)$overview / role_summary
#>                                        summary(bundle)$table_catalog / bundle$table_index
#>                                            summary(bundle)$plot_index / plot(bundle, ...)
#>  apa_table(bundle, which = ...) / export_summary_appendix(bundle, preset = "recommended")
#>                             bundle$notes and the originating summary()/diagnostics output
#> 
#> Notes
#>  - The iteration ceiling was reached before numerical readiness; estimates are review-only and must not be used to select a preferred result.
#>  - 3 empty table(s) were omitted from `tables`; use `include_empty = TRUE` to retain them.
# }
```
