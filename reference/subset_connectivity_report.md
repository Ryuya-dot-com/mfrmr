# Build a subset connectivity report (preferred alias)

Build a subset connectivity report (preferred alias)

## Usage

``` r
subset_connectivity_report(
  fit = NULL,
  diagnostics = NULL,
  top_n_subsets = NULL,
  min_observations = 0,
  data = NULL,
  person = NULL,
  facets = NULL,
  score = NULL,
  basis = c("observed", "planned"),
  weight = NULL
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

- data:

  Optional raw assignment/rating data, supplied instead of `fit`.

- person, facets:

  Names of the person column and one or more facet columns in `data`.
  Include only Rater in `facets` to inspect person-rater links without a
  common Criterion node obscuring separate panels.

- score:

  Numeric score column for `basis = "observed"`. Recode study-specific
  missing markers to `NA` first; no category recoding or estimation is
  done.

- basis:

  `"observed"` includes rows with complete identifiers and nonmissing
  finite scores; `"planned"` includes complete assignment rows without
  scores. Planned networks require `score = NULL` and `weight = NULL`.

- weight:

  Optional numeric weight column for observed raw data. Missing and
  zero-weight rows do not create edges. Edge weights still count rows,
  not sampling weights. Negative or infinite weights are refused.

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

2.  Inspect graph coverage alongside `identification_audit`. A common
    criterion can connect panels whose person/rater locations remain
    confounded.

3.  Use the model rank and population assumptions to assess linking; a
    single co-observation component is not a FACETS identification
    subset.

## Before fitting

Supply `data`, `person`, `facets` and `score` instead of `fit`. Known
levels from incomplete/unscored rows remain as nodes, including
isolates. A planned assignment roster can be examined with
`basis = "planned"`; absent assignments cannot be reconstructed from an
observed-only file. `row_usage` records each input row's inclusion and
first exclusion reason. With a fit, only its retained rows are available
here; review original missing assignments before fitting. No prefit
result supplies an identification audit or model-readiness decision.
`settings$is_disjoint` describes the source graph, even when subset
filters omit components; compare source/retained subset counts. Filters
do not establish linking. See
[`vignette("mfrmr-networks-and-reporting")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-networks-and-reporting.md)
for a panel example.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md),
[`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md),
[`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
out <- subset_connectivity_report(fit)
summary(out)
#> mfrmr Subset Connectivity Summary 
#>   Class: mfrm_subset_connectivity
#>   Components: 7
#> 
#> Subset overview
#>  Subset Observations Rater Criterion ObservationPercent
#>       1          768     4         4                100
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
#>           Setting             Value
#>     top_n_subsets                NA
#>  min_observations                 0
#>    source_subsets                 1
#>  retained_subsets                 1
#>       is_disjoint             FALSE
#>             basis          observed
#>            person            Person
#>            facets  Rater, Criterion
#>             score             Score
#>            weight            Weight
#>        input_rows               768
#>     included_rows               768
#>            source fit_retained_rows
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
#>                       From          To FromFacet    FromLevel ToFacet ToLevel
#> 1       Criterion:Accuracy   Rater:R01 Criterion     Accuracy   Rater     R01
#> 2       Criterion:Accuracy   Rater:R02 Criterion     Accuracy   Rater     R02
#> 3       Criterion:Accuracy   Rater:R03 Criterion     Accuracy   Rater     R03
#> 4       Criterion:Accuracy   Rater:R04 Criterion     Accuracy   Rater     R04
#> 5        Criterion:Content   Rater:R01 Criterion      Content   Rater     R01
#> 6        Criterion:Content   Rater:R02 Criterion      Content   Rater     R02
#> 7        Criterion:Content   Rater:R03 Criterion      Content   Rater     R03
#> 8        Criterion:Content   Rater:R04 Criterion      Content   Rater     R04
#> 9       Criterion:Language   Rater:R01 Criterion     Language   Rater     R01
#> 10      Criterion:Language   Rater:R02 Criterion     Language   Rater     R02
#> 11      Criterion:Language   Rater:R03 Criterion     Language   Rater     R03
#> 12      Criterion:Language   Rater:R04 Criterion     Language   Rater     R04
#> 13  Criterion:Organization   Rater:R01 Criterion Organization   Rater     R01
#> 14  Criterion:Organization   Rater:R02 Criterion Organization   Rater     R02
#> 15  Criterion:Organization   Rater:R03 Criterion Organization   Rater     R03
#> 16  Criterion:Organization   Rater:R04 Criterion Organization   Rater     R04
#> 17      Criterion:Accuracy Person:P001 Criterion     Accuracy  Person    P001
#> 18      Criterion:Accuracy Person:P002 Criterion     Accuracy  Person    P002
#> 19      Criterion:Accuracy Person:P003 Criterion     Accuracy  Person    P003
#> 20      Criterion:Accuracy Person:P004 Criterion     Accuracy  Person    P004
#> 21      Criterion:Accuracy Person:P005 Criterion     Accuracy  Person    P005
#> 22      Criterion:Accuracy Person:P006 Criterion     Accuracy  Person    P006
#> 23      Criterion:Accuracy Person:P007 Criterion     Accuracy  Person    P007
#> 24      Criterion:Accuracy Person:P008 Criterion     Accuracy  Person    P008
#> 25      Criterion:Accuracy Person:P009 Criterion     Accuracy  Person    P009
#> 26      Criterion:Accuracy Person:P010 Criterion     Accuracy  Person    P010
#> 27      Criterion:Accuracy Person:P011 Criterion     Accuracy  Person    P011
#> 28      Criterion:Accuracy Person:P012 Criterion     Accuracy  Person    P012
#> 29      Criterion:Accuracy Person:P013 Criterion     Accuracy  Person    P013
#> 30      Criterion:Accuracy Person:P014 Criterion     Accuracy  Person    P014
#> 31      Criterion:Accuracy Person:P015 Criterion     Accuracy  Person    P015
#> 32      Criterion:Accuracy Person:P016 Criterion     Accuracy  Person    P016
#> 33      Criterion:Accuracy Person:P017 Criterion     Accuracy  Person    P017
#> 34      Criterion:Accuracy Person:P018 Criterion     Accuracy  Person    P018
#> 35      Criterion:Accuracy Person:P019 Criterion     Accuracy  Person    P019
#> 36      Criterion:Accuracy Person:P020 Criterion     Accuracy  Person    P020
#> 37      Criterion:Accuracy Person:P021 Criterion     Accuracy  Person    P021
#> 38      Criterion:Accuracy Person:P022 Criterion     Accuracy  Person    P022
#> 39      Criterion:Accuracy Person:P023 Criterion     Accuracy  Person    P023
#> 40      Criterion:Accuracy Person:P024 Criterion     Accuracy  Person    P024
#> 41      Criterion:Accuracy Person:P025 Criterion     Accuracy  Person    P025
#> 42      Criterion:Accuracy Person:P026 Criterion     Accuracy  Person    P026
#> 43      Criterion:Accuracy Person:P027 Criterion     Accuracy  Person    P027
#> 44      Criterion:Accuracy Person:P028 Criterion     Accuracy  Person    P028
#> 45      Criterion:Accuracy Person:P029 Criterion     Accuracy  Person    P029
#> 46      Criterion:Accuracy Person:P030 Criterion     Accuracy  Person    P030
#> 47      Criterion:Accuracy Person:P031 Criterion     Accuracy  Person    P031
#> 48      Criterion:Accuracy Person:P032 Criterion     Accuracy  Person    P032
#> 49      Criterion:Accuracy Person:P033 Criterion     Accuracy  Person    P033
#> 50      Criterion:Accuracy Person:P034 Criterion     Accuracy  Person    P034
#> 51      Criterion:Accuracy Person:P035 Criterion     Accuracy  Person    P035
#> 52      Criterion:Accuracy Person:P036 Criterion     Accuracy  Person    P036
#> 53      Criterion:Accuracy Person:P037 Criterion     Accuracy  Person    P037
#> 54      Criterion:Accuracy Person:P038 Criterion     Accuracy  Person    P038
#> 55      Criterion:Accuracy Person:P039 Criterion     Accuracy  Person    P039
#> 56      Criterion:Accuracy Person:P040 Criterion     Accuracy  Person    P040
#> 57      Criterion:Accuracy Person:P041 Criterion     Accuracy  Person    P041
#> 58      Criterion:Accuracy Person:P042 Criterion     Accuracy  Person    P042
#> 59      Criterion:Accuracy Person:P043 Criterion     Accuracy  Person    P043
#> 60      Criterion:Accuracy Person:P044 Criterion     Accuracy  Person    P044
#> 61      Criterion:Accuracy Person:P045 Criterion     Accuracy  Person    P045
#> 62      Criterion:Accuracy Person:P046 Criterion     Accuracy  Person    P046
#> 63      Criterion:Accuracy Person:P047 Criterion     Accuracy  Person    P047
#> 64      Criterion:Accuracy Person:P048 Criterion     Accuracy  Person    P048
#> 65       Criterion:Content Person:P001 Criterion      Content  Person    P001
#> 66       Criterion:Content Person:P002 Criterion      Content  Person    P002
#> 67       Criterion:Content Person:P003 Criterion      Content  Person    P003
#> 68       Criterion:Content Person:P004 Criterion      Content  Person    P004
#> 69       Criterion:Content Person:P005 Criterion      Content  Person    P005
#> 70       Criterion:Content Person:P006 Criterion      Content  Person    P006
#> 71       Criterion:Content Person:P007 Criterion      Content  Person    P007
#> 72       Criterion:Content Person:P008 Criterion      Content  Person    P008
#> 73       Criterion:Content Person:P009 Criterion      Content  Person    P009
#> 74       Criterion:Content Person:P010 Criterion      Content  Person    P010
#> 75       Criterion:Content Person:P011 Criterion      Content  Person    P011
#> 76       Criterion:Content Person:P012 Criterion      Content  Person    P012
#> 77       Criterion:Content Person:P013 Criterion      Content  Person    P013
#> 78       Criterion:Content Person:P014 Criterion      Content  Person    P014
#> 79       Criterion:Content Person:P015 Criterion      Content  Person    P015
#> 80       Criterion:Content Person:P016 Criterion      Content  Person    P016
#> 81       Criterion:Content Person:P017 Criterion      Content  Person    P017
#> 82       Criterion:Content Person:P018 Criterion      Content  Person    P018
#> 83       Criterion:Content Person:P019 Criterion      Content  Person    P019
#> 84       Criterion:Content Person:P020 Criterion      Content  Person    P020
#> 85       Criterion:Content Person:P021 Criterion      Content  Person    P021
#> 86       Criterion:Content Person:P022 Criterion      Content  Person    P022
#> 87       Criterion:Content Person:P023 Criterion      Content  Person    P023
#> 88       Criterion:Content Person:P024 Criterion      Content  Person    P024
#> 89       Criterion:Content Person:P025 Criterion      Content  Person    P025
#> 90       Criterion:Content Person:P026 Criterion      Content  Person    P026
#> 91       Criterion:Content Person:P027 Criterion      Content  Person    P027
#> 92       Criterion:Content Person:P028 Criterion      Content  Person    P028
#> 93       Criterion:Content Person:P029 Criterion      Content  Person    P029
#> 94       Criterion:Content Person:P030 Criterion      Content  Person    P030
#> 95       Criterion:Content Person:P031 Criterion      Content  Person    P031
#> 96       Criterion:Content Person:P032 Criterion      Content  Person    P032
#> 97       Criterion:Content Person:P033 Criterion      Content  Person    P033
#> 98       Criterion:Content Person:P034 Criterion      Content  Person    P034
#> 99       Criterion:Content Person:P035 Criterion      Content  Person    P035
#> 100      Criterion:Content Person:P036 Criterion      Content  Person    P036
#> 101      Criterion:Content Person:P037 Criterion      Content  Person    P037
#> 102      Criterion:Content Person:P038 Criterion      Content  Person    P038
#> 103      Criterion:Content Person:P039 Criterion      Content  Person    P039
#> 104      Criterion:Content Person:P040 Criterion      Content  Person    P040
#> 105      Criterion:Content Person:P041 Criterion      Content  Person    P041
#> 106      Criterion:Content Person:P042 Criterion      Content  Person    P042
#> 107      Criterion:Content Person:P043 Criterion      Content  Person    P043
#> 108      Criterion:Content Person:P044 Criterion      Content  Person    P044
#> 109      Criterion:Content Person:P045 Criterion      Content  Person    P045
#> 110      Criterion:Content Person:P046 Criterion      Content  Person    P046
#> 111      Criterion:Content Person:P047 Criterion      Content  Person    P047
#> 112      Criterion:Content Person:P048 Criterion      Content  Person    P048
#> 113     Criterion:Language Person:P001 Criterion     Language  Person    P001
#> 114     Criterion:Language Person:P002 Criterion     Language  Person    P002
#> 115     Criterion:Language Person:P003 Criterion     Language  Person    P003
#> 116     Criterion:Language Person:P004 Criterion     Language  Person    P004
#> 117     Criterion:Language Person:P005 Criterion     Language  Person    P005
#> 118     Criterion:Language Person:P006 Criterion     Language  Person    P006
#> 119     Criterion:Language Person:P007 Criterion     Language  Person    P007
#> 120     Criterion:Language Person:P008 Criterion     Language  Person    P008
#> 121     Criterion:Language Person:P009 Criterion     Language  Person    P009
#> 122     Criterion:Language Person:P010 Criterion     Language  Person    P010
#> 123     Criterion:Language Person:P011 Criterion     Language  Person    P011
#> 124     Criterion:Language Person:P012 Criterion     Language  Person    P012
#> 125     Criterion:Language Person:P013 Criterion     Language  Person    P013
#> 126     Criterion:Language Person:P014 Criterion     Language  Person    P014
#> 127     Criterion:Language Person:P015 Criterion     Language  Person    P015
#> 128     Criterion:Language Person:P016 Criterion     Language  Person    P016
#> 129     Criterion:Language Person:P017 Criterion     Language  Person    P017
#> 130     Criterion:Language Person:P018 Criterion     Language  Person    P018
#> 131     Criterion:Language Person:P019 Criterion     Language  Person    P019
#> 132     Criterion:Language Person:P020 Criterion     Language  Person    P020
#> 133     Criterion:Language Person:P021 Criterion     Language  Person    P021
#> 134     Criterion:Language Person:P022 Criterion     Language  Person    P022
#> 135     Criterion:Language Person:P023 Criterion     Language  Person    P023
#> 136     Criterion:Language Person:P024 Criterion     Language  Person    P024
#> 137     Criterion:Language Person:P025 Criterion     Language  Person    P025
#> 138     Criterion:Language Person:P026 Criterion     Language  Person    P026
#> 139     Criterion:Language Person:P027 Criterion     Language  Person    P027
#> 140     Criterion:Language Person:P028 Criterion     Language  Person    P028
#> 141     Criterion:Language Person:P029 Criterion     Language  Person    P029
#> 142     Criterion:Language Person:P030 Criterion     Language  Person    P030
#> 143     Criterion:Language Person:P031 Criterion     Language  Person    P031
#> 144     Criterion:Language Person:P032 Criterion     Language  Person    P032
#> 145     Criterion:Language Person:P033 Criterion     Language  Person    P033
#> 146     Criterion:Language Person:P034 Criterion     Language  Person    P034
#> 147     Criterion:Language Person:P035 Criterion     Language  Person    P035
#> 148     Criterion:Language Person:P036 Criterion     Language  Person    P036
#> 149     Criterion:Language Person:P037 Criterion     Language  Person    P037
#> 150     Criterion:Language Person:P038 Criterion     Language  Person    P038
#> 151     Criterion:Language Person:P039 Criterion     Language  Person    P039
#> 152     Criterion:Language Person:P040 Criterion     Language  Person    P040
#> 153     Criterion:Language Person:P041 Criterion     Language  Person    P041
#> 154     Criterion:Language Person:P042 Criterion     Language  Person    P042
#> 155     Criterion:Language Person:P043 Criterion     Language  Person    P043
#> 156     Criterion:Language Person:P044 Criterion     Language  Person    P044
#> 157     Criterion:Language Person:P045 Criterion     Language  Person    P045
#> 158     Criterion:Language Person:P046 Criterion     Language  Person    P046
#> 159     Criterion:Language Person:P047 Criterion     Language  Person    P047
#> 160     Criterion:Language Person:P048 Criterion     Language  Person    P048
#> 161 Criterion:Organization Person:P001 Criterion Organization  Person    P001
#> 162 Criterion:Organization Person:P002 Criterion Organization  Person    P002
#> 163 Criterion:Organization Person:P003 Criterion Organization  Person    P003
#> 164 Criterion:Organization Person:P004 Criterion Organization  Person    P004
#> 165 Criterion:Organization Person:P005 Criterion Organization  Person    P005
#> 166 Criterion:Organization Person:P006 Criterion Organization  Person    P006
#> 167 Criterion:Organization Person:P007 Criterion Organization  Person    P007
#> 168 Criterion:Organization Person:P008 Criterion Organization  Person    P008
#> 169 Criterion:Organization Person:P009 Criterion Organization  Person    P009
#> 170 Criterion:Organization Person:P010 Criterion Organization  Person    P010
#> 171 Criterion:Organization Person:P011 Criterion Organization  Person    P011
#> 172 Criterion:Organization Person:P012 Criterion Organization  Person    P012
#> 173 Criterion:Organization Person:P013 Criterion Organization  Person    P013
#> 174 Criterion:Organization Person:P014 Criterion Organization  Person    P014
#> 175 Criterion:Organization Person:P015 Criterion Organization  Person    P015
#> 176 Criterion:Organization Person:P016 Criterion Organization  Person    P016
#> 177 Criterion:Organization Person:P017 Criterion Organization  Person    P017
#> 178 Criterion:Organization Person:P018 Criterion Organization  Person    P018
#> 179 Criterion:Organization Person:P019 Criterion Organization  Person    P019
#> 180 Criterion:Organization Person:P020 Criterion Organization  Person    P020
#> 181 Criterion:Organization Person:P021 Criterion Organization  Person    P021
#> 182 Criterion:Organization Person:P022 Criterion Organization  Person    P022
#> 183 Criterion:Organization Person:P023 Criterion Organization  Person    P023
#> 184 Criterion:Organization Person:P024 Criterion Organization  Person    P024
#> 185 Criterion:Organization Person:P025 Criterion Organization  Person    P025
#> 186 Criterion:Organization Person:P026 Criterion Organization  Person    P026
#> 187 Criterion:Organization Person:P027 Criterion Organization  Person    P027
#> 188 Criterion:Organization Person:P028 Criterion Organization  Person    P028
#> 189 Criterion:Organization Person:P029 Criterion Organization  Person    P029
#> 190 Criterion:Organization Person:P030 Criterion Organization  Person    P030
#> 191 Criterion:Organization Person:P031 Criterion Organization  Person    P031
#> 192 Criterion:Organization Person:P032 Criterion Organization  Person    P032
#> 193 Criterion:Organization Person:P033 Criterion Organization  Person    P033
#> 194 Criterion:Organization Person:P034 Criterion Organization  Person    P034
#> 195 Criterion:Organization Person:P035 Criterion Organization  Person    P035
#> 196 Criterion:Organization Person:P036 Criterion Organization  Person    P036
#> 197 Criterion:Organization Person:P037 Criterion Organization  Person    P037
#> 198 Criterion:Organization Person:P038 Criterion Organization  Person    P038
#> 199 Criterion:Organization Person:P039 Criterion Organization  Person    P039
#> 200 Criterion:Organization Person:P040 Criterion Organization  Person    P040
#> 201 Criterion:Organization Person:P041 Criterion Organization  Person    P041
#> 202 Criterion:Organization Person:P042 Criterion Organization  Person    P042
#> 203 Criterion:Organization Person:P043 Criterion Organization  Person    P043
#> 204 Criterion:Organization Person:P044 Criterion Organization  Person    P044
#> 205 Criterion:Organization Person:P045 Criterion Organization  Person    P045
#> 206 Criterion:Organization Person:P046 Criterion Organization  Person    P046
#> 207 Criterion:Organization Person:P047 Criterion Organization  Person    P047
#> 208 Criterion:Organization Person:P048 Criterion Organization  Person    P048
#> 209            Person:P001   Rater:R01    Person         P001   Rater     R01
#> 210            Person:P001   Rater:R02    Person         P001   Rater     R02
#> 211            Person:P001   Rater:R03    Person         P001   Rater     R03
#> 212            Person:P001   Rater:R04    Person         P001   Rater     R04
#> 213            Person:P002   Rater:R01    Person         P002   Rater     R01
#> 214            Person:P002   Rater:R02    Person         P002   Rater     R02
#> 215            Person:P002   Rater:R03    Person         P002   Rater     R03
#> 216            Person:P002   Rater:R04    Person         P002   Rater     R04
#> 217            Person:P003   Rater:R01    Person         P003   Rater     R01
#> 218            Person:P003   Rater:R02    Person         P003   Rater     R02
#> 219            Person:P003   Rater:R03    Person         P003   Rater     R03
#> 220            Person:P003   Rater:R04    Person         P003   Rater     R04
#> 221            Person:P004   Rater:R01    Person         P004   Rater     R01
#> 222            Person:P004   Rater:R02    Person         P004   Rater     R02
#> 223            Person:P004   Rater:R03    Person         P004   Rater     R03
#> 224            Person:P004   Rater:R04    Person         P004   Rater     R04
#> 225            Person:P005   Rater:R01    Person         P005   Rater     R01
#> 226            Person:P005   Rater:R02    Person         P005   Rater     R02
#> 227            Person:P005   Rater:R03    Person         P005   Rater     R03
#> 228            Person:P005   Rater:R04    Person         P005   Rater     R04
#> 229            Person:P006   Rater:R01    Person         P006   Rater     R01
#> 230            Person:P006   Rater:R02    Person         P006   Rater     R02
#> 231            Person:P006   Rater:R03    Person         P006   Rater     R03
#> 232            Person:P006   Rater:R04    Person         P006   Rater     R04
#> 233            Person:P007   Rater:R01    Person         P007   Rater     R01
#> 234            Person:P007   Rater:R02    Person         P007   Rater     R02
#> 235            Person:P007   Rater:R03    Person         P007   Rater     R03
#> 236            Person:P007   Rater:R04    Person         P007   Rater     R04
#> 237            Person:P008   Rater:R01    Person         P008   Rater     R01
#> 238            Person:P008   Rater:R02    Person         P008   Rater     R02
#> 239            Person:P008   Rater:R03    Person         P008   Rater     R03
#> 240            Person:P008   Rater:R04    Person         P008   Rater     R04
#> 241            Person:P009   Rater:R01    Person         P009   Rater     R01
#> 242            Person:P009   Rater:R02    Person         P009   Rater     R02
#> 243            Person:P009   Rater:R03    Person         P009   Rater     R03
#> 244            Person:P009   Rater:R04    Person         P009   Rater     R04
#> 245            Person:P010   Rater:R01    Person         P010   Rater     R01
#> 246            Person:P010   Rater:R02    Person         P010   Rater     R02
#> 247            Person:P010   Rater:R03    Person         P010   Rater     R03
#> 248            Person:P010   Rater:R04    Person         P010   Rater     R04
#> 249            Person:P011   Rater:R01    Person         P011   Rater     R01
#> 250            Person:P011   Rater:R02    Person         P011   Rater     R02
#> 251            Person:P011   Rater:R03    Person         P011   Rater     R03
#> 252            Person:P011   Rater:R04    Person         P011   Rater     R04
#> 253            Person:P012   Rater:R01    Person         P012   Rater     R01
#> 254            Person:P012   Rater:R02    Person         P012   Rater     R02
#> 255            Person:P012   Rater:R03    Person         P012   Rater     R03
#> 256            Person:P012   Rater:R04    Person         P012   Rater     R04
#> 257            Person:P013   Rater:R01    Person         P013   Rater     R01
#> 258            Person:P013   Rater:R02    Person         P013   Rater     R02
#> 259            Person:P013   Rater:R03    Person         P013   Rater     R03
#> 260            Person:P013   Rater:R04    Person         P013   Rater     R04
#> 261            Person:P014   Rater:R01    Person         P014   Rater     R01
#> 262            Person:P014   Rater:R02    Person         P014   Rater     R02
#> 263            Person:P014   Rater:R03    Person         P014   Rater     R03
#> 264            Person:P014   Rater:R04    Person         P014   Rater     R04
#> 265            Person:P015   Rater:R01    Person         P015   Rater     R01
#> 266            Person:P015   Rater:R02    Person         P015   Rater     R02
#> 267            Person:P015   Rater:R03    Person         P015   Rater     R03
#> 268            Person:P015   Rater:R04    Person         P015   Rater     R04
#> 269            Person:P016   Rater:R01    Person         P016   Rater     R01
#> 270            Person:P016   Rater:R02    Person         P016   Rater     R02
#> 271            Person:P016   Rater:R03    Person         P016   Rater     R03
#> 272            Person:P016   Rater:R04    Person         P016   Rater     R04
#> 273            Person:P017   Rater:R01    Person         P017   Rater     R01
#> 274            Person:P017   Rater:R02    Person         P017   Rater     R02
#> 275            Person:P017   Rater:R03    Person         P017   Rater     R03
#> 276            Person:P017   Rater:R04    Person         P017   Rater     R04
#> 277            Person:P018   Rater:R01    Person         P018   Rater     R01
#> 278            Person:P018   Rater:R02    Person         P018   Rater     R02
#> 279            Person:P018   Rater:R03    Person         P018   Rater     R03
#> 280            Person:P018   Rater:R04    Person         P018   Rater     R04
#> 281            Person:P019   Rater:R01    Person         P019   Rater     R01
#> 282            Person:P019   Rater:R02    Person         P019   Rater     R02
#> 283            Person:P019   Rater:R03    Person         P019   Rater     R03
#> 284            Person:P019   Rater:R04    Person         P019   Rater     R04
#> 285            Person:P020   Rater:R01    Person         P020   Rater     R01
#> 286            Person:P020   Rater:R02    Person         P020   Rater     R02
#> 287            Person:P020   Rater:R03    Person         P020   Rater     R03
#> 288            Person:P020   Rater:R04    Person         P020   Rater     R04
#> 289            Person:P021   Rater:R01    Person         P021   Rater     R01
#> 290            Person:P021   Rater:R02    Person         P021   Rater     R02
#> 291            Person:P021   Rater:R03    Person         P021   Rater     R03
#> 292            Person:P021   Rater:R04    Person         P021   Rater     R04
#> 293            Person:P022   Rater:R01    Person         P022   Rater     R01
#> 294            Person:P022   Rater:R02    Person         P022   Rater     R02
#> 295            Person:P022   Rater:R03    Person         P022   Rater     R03
#> 296            Person:P022   Rater:R04    Person         P022   Rater     R04
#> 297            Person:P023   Rater:R01    Person         P023   Rater     R01
#> 298            Person:P023   Rater:R02    Person         P023   Rater     R02
#> 299            Person:P023   Rater:R03    Person         P023   Rater     R03
#> 300            Person:P023   Rater:R04    Person         P023   Rater     R04
#> 301            Person:P024   Rater:R01    Person         P024   Rater     R01
#> 302            Person:P024   Rater:R02    Person         P024   Rater     R02
#> 303            Person:P024   Rater:R03    Person         P024   Rater     R03
#> 304            Person:P024   Rater:R04    Person         P024   Rater     R04
#> 305            Person:P025   Rater:R01    Person         P025   Rater     R01
#> 306            Person:P025   Rater:R02    Person         P025   Rater     R02
#> 307            Person:P025   Rater:R03    Person         P025   Rater     R03
#> 308            Person:P025   Rater:R04    Person         P025   Rater     R04
#> 309            Person:P026   Rater:R01    Person         P026   Rater     R01
#> 310            Person:P026   Rater:R02    Person         P026   Rater     R02
#> 311            Person:P026   Rater:R03    Person         P026   Rater     R03
#> 312            Person:P026   Rater:R04    Person         P026   Rater     R04
#> 313            Person:P027   Rater:R01    Person         P027   Rater     R01
#> 314            Person:P027   Rater:R02    Person         P027   Rater     R02
#> 315            Person:P027   Rater:R03    Person         P027   Rater     R03
#> 316            Person:P027   Rater:R04    Person         P027   Rater     R04
#> 317            Person:P028   Rater:R01    Person         P028   Rater     R01
#> 318            Person:P028   Rater:R02    Person         P028   Rater     R02
#> 319            Person:P028   Rater:R03    Person         P028   Rater     R03
#> 320            Person:P028   Rater:R04    Person         P028   Rater     R04
#> 321            Person:P029   Rater:R01    Person         P029   Rater     R01
#> 322            Person:P029   Rater:R02    Person         P029   Rater     R02
#> 323            Person:P029   Rater:R03    Person         P029   Rater     R03
#> 324            Person:P029   Rater:R04    Person         P029   Rater     R04
#> 325            Person:P030   Rater:R01    Person         P030   Rater     R01
#> 326            Person:P030   Rater:R02    Person         P030   Rater     R02
#> 327            Person:P030   Rater:R03    Person         P030   Rater     R03
#> 328            Person:P030   Rater:R04    Person         P030   Rater     R04
#> 329            Person:P031   Rater:R01    Person         P031   Rater     R01
#> 330            Person:P031   Rater:R02    Person         P031   Rater     R02
#> 331            Person:P031   Rater:R03    Person         P031   Rater     R03
#> 332            Person:P031   Rater:R04    Person         P031   Rater     R04
#> 333            Person:P032   Rater:R01    Person         P032   Rater     R01
#> 334            Person:P032   Rater:R02    Person         P032   Rater     R02
#> 335            Person:P032   Rater:R03    Person         P032   Rater     R03
#> 336            Person:P032   Rater:R04    Person         P032   Rater     R04
#> 337            Person:P033   Rater:R01    Person         P033   Rater     R01
#> 338            Person:P033   Rater:R02    Person         P033   Rater     R02
#> 339            Person:P033   Rater:R03    Person         P033   Rater     R03
#> 340            Person:P033   Rater:R04    Person         P033   Rater     R04
#> 341            Person:P034   Rater:R01    Person         P034   Rater     R01
#> 342            Person:P034   Rater:R02    Person         P034   Rater     R02
#> 343            Person:P034   Rater:R03    Person         P034   Rater     R03
#> 344            Person:P034   Rater:R04    Person         P034   Rater     R04
#> 345            Person:P035   Rater:R01    Person         P035   Rater     R01
#> 346            Person:P035   Rater:R02    Person         P035   Rater     R02
#> 347            Person:P035   Rater:R03    Person         P035   Rater     R03
#> 348            Person:P035   Rater:R04    Person         P035   Rater     R04
#> 349            Person:P036   Rater:R01    Person         P036   Rater     R01
#> 350            Person:P036   Rater:R02    Person         P036   Rater     R02
#> 351            Person:P036   Rater:R03    Person         P036   Rater     R03
#> 352            Person:P036   Rater:R04    Person         P036   Rater     R04
#> 353            Person:P037   Rater:R01    Person         P037   Rater     R01
#> 354            Person:P037   Rater:R02    Person         P037   Rater     R02
#> 355            Person:P037   Rater:R03    Person         P037   Rater     R03
#> 356            Person:P037   Rater:R04    Person         P037   Rater     R04
#> 357            Person:P038   Rater:R01    Person         P038   Rater     R01
#> 358            Person:P038   Rater:R02    Person         P038   Rater     R02
#> 359            Person:P038   Rater:R03    Person         P038   Rater     R03
#> 360            Person:P038   Rater:R04    Person         P038   Rater     R04
#> 361            Person:P039   Rater:R01    Person         P039   Rater     R01
#> 362            Person:P039   Rater:R02    Person         P039   Rater     R02
#> 363            Person:P039   Rater:R03    Person         P039   Rater     R03
#> 364            Person:P039   Rater:R04    Person         P039   Rater     R04
#> 365            Person:P040   Rater:R01    Person         P040   Rater     R01
#> 366            Person:P040   Rater:R02    Person         P040   Rater     R02
#> 367            Person:P040   Rater:R03    Person         P040   Rater     R03
#> 368            Person:P040   Rater:R04    Person         P040   Rater     R04
#> 369            Person:P041   Rater:R01    Person         P041   Rater     R01
#> 370            Person:P041   Rater:R02    Person         P041   Rater     R02
#> 371            Person:P041   Rater:R03    Person         P041   Rater     R03
#> 372            Person:P041   Rater:R04    Person         P041   Rater     R04
#> 373            Person:P042   Rater:R01    Person         P042   Rater     R01
#> 374            Person:P042   Rater:R02    Person         P042   Rater     R02
#> 375            Person:P042   Rater:R03    Person         P042   Rater     R03
#> 376            Person:P042   Rater:R04    Person         P042   Rater     R04
#> 377            Person:P043   Rater:R01    Person         P043   Rater     R01
#> 378            Person:P043   Rater:R02    Person         P043   Rater     R02
#> 379            Person:P043   Rater:R03    Person         P043   Rater     R03
#> 380            Person:P043   Rater:R04    Person         P043   Rater     R04
#> 381            Person:P044   Rater:R01    Person         P044   Rater     R01
#> 382            Person:P044   Rater:R02    Person         P044   Rater     R02
#> 383            Person:P044   Rater:R03    Person         P044   Rater     R03
#> 384            Person:P044   Rater:R04    Person         P044   Rater     R04
#> 385            Person:P045   Rater:R01    Person         P045   Rater     R01
#> 386            Person:P045   Rater:R02    Person         P045   Rater     R02
#> 387            Person:P045   Rater:R03    Person         P045   Rater     R03
#> 388            Person:P045   Rater:R04    Person         P045   Rater     R04
#> 389            Person:P046   Rater:R01    Person         P046   Rater     R01
#> 390            Person:P046   Rater:R02    Person         P046   Rater     R02
#> 391            Person:P046   Rater:R03    Person         P046   Rater     R03
#> 392            Person:P046   Rater:R04    Person         P046   Rater     R04
#> 393            Person:P047   Rater:R01    Person         P047   Rater     R01
#> 394            Person:P047   Rater:R02    Person         P047   Rater     R02
#> 395            Person:P047   Rater:R03    Person         P047   Rater     R03
#> 396            Person:P047   Rater:R04    Person         P047   Rater     R04
#> 397            Person:P048   Rater:R01    Person         P048   Rater     R01
#> 398            Person:P048   Rater:R02    Person         P048   Rater     R02
#> 399            Person:P048   Rater:R03    Person         P048   Rater     R03
#> 400            Person:P048   Rater:R04    Person         P048   Rater     R04
#>     Weight Subset
#> 1       48      1
#> 2       48      1
#> 3       48      1
#> 4       48      1
#> 5       48      1
#> 6       48      1
#> 7       48      1
#> 8       48      1
#> 9       48      1
#> 10      48      1
#> 11      48      1
#> 12      48      1
#> 13      48      1
#> 14      48      1
#> 15      48      1
#> 16      48      1
#> 17       4      1
#> 18       4      1
#> 19       4      1
#> 20       4      1
#> 21       4      1
#> 22       4      1
#> 23       4      1
#> 24       4      1
#> 25       4      1
#> 26       4      1
#> 27       4      1
#> 28       4      1
#> 29       4      1
#> 30       4      1
#> 31       4      1
#> 32       4      1
#> 33       4      1
#> 34       4      1
#> 35       4      1
#> 36       4      1
#> 37       4      1
#> 38       4      1
#> 39       4      1
#> 40       4      1
#> 41       4      1
#> 42       4      1
#> 43       4      1
#> 44       4      1
#> 45       4      1
#> 46       4      1
#> 47       4      1
#> 48       4      1
#> 49       4      1
#> 50       4      1
#> 51       4      1
#> 52       4      1
#> 53       4      1
#> 54       4      1
#> 55       4      1
#> 56       4      1
#> 57       4      1
#> 58       4      1
#> 59       4      1
#> 60       4      1
#> 61       4      1
#> 62       4      1
#> 63       4      1
#> 64       4      1
#> 65       4      1
#> 66       4      1
#> 67       4      1
#> 68       4      1
#> 69       4      1
#> 70       4      1
#> 71       4      1
#> 72       4      1
#> 73       4      1
#> 74       4      1
#> 75       4      1
#> 76       4      1
#> 77       4      1
#> 78       4      1
#> 79       4      1
#> 80       4      1
#> 81       4      1
#> 82       4      1
#> 83       4      1
#> 84       4      1
#> 85       4      1
#> 86       4      1
#> 87       4      1
#> 88       4      1
#> 89       4      1
#> 90       4      1
#> 91       4      1
#> 92       4      1
#> 93       4      1
#> 94       4      1
#> 95       4      1
#> 96       4      1
#> 97       4      1
#> 98       4      1
#> 99       4      1
#> 100      4      1
#> 101      4      1
#> 102      4      1
#> 103      4      1
#> 104      4      1
#> 105      4      1
#> 106      4      1
#> 107      4      1
#> 108      4      1
#> 109      4      1
#> 110      4      1
#> 111      4      1
#> 112      4      1
#> 113      4      1
#> 114      4      1
#> 115      4      1
#> 116      4      1
#> 117      4      1
#> 118      4      1
#> 119      4      1
#> 120      4      1
#> 121      4      1
#> 122      4      1
#> 123      4      1
#> 124      4      1
#> 125      4      1
#> 126      4      1
#> 127      4      1
#> 128      4      1
#> 129      4      1
#> 130      4      1
#> 131      4      1
#> 132      4      1
#> 133      4      1
#> 134      4      1
#> 135      4      1
#> 136      4      1
#> 137      4      1
#> 138      4      1
#> 139      4      1
#> 140      4      1
#> 141      4      1
#> 142      4      1
#> 143      4      1
#> 144      4      1
#> 145      4      1
#> 146      4      1
#> 147      4      1
#> 148      4      1
#> 149      4      1
#> 150      4      1
#> 151      4      1
#> 152      4      1
#> 153      4      1
#> 154      4      1
#> 155      4      1
#> 156      4      1
#> 157      4      1
#> 158      4      1
#> 159      4      1
#> 160      4      1
#> 161      4      1
#> 162      4      1
#> 163      4      1
#> 164      4      1
#> 165      4      1
#> 166      4      1
#> 167      4      1
#> 168      4      1
#> 169      4      1
#> 170      4      1
#> 171      4      1
#> 172      4      1
#> 173      4      1
#> 174      4      1
#> 175      4      1
#> 176      4      1
#> 177      4      1
#> 178      4      1
#> 179      4      1
#> 180      4      1
#> 181      4      1
#> 182      4      1
#> 183      4      1
#> 184      4      1
#> 185      4      1
#> 186      4      1
#> 187      4      1
#> 188      4      1
#> 189      4      1
#> 190      4      1
#> 191      4      1
#> 192      4      1
#> 193      4      1
#> 194      4      1
#> 195      4      1
#> 196      4      1
#> 197      4      1
#> 198      4      1
#> 199      4      1
#> 200      4      1
#> 201      4      1
#> 202      4      1
#> 203      4      1
#> 204      4      1
#> 205      4      1
#> 206      4      1
#> 207      4      1
#> 208      4      1
#> 209      4      1
#> 210      4      1
#> 211      4      1
#> 212      4      1
#> 213      4      1
#> 214      4      1
#> 215      4      1
#> 216      4      1
#> 217      4      1
#> 218      4      1
#> 219      4      1
#> 220      4      1
#> 221      4      1
#> 222      4      1
#> 223      4      1
#> 224      4      1
#> 225      4      1
#> 226      4      1
#> 227      4      1
#> 228      4      1
#> 229      4      1
#> 230      4      1
#> 231      4      1
#> 232      4      1
#> 233      4      1
#> 234      4      1
#> 235      4      1
#> 236      4      1
#> 237      4      1
#> 238      4      1
#> 239      4      1
#> 240      4      1
#> 241      4      1
#> 242      4      1
#> 243      4      1
#> 244      4      1
#> 245      4      1
#> 246      4      1
#> 247      4      1
#> 248      4      1
#> 249      4      1
#> 250      4      1
#> 251      4      1
#> 252      4      1
#> 253      4      1
#> 254      4      1
#> 255      4      1
#> 256      4      1
#> 257      4      1
#> 258      4      1
#> 259      4      1
#> 260      4      1
#> 261      4      1
#> 262      4      1
#> 263      4      1
#> 264      4      1
#> 265      4      1
#> 266      4      1
#> 267      4      1
#> 268      4      1
#> 269      4      1
#> 270      4      1
#> 271      4      1
#> 272      4      1
#> 273      4      1
#> 274      4      1
#> 275      4      1
#> 276      4      1
#> 277      4      1
#> 278      4      1
#> 279      4      1
#> 280      4      1
#> 281      4      1
#> 282      4      1
#> 283      4      1
#> 284      4      1
#> 285      4      1
#> 286      4      1
#> 287      4      1
#> 288      4      1
#> 289      4      1
#> 290      4      1
#> 291      4      1
#> 292      4      1
#> 293      4      1
#> 294      4      1
#> 295      4      1
#> 296      4      1
#> 297      4      1
#> 298      4      1
#> 299      4      1
#> 300      4      1
#> 301      4      1
#> 302      4      1
#> 303      4      1
#> 304      4      1
#> 305      4      1
#> 306      4      1
#> 307      4      1
#> 308      4      1
#> 309      4      1
#> 310      4      1
#> 311      4      1
#> 312      4      1
#> 313      4      1
#> 314      4      1
#> 315      4      1
#> 316      4      1
#> 317      4      1
#> 318      4      1
#> 319      4      1
#> 320      4      1
#> 321      4      1
#> 322      4      1
#> 323      4      1
#> 324      4      1
#> 325      4      1
#> 326      4      1
#> 327      4      1
#> 328      4      1
#> 329      4      1
#> 330      4      1
#> 331      4      1
#> 332      4      1
#> 333      4      1
#> 334      4      1
#> 335      4      1
#> 336      4      1
#> 337      4      1
#> 338      4      1
#> 339      4      1
#> 340      4      1
#> 341      4      1
#> 342      4      1
#> 343      4      1
#> 344      4      1
#> 345      4      1
#> 346      4      1
#> 347      4      1
#> 348      4      1
#> 349      4      1
#> 350      4      1
#> 351      4      1
#> 352      4      1
#> 353      4      1
#> 354      4      1
#> 355      4      1
#> 356      4      1
#> 357      4      1
#> 358      4      1
#> 359      4      1
#> 360      4      1
#> 361      4      1
#> 362      4      1
#> 363      4      1
#> 364      4      1
#> 365      4      1
#> 366      4      1
#> 367      4      1
#> 368      4      1
#> 369      4      1
#> 370      4      1
#> 371      4      1
#> 372      4      1
#> 373      4      1
#> 374      4      1
#> 375      4      1
#> 376      4      1
#> 377      4      1
#> 378      4      1
#> 379      4      1
#> 380      4      1
#> 381      4      1
#> 382      4      1
#> 383      4      1
#> 384      4      1
#> 385      4      1
#> 386      4      1
#> 387      4      1
#> 388      4      1
#> 389      4      1
#> 390      4      1
#> 391      4      1
#> 392      4      1
#> 393      4      1
#> 394      4      1
#> 395      4      1
#> 396      4      1
#> 397      4      1
#> 398      4      1
#> 399      4      1
#> 400      4      1
out$summary[, c("Subset", "Observations", "ObservationPercent")]
#>   Subset Observations ObservationPercent
#> 1      1          768                100
```
