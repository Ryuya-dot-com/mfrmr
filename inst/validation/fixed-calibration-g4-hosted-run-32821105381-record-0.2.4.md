# Fixed-calibration G4 hosted run 32821105381 record

Status: `macos_receipt_complete_post_receipt_review_scope_failure`, 2026-08-25.

## Candidate and execution order

- Commit: `a2ced019d1e21f7a80676f4de1dfa9856c74fbb1`
- GitHub Actions run: `32821105381`
- macOS release prerequisite: `failure_after_receipt`
- Windows release: `skipped`
- Ubuntu devel: `skipped`
- Ubuntu release: `skipped`
- Ubuntu oldrel-1: `skipped`
- Five-receipt aggregation: `skipped`

The hosted exact-tarball step itself completed. Its source tarball passed R CMD
check with `Status: OK`; the repository static suite loaded the package from the
retained check library and completed 26 tests; the current worker then passed
all 49 cells and all three resource scales. The uploaded macOS receipt was read
back independently and its receipt hash was valid.

The job failed only in the later general release-readiness review. That review
treated development-expected states—no CRAN `--as-cran`, manual, `--run-donttest`,
or final release-candidate record—as G4 concerns. Those are G6/release gates,
not falsifiers of the development-only fixed-calibration confirmation. The
workflow now requires the eight repository gates material to G4 plus an exact
successful, version-matched package check; it leaves G6 and public API
authorization false.

## Retained hosted receipt

- Candidate tarball SHA-256:
  `e948b157aae0f5c822858116f418cf5e5011a91c3f0ae70bf9af83c7404d8f5a`
- Candidate manifest hash:
  `984b83f86a3e98157e497d2c81177aa6bc15dcbe0bd3e83ec55ca69e346334ab`
- Production registry hash:
  `3f9bc9bed57910194e82b1a1996b1a6e3d45ff312991f3b99d81a772abded343`
- Support registry hash:
  `03cadab9cf7325462f54e31b56c5c92169a7555537a0fab64dc9d6e2957cf64f`
- Receipt hash:
  `4df2976e8319ef7f87b4cf54388db8623a0e26e2398b7426799e13e2efa1c009`

The same commit's local macOS execution produced production registry hash
`8bc3ead3efed7296f0f4af1b5a7197885e42d6181cb1a6d77592dff229103547`
despite an identical clean Git tree. Both registries were hashes of serialized
R data frames. R serialization includes runtime writer metadata, so it cannot
serve as a cross-R identity representation. The binding and hosted receipt path
now use one canonical type-tagged UTF-8/text encoding before SHA-256 hashing.
This support-contract repair changes no production file, fixture, handler,
threshold, numerical decision, or v4 confirmation identity. A new clean
candidate must nevertheless repeat all cells because the support registry and
workflow changed.

- `ExactTarballCheckStatus=OK`
- `RepositoryStaticEvidenceComplete=TRUE`
- `StaticFreshProcessEnteredInstalledMode=TRUE`
- `HostedCurrentWorkerInvoked=TRUE`
- `PassedCells=49`
- `FailedCells=0`
- `ResourceScalesPassed=3`
- `HostedCellReceiptCreated=TRUE`
- `HostedCellComplete=TRUE`
- `DependentPlatformJobsSkipped=TRUE`
- `HostedPlatformMatrixComplete=FALSE`
- `G4ExitComplete=FALSE`
- `G6Authorized=FALSE`
- `PublicAPIAuthorized=FALSE`
- `V4NumericalIdentityChanged=FALSE`
- `ProductionBoundaryChanged=FALSE`
- `NextGate=portable-hash-and-g4-scoped-repository-review-rerun`
