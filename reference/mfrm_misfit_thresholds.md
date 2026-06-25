# MnSq misfit threshold pair used across mfrmr screening helpers

Returns the lower / upper bounds that mfrmr screens treat as the
acceptable mean-square (Infit / Outfit MnSq) band when flagging
element-level misfit. Defaults follow Linacre's published 0.5-1.5
acceptance band; both ends can be overridden via R options.

## Usage

``` r
mfrm_misfit_thresholds(lower = NULL, upper = NULL)
```

## Arguments

- lower:

  Optional lower bound. When `NULL` (default), the active option /
  package default is used.

- upper:

  Optional upper bound.

## Value

A named numeric vector `c(lower = ..., upper = ...)` with
`lower < upper`.

## Details

Helpers that consume the band include
[`summary.mfrm_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_diagnostics.md)
(`misfit_flagged` block and `key_warnings` auto-flag),
[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
(the new `element_fit` source family), the bias / misfit narrative
inside
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
and
[`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)
when `misfit_warn = NULL`. Setting the options once at the top of an
analysis script therefore changes every downstream screen at once.

## Configuration

Two scalar R options drive the band:

- `mfrmr.misfit_lower`:

  Lower acceptance bound. Default `0.5`.

- `mfrmr.misfit_upper`:

  Upper acceptance bound. Default `1.5`.

Pass scalar arguments to override the options for a single call, e.g.
`mfrm_misfit_thresholds(lower = 0.7, upper = 1.3)` for the tighter Bond
& Fox (2015) reporting band.

## See also

[`summary.mfrm_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_diagnostics.md),
[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md),
[`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)

## Examples

``` r
mfrm_misfit_thresholds()
#> lower upper 
#>   0.5   1.5 
old <- options(mfrmr.misfit_lower = 0.7, mfrmr.misfit_upper = 1.3)
mfrm_misfit_thresholds()
#> lower upper 
#>   0.7   1.3 
options(old)
```
