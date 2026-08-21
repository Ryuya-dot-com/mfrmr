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
# A balanced slice retains every Rater and Criterion while running quickly.
toy <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", model = "RSM", quad_points = 5)
diag <- diagnose_mfrm(fit, diagnostic_mode = "both", residual_pca = "none")
casebook <- build_misfit_casebook(fit, diagnostics = diag, top_n = 10)
summary(casebook)
#> mfrm Misfit Casebook Summary
#> 
#> Overview
#>  Model DiagnosticMode    ReviewStatus AdministrationID WaveID TotalCases
#>    RSM           both review_required             <NA>   <NA>         49
#>  RollupRows GroupViews TopCaseRows SourcesAvailable GPCMSupport
#>          14          7          10                2    deferred
#> 
#> Status
#>            Item           Value
#>  Overall status review_required
#>           Model             RSM
#>    Bounded GPCM        deferred
#> 
#> Key Warnings
#>  - Strict pairwise screening contributed 1 flagged pair rows.
#>  - Unexpected-response screening contributed 47 case rows.
#> 
#> Next Actions
#>  - Use plot_marginal_pairwise(diagnostics, draw = FALSE) to inspect the
#>    strongest pairwise local-dependence signals.
#>  - Use plot_unexpected(unexpected, draw = FALSE) to review the most surprising
#>    person-level observations.
#> 
#> Case Rollup
#>  AdministrationID WaveID  RollupType                     RollupKey
#>              <NA>   <NA>      person                          P004
#>              <NA>   <NA>      person                          P007
#>              <NA>   <NA>      person                          P010
#>              <NA>   <NA>      person                          P011
#>              <NA>   <NA>      person                          P012
#>              <NA>   <NA>      person                          P001
#>              <NA>   <NA>      person                          P005
#>              <NA>   <NA>      person                          P009
#>              <NA>   <NA>      person                          P003
#>              <NA>   <NA>      person                          P002
#>              <NA>   <NA>      person                          P008
#>              <NA>   <NA>      person                          P006
#>              <NA>   <NA>  facet_pair Criterion::Accuracy::Language
#>              <NA>   <NA> facet_level                  Person::P004
#>                         RollupLabel  SourceFamily     Facet SupportBasis
#>                        Person: P004    unexpected      <NA>       legacy
#>                        Person: P007    unexpected      <NA>       legacy
#>                        Person: P010    unexpected      <NA>       legacy
#>                        Person: P011    unexpected      <NA>       legacy
#>                        Person: P012    unexpected      <NA>       legacy
#>                        Person: P001    unexpected      <NA>       legacy
#>                        Person: P005    unexpected      <NA>       legacy
#>                        Person: P009    unexpected      <NA>       legacy
#>                        Person: P003    unexpected      <NA>       legacy
#>                        Person: P002    unexpected      <NA>       legacy
#>                        Person: P008    unexpected      <NA>       legacy
#>                        Person: P006    unexpected      <NA>       legacy
#>  Criterion pair: Accuracy::Language marginal_pair Criterion marginal_fit
#>                        Person: P004   element_fit    Person       legacy
#>  InterpretationTier
#>  operational_review
#>  operational_review
#>  operational_review
#>  operational_review
#>  operational_review
#>  operational_review
#>  operational_review
#>  operational_review
#>  operational_review
#>  operational_review
#>  operational_review
#>  operational_review
#>         exploratory
#>  operational_review
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
#>                plot_marginal_pairwise(diagnostics, draw = FALSE)     supported
#>  plot_qc_dashboard(fit, diagnostics = diagnostics, draw = FALSE)     supported
#>  Cases DistinctSourceRows PersonsFlagged MaxPriority MeanPriority EvidenceN
#>      4                  4              1       6.217        3.973         4
#>      5                  5              1       5.701        3.106         5
#>      4                  4              1       4.770        3.216         4
#>      5                  5              1       4.414        3.271         5
#>      5                  5              1       4.329        3.197         5
#>      6                  6              1       3.883        3.068         6
#>      6                  6              1       3.756        3.029         6
#>      3                  3              1       3.673        2.772         3
#>      3                  3              1       3.498        2.928         3
#>      3                  3              1       2.965        2.540         3
#>      1                  1              1       2.556        2.556         1
#>      2                  2              1       2.553        2.501         2
#>      1                  1              0       2.042        2.042         1
#>      1                  1              0       0.487        0.487         1
#>                               TopCaseID
#>                          unexpected:160
#>                           unexpected:55
#>                          unexpected:130
#>                           unexpected:95
#>                           unexpected:48
#>                          unexpected:181
#>                            unexpected:5
#>                          unexpected:177
#>                          unexpected:123
#>                          unexpected:146
#>                            unexpected:8
#>                            unexpected:6
#>  pairwise:Criterion::Accuracy::Language
#>                element_fit:Person::P004
#> 
#> Grouping Views
#>                   View Rows
#>              by_person   12
#>         by_facet_level    1
#>          by_facet_pair    1
#>       by_source_family    3
#>               by_facet    2
#>      by_administration    0
#>                by_wave    0
#>  facet_views$Criterion    1
#>     facet_views$Person    1
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
#> 
#> Plot Follow-up
#>   SourceFamily Available                                        PlotHelper
#>  marginal_pair      TRUE plot_marginal_pairwise(diagnostics, draw = FALSE)
#>     unexpected      TRUE         plot_unexpected(unexpected, draw = FALSE)
#>                                                      Trigger
#>  Use when strict pairwise local-dependence rows are flagged.
#>  Use when person-level unexpected responses dominate review.
#> 
#> Source Summary
#>   SourceFamily SupportBasis InterpretationTier
#>     unexpected       legacy operational_review
#>  marginal_pair marginal_fit        exploratory
#>    element_fit       legacy operational_review
#>                                                 PrimaryPlotRoute Cases
#>                        plot_unexpected(unexpected, draw = FALSE)    47
#>                plot_marginal_pairwise(diagnostics, draw = FALSE)     1
#>  plot_qc_dashboard(fit, diagnostics = diagnostics, draw = FALSE)     1
#>  MaxPriority
#>        6.217
#>        2.042
#>        0.487
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
#>  unexpected:160 unexpected_response_case   unexpected
#>   unexpected:55 unexpected_response_case   unexpected
#>  unexpected:130 unexpected_response_case   unexpected
#>   unexpected:28 unexpected_response_case   unexpected
#>   unexpected:95 unexpected_response_case   unexpected
#>   unexpected:48 unexpected_response_case   unexpected
#>  unexpected:181 unexpected_response_case   unexpected
#>  unexpected:179 unexpected_response_case   unexpected
#>    unexpected:5 unexpected_response_case   unexpected
#>  unexpected:177 unexpected_response_case   unexpected
#>                  SourceTable SourceRowKey AdministrationID WaveID PrimaryUnit
#>  unexpected_response_table()          160             <NA>   <NA>        P004
#>  unexpected_response_table()           55             <NA>   <NA>        P007
#>  unexpected_response_table()          130             <NA>   <NA>        P010
#>  unexpected_response_table()           28             <NA>   <NA>        P004
#>  unexpected_response_table()           95             <NA>   <NA>        P011
#>  unexpected_response_table()           48             <NA>   <NA>        P012
#>  unexpected_response_table()          181             <NA>   <NA>        P001
#>  unexpected_response_table()          179             <NA>   <NA>        P011
#>  unexpected_response_table()            5             <NA>   <NA>        P005
#>  unexpected_response_table()          177             <NA>   <NA>        P009
#>     PrimaryUnitType Person Facet Level Category PairKey         ContextKey Wave
#>  person_observation   P004  <NA>  <NA>        1    <NA>     R02 | Accuracy <NA>
#>  person_observation   P007  <NA>  <NA>        1    <NA> R01 | Organization <NA>
#>  person_observation   P010  <NA>  <NA>        1    <NA>     R03 | Language <NA>
#>  person_observation   P004  <NA>  <NA>        2    <NA>      R03 | Content <NA>
#>  person_observation   P011  <NA>  <NA>        4    <NA> R04 | Organization <NA>
#>  person_observation   P012  <NA>  <NA>        1    <NA>      R04 | Content <NA>
#>  person_observation   P001  <NA>  <NA>        1    <NA>     R04 | Accuracy <NA>
#>  person_observation   P011  <NA>  <NA>        1    <NA>     R03 | Accuracy <NA>
#>  person_observation   P005  <NA>  <NA>        2    <NA>      R01 | Content <NA>
#>  person_observation   P009  <NA>  <NA>        3    <NA>     R03 | Accuracy <NA>
#>                      Signal            Direction Magnitude ReviewPriority
#>  Unexpected response screen  Lower than expected     6.217          6.217
#>  Unexpected response screen  Lower than expected     5.701          5.701
#>  Unexpected response screen  Lower than expected     4.770          4.770
#>  Unexpected response screen  Lower than expected     4.672          4.672
#>  Unexpected response screen Higher than expected     4.414          4.414
#>  Unexpected response screen  Lower than expected     4.329          4.329
#>  Unexpected response screen  Lower than expected     3.883          3.883
#>  Unexpected response screen  Lower than expected     3.858          3.858
#>  Unexpected response screen  Lower than expected     3.756          3.756
#>  Unexpected response screen Higher than expected     3.673          3.673
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
#>  1 unexp… unexpec… unexpected   unexpected… 160          NA               NA    
#>  2 unexp… unexpec… unexpected   unexpected… 55           NA               NA    
#>  3 unexp… unexpec… unexpected   unexpected… 130          NA               NA    
#>  4 unexp… unexpec… unexpected   unexpected… 28           NA               NA    
#>  5 unexp… unexpec… unexpected   unexpected… 95           NA               NA    
#>  6 unexp… unexpec… unexpected   unexpected… 48           NA               NA    
#>  7 unexp… unexpec… unexpected   unexpected… 181          NA               NA    
#>  8 unexp… unexpec… unexpected   unexpected… 179          NA               NA    
#>  9 unexp… unexpec… unexpected   unexpected… 5            NA               NA    
#> 10 unexp… unexpec… unexpected   unexpected… 177          NA               NA    
#> # ℹ 19 more variables: PrimaryUnit <chr>, PrimaryUnitType <chr>, Person <chr>,
#> #   Facet <chr>, Level <chr>, Category <int>, PairKey <chr>, ContextKey <chr>,
#> #   Wave <chr>, Signal <chr>, Direction <chr>, Magnitude <dbl>,
#> #   ReviewPriority <dbl>, WithinSourceRank <int>, EvidenceN <int>,
#> #   SupportBasis <chr>, InterpretationTier <chr>, PrimaryPlotRoute <chr>,
#> #   SupportStatus <chr>
# }
```
