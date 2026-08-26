# mfrmr 0.2.4 recovery transition v2 invalidation record

Status: `recovery_transition_v2_invalidated_public_language_revision`,
2026-08-26.

## Decision

Recovery transition contract v2 is invalidated before candidate metadata was
applied. No candidate commit or tag was created, no candidate check was
started, submission was not authorized, and no CRAN submission was performed.

A user-facing language audit found that the new portable-calibration object
exposed development terminology through its saved schema and public
`summary()` and `print()` methods. In particular, the artifact stored
`eligibility.lane_id`, values prefixed with `core_`, and a non-exported helper
name; printed output labelled the value as `Lane`. Some errors and public
guides also used development labels such as `G1`, `OPT-01`, `core lane`,
`gate`, `preflight`, and `matched lane`.

These terms do not help a user determine what can be fitted, saved, scored, or
interpreted. Leaving them in place would also make development workflow names
part of the first public artifact schema. The correction is therefore a
package-payload change, not an allowed metadata transition.

## Correction boundary

The portable artifact now uses `eligibility.support_profile_id`, with explicit
RSM/PCM MML fixed-standard-normal profile identifiers. Public summaries label
the field `Support profile`. The recorded creator names the exported
`extract_mfrm_calibration()` function. User-visible errors and documentation
describe supported models, readiness criteria, comparison routes, and scoring
limitations without referring to development gates or roadmap codes.

The change does not alter the likelihood, optimizer, quadrature algorithm,
stored numeric coordinates, posterior scoring equations, or supported model
envelope. It does change the schema field names, semantic identity components,
validation refusal code for an invalid support profile, provenance text, and
public wording. Fresh schema, lifecycle, persistence, public-surface,
source-package, and hosted checks are required before another candidate
transition can be frozen.

## Decision fields

- `InvalidatedTransitionContractId=mfrmr_release_candidate_transition_0_2_4_v2_recovery`
- `InvalidatedTransitionCommitSHA40=e49903255fb728bf4cc631ad66077700840c043b`
- `InvalidatedTransitionRecordCommitSHA40=fb23fdbfbe917d0aa55718bb70d74e685eb6fee6`
- `CandidateMetadataApplied=FALSE`
- `CandidateCommitCreated=FALSE`
- `CandidateTagCreated=FALSE`
- `CandidateChecksRun=FALSE`
- `SubmissionAuthorized=FALSE`
- `CRANSubmissionPerformed=FALSE`
- `ProductionPayloadChanged=TRUE`
- `PublicArtifactSchemaChanged=TRUE`
- `NumericalScoringAlgorithmChanged=FALSE`
- `StatisticalModelChanged=FALSE`
- `OldCandidateReusable=FALSE`
- `TransitionV1Reusable=FALSE`
- `TransitionV2Reusable=FALSE`
- `ReturnedToDevelopment=TRUE`
- `NextAction=run-public-language-and-schema-regression`
