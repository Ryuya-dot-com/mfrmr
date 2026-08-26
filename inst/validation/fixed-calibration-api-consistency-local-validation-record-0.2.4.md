# Fixed-calibration API consistency local validation record for 0.2.4

Date: 2026-08-27

## Decision

The current development payload has completed a bounded API-consistency sprint
for the release-critical `summary()`, `print()`, and `plot()` surfaces. The
registered S3 methods were checked for generic-compatible signatures. The
portable calibration artifact, portable score batch, and DIF/DFF result now
have directly discoverable method documentation. A DFF summary retains its DFF
class during dispatch rather than falling through to the DIF-only summary
label.

Portable-score console output now remains compact at an 80-column console while
the summary object keeps its complete structured tables. Long unbroken
identifiers are wrapped without truncating their value. Base graphics and
`as_ggplot()` use the same scored/review ordering and distinguish status by
both colour and shape. Precision labels are vertically separated and connected
to their points; quadrature edge-mass labels are placed inward so boundary
labels are not clipped. The calibration artifact intentionally has no raw
parameter `plot()` method: its coordinates mix parameter roles and do not carry
calibration-parameter uncertainty. Score-batch plots remain the supported
visual review surface.

The complete pkgdown site was rebuilt. The reference index exposes the three
method topics, and S3 aliases redirect to their shared pages. The reference
index, calibration-method page, score-method page, DFF-method page, and portable
calibration article were checked at 1280 px and 390 px. Every inspected page had
equal document/body client and scroll widths. Representative desktop and mobile
screens were also inspected visually.

This closes local API repair, not release validation. The prior five-platform
run belongs to an older payload and is not reused for this change. A fresh
hosted matrix is required before candidate metadata or human sign-off. No tag,
publication, or CRAN submission was performed.

## Scope and evidence

- Registered `print` / `summary` / `plot` methods inspected: `181`
- Generic-signature mismatches: `0`
- Direct portable calibration method help: present
- Direct portable score method help: present
- Direct DIF/DFF method help: present
- DFF-specific summary class retained: yes
- Normal fixture direct-print maximum width: `69`
- Normal fixture summary-print maximum width: `79`
- Complete summary tables retained outside the console preview: yes
- Long calibration identifier retained within the console width: yes
- Base/ggplot scored-review order aligned: yes
- Base/ggplot status encoding uses colour and shape: yes
- Precision review labels inspected after non-overlap layout: yes
- Edge-mass review labels inspected without clipping: yes
- Fresh pkgdown build: complete
- Desktop and 390 px page inspection: complete
- Whole-page horizontal overflow at 390 px: none on all five inspected pages
- Targeted API, calibration, DFF, ggplot, lifecycle, and namespace tests: pass
- Exact source tarball: `mfrmr_0.2.4.9000.tar.gz`
- Source tarball SHA-256:
  `b4b7fc0699b25b4803f4cae9a6cd45cd983beb8aa0383147db58de379f525b34`
- `R CMD check --no-manual` log SHA-256:
  `819b8bfc6ca3a738a7185aae832e203538562f593620fe45d926fe9d2492e570`
- Source check status: `OK`
- Source check errors / warnings / notes: `0 / 0 / 0`

## Machine-readable disposition

- `DevelopmentVersion=0.2.4.9000`
- `ReleaseStatus=development`
- `RegisteredS3MethodsAudited=181`
- `GenericSignatureMismatches=0`
- `DFFSummaryClassPreserved=TRUE`
- `CalibrationArtifactMethodHelpAvailable=TRUE`
- `CalibrationScoreMethodHelpAvailable=TRUE`
- `DFFMethodHelpAvailable=TRUE`
- `CalibrationArtifactPlotMethodAvailable=FALSE`
- `CalibrationArtifactPlotOmissionIntentional=TRUE`
- `DirectPrintMaxWidth=69`
- `SummaryPrintMaxWidth=79`
- `CompleteSummaryTablesRetained=TRUE`
- `OverlongIdentifierWrappedWithoutTruncation=TRUE`
- `BaseAndGgplotStatusEncodingAligned=TRUE`
- `PlotEncodingUsesColourAndShape=TRUE`
- `PrecisionReviewLabelsNonoverlapping=TRUE`
- `EdgeReviewLabelsClipped=FALSE`
- `FreshPkgdownBuildComplete=TRUE`
- `DesktopRenderInspected=TRUE`
- `NarrowRenderInspected=TRUE`
- `NarrowWholePageOverflowDetected=FALSE`
- `ExactSourcePackageCheckStatus=OK`
- `ExactSourcePackageErrors=0`
- `ExactSourcePackageWarnings=0`
- `ExactSourcePackageNotes=0`
- `PreviousHostedRunAppliesToCurrentPayload=FALSE`
- `CurrentPayloadHostedMatrixComplete=FALSE`
- `HumanSignOffComplete=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=commit-api-consistency-payload-and-run-fresh-five-platform-matrix`
