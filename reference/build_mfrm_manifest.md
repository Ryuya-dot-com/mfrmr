# Build a reproducibility manifest for an MFRM analysis

Build a reproducibility manifest for an MFRM analysis

## Usage

``` r
build_mfrm_manifest(
  fit,
  diagnostics = NULL,
  bias_results = NULL,
  population_prediction = NULL,
  unit_prediction = NULL,
  plausible_values = NULL,
  include_person_anchors = FALSE,
  data = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When `NULL`, diagnostics are computed with `residual_pca = "none"`.

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  or a named list of bias bundles.

- population_prediction:

  Optional output from
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md).

- unit_prediction:

  Optional output from
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).

- plausible_values:

  Optional output from
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md).

- include_person_anchors:

  If `TRUE`, include person measures in the exported anchor table.

- data:

  Optional original analysis data frame. When supplied, the manifest's
  `input_hash` row for `data` is computed against the user's untouched
  input rather than the package's internal `prep$data` (which carries
  synthesised `Weight` / `score_k` columns) so the recorded fingerprint
  matches what [`read.csv()`](https://rdrr.io/r/utils/read.table.html)
  will produce in a replay session.

## Value

A named list with class `mfrm_manifest`.

## Details

This helper captures the package-native equivalent of the Streamlit
app's configuration export. It summarizes analysis settings, source
columns, anchoring information, and which downstream outputs are
currently available.

## When to use this

Use `build_mfrm_manifest()` when you want a compact, machine-readable
record of how an analysis was run. Compared with related helpers:

- [`export_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm.md)
  writes analysis tables only.

- `build_mfrm_manifest()` records settings and available outputs.

- [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md)
  creates an executable R script.

- [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  writes a shareable folder of files.

## Output

The returned bundle has class `mfrm_manifest` and includes:

- `summary`: one-row analysis overview

- `environment`: package/R/platform metadata

- `model_settings`: key-value model settings table

- `source_columns`: key-value data-column table

- `estimation_control`: key-value optimizer settings table

- `anchor_summary`: facet-level anchor summary

- `anchors`: machine-readable anchor table

- `hierarchical_review`: retained traceability table for hierarchical /
  small-sample design flags

- `missing_recoding`: retained traceability table for missing-code
  recoding

- `shrinkage_review`: retained traceability table for shrinkage settings

- `available_outputs`: availability table for
  diagnostics/bias/PCA/prediction outputs

- `dependencies`, `input_hash`, and `session_info`: reproducibility
  metadata tables

- `settings`: manifest build settings

## Interpreting output

The `summary` table is the direct place to confirm that you are looking
at the intended analysis. The `model_settings`, `source_columns`, and
`estimation_control` tables are designed for reproducibility records and
method write-up. Active latent-regression fits also record their
population-model provenance there, including the fitted scoring basis,
stored `population_formula`, and person-level contract used by the
fitted population model. When categorical background variables are
expanded through
[`stats::model.matrix()`](https://rdrr.io/r/stats/model.matrix.html),
`population_xlevel_variables` and `population_contrast_variables`
identify the variables whose fitted coding must be preserved for
replay/scoring. The `available_outputs` table is especially useful
before building bundles, because it tells you whether residual PCA,
anchors, bias results, or prediction-side artifacts are already
available. A practical reading order is `summary` first,
`available_outputs` second, and `anchors` last when reproducibility
depends on fixed constraints.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    or
    [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md).

2.  Compute diagnostics once with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    if you want explicit control over residual PCA.

3.  Build a manifest and inspect `summary` plus `available_outputs`.

4.  If you need files on disk, pass the same objects to
    [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md).

For bounded `GPCM` fits, the manifest is available with an explicit
`gpcm_boundary` table. It records supported direct diagnostics/reporting
surfaces while keeping full FACETS score-side contract review blocked
and routing design forecasting through its separate caveated capability
row.

## See also

[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
manifest <- build_mfrm_manifest(fit, diagnostics = diag)
manifest$summary[, c("Model", "Method", "Observations", "Facets")]
manifest$available_outputs[, c("Component", "Available")]
}
```
