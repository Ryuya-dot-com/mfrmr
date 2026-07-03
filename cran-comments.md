## Release type

Maintenance release for the next CRAN upload candidate. The local submission
gate is complete; the GitHub Actions matrix should be checked after the final
push and before upload.

## Test environments

* Local macOS Tahoe 26.5.1, R 4.6.0: R CMD check
  --no-manual --no-build-vignettes --as-cran for 0.2.2
* Release-readiness helper: all local gates OK for 0.2.2
* GitHub Actions matrix: to be checked after the final commit/push
* CRAN checks for previous release 0.2.1: all current CRAN check flavors OK in
  the local release-readiness snapshot

## R CMD check results

Local R CMD check --as-cran for mfrmr 0.2.2:

* 0 errors
* 0 warnings
* 0 notes

Current local notes:

* None

The final submission should not be uploaded if the post-push CI matrix reports
any failures.

## Release scope

This is a maintenance release focused on public package usability and release
readiness:

* adds pkgdown configuration and a GitHub Pages deployment workflow
* updates README installation, first-contact workflow, and package navigation
* adds topic-local examples for exported and medium-priority help topics
* adds small workflow-vignette CSV artifacts so representative output is shown
  during CRAN-style builds without rerunning heavier fitting or simulation
  chunks
* keeps bounded GPCM support explicit, caveated, and guarded by the public
  capability matrix
* keeps long-running illustrations out of routine example execution

No external submission has been made from the local release-review workflow.
