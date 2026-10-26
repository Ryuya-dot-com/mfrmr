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
  Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
  for migration of saved diagnostics.

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

For `GPCM`, the helper is available with caveat. The casebook inherits
exploratory screening semantics from the underlying residual and strict
marginal sources; it should not be read as a formal inferential case
test.

## Saved-result reuse

Supplied screening results must describe this fitted analysis. Results
from another fit or older results without identity metadata are refused.
See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
to recreate them from the saved fit and matching diagnostics without
refitting the model.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md),
[plot(x, type =
"unexpected")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"displacement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"marginal_fit")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"marginal_pairwise")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

## Examples

``` r
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
#>    RSM           both review_required             <NA>   <NA>          3
#>  RollupRows GroupViews TopCaseRows SourcesAvailable GPCMSupport
#>           3          7           3                2    deferred
#> 
#> Status
#>            Item           Value
#>  Overall status review_required
#>           Model             RSM
#>            GPCM        deferred
#> 
#> Key Warnings
#>  - Strict pairwise screening contributed 1 flagged pair rows.
#>  - Unexpected-response screening contributed 1 case rows.
#> 
#> Next Actions
#>  - Use plot(diagnostics, type = "marginal_pairwise", draw = FALSE) to inspect
#>    the strongest pairwise local-dependence signals.
#>  - Use plot(unexpected, type = "unexpected", draw = FALSE) to review the most
#>    surprising person-level observations.
#> 
#> Case Rollup
#>  AdministrationID WaveID  RollupType                     RollupKey
#>              <NA>   <NA>      person                          P004
#>              <NA>   <NA>  facet_pair Criterion::Accuracy::Language
#>              <NA>   <NA> facet_level                  Person::P004
#>                         RollupLabel  SourceFamily     Facet SupportBasis
#>                        Person: P004    unexpected      <NA>       legacy
#>  Criterion pair: Accuracy::Language marginal_pair Criterion marginal_fit
#>                        Person: P004   element_fit    Person       legacy
#>  InterpretationTier
#>  operational_review
#>         exploratory
#>  operational_review
#>                                                 PrimaryPlotRoute SupportStatus
#>              plot(unexpected, type = "unexpected", draw = FALSE)     supported
#>      plot(diagnostics, type = "marginal_pairwise", draw = FALSE)     supported
#>  plot(fit, type = "qc", diagnostics = diagnostics, draw = FALSE)     supported
#>  Cases DistinctSourceRows PersonsFlagged MaxPriority MeanPriority EvidenceN
#>      1                  1              1       6.217        6.217         1
#>      1                  1              0       2.042        2.042         1
#>      1                  1              0       0.487        0.487         1
#>                               TopCaseID
#>                          unexpected:160
#>  pairwise:Criterion::Accuracy::Language
#>                element_fit:Person::P004
#> 
#> Grouping Views
#>                   View Rows
#>              by_person    1
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
#>   SourceFamily Available
#>  marginal_pair      TRUE
#>     unexpected      TRUE
#>                                                   PlotHelper
#>  plot(diagnostics, type = "marginal_pairwise", draw = FALSE)
#>          plot(unexpected, type = "unexpected", draw = FALSE)
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
#>              plot(unexpected, type = "unexpected", draw = FALSE)     1
#>      plot(diagnostics, type = "marginal_pairwise", draw = FALSE)     1
#>  plot(fit, type = "qc", diagnostics = diagnostics, draw = FALSE)     1
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
#>                                  CaseID                       CaseType
#>                          unexpected:160       unexpected_response_case
#>  pairwise:Criterion::Accuracy::Language pairwise_local_dependence_case
#>                element_fit:Person::P004               element_fit_case
#>   SourceFamily                                 SourceTable
#>     unexpected                 unexpected_response_table()
#>  marginal_pair diagnostics$marginal_fit$pairwise$top_pairs
#>    element_fit                             diagnostics$fit
#>                   SourceRowKey AdministrationID WaveID          PrimaryUnit
#>                            160             <NA>   <NA>                 P004
#>  Criterion::Accuracy::Language             <NA>   <NA> Accuracy vs Language
#>                   Person::P004             <NA>   <NA>         Person: P004
#>     PrimaryUnitType Person     Facet Level Category            PairKey
#>  person_observation   P004      <NA>  <NA>        1               <NA>
#>          facet_pair   <NA> Criterion  <NA>       NA Accuracy::Language
#>         facet_level   <NA>    Person  P004       NA               <NA>
#>               ContextKey Wave                                  Signal
#>           R02 | Accuracy <NA>              Unexpected response screen
#>                Criterion <NA> Strict pairwise local-dependence screen
#>  Infit=1.56, Outfit=1.63 <NA>              MnSq misfit (band 0.5-1.5)
#>                               Direction Magnitude ReviewPriority
#>                     Lower than expected     6.217          6.217
#>  Lower than expected adjacent agreement     2.042          2.042
#>                  Outfit MnSq above band     0.487          0.487
#>  WithinSourceRank EvidenceN SupportBasis InterpretationTier
#>                 1         1       legacy operational_review
#>                 1         1 marginal_fit        exploratory
#>                 1         1       legacy operational_review
#>                                                 PrimaryPlotRoute SupportStatus
#>              plot(unexpected, type = "unexpected", draw = FALSE)     supported
#>      plot(diagnostics, type = "marginal_pairwise", draw = FALSE)     supported
#>  plot(fit, type = "qc", diagnostics = diagnostics, draw = FALSE)     supported
#> 
#> Support Status
#>      Scope    Status
#>  RSM / PCM supported
#>       GPCM  deferred
#>                                                                   Note
#>  Supported as a synthesis layer over package-native screening outputs.
#>                         Deferred unless a GPCM source fit is supplied.
#> 
#> Notes
#>  - Misfit casebook rows are operational review units, not formal case
#>    decisions.
#>  - The helper preserves source-family-specific screening logic rather than
#>    collapsing all evidence into one opaque score.
#>  - Repeated signals across strict marginal, unexpected-response, and
#>    displacement sources deserve priority.
casebook$top_cases
#> # A tibble: 3 × 26
#>   CaseID  CaseType SourceFamily SourceTable SourceRowKey AdministrationID WaveID
#>   <chr>   <chr>    <chr>        <chr>       <chr>        <chr>            <chr> 
#> 1 unexpe… unexpec… unexpected   unexpected… 160          NA               NA    
#> 2 pairwi… pairwis… marginal_pa… diagnostic… Criterion::… NA               NA    
#> 3 elemen… element… element_fit  diagnostic… Person::P004 NA               NA    
#> # ℹ 19 more variables: PrimaryUnit <chr>, PrimaryUnitType <chr>, Person <chr>,
#> #   Facet <chr>, Level <chr>, Category <int>, PairKey <chr>, ContextKey <chr>,
#> #   Wave <chr>, Signal <chr>, Direction <chr>, Magnitude <dbl>,
#> #   ReviewPriority <dbl>, WithinSourceRank <int>, EvidenceN <int>,
#> #   SupportBasis <chr>, InterpretationTier <chr>, PrimaryPlotRoute <chr>,
#> #   SupportStatus <chr>
```
