# Sampling covariance and SEs of G-study component estimates

Quantify how estimated sources of score variation would vary across
repeated G-studies with the same assignment design. Supports balanced
ANOVA and identifiable MINQUE(0), including incomplete and supported
nested sources.

## Usage

``` r
# S3 method for class 'mfrm_multivariate_gstudy'
vcov(object, score = NULL, weights = NULL, assumption, ...)
```

## Arguments

- object:

  A result from
  [`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md).

- score:

  One original score, or exactly two distinct original scores for the
  sampling covariance of their between-score component covariances. The
  default selects the first original score.

- weights:

  Optional named weights for one prespecified composite; name every
  original score. Do not also supply `score`.

- assumption:

  Required: `"normal"` asserts independent normal random effects, a
  common mean for each score and constant component covariances.
  Assignment and omissions must preserve that model when conditioning on
  the observed assignment. The assumption is not tested.

- ...:

  Reserved; extra arguments are rejected.

## Value

A named matrix estimating the sampling covariance of component
estimates. Attribute `summary` is a data frame with `Source`,
`Estimate`, `SamplingVariance`, `SE`, and `SEStatus`. `diagnostics`
retains the moment rank, singular values, entrywise estimability and
matrix PSD check. `score`, `weights`, `assumption`, `source_design`,
`source_rows` and `notes` retain interpretation. Save the full result
using [`saveRDS()`](https://rdrr.io/r/base/readRDS.html). MINQUE
requires its retained grouping assignments, moment equations and
quadratic products; balanced ANOVA uses saved summaries without raw
data.

## Details

Rows and columns refer to **estimated components**, such as Person, Task
and Residual. This is neither the covariance matrix between individual
ratings nor the component matrices between score columns in `object`.
Use `attr(result, "summary")` to read the original estimates, sampling
variance estimates, SEs and availability. A component SE has squared
score units; the returned covariance matrix has fourth-power score
units. For a between-score covariance, the SE has the product of the two
score units. These SEs differ from the D-study's measurement SEM in
original score units.

The component estimates are unchanged. This method uses Gaussian product
moments to correct plug-in bias in their estimated sampling covariance.
It does not fit a likelihood, resample data or construct confidence
intervals. In particular, `Estimate +/- 1.96 * SE` is not a generally
justified interval. Use
[`confint.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md)
for its separately qualified interval methods. A REML profile's center
belongs to a different estimator; the SE returned here describes the
original ANOVA/MINQUE estimator.

## Calculation

With mean-removing MINQUE quadratic forms \\q_s=y^T A_s y\\,
\\E(q_s)=\theta_s\\ and \\C\_{st}=2\mathrm{tr}(A_s V A_t V)\\, where
\\V=\sum_u\theta_u K_u\\. Let the linear operator P map
\\\mathrm{vec}(\theta\theta^T)\\ to \\\mathrm{vec}(C)\\. The normal
product-moment identity gives
\\E\\\mathrm{vec}(qq^T)\\=(I+P)\mathrm{vec}(\theta\theta^T)\\. Inverting
this moment system gives an unbiased estimator of C for its identifiable
entries. This is a consequence of the cited moment identity, not a claim
that the reference proposes this package's G-theory procedure. The
squared SE, when available, is the corresponding diagonal estimate; the
square root is not itself an unbiased SE estimator.

For two scores, write x and y for their variance-component vectors and c
for their covariance-component vector. On symmetric matrix coordinates,
\\E\\\mathrm{sym}(\hat x\hat y^T)\\=\mathrm{sym}(xy^T)+P(cc^T)\\ and
\\E(\hat c\hat c^T)=(I+P/2)(cc^T)+(P/2)\mathrm{sym}(xy^T)\\. Solve these
coupled equations for the sampling covariance
\\(P/2)\\\mathrm{sym}(xy^T)+cc^T\\\\. Applying only the scalar
correction to a covariance component would be incorrect.

Balanced ANOVA reduces to the existing independent-mean-square result
`A %*% diag(2 * MS^2 / (df + 2)) %*% t(A)` for a variance/fixed
composite, and the Wishart product-moment correction for a between-score
covariance. MINQUE uses the actual observed grouping kernels.
Column-block calculations avoid allocating observation-square matrices,
but time still increases quadratically with the number of observed
ratings. No sampling simulation is performed. Balanced MINQUE uses the
same ANOVA limit.

