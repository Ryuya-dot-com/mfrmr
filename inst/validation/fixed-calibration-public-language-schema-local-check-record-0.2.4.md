# mfrmr 0.2.4 public-language/schema local package-check record

Status: `public_language_schema_local_source_check_pass_hosted_running`,
2026-08-26.

## Result

Exact development commit
`96068c9a16d48e7011a321f40ef125d8ab621418` was built as a source package with
vignette rebuilding and checked with `R CMD check --no-manual` under R 4.6.1
on arm64 macOS. The check completed with `Status: OK`: zero errors, zero
warnings, and zero notes.

The installed source-package test denominator passed 435 expectations and
retained three explicit CRAN skips for bounded-GPCM design evaluation. The
distributed documentation and vignette-artifact tests therefore exercised the
reader-facing wording and same-release-line artifact provenance in an
installed-package context.

Network index lookups for CRAN and Bioconductor were unavailable in the local
sandbox. `R CMD check` recorded no dependency-check warning or note. A Quarto
version probe also returned a process warning after the completed check; it is
not present in `00check.log` and did not change the `Status: OK` receipt.

## Scope

This is package-check evidence only. It does not issue G4 evidence, revalidate
G6, freeze another candidate transition, apply candidate metadata, create a
tag, or authorize submission. Ordinary five-platform run `32920882662` was
started separately against the same exact commit.

## Exact fields

- `CheckContract=mfrmr_release_check_receipt_v1`
- `EvidenceRole=package_check_only`
- `CheckedCommitSHA40=96068c9a16d48e7011a321f40ef125d8ab621418`
- `CheckedTreeSHA40=7569b4b84dc0182b22fc7d9c5582c17cb606f920`
- `PackageVersion=0.2.4.9000`
- `SourceTarballSHA256=ad901c65751ffc9974f1ea2ab2739058d8e9f5c672833e3792a85932784c5956`
- `CheckLogSHA256=2fda34c792dcc83301699b1bfc44a530933648d09d8fdc07883e0aeff619147e`
- `Errors=0`
- `Warnings=0`
- `Notes=0`
- `DistributedTestsPassed=435`
- `DistributedTestsSkipped=3`
- `SourceCheckStatus=OK`
- `G4EvidenceIssued=FALSE`
- `G4ExitComplete=FALSE`
- `G6Revalidated=FALSE`
- `HostedRunId=32920882662`
- `HostedRunComplete=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=complete-public-language-schema-five-platform-matrix`
