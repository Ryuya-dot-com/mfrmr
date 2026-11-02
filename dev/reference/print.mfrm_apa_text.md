# Print APA narrative text with preserved line breaks

Print APA narrative text with preserved line breaks

## Usage

``` r
# S3 method for class 'mfrm_apa_text'
print(x, ...)
```

## Arguments

- x:

  Character text object from `build_apa_outputs()$report_text`.

- ...:

  Reserved for generic compatibility.

## Value

The input object (invisibly).

## Details

Prints APA narrative text with preserved paragraph breaks using
[`cat()`](https://rdrr.io/r/base/cat.html). This is preferred over bare
[`print()`](https://rdrr.io/r/base/print.html) when you want readable
multi-line report output in the console.

## Interpreting output

The printed text is the same content stored in
`build_apa_outputs(...)$report_text`, but with explicit paragraph
breaks.

## Typical workflow

1.  Generate `apa <- build_apa_outputs(...)`.

2.  Print readable narrative with `apa$report_text`.

3.  Use `summary(apa)` to check completeness before manuscript use.

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("print.mfrm_apa_text", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
apa <- build_apa_outputs(fit, diag)
apa$report_text
} # }
```
