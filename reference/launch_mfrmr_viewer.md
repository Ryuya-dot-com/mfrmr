# Interactively choose data-frame columns before calling `mfrm_results()`

`launch_mfrmr_viewer()` opens a local Shiny app for reading the object
returned by
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
It is intentionally a viewer over an existing comprehensive results
object, not a new estimation interface.

## Usage

``` r
mfrm_results_interactive(
  data,
  include = "standard",
  output = c("object", "summary", "tables", "html")
)

launch_mfrmr_viewer(
  x,
  top_n = 100L,
  launch.browser = TRUE,
  port = NULL,
  host = getOption("shiny.host", "127.0.0.1"),
  display.mode = c("auto", "normal", "showcase"),
  return_app = FALSE,
  ...
)
```

## Arguments

- data:

  A long-format data frame.

- include:

  Passed to
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).

- output:

  Passed to
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).

- x:

  An
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  object.

- top_n:

  Maximum number of table-index rows shown in the summary payload.

- launch.browser:

  Passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

- port:

  Optional port passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html). `NULL`
  lets Shiny choose its default.

- host:

  Host passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).
  Defaults to the local host.

- display.mode:

  Passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

- return_app:

  Logical; if `TRUE`, return the Shiny app object without running it.
  This is useful for embedding or testing.

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html) when
  `return_app = FALSE`.

## Value

The selected
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
output.

Invisibly returns the value from
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), or the
Shiny app object when `return_app = TRUE`.

## Details

This helper is deliberately opt-in and stops in non-interactive
sessions. It asks the user to choose the person, score, optional weight,
and facet columns, prints reproducible code for the selected roles, then
fits the documented `RSM`/`MML` starting route before calling
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
Use explicit
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
calls in scripts, Quarto documents, batch workflows, and reproducible
analyses.

Testlet and random-rater results are not supported by this viewer. Use
`mfrm_report(res, output = "html")` or
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
for their static results and model-specific figures.

The viewer assumes that fitting, diagnostics, and section selection have
already happened through
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
This keeps GUI exploration separate from reproducible analysis setup:
the Replay tab displays the
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
replay script stored in the result object.

The app includes tabs for overview/triage, QC evidence, APA-style report
text when `include = "publication"` or `"apa"` was used, available bias
screens, pathway plotting, unexpected-response inspection, generic
tables, generic plot routes, and replay code. QC, Report, Bias, and
Pathway/Misfit tabs show local section-status tables so unavailable or
not-requested sections are visible where users look for them.
Bias-interaction follow-up still requires an explicit facet-pair
decision outside the viewer.

`shiny` is an optional dependency. Install it before using this viewer:
`install.packages("shiny")`.

## Why this helper is opt-in

Interactive prompts are useful at the console but are unsafe defaults
for reproducible analysis, unattended workflows, and manuscripts. The
helper therefore prints replay code and leaves the scripted route
explicit.

## See also

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
`mfrm_results_interactive()`

## Examples

``` r
if (interactive()) {
  toy <- load_mfrmr_data("example_core")
  res <- mfrm_results_interactive(toy)
}
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "JML",
  maxit = 30
)
res <- mfrm_results(fit, include = c("fit", "diagnostics", "tables"))

if (interactive() && requireNamespace("shiny", quietly = TRUE)) {
  launch_mfrmr_viewer(res)
}
}
```
