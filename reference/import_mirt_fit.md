# Import an `mirt` fit to an mfrmr-compatible bundle

Extracts item, step, and person parameters from a
[`mirt::mirt()`](https://philchalmers.github.io/mirt/reference/mirt.html)
fit and returns an `mfrm_imported_fit` object. The returned object has
the public slots `summary`, `facets$person`, `facets$others`, `steps`,
`config`, and `source` that the mfrmr plot and table helpers expect.
Only unidimensional Rasch and partial-credit response models with
positive slopes and ordinary category scores are supported.
Graded-response, guessing and multidimensional models are refused. With
`compute_fit = TRUE`, source Infit / Outfit statistics are attached.

## Usage

``` r
import_mirt_fit(
  fit,
  model = c("RSM", "PCM", "GPCM"),
  item_facet = "Item",
  compute_fit = FALSE
)

# S3 method for class 'mfrm_imported_fit'
summary(object, digits = 3L, ...)

# S3 method for class 'summary.mfrm_imported_fit'
print(x, ...)
```

## Arguments

- fit:

  An object returned by
  [`mirt::mirt()`](https://philchalmers.github.io/mirt/reference/mirt.html)
  (a `SingleGroupClass`).

- model:

  One of `"RSM"`, `"PCM"`, `"GPCM"`. The importer does not reconstruct
  all source constraints; pass the model that was estimated. Non-unit
  slopes require `"GPCM"`. A polytomous `"RSM"` import requires source
  item type `"rsm"`.

- item_facet:

  Name to assign to the item facet in the imported bundle (default
  `"Item"`).

- compute_fit:

  Logical. When `TRUE`, run
  [`mirt::itemfit()`](https://philchalmers.github.io/mirt/reference/itemfit.html)
  and
  [`mirt::personfit()`](https://philchalmers.github.io/mirt/reference/personfit.html)
  to populate Infit / Outfit / OutfitZSTD columns on the returned facet
  tables, plus build a measurement-side diagnostics bundle. Person fit
  uses source EAP scores. Default `FALSE` extracts parameters without
  calculating fit statistics.

- object, x:

  An imported measurement bundle.

- digits:

  Number of digits for displayed estimates.

- ...:

  Additional arguments (unused by imported summaries).

## Value

An `mfrm_imported_fit` object. Slots:

- `summary`:

  Model / method / N / LogLik / AIC / BIC.

- `facets$person`:

  Person ID, Estimate, SE, Extreme, plus Infit / Outfit / OutfitZSTD /
  Zh when `compute_fit = TRUE`.

- `facets$others`:

  Item-level estimates and slopes; with `compute_fit = TRUE`, also
  available Infit / Outfit statistics.

- `steps`:

  Absolute adjacent-category thresholds on the source ability scale,
  labelled in `Parameterization`; these are not centered step
  deviations. Rating-scale offsets are included.

- `config`:

  List with the declared `model` and facet names used for the import;
  downstream plot and table helpers consult this to dispatch correctly
  on the imported bundle.

- `diagnostics`:

  `mfrm_diagnostics`-shape bundle when `compute_fit = TRUE`; `NULL`
  otherwise.

- `source`:

  Imported-from metadata.

## Source scale

Item difficulty is the mean of its absolute adjacent-category
thresholds. Source identification and slopes are retained without
rescaling. For mirt `gpcmIRT` and `rsm`, the category offset is included
as `b - c / a`. Person estimates are EAP; the `SE` column contains
conditional posterior SDs, not sampling SEs. Person labels use retained
source row names or P-prefixed row positions. Original identifiers
discarded by mirt cannot be recovered. Imported summaries describe these
conventions without assuming a native mfrmr population distribution or
slope normalization.

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
uncertainty labels. The mirt and TAM importers accept
`compute_fit = TRUE` when source fit statistics are needed; no model
re-estimation is required.

## Scope

Use [`summary()`](https://rdrr.io/r/base/summary.html) for source-scale
tables and [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
a point-only Wright map. Available source fit statistics remain in the
facet and diagnostic tables. Native model curves, comprehensive
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
reports, response-level diagnostics,
[`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md),
bias/DIF analysis, anchoring and portable calibration are unavailable
for imported bundles. This is a one-way fitted-object import of the
documented fields.

## See also

[`import_tam_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_tam_fit.md),
[`import_erm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_erm_fit.md)

## Examples

``` r
# \donttest{
if (requireNamespace("mirt", quietly = TRUE)) {
  response_matrix <- matrix(sample(0:1, 120, replace = TRUE), nrow = 40)
  colnames(response_matrix) <- paste0("Item", seq_len(ncol(response_matrix)))
  fit <- mirt::mirt(response_matrix, 1, itemtype = "Rasch", verbose = FALSE)
  imported <- import_mirt_fit(fit, model = "RSM")
  imported$summary
}
#>   Model Method Source  N Persons Facets Categories    LogLik      AIC      BIC
#> 1   RSM    MML   mirt 40      40      1         NA -81.62847 171.2569 178.0125
#>   Converged ConvergenceStatus
#> 1      TRUE                ok
# }
```
