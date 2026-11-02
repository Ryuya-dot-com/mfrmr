# Score new Persons under a saved external Bayesian calibration

Evaluate posterior ability distributions, cut-score decision
probabilities, and posterior predictive rating distributions for new
Persons against a validated
[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/read_mfrm_posterior.md)
calibration without refitting the exported Stan or brms model.

## Usage

``` r
# S3 method for class 'mfrm_posterior_summary'
predict(
  object,
  newdata,
  type = c("ability", "both", "predictive"),
  conditioning = c("posterior", "plugin_mean"),
  level = 0.95,
  cut_scores = NULL,
  quad_points = 31L,
  missing = c("fail", "omit"),
  persons = NULL,
  allow_calibration_persons = FALSE,
  repeated_ratings = NULL,
  keep_person_draws = FALSE,
  ...
)

# S3 method for class 'mfrm_posterior_scores'
print(x, digits = 3L, ...)

# S3 method for class 'mfrm_posterior_scores'
summary(object, ...)

# S3 method for class 'summary.mfrm_posterior_scores'
print(x, digits = 3L, ...)

# S3 method for class 'mfrm_posterior_scores'
confint(object, parm = NULL, level = object$settings$level, ...)

# S3 method for class 'mfrm_posterior_scores'
as.data.frame(
  x,
  row.names = NULL,
  optional = FALSE,
  ...,
  what = c("estimates", "predictive", "decisions", "person_draws", "dispositions")
)

# S3 method for class 'mfrm_posterior_scores'
plot(
  x,
  type = c("intervals", "variance", "predictive"),
  persons = NULL,
  draw = TRUE,
  reference = NULL,
  preset = "standard",
  show_legend = TRUE,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  ...
)
```

## Arguments

- object:

  A validated `mfrm_posterior_summary` returned by
  [`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/read_mfrm_posterior.md).
  Supported models are ordinary `"RSM"`, ordinary `"PCM"`, and
  one-family `"GPCM"` (both fixed standard-normal and
  estimated-population Stan bundles). Two-family product-slope GPCM
  bundles are excluded and fail before scoring.

- newdata:

  Non-empty `data.frame` of long-format rating rows using the exported
  bundle's source column names (`Person`, declared non-Person `facets`,
  and `Score`). New Person IDs are expected; all non-Person facet levels
  and non-missing score categories must exist in the saved calibration.

- type:

  Output scope: `"ability"` (default: Person posterior ability table and
  optional `cut_scores` decisions), `"both"` (ability table plus
  row-level posterior predictive score distributions), or `"predictive"`
  (ability table plus row-level posterior predictive score
  distributions, defaulting
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) and
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) to predictive
  outputs when inspected).

- conditioning:

  Calibration conditioning mode:

  `"posterior"`

  :   (Default) Integrates ability continuously within each saved MCMC
      calibration draw \\\psi^{(m)}\\ and averages the conditional
      posteriors equally across all \\M\\ joint draws in
      `posterior-draws.rds`. Propagates joint calibration uncertainty
      into `SD`, `[Lower, Upper]`, `decisions`, and `predictive` while
      holding \\p(\psi \mid y\_{\mathrm{cal}})\\ fixed (new Person
      responses do not update calibration parameters). Fails closed when
      `posterior-draws.rds` is absent.

  `"plugin_mean"`

  :   Scores conditional on a single calibration vector formed from
      marginal posterior means (`locations`, `steps`,
      `exp(mean(log_component_slopes))` preserving unit geometric mean
      for one-family GPCM, and `population_mean` / `population_sd` when
      present). Excludes calibration-estimation uncertainty (`BetweenSD`
      and `CalibrationVarShare` are `NA`).

  Passing `"joint"` fails with guidance to combine calibration and new
  rows in
  [`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/export_mfrm_model.md),
  because updating \\\psi\\ from new Persons requires refitting the full
  hierarchical model.

- level:

  Equal-tailed posterior credible interval probability strictly between
  `0` and `1` (default `0.95`).

- cut_scores:

  Optional finite, strictly increasing numeric vector of ability cut
  scores on the exported model's ability metric, with optional distinct
  names. Computes posterior probabilities above each cut and within each
  band (`Lower < ability <= Upper`).

