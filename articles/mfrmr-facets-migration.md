# Migrating from Facets to mfrmr

This vignette walks Facets users through the equivalent `mfrmr`
workflow: preparing data, fitting an `RSM`/`PCM` many-facet Rasch-family
model with Facets-compatible defaults, generating the diagnostic and
reporting tables that the canonical Facets output stack provides, and
reviewing the output-contract boundary between the two systems. Bounded
`GPCM` can be fit in `mfrmr`, but its slope-aware score semantics are
intentionally outside the score-side Facets output-contract route.

## Mental model

The two stacks share the same psychometric framework but differ in
operating model.

Before treating a legacy workflow as covered, inspect the public
coverage boundary:

``` r

facets_feature_coverage()
facets_feature_coverage("not_implemented")
```

| Concept | Facets (Linacre 2026) | mfrmr |
|----|----|----|
| Input | Specification file plus data file | `data.frame` in long format |
| Estimation | JMLE by default | `JML` (legacy default) or `MML` (recommended for new analyses) |
| Fit-statistic basis | Residuals at JMLE estimates | Residuals at EAP person measures under `MML` (shrunken toward the mean); refit with `method = "JML"` for a JMLE-style residual basis |
| Models | Rating-scale, partial-credit, polytomous step models | `RSM`, `PCM`, bounded `GPCM` |
| Output | Tables 0-30 plus graphic files | Returned R objects with [`summary()`](https://rdrr.io/r/base/summary.html) and [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods |
| Anchoring | `D=`, `A=` fields in the specification | `anchors` and `group_anchors` arguments to [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md) |
| Bias / interaction | Table 14 | [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md) and [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md) |
| Wright map / variable map | Graphic variable-map output | `plot(fit, type = "wright")` and [`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md) |
| Fair average | Table 7 fair-M average | [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md) |
| Reproducibility | Specification file is the manifest | [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md) plus [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md) |

## A one-shot legacy-compatible call

If the goal is to reproduce a Facets-style script with minimal R-side
plumbing, use
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
(alias
[`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)):

``` r

library(mfrmr)
data("ej2021_study1", package = "mfrmr")

run <- run_mfrm_facets(
  data = ej2021_study1,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  model = "RSM",
  method = "JML"
)

names(run)
#> [1] "fit"          "diagnostics"  "iteration"    "fair_average" "rating_scale"
#> [6] "run_info"     "mapping"
```

The wrapper returns the same
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
and
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
objects that a step-by-step pipeline produces, plus the iteration log,
fair-average table, and rating-scale table:

