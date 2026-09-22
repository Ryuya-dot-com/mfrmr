# Fixed-calibration G0 baseline and threat inventory for mfrmr 0.2.4

Status: `G0_complete_cran_0.2.3_source_bound`, 2026-08-22.

- Specification: `0.2.4-fixed-calibration-g0-baseline-threat-inventory-v1`
- Contract: `mfrmr_fixed_calibration_g0_contract_v1`
- Active stage: G0
- Fit executed: `FALSE`
- Data generated: `FALSE`
- G1 specification/implementation work authorized: `TRUE`
- Public promotion authorized: `FALSE`

## Bounded result

The claim ledger, fitted-object field inventory, current-behavior threat
inventory, provisional support matrix, and public-source binding are complete.
G0 is closed and bounded G1 work is authorized. No public operational-
calibration claim or optional-lane promotion is authorized.

The live CRAN page identifies mfrmr 0.2.3 as published on 2026-08-21. Its
canonical source artifact is `mfrmr_0.2.3.tar.gz`, with SHA-256
`3395df8ea7f9263b0b191bb9e95ff297c139355cdd25fa3da65f7c3e73fe640f` and MD5
`384f3e60d17d28c14814207b924b6f34`. The common payload files have no byte
differences from local commit `1dde9cb25f83683bd97e4ca0707901a41b1870ad`
after CRAN-generated files and DESCRIPTION normalization are separated.

The CRAN source DESCRIPTION still says `release-status: candidate` and
`public-version: 0.2.2`; GitHub Releases/Tags and R-universe also lag the CRAN
source publication. These are distribution-metadata findings, not ambiguity
about the bound source payload. CORE-07 must prevent their recurrence for
0.2.4.

## Current scorer dependency finding

The 0.2.3 `predict_mfrm_units()` path consumes substantially more than fitted
facet estimates. Its direct and transitive dependencies include:

- method, model, facet order, complete level dictionaries, score map and
  rating origin;
- step and slope owners, interaction definitions, facet signs, constraints,
  GPCM identification, and the raw optimizer parameter vector;
- quadrature size and regenerated nodes/weights;
- posterior-basis activation, population formula/coding, coefficients, and
  variance; and
- for active population models, the training-person design matrix merely to
  recover the raw parameter-vector partition.

The last dependency is specifically prohibited in the new artifact. G1 must
store expanded, named calibration coordinates so operational scoring neither
retains training-person state nor reinterprets an old raw vector through new
helper code.

## Adversarial behaviors that must not migrate silently

The predecessor scorer is an analysis helper, not the 0.2.4 operational
contract. In particular:

- it does not consult the current fit-readiness record before returning finite
  posterior scores;
- it drops missing, non-numeric, and non-positive-weight rows with a warning;
- it has no exact-event duplicate policy;
- it defaults missing quadrature size to 15 and missing posterior identity to
  `legacy_mml`;
- it selects the JML standard-normal reference prior through the method branch;
- it returns no dedicated endpoint, quadrature-edge, sparse-pattern, or
  prior-sensitivity disposition; and
- its conditional posterior intervals do not propagate calibration-parameter
  uncertainty.

Some current behaviors are positive baseline constraints: unseen non-Person
levels and unknown observed scores stop, compressed score maps are honored,
and seeded posterior draws preserve caller RNG state. G1--G4 must bind these
semantically rather than merely copy their implementation.

## Anchor baseline

The current strictness boundary is also explicit:

- direct and group facet anchors exist; threshold/step anchors do not;
- duplicate anchors and group assignments are reviewed but the last row wins;
- direct anchors take precedence over overlapping group anchors;
- missing/conflicting group values become zero or the most recent finite value;
- `make_anchor_table()` rounds to six digits by default and does not export a
  complete calibration; and
- `anchor_to_baseline()` performs a new fit and is not operational scoring.

These behaviors remain regression evidence for their existing APIs. CORE-03
requires a separate order-invariant, typed, fail-closed anchor contract.

## Provisional support matrix

| lane | frozen-calibration status | provisional disposition |
| --- | --- | --- |
| RSM MML, fixed standard normal | `not_available` | core candidate, unvalidated |
| PCM MML, fixed standard normal | `not_available` | core candidate, unvalidated |
| Estimated-population/latent-regression MML | `not_available` | OPT-01, unpromoted |
| Bounded GPCM MML | `not_available` | OPT-02, unpromoted |
| RSM/PCM JML with explicit post-hoc prior | `not_available` | OPT-03, unpromoted |
| Bounded GPCM JML | `not_available` | OPT-04, unpromoted |

No row is `validated`, `caveated`, or `experimental` for the new artifact
because that artifact and API do not exist. Existing fitted-object callability
does not change this disposition.

## G0 decision

- `ClaimLedgerComplete=TRUE`
- `FieldInventoryComplete=TRUE`
- `SupportMatrixProvisional=TRUE`
- `PublishedArtifactIdentityBound=TRUE`
- `LocalCandidateContentBound=TRUE`
- `G0ExitComplete=TRUE`
- `G1ImplementationAuthorized=TRUE`
- `PublicPromotionAuthorized=FALSE`

## Verification

- The repository claim-ledger/G0 contract test passed 51 assertions after
  carrying the evidenced CORE-01/02 G1 closure forward.
- The local 0.2.3 candidate regression run for `prediction|anchor-equating`
  passed 243 assertions with zero failures and zero skips.
- The two emitted warnings were the already-declared category-support review
  warnings in the anchor fixture; they are not evidence that the exact
  distributed 0.2.3 payload was exercised.

At G0 closure, the next bounded action was the G1 core schema, lifecycle, and
refusal-taxonomy specification. G1 has since closed CORE-01/02, and G2 has
closed CORE-03 for the internal RSM/PCM MML route. G3 has since closed CORE-04
with explicit operational-scoring dispositions. Current evidence is recorded
in the corresponding G1, G2, and G3 fixed-calibration records. None of these
transitions is public API promotion, retrofit of every predecessor behavior,
or opening an optional lane; G4 is the next release-critical boundary.
