# Import a `TAM` fit to an mfrmr-compatible bundle

Extracts item / step / person parameters from a
[`TAM::tam.mml()`](https://rdrr.io/pkg/TAM/man/tam.mml.html),
[`TAM::tam.jml()`](https://rdrr.io/pkg/TAM/man/tam.jml.html), or
[`TAM::tam.mml.mfr()`](https://rdrr.io/pkg/TAM/man/tam.mml.html) fit.
The multi-facet `tam.mml.mfr()` path is detected automatically and each
non-person facet is mapped onto a row of `fit$facets$others` so
downstream MFRM helpers (e.g.
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md))
work on the imported object.

## Usage

``` r
import_tam_fit(
  fit,
  model = c("RSM", "PCM", "GPCM"),
  item_facet = "Item",
  compute_fit = FALSE
)
```

## Arguments

- fit:

  An object returned by
  [`TAM::tam.mml()`](https://rdrr.io/pkg/TAM/man/tam.mml.html),
  [`TAM::tam.jml()`](https://rdrr.io/pkg/TAM/man/tam.jml.html), or
  [`TAM::tam.mml.mfr()`](https://rdrr.io/pkg/TAM/man/tam.mml.html).

- model:

  Same as
  [`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md).

- item_facet:

  Name to assign to the item facet for the single-facet path. Ignored
  when the input is a multi-facet `tam.mml.mfr` fit (the original facet
  names are preserved).

- compute_fit:

  Logical. When `TRUE`, run
  [`TAM::tam.fit()`](https://rdrr.io/pkg/TAM/man/tam.fit.html) and
  [`TAM::tam.personfit()`](https://rdrr.io/pkg/TAM/man/tam.personfit.html)
  to populate Infit / Outfit columns on the returned facet tables, plus
  build a measurement-side `mfrm_diagnostics` bundle. Default `FALSE`.

## Value

An `mfrm_imported_fit` object. Slots mirror
[`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md).

## See also

[`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md),
[`import_erm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_erm_fit.md)

## Examples

``` r
if (FALSE) { # \dontrun{
if (requireNamespace("TAM", quietly = TRUE)) {
  response_matrix <- matrix(sample(0:3, 60, replace = TRUE), nrow = 20)
  colnames(response_matrix) <- paste0("Item", seq_len(ncol(response_matrix)))
  fit <- TAM::tam.mml(resp = response_matrix, irtmodel = "PCM")
  imported <- import_tam_fit(fit, model = "PCM")
  imported$summary
}
} # }
```