``` r

summary(run$fit)
#> Many-Facet Rasch Model Summary
#>   Model: RSM | Method: JML | N: 1842 | Persons: 307 | Facets: 2 | Categories: 4
#> 
#> Status
#>  - Overall status: usable_fit
#>  - Convergence: converged (severity: pass, sup-norm: 0.127)
#>  - Estimation path: RSM / JML
#>  - Reporting readiness: exploratory_fit_ready_for_diagnostics
#> 
#> Key warnings
#>  - None.
#> 
#> Next actions
#>  - If formal SE/CI or strict marginal diagnostics are needed, re-fit with `method = "MML"`.
#>  - Run `diagnose_mfrm(fit, diagnostic_mode = "both")` for element-level fit review.
#>  - Use `plot(fit, type = "wright", preset = "publication")` for targeting and scale review.
#>  - After diagnostics, use `reporting_checklist(fit, diagnostics = diagnostics)` for reporting readiness.
#> 
#> Fit overview
#>   LogLik: -1681.608 | AIC: 4019.215 | BIC: 5829.319
#>   Converged: Yes | Status: converged | Basis: optimizer_gradient | Fn evals: 112 | Gr evals: 44
#>   Terminal gradient: sup-norm = 0.127 | RMS = 0.013 | Review tol = 0
#>   Optimization note: Optimizer returned convergence code 0.
#> 
#> Population basis
#>  PopulationModel PosteriorBasis Formula PersonRows DesignColumns
#>            FALSE     legacy_mml    <NA>         NA            NA
#>  CodingVariables ContrastVariables Policy ResidualVariance OmittedPersons
#>                                      <NA>               NA              0
#>  OmittedRows
#>            0
#> 
#> Facet overview
#>      Facet Levels MeanEstimate SDEstimate MinEstimate MaxEstimate  Span
#>  Criterion      3            0      0.880      -1.015       0.547 1.562
#>      Rater     18            0      0.852      -1.039       2.286 3.324
#> 
#> Person measure distribution
#>  Persons  Mean    SD Median    Min   Max   Span
#>      307 0.928 1.974  0.766 -2.519 12.63 15.149
#> 
#> Targeting (Person vs facet means; sum-to-zero ID makes Targeting = Person mean)
#>      Facet PersonMean FacetMean Targeting PersonSD FacetSD SpreadRatio
#>  Criterion      0.928         0     0.928    1.974   0.880       2.243
#>      Rater      0.928         0     0.928    1.974   0.852       2.317
#> 
#> Step parameter summary
#>  Steps    Min   Max  Span Monotonic
#>      3 -1.537 1.356 2.894      TRUE
#> 
#> Estimation settings
#>  StepFacet SlopeFacet NoncenterFacet WeightColumn QuadPoints RatingMin
#>       <NA>       <NA>         Person         <NA>         15         1
#>  RatingMax RatingRangeSource RatingMinSource RatingMaxSource DummyFacets
#>          4          observed        observed        observed            
#>  PositiveFacets FacetInteractions UnusedScoreCategories
#>                                                        
#>  UnusedScoreCategoryCount UnusedScoreCategoryType
#>                         0                    none
#> 
#> Most extreme facet levels (|estimate|)
#>      Facet             Level Estimate
#>      Rater               R13    2.286
#>      Rater               R06    1.238
#>      Rater               R04   -1.039
#>  Criterion Global_Impression   -1.015
#>      Rater               R08   -1.007
#> 
#> Highest person measures
#>  Person Estimate SE Extreme
#>    P018   12.630 NA    high
#>    P239   12.254 NA    high
#>    P209   11.561 NA    high
#>    P188   11.547 NA    high
#>    P007   10.686 NA    high
#> 
#> Lowest person measures
#>  Person Estimate SE Extreme
#>    P159   -2.519 NA    none
#>    P136   -2.384 NA    none
#>    P173   -2.299 NA    none
#>    P048   -2.189 NA    none
#>    P089   -1.925 NA    none
#> 
#> Paper reporting map
#>                                Area CoveredHere
#>  Model identification / convergence         yes
#>        Data structure / missingness          no
#>    Reliability / fit / residual PCA          no
#>                Category functioning     partial
#>     Bias / DIF / interaction checks          no
#>         Draft reporting / checklist          no
#>                                                                CompanionOutput
#>                                                                   summary(fit)
#>                                               summary(describe_mfrm_data(...))
#>                                                    summary(diagnose_mfrm(fit))
#>  rating_scale_table() / category_structure_report() / category_curves_report()
#>         summary(estimate_bias(...)) / analyze_dff() / related bundle summaries
#>                        reporting_checklist() / summary(build_apa_outputs(...))
head(run$fair_average)
#> $raw_by_facet
#> $raw_by_facet$Person
#> # A tibble: 307 × 18
#>    TotalScore TotalCount WeightdScore WeightdCount ObservedAverage FairM FairZ
#>         <int>      <int>        <dbl>        <dbl>           <dbl> <dbl> <dbl>
#>  1         24          6           24            6            4     4.00  4.00
#>  2         24          6           24            6            4     4.00  4.00
#>  3         24          6           24            6            4     4.00  4.00
#>  4         24          6           24            6            4     4.00  4.00
#>  5         24          6           24            6            4     4.00  4.00
#>  6         24          6           24            6            4     4.00  4.00
#>  7         23          6           23            6            3.83  3.97  3.97
#>  8         23          6           23            6            3.83  3.94  3.94
#>  9         23          6           23            6            3.83  3.89  3.89
#> 10         23          6           23            6            3.83  3.88  3.88
#> # ℹ 297 more rows
#> # ℹ 11 more variables: Measure <dbl>, ModelSE <dbl>, RealSE <dbl>,
#> #   InfitMnSq <dbl>, InfitZStd <dbl>, OutfitMnSq <dbl>, OutfitZStd <dbl>,
#> #   PtMeaCorr <dbl>, Anchor <chr>, Status <chr>, Level <chr>
#> 
#> $raw_by_facet$Rater
#> # A tibble: 18 × 18
#>    TotalScore TotalCount WeightdScore WeightdCount ObservedAverage FairM FairZ
#>         <int>      <int>        <dbl>        <dbl>           <dbl> <dbl> <dbl>
#>  1        148         75          148           75            1.97  1.71  1.37
#>  2        272        126          272          126            2.16  2.27  1.77
#>  3        190         75          190           75            2.53  2.63  2.06
#>  4        141         48          141           48            2.94  2.74  2.16
#>  5        515        192          515          192            2.68  2.86  2.27
#>  6        241         84          241           84            2.87  2.86  2.27
#>  7        387        150          387          150            2.58  2.89  2.30
#>  8        263         90          263           90            2.92  2.95  2.36
#>  9        103         33          103           33            3.12  3.07  2.48
#> 10        197         69          197           69            2.86  3.07  2.49
#> 11        370        123          370          123            3.01  3.22  2.66
#> 12        319        105          319          105            3.04  3.28  2.73
#> 13        528        174          528          174            3.03  3.30  2.75
#> 14         41         15           41           15            2.73  3.37  2.84
#> 15        140         42          140           42            3.33  3.47  2.99
#> 16        387        117          387          117            3.31  3.53  3.08
#> 17        749        228          749          228            3.29  3.54  3.09
#> 18        305         96          305           96            3.18  3.55  3.11
#> # ℹ 11 more variables: Measure <dbl>, ModelSE <dbl>, RealSE <dbl>,
#> #   InfitMnSq <dbl>, InfitZStd <dbl>, OutfitMnSq <dbl>, OutfitZStd <dbl>,
#> #   PtMeaCorr <dbl>, Anchor <chr>, Status <chr>, Level <chr>
#> 
#> $raw_by_facet$Criterion
#> # A tibble: 3 × 18
#>   TotalScore TotalCount WeightdScore WeightdCount ObservedAverage FairM FairZ
#>        <int>      <int>        <dbl>        <dbl>           <dbl> <dbl> <dbl>
#> 1       1618        614         1618          614            2.64  2.71  2.13
#> 2       1641        614         1641          614            2.67  2.76  2.18
#> 3       2037        614         2037          614            3.32  3.54  3.10
#> # ℹ 11 more variables: Measure <dbl>, ModelSE <dbl>, RealSE <dbl>,
#> #   InfitMnSq <dbl>, InfitZStd <dbl>, OutfitMnSq <dbl>, OutfitZStd <dbl>,
#> #   PtMeaCorr <dbl>, Anchor <chr>, Status <chr>, Level <chr>
#> 
#> 
#> $by_facet
#> $by_facet$Person
#>     Total Score Total Count Weightd Score Weightd Count Obsvd Average
#> 1            24           6            24             6          4.00
#> 2            24           6            24             6          4.00
#> 3            24           6            24             6          4.00
#> 4            24           6            24             6          4.00
#> 5            24           6            24             6          4.00
#> 6            24           6            24             6          4.00
#> 7            23           6            23             6          3.83
#> 8            23           6            23             6          3.83
#> 9            23           6            23             6          3.83
#> 10           23           6            23             6          3.83
#> 11           23           6            23             6          3.83
#> 12           23           6            23             6          3.83
#> 13           23           6            23             6          3.83
#> 14           23           6            23             6          3.83
#> 15           23           6            23             6          3.83
#> 16           23           6            23             6          3.83
#> 17           23           6            23             6          3.83
#> 18           23           6            23             6          3.83
#> 19           22           6            22             6          3.67
#> 20           23           6            23             6          3.83
#> 21           22           6            22             6          3.67
#> 22           21           6            21             6          3.50
#> 23           23           6            23             6          3.83
#> 24           19           6            19             6          3.17
#> 25           19           6            19             6          3.17
#> 26           23           6            23             6          3.83
#> 27           23           6            23             6          3.83
#> 28           21           6            21             6          3.50
#> 29           22           6            22             6          3.67
#> 30           23           6            23             6          3.83
#> 31           21           6            21             6          3.50
#> 32           22           6            22             6          3.67
#> 33           20           6            20             6          3.33
#> 34           22           6            22             6          3.67
#> 35           22           6            22             6          3.67
#> 36           22           6            22             6          3.67
#> 37           22           6            22             6          3.67
#> 38           18           6            18             6          3.00
#> 39           23           6            23             6          3.83
#> 40           19           6            19             6          3.17
#> 41           19           6            19             6          3.17
#> 42           18           6            18             6          3.00
#> 43           18           6            18             6          3.00
#> 44           22           6            22             6          3.67
#> 45           22           6            22             6          3.67
#> 46           22           6            22             6          3.67
#> 47           23           6            23             6          3.83
#> 48           21           6            21             6          3.50
#> 49           22           6            22             6          3.67
#> 50           21           6            21             6          3.50
#> 51           20           6            20             6          3.33
#> 52           21           6            21             6          3.50
#> 53           21           6            21             6          3.50
#> 54           21           6            21             6          3.50
#> 55           22           6            22             6          3.67
#> 56           21           6            21             6          3.50
#> 57           22           6            22             6          3.67
#> 58           19           6            19             6          3.17
#> 59           22           6            22             6          3.67
#> 60           21           6            21             6          3.50
#> 61           21           6            21             6          3.50
#> 62           21           6            21             6          3.50
#> 63           21           6            21             6          3.50
#> 64           20           6            20             6          3.33
#> 65           20           6            20             6          3.33
#> 66           20           6            20             6          3.33
#> 67           22           6            22             6          3.67
#> 68           22           6            22             6          3.67
#> 69           22           6            22             6          3.67
#> 70           20           6            20             6          3.33
#> 71           22           6            22             6          3.67
#> 72           22           6            22             6          3.67
#> 73           20           6            20             6          3.33
#> 74           16           6            16             6          2.67
#> 75           21           6            21             6          3.50
#> 76           21           6            21             6          3.50
#> 77           19           6            19             6          3.17
#> 78           21           6            21             6          3.50
#> 79           20           6            20             6          3.33
#> 80           19           6            19             6          3.17
#> 81           19           6            19             6          3.17
#> 82           21           6            21             6          3.50
#> 83           21           6            21             6          3.50
#> 84           21           6            21             6          3.50
#> 85           19           6            19             6          3.17
#> 86           20           6            20             6          3.33
#> 87           20           6            20             6          3.33
#> 88           21           6            21             6          3.50
#> 89           14           6            14             6          2.33
#> 90           20           6            20             6          3.33
#> 91           22           6            22             6          3.67
#> 92           22           6            22             6          3.67
#> 93           19           6            19             6          3.17
#> 94           20           6            20             6          3.33
#> 95           19           6            19             6          3.17
#> 96           17           6            17             6          2.83
#> 97           18           6            18             6          3.00
#> 98           20           6            20             6          3.33
#> 99           19           6            19             6          3.17
#> 100          19           6            19             6          3.17
#> 101          18           6            18             6          3.00
#> 102          20           6            20             6          3.33
#> 103          20           6            20             6          3.33
#> 104          20           6            20             6          3.33
#> 105          21           6            21             6          3.50
#> 106          21           6            21             6          3.50
#> 107          20           6            20             6          3.33
#> 108          16           6            16             6          2.67
#> 109          21           6            21             6          3.50
#> 110          19           6            19             6          3.17
#> 111          20           6            20             6          3.33
#> 112          18           6            18             6          3.00
#> 113          14           6            14             6          2.33
#> 114          19           6            19             6          3.17
#> 115          19           6            19             6          3.17
#> 116          19           6            19             6          3.17
#> 117          18           6            18             6          3.00
#> 118          18           6            18             6          3.00
#> 119          19           6            19             6          3.17
#> 120          15           6            15             6          2.50
#> 121          17           6            17             6          2.83
#> 122          16           6            16             6          2.67
#> 123          19           6            19             6          3.17
#> 124          21           6            21             6          3.50
#> 125          21           6            21             6          3.50
#> 126          16           6            16             6          2.67
#> 127          19           6            19             6          3.17
#> 128          17           6            17             6          2.83
#> 129          19           6            19             6          3.17
#> 130          19           6            19             6          3.17
#> 131          21           6            21             6          3.50
#> 132          18           6            18             6          3.00
#> 133          20           6            20             6          3.33
#> 134          19           6            19             6          3.17
#> 135          19           6            19             6          3.17
#> 136          19           6            19             6          3.17
#> 137          20           6            20             6          3.33
#> 138          20           6            20             6          3.33
#> 139          19           6            19             6          3.17
#> 140          13           6            13             6          2.17
#> 141          20           6            20             6          3.33
#> 142          20           6            20             6          3.33
#> 143          20           6            20             6          3.33
#> 144          20           6            20             6          3.33
#> 145          18           6            18             6          3.00
#> 146          19           6            19             6          3.17
#> 147          17           6            17             6          2.83
#> 148          18           6            18             6          3.00
#> 149          19           6            19             6          3.17
#> 150          18           6            18             6          3.00
#> 151          17           6            17             6          2.83
#> 152          15           6            15             6          2.50
#> 153          16           6            16             6          2.67
#> 154          17           6            17             6          2.83
#> 155          15           6            15             6          2.50
#> 156          19           6            19             6          3.17
#> 157          19           6            19             6          3.17
#> 158          16           6            16             6          2.67
#> 159          19           6            19             6          3.17
#> 160          13           6            13             6          2.17
#> 161          13           6            13             6          2.17
#> 162          16           6            16             6          2.67
#> 163          18           6            18             6          3.00
#> 164          18           6            18             6          3.00
#> 165          19           6            19             6          3.17
#> 166          14           6            14             6          2.33
#> 167          18           6            18             6          3.00
#> 168          20           6            20             6          3.33
#> 169          18           6            18             6          3.00
#> 170          20           6            20             6          3.33
#> 171          20           6            20             6          3.33
#> 172          16           6            16             6          2.67
#> 173          18           6            18             6          3.00
#> 174          19           6            19             6          3.17
#> 175          19           6            19             6          3.17
#> 176          19           6            19             6          3.17
#> 177          14           6            14             6          2.33
#> 178          14           6            14             6          2.33
#> 179          19           6            19             6          3.17
#> 180          18           6            18             6          3.00
#> 181          16           6            16             6          2.67
#> 182          15           6            15             6          2.50
#> 183          14           6            14             6          2.33
#> 184          18           6            18             6          3.00
#> 185          19           6            19             6          3.17
#> 186          14           6            14             6          2.33
#> 187          14           6            14             6          2.33
#> 188          15           6            15             6          2.50
#> 189          15           6            15             6          2.50
#> 190          12           6            12             6          2.00
#> 191          13           6            13             6          2.17
#> 192          16           6            16             6          2.67
#> 193          16           6            16             6          2.67
#> 194          18           6            18             6          3.00
#> 195          18           6            18             6          3.00
#> 196          16           6            16             6          2.67
#> 197          17           6            17             6          2.83
#> 198          18           6            18             6          3.00
#> 199          18           6            18             6          3.00
#> 200          15           6            15             6          2.50
#> 201          18           6            18             6          3.00
#> 202          16           6            16             6          2.67
#> 203          17           6            17             6          2.83
#> 204          16           6            16             6          2.67
#> 205          14           6            14             6          2.33
#> 206          13           6            13             6          2.17
#> 207          16           6            16             6          2.67
#> 208          15           6            15             6          2.50
#> 209          15           6            15             6          2.50
#> 210          16           6            16             6          2.67
#> 211          16           6            16             6          2.67
#> 212          16           6            16             6          2.67
#> 213          15           6            15             6          2.50
#> 214          17           6            17             6          2.83
#> 215          15           6            15             6          2.50
#> 216          13           6            13             6          2.17
#> 217          14           6            14             6          2.33
#> 218          17           6            17             6          2.83
#> 219          13           6            13             6          2.17
#> 220          18           6            18             6          3.00
#> 221          15           6            15             6          2.50
#> 222          18           6            18             6          3.00
#> 223          17           6            17             6          2.83
#> 224          12           6            12             6          2.00
#> 225          17           6            17             6          2.83
#> 226          12           6            12             6          2.00
#> 227          14           6            14             6          2.33
#> 228          13           6            13             6          2.17
#> 229          12           6            12             6          2.00
#> 230          14           6            14             6          2.33
#> 231          15           6            15             6          2.50
#> 232          15           6            15             6          2.50
#> 233          15           6            15             6          2.50
#> 234          15           6            15             6          2.50
#> 235          14           6            14             6          2.33
#> 236          16           6            16             6          2.67
#> 237          15           6            15             6          2.50
#> 238          13           6            13             6          2.17
#> 239          15           6            15             6          2.50
#> 240          16           6            16             6          2.67
#> 241          14           6            14             6          2.33
#> 242          14           6            14             6          2.33
#> 243          13           6            13             6          2.17
#> 244          12           6            12             6          2.00
#> 245          14           6            14             6          2.33
#> 246          17           6            17             6          2.83
#> 247          13           6            13             6          2.17
#> 248          11           6            11             6          1.83
#> 249          11           6            11             6          1.83
#> 250          15           6            15             6          2.50
#> 251          14           6            14             6          2.33
#> 252          13           6            13             6          2.17
#> 253          13           6            13             6          2.17
#> 254          13           6            13             6          2.17
#> 255          14           6            14             6          2.33
#> 256          13           6            13             6          2.17
#> 257          12           6            12             6          2.00
#> 258          12           6            12             6          2.00
#> 259          12           6            12             6          2.00
#> 260          11           6            11             6          1.83
#> 261          13           6            13             6          2.17
#> 262          14           6            14             6          2.33
#> 263          13           6            13             6          2.17
#> 264          13           6            13             6          2.17
#> 265          13           6            13             6          2.17
#> 266          14           6            14             6          2.33
#> 267          14           6            14             6          2.33
#> 268          15           6            15             6          2.50
#> 269          15           6            15             6          2.50
#> 270          14           6            14             6          2.33
#> 271          13           6            13             6          2.17
#> 272          10           6            10             6          1.67
#> 273          15           6            15             6          2.50
#> 274          12           6            12             6          2.00
#> 275          11           6            11             6          1.83
#> 276          13           6            13             6          2.17
#> 277          13           6            13             6          2.17
#> 278          12           6            12             6          2.00
#> 279          12           6            12             6          2.00
#> 280          13           6            13             6          2.17
#> 281          15           6            15             6          2.50
#> 282          13           6            13             6          2.17
#> 283          15           6            15             6          2.50
#> 284          11           6            11             6          1.83
#> 285          13           6            13             6          2.17
#> 286          12           6            12             6          2.00
#> 287          11           6            11             6          1.83
#> 288          11           6            11             6          1.83
#> 289          10           6            10             6          1.67
#> 290          12           6            12             6          2.00
#> 291           9           6             9             6          1.50
#> 292          10           6            10             6          1.67
#> 293          13           6            13             6          2.17
#> 294          10           6            10             6          1.67
#> 295          11           6            11             6          1.83
#> 296           9           6             9             6          1.50
#> 297           9           6             9             6          1.50
#> 298           9           6             9             6          1.50
#> 299          12           6            12             6          2.00
#> 300          12           6            12             6          2.00
#> 301          11           6            11             6          1.83
#> 302           9           6             9             6          1.50
#> 303          11           6            11             6          1.83
#> 304           9           6             9             6          1.50
#> 305           8           6             8             6          1.33
#> 306           8           6             8             6          1.33
#> 307           7           6             7             6          1.17
#>     Fair(M) Average Fair(Z) Average Measure Model S.E. Real S.E. Infit MnSq
#> 1              4.00            4.00   12.63     100.88    100.88         NA
#> 2              4.00            4.00   12.25      61.98     61.98         NA
#> 3              4.00            4.00   11.56      66.36     66.36         NA
#> 4              4.00            4.00   11.55      64.75     64.75         NA
#> 5              4.00            4.00   10.69      54.68     54.68         NA
#> 6              4.00            4.00   10.60      53.25     53.25         NA
#> 7              3.97            3.97    4.82       1.08      1.08       0.65
#> 8              3.94            3.94    4.13       1.05      1.05       0.70
#> 9              3.89            3.89    3.51       1.04      1.04       0.77
#> 10             3.88            3.88    3.41       1.04      1.14       1.18
#> 11             3.88            3.88    3.41       1.06      1.18       1.23
#> 12             3.87            3.87    3.34       1.04      1.04       0.80
#> 13             3.87            3.87    3.31       1.05      1.14       1.19
#> 14             3.86            3.86    3.26       1.05      1.05       0.72
#> 15             3.86            3.86    3.26       1.05      1.07       1.03
#> 16             3.84            3.84    3.14       1.05      1.05       0.63
#> 17             3.84            3.84    3.10       1.06      1.06       0.67
#> 18             3.80            3.80    2.91       1.04      1.04       0.87
#> 19             3.80            3.80    2.87       0.77      0.77       0.59
#> 20             3.79            3.79    2.83       1.04      1.04       0.83
#> 21             3.78            3.78    2.79       0.77      0.77       0.62
#> 22             3.77            3.77    2.76       0.68      0.68       0.83
#> 23             3.77            3.77    2.73       1.04      1.04       0.97
#> 24             3.76            3.76    2.68       0.62      0.66       1.14
#> 25             3.76            3.76    2.68       0.61      0.70       1.30
#> 26             3.76            3.76    2.67       1.05      1.05       0.72
#> 27             3.76            3.76    2.67       1.05      1.05       0.68
#> 28             3.74            3.74    2.60       0.69      0.69       1.01
#> 29             3.74            3.74    2.59       0.78      0.78       0.72
#> 30             3.73            3.73    2.57       1.05      1.05       0.74
#> 31             3.73            3.73    2.56       0.70      0.77       1.22
#> 32             3.72            3.72    2.52       0.78      0.83       1.14
#> 33             3.71            3.71    2.48       0.61      0.61       0.84
#> 34             3.71            3.71    2.47       0.79      0.79       0.85
#> 35             3.71            3.71    2.46       0.78      0.78       0.35
#> 36             3.71            3.71    2.46       0.78      0.99       1.60
#> 37             3.70            3.70    2.43       0.78      0.78       0.36
#> 38             3.69            3.69    2.40       0.58      0.60       1.05
#> 39             3.68            3.68    2.35       1.04      1.04       0.81
#> 40             3.67            3.67    2.33       0.68      0.68       0.62
#> 41             3.67            3.67    2.32       0.68      0.68       0.92
#> 42             3.67            3.67    2.32       0.59      0.59       0.96
#> 43             3.67            3.67    2.32       0.59      0.89       2.25
#> 44             3.66            3.66    2.28       0.79      0.95       1.43
#> 45             3.66            3.66    2.28       0.79      0.79       0.81
#> 46             3.65            3.65    2.25       0.79      0.98       1.53
#> 47             3.65            3.65    2.25       1.04      1.04       0.80
#> 48             3.63            3.63    2.19       0.66      0.73       1.21
#> 49             3.63            3.63    2.18       0.79      0.79       1.00
#> 50             3.63            3.63    2.18       0.68      0.75       1.23
#> 51             3.61            3.61    2.12       0.64      0.64       0.51
#> 52             3.61            3.61    2.12       0.66      0.81       1.48
#> 53             3.60            3.60    2.10       0.66      0.66       0.46
#> 54             3.59            3.59    2.06       0.67      0.81       1.44
#> 55             3.58            3.58    2.05       0.78      0.78       0.30
#> 56             3.58            3.58    2.05       0.66      0.66       0.79
#> 57             3.58            3.58    2.04       0.78      0.78       0.70
#> 58             3.58            3.58    2.04       0.58      0.58       0.63
#> 59             3.57            3.57    2.03       0.78      0.78       0.82
#> 60             3.56            3.56    1.99       0.70      0.70       0.57
#> 61             3.55            3.55    1.96       0.67      0.82       1.50
#> 62             3.54            3.54    1.94       0.67      0.67       0.93
#> 63             3.54            3.54    1.94       0.67      0.67       0.49
#> 64             3.53            3.53    1.92       0.61      0.61       0.79
#> 65             3.53            3.53    1.92       0.61      0.63       1.08
#> 66             3.52            3.52    1.89       0.60      0.60       0.84
#> 67             3.52            3.52    1.88       0.78      0.78       0.90
#> 68             3.52            3.52    1.87       0.78      1.14       2.16
#> 69             3.52            3.52    1.87       0.78      0.78       0.94
#> 70             3.51            3.51    1.87       0.60      0.60       0.82
#> 71             3.49            3.49    1.80       0.78      0.82       1.13
#> 72             3.49            3.49    1.80       0.78      0.78       0.91
#> 73             3.47            3.47    1.75       0.62      0.62       0.55
#> 74             3.46            3.46    1.75       0.56      0.56       0.84
#> 75             3.46            3.46    1.75       0.68      0.68       0.65
#> 76             3.45            3.45    1.71       0.68      0.68       0.67
#> 77             3.43            3.43    1.66       0.57      0.57       0.29
#> 78             3.43            3.43    1.65       0.68      0.79       1.35
#> 79             3.38            3.38    1.56       0.64      0.72       1.28
#> 80             3.38            3.38    1.55       0.63      0.63       0.97
#> 81             3.38            3.38    1.55       0.63      0.65       1.09
#> 82             3.37            3.37    1.54       0.66      0.66       0.35
#> 83             3.37            3.37    1.54       0.66      0.66       0.40
#> 84             3.37            3.37    1.53       0.67      1.10       2.66
#> 85             3.36            3.36    1.52       0.57      0.69       1.46
#> 86             3.36            3.36    1.52       0.61      0.61       0.63
#> 87             3.36            3.36    1.52       0.61      0.61       0.62
#> 88             3.36            3.36    1.52       0.67      0.67       0.58
#> 89             3.36            3.36    1.51       0.55      0.55       0.71
#> 90             3.36            3.36    1.51       0.61      0.61       0.66
#> 91             3.35            3.35    1.49       0.77      0.77       0.62
#> 92             3.34            3.34    1.47       0.77      1.06       1.87
#> 93             3.34            3.34    1.47       0.57      0.57       0.61
#> 94             3.33            3.33    1.45       0.63      0.89       1.98
#> 95             3.30            3.30    1.39       0.59      0.96       2.71
#> 96             3.30            3.30    1.39       0.55      0.67       1.49
#> 97             3.30            3.30    1.39       0.58      0.58       0.97
#> 98             3.28            3.28    1.36       0.61      0.61       0.67
#> 99             3.28            3.28    1.35       0.57      0.88       2.38
#> 100            3.28            3.28    1.35       0.57      0.57       0.91
#> 101            3.28            3.28    1.34       0.55      0.55       0.30
#> 102            3.27            3.27    1.33       0.63      0.66       1.12
#> 103            3.26            3.26    1.31       0.63      0.63       0.53
#> 104            3.26            3.26    1.31       0.63      0.63       0.66
#> 105            3.25            3.25    1.30       0.67      0.67       0.55
#> 106            3.25            3.25    1.30       0.67      0.71       1.13
#> 107            3.25            3.25    1.30       0.62      0.62       0.54
#> 108            3.25            3.25    1.30       0.60      0.66       1.20
#> 109            3.25            3.25    1.29       0.67      0.80       1.44
#> 110            3.22            3.22    1.23       0.57      0.75       1.69
#> 111            3.21            3.21    1.23       0.62      0.80       1.67
#> 112            3.20            3.20    1.21       0.55      0.73       1.77
#> 113            3.20            3.20    1.21       0.56      0.60       1.13
#> 114            3.20            3.20    1.20       0.58      0.74       1.66
#> 115            3.19            3.19    1.19       0.58      0.58       0.91
#> 116            3.19            3.19    1.18       0.60      0.65       1.18
#> 117            3.18            3.18    1.17       0.60      0.60       1.00
#> 118            3.18            3.18    1.17       0.60      0.60       0.98
#> 119            3.18            3.18    1.16       0.58      0.65       1.27
#> 120            3.17            3.17    1.15       0.58      0.58       0.92
#> 121            3.16            3.16    1.13       0.56      0.56       0.04
#> 122            3.16            3.16    1.12       0.62      0.62       0.68
#> 123            3.15            3.15    1.11       0.58      0.82       2.03
#> 124            3.13            3.13    1.07       0.66      0.66       0.33
#> 125            3.13            3.13    1.07       0.66      0.72       1.17
#> 126            3.11            3.11    1.05       0.64      0.88       1.91
#> 127            3.10            3.10    1.02       0.59      0.60       1.06
#> 128            3.09            3.09    1.01       0.54      0.56       1.08
#> 129            3.09            3.09    1.01       0.57      0.83       2.12
#> 130            3.08            3.08    0.99       0.58      0.58       0.24
#> 131            3.08            3.08    0.98       0.66      0.74       1.26
#> 132            3.08            3.08    0.98       0.55      0.55       0.34
#> 133            3.06            3.06    0.96       0.61      0.61       0.57
#> 134            3.06            3.06    0.96       0.59      0.76       1.65
#> 135            3.06            3.06    0.96       0.59      0.79       1.78
#> 136            3.06            3.06    0.95       0.59      0.59       0.36
#> 137            3.06            3.06    0.95       0.61      0.61       0.49
#> 138            3.05            3.05    0.94       0.61      0.66       1.15
#> 139            3.04            3.04    0.91       0.59      0.59       0.55
#> 140            3.02            3.02    0.89       0.57      0.68       1.40
#> 141            3.02            3.02    0.88       0.61      0.75       1.54
#> 142            3.01            3.01    0.88       0.61      0.61       0.82
#> 143            3.01            3.01    0.87       0.61      0.61       0.51
#> 144            3.01            3.01    0.87       0.61      0.77       1.60
#> 145            3.01            3.01    0.87       0.56      0.81       2.14
#> 146            3.01            3.01    0.86       0.57      0.80       1.95
#> 147            3.00            3.00    0.86       0.54      0.54       0.22
#> 148            3.00            3.00    0.86       0.55      0.55       0.73
#> 149            3.00            3.00    0.85       0.59      0.59       0.70
#> 150            2.99            2.99    0.84       0.56      0.56       0.81
#> 151            2.99            2.99    0.84       0.54      0.54       0.42
#> 152            2.98            2.98    0.82       0.54      0.76       1.98
#> 153            2.97            2.97    0.80       0.54      0.64       1.40
#> 154            2.95            2.95    0.77       0.54      0.54       0.51
#> 155            2.94            2.94    0.75       0.54      0.75       1.88
#> 156            2.93            2.93    0.75       0.58      0.85       2.13
#> 157            2.93            2.93    0.75       0.58      0.58       0.47
#> 158            2.93            2.93    0.74       0.56      0.56       0.33
#> 159            2.93            2.93    0.73       0.58      0.60       1.07
#> 160            2.89            2.89    0.68       0.58      0.60       1.05
#> 161            2.89            2.89    0.68       0.58      0.78       1.81
#> 162            2.88            2.88    0.65       0.54      0.64       1.43
#> 163            2.86            2.86    0.62       0.57      0.57       0.35
#> 164            2.85            2.85    0.62       0.57      0.57       0.37
#> 165            2.85            2.85    0.61       0.58      0.68       1.40
#> 166            2.84            2.84    0.60       0.60      0.60       0.48
#> 167            2.84            2.84    0.59       0.57      0.58       1.03
#> 168            2.83            2.83    0.57       0.60      0.60       0.82
#> 169            2.82            2.82    0.56       0.55      0.55       0.43
#> 170            2.82            2.82    0.56       0.60      0.60       0.77
#> 171            2.82            2.82    0.56       0.60      0.68       1.26
#> 172            2.81            2.81    0.55       0.54      0.54       0.86
#> 173            2.81            2.81    0.55       0.55      0.59       1.13
#> 174            2.81            2.81    0.55       0.57      0.62       1.15
#> 175            2.80            2.80    0.53       0.57      0.57       0.73
#> 176            2.80            2.80    0.53       0.57      0.62       1.15
#> 177            2.80            2.80    0.53       0.55      0.55       0.75
#> 178            2.80            2.80    0.53       0.55      0.73       1.78
#> 179            2.78            2.78    0.50       0.57      0.75       1.70
#> 180            2.77            2.77    0.48       0.55      0.55       0.29
#> 181            2.76            2.76    0.46       0.58      1.01       3.03
#> 182            2.76            2.76    0.46       0.54      0.54       0.74
#> 183            2.75            2.75    0.45       0.55      0.60       1.21
#> 184            2.74            2.74    0.43       0.56      0.68       1.47
#> 185            2.74            2.74    0.43       0.57      0.57       0.70
#> 186            2.68            2.68    0.35       0.54      0.54       0.57
#> 187            2.68            2.68    0.35       0.54      0.54       0.01
#> 188            2.68            2.68    0.34       0.54      0.63       1.37
#> 189            2.68            2.68    0.34       0.54      0.54       0.85
#> 190            2.67            2.67    0.33       0.60      0.62       1.07
#> 191            2.66            2.66    0.31       0.60      0.60       0.80
#> 192            2.64            2.64    0.28       0.54      0.54       0.55
#> 193            2.64            2.64    0.28       0.54      0.54       0.87
#> 194            2.64            2.64    0.28       0.56      0.69       1.55
#> 195            2.64            2.64    0.28       0.56      0.56       0.96
#> 196            2.63            2.63    0.27       0.54      0.54       0.79
#> 197            2.61            2.61    0.23       0.55      0.66       1.42
#> 198            2.60            2.60    0.22       0.55      0.74       1.80
#> 199            2.59            2.59    0.20       0.55      0.55       0.24
#> 200            2.56            2.56    0.15       0.58      0.58       0.30
#> 201            2.54            2.54    0.13       0.55      0.55       0.88
#> 202            2.53            2.53    0.11       0.54      0.54       0.38
#> 203            2.53            2.53    0.10       0.55      0.55       0.90
#> 204            2.52            2.52    0.10       0.54      0.54       0.28
#> 205            2.49            2.49    0.05       0.54      0.71       1.74
#> 206            2.48            2.48    0.03       0.56      0.59       1.11
#> 207            2.46            2.46    0.00       0.55      0.55       0.84
#> 208            2.46            2.46   -0.01       0.54      0.54       0.54
#> 209            2.46            2.46   -0.01       0.54      0.61       1.27
#> 210            2.45            2.45   -0.02       0.55      0.77       1.95
#> 211            2.45            2.45   -0.02       0.54      0.54       0.90
#> 212            2.45            2.45   -0.03       0.55      0.55       0.65
#> 213            2.45            2.45   -0.03       0.54      0.68       1.60
#> 214            2.44            2.44   -0.04       0.54      0.58       1.11
#> 215            2.44            2.44   -0.04       0.54      0.54       0.84
#> 216            2.43            2.43   -0.05       0.55      0.65       1.40
#> 217            2.42            2.42   -0.07       0.55      0.61       1.25
#> 218            2.42            2.42   -0.07       0.54      0.69       1.63
#> 219            2.42            2.42   -0.07       0.55      0.56       1.02
#> 220            2.41            2.41   -0.09       0.55      0.55       0.39
#> 221            2.40            2.40   -0.10       0.54      0.58       1.15
#> 222            2.40            2.40   -0.10       0.55      0.55       0.38
#> 223            2.40            2.40   -0.10       0.54      0.54       0.48
#> 224            2.40            2.40   -0.10       0.58      0.63       1.19
#> 225            2.39            2.39   -0.11       0.54      0.54       0.45
#> 226            2.35            2.35   -0.18       0.58      0.58       0.83
#> 227            2.35            2.35   -0.19       0.58      0.58       0.46
#> 228            2.31            2.31   -0.25       0.55      0.55       0.92
#> 229            2.30            2.30   -0.26       0.57      0.72       1.59
#> 230            2.28            2.28   -0.30       0.54      0.71       1.68
#> 231            2.28            2.28   -0.30       0.55      0.82       2.26
#> 232            2.28            2.28   -0.30       0.55      0.55       0.96
#> 233            2.28            2.28   -0.30       0.55      0.55       0.24
#> 234            2.28            2.28   -0.30       0.55      0.55       0.34
#> 235            2.27            2.27   -0.31       0.54      0.56       1.08
#> 236            2.27            2.27   -0.31       0.54      0.55       1.05
#> 237            2.27            2.27   -0.32       0.55      0.65       1.40
#> 238            2.26            2.26   -0.32       0.55      0.68       1.51
#> 239            2.26            2.26   -0.33       0.54      0.54       0.82
#> 240            2.26            2.26   -0.33       0.54      0.78       2.07
#> 241            2.26            2.26   -0.34       0.54      0.59       1.16
#> 242            2.25            2.25   -0.35       0.56      0.72       1.67
#> 243            2.24            2.24   -0.37       0.56      0.70       1.58
#> 244            2.23            2.23   -0.39       0.57      0.57       0.40
#> 245            2.22            2.22   -0.39       0.55      0.55       0.45
#> 246            2.22            2.22   -0.39       0.54      0.54       0.35
#> 247            2.20            2.20   -0.43       0.56      0.58       1.06
#> 248            2.18            2.18   -0.47       0.60      0.60       0.71
#> 249            2.18            2.18   -0.47       0.60      0.66       1.18
#> 250            2.18            2.18   -0.47       0.54      0.54       0.19
#> 251            2.17            2.17   -0.49       0.54      0.54       0.48
#> 252            2.15            2.15   -0.51       0.56      0.65       1.35
#> 253            2.15            2.15   -0.52       0.59      0.87       2.16
#> 254            2.15            2.15   -0.52       0.59      0.59       0.66
#> 255            2.15            2.15   -0.52       0.55      0.55       0.35
#> 256            2.14            2.14   -0.53       0.59      0.59       0.46
#> 257            2.14            2.14   -0.54       0.57      0.64       1.26
#> 258            2.12            2.12   -0.56       0.57      0.57       0.41
#> 259            2.12            2.12   -0.56       0.57      0.57       0.53
#> 260            2.12            2.12   -0.57       0.65      0.67       1.04
#> 261            2.10            2.10   -0.61       0.55      0.55       0.65
#> 262            2.09            2.09   -0.61       0.54      0.61       1.25
#> 263            2.09            2.09   -0.62       0.56      0.56       0.56
#> 264            2.09            2.09   -0.62       0.56      0.56       0.56
#> 265            2.09            2.09   -0.62       0.56      0.56       0.96
#> 266            2.09            2.09   -0.62       0.55      0.61       1.20
#> 267            2.09            2.09   -0.63       0.55      0.55       0.58
#> 268            2.07            2.07   -0.67       0.54      0.54       0.77
#> 269            2.06            2.06   -0.68       0.54      0.54       0.54
#> 270            2.05            2.05   -0.69       0.55      0.68       1.54
#> 271            2.04            2.04   -0.71       0.55      0.55       1.00
#> 272            1.97            1.97   -0.83       0.64      0.80       1.55
#> 273            1.95            1.95   -0.87       0.54      0.54       0.30
#> 274            1.95            1.95   -0.87       0.61      0.90       2.19
#> 275            1.93            1.93   -0.91       0.62      0.62       0.55
#> 276            1.93            1.93   -0.92       0.56      0.56       0.33
#> 277            1.93            1.93   -0.92       0.56      0.84       2.20
#> 278            1.92            1.92   -0.94       0.57      0.57       0.64
#> 279            1.92            1.92   -0.94       0.57      0.67       1.34
#> 280            1.92            1.92   -0.94       0.56      0.56       1.00
#> 281            1.92            1.92   -0.94       0.54      0.54       0.82
#> 282            1.91            1.91   -0.96       0.56      0.56       0.34
#> 283            1.90            1.90   -0.97       0.54      0.54       0.21
#> 284            1.87            1.87   -1.04       0.60      0.73       1.46
#> 285            1.79            1.79   -1.20       0.56      0.56       0.80
#> 286            1.76            1.76   -1.25       0.58      0.58       0.83
#> 287            1.76            1.76   -1.26       0.63      0.69       1.18
#> 288            1.75            1.75   -1.28       0.60      0.96       2.57
#> 289            1.75            1.75   -1.28       0.64      0.64       0.43
#> 290            1.75            1.75   -1.29       0.58      0.58       0.17
#> 291            1.74            1.74   -1.29       0.71      0.71       0.80
#> 292            1.72            1.72   -1.33       0.64      0.64       0.70
#> 293            1.72            1.72   -1.34       0.55      0.55       0.25
#> 294            1.66            1.66   -1.47       0.71      0.71       0.06
#> 295            1.65            1.65   -1.50       0.61      0.61       0.80
#> 296            1.64            1.64   -1.51       0.72      0.72       0.39
#> 297            1.64            1.64   -1.51       0.72      0.72       0.39
#> 298            1.63            1.63   -1.54       0.75      1.24       2.74
#> 299            1.62            1.62   -1.57       0.57      0.59       1.07
#> 300            1.61            1.61   -1.59       0.57      0.58       1.01
#> 301            1.61            1.61   -1.60       0.61      0.61       0.13
#> 302            1.54            1.54   -1.78       0.72      0.72       0.80
#> 303            1.48            1.48   -1.92       0.60      0.60       0.85
#> 304            1.40            1.40   -2.19       0.70      1.13       2.60
#> 305            1.36            1.36   -2.30       0.82      0.82       0.88
#> 306            1.34            1.34   -2.38       0.84      0.84       0.48
#> 307            1.30            1.30   -2.52       1.12      1.12       0.34
#>     Infit ZStd Outfit MnSq Outfit ZStd PtMea Corr Anch  Status Element
#> 1           NA          NA          NA         NA      Maximum    P018
#> 2           NA          NA          NA         NA      Maximum    P239
#> 3           NA          NA          NA         NA      Maximum    P209
#> 4           NA          NA          NA         NA      Maximum    P188
#> 5           NA          NA          NA         NA      Maximum    P007
#> 6           NA          NA          NA         NA      Maximum    P057
#> 7           NA        0.28       -1.60         NA                 P157
#> 8           NA        0.43       -1.08         NA                 P135
#> 9           NA        0.56       -0.73         NA                 P237
#> 10          NA        2.61        2.15         NA                 P295
#> 11          NA        1.71        1.21         NA                 P259
#> 12          NA        0.60       -0.63         NA                 P116
#> 13          NA        2.35        1.91         NA                 P010
#> 14          NA        0.46       -0.99         NA                 P204
#> 15          NA        1.06        0.30         NA                 P144
#> 16          NA        0.36       -1.30         NA                 P208
#> 17          NA        0.38       -1.24         NA                 P049
#> 18          NA        0.70       -0.38         NA                 P161
#> 19       -0.08        0.48       -0.93         NA                 P290
#> 20          NA        0.65       -0.51         NA                 P176
#> 21       -0.04        0.50       -0.88         NA                 P278
#> 22        0.13        0.84       -0.10         NA                 P047
#> 23          NA        0.91        0.04         NA                 P108
#> 24        0.44        0.93        0.08         NA                 P206
#> 25        0.61        1.37        0.77         NA                 P299
#> 26          NA        0.47       -0.96         NA                 P127
#> 27          NA        0.43       -1.09         NA                 P156
#> 28        0.33        0.95        0.11         NA                 P280
#> 29        0.09        0.63       -0.56         NA                 P287
#> 30          NA        0.50       -0.88         NA                 P149
#> 31        0.54        0.91        0.03         NA                 P257
#> 32        0.48        1.44        0.86         NA                 P008
#> 33        0.09        0.81       -0.16         NA                 P097
#> 34        0.23        0.94        0.09         NA                 P128
#> 35       -0.44        0.29       -1.56         NA                 P175
#> 36        0.83        1.08        0.33         NA                 P248
#> 37       -0.42        0.30       -1.53         NA                 P118
#> 38        0.34        0.98        0.16         NA                 P096
#> 39          NA        0.60       -0.61         NA                 P084
#> 40       -0.14        0.79       -0.20         NA                 P289
#> 41        0.23        0.64       -0.53         NA                 P013
#> 42        0.24        0.85       -0.08         NA                 P189
#> 43        1.39        1.89        1.43         NA                 P117
#> 44        0.71        0.85       -0.08         NA                 P019
#> 45        0.19        0.81       -0.15         NA                 P225
#> 46        0.78        0.93        0.07         NA                 P162
#> 47          NA        0.59       -0.64         NA                 P198
#> 48        0.52        0.97        0.14         NA                 P275
#> 49        0.37        2.93        2.43         NA                 P002
#> 50        0.55        0.92        0.04         NA                 P154
#> 51       -0.36        0.49       -0.91         NA                 P155
#> 52        0.76        1.23        0.56         NA                 P078
#> 53       -0.41        0.40       -1.18         NA                 P191
#> 54        0.73        2.06        1.61         NA                 P036
#> 55       -0.53        0.25       -1.71         NA                 P105
#> 56        0.06        1.00        0.19         NA                 P273
#> 57        0.07        0.65       -0.49         NA                 P291
#> 58       -0.25        0.58       -0.66         NA                 P081
#> 59        0.20        1.04        0.26         NA                 P134
#> 60       -0.19        0.43       -1.09         NA                 P300
#> 61        0.77        1.40        0.81         NA                 P304
#> 62        0.24        1.58        1.05         NA                 P183
#> 63       -0.36        0.66       -0.49         NA                 P146
#> 64        0.03        0.72       -0.34         NA                 P265
#> 65        0.38        0.97        0.13         NA                 P126
#> 66        0.08        0.73       -0.32         NA                 P253
#> 67        0.27        1.20        0.52         NA                 P197
#> 68        1.16        1.97        1.51         NA                 P247
#> 69        0.31        2.23        1.79         NA                 P241
#> 70        0.06        0.73       -0.33         NA                 P120
#> 71        0.48        1.44        0.87         NA                 P171
#> 72        0.28        1.25        0.59         NA                 P031
#> 73       -0.33        0.49       -0.90         NA                 P140
#> 74        0.06        0.87       -0.04         NA                 P246
#> 75       -0.09        0.50       -0.87         NA                 P255
#> 76       -0.07        0.51       -0.85         NA                 P125
#> 77       -0.98        0.30       -1.52         NA                 P046
#> 78        0.65        1.12        0.39         NA                 P172
#> 79        0.59        1.50        0.95         NA                 P168
#> 80        0.26        0.84       -0.11         NA                 P260
#> 81        0.39        0.84       -0.10         NA                 P040
#> 82       -0.63        0.32       -1.46         NA                 P082
#> 83       -0.54        0.35       -1.34         NA                 P222
#> 84        1.53        1.83        1.36         NA                 P199
#> 85        0.76        1.37        0.76         NA                 P101
#> 86       -0.22        0.65       -0.50         NA                 P139
#> 87       -0.24        0.55       -0.76         NA                 P079
#> 88       -0.21        1.51        0.96         NA                 P073
#> 89       -0.16        0.72       -0.35         NA                 P166
#> 90       -0.16        0.64       -0.52         NA                 P233
#> 91       -0.04        0.50       -0.87         NA                 P023
#> 92        1.00        1.50        0.95         NA                 P014
#> 93       -0.29        0.75       -0.28         NA                 P067
#> 94        1.16        1.79        1.30         NA                 P235
#> 95        1.71        4.26        3.42         NA                 P098
#> 96        0.80        1.46        0.89         NA                 P095
#> 97        0.24        0.93        0.08         NA                 P028
#> 98       -0.15        0.60       -0.63         NA                 P153
#> 99        1.51        2.21        1.77         NA                 P211
#> 100       0.16        0.87       -0.04         NA                 P160
#> 101      -1.00        0.39       -1.21         NA                 P062
#> 102       0.43        0.88       -0.02         NA                 P006
#> 103      -0.36        0.49       -0.91         NA                 P178
#> 104      -0.14        1.43        0.85         NA                 P092
#> 105      -0.26        0.74       -0.30         NA                 P217
#> 106       0.45        0.87       -0.05         NA                 P185
#> 107      -0.33        0.49       -0.91         NA                 P269
#> 108       0.50        1.01        0.21         NA                 P003
#> 109       0.73        1.31        0.68         NA                 P270
#> 110       0.98        1.66        1.14         NA                 P234
#> 111       0.93        1.57        1.04         NA                 P131
#> 112       1.07        1.61        1.08         NA                 P216
#> 113       0.42        1.07        0.30         NA                 P110
#> 114       0.95        1.69        1.18         NA                 P093
#> 115       0.15        0.84       -0.10         NA                 P015
#> 116       0.48        1.18        0.49         NA                 P068
#> 117       0.29        0.86       -0.06         NA                 P294
#> 118       0.26        0.84       -0.11         NA                 P201
#> 119       0.58        1.34        0.72         NA                 P077
#> 120       0.18        0.85       -0.07         NA                 P218
#> 121      -2.28        0.06       -2.94         NA                 P203
#> 122      -0.12        0.65       -0.49         NA                 P251
#> 123       1.25        2.30        1.85         NA                 P038
#> 124      -0.68        0.30       -1.51         NA                 P114
#> 125       0.49        0.94        0.08         NA                 P274
#> 126       1.11        1.77        1.28         NA                 P012
#> 127       0.35        1.25        0.60         NA                 P094
#> 128       0.35        1.05        0.27         NA                 P099
#> 129       1.33        2.32        1.87         NA                 P052
#> 130      -1.08        0.25       -1.73         NA                 P076
#> 131       0.57        1.04        0.26         NA                 P254
#> 132      -0.90        0.37       -1.27         NA                 P025
#> 133      -0.31        0.51       -0.86         NA                 P137
#> 134       0.93        1.46        0.89         NA                 P169
#> 135       1.04        1.43        0.85         NA                 P276
#> 136      -0.75        0.35       -1.34         NA                 P001
#> 137      -0.45        0.90        0.00         NA                 P223
#> 138       0.45        1.01        0.21         NA                 P042
#> 139      -0.37        0.52       -0.83         NA                 P293
#> 140       0.71        1.70        1.20         NA                 P147
#> 141       0.82        1.31        0.67         NA                 P158
#> 142       0.07        0.77       -0.24         NA                 P033
#> 143      -0.41        0.85       -0.08         NA                 P264
#> 144       0.88        1.35        0.74         NA                 P186
#> 145       1.36        1.93        1.46         NA                 P306
#> 146       1.20        2.31        1.87         NA                 P143
#> 147      -1.30        0.24       -1.77         NA                 P086
#> 148      -0.12        0.76       -0.27         NA                 P053
#> 149      -0.12        1.04        0.25         NA                 P258
#> 150       0.01        0.76       -0.26         NA                 P064
#> 151      -0.73        0.44       -1.05         NA                 P103
#> 152       1.25        1.84        1.37         NA                 P138
#> 153       0.73        1.33        0.71         NA                 P229
#> 154      -0.54        0.53       -0.80         NA                 P066
#> 155       1.17        1.83        1.35         NA                 P224
#> 156       1.32        2.10        1.65         NA                 P282
#> 157      -0.54        0.46       -0.99         NA                 P277
#> 158      -0.90        0.33       -1.43         NA                 P190
#> 159       0.36        1.32        0.69         NA                 P071
#> 160       0.34        1.56        1.02         NA                 P165
#> 161       1.07        1.73        1.24         NA                 P238
#> 162       0.75        1.39        0.80         NA                 P214
#> 163      -0.84        0.35       -1.35         NA                 P215
#> 164      -0.78        0.36       -1.30         NA                 P016
#> 165       0.71        1.20        0.52         NA                 P122
#> 166      -0.48        0.55       -0.75         NA                 P074
#> 167       0.31        0.95        0.10         NA                 P236
#> 168       0.05        0.71       -0.36         NA                 P302
#> 169      -0.67        0.48       -0.94         NA                 P043
#> 170       0.00        0.68       -0.44         NA                 P232
#> 171       0.56        1.26        0.62         NA                 P109
#> 172       0.06        0.92        0.05         NA                 P263
#> 173       0.43        1.06        0.29         NA                 P130
#> 174       0.45        1.22        0.55         NA                 P050
#> 175      -0.09        0.68       -0.44         NA                 P284
#> 176       0.45        1.21        0.53         NA                 P174
#> 177      -0.09        0.72       -0.34         NA                 P121
#> 178       1.08        1.82        1.34         NA                 P243
#> 179       0.99        1.67        1.16         NA                 P221
#> 180      -1.04        0.32       -1.45         NA                 P200
#> 181       1.91        2.94        2.44         NA                 P141
#> 182      -0.12        0.74       -0.31         NA                 P213
#> 183       0.51        1.15        0.44         NA                 P037
#> 184       0.78        1.47        0.91         NA                 P111
#> 185      -0.14        0.82       -0.14         NA                 P163
#> 186      -0.42        0.56       -0.72         NA                 P207
#> 187      -2.94        0.01       -4.05         NA                 P020
#> 188       0.69        1.38        0.78         NA                 P029
#> 189       0.05        0.86       -0.06         NA                 P249
#> 190       0.36        0.93        0.06         NA                 P245
#> 191       0.04        0.90        0.02         NA                 P297
#> 192      -0.46        0.55       -0.74         NA                 P182
#> 193       0.07        0.87       -0.04         NA                 P220
#> 194       0.86        1.41        0.82         NA                 P034
#> 195       0.21        0.91        0.03         NA                 P279
#> 196      -0.04        0.80       -0.17         NA                 P060
#> 197       0.74        2.01        1.55         NA                 P083
#> 198       1.09        1.72        1.23         NA                 P285
#> 199      -1.18        0.27       -1.66         NA                 P272
#> 200      -0.95        0.35       -1.33         NA                 P170
#> 201       0.10        0.83       -0.13         NA                 P080
#> 202      -0.85        0.37       -1.27         NA                 P148
#> 203       0.13        0.86       -0.06         NA                 P292
#> 204      -1.12        0.29       -1.55         NA                 P261
#> 205       1.05        1.78        1.29         NA                 P271
#> 206       0.40        1.04        0.26         NA                 P009
#> 207       0.04        0.83       -0.11         NA                 P210
#> 208      -0.48        0.53       -0.80         NA                 P129
#> 209       0.58        1.28        0.65         NA                 P286
#> 210       1.22        1.84        1.37         NA                 P283
#> 211       0.11        0.95        0.10         NA                 P061
#> 212      -0.26        0.64       -0.52         NA                 P119
#> 213       0.92        1.59        1.06         NA                 P187
#> 214       0.40        1.08        0.32         NA                 P180
#> 215       0.03        0.89        0.00         NA                 P011
#> 216       0.71        1.43        0.85         NA                 P152
#> 217       0.55        1.19        0.51         NA                 P202
#> 218       0.94        1.63        1.11         NA                 P301
#> 219       0.29        0.99        0.17         NA                 P268
#> 220      -0.77        0.44       -1.06         NA                 P035
#> 221       0.44        1.17        0.48         NA                 P305
#> 222      -0.81        0.42       -1.11         NA                 P090
#> 223      -0.59        0.50       -0.87         NA                 P133
#> 224       0.50        1.14        0.42         NA                 P024
#> 225      -0.65        0.48       -0.95         NA                 P106
#> 226       0.05        0.83       -0.13         NA                 P087
#> 227      -0.56        0.50       -0.89         NA                 P195
#> 228       0.16        0.85       -0.08         NA                 P151
#> 229       0.89        1.37        0.77         NA                 P100
#> 230       0.99        1.63        1.11         NA                 P212
#> 231       1.47        2.16        1.71         NA                 P142
#> 232       0.21        0.92        0.05         NA                 P091
#> 233      -1.19        0.24       -1.76         NA                 P177
#> 234      -0.91        0.34       -1.38         NA                 P167
#> 235       0.36        1.08        0.34         NA                 P051
#> 236       0.32        1.05        0.28         NA                 P065
#> 237       0.72        1.27        0.62         NA                 P041
#> 238       0.83        1.52        0.97         NA                 P044
#> 239      -0.01        0.81       -0.16         NA                 P072
#> 240       1.33        1.95        1.49         NA                 P022
#> 241       0.46        1.16        0.46         NA                 P107
#> 242       0.97        1.65        1.14         NA                 P069
#> 243       0.89        1.64        1.12         NA                 P150
#> 244      -0.72        0.41       -1.13         NA                 P227
#> 245      -0.64        0.48       -0.92         NA                 P307
#> 246      -0.90        0.36       -1.31         NA                 P281
#> 247       0.33        1.03        0.24         NA                 P059
#> 248      -0.10        0.69       -0.42         NA                 P303
#> 249       0.49        1.21        0.53         NA                 P179
#> 250      -1.41        0.18       -2.05         NA                 P017
#> 251      -0.59        0.50       -0.89         NA                 P244
#> 252       0.67        1.25        0.60         NA                 P021
#> 253       1.33        2.01        1.55         NA                 P262
#> 254      -0.18        0.64       -0.53         NA                 P288
#> 255      -0.87        0.33       -1.41         NA                 P250
#> 256      -0.53        0.54       -0.77         NA                 P026
#> 257       0.56        1.19        0.50         NA                 P252
#> 258      -0.70        0.41       -1.15         NA                 P242
#> 259      -0.45        0.55       -0.74         NA                 P266
#> 260       0.35        0.79       -0.21         NA                 P226
#> 261      -0.25        0.67       -0.45         NA                 P054
#> 262       0.56        1.25        0.59         NA                 P070
#> 263      -0.42        0.58       -0.68         NA                 P115
#> 264      -0.41        0.55       -0.74         NA                 P164
#> 265       0.21        0.99        0.18         NA                 P063
#> 266       0.50        1.17        0.47         NA                 P228
#> 267      -0.37        0.60       -0.63         NA                 P267
#> 268      -0.07        0.76       -0.27         NA                 P192
#> 269      -0.48        0.54       -0.76         NA                 P030
#> 270       0.86        1.44        0.86         NA                 P184
#> 271       0.27        0.97        0.14         NA                 P230
#> 272       0.82        1.60        1.07         NA                 P256
#> 273      -1.07        0.29       -1.55         NA                 P058
#> 274       1.33        1.79        1.31         NA                 P055
#> 275      -0.33        0.70       -0.40         NA                 P005
#> 276      -0.90        0.36       -1.32         NA                 P039
#> 277       1.40        2.00        1.54         NA                 P104
#> 278      -0.24        0.68       -0.42         NA                 P032
#> 279       0.65        1.21        0.53         NA                 P296
#> 280       0.26        0.97        0.14         NA                 P145
#> 281       0.00        0.82       -0.14         NA                 P027
#> 282      -0.86        0.38       -1.25         NA                 P132
#> 283      -1.35        0.21       -1.93         NA                 P085
#> 284       0.76        1.91        1.44         NA                 P124
#> 285      -0.02        0.78       -0.21         NA                 P123
#> 286       0.06        0.83       -0.12         NA                 P088
#> 287       0.49        1.09        0.34         NA                 P231
#> 288       1.59        2.67        2.21         NA                 P219
#> 289      -0.52        0.53       -0.80         NA                 P075
#> 290      -1.34        0.25       -1.74         NA                 P102
#> 291       0.12        1.05        0.27         NA                 P181
#> 292      -0.07        0.69       -0.41         NA                 P298
#> 293      -1.16        0.27       -1.63         NA                 P194
#> 294      -1.47        0.09       -2.70         NA                 P056
#> 295       0.03        0.76       -0.25         NA                 P240
#> 296      -0.46        0.38       -1.23         NA                 P193
#> 297      -0.46        0.38       -1.23         NA                 P112
#> 298       1.48        1.92        1.46         NA                 P196
#> 299       0.35        1.25        0.59         NA                 P004
#> 300       0.28        1.05        0.28         NA                 P045
#> 301      -1.43        0.18       -2.09         NA                 P113
#> 302       0.13        1.41        0.82         NA                 P205
#> 303       0.09        0.79       -0.20         NA                 P089
#> 304       1.46        3.18        2.64         NA                 P048
#> 305       0.28        1.00        0.20         NA                 P173
#> 306      -0.16        0.46       -1.00         NA                 P136
#> 307         NA        0.17       -2.10         NA                 P159
#>     ObservedAverage AdjustedAverage StandardizedAdjustedAverage ModelBasedSE
#> 1              4.00            4.00                        4.00       100.88
#> 2              4.00            4.00                        4.00        61.98
#> 3              4.00            4.00                        4.00        66.36
#> 4              4.00            4.00                        4.00        64.75
#> 5              4.00            4.00                        4.00        54.68
#> 6              4.00            4.00                        4.00        53.25
#> 7              3.83            3.97                        3.97         1.08
#> 8              3.83            3.94                        3.94         1.05
#> 9              3.83            3.89                        3.89         1.04
#> 10             3.83            3.88                        3.88         1.04
#> 11             3.83            3.88                        3.88         1.06
#> 12             3.83            3.87                        3.87         1.04
#> 13             3.83            3.87                        3.87         1.05
#> 14             3.83            3.86                        3.86         1.05
#> 15             3.83            3.86                        3.86         1.05
#> 16             3.83            3.84                        3.84         1.05
#> 17             3.83            3.84                        3.84         1.06
#> 18             3.83            3.80                        3.80         1.04
#> 19             3.67            3.80                        3.80         0.77
#> 20             3.83            3.79                        3.79         1.04
#> 21             3.67            3.78                        3.78         0.77
#> 22             3.50            3.77                        3.77         0.68
#> 23             3.83            3.77                        3.77         1.04
#> 24             3.17            3.76                        3.76         0.62
#> 25             3.17            3.76                        3.76         0.61
#> 26             3.83            3.76                        3.76         1.05
#> 27             3.83            3.76                        3.76         1.05
#> 28             3.50            3.74                        3.74         0.69
#> 29             3.67            3.74                        3.74         0.78
#> 30             3.83            3.73                        3.73         1.05
#> 31             3.50            3.73                        3.73         0.70
#> 32             3.67            3.72                        3.72         0.78
#> 33             3.33            3.71                        3.71         0.61
#> 34             3.67            3.71                        3.71         0.79
#> 35             3.67            3.71                        3.71         0.78
#> 36             3.67            3.71                        3.71         0.78
#> 37             3.67            3.70                        3.70         0.78
#> 38             3.00            3.69                        3.69         0.58
#> 39             3.83            3.68                        3.68         1.04
#> 40             3.17            3.67                        3.67         0.68
#> 41             3.17            3.67                        3.67         0.68
#> 42             3.00            3.67                        3.67         0.59
#> 43             3.00            3.67                        3.67         0.59
#> 44             3.67            3.66                        3.66         0.79
#> 45             3.67            3.66                        3.66         0.79
#> 46             3.67            3.65                        3.65         0.79
#> 47             3.83            3.65                        3.65         1.04
#> 48             3.50            3.63                        3.63         0.66
#> 49             3.67            3.63                        3.63         0.79
#> 50             3.50            3.63                        3.63         0.68
#> 51             3.33            3.61                        3.61         0.64
#> 52             3.50            3.61                        3.61         0.66
#> 53             3.50            3.60                        3.60         0.66
#> 54             3.50            3.59                        3.59         0.67
#> 55             3.67            3.58                        3.58         0.78
#> 56             3.50            3.58                        3.58         0.66
#> 57             3.67            3.58                        3.58         0.78
#> 58             3.17            3.58                        3.58         0.58
#> 59             3.67            3.57                        3.57         0.78
#> 60             3.50            3.56                        3.56         0.70
#> 61             3.50            3.55                        3.55         0.67
#> 62             3.50            3.54                        3.54         0.67
#> 63             3.50            3.54                        3.54         0.67
#> 64             3.33            3.53                        3.53         0.61
#> 65             3.33            3.53                        3.53         0.61
#> 66             3.33            3.52                        3.52         0.60
#> 67             3.67            3.52                        3.52         0.78
#> 68             3.67            3.52                        3.52         0.78
#> 69             3.67            3.52                        3.52         0.78
#> 70             3.33            3.51                        3.51         0.60
#> 71             3.67            3.49                        3.49         0.78
#> 72             3.67            3.49                        3.49         0.78
#> 73             3.33            3.47                        3.47         0.62
#> 74             2.67            3.46                        3.46         0.56
#> 75             3.50            3.46                        3.46         0.68
#> 76             3.50            3.45                        3.45         0.68
#> 77             3.17            3.43                        3.43         0.57
#> 78             3.50            3.43                        3.43         0.68
#> 79             3.33            3.38                        3.38         0.64
#> 80             3.17            3.38                        3.38         0.63
#> 81             3.17            3.38                        3.38         0.63
#> 82             3.50            3.37                        3.37         0.66
#> 83             3.50            3.37                        3.37         0.66
#> 84             3.50            3.37                        3.37         0.67
#> 85             3.17            3.36                        3.36         0.57
#> 86             3.33            3.36                        3.36         0.61
#> 87             3.33            3.36                        3.36         0.61
#> 88             3.50            3.36                        3.36         0.67
#> 89             2.33            3.36                        3.36         0.55
#> 90             3.33            3.36                        3.36         0.61
#> 91             3.67            3.35                        3.35         0.77
#> 92             3.67            3.34                        3.34         0.77
#> 93             3.17            3.34                        3.34         0.57
#> 94             3.33            3.33                        3.33         0.63
#> 95             3.17            3.30                        3.30         0.59
#> 96             2.83            3.30                        3.30         0.55
#> 97             3.00            3.30                        3.30         0.58
#> 98             3.33            3.28                        3.28         0.61
#> 99             3.17            3.28                        3.28         0.57
#> 100            3.17            3.28                        3.28         0.57
#> 101            3.00            3.28                        3.28         0.55
#> 102            3.33            3.27                        3.27         0.63
#> 103            3.33            3.26                        3.26         0.63
#> 104            3.33            3.26                        3.26         0.63
#> 105            3.50            3.25                        3.25         0.67
#> 106            3.50            3.25                        3.25         0.67
#> 107            3.33            3.25                        3.25         0.62
#> 108            2.67            3.25                        3.25         0.60
#> 109            3.50            3.25                        3.25         0.67
#> 110            3.17            3.22                        3.22         0.57
#> 111            3.33            3.21                        3.21         0.62
#> 112            3.00            3.20                        3.20         0.55
#> 113            2.33            3.20                        3.20         0.56
#> 114            3.17            3.20                        3.20         0.58
#> 115            3.17            3.19                        3.19         0.58
#> 116            3.17            3.19                        3.19         0.60
#> 117            3.00            3.18                        3.18         0.60
#> 118            3.00            3.18                        3.18         0.60
#> 119            3.17            3.18                        3.18         0.58
#> 120            2.50            3.17                        3.17         0.58
#> 121            2.83            3.16                        3.16         0.56
#> 122            2.67            3.16                        3.16         0.62
#> 123            3.17            3.15                        3.15         0.58
#> 124            3.50            3.13                        3.13         0.66
#> 125            3.50            3.13                        3.13         0.66
#> 126            2.67            3.11                        3.11         0.64
#> 127            3.17            3.10                        3.10         0.59
#> 128            2.83            3.09                        3.09         0.54
#> 129            3.17            3.09                        3.09         0.57
#> 130            3.17            3.08                        3.08         0.58
#> 131            3.50            3.08                        3.08         0.66
#> 132            3.00            3.08                        3.08         0.55
#> 133            3.33            3.06                        3.06         0.61
#> 134            3.17            3.06                        3.06         0.59
#> 135            3.17            3.06                        3.06         0.59
#> 136            3.17            3.06                        3.06         0.59
#> 137            3.33            3.06                        3.06         0.61
#> 138            3.33            3.05                        3.05         0.61
#> 139            3.17            3.04                        3.04         0.59
#> 140            2.17            3.02                        3.02         0.57
#> 141            3.33            3.02                        3.02         0.61
#> 142            3.33            3.01                        3.01         0.61
#> 143            3.33            3.01                        3.01         0.61
#> 144            3.33            3.01                        3.01         0.61
#> 145            3.00            3.01                        3.01         0.56
#> 146            3.17            3.01                        3.01         0.57
#> 147            2.83            3.00                        3.00         0.54
#> 148            3.00            3.00                        3.00         0.55
#> 149            3.17            3.00                        3.00         0.59
#> 150            3.00            2.99                        2.99         0.56
#> 151            2.83            2.99                        2.99         0.54
#> 152            2.50            2.98                        2.98         0.54
#> 153            2.67            2.97                        2.97         0.54
#> 154            2.83            2.95                        2.95         0.54
#> 155            2.50            2.94                        2.94         0.54
#> 156            3.17            2.93                        2.93         0.58
#> 157            3.17            2.93                        2.93         0.58
#> 158            2.67            2.93                        2.93         0.56
#> 159            3.17            2.93                        2.93         0.58
#> 160            2.17            2.89                        2.89         0.58
#> 161            2.17            2.89                        2.89         0.58
#> 162            2.67            2.88                        2.88         0.54
#> 163            3.00            2.86                        2.86         0.57
#> 164            3.00            2.85                        2.85         0.57
#> 165            3.17            2.85                        2.85         0.58
#> 166            2.33            2.84                        2.84         0.60
#> 167            3.00            2.84                        2.84         0.57
#> 168            3.33            2.83                        2.83         0.60
#> 169            3.00            2.82                        2.82         0.55
#> 170            3.33            2.82                        2.82         0.60
#> 171            3.33            2.82                        2.82         0.60
#> 172            2.67            2.81                        2.81         0.54
#> 173            3.00            2.81                        2.81         0.55
#> 174            3.17            2.81                        2.81         0.57
#> 175            3.17            2.80                        2.80         0.57
#> 176            3.17            2.80                        2.80         0.57
#> 177            2.33            2.80                        2.80         0.55
#> 178            2.33            2.80                        2.80         0.55
#> 179            3.17            2.78                        2.78         0.57
#> 180            3.00            2.77                        2.77         0.55
#> 181            2.67            2.76                        2.76         0.58
#> 182            2.50            2.76                        2.76         0.54
#> 183            2.33            2.75                        2.75         0.55
#> 184            3.00            2.74                        2.74         0.56
#> 185            3.17            2.74                        2.74         0.57
#> 186            2.33            2.68                        2.68         0.54
#> 187            2.33            2.68                        2.68         0.54
#> 188            2.50            2.68                        2.68         0.54
#> 189            2.50            2.68                        2.68         0.54
#> 190            2.00            2.67                        2.67         0.60
#> 191            2.17            2.66                        2.66         0.60
#> 192            2.67            2.64                        2.64         0.54
#> 193            2.67            2.64                        2.64         0.54
#> 194            3.00            2.64                        2.64         0.56
#> 195            3.00            2.64                        2.64         0.56
#> 196            2.67            2.63                        2.63         0.54
#> 197            2.83            2.61                        2.61         0.55
#> 198            3.00            2.60                        2.60         0.55
#> 199            3.00            2.59                        2.59         0.55
#> 200            2.50            2.56                        2.56         0.58
#> 201            3.00            2.54                        2.54         0.55
#> 202            2.67            2.53                        2.53         0.54
#> 203            2.83            2.53                        2.53         0.55
#> 204            2.67            2.52                        2.52         0.54
#> 205            2.33            2.49                        2.49         0.54
#> 206            2.17            2.48                        2.48         0.56
#> 207            2.67            2.46                        2.46         0.55
#> 208            2.50            2.46                        2.46         0.54
#> 209            2.50            2.46                        2.46         0.54
#> 210            2.67            2.45                        2.45         0.55
#> 211            2.67            2.45                        2.45         0.54
#> 212            2.67            2.45                        2.45         0.55
#> 213            2.50            2.45                        2.45         0.54
#> 214            2.83            2.44                        2.44         0.54
#> 215            2.50            2.44                        2.44         0.54
#> 216            2.17            2.43                        2.43         0.55
#> 217            2.33            2.42                        2.42         0.55
#> 218            2.83            2.42                        2.42         0.54
#> 219            2.17            2.42                        2.42         0.55
#> 220            3.00            2.41                        2.41         0.55
#> 221            2.50            2.40                        2.40         0.54
#> 222            3.00            2.40                        2.40         0.55
#> 223            2.83            2.40                        2.40         0.54
#> 224            2.00            2.40                        2.40         0.58
#> 225            2.83            2.39                        2.39         0.54
#> 226            2.00            2.35                        2.35         0.58
#> 227            2.33            2.35                        2.35         0.58
#> 228            2.17            2.31                        2.31         0.55
#> 229            2.00            2.30                        2.30         0.57
#> 230            2.33            2.28                        2.28         0.54
#> 231            2.50            2.28                        2.28         0.55
#> 232            2.50            2.28                        2.28         0.55
#> 233            2.50            2.28                        2.28         0.55
#> 234            2.50            2.28                        2.28         0.55
#> 235            2.33            2.27                        2.27         0.54
#> 236            2.67            2.27                        2.27         0.54
#> 237            2.50            2.27                        2.27         0.55
#> 238            2.17            2.26                        2.26         0.55
#> 239            2.50            2.26                        2.26         0.54
#> 240            2.67            2.26                        2.26         0.54
#> 241            2.33            2.26                        2.26         0.54
#> 242            2.33            2.25                        2.25         0.56
#> 243            2.17            2.24                        2.24         0.56
#> 244            2.00            2.23                        2.23         0.57
#> 245            2.33            2.22                        2.22         0.55
#> 246            2.83            2.22                        2.22         0.54
#> 247            2.17            2.20                        2.20         0.56
#> 248            1.83            2.18                        2.18         0.60
#> 249            1.83            2.18                        2.18         0.60
#> 250            2.50            2.18                        2.18         0.54
#> 251            2.33            2.17                        2.17         0.54
#> 252            2.17            2.15                        2.15         0.56
#> 253            2.17            2.15                        2.15         0.59
#> 254            2.17            2.15                        2.15         0.59
#> 255            2.33            2.15                        2.15         0.55
#> 256            2.17            2.14                        2.14         0.59
#> 257            2.00            2.14                        2.14         0.57
#> 258            2.00            2.12                        2.12         0.57
#> 259            2.00            2.12                        2.12         0.57
#> 260            1.83            2.12                        2.12         0.65
#> 261            2.17            2.10                        2.10         0.55
#> 262            2.33            2.09                        2.09         0.54
#> 263            2.17            2.09                        2.09         0.56
#> 264            2.17            2.09                        2.09         0.56
#> 265            2.17            2.09                        2.09         0.56
#> 266            2.33            2.09                        2.09         0.55
#> 267            2.33            2.09                        2.09         0.55
#> 268            2.50            2.07                        2.07         0.54
#> 269            2.50            2.06                        2.06         0.54
#> 270            2.33            2.05                        2.05         0.55
#> 271            2.17            2.04                        2.04         0.55
#> 272            1.67            1.97                        1.97         0.64
#> 273            2.50            1.95                        1.95         0.54
#> 274            2.00            1.95                        1.95         0.61
#> 275            1.83            1.93                        1.93         0.62
#> 276            2.17            1.93                        1.93         0.56
#> 277            2.17            1.93                        1.93         0.56
#> 278            2.00            1.92                        1.92         0.57
#> 279            2.00            1.92                        1.92         0.57
#> 280            2.17            1.92                        1.92         0.56
#> 281            2.50            1.92                        1.92         0.54
#> 282            2.17            1.91                        1.91         0.56
#> 283            2.50            1.90                        1.90         0.54
#> 284            1.83            1.87                        1.87         0.60
#> 285            2.17            1.79                        1.79         0.56
#> 286            2.00            1.76                        1.76         0.58
#> 287            1.83            1.76                        1.76         0.63
#> 288            1.83            1.75                        1.75         0.60
#> 289            1.67            1.75                        1.75         0.64
#> 290            2.00            1.75                        1.75         0.58
#> 291            1.50            1.74                        1.74         0.71
#> 292            1.67            1.72                        1.72         0.64
#> 293            2.17            1.72                        1.72         0.55
#> 294            1.67            1.66                        1.66         0.71
#> 295            1.83            1.65                        1.65         0.61
#> 296            1.50            1.64                        1.64         0.72
#> 297            1.50            1.64                        1.64         0.72
#> 298            1.50            1.63                        1.63         0.75
#> 299            2.00            1.62                        1.62         0.57
#> 300            2.00            1.61                        1.61         0.57
#> 301            1.83            1.61                        1.61         0.61
#> 302            1.50            1.54                        1.54         0.72
#> 303            1.83            1.48                        1.48         0.60
#> 304            1.50            1.40                        1.40         0.70
#> 305            1.33            1.36                        1.36         0.82
#> 306            1.33            1.34                        1.34         0.84
#> 307            1.17            1.30                        1.30         1.12
#>     FitAdjustedSE
#> 1          100.88
#> 2           61.98
#> 3           66.36
#> 4           64.75
#> 5           54.68
#> 6           53.25
#> 7            1.08
#> 8            1.05
#> 9            1.04
#> 10           1.14
#> 11           1.18
#> 12           1.04
#> 13           1.14
#> 14           1.05
#> 15           1.07
#> 16           1.05
#> 17           1.06
#> 18           1.04
#> 19           0.77
#> 20           1.04
#> 21           0.77
#> 22           0.68
#> 23           1.04
#> 24           0.66
#> 25           0.70
#> 26           1.05
#> 27           1.05
#> 28           0.69
#> 29           0.78
#> 30           1.05
#> 31           0.77
#> 32           0.83
#> 33           0.61
#> 34           0.79
#> 35           0.78
#> 36           0.99
#> 37           0.78
#> 38           0.60
#> 39           1.04
#> 40           0.68
#> 41           0.68
#> 42           0.59
#> 43           0.89
#> 44           0.95
#> 45           0.79
#> 46           0.98
#> 47           1.04
#> 48           0.73
#> 49           0.79
#> 50           0.75
#> 51           0.64
#> 52           0.81
#> 53           0.66
#> 54           0.81
#> 55           0.78
#> 56           0.66
#> 57           0.78
#> 58           0.58
#> 59           0.78
#> 60           0.70
#> 61           0.82
#> 62           0.67
#> 63           0.67
#> 64           0.61
#> 65           0.63
#> 66           0.60
#> 67           0.78
#> 68           1.14
#> 69           0.78
#> 70           0.60
#> 71           0.82
#> 72           0.78
#> 73           0.62
#> 74           0.56
#> 75           0.68
#> 76           0.68
#> 77           0.57
#> 78           0.79
#> 79           0.72
#> 80           0.63
#> 81           0.65
#> 82           0.66
#> 83           0.66
#> 84           1.10
#> 85           0.69
#> 86           0.61
#> 87           0.61
#> 88           0.67
#> 89           0.55
#> 90           0.61
#> 91           0.77
#> 92           1.06
#> 93           0.57
#> 94           0.89
#> 95           0.96
#> 96           0.67
#> 97           0.58
#> 98           0.61
#> 99           0.88
#> 100          0.57
#> 101          0.55
#> 102          0.66
#> 103          0.63
#> 104          0.63
#> 105          0.67
#> 106          0.71
#> 107          0.62
#> 108          0.66
#> 109          0.80
#> 110          0.75
#> 111          0.80
#> 112          0.73
#> 113          0.60
#> 114          0.74
#> 115          0.58
#> 116          0.65
#> 117          0.60
#> 118          0.60
#> 119          0.65
#> 120          0.58
#> 121          0.56
#> 122          0.62
#> 123          0.82
#> 124          0.66
#> 125          0.72
#> 126          0.88
#> 127          0.60
#> 128          0.56
#> 129          0.83
#> 130          0.58
#> 131          0.74
#> 132          0.55
#> 133          0.61
#> 134          0.76
#> 135          0.79
#> 136          0.59
#> 137          0.61
#> 138          0.66
#> 139          0.59
#> 140          0.68
#> 141          0.75
#> 142          0.61
#> 143          0.61
#> 144          0.77
#> 145          0.81
#> 146          0.80
#> 147          0.54
#> 148          0.55
#> 149          0.59
#> 150          0.56
#> 151          0.54
#> 152          0.76
#> 153          0.64
#> 154          0.54
#> 155          0.75
#> 156          0.85
#> 157          0.58
#> 158          0.56
#> 159          0.60
#> 160          0.60
#> 161          0.78
#> 162          0.64
#> 163          0.57
#> 164          0.57
#> 165          0.68
#> 166          0.60
#> 167          0.58
#> 168          0.60
#> 169          0.55
#> 170          0.60
#> 171          0.68
#> 172          0.54
#> 173          0.59
#> 174          0.62
#> 175          0.57
#> 176          0.62
#> 177          0.55
#> 178          0.73
#> 179          0.75
#> 180          0.55
#> 181          1.01
#> 182          0.54
#> 183          0.60
#> 184          0.68
#> 185          0.57
#> 186          0.54
#> 187          0.54
#> 188          0.63
#> 189          0.54
#> 190          0.62
#> 191          0.60
#> 192          0.54
#> 193          0.54
#> 194          0.69
#> 195          0.56
#> 196          0.54
#> 197          0.66
#> 198          0.74
#> 199          0.55
#> 200          0.58
#> 201          0.55
#> 202          0.54
#> 203          0.55
#> 204          0.54
#> 205          0.71
#> 206          0.59
#> 207          0.55
#> 208          0.54
#> 209          0.61
#> 210          0.77
#> 211          0.54
#> 212          0.55
#> 213          0.68
#> 214          0.58
#> 215          0.54
#> 216          0.65
#> 217          0.61
#> 218          0.69
#> 219          0.56
#> 220          0.55
#> 221          0.58
#> 222          0.55
#> 223          0.54
#> 224          0.63
#> 225          0.54
#> 226          0.58
#> 227          0.58
#> 228          0.55
#> 229          0.72
#> 230          0.71
#> 231          0.82
#> 232          0.55
#> 233          0.55
#> 234          0.55
#> 235          0.56
#> 236          0.55
#> 237          0.65
#> 238          0.68
#> 239          0.54
#> 240          0.78
#> 241          0.59
#> 242          0.72
#> 243          0.70
#> 244          0.57
#> 245          0.55
#> 246          0.54
#> 247          0.58
#> 248          0.60
#> 249          0.66
#> 250          0.54
#> 251          0.54
#> 252          0.65
#> 253          0.87
#> 254          0.59
#> 255          0.55
#> 256          0.59
#> 257          0.64
#> 258          0.57
#> 259          0.57
#> 260          0.67
#> 261          0.55
#> 262          0.61
#> 263          0.56
#> 264          0.56
#> 265          0.56
#> 266          0.61
#> 267          0.55
#> 268          0.54
#> 269          0.54
#> 270          0.68
#> 271          0.55
#> 272          0.80
#> 273          0.54
#> 274          0.90
#> 275          0.62
#> 276          0.56
#> 277          0.84
#> 278          0.57
#> 279          0.67
#> 280          0.56
#> 281          0.54
#> 282          0.56
#> 283          0.54
#> 284          0.73
#> 285          0.56
#> 286          0.58
#> 287          0.69
#> 288          0.96
#> 289          0.64
#> 290          0.58
#> 291          0.71
#> 292          0.64
#> 293          0.55
#> 294          0.71
#> 295          0.61
#> 296          0.72
#> 297          0.72
#> 298          1.24
#> 299          0.59
#> 300          0.58
#> 301          0.61
#> 302          0.72
#> 303          0.60
#> 304          1.13
#> 305          0.82
#> 306          0.84
#> 307          1.12
#> 
#> $by_facet$Rater
#>    Total Score Total Count Weightd Score Weightd Count Obsvd Average
#> 1          148          75           148            75          1.97
#> 2          272         126           272           126          2.16
#> 3          190          75           190            75          2.53
#> 4          141          48           141            48          2.94
#> 5          515         192           515           192          2.68
#> 6          241          84           241            84          2.87
#> 7          387         150           387           150          2.58
#> 8          263          90           263            90          2.92
#> 9          103          33           103            33          3.12
#> 10         197          69           197            69          2.86
#> 11         370         123           370           123          3.01
#> 12         319         105           319           105          3.04
#> 13         528         174           528           174          3.03
#> 14          41          15            41            15          2.73
#> 15         140          42           140            42          3.33
#> 16         387         117           387           117          3.31
#> 17         749         228           749           228          3.29
#> 18         305          96           305            96          3.18
#>    Fair(M) Average Fair(Z) Average Measure Model S.E. Real S.E. Infit MnSq
#> 1             1.71            1.37    2.29       0.18      0.20       1.25
#> 2             2.27            1.77    1.24       0.14      0.15       1.19
#> 3             2.63            2.06    0.67       0.16      0.16       0.85
#> 4             2.74            2.16    0.50       0.21      0.21       0.93
#> 5             2.86            2.27    0.31       0.11      0.11       0.92
#> 6             2.86            2.27    0.31       0.17      0.18       1.19
#> 7             2.89            2.30    0.26       0.12      0.12       1.04
#> 8             2.95            2.36    0.16       0.15      0.15       1.02
#> 9             3.07            2.48   -0.03       0.26      0.26       0.82
#> 10            3.07            2.49   -0.05       0.17      0.19       1.15
#> 11            3.22            2.66   -0.30       0.13      0.13       0.99
#> 12            3.28            2.73   -0.42       0.14      0.15       1.11
#> 13            3.30            2.75   -0.45       0.12      0.12       0.90
#> 14            3.37            2.84   -0.60       0.35      0.35       0.41
#> 15            3.47            2.99   -0.84       0.26      0.26       1.01
#> 16            3.53            3.08   -0.99       0.14      0.16       1.15
#> 17            3.54            3.09   -1.01       0.11      0.11       0.83
#> 18            3.55            3.11   -1.04       0.15      0.15       0.90
#>    Infit ZStd Outfit MnSq Outfit ZStd PtMea Corr Anch Status Element
#> 1        1.02        1.16        0.97       0.68                 R13
#> 2        1.01        1.11        0.92       0.68                 R06
#> 3       -0.61        0.87       -0.78       0.68                 R01
#> 4       -0.16        0.87       -0.59       0.68                 R16
#> 5       -0.53        0.92       -0.77       0.68                 R10
#> 6        0.81        1.15        0.97       0.68                 R17
#> 7        0.28        0.98       -0.17       0.68                 R11
#> 8        0.17        1.00        0.04       0.68                 R12
#> 9       -0.38        0.69       -1.34       0.68                 R07
#> 10       0.67        1.25        1.41       0.68                 R02
#> 11       0.03        0.93       -0.53       0.68                 R18
#> 12       0.57        1.11        0.83       0.68                 R03
#> 13      -0.61        0.92       -0.71       0.68                 R05
#> 14      -1.39        0.43       -1.87       0.68                 R15
#> 15       0.15        1.04        0.27       0.68                 R14
#> 16       0.74        1.12        0.95       0.68                 R09
#> 17      -1.11        0.78       -2.52       0.68                 R08
#> 18      -0.40        0.89       -0.75       0.68                 R04
#>    ObservedAverage AdjustedAverage StandardizedAdjustedAverage ModelBasedSE
#> 1             1.97            1.71                        1.37         0.18
#> 2             2.16            2.27                        1.77         0.14
#> 3             2.53            2.63                        2.06         0.16
#> 4             2.94            2.74                        2.16         0.21
#> 5             2.68            2.86                        2.27         0.11
#> 6             2.87            2.86                        2.27         0.17
#> 7             2.58            2.89                        2.30         0.12
#> 8             2.92            2.95                        2.36         0.15
#> 9             3.12            3.07                        2.48         0.26
#> 10            2.86            3.07                        2.49         0.17
#> 11            3.01            3.22                        2.66         0.13
#> 12            3.04            3.28                        2.73         0.14
#> 13            3.03            3.30                        2.75         0.12
#> 14            2.73            3.37                        2.84         0.35
#> 15            3.33            3.47                        2.99         0.26
#> 16            3.31            3.53                        3.08         0.14
#> 17            3.29            3.54                        3.09         0.11
#> 18            3.18            3.55                        3.11         0.15
#>    FitAdjustedSE
#> 1           0.20
#> 2           0.15
#> 3           0.16
#> 4           0.21
#> 5           0.11
#> 6           0.18
#> 7           0.12
#> 8           0.15
#> 9           0.26
#> 10          0.19
#> 11          0.13
#> 12          0.15
#> 13          0.12
#> 14          0.35
#> 15          0.26
#> 16          0.16
#> 17          0.11
#> 18          0.15
#> 
#> $by_facet$Criterion
#>   Total Score Total Count Weightd Score Weightd Count Obsvd Average
#> 1        1618         614          1618           614          2.64
#> 2        1641         614          1641           614          2.67
#> 3        2037         614          2037           614          3.32
#>   Fair(M) Average Fair(Z) Average Measure Model S.E. Real S.E. Infit MnSq
#> 1            2.71            2.13    0.55       0.06      0.06       1.01
#> 2            2.76            2.18    0.47       0.06      0.06       0.99
#> 3            3.54            3.10   -1.02       0.07      0.07       0.99
#>   Infit ZStd Outfit MnSq Outfit ZStd PtMea Corr Anch Status
#> 1       0.11        0.97       -0.55       0.42            
#> 2      -0.09        0.98       -0.35       0.42            
#> 3      -0.08        0.97       -0.58       0.42            
#>                  Element ObservedAverage AdjustedAverage
#> 1       Task_Fulfillment            2.64            2.71
#> 2 Linguistic_Realization            2.67            2.76
#> 3      Global_Impression            3.32            3.54
#>   StandardizedAdjustedAverage ModelBasedSE FitAdjustedSE
#> 1                        2.13         0.06          0.06
#> 2                        2.18         0.06          0.06
#> 3                        3.10         0.07          0.07
#> 
#> 
#> $stacked
#>         Facet Total Score Total Count Weightd Score Weightd Count Obsvd Average
#> 1      Person          24           6            24             6          4.00
#> 2      Person          24           6            24             6          4.00
#> 3      Person          24           6            24             6          4.00
#> 4      Person          24           6            24             6          4.00
#> 5      Person          24           6            24             6          4.00
#> 6      Person          24           6            24             6          4.00
#> 7      Person          23           6            23             6          3.83
#> 8      Person          23           6            23             6          3.83
#> 9      Person          23           6            23             6          3.83
#> 10     Person          23           6            23             6          3.83
#> 11     Person          23           6            23             6          3.83
#> 12     Person          23           6            23             6          3.83
#> 13     Person          23           6            23             6          3.83
#> 14     Person          23           6            23             6          3.83
#> 15     Person          23           6            23             6          3.83
#> 16     Person          23           6            23             6          3.83
#> 17     Person          23           6            23             6          3.83
#> 18     Person          23           6            23             6          3.83
#> 19     Person          22           6            22             6          3.67
#> 20     Person          23           6            23             6          3.83
#> 21     Person          22           6            22             6          3.67
#> 22     Person          21           6            21             6          3.50
#> 23     Person          23           6            23             6          3.83
#> 24     Person          19           6            19             6          3.17
#> 25     Person          19           6            19             6          3.17
#> 26     Person          23           6            23             6          3.83
#> 27     Person          23           6            23             6          3.83
#> 28     Person          21           6            21             6          3.50
#> 29     Person          22           6            22             6          3.67
#> 30     Person          23           6            23             6          3.83
#> 31     Person          21           6            21             6          3.50
#> 32     Person          22           6            22             6          3.67
#> 33     Person          20           6            20             6          3.33
#> 34     Person          22           6            22             6          3.67
#> 35     Person          22           6            22             6          3.67
#> 36     Person          22           6            22             6          3.67
#> 37     Person          22           6            22             6          3.67
#> 38     Person          18           6            18             6          3.00
#> 39     Person          23           6            23             6          3.83
#> 40     Person          19           6            19             6          3.17
#> 41     Person          19           6            19             6          3.17
#> 42     Person          18           6            18             6          3.00
#> 43     Person          18           6            18             6          3.00
#> 44     Person          22           6            22             6          3.67
#> 45     Person          22           6            22             6          3.67
#> 46     Person          22           6            22             6          3.67
#> 47     Person          23           6            23             6          3.83
#> 48     Person          21           6            21             6          3.50
#> 49     Person          22           6            22             6          3.67
#> 50     Person          21           6            21             6          3.50
#> 51     Person          20           6            20             6          3.33
#> 52     Person          21           6            21             6          3.50
#> 53     Person          21           6            21             6          3.50
#> 54     Person          21           6            21             6          3.50
#> 55     Person          22           6            22             6          3.67
#> 56     Person          21           6            21             6          3.50
#> 57     Person          22           6            22             6          3.67
#> 58     Person          19           6            19             6          3.17
#> 59     Person          22           6            22             6          3.67
#> 60     Person          21           6            21             6          3.50
#> 61     Person          21           6            21             6          3.50
#> 62     Person          21           6            21             6          3.50
#> 63     Person          21           6            21             6          3.50
#> 64     Person          20           6            20             6          3.33
#> 65     Person          20           6            20             6          3.33
#> 66     Person          20           6            20             6          3.33
#> 67     Person          22           6            22             6          3.67
#> 68     Person          22           6            22             6          3.67
#> 69     Person          22           6            22             6          3.67
#> 70     Person          20           6            20             6          3.33
#> 71     Person          22           6            22             6          3.67
#> 72     Person          22           6            22             6          3.67
#> 73     Person          20           6            20             6          3.33
#> 74     Person          16           6            16             6          2.67
#> 75     Person          21           6            21             6          3.50
#> 76     Person          21           6            21             6          3.50
#> 77     Person          19           6            19             6          3.17
#> 78     Person          21           6            21             6          3.50
#> 79     Person          20           6            20             6          3.33
#> 80     Person          19           6            19             6          3.17
#> 81     Person          19           6            19             6          3.17
#> 82     Person          21           6            21             6          3.50
#> 83     Person          21           6            21             6          3.50
#> 84     Person          21           6            21             6          3.50
#> 85     Person          19           6            19             6          3.17
#> 86     Person          20           6            20             6          3.33
#> 87     Person          20           6            20             6          3.33
#> 88     Person          21           6            21             6          3.50
#> 89     Person          14           6            14             6          2.33
#> 90     Person          20           6            20             6          3.33
#> 91     Person          22           6            22             6          3.67
#> 92     Person          22           6            22             6          3.67
#> 93     Person          19           6            19             6          3.17
#> 94     Person          20           6            20             6          3.33
#> 95     Person          19           6            19             6          3.17
#> 96     Person          17           6            17             6          2.83
#> 97     Person          18           6            18             6          3.00
#> 98     Person          20           6            20             6          3.33
#> 99     Person          19           6            19             6          3.17
#> 100    Person          19           6            19             6          3.17
#> 101    Person          18           6            18             6          3.00
#> 102    Person          20           6            20             6          3.33
#> 103    Person          20           6            20             6          3.33
#> 104    Person          20           6            20             6          3.33
#> 105    Person          21           6            21             6          3.50
#> 106    Person          21           6            21             6          3.50
#> 107    Person          20           6            20             6          3.33
#> 108    Person          16           6            16             6          2.67
#> 109    Person          21           6            21             6          3.50
#> 110    Person          19           6            19             6          3.17
#> 111    Person          20           6            20             6          3.33
#> 112    Person          18           6            18             6          3.00
#> 113    Person          14           6            14             6          2.33
#> 114    Person          19           6            19             6          3.17
#> 115    Person          19           6            19             6          3.17
#> 116    Person          19           6            19             6          3.17
#> 117    Person          18           6            18             6          3.00
#> 118    Person          18           6            18             6          3.00
#> 119    Person          19           6            19             6          3.17
#> 120    Person          15           6            15             6          2.50
#> 121    Person          17           6            17             6          2.83
#> 122    Person          16           6            16             6          2.67
#> 123    Person          19           6            19             6          3.17
#> 124    Person          21           6            21             6          3.50
#> 125    Person          21           6            21             6          3.50
#> 126    Person          16           6            16             6          2.67
#> 127    Person          19           6            19             6          3.17
#> 128    Person          17           6            17             6          2.83
#> 129    Person          19           6            19             6          3.17
#> 130    Person          19           6            19             6          3.17
#> 131    Person          21           6            21             6          3.50
#> 132    Person          18           6            18             6          3.00
#> 133    Person          20           6            20             6          3.33
#> 134    Person          19           6            19             6          3.17
#> 135    Person          19           6            19             6          3.17
#> 136    Person          19           6            19             6          3.17
#> 137    Person          20           6            20             6          3.33
#> 138    Person          20           6            20             6          3.33
#> 139    Person          19           6            19             6          3.17
#> 140    Person          13           6            13             6          2.17
#> 141    Person          20           6            20             6          3.33
#> 142    Person          20           6            20             6          3.33
#> 143    Person          20           6            20             6          3.33
#> 144    Person          20           6            20             6          3.33
#> 145    Person          18           6            18             6          3.00
#> 146    Person          19           6            19             6          3.17
#> 147    Person          17           6            17             6          2.83
#> 148    Person          18           6            18             6          3.00
#> 149    Person          19           6            19             6          3.17
#> 150    Person          18           6            18             6          3.00
#> 151    Person          17           6            17             6          2.83
#> 152    Person          15           6            15             6          2.50
#> 153    Person          16           6            16             6          2.67
#> 154    Person          17           6            17             6          2.83
#> 155    Person          15           6            15             6          2.50
#> 156    Person          19           6            19             6          3.17
#> 157    Person          19           6            19             6          3.17
#> 158    Person          16           6            16             6          2.67
#> 159    Person          19           6            19             6          3.17
#> 160    Person          13           6            13             6          2.17
#> 161    Person          13           6            13             6          2.17
#> 162    Person          16           6            16             6          2.67
#> 163    Person          18           6            18             6          3.00
#> 164    Person          18           6            18             6          3.00
#> 165    Person          19           6            19             6          3.17
#> 166    Person          14           6            14             6          2.33
#> 167    Person          18           6            18             6          3.00
#> 168    Person          20           6            20             6          3.33
#> 169    Person          18           6            18             6          3.00
#> 170    Person          20           6            20             6          3.33
#> 171    Person          20           6            20             6          3.33
#> 172    Person          16           6            16             6          2.67
#> 173    Person          18           6            18             6          3.00
#> 174    Person          19           6            19             6          3.17
#> 175    Person          19           6            19             6          3.17
#> 176    Person          19           6            19             6          3.17
#> 177    Person          14           6            14             6          2.33
#> 178    Person          14           6            14             6          2.33
#> 179    Person          19           6            19             6          3.17
#> 180    Person          18           6            18             6          3.00
#> 181    Person          16           6            16             6          2.67
#> 182    Person          15           6            15             6          2.50
#> 183    Person          14           6            14             6          2.33
#> 184    Person          18           6            18             6          3.00
#> 185    Person          19           6            19             6          3.17
#> 186    Person          14           6            14             6          2.33
#> 187    Person          14           6            14             6          2.33
#> 188    Person          15           6            15             6          2.50
#> 189    Person          15           6            15             6          2.50
#> 190    Person          12           6            12             6          2.00
#> 191    Person          13           6            13             6          2.17
#> 192    Person          16           6            16             6          2.67
#> 193    Person          16           6            16             6          2.67
#> 194    Person          18           6            18             6          3.00
#> 195    Person          18           6            18             6          3.00
#> 196    Person          16           6            16             6          2.67
#> 197    Person          17           6            17             6          2.83
#> 198    Person          18           6            18             6          3.00
#> 199    Person          18           6            18             6          3.00
#> 200    Person          15           6            15             6          2.50
#> 201    Person          18           6            18             6          3.00
#> 202    Person          16           6            16             6          2.67
#> 203    Person          17           6            17             6          2.83
#> 204    Person          16           6            16             6          2.67
#> 205    Person          14           6            14             6          2.33
#> 206    Person          13           6            13             6          2.17
#> 207    Person          16           6            16             6          2.67
#> 208    Person          15           6            15             6          2.50
#> 209    Person          15           6            15             6          2.50
#> 210    Person          16           6            16             6          2.67
#> 211    Person          16           6            16             6          2.67
#> 212    Person          16           6            16             6          2.67
#> 213    Person          15           6            15             6          2.50
#> 214    Person          17           6            17             6          2.83
#> 215    Person          15           6            15             6          2.50
#> 216    Person          13           6            13             6          2.17
#> 217    Person          14           6            14             6          2.33
#> 218    Person          17           6            17             6          2.83
#> 219    Person          13           6            13             6          2.17
#> 220    Person          18           6            18             6          3.00
#> 221    Person          15           6            15             6          2.50
#> 222    Person          18           6            18             6          3.00
#> 223    Person          17           6            17             6          2.83
#> 224    Person          12           6            12             6          2.00
#> 225    Person          17           6            17             6          2.83
#> 226    Person          12           6            12             6          2.00
#> 227    Person          14           6            14             6          2.33
#> 228    Person          13           6            13             6          2.17
#> 229    Person          12           6            12             6          2.00
#> 230    Person          14           6            14             6          2.33
#> 231    Person          15           6            15             6          2.50
#> 232    Person          15           6            15             6          2.50
#> 233    Person          15           6            15             6          2.50
#> 234    Person          15           6            15             6          2.50
#> 235    Person          14           6            14             6          2.33
#> 236    Person          16           6            16             6          2.67
#> 237    Person          15           6            15             6          2.50
#> 238    Person          13           6            13             6          2.17
#> 239    Person          15           6            15             6          2.50
#> 240    Person          16           6            16             6          2.67
#> 241    Person          14           6            14             6          2.33
#> 242    Person          14           6            14             6          2.33
#> 243    Person          13           6            13             6          2.17
#> 244    Person          12           6            12             6          2.00
#> 245    Person          14           6            14             6          2.33
#> 246    Person          17           6            17             6          2.83
#> 247    Person          13           6            13             6          2.17
#> 248    Person          11           6            11             6          1.83
#> 249    Person          11           6            11             6          1.83
#> 250    Person          15           6            15             6          2.50
#> 251    Person          14           6            14             6          2.33
#> 252    Person          13           6            13             6          2.17
#> 253    Person          13           6            13             6          2.17
#> 254    Person          13           6            13             6          2.17
#> 255    Person          14           6            14             6          2.33
#> 256    Person          13           6            13             6          2.17
#> 257    Person          12           6            12             6          2.00
#> 258    Person          12           6            12             6          2.00
#> 259    Person          12           6            12             6          2.00
#> 260    Person          11           6            11             6          1.83
#> 261    Person          13           6            13             6          2.17
#> 262    Person          14           6            14             6          2.33
#> 263    Person          13           6            13             6          2.17
#> 264    Person          13           6            13             6          2.17
#> 265    Person          13           6            13             6          2.17
#> 266    Person          14           6            14             6          2.33
#> 267    Person          14           6            14             6          2.33
#> 268    Person          15           6            15             6          2.50
#> 269    Person          15           6            15             6          2.50
#> 270    Person          14           6            14             6          2.33
#> 271    Person          13           6            13             6          2.17
#> 272    Person          10           6            10             6          1.67
#> 273    Person          15           6            15             6          2.50
#> 274    Person          12           6            12             6          2.00
#> 275    Person          11           6            11             6          1.83
#> 276    Person          13           6            13             6          2.17
#> 277    Person          13           6            13             6          2.17
#> 278    Person          12           6            12             6          2.00
#> 279    Person          12           6            12             6          2.00
#> 280    Person          13           6            13             6          2.17
#> 281    Person          15           6            15             6          2.50
#> 282    Person          13           6            13             6          2.17
#> 283    Person          15           6            15             6          2.50
#> 284    Person          11           6            11             6          1.83
#> 285    Person          13           6            13             6          2.17
#> 286    Person          12           6            12             6          2.00
#> 287    Person          11           6            11             6          1.83
#> 288    Person          11           6            11             6          1.83
#> 289    Person          10           6            10             6          1.67
#> 290    Person          12           6            12             6          2.00
#> 291    Person           9           6             9             6          1.50
#> 292    Person          10           6            10             6          1.67
#> 293    Person          13           6            13             6          2.17
#> 294    Person          10           6            10             6          1.67
#> 295    Person          11           6            11             6          1.83
#> 296    Person           9           6             9             6          1.50
#> 297    Person           9           6             9             6          1.50
#> 298    Person           9           6             9             6          1.50
#> 299    Person          12           6            12             6          2.00
#> 300    Person          12           6            12             6          2.00
#> 301    Person          11           6            11             6          1.83
#> 302    Person           9           6             9             6          1.50
#> 303    Person          11           6            11             6          1.83
#> 304    Person           9           6             9             6          1.50
#> 305    Person           8           6             8             6          1.33
#> 306    Person           8           6             8             6          1.33
#> 307    Person           7           6             7             6          1.17
#> 308     Rater         148          75           148            75          1.97
#> 309     Rater         272         126           272           126          2.16
#> 310     Rater         190          75           190            75          2.53
#> 311     Rater         141          48           141            48          2.94
#> 312     Rater         515         192           515           192          2.68
#> 313     Rater         241          84           241            84          2.87
#> 314     Rater         387         150           387           150          2.58
#> 315     Rater         263          90           263            90          2.92
#> 316     Rater         103          33           103            33          3.12
#> 317     Rater         197          69           197            69          2.86
#> 318     Rater         370         123           370           123          3.01
#> 319     Rater         319         105           319           105          3.04
#> 320     Rater         528         174           528           174          3.03
#> 321     Rater          41          15            41            15          2.73
#> 322     Rater         140          42           140            42          3.33
#> 323     Rater         387         117           387           117          3.31
#> 324     Rater         749         228           749           228          3.29
#> 325     Rater         305          96           305            96          3.18
#> 326 Criterion        1618         614          1618           614          2.64
#> 327 Criterion        1641         614          1641           614          2.67
#> 328 Criterion        2037         614          2037           614          3.32
#>     Fair(M) Average Fair(Z) Average Measure Model S.E. Real S.E. Infit MnSq
#> 1              4.00            4.00   12.63     100.88    100.88         NA
#> 2              4.00            4.00   12.25      61.98     61.98         NA
#> 3              4.00            4.00   11.56      66.36     66.36         NA
#> 4              4.00            4.00   11.55      64.75     64.75         NA
#> 5              4.00            4.00   10.69      54.68     54.68         NA
#> 6              4.00            4.00   10.60      53.25     53.25         NA
#> 7              3.97            3.97    4.82       1.08      1.08       0.65
#> 8              3.94            3.94    4.13       1.05      1.05       0.70
#> 9              3.89            3.89    3.51       1.04      1.04       0.77
#> 10             3.88            3.88    3.41       1.04      1.14       1.18
#> 11             3.88            3.88    3.41       1.06      1.18       1.23
#> 12             3.87            3.87    3.34       1.04      1.04       0.80
#> 13             3.87            3.87    3.31       1.05      1.14       1.19
#> 14             3.86            3.86    3.26       1.05      1.05       0.72
#> 15             3.86            3.86    3.26       1.05      1.07       1.03
#> 16             3.84            3.84    3.14       1.05      1.05       0.63
#> 17             3.84            3.84    3.10       1.06      1.06       0.67
#> 18             3.80            3.80    2.91       1.04      1.04       0.87
#> 19             3.80            3.80    2.87       0.77      0.77       0.59
#> 20             3.79            3.79    2.83       1.04      1.04       0.83
#> 21             3.78            3.78    2.79       0.77      0.77       0.62
#> 22             3.77            3.77    2.76       0.68      0.68       0.83
#> 23             3.77            3.77    2.73       1.04      1.04       0.97
#> 24             3.76            3.76    2.68       0.62      0.66       1.14
#> 25             3.76            3.76    2.68       0.61      0.70       1.30
#> 26             3.76            3.76    2.67       1.05      1.05       0.72
#> 27             3.76            3.76    2.67       1.05      1.05       0.68
#> 28             3.74            3.74    2.60       0.69      0.69       1.01
#> 29             3.74            3.74    2.59       0.78      0.78       0.72
#> 30             3.73            3.73    2.57       1.05      1.05       0.74
#> 31             3.73            3.73    2.56       0.70      0.77       1.22
#> 32             3.72            3.72    2.52       0.78      0.83       1.14
#> 33             3.71            3.71    2.48       0.61      0.61       0.84
#> 34             3.71            3.71    2.47       0.79      0.79       0.85
#> 35             3.71            3.71    2.46       0.78      0.78       0.35
#> 36             3.71            3.71    2.46       0.78      0.99       1.60
#> 37             3.70            3.70    2.43       0.78      0.78       0.36
#> 38             3.69            3.69    2.40       0.58      0.60       1.05
#> 39             3.68            3.68    2.35       1.04      1.04       0.81
#> 40             3.67            3.67    2.33       0.68      0.68       0.62
#> 41             3.67            3.67    2.32       0.68      0.68       0.92
#> 42             3.67            3.67    2.32       0.59      0.59       0.96
#> 43             3.67            3.67    2.32       0.59      0.89       2.25
#> 44             3.66            3.66    2.28       0.79      0.95       1.43
#> 45             3.66            3.66    2.28       0.79      0.79       0.81
#> 46             3.65            3.65    2.25       0.79      0.98       1.53
#> 47             3.65            3.65    2.25       1.04      1.04       0.80
#> 48             3.63            3.63    2.19       0.66      0.73       1.21
#> 49             3.63            3.63    2.18       0.79      0.79       1.00
#> 50             3.63            3.63    2.18       0.68      0.75       1.23
#> 51             3.61            3.61    2.12       0.64      0.64       0.51
#> 52             3.61            3.61    2.12       0.66      0.81       1.48
#> 53             3.60            3.60    2.10       0.66      0.66       0.46
#> 54             3.59            3.59    2.06       0.67      0.81       1.44
#> 55             3.58            3.58    2.05       0.78      0.78       0.30
#> 56             3.58            3.58    2.05       0.66      0.66       0.79
#> 57             3.58            3.58    2.04       0.78      0.78       0.70
#> 58             3.58            3.58    2.04       0.58      0.58       0.63
#> 59             3.57            3.57    2.03       0.78      0.78       0.82
#> 60             3.56            3.56    1.99       0.70      0.70       0.57
#> 61             3.55            3.55    1.96       0.67      0.82       1.50
#> 62             3.54            3.54    1.94       0.67      0.67       0.93
#> 63             3.54            3.54    1.94       0.67      0.67       0.49
#> 64             3.53            3.53    1.92       0.61      0.61       0.79
#> 65             3.53            3.53    1.92       0.61      0.63       1.08
#> 66             3.52            3.52    1.89       0.60      0.60       0.84
#> 67             3.52            3.52    1.88       0.78      0.78       0.90
#> 68             3.52            3.52    1.87       0.78      1.14       2.16
#> 69             3.52            3.52    1.87       0.78      0.78       0.94
#> 70             3.51            3.51    1.87       0.60      0.60       0.82
#> 71             3.49            3.49    1.80       0.78      0.82       1.13
#> 72             3.49            3.49    1.80       0.78      0.78       0.91
#> 73             3.47            3.47    1.75       0.62      0.62       0.55
#> 74             3.46            3.46    1.75       0.56      0.56       0.84
#> 75             3.46            3.46    1.75       0.68      0.68       0.65
#> 76             3.45            3.45    1.71       0.68      0.68       0.67
#> 77             3.43            3.43    1.66       0.57      0.57       0.29
#> 78             3.43            3.43    1.65       0.68      0.79       1.35
#> 79             3.38            3.38    1.56       0.64      0.72       1.28
#> 80             3.38            3.38    1.55       0.63      0.63       0.97
#> 81             3.38            3.38    1.55       0.63      0.65       1.09
#> 82             3.37            3.37    1.54       0.66      0.66       0.35
#> 83             3.37            3.37    1.54       0.66      0.66       0.40
#> 84             3.37            3.37    1.53       0.67      1.10       2.66
#> 85             3.36            3.36    1.52       0.57      0.69       1.46
#> 86             3.36            3.36    1.52       0.61      0.61       0.63
#> 87             3.36            3.36    1.52       0.61      0.61       0.62
#> 88             3.36            3.36    1.52       0.67      0.67       0.58
#> 89             3.36            3.36    1.51       0.55      0.55       0.71
#> 90             3.36            3.36    1.51       0.61      0.61       0.66
#> 91             3.35            3.35    1.49       0.77      0.77       0.62
#> 92             3.34            3.34    1.47       0.77      1.06       1.87
#> 93             3.34            3.34    1.47       0.57      0.57       0.61
#> 94             3.33            3.33    1.45       0.63      0.89       1.98
#> 95             3.30            3.30    1.39       0.59      0.96       2.71
#> 96             3.30            3.30    1.39       0.55      0.67       1.49
#> 97             3.30            3.30    1.39       0.58      0.58       0.97
#> 98             3.28            3.28    1.36       0.61      0.61       0.67
#> 99             3.28            3.28    1.35       0.57      0.88       2.38
#> 100            3.28            3.28    1.35       0.57      0.57       0.91
#> 101            3.28            3.28    1.34       0.55      0.55       0.30
#> 102            3.27            3.27    1.33       0.63      0.66       1.12
#> 103            3.26            3.26    1.31       0.63      0.63       0.53
#> 104            3.26            3.26    1.31       0.63      0.63       0.66
#> 105            3.25            3.25    1.30       0.67      0.67       0.55
#> 106            3.25            3.25    1.30       0.67      0.71       1.13
#> 107            3.25            3.25    1.30       0.62      0.62       0.54
#> 108            3.25            3.25    1.30       0.60      0.66       1.20
#> 109            3.25            3.25    1.29       0.67      0.80       1.44
#> 110            3.22            3.22    1.23       0.57      0.75       1.69
#> 111            3.21            3.21    1.23       0.62      0.80       1.67
#> 112            3.20            3.20    1.21       0.55      0.73       1.77
#> 113            3.20            3.20    1.21       0.56      0.60       1.13
#> 114            3.20            3.20    1.20       0.58      0.74       1.66
#> 115            3.19            3.19    1.19       0.58      0.58       0.91
#> 116            3.19            3.19    1.18       0.60      0.65       1.18
#> 117            3.18            3.18    1.17       0.60      0.60       1.00
#> 118            3.18            3.18    1.17       0.60      0.60       0.98
#> 119            3.18            3.18    1.16       0.58      0.65       1.27
#> 120            3.17            3.17    1.15       0.58      0.58       0.92
#> 121            3.16            3.16    1.13       0.56      0.56       0.04
#> 122            3.16            3.16    1.12       0.62      0.62       0.68
#> 123            3.15            3.15    1.11       0.58      0.82       2.03
#> 124            3.13            3.13    1.07       0.66      0.66       0.33
#> 125            3.13            3.13    1.07       0.66      0.72       1.17
#> 126            3.11            3.11    1.05       0.64      0.88       1.91
#> 127            3.10            3.10    1.02       0.59      0.60       1.06
#> 128            3.09            3.09    1.01       0.54      0.56       1.08
#> 129            3.09            3.09    1.01       0.57      0.83       2.12
#> 130            3.08            3.08    0.99       0.58      0.58       0.24
#> 131            3.08            3.08    0.98       0.66      0.74       1.26
#> 132            3.08            3.08    0.98       0.55      0.55       0.34
#> 133            3.06            3.06    0.96       0.61      0.61       0.57
#> 134            3.06            3.06    0.96       0.59      0.76       1.65
#> 135            3.06            3.06    0.96       0.59      0.79       1.78
#> 136            3.06            3.06    0.95       0.59      0.59       0.36
#> 137            3.06            3.06    0.95       0.61      0.61       0.49
#> 138            3.05            3.05    0.94       0.61      0.66       1.15
#> 139            3.04            3.04    0.91       0.59      0.59       0.55
#> 140            3.02            3.02    0.89       0.57      0.68       1.40
#> 141            3.02            3.02    0.88       0.61      0.75       1.54
#> 142            3.01            3.01    0.88       0.61      0.61       0.82
#> 143            3.01            3.01    0.87       0.61      0.61       0.51
#> 144            3.01            3.01    0.87       0.61      0.77       1.60
#> 145            3.01            3.01    0.87       0.56      0.81       2.14
#> 146            3.01            3.01    0.86       0.57      0.80       1.95
#> 147            3.00            3.00    0.86       0.54      0.54       0.22
#> 148            3.00            3.00    0.86       0.55      0.55       0.73
#> 149            3.00            3.00    0.85       0.59      0.59       0.70
#> 150            2.99            2.99    0.84       0.56      0.56       0.81
#> 151            2.99            2.99    0.84       0.54      0.54       0.42
#> 152            2.98            2.98    0.82       0.54      0.76       1.98
#> 153            2.97            2.97    0.80       0.54      0.64       1.40
#> 154            2.95            2.95    0.77       0.54      0.54       0.51
#> 155            2.94            2.94    0.75       0.54      0.75       1.88
#> 156            2.93            2.93    0.75       0.58      0.85       2.13
#> 157            2.93            2.93    0.75       0.58      0.58       0.47
#> 158            2.93            2.93    0.74       0.56      0.56       0.33
#> 159            2.93            2.93    0.73       0.58      0.60       1.07
#> 160            2.89            2.89    0.68       0.58      0.60       1.05
#> 161            2.89            2.89    0.68       0.58      0.78       1.81
#> 162            2.88            2.88    0.65       0.54      0.64       1.43
#> 163            2.86            2.86    0.62       0.57      0.57       0.35
#> 164            2.85            2.85    0.62       0.57      0.57       0.37
#> 165            2.85            2.85    0.61       0.58      0.68       1.40
#> 166            2.84            2.84    0.60       0.60      0.60       0.48
#> 167            2.84            2.84    0.59       0.57      0.58       1.03
#> 168            2.83            2.83    0.57       0.60      0.60       0.82
#> 169            2.82            2.82    0.56       0.55      0.55       0.43
#> 170            2.82            2.82    0.56       0.60      0.60       0.77
#> 171            2.82            2.82    0.56       0.60      0.68       1.26
#> 172            2.81            2.81    0.55       0.54      0.54       0.86
#> 173            2.81            2.81    0.55       0.55      0.59       1.13
#> 174            2.81            2.81    0.55       0.57      0.62       1.15
#> 175            2.80            2.80    0.53       0.57      0.57       0.73
#> 176            2.80            2.80    0.53       0.57      0.62       1.15
#> 177            2.80            2.80    0.53       0.55      0.55       0.75
#> 178            2.80            2.80    0.53       0.55      0.73       1.78
#> 179            2.78            2.78    0.50       0.57      0.75       1.70
#> 180            2.77            2.77    0.48       0.55      0.55       0.29
#> 181            2.76            2.76    0.46       0.58      1.01       3.03
#> 182            2.76            2.76    0.46       0.54      0.54       0.74
#> 183            2.75            2.75    0.45       0.55      0.60       1.21
#> 184            2.74            2.74    0.43       0.56      0.68       1.47
#> 185            2.74            2.74    0.43       0.57      0.57       0.70
#> 186            2.68            2.68    0.35       0.54      0.54       0.57
#> 187            2.68            2.68    0.35       0.54      0.54       0.01
#> 188            2.68            2.68    0.34       0.54      0.63       1.37
#> 189            2.68            2.68    0.34       0.54      0.54       0.85
#> 190            2.67            2.67    0.33       0.60      0.62       1.07
#> 191            2.66            2.66    0.31       0.60      0.60       0.80
#> 192            2.64            2.64    0.28       0.54      0.54       0.55
#> 193            2.64            2.64    0.28       0.54      0.54       0.87
#> 194            2.64            2.64    0.28       0.56      0.69       1.55
#> 195            2.64            2.64    0.28       0.56      0.56       0.96
#> 196            2.63            2.63    0.27       0.54      0.54       0.79
#> 197            2.61            2.61    0.23       0.55      0.66       1.42
#> 198            2.60            2.60    0.22       0.55      0.74       1.80
#> 199            2.59            2.59    0.20       0.55      0.55       0.24
#> 200            2.56            2.56    0.15       0.58      0.58       0.30
#> 201            2.54            2.54    0.13       0.55      0.55       0.88
#> 202            2.53            2.53    0.11       0.54      0.54       0.38
#> 203            2.53            2.53    0.10       0.55      0.55       0.90
#> 204            2.52            2.52    0.10       0.54      0.54       0.28
#> 205            2.49            2.49    0.05       0.54      0.71       1.74
#> 206            2.48            2.48    0.03       0.56      0.59       1.11
#> 207            2.46            2.46    0.00       0.55      0.55       0.84
#> 208            2.46            2.46   -0.01       0.54      0.54       0.54
#> 209            2.46            2.46   -0.01       0.54      0.61       1.27
#> 210            2.45            2.45   -0.02       0.55      0.77       1.95
#> 211            2.45            2.45   -0.02       0.54      0.54       0.90
#> 212            2.45            2.45   -0.03       0.55      0.55       0.65
#> 213            2.45            2.45   -0.03       0.54      0.68       1.60
#> 214            2.44            2.44   -0.04       0.54      0.58       1.11
#> 215            2.44            2.44   -0.04       0.54      0.54       0.84
#> 216            2.43            2.43   -0.05       0.55      0.65       1.40
#> 217            2.42            2.42   -0.07       0.55      0.61       1.25
#> 218            2.42            2.42   -0.07       0.54      0.69       1.63
#> 219            2.42            2.42   -0.07       0.55      0.56       1.02
#> 220            2.41            2.41   -0.09       0.55      0.55       0.39
#> 221            2.40            2.40   -0.10       0.54      0.58       1.15
#> 222            2.40            2.40   -0.10       0.55      0.55       0.38
#> 223            2.40            2.40   -0.10       0.54      0.54       0.48
#> 224            2.40            2.40   -0.10       0.58      0.63       1.19
#> 225            2.39            2.39   -0.11       0.54      0.54       0.45
#> 226            2.35            2.35   -0.18       0.58      0.58       0.83
#> 227            2.35            2.35   -0.19       0.58      0.58       0.46
#> 228            2.31            2.31   -0.25       0.55      0.55       0.92
#> 229            2.30            2.30   -0.26       0.57      0.72       1.59
#> 230            2.28            2.28   -0.30       0.54      0.71       1.68
#> 231            2.28            2.28   -0.30       0.55      0.82       2.26
#> 232            2.28            2.28   -0.30       0.55      0.55       0.96
#> 233            2.28            2.28   -0.30       0.55      0.55       0.24
#> 234            2.28            2.28   -0.30       0.55      0.55       0.34
#> 235            2.27            2.27   -0.31       0.54      0.56       1.08
#> 236            2.27            2.27   -0.31       0.54      0.55       1.05
#> 237            2.27            2.27   -0.32       0.55      0.65       1.40
#> 238            2.26            2.26   -0.32       0.55      0.68       1.51
#> 239            2.26            2.26   -0.33       0.54      0.54       0.82
#> 240            2.26            2.26   -0.33       0.54      0.78       2.07
#> 241            2.26            2.26   -0.34       0.54      0.59       1.16
#> 242            2.25            2.25   -0.35       0.56      0.72       1.67
#> 243            2.24            2.24   -0.37       0.56      0.70       1.58
#> 244            2.23            2.23   -0.39       0.57      0.57       0.40
#> 245            2.22            2.22   -0.39       0.55      0.55       0.45
#> 246            2.22            2.22   -0.39       0.54      0.54       0.35
#> 247            2.20            2.20   -0.43       0.56      0.58       1.06
#> 248            2.18            2.18   -0.47       0.60      0.60       0.71
#> 249            2.18            2.18   -0.47       0.60      0.66       1.18
#> 250            2.18            2.18   -0.47       0.54      0.54       0.19
#> 251            2.17            2.17   -0.49       0.54      0.54       0.48
#> 252            2.15            2.15   -0.51       0.56      0.65       1.35
#> 253            2.15            2.15   -0.52       0.59      0.87       2.16
#> 254            2.15            2.15   -0.52       0.59      0.59       0.66
#> 255            2.15            2.15   -0.52       0.55      0.55       0.35
#> 256            2.14            2.14   -0.53       0.59      0.59       0.46
#> 257            2.14            2.14   -0.54       0.57      0.64       1.26
#> 258            2.12            2.12   -0.56       0.57      0.57       0.41
#> 259            2.12            2.12   -0.56       0.57      0.57       0.53
#> 260            2.12            2.12   -0.57       0.65      0.67       1.04
#> 261            2.10            2.10   -0.61       0.55      0.55       0.65
#> 262            2.09            2.09   -0.61       0.54      0.61       1.25
#> 263            2.09            2.09   -0.62       0.56      0.56       0.56
#> 264            2.09            2.09   -0.62       0.56      0.56       0.56
#> 265            2.09            2.09   -0.62       0.56      0.56       0.96
#> 266            2.09            2.09   -0.62       0.55      0.61       1.20
#> 267            2.09            2.09   -0.63       0.55      0.55       0.58
#> 268            2.07            2.07   -0.67       0.54      0.54       0.77
#> 269            2.06            2.06   -0.68       0.54      0.54       0.54
#> 270            2.05            2.05   -0.69       0.55      0.68       1.54
#> 271            2.04            2.04   -0.71       0.55      0.55       1.00
#> 272            1.97            1.97   -0.83       0.64      0.80       1.55
#> 273            1.95            1.95   -0.87       0.54      0.54       0.30
#> 274            1.95            1.95   -0.87       0.61      0.90       2.19
#> 275            1.93            1.93   -0.91       0.62      0.62       0.55
#> 276            1.93            1.93   -0.92       0.56      0.56       0.33
#> 277            1.93            1.93   -0.92       0.56      0.84       2.20
#> 278            1.92            1.92   -0.94       0.57      0.57       0.64
#> 279            1.92            1.92   -0.94       0.57      0.67       1.34
#> 280            1.92            1.92   -0.94       0.56      0.56       1.00
#> 281            1.92            1.92   -0.94       0.54      0.54       0.82
#> 282            1.91            1.91   -0.96       0.56      0.56       0.34
#> 283            1.90            1.90   -0.97       0.54      0.54       0.21
#> 284            1.87            1.87   -1.04       0.60      0.73       1.46
#> 285            1.79            1.79   -1.20       0.56      0.56       0.80
#> 286            1.76            1.76   -1.25       0.58      0.58       0.83
#> 287            1.76            1.76   -1.26       0.63      0.69       1.18
#> 288            1.75            1.75   -1.28       0.60      0.96       2.57
#> 289            1.75            1.75   -1.28       0.64      0.64       0.43
#> 290            1.75            1.75   -1.29       0.58      0.58       0.17
#> 291            1.74            1.74   -1.29       0.71      0.71       0.80
#> 292            1.72            1.72   -1.33       0.64      0.64       0.70
#> 293            1.72            1.72   -1.34       0.55      0.55       0.25
#> 294            1.66            1.66   -1.47       0.71      0.71       0.06
#> 295            1.65            1.65   -1.50       0.61      0.61       0.80
#> 296            1.64            1.64   -1.51       0.72      0.72       0.39
#> 297            1.64            1.64   -1.51       0.72      0.72       0.39
#> 298            1.63            1.63   -1.54       0.75      1.24       2.74
#> 299            1.62            1.62   -1.57       0.57      0.59       1.07
#> 300            1.61            1.61   -1.59       0.57      0.58       1.01
#> 301            1.61            1.61   -1.60       0.61      0.61       0.13
#> 302            1.54            1.54   -1.78       0.72      0.72       0.80
#> 303            1.48            1.48   -1.92       0.60      0.60       0.85
#> 304            1.40            1.40   -2.19       0.70      1.13       2.60
#> 305            1.36            1.36   -2.30       0.82      0.82       0.88
#> 306            1.34            1.34   -2.38       0.84      0.84       0.48
#> 307            1.30            1.30   -2.52       1.12      1.12       0.34
#> 308            1.71            1.37    2.29       0.18      0.20       1.25
#> 309            2.27            1.77    1.24       0.14      0.15       1.19
#> 310            2.63            2.06    0.67       0.16      0.16       0.85
#> 311            2.74            2.16    0.50       0.21      0.21       0.93
#> 312            2.86            2.27    0.31       0.11      0.11       0.92
#> 313            2.86            2.27    0.31       0.17      0.18       1.19
#> 314            2.89            2.30    0.26       0.12      0.12       1.04
#> 315            2.95            2.36    0.16       0.15      0.15       1.02
#> 316            3.07            2.48   -0.03       0.26      0.26       0.82
#> 317            3.07            2.49   -0.05       0.17      0.19       1.15
#> 318            3.22            2.66   -0.30       0.13      0.13       0.99
#> 319            3.28            2.73   -0.42       0.14      0.15       1.11
#> 320            3.30            2.75   -0.45       0.12      0.12       0.90
#> 321            3.37            2.84   -0.60       0.35      0.35       0.41
#> 322            3.47            2.99   -0.84       0.26      0.26       1.01
#> 323            3.53            3.08   -0.99       0.14      0.16       1.15
#> 324            3.54            3.09   -1.01       0.11      0.11       0.83
#> 325            3.55            3.11   -1.04       0.15      0.15       0.90
#> 326            2.71            2.13    0.55       0.06      0.06       1.01
#> 327            2.76            2.18    0.47       0.06      0.06       0.99
#> 328            3.54            3.10   -1.02       0.07      0.07       0.99
#>     Infit ZStd Outfit MnSq Outfit ZStd PtMea Corr Anch  Status
#> 1           NA          NA          NA         NA      Maximum
#> 2           NA          NA          NA         NA      Maximum
#> 3           NA          NA          NA         NA      Maximum
#> 4           NA          NA          NA         NA      Maximum
#> 5           NA          NA          NA         NA      Maximum
#> 6           NA          NA          NA         NA      Maximum
#> 7           NA        0.28       -1.60         NA             
#> 8           NA        0.43       -1.08         NA             
#> 9           NA        0.56       -0.73         NA             
#> 10          NA        2.61        2.15         NA             
#> 11          NA        1.71        1.21         NA             
#> 12          NA        0.60       -0.63         NA             
#> 13          NA        2.35        1.91         NA             
#> 14          NA        0.46       -0.99         NA             
#> 15          NA        1.06        0.30         NA             
#> 16          NA        0.36       -1.30         NA             
#> 17          NA        0.38       -1.24         NA             
#> 18          NA        0.70       -0.38         NA             
#> 19       -0.08        0.48       -0.93         NA             
#> 20          NA        0.65       -0.51         NA             
#> 21       -0.04        0.50       -0.88         NA             
#> 22        0.13        0.84       -0.10         NA             
#> 23          NA        0.91        0.04         NA             
#> 24        0.44        0.93        0.08         NA             
#> 25        0.61        1.37        0.77         NA             
#> 26          NA        0.47       -0.96         NA             
#> 27          NA        0.43       -1.09         NA             
#> 28        0.33        0.95        0.11         NA             
#> 29        0.09        0.63       -0.56         NA             
#> 30          NA        0.50       -0.88         NA             
#> 31        0.54        0.91        0.03         NA             
#> 32        0.48        1.44        0.86         NA             
#> 33        0.09        0.81       -0.16         NA             
#> 34        0.23        0.94        0.09         NA             
#> 35       -0.44        0.29       -1.56         NA             
#> 36        0.83        1.08        0.33         NA             
#> 37       -0.42        0.30       -1.53         NA             
#> 38        0.34        0.98        0.16         NA             
#> 39          NA        0.60       -0.61         NA             
#> 40       -0.14        0.79       -0.20         NA             
#> 41        0.23        0.64       -0.53         NA             
#> 42        0.24        0.85       -0.08         NA             
#> 43        1.39        1.89        1.43         NA             
#> 44        0.71        0.85       -0.08         NA             
#> 45        0.19        0.81       -0.15         NA             
#> 46        0.78        0.93        0.07         NA             
#> 47          NA        0.59       -0.64         NA             
#> 48        0.52        0.97        0.14         NA             
#> 49        0.37        2.93        2.43         NA             
#> 50        0.55        0.92        0.04         NA             
#> 51       -0.36        0.49       -0.91         NA             
#> 52        0.76        1.23        0.56         NA             
#> 53       -0.41        0.40       -1.18         NA             
#> 54        0.73        2.06        1.61         NA             
#> 55       -0.53        0.25       -1.71         NA             
#> 56        0.06        1.00        0.19         NA             
#> 57        0.07        0.65       -0.49         NA             
#> 58       -0.25        0.58       -0.66         NA             
#> 59        0.20        1.04        0.26         NA             
#> 60       -0.19        0.43       -1.09         NA             
#> 61        0.77        1.40        0.81         NA             
#> 62        0.24        1.58        1.05         NA             
#> 63       -0.36        0.66       -0.49         NA             
#> 64        0.03        0.72       -0.34         NA             
#> 65        0.38        0.97        0.13         NA             
#> 66        0.08        0.73       -0.32         NA             
#> 67        0.27        1.20        0.52         NA             
#> 68        1.16        1.97        1.51         NA             
#> 69        0.31        2.23        1.79         NA             
#> 70        0.06        0.73       -0.33         NA             
#> 71        0.48        1.44        0.87         NA             
#> 72        0.28        1.25        0.59         NA             
#> 73       -0.33        0.49       -0.90         NA             
#> 74        0.06        0.87       -0.04         NA             
#> 75       -0.09        0.50       -0.87         NA             
#> 76       -0.07        0.51       -0.85         NA             
#> 77       -0.98        0.30       -1.52         NA             
#> 78        0.65        1.12        0.39         NA             
#> 79        0.59        1.50        0.95         NA             
#> 80        0.26        0.84       -0.11         NA             
#> 81        0.39        0.84       -0.10         NA             
#> 82       -0.63        0.32       -1.46         NA             
#> 83       -0.54        0.35       -1.34         NA             
#> 84        1.53        1.83        1.36         NA             
#> 85        0.76        1.37        0.76         NA             
#> 86       -0.22        0.65       -0.50         NA             
#> 87       -0.24        0.55       -0.76         NA             
#> 88       -0.21        1.51        0.96         NA             
#> 89       -0.16        0.72       -0.35         NA             
#> 90       -0.16        0.64       -0.52         NA             
#> 91       -0.04        0.50       -0.87         NA             
#> 92        1.00        1.50        0.95         NA             
#> 93       -0.29        0.75       -0.28         NA             
#> 94        1.16        1.79        1.30         NA             
#> 95        1.71        4.26        3.42         NA             
#> 96        0.80        1.46        0.89         NA             
#> 97        0.24        0.93        0.08         NA             
#> 98       -0.15        0.60       -0.63         NA             
#> 99        1.51        2.21        1.77         NA             
#> 100       0.16        0.87       -0.04         NA             
#> 101      -1.00        0.39       -1.21         NA             
#> 102       0.43        0.88       -0.02         NA             
#> 103      -0.36        0.49       -0.91         NA             
#> 104      -0.14        1.43        0.85         NA             
#> 105      -0.26        0.74       -0.30         NA             
#> 106       0.45        0.87       -0.05         NA             
#> 107      -0.33        0.49       -0.91         NA             
#> 108       0.50        1.01        0.21         NA             
#> 109       0.73        1.31        0.68         NA             
#> 110       0.98        1.66        1.14         NA             
#> 111       0.93        1.57        1.04         NA             
#> 112       1.07        1.61        1.08         NA             
#> 113       0.42        1.07        0.30         NA             
#> 114       0.95        1.69        1.18         NA             
#> 115       0.15        0.84       -0.10         NA             
#> 116       0.48        1.18        0.49         NA             
#> 117       0.29        0.86       -0.06         NA             
#> 118       0.26        0.84       -0.11         NA             
#> 119       0.58        1.34        0.72         NA             
#> 120       0.18        0.85       -0.07         NA             
#> 121      -2.28        0.06       -2.94         NA             
#> 122      -0.12        0.65       -0.49         NA             
#> 123       1.25        2.30        1.85         NA             
#> 124      -0.68        0.30       -1.51         NA             
#> 125       0.49        0.94        0.08         NA             
#> 126       1.11        1.77        1.28         NA             
#> 127       0.35        1.25        0.60         NA             
#> 128       0.35        1.05        0.27         NA             
#> 129       1.33        2.32        1.87         NA             
#> 130      -1.08        0.25       -1.73         NA             
#> 131       0.57        1.04        0.26         NA             
#> 132      -0.90        0.37       -1.27         NA             
#> 133      -0.31        0.51       -0.86         NA             
#> 134       0.93        1.46        0.89         NA             
#> 135       1.04        1.43        0.85         NA             
#> 136      -0.75        0.35       -1.34         NA             
#> 137      -0.45        0.90        0.00         NA             
#> 138       0.45        1.01        0.21         NA             
#> 139      -0.37        0.52       -0.83         NA             
#> 140       0.71        1.70        1.20         NA             
#> 141       0.82        1.31        0.67         NA             
#> 142       0.07        0.77       -0.24         NA             
#> 143      -0.41        0.85       -0.08         NA             
#> 144       0.88        1.35        0.74         NA             
#> 145       1.36        1.93        1.46         NA             
#> 146       1.20        2.31        1.87         NA             
#> 147      -1.30        0.24       -1.77         NA             
#> 148      -0.12        0.76       -0.27         NA             
#> 149      -0.12        1.04        0.25         NA             
#> 150       0.01        0.76       -0.26         NA             
#> 151      -0.73        0.44       -1.05         NA             
#> 152       1.25        1.84        1.37         NA             
#> 153       0.73        1.33        0.71         NA             
#> 154      -0.54        0.53       -0.80         NA             
#> 155       1.17        1.83        1.35         NA             
#> 156       1.32        2.10        1.65         NA             
#> 157      -0.54        0.46       -0.99         NA             
#> 158      -0.90        0.33       -1.43         NA             
#> 159       0.36        1.32        0.69         NA             
#> 160       0.34        1.56        1.02         NA             
#> 161       1.07        1.73        1.24         NA             
#> 162       0.75        1.39        0.80         NA             
#> 163      -0.84        0.35       -1.35         NA             
#> 164      -0.78        0.36       -1.30         NA             
#> 165       0.71        1.20        0.52         NA             
#> 166      -0.48        0.55       -0.75         NA             
#> 167       0.31        0.95        0.10         NA             
#> 168       0.05        0.71       -0.36         NA             
#> 169      -0.67        0.48       -0.94         NA             
#> 170       0.00        0.68       -0.44         NA             
#> 171       0.56        1.26        0.62         NA             
#> 172       0.06        0.92        0.05         NA             
#> 173       0.43        1.06        0.29         NA             
#> 174       0.45        1.22        0.55         NA             
#> 175      -0.09        0.68       -0.44         NA             
#> 176       0.45        1.21        0.53         NA             
#> 177      -0.09        0.72       -0.34         NA             
#> 178       1.08        1.82        1.34         NA             
#> 179       0.99        1.67        1.16         NA             
#> 180      -1.04        0.32       -1.45         NA             
#> 181       1.91        2.94        2.44         NA             
#> 182      -0.12        0.74       -0.31         NA             
#> 183       0.51        1.15        0.44         NA             
#> 184       0.78        1.47        0.91         NA             
#> 185      -0.14        0.82       -0.14         NA             
#> 186      -0.42        0.56       -0.72         NA             
#> 187      -2.94        0.01       -4.05         NA             
#> 188       0.69        1.38        0.78         NA             
#> 189       0.05        0.86       -0.06         NA             
#> 190       0.36        0.93        0.06         NA             
#> 191       0.04        0.90        0.02         NA             
#> 192      -0.46        0.55       -0.74         NA             
#> 193       0.07        0.87       -0.04         NA             
#> 194       0.86        1.41        0.82         NA             
#> 195       0.21        0.91        0.03         NA             
#> 196      -0.04        0.80       -0.17         NA             
#> 197       0.74        2.01        1.55         NA             
#> 198       1.09        1.72        1.23         NA             
#> 199      -1.18        0.27       -1.66         NA             
#> 200      -0.95        0.35       -1.33         NA             
#> 201       0.10        0.83       -0.13         NA             
#> 202      -0.85        0.37       -1.27         NA             
#> 203       0.13        0.86       -0.06         NA             
#> 204      -1.12        0.29       -1.55         NA             
#> 205       1.05        1.78        1.29         NA             
#> 206       0.40        1.04        0.26         NA             
#> 207       0.04        0.83       -0.11         NA             
#> 208      -0.48        0.53       -0.80         NA             
#> 209       0.58        1.28        0.65         NA             
#> 210       1.22        1.84        1.37         NA             
#> 211       0.11        0.95        0.10         NA             
#> 212      -0.26        0.64       -0.52         NA             
#> 213       0.92        1.59        1.06         NA             
#> 214       0.40        1.08        0.32         NA             
#> 215       0.03        0.89        0.00         NA             
#> 216       0.71        1.43        0.85         NA             
#> 217       0.55        1.19        0.51         NA             
#> 218       0.94        1.63        1.11         NA             
#> 219       0.29        0.99        0.17         NA             
#> 220      -0.77        0.44       -1.06         NA             
#> 221       0.44        1.17        0.48         NA             
#> 222      -0.81        0.42       -1.11         NA             
#> 223      -0.59        0.50       -0.87         NA             
#> 224       0.50        1.14        0.42         NA             
#> 225      -0.65        0.48       -0.95         NA             
#> 226       0.05        0.83       -0.13         NA             
#> 227      -0.56        0.50       -0.89         NA             
#> 228       0.16        0.85       -0.08         NA             
#> 229       0.89        1.37        0.77         NA             
#> 230       0.99        1.63        1.11         NA             
#> 231       1.47        2.16        1.71         NA             
#> 232       0.21        0.92        0.05         NA             
#> 233      -1.19        0.24       -1.76         NA             
#> 234      -0.91        0.34       -1.38         NA             
#> 235       0.36        1.08        0.34         NA             
#> 236       0.32        1.05        0.28         NA             
#> 237       0.72        1.27        0.62         NA             
#> 238       0.83        1.52        0.97         NA             
#> 239      -0.01        0.81       -0.16         NA             
#> 240       1.33        1.95        1.49         NA             
#> 241       0.46        1.16        0.46         NA             
#> 242       0.97        1.65        1.14         NA             
#> 243       0.89        1.64        1.12         NA             
#> 244      -0.72        0.41       -1.13         NA             
#> 245      -0.64        0.48       -0.92         NA             
#> 246      -0.90        0.36       -1.31         NA             
#> 247       0.33        1.03        0.24         NA             
#> 248      -0.10        0.69       -0.42         NA             
#> 249       0.49        1.21        0.53         NA             
#> 250      -1.41        0.18       -2.05         NA             
#> 251      -0.59        0.50       -0.89         NA             
#> 252       0.67        1.25        0.60         NA             
#> 253       1.33        2.01        1.55         NA             
#> 254      -0.18        0.64       -0.53         NA             
#> 255      -0.87        0.33       -1.41         NA             
#> 256      -0.53        0.54       -0.77         NA             
#> 257       0.56        1.19        0.50         NA             
#> 258      -0.70        0.41       -1.15         NA             
#> 259      -0.45        0.55       -0.74         NA             
#> 260       0.35        0.79       -0.21         NA             
#> 261      -0.25        0.67       -0.45         NA             
#> 262       0.56        1.25        0.59         NA             
#> 263      -0.42        0.58       -0.68         NA             
#> 264      -0.41        0.55       -0.74         NA             
#> 265       0.21        0.99        0.18         NA             
#> 266       0.50        1.17        0.47         NA             
#> 267      -0.37        0.60       -0.63         NA             
#> 268      -0.07        0.76       -0.27         NA             
#> 269      -0.48        0.54       -0.76         NA             
#> 270       0.86        1.44        0.86         NA             
#> 271       0.27        0.97        0.14         NA             
#> 272       0.82        1.60        1.07         NA             
#> 273      -1.07        0.29       -1.55         NA             
#> 274       1.33        1.79        1.31         NA             
#> 275      -0.33        0.70       -0.40         NA             
#> 276      -0.90        0.36       -1.32         NA             
#> 277       1.40        2.00        1.54         NA             
#> 278      -0.24        0.68       -0.42         NA             
#> 279       0.65        1.21        0.53         NA             
#> 280       0.26        0.97        0.14         NA             
#> 281       0.00        0.82       -0.14         NA             
#> 282      -0.86        0.38       -1.25         NA             
#> 283      -1.35        0.21       -1.93         NA             
#> 284       0.76        1.91        1.44         NA             
#> 285      -0.02        0.78       -0.21         NA             
#> 286       0.06        0.83       -0.12         NA             
#> 287       0.49        1.09        0.34         NA             
#> 288       1.59        2.67        2.21         NA             
#> 289      -0.52        0.53       -0.80         NA             
#> 290      -1.34        0.25       -1.74         NA             
#> 291       0.12        1.05        0.27         NA             
#> 292      -0.07        0.69       -0.41         NA             
#> 293      -1.16        0.27       -1.63         NA             
#> 294      -1.47        0.09       -2.70         NA             
#> 295       0.03        0.76       -0.25         NA             
#> 296      -0.46        0.38       -1.23         NA             
#> 297      -0.46        0.38       -1.23         NA             
#> 298       1.48        1.92        1.46         NA             
#> 299       0.35        1.25        0.59         NA             
#> 300       0.28        1.05        0.28         NA             
#> 301      -1.43        0.18       -2.09         NA             
#> 302       0.13        1.41        0.82         NA             
#> 303       0.09        0.79       -0.20         NA             
#> 304       1.46        3.18        2.64         NA             
#> 305       0.28        1.00        0.20         NA             
#> 306      -0.16        0.46       -1.00         NA             
#> 307         NA        0.17       -2.10         NA             
#> 308       1.02        1.16        0.97       0.68             
#> 309       1.01        1.11        0.92       0.68             
#> 310      -0.61        0.87       -0.78       0.68             
#> 311      -0.16        0.87       -0.59       0.68             
#> 312      -0.53        0.92       -0.77       0.68             
#> 313       0.81        1.15        0.97       0.68             
#> 314       0.28        0.98       -0.17       0.68             
#> 315       0.17        1.00        0.04       0.68             
#> 316      -0.38        0.69       -1.34       0.68             
#> 317       0.67        1.25        1.41       0.68             
#> 318       0.03        0.93       -0.53       0.68             
#> 319       0.57        1.11        0.83       0.68             
#> 320      -0.61        0.92       -0.71       0.68             
#> 321      -1.39        0.43       -1.87       0.68             
#> 322       0.15        1.04        0.27       0.68             
#> 323       0.74        1.12        0.95       0.68             
#> 324      -1.11        0.78       -2.52       0.68             
#> 325      -0.40        0.89       -0.75       0.68             
#> 326       0.11        0.97       -0.55       0.42             
#> 327      -0.09        0.98       -0.35       0.42             
#> 328      -0.08        0.97       -0.58       0.42             
#>                    Element ObservedAverage AdjustedAverage
#> 1                     P018            4.00            4.00
#> 2                     P239            4.00            4.00
#> 3                     P209            4.00            4.00
#> 4                     P188            4.00            4.00
#> 5                     P007            4.00            4.00
#> 6                     P057            4.00            4.00
#> 7                     P157            3.83            3.97
#> 8                     P135            3.83            3.94
#> 9                     P237            3.83            3.89
#> 10                    P295            3.83            3.88
#> 11                    P259            3.83            3.88
#> 12                    P116            3.83            3.87
#> 13                    P010            3.83            3.87
#> 14                    P204            3.83            3.86
#> 15                    P144            3.83            3.86
#> 16                    P208            3.83            3.84
#> 17                    P049            3.83            3.84
#> 18                    P161            3.83            3.80
#> 19                    P290            3.67            3.80
#> 20                    P176            3.83            3.79
#> 21                    P278            3.67            3.78
#> 22                    P047            3.50            3.77
#> 23                    P108            3.83            3.77
#> 24                    P206            3.17            3.76
#> 25                    P299            3.17            3.76
#> 26                    P127            3.83            3.76
#> 27                    P156            3.83            3.76
#> 28                    P280            3.50            3.74
#> 29                    P287            3.67            3.74
#> 30                    P149            3.83            3.73
#> 31                    P257            3.50            3.73
#> 32                    P008            3.67            3.72
#> 33                    P097            3.33            3.71
#> 34                    P128            3.67            3.71
#> 35                    P175            3.67            3.71
#> 36                    P248            3.67            3.71
#> 37                    P118            3.67            3.70
#> 38                    P096            3.00            3.69
#> 39                    P084            3.83            3.68
#> 40                    P289            3.17            3.67
#> 41                    P013            3.17            3.67
#> 42                    P189            3.00            3.67
#> 43                    P117            3.00            3.67
#> 44                    P019            3.67            3.66
#> 45                    P225            3.67            3.66
#> 46                    P162            3.67            3.65
#> 47                    P198            3.83            3.65
#> 48                    P275            3.50            3.63
#> 49                    P002            3.67            3.63
#> 50                    P154            3.50            3.63
#> 51                    P155            3.33            3.61
#> 52                    P078            3.50            3.61
#> 53                    P191            3.50            3.60
#> 54                    P036            3.50            3.59
#> 55                    P105            3.67            3.58
#> 56                    P273            3.50            3.58
#> 57                    P291            3.67            3.58
#> 58                    P081            3.17            3.58
#> 59                    P134            3.67            3.57
#> 60                    P300            3.50            3.56
#> 61                    P304            3.50            3.55
#> 62                    P183            3.50            3.54
#> 63                    P146            3.50            3.54
#> 64                    P265            3.33            3.53
#> 65                    P126            3.33            3.53
#> 66                    P253            3.33            3.52
#> 67                    P197            3.67            3.52
#> 68                    P247            3.67            3.52
#> 69                    P241            3.67            3.52
#> 70                    P120            3.33            3.51
#> 71                    P171            3.67            3.49
#> 72                    P031            3.67            3.49
#> 73                    P140            3.33            3.47
#> 74                    P246            2.67            3.46
#> 75                    P255            3.50            3.46
#> 76                    P125            3.50            3.45
#> 77                    P046            3.17            3.43
#> 78                    P172            3.50            3.43
#> 79                    P168            3.33            3.38
#> 80                    P260            3.17            3.38
#> 81                    P040            3.17            3.38
#> 82                    P082            3.50            3.37
#> 83                    P222            3.50            3.37
#> 84                    P199            3.50            3.37
#> 85                    P101            3.17            3.36
#> 86                    P139            3.33            3.36
#> 87                    P079            3.33            3.36
#> 88                    P073            3.50            3.36
#> 89                    P166            2.33            3.36
#> 90                    P233            3.33            3.36
#> 91                    P023            3.67            3.35
#> 92                    P014            3.67            3.34
#> 93                    P067            3.17            3.34
#> 94                    P235            3.33            3.33
#> 95                    P098            3.17            3.30
#> 96                    P095            2.83            3.30
#> 97                    P028            3.00            3.30
#> 98                    P153            3.33            3.28
#> 99                    P211            3.17            3.28
#> 100                   P160            3.17            3.28
#> 101                   P062            3.00            3.28
#> 102                   P006            3.33            3.27
#> 103                   P178            3.33            3.26
#> 104                   P092            3.33            3.26
#> 105                   P217            3.50            3.25
#> 106                   P185            3.50            3.25
#> 107                   P269            3.33            3.25
#> 108                   P003            2.67            3.25
#> 109                   P270            3.50            3.25
#> 110                   P234            3.17            3.22
#> 111                   P131            3.33            3.21
#> 112                   P216            3.00            3.20
#> 113                   P110            2.33            3.20
#> 114                   P093            3.17            3.20
#> 115                   P015            3.17            3.19
#> 116                   P068            3.17            3.19
#> 117                   P294            3.00            3.18
#> 118                   P201            3.00            3.18
#> 119                   P077            3.17            3.18
#> 120                   P218            2.50            3.17
#> 121                   P203            2.83            3.16
#> 122                   P251            2.67            3.16
#> 123                   P038            3.17            3.15
#> 124                   P114            3.50            3.13
#> 125                   P274            3.50            3.13
#> 126                   P012            2.67            3.11
#> 127                   P094            3.17            3.10
#> 128                   P099            2.83            3.09
#> 129                   P052            3.17            3.09
#> 130                   P076            3.17            3.08
#> 131                   P254            3.50            3.08
#> 132                   P025            3.00            3.08
#> 133                   P137            3.33            3.06
#> 134                   P169            3.17            3.06
#> 135                   P276            3.17            3.06
#> 136                   P001            3.17            3.06
#> 137                   P223            3.33            3.06
#> 138                   P042            3.33            3.05
#> 139                   P293            3.17            3.04
#> 140                   P147            2.17            3.02
#> 141                   P158            3.33            3.02
#> 142                   P033            3.33            3.01
#> 143                   P264            3.33            3.01
#> 144                   P186            3.33            3.01
#> 145                   P306            3.00            3.01
#> 146                   P143            3.17            3.01
#> 147                   P086            2.83            3.00
#> 148                   P053            3.00            3.00
#> 149                   P258            3.17            3.00
#> 150                   P064            3.00            2.99
#> 151                   P103            2.83            2.99
#> 152                   P138            2.50            2.98
#> 153                   P229            2.67            2.97
#> 154                   P066            2.83            2.95
#> 155                   P224            2.50            2.94
#> 156                   P282            3.17            2.93
#> 157                   P277            3.17            2.93
#> 158                   P190            2.67            2.93
#> 159                   P071            3.17            2.93
#> 160                   P165            2.17            2.89
#> 161                   P238            2.17            2.89
#> 162                   P214            2.67            2.88
#> 163                   P215            3.00            2.86
#> 164                   P016            3.00            2.85
#> 165                   P122            3.17            2.85
#> 166                   P074            2.33            2.84
#> 167                   P236            3.00            2.84
#> 168                   P302            3.33            2.83
#> 169                   P043            3.00            2.82
#> 170                   P232            3.33            2.82
#> 171                   P109            3.33            2.82
#> 172                   P263            2.67            2.81
#> 173                   P130            3.00            2.81
#> 174                   P050            3.17            2.81
#> 175                   P284            3.17            2.80
#> 176                   P174            3.17            2.80
#> 177                   P121            2.33            2.80
#> 178                   P243            2.33            2.80
#> 179                   P221            3.17            2.78
#> 180                   P200            3.00            2.77
#> 181                   P141            2.67            2.76
#> 182                   P213            2.50            2.76
#> 183                   P037            2.33            2.75
#> 184                   P111            3.00            2.74
#> 185                   P163            3.17            2.74
#> 186                   P207            2.33            2.68
#> 187                   P020            2.33            2.68
#> 188                   P029            2.50            2.68
#> 189                   P249            2.50            2.68
#> 190                   P245            2.00            2.67
#> 191                   P297            2.17            2.66
#> 192                   P182            2.67            2.64
#> 193                   P220            2.67            2.64
#> 194                   P034            3.00            2.64
#> 195                   P279            3.00            2.64
#> 196                   P060            2.67            2.63
#> 197                   P083            2.83            2.61
#> 198                   P285            3.00            2.60
#> 199                   P272            3.00            2.59
#> 200                   P170            2.50            2.56
#> 201                   P080            3.00            2.54
#> 202                   P148            2.67            2.53
#> 203                   P292            2.83            2.53
#> 204                   P261            2.67            2.52
#> 205                   P271            2.33            2.49
#> 206                   P009            2.17            2.48
#> 207                   P210            2.67            2.46
#> 208                   P129            2.50            2.46
#> 209                   P286            2.50            2.46
#> 210                   P283            2.67            2.45
#> 211                   P061            2.67            2.45
#> 212                   P119            2.67            2.45
#> 213                   P187            2.50            2.45
#> 214                   P180            2.83            2.44
#> 215                   P011            2.50            2.44
#> 216                   P152            2.17            2.43
#> 217                   P202            2.33            2.42
#> 218                   P301            2.83            2.42
#> 219                   P268            2.17            2.42
#> 220                   P035            3.00            2.41
#> 221                   P305            2.50            2.40
#> 222                   P090            3.00            2.40
#> 223                   P133            2.83            2.40
#> 224                   P024            2.00            2.40
#> 225                   P106            2.83            2.39
#> 226                   P087            2.00            2.35
#> 227                   P195            2.33            2.35
#> 228                   P151            2.17            2.31
#> 229                   P100            2.00            2.30
#> 230                   P212            2.33            2.28
#> 231                   P142            2.50            2.28
#> 232                   P091            2.50            2.28
#> 233                   P177            2.50            2.28
#> 234                   P167            2.50            2.28
#> 235                   P051            2.33            2.27
#> 236                   P065            2.67            2.27
#> 237                   P041            2.50            2.27
#> 238                   P044            2.17            2.26
#> 239                   P072            2.50            2.26
#> 240                   P022            2.67            2.26
#> 241                   P107            2.33            2.26
#> 242                   P069            2.33            2.25
#> 243                   P150            2.17            2.24
#> 244                   P227            2.00            2.23
#> 245                   P307            2.33            2.22
#> 246                   P281            2.83            2.22
#> 247                   P059            2.17            2.20
#> 248                   P303            1.83            2.18
#> 249                   P179            1.83            2.18
#> 250                   P017            2.50            2.18
#> 251                   P244            2.33            2.17
#> 252                   P021            2.17            2.15
#> 253                   P262            2.17            2.15
#> 254                   P288            2.17            2.15
#> 255                   P250            2.33            2.15
#> 256                   P026            2.17            2.14
#> 257                   P252            2.00            2.14
#> 258                   P242            2.00            2.12
#> 259                   P266            2.00            2.12
#> 260                   P226            1.83            2.12
#> 261                   P054            2.17            2.10
#> 262                   P070            2.33            2.09
#> 263                   P115            2.17            2.09
#> 264                   P164            2.17            2.09
#> 265                   P063            2.17            2.09
#> 266                   P228            2.33            2.09
#> 267                   P267            2.33            2.09
#> 268                   P192            2.50            2.07
#> 269                   P030            2.50            2.06
#> 270                   P184            2.33            2.05
#> 271                   P230            2.17            2.04
#> 272                   P256            1.67            1.97
#> 273                   P058            2.50            1.95
#> 274                   P055            2.00            1.95
#> 275                   P005            1.83            1.93
#> 276                   P039            2.17            1.93
#> 277                   P104            2.17            1.93
#> 278                   P032            2.00            1.92
#> 279                   P296            2.00            1.92
#> 280                   P145            2.17            1.92
#> 281                   P027            2.50            1.92
#> 282                   P132            2.17            1.91
#> 283                   P085            2.50            1.90
#> 284                   P124            1.83            1.87
#> 285                   P123            2.17            1.79
#> 286                   P088            2.00            1.76
#> 287                   P231            1.83            1.76
#> 288                   P219            1.83            1.75
#> 289                   P075            1.67            1.75
#> 290                   P102            2.00            1.75
#> 291                   P181            1.50            1.74
#> 292                   P298            1.67            1.72
#> 293                   P194            2.17            1.72
#> 294                   P056            1.67            1.66
#> 295                   P240            1.83            1.65
#> 296                   P193            1.50            1.64
#> 297                   P112            1.50            1.64
#> 298                   P196            1.50            1.63
#> 299                   P004            2.00            1.62
#> 300                   P045            2.00            1.61
#> 301                   P113            1.83            1.61
#> 302                   P205            1.50            1.54
#> 303                   P089            1.83            1.48
#> 304                   P048            1.50            1.40
#> 305                   P173            1.33            1.36
#> 306                   P136            1.33            1.34
#> 307                   P159            1.17            1.30
#> 308                    R13            1.97            1.71
#> 309                    R06            2.16            2.27
#> 310                    R01            2.53            2.63
#> 311                    R16            2.94            2.74
#> 312                    R10            2.68            2.86
#> 313                    R17            2.87            2.86
#> 314                    R11            2.58            2.89
#> 315                    R12            2.92            2.95
#> 316                    R07            3.12            3.07
#> 317                    R02            2.86            3.07
#> 318                    R18            3.01            3.22
#> 319                    R03            3.04            3.28
#> 320                    R05            3.03            3.30
#> 321                    R15            2.73            3.37
#> 322                    R14            3.33            3.47
#> 323                    R09            3.31            3.53
#> 324                    R08            3.29            3.54
#> 325                    R04            3.18            3.55
#> 326       Task_Fulfillment            2.64            2.71
#> 327 Linguistic_Realization            2.67            2.76
#> 328      Global_Impression            3.32            3.54
#>     StandardizedAdjustedAverage ModelBasedSE FitAdjustedSE
#> 1                          4.00       100.88        100.88
#> 2                          4.00        61.98         61.98
#> 3                          4.00        66.36         66.36
#> 4                          4.00        64.75         64.75
#> 5                          4.00        54.68         54.68
#> 6                          4.00        53.25         53.25
#> 7                          3.97         1.08          1.08
#> 8                          3.94         1.05          1.05
#> 9                          3.89         1.04          1.04
#> 10                         3.88         1.04          1.14
#> 11                         3.88         1.06          1.18
#> 12                         3.87         1.04          1.04
#> 13                         3.87         1.05          1.14
#> 14                         3.86         1.05          1.05
#> 15                         3.86         1.05          1.07
#> 16                         3.84         1.05          1.05
#> 17                         3.84         1.06          1.06
#> 18                         3.80         1.04          1.04
#> 19                         3.80         0.77          0.77
#> 20                         3.79         1.04          1.04
#> 21                         3.78         0.77          0.77
#> 22                         3.77         0.68          0.68
#> 23                         3.77         1.04          1.04
#> 24                         3.76         0.62          0.66
#> 25                         3.76         0.61          0.70
#> 26                         3.76         1.05          1.05
#> 27                         3.76         1.05          1.05
#> 28                         3.74         0.69          0.69
#> 29                         3.74         0.78          0.78
#> 30                         3.73         1.05          1.05
#> 31                         3.73         0.70          0.77
#> 32                         3.72         0.78          0.83
#> 33                         3.71         0.61          0.61
#> 34                         3.71         0.79          0.79
#> 35                         3.71         0.78          0.78
#> 36                         3.71         0.78          0.99
#> 37                         3.70         0.78          0.78
#> 38                         3.69         0.58          0.60
#> 39                         3.68         1.04          1.04
#> 40                         3.67         0.68          0.68
#> 41                         3.67         0.68          0.68
#> 42                         3.67         0.59          0.59
#> 43                         3.67         0.59          0.89
#> 44                         3.66         0.79          0.95
#> 45                         3.66         0.79          0.79
#> 46                         3.65         0.79          0.98
#> 47                         3.65         1.04          1.04
#> 48                         3.63         0.66          0.73
#> 49                         3.63         0.79          0.79
#> 50                         3.63         0.68          0.75
#> 51                         3.61         0.64          0.64
#> 52                         3.61         0.66          0.81
#> 53                         3.60         0.66          0.66
#> 54                         3.59         0.67          0.81
#> 55                         3.58         0.78          0.78
#> 56                         3.58         0.66          0.66
#> 57                         3.58         0.78          0.78
#> 58                         3.58         0.58          0.58
#> 59                         3.57         0.78          0.78
#> 60                         3.56         0.70          0.70
#> 61                         3.55         0.67          0.82
#> 62                         3.54         0.67          0.67
#> 63                         3.54         0.67          0.67
#> 64                         3.53         0.61          0.61
#> 65                         3.53         0.61          0.63
#> 66                         3.52         0.60          0.60
#> 67                         3.52         0.78          0.78
#> 68                         3.52         0.78          1.14
#> 69                         3.52         0.78          0.78
#> 70                         3.51         0.60          0.60
#> 71                         3.49         0.78          0.82
#> 72                         3.49         0.78          0.78
#> 73                         3.47         0.62          0.62
#> 74                         3.46         0.56          0.56
#> 75                         3.46         0.68          0.68
#> 76                         3.45         0.68          0.68
#> 77                         3.43         0.57          0.57
#> 78                         3.43         0.68          0.79
#> 79                         3.38         0.64          0.72
#> 80                         3.38         0.63          0.63
#> 81                         3.38         0.63          0.65
#> 82                         3.37         0.66          0.66
#> 83                         3.37         0.66          0.66
#> 84                         3.37         0.67          1.10
#> 85                         3.36         0.57          0.69
#> 86                         3.36         0.61          0.61
#> 87                         3.36         0.61          0.61
#> 88                         3.36         0.67          0.67
#> 89                         3.36         0.55          0.55
#> 90                         3.36         0.61          0.61
#> 91                         3.35         0.77          0.77
#> 92                         3.34         0.77          1.06
#> 93                         3.34         0.57          0.57
#> 94                         3.33         0.63          0.89
#> 95                         3.30         0.59          0.96
#> 96                         3.30         0.55          0.67
#> 97                         3.30         0.58          0.58
#> 98                         3.28         0.61          0.61
#> 99                         3.28         0.57          0.88
#> 100                        3.28         0.57          0.57
#> 101                        3.28         0.55          0.55
#> 102                        3.27         0.63          0.66
#> 103                        3.26         0.63          0.63
#> 104                        3.26         0.63          0.63
#> 105                        3.25         0.67          0.67
#> 106                        3.25         0.67          0.71
#> 107                        3.25         0.62          0.62
#> 108                        3.25         0.60          0.66
#> 109                        3.25         0.67          0.80
#> 110                        3.22         0.57          0.75
#> 111                        3.21         0.62          0.80
#> 112                        3.20         0.55          0.73
#> 113                        3.20         0.56          0.60
#> 114                        3.20         0.58          0.74
#> 115                        3.19         0.58          0.58
#> 116                        3.19         0.60          0.65
#> 117                        3.18         0.60          0.60
#> 118                        3.18         0.60          0.60
#> 119                        3.18         0.58          0.65
#> 120                        3.17         0.58          0.58
#> 121                        3.16         0.56          0.56
#> 122                        3.16         0.62          0.62
#> 123                        3.15         0.58          0.82
#> 124                        3.13         0.66          0.66
#> 125                        3.13         0.66          0.72
#> 126                        3.11         0.64          0.88
#> 127                        3.10         0.59          0.60
#> 128                        3.09         0.54          0.56
#> 129                        3.09         0.57          0.83
#> 130                        3.08         0.58          0.58
#> 131                        3.08         0.66          0.74
#> 132                        3.08         0.55          0.55
#> 133                        3.06         0.61          0.61
#> 134                        3.06         0.59          0.76
#> 135                        3.06         0.59          0.79
#> 136                        3.06         0.59          0.59
#> 137                        3.06         0.61          0.61
#> 138                        3.05         0.61          0.66
#> 139                        3.04         0.59          0.59
#> 140                        3.02         0.57          0.68
#> 141                        3.02         0.61          0.75
#> 142                        3.01         0.61          0.61
#> 143                        3.01         0.61          0.61
#> 144                        3.01         0.61          0.77
#> 145                        3.01         0.56          0.81
#> 146                        3.01         0.57          0.80
#> 147                        3.00         0.54          0.54
#> 148                        3.00         0.55          0.55
#> 149                        3.00         0.59          0.59
#> 150                        2.99         0.56          0.56
#> 151                        2.99         0.54          0.54
#> 152                        2.98         0.54          0.76
#> 153                        2.97         0.54          0.64
#> 154                        2.95         0.54          0.54
#> 155                        2.94         0.54          0.75
#> 156                        2.93         0.58          0.85
#> 157                        2.93         0.58          0.58
#> 158                        2.93         0.56          0.56
#> 159                        2.93         0.58          0.60
#> 160                        2.89         0.58          0.60
#> 161                        2.89         0.58          0.78
#> 162                        2.88         0.54          0.64
#> 163                        2.86         0.57          0.57
#> 164                        2.85         0.57          0.57
#> 165                        2.85         0.58          0.68
#> 166                        2.84         0.60          0.60
#> 167                        2.84         0.57          0.58
#> 168                        2.83         0.60          0.60
#> 169                        2.82         0.55          0.55
#> 170                        2.82         0.60          0.60
#> 171                        2.82         0.60          0.68
#> 172                        2.81         0.54          0.54
#> 173                        2.81         0.55          0.59
#> 174                        2.81         0.57          0.62
#> 175                        2.80         0.57          0.57
#> 176                        2.80         0.57          0.62
#> 177                        2.80         0.55          0.55
#> 178                        2.80         0.55          0.73
#> 179                        2.78         0.57          0.75
#> 180                        2.77         0.55          0.55
#> 181                        2.76         0.58          1.01
#> 182                        2.76         0.54          0.54
#> 183                        2.75         0.55          0.60
#> 184                        2.74         0.56          0.68
#> 185                        2.74         0.57          0.57
#> 186                        2.68         0.54          0.54
#> 187                        2.68         0.54          0.54
#> 188                        2.68         0.54          0.63
#> 189                        2.68         0.54          0.54
#> 190                        2.67         0.60          0.62
#> 191                        2.66         0.60          0.60
#> 192                        2.64         0.54          0.54
#> 193                        2.64         0.54          0.54
#> 194                        2.64         0.56          0.69
#> 195                        2.64         0.56          0.56
#> 196                        2.63         0.54          0.54
#> 197                        2.61         0.55          0.66
#> 198                        2.60         0.55          0.74
#> 199                        2.59         0.55          0.55
#> 200                        2.56         0.58          0.58
#> 201                        2.54         0.55          0.55
#> 202                        2.53         0.54          0.54
#> 203                        2.53         0.55          0.55
#> 204                        2.52         0.54          0.54
#> 205                        2.49         0.54          0.71
#> 206                        2.48         0.56          0.59
#> 207                        2.46         0.55          0.55
#> 208                        2.46         0.54          0.54
#> 209                        2.46         0.54          0.61
#> 210                        2.45         0.55          0.77
#> 211                        2.45         0.54          0.54
#> 212                        2.45         0.55          0.55
#> 213                        2.45         0.54          0.68
#> 214                        2.44         0.54          0.58
#> 215                        2.44         0.54          0.54
#> 216                        2.43         0.55          0.65
#> 217                        2.42         0.55          0.61
#> 218                        2.42         0.54          0.69
#> 219                        2.42         0.55          0.56
#> 220                        2.41         0.55          0.55
#> 221                        2.40         0.54          0.58
#> 222                        2.40         0.55          0.55
#> 223                        2.40         0.54          0.54
#> 224                        2.40         0.58          0.63
#> 225                        2.39         0.54          0.54
#> 226                        2.35         0.58          0.58
#> 227                        2.35         0.58          0.58
#> 228                        2.31         0.55          0.55
#> 229                        2.30         0.57          0.72
#> 230                        2.28         0.54          0.71
#> 231                        2.28         0.55          0.82
#> 232                        2.28         0.55          0.55
#> 233                        2.28         0.55          0.55
#> 234                        2.28         0.55          0.55
#> 235                        2.27         0.54          0.56
#> 236                        2.27         0.54          0.55
#> 237                        2.27         0.55          0.65
#> 238                        2.26         0.55          0.68
#> 239                        2.26         0.54          0.54
#> 240                        2.26         0.54          0.78
#> 241                        2.26         0.54          0.59
#> 242                        2.25         0.56          0.72
#> 243                        2.24         0.56          0.70
#> 244                        2.23         0.57          0.57
#> 245                        2.22         0.55          0.55
#> 246                        2.22         0.54          0.54
#> 247                        2.20         0.56          0.58
#> 248                        2.18         0.60          0.60
#> 249                        2.18         0.60          0.66
#> 250                        2.18         0.54          0.54
#> 251                        2.17         0.54          0.54
#> 252                        2.15         0.56          0.65
#> 253                        2.15         0.59          0.87
#> 254                        2.15         0.59          0.59
#> 255                        2.15         0.55          0.55
#> 256                        2.14         0.59          0.59
#> 257                        2.14         0.57          0.64
#> 258                        2.12         0.57          0.57
#> 259                        2.12         0.57          0.57
#> 260                        2.12         0.65          0.67
#> 261                        2.10         0.55          0.55
#> 262                        2.09         0.54          0.61
#> 263                        2.09         0.56          0.56
#> 264                        2.09         0.56          0.56
#> 265                        2.09         0.56          0.56
#> 266                        2.09         0.55          0.61
#> 267                        2.09         0.55          0.55
#> 268                        2.07         0.54          0.54
#> 269                        2.06         0.54          0.54
#> 270                        2.05         0.55          0.68
#> 271                        2.04         0.55          0.55
#> 272                        1.97         0.64          0.80
#> 273                        1.95         0.54          0.54
#> 274                        1.95         0.61          0.90
#> 275                        1.93         0.62          0.62
#> 276                        1.93         0.56          0.56
#> 277                        1.93         0.56          0.84
#> 278                        1.92         0.57          0.57
#> 279                        1.92         0.57          0.67
#> 280                        1.92         0.56          0.56
#> 281                        1.92         0.54          0.54
#> 282                        1.91         0.56          0.56
#> 283                        1.90         0.54          0.54
#> 284                        1.87         0.60          0.73
#> 285                        1.79         0.56          0.56
#> 286                        1.76         0.58          0.58
#> 287                        1.76         0.63          0.69
#> 288                        1.75         0.60          0.96
#> 289                        1.75         0.64          0.64
#> 290                        1.75         0.58          0.58
#> 291                        1.74         0.71          0.71
#> 292                        1.72         0.64          0.64
#> 293                        1.72         0.55          0.55
#> 294                        1.66         0.71          0.71
#> 295                        1.65         0.61          0.61
#> 296                        1.64         0.72          0.72
#> 297                        1.64         0.72          0.72
#> 298                        1.63         0.75          1.24
#> 299                        1.62         0.57          0.59
#> 300                        1.61         0.57          0.58
#> 301                        1.61         0.61          0.61
#> 302                        1.54         0.72          0.72
#> 303                        1.48         0.60          0.60
#> 304                        1.40         0.70          1.13
#> 305                        1.36         0.82          0.82
#> 306                        1.34         0.84          0.84
#> 307                        1.30         1.12          1.12
#> 308                        1.37         0.18          0.20
#> 309                        1.77         0.14          0.15
#> 310                        2.06         0.16          0.16
#> 311                        2.16         0.21          0.21
#> 312                        2.27         0.11          0.11
#> 313                        2.27         0.17          0.18
#> 314                        2.30         0.12          0.12
#> 315                        2.36         0.15          0.15
#> 316                        2.48         0.26          0.26
#> 317                        2.49         0.17          0.19
#> 318                        2.66         0.13          0.13
#> 319                        2.73         0.14          0.15
#> 320                        2.75         0.12          0.12
#> 321                        2.84         0.35          0.35
#> 322                        2.99         0.26          0.26
#> 323                        3.08         0.14          0.16
#> 324                        3.09         0.11          0.11
#> 325                        3.11         0.15          0.15
#> 326                        2.13         0.06          0.06
#> 327                        2.18         0.06          0.06
#> 328                        3.10         0.07          0.07
#> 
#> $settings
#> $settings$facets
#> NULL
#> 
#> $settings$totalscore
#> [1] TRUE
#> 
#> $settings$umean
#> [1] 0
#> 
#> $settings$uscale
#> [1] 1
#> 
#> $settings$udecimals
#> [1] 2
#> 
#> $settings$reference
#> [1] "both"
#> 
#> $settings$label_style
#> [1] "both"
#> 
#> $settings$omit_unobserved
#> [1] FALSE
#> 
#> $settings$xtreme
#> [1] 0
#> 
#> $settings$fair_se
#> [1] FALSE
#> 
#> $settings$ci_level
#> [1] 0.95
#> 
#> $settings$model
#> [1] "RSM"
#> 
#> $settings$method
#> [1] "PCM/RSM"
```

