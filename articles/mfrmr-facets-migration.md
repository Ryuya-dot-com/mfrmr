# Migrating from FACETS to mfrmr

This vignette walks FACETS users through the closest `mfrmr` workflow:
preparing data, fitting an `RSM`/`PCM` many-facet Rasch-family model
with FACETS-oriented settings, generating related diagnostic and
reporting tables, and reviewing the output-contract boundary between the
two systems. Bounded `GPCM` can be fit in `mfrmr`, but its slope-aware
score semantics are intentionally outside the score-side FACETS
output-contract route.

## Mental model

The two stacks share the same psychometric framework but differ in
operating model.

Before treating a legacy workflow as covered, inspect the public
coverage boundary:

``` r

facets_feature_coverage()
facets_feature_coverage("not_implemented")
```

| Concept | FACETS (Linacre 2026) | mfrmr |
|----|----|----|
| Input | Specification file plus data file | `data.frame` in long format |
| Estimation | JMLE by default | `MML` by default; `JML` is the closest estimation route for a JMLE-oriented comparison |
| Fit-statistic basis | Residuals at JMLE estimates | Residuals at EAP person measures under `MML` (shrunken toward the mean); refit with `method = "JML"` for a JMLE-style residual basis |
| Models | Rating-scale, partial-credit, polytomous step models | `RSM`, `PCM`, bounded `GPCM` |
| Output | Tables 0-30 plus graphic files | Returned R objects with [`summary()`](https://rdrr.io/r/base/summary.html) and [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods |
| Anchoring | `D=`, `A=` fields in the specification | `anchors` and `group_anchors` arguments to [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md) |
| Bias / interaction | Table 14 | [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md) and [`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md) |
| Wright map / variable map | Graphic variable-map output | `plot(fit, type = "wright")` and [`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md) |
| Fair average | Table 7 fair-M average | [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md) |
| Reproducibility | Specification, input data, FACETS version, and recorded run environment/settings | [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md) plus [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md) |

## A one-shot legacy-compatible call

If the goal is to translate a FACETS-style script with minimal R-side
plumbing, use
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
(alias
[`mfrmRFacets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)):

``` r

library(mfrmr)
data("mfrmr_example_operational", package = "mfrmr")

run <- run_mfrm_facets(
  data = mfrmr_example_operational,
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

jml_status <- summary(run$fit, profile = "fit", detail = "brief")
jml_status$overview[, c(
  "Model", "Method", "Converged", "InferenceReady",
  "ConvergenceSeverity"
)]
#> # A tibble: 1 × 5
#>   Model Method Converged InferenceReady ConvergenceSeverity
#>   <chr> <chr>  <lgl>     <lgl>          <chr>              
#> 1 RSM   JML    TRUE      TRUE           pass
jml_status$readiness
#>        Domain                                Status
#> 1   Numerical                                  pass
#> 2        Data                                  pass
#> 3      Design                           pass_linked
#> 4   Stability                                  pass
#> 5 Diagnostics                          not_assessed
#> 6   Reporting exploratory_fit_ready_for_diagnostics
#>                                                                                                                              Detail
#> 1                                                                                            Optimizer returned convergence code 0.
#> 2                                                                                No preparation warning or review row was retained.
#> 3 The observed graph satisfies the connectivity requirement; review the remaining design and identification assumptions separately.
#> 4                                                                         No boundary-constant non-person facet level was detected.
#> 5                                                             Diagnostics have not yet been incorporated into this fit-only status.
#> 6                                                             Reporting status is the strictest applicable upstream workflow state.
head(run$fair_average)
#> $raw_by_facet
#> $raw_by_facet$Person
#> # A tibble: 48 × 18
#>    TotalScore TotalCount WeightdScore WeightdCount ObservedAverage FairM FairZ
#>         <int>      <int>        <dbl>        <dbl>           <dbl> <dbl> <dbl>
#>  1         22          6           22            6            3.67  3.69  3.69
#>  2         22          6           22            6            3.67  3.66  3.66
#>  3         20          6           20            6            3.33  3.44  3.44
#>  4         20          6           20            6            3.33  3.41  3.41
#>  5         19          6           19            6            3.17  3.34  3.34
#>  6         19          6           19            6            3.17  3.19  3.19
#>  7         18          6           18            6            3     3.19  3.19
#>  8         17          5           17            5            3.4   3.11  3.11
#>  9         20          6           20            6            3.33  3.07  3.07
#> 10         18          6           18            6            3     3.02  3.02
#> # ℹ 38 more rows
#> # ℹ 11 more variables: Measure <dbl>, ModelSE <dbl>, RealSE <dbl>,
#> #   InfitMnSq <dbl>, InfitZStd <dbl>, OutfitMnSq <dbl>, OutfitZStd <dbl>,
#> #   PtMeaCorr <dbl>, Anchor <chr>, Status <chr>, Level <chr>
#> 
#> $raw_by_facet$Rater
#> # A tibble: 6 × 18
#>   TotalScore TotalCount WeightdScore WeightdCount ObservedAverage FairM FairZ
#>        <int>      <int>        <dbl>        <dbl>           <dbl> <dbl> <dbl>
#> 1        115         50          115           50            2.3   2.09  2.23
#> 2         77         38           77           38            2.03  2.10  2.24
#> 3        108         47          108           47            2.30  2.17  2.31
#> 4         95         44           95           44            2.16  2.29  2.44
#> 5        147         56          147           56            2.62  2.54  2.70
#> 6        130         47          130           47            2.77  2.73  2.88
#> # ℹ 11 more variables: Measure <dbl>, ModelSE <dbl>, RealSE <dbl>,
#> #   InfitMnSq <dbl>, InfitZStd <dbl>, OutfitMnSq <dbl>, OutfitZStd <dbl>,
#> #   PtMeaCorr <dbl>, Anchor <chr>, Status <chr>, Level <chr>
#> 
#> $raw_by_facet$Criterion
#> # A tibble: 3 × 18
#>   TotalScore TotalCount WeightdScore WeightdCount ObservedAverage FairM FairZ
#>        <int>      <int>        <dbl>        <dbl>           <dbl> <dbl> <dbl>
#> 1        211         94          211           94            2.24  2.16  2.30
#> 2        218         94          218           94            2.32  2.23  2.37
#> 3        243         94          243           94            2.59  2.57  2.73
#> # ℹ 11 more variables: Measure <dbl>, ModelSE <dbl>, RealSE <dbl>,
#> #   InfitMnSq <dbl>, InfitZStd <dbl>, OutfitMnSq <dbl>, OutfitZStd <dbl>,
#> #   PtMeaCorr <dbl>, Anchor <chr>, Status <chr>, Level <chr>
#> 
#> 
#> $by_facet
#> $by_facet$Person
#>    Total Score Total Count Weightd Score Weightd Count Obsvd Average
#> 1           22           6            22             6          3.67
#> 2           22           6            22             6          3.67
#> 3           20           6            20             6          3.33
#> 4           20           6            20             6          3.33
#> 5           19           6            19             6          3.17
#> 6           19           6            19             6          3.17
#> 7           18           6            18             6          3.00
#> 8           17           5            17             5          3.40
#> 9           20           6            20             6          3.33
#> 10          18           6            18             6          3.00
#> 11          17           6            17             6          2.83
#> 12          16           6            16             6          2.67
#> 13          15           5            15             5          3.00
#> 14          16           6            16             6          2.67
#> 15          16           6            16             6          2.67
#> 16          18           6            18             6          3.00
#> 17          12           5            12             5          2.40
#> 18          15           6            15             6          2.50
#> 19          16           6            16             6          2.67
#> 20          14           6            14             6          2.33
#> 21          17           6            17             6          2.83
#> 22          13           6            13             6          2.17
#> 23          13           6            13             6          2.17
#> 24          16           6            16             6          2.67
#> 25          16           6            16             6          2.67
#> 26          12           5            12             5          2.40
#> 27          11           5            11             5          2.20
#> 28          15           6            15             6          2.50
#> 29          13           6            13             6          2.17
#> 30          13           6            13             6          2.17
#> 31          12           6            12             6          2.00
#> 32          10           5            10             5          2.00
#> 33          13           6            13             6          2.17
#> 34          13           6            13             6          2.17
#> 35          14           6            14             6          2.33
#> 36          12           6            12             6          2.00
#> 37          12           6            12             6          2.00
#> 38          12           6            12             6          2.00
#> 39           9           6             9             6          1.50
#> 40          10           6            10             6          1.67
#> 41           9           6             9             6          1.50
#> 42           9           6             9             6          1.50
#> 43           9           6             9             6          1.50
#> 44           8           6             8             6          1.33
#> 45           8           6             8             6          1.33
#> 46           8           6             8             6          1.33
#> 47           8           6             8             6          1.33
#> 48           7           6             7             6          1.17
#>    Fair(M) Average Fair(Z) Average Measure Model S.E. Real S.E. Infit MnSq
#> 1             3.69            3.69    2.37       0.76      0.76       0.44
#> 2             3.66            3.66    2.26       0.77      0.94       1.51
#> 3             3.44            3.44    1.65       0.59      0.65       1.23
#> 4             3.41            3.41    1.59       0.58      0.58       1.00
#> 5             3.34            3.34    1.44       0.55      0.60       1.22
#> 6             3.19            3.19    1.16       0.55      0.71       1.66
#> 7             3.19            3.19    1.15       0.53      0.85       2.62
#> 8             3.11            3.11    1.01       0.66      0.66       0.56
#> 9             3.07            3.07    0.95       0.58      0.70       1.44
#> 10            3.02            3.02    0.87       0.53      0.53       0.89
#> 11            2.92            2.92    0.71       0.51      0.51       0.72
#> 12            2.86            2.86    0.62       0.51      0.67       1.72
#> 13            2.76            2.76    0.45       0.57      0.59       1.04
#> 14            2.75            2.75    0.45       0.51      0.51       0.69
#> 15            2.75            2.75    0.45       0.51      0.51       0.34
#> 16            2.69            2.69    0.35       0.53      0.56       1.13
#> 17            2.66            2.66    0.30       0.56      0.78       1.95
#> 18            2.62            2.62    0.25       0.51      0.52       1.01
#> 19            2.58            2.58    0.17       0.52      0.72       1.93
#> 20            2.52            2.52    0.09       0.52      0.52       0.14
#> 21            2.51            2.51    0.08       0.51      0.62       1.44
#> 22            2.35            2.35   -0.18       0.53      0.53       0.13
#> 23            2.35            2.35   -0.18       0.53      0.53       0.65
#> 24            2.35            2.35   -0.19       0.51      0.51       0.61
#> 25            2.35            2.35   -0.19       0.51      0.51       0.61
#> 26            2.33            2.33   -0.21       0.57      0.57       0.59
#> 27            2.26            2.26   -0.33       0.58      0.60       1.08
#> 28            2.18            2.18   -0.45       0.51      0.51       0.29
#> 29            2.16            2.16   -0.49       0.54      0.66       1.54
#> 30            2.16            2.16   -0.49       0.54      0.82       2.35
#> 31            2.10            2.10   -0.59       0.55      0.55       0.43
#> 32            2.07            2.07   -0.65       0.60      0.63       1.07
#> 33            2.06            2.06   -0.65       0.54      0.54       0.50
#> 34            2.06            2.06   -0.65       0.54      0.57       1.11
#> 35            2.03            2.03   -0.71       0.52      0.53       1.04
#> 36            1.99            1.99   -0.79       0.55      0.55       0.29
#> 37            1.90            1.90   -0.95       0.56      0.56       0.79
#> 38            1.74            1.74   -1.28       0.55      0.55       0.43
#> 39            1.61            1.61   -1.56       0.68      0.68       0.70
#> 40            1.58            1.58   -1.64       0.62      0.62       0.54
#> 41            1.56            1.56   -1.68       0.68      0.68       0.59
#> 42            1.48            1.48   -1.89       0.68      0.71       1.08
#> 43            1.48            1.48   -1.89       0.68      1.28       3.53
#> 44            1.38            1.38   -2.21       0.79      0.79       0.70
#> 45            1.38            1.38   -2.21       0.79      0.79       0.79
#> 46            1.36            1.36   -2.26       0.79      0.79       0.73
#> 47            1.36            1.36   -2.26       0.79      0.79       0.57
#> 48            1.18            1.18   -3.08       1.06      1.08       1.03
#>    Infit ZStd Outfit MnSq Outfit ZStd PtMea Corr Anch Status Element
#> 1       -0.30        0.39       -1.22         NA                P015
#> 2        0.77        1.04        0.27         NA                P045
#> 3        0.53        1.31        0.68         NA                P036
#> 4        0.27        0.99        0.18         NA                P030
#> 5        0.52        1.31        0.68         NA                P027
#> 6        0.97        1.91        1.44         NA                P013
#> 7        1.77        2.59        2.13         NA                P025
#> 8       -0.25        0.60       -0.54         NA                P006
#> 9        0.74        1.53        0.99         NA                P002
#> 10       0.11        0.85       -0.08         NA                P019
#> 11      -0.19        0.69       -0.40         NA                P034
#> 12       1.07        1.75        1.26         NA                P021
#> 13       0.32        1.05        0.29         NA                P001
#> 14      -0.25        0.68       -0.42         NA                P031
#> 15      -1.01        0.34       -1.39         NA                P035
#> 16       0.41        1.09        0.35         NA                P004
#> 17       1.20        1.93        1.37         NA                P024
#> 18       0.26        1.01        0.20         NA                P038
#> 19       1.24        1.95        1.49         NA                P048
#> 20      -1.72        0.14       -2.32         NA                P022
#> 21       0.77        1.44        0.86         NA                P003
#> 22      -1.74        0.12       -2.46         NA                P026
#> 23      -0.29        0.67       -0.46         NA                P020
#> 24      -0.39        0.62       -0.57         NA                P005
#> 25      -0.39        0.62       -0.57         NA                P010
#> 26      -0.34        0.62       -0.49         NA                P011
#> 27       0.37        1.13        0.40         NA                P028
#> 28      -1.17        0.29       -1.58         NA                P008
#> 29       0.86        1.49        0.93         NA                P018
#> 30       1.56        2.57        2.11         NA                P012
#> 31      -0.67        0.43       -1.09         NA                P042
#> 32       0.37        1.10        0.36         NA                P039
#> 33      -0.56        0.53       -0.81         NA                P046
#> 34       0.39        1.03        0.25         NA                P043
#> 35       0.30        1.06        0.30         NA                P009
#> 36      -1.03        0.31       -1.48         NA                P017
#> 37      -0.03        0.79       -0.19         NA                P044
#> 38      -0.68        0.42       -1.10         NA                P007
#> 39      -0.03        0.72       -0.35         NA                P023
#> 40      -0.34        0.58       -0.67         NA                P047
#> 41      -0.19        0.64       -0.53         NA                P041
#> 42       0.40        0.91        0.04         NA                P014
#> 43       1.94        3.31        2.74         NA                P016
#> 44       0.07        0.68       -0.42         NA                P037
#> 45       0.17        0.88       -0.03         NA                P040
#> 46       0.11        0.73       -0.32         NA                P029
#> 47      -0.08        0.52       -0.81         NA                P033
#> 48         NA        1.23        0.56         NA                P032
#>    ObservedAverage AdjustedAverage StandardizedAdjustedAverage ModelBasedSE
#> 1             3.67            3.69                        3.69         0.76
#> 2             3.67            3.66                        3.66         0.77
#> 3             3.33            3.44                        3.44         0.59
#> 4             3.33            3.41                        3.41         0.58
#> 5             3.17            3.34                        3.34         0.55
#> 6             3.17            3.19                        3.19         0.55
#> 7             3.00            3.19                        3.19         0.53
#> 8             3.40            3.11                        3.11         0.66
#> 9             3.33            3.07                        3.07         0.58
#> 10            3.00            3.02                        3.02         0.53
#> 11            2.83            2.92                        2.92         0.51
#> 12            2.67            2.86                        2.86         0.51
#> 13            3.00            2.76                        2.76         0.57
#> 14            2.67            2.75                        2.75         0.51
#> 15            2.67            2.75                        2.75         0.51
#> 16            3.00            2.69                        2.69         0.53
#> 17            2.40            2.66                        2.66         0.56
#> 18            2.50            2.62                        2.62         0.51
#> 19            2.67            2.58                        2.58         0.52
#> 20            2.33            2.52                        2.52         0.52
#> 21            2.83            2.51                        2.51         0.51
#> 22            2.17            2.35                        2.35         0.53
#> 23            2.17            2.35                        2.35         0.53
#> 24            2.67            2.35                        2.35         0.51
#> 25            2.67            2.35                        2.35         0.51
#> 26            2.40            2.33                        2.33         0.57
#> 27            2.20            2.26                        2.26         0.58
#> 28            2.50            2.18                        2.18         0.51
#> 29            2.17            2.16                        2.16         0.54
#> 30            2.17            2.16                        2.16         0.54
#> 31            2.00            2.10                        2.10         0.55
#> 32            2.00            2.07                        2.07         0.60
#> 33            2.17            2.06                        2.06         0.54
#> 34            2.17            2.06                        2.06         0.54
#> 35            2.33            2.03                        2.03         0.52
#> 36            2.00            1.99                        1.99         0.55
#> 37            2.00            1.90                        1.90         0.56
#> 38            2.00            1.74                        1.74         0.55
#> 39            1.50            1.61                        1.61         0.68
#> 40            1.67            1.58                        1.58         0.62
#> 41            1.50            1.56                        1.56         0.68
#> 42            1.50            1.48                        1.48         0.68
#> 43            1.50            1.48                        1.48         0.68
#> 44            1.33            1.38                        1.38         0.79
#> 45            1.33            1.38                        1.38         0.79
#> 46            1.33            1.36                        1.36         0.79
#> 47            1.33            1.36                        1.36         0.79
#> 48            1.17            1.18                        1.18         1.06
#>    FitAdjustedSE
#> 1           0.76
#> 2           0.94
#> 3           0.65
#> 4           0.58
#> 5           0.60
#> 6           0.71
#> 7           0.85
#> 8           0.66
#> 9           0.70
#> 10          0.53
#> 11          0.51
#> 12          0.67
#> 13          0.59
#> 14          0.51
#> 15          0.51
#> 16          0.56
#> 17          0.78
#> 18          0.52
#> 19          0.72
#> 20          0.52
#> 21          0.62
#> 22          0.53
#> 23          0.53
#> 24          0.51
#> 25          0.51
#> 26          0.57
#> 27          0.60
#> 28          0.51
#> 29          0.66
#> 30          0.82
#> 31          0.55
#> 32          0.63
#> 33          0.54
#> 34          0.57
#> 35          0.53
#> 36          0.55
#> 37          0.56
#> 38          0.55
#> 39          0.68
#> 40          0.62
#> 41          0.68
#> 42          0.71
#> 43          1.28
#> 44          0.79
#> 45          0.79
#> 46          0.79
#> 47          0.79
#> 48          1.08
#> 
#> $by_facet$Rater
#>   Total Score Total Count Weightd Score Weightd Count Obsvd Average
#> 1         115          50           115            50          2.30
#> 2          77          38            77            38          2.03
#> 3         108          47           108            47          2.30
#> 4          95          44            95            44          2.16
#> 5         147          56           147            56          2.62
#> 6         130          47           130            47          2.77
#>   Fair(M) Average Fair(Z) Average Measure Model S.E. Real S.E. Infit MnSq
#> 1            2.09            2.23    0.37       0.20      0.21       1.13
#> 2            2.10            2.24    0.36       0.24      0.24       0.99
#> 3            2.17            2.31    0.24       0.20      0.21       1.10
#> 4            2.29            2.44    0.03       0.22      0.22       0.79
#> 5            2.54            2.70   -0.36       0.18      0.19       1.12
#> 6            2.73            2.88   -0.64       0.19      0.19       0.86
#>   Infit ZStd Outfit MnSq Outfit ZStd PtMea Corr Anch Status Element
#> 1       0.56        1.07        0.40       0.59                 R03
#> 2       0.08        0.98        0.00       0.59                 R06
#> 3       0.42        1.12        0.63       0.59                 R04
#> 4      -0.60        0.76       -1.14       0.59                 R05
#> 5       0.53        1.24        1.22       0.59                 R02
#> 6      -0.46        0.83       -0.82       0.59                 R01
#>   ObservedAverage AdjustedAverage StandardizedAdjustedAverage ModelBasedSE
#> 1            2.30            2.09                        2.23         0.20
#> 2            2.03            2.10                        2.24         0.24
#> 3            2.30            2.17                        2.31         0.20
#> 4            2.16            2.29                        2.44         0.22
#> 5            2.62            2.54                        2.70         0.18
#> 6            2.77            2.73                        2.88         0.19
#>   FitAdjustedSE
#> 1          0.21
#> 2          0.24
#> 3          0.21
#> 4          0.22
#> 5          0.19
#> 6          0.19
#> 
#> $by_facet$Criterion
#>   Total Score Total Count Weightd Score Weightd Count Obsvd Average
#> 1         211          94           211            94          2.24
#> 2         218          94           218            94          2.32
#> 3         243          94           243            94          2.59
#>   Fair(M) Average Fair(Z) Average Measure Model S.E. Real S.E. Infit MnSq
#> 1            2.16            2.30    0.26       0.14      0.16       1.20
#> 2            2.23            2.37    0.14       0.14      0.14       0.95
#> 3            2.57            2.73   -0.40       0.14      0.14       0.88
#>   Infit ZStd Outfit MnSq Outfit ZStd PtMea Corr Anch Status      Element
#> 1       1.00        1.21        1.41       0.63             Organization
#> 2      -0.17        0.93       -0.45       0.63                 Language
#> 3      -0.57        0.89       -0.71       0.63                  Content
#>   ObservedAverage AdjustedAverage StandardizedAdjustedAverage ModelBasedSE
#> 1            2.24            2.16                        2.30         0.14
#> 2            2.32            2.23                        2.37         0.14
#> 3            2.59            2.57                        2.73         0.14
#>   FitAdjustedSE
#> 1          0.16
#> 2          0.14
#> 3          0.14
#> 
#> 
#> $stacked
#>        Facet Total Score Total Count Weightd Score Weightd Count Obsvd Average
#> 1     Person          22           6            22             6          3.67
#> 2     Person          22           6            22             6          3.67
#> 3     Person          20           6            20             6          3.33
#> 4     Person          20           6            20             6          3.33
#> 5     Person          19           6            19             6          3.17
#> 6     Person          19           6            19             6          3.17
#> 7     Person          18           6            18             6          3.00
#> 8     Person          17           5            17             5          3.40
#> 9     Person          20           6            20             6          3.33
#> 10    Person          18           6            18             6          3.00
#> 11    Person          17           6            17             6          2.83
#> 12    Person          16           6            16             6          2.67
#> 13    Person          15           5            15             5          3.00
#> 14    Person          16           6            16             6          2.67
#> 15    Person          16           6            16             6          2.67
#> 16    Person          18           6            18             6          3.00
#> 17    Person          12           5            12             5          2.40
#> 18    Person          15           6            15             6          2.50
#> 19    Person          16           6            16             6          2.67
#> 20    Person          14           6            14             6          2.33
#> 21    Person          17           6            17             6          2.83
#> 22    Person          13           6            13             6          2.17
#> 23    Person          13           6            13             6          2.17
#> 24    Person          16           6            16             6          2.67
#> 25    Person          16           6            16             6          2.67
#> 26    Person          12           5            12             5          2.40
#> 27    Person          11           5            11             5          2.20
#> 28    Person          15           6            15             6          2.50
#> 29    Person          13           6            13             6          2.17
#> 30    Person          13           6            13             6          2.17
#> 31    Person          12           6            12             6          2.00
#> 32    Person          10           5            10             5          2.00
#> 33    Person          13           6            13             6          2.17
#> 34    Person          13           6            13             6          2.17
#> 35    Person          14           6            14             6          2.33
#> 36    Person          12           6            12             6          2.00
#> 37    Person          12           6            12             6          2.00
#> 38    Person          12           6            12             6          2.00
#> 39    Person           9           6             9             6          1.50
#> 40    Person          10           6            10             6          1.67
#> 41    Person           9           6             9             6          1.50
#> 42    Person           9           6             9             6          1.50
#> 43    Person           9           6             9             6          1.50
#> 44    Person           8           6             8             6          1.33
#> 45    Person           8           6             8             6          1.33
#> 46    Person           8           6             8             6          1.33
#> 47    Person           8           6             8             6          1.33
#> 48    Person           7           6             7             6          1.17
#> 49     Rater         115          50           115            50          2.30
#> 50     Rater          77          38            77            38          2.03
#> 51     Rater         108          47           108            47          2.30
#> 52     Rater          95          44            95            44          2.16
#> 53     Rater         147          56           147            56          2.62
#> 54     Rater         130          47           130            47          2.77
#> 55 Criterion         211          94           211            94          2.24
#> 56 Criterion         218          94           218            94          2.32
#> 57 Criterion         243          94           243            94          2.59
#>    Fair(M) Average Fair(Z) Average Measure Model S.E. Real S.E. Infit MnSq
#> 1             3.69            3.69    2.37       0.76      0.76       0.44
#> 2             3.66            3.66    2.26       0.77      0.94       1.51
#> 3             3.44            3.44    1.65       0.59      0.65       1.23
#> 4             3.41            3.41    1.59       0.58      0.58       1.00
#> 5             3.34            3.34    1.44       0.55      0.60       1.22
#> 6             3.19            3.19    1.16       0.55      0.71       1.66
#> 7             3.19            3.19    1.15       0.53      0.85       2.62
#> 8             3.11            3.11    1.01       0.66      0.66       0.56
#> 9             3.07            3.07    0.95       0.58      0.70       1.44
#> 10            3.02            3.02    0.87       0.53      0.53       0.89
#> 11            2.92            2.92    0.71       0.51      0.51       0.72
#> 12            2.86            2.86    0.62       0.51      0.67       1.72
#> 13            2.76            2.76    0.45       0.57      0.59       1.04
#> 14            2.75            2.75    0.45       0.51      0.51       0.69
#> 15            2.75            2.75    0.45       0.51      0.51       0.34
#> 16            2.69            2.69    0.35       0.53      0.56       1.13
#> 17            2.66            2.66    0.30       0.56      0.78       1.95
#> 18            2.62            2.62    0.25       0.51      0.52       1.01
#> 19            2.58            2.58    0.17       0.52      0.72       1.93
#> 20            2.52            2.52    0.09       0.52      0.52       0.14
#> 21            2.51            2.51    0.08       0.51      0.62       1.44
#> 22            2.35            2.35   -0.18       0.53      0.53       0.13
#> 23            2.35            2.35   -0.18       0.53      0.53       0.65
#> 24            2.35            2.35   -0.19       0.51      0.51       0.61
#> 25            2.35            2.35   -0.19       0.51      0.51       0.61
#> 26            2.33            2.33   -0.21       0.57      0.57       0.59
#> 27            2.26            2.26   -0.33       0.58      0.60       1.08
#> 28            2.18            2.18   -0.45       0.51      0.51       0.29
#> 29            2.16            2.16   -0.49       0.54      0.66       1.54
#> 30            2.16            2.16   -0.49       0.54      0.82       2.35
#> 31            2.10            2.10   -0.59       0.55      0.55       0.43
#> 32            2.07            2.07   -0.65       0.60      0.63       1.07
#> 33            2.06            2.06   -0.65       0.54      0.54       0.50
#> 34            2.06            2.06   -0.65       0.54      0.57       1.11
#> 35            2.03            2.03   -0.71       0.52      0.53       1.04
#> 36            1.99            1.99   -0.79       0.55      0.55       0.29
#> 37            1.90            1.90   -0.95       0.56      0.56       0.79
#> 38            1.74            1.74   -1.28       0.55      0.55       0.43
#> 39            1.61            1.61   -1.56       0.68      0.68       0.70
#> 40            1.58            1.58   -1.64       0.62      0.62       0.54
#> 41            1.56            1.56   -1.68       0.68      0.68       0.59
#> 42            1.48            1.48   -1.89       0.68      0.71       1.08
#> 43            1.48            1.48   -1.89       0.68      1.28       3.53
#> 44            1.38            1.38   -2.21       0.79      0.79       0.70
#> 45            1.38            1.38   -2.21       0.79      0.79       0.79
#> 46            1.36            1.36   -2.26       0.79      0.79       0.73
#> 47            1.36            1.36   -2.26       0.79      0.79       0.57
#> 48            1.18            1.18   -3.08       1.06      1.08       1.03
#> 49            2.09            2.23    0.37       0.20      0.21       1.13
#> 50            2.10            2.24    0.36       0.24      0.24       0.99
#> 51            2.17            2.31    0.24       0.20      0.21       1.10
#> 52            2.29            2.44    0.03       0.22      0.22       0.79
#> 53            2.54            2.70   -0.36       0.18      0.19       1.12
#> 54            2.73            2.88   -0.64       0.19      0.19       0.86
#> 55            2.16            2.30    0.26       0.14      0.16       1.20
#> 56            2.23            2.37    0.14       0.14      0.14       0.95
#> 57            2.57            2.73   -0.40       0.14      0.14       0.88
#>    Infit ZStd Outfit MnSq Outfit ZStd PtMea Corr Anch Status      Element
#> 1       -0.30        0.39       -1.22         NA                     P015
#> 2        0.77        1.04        0.27         NA                     P045
#> 3        0.53        1.31        0.68         NA                     P036
#> 4        0.27        0.99        0.18         NA                     P030
#> 5        0.52        1.31        0.68         NA                     P027
#> 6        0.97        1.91        1.44         NA                     P013
#> 7        1.77        2.59        2.13         NA                     P025
#> 8       -0.25        0.60       -0.54         NA                     P006
#> 9        0.74        1.53        0.99         NA                     P002
#> 10       0.11        0.85       -0.08         NA                     P019
#> 11      -0.19        0.69       -0.40         NA                     P034
#> 12       1.07        1.75        1.26         NA                     P021
#> 13       0.32        1.05        0.29         NA                     P001
#> 14      -0.25        0.68       -0.42         NA                     P031
#> 15      -1.01        0.34       -1.39         NA                     P035
#> 16       0.41        1.09        0.35         NA                     P004
#> 17       1.20        1.93        1.37         NA                     P024
#> 18       0.26        1.01        0.20         NA                     P038
#> 19       1.24        1.95        1.49         NA                     P048
#> 20      -1.72        0.14       -2.32         NA                     P022
#> 21       0.77        1.44        0.86         NA                     P003
#> 22      -1.74        0.12       -2.46         NA                     P026
#> 23      -0.29        0.67       -0.46         NA                     P020
#> 24      -0.39        0.62       -0.57         NA                     P005
#> 25      -0.39        0.62       -0.57         NA                     P010
#> 26      -0.34        0.62       -0.49         NA                     P011
#> 27       0.37        1.13        0.40         NA                     P028
#> 28      -1.17        0.29       -1.58         NA                     P008
#> 29       0.86        1.49        0.93         NA                     P018
#> 30       1.56        2.57        2.11         NA                     P012
#> 31      -0.67        0.43       -1.09         NA                     P042
#> 32       0.37        1.10        0.36         NA                     P039
#> 33      -0.56        0.53       -0.81         NA                     P046
#> 34       0.39        1.03        0.25         NA                     P043
#> 35       0.30        1.06        0.30         NA                     P009
#> 36      -1.03        0.31       -1.48         NA                     P017
#> 37      -0.03        0.79       -0.19         NA                     P044
#> 38      -0.68        0.42       -1.10         NA                     P007
#> 39      -0.03        0.72       -0.35         NA                     P023
#> 40      -0.34        0.58       -0.67         NA                     P047
#> 41      -0.19        0.64       -0.53         NA                     P041
#> 42       0.40        0.91        0.04         NA                     P014
#> 43       1.94        3.31        2.74         NA                     P016
#> 44       0.07        0.68       -0.42         NA                     P037
#> 45       0.17        0.88       -0.03         NA                     P040
#> 46       0.11        0.73       -0.32         NA                     P029
#> 47      -0.08        0.52       -0.81         NA                     P033
#> 48         NA        1.23        0.56         NA                     P032
#> 49       0.56        1.07        0.40       0.59                      R03
#> 50       0.08        0.98        0.00       0.59                      R06
#> 51       0.42        1.12        0.63       0.59                      R04
#> 52      -0.60        0.76       -1.14       0.59                      R05
#> 53       0.53        1.24        1.22       0.59                      R02
#> 54      -0.46        0.83       -0.82       0.59                      R01
#> 55       1.00        1.21        1.41       0.63             Organization
#> 56      -0.17        0.93       -0.45       0.63                 Language
#> 57      -0.57        0.89       -0.71       0.63                  Content
#>    ObservedAverage AdjustedAverage StandardizedAdjustedAverage ModelBasedSE
#> 1             3.67            3.69                        3.69         0.76
#> 2             3.67            3.66                        3.66         0.77
#> 3             3.33            3.44                        3.44         0.59
#> 4             3.33            3.41                        3.41         0.58
#> 5             3.17            3.34                        3.34         0.55
#> 6             3.17            3.19                        3.19         0.55
#> 7             3.00            3.19                        3.19         0.53
#> 8             3.40            3.11                        3.11         0.66
#> 9             3.33            3.07                        3.07         0.58
#> 10            3.00            3.02                        3.02         0.53
#> 11            2.83            2.92                        2.92         0.51
#> 12            2.67            2.86                        2.86         0.51
#> 13            3.00            2.76                        2.76         0.57
#> 14            2.67            2.75                        2.75         0.51
#> 15            2.67            2.75                        2.75         0.51
#> 16            3.00            2.69                        2.69         0.53
#> 17            2.40            2.66                        2.66         0.56
#> 18            2.50            2.62                        2.62         0.51
#> 19            2.67            2.58                        2.58         0.52
#> 20            2.33            2.52                        2.52         0.52
#> 21            2.83            2.51                        2.51         0.51
#> 22            2.17            2.35                        2.35         0.53
#> 23            2.17            2.35                        2.35         0.53
#> 24            2.67            2.35                        2.35         0.51
#> 25            2.67            2.35                        2.35         0.51
#> 26            2.40            2.33                        2.33         0.57
#> 27            2.20            2.26                        2.26         0.58
#> 28            2.50            2.18                        2.18         0.51
#> 29            2.17            2.16                        2.16         0.54
#> 30            2.17            2.16                        2.16         0.54
#> 31            2.00            2.10                        2.10         0.55
#> 32            2.00            2.07                        2.07         0.60
#> 33            2.17            2.06                        2.06         0.54
#> 34            2.17            2.06                        2.06         0.54
#> 35            2.33            2.03                        2.03         0.52
#> 36            2.00            1.99                        1.99         0.55
#> 37            2.00            1.90                        1.90         0.56
#> 38            2.00            1.74                        1.74         0.55
#> 39            1.50            1.61                        1.61         0.68
#> 40            1.67            1.58                        1.58         0.62
#> 41            1.50            1.56                        1.56         0.68
#> 42            1.50            1.48                        1.48         0.68
#> 43            1.50            1.48                        1.48         0.68
#> 44            1.33            1.38                        1.38         0.79
#> 45            1.33            1.38                        1.38         0.79
#> 46            1.33            1.36                        1.36         0.79
#> 47            1.33            1.36                        1.36         0.79
#> 48            1.17            1.18                        1.18         1.06
#> 49            2.30            2.09                        2.23         0.20
#> 50            2.03            2.10                        2.24         0.24
#> 51            2.30            2.17                        2.31         0.20
#> 52            2.16            2.29                        2.44         0.22
#> 53            2.62            2.54                        2.70         0.18
#> 54            2.77            2.73                        2.88         0.19
#> 55            2.24            2.16                        2.30         0.14
#> 56            2.32            2.23                        2.37         0.14
#> 57            2.59            2.57                        2.73         0.14
#>    FitAdjustedSE
#> 1           0.76
#> 2           0.94
#> 3           0.65
#> 4           0.58
#> 5           0.60
#> 6           0.71
#> 7           0.85
#> 8           0.66
#> 9           0.70
#> 10          0.53
#> 11          0.51
#> 12          0.67
#> 13          0.59
#> 14          0.51
#> 15          0.51
#> 16          0.56
#> 17          0.78
#> 18          0.52
#> 19          0.72
#> 20          0.52
#> 21          0.62
#> 22          0.53
#> 23          0.53
#> 24          0.51
#> 25          0.51
#> 26          0.57
#> 27          0.60
#> 28          0.51
#> 29          0.66
#> 30          0.82
#> 31          0.55
#> 32          0.63
#> 33          0.54
#> 34          0.57
#> 35          0.53
#> 36          0.55
#> 37          0.56
#> 38          0.55
#> 39          0.68
#> 40          0.62
#> 41          0.68
#> 42          0.71
#> 43          1.28
#> 44          0.79
#> 45          0.79
#> 46          0.79
#> 47          0.79
#> 48          1.08
#> 49          0.21
#> 50          0.24
#> 51          0.21
#> 52          0.22
#> 53          0.19
#> 54          0.19
#> 55          0.16
#> 56          0.14
#> 57          0.14
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

`method = "JML"` is shown here for a JMLE-oriented migration comparison.
Do not infer readiness from `Converged` alone: require
`InferenceReady = TRUE` for the numerical gate and review the
terminal-gradient guidance when severity is `"review"` or `"fail"`.
Numerical readiness does not override a Data, Design, or Stability hold;
use the readiness table before interpreting or reporting the fit. For
new analysis scripts, prefer `fit_mfrm(method = "MML")` directly. MML
integrates over the person distribution under an N(0, 1) prior and
exposes per-person posterior SEs that JML cannot produce.

## Translating the specification file

The mapping below covers the most common FACETS specification keywords.

### FACETS and labels

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

A FACETS `D = 2, A =` block:

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

For FACETS Table 14 bias output between Rater and Criterion, the closest
mfrmr screening route is:

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
thresholds, first create the FACETS-organized summary and retain its
result object:

``` r

review <- summary(fit, profile = "facets", detail = "brief")
res <- review$results

# Primary final-scale artifact: all locations and available facet uncertainty.
plot(res, type = "wright", renderer = "native", show_ci = TRUE,
     top_n = Inf, preset = "publication")
```

[`plot_wright_unified()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_wright_unified.md)
is the corresponding explicit helper when the Wright map is the main
figure. For readers who expect the FACETS Table 6-style asterisk ruler
and horizontal, rubric-labelled category transitions, define one label
for every retained original score:

``` r

rubric_labels <- setNames(
  your_rubric_labels,
  fit$prep$score_map$OriginalScore
)
plot(res, type = "wright", renderer = "facets", show_ci = FALSE,
     category_labels = rubric_labels, preset = "publication")
```

`show_ci = FALSE` is the closest FACETS-style visual grammar. Setting
`show_ci = TRUE` deliberately creates a hybrid display: the ruler is
FACETS-style, but the intervals are mfrmr uncertainty estimates. Neither
renderer implies that FACETS performed the estimation or that the two
programs are numerically equivalent.

For the Bond-and-Fox-style follow-up requested by many FACETS users, put
Infit on the horizontal axis and the measure on the vertical axis.
Person rows remain opt-in:

``` r

plot(res, type = "fit_pathway", fit_stat = "Infit",
     include_person = TRUE, top_n_person = 12,
     person_labels = "none", facet_labels = "flagged")
```

Use `draw = FALSE` or `plot_data(fit, type = "wright")` when you need
the underlying coordinates for a custom `ggplot2`, base-R, or Quarto
graphic.

### Fit df and ZSTD review

FACETS users often compare Infit/Outfit MnSq together with ZStd columns.
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

FACETS `D = ..., G =` group-anchor blocks for differential facet
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

## Producing FACETS-style output files

For traceability or downstream tools that expect FACETS output files,
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

After a FACETS-oriented package-native fit is in hand, the canonical
mfrmr reporting route extends the analysis with:

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
  for the reproducibility bundle alongside the FACETS-style handoff out
  of the box.

The `mfrmr-workflow` vignette covers the full sequence end to end; the
`mfrmr-reporting-and-apa` vignette focuses on the manuscript surface;
the `mfrmr-linking-and-dff` vignette covers anchoring, drift, and DFF in
detail.
