# Build a case-level misfit review bundle

Build a case-level misfit review bundle

## Usage

``` r
build_misfit_casebook(
  fit,
  diagnostics = NULL,
  unexpected = NULL,
  displacement = NULL,
  administration_id = NULL,
  wave_id = NULL,
  top_n = 25
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
  for migration of saved diagnostics.

- unexpected:

  Optional output from
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md).

- displacement:

  Optional output from
  [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md).

- administration_id:

  Optional scalar identifier describing the current administration or
  form. It is stored in row-level provenance and summary outputs when
  supplied.

- wave_id:

  Optional scalar identifier for the current wave or occasion. It is
  stored in row-level provenance and summary outputs when supplied.

- top_n:

  Maximum number of rows to keep in compact summary outputs.

## Value

An object of class `mfrm_misfit_casebook`.

## Details

`build_misfit_casebook()` is a synthesis layer over package-native
screening outputs. It does not invent a new misfit statistic. Instead,
it organizes existing evidence families into one case-level review
surface:

- element-level Infit / Outfit MnSq misfit from `diagnostics$fit` (rows
  whose Infit or Outfit MnSq falls outside the configured Linacre
  heuristic review band, 0.5-1.5 by default)

- strict marginal cell screens from `diagnostics$marginal_fit$top_cells`

- strict pairwise screens from
  `diagnostics$marginal_fit$pairwise$top_pairs`

- unexpected responses from
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)

- displacement flags from
  [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)

The result is an operational review bundle. It is not a formal
adjudication system, and repeated signals across evidence families
should be prioritized over any single isolated case row. In addition to
raw case rows, the object includes stable grouping views such as
`by_person`, `by_facet_level`, `by_source_family`, and `by_wave` to
support operational triage. The `source_support` component records which
evidence families are currently supported, caveated, or deferred under
the active model.

## Recommended input route

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Build diagnostics with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

3.  Optionally build
    [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)
    and
    [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)
    yourself when you want custom thresholds before synthesizing the
    casebook.

## GPCM boundary

For `GPCM`, the helper is available with caveat. The casebook inherits
exploratory screening semantics from the underlying residual and strict
marginal sources; it should not be read as a formal inferential case
test.

## Saved-result reuse

Supplied screening results must describe this fitted analysis. Results
from another fit or older results without identity metadata are refused.
See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
to recreate them from the saved fit and matching diagnostics without
refitting the model.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md),
[plot(x, type =
"unexpected")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"displacement")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"marginal_fit")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[plot(x, type =
"marginal_pairwise")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("build_misfit_casebook", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
# A balanced slice retains every Rater and Criterion while running quickly.
toy <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", model = "RSM", quad_points = 5)
diag <- diagnose_mfrm(fit, diagnostic_mode = "both", residual_pca = "none")
casebook <- build_misfit_casebook(fit, diagnostics = diag, top_n = 10)
summary(casebook)
casebook$top_cases
} # }
```
