# What mfrmr Calculates and Where to Read More

Locate the calculation and literature for a chosen question. This is a
help topic, not a function. Use the model-choice tutorial to select a
model and
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)
to connect analysis steps.

## Distinguish the target

A Person ability, a rater severity, observed agreement and a G
coefficient answer different questions. A facet is a modeled role (Rater
or Task); its levels are individual raters or tasks. More facets do not
mean more ability dimensions. Prespecify the score, population, rating
unit and intended comparison before choosing a calculation.

|  |  |
|----|----|
| Target | Definition and implementation |
| Ordered-response model, estimator, scale and anchors | [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md): RSM/PCM/GPCM, MML/JML/CML, identification, weights and numerical approximation |
| Information in the observed assignment and categories | [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md), [`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md): retained rows, support and design review |
| Structural uncertainty | [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md), [`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md): target, covariance/interval method and conditions |
| Conditional ability scores or plausible values | [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md), [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md), [mfrm_calibration_score_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md) |
| Response fit, ZSTD, separation and residuals | [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md) for supported ordinary models; [`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md) for supported extended models |
| Category use, steps and probability curves | [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md), [mfrm_report_category_structure](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md), [mfrm_report_category_curves](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md) |
| Conditional bias and group contrasts | [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md), [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md), [`mantel_haenszel_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/mantel_haenszel_table.md), [`ordinal_logistic_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/ordinal_logistic_table.md) |
| Observed agreement | [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md), [`pairwise_icc_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md), [`pairwise_kappa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md), [`krippendorff_alpha_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md), [`gwet_ac2_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md) |
| Assessment-plan variance and precision | [`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md), [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md) and their covariance/interval methods |
| Score classification | [`classification_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/classification_table.md) and fixed-calibration decision methods in [mfrm_calibration_workflow](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md) |

The linked help is the reference for the implemented equations,
denominators, defaults, output columns and original sources. A general
model citation does not by itself justify an implementation choice or
extension.

## Choose an agreement target and keep its denominator

Match the same rated response by its Person/Task/Criterion keys. Exact
agreement counts matched pair-context opportunities; its model-expected
counterpart is not chance agreement in kappa or AC2. Pairwise kappa uses
each pair's common complete units. Alpha and AC2 pool ratings
differently, including their treatment of singleton units and category
distances. Read the selected helper's denominator before comparing
values. ICC additionally requires an interval-score interpretation and
choices of agreement/consistency, selected/random raters and
single/average ratings. A pair's average-rating ICC concerns two raters,
not the whole panel.

These raw-score helpers supply descriptive points and counts, without
sampling intervals; save their complete lists with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html). They are separate
from the fitted `mfrm_interrater` summary/plot bundle. Repeated
responses from one Person are not automatically independent; high
agreement does not establish accuracy against a defensible reference.

## Distinguish rater effects before choosing a diagnostic

Severity concerns generally higher/lower ratings after model adjustment.
Centrality concerns compression toward middle categories; use
[`rater_centrality_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_centrality_table.md),
not graph centrality. Halo/horn concerns impression spillover across
criteria:
[`rater_halo_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/rater_halo_network_analysis.md)
describes score associations, not their psychological cause. A negative
edge does not identify a horn effect. Local dependence concerns
variation shared beyond the fitted model; a supported
[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
model represents a declared shared effect without identifying its cause.
None of these mechanisms is diagnosed by Infit/Outfit alone. Direct
FM-SC/MRFM-H models are not implemented; the specialist help
distinguishes them from these descriptive routes.

## Choose the G-theory target and uncertainty

Score columns are fixed score components, not additional random facets
or latent dimensions. Choose the uncertainty target before the method:

|  |  |
|----|----|
| Target | Interface |
| A source variance/covariance component | [`confint.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md) |
| Joint sampling covariance of component estimates | [`vcov.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md) |
| A future plan's G, Phi or measurement SEM | [`confint.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_d_study.md) |
| A difference between plans using the same source | `confint(d, reference = 1, ...)` or [mfrm_d_study_comparison](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study_comparison.md) |

A coefficient's sampling SE differs from measurement SEM. Paired plans
need their shared-source covariance/set, not subtraction of marginal
endpoints. The linked methods require explicit normal-model assumptions
and their documented design/estimator conditions; incomplete source data
do not authorize sparse future plans. Current D-studies project complete
balanced plans.

