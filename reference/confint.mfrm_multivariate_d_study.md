# Confidence intervals for dependability and SEM in D-Study plans

Quantify source-G-Study sampling uncertainty in relative `G`, absolute
dependability `Phi`, or measurement `SEM` for prespecified future facet
counts. Future counts do not add source degrees of freedom. Inspect
`Estimate`/`PointStatus` separately from `Lower`/`Upper`/`Status` (an
unavailable negative-variance point can coexist with a valid interval,
and `NA` bounds never denote zero uncertainty).

Read G, Phi and measurement SEM together with their confidence
intervals, methods and limitations. Ordinary `summary(d)` retains its
coefficient-table return value. Request intervals explicitly, or reuse
saved interval results.

Compare future plans on one shared coefficient or SEM axis. Each plan
has adjacent method rows, distinguished by color, point shape and line
type. Method agreement in a single dataset is not evidence of coverage.

## Usage

``` r
# S3 method for class 'mfrm_multivariate_d_study'
confint(
  object,
  parm = "G",
  level = 0.95,
  score = NULL,
  composite = NULL,
  assumption,
  draws = 100000L,
  seed = 1L,
  reference = NULL,
  method = "auto",
  ...
)

# S3 method for class 'mfrm_multivariate_d_study'
summary(
  object,
  intervals = FALSE,
  parm = c("G", "Phi", "RelativeSEM", "AbsoluteSEM"),
  ...
)

# S3 method for class 'summary.mfrm_multivariate_d_study'
print(x, digits = NULL, row.names = FALSE, ...)

# S3 method for class 'mfrm_dstudy_intervals'
plot(
  x,
  draw = TRUE,
  preset = "standard",
  ncol = 2L,
  layout = c("combined", "panels"),
  ...
)
```

## Arguments

- object:

  A result from
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md).

- parm:

  Metrics to calculate when `intervals = TRUE`. The default includes
  `"G"`, `"Phi"`, `"RelativeSEM"` and `"AbsoluteSEM"`. Select fewer
  metrics when only those answer your question, particularly for
  explicitly requested expensive profile methods.

- level:

  Pointwise confidence level in `(0, 1)`.

- score:

  Select either one original `score` name or one named `composite`
  (`"Composite"` for vector weights; defaults to the sole composite or
  first original score).

- composite:

  Select either one original `score` name or one named `composite`
  (`"Composite"` for vector weights; defaults to the sole composite or
  first original score).

- assumption:

  Required `"normal"`, asserting independent normal random Person,
  facet, interaction, and residual effects with constant variances.

- draws:

  Pivotal draw count (`>= 1000`, `>= 100` expected per tail; default
  `100000`) and nonnegative integer seed (`1` default; caller RNG
  restored) for one-facet `Phi` GCI; unused by other methods.

- seed:

  Pivotal draw count (`>= 1000`, `>= 100` expected per tail; default
  `100000`) and nonnegative integer seed (`1` default; caller RNG
  restored) for one-facet `Phi` GCI; unused by other methods.

- reference:

  Optional row index in `object$design_grid` returning each other plan
  minus the reference plan (`NULL` returns individual plans).

