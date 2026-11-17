# Run a legacy-compatible estimation workflow wrapper

This workflow uses legacy-compatible defaults (`model = "RSM"`,
`method = "JML"`), while allowing users to choose compatible estimation
options.

## Usage

``` r
run_mfrm_facets(
  data,
  person = NULL,
  facets = NULL,
  score = NULL,
  weight = NULL,
  keep_original = FALSE,
  model = c("RSM", "PCM"),
  method = c("JML", "JMLE", "MML"),
  step_facet = NULL,
  anchors = NULL,
  group_anchors = NULL,
  noncenter_facet = "Person",
  dummy_facets = NULL,
  positive_facets = NULL,
  quad_points = 15,
  maxit = 400,
  reltol = 1e-09,
  optimizer = c("auto", "BFGS", "L-BFGS-B"),
  mml_engine = c("direct", "em", "hybrid"),
  top_n_interactions = 20L,
  mml_integration = c("fixed", "adaptive"),
  centering_scope = c("facet", "remainder", "anchor_origin")
)

# S3 method for class 'mfrm_facets_run'
summary(object, digits = 3, top_n = 10, ...)

# S3 method for class 'mfrm_facets_run'
plot(x, y = NULL, type = c("fit", "qc"), ...)
```

## Arguments

- data:

  A data.frame in long format.

- person:

  Optional person column name. If `NULL`, guessed from names.

- facets:

  Optional facet column names. If `NULL`, inferred from remaining
  columns after person/score/weight mapping.

- score:

  Optional score column name. If `NULL`, guessed from names.

- weight:

  Optional weight column name.

- keep_original:

  Passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- model:

  MFRM model (`"RSM"` default, or `"PCM"`).

- method:

  Estimation method (`"JML"` default; `"JMLE"` and `"MML"` also
  supported).

- step_facet:

  Step facet for PCM mode; passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- anchors:

  Optional anchor table (data.frame).

- group_anchors:

  Optional group-anchor table (data.frame).

- noncenter_facet:

  Non-centered facet passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- dummy_facets:

  Optional dummy facets fixed at zero.

- positive_facets:

  Optional facets with positive orientation.

- quad_points:

  Quadrature points for MML; passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- maxit:

  Maximum optimizer iterations.

- reltol:

  Relative optimizer tolerance passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  The default is `1e-9`.

- optimizer:

  Direct optimizer passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  `"auto"` selects L-BFGS-B for MML and JML fits with at least 200 free
  parameters, and BFGS for smaller JML fits.

- mml_engine:

  MML optimization engine passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Applies only when `method = "MML"`.

- top_n_interactions:

  Number of rows for interaction diagnostics.

- mml_integration:

  MML integration mode passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md):
  `"fixed"` (default) or `"adaptive"`. Adaptive integration requires the
  direct MML engine.

- centering_scope:

  Whole-facet (default), legacy remainder, or explicit
  direct/group-anchor-origin centering for ordinary additive RSM/PCM
  JML; passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- object:

  Output from `run_mfrm_facets()`.

- digits:

  Number of digits for numeric rounding in summaries.

- top_n:

  Maximum rows shown in nested preview tables.

- ...:

  Additional arguments passed to the selected plot function.

- x:

  A `mfrm_facets_run` object from `run_mfrm_facets()`.

- y:

  Unused.

