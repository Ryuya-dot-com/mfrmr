# Convert mfrm_fit to a tidy data.frame

Returns all facet-level estimates (person and others) in a single tidy
data.frame. Person rows retain their original identifiers; review or
transform them before writing the result outside a controlled analysis
environment.

## Usage

``` r
# S3 method for class 'mfrm_fit'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  An `mfrm_fit` object from
  [`fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- row.names:

  Ignored (included for S3 generic compatibility).

- optional:

  Ignored (included for S3 generic compatibility).

- ...:

  Additional arguments (ignored).

## Value

A data.frame with columns `Facet`, `Level`, `Estimate`, and `Extreme`.
The `Extreme` column is populated for person rows from the extreme-score
flag (`"Min"` / `"Max"` / `NA`); non-person facet rows carry `NA` in
that column by design. Corrected-JML fits additionally retain estimator,
correction order, point/covariance status, uncertainty target and
structural `RootSE` columns. Person `RootSE` is missing; extreme Person
flags are `"low"` / `"high"` / `"none"`. The `estimation_note` attribute
explains the local-root uncertainty and remaining bias. Ordinary
diagnostic attachments do not apply to this estimator; see the Corrected
JML section of
[`fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

## Details

This method returns four columns (`Facet`, `Level`, `Estimate`,
`Extreme`) so that the result is easy to inspect, join, or write to
disk.

## Interpreting output

Person estimates are returned with `Facet = "Person"`. All non-person
facets are stacked underneath in the same schema.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

2.  Convert with `as.data.frame(fit)` for a compact long-format export.

3.  Join additional diagnostics later if you need SE or fit statistics.

## See also

[`fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
[`export_mfrm_tables`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/export_mfrm_tables.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("as.data.frame.mfrm_fit", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Extract estimates and select the rows to display
estimates <- as.data.frame(fit)
head(subset(estimates, Facet == "Person")) # First six persons
subset(estimates, Facet == "Rater")       # All raters
subset(estimates, Facet == "Criterion")   # All criteria
} # }
```
