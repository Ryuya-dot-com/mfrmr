# mfrmr

[![GitHub](https://img.shields.io/badge/GitHub-mfrmr-181717?logo=github)](https://github.com/Ryuya-dot-com/mfrmr)
[![R-CMD-check](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/pkgdown.yaml)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`mfrmr` fits unidimensional many-facet ordered-response models in R. It
supports rating-scale (`RSM`) and partial-credit (`PCM`) models,
together with a `GPCM` extension in which one selected facet supplies
level-specific discriminations. MML permits a different facet to supply
category steps; JML requires the same facet for both roles. GPCM MML
information-criterion comparison uses explicit likelihood and solution
checks; `confint(fit, parm = "slopes")` checks approximate pointwise
relative-slope intervals separately. Matched PCM/GPCM MML fits can be
tested with `compare_mfrm(..., nested = TRUE)`. A facet can represent a
rater, item, task, criterion, form, occasion, or another observed role
that affects an ordered score.

Educational performance assessment is a recurring example, but the
column names and facet roles are configurable. The same analysis
questions can arise when judges rate musical performances, clinicians
rate observed performance, or observers apply a psychological rating
rubric. Define the unit being rated, the ordered categories and the
modeled construct for each application. A competition total or a
continuous clinical measurement is not automatically an ordered-category
response.

Start with the quick start below: load data, fit a model, draw a plot,
and inspect the summary. The complete workflow then covers data checks,
diagnostics, and reporting.

Package website: <https://ryuya-dot-com.github.io/mfrmr/>

Source code: <https://github.com/Ryuya-dot-com/mfrmr>

Questions and bug reports:
<https://github.com/Ryuya-dot-com/mfrmr/issues>

## Installation

This README describes the `0.2.4.9000` development source, including
portable calibration, exploratory external-feature groups, numeric
PCA/k-means, assigned-score imputation, fixed-facet sandwich intervals,
screening evaluation, multivariate G/D-studies, and shared random-rater
and Person-specific testlet RSMs. See [the
roadmap](https://ryuya-dot-com.github.io/mfrmr/ROADMAP.html) for
supported scope and future work. The development version is intended for
evaluation and has not been released on CRAN. Its
`mfrmr_output_guide("plots")` is not part of the checked rc.6 archive.
Functions and options shown here may differ from an installed release;
retain the installed source tag or commit and use its matching help.
Earlier candidates also report `0.2.4`, so `packageVersion("mfrmr")`
alone cannot distinguish them. For an existing analysis, read [Updating
saved analyses](#updating-saved-analyses) before reusing saved
diagnostics, scores or reports.

Install the published CRAN release with:

``` r

install.packages("mfrmr")
```

To install the downloaded 0.2.4 candidate archive, use the following
command (replace the path with its location on your computer).
Development-only features require the corresponding development
checkout:

``` r

install.packages("path/to/mfrmr_0.2.4.tar.gz", repos = NULL, type = "source")
```

The checked GitHub candidate is `v0.2.4-rc.6`. It includes
[`mfrm_cluster_pam()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md),
[`review_mfrm_imputations()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md),
`category_policy` and the `"feedback"` output-guide scope. To install
that candidate reproducibly:

``` r

if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

remotes::install_github(
  "Ryuya-dot-com/mfrmr",
  ref = "v0.2.4-rc.6",
  build_vignettes = TRUE
)
```

The [release
page](https://github.com/Ryuya-dot-com/mfrmr/releases/tag/v0.2.4-rc.6)
provides the rc.6 source archive with prebuilt tutorials, its checksum
and the applicable check results. Check which revision contains a new
API before using `ref = "main"`; that branch changes over time. A local
checkout can also be installed with
`remotes::install_local("path/to/mfrmr")`, using the directory
containing `DESCRIPTION` and this README.

## Quick start

This example estimates person abilities while accounting for rater
severity and criterion difficulty. A *facet* is a source of variation in
scores; here, `Rater` and `Criterion` are facets, and individual raters
and criteria are their *levels*. The data are synthetic, with one row
per rating and scores from 1 to 4.

`head(toy)` shows the first six rows. The quoted column names in
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
are case-sensitive; `Study` and `Group` are extra labels unused by this
model. `MML` selects marginal maximum likelihood; `RSM` selects a
rating-scale model with shared category thresholds (the transitions
between adjacent scores).

``` r

# Load the package
library(mfrmr)

# Load example ratings and look at the first six rows
toy <- load_mfrmr_data("example_operational")
head(toy)

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1, rating_max = 4, category_policy = "preserve",
  method = "MML",
  model = "RSM",
  population_formula = NULL # Fixed N(0,1) ability distribution
)

# Plot the results (Wright map)
plot(fit)

# Save the summary, then display its tables
results <- summary(fit)
results$person_overview # One row summarizing person ability estimates
results$facet_overview  # One row per facet: number of levels, mean, SD, range

# Check the interpretation status and recommended next step
results$decision
```

`<-` saves an object without printing it. Here `toy` holds the data,
`fit` holds the model, and `results` holds its summary. `$` selects a
named part: `results$person_overview` displays just that table. Enter
`results` to print the full summary.

These settings describe this example, not every assessment. The bounds 1
and 4 come from its rubric; change them for your own data.
`keep_original = TRUE` preserves that category ladder. The ordinary
default is `FALSE`, which can collapse unused internal categories and
change the model’s steps. Preserving an unsupported internal category
instead stops fitting for review. `population_formula = NULL` fixes the
ordinary RSM/PCM ability distribution at N(0,1); it does not estimate
the population variance. Both extended RSMs estimate that variance by
default, so copying defaults across models does not necessarily provide
a matched comparison.

The Wright map displays the estimates in logits, the model’s measurement
units, rather than the original 1-to-4 scores. With this example’s
default orientation, higher person estimates mean higher ability; higher
rater estimates mean stricter ratings, and higher criterion estimates
mean greater difficulty.

The overview tables describe distributions: `person_overview` has one
row for all 48 persons, and `facet_overview` has one row for each facet.
`Mean`/`MeanEstimate` is the average, `SD`/`SDEstimate` is the spread,
and `Min`/`Max` or `MinEstimate`/`MaxEstimate` give the endpoints. Rater
and criterion means are constrained to zero here; their SDs and ranges
show differences among levels.

### Inspect individual estimates

``` r

estimates <- as.data.frame(fit)
head(subset(estimates, Facet == "Person")) # First six persons
subset(estimates, Facet == "Rater")       # All raters
subset(estimates, Facet == "Criterion")   # All criteria
```

`Facet` identifies the type of estimate, `Level` identifies the person,
rater, or criterion, and `Estimate` is its value in logits.

### Check what needs review

Read `results$decision`, especially `Why` and `NextAction`, before
interpreting or reporting estimates. `FormalInference = "No"` in this
first summary can mean that precision has not yet been reviewed; it does
not necessarily mean that fitting failed. The default summary does not
compute diagnostics.

``` r

diagnostics <- diagnose_mfrm(fit)
diagnostic_summary <- summary(diagnostics)
diagnostic_summary$decision
```

For your own data, follow [Use your own CSV](#use-your-own-csv) below.
For reporting, `res <- mfrm_results(fit, diagnostics = diagnostics)`
builds a comprehensive object that reuses the checks above. Pass `res`
to
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
or
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md);
`results` remains the basic summary.

For a guide to the next steps, open
[`help("mfrmr_workflow_methods", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)
or
[`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md).
Use
[`help("mfrmr_visual_diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
when choosing a figure and
[`help("mfrmr_reporting_and_apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)
when moving from a reviewed fit to tables and manuscript-draft output.

### Choose a function by your question

You do not need to learn every function before starting. Continue with
the question you have and open the named function’s help, for example
[`help("review_mfrm_imputations", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md).

Earlier scripts using
[`mfrm_cluster()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
or
[`mfrm_response_imputations()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md)
remain valid. For new scripts, the names below make the clustering
method and the imputation-review step explicit. In imputation review,
`impute_ids` contains rating-event IDs to check, not a switch that
starts an imputation model.
[`compatibility_alias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/compatibility_alias_table.md)
maps old calls to their recommended names.

| Your question | Start with | What you receive |
|----|----|----|
| Are my rating rows and categories usable? | [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md) | A data review; correct problems in the rating table before fitting. |
| How severe are these raters, allowing for person ability and criterion difficulty? | [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md) | A fitted model; use [`summary()`](https://rdrr.io/r/base/summary.html) and [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md) to review it. |
| How uncertain is a specified fixed-rater difference? | [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md) | Pointwise intervals for an eligible ordinary RSM/PCM fit, using model-based or explicitly selected sandwich covariance. |
| What are the abilities of people already in my fitted RSM? | [`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md) | Conditional ability scores under a supported ordinary, shared-rater or testlet RSM. |
| Do raters with similar backgrounds form descriptive groups? | [`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md), then [`mfrm_cluster_pam()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md) or [`mfrm_cluster_kmeans()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_kmeans.md) | Groups based on external attributes, not rater quality. [`mfrm_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md) optionally summarizes numeric attributes first. |
| How do I analyze several completed versions of missing assigned scores? | [`review_mfrm_imputations()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_imputations.md), then [`fit_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_imputed.md) and [`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md) | A review, separate fits and pooled eligible facet estimates. Supply the completed data; the first function does not generate replacements. |
| Would more raters or tasks make scores more dependable? | [`mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_gstudy.md), then [`mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_study.md) | Sources of variation in observed scores, then projections for the plans you specify. |
| How often does my warning rule miss a simulated problem or raise a false flag? | [`mfrm_screening_performance()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md); [`mfrm_screening_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_sensitivity.md) to compare thresholds | Simulation summaries with known truth, not an accuracy estimate from real ratings alone. |

For feedback to raters, `mfrmr_output_guide("feedback")` connects these
questions to the appropriate model, tables, plots and saved results. A
severe rater need not misfit. Changing a cutoff shows how flags change
in your data; it does not estimate the rule’s false-flag rate without
known truth. Shared-rater severity intervals and fixed-rater coefficient
intervals have different targets.

[`mfrm_cluster_pam()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
uses partitioning around medoids (PAM), which represents each group by
an actual member and accepts mixed numeric/categorical attributes.
[`mfrm_cluster_kmeans()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_kmeans.md)
uses numeric group means. For a tree of nested groups and a dendrogram,
choose
[`mfrm_cluster_hierarchical()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_hierarchical.md).
These are different algorithms; the shorter name does not choose among
them automatically.

The verbs help identify the operation: `fit_` estimates a model,
`score_` estimates person abilities using a fitted calibration, `pool_`
combines eligible analyses, and `export_` writes files. The package is
named **mfrmr**; **mfrm** in function names refers to a many-facet Rasch
model. Some help guides use the package prefix `mfrmr_`. These prefixes
do not select different estimators. Use `summary(object)` and
`plot(object)` rather than calling class-specific names such as
`plot.mfrm_testlet` directly.

Two distinctions matter when choosing an extension:

- [`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
  models one rater effect shared across everyone that rater evaluates.
  [`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
  models an extra local effect shared by a group of ratings **within one
  person**, such as criteria from one performance. Choose this structure
  from the assessment design, not the function name alone.
- For people already included in a supported fitted RSM,
  `score_mfrm_persons(fit)` provides a common scoring entry.
  [`predict()`](https://rdrr.io/r/stats/predict.html) has model-specific
  meanings: shared-rater prediction needs supplied abilities and returns
  response probabilities, while testlet prediction estimates abilities
  from ratings. For new people with ordinary RSM/PCM calibration, see
  [`help("score_mfrm_calibration")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md).

Shared-rater ability scoring can be slow: each selected person’s
calculation uses the complete rating table to account for uncertainty
about shared raters. Start with a few existing IDs using `persons`, for
example `score_mfrm_persons(fit, persons = c("P01", "P02"))` when those
IDs occur in your fit. This selects the output rows; it does not discard
the other people’s ratings. Omitting `persons` requests everyone.

A **calibration** is the fitted set of model parameters, such as rater
severity, criterion difficulty and category thresholds. A
**conditional** ability interval holds that calibration fixed; it does
not include uncertainty from estimating those parameters. **EAP** means
the mean of the conditional ability distribution. An **SE** describes
uncertainty in an estimate; an **SD** describes spread, such as the
variation among persons. Check which quantity a table’s SD represents.

`mfrmr_output_guide("beginner")[, c("Question", "MainFunction")]` gives
a compact ordinary-MFRM route. The full
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)
is a specialist reference; use `"models"`, `"features"`, `"imputation"`
or `"gtheory"` for a focused guide. For figures,
`mfrmr_output_guide("plots")` maps purposes to plotting and conversion
routes. The development visual-diagnostics gallery links six previews to
runnable examples and their numerical tables; in R, open
[`vignette("mfrmr-visual-diagnostics")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).
See
[`help("mfrmr_workflow_methods")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)
for the supported inputs and next steps.

Before adapting an example, read **Check defaults before adapting an
example** in that help page. It explains different missing-value
policies, fixed facets versus testlet membership, feature scaling and
weights, G/D-study plans, interval methods and screening bands. For
example, calling
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
without `method` requests model-based intervals; request
`method = "sandwich"` explicitly for that alternative. PCA and direct
k-means standardize features by default. These are analysis choices, not
just display preferences. Check the settings stored with each result.

For custom figure headings, the development version adds `title` to
eight existing diagnostic helpers, including
[`plot_bubble()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bubble.md)
and
[`plot_facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_quality_dashboard.md).
Use `title = "Scoring patterns"` to replace the heading or
`title = NULL` to hide it. Existing `main` calls remain supported;
`main = NULL` still means the default heading. Supply only one name. See
[`?mfrmr_visual_diagnostics`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
for the complete list and interpretation notes that should accompany
minimal figures.

### Give feedback to raters

Use the fitted model and diagnostics above to ask which rating patterns
need discussion with a rater. First read `diagnostic_summary$decision`;
a plot does not override its restrictions. Then inspect signed severity
estimates and their uncertainty, followed by the detailed screening
results:

``` r

# Review severity on the fitted scale without heuristic guide bands
severity <- plot_rater_severity_profile(
  fit, diagnostics = diagnostics, facet = "Rater",
  show_bands = FALSE, draw = FALSE
)
severity$data$data[, c("Level", "Estimate", "SE", "CI_Lower", "CI_Upper")]

# Keep the screening settings and interpretation notes with the results
rater_review <- facet_quality_dashboard(
  fit, diagnostics = diagnostics, facet = "Rater"
)
rater_review$detail[, c("Level", "N", "Estimate", "SE", "Infit", "Outfit")]
rater_review$detail[, c("Level", "MissingMetrics", "SeverityFlag", "MisfitFlag")]
rater_review$settings
writeLines(strwrap(rater_review$notes, width = 72))

# Inspect rating coverage and category use before selecting feedback cases
coverage <- subset_connectivity_report(fit, diagnostics = diagnostics)
summary(coverage)
usage <- data_quality_report(fit)
usage$category_usage_summary
usage$facet_response_patterns
cases <- build_misfit_casebook(fit, diagnostics = diagnostics)
summary(cases)
```

For one recipient, the development version also provides a standalone
sheet from saved native additive RSM/PCM results:

``` r

feedback_results <- mfrm_results(fit, diagnostics = diagnostics, compute = "never")
sheet <- mfrm_report(feedback_results, style = "rater", facet = "Rater",
                     rater = "R01", output = "html", max_cases = 0)
sheet$path # Open and review, then copy this HTML file to a permanent location.
```

`audience = "researcher"` adds technical guidance. Use `max_cases = 5`
to include selected unexpected ratings. For available fixed-facet
intervals, attach saved
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
output through `mfrm_results(intervals = list(raters = ci))`; the sheet
never calculates missing diagnostics or intervals. Its default label is
“Selected rater”; an explicit `label` is printed as supplied. The sheet
omits source identifiers and the source fit, but recognizable rating
patterns still require review before sharing. Distribute the standalone
HTML, not the comprehensive analysis bundle. GPCM, interaction, testlet
and random-rater models require their own reports.

For a column named `Judge` or `Examiner`, pass that modeled facet name
instead of `"Rater"`. Severity describes scoring relative to the fitted
reference; being stricter does not by itself mean being inconsistent or
incorrect. Individual interval overlap is not a test of the difference
between two raters. Dashboard flags use the displayed screening settings
and require follow-up; they do not establish bias or justify automatic
exclusion. `MissingMetrics` identifies unavailable diagnostics: zero
observed flags is not a complete pass. A `REVIEW ONLY` plot retains the
fit’s interpretation restrictions. Keep the complete dashboard when
saving with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html);
`export_mfrm_bundle(..., include = c("dashboard", "html"))` also retains
screening settings and interpretation notes with the exported tables.

Check each rater’s workload, category use and overlap with other raters
before discussing flagged cases. Compare selected ratings with the
rubric and shared calibration performances. Insufficient overlap may
call for additional common ratings before comparing raters. For a
training follow-up, compare explicitly linked occasions; a change in
severity alone does not establish a training effect. See
[`help("facet_quality_dashboard")`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md),
[`help("data_quality_report")`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md)
and
[`help("subset_connectivity_report")`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md)
for the supporting checks.

### Compare uncertainty for a rater difference

[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
compares ordinary observed-information intervals with a sandwich
covariance for eligible fixed-standard-normal RSM/PCM MML fits. By
default, each person’s full response vector is one independent unit. For
a rater difference, specify named contrast coefficients so the
calculation includes covariance between rater estimates:

``` r

rater_levels <- as.character(subset(as.data.frame(fit), Facet == "Rater")$Level)
contrast <- matrix(0, nrow = 1, ncol = length(rater_levels),
  dimnames = list("R01 minus R02", rater_levels))
contrast[1, c("R01", "R02")] <- c(1, -1)
intervals <- mfrm_facet_intervals(
  fit, "Rater", contrasts = contrast, method = "sandwich"
)
summary(intervals)
plot(intervals)
```

Use level names from your fitted facet. Both covariance methods share
the same point estimate; changing interval width does not correct bias
from a wrong population model or informative assignment. Larger
independent clusters can be declared explicitly, but few clusters can
give poor intervals. These are pointwise intervals conditional on the
observed fixed raters, not random-rater inference or a rater-exclusion
rule. The tutorial explains the assumptions, unavailable results and
saved output:
[`vignette("mfrmr-facet-intervals", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-facet-intervals.md).

To evaluate a warning rule in a simulation, use
`mfrm_screening_performance(roster, results, rule = "your prespecified rule")`.
Declare every planned condition, replication and target in `roster`,
together with known `Affected` truth. Supply logical `Flag` outcomes in
`results`, keeping unavailable screens as `NA`. The helper separates
per-rater rates from the probability of any false warning among raters
and retains Monte Carlo intervals and unresolved trials. It does not
supply truth labels for actual raters. An implemented screen can have
poor sensitivity: in a bounded comparison, Infit/Outfit outside \[0.5,
1.5\] detected only 6/100 and 2/100 contaminated-rater cases under two
sparse assignments. See
[`vignette("mfrmr-screening-performance", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-screening-performance.md)
for runnable examples, plots, study conditions and interpretation.

For several prespecified bands, use
`mfrm_screening_sensitivity(roster, measures, thresholds, rule = ...)`
with saved Infit/Outfit columns. Plot `direction = "underfit"` and
`"overfit"` separately, or choose `style = "curves"` for Monte Carlo
intervals. Labelled tiles, monochrome rendering, ggplot conversion and
hidden/custom annotations are supported.
[`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md)
now bases its default status on mean squares; ZSTD remains separate
evidence. The earlier combined rule is available with
`flag_basis = "mnsq_or_zstd"`. A low mean square is not an automatic
reason to exclude a rater, and these ordinary-model thresholds do not
qualify extended-model posterior-predictive diagnostics.

### Model a population of raters

[`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
fits an RSM in which the same random severity enters all ratings from a
given rater. It uses frequentist approximate marginal maximum likelihood
with Person quadrature and a joint rater Laplace integral. It requires
optional `RTMB` version 2.0 or later, an independent normal rater
population and a connected assignment. Normal Person variance is
estimated by default, with mean zero and Rasch slope one; use
`person_sd = 1` only for an explicitly known N(0,1) population. Profiles
and bootstrap refits retain the same estimated or known population
specification.

``` r

random_fit <- fit_mfrm_random_rater(
  load_mfrmr_data("example_core"), "Person", "Rater", "Score",
  facets = "Criterion", score_levels = 1:4, quad_points = 121
)
random_fit$checks
plot(random_fit)
confint(random_fit, parm = "rater_sd")
```

The default plot shows severity point estimates. Explicitly choose
`plot(random_fit, style = "precision", intervals = "normal")` to inspect
approximate interval width, or `style = "distribution"` for the
empirical cumulative distribution of the observed estimates. These views
also work for extended-model Person scores and testlet fixed facets.
They do not estimate fit or the latent population distribution. Use
`palette = "mono"`, `sort = "estimate"`, `show_title = FALSE` and
`show_notes = FALSE` to adapt a figure, or replace `title` and
`caption`. Saved plot data retain interpretation notes, text
alternatives, complete tables and exclusion reasons;
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
preserves the selected view and supports further styling.

`compare_mfrm(ordinary_fit, random_fit)` compares centered facet
summaries when the ordinary RSM MML uses matching data, categories and
population assumptions (`population_formula = ~1` for estimated ability
SD). It retains checks and raw values, and supports paired/difference
plots and attachment via
`mfrm_results(random_fit, comparison = comparison)`. The same route
accepts a testlet fit. This is descriptive: no automatic model
preference, difference intervals or cross-model Infit comparison is
supplied.

`score_mfrm_random_rater(random_fit, persons = c("P001", "P002"))`
scores selected Persons while retaining all source responses. It
integrates the shared raters jointly, holds calibration fixed and
returns continuous conditional intervals, prior-only rows and
unavailable reasons. New scoring data replace the entire response
roster; selecting output IDs does not drop other Persons’ evidence.
Attach saved scores with `mfrm_results(random_fit, scores = scores)`;
response predictions and bootstrap intervals may be attached at the same
time. The scoring calculation uses a conditional Laplace approximation,
whose accuracy is separate from its numerical checks and from
repeated-sample coverage.

Individual-rater bounds are not supplied automatically: their nominal
coverage is not established. `confint(random_fit, parm = "raters")`
explicitly returns the first-order normal approximation without
refitting; `plot(random_fit, intervals = "normal")` displays it. Earlier
saved fits also show no automatic bounds in new summaries, plots and
reports. This output restriction does not correct the approximation’s
coverage. Observed-rater intervals describe realized severities; the
profile interval describes population variation and may include zero.
[`predict()`](https://rdrr.io/r/stats/predict.html) distinguishes
observed from replacement raters at explicitly supplied abilities,
holding calibration fixed. Numerical checks do not certify coverage or
the accuracy of the rater approximation, especially with few raters. A
study with estimated ability SD used 200 datasets in each of four
assignment/rater-count conditions. Conditional coverage was 91.6–91.8%
with six raters and 94.0–94.1% with 24, but finite-interval availability
was 99% and 87–88%, respectively. None met the combined qualification
criterion. The tutorial reports Monte Carlo uncertainty, numerical
failures and the earlier known-population pilot.
`mfrm_random_rater_intervals(random_fit, nsim = 499, seed = 123)` adds a
model-based bootstrap comparison by generating persons, shared raters
and scores and refitting each dataset. It retains unavailable results,
can return unbounded limits, and saves draws for
[`confint()`](https://rdrr.io/r/stats/confint.html) and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) without further
fitting. More accurate coverage is a question to verify, not a
consequence of using a bootstrap. Bootstrap intervals do not become the
default. The result has its own methods; fixed-facet diagnostics, MI
pooling and portable calibration do not accept it. See
[`vignette("mfrmr-random-raters", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-random-raters.md)
for the complete feedback, prediction and save/load workflow.

## Dependence within a person’s ratings

[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
models an extra effect shared by ratings in the same Person/testlet
group. For example, one examiner’s impression of a performance may
influence several criterion scores. A fixed `Rater` effect can describe
usual severity while `testlet = "Rater"` groups those criteria within
each person. Reusing that rater label for another person creates an
independent local effect.

``` r

ratings <- load_mfrmr_data("example_core")
testlet_fit <- fit_mfrm_testlet(
  ratings, "Person", "Score", "Rater", c("Rater", "Criterion"),
  score_levels = 1:4, quad_points = 121
)
testlet_fit$checks
plot(testlet_fit, facet = "Rater")
first <- ratings[ratings$Person %in% unique(ratings$Person)[1:4], ]
scores <- predict(testlet_fit, first)
plot(scores)
```

This is frequentist MML for an RSM with mean-zero normal abilities and
one common normal local variance. Ability variance is estimated by
default; use `person_sd = 1` for a known standard-normal population.
Numerical and information checks must pass before scoring. Unequal
blocks and sparse assignments are allowed, subject to design
requirements; missing assigned scores require explicit omission. The
Person intervals are conditional on fitted calibration and exclude its
estimation uncertainty. Entirely missing persons are labeled
`prior_only`. Use `mfrmr_output_guide("models")` to compare the three
model routes and
[`help("mfrmr_workflow_methods")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)
to find their supported outputs. The testlet class supports
[`summary()`](https://rdrr.io/r/base/summary.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md)
and save/load. `as_ggplot(scores)` and
`as_ggplot(testlet_fit, facet = "Rater")` preserve interval meanings,
unavailable rows and prior-only symbols. Existing saved results need no
refit for these displays. For a report, use
`res <- mfrm_results(testlet_fit, predictions = scores)`, then
`mfrm_report(res)` or
`export_mfrm_results(res, output_dir = "testlet-results", preset = "starter")`.
The random-rater route also accepts separately computed `intervals` from
[`mfrm_random_rater_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md).
These routes collect saved results without fitting, scoring or
resampling; older predictions require regeneration from the saved fit to
add source metadata. Ordinary-model diagnostics, the Shiny viewer,
response-MI pooling and portable calibration remain unavailable. See
[`vignette("mfrmr-testlets", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-testlets.md)
for membership, missingness, variance boundaries and reuse. Broader
coverage and calibration-aware Person intervals remain unfinished.

[`vignette("mfrmr-testlet-applications", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-testlet-applications.md)
connects this model to assessment decisions: allocating four ratings
across tasks, comparing one-point changes in five- versus two-criterion
tasks, reviewing possible halo, and recognizing the limits of a common
local variance. The executed planning example averages all 81 possible
score patterns under a fixed fitted model; its marginal EAP reliability
is neither a G/Phi coefficient nor a coverage guarantee. Large local
variance does not diagnose halo or show that criteria should be merged.
Task-specific variances and enforced equal task weighting are not
supplied by the current API.

Use `mfrm_response_diagnostics(fit, group_by = "Rater")` with an
ordinary RSM MML fit or either extension for category probabilities,
predictive means/variances and **descriptive** Infit/Outfit. These
integrate latent uncertainty given the same observed responses and
fitted calibration. They have no established expectation of one or
reference cutoffs, and cannot be directly compared with ordinary plug-in
fit indices. Shared-rater computation uses a joint Laplace
approximation; its numerical checks do not certify accuracy.

``` r

residuals <- mfrm_response_diagnostics(testlet_fit, group_by = "Rater")
plot(residuals, style = "paired")
as_ggplot(residuals, style = "scatter", show_title = FALSE)
res <- mfrm_results(testlet_fit, predictions = scores, diagnostics = residuals)
```

For a comparison on the same definition, compute the ordinary RSM’s
posterior predictions once and attach both saved results:

``` r

ordinary_residuals <- mfrm_response_diagnostics(ordinary_fit, group_by = "Rater")
comparison <- compare_mfrm(ordinary_fit, testlet_fit,
  response_diagnostics = list(ordinary_residuals, residuals))
plot(comparison, metric = "infit", style = "difference")
as_ggplot(comparison, metric = "probability", show_labels = FALSE)
```

Use matching events, output selections, group identifiers and population
assumptions. These paired/difference displays compare category
probabilities, expected scores, full predictive variances or descriptive
Infit/Outfit. Smaller residual indices do not establish improvement on
new data or model adequacy. See the two model tutorials for a complete
example and saved reports.

Missing scores and failed calculations remain visible. Selecting `rows`
limits the summaries, while all observed source ratings continue to
inform the posterior. Paired/scatter figures, reports and saved replay
reuse the computed diagnostics. They do not supply formal model-fit
tests.

[`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/reference/score_mfrm_persons.md)
provides source-roster conditional EAPs and continuous intervals for the
ordinary RSM and both extensions. Attach two saved scores with
`compare_mfrm(..., person_scores = list(ordinary_scores, extended_scores))`
and select `metric = "person"` to compare population-centered EAPs.

For either extension, collect source scores and residuals with
`mfrm_results(fit, scores = extended_scores, response_diagnostics = residuals)`.
Then `plot(res, type = "wright")` displays conditional reference
locations and `plot(res, type = "fit_pathway", facet = "Rater")`
connects them to descriptive Infit. Whiskers are Person conditional
intervals only; no ordinary fit bands are transferred. See
[`?mfrmr_model_maps`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_model_maps.md)
and the two tutorials for the location formula, selected-roster counts,
missing results and presentation controls.

## Data format

Each row records **one score given by one rater to one person on one
criterion**. The same person therefore appears on several rows:

| Person | Rater | Criterion | Score |
|--------|-------|-----------|-------|
| 001    | R1    | Content   | 3     |
| 001    | R1    | Style     | 2     |
| 001    | R2    | Content   | 4     |
| 001    | R2    | Style     | 3     |

These four rows illustrate the layout, not a dataset for estimating a
model. Keep the complete set of ratings for your analysis. Use
consistent IDs across rows; `001` identifies the same person each time.
`Score` contains the ordered integer categories from the rubric, not
person totals or averages across raters. Use a blank cell or `NA` for a
missing rating; zero is a score if your rubric includes zero. Do not add
zeros for ratings that were never assigned.

At least one non-person facet is required. This example uses two; choose
columns that represent your design. If criteria occupy separate
spreadsheet columns, see the reshaping example in the workflow vignette.

## Use your own CSV

Export the rating sheet as **CSV UTF-8**, with column names in the first
row. For the four-column layout above, run:

``` r

library(mfrmr)

# Select your CSV file in the file dialog
csv_path <- file.choose()
ratings <- read.csv(
  csv_path,
  colClasses = "character",
  na.strings = "",
  check.names = FALSE,
  fileEncoding = "UTF-8-BOM"
)
# Treat the documented missing-score marker only in the score column
ratings <- recode_missing_codes(ratings, columns = "Score", codes = "NA")
head(ratings)
names(ratings)
table(ratings$Score, useNA = "ifany")
```

For a reusable script, replace
[`file.choose()`](https://rdrr.io/r/base/file.choose.html) with a quoted
path such as `"data/ratings.csv"`, relative to the folder shown by
[`getwd()`](https://rdrr.io/r/base/getwd.html). Reading columns as text
preserves distinct IDs such as `001`, `1`, and `NA`; `mfrmr` converts
numeric score strings such as `"3"` for estimation. Empty cells are
missing in every column; the literal marker `NA` is recoded only in
`Score`. Use the missing-score markers declared for your data.

The names in `person`, `facets`, and `score` must match `names(ratings)`
exactly. For a file headed `Student`, `Judge`, `Task`, and `Rating`, use
`person = "Student"`, `facets = c("Judge", "Task")`, and
`score = "Rating"` in **both** calls below. Also use
`columns = "Rating"` in the recoding call and inspect `ratings$Rating`
above.

### Check the data before fitting

``` r

data_review <- describe_mfrm_data(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1,
  rating_max = 4,
  keep_original = TRUE
)
data_review$row_retention
data_review$missing_by_column
data_review$score_distribution
data_review$design_connectivity
```

Set `rating_min` and `rating_max` from the **rubric**, even if nobody
received the lowest or highest score. The values above describe a 1-to-4
rubric. `keep_original = TRUE` preserves its category structure. Check
`DroppedRows` for excluded rows and `RawN` for category counts. Missing
scores or required IDs remove that rating row, not automatically the
person’s other ratings. The package does not fill missing ratings. If an
internal category has no observations, fitting with this setting stops:
review the data and rubric before changing the categories.

`Components = 1` indicates that a facet’s levels are connected through
shared persons. More than one component needs design review before
comparing levels across components. This check alone does not establish
model identification. The vignette’s **If a check stops you** section
covers missing-value codes, unexpected row loss, and common input
errors.

### Fit and read the results

After resolving the data-review findings, use the same columns and score
scale:

``` r

csv_fit <- fit_mfrm(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1,
  rating_max = 4,
  keep_original = TRUE,
  method = "MML",
  model = "RSM"
)
csv_diagnostics <- diagnose_mfrm(csv_fit)
csv_results <- summary(csv_fit, diagnostics = csv_diagnostics)
csv_results$decision

plot(csv_fit)
csv_estimates <- as.data.frame(csv_fit)
head(subset(csv_estimates, Facet == "Person"))
subset(csv_estimates, Facet == "Rater")
subset(csv_estimates, Facet == "Criterion")
```

Read `Why` and `NextAction` before using the estimates. With these
default settings, higher person estimates mean higher ability, higher
rater estimates mean stricter ratings, and higher criterion estimates
mean greater difficulty. The values are in logits; a difference in
estimates alone does not establish statistical significance. For custom
facet names, also change the `Facet` filters above, for example from
`"Rater"` to `"Judge"`; person rows retain `Facet == "Person"`.

Open
[`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md)
for a runnable practice CSV, a wide-to-long example, and
troubleshooting. The complete workflow below returns to the packaged
data to illustrate further review and reporting.

## Further data considerations

### Response type and frequencies

The current response likelihood is ordered categorical. Binary scores
are the two-category special case, and RSM, PCM, and GPCM cover ordered
polytomous scores. Although their category probabilities form a vector
that sums to one, they are not unordered nominal-response or
multinomial-logit models. Poisson, negative-binomial, and grouped
binomial-trial count responses are also outside the current
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
scope. Integer counts supplied as `Score` are interpreted as ordered
category codes, not as Poisson or related counts.

A positive numeric `weight` weights one row’s conditional
ordered-category likelihood and can represent a defensible
row-replication weight. It is not a general collapsed-person frequency
table. Under MML, powering responses within one Person’s conditional
pattern is not equivalent to replicating a complete Person response
pattern after marginalization. It also does not change the response
family or model dependence among repeated ratings. Non-unit
observation-weight fits are excluded from the common MML
information-criterion panel and remain review-only for ordinary
inference: their SEs and intervals have not been qualified for the
weighted objective. FACETS has separate `Bn` binomial-trial and `P`
Poisson response models; those are not reproduced by mfrmr’s binary
ordered-score route.

Each row should represent a distinguishable rating event. Exact
duplicate Person-by-facet combinations are retained but trigger a
warning and a Data review state because the package does not model
within-cell dependence. For a legitimate re-rating or replicated scoring
study, include an event or occasion facet that distinguishes the
observations before fitting.

For conventional score sentinels such as `99`, `-1`, `N`, or `.`, set
`missing_codes = TRUE`. This convenience policy recodes the score column
only; it preserves person and facet identifiers because short labels
such as `N` can be legitimate IDs. Supplying an explicit character
vector instead applies that user-declared code set across the selected
model columns, so inspect the returned `missing_recoding` record before
fitting or reporting exclusions.

The main workflow below uses a compact synthetic dataset with a
connected two-rater assignment, moderately unequal rater workloads, and
six planned criterion-level omissions represented by absent long-format
rows, not `NA` or sentinel scores. Its groups contain 24 persons each;
three omissions per group leave 141 observed rows in Group A and 141 in
Group B:

``` r

library(mfrmr)

dat <- load_mfrmr_data("example_operational")
data("mfrmr_example_operational_design", package = "mfrmr")
head(dat)
table(dat$Score)
list_mfrmr_data(details = TRUE)[, c("Key", "PrimaryUse", "Design", "CountBasis")]
```

All bundled examples are synthetic. `example_operational` is the applied
teaching dataset, not an empirical reference dataset. Use `example_core`
only when an idealized complete crossing is useful for a fast example,
and use `example_bias` for demonstrations with deliberately planted
DFF/bias effects.

## Complete MML workflow

### 1. Check the data and intended score scale

Before fitting, state the complete rubric support and inspect retained,
missing, and zero-count categories:

``` r

data_review <- describe_mfrm_data(
  data = dat,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1,
  rating_max = 4,
  expected_design = mfrmr_example_operational_design
)
data_summary <- summary(data_review)
data_summary$structural_missingness
data_summary$design_connectivity
```

The assignment roster contains no scores. It tells
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
which Person x Rater x Criterion cells were planned. The review
therefore reports the six expected-but-unobserved cells separately from
ordinary column `NA` counts, while confirming that both observed
Person-facet graphs remain connected. Without `expected_design`,
structural missingness is reported as not assessed because an absent row
may simply mean that the cell was never assigned.

`rating_min` and `rating_max` retain unobserved boundary categories in
the data-support review. A boundary gap remains review evidence for the
separate element-boundary contract; it is not by itself an unsupported
free-step contrast. If an intended intermediate category is unobserved,
use `keep_original = TRUE` in both
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
and
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
In a polytomous fitted ladder, that retained internal gap creates an
exact adjacent-step recession direction, so fitting stops before
optimization. Otherwise non-consecutive observed scores such as
`1, 2, 4, 5` are mapped to a contiguous internal scale; always review
the reported score map before interpreting steps.

### 2. Fit the model

For a new analysis, start with marginal maximum likelihood:

``` r

fit <- fit_mfrm(
  data = dat,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1,
  rating_max = 4,
  method = "MML",
  model = "RSM"
)
```

`MML` integrates over the person distribution and returns posterior
person summaries. The default uses 31 quadrature points. Record that
setting and examine same-data quadrature sensitivity before portable
calibration and whenever numerical movement could affect a consequential
result. Eligible fits below 15 points retain raw AIC/BIC/SABIC for
screening, and fits at 15–30 points retain them for review, but
automatic deltas, criterion weights, preferred-model labels, evidence
ratios, and LRT are disabled below 31 points. Use 31–60 points as a
comparison starting grid and 61 or more as a denser sensitivity grid. A
close or consequential comparison still requires a prespecified
common-grid sensitivity check; q\>=31 alone is not evidence that
integration error is negligible.

For the fitted MML model and the same data, request the comparison
explicitly.
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
reuses the supplied fit at its stored grid and refits the other
requested grids; `summary(q_review)` only summarizes the returned
review:

``` r

q_review <- mml_quadrature_sensitivity(
  fit,
  data = dat,
  quad_points = c(31, 61)
)
summary(q_review)
apa_table(q_review)
```

The review works for RSM, PCM, and GPCM. It reports changes in marginal
likelihood per Person, measurement coordinates, probabilities, EAP,
posterior SD, and, when present, relative slopes, raw local-curvature
SEs, and population SD. Explicit population formulas, person covariates
and their coding are preserved. GPCM tables also show interval
endpoints, eligibility and their changes across grids. The GPCM-specific
[`gpcm_mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
name remains available. Neither route assigns a universal
stable/unstable cutoff, makes raw slope SEs inferentially eligible, or
changes the fit-readiness decision.

A fit marked `ready` has passed its recorded checks at the chosen grid;
that status does not establish that a denser grid would give the same
answer. Review changes in rater estimates and SEs separately from
changes in person scores, using tolerances appropriate to the intended
interpretation. If the first comparison shows meaningful movement,
compare against a further denser grid. Numerical agreement does not
establish repeated-sampling interval coverage.

Use `model = "PCM", step_facet = "Criterion"` when category steps differ
across that facet. Choose the model from the scoring design and
measurement rationale, not from a single fit statistic.

### 3. Read the fit-only summary

The default summary is deliberately lightweight:

``` r

fit_summary <- summary(
  fit,
  profile = "fit",
  detail = "brief"
)

fit_summary$decision
fit_summary$overview
fit_summary$status
fit_summary$readiness
fit_summary$data_review
fit_summary$settings_overview
fit_summary$facet_overview
fit_summary$person_overview
fit_summary$step_overview
```

Read `fit_summary$decision` first: have estimation checks passed, has
precision been assessed, what limits interpretation, and what should be
done next? A fit-only summary returns `FormalInference = "No"` even when
estimation checks pass. Convergence and estimability do not by
themselves validate standard errors, confidence intervals or
reliability. Review precision with matching diagnostics:

``` r

diag <- diagnose_mfrm(fit, residual_pca = "none")
summary(fit, diagnostics = diag)$decision
# Equivalent precision-aware decision:
summary(diag)$decision
```

The decision is a presentation of existing evidence, not a new
statistical test or an automatic model-selection rule.
`FormalInference = "No"` still permits explicitly labelled diagnostic
inspection, but not formal SE/CI, reliability, or significance claims.
It does not mean that changing optimizer settings until the answer
becomes `"Yes"` is appropriate. Follow `NextAction` and retain the
original reason in reports.

Then review convergence and estimation settings. Optimizer success and
the terminal-gradient check are separate numerical checks. A small
gradient still does not resolve a disconnected design, effects that
cannot be separately estimated, or unbounded estimates. The fitting help
describes the numerical controls and the recorded optimization history.

Treat `maxit` as a computational ceiling, not a convergence criterion or
a control to tune until preferred estimates appear. The default is
`maxit = 400`. Prespecify the estimator and controls before inspecting
results. If a fit stops at the iteration limit, refit the same data,
model, method, anchors, optimizer, tolerance and quadrature rule using
the next ceiling in that sequence. Do not select among runs by
coefficient size, fit statistics, significance or agreement with an
expected answer. Material differences between numerically acceptable
runs require review.

Print `fit_summary` for readable explanations; its component tables
retain detailed settings and status fields for further inspection.
Estimation checks and precision assessment are distinct from reviewing
the rating design and the assumptions needed for the intended
comparison. Plots marked `REVIEW ONLY` remain diagnostic displays. A
saved fit without current estimation checks needs the update procedure
below before inferential reuse.

### 4. Request the comprehensive measurement summary

Use the `facets` profile for the main review:

``` r

facets_summary <- summary(
  fit,
  profile = "facets",
  detail = "brief"
)

facets_summary
facets_summary$status
facets_summary$section_status
facets_summary$required_visual

res <- facets_summary$results
res$readiness
res$plot_map[, c(
  "Type", "Available", "InterpretationStatus", "InterpretationReady"
)]
```

This profile organizes model information, measures, uncertainty, fit
evidence, precision, category/step information, and plot routes in one
reading order. No experience with FACETS, TAM, or sirt is required. It
computes the documented diagnostics when they are needed and returns the
resulting `mfrm_results` object in `facets_summary$results`.

The historical profile name describes organization, not software
execution:

- FACETS is not called;
- all estimates remain `mfrmr` estimates;
- sections that require a study-specific contrast, such as DIF or DFF,
  are not inferred automatically;
- residual PCA and multi-wave linking or drift analyses remain explicit
  follow-up decisions.

Pass a matching
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
object through `diagnostics = diag` to reuse work already completed. Use
`compute = "never"` for a no-computation review; dependent sections are
then marked as not computed.

Person identifiers are omitted from the brief console view. Request
detailed person output only when the analysis purpose and data-handling
plan require it.

### 5. Inspect targeting with the native Wright map

The native renderer is the primary targeting figure because it keeps
uncertainty visible:

``` r

plot(
  res,
  type = "wright",
  renderer = "native",
  show_ci = TRUE,
  preset = "publication"
)
```

Read the vertical axis as the shared logit scale:

- the person distribution shows where the sample lies;
- facet levels show severity, difficulty, or the active signed
  orientation;
- step locations show the fitted category structure;
- intervals show uncertainty where an appropriate SE is available;
- gaps between the person distribution and the modeled locations may
  indicate weak targeting in that region.

Person and non-person uncertainty can have different statistical bases.
For example, an MML person interval is based on posterior uncertainty,
whereas a non-person interval may use observed-information uncertainty.
Keep the reported SE method with any table or figure interpretation.

The package defaults to a negative orientation for ordinary non-person
facets: higher measures indicate greater severity or difficulty. Facets
named in `positive_facets` have the reverse scoring direction. State the
active orientation in the figure caption.

Set `draw = FALSE` to obtain the fitted coordinates for a custom
`ggplot2`, Quarto, or accessibility-aware figure.

`top_n = Inf` retains and labels every fitted coordinate. The native
text layer keeps the fitted points fixed, moves only colliding labels,
and connects them with leader lines; `label_points` records both
coordinates. Step thresholds share a vertical ladder and are labelled
with both the score transition and the fitted logit. For genuinely dense
maps, use the finite `top_n` compact view or a larger output device
rather than silently omitting interior labels.

When the fit review diagnoses boundary-separated facet levels and no
explicit `wright_range` is supplied, the native and FACETS-style
renderers use the same robust central range. Boundary levels appear at
the appropriate ruler end with triangles, while `OriginalEstimate`,
`CI_Lower`, and `CI_Upper` retain the untruncated values.
`DisplayEstimate`, `DisplayCI_Lower`, `DisplayCI_Upper`, and the
`CIClipped*` / `CISuppressed` fields describe only what was drawn. This
prevents a huge separation interval from compressing the interpretable
center or being mistaken for a complete visible interval.

### 6. Add the optional FACETS-style Wright map

Use study-specific rubric labels rather than anonymous category numbers:

``` r

rubric_labels <- c(
  "1" = "Beginning",
  "2" = "Developing",
  "3" = "Proficient",
  "4" = "Advanced"
)

plot(
  res,
  type = "wright",
  renderer = "facets",
  category_labels = rubric_labels,
  rows_per_logit = 2,
  show_ci = FALSE,
  preset = "publication"
)
```

The FACETS-style renderer provides:

- one common logit ruler;
- a person-frequency column drawn with `*`;
- signed facet headers and facet-level labels;
- horizontal step lines;
- adjacent-score labels such as `1 Beginning -> 2 Developing`;
- expected-score midpoint markers;
- an explicit `* = n person(s)` legend.

Set `persons_per_star` when the same star density must be used across
several figures. Otherwise, the renderer chooses a compact value and
prints it below the map.

The step display is designed to make the rating scale readable:

- a solid horizontal line is an estimated adjacent-category step
  location;
- its label names the lower and upper observed score categories and
  prints the fitted logit value in brackets;
- its height is the step location on the shared logit scale;
- a shorter dotted line is an expected-score midpoint crossing, not an
  additional model parameter.

For `RSM`, the step pattern is shared by the relevant observations. For
`PCM`, read the step column within its curve or step-facet group.
Disordered or closely spaced steps are prompts to inspect category use,
sample support, and the scoring design; they are not automatic
instructions to collapse categories.

Use the actual rubric wording from the instrument. The names of
`category_labels` must match the original scores. A two-column data
frame with columns `Score` and `Label` is also accepted.

With `draw = FALSE`, the returned `facets_style` component exposes
`category_labels`, `step_ruler`, `score_transitions`, and `settings`
tables. For line-printer reconstruction, `RulerValue` records the
nearest discrete ruler row; `DrawValue` records the exact coordinate
used for step and midpoint lines in the current renderer.

For a closer FACETS visual comparison, leave `show_ci = FALSE`. Setting
`show_ci = TRUE` adds `mfrmr` uncertainty whiskers to the asterisk
ruler. That hybrid is useful analytically, but it is intentionally an
extension of the FACETS-style layout; its footer identifies the interval
level and the dot at each whisker marks the corresponding fitted facet
location.

Boundary-separated levels otherwise make an estimate-derived ruler very
wide. The automatic boundary-aware range described above is used by
default; set an explicit, reported range such as
`wright_range = c(-4, 4)` when the application requires a prespecified
display scale. Out-of-range levels remain visible in parentheses at the
ruler ends. With `show_ci = TRUE`, endpoint triangles and the footer
identify intervals that extend beyond or are omitted from the displayed
ruler; exact values remain in the returned data.

### Visual correspondence is not numerical equivalence

The FACETS renderer reproduces the main reading grammar of a FACETS
Table 6-style variable map. It does not reproduce a FACETS run.

| Question | What `mfrmr` provides |
|----|----|
| Familiar visual layout | Asterisk person counts, shared ruler, signed facet columns, step lines, and rubric-labelled transitions |
| Estimate source | The fitted `mfrmr` object |
| Pixel-identical output | Not guaranteed across graphics devices, fonts, or FACETS versions |
| Numerical equivalence | Not established by selecting `renderer = "facets"` |
| External comparison | Available after the user supplies output from a separately run FACETS analysis |

A defensible numerical comparison requires the same response records,
score coding, model, estimator, identification constraints, anchors,
facet orientation, extreme-score handling, and convergence criteria.
FACETS commonly uses JMLE, whereas the starter `mfrmr` workflow above
uses MML with EAP person summaries when its population-model assumptions
are suitable. Those choices target related but different calculations.

When a JMLE-oriented comparison is required, refit with `method = "JML"`
and still document every remaining setting. Matching the estimator
family alone does not establish equivalence.

For an exported FACETS fit table, use
[`read_facets_fit_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_fit_table.md)
followed by
`facets_fit_review(fit, diagnostics = res$diagnostics, facets_fit = ...)`.
This reads supplied output; it does not launch or automate FACETS.

### 7. Review the Infit pathway, including persons

The fit pathway uses Infit on the horizontal axis and measure on the
vertical axis:

``` r

plot(
  res,
  type = "fit_pathway",
  fit_stat = "Infit",
  fit_scale = "mnsq",
  include_person = TRUE,
  top_n_person = 12,
  person_labels = "none",
  facet_labels = "flagged",
  show_ci = TRUE,
  preset = "publication"
)
```

The vertical axis remains the fitted logit measure. The horizontal
reference at Infit MnSq = 1 represents model expectation; the outer
lines are review guides. Selected persons use a different point shape
from non-person facet levels. Completing this follow-up can change the
Reporting readiness row while leaving the already-passed Numerical row
unchanged.

`top_n_person` limits the displayed person layer so a large study
remains readable. The selected persons are those with the largest fit
distances; non-person rows remain available. Use `person_subset` for a
prespecified case list, or `top_n_person = Inf` only when displaying
every person serves a clear purpose.

Fit statistics are evidence for review, not automatic exclusion rules.
Investigate response patterns, design cells, score support, and
practical consequences before changing data or operational decisions.

The separate `type = "pathway"` route displays expected scores and
dominant-category regions across theta; `type = "fit_pathway"` displays
Infit or Outfit against the fitted measure.

### Set a default appearance for a session

In the development version, plots with the common `preset` controls can
share one default:

``` r

old <- options(mfrmr.plot_preset = "monochrome")
plot(fit, type = "wright")
plot(fit, type = "ccc", preset = "publication")  # Override for this plot.
options(old)  # Restore the previous session settings.
```

Choices are `"standard"`, `"publication"`, `"compact"` and
`"monochrome"`. An explicit call takes precedence over the option;
without the option the usual `"standard"` default applies. Supported
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
conversions retain the preset saved in their plot payload, even if the
option later changes. Plots with separate `palette` controls retain
their own settings. The option does not change estimates, diagnostic
cutoffs or the global ggplot theme. See
[`?mfrmr_visual_diagnostics`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
for scope and saved-plot behavior.

### Fair Scores and figures without embedded notes

[`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md)
offers observed-versus-fair (`"scatter"`), observed-minus-fair
(`"difference"`), and measure-to-score (`"measure"`) views. FairM uses
mean reference measures; FairZ uses zero reference measures. **FairZ is
an expected score, not a z-score.** These transformations do not average
predictions over the observed assignment distribution, and gaps also
reflect person mix and assignment; they do not by themselves establish
bias.

``` r

p_fair <- plot_fair_average(
  fit, diagnostics = diag, facet = "Rater", metric = "FairZ",
  plot_type = "measure", show_ci = TRUE, preset = "monochrome",
  show_title = FALSE, show_notes = FALSE, draw = FALSE
)
p_fair$data$notes
p_fair$data$plot_data
# With ggplot2 installed:
# as_ggplot(p_fair)
```

Use `draw = TRUE` for a base-R figure. The returned object retains notes
even when annotations are hidden. Wright, expected-score pathway, and
CCC plots also accept `show_title`, `show_notes`, and
`preset = "monochrome"`; see
[`help("mfrmr_visual_diagnostics")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
for the reusable-data route and display limits.

| Fair-score interval route | What is propagated | Current interpretation |
|----|----|----|
| `plot_fair_average(fit, show_ci = TRUE)` for RSM/PCM | Focal measure SE, with thresholds and reference measures fixed | Conditional diagnostic interval |
| `fair_average_table(fit_gpcm, fair_se = TRUE)` for GPCM-MML | Joint structural covariance, with Person EAP/reference means fixed; non-Person rows only | Structural diagnostic interval |

The table’s `fair_se` option does not supply RSM/PCM fair-score SEs.
Historical `SE`/`ModelBasedSE` columns describe measures, not fair
scores. Plot intervals carry `CI_Eligible = FALSE`; requested table
intervals carry `FairCIEligible = FALSE`. Neither finite limits nor a
ready fit establishes full-refit coverage. Difference-view whiskers also
hold the observed mean fixed and are not confidence intervals for the
observed-minus-fair gap.

### 8. Build a report and export the results

Start with the brief result summary:

``` r

results_summary <- summary(res, view = "brief")
results_summary$overview
results_summary$triage
results_summary$next_actions
results_summary$plot_map
```

Build a report-oriented object from the same fitted results:

``` r

report <- mfrm_report(
  res,
  style = "qc"
)

summary(report, view = "reader")
report$first_screen
report$report_index
```

[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
organizes existing evidence. It does not refit the model or turn
diagnostic thresholds into a validity decision.

Export a reader-oriented, controlled analysis archive:

``` r

exported <- export_mfrm_results(
  res,
  output_dir = "mfrmr-results",
  prefix = "analysis01",
  preset = "starter"
)

exported$summary
exported$written_files
```

The `starter` preset includes the result summary, report tables, replay
code, manifest, native Wright map, and focused plot routes. Existing
files are not overwritten unless `overwrite = TRUE` is requested
explicitly.

This preset is a controlled **analysis archive**, not a deidentified or
automatically shareable deliverable. It includes a complete `.rds`
result object, and its tables, HTML, plots, replay code, and manifest
can retain direct person identifiers, person-level estimates, original
labels, or local paths. Review and transform every file under the
study’s data-handling policy before sharing it. After making that
assessment, `acknowledge_sensitive = TRUE` can suppress the export
warning; it does not remove or pseudonymize any data.

## A practical reading order

For an ordinary MFRM analysis, review the output in this order:

1.  Confirm the data roles, score range, row retention, and model.
2.  Confirm convergence and the estimation settings.
3.  Inspect the native Wright map with uncertainty.
4.  Review targeting, facet measures, person summaries, and category
    steps.
5.  Inspect Infit/Outfit and the person-inclusive Infit pathway.
6.  Add residual, bias/DIF, linking, or interaction analyses only when
    the design and research question require them.
7.  Review report caveats before exporting or drafting substantive
    claims.

Do not reduce this sequence to a single pass/fail index. Fit, precision,
targeting, category function, fairness, and validity answer different
questions.

For other analysis goals, `mfrmr_output_guide("features")`,
`mfrmr_output_guide("imputation")` and `mfrmr_output_guide("gtheory")`
connect external-feature groups, assigned-score MI and observed-score
G/D planning to their dedicated output routes. Use their summaries,
supported [`plot()`](https://rdrr.io/r/graphics/plot.default.html)
methods and
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
then [`saveRDS()`](https://rdrr.io/r/base/readRDS.html) for the full
analysis or [`write.csv()`](https://rdrr.io/r/utils/write.table.html)
for a selected table. These analysis objects are not inputs to
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
The separate `mfrmr_output_guide("models")` describes the fitted-model
report routes, including shared-rater and testlet results.

## FACETS users

The closest translation of common FACETS concepts is:

| FACETS concept | `mfrmr` route |
|----|----|
| Data/specification roles | Explicit `person`, `facets`, and `score` arguments |
| JMLE-oriented fit | `fit_mfrm(method = "JML")` |
| MML analysis | `fit_mfrm(method = "MML")` |
| Measures and SEs | `summary(fit, profile = "facets")` and its result tables |
| Variable/Wright map | Native `renderer = "native"` or optional `renderer = "facets"` |
| Infit/Outfit review | [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md) and `type = "fit_pathway"` |
| Fair average | [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md) |
| Bias/interaction screen | [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md) and related review functions |
| Anchors | `anchors` and `group_anchors` in [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md) |
| External fit comparison | [`read_facets_fit_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/read_facets_fit_table.md) then [`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md) |

For an existing FACETS-oriented script,
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
provides a one-call wrapper around package fitting and diagnostics. For
new work, the explicit
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
workflow is easier to review and is recommended.

Use these guides for the full migration details:

- [Migrating from FACETS to mfrmr](#documentation)
- [Visual diagnostics](#documentation)

The installed `references/FACETS_manual_mapping.md` maps concepts and
output routes. It is not evidence that FACETS was executed.

## ConQuest MML comparison

`mfrmr` can prepare and review a narrow external-table comparison for an
MML latent-regression case. The supported overlap is:

- `RSM` or `PCM`;
- binary responses;
- exactly one non-person facet, treated as the item facet;
- a unidimensional latent-regression MML fit;
- one numeric person covariate in addition to the intercept;
- complete rectangular person-by-item response data.

Within that scope, comparison targets include the population regression
slope, residual variance, centered item estimates, and case-level EAP
estimates.

The handoff is explicit: mfrmr prepares the analysis files, the user
runs ConQuest separately, and mfrmr then normalizes the requested
exports.

``` r

# fit_lr must satisfy the documented overlap conditions.
bundle <- build_conquest_overlap_bundle(
  fit = fit_lr,
  output_dir = "conquest-overlap"
)

# Run the generated .cqc file in ConQuest separately, then normalize its
# parameter, regression, covariance, and case-EAP CSV files.
conquest_tables <- normalize_conquest_overlap_exports(
  bundle,
  parameter_file = "conquest-overlap/conquest_overlap_conquest_parameters.csv",
  regression_file = "conquest-overlap/conquest_overlap_conquest_reg_coefficients.csv",
  covariance_file = "conquest-overlap/conquest_overlap_conquest_covariance.csv",
  case_file = "conquest-overlap/conquest_overlap_conquest_cases_eap.csv",
  conquest_version = "5.47.5",
  conquest_edition = "demo/free",
  run_date = Sys.Date()
)

conquest_review <- review_conquest_overlap(
  bundle,
  conquest_tables
)

summary(conquest_review)
conquest_review$attention_items
```

`mfrmr` does not execute or control ConQuest, and it does not parse
arbitrary raw ConQuest reports. The user runs ConQuest separately; mfrmr
can normalize the native comparison CSV exports requested by its
generated command. The review reports coordinate-level differences; it
does not declare general software equivalence from a single dataset or
tolerance.

The generated ConQuest command uses the fitted mfrmr quadrature-point
count; the bundle records both values. Record the actual ConQuest
version, edition, and run date during normalization so the external
comparison remains reproducible.

This public bundle route does not cover multidimensional models,
arbitrary imported design matrices, `GPCM` latent regression, JML latent
regression, or the full ConQuest plausible-values workflow. Separately,
the item-only GPCM parameterization can be compared only after the
response kernel, slope grouping, threshold coordinates, latent-scale
identification, retained rows, and category map have been matched. A
result in that restricted overlap does not extend automatically to a
multifacet ConQuest generalized-item design.

The ConQuest overlap bundle is also a controlled analysis bundle. Its
long and wide response files contain person identifiers and responses;
the person-data file contains identifiers and the covariate; and both
mfrmr and ConQuest case-EAP files contain identifiers and person-level
estimates. The helper warns when writing these files and creates
`*_privacy_notice.csv`. Store the bundle in an approved restricted
location and pseudonymize or redact it as required before sharing.

## External features and exploratory groups

The [external-feature tutorial](#documentation) follows 120 fictional
raters from experience, workload, specialty, training, and certification
attributes through missingness review, multiple imputation, group
profiles, and sensitivity to feature selection, group count, weights,
and clustering method. It also groups persons and tasks separately and
joins their classifications to planned and observed ratings by ID. It
distinguishes unrecorded values from inapplicable mentoring histories
and keeps auxiliary imputation predictors separate from clustering
features.

In version 0.2.4,
[`mfrm_features()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md)
reviews a table with one row per person, rater, or task and explicitly
selected external attributes, such as experience or specialization.
[`mfrm_cluster_pam()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster.md)
groups those profiles using Gower distances and PAM; install the
optional `cluster` package to use it.

``` r

features <- mfrm_features(rater_attributes, id = "Rater",
                         features = c("ExperienceYears", "Specialty"))
summary(features)
features$missing
groups <- mfrm_cluster_pam(features, k = 3)
groups$membership
groups$profiles
plot(groups)
plot(groups, type = "profile", feature = "ExperienceYears")
```

Here `rater_attributes` is your entity-level table, with
`ExperienceYears` measured in completed years. Group count and feature
selection are substantive choices. Missing features stop clustering by
default; `missing = "omit"` explicitly selects complete cases and
retains excluded IDs with missing group membership. Optional missingness
reasons are documented in
[`?mfrm_features`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_features.md).
No value is imputed. Silhouette widths describe separation in this
sample; stability, inferential comparisons, and measurement uncertainty
are not assessed. The groups do not establish ability levels or rater
quality.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) also displays
categorical feature proportions and, for an imputed clustering result, a
co-membership heatmap. All views reuse stored results; `draw = FALSE`
returns the values for custom graphics. See
[`?plot.mfrm_clusters`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_clusters.md)
and the tutorial for examples. PAM is nonhierarchical and has no
dendrogram.

For a hierarchy, fit a separate Gower-based analysis using average
linkage (default) or complete linkage:

``` r

hierarchy <- mfrm_cluster_hierarchical(features, k = 3, linkage = "average")
plot(hierarchy)
summary(mfrm_cluster_compare(list(PAM = groups, Average = hierarchy)))
```

The dendrogram uses the stored tree; boxes mark the chosen groups.
Heights are linkage dissimilarities, not branch support. With missing
features, use an explicit omission policy or the imputation workflow
below. Set `method = "hierarchical", linkage = "average"` in
[`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_imputed.md)
to retain a tree for each completion. No pooled tree is estimated.

For meaningful numeric features, the local
[`mfrm_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_pca.md)
and
[`mfrm_cluster_kmeans()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_kmeans.md)
additions provide a Euclidean workflow. PCA summarizes variation;
k-means forms groups. Both retain the chosen scaling, weights,
missingness and IDs. A fitted PCA can be passed directly to k-means
without whitening or rescaling its retained scores:

``` r

numeric_features <- mfrm_features(rater_attributes, "Rater",
  c("ExperienceYears", "AnnualRatings", "WorkshopHours"))
pca <- mfrm_pca(numeric_features, components = 2)
numeric_groups <- mfrm_cluster_kmeans(pca, k = 3, seed = 42)
summary(pca)
plot(pca, type = "scores", groups = numeric_groups)
plot(pca, type = "loadings", components = 1)
plot(numeric_groups, type = "profile", feature = "ExperienceYears")
```

The development version also supports
`as_ggplot(pca, type = "scores", groups = numeric_groups)`, plus
`"scree"` and `"loadings"`. These conversions retain the selected
components and saved group colours and shapes. Add
`ggplot2::labs(title = NULL, subtitle = NULL)` to omit headings; use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
on the returned plot to recover the transformation and excluded IDs.
Saved hierarchies also support `as_ggplot(hierarchy)`, preserving merge
heights, leaf order and the requested group boxes. Imputation
co-membership also supports
`as_ggplot(imputed_groups, ids = selected_ids)`: it retains the
all-imputation fractions on a fixed zero-to-one scale, with crosses on
unavailable cells. Selecting IDs changes only the display.
`as_ggplot(groups)` converts saved silhouettes;
`as_ggplot(groups, type = "profile", feature = "ExperienceYears")`
converts an original-unit numeric profile. Categorical profiles use the
same call with a categorical feature, preserving unused levels and
within-group proportions. These summaries add no uncertainty intervals
or automatic quality judgments.

These three numeric columns must exist in the user’s rater table; the
tutorial provides a complete fictional example. Select component and
group counts for the question. Truncating PCA changes the distance
objective, and explained variance does not validate clusters. For
incomplete numeric attributes, use `method = "kmeans"` and an optional
`components` count in the imputation workflow below. Every completion
retains its own transformation and PCA.

For incomplete external attributes,
[`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_imputed.md)
accepts a model fitted with the optional `mice` package. Select eligible
missing cells explicitly after reviewing their reasons; structurally
undefined attributes should remain missing. The imputation model may
include auxiliary variables that are not clustering features. Choose and
review its methods, predictors, and diagnostics in `mice`; see
[`?mfrm_cluster_imputed`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_imputed.md)
for a runnable example.

The result retains every imputation’s groups, original missingness
reasons, and the fitted imputation model. Its `co_membership` matrix
reports how often each pair belongs to the same group across all
supplied imputations, independent of group numbering. A failed analysis
stops the comparison. These proportions describe sensitivity to the
imputations, conditional on the chosen model and clustering settings;
they are not membership probabilities or sampling stability. This
feature-imputation workflow does not impute rating responses. For
missing assigned scores, use the separate workflow below.

To review sensitivity to selected features, group count, weights, or
clustering method, fit the settings you want to compare and pass the
named results to
[`mfrm_cluster_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_compare.md).
The comparison reuses these results without refitting:

``` r

alternatives <- list(
  TwoGroups = mfrm_cluster_pam(features, k = 2),
  ThreeGroups = groups,
  ExperienceWeighted = mfrm_cluster_pam(features, k = 3,
    weights = c(ExperienceYears = 3, Specialty = 1))
)
comparison <- mfrm_cluster_compare(alternatives)
comparison$analysis_summary
comparison$comparisons
summary(comparison)
```

`ChangedFraction` is the fraction of entity pairs whose together/apart
status changes; `SplitPairs` and `JoinedPairs` show the direction.
`AdjustedRand` also compares the partitions while correcting for
agreement expected under random partitions with fixed group sizes. Both
measures ignore arbitrary group numbering. Inspect group sizes and
profiles alongside them. Mean silhouettes under different feature
selections or weights use different distances and do not establish the
best selection or weights.

For multiple imputations, supply a named list of
[`mfrm_cluster_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_cluster_imputed.md)
results. Selected features may differ, but entity IDs and included
entities must match; shared features must retain their values and types.
When feature selections differ, all results must retain the same fitted
`mids` object, and selected values are checked against its corresponding
completion. Changing a clustering feature selection does not change the
imputation model. See the “Compare feature selections” section of the
external-feature tutorial listed under [Documentation](#documentation)
for an example. Unmatched completions or different included entities are
refused. The summary reports descriptive means and ranges across
imputations; these are not pooled inference or sampling stability. No
setting is automatically selected.

Pairwise distances use quadratic memory. The 5,000-entity limits are
input guards, not performance or memory guarantees; multiply imputed
analyses also retain every completed result. Reuse saved results when
comparing settings.

## Missing scores on assigned ratings

The assigned-score workflow preserves the original roster and
distinguishes unassigned combinations from assigned ratings with missing
scores. Start with
[`vignette("mfrmr-response-imputation", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-response-imputation.md):
its complete example fits and reviews an ordinal imputation model,
returns each completion to the original event IDs, and estimates a rater
difference.

The following outline assumes that `ratings`, `completed`, `impute_ids`
and `model` have been constructed as in that tutorial:

``` r

review <- review_mfrm_imputations(
  ratings, completed, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", event_id = "Event", impute_ids = impute_ids, categories = 1:4,
  assigned = "Assigned", imputation_model = model
)
summary(review)                  # Original observed and imputed support
analyses <- fit_mfrm_imputed(review, model = "RSM")
summary(analyses)                # Every fit's status, errors and warnings
pooled <- pool_mfrm_imputed(analyses, facet = "Rater")
summary(pooled)
plot(pooled)
```

Supply at least two completed data frames with their retained model, or
a long-format `mids` object. Only the selected missing assigned scores
may change. The analysis uses a common category ladder and
fixed-standard-normal RSM/PCM MML scale; every fit must qualify before
pooling. For a rater difference, supply a named contrast matrix to
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md).
Its variance includes covariance between rater estimates,
within-imputation uncertainty and between-imputation variation.
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) retains the whole
review and analysis.

In the development version, `as_ggplot(pooled, title = NULL)` reuses the
stored pointwise t intervals and their target order.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains contrasts, degrees of freedom, settings and information
cautions; it does not recalculate intervals from standard errors or
infer a new confidence level.

Choose a proper imputation model that reflects score categories,
dependence and nonresponse predictors. Passing these checks does not
establish MAR or imputation-model compatibility. The resulting intervals
are pointwise and model-based, with a large-sample complete-data
reference by default; they are not robust or generally
coverage-guaranteed. Person EAPs and posterior SDs cannot be pooled by
this function. Unassigned cells remain unassigned.

## Multivariate G-theory

For a first runnable example, start with the bundled two-score data
under [Common tasks and crossed
facets](#common-tasks-and-crossed-facets). It follows the question of
adding tasks through data import, G-study estimation, D-study tables,
plots and interpretation. Use the design table below to check whether
that model matches your assessment before adapting the example.

Choose the G-study model before comparing designs. The existing
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
/
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
route fits main effects and uses an explicit assumption to scale its
combined residual. The
[`mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_gstudy.md)
/
[`mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_study.md)
route estimates the supported interaction covariance components
separately; it also accepts a **single score**, so its use is not
restricted to composites. Neither route automatically infers the
intended measurement design from column names.

When an assessment reports several score components, such as content and
organization, their covariances matter for the dependability of a
composite. In version 0.2.4,
[`mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_gstudy.md)
estimates those covariances for one or two common random measurement
facets. The default ANOVA method requires a complete balanced design;
`method = "minque0"` also handles incomplete configurations and unequal
nested child counts. Each retained cell has one row with all selected
numeric scores observed. Included facet identifiers must denote the same
conditions across scores and persons, and represent the random
conditions over which scores will be generalized. Score components are
fixed parts of the assessment.

Choose the facets explicitly:

| Measurement design | G-study arguments | D-study count columns |
|----|----|----|
| Persons and common tasks | `rater = NULL` | `Tasks` |
| Persons and common raters | `task = NULL` | `Raters` |
| The same fixed tasks, each scored by common raters | One score column per fixed task; `task = NULL` | `Raters`; keep the task set fixed |
| Persons, common raters, and common tasks | Defaults | `Raters`, `Tasks` |
| Persons and tasks with a different rater team for each task | `nesting = c(Rater = "Task")` | `Raters` **per task**, `Tasks` |
| One or two other common random facets | `facets = c(Rater = "Assessor", Occasion = "Session")` | Exact labels: `Rater`, `Occasion` |

In `facets`, values select data columns and names label the analysis. Do
not combine it with `rater`/`task`. Labels carry through component
matrices, count tables, and plots. For example, with `repeat_ratings`
containing `Person`, `Assessor`, `Session`, `Content`, and
`Organization`:

``` r

g_repeat <- mfrm_multivariate_gstudy(repeat_ratings,
  scores = c("Content", "Organization"),
  facets = c(Rater = "Assessor", Occasion = "Session"))
d_repeat <- mfrm_multivariate_d_study(g_repeat,
  expand.grid(Rater = c(1, 2), Occasion = c(2, 4)),
  weights = c(Content = 0.6, Organization = 0.4))
summary(d_repeat)
plot(d_repeat, x_var = "Occasion", type = "sem")
```

Here the question is whether additional occasions reduce error while
rater counts are held constant within each line. Occasions must be
defensibly treated as exchangeable random conditions; this specification
does not estimate learning, growth, a time trend, or serial correlation.
All included facets are random; the default model is crossed. Fixed
facets and three or more measurement facets are not accepted as model
factors. The fixed-score representation below addresses a narrower
fixed-task question.

### The same fixed tasks with more raters

An oral assessment uses an interview, a presentation and a discussion.
Its question is: **would using more raters improve the dependability of
the weighted score on these same three tasks?** The task set and weights
define the score; they are not a sample of tasks to be replaced. Put
each fixed task in its own score column, with one row per Person/Rater.
The same rater must denote the same individual across all three columns
and persons. Different rater teams for each task do not satisfy this
representation.

The following fictional continuous scores illustrate the arrangement.
They are not ordinal MFRM estimates or evidence about a real assessment.

``` r

set.seed(923)
fixed_tasks <- expand.grid(Person = paste0("P", 1:60), Rater = paste0("R", 1:8),
                           stringsAsFactors = FALSE)
task_names <- c("Interview", "Presentation", "Discussion")
p <- match(fixed_tasks$Person, unique(fixed_tasks$Person))
r <- match(fixed_tasks$Rater, unique(fixed_tasks$Rater))
person_common <- rnorm(60, sd = 1.8)
rater_common <- rnorm(8, sd = 0.6)
for (nm in task_names) {
  fixed_tasks[[nm]] <- 12 + person_common[p] + rnorm(60, sd = 0.8)[p] +
    rater_common[r] + rnorm(8, sd = 0.5)[r] + rnorm(nrow(fixed_tasks))
}
g_fixed <- mfrm_multivariate_gstudy(fixed_tasks, scores = task_names,
                                   task = NULL)
g_fixed$component_diagnostics
w <- c(Interview = 0.5, Presentation = 0.3, Discussion = 0.2)
rater_plans <- data.frame(Raters = c(1, 2, 4))
d_fixed <- mfrm_multivariate_d_study(g_fixed, rater_plans, weights = w)
subset(summary(d_fixed), Kind == "Composite",
       select = c(Raters, G, Phi, RelativeSEM, AbsoluteSEM, Status, ComponentPSD))
plot(d_fixed, x_var = "Raters")
plot(d_fixed, x_var = "Raters", type = "sem")
```

Each planned rater scores all three fixed tasks. Two raters therefore
require six task ratings per person, and four require twelve; the number
of tasks does not change. G describes relative ranking and Phi
absolute-score dependability, with SEMs in weighted-score units. These
are point projections, not confidence intervals or demonstrated
improvements from a new study. Inspect component and metric status even
when coefficients are available.

The Person covariance includes stable differences among persons on the
fixed tasks. For weights `w`, universe variance is `w' P w`,
relative-error variance is `w' E w / n_r`, and absolute-error variance
is `w' (R + E) w / n_r`. Task-specific rater behavior and residual
covariances enter through the component matrices. Do not average the
three separate G coefficients or divide their errors by three again. A
direct weighted-score analysis gives the same composite result:

``` r

fixed_tasks$WeightedScore <- drop(as.matrix(fixed_tasks[task_names]) %*% w)
g_direct <- mfrm_multivariate_gstudy(fixed_tasks, "WeightedScore", task = NULL)
d_direct <- mfrm_multivariate_d_study(g_direct, rater_plans)
metrics <- c("UniverseVariance", "RelativeErrorVariance", "AbsoluteErrorVariance",
             "G", "Phi", "RelativeSEM", "AbsoluteSEM")
stopifnot(isTRUE(all.equal(
  as.matrix(subset(summary(d_fixed), Kind == "Composite")[metrics]),
  as.matrix(summary(d_direct)[metrics]), check.attributes = FALSE)))
```

For an incomplete source, `method = "minque0"` requires identifiable
covariance components. A retained Person/Rater row must have every task
score: `missing = "omit"` excludes the entire incomplete vector, not
just one task’s value. Keep the assignment roster to distinguish
nonassignment from missing assigned scores; do not fill unassigned task
scores to create this table. The D-study still describes a future
complete design using common raters across all fixed tasks. It does not
estimate reliability of the observed sparse roster.

Changing the weights changes the specified composite; sampling new tasks
is a different question requiring a random-task model. A fixed task
count in a random-task D-study is not equivalent to treating these
particular tasks as fixed. This example uses the existing multivariate
score model, not a general fixed/random-facet formula interface. See the
“Fixed tasks as score components” section in
[`?mfrm_multivariate_gstudy`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_gstudy.md).

### Different rater teams for different tasks

Suppose each task has its own raters, and each team rates the same
examinees on Content and Organization. Specify
`nesting = c(Rater = "Task")` to estimate five components: Person, Task,
Rater(Task), Person:Task, and the combined
Person-by-Rater-within-Task/residual component. A local label R1 on Task
1 identifies a different rater from R1 on Task 2. If the same physical
rater works on both tasks, this independent nested-rater model does not
describe that arrangement; relabeling the rater cannot make it so.

With `nested_ratings` containing one row per observed Person/Task/Rater
and both score columns:

``` r

g_nested <- mfrm_multivariate_gstudy(nested_ratings,
  scores = c("Content", "Organization"), nesting = c(Rater = "Task"))
g_nested$design$child_counts # Raters within each observed task.
g_nested$component_diagnostics
d_nested <- mfrm_multivariate_d_study(g_nested,
  expand.grid(Raters = c(2, 3), Tasks = c(4, 6)),
  weights = c(Content = 0.6, Organization = 0.4))
summary(d_nested)
plot(d_nested, x_var = "Raters") # Horizontal axis: raters per task.
plot(d_nested, x_var = "Tasks", type = "sem")
```

Here two raters for each of six tasks requires **twelve distinct
raters** and twelve ratings per examinee. Increasing `Raters` adds
raters within each task; increasing `Tasks` samples more tasks with
their own teams. Read the G/Phi and SEM projections together with their
status and component diagnostics. They are point estimates; the
plan-comparison interval method currently requires crossed facets and
cannot be used for this nested model.

ANOVA requires complete observations and equal numbers of raters per
task. Use `method = "minque0"` for incomplete observations or unequal
team sizes when the observed design separates the five components. An
explicit future grid is then required; it describes a complete design
with equal team sizes, not reliability of the observed sparse roster.
Nesting within examinees, partly shared raters and score-specific rater
identities are unsupported. See
[`?mfrm_multivariate_gstudy`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_gstudy.md)
for a runnable synthetic nested-score example.

### Common tasks and crossed facets

For a design without a rater facet, set `rater = NULL` explicitly. This
example uses the published synthetic data from Brennan’s *Manual for
mGENOVA*, Table 12: ten persons, six common items (named `Task` here),
and scores V and W.

``` r

tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
g_task <- mfrm_multivariate_gstudy(tasks, c("V", "W"), rater = NULL)
d_task <- mfrm_multivariate_d_study(g_task,
  design_grid = data.frame(Tasks = c(6, 12)), weights = c(V = -1, W = 1))
summary(d_task)
plot(d_task) # G and Phi for W minus V, identified by the title and weights.
plot(d_task, type = "sem") # Error in difference-score units.
plot(d_task, score = "V") # An original score, shown separately.
if (requireNamespace("ggplot2", quietly = TRUE)) {
  p <- as_ggplot(d_task, type = "sem")
  print(p)
  # ggplot2::ggsave("d-study-sem.png", p, width = 7, height = 7, dpi = 300)
}
```

At six tasks the difference W minus V has G = 0.30000 and Phi = 0.24116,
matching the manual’s Appendix E. Person, Task, and the combined
Person-by-Task/residual covariance matrices are estimated from the
scores. The D-study varies task counts; it cannot project new raters
from this model. No scores are averaged automatically when omitting the
rater facet.

The planning question is whether adding common tasks would improve the
dependability of the difference score. Under the estimated components,
doubling tasks from six to twelve raises G from 0.300 to 0.462. This is
a projection, not evidence from twelve observed tasks. G concerns
relative ordering; Phi also includes shifts in absolute score levels.
Larger values mean greater dependability under the model. SEM expresses
error in score units, where smaller is better; it is not a confidence
interval for G or Phi. Neither coefficient gives pass/fail
classification accuracy, and no universal acceptable threshold or
optimal design is selected.

With `ratings` containing `Person`, `Rater`, `Task`, `Content`, and
`Organization` columns:

``` r

g <- mfrm_multivariate_gstudy(ratings, scores = c("Content", "Organization"))
g$component_diagnostics
g$components$Person
d <- mfrm_multivariate_d_study(g,
  design_grid = data.frame(Raters = c(2, 4), Tasks = c(3, 3)),
  weights = c(Content = 0.6, Organization = 0.4))
summary(d)
plot(d) # Rater counts on the horizontal axis because tasks are held at three.

# To vary both counts, request all combinations explicitly.
d_grid <- mfrm_multivariate_d_study(g,
  expand.grid(Raters = c(2, 4), Tasks = c(3, 6, 9)),
  weights = c(Content = 0.6, Organization = 0.4))
plot(d_grid, x_var = "Tasks") # Each line holds the rater count constant.
```

Plots select a sole composite by default, or the first score when no
weights are supplied; `score = "Content"` selects an original score.
Points show requested scenarios and lines only guide comparisons.
Inspect exact values with `summary(d_grid)` or
`plot_data(plot(d_grid, draw = FALSE))`. Unavailable estimates are
explained and retained in the plot payload rather than shown as zero.
See
[`?mfrm_multivariate_d_study`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_study.md)
and
[`?plot.mfrm_multivariate_d_study`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_multivariate_d_study.md)
for the complete workflow and how to read it.

To compare feasible plans with twelve ratings per person, reuse the same
G-study and score weights:

``` r

plans <- data.frame(Raters = c(2, 3, 4), Tasks = c(6, 4, 3))
d_plans <- mfrm_multivariate_d_study(g, plans,
  weights = c(Content = 0.6, Organization = 0.4))
plan_results <- subset(summary(d_plans), Kind == "Composite")
plan_results$RatingsPerPerson <- with(plan_results, Raters * Tasks)
plan_results[c("Raters", "Tasks", "RatingsPerPerson", "G", "Phi", "GStatus", "PhiStatus")]
```

Twelve ratings do not mean equal examinee burden: six tasks scored by
two raters require twice as many performances as three tasks scored by
four raters. Consider task duration, rater workload and other costs
separately. Choose the metric from the intended decision, then compare
the size of the projected differences. The largest point estimate does
not establish a reliably better plan, and a rank change can have a small
practical effect. Component-estimation uncertainty is not included in
these comparisons; SEM is measurement error, not uncertainty in the
comparison itself. If a candidate’s metric is unavailable, selecting
among the remaining values does not settle the comparison of all plans.

For plans specified before inspecting their estimates, the
two-crossed-facet workflow also provides approximate intervals for their
differences. Use this method only when independent normal random effects
are a defensible model for the persons and both facets; the function
does not test that assumption:

``` r

comparison <- mfrm_multivariate_d_compare(d_plans, reference = 1,
  assumption = "normal")
summary(comparison) # Every plan minus row 1: two raters and six tasks.
plot(comparison) # Positive G/Phi differences favor the comparison plan.
plot(comparison, type = "sem") # Negative SEM differences favor it.
plot_data(plot(comparison, draw = FALSE))$table # Exact points and intervals.
```

The calculation preserves dependence between plans estimated from the
same data. `SE` describes sampling uncertainty in the difference; it is
not SEM. An interval containing zero does not establish equivalence.
Intervals are pointwise, not simultaneous guarantees for all plans or a
plan selected after examining the results. This approximation is
sensitive to nonnormal effects, small facet pools and uneven
assignments; it is not a robust missing-data correction. One-facet and
nested-design intervals are not yet provided. A point can remain
available when its interval is unavailable; inspect `Status`. See
[`?mfrm_multivariate_d_compare`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md)
for assumptions and a complete example.

To compare several ways of combining the scores, give `weights` a
matrix: rows name the original scores and columns name the choices. For
example, compare an equally weighted total, a content-focused total, and
the difference between Content and Organization under the same planned
assessment designs:

``` r

weight_choices <- cbind(
  Equal = c(Content = 0.5, Organization = 0.5),
  ContentFocus = c(Content = 0.8, Organization = 0.2),
  Difference = c(Content = 1, Organization = -1))
d_choices <- mfrm_multivariate_d_study(g,
  expand.grid(Raters = c(2, 4), Tasks = c(3, 6, 9)),
  weights = weight_choices)
summary(d_choices) # Original scores and all three composites for every design.
plot(d_choices, composite = "ContentFocus", x_var = "Tasks")
plot(d_choices, composite = "Difference", type = "sem")
if (requireNamespace("ggplot2", quietly = TRUE)) {
  print(as_ggplot(d_choices, composite = "Equal"))
}
```

[`summary()`](https://rdrr.io/r/base/summary.html) identifies original
scores and composites with `Kind` and their names with `Score`. Each
composite uses the same estimated covariance components, without
refitting the G-study. With several composites, plots require
`composite` or `score` to identify what to show. Rows of the weight
matrix are matched by score name; weights are never normalized
automatically. Changing weights may change what the assessment measures:
a higher G or Phi alone does not justify adopting a different total.
Differences describe a different target from totals, and SEM comparisons
require comparable score scales. Select weights for the intended use
before interpreting dependability.

With both rater and task facets, the G-study includes Person-by-Rater,
Person-by-Task, and Rater-by-Task components. The three-way interaction
and within-cell error remain combined because each cell has one
observation. The D-study projects mean scores over the specified raters
and tasks. It uses the full covariance matrices to report relative G,
absolute Phi, and their corresponding error SEMs; it does not average
separate reliability coefficients. Weights are used as supplied.
Omitting `weights` reports the score components without creating a
composite. See
[`?mfrm_multivariate_gstudy`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_gstudy.md)
for a runnable fictional continuous-score example.

Signed weights also allow difference scores. For example,
`mfrm_multivariate_d_study(g, weights = c(Content = 1, Organization = -1))`
projects the dependability of Content minus Organization. Subtraction
must be meaningful on the supplied score scales. The same weights define
the universe-score target and its observed mean-score estimate; distinct
target and estimation weights are not supported.

For incomplete crossed data, explicitly select `method = "minque0"`. It
estimates covariance components from observed overlaps, without
constructing the full assignment grid. The identity-working-covariance
MINQUE method uses a common mean per score and common covariance
components across the sample ([Rao,
1971](https://doi.org/10.1016/0047-259X(71)90001-7)). It does not fit a
selection model or covariate-dependent means.

``` r

# Thin the example to illustrate an incomplete assignment roster.
sparse <- tasks[(tasks$Person + tasks$Task) %% 3 != 0, ]
sparse$V[1] <- NA_real_ # Additionally, one assigned score was not recorded.
g_sparse <- mfrm_multivariate_gstudy(sparse, c("V", "W"), rater = NULL,
  method = "minque0", missing = "omit")
g_sparse$data_usage
g_sparse$estimation$component_support
g_sparse$component_diagnostics
d_sparse <- mfrm_multivariate_d_study(g_sparse,
  data.frame(Tasks = c(6, 12)), weights = c(V = -1, W = 1))
summary(d_sparse)
```

Unassigned cells need no invented score. Missing assigned scores are a
different issue: omission removes the whole row for all selected scores
and records its input position. It can lose information and introduce
bias. Neither sparse estimation nor labeling missingness MAR corrects
selective assignment, nonresponse, or omitted predictors. Preserve the
original roster and review coverage with
`describe_mfrm_data(..., expected_design = ...)`. The G-study’s
`observed_fraction` concerns retained level combinations, not completion
of planned assignments or entirely unobserved entities.

Connectedness alone does not guarantee separable variance components.
For example, with just one rater per Person/Task cell, Person-by-Task
interaction and residual error cannot both be estimated by this model.
MINQUE stops when its scaled moment equations cannot separate the
requested components. Passing this check does not guarantee useful
precision. The thinned example also illustrates that a difference score
can have negative estimated universe variance while the original scores
still have calculable G/Phi. Its explicit D-study grid describes a
**future complete crossed design**; it does not describe the
dependability of the observed sparse roster or person-specific
assignment patterns.

Review an incomplete design in this order:

| Question | What to inspect | What the result can tell you |
|----|----|----|
| Were planned ratings actually recorded? | The planned roster, `describe_mfrm_data(..., expected_design = ...)`, and `g_sparse$data_usage` | Unassigned cells and missing assigned scores are different. Omission counts do not identify the cause of missingness. |
| Can this arrangement separate the components? | The estimation error or `g_sparse$estimation`, including component replication | A full-rank moment system permits calculation. A small condition number is not an estimate of statistical precision. |
| Are the estimated covariance matrices admissible? | `g_sparse$component_diagnostics` and D-study `ComponentPSD` | Non-PSD components flag a need for review. This diagnostic is separate from whether each requested coefficient can be calculated. |
| Which requested metrics can be calculated? | `GStatus`, `PhiStatus`, `RelativeSEMStatus`, `AbsoluteSEMStatus` | Each metric uses its own projected variances. An unavailable Phi does not automatically withhold G. Calculability does not establish model fit or precision. |
| How uncertain is a prespecified improvement between plans? | [`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md) for two common crossed facets under normal random effects, plus evidence for the source design and population | Approximate paired intervals preserve dependence between plans. They do not establish robustness to nonnormality, selective missingness or post-selection inference. |

The arrangement matters even at the same workload. With 120 persons,
rating four tasks with two distinct raters per performance and rating
eight tasks with one rater per performance both require 960 ratings.
Only the former supplies repeated ratings within a Person/Task cell; the
latter cannot separate Person-by-Task variation from residual variation
in the seven-component model. Other overlaps are still needed to
separate the remaining components. Do not interpret a rating count,
percentage of observed cells, or connected graph as a universal adequacy
threshold.

Allocation and missingness affect precision, even when coefficients can
be calculated. A limited Gaussian simulation used two scores, 120
persons, 12 raters and eight task levels, with 1,000 replications per
condition. At the same 960-rating workload, rotating rater pairs gave
equal-composite G RMSE 0.050, compared with 0.066 for a repeated pair
per person. Omitting Content scores on 25% of rating rows, then using
common complete rows for both scores, gave mean G of 0.766 under random
omission and 0.684 when the highest Content scores were omitted, against
a true value of 0.767. G was calculable in every replication of these
conditions. These results concern one specified model; they illustrate
why successful calculation cannot establish precision or correct
selective missingness, rather than identify an optimal allocation.

Small or zero true components can produce non-PSD estimates through
sampling variation under a correct model. Rater-by-Task variation
contributes to absolute error, but not relative error, so a problem in
that component need not prevent calculation of G. Review each requested
metric and the component diagnostics separately; non-PSD frequency is
not a model-fit test or a coefficient-calculation failure rate.

The number of distinct raters or tasks observed in the G-study affects
component estimation. It differs from the number each person would
receive in a future D-study scenario. At a fixed rating budget,
expanding the pool also reduces ratings per level; there is no universal
minimum pool size or automatically preferred design established by these
checks.

Negative or indefinite component estimates remain visible. **D-study
output is judged separately for every score/composite and metric.** G
requires nonnegative universe and relative-error variances with a
positive sum; Phi uses absolute-error variance instead. Each SEM
requires only its corresponding nonnegative error variance. Zero
universe variance gives zero G/Phi when the corresponding error variance
is positive; zero total variance leaves the coefficient undefined. No
negative estimates are automatically replaced.

`Status` summarizes a row as `Available`, `Partially available`, or
`Unavailable`; the four metric-specific status columns give the reasons.
`ComponentPSD` separately reports whether all component matrices pass
their numerical check. Print and plot methods note non-PSD estimates
even when the requested metrics are calculable. Recalculate a previously
saved D-study from its G-study to apply these rules; plotting does not
change stored values. Raw estimates can also yield Phi greater than G
when estimated absolute error is below relative error. This calls for
review of component estimates; the model’s additional absolute-error
contributions are nonnegative, so a reversal is not evidence that
absolute decisions are more dependable. Passing a matrix check does not
establish precise estimation or model fit, and failing it does not prove
that the data or model are wrong. Distinguish the number of separable
components (`estimation$rank`) from the rank of each between-score
covariance matrix (`component_diagnostics$Rank`): a true zero component
can have matrix rank zero without being confounded with another
component. These are observed-score point projections conditional on
estimated components. The separate two-facet comparison method provides
approximate normal-theory intervals for prespecified differences with
crossed facets. Numeric category scores do not yield latent ordinal or
MFRM reliability. Agreement with a published numerical example does not
establish recovery under missingness or ordinal latent models. Nesting
other than the stated Person-by-(Child-within-Parent) model, partial
sharing across score components, score-specific missing-data estimation,
and score imputation are not supported. The existing main-effects
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
workflow remains separate.

When comparing results with GENOVA programs, check the estimator and the
negative-component convention. mfrmr retains raw component estimates.
mGENOVA 2.1 instead replaces negative variance components with zero for
its D-study unless `DOPTIONS NEGATIVE` is specified. This concerns
variances, not all negative covariances, and is not a general PSD
repair. jGENOVA’s `NEGATIVE` option controls printing: its D-study
zeroes negative variances under both `ALGORITHM` and the default `EMS`
convention; `EMS` also recalculates other components using those zero
replacements. See the [jGENOVA
manual](https://brennancrickgenova.org/genova-suite/) for these options.
Zeroing components before forming a multivariate composite can also
differ from zeroing components estimated from a single summed score.

Matched examples confirm the calculations under these respective
conventions. They check specific formulas and explain output
differences; agreement does not establish suitability for an assessment,
sampling precision, or correction for selective missingness. Choose the
score meaning, model and assumptions from the assessment question rather
than from agreement with another program.

## ICC inputs and intervals

[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
preserves numeric character/factor score labels. Missing scores or
selected grouping values stop the analysis by default; choose
`missing = "omit"` explicitly to use complete rows. Invalid score labels
and infinite values must be corrected. Inspect the input, used, and
excluded row counts and `attr(icc, "data_usage")` for excluded positions
and missing columns.
[`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md)
uses the observation and grouping-level counts retained in that ICC
result. Rerun older ICC results before calculating design effects.
Omission does not impute scores or correct missing-data bias.

ICC variance shares are not screened against a fixed variance cutoff
tied to score units. Returned variances retain their numerical
precision. Constant scores yield unavailable variances and ICCs,
including in bootstrap refits. Rerun earlier results to obtain these
corrections.

Design effects use a per-facet average-cluster-size approximation.
`EffectiveN` is a descriptive equivalent row count, not a count of
independent Persons or a precision estimate for the full design. Unequal
cluster sizes, crossed or nested dependencies, sampling weights, and
finite-population corrections are not represented. Use a
design-appropriate estimator and variance calculation for standard
errors or sample-size planning; see
[`?compute_facet_design_effect`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md).

[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
reports observed-score variance shares from a Gaussian random-intercept
model. Request parametric percentile intervals with `ci_method = "boot"`
and a recorded `ci_boot_seed`. Read `ICC_CI_Status`, the
requested/available replicate counts, and `attr(icc, "icc_ci")` before
reporting them. Failed or nonconverged refits and fit warnings withhold
intervals. Converged zero-variance components remain in the bootstrap
distribution; coverage can be unreliable at such boundaries or with few
grouping levels. The bootstrap does not correct missing-data bias.

The former `"profile"` method transformed separate variance-component
bounds and did not calculate a profile-likelihood interval for the ICC
ratio. It is now refused. Rerun saved ICC interval analyses from their
original data and settings; reprinting old results cannot fix their
intervals or recover omitted bootstrap diagnostics. See
[`help("compute_facet_icc")`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
for details.

## Model scope

GPCM uses one substantive ability dimension and assigns relative
discriminations to one selected facet. MML allows a different facet to
own category steps; JML requires the same owner. Its model structure and
the availability of intervals, comparisons and downstream workflows are
described separately. Unsupported combinations and inference states are
reported explicitly.

The package extends Rasch-family RSM/PCM work with MML, modern
diagnostics, reproducibility, network review, and reporting support. It
is not a general FACETS replacement: each
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
call uses one response-model family and one observed score scale, and
the current public API does not provide mixed response families,
multiple independent rating scales, general threshold anchoring, or
online calibration updates. Portable fixed-calibration artifacts are
available only for one-scale `RSM`/`PCM` `MML` fits under the fixed
standard-normal scoring basis. Posterior scoring from an existing fitted
object is a separate, wider analysis route.

## Portable fixed calibration

An eligible `RSM` or `PCM` `MML` fit can be converted into a versioned
calibration artifact, validated, frozen, saved, and applied to new
Persons without retaining the source fit or training responses:

The following template assumes an eligible `fit`, its original
`training_data`, and `new_responses` with matching facet labels and
score coding. The portable calibration vignette below supplies a
complete example defining these objects.

``` r

q_review <- mml_quadrature_sensitivity(
  fit, training_data, quad_points = c(31, 61)
)
summary(q_review) # You decide whether the observed movement is acceptable.
fit_for_calibration <- q_review$fits$q61

draft <- extract_mfrm_calibration(
  fit_for_calibration, quadrature_review = q_review
)
review_mfrm_calibration(draft)

validated <- validate_mfrm_calibration(draft)
calibration <- freeze_mfrm_calibration(validated)
save_mfrm_calibration(calibration, "reviewed-calibration.rds")

# This can run in a new R session.
calibration <- load_mfrm_calibration("reviewed-calibration.rds")
scores <- score_mfrm_calibration(calibration, new_responses)
summary(scores)
plot(scores, type = "interval", preset = "publication")
```

Use
[`mfrm_calibration_capabilities()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_capabilities.md)
for the exact portable support envelope, and see
[`vignette("mfrmr-portable-calibration")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-portable-calibration.md)
for a complete synthetic example. See
[`help("mfrm_calibration_methods", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_methods.md)
for the artifact summaries and
[`help("mfrm_calibration_score_methods", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_score_methods.md)
for score summaries and plots. Estimated-population and
latent-regression MML, JML, and GPCM remain fitted-object-only routes;
they do not create portable calibration artifacts in 0.2.4. Artifact
scores are posterior EAP values conditional on the frozen point
calibration and recorded prior. Their intervals exclude
calibration-parameter uncertainty, and loading validates consistency
rather than authenticating files from untrusted sources. Review every
`scored_review` or `not_scored` disposition before using estimates. The
score plot is a batch-review display, not evidence that the source
calibration fits or transports to a new population.

Score tables and summaries retain the scoring algorithm and requested
interval level for CSV export. Printed scores and interval plots
identify saved grid-based intervals, whose posterior mass may differ
from the requested level.

## Model and interpretation boundaries

| Area | Supported route | Important boundary |
|----|----|----|
| Latent structure | One latent dimension | No multidimensional or Q-matrix engine |
| Facets | Multiple observed facet roles | The design must remain connected for the intended contrasts |
| `RSM` | Shared step structure | The common rating-scale assumption must be substantively defensible |
| `PCM` | Step structure associated with `step_facet` | Specify the step facet explicitly when the default is not intended |
| `GPCM` | One slope family; MML permits separate slope/step owners and estimates the common scale by default | Not an unrestricted many-facet GPCM implementation |
| Estimation | `MML` and `JML`/`JMLE` | Estimator choice changes person summaries and residual-fit basis |
| Latent regression | Conditional-normal, unidimensional MML population model | Person scoring requires explicit exploratory review and omits uncertainty in the fitted population parameters |
| Diagnostics | Residual and posterior-averaged marginal screens | A flag is not a deletion, fairness, or validity decision; missing results remain unavailable |
| Residual group comparisons | Differences in observed-minus-expected scores | No residual SEs, p-values, confidence intervals or differential-functioning classifications |
| G/D studies | Observed-score main-effects variance decomposition and design projections | No MFRM latent-scale reliability, full interaction decomposition or cut-score accuracy estimate; variance-estimation uncertainty is omitted |
| Shrinkage | Post-fit adjustment toward zero | Original estimates and predictions are unchanged; descriptive bands omit prior-variance uncertainty and cross-level covariance |
| External imports | Source-scale displays for supported mirt, TAM and eRm fits | No native response-level diagnostics or portable calibration; missing joint covariance is not reconstructed |
| FACETS and ConQuest | Exported-table review within documented overlap | Neither external program is executed by `mfrmr` |

Fitted-object Person scoring is separate from calibration estimation. It
returns posterior EAP under a stated normal prior, including a
standard-normal reference prior when the calibration was fitted by JML.
Scores, posterior SDs and intervals hold calibration and prior
parameters fixed. Estimated-population scoring requires
`readiness_policy = "review"`; posterior draws alone do not justify
downstream regression or group inference without a compatible
conditioning model and sampling design. See
[`?predict_mfrm_units`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
and
[`?sample_mfrm_plausible_values`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md).

For `GPCM`, inspect the capability table before choosing a downstream
helper:

``` r

gpcm_capability_matrix()
vignette("mfrmr-gpcm-scope", package = "mfrmr")
```

GPCM output has separate eligibility checks. Use
`confint(fit, parm = "slopes")` for approximate pointwise MML
relative-slope intervals. The same 95% calculation is in
`diagnose_mfrm(fit)$parameter_uncertainty$slopes`; read `CIEligible` and
`InferenceReview`. It uses the inverse joint observed information and
log-slope transformation after checking the current solution. Singular,
regularized, nonconverged, coarse-grid or non-unit-weight fits do not
receive ordinary bounds. Global `InferenceReady` is not promoted: slope
intervals do not establish a global maximum or authorize other parameter
families. These intervals are model-based approximations, not universal
coverage guarantees.

Use `scale = "standardized"` to include uncertainty in population-SD
times slope; with covariates this is the residual population SD. Named
`contrasts` compare slopes by ratio or difference. Request
`method = "sandwich"` for Person-level or specified independent-cluster
covariance, and `simultaneous = "bonferroni"` for the finite family in
that call. Sandwich covariance does not correct biased estimates or
dependence between clusters.
`bootstrap_mfrm_gpcm(fit, nsim = 499, seed = 92401)` supplies a
fitted-model bootstrap alternative, with failed refits retained.
Supplying `null_fit` instead performs a matched PCM/GPCM bootstrap LRT.
[`mfrm_curve_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md)
adds intervals and customizable plots to category probabilities or
per-rating information at known ability values. See the GPCM tutorial
for worked choices; these methods have different targets and
assumptions. Probability-curve intervals showed undercoverage in a small
incomplete-design check, including Bonferroni-adjusted families.
Numerical availability is not a coverage certification, and neither
sandwich covariance nor a bootstrap option automatically resolves that
limitation.

For MML, the default `gpcm_mml_identification = "free_population"`
estimates an intercept-only population distribution while relative
slopes satisfy a geometric-mean-one constraint. The corresponding
fixed-latent-SD optimizer coordinate is retained in
`FixedLatentSDOptimizerEstimate`. Use
`gpcm_mml_identification = "fixed_standard_normal"` only when a
deliberately matched legacy or external comparison requires that
identification.

The GPCM estimates **relative discriminations for one selected facet**;
under MML, another facet may own the category steps:

``` math
\log\frac{P(Y_o=k)}{P(Y_o=k-1)}
 = \alpha_{g(o)}\{\eta_o-\tau_{h(o),k}\},
\qquad \prod_g\alpha_g=1.
```

Here `g` is the slope owner and `h` the step owner. MML permits, for
example, `step_facet = "Rater", slope_facet = "Criterion"`; JML requires
the same owner. This separates rater category use from criterion
discrimination within the specified model. It does not estimate two
slope families or prove a rater habit. Setting all slopes to one
recovers the equal-discrimination PCM kernel. This is narrower than the
generalized MFRM of [Uto and Ueno
(2020)](https://doi.org/10.1007/s41237-020-00115-7), whose task and
rater slopes enter multiplicatively as `alpha_i * alpha_r` and whose
step owner is stated separately. The current criterion-owned and
rater-owned fits are therefore separate restricted many-facet GPCM
strata, not interchangeable fits of the full Uto–Ueno model.

The selected facet receives one slope per level, not one common slope
for the whole fit. For example, `slope_facet = "Criterion"` estimates a
relative slope for every criterion; `slope_facet = "Rater"` estimates
one for every rater. The other facets retain additive location effects
but no slope block. Those effects are still inside the complete
adjacent-category predictor multiplied by the selected slope; the
current kernel is not a loading-only model with unscaled facet
intercepts. Criterion and rater slopes cannot be estimated
simultaneously in this model.

`plot(fit_gpcm, type = "ccc")` and `category_curves_report(fit_gpcm)`
retain the estimated slope for each step-facet level. These are
reference-profile curves, however: additive facet main effects and
fitted interactions are fixed at zero. The native plot facets multiple
curve groups instead of overlaying unlabelled traces, and both native
and ggplot displays state the reference profile condition. Inspect
`CurveBasis`, `PredictorOffset`, and `settings$curve_basis` before
interpreting a curve as if it represented a particular observed
Person-by-facet cell.

`fit_mfrm(method = "JML")` uses the observed scores without
extreme-score adjustment or finite-item bias correction. Freely
estimated Persons with all-minimum or all-maximum responses have primary
estimates of `-Inf` or `Inf`; their finite optimizer values are
computational traces. Fixed anchors retain their supplied values, while
coupled constraints require separate review. JML SEs and normal bands
remain exploratory.

`fair_average_table(..., xtreme = 0.25)` can produce a finite displayed
`Measure` without refitting. Its `PrimaryMeasure` retains the original
fitted value, and `MeasureBasis` and `ExtremeAdjustment` identify the
replacement. The original SE does not describe that replacement, so
measure SEs are unavailable on adjusted rows. Fair-score calculations do
not use this replacement. When a JML Person measure is infinite,
non-Person FairM is unavailable because its mean Person reference is
unbounded. FairZ uses a zero reference; `FairMReference` records the
distinction. This display option and endpoint placement on a Wright map
do not correct JML bias. In comparisons across software, specify score
adjustments and post-fit corrections separately; a shared “JML” label is
insufficient.

The same principle applies to any GPCM slope whose boundary status has
not been resolved: a finite optimizer iterate is not automatically a
finite maximum suitable for ordinary inference.

PCM and GPCM can be reviewed on the same data with
`compare_mfrm(fit_pcm, fit_gpcm)`,
`build_weighting_review(fit_pcm, fit_gpcm)`, or
`build_model_choice_review(..., run_weighting_review = TRUE)`.
Selectable information-criterion ranking requires comparable MML fits
with adequate support for comparison on a common quadrature grid with at
least 31 points. For GPCM, `ICFitEligible` checks the reevaluated
likelihood, gradient and positive unregularized local information
independently of slope-interval eligibility. `ICComparable` records the
final comparison decision. PCM is the all-unit-slope reduction of the
aligned GPCM kernel. `nested = TRUE` requests an asymptotic chi-square
test with G-1 degrees of freedom, after verifying that only the relative
slopes differ. Match the population model explicitly (for example,
`population_formula = ~1` and the same person data in both fits); the
defaults differ. IC ranking and LRT eligibility are separate.

The practical comparison is available without reconstructing the model
matrices manually. After fitting the same data as `fit_pcm` and
`fit_gpcm` (see the GPCM scope vignette), use:

``` r

choice <- build_model_choice_review(PCM = fit_pcm, GPCM = fit_gpcm)
choice$model_roles[, c(
  "Model", "StepCoordinates", "FreeStepParameters",
  "SlopeCoordinates", "FreeSlopeParameters",
  "FitReadiness", "FormalInference", "Interpretation"
)]
```

The coordinate columns count reported values; the free-parameter columns
also apply the fitted constraints.
[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
describes changes in measures and information under discrimination-based
weighting. GPCM MML ranking is returned only for an eligible comparison;
an unpenalized JML likelihood difference does not justify an automatic
PCM-versus-GPCM choice.

Cross-software slope values are not automatically matched estimands.
FACETS does not jointly fit Muraki’s free-slope polytomous GPCM. FACETS’
reported element discrimination is a post-fit diagnostic computed after
the Rasch measures and does not feed back into the other estimates; it
must not be treated as a free-GPCM slope estimate from `mfrmr`. TAM’s
documented Example 14c combines a facet intercept design with grouped
slopes through `tam.mml.2pl(irtmodel = "GPCM.design")`; `tam.mml.mfr()`
alone does not estimate slopes. ConQuest’s `scoresfree` route assigns
slopes to generalized items (facet combinations), with further sharing
specified through a scoring design. These constructions do not
automatically match mfrmr’s slope multiplying ability, rater severity
and steps together. The current `immer` estimation routes provide PCM-
design and hierarchical-rater references rather than a matched free-GPCM
fit. Consequently, FACETS and `immer` are appropriate only for
documented equal-discrimination overlaps or deliberately different-model
sensitivity checks. Replicating GPCM point estimates with ConQuest or
TAM requires matching the response kernel, slope grouping, threshold
parameterization, latent-scale identification, retained rows and
category map.

For the matched item-only model, mfrmr’s relative slopes become
population-SD-standardized slopes after multiplying by the fitted
population SD (conditional on any population covariates). Transforming
intervals also requires the SD’s uncertainty and its covariance with the
slopes; multiplying interval endpoints is insufficient. The [GPCM
tutorial](https://ryuya-dot-com.github.io/mfrmr/vignettes/mfrmr-gpcm-scope.Rmd#what-can-and-cannot-be-compared-across-programs)
links the official ConQuest/TAM specifications and distinguishes
existing numerical comparisons from unverified uncertainty comparisons.
Its scope is separate from the public ConQuest overlap-bundle and
external-import APIs.

For strict MML diagnostics, keep the two evidence bases distinct:

``` r

diag_both <- diagnose_mfrm(
  fit,
  residual_pca = "none",
  diagnostic_mode = "both"
)

summary(diag_both)$diagnostic_basis
```

The residual route uses person point estimates. The marginal route
averages expectations over Person posteriors conditional on the same
responses, with the calibration held fixed. Its residual scales omit
cross-response covariance and calibration uncertainty. These are
complementary descriptive screens; neither supplies guaranteed
individual or multiple-element false-positive rates.

## Updating saved analyses

In version 0.2.4,
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
stops if scores or selected facet values are missing. Review the data
and use `missing = "omit"` only when complete-row selection is intended;
invalid score labels must be cleaned explicitly. `gt$data_usage` records
the input source, row counts, and missing cells. The counts also
accompany G/D coefficient tables and exports. Counts based on stored
fitted rows exclude any earlier MFRM filtering. Older saved G/D results
cannot recover that accounting by reprinting; rerun the G-study with the
original data if it is needed.

Installing 0.2.4 does not recalculate saved diagnostics, scores or
reports. Keep the originals and the settings used to create them. For
analyses based on a native MFRM fit, first print `summary(fit)` with the
updated package. A native fit lacking the current estimation checks must
be refitted from its original data and settings before inferential
reuse; computing diagnostics alone cannot supply those fit checks.
Observed-score G/D studies and external-feature groups use their own
source objects and do not require an MFRM fit.

Start at the affected step below and rebuild everything that depends on
it. For an MFRM-based analysis, this assumes a fit with current
estimation checks:

| Saved result | Required action |
|----|----|
| Fit-summary wording | Reprint the summary. Stored calculations and missing precision evidence do not change. |
| Generic conversions of dedicated plots | Recreate affected figures from the saved analysis with its base [`plot()`](https://rdrr.io/r/graphics/plot.default.html) method or use [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md) for explicitly specified custom graphics. Previously, `as_ggplot(..., component = "table")` could discard PCA axes, MI intervals or D-study metrics; that bypass is now refused. Dedicated external-feature PCA and pooled MI interval conversions preserve their full views with the default or `component = "table"`; supported multivariate D-study scenario conversions use the default or `component = "series"`. Refitting is unnecessary, but previously saved ggplots/images are not automatically corrected. |
| Shared-rater/testlet calibration bounds | Rebuild `summary(fit)`, `mfrm_results(fit)` and dependent reports from the saved fit; refitting is unnecessary. Defaults now retain estimates and approximate SEs with missing bounds. Request `confint(fit, parm = "calibration", level = .95)` or `mfrm_results(fit, calibration_intervals = "normal", calibration_level = .95)` explicitly for pointwise normal approximations with unestablished finite-sample coverage. Testlet plots accept `intervals = "normal", level = .95`. Older result bundles retain their original tables; changing display does not correct coverage. |
| Diagnostics, QC, fair scores and reports | Recompute diagnostics with the original options, rerun the affected helpers and recreate plots/exports. This includes updated treatment of missing results and SE eligibility. |
| Residual group comparisons or facet equivalence | Recreate residual comparisons from the fit and original group data. Recompute equivalence from an eligible MML fit with matching diagnostics and the original practical bound. |
| ICC and design effects | Rerun [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md) or [`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md) from the original data/settings, explicitly choosing how to handle missing values. Recreate design effects from the new ICC result’s row accounting. Choose `"boot"` explicitly for intervals and inspect all failure diagnostics. The former `"profile"` method is withdrawn; reprinting cannot correct saved intervals. |
| Main-effects G/D studies | Rerun the observed-score G-study and D-study using the original settings. The G-study fits a separate mixed model; the MFRM need not be refitted for these corrections. |
| Multivariate G/D studies | Recompute the D-study from its saved G-study to update metric-specific availability or change future counts/weights; then recreate dependent comparisons and plots. Replotting alone preserves stored values. Changed source data, a changed G-study model (including nesting), incompatible design metadata or an earlier G-study affected by the single-score MINQUE(0) or interaction-ID corrections requires a new G-study. Keep the G-study and its data for plan-comparison intervals. |
| External-feature groups | Replot saved results for updated labels; memberships and trees are preserved. Changed features, weights, group counts or methods require new clustering, followed by a new comparison of those results. Reuse the same fitted imputation object when comparing settings across completions. Use [`plot()`](https://rdrr.io/r/graphics/plot.default.html), [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md) or the dedicated [`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md) routes for PCA, silhouettes, numeric/categorical profiles, saved dendrograms and imputation co-membership. |
| Shrinkage | Reapply using the original prior and explicit Person settings, then regenerate reports and replay scripts. Switching Person shrinkage off removes old adjustment columns. No MFRM refit is needed to refresh these results. |
| Person scores or plausible values | Re-summarize the original scoring/draw object for updated labels and requested empirical quantiles. To change old grid-endpoint intervals or recover missing prior parameters, rerun scoring from the existing fit. Estimated-population results may require regeneration with explicit review. |
| Portable calibration | A valid saved artifact retains its algorithm. To adopt continuous intervals, create a new artifact through the reviewed calibration workflow and score again. |
| External imports | Re-import the saved source-package fit, then recreate derived output; source-model re-estimation is unnecessary. |
| Simulation/design evaluations | Re-summarize retained runs for corrected denominators and unrounded recommendation metrics; older rounded summaries cannot recover precision themselves. Missing connectivity or workload records require repeating the original evaluation if needed for a recommendation. |
| DIF/bias screening simulations | Rebuild target summaries and plots from the original evaluation to preserve unavailable outcomes and full precision. Earlier non-target averages lack cell availability counts and are withheld; rerun only if those corrected cell rates are needed. |

The complete instructions, including function names and exceptions, are
in “Updating saved analyses for 0.2.4” under
[`help("mfrmr_workflow_methods", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md).
[NEWS](https://ryuya-dot-com.github.io/mfrmr/news/index.html) explains
the individual changes. Re-exporting an old derived object does not
update its calculations, and updating an object does not broaden its
statistical use.

## Documentation

The package includes the following tutorials. On the documentation
website, open them from the **Articles** menu. In R, run the command
below to read the guide shipped with your installed version.

| Guide | Open in R |
|----|----|
| End-to-end workflow | [`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md) |
| MML estimation and marginal-fit diagnostics | [`vignette("mfrmr-mml-and-marginal-fit", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-mml-and-marginal-fit.md) |
| Portable calibration and fresh-session scoring | [`vignette("mfrmr-portable-calibration", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-portable-calibration.md) |
| Exploring person, rater, and task attributes | [`vignette("mfrmr-external-features", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-external-features.md) |
| Missing scores on assigned ratings | [`vignette("mfrmr-response-imputation", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-response-imputation.md) |
| Uncertainty in rater estimates and differences | [`vignette("mfrmr-facet-intervals", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-facet-intervals.md) |
| Accuracy and availability of rater warnings | [`vignette("mfrmr-screening-performance", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-screening-performance.md) |
| A rater population, observed-rater feedback and replacement raters | [`vignette("mfrmr-random-raters", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-random-raters.md) |
| Dependence within a person’s ratings and conditional testlet scoring | [`vignette("mfrmr-testlets", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-testlets.md) |
| Migrating from FACETS | [`vignette("mfrmr-facets-migration", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-facets-migration.md) |
| Visual diagnostics | [`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md) |
| Reporting and APA-oriented output | [`vignette("mfrmr-reporting-and-apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-reporting-and-apa.md) |
| Linking and DFF | [`vignette("mfrmr-linking-and-dff", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.md) |
| GPCM scope | [`vignette("mfrmr-gpcm-scope", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.md) |

List installed guides with `browseVignettes("mfrmr")`. A printable API
overview is installed at `cheatsheet/mfrmr-cheatsheet.pdf`.
Function-level help starts with
[`?fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`?summary.mfrm_fit`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
and
[`?plot.mfrm_fit`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md).

## Citation

Use the package citation supplied with the installed version:

``` r

citation("mfrmr")
```

The underlying ordered-response models are described by Andrich (1978),
Masters (1982), and Muraki (1992). See the package help and vignettes
for the references relevant to each model and diagnostic route.

## License

`mfrmr` is licensed under the [MIT
License](https://opensource.org/licenses/MIT).

## Acknowledgements

`mfrmr` has benefited from discussion and methodological input from
[Dr. Atsushi Mizumoto](https://mizumot.com/) and [Dr. Taichi
Yamashita](https://kugakujo.kansai-u.ac.jp/html/100000882_en.html).