For new analysis scripts, prefer `fit_mfrm(method = "MML")` directly.
MML integrates over the person distribution under an N(0, 1) prior and
exposes per-person posterior SEs that JML cannot produce.

## Translating the specification file

The mapping below covers the most common Facets specification keywords.

### Facets and labels

    Facets = 3
    Models = ?,?,?,R5
    Labels =
      1, Examinee
        1 = P01
        ...
      2, Rater
        1 = R1
        ...
      3, Criterion
        1 = Content
        ...

translates to:

``` r

fit_mfrm(
  data = examinee_long,
  person = "Examinee",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1,
  rating_max = 5,
  model = "RSM"
)
```

`Models = ?,?,?,R5` becomes `model = "RSM"` and the `R5` rating-scale
declaration becomes `rating_min = 1, rating_max = 5`. For a
partial-credit specification, pass `model = "PCM"` and identify the
facet that carries the step thresholds with `step_facet = "Rater"` (or
the appropriate facet name).

### Anchoring

A Facets `D = 2, A =` block:

    D = 2
    A = 1, 0.0
        2, 0.5

becomes an `anchors` data frame:

``` r

anchors <- data.frame(
  facet = "Rater",
  level = c("R1", "R2"),
  estimate = c(0.0, 0.5),
  stringsAsFactors = FALSE
)
fit <- fit_mfrm(..., anchors = anchors)
```

