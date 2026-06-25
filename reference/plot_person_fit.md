# Plot per-person fit

Per-person diagnostic bubble plot inspired by FACETS Table 6 / KIDMAP
summaries. Each bubble represents one person at the intersection of
Infit (x) and Outfit (y), sized by total observations and coloured by
the standard 0.5/1.5 fit envelope: green when both Infit and Outfit fall
in `[lower, upper]`, amber when one statistic is outside, red when both
are outside. Set `fit_index = "loglik"` for a ranked view of the
report-ready `lz_star` / `lz` index instead.

## Usage

``` r
plot_person_fit(
  fit,
  diagnostics = NULL,
  lower = 0.5,
  upper = 1.5,
  top_n_label = 12L,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  fit_index = c("meansquare", "loglik")
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output. When omitted, `diagnose_mfrm(fit, residual_pca = "none")` is
  run internally.

- lower:

  Lower fit threshold (default `0.5`, Linacre 2002).

- upper:

  Upper fit threshold (default `1.5`).

- top_n_label:

  Maximum number of persons whose label is drawn. The default
  mean-square view uses largest `|Infit - 1| + |Outfit - 1|`;
  `fit_index = "loglik"` uses largest absolute report index. Default
  `12`.

- preset:

  Visual preset, including `"monochrome"`.

- draw:

  If `TRUE`, draw with base graphics.

- fit_index:

  Plot focus. `"meansquare"` keeps the Infit/Outfit bubble plot.
  `"loglik"` draws the report index selected by
  [`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md)
  (`lz_star` when available, otherwise `lz` with a caveat).

## Value

An `mfrm_plot_data` object whose reusable plot data include `data` with
one row per person, `plot_long` for custom R graphics,
`person_fit_indices` from
[`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_person_fit_indices.md),
and compact flag/status summaries.

## Interpreting output

The default 0.5-1.5 envelope follows Linacre (2002) Rasch Measurement
Transactions. Persons in the green centre are fit-acceptable; amber and
red corners are candidates for misfit review (overfit / underfit) using
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)
for follow-up.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md).

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
p <- plot_person_fit(fit, draw = FALSE)
head(p$data$data)
}
```
