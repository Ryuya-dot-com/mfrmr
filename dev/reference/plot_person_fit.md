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
  marginal = c("auto", "histogram", "none"),
  draw = TRUE,
  fit_index = c("meansquare", "loglik")
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
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

  If `TRUE`, print the `ggplot` object.

- fit_index:

  Plot focus. `"meansquare"` keeps the Infit/Outfit bubble plot.
  `"loglik"` draws the report index selected by
  [`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/compute_person_fit_indices.md)
  (`lz_star` when available, otherwise `lz` with a caveat).

## Value

Invisibly, a `ggplot` object. Its
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
components include `data` with one row per person, `plot_long` for
custom R graphics, `person_fit_indices` from
[`compute_person_fit_indices()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/compute_person_fit_indices.md),
and compact flag/status summaries.

## Interpreting output

The default 0.5-1.5 envelope follows Linacre (2002) Rasch Measurement
Transactions. Persons in the green centre are within the screening band;
amber and red corners are candidates for review (overfit / underfit)
using
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md)
for follow-up.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md),
[`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_misfit_casebook.md).

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_person_fit", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Use the diagnostics saved with this fit
diagnostics <- example_fit$diagnostics

# Compare each person's Infit and Outfit with the reference value of 1
plot(fit, type = "person_fit", diagnostics = diagnostics)
# Values above 1 indicate more response variation than expected, below 1 less
# The reference bands flag patterns for review, not automatic exclusion
} # }
```
