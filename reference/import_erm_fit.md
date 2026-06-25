# Import an `eRm` fit to an mfrmr-compatible bundle

Extracts item / person parameters from an
[`eRm::PCM()`](https://rdrr.io/pkg/eRm/man/PCM.html) /
[`eRm::RM()`](https://rdrr.io/pkg/eRm/man/RM.html) fit. Same caveats as
[`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md).

## Usage

``` r
import_erm_fit(fit, model = c("RSM", "PCM", "GPCM"), item_facet = "Item")
```

## Arguments

- fit:

  An object returned by
  [`eRm::PCM()`](https://rdrr.io/pkg/eRm/man/PCM.html),
  [`eRm::RM()`](https://rdrr.io/pkg/eRm/man/RM.html), or
  [`eRm::RSM()`](https://rdrr.io/pkg/eRm/man/RSM.html).

- model:

  Same as
  [`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md).

- item_facet:

  Name to assign to the item facet.

## Value

An `mfrm_imported_fit` object.

## See also

[`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md),
[`import_tam_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_tam_fit.md)

## Examples

``` r
if (FALSE) { # \dontrun{
if (requireNamespace("eRm", quietly = TRUE)) {
  response_matrix <- matrix(sample(0:3, 60, replace = TRUE), nrow = 20)
  colnames(response_matrix) <- paste0("Item", seq_len(ncol(response_matrix)))
  fit <- eRm::PCM(response_matrix)
  imported <- import_erm_fit(fit, model = "PCM")
  imported$summary
}
} # }
```