- quad_points:

  Integer Gauss-Legendre order per sub-panel (`7` to `121`, default
  `31`). Each Person is integrated on an eight-panel composite grid
  centered at the draw-specific posterior mode and verified at
  `2 * quad_points + 1` (`63` by default, `504` composite nodes).
  Ability summaries and predictive distributions are checked separately;
  discrepancies above `1e-6` withhold the affected output. Agreement
  between two orders is a numerical diagnostic, not a rigorous error
  bound.

- missing:

  Missing-score policy for `newdata`: `"fail"` (default) rejects `NA`
  scores; `"omit"` omits `NA` rows when updating ability (returning
  `Status = "prior_only"` if a Person has zero observed ratings, while
  still evaluating posterior predictive category probabilities for
  omitted rows when `type` includes `"predictive"`).

- persons:

  Optional character vector of distinct Person IDs in `newdata` to score
  and return; `NULL` scores all Persons in first-appearance order.

- allow_calibration_persons:

  Logical (default `FALSE`). Scoring a Person who already contributed to
  the calibration sample double-counts their ratings under \\p(\psi \mid
  y\_{\mathrm{cal}})\\. Set `TRUE` only for explicit diagnostic or
  counterfactual comparisons; calibration members are flagged in
  `CalibrationMember` and their out-of-sample
  `PersonLogMarginalLikelihood` is set to `NA`.

- repeated_ratings:

  Optional override (`"review"` or `"independent"`) for duplicate
  observed Person-by-facet cells in `newdata`; `NULL` inherits the
  exported bundle's `repeated_ratings` setting.

- keep_person_draws:

  Logical (default `FALSE`); if `TRUE`, retains `$person_draws` with
  each Person's per-draw conditional mean, conditional SD, and log
  marginal likelihood across the calibration draws.

- ...:

  Unused; checked to be empty.

