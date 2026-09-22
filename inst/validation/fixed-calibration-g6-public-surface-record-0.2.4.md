# Fixed-calibration G6 public-surface record for mfrmr 0.2.4

Status: `core07_complete_cross_platform_release_decision_open`, 2026-08-26.

## Completed slice

The first G6 slice promotes only the already validated portable-calibration
core through a thin public layer. It adds these exported operations without
changing the internal schema, lifecycle, posterior kernel, quadrature, or
parameter materialization:

- `mfrm_calibration_capabilities()`;
- `extract_mfrm_calibration()` and `review_mfrm_calibration()`;
- `validate_mfrm_calibration()` and `freeze_mfrm_calibration()`;
- `save_mfrm_calibration()` and `load_mfrm_calibration()`;
- `score_mfrm_calibration()`; and
- `supersede_mfrm_calibration()` and `retire_mfrm_calibration()`.

The central public capability matrix has six rows. Only one-scale RSM and PCM
MML under the fixed-standard-normal scoring basis are `available`. Estimated-
population/latent-regression MML, bounded GPCM MML, RSM/PCM JML, and bounded
GPCM JML are `unavailable` as portable artifacts, with an actionable fitted-
object alternative on every row. This matrix does not narrow the existing
fitted-object routes.

The new public vignette fits a bundled synthetic data subset, extracts a draft,
reviews, validates, freezes, saves, removes the fit and training data, reloads
the artifact, and scores new Person identifiers using exported functions only.
It rendered successfully with executable chunks. A check-installed package
also completed the load-and-score phase in a separate `Rscript --vanilla`
process; the child script contained neither `:::` nor an internal function
name.

Public loader fixtures explicitly refused a newer schema version, an unknown
top-level field, and a missing score map. Public lifecycle tests also confirm
that a retired calibration cannot score and that save/load preserves the
artifact and score result exactly.

## Public wording boundary

README, NEWS, generated help, the new vignette, and pkgdown navigation now use
the same narrow portable envelope and distinguish it from fitted-object
scoring. They state that posterior EAP uncertainty is conditional on the
frozen point calibration and recorded prior, excludes calibration-parameter
uncertainty, and does not authenticate untrusted artifact files. The public
surfaces contain no gate identifiers, run identifiers, candidate mechanics,
or internal function names.

`mfrmr_output_guide("calibration")` now provides a four-step route from the
capability matrix through lifecycle, persistence, and artifact-only scoring.
Its scoring boundary repeats the conditional point-calibration uncertainty
statement. Public extraction translates unsupported family, estimator, and
population-basis refusals into actionable fitted-object alternatives while
retaining their structured error codes; the exposed messages contain no
internal lane or gate labels.

One difference exposed by this reconciliation is now explicitly resolved for
0.2.4: the internal schema can represent and validate shared-step and owner-
specific step anchors, but the current public `fit_mfrm()` interface has no
typed step-anchor declaration. Consequently the public capability matrix
claims only preservation of stored direct and group facet anchors. The public
0.2.4 envelope is re-chartered to that smaller behavior; public step-anchor
construction is deferred rather than added during release hardening. The
internal shared/owned representation remains tested but is not a public
capability. Documentation is not allowed to imply that an internal test helper
is a public workflow.

## Local source and rendered-site result

The complete pkgdown site was rebuilt after the wording reconciliation. Its
home page, package help, reference index, capability page, lifecycle page, and
portable-calibration article link to one another and state the same six-row
support envelope. A rendered-site scan found no release-process identifiers or
the superseded fit-gate wording. `DESCRIPTION` remains the non-conflicting
0.2.4.9000 development identity with public predecessor 0.2.3.1; it was not
changed merely to repeat the more specific capability matrix.

The final local source candidate was built with all vignettes at
`/private/tmp/mfrmr-g6-final3-oIR9qm/mfrmr_0.2.4.9000.tar.gz`. Its SHA-256 is
`bd13e8d4e26b1c914c4f5c7f8ee5f5f60a3499531ca6c48d45eeabb499f76f80`.
`R CMD check --no-manual` returned `Status: OK`: examples passed, all vignettes
rebuilt, and the distributed test suite reported 435 passes, three documented
CRAN-only bounded-GPCM skips, zero failures, and zero warnings. The installed-
package fresh-process calibration test executed rather than skipping. The
source tarball contains the public wrappers, help, vignette, installed article,
and public tests; repository validation records and the ConQuest/G-theory
research tests are absent as required.

An exploratory `NOT_CRAN=true` checkout-wide run also traversed ignored
research files. Its ordinary production, replay, checkpoint, fixed-calibration,
GPCM, and anchor tests passed, but version-pinned 0.2.3 ConQuest harnesses,
unopened/optional G-theory execution entries, dirty-tree release checks, and a
locally mismatched TAM/glmmTMB backend produced expected non-release-clean
results. These files are excluded from the tarball and no release-critical row
depends on them; they are not counted as G6 evidence.

The no-go audit is closed for the bounded public claim. Scoring uses only the
frozen artifact, unknown schema/levels/score values and invalid weights fail
closed, save/load and fresh-process results are covered, and uncertainty is
labelled conditional on the frozen point calibration. Failed optional claims
remain unavailable in the capability matrix: estimated-population or latent-
regression MML, JML, bounded GPCM, and public typed step-anchor construction.
The exact G4 numerical production and support registries are unchanged at
`7927724339fe6b450246b3738ae3688d94d2f81fd9391c6108e2e59f7f45eafb` and
`a83594d9393b1aedf09cc57ca5b798f406aa78bc81c8568ebe03c00f245d94cc`.

## Remaining release work

- Commit the public-surface payload and run the ordinary five-platform check
  matrix on that exact commit.
- Review reverse dependencies where available.
- Make the separate CORE-08 decision from those results; G6 is not closed by
  the local source check alone.

- `PublicWrapperParityComplete=TRUE`
- `PublicCapabilityRows=6`
- `PortableAvailableRows=2`
- `PortableUnavailableRows=4`
- `FreshSessionPublicAPIScoringComplete=TRUE`
- `SchemaNewerVersionRefusalComplete=TRUE`
- `SchemaUnknownFieldRefusalComplete=TRUE`
- `SchemaPartialPayloadRefusalComplete=TRUE`
- `PublicVignetteRendered=TRUE`
- `PublicInternalLanguageClean=TRUE`
- `PublicOutputGuideIntegrated=TRUE`
- `PublicExtractionMessagesClean=TRUE`
- `PackageMetadataAligned=TRUE`
- `WebsiteBuiltAndReviewed=TRUE`
- `LocalSourceTarballSHA256=bd13e8d4e26b1c914c4f5c7f8ee5f5f60a3499531ca6c48d45eeabb499f76f80`
- `LocalSourceCheckStatus=OK`
- `DistributedTestPasses=435`
- `DistributedTestSkips=3`
- `DistributedTestFailures=0`
- `AllVignettesRebuilt=TRUE`
- `NoGoAuditComplete=TRUE`
- `ReleaseCriticalLocalOnlyDependency=FALSE`
- `StepAnchorPublicConstructionResolved=TRUE`
- `StepAnchorPublicConstructionAvailable=FALSE`
- `DirectGroupAnchorPreservationAvailable=TRUE`
- `CORE07Complete=TRUE`
- `CORE08Complete=FALSE`
- `G6ExitComplete=FALSE`
- `PublicAPIAuthorizedForRelease=FALSE`
- `NextAction=commit-and-run-ordinary-five-platform-check-matrix`