[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
validates and reports on the anchor block before the fit runs, surfacing
connectivity, overlap, and minimum-sample issues.

### Bias and interaction

Facets Table 14 bias output between Rater and Criterion has a direct
equivalent:

``` r

diag <- diagnose_mfrm(fit)
bias <- estimate_bias(fit, diag,
                      facet_a = "Rater", facet_b = "Criterion")
summary(bias)
```

[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md)
enumerates every non-person facet pair in one call.

### Wright map / variable map

For a shared-logit visual display of persons, facet levels, and step
thresholds, use the Wright map route:

``` r

plot(fit, type = "wright", preset = "publication", show_ci = TRUE)
```

[`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md)
is the corresponding explicit helper when the Wright map is the main
figure rather than one panel in a larger visual workflow. Use
`draw = FALSE` or `plot_data(fit, type = "wright")` when you need the
underlying coordinates for a custom `ggplot2`, base-R, or Quarto
graphic.

### Fit df and ZSTD review

Facets users often compare Infit/Outfit MnSq together with ZStd columns.
In `mfrmr`, treat MnSq as the primary fit statistic and use the df/ZSTD
columns to explain how the same MnSq values were standardized. The
direct review path is:

``` r

diag <- diagnose_mfrm(fit, residual_pca = "none", fit_df_method = "both")
fm <- fit_measures_table(fit, diagnostics = diag,
                         facet = "Rater", fit_df_method = "both")

fm$facets_table
fm$df_sensitive
plot(fm, type = "df_sensitivity")
```

`df_sensitivity` reports the engine-vs-FACETS-style df comparison row by
row; `df_sensitive` keeps only rows where the df convention changes the
\|ZSTD\| flag or materially changes the ZSTD interpretation. The same
status taxonomy is used by
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md),
so a table-oriented review and an external FACETS comparison use the
same language.

### Group anchoring and DFF

Facets `D = ..., G =` group-anchor blocks for differential facet
functioning translate to the `group_anchors` argument and the
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
follow-up:

``` r

group_anchors <- data.frame(
  facet = "Criterion",
  level = "Content",
  group = c("Native", "Non-native"),
  estimate = c(0.0, 0.0),
  stringsAsFactors = FALSE
)
fit_g <- fit_mfrm(..., group_anchors = group_anchors)
dff <- analyze_dff(fit_g, diag, facet = "Criterion",
                   group = "FirstLanguage", method = "refit")
```

## Reviewing output contracts and fit tables

When migrating an existing study,
[`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md)
checks whether the package-generated report components satisfy the
FACETS-style output contract encoded in the package:

``` r

contract_review <- facets_output_contract_review(
  fit,
  diagnostics = diag,
  branch = "facets"
)
summary(contract_review)
contract_review$missing_preview
contract_review$metric_checks
```

The resulting object reviews column coverage and package-native metric
checks. It is not a claim that `mfrmr` has reproduced FACETS estimates
numerically. For external numerical comparison, use an exported FACETS
fit table and
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md).

