# GPCM Workflow, Identification, and Score Availability

Reference for one-family and provisional two-family `GPCM` support in
`mfrmr`. Call `mfrmr_output_guide("gpcm_capabilities")`
(`view = "workflows"`, `"scores"`, or `"unavailable"`) to inspect
route-level availability, interpretive boundaries, and recommended
alternatives.

## Details

Workflow `Status` values in `mfrmr_output_guide("gpcm_capabilities")`:

- `supported`: available within the stated `Boundary`;

- `supported_with_caveat`: runs with restricted interpretation in
  `Boundary`;

- `blocked`: intentionally stops for a `GPCM` fit;

- `deferred`: not currently implemented in `mfrmr` (follow
  `RecommendedRoute`).

Score-view (`view = "scores"`) statuses distinguish
`available_with_caveat`, `supporting_route`, and `unavailable`.

**One-family vs two-family scope.** One-family `GPCM` estimates positive
relative discriminations (geometric mean `1`) on `slope_facet`; MML
permits `slope_facet != step_facet` and defaults to
`gpcm_mml_identification = "free_population"` (estimating population SD
\\\sigma\\, so standardized unit-variance slopes are \\a_i =
\sigma\alpha_i\\), whereas JML requires `slope_facet == step_facet` and
offers exploratory location SEs without structural slope intervals.
Provisional two-family `GPCM` requires fixed \\N(0,1)\\ MML (`"em"`
fixed-grid or `"direct"` adaptive) on zero-based unweighted integer
scores (`0:rating_max`). When extreme responses occur on one
non-reference facet, `fit$point_limit` records any supported
limiting-likelihood refit (`PrimaryEstimate` vs working
`OptimizerEstimate`, or `neutral_boundary_reference` when full
optimization is skipped).

## Intervals, model comparison, and software alignment

|  |  |
|----|----|
| Target | Entry and requirement |
| Relative / standardized slope intervals | [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md) (`parm = "slopes"`): joint observed information (or Person/cluster sandwich, or 1-parameter `"profile"`); inspect `CIEligible` and `CoverageQualified` |
| Facet locations, steps, and curves | [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md), `confint(fit, parm = "steps")` (two-family), [`mfrm_curve_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md) |
| IC ranking and nested equal-slope LRT | [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md) (`ICSelectable`, `ICFitEligible`, `ICComparable`; `nested = TRUE` requires matched population and step constraints) |
| Conditional Person scoring | [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md) and [`extract_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md) (fixed calibration + normal prior; excludes calibration uncertainty) |

Because `mfrmr` multiplies the complete adjacent-category predictor
\\\alpha_g(\theta_n - \delta_j - \beta_i - \tau\_{h,k})\\ by the slope,
comparisons with `TAM` or ConQuest must match slope placement,
population SD, and centering constraints. Worked derivations and
empirical examples appear on the package website
(<https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.html>).

## References

