# mfrmr 0.2.4 public-language and calibration-schema amendment

Status: `implemented_targeted_regression_pass_local_package_check_pending`,
2026-08-26.

## User-facing result

Portable calibration artifacts and their printed summaries no longer expose
development workflow labels. The saved artifact uses
`eligibility.support_profile_id`; RSM and PCM values explicitly identify the
model, MML estimator, fixed-standard-normal scoring basis, and profile version.
`summary()` and `print()` label this value `Support profile`.

The artifact provenance records the exported constructor
`mfrmr::extract_mfrm_calibration`. Validation reports
`SUPPORT_PROFILE_INVALID` at `eligibility.support_profile_id` when the profile
does not match the model family. The semantic identity includes
`support_profile` and no longer includes the earlier development label.

Public NEWS, README, help, and vignettes were checked for workflow-oriented
terms. Reader-facing text now describes supported models, readiness criteria,
comparison routes, uncertainty, and limitations. A regression test rejects
development phase codes and the words previously used for internal workflow
stages across those public files.

## Scope and evidence

This amendment changes schema names, semantic identity text, provenance text,
validation field paths, printed labels, and documentation only. It does not
change calibration coordinates, anchors, the likelihood, optimizer,
quadrature nodes or weights, posterior equations, uncertainty calculation, or
the supported RSM/PCM MML fixed-standard-normal envelope.

Seven targeted test files passed after the change: calibration lifecycle,
public calibration API, documentation terminology, output guide, reporting,
GPCM capability boundaries, and vignette artifacts. One fresh-installed-
package check remains intentionally skipped outside an installed check
context, and three bounded-GPCM design evaluations retain their explicit CRAN
skip. A clean source-package check and fresh hosted matrix remain required.

## Exact fields

- `AmendmentId=mfrmr_public_language_schema_amendment_0_2_4_v1`
- `PreviousEligibilityField=eligibility.lane_id`
- `CurrentEligibilityField=eligibility.support_profile_id`
- `RsmSupportProfileId=rsm_mml_fixed_standard_normal_v1`
- `PcmSupportProfileId=pcm_mml_fixed_standard_normal_v1`
- `CurrentCreatorIdentity=mfrmr::extract_mfrm_calibration`
- `PublicPrintLabel=Support profile`
- `SemanticComponentName=support_profile`
- `InvalidProfileCode=SUPPORT_PROFILE_INVALID`
- `PublicDocumentationInternalProcessTermHits=0`
- `TargetedRegressionFiles=7`
- `TargetedRegressionPassed=TRUE`
- `TargetedRegressionFailures=0`
- `ExpectedInstalledContextSkips=1`
- `ExpectedCranSkips=3`
- `NumericalScoringAlgorithmChanged=FALSE`
- `StatisticalModelChanged=FALSE`
- `SupportedEnvelopeChanged=FALSE`
- `LocalSourceCheckPassed=FALSE`
- `HostedFivePlatformPassed=FALSE`
- `G6Revalidated=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=run-clean-source-package-check`
