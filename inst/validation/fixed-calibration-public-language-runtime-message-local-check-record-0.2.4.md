# mfrmr 0.2.4 public-language runtime-message local check

Status: `public_language_runtime_messages_local_pass_hosted_running`,
2026-08-26.

## Result

The final reader-facing review extended beyond documentation to rare GPCM JML
boundary messages. Development-stage labels were replaced with descriptions of
the relevant reachable-parameter, finite-limit, response-image, binary-closure,
and simplex-face conditions. Help text also explains reduced example settings
in terms of substantive use rather than package-check or CRAN runtime.

Exact commit `0dd03dd9830371dd13159db68f00d14ada0cb0ba` was built with vignette
rebuilding and checked with `R CMD check --no-manual` under R 4.6.1 on arm64
macOS. The check completed with `Status: OK`: zero errors, zero warnings, zero
notes, 435 installed-package expectations passed, and three explicit CRAN
skips were retained for bounded-GPCM design evaluation.

## Numerical and package-content falsifiers

The exact final tarball was installed into a separate library. The same
deterministic RSM/MML and PCM/MML fit, calibration freeze, and scoring
comparison used for the earlier schema review was rerun. Both complete result
objects were identical to the earlier results. Fitted parameter differences,
calibration-coordinate differences, and Person-estimate differences were all
zero; the serialized object hashes were unchanged.

The tarball member list contains no `inst/validation`, root roadmap, or internal
fixed-calibration evidence test. Direct scans of README, NEWS, vignettes, help,
and quoted R strings found no blocked development-process phrase or boundary
stage code. The only `P`-number matches were ordinary example Person identifiers
(`P01`/`P001`).

## Delta classification

Relative to `772ada581c37ebab4c42e932abac32d373bef938`, fourteen distributed
paths changed: two roxygen sources and their generated help, nine GPCM boundary
sources, and the public-terminology test. The GPCM edits change diagnostic text
only. No conditional, loop, return value, parameter mapping, likelihood,
gradient, optimizer, calibration coordinate, scoring kernel, or public
signature changed. Focused tests for all nine boundary sources passed before
the complete package check.

Network index lookups for CRAN and Bioconductor were unavailable in the local
sandbox. `R CMD check` recorded no dependency warning or note. A Quarto version
probe returned a process warning after the completed check; it is absent from
`00check.log` and does not alter the `Status: OK` receipt.

## Exact fields

- `ReviewContract=mfrmr_public_language_runtime_message_review_v1`
- `EvidenceRole=package_check_content_audit_and_numerical_parity`
- `PriorCheckedCommitSHA40=772ada581c37ebab4c42e932abac32d373bef938`
- `CheckedCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba`
- `CheckedTreeSHA40=1697a7df6b2bd9d9b2540ac7036975f5d9921d83`
- `PackageVersion=0.2.4.9000`
- `DistributedChangedPaths=14`
- `ControlFlowChanged=FALSE`
- `NumericExpressionChanged=FALSE`
- `StatisticalModelChanged=FALSE`
- `ScoringKernelChanged=FALSE`
- `CalibrationSchemaChanged=FALSE`
- `PublicDocumentationChanged=TRUE`
- `PublicRuntimeMessageChanged=TRUE`
- `SourceTarballSHA256=4876a1c247109567399e74101f3bfd5b69b7e911e310f0a6ea31589e79a37241`
- `CheckLogSHA256=2f40ab9aab06d7982883f77bf85ed53f34f4db5444c800fb9afa6f3b2698b810`
- `Errors=0`
- `Warnings=0`
- `Notes=0`
- `DistributedTestsPassed=435`
- `DistributedTestsSkipped=3`
- `SourceCheckStatus=OK`
- `RsmOldNewObjectIdentical=TRUE`
- `PcmOldNewObjectIdentical=TRUE`
- `RsmResultSHA256=d0dbbb2b8b2a531f595afe4eca3825b8e214e4bd12a03cfd2462792f315ebb7d`
- `PcmResultSHA256=bd3c80b90a037ec3e678148f93e5f55d635787f5174f72dba0917ef20a9d462f`
- `MaxFitParameterDifference=0`
- `MaxCalibrationCoordinateDifference=0`
- `MaxPersonEstimateDifference=0`
- `InternalValidationPathsInTarball=0`
- `PublicDocumentationBlockedPhraseHits=0`
- `PublicRuntimeBoundaryCodeHits=0`
- `G4EvidenceIssued=FALSE`
- `G4Reissued=FALSE`
- `G6Revalidated=FALSE`
- `HostedRunId=32923607662`
- `HostedRunComplete=FALSE`
- `PriorHostedRunReusableForFinalPayload=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=complete-public-language-runtime-message-five-platform-matrix`
