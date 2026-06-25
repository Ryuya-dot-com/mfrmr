# Build a specification summary report (preferred alias)

Build a specification summary report (preferred alias)

## Usage

``` r
specifications_report(
  fit,
  title = NULL,
  data_file = NULL,
  output_file = NULL,
  include_fixed = FALSE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- title:

  Optional analysis title.

- data_file:

  Optional data-file label (for reporting only).

- output_file:

  Optional output-file label (for reporting only).

- include_fixed:

  If `TRUE`, include a legacy-compatible fixed-width text block.

## Value

A named list with specification-report components. Class:
`mfrm_specifications`.

## Details

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_specifications` (`type = "facet_elements"`,
`"anchor_constraints"`, `"convergence"`).

## Interpreting output

- `header` / `data_spec`: run identity and model settings.

- `facet_labels`: facet sizes and labels.

- `convergence_control`: optimizer configuration and status.

## Typical workflow

1.  Generate `specifications_report(fit)`.

2.  Verify model settings and convergence metadata.

3.  Use the output as methods and run-documentation support in reports.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md),
[`estimation_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimation_iteration_report.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
out <- specifications_report(fit, title = "Toy run")
summary(out)
#> mfrmr Specifications Summary 
#>   Class: mfrm_specifications
#>   Components (6): header, data_spec, facet_labels, output_spec, convergence_control, anchor_summary
#> 
#> Specification header
#>       Engine   Title DataFile OutputFile Model Method
#>  mfrmr 0.2.2 Toy run                       RSM    JML
#> 
#> Specification rows: data_spec
#>           Setting  Value
#>            Facets      2
#>           Persons     48
#>        Categories      4
#>         RatingMin      1
#>         RatingMax      4
#>  NonCenteredFacet Person
#>    PositiveFacets       
#>       DummyFacets       
#>         StepFacet       
#>      WeightColumn       
#> 
#> Notes
#>  - Model specification summary for method and run documentation.
p_spec <- plot(out, draw = FALSE)
p_spec$data$plot
#> [1] "facet_elements"
```
