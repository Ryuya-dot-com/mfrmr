# Import an `eRm` fit to an mfrmr-compatible bundle

Extracts item / person parameters from an
[`eRm::PCM()`](https://rdrr.io/pkg/eRm/man/PCM.html),
[`eRm::RM()`](https://rdrr.io/pkg/eRm/man/RM.html) or
[`eRm::RSM()`](https://rdrr.io/pkg/eRm/man/RSM.html) fit. Source
cumulative easiness coefficients are converted to absolute
adjacent-category difficulties. One item location is returned per item:
the mean of its thresholds. Source identification is retained. Current
`eRm` person tables use `Person Parameter` and `Std.Error`; historical
`theta` / `thetapar` estimate labels are also accepted. Unknown or
internally misaligned person-table schemas stop with an explicit error
rather than silently recycling rows. Same caveats as
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

  Matching `"PCM"` or `"RSM"` label; either is accepted for a binary
  `RM`. `"GPCM"` and linear extensions are unsupported.

- item_facet:

  Name to assign to the item facet.

## Value

An `mfrm_imported_fit` object.

## Details

Item-location SEs use the corresponding scalar transformation of the
source cumulative coefficient SE. Person maximum-likelihood estimates
and conditional SEs retain source conventions, including labelled
extreme-score extrapolations. The original coefficient table is retained
in `source$native_parameters`.

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

[`import_mirt_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_mirt_fit.md),
[`import_tam_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_tam_fit.md)

## Examples

``` r
# \donttest{
if (requireNamespace("eRm", quietly = TRUE)) {
  response_matrix <- matrix(sample(0:3, 60, replace = TRUE), nrow = 20)
  colnames(response_matrix) <- paste0("Item", seq_len(ncol(response_matrix)))
  fit <- eRm::PCM(response_matrix)
  imported <- import_erm_fit(fit, model = "PCM")
  imported$summary
}
#>   Model Method Source  N Persons Facets Categories    LogLik AIC BIC Converged
#> 1   PCM    CML    eRm 20      20      1         NA -38.17201  NA  NA      TRUE
#>   ConvergenceStatus
#> 1          imported
# }
```
