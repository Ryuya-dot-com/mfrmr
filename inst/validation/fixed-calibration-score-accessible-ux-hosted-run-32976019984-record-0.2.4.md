# Fixed-calibration accessible score UX hosted run 32976019984 record

Status: `development_accessible_score_ux_exact_source_five_platform_pass`,
2026-08-26.

## Result

Ordinary workflow run `32976019984` completed successfully on exact head
`0e6e75222bd6c390e644b7b9ef6a308c0ef96159`. All five cells passed both the
exact source-tarball package check and repository validation review:

| Platform | Job ID | Result | Started (UTC) | Completed (UTC) |
| --- | ---: | --- | --- | --- |
| macOS release prerequisite | 98200836028 | success | 2026-08-26 13:44:43 | 2026-08-26 13:50:41 |
| Windows release | 98202837602 | success | 2026-08-26 13:50:44 | 2026-08-26 13:59:01 |
| Ubuntu devel | 98202837612 | success | 2026-08-26 13:50:43 | 2026-08-26 13:57:24 |
| Ubuntu oldrel-1 | 98202837725 | success | 2026-08-26 13:50:45 | 2026-08-26 13:59:34 |
| Ubuntu release | 98202837766 | success | 2026-08-26 13:50:44 | 2026-08-26 14:42:32 |

This exact head contains the completed pre-human score UX boundary:

- dedicated score and summary print methods with directly searchable help
  aliases;
- interval, precision, and edge-mass plot routes with draw-free plot data;
- review-priority and not-scored dispositions plus conditional-uncertainty
  language;
- semantic alternative text for the principal article figure;
- review states distinguished by shape as well as colour;
- grammatical singular/plural plot annotation; and
- a successful official-mode pkgdown build inspected at desktop and 390-pixel
  viewport widths with no document-level horizontal overflow.

Before this hosted run, the same payload passed the local exact source check
with `Status: OK` and zero errors, warnings, or notes. The local source tarball
SHA-256 was
`10be1e9432ea9ebd7a7ba5f926663e3029b0e5751e48dce9a4f8cbc4fd13e521`;
the `00check.log` SHA-256 was
`2b35dd3b73ab7f34c8c5596948cdb9918d6859a04663ab77385d48a2a964777d`.

The earlier source-truth failure `32961641396` and the successful but
superseded exact-head runs `32962886137` and `32969632558` remain in the
evidence lineage. Their outcomes are not rewritten or silently dropped.

This record and its roadmap/test bookkeeping are excluded from the package
source payload by `.Rbuildignore`. Recording the result therefore does not
alter the package payload that run `32976019984` validated.

No candidate metadata, tag, CRAN submission, publication, or human sign-off
was produced.

## Exact fields

- `AccessibleScoreUxHostedRunId=32976019984`
- `AccessibleScoreUxHostedHeadSHA40=0e6e75222bd6c390e644b7b9ef6a308c0ef96159`
- `WorkflowName=R-CMD-check`
- `WorkflowConclusion=success`
- `WorkflowCreatedUTC=2026-08-26T13:44:40Z`
- `WorkflowCompletedUTC=2026-08-26T14:42:33Z`
- `PlatformCells=5`
- `CompletePlatformCells=5`
- `SuccessfulPlatformCells=5`
- `FailedPlatformCells=0`
- `SkippedPlatformCells=0`
- `EachExactSourcePackageCheckPassed=TRUE`
- `EachRepositoryValidationReviewPassed=TRUE`
- `LocalExactSourceCheckStatus=OK`
- `LocalExactSourceCheckErrors=0`
- `LocalExactSourceCheckWarnings=0`
- `LocalExactSourceCheckNotes=0`
- `DesktopVisualInspectionPassed=TRUE`
- `NarrowViewportWidthPx=390`
- `NarrowDocumentHorizontalOverflow=FALSE`
- `PrincipalFigureSemanticAltTextPresent=TRUE`
- `ReviewStateUsesColourAndShape=TRUE`
- `PriorFailedRunId=32961641396`
- `PriorSuccessfulRunIds=32962886137,32969632558`
- `FailedRunRetainedInDenominator=TRUE`
- `CurrentPackagePayloadValidated=TRUE`
- `EvidenceOnlyFollowUpExcludedFromPackagePayload=TRUE`
- `CandidateMetadataApplied=FALSE`
- `HumanSignOffComplete=FALSE`
- `CandidateTagCreated=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `PublicationPerformed=FALSE`
- `NextAction=reform-candidate-metadata-and-bind-a-new-exact-candidate-head-before-human-sign-off`