- x, parm, row.names, optional, digits, draw, reference, preset,
  show_legend, title, subtitle, caption:

  Arguments for [`print()`](https://rdrr.io/r/base/print.html),
  [`summary()`](https://rdrr.io/r/base/summary.html),
  [`confint()`](https://rdrr.io/r/stats/confint.html),
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html), and
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods on
  `mfrm_posterior_scores`.

- what:

  Table component for
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html):
  `"estimates"` (default, or `"predictive"` when
  `x$settings$type == "predictive"`), `"predictive"`, `"decisions"`,
  `"person_draws"`, or `"dispositions"`.

## Value

An `mfrm_posterior_scores` object with:

- `estimates`:

  One row per scored Person with `Estimate`, `Median`, `SD`, `WithinSD`,
  `BetweenSD`, `CalibrationVarShare`, `Lower`, `Upper`, `PriorMean`,
  `PriorSD`, `PersonLogMarginalLikelihood`, `IntegrationMaxDiff`,
  `CalibrationMember`, `CalibrationUncertainty`, `SamplingReview`,
  `Status`, and `Reason`.

- `predictive`:

  Row-level posterior predictive expected scores, `PredictiveSD`,
  `ExpectedMeanSD`, `Residual`, `ModalScore`, and category probabilities
  when `type` is `"both"` or `"predictive"` (`NULL` otherwise).
  `IntegrationMaxDiff` compares category probabilities and
  `ExpectedMeanSD` between quadrature orders for each row. `Status` and
  `Reason` describe predictive availability; `PersonStatus` describes
  the separate ability result. Failed predictive checks withhold
  probabilities and score summaries without suppressing otherwise valid
  ability results, including `prior_only`. The `IntegrationMaxDiff` in
  `estimates` concerns ability summaries, log likelihood and cut-score
  probabilities/SDs only.

- `decisions`:

  Long cut-score probability table (`above_cut` and `ability_band`) with
  `Probability` and `ProbabilityBetweenSD` when `cut_scores` is supplied
  (`NULL` otherwise).

- `person_draws`:

  Optional per-draw conditional moments when `keep_person_draws = TRUE`.

- `source`, `posterior_decision`, `categories`, `data_usage`,
  `omitted_rows`, `settings`, `notes`:

  Provenance, row accounting, and interpretation notes.

Pass the result to [`summary()`](https://rdrr.io/r/base/summary.html),
[`confint()`](https://rdrr.io/r/stats/confint.html),
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_report.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apa_table.md),
or
[`export_summary_appendix()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/export_summary_appendix.md).

## Details

### Three Bayesian scoring paradigms

Under the exported adjacent-category logit likelihood (\\D = 1\\),
calibration parameters \\\psi = (\beta, \tau, \alpha, \mu, \sigma)\\ are
estimated on the calibration sample \\y\_{\mathrm{cal}}\\. When new
rating rows \\y\_{\mathrm{new}, p}\\ arrive for a Person not in
\\y\_{\mathrm{cal}}\\, three distinct quantities exist:

1.  **Fixed-calibration posterior mixture
    (`conditioning = "posterior"`)**:
    \$\$p\_{\mathrm{cal}}(\theta\_{\mathrm{new}, p} \mid
    y\_{\mathrm{new}, p}; y\_{\mathrm{cal}}) = \int
    p(\theta\_{\mathrm{new}, p} \mid y\_{\mathrm{new}, p}, \psi)\\
    p(\psi \mid y\_{\mathrm{cal}})\\d\psi \approx
    \frac{1}{M}\sum\_{m=1}^{M} p(\theta\_{\mathrm{new}, p} \mid
    y\_{\mathrm{new}, p}, \psi^{(m)}).\$\$ New Person responses inform
    \\\theta\_{\mathrm{new}, p}\\ conditional on each draw
    \\\psi^{(m)}\\ without reweighting or updating \\\psi\\; therefore,
    a Person's score is invariant to which other new Persons are scored
    in the same batch. By the law of total variance on the equal-weight
    \\M\\-component mixture, \$\$\mathrm{SD}\_p^2 =
    \underbrace{\frac{1}{M}\sum\_{m=1}^{M}
    v\_{p,m}}\_{\mathrm{WithinSD}\_p^2} +
    \underbrace{\frac{1}{M}\sum\_{m=1}^{M}(\mu\_{p,m} -
    \hat{\theta}\_p)^2}\_{\mathrm{BetweenSD}\_p^2},\$\$ decomposing
    total posterior variance into conditional measurement variance
    (`WithinSD^2`) and calibration posterior variance (`BetweenSD^2`,
    share `CalibrationVarShare`). `Median`, `Lower`, and `Upper` invert
    the exact continuous mixture CDF \\F_p(x) = M^{-1}\sum\_{m=1}^{M}
    F\_{p,m}(x)\\.

2.  **Posterior-mean plug-in (`conditioning = "plugin_mean"`)**:
    evaluates \\p(\theta\_{\mathrm{new}, p} \mid y\_{\mathrm{new}, p},
    \hat{\psi})\\ at marginal posterior means (using \\\hat{\alpha} =
    \exp(\overline{\log\alpha})\\ for one-family GPCM so \\\prod_a
    \hat{\alpha}\_a = 1\\ holds). Available even when
    `posterior-draws.rds` is absent, but omits calibration uncertainty
    (`BetweenSD = NA`).

3.  **Joint hierarchical refitting**: updates \\\psi\\ using both
    \\y\_{\mathrm{cal}}\\ and \\y\_{\mathrm{new}}\\; requires
    re-exporting the combined data with
    [`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/export_mfrm_model.md).

### Out-of-sample person likelihood vs `predictive-draws.rds`

Existing-Person `log_lik` arrays saved in `predictive-draws.rds`
condition on sampled calibration abilities \\\theta_j^{(m)}\\ and
therefore validate conditional observation fit rather than
leave-one-Person-out prediction. For genuinely new Persons
(`CalibrationMember == FALSE`), `PersonLogMarginalLikelihood` integrates
\\\theta\_{\mathrm{new}, p}\\ over \\\mathcal{N}(\mu^{(m)},
(\sigma^{(m)})^2)\\ within each draw before averaging on the probability
scale (`logMeanExp` across \\m = 1, \dots, M\\).

## See also

[`read_mfrm_posterior()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/read_mfrm_posterior.md),
[`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/export_mfrm_model.md),
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_calibration_workflow.md),
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_report.md)

## Examples

