# Fixed-calibration G4 hosted run 32818900492 record

Status: `macos_static_child_explicit_library_transport_incomplete`, 2026-08-25.

## Candidate and execution order

- Commit: `12596f5cdaa42970f128c2582fcaaee9ac2e6747`
- GitHub Actions run: `32818900492`
- macOS release prerequisite: `failure`
- Windows release: `skipped`
- Ubuntu devel: `skipped`
- Ubuntu release: `skipped`
- Ubuntu oldrel-1: `skipped`
- Five-receipt aggregation: `skipped`

The macOS job again completed exact-tarball `R CMD check --no-manual` with
`Status: OK`. The first library-transport repair exported the parent's
library set through standard `R_LIBS`, but the repository static test's
`Rscript --vanilla` worker still rebuilt `.libPaths()` without setup-r's
temporary dependency library and stopped because `decor` was unavailable.

The workflow upload step was itself successful because missing evidence is
configured as an allowed diagnostic condition, but its log states that no
`hosted-cell-receipt.rds` existed. The current 49-cell worker was not invoked,
and the four dependent platform jobs plus matrix aggregation were skipped.

## Disposition

The second repair replaces reliance on implicit R startup handling with an
explicit repository-only transport contract. The hosted runner exports the
validated parent library directories through
`MFRMR_G4_DEPENDENCY_LIBRARIES`; the confirmation worker splits them with the
platform path separator, retains only existing directories, normalizes them,
and adds them to `.libPaths()` after the exact check-installed library.

No production file, handler, fixture, numerical rule, threshold, or decision
disposition changes. The existing local v4 result remains retained, while a
new clean candidate must repeat the complete local and hosted paths because
the worker/support registry changed.

- `ExactTarballCheckStatus=OK`
- `RepositoryStaticEvidenceComplete=FALSE`
- `HostedCurrentWorkerInvoked=FALSE`
- `HostedConfirmationResultObserved=FALSE`
- `HostedCellReceiptCreated=FALSE`
- `DependentPlatformJobsSkipped=TRUE`
- `HostedPlatformMatrixComplete=FALSE`
- `G4ExitComplete=FALSE`
- `V4NumericalIdentityChanged=FALSE`
- `ProductionBoundaryChanged=FALSE`
- `NextGate=explicit-worker-library-transport-clean-candidate-rerun`