## Unavailable or negative results

A moment system can fail to identify some sampling-covariance entries
even when point components are identifiable. A contributing balanced
stratum with df one is an example for between-score covariance SEs. An
SVD checks each target entry's estimability; only unidentified entries
become `NA`. Its rank tolerance is `sqrt(.Machine$double.eps)` relative
to the largest singular value, with relative target reconstruction error
below `1e-8`.

An unbiased sampling-variance estimate may be negative. It is retained
in the returned matrix and `SamplingVariance`, while its `SE` is `NA`
and `SEStatus` explains why. The matrix can also be indefinite with
positive diagonal entries. Nothing is clipped or repaired to make it
positive semidefinite. A mathematically unbiased variance estimate does
not ensure a useful SE in a small sample or correct normal-reference
coverage.

## References

Magnus, J. R. (1978). The moments of products of quadratic forms in
normal variables. *Statistica Neerlandica, 32*, 201–210. Lemma 6.2,
p.209.
[doi:10.1111/j.1467-9574.1978.tb01399.x](https://doi.org/10.1111/j.1467-9574.1978.tb01399.x)
.

Rao, C. R. (1971). Estimation of variance and covariance
components–MINQUE theory. *Journal of Multivariate Analysis, 1*,
257–275.
[doi:10.1016/0047-259X(71)90001-7](https://doi.org/10.1016/0047-259X%2871%2990001-7)
.

## Examples

``` r
data("mfrmr_example_gtheory_crossed", package = "mfrmr")
ratings <- mfrmr_example_gtheory_crossed
# Complete balanced ratings: compute both targets directly.
g <- mfrm_g_study(ratings, c("Content", "Organization"),
                            method = "anova")
sampling <- vcov(g, score = "Content", assumption = "normal")
attr(sampling, "summary") # Component estimates and their sampling SEs.
#>         Source  Estimate SamplingVariance         SE  SEStatus
#> 1       Person 0.9492992      0.076819793 0.27716384 Available
#> 2        Rater 0.8073438      0.238859253 0.48873229 Available
#> 3         Task 1.6162718      0.915385926 0.95675803 Available
#> 4 Person:Rater 1.0182691      0.010283222 0.10140622 Available
#> 5  Person:Task 0.9206047      0.011150699 0.10559687 Available
#> 6   Rater:Task 1.1703825      0.077274940 0.27798370 Available
#> 7     Residual 1.0105340      0.001494044 0.03865286 Available
attr(sampling, "notes")
#> [1] "Sampling covariance of original ANOVA/MINQUE component estimates, conditional on the declared assignment under independent normal random effects. This is not measurement SEM, covariance between individual ratings or the SE of a separate REML estimator."
#> [2] "Gaussian product-moment correction gives unbiased identifiable sampling-covariance entries under the model. Taking square roots is not an unbiasedness guarantee for SEs and does not justify normal-reference confidence intervals."                        
#> [3] "Negative sampling variances are retained, with unavailable SEs. Unidentified entries are NA. An indefinite matrix is not repaired; inspect summary and diagnostics before propagating it to another target."                                                 
#> [4] "Scores and composite weights are prespecified; omission must preserve the model conditional on assignment. No robustness, informative-missingness correction or general confidence-interval coverage is claimed. Save the complete result with saveRDS()."   
# Uncertainty in the covariance between two criteria, by source.
cross_score <- vcov(g, score = c("Content", "Organization"),
                    assumption = "normal")
attr(cross_score, "summary")
#>         Source    Estimate SamplingVariance         SE  SEStatus
#> 1       Person -0.08845568     0.0389471416 0.19735030 Available
#> 2        Rater  0.27503314     0.1301264587 0.36073045 Available
#> 3         Task  0.27652734     0.1332958079 0.36509698 Available
#> 4 Person:Rater -0.12037694     0.0052971546 0.07278155 Available
#> 5  Person:Task -0.11132953     0.0053251089 0.07297334 Available
#> 6   Rater:Task  0.06976932     0.0276174789 0.16618507 Available
#> 7     Residual -0.01083917     0.0007222732 0.02687514 Available

# Incomplete assignments also work, but their moment calculation is longer.
# These saved results use the same ratings with rows 1, 8 and 23 omitted.
# Omitted ratings are absent observations, never zero scores.
incomplete <- readRDS(system.file("examples", "gstudy-sampling.rds",
                                  package = "mfrmr", mustWork = TRUE))
incomplete$study$design
#> $person
#> [1] "Person"
#> 
#> $rater
#> [1] "Rater"
#> 
#> $task
#> [1] "Task"
#> 
#> $scores
#> [1] "Content"      "Organization"
#> 
#> $facets
#>   Rater    Task 
#> "Rater"  "Task" 
#> 
#> $count_columns
#>    Rater     Task 
#> "Raters"  "Tasks" 
#> 
#> $counts
#> Person  Rater   Task 
#>     40      8      6 
#> 
#> $levels
#> $levels$Person
#>  [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10" "11" "12" "13" "14" "15"
#> [16] "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"
#> [31] "31" "32" "33" "34" "35" "36" "37" "38" "39" "40"
#> 
#> $levels$Rater
#> [1] "1" "2" "3" "4" "5" "6" "7" "8"
#> 
#> $levels$Task
#> [1] "1" "2" "3" "4" "5" "6"
#> 
#> 
#> $rows
#> [1] 1917
#> 
#> $nesting
#> NULL
#> 
#> $child_counts
#> NULL
#> 
#> $balanced
#> [1] FALSE
#> 
#> $complete
#> [1] FALSE
#> 
#> $potential_cells
#> [1] 1920
#> 
#> $observed_fraction
#> [1] 0.9984375
#> 
#> $method
#> [1] "Multivariate MINQUE(0)"
#> 
#> $score_convention
#> [1] "Means over common random raters and tasks"
#> 
#> $calculation_version
#> [1] 2
#> 
attr(incomplete$variance, "summary")
#>         Source  Estimate SamplingVariance         SE  SEStatus
#> 1       Person 0.9461647      0.076504531 0.27659452 Available
#> 2        Rater 0.8072029      0.239431991 0.48931788 Available
#> 3         Task 1.6208397      0.921356363 0.95987310 Available
#> 4 Person:Rater 1.0126988      0.010217691 0.10108260 Available
#> 5  Person:Task 0.9266872      0.011308107 0.10633958 Available
#> 6   Rater:Task 1.1786624      0.078418884 0.28003372 Available
#> 7     Residual 1.0088781      0.001580505 0.03975556 Available
attr(incomplete$covariance, "summary")
#>         Source    Estimate SamplingVariance         SE  SEStatus
#> 1       Person -0.08472677     0.0389429831 0.19733977 Available
#> 2        Rater  0.27916523     0.1303902391 0.36109589 Available
#> 3         Task  0.27819934     0.1336031299 0.36551762 Available
#> 4 Person:Rater -0.11681953     0.0052861207 0.07270571 Available
#> 5  Person:Task -0.11212412     0.0053908081 0.07342212 Available
#> 6   Rater:Task  0.06643709     0.0278149937 0.16677828 Available
#> 7     Residual -0.01494854     0.0007523036 0.02742815 Available
attr(incomplete$covariance, "notes")
#> [1] "Sampling covariance of original ANOVA/MINQUE component estimates, conditional on the declared assignment under independent normal random effects. This is not measurement SEM, covariance between individual ratings or the SE of a separate REML estimator."
#> [2] "Gaussian product-moment correction gives unbiased identifiable sampling-covariance entries under the model. Taking square roots is not an unbiasedness guarantee for SEs and does not justify normal-reference confidence intervals."                        
#> [3] "Negative sampling variances are retained, with unavailable SEs. Unidentified entries are NA. An indefinite matrix is not repaired; inspect summary and diagnostics before propagating it to another target."                                                 
#> [4] "Scores and composite weights are prespecified; omission must preserve the model conditional on assignment. No robustness, informative-missingness correction or general confidence-interval coverage is claimed. Save the complete result with saveRDS()."   
# To repeat the full incomplete-data calculation:
# source(system.file("examples", "gstudy-sampling.R", package = "mfrmr"))
# incomplete <- gstudy_sampling_example()
```
