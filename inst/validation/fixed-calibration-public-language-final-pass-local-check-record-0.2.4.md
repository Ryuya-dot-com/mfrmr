# mfrmr 0.2.4 final public-language local package-check record

Status: `final_public_language_local_source_check_pass_hosted_running`,
2026-08-26.

## Result

A second reader-facing review removed the remaining development-process
phrasing from NEWS, the FACETS coverage help, and five vignettes. Exact commit
`772ada581c37ebab4c42e932abac32d373bef938` was then built with vignette
rebuilding and checked with `R CMD check --no-manual` under R 4.6.1 on arm64
macOS.

The check completed with `Status: OK`: zero errors, zero warnings, and zero
notes. Installed-package tests passed 435 expectations and retained three
explicit CRAN skips for bounded-GPCM design evaluation.

## Delta classification

Relative to the earlier numerically compared public-language payload at
`96068c9a16d48e7011a321f40ef125d8ab621418`, nine distributed paths changed:
NEWS, one roxygen source and its generated help page, the public-terminology
test, and five vignettes. The sole changed R source contains documentation
comments only. Parsing the old and new file with source retention disabled
produced identical executable R expressions.

No likelihood, optimizer, calibration coordinate, scoring kernel, validator,
runtime message, exported signature, or statistical model changed. The prior
old/new RSM and PCM exact numerical comparison therefore continues to address
the same executable implementation. This classification does not replace the
fresh local package check or the fresh five-platform run for the changed source
package.

Network index lookups for CRAN and Bioconductor were unavailable in the local
sandbox. `R CMD check` recorded no dependency-check warning or note. A Quarto
version probe returned a process warning after the completed check; it is not
present in `00check.log` and did not change the `Status: OK` receipt.

## Exact fields

- `ReviewContract=mfrmr_public_language_final_pass_v1`
- `EvidenceRole=package_check_and_delta_classification_only`
- `PriorCheckedCommitSHA40=96068c9a16d48e7011a321f40ef125d8ab621418`
- `CheckedCommitSHA40=772ada581c37ebab4c42e932abac32d373bef938`
- `CheckedTreeSHA40=2acf9d32d2857dd71aa22f9a7aa3f5002f9d3065`
- `PackageVersion=0.2.4.9000`
- `DistributedChangedPaths=9`
- `ExecutableRExpressionsIdentical=TRUE`
- `StatisticalCodeChanged=FALSE`
- `ScoringKernelChanged=FALSE`
- `CalibrationSchemaChanged=FALSE`
- `PublicDocumentationChanged=TRUE`
- `SourceTarballSHA256=b975104f73ca7de378a9aee523836213a1cc683369317facdf0efa4a57e43b37`
- `CheckLogSHA256=736a597848b08d5803038cf48abdf7f4e99a93070883b6184276f40045488719`
- `Errors=0`
- `Warnings=0`
- `Notes=0`
- `DistributedTestsPassed=435`
- `DistributedTestsSkipped=3`
- `SourceCheckStatus=OK`
- `PriorNumericalParityStillApplicable=TRUE`
- `G4EvidenceIssued=FALSE`
- `G4Reissued=FALSE`
- `G6Revalidated=FALSE`
- `HostedRunId=32922730035`
- `HostedRunComplete=FALSE`
- `PriorHostedRunReusableForFinalPayload=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=complete-final-public-language-five-platform-matrix`
