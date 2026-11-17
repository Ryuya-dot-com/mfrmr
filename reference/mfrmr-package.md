# mfrmr: Many-Facet Ordered-Response Modeling in R

Analyze ordered ratings involving raters, tasks and criteria. The
package provides measurement models, observed-score assessment planning
and rater feedback. Choose a route from the question; these are not
compulsory stages of a single analysis.

## Five-question workflow map

|  |  |  |
|----|----|----|
| Question | Start with | Inspect next |
| Person abilities and facet effects | [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md), [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md) | `summary(fit)$decision`, estimate tables |
| Rater/task counts and score weights | [`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md), [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md) | Declared design, `G`/`Phi`, interval status |
| Ratings or rater patterns needing review | [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md), [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md), [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md) | Diagnostic target, counts, availability reasons |
| Observed rater score agreement | [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md) or pairwise agreement helpers | Matched units, agreement definition, denominator |
| Scoring new Persons on a fixed calibration | [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md) or [mfrm_calibration_workflow](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md) | Conditional EAP/SD, prior, source checks |

Observed agreement and G-Study/D-Study planning use raw ratings directly
and do not establish MFRM fit; rater severity separation is distinct
from inter-rater agreement. See
[`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md)
and
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)
for step-by-step routes.

## Choose an analysis route

- **Measurement:**
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  reviews rating rows and the design;
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  estimates Person abilities, facet effects and category steps within
  the selected model's scope. Read `summary(fit)$decision` before
  interpreting the estimates. The example below starts with bundled
  ratings.

- **Assessment planning:**
  [`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
  estimates observed-score variance components;
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  compares specified rater/task plans. Neither requires an MFRM fit.
  G/Phi refer to the declared score and replication plan.

- **Rater feedback:**
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  describes agreement,
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  reviews supported response-fit diagnostics, and
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  /
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  address specified interaction/group questions. Severity, agreement and
  fit are different targets.

## Learning and reference

Use
[`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md)
for a first analysis and importing your own ratings. The model-choice,
G-theory, visual-diagnostics and reporting tutorials address the
corresponding decisions; list installed tutorials with
`vignette(package = "mfrmr")`.

mfrmr_workflow_methods connects the main result objects. Use
[mfrmr_methods_reference](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md)
to locate definitions and methodological sources, or
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)
for the five central routes. Use `mfrmr_output_guide("all")` to find
specialist tables, figures or exports. Function help gives the installed
version's arguments, calculations and limitations. Additional packages
are required only by the features that name them in their help. Cite
`citation("mfrmr")` and the methods actually used.

## Saved analyses

Keep complete result objects with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) and record the
package version and analysis settings. Reopening with
[`base::readRDS()`](https://rdrr.io/r/base/readRDS.html) does not update
calculations.
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
distinguishes redisplaying, recomputing derived results and refitting
when updating older analyses. For scoring against a portable fixed
calibration, use
[mfrm_calibration_workflow](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md);
this is a different artifact from a saved fit.

## Interpretation

Model, estimator, score coding, assignment and uncertainty assumptions
must match the intended use. A returned estimate, numerical convergence
and an available interval are separate results. The specialist help and
returned status/reason fields state the applicable restrictions; a
review flag is not an automatic judgment of rater quality or fairness.

## See also

Useful links:

- <https://ryuya-dot-com.github.io/mfrmr/>

- <https://github.com/Ryuya-dot-com/mfrmr>

- Report bugs at <https://github.com/Ryuya-dot-com/mfrmr/issues>

## Author

**Maintainer**: Ryuya Komuro <ryuya.komuro.c4@tohoku.ac.jp>
([ORCID](https://orcid.org/0000-0001-9205-0926)) \[copyright holder\]

Authors:

- Ryuya Komuro <ryuya.komuro.c4@tohoku.ac.jp>
  ([ORCID](https://orcid.org/0000-0001-9205-0926)) \[copyright holder\]

## Examples

``` r
# Load the package
library(mfrmr)

# Load example ratings and look at the first six rows
ratings <- load_mfrmr_data("example_operational")
head(ratings)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A

# Fit the model
fit <- fit_mfrm(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1, rating_max = 4, category_policy = "preserve",
  method = "MML",
  model = "RSM"
)

# Read the interpretation status before examining or plotting estimates
results <- summary(fit)
results$decision
#>                                                           Interpretation
#> 1 Fit-readiness requirements satisfied; formal precision review required
#>   FormalInference FitReadiness
#> 1              No        ready
#>                                                                                                                                                                                                                                      Why
#> 1 Formal precision support has not been evaluated. These checks assess numerical readiness and the requested precision method under the specified model; they do not establish model adequacy or finite-sample coverage for this design.
#>                                                                                                                                                   NextAction
#> 1 Run `diagnose_mfrm()` and pass its result as `diagnostics =` to evaluate formal precision support; fit readiness alone is not a formal-inference decision.
results$person_overview # One row summarizing person ability estimates
#> # A tibble: 1 × 11
#>   Persons DistributionN ReviewExcludedExtremeE…¹ EstimateUse   Mean    SD Median
#>     <int>         <int>                    <int> <chr>        <dbl> <dbl>  <dbl>
#> 1      48            48                        0 source_fit… -0.155 0.824 -0.208
#> # ℹ abbreviated name: ¹​ReviewExcludedExtremeEAPs
#> # ℹ 4 more variables: Min <dbl>, Max <dbl>, Span <dbl>, MeanPosteriorSD <dbl>
results$facet_overview  # One row per facet: number of levels, mean, SD, range
#> # A tibble: 2 × 7
#>   Facet     Levels MeanEstimate SDEstimate MinEstimate MaxEstimate  Span
#>   <chr>      <int>        <dbl>      <dbl>       <dbl>       <dbl> <dbl>
#> 1 Criterion      3     0             0.302      -0.344       0.224 0.568
#> 2 Rater          6    -4.64e-18      0.399      -0.606       0.412 1.02 

# Plot the results (Wright map) within the reported interpretation limits
plot(fit)
```
