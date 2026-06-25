## Release type

Maintenance release for the next CRAN upload candidate. This local draft is
not ready for submission until the latest GitHub Actions matrix completes
successfully.

## Test environments

* Local macOS Tahoe 26.5.1, R 4.5.2: R CMD check --as-cran for 0.2.2
  with Homebrew `tidy-html5` 5.8.0 on PATH and the pkgdown URL reachable
* GitHub Actions matrix: pending for the latest commit/push
* CRAN checks for previous release 0.2.1: all current CRAN check flavors OK in
  the local release-readiness snapshot

## R CMD check results

Local R CMD check --as-cran for mfrmr 0.2.2:

* 0 errors
* 0 warnings
* 0 notes

Current local notes:

* None

The final submission will be refreshed after CI checks complete. This draft
should not be submitted if CI reports any failures.

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
