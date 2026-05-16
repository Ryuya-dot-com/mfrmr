# mfrmr 0.2.0 validation artifacts

This directory contains non-exported release-review helpers and evidence
artifacts. They are included with the package so that the 0.2.0 release
decision can be reconstructed from source files, check logs, and documented
validation criteria.

These files are not user-facing analysis functions. They support release
review, CRAN submission preparation, and future maintenance.

## Primary files

- `release-readiness.R`: release-readiness review. Source this file and run
  `mfrmr_release_readiness_review(pkg_dir = ".")` from the package root. The
  review checks version labels, the local check log, the CI check workflow,
  public terminology, and the release evidence files.
- `release-evidence-map-0.2.0.md`: narrative review map linking release
  claims to mathematical, statistical, UX, documentation, and engineering
  evidence.
- `release-evidence-checklist-0.2.0.csv`: structured checklist used by the
  readiness helper and by manual release review.

## Recommended local sequence

Run these commands from the package root after any source, roxygen, vignette, or
compiled-code change:

```sh
R CMD build .
R CMD check --no-manual --as-cran mfrmr_0.2.0.tar.gz
```

Then run:

```r
source("inst/validation/release-readiness.R")
readiness <- mfrmr_release_readiness_review(pkg_dir = ".")
summary(readiness)
```

The release candidate should have `Status: OK` in the local check log and no
`concern` rows in `readiness$gate_summary`.

## Cross-platform evidence

GitHub Actions runs the package on macOS, Windows, and Linux across release,
oldrel, and devel R. Warnings are treated as check failures. The workflow also
uploads the check directory as an artifact for each matrix job so that release
review can compare local and CI evidence instead of relying only on the final
job status.

The readiness helper checks the workflow contract from source. It does not
replace reading the uploaded CI artifacts before release submission.
