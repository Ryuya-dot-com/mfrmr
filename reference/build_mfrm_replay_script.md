# Build a package-native replay script for an MFRM analysis

Build a package-native replay script for an MFRM analysis

## Usage

``` r
build_mfrm_replay_script(
  fit,
  diagnostics = NULL,
  bias_results = NULL,
  population_prediction = NULL,
  unit_prediction = NULL,
  plausible_values = NULL,
  data_file = "your_data.csv",
  fit_person_data_file = NULL,
  script_mode = c("auto", "fit", "facets"),
  include_bundle = FALSE,
  bundle_dir = "analysis_bundle",
  bundle_prefix = "mfrmr_replay"
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
  When `NULL`, diagnostics are reused from
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  when available, otherwise recomputed.

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  or a named list of bias bundles. When supplied, the generated script
  includes package-native bias estimation calls.

- population_prediction:

  Optional output from
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
  to recreate in the generated script.

- unit_prediction:

  Optional output from
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  to recreate in the generated script.

- plausible_values:

  Optional output from
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  to recreate in the generated script.

- data_file:

  Path to the analysis data file used in the generated script.

- fit_person_data_file:

  Optional CSV filename to read for the fit-level latent-regression
  replay person table. When `NULL`, the replay script embeds that table
  inline.
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  uses this to keep replay scripts portable while avoiding large inline
  literals.

- script_mode:

  One of `"auto"`, `"fit"`, or `"facets"`. `"auto"` uses
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  when the input object came from that workflow.

- include_bundle:

  If `TRUE`, append an
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  call to the generated script.

- bundle_dir:

  Output directory used when `include_bundle = TRUE`.

- bundle_prefix:

  Prefix used by the generated bundle exporter call.

## Value

A named list with class `mfrm_replay_script`.

## Details

This helper mirrors the Streamlit app's reproducible-download idea, but
uses `mfrmr`'s installed API rather than embedding a separate estimation
engine. The generated script assumes the user has the package installed
and provides a data file at `data_file`.

Anchor and group-anchor constraints are embedded directly from the
fitted object's stored configuration, so the script can replay anchored
analyses without manual table reconstruction.

When the supplied fit uses the latent-regression `MML` branch, the
generated fit-mode script also carries the stored replay-ready person
table together with the corresponding `population_formula` / `person_id`
/ `population_policy` arguments needed to recreate the population model.
By default that replay-ready table is embedded inline; when
`fit_person_data_file` is supplied, the generated script reads it from
that sidecar CSV relative to the replay script location.

For bounded `GPCM`, replay scripts are available with an explicit
`gpcm_boundary` table. The generated script records `step_facet` and
`slope_facet` settings, but full FACETS score-side contract review
remains outside this replay contract. Role-based design forecasting is
available through
[`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md)
as a separate caveated helper route.

## When to use this

Use `build_mfrm_replay_script()` when you want a package-native recipe
that another analyst can rerun later. Compared with related helpers:

- [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md)
  records settings but does not run anything.

- `build_mfrm_replay_script()` produces executable R code.

- [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
  can optionally write the replay script to disk.

## Interpreting output

The returned object contains:

- `summary`: a one-row overview of the chosen replay mode and whether
  bundle export was included

- `script`: the generated R code as a single string

- `anchors` and `group_anchors`: the exact stored constraints that were
  embedded into the script

If `ScriptMode` is `"facets"`, the script replays the higher-level
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
workflow. If it is `"fit"`, the script uses
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
directly.

## Mode guide

- `"auto"` is the safest default and follows the structure of the
  supplied object.

- `"fit"` is useful when you want a minimal script centered on
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- `"facets"` is useful when you want to preserve the higher-level
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)
  workflow, including stored column mapping.

## Typical workflow

1.  Finalize a fit and diagnostics object.

2.  Generate the replay script with the path you want users to read
    from.

3.  Write `replay$script` to disk, or let
    [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
    do it for you.

4.  Rerun the script in a fresh R session to confirm reproducibility.

## See also

[`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
replay <- build_mfrm_replay_script(fit, data_file = "your_data.csv")
replay$summary[, c("ScriptMode", "ResidualPCA", "BiasPairs")]
cat(substr(replay$script, 1, 120))
}
```
