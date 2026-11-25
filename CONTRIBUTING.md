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

For regression tests on a particular feature, use the relevant file in
`tests/testthat/`. Run the package check on the exact tarball you intend to
distribute. Use short help examples with real calculations and run longer
examples explicitly when their model or dependencies change.

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
