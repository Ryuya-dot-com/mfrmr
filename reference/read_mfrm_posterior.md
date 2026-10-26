# Read an exported Bayesian measurement summary

Bring a saved Stan/brms summary back into mfrmr for figures and reports,
without loading either backend or running an estimator.

## Usage

``` r
read_mfrm_posterior(path)

# S3 method for class 'mfrm_posterior_summary'
print(x, ...)

# S3 method for class 'mfrm_posterior_summary'
summary(object, ...)

# S3 method for class 'mfrm_posterior_summary'
confint(object, parm = NULL, level = 0.95, ...)
```

## Arguments

- path:

  An export directory containing `posterior-summary.rds` and its
  matching `model-data.rds`, or the path to that summary file.

- x, object:

  A saved `mfrm_posterior_summary`.

- ...:

  Unused.

- parm:

  Optional saved parameter names (for example `"locations[1]"`) or row
  indices in `$parameters`. `NULL` returns mapped model parameters.

- level:

  The stored level, currently `0.95`. Other levels require posterior
  draws and are rejected rather than approximated from an SD.

## Value

An `mfrm_posterior_summary` containing unrounded parameter and
diagnostic tables, source settings, priors, mappings and constraints.

## Details

Run the exported bundle's `Rscript run.R --summarize` first. The reader
checks the recorded model-data checksum, parameter mappings, fixed-value
semantics and consistency of the saved sampling checks. Older summaries
without a checksum must be regenerated with the current bundled `run.R`
and `summarize.R`; no new sampling is needed. Keep the original
`model-data.rds` bytes with the fit when moving an export directory.

These checks detect mismatched files and inconsistent summaries; they do
not independently verify draws, convergence, prior adequacy or model
fit. The object contains marginal summaries, not joint posterior draws
or a native fitted model. It supports
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
and
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md).
Use the backend's saved fit for new credible levels, contrasts,
predictions, trace plots or posterior predictive checks. Native scoring
and MML/JML diagnostics are not available from this object.

[`confint()`](https://rdrr.io/r/stats/confint.html) retrieves the stored
equal-tailed 95% *posterior credible* intervals, retaining
fixed/unavailable rows and review flags. It does not calculate
frequentist confidence intervals or change the saved level. Fixed
anchors and constraint-determined values have no estimated SD or
interval. External calibration uncertainty has not been propagated.
[`summary()`](https://rdrr.io/r/base/summary.html) returns the complete
validated summary; printing is compact. The bundled synthetic example
uses short chains and requires sampling review. Its numbers are workflow
illustrations, not assessment findings.

## See also

[`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md),
[`plot.mfrm_posterior_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_posterior_summary.md)

## Examples

``` r
directory <- system.file("extdata", "posterior-example", package = "mfrmr")
posterior <- read_mfrm_posterior(directory)
summary(posterior) # Read the decision and next action before the estimates.
#> External Bayesian measurement summary
#> GPCM | Stan | Fixed N(0,1) 
#> Review sampling before interpreting intervals
#> Why: Fewer than four chains; Chain mixing (R-hat) needs review; Effective sample size for central summaries needs review
#> Next: inspect $checks, then model fit, prior sensitivity and target-specific MCSE.
#> 53 mapped parameters; fixed values have no estimated interval.
#>                Parameter         Role   Mean  Lower  Upper        Interval
#>             Person: p001    estimated -0.403 -1.414  0.543 Sampling review
#>                 Task: t1 fixed_anchor  0.400     NA     NA     Fixed value
#>                 Task: t2    estimated -0.272 -0.471 -0.078 Sampling review
#>  Step owner: r1 | 0 -> 1 fixed_anchor  0.250     NA     NA     Fixed value
#>  Step owner: r1 | 1 -> 2    estimated -1.061 -1.997 -0.058 Sampling review
#>                 Task: t1    estimated  0.635  0.445  0.887 Sampling review
#> Use $parameters, confint(x), plot(x), or mfrm_report(x). Sampling checks do not establish model validity.
intervals <- confint(posterior)
head(intervals[, c("facet", "level", "value_role", "lower", "upper", "interval_status")])
#>    facet level value_role      lower      upper
#> 2 Person  p001  estimated -1.4139833  0.5430092
#> 3 Person  p002  estimated -1.8840950 -0.7452628
#> 4 Person  p003  estimated -1.2022894  0.6702318
#> 5 Person  p004  estimated -1.7130268  0.1526192
#> 6 Person  p005  estimated -0.5258744  0.2955422
#> 7 Person  p006  estimated -2.7862091 -0.3048554
#>                     interval_status
#> 2 computed_sampling_review_required
#> 3 computed_sampling_review_required
#> 4 computed_sampling_review_required
#> 5 computed_sampling_review_required
#> 6 computed_sampling_review_required
#> 7 computed_sampling_review_required
report <- mfrm_report(posterior, style = "apa", study_context = c(
  score_direction = "Higher coded scores indicate more favorable performance"))
summary(report, view = "reader")
#> mfrmr Report Summary
#> 
#> Overview
#>  Style OverallStatus
#>    apa        review
#>                                                                                    FirstAction
#>  Read report$tables$sampling_review; resolve recorded sampling concerns before interpretation.
#>  ReviewAreas NotComputedAreas CaveatAreas OptionalAreas UnavailableAreas
#>            0                0           0             0                0
#>  OkAreas          SourceInclude
#>        0 mfrm_posterior_summary
#> 
#> First screen
#>     Area Status                                     Readiness
#>  Overall review Review sampling before interpreting intervals
#>                                                                                                                                                          MainIssue
#>  Review sampling before interpreting intervals Fewer than four chains; Chain mixing (R-hat) needs review; Effective sample size for central summaries needs review
#>                                                                                     NextAction
#>  Read report$tables$sampling_review; resolve recorded sampling concerns before interpretation.
#>                                        PrimaryRoute
#>  report$tables$sampling_review; plot(x); confint(x)
```
