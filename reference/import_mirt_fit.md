# Import an `mirt` fit to an mfrmr-compatible bundle

Extracts item, step, and person parameters from a
[`mirt::mirt()`](https://philchalmers.github.io/mirt/reference/mirt.html)
fit and returns an `mfrm_imported_fit` object. The returned object has
the public slots `summary`, `facets$person`, `facets$others`, `steps`,
`config`, and `source` that the mfrmr plot and table helpers expect.
With `compute_fit = TRUE` the importer also runs
[`mirt::itemfit()`](https://philchalmers.github.io/mirt/reference/itemfit.html)
and
[`mirt::personfit()`](https://philchalmers.github.io/mirt/reference/personfit.html)
so Infit / Outfit columns are populated, and synthesises a
`mfrm_diagnostics`-shape `diagnostics` slot consumable by downstream
plot helpers (Wright map, QC dashboard, etc.).

## Usage

``` r
import_mirt_fit(
  fit,
  model = c("RSM", "PCM", "GPCM"),
  item_facet = "Item",
  compute_fit = FALSE
)
```

## Arguments

- fit:

  An object returned by
  [`mirt::mirt()`](https://philchalmers.github.io/mirt/reference/mirt.html)
  (a `SingleGroupClass`).

- model:

  One of `"RSM"`, `"PCM"`, `"GPCM"`. The importer does not infer the
  model from the mirt object; pass the model that was estimated.

- item_facet:

  Name to assign to the item facet in the imported bundle (default
  `"Item"`).

- compute_fit:

  Logical. When `TRUE`, run
  [`mirt::itemfit()`](https://philchalmers.github.io/mirt/reference/itemfit.html)
  and
  [`mirt::personfit()`](https://philchalmers.github.io/mirt/reference/personfit.html)
  to populate Infit / Outfit / OutfitZSTD columns on the returned facet
  tables, plus build a measurement-side `mfrm_diagnostics` bundle
  consumable by [`summary()`](https://rdrr.io/r/base/summary.html),
  [`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
  etc. Default `FALSE` keeps the importer fast (skeleton only).

## Value

An `mfrm_imported_fit` object. Slots:

- `summary`:

  Model / method / N / LogLik / AIC / BIC.

- `facets$person`:

  Person ID, Estimate, SE, Extreme, plus Infit / Outfit / OutfitZSTD /
  Zh when `compute_fit = TRUE`.

- `facets$others`:

  Item-level estimates and slopes; with `compute_fit = TRUE`, also Infit
  / Outfit / S_X2 / RMSEA / df from
  [`mirt::itemfit()`](https://philchalmers.github.io/mirt/reference/itemfit.html).

- `steps`:

  Per-item threshold parameters extracted from the IRT parameterisation
  (`b1`, ..., `b(K-1)`).

- `config`:

  List with the resolved `model` and `item_facet` used for the import;
  downstream plot and table helpers consult this to dispatch correctly
  on the imported bundle.

- `diagnostics`:

  `mfrm_diagnostics`-shape bundle when `compute_fit = TRUE`; `NULL`
  otherwise.

- `source`:

  Imported-from metadata.

## Scope

Bundles bias / DIF / anchor / replay slots are explicitly not populated;
full bidirectional import / export is planned for a future release.

## See also

[`import_tam_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_tam_fit.md),
[`import_erm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_erm_fit.md)

## Examples

``` r
if (FALSE) { # \dontrun{
if (requireNamespace("mirt", quietly = TRUE)) {
  response_matrix <- matrix(sample(0:3, 60, replace = TRUE), nrow = 20)
  colnames(response_matrix) <- paste0("Item", seq_len(ncol(response_matrix)))
  fit <- mirt::mirt(response_matrix, 1, itemtype = "gpcm", verbose = FALSE)
  imported <- import_mirt_fit(fit, model = "GPCM")
  imported$summary
}
} # }
```
