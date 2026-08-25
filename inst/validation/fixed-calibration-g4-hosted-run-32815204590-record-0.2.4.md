# Fixed-calibration G4 hosted run 32815204590 record

Status: `macos_static_child_dependency_transport_failure`, 2026-08-25.

## Candidate and execution order

- Commit: `5af00ed64b62be3c4314a7095c937e279649ccbd`
- GitHub Actions run: `32815204590`
- macOS release prerequisite: `failure`
- Windows release: `skipped`
- Ubuntu devel: `skipped`
- Ubuntu release: `skipped`
- Ubuntu oldrel-1: `skipped`
- Five-receipt aggregation: `skipped`

The macOS job built and bound its source tarball and completed exact-tarball
`R CMD check --no-manual` with `Status: OK`. It then entered the
repository-only static G4 test before the current 49-cell worker was invoked.
The static fresh-process regression launched `Rscript --vanilla`; that child
found the check-installed `mfrmr` package but did not inherit setup-r's
temporary dependency library and stopped because `decor` was unavailable.

No hosted `current-confirmation.rds` or `hosted-cell-receipt.rds` was created.
Thus this run opened no hosted v4 numerical cell. The four dependent platform
jobs and matrix aggregation were skipped exactly as required by the macOS-
first contract.

## Disposition

The repair is limited to hosted dependency-library transport. The hosted
runner now passes the parent's existing `.libPaths()` through standard
`R_LIBS`, which remains visible to a `--vanilla` child. The static test also
stops after reporting the subprocess failure instead of attempting to read an
output file that was never created. Production files, the 49-cell worker,
v4 modular-1031/1033 fixtures, numerical rules, thresholds, and decision
dispositions are unchanged.

This is analogous to a platform path/library transport repair, not a change to
an evaluated production implementation or statistical decision rule. The
local v4 result remains separately retained. A new clean candidate must repeat
the complete local and hosted paths with the updated support registry.

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
- `NextGate=new-clean-candidate-same-v4-complete-local-and-hosted-execution`
