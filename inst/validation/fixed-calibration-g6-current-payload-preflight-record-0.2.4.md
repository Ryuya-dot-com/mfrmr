# Fixed-calibration G6 current-payload preflight for mfrmr 0.2.4

Status: `machine_preflight_complete_owner_review_open`, 2026-09-06.

## Bound payload

This preflight applies to implementation commit
`71f32200a21bb349689b7e9d1d327726aeec785c`, Git tree
`07ff6e99250697c03b0593528a1dcf3d7a206b74`, and development source tarball
`mfrmr_0.2.4.9000.tar.gz` with SHA-256
`29bbc74c67fa5efaa30ce7973e4fdf04c962ccf901f3d64acebfe43cecbb1847`.
Commit `19fb6f3906cb96776ab765be5f4e7bea970e5d4c` adds only the G4 record and its
internal index entry. Both paths are excluded from the source package by
`.Rbuildignore`, so the evaluated package payload is unchanged.

The earlier unsigned human-review packet targets commit `036565f` and is not
reusable as current-payload approval. This record is a machine preflight, not
a replacement signature or release decision.

## Machine evidence

- The exact local source tarball completed `R CMD check --no-manual` with
  `Status: OK` during G4 revalidation.
- Routine GitHub Actions run `34014929402` passed all five required R/platform
  cells on the exact implementation commit.
- Dedicated G4 run `34018691491` passed all five platform cells, all 49/49
  numerical cells per platform, and all three resource scales per platform;
  the five receipt hashes and aggregate matrix hash were independently
  recomputed successfully.
- Homebrew GCC 15.2.0 with LTO built both compiled translation units, and the
  installed backend passed 37/37 pure-R-reference expectations.
- The check-installed package passed all 145/145 expectations in
  `test-calibration-public-api.R`, including lifecycle, artifact-only
  fresh-process scoring, persistence, schema refusals, and public messages.
- The CRAN package index queried on 2026-09-06 reported public version
  `0.2.3.1` and zero reverse Depends, Imports, LinkingTo, Suggests, and Enhances
  relationships. The reverse-dependency denominator is therefore zero, not
  skipped.

## Human review delta

The portable-calibration export list, implementation in
`R/core-fixed-calibration.R`, and public scoring route in `R/api-prediction.R`
are unchanged from the earlier human-review target. The supported envelope
also remains one-scale RSM/PCM MML under a fixed N(0,1) scoring basis; portable
GPCM, JML, estimated-population, and latent-regression calibration remain
unavailable.

The current payload nevertheless changes public interpretation and first-use
surfaces. A current review must therefore cover these material deltas:

- G-theory coefficients are described as observed-score, not latent-MFRM,
  quantities, and the implemented nonnegative decomposition states
  `Phi <= G`;
- `evaluate_mfrm_design(parallel = "future")` uses the active future plan with
  preallocated deterministic replication seeds;
- anchor export and reuse fail closed by default unless the source fit is
  inference-ready, while explicit review-only extraction remains available;
- direct anchors, group-mean constraints, and empirical common-element overlap
  are distinguished rather than treated as interchangeable evidence;
- facet category avoidance is separated from global score support and GPCM
  model choice, and the legacy central-tendency flag is off by default; and
- front-door examples now use an explicit RSM-MML workflow, while the FACETS
  profile name is presented as historical organization rather than a software
  prerequisite.

These are mostly semantic corrections and conservative defaults, not a wider
portable-calibration claim. They still require a fresh build of the current
pkgdown site and owner review because the older rendered-site review predates
them.

## Decision boundary

The available evidence is sufficient to complete the machine portion of the
current-payload G6 review. It is not sufficient to self-issue the owner's
product judgment. No candidate metadata, release tag, publication, or CRAN
submission is authorized here.

- `ReviewTargetCommitSHA40=71f32200a21bb349689b7e9d1d327726aeec785c`
- `ReviewTargetTreeSHA40=07ff6e99250697c03b0593528a1dcf3d7a206b74`
- `ReviewTargetTarballSHA256=29bbc74c67fa5efaa30ce7973e4fdf04c962ccf901f3d64acebfe43cecbb1847`
- `RoutineHostedRunId=34014929402`
- `RoutineHostedPassedCells=5`
- `RoutineHostedFailedCells=0`
- `G4HostedRunId=34018691491`
- `G4ExitComplete=TRUE`
- `InstalledPublicAPIExpectationsPassed=145`
- `InstalledPublicAPIExpectationsFailed=0`
- `ReverseDepends=0`
- `ReverseImports=0`
- `ReverseLinkingTo=0`
- `ReverseSuggests=0`
- `ReverseEnhances=0`
- `ReverseDependencyReviewComplete=TRUE`
- `CalibrationExportAndScoringKernelChangedSincePriorHumanTarget=FALSE`
- `OtherPublicInterpretationSurfacesChangedSincePriorHumanTarget=TRUE`
- `MachineG6PreflightComplete=TRUE`
- `FreshCurrentPayloadPkgdownReviewComplete=FALSE`
- `CurrentPayloadHumanReleaseReviewComplete=FALSE`
- `CORE08Complete=FALSE`
- `G6ExitComplete=FALSE`
- `CandidateTransitionAuthorized=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `NextAction=fresh-current-payload-pkgdown-and-owner-review`
