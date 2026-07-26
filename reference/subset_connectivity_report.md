# Build a subset connectivity report (preferred alias)

Build a subset connectivity report (preferred alias)

## Usage

``` r
subset_connectivity_report(
  fit,
  diagnostics = NULL,
  top_n_subsets = NULL,
  min_observations = 0
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- top_n_subsets:

  Optional maximum number of subset rows to keep.

- min_observations:

  Minimum observations required to keep a subset row.

## Value

A named list with subset-connectivity components. Class:
`mfrm_subset_connectivity`.

## Details

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_subset_connectivity` (`type = "subset_observations"`,
`"facet_levels"`, or `"linking_matrix"` / `"coverage_matrix"` /
`"design_matrix"` / `"network"`). The network route returns reusable
node and edge tables with `draw = FALSE`; drawing uses `igraph` when
available.

## Interpreting output

- `summary`: number and size of connected subsets.

- subset table: whether data are fragmented into disconnected
  components.

- facet-level columns: where connectivity bottlenecks occur.

## Typical workflow

1.  Run `subset_connectivity_report(fit)`.

2.  Confirm near-single-subset structure when possible.

3.  Use results to justify linking/anchoring strategy.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md),
[`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md),
[`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
out <- subset_connectivity_report(fit)
summary(out)
#> mfrmr Subset Connectivity Summary 
#>   Class: mfrm_subset_connectivity
#>   Components: 5
#> 
#> Subset overview
#>  Subset Criterion Rater Observations ObservationPercent
#>       1         4     4          768                100
#> 
#> Subset/node rows: listing
#>  Subset     Facet LevelsN
#>       1 Criterion       4
#>       1    Person      48
#>       1     Rater       4
#>                                                                                                                                                                                                                                                                                          Levels
#>                                                                                                                                                                                                                                                       Accuracy, Content, Language, Organization
#>  P001, P002, P003, P004, P005, P006, P007, P008, P009, P010, P011, P012, P013, P014, P015, P016, P017, P018, P019, P020, P021, P022, P023, P024, P025, P026, P027, P028, P029, P030, P031, P032, P033, P034, P035, P036, P037, P038, P039, P040, P041, P042, P043, P044, P045, P046, P047, P048
#>                                                                                                                                                                                                                                                                              R01, R02, R03, R04
#>  Observations ObservationPercent                  Ruler
#>           768                100 [====================]
#>           768                100 [====================]
#>           768                100 [====================]
#> 
#> Settings
#>           Setting Value
#>     top_n_subsets    NA
#>  min_observations     0
#>       is_disjoint FALSE
#> 
#> Notes
#>  - Legacy-compatible Table 6 subset/connectivity report with subset and node
#>    listings.
#>  - Person identifiers are suppressed in this summary. Use `include_person =
#>    TRUE` only under appropriate privacy controls.
p_sub <- plot(out, draw = FALSE)
p_design <- plot(out, type = "design_matrix", draw = FALSE)
p_net <- plot(out, type = "network", draw = FALSE)
p_sub$data$plot
#> [1] "subset_observations"
p_design$data$plot
#> [1] "coverage_matrix"
p_net$data$edges
#>     Subset                   From          To FromFacet    FromLevel ToFacet
#> 1        1     Criterion:Accuracy   Rater:R01 Criterion     Accuracy   Rater
#> 2        1     Criterion:Accuracy   Rater:R02 Criterion     Accuracy   Rater
#> 3        1     Criterion:Accuracy   Rater:R03 Criterion     Accuracy   Rater
#> 4        1     Criterion:Accuracy   Rater:R04 Criterion     Accuracy   Rater
#> 5        1      Criterion:Content   Rater:R01 Criterion      Content   Rater
#> 6        1      Criterion:Content   Rater:R02 Criterion      Content   Rater
#> 7        1      Criterion:Content   Rater:R03 Criterion      Content   Rater
#> 8        1      Criterion:Content   Rater:R04 Criterion      Content   Rater
#> 9        1     Criterion:Language   Rater:R01 Criterion     Language   Rater
#> 10       1     Criterion:Language   Rater:R02 Criterion     Language   Rater
#> 11       1     Criterion:Language   Rater:R03 Criterion     Language   Rater
#> 12       1     Criterion:Language   Rater:R04 Criterion     Language   Rater
#> 13       1 Criterion:Organization   Rater:R01 Criterion Organization   Rater
#> 14       1 Criterion:Organization   Rater:R02 Criterion Organization   Rater
#> 15       1 Criterion:Organization   Rater:R03 Criterion Organization   Rater
#> 16       1 Criterion:Organization   Rater:R04 Criterion Organization   Rater
#> 17       1     Criterion:Accuracy Person:P001 Criterion     Accuracy  Person
#> 18       1     Criterion:Accuracy Person:P002 Criterion     Accuracy  Person
#> 19       1     Criterion:Accuracy Person:P003 Criterion     Accuracy  Person
#> 20       1     Criterion:Accuracy Person:P004 Criterion     Accuracy  Person
#> 21       1     Criterion:Accuracy Person:P005 Criterion     Accuracy  Person
#> 22       1     Criterion:Accuracy Person:P006 Criterion     Accuracy  Person
#> 23       1     Criterion:Accuracy Person:P007 Criterion     Accuracy  Person
#> 24       1     Criterion:Accuracy Person:P008 Criterion     Accuracy  Person
#> 25       1     Criterion:Accuracy Person:P009 Criterion     Accuracy  Person
#> 26       1     Criterion:Accuracy Person:P010 Criterion     Accuracy  Person
#> 27       1     Criterion:Accuracy Person:P011 Criterion     Accuracy  Person
#> 28       1     Criterion:Accuracy Person:P012 Criterion     Accuracy  Person
#> 29       1     Criterion:Accuracy Person:P013 Criterion     Accuracy  Person
#> 30       1     Criterion:Accuracy Person:P014 Criterion     Accuracy  Person
#> 31       1     Criterion:Accuracy Person:P015 Criterion     Accuracy  Person
#> 32       1     Criterion:Accuracy Person:P016 Criterion     Accuracy  Person
#> 33       1     Criterion:Accuracy Person:P017 Criterion     Accuracy  Person
#> 34       1     Criterion:Accuracy Person:P018 Criterion     Accuracy  Person
#> 35       1     Criterion:Accuracy Person:P019 Criterion     Accuracy  Person
#> 36       1     Criterion:Accuracy Person:P020 Criterion     Accuracy  Person
#> 37       1     Criterion:Accuracy Person:P021 Criterion     Accuracy  Person
#> 38       1     Criterion:Accuracy Person:P022 Criterion     Accuracy  Person
#> 39       1     Criterion:Accuracy Person:P023 Criterion     Accuracy  Person
#> 40       1     Criterion:Accuracy Person:P024 Criterion     Accuracy  Person
#> 41       1     Criterion:Accuracy Person:P025 Criterion     Accuracy  Person
#> 42       1     Criterion:Accuracy Person:P026 Criterion     Accuracy  Person
#> 43       1     Criterion:Accuracy Person:P027 Criterion     Accuracy  Person
#> 44       1     Criterion:Accuracy Person:P028 Criterion     Accuracy  Person
#> 45       1     Criterion:Accuracy Person:P029 Criterion     Accuracy  Person
#> 46       1     Criterion:Accuracy Person:P030 Criterion     Accuracy  Person
#> 47       1     Criterion:Accuracy Person:P031 Criterion     Accuracy  Person
#> 48       1     Criterion:Accuracy Person:P032 Criterion     Accuracy  Person
#> 49       1     Criterion:Accuracy Person:P033 Criterion     Accuracy  Person
#> 50       1     Criterion:Accuracy Person:P034 Criterion     Accuracy  Person
#> 51       1     Criterion:Accuracy Person:P035 Criterion     Accuracy  Person
#> 52       1     Criterion:Accuracy Person:P036 Criterion     Accuracy  Person
#> 53       1     Criterion:Accuracy Person:P037 Criterion     Accuracy  Person
#> 54       1     Criterion:Accuracy Person:P038 Criterion     Accuracy  Person
#> 55       1     Criterion:Accuracy Person:P039 Criterion     Accuracy  Person
#> 56       1     Criterion:Accuracy Person:P040 Criterion     Accuracy  Person
#> 57       1     Criterion:Accuracy Person:P041 Criterion     Accuracy  Person
#> 58       1     Criterion:Accuracy Person:P042 Criterion     Accuracy  Person
#> 59       1     Criterion:Accuracy Person:P043 Criterion     Accuracy  Person
#> 60       1     Criterion:Accuracy Person:P044 Criterion     Accuracy  Person
#> 61       1     Criterion:Accuracy Person:P045 Criterion     Accuracy  Person
#> 62       1     Criterion:Accuracy Person:P046 Criterion     Accuracy  Person
#> 63       1     Criterion:Accuracy Person:P047 Criterion     Accuracy  Person
#> 64       1     Criterion:Accuracy Person:P048 Criterion     Accuracy  Person
#> 65       1      Criterion:Content Person:P001 Criterion      Content  Person
#> 66       1      Criterion:Content Person:P002 Criterion      Content  Person
#> 67       1      Criterion:Content Person:P003 Criterion      Content  Person
#> 68       1      Criterion:Content Person:P004 Criterion      Content  Person
#> 69       1      Criterion:Content Person:P005 Criterion      Content  Person
#> 70       1      Criterion:Content Person:P006 Criterion      Content  Person
#> 71       1      Criterion:Content Person:P007 Criterion      Content  Person
#> 72       1      Criterion:Content Person:P008 Criterion      Content  Person
#> 73       1      Criterion:Content Person:P009 Criterion      Content  Person
#> 74       1      Criterion:Content Person:P010 Criterion      Content  Person
#> 75       1      Criterion:Content Person:P011 Criterion      Content  Person
#> 76       1      Criterion:Content Person:P012 Criterion      Content  Person
#> 77       1      Criterion:Content Person:P013 Criterion      Content  Person
#> 78       1      Criterion:Content Person:P014 Criterion      Content  Person
#> 79       1      Criterion:Content Person:P015 Criterion      Content  Person
#> 80       1      Criterion:Content Person:P016 Criterion      Content  Person
#> 81       1      Criterion:Content Person:P017 Criterion      Content  Person
#> 82       1      Criterion:Content Person:P018 Criterion      Content  Person
#> 83       1      Criterion:Content Person:P019 Criterion      Content  Person
#> 84       1      Criterion:Content Person:P020 Criterion      Content  Person
#> 85       1      Criterion:Content Person:P021 Criterion      Content  Person
#> 86       1      Criterion:Content Person:P022 Criterion      Content  Person
#> 87       1      Criterion:Content Person:P023 Criterion      Content  Person
#> 88       1      Criterion:Content Person:P024 Criterion      Content  Person
#> 89       1      Criterion:Content Person:P025 Criterion      Content  Person
#> 90       1      Criterion:Content Person:P026 Criterion      Content  Person
#> 91       1      Criterion:Content Person:P027 Criterion      Content  Person
#> 92       1      Criterion:Content Person:P028 Criterion      Content  Person
#> 93       1      Criterion:Content Person:P029 Criterion      Content  Person
#> 94       1      Criterion:Content Person:P030 Criterion      Content  Person
#> 95       1      Criterion:Content Person:P031 Criterion      Content  Person
#> 96       1      Criterion:Content Person:P032 Criterion      Content  Person
#> 97       1      Criterion:Content Person:P033 Criterion      Content  Person
#> 98       1      Criterion:Content Person:P034 Criterion      Content  Person
#> 99       1      Criterion:Content Person:P035 Criterion      Content  Person
#> 100      1      Criterion:Content Person:P036 Criterion      Content  Person
#> 101      1      Criterion:Content Person:P037 Criterion      Content  Person
#> 102      1      Criterion:Content Person:P038 Criterion      Content  Person
#> 103      1      Criterion:Content Person:P039 Criterion      Content  Person
#> 104      1      Criterion:Content Person:P040 Criterion      Content  Person
#> 105      1      Criterion:Content Person:P041 Criterion      Content  Person
#> 106      1      Criterion:Content Person:P042 Criterion      Content  Person
#> 107      1      Criterion:Content Person:P043 Criterion      Content  Person
#> 108      1      Criterion:Content Person:P044 Criterion      Content  Person
#> 109      1      Criterion:Content Person:P045 Criterion      Content  Person
#> 110      1      Criterion:Content Person:P046 Criterion      Content  Person
#> 111      1      Criterion:Content Person:P047 Criterion      Content  Person
#> 112      1      Criterion:Content Person:P048 Criterion      Content  Person
#> 113      1     Criterion:Language Person:P001 Criterion     Language  Person
#> 114      1     Criterion:Language Person:P002 Criterion     Language  Person
#> 115      1     Criterion:Language Person:P003 Criterion     Language  Person
#> 116      1     Criterion:Language Person:P004 Criterion     Language  Person
#> 117      1     Criterion:Language Person:P005 Criterion     Language  Person
#> 118      1     Criterion:Language Person:P006 Criterion     Language  Person
#> 119      1     Criterion:Language Person:P007 Criterion     Language  Person
#> 120      1     Criterion:Language Person:P008 Criterion     Language  Person
#> 121      1     Criterion:Language Person:P009 Criterion     Language  Person
#> 122      1     Criterion:Language Person:P010 Criterion     Language  Person
#> 123      1     Criterion:Language Person:P011 Criterion     Language  Person
#> 124      1     Criterion:Language Person:P012 Criterion     Language  Person
#> 125      1     Criterion:Language Person:P013 Criterion     Language  Person
#> 126      1     Criterion:Language Person:P014 Criterion     Language  Person
#> 127      1     Criterion:Language Person:P015 Criterion     Language  Person
#> 128      1     Criterion:Language Person:P016 Criterion     Language  Person
#> 129      1     Criterion:Language Person:P017 Criterion     Language  Person
#> 130      1     Criterion:Language Person:P018 Criterion     Language  Person
#> 131      1     Criterion:Language Person:P019 Criterion     Language  Person
#> 132      1     Criterion:Language Person:P020 Criterion     Language  Person
#> 133      1     Criterion:Language Person:P021 Criterion     Language  Person
#> 134      1     Criterion:Language Person:P022 Criterion     Language  Person
#> 135      1     Criterion:Language Person:P023 Criterion     Language  Person
#> 136      1     Criterion:Language Person:P024 Criterion     Language  Person
#> 137      1     Criterion:Language Person:P025 Criterion     Language  Person
#> 138      1     Criterion:Language Person:P026 Criterion     Language  Person
#> 139      1     Criterion:Language Person:P027 Criterion     Language  Person
#> 140      1     Criterion:Language Person:P028 Criterion     Language  Person
#> 141      1     Criterion:Language Person:P029 Criterion     Language  Person
#> 142      1     Criterion:Language Person:P030 Criterion     Language  Person
#> 143      1     Criterion:Language Person:P031 Criterion     Language  Person
#> 144      1     Criterion:Language Person:P032 Criterion     Language  Person
#> 145      1     Criterion:Language Person:P033 Criterion     Language  Person
#> 146      1     Criterion:Language Person:P034 Criterion     Language  Person
#> 147      1     Criterion:Language Person:P035 Criterion     Language  Person
#> 148      1     Criterion:Language Person:P036 Criterion     Language  Person
#> 149      1     Criterion:Language Person:P037 Criterion     Language  Person
#> 150      1     Criterion:Language Person:P038 Criterion     Language  Person
#> 151      1     Criterion:Language Person:P039 Criterion     Language  Person
#> 152      1     Criterion:Language Person:P040 Criterion     Language  Person
#> 153      1     Criterion:Language Person:P041 Criterion     Language  Person
#> 154      1     Criterion:Language Person:P042 Criterion     Language  Person
#> 155      1     Criterion:Language Person:P043 Criterion     Language  Person
#> 156      1     Criterion:Language Person:P044 Criterion     Language  Person
#> 157      1     Criterion:Language Person:P045 Criterion     Language  Person
#> 158      1     Criterion:Language Person:P046 Criterion     Language  Person
#> 159      1     Criterion:Language Person:P047 Criterion     Language  Person
#> 160      1     Criterion:Language Person:P048 Criterion     Language  Person
#> 161      1 Criterion:Organization Person:P001 Criterion Organization  Person
#> 162      1 Criterion:Organization Person:P002 Criterion Organization  Person
#> 163      1 Criterion:Organization Person:P003 Criterion Organization  Person
#> 164      1 Criterion:Organization Person:P004 Criterion Organization  Person
#> 165      1 Criterion:Organization Person:P005 Criterion Organization  Person
#> 166      1 Criterion:Organization Person:P006 Criterion Organization  Person
#> 167      1 Criterion:Organization Person:P007 Criterion Organization  Person
#> 168      1 Criterion:Organization Person:P008 Criterion Organization  Person
#> 169      1 Criterion:Organization Person:P009 Criterion Organization  Person
#> 170      1 Criterion:Organization Person:P010 Criterion Organization  Person
#> 171      1 Criterion:Organization Person:P011 Criterion Organization  Person
#> 172      1 Criterion:Organization Person:P012 Criterion Organization  Person
#> 173      1 Criterion:Organization Person:P013 Criterion Organization  Person
#> 174      1 Criterion:Organization Person:P014 Criterion Organization  Person
#> 175      1 Criterion:Organization Person:P015 Criterion Organization  Person
#> 176      1 Criterion:Organization Person:P016 Criterion Organization  Person
#> 177      1 Criterion:Organization Person:P017 Criterion Organization  Person
#> 178      1 Criterion:Organization Person:P018 Criterion Organization  Person
#> 179      1 Criterion:Organization Person:P019 Criterion Organization  Person
#> 180      1 Criterion:Organization Person:P020 Criterion Organization  Person
#> 181      1 Criterion:Organization Person:P021 Criterion Organization  Person
#> 182      1 Criterion:Organization Person:P022 Criterion Organization  Person
#> 183      1 Criterion:Organization Person:P023 Criterion Organization  Person
#> 184      1 Criterion:Organization Person:P024 Criterion Organization  Person
#> 185      1 Criterion:Organization Person:P025 Criterion Organization  Person
#> 186      1 Criterion:Organization Person:P026 Criterion Organization  Person
#> 187      1 Criterion:Organization Person:P027 Criterion Organization  Person
#> 188      1 Criterion:Organization Person:P028 Criterion Organization  Person
#> 189      1 Criterion:Organization Person:P029 Criterion Organization  Person
#> 190      1 Criterion:Organization Person:P030 Criterion Organization  Person
#> 191      1 Criterion:Organization Person:P031 Criterion Organization  Person
#> 192      1 Criterion:Organization Person:P032 Criterion Organization  Person
#> 193      1 Criterion:Organization Person:P033 Criterion Organization  Person
#> 194      1 Criterion:Organization Person:P034 Criterion Organization  Person
#> 195      1 Criterion:Organization Person:P035 Criterion Organization  Person
#> 196      1 Criterion:Organization Person:P036 Criterion Organization  Person
#> 197      1 Criterion:Organization Person:P037 Criterion Organization  Person
#> 198      1 Criterion:Organization Person:P038 Criterion Organization  Person
#> 199      1 Criterion:Organization Person:P039 Criterion Organization  Person
#> 200      1 Criterion:Organization Person:P040 Criterion Organization  Person
#> 201      1 Criterion:Organization Person:P041 Criterion Organization  Person
#> 202      1 Criterion:Organization Person:P042 Criterion Organization  Person
#> 203      1 Criterion:Organization Person:P043 Criterion Organization  Person
#> 204      1 Criterion:Organization Person:P044 Criterion Organization  Person
#> 205      1 Criterion:Organization Person:P045 Criterion Organization  Person
#> 206      1 Criterion:Organization Person:P046 Criterion Organization  Person
#> 207      1 Criterion:Organization Person:P047 Criterion Organization  Person
#> 208      1 Criterion:Organization Person:P048 Criterion Organization  Person
#> 209      1            Person:P001   Rater:R01    Person         P001   Rater
#> 210      1            Person:P001   Rater:R02    Person         P001   Rater
#> 211      1            Person:P001   Rater:R03    Person         P001   Rater
#> 212      1            Person:P001   Rater:R04    Person         P001   Rater
#> 213      1            Person:P002   Rater:R01    Person         P002   Rater
#> 214      1            Person:P002   Rater:R02    Person         P002   Rater
#> 215      1            Person:P002   Rater:R03    Person         P002   Rater
#> 216      1            Person:P002   Rater:R04    Person         P002   Rater
#> 217      1            Person:P003   Rater:R01    Person         P003   Rater
#> 218      1            Person:P003   Rater:R02    Person         P003   Rater
#> 219      1            Person:P003   Rater:R03    Person         P003   Rater
#> 220      1            Person:P003   Rater:R04    Person         P003   Rater
#> 221      1            Person:P004   Rater:R01    Person         P004   Rater
#> 222      1            Person:P004   Rater:R02    Person         P004   Rater
#> 223      1            Person:P004   Rater:R03    Person         P004   Rater
#> 224      1            Person:P004   Rater:R04    Person         P004   Rater
#> 225      1            Person:P005   Rater:R01    Person         P005   Rater
#> 226      1            Person:P005   Rater:R02    Person         P005   Rater
#> 227      1            Person:P005   Rater:R03    Person         P005   Rater
#> 228      1            Person:P005   Rater:R04    Person         P005   Rater
#> 229      1            Person:P006   Rater:R01    Person         P006   Rater
#> 230      1            Person:P006   Rater:R02    Person         P006   Rater
#> 231      1            Person:P006   Rater:R03    Person         P006   Rater
#> 232      1            Person:P006   Rater:R04    Person         P006   Rater
#> 233      1            Person:P007   Rater:R01    Person         P007   Rater
#> 234      1            Person:P007   Rater:R02    Person         P007   Rater
#> 235      1            Person:P007   Rater:R03    Person         P007   Rater
#> 236      1            Person:P007   Rater:R04    Person         P007   Rater
#> 237      1            Person:P008   Rater:R01    Person         P008   Rater
#> 238      1            Person:P008   Rater:R02    Person         P008   Rater
#> 239      1            Person:P008   Rater:R03    Person         P008   Rater
#> 240      1            Person:P008   Rater:R04    Person         P008   Rater
#> 241      1            Person:P009   Rater:R01    Person         P009   Rater
#> 242      1            Person:P009   Rater:R02    Person         P009   Rater
#> 243      1            Person:P009   Rater:R03    Person         P009   Rater
#> 244      1            Person:P009   Rater:R04    Person         P009   Rater
#> 245      1            Person:P010   Rater:R01    Person         P010   Rater
#> 246      1            Person:P010   Rater:R02    Person         P010   Rater
#> 247      1            Person:P010   Rater:R03    Person         P010   Rater
#> 248      1            Person:P010   Rater:R04    Person         P010   Rater
#> 249      1            Person:P011   Rater:R01    Person         P011   Rater
#> 250      1            Person:P011   Rater:R02    Person         P011   Rater
#> 251      1            Person:P011   Rater:R03    Person         P011   Rater
#> 252      1            Person:P011   Rater:R04    Person         P011   Rater
#> 253      1            Person:P012   Rater:R01    Person         P012   Rater
#> 254      1            Person:P012   Rater:R02    Person         P012   Rater
#> 255      1            Person:P012   Rater:R03    Person         P012   Rater
#> 256      1            Person:P012   Rater:R04    Person         P012   Rater
#> 257      1            Person:P013   Rater:R01    Person         P013   Rater
#> 258      1            Person:P013   Rater:R02    Person         P013   Rater
#> 259      1            Person:P013   Rater:R03    Person         P013   Rater
#> 260      1            Person:P013   Rater:R04    Person         P013   Rater
#> 261      1            Person:P014   Rater:R01    Person         P014   Rater
#> 262      1            Person:P014   Rater:R02    Person         P014   Rater
#> 263      1            Person:P014   Rater:R03    Person         P014   Rater
#> 264      1            Person:P014   Rater:R04    Person         P014   Rater
#> 265      1            Person:P015   Rater:R01    Person         P015   Rater
#> 266      1            Person:P015   Rater:R02    Person         P015   Rater
#> 267      1            Person:P015   Rater:R03    Person         P015   Rater
#> 268      1            Person:P015   Rater:R04    Person         P015   Rater
#> 269      1            Person:P016   Rater:R01    Person         P016   Rater
#> 270      1            Person:P016   Rater:R02    Person         P016   Rater
#> 271      1            Person:P016   Rater:R03    Person         P016   Rater
#> 272      1            Person:P016   Rater:R04    Person         P016   Rater
#> 273      1            Person:P017   Rater:R01    Person         P017   Rater
#> 274      1            Person:P017   Rater:R02    Person         P017   Rater
#> 275      1            Person:P017   Rater:R03    Person         P017   Rater
#> 276      1            Person:P017   Rater:R04    Person         P017   Rater
#> 277      1            Person:P018   Rater:R01    Person         P018   Rater
#> 278      1            Person:P018   Rater:R02    Person         P018   Rater
#> 279      1            Person:P018   Rater:R03    Person         P018   Rater
#> 280      1            Person:P018   Rater:R04    Person         P018   Rater
#> 281      1            Person:P019   Rater:R01    Person         P019   Rater
#> 282      1            Person:P019   Rater:R02    Person         P019   Rater
#> 283      1            Person:P019   Rater:R03    Person         P019   Rater
#> 284      1            Person:P019   Rater:R04    Person         P019   Rater
#> 285      1            Person:P020   Rater:R01    Person         P020   Rater
#> 286      1            Person:P020   Rater:R02    Person         P020   Rater
#> 287      1            Person:P020   Rater:R03    Person         P020   Rater
#> 288      1            Person:P020   Rater:R04    Person         P020   Rater
#> 289      1            Person:P021   Rater:R01    Person         P021   Rater
#> 290      1            Person:P021   Rater:R02    Person         P021   Rater
#> 291      1            Person:P021   Rater:R03    Person         P021   Rater
#> 292      1            Person:P021   Rater:R04    Person         P021   Rater
#> 293      1            Person:P022   Rater:R01    Person         P022   Rater
#> 294      1            Person:P022   Rater:R02    Person         P022   Rater
#> 295      1            Person:P022   Rater:R03    Person         P022   Rater
#> 296      1            Person:P022   Rater:R04    Person         P022   Rater
#> 297      1            Person:P023   Rater:R01    Person         P023   Rater
#> 298      1            Person:P023   Rater:R02    Person         P023   Rater
#> 299      1            Person:P023   Rater:R03    Person         P023   Rater
#> 300      1            Person:P023   Rater:R04    Person         P023   Rater
#> 301      1            Person:P024   Rater:R01    Person         P024   Rater
#> 302      1            Person:P024   Rater:R02    Person         P024   Rater
#> 303      1            Person:P024   Rater:R03    Person         P024   Rater
#> 304      1            Person:P024   Rater:R04    Person         P024   Rater
#> 305      1            Person:P025   Rater:R01    Person         P025   Rater
#> 306      1            Person:P025   Rater:R02    Person         P025   Rater
#> 307      1            Person:P025   Rater:R03    Person         P025   Rater
#> 308      1            Person:P025   Rater:R04    Person         P025   Rater
#> 309      1            Person:P026   Rater:R01    Person         P026   Rater
#> 310      1            Person:P026   Rater:R02    Person         P026   Rater
#> 311      1            Person:P026   Rater:R03    Person         P026   Rater
#> 312      1            Person:P026   Rater:R04    Person         P026   Rater
#> 313      1            Person:P027   Rater:R01    Person         P027   Rater
#> 314      1            Person:P027   Rater:R02    Person         P027   Rater
#> 315      1            Person:P027   Rater:R03    Person         P027   Rater
#> 316      1            Person:P027   Rater:R04    Person         P027   Rater
#> 317      1            Person:P028   Rater:R01    Person         P028   Rater
#> 318      1            Person:P028   Rater:R02    Person         P028   Rater
#> 319      1            Person:P028   Rater:R03    Person         P028   Rater
#> 320      1            Person:P028   Rater:R04    Person         P028   Rater
#> 321      1            Person:P029   Rater:R01    Person         P029   Rater
#> 322      1            Person:P029   Rater:R02    Person         P029   Rater
#> 323      1            Person:P029   Rater:R03    Person         P029   Rater
#> 324      1            Person:P029   Rater:R04    Person         P029   Rater
#> 325      1            Person:P030   Rater:R01    Person         P030   Rater
#> 326      1            Person:P030   Rater:R02    Person         P030   Rater
#> 327      1            Person:P030   Rater:R03    Person         P030   Rater
#> 328      1            Person:P030   Rater:R04    Person         P030   Rater
#> 329      1            Person:P031   Rater:R01    Person         P031   Rater
#> 330      1            Person:P031   Rater:R02    Person         P031   Rater
#> 331      1            Person:P031   Rater:R03    Person         P031   Rater
#> 332      1            Person:P031   Rater:R04    Person         P031   Rater
#> 333      1            Person:P032   Rater:R01    Person         P032   Rater
#> 334      1            Person:P032   Rater:R02    Person         P032   Rater
#> 335      1            Person:P032   Rater:R03    Person         P032   Rater
#> 336      1            Person:P032   Rater:R04    Person         P032   Rater
#> 337      1            Person:P033   Rater:R01    Person         P033   Rater
#> 338      1            Person:P033   Rater:R02    Person         P033   Rater
#> 339      1            Person:P033   Rater:R03    Person         P033   Rater
#> 340      1            Person:P033   Rater:R04    Person         P033   Rater
#> 341      1            Person:P034   Rater:R01    Person         P034   Rater
#> 342      1            Person:P034   Rater:R02    Person         P034   Rater
#> 343      1            Person:P034   Rater:R03    Person         P034   Rater
#> 344      1            Person:P034   Rater:R04    Person         P034   Rater
#> 345      1            Person:P035   Rater:R01    Person         P035   Rater
#> 346      1            Person:P035   Rater:R02    Person         P035   Rater
#> 347      1            Person:P035   Rater:R03    Person         P035   Rater
#> 348      1            Person:P035   Rater:R04    Person         P035   Rater
#> 349      1            Person:P036   Rater:R01    Person         P036   Rater
#> 350      1            Person:P036   Rater:R02    Person         P036   Rater
#> 351      1            Person:P036   Rater:R03    Person         P036   Rater
#> 352      1            Person:P036   Rater:R04    Person         P036   Rater
#> 353      1            Person:P037   Rater:R01    Person         P037   Rater
#> 354      1            Person:P037   Rater:R02    Person         P037   Rater
#> 355      1            Person:P037   Rater:R03    Person         P037   Rater
#> 356      1            Person:P037   Rater:R04    Person         P037   Rater
#> 357      1            Person:P038   Rater:R01    Person         P038   Rater
#> 358      1            Person:P038   Rater:R02    Person         P038   Rater
#> 359      1            Person:P038   Rater:R03    Person         P038   Rater
#> 360      1            Person:P038   Rater:R04    Person         P038   Rater
#> 361      1            Person:P039   Rater:R01    Person         P039   Rater
#> 362      1            Person:P039   Rater:R02    Person         P039   Rater
#> 363      1            Person:P039   Rater:R03    Person         P039   Rater
#> 364      1            Person:P039   Rater:R04    Person         P039   Rater
#> 365      1            Person:P040   Rater:R01    Person         P040   Rater
#> 366      1            Person:P040   Rater:R02    Person         P040   Rater
#> 367      1            Person:P040   Rater:R03    Person         P040   Rater
#> 368      1            Person:P040   Rater:R04    Person         P040   Rater
#> 369      1            Person:P041   Rater:R01    Person         P041   Rater
#> 370      1            Person:P041   Rater:R02    Person         P041   Rater
#> 371      1            Person:P041   Rater:R03    Person         P041   Rater
#> 372      1            Person:P041   Rater:R04    Person         P041   Rater
#> 373      1            Person:P042   Rater:R01    Person         P042   Rater
#> 374      1            Person:P042   Rater:R02    Person         P042   Rater
#> 375      1            Person:P042   Rater:R03    Person         P042   Rater
#> 376      1            Person:P042   Rater:R04    Person         P042   Rater
#> 377      1            Person:P043   Rater:R01    Person         P043   Rater
#> 378      1            Person:P043   Rater:R02    Person         P043   Rater
#> 379      1            Person:P043   Rater:R03    Person         P043   Rater
#> 380      1            Person:P043   Rater:R04    Person         P043   Rater
#> 381      1            Person:P044   Rater:R01    Person         P044   Rater
#> 382      1            Person:P044   Rater:R02    Person         P044   Rater
#> 383      1            Person:P044   Rater:R03    Person         P044   Rater
#> 384      1            Person:P044   Rater:R04    Person         P044   Rater
#> 385      1            Person:P045   Rater:R01    Person         P045   Rater
#> 386      1            Person:P045   Rater:R02    Person         P045   Rater
#> 387      1            Person:P045   Rater:R03    Person         P045   Rater
#> 388      1            Person:P045   Rater:R04    Person         P045   Rater
#> 389      1            Person:P046   Rater:R01    Person         P046   Rater
#> 390      1            Person:P046   Rater:R02    Person         P046   Rater
#> 391      1            Person:P046   Rater:R03    Person         P046   Rater
#> 392      1            Person:P046   Rater:R04    Person         P046   Rater
#> 393      1            Person:P047   Rater:R01    Person         P047   Rater
#> 394      1            Person:P047   Rater:R02    Person         P047   Rater
#> 395      1            Person:P047   Rater:R03    Person         P047   Rater
#> 396      1            Person:P047   Rater:R04    Person         P047   Rater
#> 397      1            Person:P048   Rater:R01    Person         P048   Rater
#> 398      1            Person:P048   Rater:R02    Person         P048   Rater
#> 399      1            Person:P048   Rater:R03    Person         P048   Rater
#> 400      1            Person:P048   Rater:R04    Person         P048   Rater
#>     ToLevel Weight
#> 1       R01     48
#> 2       R02     48
#> 3       R03     48
#> 4       R04     48
#> 5       R01     48
#> 6       R02     48
#> 7       R03     48
#> 8       R04     48
#> 9       R01     48
#> 10      R02     48
#> 11      R03     48
#> 12      R04     48
#> 13      R01     48
#> 14      R02     48
#> 15      R03     48
#> 16      R04     48
#> 17     P001      4
#> 18     P002      4
#> 19     P003      4
#> 20     P004      4
#> 21     P005      4
#> 22     P006      4
#> 23     P007      4
#> 24     P008      4
#> 25     P009      4
#> 26     P010      4
#> 27     P011      4
#> 28     P012      4
#> 29     P013      4
#> 30     P014      4
#> 31     P015      4
#> 32     P016      4
#> 33     P017      4
#> 34     P018      4
#> 35     P019      4
#> 36     P020      4
#> 37     P021      4
#> 38     P022      4
#> 39     P023      4
#> 40     P024      4
#> 41     P025      4
#> 42     P026      4
#> 43     P027      4
#> 44     P028      4
#> 45     P029      4
#> 46     P030      4
#> 47     P031      4
#> 48     P032      4
#> 49     P033      4
#> 50     P034      4
#> 51     P035      4
#> 52     P036      4
#> 53     P037      4
#> 54     P038      4
#> 55     P039      4
#> 56     P040      4
#> 57     P041      4
#> 58     P042      4
#> 59     P043      4
#> 60     P044      4
#> 61     P045      4
#> 62     P046      4
#> 63     P047      4
#> 64     P048      4
#> 65     P001      4
#> 66     P002      4
#> 67     P003      4
#> 68     P004      4
#> 69     P005      4
#> 70     P006      4
#> 71     P007      4
#> 72     P008      4
#> 73     P009      4
#> 74     P010      4
#> 75     P011      4
#> 76     P012      4
#> 77     P013      4
#> 78     P014      4
#> 79     P015      4
#> 80     P016      4
#> 81     P017      4
#> 82     P018      4
#> 83     P019      4
#> 84     P020      4
#> 85     P021      4
#> 86     P022      4
#> 87     P023      4
#> 88     P024      4
#> 89     P025      4
#> 90     P026      4
#> 91     P027      4
#> 92     P028      4
#> 93     P029      4
#> 94     P030      4
#> 95     P031      4
#> 96     P032      4
#> 97     P033      4
#> 98     P034      4
#> 99     P035      4
#> 100    P036      4
#> 101    P037      4
#> 102    P038      4
#> 103    P039      4
#> 104    P040      4
#> 105    P041      4
#> 106    P042      4
#> 107    P043      4
#> 108    P044      4
#> 109    P045      4
#> 110    P046      4
#> 111    P047      4
#> 112    P048      4
#> 113    P001      4
#> 114    P002      4
#> 115    P003      4
#> 116    P004      4
#> 117    P005      4
#> 118    P006      4
#> 119    P007      4
#> 120    P008      4
#> 121    P009      4
#> 122    P010      4
#> 123    P011      4
#> 124    P012      4
#> 125    P013      4
#> 126    P014      4
#> 127    P015      4
#> 128    P016      4
#> 129    P017      4
#> 130    P018      4
#> 131    P019      4
#> 132    P020      4
#> 133    P021      4
#> 134    P022      4
#> 135    P023      4
#> 136    P024      4
#> 137    P025      4
#> 138    P026      4
#> 139    P027      4
#> 140    P028      4
#> 141    P029      4
#> 142    P030      4
#> 143    P031      4
#> 144    P032      4
#> 145    P033      4
#> 146    P034      4
#> 147    P035      4
#> 148    P036      4
#> 149    P037      4
#> 150    P038      4
#> 151    P039      4
#> 152    P040      4
#> 153    P041      4
#> 154    P042      4
#> 155    P043      4
#> 156    P044      4
#> 157    P045      4
#> 158    P046      4
#> 159    P047      4
#> 160    P048      4
#> 161    P001      4
#> 162    P002      4
#> 163    P003      4
#> 164    P004      4
#> 165    P005      4
#> 166    P006      4
#> 167    P007      4
#> 168    P008      4
#> 169    P009      4
#> 170    P010      4
#> 171    P011      4
#> 172    P012      4
#> 173    P013      4
#> 174    P014      4
#> 175    P015      4
#> 176    P016      4
#> 177    P017      4
#> 178    P018      4
#> 179    P019      4
#> 180    P020      4
#> 181    P021      4
#> 182    P022      4
#> 183    P023      4
#> 184    P024      4
#> 185    P025      4
#> 186    P026      4
#> 187    P027      4
#> 188    P028      4
#> 189    P029      4
#> 190    P030      4
#> 191    P031      4
#> 192    P032      4
#> 193    P033      4
#> 194    P034      4
#> 195    P035      4
#> 196    P036      4
#> 197    P037      4
#> 198    P038      4
#> 199    P039      4
#> 200    P040      4
#> 201    P041      4
#> 202    P042      4
#> 203    P043      4
#> 204    P044      4
#> 205    P045      4
#> 206    P046      4
#> 207    P047      4
#> 208    P048      4
#> 209     R01      4
#> 210     R02      4
#> 211     R03      4
#> 212     R04      4
#> 213     R01      4
#> 214     R02      4
#> 215     R03      4
#> 216     R04      4
#> 217     R01      4
#> 218     R02      4
#> 219     R03      4
#> 220     R04      4
#> 221     R01      4
#> 222     R02      4
#> 223     R03      4
#> 224     R04      4
#> 225     R01      4
#> 226     R02      4
#> 227     R03      4
#> 228     R04      4
#> 229     R01      4
#> 230     R02      4
#> 231     R03      4
#> 232     R04      4
#> 233     R01      4
#> 234     R02      4
#> 235     R03      4
#> 236     R04      4
#> 237     R01      4
#> 238     R02      4
#> 239     R03      4
#> 240     R04      4
#> 241     R01      4
#> 242     R02      4
#> 243     R03      4
#> 244     R04      4
#> 245     R01      4
#> 246     R02      4
#> 247     R03      4
#> 248     R04      4
#> 249     R01      4
#> 250     R02      4
#> 251     R03      4
#> 252     R04      4
#> 253     R01      4
#> 254     R02      4
#> 255     R03      4
#> 256     R04      4
#> 257     R01      4
#> 258     R02      4
#> 259     R03      4
#> 260     R04      4
#> 261     R01      4
#> 262     R02      4
#> 263     R03      4
#> 264     R04      4
#> 265     R01      4
#> 266     R02      4
#> 267     R03      4
#> 268     R04      4
#> 269     R01      4
#> 270     R02      4
#> 271     R03      4
#> 272     R04      4
#> 273     R01      4
#> 274     R02      4
#> 275     R03      4
#> 276     R04      4
#> 277     R01      4
#> 278     R02      4
#> 279     R03      4
#> 280     R04      4
#> 281     R01      4
#> 282     R02      4
#> 283     R03      4
#> 284     R04      4
#> 285     R01      4
#> 286     R02      4
#> 287     R03      4
#> 288     R04      4
#> 289     R01      4
#> 290     R02      4
#> 291     R03      4
#> 292     R04      4
#> 293     R01      4
#> 294     R02      4
#> 295     R03      4
#> 296     R04      4
#> 297     R01      4
#> 298     R02      4
#> 299     R03      4
#> 300     R04      4
#> 301     R01      4
#> 302     R02      4
#> 303     R03      4
#> 304     R04      4
#> 305     R01      4
#> 306     R02      4
#> 307     R03      4
#> 308     R04      4
#> 309     R01      4
#> 310     R02      4
#> 311     R03      4
#> 312     R04      4
#> 313     R01      4
#> 314     R02      4
#> 315     R03      4
#> 316     R04      4
#> 317     R01      4
#> 318     R02      4
#> 319     R03      4
#> 320     R04      4
#> 321     R01      4
#> 322     R02      4
#> 323     R03      4
#> 324     R04      4
#> 325     R01      4
#> 326     R02      4
#> 327     R03      4
#> 328     R04      4
#> 329     R01      4
#> 330     R02      4
#> 331     R03      4
#> 332     R04      4
#> 333     R01      4
#> 334     R02      4
#> 335     R03      4
#> 336     R04      4
#> 337     R01      4
#> 338     R02      4
#> 339     R03      4
#> 340     R04      4
#> 341     R01      4
#> 342     R02      4
#> 343     R03      4
#> 344     R04      4
#> 345     R01      4
#> 346     R02      4
#> 347     R03      4
#> 348     R04      4
#> 349     R01      4
#> 350     R02      4
#> 351     R03      4
#> 352     R04      4
#> 353     R01      4
#> 354     R02      4
#> 355     R03      4
#> 356     R04      4
#> 357     R01      4
#> 358     R02      4
#> 359     R03      4
#> 360     R04      4
#> 361     R01      4
#> 362     R02      4
#> 363     R03      4
#> 364     R04      4
#> 365     R01      4
#> 366     R02      4
#> 367     R03      4
#> 368     R04      4
#> 369     R01      4
#> 370     R02      4
#> 371     R03      4
#> 372     R04      4
#> 373     R01      4
#> 374     R02      4
#> 375     R03      4
#> 376     R04      4
#> 377     R01      4
#> 378     R02      4
#> 379     R03      4
#> 380     R04      4
#> 381     R01      4
#> 382     R02      4
#> 383     R03      4
#> 384     R04      4
#> 385     R01      4
#> 386     R02      4
#> 387     R03      4
#> 388     R04      4
#> 389     R01      4
#> 390     R02      4
#> 391     R03      4
#> 392     R04      4
#> 393     R01      4
#> 394     R02      4
#> 395     R03      4
#> 396     R04      4
#> 397     R01      4
#> 398     R02      4
#> 399     R03      4
#> 400     R04      4
out$summary[, c("Subset", "Observations", "ObservationPercent")]
#>   Subset Observations ObservationPercent
#> 1      1          768                100
# }
```
