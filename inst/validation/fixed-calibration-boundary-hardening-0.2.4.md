# 0.2.4 boundary-hardening disposition

Status: `maintenance_integrated_post_maintenance_g4_pending`, 2026-08-25.

## Decision

The replay, fitted-object scoring, MML--EM checkpoint, and release-metadata
defects found by the 2026-08-23 source audit are corrected directly on
`development/0.2.4`. At the time of this disposition no 0.2.3.1 release was
planned. That sequencing decision was superseded on 2026-08-25 by a focused
CRAN-requested maintenance release. This disposition does not change the
audited ordinary RSM/PCM fitting likelihood or gradient; it hardens post-fit
reproduction, scoring, resume, and identity boundaries.

The changes are production-code changes after the hosted G4 result at commit
`f492fb9f0ee977777d03f0255de008af33860db5`. That result is retained as
historical evidence for its exact explicit nine-node calibration payload. It
is not current-source confirmation. CORE-05, CORE-06, and G4 are reopened;
G6 and public API promotion remain held.

## Implemented disposition

| Finding | Implementation | Local falsifier |
| --- | --- | --- |
| Interaction arguments absent from replay | Replay emits `facet_interactions`, `min_obs_per_interaction`, and `interaction_policy`. | Interaction round trip compares specification, parameter count, log likelihood, interaction effects, facet effects, and readiness; a registry test rejects unhandled material replay fields. |
| JML scoring inherited fit-time quadrature | Fitted-object scoring has `scoring_quad_points = 31L`, independent of fitting, and refuses values below 2. Replay preserves the scoring setting. | A JML/PCM fit made with one fit-time node returns non-degenerate EAP uncertainty under the default scoring grid; an explicit one-node scoring request fails. |
| Non-ready fits could produce ordinary scores | A purpose-specific scoring-readiness contract requires a current readiness record, valid support and boundary states, ready numerical state, and a finite parameter layout. `readiness_policy = "review"` is the only bypass and labels every result review-only. | Non-ready numerical and bounded-GPCM cases fail closed by default; valid latent-regression and explicitly recoded-score paths remain available under their recorded semantics. |
| Positive infinite weights reached posterior arithmetic | Fitted-object and artifact scoring refuse every non-finite or non-positive supplied weight. | Zero, `Inf`, `-Inf`, `NaN`, and `NA` fixtures fail before posterior normalization. |
| Checkpoints lacked objective identity | Checkpoint schema v2 binds package, engine stage, model, parameter layout/names, facet dictionaries, score map, constraints/anchors, interactions, population specification, quadrature, and a prepared-objective fingerprint. Payload scalars and the finite named parameter vector are validated before use. | Same-shape score and quadrature mutations, legacy payloads, corrupt layouts, and cross-stage reuse are rejected. |
| Hybrid ignored checkpoints | Hybrid passes the checkpoint through its EM warm-start stage with a distinct stage identity. | A hybrid run writes a completed warm-start checkpoint and a second run loads it before direct polishing. |
| Completed checkpoint could enter a descending iteration sequence | Iteration and cadence values require finite positive integers; completed pure EM cannot re-enter at the same `maxit`; writes use a temporary file and checked same-directory replacement. | Same-`maxit` reuse leaves the saved boundary unchanged; a non-converged pure-EM checkpoint can continue only with a larger outer limit. |
| Development metadata described the wrong release | `DESCRIPTION` and `CITATION.cff` use 0.2.4.9000; release status is `development`; public predecessor is 0.2.3.1; development release dates are absent. | The source-truth release check binds version, lifecycle, declared public baseline, and date policy. |

## 2026-08-25 maintenance-line addendum

CRAN 0.2.3.1 was published as a narrower maintenance correction. It removes a
local `HAVE_ENUM_BASE_TYPE` override that made compiled translation units use
inconsistent `Rboolean` definitions under LTO, adds a source-level regression
contract, and removes expired FACETS/Winsteps hyperlinks. It does not contain
the eight replay, scoring, checkpoint, and metadata corrections above.

