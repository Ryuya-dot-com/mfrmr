# Compare fitted measurement models or prespecified assessment plans

Compare two or more eligible MML
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
models via `AIC`, Person-based `BIC`, Sclove `SABIC`, candidate weights,
and optional nested likelihood-ratio tests (`nested = TRUE`), compare an
ordinary RSM fit descriptively against a
[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
or
[`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
fit, or compare D-Study plans from one
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
object (`assumption = "normal"`).

## Usage

``` r
compare_mfrm(
  ...,
  labels = NULL,
  warn_constraints = TRUE,
  nested = FALSE,
  response_diagnostics = NULL,
  person_scores = NULL
)

# S3 method for class 'mfrm_extended_comparison'
summary(object, ...)

# S3 method for class 'mfrm_extended_comparison'
print(x, ...)

# S3 method for class 'mfrm_extended_comparison'
plot(
  x,
  style = c("paired", "difference"),
  facet = NULL,
  draw = TRUE,
  palette = c("accessible", "mono"),
  title = NULL,
  caption = NULL,
  show_title = FALSE,
  show_notes = FALSE,
  show_labels = metric %in% c("effects", "infit", "outfit"),
  text_scale = 1,
  point_size = 2.5,
  metric = c("effects", "expected_score", "variance", "infit", "outfit", "probability",
    "person"),
  category = NULL,
  marginal = c("auto", "histogram", "none"),
  ...
)
```

## Arguments

- ...:

  Two or more `mfrm_fit` objects, one ordinary `mfrm_fit` paired with
  one testlet/random-rater fit, or one
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  object with named plan-comparison options (`reference`,
  `score`/`composite`, `assumption = "normal"`, `level`; see
  [mfrm_d_study_comparison](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study_comparison.md)).

- labels:

  Optional model labels and logical (`TRUE` default) warning when score
  coding or constraints differ (ranking is always suppressed when
  comparability fails).

- warn_constraints:

  Optional model labels and logical (`TRUE` default) warning when score
  coding or constraints differ (ranking is always suppressed when
  comparability fails).

- nested:

  Logical (`FALSE` default); when `TRUE` for two comparable MML fits
  passing structural nesting review (`RSM` in `PCM`, `PCM` in `GPCM`
  with matched population/step constraints, or nested
  `facet_interactions`), computes \\\Lambda =
  -2(\ell\_{\mathrm{restricted}} - \ell\_{\mathrm{full}}) \sim
  \chi^2\_{\Delta p}\\.

- response_diagnostics:

  Optional length-2 lists of matching
  [`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  and
  [`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
  outputs for ordinary-vs-extended RSM descriptive comparisons.

- person_scores:

  Optional length-2 lists of matching
  [`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  and
  [`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
  outputs for ordinary-vs-extended RSM descriptive comparisons.

- object:

  An `mfrm_extended_comparison` object in
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html).

- x:

  A descriptive extended-model result from `compare_mfrm()`.

  Also for `compare_mfrm()`: An extended-model comparison returned by
  `compare_mfrm()`.

- style:

  `"paired"` plots comparison against reference with an equality line.
  `"difference"` plots comparison minus reference against their mean.

- facet:

  Panels to display; `NULL` includes all. For effects and group indices
  these are facet names; for row moments the panel is
  `"Selected ratings"`; for probabilities it is `"Score k"` for category
  k.

- draw:

  `FALSE` returns plot data without opening a device.

- palette:

  `"accessible"` uses blue points and a dashed grey reference; `"mono"`
  uses dark grey points. Meaning does not depend on colour.

- title:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- caption:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- show_title:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_notes:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_labels:

  Show matched IDs beside the points. Defaults to `TRUE` for effects and
  group indices, `FALSE` for rating-level moments and probabilities.
  Consult the retained table when labels are hidden.

- text_scale:

  Positive multiplier for text size.

- point_size:

  Positive point size in ggplot millimetres; base graphics use the
  corresponding relative size (2.5 is the default).

- metric:

  `"effects"` compares centered facet locations (default).
  `"expected_score"`, `"variance"`, `"infit"`, `"outfit"` and
  `"probability"` require saved `response_diagnostics` in
  `compare_mfrm()`. These compare the same posterior predictive target
  in original score units, squared score units, descriptive mean squares
  or probabilities. `"person"` requires saved `person_scores` and
  compares EAPs centered at each fitted population mean, in logits. No
  difference interval is drawn.

- category:

  Numeric score categories to display with `metric = "probability"`;
  `NULL` includes all categories.

- marginal:

  Marginal histogram display on single-panel scatterplots: `"auto"`
  (default; displayed when at least 8 finite pairs are plotted on a
  single panel), `"histogram"`, or `"none"`.

## Value

`mfrm_comparison` (`table`, `lrt`, `evidence_ratios`, `preferred`,
`comparison_basis`), `mfrm_extended_comparison`, or
`mfrm_multivariate_d_comparison`.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object carrying the underlying `mfrm_plot_data` payload
(accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md))
with source effects, checks, interpretation notes, marginal histogram
bins, and a text alternative.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
supports saved payloads without estimation.

## Details

**Comparability and IC diagnostics.** Automatic IC deltas, candidate-set
`AkaikeWeight`/`BICWeight`/`SABICWeight`, pairwise `EvidenceRatio`
(`LogEvidenceRatio`, `RatioReason`), and LRT require identical prepared
rows, unit weights, `quad_points >= 31` (`ICSelectable`), and passing
local solution/curvature checks (`ICFitEligible`, `ICComparable`;
`SABICComparable` additionally requires `> 22` Persons; Burnham &
Anderson, 2002). Ordinary vs extended RSM pairs return centered
facet/response/Person differences without IC ranking or LRT.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
matched facet effects or posterior predictions across MFRMs

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Points are
centered at the unweighted mean within each complete matched facet.
These displays compare fitted summaries, including shrinkage, rather
than testing differences or choosing a better model. The equality/zero
line is a descriptive reference. No difference intervals or limits of
agreement are computed. Unavailable rows remain in plot data. Select
`facet` or use `show_labels = FALSE` for crowded displays.

Predictive quantities are not centered. Each row label maps through
`data$response_events` and the comparison's `responses$rows`, which
retain both original input row numbers. Infit/Outfit use selected rows
in each group; posterior conditioning retains all observed source
ratings. Smaller residual indices do not establish better prediction or
model adequacy. There are no ordinary fit cutoffs, tests or automatic
ranking.

## References

- Burnham, K. P., & Anderson, D. R. (2002). *Model selection and
  multimodel inference: A practical information-theoretic approach* (2nd
  ed.). Springer.

- Akaike, H. (1974). A new look at the statistical model identification.
  *IEEE Transactions on Automatic Control, 19*(6), 716-723.

- Schwarz, G. (1978). Estimating the dimension of a model. *Annals of
  Statistics, 6*(2), 461-464.

- Sclove, S. L. (1987). Application of model-selection criteria to some
  problems in multivariate analysis. *Psychometrika, 52*(3), 333-343.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md),
[mfrm_d_study_comparison](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study_comparison.md)

## Examples

``` r
# Optional workflow; run the example explicitly as shown below.
# example("compare_mfrm", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Load one dataset for both models
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# RSM: shared category thresholds
fit_rsm <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# PCM: separate category thresholds for each criterion
fit_pcm <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "PCM",
  step_facet = "Criterion"
)

# Check that the fitted models can be compared
comparison <- compare_mfrm(fit_rsm, fit_pcm, labels = c("RSM", "PCM"))
comparison$table[, c("Label", "Converged", "ICComparable", "ICSelectable")]

# Smaller AIC/BIC indicates better relative support among these models
comparison$table[, c("Label", "AIC", "Delta_AIC", "BIC", "Delta_BIC")]
# Delta is the difference from the lowest value of that criterion
# For close or consequential comparisons, check a denser shared grid with
# mml_quadrature_sensitivity() before choosing a model
# For a PCM/GPCM equal-slope test, see the matched-population example in
# https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-gpcm-scope.html
# Request compare_mfrm(..., nested = TRUE).
} # }
```
