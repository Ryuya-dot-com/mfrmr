# mfrmr 0.2.4 public-language hosted workflow record

Status: `development_public_language_five_platform_pass_g6_rebinding_pending`,
2026-08-26.

## Result

The ordinary `R-CMD-check` workflow run `32923607662` completed successfully
against exact development commit
`0dd03dd9830371dd13159db68f00d14ada0cb0ba`. All five required jobs succeeded,
and each job retained its own check artifact. No cell was borrowed from an
earlier payload or removed from the denominator.

| Cell | Job id | Conclusion | Started (UTC) | Completed (UTC) |
| --- | ---: | --- | --- | --- |
| macOS release prerequisite | 98041918483 | success | 2026-08-26 02:40:31 | 2026-08-26 02:46:12 |
| Ubuntu devel | 98042943622 | success | 2026-08-26 02:46:14 | 2026-08-26 02:53:16 |
| Ubuntu release/full | 98042943550 | success | 2026-08-26 02:46:15 | 2026-08-26 03:38:43 |
| Windows release | 98042943655 | success | 2026-08-26 02:46:14 | 2026-08-26 02:54:33 |
| Ubuntu oldrel-1 | 98042943641 | success | 2026-08-26 02:46:14 | 2026-08-26 02:53:15 |

The five unexpired artifacts observed after completion were:

| Artifact | Bytes | SHA-256 digest | Expires (UTC) |
| --- | ---: | --- | --- |
| `r-cmd-check-macos-release` | 18092227 | `35b11a8e2f353c555904a46996bc6e678aeb32d3da689693873a1d39b6a63d87` | 2026-11-24 02:40:28 |
| `r-cmd-check-ubuntu-devel` | 18735650 | `498441b038b164d0556288650338b64fe11e129f68374fe62aed7a2a5336d989` | 2026-11-24 02:40:28 |
| `r-cmd-check-ubuntu-release` | 21394000 | `97e2219f37d3c0d084f251c361f4e86dc077a67dc0ee8b5b128358dc6ac53920` | 2026-11-24 02:40:28 |
| `r-cmd-check-windows-release` | 18159083 | `f673bc8e0590e122b1d4c67ad41048e9ce9421a9562d99b0c8c7c34f67899b43` | 2026-11-24 02:40:28 |
| `r-cmd-check-ubuntu-oldrel-1` | 18714732 | `ccb6a21f02eca34f1f4504d07339c98291e949ebb162021c80541d59d9154040` | 2026-11-24 02:40:28 |

GitHub's Node.js 20-to-24 runner deprecation annotations are infrastructure
annotations, not R package check warnings, notes, or failures.

## Relationship to the local check

The hosted head is the exact commit checked locally. Its source tarball passed
with zero errors, zero warnings, and zero notes; 435 distributed expectations
passed and the three explicit bounded-GPCM design skips were retained. Exact
RSM/PCM fit, calibration, and scoring comparisons also remained identical with
maximum numerical difference zero.

This record is evidence input, not a self-authorizing release action. It does
not apply candidate metadata, create a tag, authorize submission, or submit to
CRAN.

## Exact fields

- `PublicLanguageHostedRunId=32923607662`
- `PublicLanguageHostedHeadSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba`
- `PublicLanguageHostedEvent=push`
- `PublicLanguageHostedStartedUTC=2026-08-26T02:40:28Z`
- `PublicLanguageHostedCompletedUTC=2026-08-26T03:38:44Z`
- `HostedWorkflowConclusion=success`
- `HostedPlatformCells=5`
- `HostedPassedCells=5`
- `HostedFailedCells=0`
- `CheckArtifactCount=5`
- `ExpiredArtifactCount=0`
- `LocalCheckedCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba`
- `InterveningSourcePackagePaths=0`
- `SourceTarballSHA256=4876a1c247109567399e74101f3bfd5b69b7e911e310f0a6ea31589e79a37241`
- `CheckLogSHA256=2f40ab9aab06d7982883f77bf85ed53f34f4db5444c800fb9afa6f3b2698b810`
- `LocalSourceCheckStatus=OK`
- `LocalErrors=0`
- `LocalWarnings=0`
- `LocalNotes=0`
- `DistributedTestsPassed=435`
- `DistributedTestsSkipped=3`
- `G4Reissued=FALSE`
- `G6Revalidated=FALSE`
- `CandidateMetadataApplied=FALSE`
- `CandidateTagCreated=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=bind-public-language-g6-and-freeze-transition-v3`