- type:

  Plot route: `"fit"` delegates to
  [`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
  and `"qc"` delegates to [plot(x, type =
  "qc")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md).

## Value

A list with components:

- `fit`:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  result

- `diagnostics`:
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  result

- `iteration`:
  [mfrm_report_iterations](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  result

- `fair_average`:
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  result

- `rating_scale`:
  [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md)
  result

- `run_info`: run metadata table

- `mapping`: resolved column mapping

An object of class `summary.mfrm_facets_run`.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): A `ggplot`
object. The `"fit"` route composes Wright, pathway and category curves;
`plot_data(p, "wright_map")` extracts the saved Wright payload, whose
`locations` component contains facet points.

## Details

`run_mfrm_facets()` is intended as a one-shot workflow helper: fit -\>
diagnostics -\> key report tables. Returned objects can be inspected
with [`summary()`](https://rdrr.io/r/base/summary.html) and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html).

This method returns a compact cross-object summary that combines:

- model overview (`object$fit$summary`)

- resolved column mapping

- run settings (`run_info`)

- nested summaries of `fit` and `diagnostics`

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
outputs from a legacy-compatible workflow run

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): This
method is a router for fast visualization from a one-shot workflow
result:

- `type = "fit"` for model-level displays.

- `type = "qc"` for multi-panel quality-control diagnostics.

## Estimation-method notes

- `method = "JML"` (default): legacy-compatible joint estimation route;
  the default preserves the FACETS-style output continuity that existing
  one-shot scripts expect. For new analysis scripts, use
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  and select the estimator for its assumptions and target. MML
  integrates abilities under a specified population model; JML treats
  them as fixed parameters and has incidental-parameter limitations.
  Availability of posterior SDs alone does not justify choosing MML.

- `method = "JMLE"`: backward-compatible input alias for the JML route;
  fitted objects and generated outputs use the canonical `"JML"` label.

- `method = "MML"`: marginal maximum likelihood route using
  `quad_points`. Use `mml_engine = "em"` or `"hybrid"` only for `RSM` /
  `PCM` fits when you want the staged MML alternatives.

`model = "PCM"` is supported; set `step_facet` when facet-specific step
structure is needed.

## Visualization

- `plot(out, type = "fit")` delegates to
  [`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
  and returns fit-level visual bundles (e.g., Wright/pathway/CCC).

- `plot(out, type = "qc")` delegates to [plot(x, type =
  "qc")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
  and returns a QC dashboard plot object.

## Interpreting output

Start with `summary(out)`:

- check convergence and iteration count in `overview`.

- confirm resolved columns in `mapping`.

Then inspect:

- `out$rating_scale` for category/threshold behavior.

- `out$fair_average` for observed-vs-model scoring tendencies.

- `out$diagnostics` for misfit/reliability/interactions.

&nbsp;

- `overview`: convergence, scale size, and the canonical/legacy
  information-criterion contract status.

- `mapping`: sanity check for auto/explicit column mapping.

- `fit` / `diagnostics`: drill-down summaries for reporting decisions.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

Returns the plotting object produced by the delegated route:
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `"fit"` and [plot(x, type =
"qc")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `"qc"`.

## Typical workflow

1.  Run `run_mfrm_facets()` with explicit column mapping.

2.  Check `summary(out)` and `summary(out$diagnostics)`.

3.  Visualize with `plot(out, type = "fit")` and
    `plot(out, type = "qc")`.

4.  Export selected tables for reporting (`out$rating_scale`,
    `out$fair_average`).

&nbsp;

1.  Run `run_mfrm_facets()` to execute a one-shot pipeline.

2.  Inspect with `summary(out)` for mapping and convergence checks.

3.  Review nested objects (`out$fit`, `out$diagnostics`) as needed.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

1.  Run `run_mfrm_facets()`.

2.  Start with `plot(out, type = "fit", draw = FALSE)`.

3.  Continue with `plot(out, type = "qc", draw = FALSE)` for
    diagnostics.

## Preferred route for new analyses

For new scripts, prefer the package-native route:
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
-\>
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
-\>
[mfrm_report_checklist](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
-\>
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).
Use `run_mfrm_facets()` when you specifically need the legacy-compatible
one-shot wrapper.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[mfrm_report_iterations](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

`run_mfrm_facets()`,
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md),
[`summary()`](https://rdrr.io/r/base/summary.html)

`run_mfrm_facets()`,
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"qc")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("run_mfrm_facets", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]

# Legacy-compatible default: RSM + JML
out <- run_mfrm_facets(
  data = toy_small,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  maxit = 30
)
out$fit$summary[, c("Model", "Method", "MethodUsed")]
s <- summary(out)
s$overview[, c("Model", "Method", "Converged")]
p_fit <- plot(out, type = "fit", draw = FALSE)
plot_data(plot_data(p_fit, "wright_map"), "locations")

# Optional: MML route
if (interactive()) {
  out_mml <- run_mfrm_facets(
    data = toy_small,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    quad_points = 5,
    maxit = 30
  )
  out_mml$fit$summary[, c("Model", "Method", "MethodUsed")]
}
} # }
# Optional workflow; run the example explicitly as shown below.
# example("summary.mfrm_facets_run", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:8], , drop = FALSE]
out <- run_mfrm_facets(
  data = toy_small,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  maxit = 30
)
s <- summary(out)
s$overview[, c("Model", "Method", "Converged")]
s$mapping
} # }
# Long-running workflow; run explicitly when needed.
# example("plot.mfrm_facets_run", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
out <- run_mfrm_facets(
  data = toy_small,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  maxit = 30
)
p_fit <- plot(out, type = "fit", draw = FALSE)
plot_data(plot_data(p_fit, "wright_map"), "locations")
p_qc <- plot(out, type = "qc", draw = FALSE)
plot_data(p_qc)$plot

} # }
```
