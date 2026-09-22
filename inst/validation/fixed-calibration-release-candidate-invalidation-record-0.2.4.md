# mfrmr 0.2.4 candidate invalidation record

Status: `candidate_invalidated_development_reopened_revalidation_required`,
2026-08-26.

## Decision

The candidate state at commit
`93d92604ed96bf7ea098b6ff52042106f44acd6b` is invalidated. No candidate tag
was created, no final candidate check suite was completed, submission was not
authorized, and no CRAN submission was performed.

The failure was detected during the final public-claim audit. The portable-
calibration public API, documentation terminology, and bounded-GPCM capability
tests passed. The vignette-artifact suite then failed one expectation because
the static artifact manifest truthfully records that its outputs were
generated with development version 0.2.4.9000 while the candidate package
version was 0.2.4.

The frozen candidate-transition contract excludes changes to distributed test
files. The required correction therefore cannot be added to that candidate or
made by widening the allowlist after seeing the result. Candidate preparation
returns to development and the production change requires new proportionate
evidence.

## Root cause and correction

`tests/testthat/test-vignette-artifacts.R` previously required
`GeneratedWith` to equal the currently installed package version exactly. That
rule works on the development line but fails during the metadata-only
0.2.4.9000-to-0.2.4 transition even when the generated artifact content and
production code are unchanged.

Changing the manifest to 0.2.4 would have falsified its generation provenance.
The correction instead retains the exact `GeneratedWith=0.2.4.9000` values and
accepts them for release 0.2.4 only. In development, only the exact 0.2.4.9000
identity is accepted. For a release version, the test accepts that exact
version or its matching `.9000` development identity; older, newer, or
different release lines remain rejected.

Commit `499c2d510f57c7d89c9263866c6265f9b124ed1e` contains the corrected test and
returns `DESCRIPTION`, `NEWS.md`, `CITATION.cff`, and `cran-comments.md` to the
development state. A read-only transition review then reports:

- metadata stage `development` and development metadata valid;
- exactly one forbidden path relative to the old G6 payload,
  `tests/testthat/test-vignette-artifacts.R`;
- old transition readiness false;
- candidate readiness false; and
- submission authorization false.

This is the intended fail-closed result. The old candidate-transition contract
is retained as historical evidence and is not reusable for the changed
payload. A new G6 evidence basis and a newly frozen transition boundary are
required before candidate metadata can be applied again.

## Repository-wide research-test disposition

A later unfiltered `devtools::test()` attempt was intentionally interrupted
after six errors across four ConQuest research contexts. Those harnesses bind
the loaded namespace to a historical 0.2.3 source identity and correctly
refused the 0.2.4.9000 working tree. They are repository research assets,
excluded from the source package, and are not rewritten or counted as passing
release tests. The release-relevant next step is the clean exact source-package
check, whose distributed test denominator excludes those version-pinned
historical harnesses by construction.

## Decision fields

- `InvalidatedCandidateCommitSHA40=93d92604ed96bf7ea098b6ff52042106f44acd6b`
- `CandidateMetadataCommitSHA40=e1fda8274579d8de6e7931148c3c59fad7d2d469`
- `RecoveryDevelopmentCommitSHA40=499c2d510f57c7d89c9263866c6265f9b124ed1e`
- `FailedTestFile=tests/testthat/test-vignette-artifacts.R`
- `FailedExpectation=GeneratedWith_must_equal_current_package_version`
- `FailedExpectations=1`
- `CandidateAuditExecuted=TRUE`
- `CandidateAuditPassed=FALSE`
- `PublicCalibrationApiExpectationsPassed=70`
- `PublicCalibrationApiExpectationsSkipped=1`
- `DocumentationTerminologyExpectationsPassed=54`
- `GpcmCapabilityExpectationsPassed=215`
- `VignetteArtifactExpectationsPassedBeforeFailure=69`
- `CandidateMetadataDryRunInvalidated=TRUE`
- `ReleaseTransitionContractReusable=FALSE`
- `ReturnedToDevelopment=TRUE`
- `ProductionChangeRequired=TRUE`
- `UnfilteredRepositoryTestRun=INTERRUPTED_AFTER_6_VERSION_BOUND_RESEARCH_ERRORS`
- `VersionBoundResearchContexts=4`
- `CandidateTagCreated=FALSE`
- `FinalCandidateChecksRun=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=run-new-development-payload-regression`
