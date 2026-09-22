# mfrmr 0.2.4 public-language candidate-metadata record

Status: `candidate_metadata_v3_applied_local_and_hosted_checks_pass`,
2026-08-26.

## Result

The 0.2.4 candidate metadata was applied under the frozen v3 transition
contract. Clean commit `8b408083c0277dabe7c71450bd8b53dcbde0853e`
contains changes only to `DESCRIPTION`, the first `NEWS.md` heading,
`CITATION.cff`, and `cran-comments.md`.

A clean read-only v3 review found the G6-validated payload in the commit's
ancestry, 12 allowed changed paths, zero forbidden package-payload path, exact
candidate metadata, and complete CRAN-comments semantic requirements. The
review returned candidate-ready and submission authorization false.

The exact candidate source tarball was then built with complete vignette
rebuilding and checked locally with `R CMD check --no-manual` under R 4.6.1 on
arm64 macOS. The check completed with `Status: OK`: zero errors, zero warnings,
zero notes, 435 distributed expectations passed, and three explicit
bounded-GPCM design skips were retained.

## Exact source-package comparison

The candidate tarball was expanded and compared recursively with the exact
G6-validated development tarball. Only `DESCRIPTION` and `NEWS.md` differed.
The `DESCRIPTION` delta was limited to Version 0.2.4, Date 2026-08-26,
candidate release status, and the automatically generated `Packaged` time.
The `NEWS.md` delta was limited to the first heading. R sources, help,
vignettes, tests, data, compiled sources, namespace, and every other tarball
member were identical.

The candidate tarball contains no internal validation directory, root
roadmap, or repository evidence test. A direct source scan found no blocked
development-stage phrase or GPCM boundary code in public documentation and R
messages.

## Candidate metadata

- `DESCRIPTION`: Version 0.2.4, Date 2026-08-26, candidate release status;
- `NEWS.md`: first heading `# mfrmr 0.2.4`;
- `CITATION.cff`: version 0.2.4 and date-released 2026-08-26; and
- `cran-comments.md`: current bounded scope and check facts in reader-facing
  language.

`Config/mfrmr/public-version` remains `0.2.3.1`.

Ordinary five-platform workflow run `32936425346` completed unsuccessfully.
Its exact source-tarball package check on macOS passed before the subsequent
repository validation review failed. The remaining four matrix cells were
skipped. This failed run remains part of the denominator and is not reused as
candidate evidence.

The failure was traced to a legacy source-truth predicate that required the
literal phrase `single source of truth` in the public roadmap. That phrase had
correctly been removed with other internal process language. Commit
`7a0e042ba4a0d07f0b6756d3409d1b06ad89e801` replaced the literal-string rule
with a reader-facing section contract, a release-lifecycle match, and an
explicit rejection of internal process phrases. It also aligned the README
scope predicate with the current portable-calibration wording. The complete
repository release-readiness test and the fixed-calibration evidence test pass
under the repaired contract.

A fresh source tarball built after that repair differs from the exact candidate
tarball only in the automatically generated `Packaged` timestamp. Its local
`R CMD check --no-manual` completed with `Status: OK`, zero errors, zero
warnings, zero notes, 435 distributed expectations passed, and three explicit
bounded-GPCM design skips. A fresh hosted matrix is required. No candidate tag
was created and no CRAN submission was authorized or performed.

The first fresh retry, run `32938041192`, confirmed that the source-truth
repair passes. Its exact source-package check also passed. The next repository
assertion then exposed a separate lifecycle defect: the historical maintenance
bridge admitted only development metadata (`0.2.4.9000`) and therefore rejected
the valid 0.2.4 candidate metadata. The other four matrix cells were skipped.
This second failed run also remains in the denominator.

Commit `a4790789a5fb7f1869ae7e5eeb225e2290a6b820` replaced that development-only
predicate with an explicit two-state contract. It admits either the exact
undated 0.2.4.9000 development identity or the exact dated 0.2.4 candidate
identity, while rejecting missing dates, stale public predecessors, mixed
version/status pairs, and released metadata. The maintenance bridge now reports
candidate stage, release metadata aligned, and bridge complete. The complete
fixed-calibration evidence test passes. These changes are excluded from the
source package, so the candidate payload is unchanged. A second fresh hosted
matrix is required.

The second fresh matrix, run `32938822686`, completed successfully on exact
head `356d0fd4149ae275f8cfbf23c59928f37d829555`. All five platform cells
passed: macOS release prerequisite, Ubuntu release, Ubuntu devel, Ubuntu
oldrel-1, and Windows release. Every cell passed both the exact source-tarball
package check and the repository validation review. The macOS prerequisite
therefore confirmed both source truth and the lifecycle-aware maintenance
bridge before the remaining matrix opened.

Runs `32936425346` and `32938041192` remain recorded as failed attempts and are
not counted as successful evidence. No further hosted retry is required for
the current candidate payload. The remaining boundary is an explicit human
decision; no tag, CRAN submission, or publication is authorized by these
machine checks.

## Exact fields

