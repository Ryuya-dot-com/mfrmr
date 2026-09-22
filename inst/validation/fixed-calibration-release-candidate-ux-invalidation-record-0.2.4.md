# Fixed-calibration release-candidate UX invalidation record for 0.2.4

Date: 2026-08-26

## Decision

The successful package-check matrix for the previous 0.2.4 candidate remains
valid evidence that its checked source installed and passed the recorded
automated checks. It is not sufficient evidence that the portable-calibration
workflow is ready for human release sign-off.

The candidate was invalidated before human sign-off because reader-facing
inspection found a material usability and reviewability gap in the portable
score result. The `mfrm_calibration_score` object had no dedicated concise
print, structured summary, or plot method. The portable-calibration article
therefore printed wide internal result tables directly; the output was
difficult to review at narrow viewport widths and did not provide a visual
route for detecting review dispositions or conditional interval width.

Package metadata was returned to the exact development lifecycle before the
public payload was changed. No tag was created and no CRAN submission was
performed.

## Evidence inspected

- Previous evidence-only head: `b6b482d064f382f106ffd207214ccb6ae31e4eb1`
- Previous successful hosted run: `32938822686`
- Hosted run result: `5/5` jobs successful
- Local R: `4.6.1`
- Local pkgdown: `2.2.1`
- Fresh pkgdown build with the isolated development package: complete
- Desktop render inspected: home page and portable-calibration article
- Narrow render inspected: portable-calibration article at 390 px width
- Public help inspected: calibration lifecycle, capability matrix, output
  guide, and visual-diagnostics guide

## Required repair

1. Add a concise default print for `mfrm_calibration_score`.
2. Add a structured summary that foregrounds scored, review, and not-scored
   Persons without dumping all provenance columns.
3. Add a draw-free-compatible score plot that shows posterior intervals and
   review dispositions while preserving the conditional-uncertainty warning.
4. Add a dedicated help page and place it in the portable-calibration
   reference section.
5. Replace wide raw-table output in the article with the reviewed summary and
   a rendered score-review figure.
6. Rebuild and inspect the site at desktop and narrow widths, rerun package
   evidence, and create a new candidate only from the repaired payload.

## Machine-readable disposition

- `PreviousCandidateAutomatedChecksPassed=TRUE`
- `PreviousCandidateHumanSignOffComplete=FALSE`
- `FreshPkgdownBuildComplete=TRUE`
- `DesktopRenderInspected=TRUE`
- `NarrowRenderInspected=TRUE`
- `PortableScorePrintAvailable=FALSE`
- `PortableScoreSummaryAvailable=FALSE`
- `PortableScorePlotAvailable=FALSE`
- `ProductionPayloadChangeRequired=TRUE`
- `PreviousCandidateReusable=FALSE`
- `ReturnedToDevelopment=TRUE`
- `CandidateTagCreated=FALSE`
- `CRANSubmissionPerformed=FALSE`
