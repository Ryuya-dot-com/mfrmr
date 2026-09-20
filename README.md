# mfrmr <img src="man/figures/logo.png" align="right" height="160" alt="mfrmr hex logo" />

[![GitHub](https://img.shields.io/badge/GitHub-mfrmr-181717?logo=github)](https://github.com/Ryuya-dot-com/mfrmr)
[![R-CMD-check](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/Ryuya-dot-com/mfrmr/actions/workflows/pkgdown.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`mfrmr` fits unidimensional many-facet ordered-response models in R.
It supports rating-scale (`RSM`) and partial-credit (`PCM`) models, together
with a documented bounded `GPCM` extension. A facet can represent a rater,
item, task, criterion, form, occasion, or another observed role that affects
an ordered score.

Start with the quick start below: load data, fit a model, draw a plot, and
inspect the summary. The complete workflow then covers data checks,
diagnostics, and reporting.

Package website: <https://ryuya-dot-com.github.io/mfrmr/>

Source code: <https://github.com/Ryuya-dot-com/mfrmr>

Questions and bug reports:
<https://github.com/Ryuya-dot-com/mfrmr/issues>

## Installation

This README describes the `0.2.4` release candidate, which has not been released.
Functions and options shown here may differ from an installed release; check
`packageVersion("mfrmr")` and the help shipped with that installation.
For an existing analysis, read [Updating saved analyses](#updating-saved-analyses)
before reusing saved diagnostics, scores or reports.

Install the CRAN package with:

```r
install.packages("mfrmr")
```

Install the GitHub version with:

```r
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

remotes::install_github(
  "Ryuya-dot-com/mfrmr",
  build_vignettes = TRUE
)
```

## Quick start

This example estimates person abilities while accounting for rater severity
and criterion difficulty. A *facet* is a source of variation in scores; here,
`Rater` and `Criterion` are facets, and individual raters and criteria are their
*levels*. The data are synthetic, with one row per rating and scores from 1 to 4.

`head(toy)` shows the first six rows. The quoted column names in `fit_mfrm()`
are case-sensitive; `Study` and `Group` are extra labels unused by this model.
`MML` selects marginal maximum likelihood; `RSM` selects a rating-scale model
with shared category thresholds (the transitions between adjacent scores).

```r
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
  method = "MML",
  model = "RSM"
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

`<-` saves an object without printing it. Here `toy` holds the data, `fit`
holds the model, and `results` holds its summary. `$` selects a named part:
`results$person_overview` displays just that table. Enter `results` to print
the full summary.

The Wright map displays the estimates in logits, the model's measurement units,
rather than the original 1-to-4 scores. With this example's default orientation,
higher person estimates mean higher ability; higher rater estimates mean
stricter ratings, and higher criterion estimates mean greater difficulty.

The overview tables describe distributions: `person_overview` has one row for
all 48 persons, and `facet_overview` has one row for each facet. `Mean`/`MeanEstimate`
is the average, `SD`/`SDEstimate` is the spread, and `Min`/`Max` or
`MinEstimate`/`MaxEstimate` give the endpoints. Rater and criterion means are
constrained to zero here; their SDs and ranges show differences among levels.

### Inspect individual estimates

```r
estimates <- as.data.frame(fit)
head(subset(estimates, Facet == "Person")) # First six persons
subset(estimates, Facet == "Rater")       # All raters
subset(estimates, Facet == "Criterion")   # All criteria
```

`Facet` identifies the type of estimate, `Level` identifies the person, rater,
or criterion, and `Estimate` is its value in logits.

### Check what needs review

Read `results$decision`, especially `Why` and `NextAction`, before interpreting
or reporting estimates. `FormalInference = "No"` in this first summary can
mean that precision has not yet been reviewed; it does not necessarily mean
that fitting failed. The default summary does not compute diagnostics.

```r
diagnostics <- diagnose_mfrm(fit)
diagnostic_summary <- summary(diagnostics)
diagnostic_summary$decision
```

For your own data, follow [Use your own CSV](#use-your-own-csv) below.
For reporting, `res <- mfrm_results(fit, diagnostics = diagnostics)`
builds a comprehensive object that reuses the checks above. Pass `res` to
`mfrm_report()` or `export_mfrm_results()`; `results` remains the basic summary.

For a guide to the next steps, open
`help("mfrmr_workflow_methods", package = "mfrmr")` or
`vignette("mfrmr-workflow", package = "mfrmr")`. Use
`help("mfrmr_visual_diagnostics", package = "mfrmr")` when choosing a figure
and `help("mfrmr_reporting_and_apa", package = "mfrmr")` when moving from a
reviewed fit to tables and manuscript-draft output.

## Data format

Each row records **one score given by one rater to one person on one
criterion**. The same person therefore appears on several rows:

| Person | Rater | Criterion | Score |
| --- | --- | --- | --- |
| 001 | R1 | Content | 3 |
| 001 | R1 | Style | 2 |
| 001 | R2 | Content | 4 |
| 001 | R2 | Style | 3 |

These four rows illustrate the layout, not a dataset for estimating a model.
Keep the complete set of ratings for your analysis. Use consistent IDs across
rows; `001` identifies the same person each time. `Score` contains the ordered
integer categories from the rubric, not person totals or averages across raters.
Use a blank cell or `NA` for a missing rating; zero is a score if your rubric
includes zero. Do not add zeros for ratings that were never assigned.

At least one non-person facet is required. This example uses two; choose
columns that represent your design. If criteria occupy separate spreadsheet
columns, see the reshaping example in the workflow vignette.

## Use your own CSV

Export the rating sheet as **CSV UTF-8**, with column names in the first row.
For the four-column layout above, run:

```r
library(mfrmr)

# Select your CSV file in the file dialog
csv_path <- file.choose()
ratings <- read.csv(
  csv_path,
  colClasses = "character",
  na.strings = c("", "NA"),
  check.names = FALSE,
  fileEncoding = "UTF-8-BOM"
)
head(ratings)
names(ratings)
table(ratings$Score, useNA = "ifany")
```

For a reusable script, replace `file.choose()` with a quoted path such as
`"data/ratings.csv"`, relative to the folder shown by `getwd()`.
Reading columns as text preserves IDs such as `001`; `mfrmr` converts numeric
score strings such as `"3"` for estimation. The missing tokens above apply to
all columns; adjust them if, for example, `NA` is a legitimate identifier.

The names in `person`, `facets`, and `score` must match `names(ratings)` exactly.
For a file headed `Student`, `Judge`, `Task`, and `Rating`, use
`person = "Student"`, `facets = c("Judge", "Task")`, and `score = "Rating"`
in **both** calls below, and inspect `ratings$Rating` above.

### Check the data before fitting

```r
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

Set `rating_min` and `rating_max` from the **rubric**, even if nobody received
the lowest or highest score. The values above describe a 1-to-4 rubric.
`keep_original = TRUE` preserves its category structure. Check `DroppedRows`
for excluded rows and `RawN` for category counts. Missing scores or required
IDs remove that rating row, not automatically the person's other ratings.
The package does not fill missing ratings. If an internal category has no
observations, fitting with this setting stops: review the data and rubric
before changing the categories.

`Components = 1` indicates that a facet's levels are connected through shared
persons. More than one component needs design review before comparing levels
across components. This check alone does not establish model identification.
The vignette's **If a check stops you** section covers missing-value codes,
unexpected row loss, and common input errors.

### Fit and read the results

After resolving the data-review findings, use the same columns and score scale:

```r
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

Read `Why` and `NextAction` before using the estimates. With these default
settings, higher person estimates mean higher ability, higher rater estimates
mean stricter ratings, and higher criterion estimates mean greater difficulty.
The values are in logits; a difference in estimates alone does not establish
statistical significance. For custom facet names, also change the `Facet`
filters above, for example from `"Rater"` to `"Judge"`; person rows retain
`Facet == "Person"`.

Open `vignette("mfrmr-workflow", package = "mfrmr")` for a runnable practice
CSV, a wide-to-long example, and troubleshooting. The complete workflow below
returns to the packaged data to illustrate further review and reporting.

## Further data considerations

### Response type and frequencies

The current response likelihood is ordered categorical. Binary scores are the
two-category special case, and RSM, PCM, and bounded GPCM cover ordered
polytomous scores. Although their category probabilities form a vector that
sums to one, they are not unordered nominal-response or multinomial-logit
models. Poisson, negative-binomial, and grouped binomial-trial count responses
are also outside the current `fit_mfrm()` scope. Integer counts supplied as
`Score` are interpreted as ordered category codes, not as Poisson or related
counts.

A positive numeric `weight` weights one row's conditional ordered-category
likelihood and can represent a defensible row-replication weight. It is not a
general collapsed-person frequency table. Under MML, powering responses within
one Person's conditional pattern is not equivalent to replicating a complete
Person response pattern after marginalization. It also does not change the
response family or model dependence among repeated ratings. Non-unit
observation-weight fits are excluded from the common MML information-criterion
panel and remain review-only for ordinary inference: their SEs and intervals
have not been qualified for the weighted objective. FACETS has separate `Bn`
binomial-trial and `P` Poisson response models;
those are not reproduced by mfrmr's binary ordered-score route.

Each row should represent a distinguishable rating event. Exact duplicate
Person-by-facet combinations are retained but trigger a warning and a Data
review state because the package does not model within-cell dependence. For a
legitimate re-rating or replicated scoring study, include an event or occasion
facet that distinguishes the observations before fitting.

For conventional score sentinels such as `99`, `-1`, `N`, or `.`, set
`missing_codes = TRUE`. This convenience policy recodes the score column only;
it preserves person and facet identifiers because short labels such as `N` can
be legitimate IDs. Supplying an explicit character vector instead applies
that user-declared code set across the selected model columns, so inspect the
returned `missing_recoding` record before fitting or reporting exclusions.

The main workflow below uses a compact synthetic dataset with a connected
two-rater assignment, moderately unequal rater workloads, and six planned
criterion-level omissions represented by absent long-format rows, not `NA` or
sentinel scores. Its groups contain 24 persons each; three omissions per group
leave 141 observed rows in Group A and 141 in Group B:

```r
library(mfrmr)

dat <- load_mfrmr_data("example_operational")
data("mfrmr_example_operational_design", package = "mfrmr")
head(dat)
table(dat$Score)
list_mfrmr_data(details = TRUE)[, c("Key", "PrimaryUse", "Design", "CountBasis")]
```

All bundled examples are synthetic. `example_operational` is the applied
teaching dataset, not an empirical reference dataset. Use `example_core` only
when an idealized complete crossing is useful for a fast example, and use
`example_bias` for demonstrations with deliberately planted DFF/bias effects.

## Complete MML workflow

### 1. Check the data and intended score scale

Before fitting, state the complete rubric support and inspect retained,
missing, and zero-count categories:

```r
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

The assignment roster contains no scores. It tells `describe_mfrm_data()`
which Person x Rater x Criterion cells were planned. The review therefore
reports the six expected-but-unobserved cells separately from ordinary column
`NA` counts, while confirming that both observed Person-facet graphs remain
connected. Without `expected_design`, structural missingness is reported as
not assessed because an absent row may simply mean that the cell was never
assigned.

`rating_min` and `rating_max` retain unobserved boundary categories in the
data-support review. A boundary gap remains review evidence for the separate
element-boundary contract; it is not by itself an unsupported free-step
contrast. If an intended intermediate category is unobserved, use
`keep_original = TRUE` in both `describe_mfrm_data()` and `fit_mfrm()`. In a
polytomous fitted ladder, that retained internal gap creates an exact
adjacent-step recession direction, so fitting stops before optimization.
Otherwise non-consecutive observed scores such as `1, 2, 4, 5` are mapped to a
contiguous internal scale; always review the reported score map before
interpreting steps.

### 2. Fit the model

For a new analysis, start with marginal maximum likelihood:

```r
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

`MML` integrates over the person distribution and returns posterior person
summaries. The default uses 31 quadrature points. Record that setting and
examine same-data quadrature sensitivity before portable calibration and
whenever numerical movement could affect a consequential result. Eligible
fits below 15 points retain raw AIC/BIC/SABIC for screening, and fits at
15--30 points retain them for review, but automatic deltas, criterion weights,
preferred-model labels, evidence ratios, and LRT are disabled below 31 points.
Use 31--60 points as a comparison starting grid and 61 or more as a denser
sensitivity grid. A close or consequential comparison still requires a
prespecified common-grid sensitivity check; q>=31 alone is not evidence that
integration error is negligible.

For the fitted MML model and the same data, request the comparison explicitly.
`mml_quadrature_sensitivity()` refits each requested grid; `summary(q_review)`
only summarizes the returned review:

```r
q_review <- mml_quadrature_sensitivity(
  fit,
  data = dat,
  quad_points = c(31, 61)
)
summary(q_review)
apa_table(q_review)
```

The review works for RSM, PCM, and bounded GPCM. It reports changes in marginal
likelihood per Person, measurement coordinates, probabilities, EAP, posterior
SD, and, when present, relative slopes, raw local-curvature SEs, and population
SD. The GPCM-specific `gpcm_mml_quadrature_sensitivity()` name remains
available. Neither route assigns a universal stable/unstable cutoff, makes raw
slope SEs inferentially eligible, or changes the fit-readiness decision.

Use `model = "PCM", step_facet = "Criterion"` when category steps differ
across that facet. Choose the model from the scoring design and measurement
rationale, not from a single fit statistic.

### 3. Read the fit-only summary

The default summary is deliberately lightweight:

```r
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

Read `fit_summary$decision` first: have estimation checks passed, has precision
been assessed, what limits interpretation, and what should be done next?
A fit-only summary returns `FormalInference = "No"` even when estimation
checks pass. Convergence and estimability do not by themselves validate
standard errors, confidence intervals or reliability. Review precision with
matching diagnostics:

```r
diag <- diagnose_mfrm(fit, residual_pca = "none")
summary(fit, diagnostics = diag)$decision
# Equivalent precision-aware decision:
summary(diag)$decision
```

The decision is a presentation of existing evidence, not a new statistical
test or an automatic model-selection rule. `FormalInference = "No"` still
permits explicitly labelled diagnostic inspection, but not formal SE/CI,
reliability, or significance claims. It does not mean that changing optimizer
settings until the answer becomes `"Yes"` is appropriate. Follow `NextAction`
and retain the original reason in reports.

Then review convergence and estimation settings. Optimizer success and the
terminal-gradient check are separate numerical checks. A small gradient still
does not resolve a disconnected design, effects that cannot be separately
estimated, or unbounded estimates. The fitting help describes the numerical
controls and the recorded optimization history.

Treat `maxit` as a computational ceiling, not a convergence criterion or a
control to tune until preferred estimates appear. The default is `maxit = 400`.
Prespecify the estimator and controls before inspecting results. If a fit stops
at the iteration limit, refit the same data, model, method, anchors, optimizer,
tolerance and quadrature rule using the next ceiling in that sequence. Do not
select among runs by coefficient size, fit statistics, significance or agreement
with an expected answer. Material differences between numerically acceptable
runs require review.

Print `fit_summary` for readable explanations; its component tables retain
detailed settings and status fields for further inspection. Estimation checks
and precision assessment are distinct from reviewing the rating design and
the assumptions needed for the intended comparison. Plots marked `REVIEW ONLY`
remain diagnostic displays. A saved fit without current estimation checks needs
the update procedure below before inferential reuse.

### 4. Request the comprehensive measurement summary

Use the `facets` profile for the main review:

```r
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

This profile organizes model information, measures, uncertainty, fit evidence,
precision, category/step information, and plot routes in one reading order. No
experience with FACETS, TAM, or sirt is required. It computes the documented
diagnostics when they are needed and returns the resulting `mfrm_results`
object in `facets_summary$results`.

The historical profile name describes organization, not software execution:

- FACETS is not called;
- all estimates remain `mfrmr` estimates;
- sections that require a study-specific contrast, such as DIF or DFF, are not
  inferred automatically;
- residual PCA and multi-wave linking or drift analyses remain explicit
  follow-up decisions.

Pass a matching `diagnose_mfrm()` object through `diagnostics = diag` to
reuse work already completed. Use `compute = "never"` for a no-computation
review; dependent sections are then marked as not computed.

Person identifiers are omitted from the brief console view. Request detailed
person output only when the analysis purpose and data-handling plan require it.

### 5. Draw the required native Wright map

The native renderer is the primary targeting figure because it keeps
uncertainty visible:

```r
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
- facet levels show severity, difficulty, or the active signed orientation;
- step locations show the fitted category structure;
- intervals show uncertainty where an appropriate SE is available;
- gaps between the person distribution and the modeled locations may indicate
  weak targeting in that region.

Person and non-person uncertainty can have different statistical bases.
For example, an MML person interval is based on posterior uncertainty, whereas
a non-person interval may use observed-information uncertainty. Keep the
reported SE method with any table or figure interpretation.

The package defaults to a negative orientation for ordinary non-person facets:
higher measures indicate greater severity or difficulty. Facets named in
`positive_facets` have the reverse scoring direction. State the active
orientation in the figure caption.

Set `draw = FALSE` to obtain the fitted coordinates for a custom `ggplot2`,
Quarto, or accessibility-aware figure.

`top_n = Inf` retains and labels every fitted coordinate. The native text layer
keeps the fitted points fixed, moves only colliding labels, and connects them
with leader lines; `label_points` records both coordinates. Step thresholds
share a vertical ladder and are labelled with both the score transition and
the fitted logit. For genuinely dense maps, use the finite `top_n` compact view
or a larger output device rather than silently omitting interior labels.

When the fit review diagnoses boundary-separated facet levels and no explicit
`wright_range` is supplied, the native and FACETS-style renderers use the same
robust central range. Boundary levels appear at the appropriate ruler end with
triangles, while `OriginalEstimate`, `CI_Lower`, and `CI_Upper` retain the
untruncated values. `DisplayEstimate`, `DisplayCI_Lower`, `DisplayCI_Upper`, and
the `CIClipped*` / `CISuppressed` fields describe only what was drawn. This
prevents a huge separation interval from compressing the interpretable center
or being mistaken for a complete visible interval.

### 6. Add the optional FACETS-style Wright map

Use study-specific rubric labels rather than anonymous category numbers:

```r
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
- adjacent-score labels such as
  `1 Beginning -> 2 Developing`;
- expected-score midpoint markers;
- an explicit `* = n person(s)` legend.

Set `persons_per_star` when the same star density must be used across several
figures. Otherwise, the renderer chooses a compact value and prints it below
the map.

The step display is designed to make the rating scale readable:

- a solid horizontal line is an estimated adjacent-category step location;
- its label names the lower and upper observed score categories and prints the
  fitted logit value in brackets;
- its height is the step location on the shared logit scale;
- a shorter dotted line is an expected-score midpoint crossing, not an
  additional model parameter.

For `RSM`, the step pattern is shared by the relevant observations. For
`PCM`, read the step column within its curve or step-facet group. Disordered or
closely spaced steps are prompts to inspect category use, sample support, and
the scoring design; they are not automatic instructions to collapse
categories.

Use the actual rubric wording from the instrument. The names of
`category_labels` must match the original scores. A two-column data frame with
columns `Score` and `Label` is also accepted.

With `draw = FALSE`, the returned `facets_style` component exposes
`category_labels`, `step_ruler`, `score_transitions`, and `settings` tables.
For line-printer reconstruction, `RulerValue` records the nearest discrete
ruler row; `DrawValue` records the exact coordinate used for step and midpoint
lines in the current renderer.

For a closer FACETS visual comparison, leave `show_ci = FALSE`. Setting
`show_ci = TRUE` adds `mfrmr` uncertainty whiskers to the asterisk ruler. That
hybrid is useful analytically, but it is intentionally an extension of the
FACETS-style layout; its footer identifies the interval level and the dot at
each whisker marks the corresponding fitted facet location.

Boundary-separated levels otherwise make an estimate-derived ruler very wide.
The automatic boundary-aware range described above is used by default; set an
explicit, reported range such as `wright_range = c(-4, 4)` when the application
requires a prespecified display scale. Out-of-range levels remain visible in
parentheses at the ruler ends. With `show_ci = TRUE`, endpoint triangles and
the footer identify intervals that extend beyond or are omitted from the
displayed ruler; exact values remain in the returned data.

### Visual correspondence is not numerical equivalence

The FACETS renderer reproduces the main reading grammar of a FACETS Table
6-style variable map. It does not reproduce a FACETS run.

| Question | What `mfrmr` provides |
| --- | --- |
| Familiar visual layout | Asterisk person counts, shared ruler, signed facet columns, step lines, and rubric-labelled transitions |
| Estimate source | The fitted `mfrmr` object |
| Pixel-identical output | Not guaranteed across graphics devices, fonts, or FACETS versions |
| Numerical equivalence | Not established by selecting `renderer = "facets"` |
| External comparison | Available after the user supplies output from a separately run FACETS analysis |

A defensible numerical comparison requires the same response records, score
coding, model, estimator, identification constraints, anchors, facet
orientation, extreme-score handling, and convergence criteria. FACETS commonly
uses JMLE, whereas the starter `mfrmr` workflow above uses MML with EAP person
summaries when its population-model assumptions are suitable. Those choices
target related but different calculations.

When a JMLE-oriented comparison is required, refit with `method = "JML"` and
still document every remaining setting. Matching the estimator family alone
does not establish equivalence.

For an exported FACETS fit table, use `read_facets_fit_table()` followed by
`facets_fit_review(fit, diagnostics = res$diagnostics, facets_fit = ...)`.
This reads supplied output; it does not launch or automate FACETS.

### 7. Review the Infit pathway, including persons

The fit pathway uses Infit on the horizontal axis and measure on the vertical
axis:

```r
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

The vertical axis remains the fitted logit measure. The horizontal reference
at Infit MnSq = 1 represents model expectation; the outer lines are review
guides. Selected persons use a different point shape from non-person facet
levels. Completing this follow-up can change the Reporting readiness row while
leaving the already-passed Numerical row unchanged.

`top_n_person` limits the displayed person layer so a large study remains
readable. The selected persons are those with the largest fit distances;
non-person rows remain available. Use `person_subset` for a prespecified case
list, or `top_n_person = Inf` only when displaying every person serves a clear
purpose.

Fit statistics are evidence for review, not automatic exclusion rules.
Investigate response patterns, design cells, score support, and practical
consequences before changing data or operational decisions.

The separate `type = "pathway"` route displays expected scores and
dominant-category regions across theta; `type = "fit_pathway"` displays Infit
or Outfit against the fitted measure.

### Fair Scores and figures without embedded notes

`plot_fair_average()` offers observed-versus-fair (`"scatter"`),
observed-minus-fair (`"difference"`), and measure-to-score (`"measure"`) views.
FairM uses mean reference measures; FairZ uses zero reference measures.
**FairZ is an expected score, not a z-score.** These transformations do not
average predictions over the observed assignment distribution, and gaps also
reflect person mix and assignment; they do not by themselves establish bias.

```r
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

Use `draw = TRUE` for a base-R figure. The returned object retains notes even
when annotations are hidden. Wright, expected-score pathway, and CCC plots
also accept `show_title`, `show_notes`, and `preset = "monochrome"`; see
`help("mfrmr_visual_diagnostics")` for the reusable-data route and display limits.

| Fair-score interval route | What is propagated | Current interpretation |
| --- | --- | --- |
| `plot_fair_average(fit, show_ci = TRUE)` for RSM/PCM | Focal measure SE, with thresholds and reference measures fixed | Conditional diagnostic interval |
| `fair_average_table(fit_gpcm, fair_se = TRUE)` for GPCM-MML | Joint structural covariance, with Person EAP/reference means fixed; non-Person rows only | Structural diagnostic interval |

The table's `fair_se` option does not supply RSM/PCM fair-score SEs. Historical
`SE`/`ModelBasedSE` columns describe measures, not fair scores. Plot intervals
carry `CI_Eligible = FALSE`; requested table intervals carry
`FairCIEligible = FALSE`. Neither finite limits nor a ready fit establishes
full-refit coverage. Difference-view whiskers also hold the observed mean
fixed and are not confidence intervals for the observed-minus-fair gap.

### 8. Build a report and export the results

Start with the brief result summary:

```r
results_summary <- summary(res, view = "brief")
results_summary$overview
results_summary$triage
results_summary$next_actions
results_summary$plot_map
```

Build a report-oriented object from the same fitted results:

```r
report <- mfrm_report(
  res,
  style = "qc"
)

summary(report, view = "reader")
report$first_screen
report$report_index
```

`mfrm_report()` organizes existing evidence. It does not refit the model or
turn diagnostic thresholds into a validity decision.

Export a reader-oriented, controlled analysis archive:

```r
exported <- export_mfrm_results(
  res,
  output_dir = "mfrmr-results",
  prefix = "analysis01",
  preset = "starter"
)

exported$summary
exported$written_files
```

The `starter` preset includes the result summary, report tables, replay code,
manifest, native Wright map, and focused plot routes. Existing files are not
overwritten unless `overwrite = TRUE` is requested explicitly.

This preset is a controlled **analysis archive**, not a deidentified or
automatically shareable deliverable. It includes a complete `.rds` result
object, and its tables, HTML, plots, replay code, and manifest can retain direct
person identifiers, person-level estimates, original labels, or local paths.
Review and transform every file under the study's data-handling policy before
sharing it. After making that assessment, `acknowledge_sensitive = TRUE` can
suppress the export warning; it does not remove or pseudonymize any data.

## A practical reading order

For most studies, review the output in this order:

1. Confirm the data roles, score range, row retention, and model.
2. Confirm convergence and the estimation settings.
3. Inspect the native Wright map with uncertainty.
4. Review targeting, facet measures, person summaries, and category steps.
5. Inspect Infit/Outfit and the person-inclusive Infit pathway.
6. Add residual, bias/DIF, linking, or interaction analyses only when the
   design and research question require them.
7. Review report caveats before exporting or drafting substantive claims.

Do not reduce this sequence to a single pass/fail index. Fit, precision,
targeting, category function, fairness, and validity answer different
questions.

## FACETS users

The closest translation of common FACETS concepts is:

| FACETS concept | `mfrmr` route |
| --- | --- |
| Data/specification roles | Explicit `person`, `facets`, and `score` arguments |
| JMLE-oriented fit | `fit_mfrm(method = "JML")` |
| MML analysis | `fit_mfrm(method = "MML")` |
| Measures and SEs | `summary(fit, profile = "facets")` and its result tables |
| Variable/Wright map | Native `renderer = "native"` or optional `renderer = "facets"` |
| Infit/Outfit review | `diagnose_mfrm()` and `type = "fit_pathway"` |
| Fair average | `fair_average_table()` |
| Bias/interaction screen | `estimate_bias()` and related review functions |
| Anchors | `anchors` and `group_anchors` in `fit_mfrm()` |
| External fit comparison | `read_facets_fit_table()` then `facets_fit_review()` |

For an existing FACETS-oriented script, `run_mfrm_facets()` provides a
one-call wrapper around package fitting and diagnostics. For new work, the
explicit `fit_mfrm()` workflow is easier to review and is recommended.

Use these guides for the full migration details:

- [Migrating from FACETS to mfrmr](vignettes/mfrmr-facets-migration.Rmd)
- [Visual diagnostics](vignettes/mfrmr-visual-diagnostics.Rmd)

The installed `references/FACETS_manual_mapping.md` maps concepts and output
routes. It is not evidence that FACETS was executed.

## ConQuest MML comparison

`mfrmr` can prepare and review a narrow external-table comparison for an MML
latent-regression case. The supported overlap is:

- `RSM` or `PCM`;
- binary responses;
- exactly one non-person facet, treated as the item facet;
- a unidimensional latent-regression MML fit;
- one numeric person covariate in addition to the intercept;
- complete rectangular person-by-item response data.

Within that scope, comparison targets include the population regression
slope, residual variance, centered item estimates, and case-level EAP
estimates.

The handoff is explicit: mfrmr prepares the analysis files, the user runs
ConQuest separately, and mfrmr then normalizes the requested exports.

```r
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

`mfrmr` does not execute or control ConQuest, and it does not parse arbitrary
raw ConQuest reports. The user runs ConQuest separately; mfrmr can normalize
the native comparison CSV exports requested by its generated command. The
review reports coordinate-level differences; it does not declare general
software equivalence from a single dataset or tolerance.

The generated ConQuest command uses the fitted mfrmr quadrature-point count;
the bundle records both values. Record the actual ConQuest version, edition,
and run date during normalization so the external comparison remains
reproducible.

This public bundle route does not cover multidimensional models, arbitrary
imported design matrices, bounded `GPCM` latent regression, JML latent
regression, or the full ConQuest plausible-values workflow. Separately, the
item-only bounded-GPCM parameterization can be compared only after the response
kernel, slope grouping, threshold coordinates, latent-scale identification,
retained rows, and category map have been matched. A result in that restricted
overlap does not extend automatically to a multifacet ConQuest generalized-item
design.

The ConQuest overlap bundle is also a controlled analysis bundle. Its long and
wide response files contain person identifiers and responses; the person-data
file contains identifiers and the covariate; and both mfrmr and ConQuest
case-EAP files contain identifiers and person-level estimates. The helper warns
when writing these files and creates `*_privacy_notice.csv`. Store the bundle in
an approved restricted location and pseudonymize or redact it as required
before sharing.

## Model scope

For GPCM, *bounded* refers to the documented model and workflow scope; it does
not mean finite parameter box constraints. Unsupported combinations and
inference states are reported explicitly rather than silently treated as
ordinary estimates.

The package extends Rasch-family RSM/PCM work with MML, modern diagnostics,
reproducibility, network review, and reporting support. It is not a general
FACETS replacement: each `fit_mfrm()` call uses one response-model family and
one observed score scale, and the current public API does not provide mixed
response families, multiple independent rating scales, general threshold
anchoring, or online calibration updates. Portable fixed-calibration artifacts
are available only for one-scale `RSM`/`PCM` `MML` fits under the fixed
standard-normal scoring basis. Posterior scoring from an existing fitted
object is a separate, wider analysis route.

## Portable fixed calibration

An eligible `RSM` or `PCM` `MML` fit can be converted into a versioned
calibration artifact, validated, frozen, saved, and applied to new Persons
without retaining the source fit or training responses:

The following template assumes an eligible `fit`, its original `training_data`,
and `new_responses` with matching facet labels and score coding. The portable
calibration vignette below supplies a complete example defining these objects.

```r
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

Use `mfrm_calibration_capabilities()` for the exact portable support envelope,
and see `vignette("mfrmr-portable-calibration")` for a complete synthetic
example. See `help("mfrm_calibration_methods", package = "mfrmr")` for the
artifact summaries and `help("mfrm_calibration_score_methods",
package = "mfrmr")` for score summaries and plots. Estimated-population and
latent-regression MML, JML, and bounded GPCM
remain fitted-object-only routes; they do not create portable calibration
artifacts in 0.2.4. Artifact scores are posterior EAP values conditional on the
frozen point calibration and recorded prior. Their intervals exclude
calibration-parameter uncertainty, and loading validates consistency rather
than authenticating files from untrusted sources. Review every
`scored_review` or `not_scored` disposition before using estimates. The score
plot is a batch-review display, not evidence that the source calibration fits
or transports to a new population.

Score tables and summaries retain the scoring algorithm and requested interval
level for CSV export. Printed scores and interval plots identify saved
grid-based intervals, whose posterior mass may differ from the requested level.

## Model and interpretation boundaries

| Area | Supported route | Important boundary |
| --- | --- | --- |
| Latent structure | One latent dimension | No multidimensional or Q-matrix engine |
| Facets | Multiple observed facet roles | The design must remain connected for the intended contrasts |
| `RSM` | Shared step structure | The common rating-scale assumption must be substantively defensible |
| `PCM` | Step structure associated with `step_facet` | Specify the step facet explicitly when the default is not intended |
| Bounded `GPCM` | Documented slope-aware core with `slope_facet == step_facet`; MML estimates the common scale by default | Not an unrestricted many-facet GPCM implementation |
| Estimation | `MML` and `JML`/`JMLE` | Estimator choice changes person summaries and residual-fit basis |
| Latent regression | Conditional-normal, unidimensional MML population model | Person scoring requires explicit exploratory review and omits uncertainty in the fitted population parameters |
| Diagnostics | Residual and posterior-averaged marginal screens | A flag is not a deletion, fairness, or validity decision; missing results remain unavailable |
| Residual group comparisons | Differences in observed-minus-expected scores | No residual SEs, p-values, confidence intervals or differential-functioning classifications |
| G/D studies | Observed-score main-effects variance decomposition and design projections | No MFRM latent-scale reliability, full interaction decomposition or cut-score accuracy estimate; variance-estimation uncertainty is omitted |
| Shrinkage | Post-fit adjustment toward zero | Original estimates and predictions are unchanged; descriptive bands omit prior-variance uncertainty and cross-level covariance |
| External imports | Source-scale displays for supported mirt, TAM and eRm fits | No native response-level diagnostics or portable calibration; missing joint covariance is not reconstructed |
| FACETS and ConQuest | Exported-table review within documented overlap | Neither external program is executed by `mfrmr` |

Fitted-object Person scoring is separate from calibration estimation. It
returns posterior EAP under a stated normal prior, including a standard-normal
reference prior when the calibration was fitted by JML. Scores, posterior SDs
and intervals hold calibration and prior parameters fixed. Estimated-population
scoring requires `readiness_policy = "review"`; posterior draws alone do not
justify downstream regression or group inference without a compatible
conditioning model and sampling design. See `?predict_mfrm_units` and
`?sample_mfrm_plausible_values`.

For bounded `GPCM`, inspect the capability table before choosing a downstream
helper:

```r
gpcm_capability_matrix()
vignette("mfrmr-gpcm-scope", package = "mfrmr")
```

Free-slope GPCM fits can be estimation-converged while parameter-level
inference remains review-only. Read `print(fit)`, `summary(fit)$decision`, and
the slope table's `ParameterStatus` and `PrimaryEstimate` before interpreting
the finite optimizer trace in `OptimizerEstimate`. `Optimizer*SE` and
`Optimizer*CI` are diagnostic quantities; ordinary slope SEs and confidence
intervals are currently unavailable for free slopes (`SEEligible = FALSE`,
`CIEligible = FALSE`). Convergence or quadrature stability does not change
that eligibility. The GPCM scope vignette explains each status and the
appropriate next action.

For MML, the default `gpcm_mml_identification = "free_population"` estimates
an intercept-only population distribution while relative slopes satisfy a
geometric-mean-one constraint. The corresponding fixed-latent-SD optimizer
coordinate is retained in `FixedLatentSDOptimizerEstimate`. Use
`gpcm_mml_identification = "fixed_standard_normal"` only when a deliberately
matched legacy or external comparison requires that identification.

The bounded GPCM is an **aligned single-owner relative-slope GPCM**:

$$
\log\frac{P(Y_o=k)}{P(Y_o=k-1)}
 = \alpha_{g(o)}\{\eta_o-\tau_{g(o),k}\},
\qquad \prod_g\alpha_g=1.
$$

Exactly one facet owns both slopes and steps, because
`slope_facet == step_facet`. Setting all slopes to one recovers the
equal-discrimination PCM kernel. This is narrower than the generalized MFRM of
[Uto and Ueno (2020)](https://doi.org/10.1007/s41237-020-00115-7), whose task
and rater slopes enter multiplicatively as `alpha_i * alpha_r` and whose step
owner is stated separately. The current
criterion-owned and rater-owned fits are therefore separate restricted
many-facet GPCM strata, not interchangeable fits of the full Uto--Ueno model.

The selected facet receives one slope per level, not one common slope for the
whole fit. For example, `slope_facet = "Criterion"` estimates a relative slope
for every criterion; `slope_facet = "Rater"` estimates one for every rater.
The other facets retain additive location effects but no slope block. Those
effects are still inside the complete adjacent-category predictor multiplied
by the selected slope; the current kernel is not a loading-only model with
unscaled facet intercepts. Criterion and rater slopes cannot be estimated
simultaneously in this model.

`plot(fit_gpcm, type = "ccc")` and `category_curves_report(fit_gpcm)` retain
the estimated slope for each step-facet level. These are reference-profile
curves, however: additive facet main effects and fitted interactions are fixed
at zero. The native plot facets multiple curve groups instead of overlaying
unlabelled traces, and both native and ggplot displays state the reference
profile condition. Inspect `CurveBasis`, `PredictorOffset`, and
`settings$curve_basis` before interpreting a curve as if it represented a
particular observed Person-by-facet cell.

`fit_mfrm(method = "JML")` uses the observed scores without extreme-score
adjustment or finite-item bias correction. Freely estimated Persons with
all-minimum or all-maximum responses have primary estimates of `-Inf` or
`Inf`; their finite optimizer values are computational traces. Fixed anchors
retain their supplied values, while coupled constraints require separate
review. JML SEs and normal bands remain exploratory.

`fair_average_table(..., xtreme = 0.25)` can produce a finite displayed
`Measure` without refitting. Its `PrimaryMeasure` retains the original fitted
value, and `MeasureBasis` and `ExtremeAdjustment` identify the replacement.
The original SE does not describe that replacement, so measure SEs are
unavailable on adjusted rows. Fair-score calculations do not use this
replacement. When a JML Person measure is infinite, non-Person FairM is
unavailable because its mean Person reference is unbounded. FairZ uses a zero
reference; `FairMReference` records the distinction. This
display option and endpoint placement on a Wright map do not correct JML
bias. In comparisons across software, specify score adjustments and post-fit
corrections separately; a shared "JML" label is insufficient.

The same principle
applies to any GPCM slope whose boundary status has not been resolved: a finite
optimizer iterate is not automatically a finite maximum suitable for ordinary
inference.

PCM and bounded GPCM can be reviewed on the same data with
`compare_mfrm(fit_pcm, fit_gpcm)`, `build_weighting_review(fit_pcm, fit_gpcm)`,
or `build_model_choice_review(..., run_weighting_review = TRUE)`. Selectable
information-criterion ranking requires comparable MML fits with adequate
support for inference on a common quadrature grid with at least 31 points.
Free-slope GPCM fits currently do not satisfy these inference requirements,
so their criteria, when available, are descriptive only. PCM is the
all-unit-slope reduction of the aligned GPCM kernel, but a PCM-versus-GPCM
chi-square LRT is unavailable. The recorded `PCM_in_GPCM_ic_only` relation
does not authorize automatic ranking.

The practical comparison is available without reconstructing the model
matrices manually. After fitting the same data as `fit_pcm` and `fit_gpcm`
(see the GPCM scope vignette), use:

```r
choice <- build_model_choice_review(PCM = fit_pcm, GPCM = fit_gpcm)
choice$model_roles[, c(
  "Model", "StepCoordinates", "FreeStepParameters",
  "SlopeCoordinates", "FreeSlopeParameters",
  "FitReadiness", "FormalInference", "Interpretation"
)]
```

The coordinate columns count reported values; the free-parameter columns also
apply the fitted constraints. `build_weighting_review()` describes changes in
measures and information under discrimination-based weighting. Free-slope
GPCM ranking remains unavailable under MML, and an unpenalized JML likelihood
difference does not justify an automatic PCM-versus-GPCM choice.

Cross-software slope values are not automatically matched estimands. FACETS
does not jointly fit Muraki's free-slope polytomous GPCM. FACETS' reported
element discrimination is a post-fit diagnostic computed after the Rasch
measures and does not feed back into the other estimates; it must not be
treated as a free-GPCM slope estimate
from `mfrmr`. TAM can estimate GPCM
slopes through its 2PL/GPCM MML route, but its many-facet fitting route does
not estimate those slopes. The current `immer` estimation routes provide PCM-
design and hierarchical-rater references rather than a matched free-GPCM fit.
Consequently, FACETS and `immer` are appropriate only for documented
equal-discrimination overlaps or deliberately different-model sensitivity
checks. A TAM GPCM comparison is numerical only after the response kernel,
slope grouping, threshold parameterization, latent-scale identification,
retained rows, category map, and covariance information have been matched.

For strict MML diagnostics, keep the two evidence bases distinct:

```r
diag_both <- diagnose_mfrm(
  fit,
  residual_pca = "none",
  diagnostic_mode = "both"
)

summary(diag_both)$diagnostic_basis
```

The residual route uses person point estimates. The marginal route averages
expectations over Person posteriors conditional on the same responses, with
the calibration held fixed. Its residual scales omit cross-response covariance
and calibration uncertainty. These are complementary descriptive screens;
neither supplies guaranteed individual or multiple-element false-positive rates.

## Updating saved analyses

Installing 0.2.4 does not recalculate saved diagnostics, scores or reports.
Keep the originals and the settings used to create them. First print
`summary(fit)` with the updated package. A native fit lacking the current
estimation checks must be refitted from its original data and settings before
inferential reuse; computing diagnostics alone cannot supply those fit checks.

For a fit that already has current estimation checks, start at the affected
step and rebuild everything that depends on it:

| Saved result | Required action |
| --- | --- |
| Fit-summary wording | Reprint the summary. Stored calculations and missing precision evidence do not change. |
| Diagnostics, QC, fair scores and reports | Recompute diagnostics with the original options, rerun the affected helpers and recreate plots/exports. This includes updated treatment of missing results and SE eligibility. |
| Residual group comparisons or facet equivalence | Recreate residual comparisons from the fit and original group data. Recompute equivalence from an eligible MML fit with matching diagnostics and the original practical bound. |
| G/D studies or shrinkage | Rerun the observed-score G-study and D-study, or reapply shrinkage, using the original settings. The G-study fits a separate mixed model; the MFRM need not be refitted for these corrections. |
| Person scores or plausible values | Re-summarize the original scoring/draw object for updated labels and requested empirical quantiles. To change old grid-endpoint intervals or recover missing prior parameters, rerun scoring from the existing fit. Estimated-population results may require regeneration with explicit review. |
| Portable calibration | A valid saved artifact retains its algorithm. To adopt continuous intervals, create a new artifact through the reviewed calibration workflow and score again. |
| External imports | Re-import the saved source-package fit, then recreate derived output; source-model re-estimation is unnecessary. |
| Simulation/design evaluations | Re-summarize retained runs for corrected denominators. Missing connectivity or workload records require repeating the original evaluation if needed for a recommendation. |

The complete instructions, including function names and exceptions, are in
"Updating saved analyses for 0.2.4" under
`help("mfrmr_workflow_methods", package = "mfrmr")`. [NEWS](NEWS.md) explains
the individual changes. Re-exporting an old derived object does not update
its calculations, and updating an object does not broaden its statistical use.

## Documentation

The package includes the following vignettes:

- [End-to-end workflow](vignettes/mfrmr-workflow.Rmd)
- [MML estimation and marginal-fit diagnostics](vignettes/mfrmr-mml-and-marginal-fit.Rmd)
- [Portable calibration and fresh-session scoring](vignettes/mfrmr-portable-calibration.Rmd)
- [Migrating from FACETS](vignettes/mfrmr-facets-migration.Rmd)
- [Visual diagnostics](vignettes/mfrmr-visual-diagnostics.Rmd)
- [Reporting and APA-oriented output](vignettes/mfrmr-reporting-and-apa.Rmd)
- [Linking and DFF](vignettes/mfrmr-linking-and-dff.Rmd)
- [Bounded GPCM scope](vignettes/mfrmr-gpcm-scope.Rmd)

Open a guide with `vignette("mfrmr-workflow", package = "mfrmr")` or list
them with `browseVignettes("mfrmr")`. A printable API overview is installed
at `cheatsheet/mfrmr-cheatsheet.pdf`. Function-level help starts with
`?fit_mfrm`, `?summary.mfrm_fit`, and `?plot.mfrm_fit`.

## Citation

Use the package citation supplied with the installed version:

```r
citation("mfrmr")
```

The underlying ordered-response models are described by Andrich (1978),
Masters (1982), and Muraki (1992). See the package help and vignettes for the
references relevant to each model and diagnostic route.

## License

`mfrmr` is licensed under the
[MIT License](https://opensource.org/licenses/MIT).

## Acknowledgements

`mfrmr` has benefited from discussion and methodological input from
[Dr. Atsushi Mizumoto](https://mizumot.com/) and
[Dr. Taichi Yamashita](https://kugakujo.kansai-u.ac.jp/html/100000882_en.html).
