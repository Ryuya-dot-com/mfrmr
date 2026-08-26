# mfrmr 0.2.4 candidate-recovery local package-check record

Status: `development_recovery_local_source_check_pass_hosted_pending`,
2026-08-26.

## Result

The clean development recovery commit
`76b4d65722cf82cc082717750ea14340571918a1` was built once as a source package
with complete vignette rebuilding and checked locally with
`R CMD check --no-manual`. The check completed with status `OK`: zero errors,
zero warnings, and zero notes.

The distributed CRAN-light test denominator passed 435 expectations and
skipped three bounded-GPCM design-evaluation cases under the explicit CRAN
condition. The static vignette-artifact suite, including the corrected
same-release-line generation-provenance rule, passed inside that source-
package check.

The tarball contained none of `inst/validation`, `ROADMAP.md`, the version-
bound ConQuest/G-theory/rater-anchor research tests, or the repository-only G4
evidence test. Thus the earlier unfiltered research-harness errors are neither
silently counted as release passes nor present in the distributed test
denominator.

## Scope

This receipt is local package-check evidence for a development payload. It
does not revalidate G4 or G6, does not restore the invalidated candidate, does
not create a candidate identity or tag, and does not authorize submission.
The next release-critical step is a fresh ordinary five-platform workflow on
the same package payload.

## Exact fields

- `CheckContract=mfrmr_release_check_receipt_v1`
- `EvidenceRole=package_check_only`
- `CheckedCommitSHA40=76b4d65722cf82cc082717750ea14340571918a1`
- `CheckedTreeSHA40=5f34a0c205e9d4338b549b031c13c90b52cbfdc7`
- `PackageVersion=0.2.4.9000`
- `SourceTarballSHA256=ff7ea0878cef0d6ee4a6ada10db95ea43d7265452070a05be57b61005e6c9dfe`
- `CheckLogSHA256=079faf2555105ff56d98037b00b1796d5fd08b227fe746c5be2c7fd0b74325d9`
- `Errors=0`
- `Warnings=0`
- `Notes=0`
- `DistributedTestsPassed=435`
- `DistributedTestsSkipped=3`
- `SourceCheckStatus=OK`
- `SourceValidationRecordsIncluded=FALSE`
- `VersionBoundResearchTestsIncluded=FALSE`
- `G4EvidenceIssued=FALSE`
- `G4ExitComplete=FALSE`
- `G6Revalidated=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=run-recovery-five-platform-matrix`
