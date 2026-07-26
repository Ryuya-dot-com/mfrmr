# Build a case-level misfit review bundle

Build a case-level misfit review bundle

## Usage

``` r
build_misfit_casebook(
  fit,
  diagnostics = NULL,
  unexpected = NULL,
  displacement = NULL,
  administration_id = NULL,
  wave_id = NULL,
  top_n = 25
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- unexpected:

  Optional output from
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md).

- displacement:

  Optional output from
  [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md).

- administration_id:

  Optional scalar identifier describing the current administration or
  form. It is stored in row-level provenance and summary outputs when
  supplied.

- wave_id:

  Optional scalar identifier for the current wave or occasion. It is
  stored in row-level provenance and summary outputs when supplied.

- top_n:

  Maximum number of rows to keep in compact summary outputs.

## Value

An object of class `mfrm_misfit_casebook`.

## Details

`build_misfit_casebook()` is a synthesis layer over package-native
screening outputs. It does not invent a new misfit statistic. Instead,
it organizes existing evidence families into one case-level review
surface:

- element-level Infit / Outfit MnSq misfit from `diagnostics$fit` (rows
  whose Infit or Outfit MnSq falls outside the configured Linacre
  heuristic review band, 0.5-1.5 by default)

- strict marginal cell screens from `diagnostics$marginal_fit$top_cells`

- strict pairwise screens from
  `diagnostics$marginal_fit$pairwise$top_pairs`

- unexpected responses from
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)

- displacement flags from
  [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)

The result is an operational review bundle. It is not a formal
adjudication system, and repeated signals across evidence families
should be prioritized over any single isolated case row. In addition to
raw case rows, the object includes stable grouping views such as
`by_person`, `by_facet_level`, `by_source_family`, and `by_wave` to
support operational triage. The `source_support` component records which
evidence families are currently supported, caveated, or deferred under
the active model.

## Recommended input route

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Build diagnostics with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

3.  Optionally build
    [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)
    and
    [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)
    yourself when you want custom thresholds before synthesizing the
    casebook.

## GPCM boundary

For bounded `GPCM`, the helper is available with caveat. The casebook
inherits exploratory screening semantics from the underlying residual
and strict marginal sources; it should not be read as a formal
inferential case test.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md),
[`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
[`plot_displacement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_displacement.md),
[`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md),
[`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", model = "RSM", quad_points = 5)
diag <- diagnose_mfrm(fit, diagnostic_mode = "both", residual_pca = "none")
casebook <- build_misfit_casebook(fit, diagnostics = diag, top_n = 10)
summary(casebook)
#> mfrm Misfit Casebook Summary
#> 
#> Overview
#>  Model DiagnosticMode    ReviewStatus AdministrationID WaveID TotalCases
#>    RSM           both review_required             <NA>   <NA>         59
#>  RollupRows GroupViews TopCaseRows SourcesAvailable GPCMSupport
#>          42          8          10                4    deferred
#> 
#> Status
#>            Item           Value
#>  Overall status review_required
#>           Model             RSM
#>    Bounded GPCM        deferred
#> 
#> Key Warnings
#>  - Strict marginal cell screening contributed 2 flagged case rows.
#>  - Strict pairwise screening contributed 1 flagged pair rows.
#>  - Unexpected-response screening contributed 50 case rows.
#>  - Displacement screening contributed 2 flagged facet-level rows.
#> 
#> Next Actions
#>  - Use plot_marginal_fit(diagnostics, draw = FALSE) to inspect the largest
#>    first-order strict marginal cells.
#>  - Use plot_marginal_pairwise(diagnostics, draw = FALSE) to inspect the
#>    strongest pairwise local-dependence signals.
#>  - Use plot_unexpected(unexpected, draw = FALSE) to review the most surprising
#>    person-level observations.
#>  - Use plot_displacement(displacement, draw = FALSE) when flagged facet levels
#>    suggest anchor or stability review.
#> 
#> Case Rollup
#>  AdministrationID WaveID  RollupType           RollupKey          RollupLabel
#>              <NA>   <NA>      person                P023         Person: P023
#>              <NA>   <NA>      person                P007         Person: P007
#>              <NA>   <NA>      person                P004         Person: P004
#>              <NA>   <NA>      person                P022         Person: P022
#>              <NA>   <NA>      person                P044         Person: P044
#>              <NA>   <NA>      person                P025         Person: P025
#>              <NA>   <NA>      person                P019         Person: P019
#>              <NA>   <NA>      person                P033         Person: P033
#>              <NA>   <NA>      person                P029         Person: P029
#>              <NA>   <NA>      person                P032         Person: P032
#>              <NA>   <NA>      person                P005         Person: P005
#>              <NA>   <NA>      person                P031         Person: P031
#>              <NA>   <NA>      person                P047         Person: P047
#>              <NA>   <NA>      person                P046         Person: P046
#>              <NA>   <NA>      person                P026         Person: P026
#>              <NA>   <NA>      person                P011         Person: P011
#>              <NA>   <NA>      person                P009         Person: P009
#>              <NA>   <NA>      person                P041         Person: P041
#>              <NA>   <NA>      person                P027         Person: P027
#>              <NA>   <NA>      person                P036         Person: P036
#>              <NA>   <NA>      person                P043         Person: P043
#>              <NA>   <NA>      person                P014         Person: P014
#>              <NA>   <NA>      person                P039         Person: P039
#>              <NA>   <NA>      person                P010         Person: P010
#>              <NA>   <NA>      person                P020         Person: P020
#>              <NA>   <NA>      person                P030         Person: P030
#>              <NA>   <NA>      person                P012         Person: P012
#>              <NA>   <NA>      person                P028         Person: P028
#>              <NA>   <NA>      person                P037         Person: P037
#>              <NA>   <NA>      person                P038         Person: P038
#>              <NA>   <NA>      person                P017         Person: P017
#>              <NA>   <NA>      person                P002         Person: P002
#>              <NA>   <NA>      person                P001         Person: P001
#>              <NA>   <NA>      person                P035         Person: P035
#>              <NA>   <NA> facet_level Criterion::Language  Criterion: Language
#>              <NA>   <NA>  facet_pair     Rater::R01::R04 Rater pair: R01::R04
#>              <NA>   <NA> facet_level        Person::P015         Person: P015
#>              <NA>   <NA> facet_level        Person::P024         Person: P024
#>              <NA>   <NA> facet_level        Person::P023         Person: P023
#>              <NA>   <NA> facet_level        Person::P004         Person: P004
#>              <NA>   <NA> facet_level        Person::P019         Person: P019
#>              <NA>   <NA> facet_level        Person::P005         Person: P005
#>   SourceFamily     Facet SupportBasis InterpretationTier
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>     unexpected      <NA>       legacy operational_review
#>  marginal_cell Criterion marginal_fit     screening_only
#>  marginal_pair     Rater marginal_fit        exploratory
#>   displacement    Person       legacy operational_review
#>   displacement    Person       legacy operational_review
#>    element_fit    Person       legacy operational_review
#>    element_fit    Person       legacy operational_review
#>    element_fit    Person       legacy operational_review
#>    element_fit    Person       legacy operational_review
#>                                                 PrimaryPlotRoute SupportStatus
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                        plot_unexpected(unexpected, draw = FALSE)     supported
#>                     plot_marginal_fit(diagnostics, draw = FALSE)     supported
#>                plot_marginal_pairwise(diagnostics, draw = FALSE)     supported
#>                    plot_displacement(displacement, draw = FALSE)     supported
#>                    plot_displacement(displacement, draw = FALSE)     supported
#>  plot_qc_dashboard(fit, diagnostics = diagnostics, draw = FALSE)     supported
#>  plot_qc_dashboard(fit, diagnostics = diagnostics, draw = FALSE)     supported
#>  plot_qc_dashboard(fit, diagnostics = diagnostics, draw = FALSE)     supported
#>  plot_qc_dashboard(fit, diagnostics = diagnostics, draw = FALSE)     supported
#>  Cases DistinctSourceRows PersonsFlagged MaxPriority MeanPriority EvidenceN
#>      1                  1              1       8.446        8.446         1
#>      1                  1              1       6.453        6.453         1
#>      2                  2              1       6.341        5.173         2
#>      1                  1              1       6.134        6.134         1
#>      2                  2              1       5.824        5.139         2
#>      2                  2              1       5.281        4.273         2
#>      2                  2              1       5.118        4.654         2
#>      1                  1              1       4.894        4.894         1
#>      3                  3              1       4.778        4.279         3
#>      1                  1              1       4.760        4.760         1
#>      4                  4              1       4.722        4.025         4
#>      1                  1              1       4.688        4.688         1
#>      1                  1              1       4.592        4.592         1
#>      1                  1              1       4.579        4.579         1
#>      1                  1              1       4.522        4.522         1
#>      1                  1              1       4.457        4.457         1
#>      1                  1              1       4.390        4.390         1
#>      1                  1              1       4.297        4.297         1
#>      2                  2              1       4.276        4.251         2
#>      1                  1              1       4.269        4.269         1
#>      1                  1              1       4.260        4.260         1
#>      1                  1              1       4.241        4.241         1
#>      3                  3              1       4.228        3.804         3
#>      1                  1              1       4.197        4.197         1
#>      2                  2              1       4.187        3.716         2
#>      3                  3              1       4.065        3.553         3
#>      1                  1              1       3.989        3.989         1
#>      1                  1              1       3.987        3.987         1
#>      1                  1              1       3.986        3.986         1
#>      1                  1              1       3.953        3.953         1
#>      2                  2              1       3.409        3.301         2
#>      1                  1              1       3.271        3.271         1
#>      1                  1              1       3.242        3.242         1
#>      1                  1              1       3.218        3.218         1
#>      2                  2              0       2.430        2.390         2
#>      1                  1              0       2.037        2.037         1
#>      1                  1              0       1.433        1.433         1
#>      1                  1              0       1.413        1.413         1
#>      1                  1              0       0.755        0.755         1
#>      1                  1              0       0.441        0.441         1
#>      1                  1              0       0.418        0.418         1
#>      1                  1              0       0.406        0.406         1
#>                                                  TopCaseID
#>                                              unexpected:71
#>                                             unexpected:199
#>                                             unexpected:628
#>                                             unexpected:166
#>                                             unexpected:236
#>                                             unexpected:361
#>                                             unexpected:739
#>                                             unexpected:609
#>                                             unexpected:749
#>                                              unexpected:80
#>                                               unexpected:5
#>                                             unexpected:703
#>                                             unexpected:719
#>                                             unexpected:574
#>                                             unexpected:362
#>                                             unexpected:347
#>                                             unexpected:681
#>                                             unexpected:521
#>                                             unexpected:507
#>                                             unexpected:132
#>                                             unexpected:619
#>                                             unexpected:110
#>                                             unexpected:327
#>                                             unexpected:490
#>                                             unexpected:116
#>                                             unexpected:222
#>                                             unexpected:156
#>                                             unexpected:412
#>                                             unexpected:661
#>                                             unexpected:566
#>                                             unexpected:593
#>                                             unexpected:578
#>                                             unexpected:721
#>                                             unexpected:179
#>  marginal_cell:facet_level::Criterion::Language::2::<none>
#>                                   pairwise:Rater::R01::R04
#>                                  displacement:Person::P015
#>                                  displacement:Person::P024
#>                                   element_fit:Person::P023
#>                                   element_fit:Person::P004
#>                                   element_fit:Person::P019
#>                                   element_fit:Person::P005
#> 
#> Grouping Views
#>                   View Rows
#>              by_person   34
#>         by_facet_level    7
#>          by_facet_pair    1
#>       by_source_family    5
#>               by_facet    3
#>      by_administration    0
#>                by_wave    0
#>  facet_views$Criterion    1
#>     facet_views$Person    6
#>      facet_views$Rater    1
#>                                                                 Description
#>  Repeated signals concentrated on the same person across evidence families.
#>                      Repeated signals concentrated on the same facet level.
#>                            Repeated pairwise signals within the same facet.
#>                              Volume and priority by evidence source family.
#>                                      All flagged evidence grouped by facet.
#>             Operational concentration by administration/form when provided.
#>                   Operational concentration by wave/occasion when provided.
#>                           Case-rollup rows restricted to facet `Criterion`.
#>                              Case-rollup rows restricted to facet `Person`.
#>                               Case-rollup rows restricted to facet `Rater`.
#> 
#> Plot Follow-up
#>   SourceFamily Available                                        PlotHelper
#>  marginal_cell      TRUE      plot_marginal_fit(diagnostics, draw = FALSE)
#>  marginal_pair      TRUE plot_marginal_pairwise(diagnostics, draw = FALSE)
#>     unexpected      TRUE         plot_unexpected(unexpected, draw = FALSE)
#>   displacement      TRUE     plot_displacement(displacement, draw = FALSE)
#>                                                        Trigger
#>        Use when strict first-order category cells are flagged.
#>    Use when strict pairwise local-dependence rows are flagged.
#>    Use when person-level unexpected responses dominate review.
#>  Use when anchor or facet-level displacement rows are flagged.
#> 
#> Source Summary
#>   SourceFamily SupportBasis InterpretationTier
#>     unexpected       legacy operational_review
#>    element_fit       legacy operational_review
#>  marginal_cell marginal_fit     screening_only
#>   displacement       legacy operational_review
#>  marginal_pair marginal_fit        exploratory
#>                                                 PrimaryPlotRoute Cases
#>                        plot_unexpected(unexpected, draw = FALSE)    50
#>  plot_qc_dashboard(fit, diagnostics = diagnostics, draw = FALSE)     4
#>                     plot_marginal_fit(diagnostics, draw = FALSE)     2
#>                    plot_displacement(displacement, draw = FALSE)     2
#>                plot_marginal_pairwise(diagnostics, draw = FALSE)     1
#>  MaxPriority
#>        8.446
#>        0.755
#>        2.430
#>        1.433
#>        2.037
#> 
#> Source Support
#>   SourceFamily Available SupportBasis    Status
#>  marginal_cell      TRUE marginal_fit supported
#>  marginal_pair      TRUE marginal_fit supported
#>     unexpected      TRUE       legacy supported
#>   displacement      TRUE       legacy supported
#>                                                                    Note
#>  Strict marginal cell screening is available for operational follow-up.
#>       Strict pairwise screening is available for operational follow-up.
#>       Unexpected-response rows are available for operational follow-up.
#>              Displacement rows are available for operational follow-up.
#> 
#> Top Cases
#>          CaseID                 CaseType SourceFamily
#>   unexpected:71 unexpected_response_case   unexpected
#>  unexpected:199 unexpected_response_case   unexpected
#>  unexpected:628 unexpected_response_case   unexpected
#>  unexpected:166 unexpected_response_case   unexpected
#>  unexpected:236 unexpected_response_case   unexpected
#>  unexpected:361 unexpected_response_case   unexpected
#>  unexpected:739 unexpected_response_case   unexpected
#>  unexpected:609 unexpected_response_case   unexpected
#>  unexpected:749 unexpected_response_case   unexpected
#>   unexpected:80 unexpected_response_case   unexpected
#>                  SourceTable SourceRowKey AdministrationID WaveID PrimaryUnit
#>  unexpected_response_table()           71             <NA>   <NA>        P023
#>  unexpected_response_table()          199             <NA>   <NA>        P007
#>  unexpected_response_table()          628             <NA>   <NA>        P004
#>  unexpected_response_table()          166             <NA>   <NA>        P022
#>  unexpected_response_table()          236             <NA>   <NA>        P044
#>  unexpected_response_table()          361             <NA>   <NA>        P025
#>  unexpected_response_table()          739             <NA>   <NA>        P019
#>  unexpected_response_table()          609             <NA>   <NA>        P033
#>  unexpected_response_table()          749             <NA>   <NA>        P029
#>  unexpected_response_table()           80             <NA>   <NA>        P032
#>     PrimaryUnitType Person Facet Level Category PairKey         ContextKey Wave
#>  person_observation   P023  <NA>  <NA>        2    <NA>      R02 | Content <NA>
#>  person_observation   P007  <NA>  <NA>        1    <NA> R01 | Organization <NA>
#>  person_observation   P004  <NA>  <NA>        1    <NA>     R02 | Accuracy <NA>
#>  person_observation   P022  <NA>  <NA>        4    <NA>      R04 | Content <NA>
#>  person_observation   P044  <NA>  <NA>        1    <NA> R01 | Organization <NA>
#>  person_observation   P025  <NA>  <NA>        1    <NA> R04 | Organization <NA>
#>  person_observation   P019  <NA>  <NA>        1    <NA>     R04 | Accuracy <NA>
#>  person_observation   P033  <NA>  <NA>        4    <NA>     R01 | Accuracy <NA>
#>  person_observation   P029  <NA>  <NA>        4    <NA>     R04 | Accuracy <NA>
#>  person_observation   P032  <NA>  <NA>        4    <NA>      R02 | Content <NA>
#>                      Signal            Direction Magnitude ReviewPriority
#>  Unexpected response screen  Lower than expected     8.446          8.446
#>  Unexpected response screen  Lower than expected     6.453          6.453
#>  Unexpected response screen  Lower than expected     6.341          6.341
#>  Unexpected response screen Higher than expected     6.134          6.134
#>  Unexpected response screen  Lower than expected     5.824          5.824
#>  Unexpected response screen  Lower than expected     5.281          5.281
#>  Unexpected response screen  Lower than expected     5.118          5.118
#>  Unexpected response screen Higher than expected     4.894          4.894
#>  Unexpected response screen Higher than expected     4.778          4.778
#>  Unexpected response screen Higher than expected     4.760          4.760
#>  WithinSourceRank EvidenceN SupportBasis InterpretationTier
#>                 1         1       legacy operational_review
#>                 2         1       legacy operational_review
#>                 3         1       legacy operational_review
#>                 4         1       legacy operational_review
#>                 5         1       legacy operational_review
#>                 6         1       legacy operational_review
#>                 7         1       legacy operational_review
#>                 8         1       legacy operational_review
#>                 9         1       legacy operational_review
#>                10         1       legacy operational_review
#>                           PrimaryPlotRoute SupportStatus
#>  plot_unexpected(unexpected, draw = FALSE)     supported
#>  plot_unexpected(unexpected, draw = FALSE)     supported
#>  plot_unexpected(unexpected, draw = FALSE)     supported
#>  plot_unexpected(unexpected, draw = FALSE)     supported
#>  plot_unexpected(unexpected, draw = FALSE)     supported
#>  plot_unexpected(unexpected, draw = FALSE)     supported
#>  plot_unexpected(unexpected, draw = FALSE)     supported
#>  plot_unexpected(unexpected, draw = FALSE)     supported
#>  plot_unexpected(unexpected, draw = FALSE)     supported
#>  plot_unexpected(unexpected, draw = FALSE)     supported
#> 
#> Support Status
#>         Scope    Status
#>     RSM / PCM supported
#>  bounded GPCM  deferred
#>                                                                   Note
#>  Supported as a synthesis layer over package-native screening outputs.
#>                 Deferred unless a bounded GPCM source fit is supplied.
#> 
#> Notes
#>  - Misfit casebook rows are operational review units, not formal case
#>    decisions.
#>  - The helper preserves source-family-specific screening logic rather than
#>    collapsing all evidence into one opaque score.
#>  - Repeated signals across strict marginal, unexpected-response, and
#>    displacement sources deserve priority.
casebook$top_cases
#> # A tibble: 10 × 26
#>    CaseID CaseType SourceFamily SourceTable SourceRowKey AdministrationID WaveID
#>    <chr>  <chr>    <chr>        <chr>       <chr>        <chr>            <chr> 
#>  1 unexp… unexpec… unexpected   unexpected… 71           NA               NA    
#>  2 unexp… unexpec… unexpected   unexpected… 199          NA               NA    
#>  3 unexp… unexpec… unexpected   unexpected… 628          NA               NA    
#>  4 unexp… unexpec… unexpected   unexpected… 166          NA               NA    
#>  5 unexp… unexpec… unexpected   unexpected… 236          NA               NA    
#>  6 unexp… unexpec… unexpected   unexpected… 361          NA               NA    
#>  7 unexp… unexpec… unexpected   unexpected… 739          NA               NA    
#>  8 unexp… unexpec… unexpected   unexpected… 609          NA               NA    
#>  9 unexp… unexpec… unexpected   unexpected… 749          NA               NA    
#> 10 unexp… unexpec… unexpected   unexpected… 80           NA               NA    
#> # ℹ 19 more variables: PrimaryUnit <chr>, PrimaryUnitType <chr>, Person <chr>,
#> #   Facet <chr>, Level <chr>, Category <int>, PairKey <chr>, ContextKey <chr>,
#> #   Wave <chr>, Signal <chr>, Direction <chr>, Magnitude <dbl>,
#> #   ReviewPriority <dbl>, WithinSourceRank <int>, EvidenceN <int>,
#> #   SupportBasis <chr>, InterpretationTier <chr>, PrimaryPlotRoute <chr>,
#> #   SupportStatus <chr>
# }
```
