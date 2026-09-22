# Fixed-calibration G6 public-language decision for mfrmr 0.2.4

Status: `g6_revalidated_after_public_language_review_bounded_api_authorized`,
2026-08-26.

## Decision

G6 is revalidated for exact development payload
`0dd03dd9830371dd13159db68f00d14ada0cb0ba`. The deliberately bounded public
scope remains one observed RSM/PCM scale, MML, a fixed standard-normal scoring
basis, stored direct/group facet anchors, and artifact-only scoring of new
Persons. No model, estimator, anchor type, response structure, or support
profile is added.

The public-language review changed terminology in calibration artifacts,
printed output, help, vignettes, and rare GPCM boundary messages. It also
renamed the public calibration-schema field `eligibility.lane_id` to
`eligibility.support_profile_id`. The new schema label is deliberately
incompatible with artifacts written under the earlier development schema; it
does not change fitted parameters, calibration coordinates, or scores.

This decision authorizes only an independently frozen v3 development-to-
candidate transition boundary. It does not revive an earlier candidate, reuse
the v1 or v2 transition, apply candidate metadata, create a tag, authorize
submission, or submit to CRAN.

## Delta from the prior G6 payload

Relative to prior G6 payload
`e39571974f70da0db90444732b5719c187a004d2`, Git reports 62 changed repository
paths. Forty-nine enter the source package: 27 R sources, 11 generated help
files, seven vignettes, three distributed tests, and `NEWS.md`. The remaining
13 are the public repository roadmap and source-package-excluded evidence or
tests.

The R changes alter public labels, schema/provenance names, help text, and
diagnostic messages. They do not alter a likelihood, gradient, optimizer
branch, scoring quadrature, posterior calculation, fitted parameter map, or
calibration coordinate. Exact old/new source-tarball RSM and PCM comparisons
returned identical complete result objects, zero maximum parameter,
calibration-coordinate, and Person-estimate difference, and unchanged
serialized result hashes.

The prior statistical G4 evidence therefore continues to address the same
implementation and estimand. G4 is not reissued or inferred from routine
package checks. The public schema compatibility boundary and G6 package/public
surface decision are revalidated here instead.

## Fresh denominator and public-surface audit

The exact source-package check at
`0dd03dd9830371dd13159db68f00d14ada0cb0ba` completed with zero errors, zero
warnings, and zero notes. It passed 435 distributed expectations and retained
three explicit bounded-GPCM design skips.

Ordinary GitHub Actions run `32923607662` passed all five fresh cells: macOS
release, Windows release, Ubuntu devel, Ubuntu release/full, and Ubuntu
oldrel-1. Exactly five corresponding, unexpired check artifacts were retained.
No failed or missing cell was removed from the denominator.

The exact tarball contained no internal validation path, root roadmap, or
repository evidence test. Direct scans of README, NEWS, vignettes, help, and
quoted runtime strings found zero blocked development-process phrase and zero
GPCM boundary-stage code. A subsequent source-package-excluded rewrite also
reduced the public repository roadmap to reader-facing scope and direction;
it does not change the hosted package payload bound by this decision.

## Decision fields

- `FinalPublicLanguageG6DecisionId=mfrmr_fixed_calibration_g6_public_language_0_2_4_v1`
- `PriorG6ValidatedCommitSHA40=e39571974f70da0db90444732b5719c187a004d2`
- `PriorG6HostedRunId=32915301113`
- `ValidatedPayloadCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba`
- `HostedRunId=32923607662`
- `HostedWorkflowConclusion=success`
- `HostedPlatformCells=5`
- `HostedPassedCells=5`
- `HostedFailedCells=0`
- `CheckArtifactCount=5`
- `LocalCheckedCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba`
- `LocalSourceCheckStatus=OK`
- `LocalErrors=0`
- `LocalWarnings=0`
- `LocalNotes=0`
- `PathsChangedFromPriorG6=62`
- `DistributedPackageChangedPaths=49`
- `DistributedRChangedPaths=27`
- `DistributedManChangedPaths=11`
- `DistributedVignetteChangedPaths=7`
- `DistributedTestChangedPaths=3`
- `CalibrationSchemaChanged=TRUE`
- `ScoringKernelChanged=FALSE`
- `LikelihoodChanged=FALSE`
- `OptimizerNumericalLogicChanged=FALSE`
- `PublicWordingChanged=TRUE`
- `PublicScopeChanged=FALSE`
- `RuntimeBoundaryMessageChanged=TRUE`
- `DirectRsmPcmNumericalParity=TRUE`
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
- `G4Reissued=FALSE`
- `G4StatisticalEvidenceStillApplicable=TRUE`
- `PriorCandidateReusable=FALSE`
- `PriorTransitionV1Reusable=FALSE`
- `PriorTransitionV2Reusable=FALSE`
- `G6Revalidated=TRUE`
- `G6ExitComplete=TRUE`
- `PublicAPIAuthorizedForRelease=TRUE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=freeze-public-language-transition-boundary-v3`
