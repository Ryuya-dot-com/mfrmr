# Print APA narrative text with preserved line breaks

Print APA narrative text with preserved line breaks

## Usage

``` r
# S3 method for class 'mfrm_apa_text'
print(x, ...)
```

## Arguments

- x:

  Character text object from `build_apa_outputs()$report_text`.

- ...:

  Reserved for generic compatibility.

## Value

The input object (invisibly).

## Details

Prints APA narrative text with preserved paragraph breaks using
[`cat()`](https://rdrr.io/r/base/cat.html). This is preferred over bare
[`print()`](https://rdrr.io/r/base/print.html) when you want readable
multi-line report output in the console.

## Interpreting output

The printed text is the same content stored in
`build_apa_outputs(...)$report_text`, but with explicit paragraph
breaks.

## Typical workflow

1.  Generate `apa <- build_apa_outputs(...)`.

2.  Print readable narrative with `apa$report_text`.

3.  Use `summary(apa)` to check completeness before manuscript use.

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
diag <- diagnose_mfrm(fit, residual_pca = "none")
apa <- build_apa_outputs(fit, diag)
apa$report_text
#> Method.
#> 
#> Design and data.
#> A many-facet rating-scale Rasch model was fit to 768 observations from 48 persons scored on
#> a 4-category scale (1-4). The design included facets for Rater (n = 4), Criterion (n = 4).
#> The smallest non-person facet-level count was 192 retained rating rows, placing it in the
#> package's 'strong' screening band. These counts are not counts of independent examinees or
#> effective sample sizes and do not establish precision or interval coverage. Review
#> targeting, connectedness and estimator-specific uncertainty alongside
#> `facet_small_sample_review()`.
#> 
#> Estimation settings.
#> The RSM specification was estimated using JML with mfrmr. Precision summaries were
#> exploratory in this run. Recommended use for this precision profile: JML standard errors
#> and normal bands are exploratory approximations. Changing to MML does not by itself
#> establish valid uncertainty; review the fitted model and its uncertainty assumptions..
#> Optimization met the numerical convergence checks after 203 function evaluations and 53
#> gradient evaluations (LogLik = -820.949). MML model-comparison criteria are unavailable for
#> this fit; numerical completion alone does not establish comparability. Legacy descriptive
#> AIC = 1753.898; legacy descriptive BIC = 2013.950; neither enters the common MML ranking
#> panel. Terminal gradient sup-norm = 0.0001 (review threshold = 0.0001). Constraint
#> settings: noncenter facet = Person; anchored levels = 0 (facets: none); group anchors = 0
#> (facets: none); dummy facets = none. Centered facets sum to zero across all levels,
#> including anchors and group totals.
#> 
#> Results.
#> 
#> Scale functioning.
#> Category counts were available for all 4 categories: 0 unused and 0 below 10. Counts alone
#> do not establish category adequacy. Adjacent threshold comparisons: 0 decreasing among 2
#> available; 0 of 2 comparisons unavailable. Available estimates range from -1.32 to 1.38
#> logits. Adjacent threshold comparisons: 0 decreasing among 2 available; 0 of 2 comparisons
#> unavailable.
#> 
#> Facet measures.
#> Person measures ranged from -2.18 to 2.68 logits (M = 0.00, SD = 1.10). Rater measures
#> ranged from -0.33 to 0.33 logits (M = -0.00, SD = 0.31). Criterion measures ranged from
#> -0.42 to 0.25 logits (M = 0.00, SD = 0.29).
#> 
#> Fit and precision.
#> Overall mean-square fit was within the 0.5-1.5 screening band (infit MnSq = 0.99, outfit
#> MnSq = 1.02). This band is the package's review convention; published mean-square
#> guidelines differ, and band position is screening evidence rather than a model-validity
#> decision. MnSq outside [0.5, 1.5]: 1 of 56 classified elements flagged; 0 of 56 elements
#> unclassified. Largest misfit signals among 56 elements with complete paired statistics:
#> Person:P023 (|ZSTD| = 2.20); Person:P018 (|ZSTD| = 1.79); Person:P048 (|ZSTD| = 1.60).
#> Criterion exploratory reliability summary = 0.89 (separation = 2.78). Person exploratory
#> reliability summary = 0.90 (separation = 3.01). Rater exploratory reliability summary =
#> 0.90 (separation = 3.05). Separation reliability describes differences among facet
#> locations relative to their estimation errors. High Person values indicate distinguishable
#> abilities; high rater values indicate distinguishable severities, not inter-rater
#> agreement. Low rater values can also reflect imprecision and do not establish agreement.
#> The index does not test every rater pair or quantify the practical size of severity
#> differences. Reliability, separation and Strata are approximate compatibility indices using
#> marginal SEs; joint-information SEs do not validate this variance decomposition. They do
#> not account for covariance among estimates. EAP-based separation is not posterior-variance
#> EAP reliability. Model and fit-adjusted values are companion indices, not confidence
#> limits. Strata describes hypothetical distinguishable strata, not discovered groups. Facet
#> heterogeneity chi-square summaries use diagonal SE weights, not full-covariance joint
#> tests. Inter-rater agreement for Rater is reported separately from separation reliability.
#> Diagnostics match scores within Person and all remaining non-rater facets; each compared
#> pair contributes one opportunity per matched context. The denominator is 1152
#> matched-context opportunities across rater pairs, not a count of independent people. 6 of 6
#> candidate rater pairs have matched scores. Observed exact agreement = 0.36; observed
#> adjacent agreement (absolute score difference at most 1, including exact matches) = 0.83;
#> model-expected exact agreement = 0.37. The model-expected baseline uses fitted category
#> probabilities with calibration fixed; it is not chance agreement or an inferential test. It
#> assumes conditional independence at the saved Person point score (EAP for MML), rather than
#> integrating over the Person posterior. These descriptive summaries do not classify rater
#> quality or establish fairness. Element-level 95% approximate intervals (Normal
#> approximation) accompany 56 of 56 estimates; 0 of 56 estimates have intervals eligible for
#> primary reporting.
#> 
#> Reporting cautions.
#> Precision note: this run relies on exploratory precision summaries, so confidence intervals
#> and reliability summaries should not be treated as formal inferential quantities.
```
