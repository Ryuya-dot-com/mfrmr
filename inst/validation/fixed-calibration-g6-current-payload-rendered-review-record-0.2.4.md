# Fixed-calibration G6 current-payload rendered review for mfrmr 0.2.4

Status: `machine_preflight_complete_rendered_review_complete_owner_review_open`,
2026-09-06.

## Bound payload

This record applies to implementation commit
`2899f5ba70e3cce98a4beab5a8b47307d365fc3d`, Git tree
`69ed26fa5d89fda7b128f6ef4d2b8bfd73da50b5`. The later commit that adds this
record and its internal index entry is excluded from the source package by
`.Rbuildignore` and does not alter the reviewed package payload.

The fixed-calibration numerical kernel, export/scoring implementation, compiled
sources, and G4 production boundary are unchanged from implementation commit
`71f32200a21bb349689b7e9d1d327726aeec785c`. The prior G4 result therefore
remains applicable to this payload; this wording review is not treated as new
independent numerical evidence and did not trigger another G4 execution.

## Public-scope correction

The first rendered review exposed one real public-contract contradiction:
`facets_feature_coverage()` described frozen-calibration import and scoring as
wholly unavailable even though mfrmr now has a native portable RSM/PCM MML
artifact route. The shared public guidance now distinguishes the two contracts:

- importing a FACETS or third-party calibration file remains unavailable; and
- loading and scoring a native mfrmr portable RSM/PCM MML artifact is available
  through the documented calibration API.

This is a clarification of an existing narrow capability, not support for
FACETS conversion, cross-program equivalence, portable GPCM, JML, estimated-
population calibration, or latent-regression calibration. Current capability
text also no longer uses stale `0.2.3` labels where it is describing the
present package rather than historical evidence.

## Machine and rendered evidence

- `roxygen2::roxygenise()` completed successfully; the exported namespace did
  not change.
- Focused output-guide, public-calibration, and public-method contract tests
  passed after the correction.
- A complete `pkgdown::build_site()` completed in 326 seconds and produced 299
  HTML files, including nine articles and 281 reference pages.
- A post-build text scan found the new native-versus-external distinction and
  found none of the superseded generic calibration-import wording or stale
  GPCM `0.2.3` scope labels.
- Desktop and narrow-width review covered the home page, GPCM scope article,
  reference index, FACETS positioning guide, portable-calibration article,
  G-theory help, design-evaluation help, and anchor-table help. Navigation,
  wrapping, tables, and the current support boundaries were readable; no
  release-blocking layout defect was found. Narrow code blocks retain expected
  horizontal scrolling.
- Routine GitHub Actions run `34023543381` passed all five required platform/R
  cells on the exact bound implementation commit: macOS release, Ubuntu
  oldrel-1, Ubuntu devel, Ubuntu release full tier, and Windows release.
- The run emitted a non-failing GitHub-hosted runner warning for the Node 20
  runtimes in `actions/checkout@v4` and `actions/upload-artifact@v4`. Current
  package validation completed successfully; upgrading those actions is a
  separate CI-maintenance change and is not folded into this package payload.

## Decision boundary

The current-payload machine preflight and rendered-site review are complete.
They do not self-issue the owner's product judgment. CORE-08, G6 exit,
candidate transition, release tagging, publication, and CRAN submission remain
open or unauthorized until the owner reviews this exact public payload.

- `ReviewTargetCommitSHA40=2899f5ba70e3cce98a4beab5a8b47307d365fc3d`
- `ReviewTargetTreeSHA40=69ed26fa5d89fda7b128f6ef4d2b8bfd73da50b5`
- `RoutineHostedRunId=34023543381`
- `RoutineHostedPassedCells=5`
- `RoutineHostedFailedCells=0`
- `CalibrationExportAndScoringKernelChangedSinceG4=FALSE`
- `G4ReexecutionRequiredForThisCorrection=FALSE`
- `FreshCurrentPayloadPkgdownReviewComplete=TRUE`
- `PublicScopeContradictionResolved=TRUE`
- `MachineG6PreflightComplete=TRUE`
- `CurrentPayloadHumanReleaseReviewComplete=FALSE`
- `CORE08Complete=FALSE`
- `G6ExitComplete=FALSE`
- `CandidateTransitionAuthorized=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=owner-review-current-payload`