- `TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v3_public_language`
- `CandidateMetadataCommitSHA40=8b408083c0277dabe7c71450bd8b53dcbde0853e`
- `G6ValidatedCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba`
- `G6HostedRunId=32923607662`
- `ReviewBranch=development/0.2.4`
- `WorkingTreeCleanAtReview=TRUE`
- `G6BaselineAncestor=TRUE`
- `ChangedPathCount=12`
- `CandidatePackageMetadataPathCount=2`
- `CandidateRepositoryMetadataOrRoadmapPathCount=3`
- `CandidateInternalEvidencePathCount=7`
- `ForbiddenPayloadPathCount=0`
- `ChangedPathsAllowed=TRUE`
- `ProductionPayloadUnchanged=TRUE`
- `MetadataStage=candidate`
- `CandidateVersion=0.2.4`
- `CandidateDate=2026-08-26`
- `CandidateReleaseStatus=candidate`
- `CandidatePublicVersion=0.2.3.1`
- `CandidateCffVersion=0.2.4`
- `CandidateCffDate=2026-08-26`
- `CandidateNewsHeading=# mfrmr 0.2.4`
- `ChangedDescriptionFields=Version,Config/mfrmr/release-status,Date`
- `CandidateMetadataOK=TRUE`
- `CranCommentsReady=TRUE`
- `CandidateReady=TRUE`
- `CandidateSourcePackageChangedPaths=2`
- `CandidateSourcePackageChangedPath1=DESCRIPTION`
- `CandidateSourcePackageChangedPath2=NEWS.md`
- `CandidateSourceTarballSHA256=6570b98e0335de3862a5c2f12355b59c2e681dc5f3ed31d03238bc6c730836a5`
- `CandidateCheckLogSHA256=8574d99765e1b29a74dc4a435f099c33e032835e39c86576176eb6963deedd33`
- `CandidateLocalSourceCheckStatus=OK`
- `CandidateLocalErrors=0`
- `CandidateLocalWarnings=0`
- `CandidateLocalNotes=0`
- `CandidateDistributedTestsPassed=435`
- `CandidateDistributedTestsSkipped=3`
- `PublicDocumentationBlockedPhraseHits=0`
- `PublicRuntimeBoundaryCodeHits=0`
- `CandidateHostedRunId=32936425346`
- `CandidateHostedRunComplete=TRUE`
- `CandidateHostedRunSuccess=FALSE`
- `CandidateHostedPackageCheckPassed=TRUE`
- `CandidateHostedRepositoryValidationPassed=FALSE`
- `CandidateHostedMatrixCellsPassed=0`
- `CandidateHostedMatrixCellsSkipped=4`
- `CandidateHostedRetryRequired=TRUE`
- `SourceTruthRepairCommitSHA40=7a0e042ba4a0d07f0b6756d3409d1b06ad89e801`
- `SourceTruthRepairSourceTarballSHA256=fa3b13f1d179e34838bce8f8b457b7552965a7cedad3528aa3b6f206a981cf47`
- `SourceTruthRepairCheckLogSHA256=52a65160fb4b49fce01d7651e9bda8a7c053518b9bc889418e6659dcf1856d24`
- `SourceTruthRepairLocalSourceCheckStatus=OK`
- `SourceTruthRepairLocalErrors=0`
- `SourceTruthRepairLocalWarnings=0`
- `SourceTruthRepairLocalNotes=0`
- `SourceTruthRepairDistributedTestsPassed=435`
- `SourceTruthRepairDistributedTestsSkipped=3`
- `SourceTruthRepairPriorCandidatePayloadDiff=DESCRIPTION_PACKAGED_TIMESTAMP_ONLY`
- `CandidateHostedRetryRunId=32938041192`
- `CandidateHostedRetryRunComplete=TRUE`
- `CandidateHostedRetryRunSuccess=FALSE`
- `CandidateHostedRetryPackageCheckPassed=TRUE`
- `CandidateHostedRetrySourceTruthPassed=TRUE`
- `CandidateHostedRetryMaintenanceBridgePassed=FALSE`
- `CandidateHostedRetryMatrixCellsPassed=0`
- `CandidateHostedRetryMatrixCellsSkipped=4`
- `CandidateHostedSecondRetryRequired=TRUE`
- `MaintenanceBridgeRepairCommitSHA40=a4790789a5fb7f1869ae7e5eeb225e2290a6b820`
- `MaintenanceBridgeContractId=mfrmr_fixed_calibration_g4_maintenance_admission_v2_lifecycle_aware`
- `MaintenanceBridgeMetadataStage=candidate`
- `MaintenanceBridgeReleaseMetadataAligned=TRUE`
- `MaintenanceBridgeComplete=TRUE`
- `MaintenanceBridgeProductionPayloadUnchanged=TRUE`
- `CandidateHostedSecondRetryRunId=32938822686`
- `CandidateHostedSecondRetryHeadSHA40=356d0fd4149ae275f8cfbf23c59928f37d829555`
- `CandidateHostedSecondRetryRunComplete=TRUE`
- `CandidateHostedSecondRetryRunSuccess=TRUE`
- `CandidateHostedSecondRetryPlatformCells=5`
- `CandidateHostedSecondRetryPlatformCellsPassed=5`
- `CandidateHostedSecondRetryPlatformCellsFailed=0`
- `CandidateHostedSecondRetryPlatformCellsSkipped=0`
- `CandidateHostedSecondRetryEachPackageCheckPassed=TRUE`
- `CandidateHostedSecondRetryEachRepositoryReviewPassed=TRUE`
- `CandidateHostedSecondRetryMacOSJobId=98085368909`
- `CandidateHostedSecondRetryUbuntuReleaseJobId=98086404242`
- `CandidateHostedSecondRetryUbuntuDevelJobId=98086404271`
- `CandidateHostedSecondRetryUbuntuOldrelJobId=98086404295`
- `CandidateHostedSecondRetryWindowsReleaseJobId=98086404330`
- `CandidateHostedFurtherRetryRequired=FALSE`
- `CandidateValidationHostedComplete=TRUE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=hold-for-explicit-human-sign-off-no-submission`