Muraki, E. (1992). A generalized partial credit model: Application of an
EM algorithm. *Applied Psychological Measurement, 16*(2), 159–176.
[doi:10.1177/014662169201600206](https://doi.org/10.1177/014662169201600206)

Masters, G. N. (1982). A Rasch model for partial credit scoring.
*Psychometrika, 47*(2), 149–174.
[doi:10.1007/BF02296272](https://doi.org/10.1007/BF02296272)

Bock, R. D., & Aitkin, M. (1981). Marginal maximum likelihood estimation
of item parameters: Application of an EM algorithm. *Psychometrika,
46*(4), 443–459.
[doi:10.1007/BF02293801](https://doi.org/10.1007/BF02293801)

## See also

[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md),
[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md),
[`mfrm_curve_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md),
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)

## Examples

``` r
mfrmr_output_guide("gpcm_capabilities")
#> mfrmr GPCM workflow availability
#> Most rows describe one slope family; two-family MML has a separate provisional scope.
#> MML IC comparison and PCM/GPCM tests have separate checks; relative-slope intervals use separate MML checks.
#> 
#>                 Status Routes
#>              supported      2
#>  supported_with_caveat     19
#>                blocked      1
#>               deferred      2
#> 
#> Route preview
#>                                             Area                Status
#>                       Core fitting and summaries supported_with_caveat
#>   Exploratory diagnostics and residual follow-up supported_with_caveat
#>  Fitted-object posterior scoring and information             supported
#>                    Core curve and category views             supported
#>       Checklist and summary-table appendix route supported_with_caveat
#>                      Operational misfit casebook supported_with_caveat
#>         Weighting review and model-choice review supported_with_caveat
#>                    Operational linking synthesis supported_with_caveat
#> 
#> ... 16 more route(s).
#> 
#> Filter by status, for example mfrmr_output_guide("gpcm_capabilities", "supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
mfrmr_output_guide("gpcm_capabilities", "supported")
#> mfrmr GPCM workflow availability
#> Most rows describe one slope family; two-family MML has a separate provisional scope.
#> MML IC comparison and PCM/GPCM tests have separate checks; relative-slope intervals use separate MML checks.
#> 
#>     Status Routes
#>  supported      2
#> 
#> Route preview
#>                                             Area    Status
#>  Fitted-object posterior scoring and information supported
#>                    Core curve and category views supported
#> 
#> Filter by status, for example mfrmr_output_guide("gpcm_capabilities", "supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
mfrmr_output_guide("gpcm_capabilities", view = "scores")
#>                            Capability                Status
#> 1       Package-native score estimand available_with_caveat
#> 2   Slope-aware expected-score fields available_with_caveat
#> 3            Native score uncertainty available_with_caveat
#> 4 FACETS-compatible score uncertainty           unavailable
#> 5 Structural fair-average uncertainty      supporting_route
#> 6  Equal-discrimination PCM reference      supporting_route
#> 7     Package-native scorefile export available_with_caveat
#> 8       Full FACETS score-side review           unavailable
#> 9            Reporting interpretation available_with_caveat
#>                                                                                                                                                                                       Limitation
#> 1                                                            Expected-score and residual quantities are package-native GPCM outputs, not Rasch measure-to-score or FACETS-equivalent quantities.
#> 2                                                                               Expected-score fields use the fitted slope structure and therefore depend on the declared step and slope facets.
#> 3                                                                       Uncertainty fields require the relevant MML diagnostics; otherwise the scorefile reports an explicit unavailable status.
#> 4                                                                                             No FACETS-compatible free-discrimination score-side uncertainty definition is currently available.
#> 5 Structural fair-average SEs condition on Person EAP/reference means and remain diagnostic-only (FairCIEligible = FALSE); full-refit coverage and FACETS score-side equivalence are unverified.
#> 6                                                           Unit-slope agreement with PCM is an interpretation reference, not evidence that every free-slope score quantity is Rasch-equivalent.
#> 7                                                                                                               The exported scorefile is package-native and must retain its GPCM caveat fields.
#> 8                                                                                                           The full FACETS-style score-side review is unavailable for free-discrimination GPCM.
#> 9                                                                                                 GPCM score-side output is sensitivity evidence, not an automatic operational scoring decision.
#>                                                                                                                              Alternative
#> 1                                  Use `facets_output_file_bundle(include = "score")` and report the package-native estimand explicitly.
#> 2                                 Inspect the fitted step and slope summaries before interpreting exported expected scores or residuals.
#> 3                Use an MML fit when uncertainty is required, or report the explicit unavailable status without substituting another SE.
#> 4             Use the package-native scorefile with caveats; use an `RSM` or `PCM` fit when a full FACETS score-side review is required.
#> 5 Use `fair_average_table(fit, fair_se = TRUE)` directly and label the result as slope-aware element-conditional diagnostic uncertainty.
#> 6                                           Fit a `PCM` reference when equal-discrimination score semantics are required for comparison.
#> 7                                           Use `facets_output_file_bundle(include = "score")` and retain all status and caveat columns.
#> 8                                                          Keep full `facets_output_contract_review()` work on the `RSM` or `PCM` route.
#> 9                                                Report GPCM as a slope-aware sensitivity analysis and keep operational claims separate.
mfrmr_output_guide("gpcm_capabilities", view = "unavailable")
#>                                                       Area
#> 1                 FACETS output-contract score-side review
#> 2            Native MCMC and posterior-predictive sampling
#> 3 Formal structural confidence intervals for corrected JML
#>                            Helper   Status
#> 1 facets_output_contract_review()  blocked
#> 2                            <NA> deferred
#> 3                            <NA> deferred
#>                                                                                                                                                                                                                                                                                                                                                   Boundary
#> 1                                                                                     Limited to direct scorefile export rather than the full FACETS-style output-contract review. Direct scorefile export is available with caveats, but contract-wide coverage and metric claims still require a broader free-discrimination score-side review contract.
#> 2 mfrmr does not run native GPCM MCMC or posterior-predictive sampling. export_mfrm_model() writes Stan/brms code for eligible one-family MML sources and Stan code for two-family sources, adding explicit structural priors and retaining supported fixed constraints. Conditional posterior response diagnostics are a different, non-MCMC calculation.
#> 3                                 Formal corrected-JML structural intervals are unavailable. The explicit corrected estimator reports local adjusted-equation RootSE, not established structural coverage. Uncorrected JML location SEs and post-hoc Person intervals answer different questions. None is a bias-corrected structural confidence interval.
#>                                                                                                                                                                                                                                                                                             RecommendedRoute
#> 1                                                                                                 Use direct fair-average tables and graph-only compatibility outputs; use package-native scorefile export with its stated caveats, and keep full FACETS output-contract reviews on the `RSM` / `PCM` route.
#> 2 Use MML and conditional posterior scoring for their stated targets. Use export_mfrm_model(format = 'stan' or 'brms') for eligible one-family sources, or format = 'stan' for two-family sources. Then review priors, sampler diagnostics and posterior fit; code export is not native Bayesian estimation.
#> 3                                                                                                                          Use current JML outputs within their descriptive scope, or explicitly choose MML inference if its population assumptions suit the analysis; do not transfer MML intervals to JML.
```
