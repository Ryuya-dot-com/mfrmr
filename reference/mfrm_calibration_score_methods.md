# Review and plot portable fixed-calibration scores

These methods provide the first review surface for the result returned
by
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md).
[`print()`](https://rdrr.io/r/base/print.html) gives a compact batch
disposition, [`summary()`](https://rdrr.io/r/base/summary.html) exposes
readable score and review tables, and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) shows
conditional score uncertainty or numerical review quantities without
refitting a model.

## Usage

``` r
# S3 method for class 'mfrm_calibration_score'
summary(object, digits = 3L, ...)

# S3 method for class 'mfrm_calibration_score'
print(x, ...)

# S3 method for class 'summary.mfrm_calibration_score'
print(x, ...)

# S3 method for class 'mfrm_calibration_score'
plot(
  x,
  type = c("interval", "precision", "edge_mass"),
  top_n = 40L,
  sort_by = c("estimate", "sd", "person"),
  label_review = TRUE,
  main = NULL,
  draw = TRUE,
  preset = c("standard", "publication", "compact", "monochrome"),
  ...
)
```

## Arguments

- object, x:

  An `mfrm_calibration_score` returned by
  [`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md).

- digits:

  Number of decimal places in the summary.

- ...:

  Reserved for generic compatibility.

- type:

  One of `"interval"`, `"precision"`, or `"edge_mass"`.

- top_n:

  Maximum number of scored Persons shown. Review rows are selected first
  when truncation is necessary. Use `Inf` to show all.

- sort_by:

  Selection priority after review rows: absolute estimate, posterior SD,
  or Person identifier.

- label_review:

  Whether review points are labelled in the precision and edge-mass
  views. Interval plots always label the displayed Persons.

- main:

  Optional plot title.

- draw:

  If `TRUE`, draw with base R graphics. The returned `mfrm_plot_data` is
  available invisibly in either case.

- preset:

  Visual preset: `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`.

## Value

[`print()`](https://rdrr.io/r/base/print.html) returns its input
invisibly. [`summary()`](https://rdrr.io/r/base/summary.html) returns a
`summary.mfrm_calibration_score` containing `overview`, `estimates`,
`review`, `row_review`, `settings`, and `notes`. When adaptive
integration was requested and scored rows exist, it also retains
unrounded `quadrature_review` and a compact `quadrature_overview`. When
cut scores were requested, `decisions` preserves every probability, cut
boundary and actual scoring prior without rounding; unavailable Persons
remain in that table with `NA` probabilities.
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) returns an
`mfrm_plot_data` with the selected plotting table, selection accounting,
unplotted Person dispositions, interpretation guidance, and plotting
settings.

## Details

The default interval plot shows posterior EAP estimates and central
intervals. `type = "precision"` plots the number of valid response rows
against posterior SD. `type = "edge_mass"` compares posterior mass on
the two outer quadrature nodes with the recorded review threshold.
Review dispositions are highlighted in every view.

These are score-batch review displays, not calibration-fit diagnostics.
Posterior SDs and intervals are conditional on the frozen point
calibration and the actual scoring prior. They exclude
calibration-parameter uncertainty. For GPCM or an explicitly supplied
scoring prior, summaries and plot data retain both original and actual
prior values without rounding, the per-Person integration checks, and
(for GPCM) the source decision recorded at extraction. These records
describe conditional scoring, not a new evaluation of the training fit
or the suitability of its population for another cohort.
`summary(x)$settings$score_integration_review` compares the reported
EAP/SD with higher-order adaptive references. The separate
`quadrature_review` compares adaptive and fixed grids; for an adaptive
scorer, that fixed grid did not produce the reported scores. Printing
distinguishes the two checks. Persons with no valid responses have no
score coordinate and are retained in `summary(x)$review` and in the plot
payload's `unplotted_dispositions` component.

The summary object retains every returned score and review disposition.
Its estimates table preserves the available estimate and uncertainty
basis columns, calibration identifiers, scoring algorithm and requested
interval level when extracted or written to CSV. The interval level is
not rounded. Older score results recover these fields from their
recorded settings when re-summarized. Saved grid-based intervals retain
their original endpoints; printed results and interval plots explain
that their posterior mass can differ from the requested level. Its print
method shows at most ten rows from each table so routine console output
stays compact. Base and ggplot2 renderers distinguish scored and review
states by shape as well as colour. `as_ggplot(p)` and
`as_ggplot(p, component = "data")` preserve the same selected view,
saved bounds, review symbols and unplotted dispositions. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to extract other components. Changing the interval level requires an
explicit scoring call; conversion does not recompute intervals. Notes
remain in the returned object and are not automatically drawn.

## Session plot defaults

Set `options(mfrmr.plot_preset = "publication")` to choose a session
default for plotting functions that expose the common `preset` argument.
The supported values are `"standard"`, `"publication"`, `"compact"` and
`"monochrome"`. Precedence is an explicit call argument, then the
session option, then `"standard"`. For example, `preset = "standard"`
overrides a session set to `"monochrome"`. Explicit `preset = NULL`
retains the earlier package-default behavior; it does not read the
session option. Invalid session values cause an error only when that
option is needed.

The category-curve, data-quality, fit-review, connectivity and network
routes of [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
report bundles use the same option through `...`. Plots without a common
`preset` argument, including extended-model plots with their own
`palette` controls, keep their own settings. This option selects a
preset, not a universal theme or a guarantee that all renderers
implement every appearance control identically.

New plot payloads retain the resolved preset for supported saved-data
rendering. Converting an existing payload with
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
uses its saved appearance, even after the session option changes. A call
that creates a new plot from a fit or statistical result uses the
current default. For a reproducible script, supply `preset` explicitly
or set the option in that script. Saving only the fitted model does not
save a session option. No global ggplot theme is changed.

Restore previous settings with
`old <- options(mfrmr.plot_preset = "monochrome")` followed by
`options(old)`. Use `options(mfrmr.plot_preset = NULL)` to remove the
option. The preset changes appearance, not estimates, confidence levels
or diagnostic thresholds.

## See also

[mfrm_calibration_workflow](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md),
[mfrm_calibration_capabilities](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_capabilities.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md),
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
for conditional-decision interpretation

## Examples

``` r
dat <- load_mfrmr_data("example_core")
ids <- unique(dat$Person)
training <- dat[dat$Person %in% ids[1:18], , drop = FALSE]
fit <- fit_mfrm(
  training, "Person", c("Rater", "Criterion"), "Score",
  model = "RSM", method = "MML", quad_points = 31
)
q_review <- mml_quadrature_sensitivity(
  fit, training, quad_points = c(31, 61), theta_points = 41
)
summary(q_review) # Inspect movement; these grids are not universal cutoffs.
#> RSM-MML quadrature sensitivity summary
#>  ReferenceNodes ComparedGrids AllEstimationConverged AllHessiansFullRank
#>              31             2                   TRUE                TRUE
#>  MaxNLLAbsChangePerPerson MaxMeasurementParameterAbsChange MaxSlopeAbsChange
#>                   0.00019                          0.00174                NA
#>  MaxPopulationSDAbsChange MaxProbabilityAbsChange MaxEAPAbsChange
#>                         0                 0.00059          0.0071
#>  MaxPosteriorSDAbsChange
#>                  0.01019
#> 
#> Grid comparisons
#>  Model ReferenceNodes Nodes IsReference NLLChangePerPerson
#>    RSM             31    31        TRUE            0.00000
#>    RSM             31    61       FALSE           -0.00019
#>  NLLAbsChangePerPerson MeasurementParameterMaxAbsChange SlopeMaxAbsChange
#>                0.00000                          0.00000                NA
#>                0.00019                          0.00174                NA
#>  RawSlopeSEMaxAbsChange SlopeIntervalMaxAbsChange
#>                      NA                        NA
#>                      NA                        NA
#>  SlopeIntervalEligibilityChanged PopulationSDAbsChange
#>                               NA                     0
#>                               NA                     0
#>  RawPopulationSDSEAbsChange ProbabilityMaxAbsChange EAPMaxAbsChange
#>                          NA                 0.00000          0.0000
#>                          NA                 0.00059          0.0071
#>  PosteriorSDMaxAbsChange
#>                  0.00000
#>                  0.01019
#> No automatic stability classification or readiness change is applied.
fit <- q_review$fits$q61
calibration <- freeze_mfrm_calibration(
  validate_mfrm_calibration(extract_mfrm_calibration(
    fit, quadrature_review = q_review, scoring_quad_points = 121
  ))
)
new_rows <- dat[dat$Person %in% ids[19:20], , drop = FALSE]
scores <- score_mfrm_calibration(calibration, new_rows,
  cut_scores = c(Basic = -0.5, Advanced = 0.8))
summary(scores)
#> mfrmr Portable Calibration Score Summary
#>   Calibration: mfrmr-calibration-v1:rsm:mml:20261026090425686245
#>   Model / estimator: RSM / MML
#>   Persons: 2 scored (0 requiring review); 0 not scored
#> 
#> Posterior estimates (2 of 2)
#>   P019: estimate 0.934, SD 0.323, interval [0.314, 1.579], scored
#>   P020: estimate -0.381, SD 0.302, interval [-0.978, 0.209], scored
#> 
#> Response-row disposition
#>   32 input; 32 scored; 0 omitted; 0 refused; missing-response policy: error
#> 
#> Conditional decision probabilities (first 10; full table in $decisions)
#>  Person         Type    Label Lower Upper  Probability PriorMean PriorSD
#>    P019    above_cut    Basic  -0.5   Inf 9.999982e-01         0       1
#>    P019    above_cut Advanced   0.8   Inf 6.568698e-01         0       1
#>    P019 ability_band    Band1  -Inf  -0.5 1.769806e-06         0       1
#>    P019 ability_band    Band2  -0.5   0.8 3.431284e-01         0       1
#>    P019 ability_band    Band3   0.8   Inf 6.568698e-01         0       1
#>    P020    above_cut    Basic  -0.5   Inf 6.546008e-01         0       1
#>    P020    above_cut Advanced   0.8   Inf 4.590082e-05         0       1
#>    P020 ability_band    Band1  -Inf  -0.5 3.453992e-01         0       1
#>    P020 ability_band    Band2  -0.5   0.8 6.545549e-01         0       1
#>    P020 ability_band    Band3   0.8   Inf 4.590082e-05         0       1
#>                 Status Reason                                Uncertainty
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>   Decision probabilities describe Lower < ability <= Upper on the calibration
#>   scale. Calibration, population estimates and supplied cut scores are held
#>   fixed. Probability accuracy depends on the scoring prior matching the target
#>   population; numerical checks do not validate that match. Uncertainty in an
#>   estimated prior is excluded, and a larger calibration sample does not correct
#>   a mismatched scoring prior. They are not Person-difference tests or
#>   probabilities of passing a future administration. Cut labels do not establish
#>   CEFR alignment. Very small tails have absolute, not relative, numerical
#>   accuracy.
#> 
#> Interval interpretation
#>   95% intervals: continuous posterior quantiles.
#>   Posterior SDs and intervals are conditional on the frozen point calibration
#>   and exclude calibration-parameter uncertainty.
apa_table(scores, which = "decisions")
#> Conditional ability decision probabilities
#>  Person         Type    Label Lower Upper  Probability PriorMean PriorSD
#>    P019    above_cut    Basic  -0.5   Inf 9.999982e-01         0       1
#>    P019    above_cut Advanced   0.8   Inf 6.568698e-01         0       1
#>    P019 ability_band    Band1  -Inf  -0.5 1.769806e-06         0       1
#>    P019 ability_band    Band2  -0.5   0.8 3.431284e-01         0       1
#>    P019 ability_band    Band3   0.8   Inf 6.568698e-01         0       1
#>    P020    above_cut    Basic  -0.5   Inf 6.546008e-01         0       1
#>    P020    above_cut Advanced   0.8   Inf 4.590082e-05         0       1
#>    P020 ability_band    Band1  -Inf  -0.5 3.453992e-01         0       1
#>    P020 ability_band    Band2  -0.5   0.8 6.545549e-01         0       1
#>    P020 ability_band    Band3   0.8   Inf 4.590082e-05         0       1
#>                 Status Reason                                Uncertainty
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#>  available_conditional        conditional_on_point_calibration_and_prior
#> Note. Decision probabilities describe Lower < ability <= Upper on the calibration scale. Calibration, population estimates and supplied cut scores are held fixed. Probability accuracy depends on the scoring prior matching the target population; numerical checks do not validate that match. Uncertainty in an estimated prior is excluded, and a larger calibration sample does not correct a mismatched scoring prior. They are not Person-difference tests or probabilities of passing a future administration. Cut labels do not establish CEFR alignment. Very small tails have absolute, not relative, numerical accuracy.
build_summary_table_bundle(scores)$table_index
#>        Table Rows Cols                  Role
#> 1   overview    1   12   prediction_overview
#> 2  estimates    2   17        unit_estimates
#> 3     review    0   11    score_dispositions
#> 4 row_review    1    5 prediction_row_review
#> 5   settings    9    2      scoring_settings
#> 6      notes    7    1  interpretation_notes
#> 7  decisions   10   11 conditional_decisions
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Description
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Scoring-batch counts and the frozen calibration identity.
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             Conditional posterior summaries for scored Persons.
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Every review or unavailable Person disposition, including missing-only Persons.
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Response-row scoring and omission counts.
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Saved scoring settings; no calibration or scoring is repeated.
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                Interpretation of conditional scores and recorded review states.
#> 7 Decision probabilities describe Lower < ability <= Upper on the calibration scale. Calibration, population estimates and supplied cut scores are held fixed. Probability accuracy depends on the scoring prior matching the target population; numerical checks do not validate that match. Uncertainty in an estimated prior is excluded, and a larger calibration sample does not correct a mismatched scoring prior. They are not Person-difference tests or probabilities of passing a future administration. Cut labels do not establish CEFR alignment. Very small tails have absolute, not relative, numerical accuracy.
plot(scores, type = "interval", draw = FALSE)
plot(scores, type = "edge_mass", draw = FALSE)
```
