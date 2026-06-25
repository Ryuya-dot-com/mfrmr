# Run a legacy-compatible estimation workflow wrapper

This helper mirrors `mfrmRFacets.R` behavior as a package API and keeps
legacy-compatible defaults (`model = "RSM"`, `method = "JML"`), while
allowing users to choose compatible estimation options.

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
  reltol = 1e-06,
  mml_engine = c("direct", "em", "hybrid"),
  top_n_interactions = 20L
)

mfrmRFacets(
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
  reltol = 1e-06,
  mml_engine = c("direct", "em", "hybrid"),
  top_n_interactions = 20L
)
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

  Optimization tolerance.

- mml_engine:

  MML optimization engine passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Applies only when `method = "MML"`.

- top_n_interactions:

  Number of rows for interaction diagnostics.

## Value

A list with components:

- `fit`:
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  result

- `diagnostics`:
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  result

- `iteration`:
  [`estimation_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimation_iteration_report.md)
  result

- `fair_average`:
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  result

- `rating_scale`:
  [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md)
  result

- `run_info`: run metadata table

- `mapping`: resolved column mapping

## Details

`run_mfrm_facets()` is intended as a one-shot workflow helper: fit -\>
diagnostics -\> key report tables. Returned objects can be inspected
with [`summary()`](https://rdrr.io/r/base/summary.html) and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Estimation-method notes

- `method = "JML"` (default): legacy-compatible joint estimation route;
  the default preserves the FACETS-style output continuity that existing
  one-shot scripts expect. For new analysis scripts, prefer
  `fit_mfrm(..., method = "MML")` – MML is the package-wide recommended
  route because person parameters are integrated out under an N(0, 1)
  prior and per-person posterior SEs are available.

- `method = "JMLE"`: explicit JMLE label; internally equivalent to JML
  route.

- `method = "MML"`: marginal maximum likelihood route using
  `quad_points`. Use `mml_engine = "em"` or `"hybrid"` only for `RSM` /
  `PCM` fits when you want the staged MML alternatives.

`model = "PCM"` is supported; set `step_facet` when facet-specific step
structure is needed.

## Visualization

- `plot(out, type = "fit")` delegates to
  [`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
  and returns fit-level visual bundles (e.g., Wright/pathway/CCC).

- `plot(out, type = "qc")` delegates to
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
  and returns a QC dashboard plot object.

## Interpreting output

Start with `summary(out)`:

- check convergence and iteration count in `overview`.

- confirm resolved columns in `mapping`.

Then inspect:

- `out$rating_scale` for category/threshold behavior.

- `out$fair_average` for observed-vs-model scoring tendencies.

- `out$diagnostics` for misfit/reliability/interactions.

## Typical workflow

1.  Run `run_mfrm_facets()` with explicit column mapping.

2.  Check `summary(out)` and `summary(out$diagnostics)`.

3.  Visualize with `plot(out, type = "fit")` and
    `plot(out, type = "qc")`.

4.  Export selected tables for reporting (`out$rating_scale`,
    `out$fair_average`).

## Preferred route for new analyses

For new scripts, prefer the package-native route:
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
-\>
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
-\>
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
-\>
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).
Use `run_mfrm_facets()` when you specifically need the legacy-compatible
one-shot wrapper.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`estimation_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimation_iteration_report.md),
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
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
p_fit$wright_map$data$plot

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
```
