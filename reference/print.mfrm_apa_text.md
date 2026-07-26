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
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
apa <- build_apa_outputs(fit, diag)
apa$report_text
#> Method.
#> 
#> Design and data.
#> A many-facet rating-scale Rasch model was fit to 768 observations from 48 persons scored on
#> a 4-category scale (1-4). The design included facets for Rater (n = 4), Criterion (n = 4).
#> Facet-level sample sizes were strong (smallest level N = 192), though facets were still
#> estimated as fixed effects with sum-to-zero identification;
#> `analyze_hierarchical_structure()` is available for nesting and variance-component
#> follow-up.
#> 
#> Estimation settings.
#> The RSM specification was estimated using JML with mfrmr. Precision summaries were
#> exploratory in this run. Recommended use for this precision profile: Use for screening and
#> calibration triage; confirm formal SE, CI, and reliability with an MML fit.. Optimization
#> did not meet the package convergence checks after 76 function evaluations and 30 gradient
#> evaluations (LogLik = -820.949, AIC = 1753.898, BIC = 2013.950). Terminal gradient sup-norm
#> = 0.0035 (review threshold = 0.0001). Optimizer reached the iteration limit before the
#> terminal gradient became small enough for review-only acceptance. Constraint settings:
#> noncenter facet = Person; anchored levels = 0 (facets: none); group anchors = 0 (facets:
#> none); dummy facets = none.
#> 
#> Results.
#> 
#> Scale functioning.
#> Category usage was adequate (unused categories = 0, low-count categories = 0), and
#> thresholds were ordered. Step/threshold summary: 3 step(s); estimate range = -1.32 to 1.38
#> logits; no disordered steps.
#> 
#> Facet measures.
#> Person measures ranged from -2.18 to 2.68 logits (M = 0.00, SD = 1.10). Rater measures
#> ranged from -0.33 to 0.33 logits (M = 0.00, SD = 0.31). Criterion measures ranged from
#> -0.42 to 0.25 logits (M = 0.00, SD = 0.29).
#> 
#> Fit and precision.
#> Overall mean-square fit was within the 0.5-1.5 screening band (infit MnSq = 0.99, outfit
#> MnSq = 1.02). This band is the package's review convention; published mean-square
#> guidelines differ, and band position is screening evidence rather than a model-validity
#> decision. 1 of 56 elements fell outside the 0.5-1.5 mean-square screening band. Largest
#> misfit signals: Person:P023 (|ZSTD| = 3.06); Person:P018 (|ZSTD| = 1.51);
#> Criterion:Organization (|ZSTD| = 1.43). Criterion exploratory reliability summary = 0.89
#> (separation = 2.78). Person exploratory reliability summary = 0.90 (separation = 3.01).
#> Rater exploratory reliability summary = 0.90 (separation = 3.05). These are
#> Rasch/FACETS-style separation indices (measure spread relative to measurement error), not
#> inter-rater agreement. Observed inter-rater agreement is reported separately from
#> separation reliability: for Rater, exact agreement = 0.36, expected exact agreement = 0.37,
#> adjacent agreement = 0.83. Element-level 95% confidence intervals (Normal approximation)
#> accompany the measures (CI_Lower / CI_Upper); 0 of 56 rows are flagged CIEligible for
#> primary reporting.
#> 
#> Residual structure.
#> Exploratory residual PCA (overall standardized residual matrix) showed PC1 eigenvalue =
#> 2.11 (13.2% variance), with PC2 eigenvalue = 1.83. Facet-specific exploratory residual PCA
#> showed the largest first-component signal in Rater (eigenvalue = 1.72, 43.0% variance).
#> Heuristic reference bands: EV >= 1.4 (critical minimum), >= 1.5 (caution), >= 2.0 (common),
#> >= 3.0 (strong); variance >= 5% (minor), >= 10% (caution), >= 20% (strong).
#> 
#> Reporting cautions.
#> Precision note: this run relies on exploratory precision summaries, so confidence intervals
#> and reliability summaries should not be treated as formal inferential quantities.
# }
```
