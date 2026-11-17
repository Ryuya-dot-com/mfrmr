# Plausible values: keep the scoring basis with the draws

One posterior mean gives one summary per Person. Repeated posterior
draws retain variation around that summary and can be useful in later
analyses. The draws must travel with their IDs, scoring basis and
limitations: exporting numbers alone does not establish a valid
population analysis.

This short example starts from the package’s saved synthetic JML
calibration, scores two invented Persons, and saves the resulting
object. It demonstrates **conditional posterior scoring and data
handoff**, not a survey regression or a population-level uncertainty
guarantee. No external survey package is needed.

## Draw values from a stated scoring model

Show R code: load the calibration and score two new Persons

``` r

library(mfrmr)
example <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example$fit
ratings <- load_mfrmr_data(example$dataset)

# Invented responses using levels present in the saved calibration.
new_ratings <- data.frame(
  Person = rep(c("NEW01", "NEW02"), each = 2),
  Rater = as.character(unique(ratings$Rater)[1]),
  Criterion = rep(as.character(unique(ratings$Criterion)[1:2]), 2),
  Score = c(2, 3, 1, 2)
)
pv <- sample_mfrm_plausible_values(
  fit, new_ratings, n_draws = 20, seed = 23
)
```

The source fit is JML. This scoring step adds the package’s
standard-normal reference prior while keeping the fitted facet/step
calibration fixed. The prior is an assumption for posterior scoring; JML
has not estimated a Person population distribution. For supported MML
fits, the default instead uses the fitted population, including Person
covariates when specified.

| Person | Draw |  Value | CalibrationMethod |
|:-------|-----:|-------:|:------------------|
| NEW01  |    1 | -0.560 | JML               |
| NEW01  |    2 |  0.000 | JML               |
| NEW01  |    3 | -0.560 | JML               |
| NEW01  |    4 |  0.560 | JML               |
| NEW01  |    5 | -1.121 | JML               |
| NEW01  |    6 | -0.560 | JML               |

The same Person appears once per draw. Twenty draws do not turn two
Persons into forty independent observations. Values are sampled from the
fitted quadrature-grid posterior; repetitions of a value are expected.

## Inspect the numerical review and retain its meaning

Show R code: inspect summaries, settings and review information

``` r

draw_summary <- summary(pv)$draw_summary
draw_summary[c("Person", "Draws", "MeanValue", "SDValue")]
pv$settings[c("method", "posterior_basis", "scoring_quad_points", "seed")]
pv$row_review
pv$population_review
pv$notes
```

| Person | Draws | MeanValue | SDValue |
|:-------|------:|----------:|--------:|
| NEW01  |    20 |    -0.533 |   0.864 |
| NEW02  |    20 |    -1.180 |   0.705 |

These are summaries of a finite set of draws. With twenty draws, the
empirical mean, SD and quantiles have appreciable Monte Carlo variation.
The companion `pv$estimates` table contains the posterior scoring
summaries computed from the quadrature rule. Increasing the number of
draws can reduce simulation error; it does not supply missing
conditioning variables or calibration uncertainty.

## Save the complete object before reshaping

Show R code: save, reload and split into one table per draw

``` r

# Choose a private location for real Person data.
local_dir <- file.path(tempdir(), "mfrmr-pv-example")
dir.create(local_dir, showWarnings = FALSE)
saveRDS(pv, file.path(local_dir, "plausible-values.rds"))
restored <- readRDS(file.path(local_dir, "plausible-values.rds"))
stopifnot(identical(pv, restored))

by_draw <- split(restored$values, restored$values$Draw)
stopifnot(all(vapply(by_draw, function(x) !anyDuplicated(x$Person), logical(1))))
```

The RDS retains the scoring settings, fit identity, review tables and
notes. Each `by_draw` table can be joined to a Person-level
background/design table by ID for a downstream analysis. Check missing,
duplicate and unmatched IDs before joining. Keep the full object even if
a receiving tool needs a wide matrix or a smaller set of columns. For an
analysis bundle with its source fit, see
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md).

## Choose the downstream analysis separately

| Intended use | What remains to justify |
|----|----|
| Describe these conditional draws | Their scoring prior, calibration, numerical review and finite-draw approximation. |
| Estimate a population mean or regression | A conditioning model compatible with that analysis, the target population, sampling design and an appropriate uncertainty-combination rule. The two-Person example does not establish these. |
| Use official IEA plausible values | Follow that survey’s PV and sampling documentation directly; no mfrmr recalibration is required. |

[BIFIEsurvey’s data
interface](https://konradoberwimmer.github.io/BIFIEsurvey/reference/BIFIE.data.html)
and [EdSurvey’s survey
objects](https://american-institutes-for-research.github.io/EdSurvey/reference/edsurvey-class.html)
are possible downstream routes. This page does not claim a tested
adapter to either package. Use their documented analysis workflow when
it matches the question, and verify the within-PV, between-PV and
combined variance for that workflow. Rating weights, sampling weights
and replicate weights have distinct roles. An ordinary regression on
averaged PVs or on all draws stacked as independent people does not
perform that uncertainty propagation.

Calibration and fitted population parameters remain fixed in the current
draws. A downstream variance calculation does not automatically add
their estimation uncertainty. See
[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
for supported models and scoring options. Independent downstream code
can use these outputs without a new mfrmr API or an IEA-specific
workflow.