The 0.2.3.1 implementation commits and their 0.2.4 integration counterparts
have identical stable patch ids:

- `69cc7a0 = dc4a337` (`8744a9894ab0a02186cab16ef3e337b067abbbeb`);
- `3eda09f = 7fa91a1` (`b99133ae6ab40c1496e9b7550b2b98097cd194d8`).

The integration merge preserves all eight 0.2.4 boundary corrections and
changes no exported R signature, likelihood/gradient expression, scoring
algorithm, checkpoint schema, or calibration schema. `DESCRIPTION` now names
0.2.3.1 as the public predecessor, and the exact CRAN source identity is bound
by `public-release-baseline-0.2.4.csv` and the G0 maintenance addendum.

The v5 G4 close at `bcf8619` predates this compiled-source integration. Its
results and hosted receipts remain valid historical evidence for their exact
source, but CORE-05, CORE-06, and G4 are open for the post-maintenance source.
G6 remains held.

The audit additionally revealed that a portable calibration extracted from an
otherwise eligible one-node MML source fit could inherit that grid. Draft
extraction now defaults to a separate 31-node scoring grid, refuses an order
below 2, and records `quadrature_eap_v1` as a semantic-identity component. The
historical G4 fixture explicitly retains its frozen nine-node design so that
its old numerical statement is not silently rewritten as evidence for the new
default.

## Local evidence completed

- Fitted-object prediction and plausible-value regression suite.
- Fixed-calibration lifecycle, schema, and historical G4 numerical suites.
- Replay round-trip and material-argument registry suite.
- Pure-EM and hybrid checkpoint schema/resume/refusal suite.
- Source build of `mfrmr_0.2.4.9000.tar.gz` followed by
  `R CMD check --no-manual --ignore-vignettes` under arm64 macOS and R 4.6.1:
  `Status: OK`. Network-restricted repository-index messages did not change
  the check result.

These local results establish implementation regression coverage only. They do
not close the reopened independent or cross-platform gates.

## Required current-source reconfirmation

1. Freeze a successor G4 contract before inspecting new confirmation results.
   It must retain the scoring algorithm, the 31-node default, an explicit
   non-authorizing nine-node historical control, a one-node source-fit
   adversary, and all replay, scoring, checkpoint, and operational cells while
   adding both compiled translation units to the production boundary.
2. Bind one clean candidate source identity, then add a disjoint posterior
   oracle and semantic-identity mutations that do not
   call production scoring or identity helpers.
3. Exercise replay and checkpoint behavior from an isolated source-tarball
   install and a fresh R session, including same-dimension objective changes,
   interrupted continuation, completed-state refusal, and hybrid stage reuse.
4. Run ordinary package tests, examples, vignettes, release-readiness, and R
   CMD check against the same built payload.
5. Run hosted macOS release first and then Windows release plus Linux devel,
   release, and oldrel on one unchanged commit. Retain failures; do not pool
   historical cells into the new denominator.
6. Only after those results pass may CORE-05, CORE-06, and G4 close again and
   G6 resume.

## Machine-readable consequence

- `PatchRelease0231Published=TRUE`
- `PatchReleaseCommit=be5611ed9a9390ac6d33997f28e16be041aec56f`
- `FixTarget=development/0.2.4`
- `DevelopmentVersion=0.2.4.9000`
- `PublicPredecessor=0.2.3.1`
- `MaintenanceHotfixIntegrated=TRUE`
- `HistoricalG4Retained=TRUE`
- `HistoricalG4CurrentSourceEvidence=FALSE`
- `PostMaintenanceG4ContractFrozen=FALSE`
- `PostMaintenanceG4CurrentExecutionOpened=FALSE`
- `PostMaintenanceG4CandidateBound=FALSE`
- `CandidateBindingPreflightImplemented=TRUE`
- `CandidateBindingPreflightLiveReady=FALSE`
- `CORE05Complete=FALSE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `G5DispositionUnchanged=TRUE`
- `G6Held=TRUE`
- `PublicAPIAuthorized=FALSE`