- method:

  `"auto"` (default: `"exact_f"` for one-facet `G`, `"gci"` for
  one-facet `Phi` and unchanged-child nested reduction, `"mls"` for
  balanced two-crossed-facet `G`/`Phi` and `SEM`), or an explicit choice
  / compatible comparison vector from:

  - `"mls"`: quadratic Ting (1990) null inversion `h(rho)'lambda = 0`
    for balanced two-crossed-facet `G`/`Phi` (`FormulaComplete = FALSE`
    flags conservatively retained negative-squared-width ranges), or
    Graybill-Wang / Ting error-variance intervals square-rooted for
    `SEM`.

  - `"approximate_f"`: Satterthwaite F inversion
    `(1 - rho)*MS_P / D(rho)` for crossed (Wong & McGraw, 1999) or
    general nested `G`/`Phi` (using expected-mean-square coefficients
    with `m = r/R`, `h = t/T`).

  - `"mean_square_region"`: conservative Charnes-Cooper LP projection
    over the `level^(1/J)` joint chi-square mean-square region
    intersected with `theta >= 0` (`lpSolve` required; supports
    individual plans and shared-region `reference` enclosures).

  - `"score"`: experimental extended-nuisance score inversion
    `T = kappa^2 sum_j 2 h_j^2 lambda_j^2 / df_j <= qchisq(level, 1)`
    for balanced two-crossed-facet `G` (`Empty = TRUE` vs
    `NumericalComplete`).

  - `"reml_profile"`: experimental normal REML deviance inversion
    (`D - D_min <= qchisq(level, 1)`, `lme4`/`minqa`, plus `nloptr` for
    direct multi-count differences) on retained ratings
    (`IntervalCenter` records the separate REML center;
    `CandidateLower/Upper` retain exploratory bounds on numerical
    failure).

  - `"spectral_f"`: exact normal-model F pivot
    `F(t) = {sum(z_i^2 / (1 + lambda_i*t)) / r} / (S_E / nu)` (E,
    Hannig, & Iyer, 2008) after projecting off facet incidence for
    incomplete/balanced one-facet `G` and `reference` differences.

  - `"residual_contrast"`: exact normal-residual chi-square projection
    mapped by `sigma_E / sqrt(m)` for one-facet `RelativeSEM` and
    `reference` differences on balanced or incomplete ratings
    (`IntervalCenter` separate).

  - `"delta"`: first-order sampling SE \\\sqrt{g^\top \hat C g}\\ and
    unclipped normal limits `Estimate +/- z * SE` for individual-plan
    `G`/`Phi` using \\\hat C\\ from
    [`vcov.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md)
    (Almehrizi, 2021; `OutsideParameterSpace` and `AtBoundary` flag
    boundary limits).

- ...:

  Reserved; additional arguments are rejected.

- intervals:

  `FALSE` (default) returns the original coefficient table. `TRUE`
  calculates the selected intervals using
  `confint.mfrm_multivariate_d_study()`. Alternatively supply a saved
  `confint(d)` result or a list of such results. Saved results may
  contain different metrics, methods, scores or reference plans, but
  must match this D-study's source, plans and score weights.
  GENOVA-adjusted results retain adjusted points alongside
  original-source population intervals, with separate `IntervalEstimate`
  and `IntervalBasis`. Saved intervals must match the component
  treatment too.

- x:

  A result from `confint.mfrm_multivariate_d_study()`.

- digits:

  Display precision passed to the printed tables; `NULL` uses R's
  current setting. Stored estimates are unchanged.

- row.names:

  Logical; print table row names? Defaults to `FALSE`.

- draw:

  Logical; `FALSE` returns the plot data without opening a device.

- preset:

  Package plot style, including `"standard"` (color) and `"monochrome"`.
  Methods also have distinct point shapes.

- ncol:

  Positive integer number of columns for `layout = "panels"`. Unused by
  the default combined view.

- layout:

  `"combined"` (default) groups methods within each plan on one axis,
  with a common method legend. `"panels"` retains one panel per future
  plan, with at most `ncol` columns.

## Value

A `data.frame` of class `mfrm_dstudy_intervals` containing plan counts,
`Kind`, `Score`, `Metric`, `Estimate`, `PointStatus`, `Lower`, `Upper`,
`RawRatioLower`/`RawRatioUpper` (balanced F/GCI), `Level`, `Method`,
`Status`, `MethodCode`, `Available`, `NegativeComponent`, and
`Validation`, plus method-specific columns (`SE`, `SamplingVariance`,
`SEStatus`, `AtBoundary`, `OutsideParameterSpace` for `"delta"`;
`FormulaComplete`, `NumericalComplete`, `Empty` for `"mls"`/`"score"`;
`IntervalCenter`, `CandidateLower/Upper` for `"reml_profile"` /
`"residual_contrast"`; `ErrorVariance`, `ErrorVarianceSE`,
`RawVarianceLower/Upper` for MLS `SEM`; `Reference*` for `reference`
contrasts) and portable attributes (`diagnostics`, `pivot`,
`monte_carlo`, `source_summary`, `nesting_context`, `notes`).

With `intervals = FALSE`, the unchanged `object$coefficients` data
frame. Otherwise a `summary.mfrm_multivariate_d_study` list containing:

- `table`: one row per returned plan, metric and method, with `Interval`
  identifying the entry in `intervals`. It retains all original interval
  columns, including point/interval status, qualifications and any
  separate REML or residual-contrast `IntervalCenter`. Columns not
  applicable to a method are `NA`.

- `intervals`: the complete original interval objects, retaining notes,
  diagnostics, reference context and their existing
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods.

- `source_design`, `source_rows`, `design_grid`, `weights` and
  `component_diagnostics`: the original design, score and review
  context.

- `notes`: method qualifications and interpretation reminders.
  [`print()`](https://rdrr.io/r/base/print.html) returns the same saved
  summary invisibly. For G/Phi with `method = "delta"`, the table
  retains and prints the coefficient sampling `SE`, distinct from
  measurement SEM. For GENOVA-adjusted points it is named `IntervalSE`
  and describes the original estimator, not the adjusted point.
  Normal-reference bounds outside `[0,1]` are not clipped.

Invisibly, a `ggplot` object;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains the exact `table`, `unavailable` rows, source `intervals`,
`design_grid`, `weights` and `notes`.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
remains idempotent on the returned object. No title or explanatory
footnote is drawn.

## Details

**One-facet pivots and plan differences.** For observed facet count `k`,
future count `m`, and `R = 1 + k * sigma_P^2 / sigma_E^2`, `"exact_f"`
intersects `(MS_P / MS_E) / F_quantiles` with `R >= 1` before mapping
`G_m = m*(R - 1) / (m*(R - 1) + k)`
(`Status = "Empty parameter-space interval"` if wholly below `1`).
One-facet `"gci"` draws `Q_j = df_j * MS_j / X_j` and evaluates Mondal
et al. (2025, Eq. 11)
`max(0, Q_P - Q_E) / (Q_P + (k/n)*Q_F + (k - 1 - k/n)*Q_E)`, mapping to
`Phi_m = m*rho / (1 + (m - 1)*rho)` (`attr(ci, "monte_carlo")` stores
binomial order-statistic endpoint bands). With `reference` (`a` vs `b`),
shared-ratio methods map the entire base interval for `t` through
`h(t) = (b - a)*t / ((1 + a*t)*(1 + b*t))`, including the interior
stationary point `t = 1 / sqrt(a*b)`, rather than subtracting marginal
endpoints.

**Nested reduction and GENOVA adjustments.** When raters are nested
within tasks and future child counts per parent match the balanced
source count `R`, cell means reduce `G`/`Phi` to the one-facet sampling
law over parent counts; changed child counts require explicit
`"approximate_f"`, `"mean_square_region"`, `"reml_profile"`, or
`"delta"`. For GENOVA-adjusted D-Studies, `Estimate` retains the
adjusted point while `IntervalEstimate` and bounds target the unadjusted
population parameter (`ComponentTreatment`, `IntervalBasis`);
finite-sample interval behavior depends on source degrees of freedom and
rating-plan balance.

The intervals describe uncertainty from the observed G-study in the
population coefficient or SEM of a specified future complete plan. They
do not represent data already collected under that future plan. G and
Phi are dimensionless; SEM is in the selected score's units. A larger
G/Phi or smaller SEM does not alone determine a worthwhile plan:
consider the intended decision, score meaning and task/rater burden.

`reference` requests the selected method's shared-source plan
differences for each metric; this is not subtraction of independently
constructed marginal intervals. For a balanced two-facet source,
explicitly select `method = "mean_square_region"` for conservative
joint-region enclosures. This summary is not an input to
[`recommend_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md),
whose D-study route uses
[mfrm_d_study_comparison](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study_comparison.md).
Positive G/Phi differences and negative SEM differences favor the
comparison plan, conditional on the stated model. Individual-plan and
difference results remain explicitly labeled if both are supplied as
saved results.

