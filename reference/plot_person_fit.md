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
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
p <- plot_person_fit(fit, draw = FALSE)
head(p$data$data)
#>   Person     Infit    Outfit  N       Status    LogLik         lz   lz_star
#> 1   P023 1.5566614 2.4412291 16 both_outside -11.95190 -0.9062624 -2.867698
#> 2   P018 0.5262803 0.5283334 16      in_band -15.67776  1.5137376  1.518508
#> 3   P048 0.5688089 0.5618333 16      in_band -15.35887  1.3572167  1.451901
#> 4   P037 0.5698914 0.5628405 16      in_band -15.88626  1.4016369  1.404820
#> 5   P030 1.3893143 1.3963185 16      in_band -21.53300 -1.2545559 -1.271109
#> 6   P035 0.6171029 0.6286213 16      in_band -16.34478  1.1912171  1.193923
#>                         lz_star_status ReportIndex ReportValue ReportFlagLevel
#> 1 computed_jml_conditional_calibration     lz_star   -2.867698            1pct
#> 2 computed_jml_conditional_calibration     lz_star    1.518508            none
#> 3 computed_jml_conditional_calibration     lz_star    1.451901            none
#> 4 computed_jml_conditional_calibration     lz_star    1.404820            none
#> 5 computed_jml_conditional_calibration     lz_star   -1.271109            none
#> 6 computed_jml_conditional_calibration     lz_star    1.193923            none
#>   ReportFlag ReviewStatus
#> 1       TRUE  review_1pct
#> 2      FALSE  not_flagged
#> 3      FALSE  not_flagged
#> 4      FALSE  not_flagged
#> 5      FALSE  not_flagged
#> 6      FALSE  not_flagged
#>                                                     ReviewReason
#> 1                                    lz_star exceeds |z| > 2.58.
#> 2 No report-level flag under the practical two-sided thresholds.
#> 3 No report-level flag under the practical two-sided thresholds.
#> 4 No report-level flag under the practical two-sided thresholds.
#> 5 No report-level flag under the practical two-sided thresholds.
#> 6 No report-level flag under the practical two-sided thresholds.
#>                                                                                                                                ReportCaveat
#> 1 lz_star applies the Snijders correction conditional on fitted non-person calibration; non-person parameter uncertainty is not propagated.
#> 2 lz_star applies the Snijders correction conditional on fitted non-person calibration; non-person parameter uncertainty is not propagated.
#> 3 lz_star applies the Snijders correction conditional on fitted non-person calibration; non-person parameter uncertainty is not propagated.
#> 4 lz_star applies the Snijders correction conditional on fitted non-person calibration; non-person parameter uncertainty is not propagated.
#> 5 lz_star applies the Snijders correction conditional on fitted non-person calibration; non-person parameter uncertainty is not propagated.
#> 6 lz_star applies the Snijders correction conditional on fitted non-person calibration; non-person parameter uncertainty is not propagated.
# }
```
