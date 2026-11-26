# Contributing to mfrmr

Check [open issues](https://github.com/Ryuya-dot-com/mfrmr/issues) for related
work. A bug report is easiest to reproduce with the package version, the
model and arguments, and a small synthetic rating table with the same design.

## Work from a checkout

From the package root, install the package dependencies and the development
tools. Load the checkout in a fresh R session.

```r
install.packages(c("devtools", "pkgload", "testthat"))
pkgload::load_all(".", export_all = FALSE)
getNamespaceInfo(asNamespace("mfrmr"), "path")
```

Use `Rscript scripts/check-publication-boundary.R` to check source boundaries
and version metadata. For changes to the public interface, update the
corresponding help and NEWS entry. Review examples from a clean session using
the same exported functions as package users.

## Build and check

Stage the package source outside the checkout so build tools only copy files
intended for the source package.

```sh
mfrmr_build_dir=$(mktemp -d)
Rscript --vanilla scripts/stage-package.R "$mfrmr_build_dir/mfrmr"
cd "$mfrmr_build_dir"
NOT_CRAN=true R_BUILD_TAR=internal R CMD build mfrmr
R CMD check --as-cran mfrmr_*.tar.gz
```

The submission archive includes both prebuilt vignette outputs and the
`build/vignette.rds` index created by this build command.

For regression tests on a particular feature, use the relevant file in
`tests/testthat/`. Run the package check on the exact tarball you intend to
distribute. Use short help examples with real calculations and run longer
examples explicitly when their model or dependencies change.

## Test suites

`tests/testthat.R` selects representative live calculations, S3 contracts,
inference guards and reporting tests for CRAN. `NOT_CRAN=true` runs every
package test, including independent numerical checks, repeated refits and
full Word output. The Ubuntu release CI cell uses this full suite on pushes
and pull requests; the other cells use the CRAN selection.

After installing the current source, run either suite with saved per-test
results and timings:

```sh
Rscript scripts/run-regression.R . cran /tmp/mfrmr-cran-tests
Rscript scripts/run-regression.R . all /tmp/mfrmr-all-tests
```

The CRAN workflow test runs estimation, a method comparison, DFF, G/D-Study,
diagnostics and reporting. The full suite adds all method comparisons and ten
bootstrap replications; these check execution, not coverage or recovery.
Downstream table, interval and information tests also load the existing
calibrations in `inst/examples/`. They test the current extraction/calculation
code and the saved-object contract, not the optimizer. Live estimator and
boundary tests remain separate. The full suite regenerates the ordinary
examples and compares their coefficients and predictions with the saved files.
Finite-difference drift derivatives, fine quadrature refinement, all DFF methods,
all plot palettes and optional Word/table renderers run with `NOT_CRAN=true`.
The CRAN selection retains live estimation, unstable-quadrature and separation
guards, a small drift calibration, and independent probability calculations.
Extraction and display examples reuse the documented fits in `inst/examples/`;
the estimation and workflow entry points still estimate from supplied data.


## Documentation

The source package includes reference help and two offline vignettes.
The GitHub Pages site adds the current assessment and agreement articles from
`vignettes/articles/`. Build it locally with `pkgdown::build_site()` and check
the rendered links and examples. The [documentation archive](https://github.com/Ryuya-dot-com/mfrmr/tree/v0.3.2/website-archive)
preserves earlier APIs and examples with their version context.

Use standard statistical terminology. In an example or report, name the
ratings, model, estimator, scale and conditions that matter for interpreting
the result. Use a suitable packaged dataset in introductory examples and
explain the meaning of one row. For design or numerical studies, preserve the
source, software versions and inputs needed to reproduce the cited result.