Printing and reopening a saved summary do not calculate intervals or
refit models. Printing separates the main estimates, method
qualifications and rows with unavailable points/intervals or incomplete
width formulas; `table` retains all statuses and diagnostics columns. A
completed approximate interval is qualified by its method, not
automatically labeled a failure. Save the complete summary with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) to retain its
context; CSV export of `table` alone loses weights, notes and
diagnostics. Use `plot(s$intervals[[1]])` for its existing forest plot,
or supply a suitable single-metric individual-plan result to
`plot(d, intervals = ...)`. A summary does not create simultaneous
guarantees across metrics, scores or selected plans. Read each method's
qualifications. Availability is not proof of model validity or accurate
finite-sample coverage.

All methods concern the same score/composite, metric and source data. A
filled point has an interval; an open point is an available estimate
without an interval. Unavailable intervals are explicitly labeled in the
combined view, or marked by an asterisk in the panel view, even if their
point estimates are missing. An interval can exist without an admissible
ANOVA/MINQUE point estimate. Missing values remain missing; no
substitute interval or zero is drawn. The shared axis includes `[0,1]`
for coefficients and `[-1,1]` for G/Phi differences, expanding to retain
all finite estimates and accepted bounds. Delta normal-reference bounds
outside `[0,1]` remain visible; they flag limitations of that
approximation, not a larger population parameter space. SEM and
SEM-difference axes instead span the estimates and intervals in score
units, including zero. Negative SEM differences favor the comparison
plan. An SEM interval is uncertainty in measurement error, not an
interval for a Person's score. Chi-square and MLS labels retain the
calculation used for each plan; their assumptions and coverage claims
differ. Method limitations, confidence level, normal-effect assumptions
and negative components remain in the returned notes and source object.
Plotting neither refits a model nor recalculates an interval. Save the
complete interval or plot object with
[`saveRDS()`](https://rdrr.io/r/base/readRDS.html) for later use. Nested
plan labels show child counts per parent, rather than total child pool
sizes; the reference plan uses the same count convention. A
mean-square-region difference is a conservative enclosure from shared
source uncertainty, not a tight joint image or a paired-delta interval.
Its returned source retains the individual projections and reference.
REML profile and residual-contrast rows retain the original source
points; the separate `IntervalCenter` and method diagnostics are
available in the source interval object. A point can lie outside this
separately calculated interval. For GENOVA-adjusted results, points use
the selected component treatment; intervals retain their original-source
population basis. `IntervalEstimate` and `IntervalBasis` in the source
table distinguish them. Drawing the two together does not make the
original sampling SE an adjusted-estimator SE. Unresolved numerical
candidates are retained in the source object but are not drawn as
accepted confidence bounds. For exact-F, score and MLS intervals, an
empty confidence set is labeled `"Empty set"`; it is distinct from an
estimated coefficient of zero. MLS rows with `FormulaComplete = FALSE`
retain candidate values where a squared width is undefined. Their
conservative bounds are drawn, while the saved interval object and notes
retain the reason and affected ranges.

## Choose the operation

`print(d)` displays the D-study and returns it invisibly; `summary(d)`
returns its coefficient table. This opt-in summary collects intervals;
`confint(d)` calculates one metric at a time with the same inference
rules. Neither changes `d`. `print(s)` displays the saved summary
without any estimation, and `s$table` is the data frame for subsetting
or CSV export. Use `plot(d)` for planning curves and
`plot(s$intervals$Phi)` for a saved interval forest. A summary list
itself is not a new plotting input.

This page explains the interface and reading order. Mathematical
constructions, design-specific assumptions, numerical diagnostics and
references are in `confint.mfrm_multivariate_d_study()`.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## References

- Almehrizi, R. S. (2021). *Journal of Educational Measurement*, 58,
  179–210. [doi:10.1111/jedm.12277](https://doi.org/10.1111/jedm.12277)
  .

- Bates, D., Maechler, M., Bolker, B., & Walker, S. (2015). *Journal of
  Statistical Software*, 67(1), 1–48.
  [doi:10.18637/jss.v067.i01](https://doi.org/10.18637/jss.v067.i01) .

- Brennan, R. L. (2001). *Generalizability theory*. Springer.
  [doi:10.1007/978-1-4757-3456-0](https://doi.org/10.1007/978-1-4757-3456-0)
  .

- Drton, M. (2009). *The Annals of Statistics*, 37(2), 979–1012.
  [doi:10.1214/07-AOS571](https://doi.org/10.1214/07-AOS571) .

- E, L., Hannig, J., & Iyer, H. (2008). *JASA*, 103(482), 854–865.
  [doi:10.1198/016214508000000229](https://doi.org/10.1198/016214508000000229)
  .

- Graybill, F. A., & Wang, C.-M. (1980). *JASA*, 75(372), 869–873.

- Mondal, D., Candel, M. J. J. M., Cassese, A., & Vanbelle, S. (2025).
  *Statistics in Medicine*, 44(10–12), e70106.
  [doi:10.1002/sim.70106](https://doi.org/10.1002/sim.70106) .

- Shedden, M., & Ekvall, K. O. (2026).
  [doi:10.48550/arXiv.2610.04181](https://doi.org/10.48550/arXiv.2610.04181)
  .

- Ting, N., Burdick, R. K., Graybill, F. A., Jeyaratnam, S., & Lu,
  T.-F. C. (1990). *J. Stat. Comput. Simul.*, 35(3–4), 135–143.
  [doi:10.1080/00949659008811240](https://doi.org/10.1080/00949659008811240)
  .

- Wong, S. P., & McGraw, K. O. (1999). *Educ. Psychol. Meas.*, 59,
  270–288.
  [doi:10.1177/00131649921969848](https://doi.org/10.1177/00131649921969848)
  .

## See also

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`confint.mfrm_multivariate_gstudy()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_multivariate_gstudy.md),
[mfrm_d_study_comparison](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study_comparison.md)

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
`confint.mfrm_multivariate_d_study()`,
[`plot.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_multivariate_d_study.md),
`plot.mfrm_dstudy_intervals()`

`confint.mfrm_multivariate_d_study()`

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("confint.mfrm_multivariate_d_study", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
g <- mfrm_g_study(tasks, c("V", "W"), rater = NULL)
d <- mfrm_d_study(g, data.frame(Tasks = c(6, 12)),
  weights = c(V = .5, W = .5))
ci <- confint(d, assumption = "normal")
ci[, c("Tasks", "Estimate", "Lower", "Upper", "Status")]
attr(ci, "notes")
# Optional normal approximation: SE describes the coefficient, not measurement SEM.
delta_ci <- confint(d, method = "delta", assumption = "normal")
delta_ci[, c("Tasks", "Estimate", "SE", "Lower", "Upper", "SEStatus")]
phi_ci <- confint(d, parm = "Phi", assumption = "normal", seed = 1)
phi_ci[, c("Tasks", "Estimate", "Lower", "Upper", "Status")]
attr(phi_ci, "monte_carlo")$endpoint_bands
# How much would G improve by changing from six to twelve tasks?
change <- confint(d, parm = "G", reference = 1, assumption = "normal")
change[, c("Tasks", "ReferenceCount", "Estimate", "Lower", "Upper", "Status")]
# The same planning question for absolute dependability; coverage is approximate.
phi_change <- confint(d, parm = "Phi", reference = 1, assumption = "normal")
phi_change[, c("Tasks", "ReferenceCount", "Estimate", "Lower", "Upper", "Status")]
attr(phi_change, "monte_carlo")$endpoint_bands
# Sampling uncertainty in measurement SEM, rather than in G or Phi.
sem_ci <- confint(d, parm = "AbsoluteSEM", assumption = "normal")
sem_ci[, c("Tasks", "Estimate", "Lower", "Upper", "Method", "Status")]
sem_change <- confint(d, parm = "RelativeSEM", reference = 1,
                      assumption = "normal")
sem_change[, c("Tasks", "Estimate", "Lower", "Upper", "Status")]
sem_plot <- plot(d, type = "sem", metric = "AbsoluteSEM", intervals = TRUE,
                 assumption = "normal", draw = FALSE)
plot_data(sem_plot, "notes")
# Different raters serve each task; retain three raters per task.
data("mfrmr_example_gtheory_nested", package = "mfrmr")
gn <- mfrm_g_study(mfrmr_example_gtheory_nested,
  c("Content", "Organization"), nesting = c(Rater = "Task"))
dn <- mfrm_d_study(gn,
  data.frame(Raters = 3, Tasks = c(6, 12)))
nested_change <- confint(dn, parm = "G", reference = 1, assumption = "normal")
nested_change[, c("Raters", "Tasks", "ReferenceCount", "Estimate", "Lower", "Upper")]
attr(nested_change, "nesting_context")
# Incomplete one-facet ratings: relative SEM without likelihood fitting.
observed <- tasks[(tasks$Person + tasks$Task) %% 3 != 0, ]
sparse_g <- mfrm_g_study(observed, "V", rater = NULL, method = "minque0")
sparse_d <- mfrm_d_study(sparse_g, data.frame(Tasks = c(6, 12)))
residual_sem <- confint(sparse_d, parm = "RelativeSEM",
  method = "residual_contrast", assumption = "normal")
residual_sem[, c("Tasks", "Estimate", "IntervalCenter", "Lower", "Upper", "Status")]
residual_change <- confint(sparse_d, parm = "RelativeSEM", reference = 1,
  method = "residual_contrast", assumption = "normal")
residual_change[, c("Tasks", "Estimate", "IntervalCenter", "Lower", "Upper")]
# Relative G also uses Person variation; normal Person effects are required.
spectral_g <- confint(sparse_d, method = "spectral_f", assumption = "normal")
spectral_g[, c("Tasks", "Estimate", "Lower", "Upper", "Status")]
spectral_change <- confint(sparse_d, method = "spectral_f", reference = 1,
  assumption = "normal")
spectral_change[, c("Tasks", "Estimate", "Lower", "Upper")]
# A separate experimental REML model can address G/Phi or absolute SEM.
if (requireNamespace("lme4", quietly = TRUE) && requireNamespace("minqa", quietly = TRUE)) {
  profile_ci <- confint(sparse_d, method = "reml_profile", assumption = "normal")
  profile_ci[, c("Tasks", "Estimate", "IntervalCenter", "Lower", "Upper", "Validation")]
  attr(profile_ci, "notes")
  # Uncertainty in absolute measurement SEM, in score units.
  profile_sem <- confint(sparse_d, parm = "AbsoluteSEM",
                         method = "reml_profile", assumption = "normal")
  plot(sparse_d, type = "sem", metric = "AbsoluteSEM", intervals = profile_sem,
       draw = FALSE)
  # How much does doubling the task count change G?
  profile_change <- confint(sparse_d, reference = 1,
    method = "reml_profile", assumption = "normal")
  profile_change[, c("Tasks", "Estimate", "IntervalCenter", "Lower", "Upper")]
  attr(profile_change, "base_interval")
  plot(profile_change, draw = FALSE)
}
# Start with the default two-crossed-facet approximation on bundled data.
data("mfrmr_example_gtheory_crossed", package = "mfrmr")
crossed <- mfrm_g_study(mfrmr_example_gtheory_crossed,
  c("Content", "Organization"))
future <- mfrm_d_study(crossed,
  data.frame(Raters = c(2, 4), Tasks = c(6, 12)),
  weights = c(Content = .5, Organization = .5))
crossed_ci <- confint(future, parm = "Phi", assumption = "normal")
crossed_ci[, c("Raters", "Tasks", "Estimate", "Lower", "Upper",
               "FormulaComplete", "Status")]
attr(crossed_ci, "notes")
# The score method remains an explicit experimental comparison for G.
score_ci <- confint(future, method = "score", assumption = "normal")
score_ci[, c("Scenario", "Estimate", "Lower", "Upper", "Empty", "Status")]
# Vary task counts within each rater count to obtain planning-curve ribbons.
curve_plans <- mfrm_d_study(crossed,
  expand.grid(Raters = c(2, 4), Tasks = c(3, 6, 12)),
  weights = c(Content = .5, Organization = .5))
score_curve <- plot(curve_plans, metric = "G", intervals = TRUE,
  method = "score", assumption = "normal", draw = FALSE)
plot_data(score_curve, "notes")
if (requireNamespace("lpSolve", quietly = TRUE)) {
  comparison <- confint(future, parm = "Phi", assumption = "normal",
    method = c("mls", "approximate_f", "mean_square_region"))
  comparison[, c("Scenario", "Method", "Lower", "Upper", "Status")]
  figure <- plot(comparison, draw = FALSE)
  plot_data(figure, "notes")
  if (requireNamespace("ggplot2", quietly = TRUE)) as_ggplot(figure)
  # General nested comparison: both counts change, with eighteen ratings.
  general_nested <- mfrm_d_study(gn,
    data.frame(Raters = c(3, 2, 6), Tasks = c(6, 9, 3)))
  nested_region <- confint(general_nested, parm = "Phi", reference = 1,
    method = "mean_square_region", assumption = "normal")
  nested_region[, c("Raters", "Tasks", "Estimate", "Lower", "Upper", "Status")]
  attr(nested_region, "reference")$counts
}
} # }
# Optional workflow; run the example explicitly as shown below.
# example("summary.mfrm_multivariate_d_study", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Published synthetic data, not empirical speech-contest records.
ratings <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
g <- mfrm_g_study(ratings, c("V", "W"), rater = NULL)
d <- mfrm_d_study(g, data.frame(Tasks = c(6, 12)),
  weights = c(V = .5, W = .5))
# Compare dependability and measurement error under the normal-effects model.
s <- summary(d, intervals = TRUE, assumption = "normal")
print(s, digits = 3)
# One row per plan for absolute dependability; the complete table is retained.
subset(s$table, Metric == "Phi",
  select = c(Tasks, Estimate, Lower, Upper, Status))
# Reuse an interval for a curve, with no interval calculation.
p <- plot(d, metric = "Phi", intervals = s$intervals$Phi, draw = FALSE)
plot_data(p, "notes")
} # }
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_dstudy_intervals", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
tasks <- read.csv(system.file("extdata", "mgenova-table12.csv", package = "mfrmr"))
g <- mfrm_g_study(tasks, c("V", "W"), rater = NULL)
d <- mfrm_d_study(g, data.frame(Tasks = c(6, 12)))
ci <- confint(d, assumption = "normal")
p <- plot(ci, draw = FALSE)
plot_data(p, "notes")
if (requireNamespace("ggplot2", quietly = TRUE)) as_ggplot(p)
} # }
```