``` r
# 1. Full calibration-posterior mixture scoring from joint MCMC draws:
draws_dir <- system.file("extdata", "posterior-draws-example", package = "mfrmr")
joint_post <- read_mfrm_posterior(draws_dir)
new_ratings <- data.frame(
  Person = c("NewP1", "NewP1", "NewP1", "NewP2", "NewP2", "NewP2"),
  Rater = c("R01", "R02", "R03", "R01", "R02", "R03"),
  Criterion = c("Accuracy", "Content", "Language", "Accuracy", "Content", "Language"),
  Score = c(1, 2, 2, 3, 3, NA),
  stringsAsFactors = FALSE
)
scored <- predict(
  joint_post,
  newdata = new_ratings,
  type = "both",
  missing = "omit",
  cut_scores = c(Pass = 0.0, Merit = 1.0)
)
scored$estimates[, c("Person", "Observed", "Estimate", "SD", "WithinSD",
                     "BetweenSD", "Lower", "Upper", "Status")]
#>   Person Observed   Estimate        SD  WithinSD BetweenSD     Lower     Upper
#> 1  NewP1        3 -0.6130990 0.6609947 0.5483797 0.3690443 -2.019002 0.5408901
#> 2  NewP2        2  0.6076407 0.7293054 0.6638066 0.3020715 -0.763545 2.1501629
#>                Status
#> 1 available_posterior
#> 2 available_posterior
scored$decisions[, c("Person", "Type", "Label", "Probability", "ProbabilityBetweenSD")]
#>    Person         Type Label Probability ProbabilityBetweenSD
#> 1   NewP1    above_cut  Pass 0.180393159          0.167990971
#> 2   NewP1    above_cut Merit 0.002417658          0.006630414
#> 3   NewP1 ability_band Band1 0.819606841          0.167990971
#> 4   NewP1 ability_band Band2 0.177975501          0.165324586
#> 5   NewP1 ability_band Band3 0.002417658          0.006630414
#> 6   NewP2    above_cut  Pass 0.806712676          0.113214909
#> 7   NewP2    above_cut Merit 0.273303346          0.148705013
#> 8   NewP2 ability_band Band1 0.193287324          0.113214909
#> 9   NewP2 ability_band Band2 0.533409330          0.106626782
#> 10  NewP2 ability_band Band3 0.273303346          0.148705013
head(scored$predictive[, c("Person", "Rater", "Criterion", "ObservedScore",
                           "ExpectedScore", "PredictiveSD")])
#>   Person Rater Criterion ObservedScore ExpectedScore PredictiveSD
#> 1  NewP1   R01  Accuracy             1      2.022829    0.8962713
#> 2  NewP1   R02   Content             2      2.280687    0.9717236
#> 3  NewP1   R03  Language             2      1.912503    0.9971508
#> 4  NewP2   R01  Accuracy             3      2.808508    0.8418570
#> 5  NewP2   R02   Content             3      2.995436    0.9054100
#> 6  NewP2   R03  Language            NA      2.905937    1.1059390
p_int <- plot(scored, type = "intervals", draw = FALSE)
plot_data(p_int, "table")[, c("Person", "Estimate", "Lower", "Upper", "Display")]
#>   Person   Estimate     Lower     Upper                  Display
#> 1  NewP1 -0.6130990 -2.019002 0.5408901 Sampling review required
#> 2  NewP2  0.6076407 -0.763545 2.1501629 Sampling review required

# 2. Marginal summary bundle without joint draws (explicit plug-in mean mode):
sum_dir <- system.file("extdata", "posterior-example", package = "mfrmr")
sum_post <- read_mfrm_posterior(sum_dir)
new_task_ratings <- data.frame(
  Person = c("CandidateA", "CandidateA"),
  Task = c("t1", "t2"),
  Rater = c("r1", "r2"),
  Score = c(2, 3),
  stringsAsFactors = FALSE
)
plugin_scores <- predict(sum_post, newdata = new_task_ratings,
                         conditioning = "plugin_mean")
plugin_scores$estimates[, c("Person", "Estimate", "SD", "BetweenSD", "Status")]
#>       Person  Estimate        SD BetweenSD                Status
#> 1 CandidateA 0.8543098 0.7136646        NA available_conditional
```
