# Package index

## Measurement: fit and interpret ratings

Follow [how the functions
connect](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr.html#how-functions-connect).
Keep the input and result objects at each step. The measurement route
below is for ordinary RSM/PCM MML/JML; G-theory planning starts
separately from observed scores. Other models use their documented
output routes.

### Step 1: Prepare rating data

Input: one row per rating. describe_mfrm_data() returns a design review;
pass the rating data itself to fit_mfrm().

- [`list_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)
  [`load_mfrmr_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/load_mfrmr_data.md)
  : List packaged ordered-response MFRM datasets
- [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  [`summary(`*`<mfrm_data_description>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  [`plot(`*`<mfrm_data_description>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  : Check rating data before fitting an MFRM

### Step 2: Fit and inspect the model

Keep fit \<- fit_mfrm(…). summary(fit) shows tables; it does not replace
fit or compute the default diagnostics.

- [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  [`summary(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  [`print(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  [`print(`*`<mfrm_comparison_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  [`summary(`*`<mfrm_comparison_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  : Fit many-facet models to ordered ratings

### Step 3: Diagnose and collect evidence

Keep diagnostics \<- diagnose_mfrm(fit), then pass both fit and matching
diagnostics to mfrm_results().

- [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  [`summary(`*`<mfrm_diagnostics>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  [`plot(`*`<mfrm_diagnostics>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  : Review response fit and the support for uncertainty summaries
- [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  : Collect fitted estimates, diagnostics and reporting tables

### Step 4: Report and save

Pass collected results to mfrm_report() or export_mfrm_results().
G/D-study and other supported result objects enter mfrm_report()
directly.

- [`summary(`*`<mfrm_reporting_checklist>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  : Build reports from measurement, G-Study/D-Study, or residual results
- [`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
  : Export an mfrm_results analysis archive

### Extract estimates and uncertainty

Use these with fit when you need individual estimates, covariance,
fitted responses or supported intervals. They complement the compact
summary.

- [`coef(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`coef(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`coef(`*`<mfrm_comparison_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`vcov(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`vcov(`*`<mfrm_comparison_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`nobs(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`nobs(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`nobs(`*`<mfrm_comparison_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`logLik(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`logLik(`*`<mfrm_comparison_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`AIC(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`BIC(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`AIC(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`BIC(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`fitted(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`residuals(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`predict(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`fitted(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`fitted(`*`<mfrm_comparison_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`residuals(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`residuals(`*`<mfrm_comparison_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`predict(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`predict(`*`<mfrm_comparison_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`as.data.frame(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`vcov(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`logLik(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`summary(`*`<mfrm_jeffreys_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`print(`*`<mfrm_jeffreys_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`coef(`*`<mfrm_jeffreys_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`fitted(`*`<mfrm_jeffreys_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`vcov(`*`<mfrm_jeffreys_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`confint(`*`<mfrm_jeffreys_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  [`logLik(`*`<mfrm_jeffreys_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
  : Extract coefficients, covariance, likelihood and observation counts
- [`confint(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
  [`confint(`*`<mfrm_cml_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
  [`confint(`*`<mfrm_comparison_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
  : Confidence intervals for native fit coefficients and GPCM slopes

### Data examples

- [`mfrmr_example_data`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_example_data.md)
  [`mfrmr_example_operational`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_example_data.md)
  [`mfrmr_example_core`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_example_data.md)
  [`mfrmr_example_bias`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_example_data.md)
  : Synthetic many-facet rating examples
- [`mfrmr_example_operational_design`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_example_operational_design.md)
  : Planned assignment roster for the operational example
- [`mfrmr_gtheory_data`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gtheory_data.md)
  [`mfrmr_example_gtheory_crossed`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gtheory_data.md)
  [`mfrmr_example_gtheory_nested`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gtheory_data.md)
  : Synthetic crossed and nested data for learning G theory
- [`mfrmr_agreement_data`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_agreement_data.md)
  [`mfrmr_example_agreement`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_agreement_data.md)
  : Synthetic ratings illustrating agreement, offsets and missing scores

### Detailed estimation reference

Open the selected model or estimator’s section for calculation and
inference conditions.

- [`fit_mfrm_technical_details`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)
  : Technical Reference for fit_mfrm() Specifications, Controls, and
  Estimators

### Workflow and method guides

Choose a question, then follow the relevant analysis route; these are
not additional required steps.

- [`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)
  : Choose an mfrmr output helper by user goal
- [`mfrmr`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)
  [`mfrmr_workflow_methods`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)
  [`mfrmr-package`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)
  : mfrmr: Many-Facet Ordered-Response Modeling in R
- [`mfrmr_methods_reference`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md)
  : What mfrmr Calculates and Where to Read More

## Rating design and linking networks

Review who rated what, crossing/nesting and observed linking
vulnerabilities. Start with observed ratings or a planned roster;
inspect graph links before fitting, then check model identification.

- [`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md)
  : Analyze the hierarchical structure of a rating design
- [`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md)
  [`plot(`*`<mfrm_facet_nesting>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md)
  : Detect nesting structure between facets
- [`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md)
  [`plot(`*`<mfrm_facet_sample_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md)
  : Review rating counts for each facet level
- [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
  : Build a subset connectivity report (preferred alias)
- [`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md)
  : Analyze the MFRM design network
- [`build_mfrm_network_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md)
  [`summary(`*`<mfrm_network_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_network_review.md)
  : Build an MFRM network review
- [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  [`print(`*`<mfrm_sim_spec>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  [`build_peer_review_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  : Build an explicit simulation specification for MFRM design studies
- [`review_peer_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_peer_design.md)
  [`summary(`*`<mfrm_peer_review_design_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/review_peer_design.md)
  : Review a peer-assessment assignment design

## Missing assigned scores

Review response imputations, fit a common MFRM and pool eligible facet
targets.

- [`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  [`fit_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  [`print(`*`<mfrm_imputed_fits>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  [`summary(`*`<mfrm_imputed_fits>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  [`print(`*`<mfrm_pooled>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  [`summary(`*`<mfrm_pooled>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  [`plot(`*`<mfrm_pooled>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  [`review_mfrm_imputations()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  [`print(`*`<mfrm_response_imputations>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  [`summary(`*`<mfrm_response_imputations>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
  : Pool common facet targets across imputed rating analyses

## Assessment planning: G-Study and D-Study

Separate observed-score variation, project specified future plans, and
compare eligible prespecified plans. Start with the G-theory planning
article.

- [`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
  [`print(`*`<mfrm_multivariate_gstudy>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
  [`summary(`*`<mfrm_multivariate_gstudy>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
  : G-Study for one or several observed scores
- [`confint(`*`<mfrm_multivariate_gstudy>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md)
  [`vcov(`*`<mfrm_multivariate_gstudy>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md)
  : Sampling uncertainty in G-Study variance and covariance components
- [`plot(`*`<mfrm_multivariate_gstudy>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_multivariate_gstudy.md)
  : Inspect sources of observed-score variation
- [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  [`print(`*`<mfrm_multivariate_d_study>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  : Plan measurement conditions with a D-study
- [`confint(`*`<mfrm_multivariate_d_study>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md)
  [`summary(`*`<mfrm_multivariate_d_study>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md)
  [`print(`*`<summary.mfrm_multivariate_d_study>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md)
  [`plot(`*`<mfrm_dstudy_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md)
  : Confidence intervals for dependability and SEM in D-Study plans
- [`plot(`*`<mfrm_multivariate_d_study>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_multivariate_d_study.md)
  : Compare measurement-condition counts in a multivariate D-study
- [`summary(`*`<mfrm_multivariate_d_comparison>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study_comparison.md)
  [`print(`*`<mfrm_multivariate_d_comparison>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study_comparison.md)
  [`plot(`*`<mfrm_multivariate_d_comparison>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study_comparison.md)
  : Compare prespecified multivariate D-study plans
- [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  [`mfrm_d_study(`*`<mfrm_generalizability>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  [`plot(`*`<mfrm_d_study>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  [`mfrm_d_study(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  [`summary(`*`<mfrm_d_study>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  : Main-effects generalizability approximation for an MFRM design

## Facet and population uncertainty

Review fixed-facet estimates and contrasts, and experimental
conditional-normal population intervals, under their respective
assumptions.

- [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
  [`print(`*`<mfrm_facet_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
  [`summary(`*`<mfrm_facet_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
  [`confint(`*`<mfrm_facet_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
  [`vcov(`*`<mfrm_facet_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
  [`plot(`*`<mfrm_facet_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
  : Pointwise intervals for fixed facet estimates and contrasts
- [`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
  [`plot(`*`<mfrm_population_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
  [`print(`*`<mfrm_population_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
  [`summary(`*`<mfrm_population_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
  [`vcov(`*`<mfrm_population_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
  : Pointwise intervals for a conditional-normal population model

## Response probabilities and residuals

Describe observed ratings using each supported model’s probability
definition, without automatic fit cutoffs.

- [`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  [`plot(`*`<mfrm_response_diagnostics>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  [`summary(`*`<mfrm_response_diagnostics>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  [`print(`*`<mfrm_response_diagnostics>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  : Describe fitted response probabilities and residuals

## Shared random raters

Estimate a rater population and distinguish observed-rater feedback from
replacement-rater probabilities.

- [`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
  [`predict(`*`<mfrm_random_rater>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
  [`plot(`*`<mfrm_random_rater>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
  [`confint(`*`<mfrm_random_rater>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
  [`summary(`*`<mfrm_random_rater>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
  [`print(`*`<mfrm_random_rater>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
  : Fit a rating-scale model with shared random rater severity
- [`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md)
  [`summary(`*`<mfrm_random_rater_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md)
  [`print(`*`<mfrm_random_rater_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md)
  [`plot(`*`<mfrm_random_rater_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md)
  : Score Persons while integrating shared random raters
- [`mfrmr_model_maps`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_model_maps.md)
  : Wright and Pathway maps for extended RSMs
- [`mfrm_random_rater_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md)
  [`plot(`*`<mfrm_random_rater_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md)
  [`confint(`*`<mfrm_random_rater_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md)
  [`summary(`*`<mfrm_random_rater_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md)
  [`print(`*`<mfrm_random_rater_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md)
  : Bootstrap prediction intervals for observed random raters

## Person-specific testlets

Model local dependence within a Person and score conditionally on fitted
calibration.

- [`predict(`*`<mfrm_testlet>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  [`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  [`confint(`*`<mfrm_testlet>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  [`summary(`*`<mfrm_testlet_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  [`print(`*`<mfrm_testlet_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  [`plot(`*`<mfrm_testlet>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  [`plot(`*`<mfrm_testlet_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  [`summary(`*`<mfrm_testlet>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  [`print(`*`<mfrm_testlet>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  : Score Persons using a fixed testlet calibration

## Person scoring and conditional decisions

Score Persons, report posterior ability-band probabilities, or evaluate
future fixed-plan classification accuracy, consistency and conditional
precision.

- [`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
  [`summary(`*`<mfrm_person_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
  [`print(`*`<mfrm_person_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
  [`plot(`*`<mfrm_person_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
  : Estimate abilities for people already included in a fitted RSM
- [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  [`summary(`*`<mfrm_unit_prediction>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  : Score future or partially observed units under the fitted scoring
  basis
- [`classification_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/classification_table.md)
  : Evaluate classification accuracy, consistency and conditional
  precision
- [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  [`summary(`*`<mfrm_plausible_values>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  : Sample approximate plausible values under fitted posterior scoring

## Portable fixed calibration

Create, validate, freeze, persist, and apply eligible RSM/PCM or GPCM
MML/JML calibrations; review and export later score batches.

- [`summary(`*`<mfrm_calibration_score>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`print(`*`<mfrm_calibration_score>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`print(`*`<summary.mfrm_calibration_score>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`plot(`*`<mfrm_calibration_score>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`extract_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`review_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`update(`*`<mfrm_calibration>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`save_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`load_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`summary(`*`<mfrm_calibration>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`print(`*`<mfrm_calibration>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  [`print(`*`<summary.mfrm_calibration>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
  : Review and plot portable fixed-calibration scores

## GPCM slopes and model comparison

Relative-slope intervals, model comparisons, and the scope of GPCM
workflows.

- [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  [`summary(`*`<mfrm_extended_comparison>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  [`print(`*`<mfrm_extended_comparison>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  [`plot(`*`<mfrm_extended_comparison>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  : Compare fitted measurement models or prespecified assessment plans
- [`mfrmr_gpcm_scope`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md)
  : GPCM Workflow, Identification, and Score Availability
- [`bootstrap_mfrm_gpcm()`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md)
  [`confint(`*`<mfrm_gpcm_bootstrap>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md)
  [`summary(`*`<mfrm_gpcm_bootstrap>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md)
  [`print(`*`<mfrm_gpcm_bootstrap>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md)
  [`plot(`*`<mfrm_slope_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md)
  [`plot(`*`<mfrm_gpcm_bootstrap>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md)
  : Parametric bootstrap for GPCM slopes or a matched PCM comparison
- [`mfrm_curve_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md)
  [`summary(`*`<mfrm_curve_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md)
  [`print(`*`<mfrm_curve_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md)
  [`plot(`*`<mfrm_curve_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md)
  : Uncertainty in GPCM category probabilities and information curves
- [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
  [`summary(`*`<mfrm_model_choice_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
  : Build a model-choice review across RSM, PCM, and GPCM fits
- [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  [`summary(`*`<mfrm_weighting_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  : Build a weighting-policy review between Rasch-family and GPCM fits
- [`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
  : Review MML sensitivity to the quadrature grid
- [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  [`plot(`*`<mfrm_information>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  : Compute design-weighted precision curves for ordered many-facet fits

## Diagnostics and quality control

Fit review, residual diagnostics, precision, agreement, and QC
dashboards.

- [`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md)
  : Build a FACETS-style fit-measures review table
- [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)
  [`summary(`*`<mfrm_facet_dashboard>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)
  [`plot(`*`<mfrm_facet_dashboard>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)
  : Facet-quality dashboard for facet-level screening
- [`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md)
  : Build a measurable-data summary
- [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md)
  : Build a rating-scale diagnostics report
- [`krippendorff_alpha_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  [`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  [`pairwise_kappa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  [`gwet_ac2_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  : Compute Krippendorff's alpha across raters
- [`score_comparison_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_comparison_table.md)
  : Compare aligned scores against reference ratings
- [`rater_centrality_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_centrality_table.md)
  : Describe rater centrality using RSM residuals and rater-specific PCM
  steps
- [`rater_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_network_analysis.md)
  : Analyze rater agreement, disagreement, and severity-direction
  networks
- [`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
  : Analyze rater-by-criterion halo-effect networks
- [`fit_rater_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md)
  [`summary(`*`<mfrm_network_ergm>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md)
  [`coef(`*`<mfrm_network_ergm>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md)
  [`vcov(`*`<mfrm_network_ergm>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md)
  [`confint(`*`<mfrm_network_ergm>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md)
  [`plot(`*`<mfrm_network_ergm>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md)
  : Fit an ERGM to a declared binary rater network
- [`fit_rater_accuracy()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_accuracy.md)
  : Estimate criterion-referenced rater accuracy from exact matches
- [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)
  [`unexpected_after_bias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)
  : Build an unexpected-response screening report
- [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)
  : Compute displacement diagnostics for facet levels
- [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
  [`plot(`*`<mfrm_residual_pca>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
  : Run exploratory residual PCA summaries
- [`mfrm_residual_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md)
  [`summary(`*`<mfrm_residual_network>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md)
  [`print(`*`<mfrm_residual_network>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md)
  [`plot(`*`<mfrm_residual_network>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md)
  : Explore residual associations and groups of facet levels
- [`q3_statistic()`](https://ryuya-dot-com.github.io/mfrmr/reference/q3_statistic.md)
  : mfrmr standardized/aggregated-residual Q3-style screen
- [`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md)
  [`summary(`*`<mfrm_person_fit_indices>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md)
  : Person fit indices: lz and Snijders-corrected lz\*
- [`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md)
  [`plot(`*`<mfrm_qc_pipeline>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md)
  : Run automated quality control pipeline
- [`plot(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
  : Plot fitted MFRM results with ggplot2
- [`compatibility_alias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
  : Fewer public entry points and unified ggplot2 graphics in 0.3.0
- [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  [`summary(`*`<mfrm_dif>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  [`summary(`*`<mfrm_dff>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  [`print(`*`<summary.mfrm_dif>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  [`print(`*`<summary.mfrm_dff>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  [`print(`*`<mfrm_dif>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  [`print(`*`<mfrm_dff>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  [`plot(`*`<mfrm_dif>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  : Differential facet functioning (DFF) screening

## Reporting, tables, and exports

Connect the study question to draft tables, figures, interpretation and
saved evidence; see the reporting article for optional sections and
model-specific routes.

- [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  [`print(`*`<mfrm_apa_text>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  [`summary(`*`<mfrm_apa_outputs>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
  : Build APA text outputs from model results

- [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
  : Build warning and narrative summaries for visual outputs

- [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  [`summary(`*`<mfrm_bundle>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  [`plot(`*`<mfrm_bundle>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  [`summary(`*`<mfrm_summary_table_bundle>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  [`plot(`*`<mfrm_summary_table_bundle>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
  :

  Build a manuscript-oriented table bundle from
  [`summary()`](https://rdrr.io/r/base/summary.html) outputs

- [`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md)
  : Export manuscript appendix tables from documented summary surfaces

- [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  : Build a reproducibility manifest for an MFRM analysis

- [`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md)
  : Export a measurement model to Stan or brms

- [`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md)
  [`plot(`*`<mfrm_posterior_summary>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md)
  [`print(`*`<mfrm_posterior_summary>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md)
  [`summary(`*`<mfrm_posterior_summary>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md)
  [`confint(`*`<mfrm_posterior_summary>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md)
  [`as.data.frame(`*`<mfrm_posterior_summary>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/read_mfrm_posterior.md)
  : Read an exported Bayesian measurement summary and optional joint
  draws

- [`predict(`*`<mfrm_posterior_summary>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_posterior_summary.md)
  [`print(`*`<mfrm_posterior_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_posterior_summary.md)
  [`summary(`*`<mfrm_posterior_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_posterior_summary.md)
  [`print(`*`<summary.mfrm_posterior_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_posterior_summary.md)
  [`confint(`*`<mfrm_posterior_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_posterior_summary.md)
  [`as.data.frame(`*`<mfrm_posterior_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_posterior_summary.md)
  [`plot(`*`<mfrm_posterior_scores>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_posterior_summary.md)
  : Score new Persons under a saved external Bayesian calibration

- [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
  [`summary(`*`<apa_table>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
  [`plot(`*`<apa_table>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
  : Build an APA-oriented table handoff using base R structures

- [`as_kable()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_kable.md)
  [`as_flextable()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_kable.md)
  :

  Convert an `apa_table` to a
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html) object

- [`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
  : Convert draw-free mfrmr plot data to ggplot2

- [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
  [`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
  : Extract reusable data from an mfrmr plot object

## Simulation, design, and recovery

Design review, GPCM recovery checks, and future-administration
scenarios.

- [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)
  : Simulate long-format ordered many-facet data for design studies
- [`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md)
  [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md)
  [`plot(`*`<mfrm_recovery_assessment>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md)
  [`plot(`*`<mfrm_recovery_simulation>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md)
  : Simulate parameter recovery by repeated generation and refitting
- [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  [`summary(`*`<mfrm_design_evaluation>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  [`plot(`*`<mfrm_design_evaluation>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
  : Evaluate MFRM design conditions by repeated simulation
- [`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md)
  [`summary(`*`<mfrm_diagnostic_screening>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md)
  [`plot(`*`<mfrm_diagnostic_screening>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md)
  : Evaluate legacy and strict marginal diagnostic screening under
  controlled misfit scenarios
- [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md)
  [`summary(`*`<mfrm_signal_detection>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md)
  [`plot(`*`<mfrm_signal_detection>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md)
  : Evaluate differential-functioning contrasts and bias screens in
  simulations
- [`mfrm_screening_performance()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md)
  [`mfrm_screening_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md)
  [`summary(`*`<mfrm_screening_performance>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md)
  [`print(`*`<mfrm_screening_performance>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md)
  [`plot(`*`<mfrm_screening_performance>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md)
  [`summary(`*`<mfrm_screening_sensitivity>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md)
  [`print(`*`<mfrm_screening_sensitivity>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md)
  [`plot(`*`<mfrm_screening_sensitivity>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md)
  : Evaluate screening outcomes against a planned simulation roster
- [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  [`summary(`*`<mfrm_population_prediction>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  : Forecast population-level MFRM operating characteristics for one
  future design
- [`build_mfrm_resampling_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_resampling_spec.md)
  [`draw_mfrm_resamples()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_resampling_spec.md)
  : Build an observed-data resampling specification

## Linking, bias, and DFF screening

Anchor review, linking synthesis, residual-bias screening, and
differential-functioning review.

- [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
  [`summary(`*`<mfrm_anchor_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
  [`plot(`*`<mfrm_anchor_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
  [`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
  : Review and normalize anchor/group-anchor tables
- [`anchor_to_baseline()`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  [`print(`*`<mfrm_anchored_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  [`summary(`*`<mfrm_anchored_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  [`print(`*`<summary.mfrm_anchored_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/anchor_to_baseline.md)
  : Fit new data anchored to a baseline calibration
- [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  [`print(`*`<mfrm_anchor_drift>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  [`summary(`*`<mfrm_anchor_drift>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  [`print(`*`<summary.mfrm_anchor_drift>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  [`plot(`*`<mfrm_anchor_drift>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md)
  : Detect anchor drift across multiple calibrations
- [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  [`print(`*`<mfrm_equating_chain>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  [`plot(`*`<mfrm_equating_chain>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  [`summary(`*`<mfrm_equating_chain>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  [`print(`*`<summary.mfrm_equating_chain>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md)
  : Build a screened linking chain across ordered calibrations
- [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
  [`summary(`*`<mfrm_linking_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
  : Build a linking-review synthesis object
- [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  [`interaction_effect_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  [`summary(`*`<mfrm_bias>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  [`plot(`*`<mfrm_bias>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  [`bias_count_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  : Screen facet combinations for departures from a fitted model
- [`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md)
  [`summary(`*`<mfrm_bias_collection>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md)
  [`print(`*`<mfrm_bias_collection>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md)
  [`print(`*`<summary.mfrm_bias_collection>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md)
  [`plot(`*`<mfrm_bias_collection>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md)
  : Estimate bias across multiple facet pairs
- [`mantel_haenszel_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mantel_haenszel_table.md)
  : Compare matched responses using MH or generalized CMH
- [`ordinal_logistic_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/ordinal_logistic_table.md)
  : Compare ordered responses using cumulative logistic models
- [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md)
  [`plot(`*`<mfrm_dif_interaction>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md)
  : Compute interaction table between a facet and a grouping variable

## Saved analyses and software compatibility

FACETS handoff, external-table review, and related package import
adapters.

- [`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
  [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
  [`facets_chisq_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
  [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
  : Review fit standardization against FACETS-style ZSTD conventions

- [`read_facets_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_results.md)
  [`summary(`*`<mfrm_facets_results>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_results.md)
  [`print(`*`<mfrm_facets_results>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_results.md)
  [`as.data.frame(`*`<mfrm_facets_results>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_results.md)
  [`plot(`*`<mfrm_facets_results>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_results.md)
  : Read FACETS results for standalone visualization and fit review

- [`facets_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_guide.md)
  : Choose a FACETS comparison guide

- [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  [`summary(`*`<mfrm_facets_run>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  [`plot(`*`<mfrm_facets_run>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  : Run a legacy-compatible estimation workflow wrapper

- [`import_irt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_irt_fit.md)
  [`summary(`*`<mfrm_imported_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/import_irt_fit.md)
  [`print(`*`<summary.mfrm_imported_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/import_irt_fit.md)
  :

  Import an external IRT fit (`mirt`, `TAM`, or `eRm`) to an
  mfrmr-compatible bundle

## External features and exploratory groups

Review entity-level external attributes and describe exploratory groups.

- [`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md)
  [`print(`*`<mfrm_features>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md)
  [`summary(`*`<mfrm_features>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md)
  : Prepare external features for exploratory grouping
- [`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`mfrm_cluster_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`print(`*`<mfrm_cluster_comparison>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`summary(`*`<mfrm_cluster_comparison>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`print(`*`<mfrm_clusters>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`summary(`*`<mfrm_clusters>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`print(`*`<mfrm_imputed_clusters>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`summary(`*`<mfrm_imputed_clusters>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`plot(`*`<mfrm_hierarchical_clusters>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`plot(`*`<mfrm_clusters>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  [`plot(`*`<mfrm_imputed_clusters>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
  : Group external features with an explicitly chosen clustering method
- [`mfrm_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md)
  [`print(`*`<mfrm_pca>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md)
  [`summary(`*`<mfrm_pca>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md)
  [`plot(`*`<mfrm_pca>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md)
  : Principal components of numeric external features

## Advanced reviews and visualization

Specialist plots, S3 methods, network reviews, reliability, shrinkage,
and compatibility helpers.

- [`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md)
  [`plot(`*`<mfrm_facet_equivalence>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md)
  : Analyze practical equivalence within a facet

- [`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md)
  [`shrinkage_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md)
  : Apply empirical-Bayes shrinkage to fitted non-person facet estimates

- [`build_conquest_overlap_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md)
  [`normalize_conquest_overlap_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md)
  [`normalize_conquest_overlap_exports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md)
  [`review_conquest_overlap()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_conquest_overlap_bundle.md)
  : Build a scoped ConQuest-overlap bundle

- [`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md)
  : Build legacy-compatible fixed-width text reports

- [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
  [`summary(`*`<mfrm_misfit_casebook>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
  : Build a case-level misfit review bundle

- [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
  [`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
  : Compute intra-class correlations for each facet

- [`ej2021_data`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_study1`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_study2`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_combined`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_study1_itercal`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_study2_itercal`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  [`ej2021_combined_itercal`](https://ryuya-dot-com.github.io/mfrmr/reference/ej2021_data.md)
  : Legacy synthetic MFRM datasets inspired by Eckes and Jin (2021)

- [`export_mfrm_tables()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_tables.md)
  : Export fitted MFRM tables to CSV files

- [`confint(`*`<mfrm_fair_average>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  [`summary(`*`<mfrm_fair_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  [`print(`*`<mfrm_fair_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  [`plot(`*`<mfrm_fair_intervals>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  : Build an adjusted-score reference table bundle

- [`mfrm_threshold_profiles()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_threshold_profiles.md)
  [`summary(`*`<mfrm_threshold_profiles>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_threshold_profiles.md)
  [`mfrm_misfit_thresholds()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_threshold_profiles.md)
  : List literature-informed and package-defined screening profiles

- [`mfrm_results_interactive()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md)
  [`launch_mfrmr_viewer()`](https://ryuya-dot-com.github.io/mfrmr/reference/launch_mfrmr_viewer.md)
  :

  Interactively choose data-frame columns before calling
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)

- [`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md)
  :

  Recode common missing-value sentinels to `NA`

- [`recommend_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md)
  [`summary(`*`<mfrm_design_recommendation>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md)
  [`print(`*`<summary.mfrm_design_recommendation>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md)
  [`print(`*`<mfrm_design_recommendation>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md)
  [`plot(`*`<mfrm_design_recommendation>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md)
  : Review assessment plans against declared planning criteria

- [`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_benchmark.md)
  : Benchmark packaged reference cases

- [`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
  [`summary(`*`<mfrm_response_time_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
  [`plot(`*`<mfrm_response_time_review>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
  : Review response-time patterns outside the MFRM likelihood

- [`summary(`*`<mfrm_fit>`*`)`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md)
  : Inspect fitted estimates and interpretation status

- [`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md)
  [`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md)
  : Write a standalone residual file
