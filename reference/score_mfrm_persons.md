# Estimate abilities for people already included in a fitted RSM

Use the existing ratings and fitted model to estimate each person's
ability. This is the common scoring entry for supported ordinary,
shared-rater and testlet rating-scale models (RSMs). It reuses the
fitted calibration, such as rater severity and category thresholds; it
does not fit the model again.

## Usage

``` r
score_mfrm_persons(
  fit,
  persons = NULL,
  level = 0.95,
  quad_points = NULL,
  cut_scores = NULL
)

# S3 method for class 'mfrm_person_scores'
summary(object, ...)

# S3 method for class 'mfrm_person_scores'
print(x, ...)

# S3 method for class 'mfrm_person_scores'
plot(x, ...)
```

## Arguments

- fit:

  A numerically ready ordinary RSM MML, testlet or shared-rater fit.

- persons:

  Distinct source Person IDs; `NULL` returns all source Persons,
  including Persons whose assigned scores are all missing. For a
  shared-rater fit, start with a few actual IDs: scoring everyone can be
  slow. Selecting IDs changes output rows, not the data used to account
  for shared raters.

- level:

  Conditional equal-tail interval probability, between zero and one.

- quad_points:

  Extension quadrature order; `NULL` uses its fit's order. Ordinary
  ability integration is continuous and does not use quadrature; leave
  this argument `NULL` for ordinary fits.

- cut_scores:

  Optional finite, strictly increasing numeric ability cuts, with
  optional distinct names. Ordinary RSM scoring only. Returns a
  `decisions` table of probabilities above each cut and in successive
  bands (`Lower < ability <= Upper`). Calibration, population parameters
  and cuts are held fixed. Labels do not establish CEFR alignment or a
  pass/fail rule.

- object, x:

  An ordinary `mfrm_person_scores` result.

- ...:

  Display controls passed to
  [`plot.mfrm_testlet_scores()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_testlet_scores.md);
  unused by print and summary.

## Value

Ordinary fits return `mfrm_person_scores` with `table`, `scoring_data`,
data usage, settings and source metadata. Extensions retain their
existing scoring classes. If `cut_scores` is supplied, `decisions`
retains probabilities, boundaries, labels, priors and availability;
`summary(x)$decisions` and `apa_table(x, which = "decisions")` reuse it.
Supply saved scores to
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
as `person_scores`; extension scores also support model-aware maps
through
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
Saved plots/reports do not recompute scores. In `table`, `Status` and
`Reason` distinguish `available_conditional` (a computed conditional
posterior), `prior_only` (no observed responses; the estimate and
interval describe the assumed population alone), and `unavailable` (the
estimate, SD and bounds are withheld, with the cause). Keep these
columns with exported scores. More integration points cannot supply
missing responses or resolve a zero ability-variance restriction.

## Details

The estimate is the mean of the conditional ability distribution (EAP).
Posterior SDs and continuous equal-tail intervals describe its
uncertainty with calibration held fixed. Selecting persons changes the
returned rows, not the ratings used to condition shared effects.

Ordinary fits use the bounded model/population specification of
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md):
additive unanchored severity facets and known N(0,1) or an estimated
intercept-only normal population. Both the fitted population mean and
variance are retained. EAP, posterior SD and interval endpoints
integrate the continuous conditional density; endpoints are not
quadrature-grid quantiles. Ordinary plug-in scoring is unchanged.

For extensions this calls
[`predict.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_testlet.md)
or
[`score_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_random_rater.md)
on the complete source roster. Their numerical checks, approximation
limits and uncertainty definitions apply unchanged. Use those functions
directly for a different complete scoring roster.

Intervals condition on fitted calibration and the assumed normal
population. They exclude calibration-estimation uncertainty, do not test
Person differences and do not guarantee frequentist coverage for each
fixed ability. Missing-only Persons remain `prior_only`; zero ability
variance and failed integration return `unavailable`, not zero-width
intervals. No missing scores are imputed.

## Conditional ability decisions

Supply `cut_scores` on the calibration's ability scale to obtain
`decisions`, with one row per Person and requested event.
`Type = "above_cut"` gives \\P(\theta \> c \mid y, \widehat\psi)\\;
`Type = "ability_band"` gives the probability between successive cuts,
including the two outer bands. `Lower < ability <= Upper` defines every
row. `Label` uses the supplied cut names (or `Cut1`, ...) and `Band1`,
... in increasing order. These events overlap: only the ability-band
probabilities sum to one.

`PriorMean` and `PriorSD` record the actual Person-specific normal
prior; `Status` and `Reason` retain scoring availability.
`available_conditional` means the applicable numerical checks passed,
not that the model or the cut's substantive meaning has been validated.
`review_only` requires inspection before interpretation. Source-roster
scoring may return `prior_only` for missing-only Persons; portable
scoring instead retains them as `unavailable` with `NA` probabilities.
Fitted-object scoring omits Persons with no retained rows; inspect its
row and population reviews. A Person absent from the input is never
invented.

Probabilities integrate the continuous posterior, rather than counting
[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
draws or applying a normal approximation to EAP/SD. They condition on
point calibration, population/prior parameters and supplied cuts, as
recorded in `Uncertainty`. They do not propagate estimation error,
compare two Persons or predict passing a future test. CEFR labels
require externally justified cuts on this same scale. Very small tails
have absolute, not relative, numerical accuracy; a returned zero or one
is not a claim of impossibility or certainty.

Review the scoring population as well as the calibration. An estimated
normal prior is treated as known during scoring; its sampling
uncertainty can matter especially with a small calibration cohort. A
larger calibration cohort can improve parameter precision without
correcting a prior that mismatches a new population's mean, spread or
shape. Passing numerical checks does not establish that probabilities
are accurate for that new population. A fixed reference prior is not a
universal remedy: justify it for the target population on the
calibration scale. If a prior override is supported, comparing
externally justified alternatives is a sensitivity analysis, not
evidence that the alternative giving the preferred classification is
valid. Population-averaged accuracy also does not guarantee accuracy
near each cut, within every subgroup or for each individual Person.

Use `score_mfrm_persons()` for eligible ordinary RSM MML source Persons,
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
for ordinary RSM/PCM MML or JML fitted-object scoring, and
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
for eligible continuous-posterior RSM/PCM artifacts. Each route retains
its existing source and population restrictions. Unit weights are
required; GPCM, shared-rater and testlet cut probabilities are not
supported. JML uses a separate scoring prior, not a population estimated
by JML. `NULL` leaves the existing output unchanged.

`summary(x)$decisions` and
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
with `which = "decisions"` reuse saved probabilities without rounding
them. Fitted-object and portable score batches also support
[`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md)
and
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_summary_appendix.md).
Save the complete result with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) to retain cuts,
priors and review states for later reporting. Existing score plots
display EAPs and intervals, not these event probabilities.