`summary(d)` returns point coefficients; `intervals = TRUE` requests
supported uncertainty and retains separate `IntervalCenter` values where
applicable. Keep original estimates, status and notes: negative
components, out-of-range delta limits, empty sets and numerical failures
have different meanings. REML centers are not MINQUE estimates, and
pointwise ribbons are not simultaneous bands. Method comparison is
sensitivity analysis, not a coverage study. The separate
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
main-effects approximation has residual sensitivity, not confidence
intervals. Use the G-theory tutorial for a worked interpretation and the
specialist help for formulas and limits.

## Conditions that change interpretation

- **Design:** connectedness alone does not identify all joint effects or
  guarantee precision. Missing assigned scores differ from unassigned
  cells; using available ratings does not correct informative
  missingness.

- **Scale and anchors:** score direction, facet signs and centering
  constraints must match. Ordinary fixed-anchor inference conditions on
  supplied values; propagating source uncertainty requires an explicit
  supported covariance route. See
  [mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md).

- **Uncertainty:** conditional posterior SD, structural sampling SE and
  G/D-study uncertainty are distinct. Specify what is held fixed. An
  available interval does not establish repeated-sample coverage; NA is
  not zero or an infinite endpoint. Use
  `mfrmr_output_guide("intervals")` for the available targets.

- **Diagnostics:** residual misfit, bias, dependence and observed
  disagreement require different follow-up. A flag is not a causal
  explanation or a verdict on fairness. High rater separation means
  distinguishable severities, not agreement; low separation can also
  reflect poor precision.

- **Score combination:** G/Phi concern the declared score and
  replication design. Reliability alone does not justify combining
  constructs or establish the validity of a use. Changing components,
  weights or the universe of raters/tasks changes the question.

## Find and cite the supporting literature

Read the chosen function's method and reference sections, and report the
settings actually used. The sources below introduce the model families
and score-interpretation framework; specialist help links its own
formulas and adaptations to their sources. Use `citation("mfrmr")` for
the software and record `packageVersion("mfrmr")`.

## References

American Educational Research Association, American Psychological
Association, & National Council on Measurement in Education. (2014).
*Standards for educational and psychological testing*. American
Educational Research Association. Internal structure and
score-combination rationale: Standards 1.13–1.14, pp. 26–27;
reliability/precision, Chapter 2.
<https://www.testingstandards.net/uploads/7/6/6/4/76643089/standards_2014edition.pdf>.

Kane, M. T. (2013). Validating the interpretations and uses of test
scores. *Journal of Educational Measurement, 50*(1), 1–73.
[doi:10.1111/jedm.12000](https://doi.org/10.1111/jedm.12000) . A
framework for claims, assumptions and evidence; not validation of a
particular mfrmr calculation.

Andrich, D. (1978). A rating formulation for ordered response
categories. *Psychometrika, 43*, 561-573.
[doi:10.1007/BF02293814](https://doi.org/10.1007/BF02293814) . RSM
foundation.

Masters, G. N. (1982). A Rasch model for partial credit scoring.
*Psychometrika, 47*, 149-174.
[doi:10.1007/BF02296272](https://doi.org/10.1007/BF02296272) . PCM
foundation.

Muraki, E. (1992). A generalized partial credit model: Application of an
EM algorithm. *Applied Psychological Measurement, 16*(2), 159-176.
[doi:10.1177/014662169201600206](https://doi.org/10.1177/014662169201600206)
. GPCM foundation.

Bock, R. D., & Aitkin, M. (1981). Marginal maximum likelihood estimation
of item parameters: Application of an EM algorithm. *Psychometrika, 46*,
443-459. [doi:10.1007/BF02293801](https://doi.org/10.1007/BF02293801) .
Marginal-likelihood estimation framework; this citation does not mean
every mfrmr engine uses EM.

Linacre, J. M. (1989). *Many-facet Rasch measurement*. MESA Press.
Many-facet formulation and interpretation.

Wright, B. D., & Masters, G. N. (1982). *Rating scale analysis*. MESA
Press. Fit, separation and reliability conventions.

Linacre, J. M. (2002). What do Infit and Outfit, Mean-square and
Standardized mean? *Rasch Measurement Transactions, 16*(2), 878.
<https://www.rasch.org/rmt/rmt162f.htm>. An introductory fit
explanation.

Brennan, R. L. (2003). *Coefficients and indices in generalizability
theory* (CASMA Research Report No. 1). University of Iowa. Pages 3–4
introduce random-facet G/D error and coefficient targets.
<https://education.uiowa.edu/sites/education.uiowa.edu/files/2026-04/casma-research-report-1-archived.pdf>.

## See also

[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md)
