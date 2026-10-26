# Synthetic crossed and nested data for learning G theory

Existing tutorial examples supplied as ready-to-load tables. Load one
with `data("mfrmr_example_gtheory_crossed", package = "mfrmr")`, then
assign it to a shorter name such as `ratings`. No simulation code is
needed to run the G-study or D-study examples.

## Format

Two data frames with five columns: `Person`, `Rater`, `Task`, `Content`,
and `Organization`. Each row is one Person-by-Rater-by-Task rating cell;
the last two columns are continuous numeric scores.
`mfrmr_example_gtheory_crossed` has 1,920 rows (40 Persons, eight common
raters and six common tasks). `mfrmr_example_gtheory_nested` has 540
rows (30 Persons, six tasks and three raters per task).

## Source

The existing crossed G-theory tutorial (seed 24) and nested G-study help
example (seed 2027). Their unchanged generation recipes are retained in
`data-raw/make-teaching-data.R` in the source repository.

## Details

In the crossed example, the same rater ID denotes the same rater on
every task. In the nested example, `R1`, `R2`, `R3` are local labels:
the pair `Task` and `Rater` identifies a rater, giving 18 raters in
total. Declare `nesting = c(Rater = "Task")` for that example. Persons
are crossed with all tasks and rater teams in both examples.

The scores were constructed from independent normal random effects for
every source in the respective design. The nested example correlates the
two score components within each source. These are fictional unbounded
continuous scores, not ordered rubric categories or MFRM ability
estimates. Their design and sample sizes demonstrate the functions; they
do not establish that an assessment's assumptions or estimation
precision are adequate.

## See also

[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md),
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md),
[`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)

## Examples

``` r
data("mfrmr_example_gtheory_crossed", package = "mfrmr")
ratings <- mfrmr_example_gtheory_crossed
head(ratings)
#>   Person Rater Task Organization    Content
#> 1      1     1    1    0.5045747  0.5475769
#> 2      2     1    1    1.3440571 -0.9615514
#> 3      3     1    1   -0.4715306  3.7099968
#> 4      4     1    1   -0.5425612  0.5795908
#> 5      5     1    1   -0.3337672  2.8174334
#> 6      6     1    1    1.6440213  0.1798085
g <- mfrm_g_study(ratings, scores = c("Content", "Organization"),
  person = "Person", rater = "Rater", task = "Task")
g$component_diagnostics
#>         Source MinimumScaledEigenvalue    Tolerance PositiveSemidefinite Rank
#> 1       Person              0.12937911 1.490116e-08                 TRUE    2
#> 2        Rater              0.07993328 1.490116e-08                 TRUE    2
#> 3         Task              0.03814013 1.490116e-08                 TRUE    2
#> 4 Person:Rater              0.13711601 1.490116e-08                 TRUE    2
#> 5  Person:Task              0.12143229 1.490116e-08                 TRUE    2
#> 6   Rater:Task              0.14198058 1.490116e-08                 TRUE    2
#> 7     Residual              0.14284035 1.490116e-08                 TRUE    2
#>   Dimension
#> 1         2
#> 2         2
#> 3         2
#> 4         2
#> 5         2
#> 6         2
#> 7         2
# Inspect component estimates before projecting future plans.
d <- mfrm_d_study(g,
  design_grid = data.frame(Raters = c(2, 4), Tasks = 3),
  weights = c(Content = .5, Organization = .5))
summary(d)
#>   Scenario Raters Tasks      Kind        Score UniverseVariance
#> 1        1      2     3     Score      Content        0.9492992
#> 2        1      2     3     Score Organization        0.9307520
#> 3        1      2     3 Composite    Composite        0.4257850
#> 4        2      4     3     Score      Content        0.9492992
#> 5        2      4     3     Score Organization        0.9307520
#> 6        2      4     3 Composite    Composite        0.4257850
#>   RelativeErrorVariance AbsoluteErrorVariance         G       Phi RelativeSEM
#> 1             0.9844251             2.1219180 0.4909175 0.3090954   0.9921820
#> 2             0.9712316             1.5667193 0.4893586 0.3726778   0.9855108
#> 3             0.4393618             0.9932672 0.4921535 0.3000488   0.6628437
#> 4             0.6456467             1.4837718 0.5951921 0.3901650   0.8035214
#> 5             0.6290735             0.9708793 0.5967026 0.4894492   0.7931415
#> 6             0.2846264             0.6629832 0.5993499 0.3910704   0.5335039
#>   AbsoluteSEM    Status   GStatus PhiStatus RelativeSEMStatus AbsoluteSEMStatus
#> 1   1.4566805 Available Available Available         Available         Available
#> 2   1.2516866 Available Available Available         Available         Available
#> 3   0.9966279 Available Available Available         Available         Available
#> 4   1.2181017 Available Available Available         Available         Available
#> 5   0.9853321 Available Available Available         Available         Available
#> 6   0.8142378 Available Available Available         Available         Available
#>   ComponentPSD ComponentTreatment
#> 1         TRUE                raw
#> 2         TRUE                raw
#> 3         TRUE                raw
#> 4         TRUE                raw
#> 5         TRUE                raw
#> 6         TRUE                raw
```