When that comparison involves an `MML` fit, remember that mfrmr
evaluates residual-based fit statistics at shrunken EAP person measures
while FACETS uses JMLE estimates, so MnSq differences can reflect the
residual basis rather than a fit-computation difference; refit with
`method = "JML"` before attributing such gaps. See
[`facets_fit_df_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_df_guide.md)
for this boundary and for the separate df/ZSTD standardization
conventions.

If you already have a FACETS fit table on disk, read it first and then
run the fit review. This does not run FACETS; it consumes an exported or
otherwise harmonized table.

``` r

facets_fit <- read_facets_fit_table(
  "score.2.txt",
  facet_map = c("1" = "Person", "2" = "Rater", "3" = "Criterion")
)
review <- facets_fit_review(
  fit,
  diagnostics = diag,
  facets_fit = facets_fit,
  external_zstd_tolerance = 0.05
)

review$df_sensitivity
review$df_sensitive
review$external_table_quality
review$external_comparison
plot(review, type = "df_sensitivity")
```

Use `external_comparison` for the supplied FACETS table and
`df_sensitivity` for the engine-vs-FACETS-style df convention check.
This separation keeps external numerical differences distinct from ZSTD
differences caused by df standardization. `external_table_quality` is
the first place to look if the FACETS export only contains ZStd and
T.Count columns, or if duplicate `Facet` x `Level` rows were supplied.

## Producing Facets-style output files

For traceability or downstream tools that expect Facets output files,
[`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md)
writes a parallel set of fixed-width or CSV exports:

