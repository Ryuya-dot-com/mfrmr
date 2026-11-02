# Import an external IRT fit (`mirt`, `TAM`, or `eRm`) to an mfrmr-compatible bundle

Extracts item, step, and person parameters from a supported
unidimensional
[`mirt::mirt()`](https://philchalmers.github.io/mirt/reference/mirt.html),
[`TAM::tam.mml()`](https://rdrr.io/pkg/TAM/man/tam.mml.html),
[`TAM::tam.mml.mfr()`](https://rdrr.io/pkg/TAM/man/tam.mml.html),
[`eRm::RM()`](https://rdrr.io/pkg/eRm/man/RM.html),
[`eRm::PCM()`](https://rdrr.io/pkg/eRm/man/PCM.html), or
[`eRm::RSM()`](https://rdrr.io/pkg/eRm/man/RSM.html) fit and returns an
`mfrm_imported_fit` object with the public slots `summary`,
`facets$person`, `facets$others`, `steps`, `config`, and `source`
expected by measurement-side
[`summary()`](https://rdrr.io/r/base/summary.html) and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) helpers.

## Usage

``` r
import_irt_fit(
  fit,
  model = c("RSM", "PCM", "GPCM"),
  item_facet = "Item",
  compute_fit = FALSE,
  source = c("auto", "mirt", "tam", "erm")
)

# S3 method for class 'mfrm_imported_fit'
summary(object, digits = 3L, ...)

# S3 method for class 'summary.mfrm_imported_fit'
print(x, ...)
```

## Arguments

- fit:

  A fitted object from
  [`mirt::mirt()`](https://philchalmers.github.io/mirt/reference/mirt.html)
  (`SingleGroupClass`),
  [`TAM::tam.mml()`](https://rdrr.io/pkg/TAM/man/tam.mml.html) /
  [`TAM::tam.mml.mfr()`](https://rdrr.io/pkg/TAM/man/tam.mml.html), or
  [`eRm::RM()`](https://rdrr.io/pkg/eRm/man/RM.html) /
  [`eRm::PCM()`](https://rdrr.io/pkg/eRm/man/PCM.html) /
  [`eRm::RSM()`](https://rdrr.io/pkg/eRm/man/RSM.html).

- model:

  Declared response model: one of `"RSM"`, `"PCM"`, or `"GPCM"`. The
  importer does not reconstruct all source constraints; pass the model
  that was estimated. Non-unit `mirt` or `TAM` slopes require `"GPCM"`.
  A polytomous `"RSM"` import from `mirt` requires source item type
  `"rsm"`. For `eRm`, pass `"PCM"` or `"RSM"` matching `fit$model`
  (either is accepted for binary `RM`; `"GPCM"` and linear extensions
  are unsupported).

- item_facet:

  Name to assign to the item facet in the imported bundle (default
  `"Item"`). Ignored when importing a multi-facet `tam.mml.mfr` fit,
  whose combined response conditions are labelled `"DesignCell"`.

- compute_fit:

  Logical. When `TRUE` for `mirt` or `TAM` imports, compute source Infit
  / Outfit statistics
  ([`mirt::itemfit()`](https://philchalmers.github.io/mirt/reference/itemfit.html) +
  [`mirt::personfit()`](https://philchalmers.github.io/mirt/reference/personfit.html),
  or
  [`TAM::msq.itemfit()`](https://rdrr.io/pkg/TAM/man/msq.itemfit.html) +
  [`TAM::tam.personfit()`](https://rdrr.io/pkg/TAM/man/tam.personfit.html))
  and attach a measurement-side `mfrm_diagnostics` bundle. Default
  `FALSE`. Not supported for `eRm` imports.

- source:

  Source package adapter: `"auto"` (default, detected from the class of
  `fit`), `"mirt"`, `"tam"`, or `"erm"`.

- object, x:

  An imported measurement bundle.

- digits:

  Number of digits for displayed estimates.

- ...:

  Additional arguments (unused by imported summaries).

## Value

An `mfrm_imported_fit` object. Slots:

- `summary`:

  Model / method / source / N / LogLik / AIC / BIC (with explicit
  `Native*` provenance and `ICEligible = FALSE` on `TAM` imports).

- `facets$person`:

  Person ID, Estimate, SE, Extreme, plus available fit columns when
  `compute_fit = TRUE`.

- `facets$others`:

  Item or design-cell estimates (and slopes for `mirt` / `TAM`,
  transformed SEs where available), plus fit statistics when
  `compute_fit = TRUE`.

- `steps`:

  Absolute adjacent-category thresholds on the source ability scale,
  labelled in `Parameterization`; these are not centered step
  deviations.

- `config`:

  List with declared `model`, `method`, `facet_names`, and `source`
  metadata.

- `diagnostics`:

  `mfrm_diagnostics`-shape bundle when `compute_fit = TRUE`; `NULL`
  otherwise.

- `source`:

  Source package version, scale convention, person scoring basis, and
  native parameter tables where applicable.

## Source scale

Item difficulty is the mean of its absolute adjacent-category
thresholds, and source scale identification and slopes are retained
without rescaling:

- **`mirt`:** Unidimensional `Rasch`, `2PL`, `gpcm`, `gpcmIRT`, and
  `rsm` items with positive slopes and ordinary `0..(K-1)` category
  scores are supported; graded-response, guessing, custom-scoring, and
  multidimensional models are refused. For `gpcmIRT` and `rsm`, the
  category offset is included as `b - c / a`. Person estimates are EAP
  with conditional posterior SDs in `SE`.

- **`TAM`:** Unidimensional MML fits (`tam.mml`, `tam.mml.mfr`) with
  positive constant adjacent-category slopes are supported; `tam.jml`
  and multidimensional (`ndim > 1`) fits are refused. Multi-facet
  `tam.mml.mfr` fits combine facet effects per design cell and retain
  the original coefficient table in `source$native_parameters`.
  Transformed item SEs are retained only when the location is a scalar
  multiple of a single fixed-slope source coefficient; otherwise `SE` is
  `NA`. Person estimates retain source EAP and conditional posterior SD,
  while
  [`TAM::tam.personfit()`](https://rdrr.io/pkg/TAM/man/tam.personfit.html)
  uses WLE scores (recorded in `FitBasis`). TAM-native AIC, BIC, and
  `aBIC` are kept under `Native*` fields with
  `ICStatus = "imported_native_descriptive"` and `ICEligible = FALSE`.

- **`eRm`:** Conditional ML cumulative easiness coefficients from `RM`,
  `PCM`, or `RSM` are negated and differenced into absolute
  adjacent-category difficulties, with scalar-transformed item-location
  SEs and ML person parameters (retaining `source_extrapolated` flags
  for extremes).

## Imported uncertainty

Imported SEs retain the source package's interpretation. The
measurement-side diagnostics do not reconstruct the joint parameter
covariance, so joint facet chi-square statistics, degrees of freedom and
p-values are unavailable. Posterior SDs do not supply sampling SEs for
separation reliability. Other separation summaries require valid SEs for
every finite estimate and remain descriptive. Imported Wright maps show
points only: source uncertainty conventions do not establish one common
confidence-interval calculation. Re-import older saved bundles from the
existing source-package fit to update difficulties, thresholds and
uncertainty labels. The `mirt` and `TAM` paths accept
`compute_fit = TRUE` when source fit statistics are needed; no model
re-estimation is required.

## Scope

Use [`summary()`](https://rdrr.io/r/base/summary.html) for source-scale
tables and [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
a point-only Wright map. Available source fit statistics remain in the
facet and diagnostic tables. Native model curves, comprehensive
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_results.md)
reports, response-level diagnostics,
[`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/run_qc_pipeline.md),
bias/DIF analysis, anchoring and portable calibration are unavailable
for imported bundles. This is a one-way fitted-object import of the
documented fields.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
[`read_facets_results()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/read_facets_results.md),
[mfrmr_api_migration_030](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_api_migration_030.md)

## Examples

``` r
# Optional integration example (loads additional modelling packages).
# example("import_irt_fit", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
if (requireNamespace("TAM", quietly = TRUE)) {
  response_matrix <- matrix(sample(0:2, 60, replace = TRUE), nrow = 20)
  colnames(response_matrix) <- paste0("Item", seq_len(ncol(response_matrix)))
  fit_tam <- TAM::tam.mml(resp = response_matrix, irtmodel = "PCM", verbose = FALSE)
  imported <- import_irt_fit(fit_tam, model = "PCM")
  summary(imported)
}
} # }
```
