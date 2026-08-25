# Fixed-calibration G4 hosted run 32819992290 record

Status: `macos_static_child_installed_mode_bound_too_late`, 2026-08-25.

## Candidate and execution order

- Commit: `87951ea5997698c7f1c3c0d2b2fd8f3afe9fcb5a`
- GitHub Actions run: `32819992290`
- macOS release prerequisite: `failure`
- Windows release: `skipped`
- Ubuntu devel: `skipped`
- Ubuntu release: `skipped`
- Ubuntu oldrel-1: `skipped`
- Five-receipt aggregation: `skipped`

The exact-tarball check again finished with `Status: OK`. The dedicated
dependency-library environment was present, but the static fresh-process test
still entered source-tree mode and requested the non-package helper `decor`.
Inspection of the hosted runner found an ordering error: it set
`MFRMR_G4_INSTALLED_LIBRARY` only after the repository static G4 test, even
though that test itself launches the fresh worker.

No `hosted-cell-receipt.rds` existed. The current 49-cell worker was not
invoked, and all dependent platform and aggregation jobs were skipped.

## Disposition

The runner now binds the exact check-installed library before calling the
static evidence test. A source-order regression requires that environment
binding to precede the static call. The same binding remains active for the
subsequent current 49-cell worker. The validated dependency-library transport
is retained for the installed package's Imports.

This is an execution-order repair only. No production file, current handler,
v4 fixture, numerical rule, threshold, or decision disposition changes. A new
clean candidate must repeat both local and hosted paths because the hosted
runner/support registry changed.

- `ExactTarballCheckStatus=OK`
- `RepositoryStaticEvidenceComplete=FALSE`
- `StaticFreshProcessEnteredInstalledMode=FALSE`
- `HostedCurrentWorkerInvoked=FALSE`
- `HostedCellReceiptCreated=FALSE`
- `DependentPlatformJobsSkipped=TRUE`
- `HostedPlatformMatrixComplete=FALSE`
- `G4ExitComplete=FALSE`
- `V4NumericalIdentityChanged=FALSE`
- `ProductionBoundaryChanged=FALSE`
- `NextGate=bind-installed-library-before-static-evidence-and-rerun`