``` r

files <- facets_output_file_bundle(
  fit,
  diagnostics = diag,
  out_dir = tempdir(),
  include = c("graph", "score")
)
```

For RSM and PCM the score-side helpers are available. Under bounded
`GPCM` the score-side bundle is intentionally restricted; see
[`?gpcm_capability_matrix`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
and the `mfrmr-gpcm-scope` vignette for the binding contract.

## Recommended next steps

After a Facets-equivalent fit is in hand, the canonical mfrmr reporting
route extends the analysis with:

- [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
  before anchored fitting, and
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  /
  [`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md)
  when common elements define a cross-form or cross-wave link.
- `diagnose_mfrm(diagnostic_mode = "both")` for the strict marginal
  screen alongside the residual stack.
- [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
  [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md),
  and
  [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md)
  for category-functioning evidence.
- [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  when FACETS Table 12-style fair-average review is needed.
- `plot(fit, type = "wright")` or
  [`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md)
  for a variable-map view of targeting and threshold placement.
- [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
  [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md),
  and
  [`bias_pairwise_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_pairwise_report.md)
  when FACETS Table 14-style local interaction screening is
  substantively relevant.
- [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  for a manuscript-readiness summary.
- [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  for Method and Results paragraphs and APA tables.
- [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md)
  and
  [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md)
  for the reproducibility bundle that Facets specifications cannot
  produce out of the box.

The `mfrmr-workflow` vignette covers the full sequence end to end; the
`mfrmr-reporting-and-apa` vignette focuses on the manuscript surface;
the `mfrmr-linking-and-dff` vignette covers anchoring, drift, and DFF in
detail.
