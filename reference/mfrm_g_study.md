# G-Study for one or several observed scores

Estimate observed-score variance and covariance components across
Persons and one or two common random measurement facets (crossed or
nested, such as raters, tasks, or exchangeable occasions) using balanced
ANOVA or incomplete-design `MINQUE(0)`. Pass the result to
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
and
[`confint.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md).

## Usage

``` r
mfrm_g_study(
  data,
  scores,
  person = "Person",
  rater = "Rater",
  task = "Task",
  method = c("anova", "minque0"),
  missing = c("error", "omit"),
  facets = NULL,
  nesting = NULL
)

# S3 method for class 'mfrm_multivariate_gstudy'
print(x, digits = NULL, row.names = FALSE, ...)

# S3 method for class 'mfrm_multivariate_gstudy'
summary(object, ...)
```

## Arguments

- data:

  Long-format `data.frame` with at most one row per observed
  Person-by-facet combination (do not pad unassigned cells with zeros).

- scores:

  Character vector of `>= 1` finite numeric score columns.

- person:

  Person ID column and either `rater`/`task` (`NULL` omits one facet) or
  named/unnamed `facets` vector (`1` or `2` random facets, e.g.,
  `c(Rater = "Assessor", Occasion = "Session")`).

- rater:

  Person ID column and either `rater`/`task` (`NULL` omits one facet) or
  named/unnamed `facets` vector (`1` or `2` random facets, e.g.,
  `c(Rater = "Assessor", Occasion = "Session")`).

- task:

  Person ID column and either `rater`/`task` (`NULL` omits one facet) or
  named/unnamed `facets` vector (`1` or `2` random facets, e.g.,
  `c(Rater = "Assessor", Occasion = "Session")`).

- method:

  `"anova"` (complete balanced designs) or `"minque0"` (complete,
  incomplete, or unequal designs solving `S_st = tr(H K_s H K_t)`
  against `Q_s = Y' H K_s H Y` without PSD clipping; Rao, 1971).

- missing:

  `"error"` (default) or `"omit"` (drops rows with missing selected
  scores/identifiers and records `data_usage`).

- facets:

  Person ID column and either `rater`/`task` (`NULL` omits one facet) or
  named/unnamed `facets` vector (`1` or `2` random facets, e.g.,
  `c(Rater = "Assessor", Occasion = "Session")`).

- nesting:

  Optional `c(Child = "Parent")` specification (e.g.,
  `c(Rater = "Task")`, yielding 5 components: `Person`, `Task`,
  `Rater(Task)`, `Person:Task`, `Residual`; child counts in
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  denote children per parent).

- x:

  A result from the corresponding G-study or D-study function.

- digits:

  Display precision passed to the printed tables; `NULL` uses R's
  current setting. Stored estimates are unchanged.

- row.names:

  Logical; print table row names? Defaults to `FALSE`.

- ...:

  Further table-printing arguments for
  [`print()`](https://rdrr.io/r/base/print.html); unused arguments to
  [`summary()`](https://rdrr.io/r/base/summary.html) are rejected.

- object:

  A result from the corresponding G-study or D-study function.

## Value

An `mfrm_multivariate_gstudy` list
([`print()`](https://rdrr.io/r/base/print.html),
[`summary()`](https://rdrr.io/r/base/summary.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`vcov()`](https://rdrr.io/r/stats/vcov.html),
[`confint()`](https://rdrr.io/r/stats/confint.html)) with `components`,
`mean_products`, `degrees_of_freedom`, `estimation`, `data_usage`,
`component_diagnostics`, `score_scale`, `design`, and `data`.

## Details

**Components, admissibility, and fixed tasks.** Crossed two-facet
designs estimate `7` covariance matrices (`Person`, `Rater`, `Task`,
`Person:Rater`, `Person:Task`, `Rater:Task`, `Residual`); single-facet
designs estimate `3`. Diagonals are variances in squared score units and
off-diagonals are signed covariances in score-product units; negative or
non-PSD estimates remain unclipped
(`component_diagnostics$PositiveSemidefinite`). Fixed tasks scored by
every sampled rater should be supplied as separate `scores` columns with
`task = NULL` and composite weights in
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md).

## References

- Brennan, R. L. (2001). *Generalizability theory*. Springer.
  [doi:10.1007/978-1-4757-3456-0](https://doi.org/10.1007/978-1-4757-3456-0)
  .

- Brennan, R. L. (2001). *Manual for mGENOVA, Version 2.1*. Iowa Testing
  Programs Occasional Papers, No. 50.

- Rao, C. R. (1971). *Journal of Multivariate Analysis*, 1, 257–275.
  [doi:10.1016/0047-259X(71)90001-7](https://doi.org/10.1016/0047-259X%2871%2990001-7)
  .

## See also

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`confint.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md),
[`vignette("mfrmr-gtheory", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gtheory.md)

## Examples

``` r
# Common tasks, without a rater facet: Brennan's published synthetic data.
# mGENOVA manual Table 12: 10 persons, 6 common items, two scores V and W.
# The item facet is named Task in the supplied long-format data.
tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
g_task <- mfrm_g_study(tasks, c("V", "W"), rater = NULL)
g_task$components
#> $Person
#>           V         W
#> V 0.3681481 0.3192593
#> W 0.3192593 0.3688889
#> 
#> $Task
#>            V          W
#> V 0.34444444 0.09185185
#> W 0.09185185 0.32000000
#> 
#> $Residual
#>           V         W
#> V 1.2522222 0.7048148
#> W 0.7048148 1.5366667
#> 
g_task$component_diagnostics
#>     Source MinimumScaledEigenvalue    Tolerance PositiveSemidefinite Rank
#> 1   Person              0.02446083 1.490116e-08                 TRUE    2
#> 2     Task              0.11735777 1.490116e-08                 TRUE    2
#> 3 Residual              0.33921548 1.553766e-08                 TRUE    2
#>   Dimension
#> 1         2
#> 2         2
#> 3         2
# To compare future designs, see ?mfrm_d_study.

# Optional planning, incomplete designs, renamed facets and nesting examples.
# example("mfrm_g_study", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
d_task <- mfrm_d_study(g_task,
  design_grid = data.frame(Tasks = c(6, 12)), weights = c(V = -1, W = 1))
d_task$coefficients
# At six tasks, W - V has G = 0.30000 and Phi = 0.24116 (Appendix E).

# An illustrative incomplete assignment roster, not a missingness model.
sparse <- tasks[(tasks$Person + tasks$Task) %% 3 != 0, ]
sparse$V[1] <- NA_real_ # One assigned score is additionally unrecorded.
g_sparse <- mfrm_g_study(sparse, c("V", "W"), rater = NULL,
  method = "minque0", missing = "omit")
g_sparse$data_usage
g_sparse$estimation$component_support
g_sparse$component_diagnostics
# Explicit future COMPLETE designs, not reliability of the sparse roster.
d_sparse <- mfrm_d_study(g_sparse,
  data.frame(Tasks = c(6, 12)), weights = c(V = -1, W = 1))
d_sparse$coefficients # Read metric status and ComponentPSD separately.

# Existing continuous-score example; rename columns to show role mapping.
data("mfrmr_example_gtheory_crossed", package = "mfrmr")
ratings <- mfrmr_example_gtheory_crossed
names(ratings)[names(ratings) == "Rater"] <- "Assessor"
names(ratings)[names(ratings) == "Task"] <- "Session"
head(ratings) # Two score columns for each Person-Assessor-Session cell.
# Here sessions represent exchangeable assessments, without a time trend.
g <- mfrm_g_study(ratings, c("Content", "Organization"),
  facets = c(Rater = "Assessor", Occasion = "Session"))
g$components$Person
g$component_diagnostics
d <- mfrm_d_study(g,
  design_grid = data.frame(Rater = c(2, 4), Occasion = c(3, 3)),
  weights = c(Content = 0.6, Organization = 0.4))
d$coefficients
# Difference-score dependability, when subtraction is meaningful on these scales.
difference <- mfrm_d_study(g,
  weights = c(Content = 1, Organization = -1))
difference$coefficients

# Rater-only planning for one occasion; no generalization across occasions.
one_session <- ratings[ratings$Session == 1, ]
g_rater <- mfrm_g_study(one_session, c("Content", "Organization"),
  rater = "Assessor", task = NULL)
d_rater <- mfrm_d_study(g_rater, data.frame(Raters = c(1, 2, 4)))
plot(d_rater, score = "Content")

# Different rater teams for different tasks; the same Persons and scores.
data("mfrmr_example_gtheory_nested", package = "mfrmr")
nested <- mfrmr_example_gtheory_nested
head(nested) # R1 in Task 1 is a different rater from R1 in Task 2.
g_nested <- mfrm_g_study(nested, c("Content", "Organization"),
  nesting = c(Rater = "Task"))
g_nested$design$child_counts # Three raters per task; eighteen in total.
g_nested$component_diagnostics
d_nested <- mfrm_d_study(g_nested,
  expand.grid(Raters = c(2, 3), Tasks = c(4, 6)),
  weights = c(Content = 0.6, Organization = 0.4))
summary(d_nested)
plot(d_nested, x_var = "Raters") # Raters on the axis means raters PER TASK.
plot(d_nested, x_var = "Tasks", type = "sem")
} # }
```