## See also

[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
for new people under an eligible saved ordinary RSM/PCM calibration;
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
for supplied response rows under a fitted calibration;
[`plot.mfrm_testlet_scores()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_testlet_scores.md),
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score")
scores <- score_mfrm_persons(fit, persons = unique(ratings$Person)[1:4],
  cut_scores = c(Basic = -0.5, Advanced = 0.8))
scores$table
#>   Person Observed  Estimate ConditionalSD      Lower    Upper
#> 1   P001       16 0.6011637     0.3029716 0.01607092 1.204810
#> 2   P002       16 1.4278211     0.3473444 0.77099827 2.133671
#> 3   P003       16 1.0902409     0.3249421 0.47028319 1.745150
#> 4   P004       16 0.7888096     0.3099718 0.19292475 1.409104
#>                  Status Reason
#> 1 available_conditional       
#> 2 available_conditional       
#> 3 available_conditional       
#> 4 available_conditional       
scores$decisions
#>    Person         Type    Label Lower Upper  Probability PriorMean PriorSD
#> 1    P001    above_cut    Basic  -0.5   Inf 9.999019e-01         0       1
#> 2    P001    above_cut Advanced   0.8   Inf 2.531738e-01         0       1
#> 3    P001 ability_band    Band1  -Inf  -0.5 9.810692e-05         0       1
#> 4    P001 ability_band    Band2  -0.5   0.8 7.467280e-01         0       1
#> 5    P001 ability_band    Band3   0.8   Inf 2.531738e-01         0       1
#> 6    P002    above_cut    Basic  -0.5   Inf 1.000000e+00         0       1
#> 7    P002    above_cut Advanced   0.8   Inf 9.691858e-01         0       1
#> 8    P002 ability_band    Band1  -Inf  -0.5 3.969859e-10         0       1
#> 9    P002 ability_band    Band2  -0.5   0.8 3.081424e-02         0       1
#> 10   P002 ability_band    Band3   0.8   Inf 9.691858e-01         0       1
#> 11   P003    above_cut    Basic  -0.5   Inf 9.999999e-01         0       1
#> 12   P003    above_cut Advanced   0.8   Inf 8.139518e-01         0       1
#> 13   P003 ability_band    Band1  -Inf  -0.5 8.910780e-08         0       1
#> 14   P003 ability_band    Band2  -0.5   0.8 1.860481e-01         0       1
#> 15   P003 ability_band    Band3   0.8   Inf 8.139518e-01         0       1
#> 16   P004    above_cut    Basic  -0.5   Inf 9.999921e-01         0       1
#> 17   P004    above_cut Advanced   0.8   Inf 4.800169e-01         0       1
#> 18   P004 ability_band    Band1  -Inf  -0.5 7.888984e-06         0       1
#> 19   P004 ability_band    Band2  -0.5   0.8 5.199753e-01         0       1
#> 20   P004 ability_band    Band3   0.8   Inf 4.800169e-01         0       1
#>                   Status Reason                                Uncertainty
#> 1  available_conditional        conditional_on_point_calibration_and_prior
#> 2  available_conditional        conditional_on_point_calibration_and_prior
#> 3  available_conditional        conditional_on_point_calibration_and_prior
#> 4  available_conditional        conditional_on_point_calibration_and_prior
#> 5  available_conditional        conditional_on_point_calibration_and_prior
#> 6  available_conditional        conditional_on_point_calibration_and_prior
#> 7  available_conditional        conditional_on_point_calibration_and_prior
#> 8  available_conditional        conditional_on_point_calibration_and_prior
#> 9  available_conditional        conditional_on_point_calibration_and_prior
#> 10 available_conditional        conditional_on_point_calibration_and_prior
#> 11 available_conditional        conditional_on_point_calibration_and_prior
#> 12 available_conditional        conditional_on_point_calibration_and_prior
#> 13 available_conditional        conditional_on_point_calibration_and_prior
#> 14 available_conditional        conditional_on_point_calibration_and_prior
#> 15 available_conditional        conditional_on_point_calibration_and_prior
#> 16 available_conditional        conditional_on_point_calibration_and_prior
#> 17 available_conditional        conditional_on_point_calibration_and_prior
#> 18 available_conditional        conditional_on_point_calibration_and_prior
#> 19 available_conditional        conditional_on_point_calibration_and_prior
#> 20 available_conditional        conditional_on_point_calibration_and_prior
apa_table(scores, which = "decisions")
#> Conditional ability decision probabilities
#>  Person         Type    Label Lower Upper  Probability PriorMean PriorSD
#>    P001    above_cut    Basic  -0.5   Inf 9.999019e-01         0       1
#>    P001    above_cut Advanced   0.8   Inf 2.531738e-01         0       1
#>    P001 ability_band    Band1  -Inf  -0.5 9.810692e-05         0       1
#>    P001 ability_band    Band2  -0.5   0.8 7.467280e-01         0       1
#>    P001 ability_band    Band3   0.8   Inf 2.531738e-01         0       1
#>    P002    above_cut    Basic  -0.5   Inf 1.000000e+00         0       1
#>    P002    above_cut Advanced   0.8   Inf 9.691858e-01         0       1
#>    P002 ability_band    Band1  -Inf  -0.5 3.969859e-10         0       1
#>    P002 ability_band    Band2  -0.5   0.8 3.081424e-02         0       1
#>    P002 ability_band    Band3   0.8   Inf 9.691858e-01         0       1
#>    P003    above_cut    Basic  -0.5   Inf 9.999999e-01         0       1
#>    P003    above_cut Advanced   0.8   Inf 8.139518e-01         0       1
#>    P003 ability_band    Band1  -Inf  -0.5 8.910780e-08         0       1
#>    P003 ability_band    Band2  -0.5   0.8 1.860481e-01         0       1
#>    P003 ability_band    Band3   0.8   Inf 8.139518e-01         0       1
#>    P004    above_cut    Basic  -0.5   Inf 9.999921e-01         0       1
#>    P004    above_cut Advanced   0.8   Inf 4.800169e-01         0       1
#>    P004 ability_band    Band1  -Inf  -0.5 7.888984e-06         0       1
#>    P004 ability_band    Band2  -0.5   0.8 5.199753e-01         0       1
#>    P004 ability_band    Band3   0.8   Inf 4.800169e-01         0       1
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
plot(scores, draw = FALSE)
```
