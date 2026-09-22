# Fixed-calibration G3 operational-scoring record for mfrmr 0.2.4

Status: `G3_complete_internal_public_gate_closed`, 2026-08-22.

- Specification: `0.2.4-fixed-calibration-g3-operational-scoring-v1`
- Contract: `mfrmr_operational_scoring_v1`
- Production implementation: `R/core-fixed-calibration.R`
- CORE-04 complete: `TRUE`
- Public constructor/scorer export authorized: `FALSE`
- Optional lane promotion authorized: `FALSE`
- Next gate: `G4-independent-and-operational-evidence`

## Bounded result

The internal one-scale RSM/PCM MML fixed-calibration lane now has a complete
pure-scoring policy. A frozen artifact can score new Persons without a source
fit, training data, optimizer, regenerated parameter vector, inferred facet
effect, substituted prior, RNG, or ambient option. The result binds numerical
scores to calibration, schema, package, response-map, prior, quadrature, and
source-readiness identities and returns both row and Person dispositions.

This closes G3 and CORE-04 for the internal core lane only. It does not export
the calibration lifecycle, promote bounded GPCM, estimated-population MML, or
JML, close the broader G4 independence/reproducibility matrix, or authorize a
0.2.4 release candidate.

## Input and omission policy

The default remains fail-closed. Missing/nonfinite response values, unknown
scores, unknown facet levels, missing Person/facet/event labels, invalid
weights on scored rows, ambiguous column mappings, and unidentified repeated
Person-by-facet cells stop the batch under stable codes.

Missing responses may be omitted only with `missing_response = "omit"`. Every
such input row is returned as `omitted` with
`RESPONSE_MISSING_OMITTED`, and a still-scored Person receives
`RESPONSES_MISSING_OMITTED`; no other invalid row is silently converted into a
missing response. If no valid response remains for a Person, that Person is
returned as `not_scored` with `ZERO_VALID_RESPONSES` and is absent from the
estimate table. A batch containing both scored and zero-valid Persons retains
both Person dispositions.

The scorer does not require a complete crossing, so a positive subset of
known fixed events is scoreable. Because the artifact contains no planned
administration schedule, completeness is explicitly
`not_evaluated_no_plan`; a short batch is not silently described as a complete
administration.

Repeated Person-by-facet cells remain errors unless the caller supplies an
explicit event-ID column. Distinct nonblank event IDs identify intentional
repeated observations; repeating the same Person-by-facet-by-event identity
still fails with `SCORING_EVENT_DUPLICATE`. Weighting alone does not silently
authorize duplicates.

## Person disposition and uncertainty boundary

Every scored Person receives one of `scored` or `scored_review`. The fixed v1
review reasons are:

- `ALL_RESPONSES_LOWER_ENDPOINT` or `ALL_RESPONSES_UPPER_ENDPOINT`;
- `VERY_SPARSE_RESPONSE_PATTERN` when exactly one valid response remains; and
- `QUADRATURE_EDGE_MASS_REVIEW` when combined posterior mass on the two outer
  stored nodes is at least `0.05`.

The 0.05 edge-mass value is an operational review trigger frozen in the v1
scoring contract, not a statistical-validity, sample-size, or universal
adequacy threshold. Endpoint patterns retain finite posterior EAP summaries
under the artifact's explicit proper N(0,1) basis, but the output and notes
state that these are not finite JML maxima. `EstimateBasis` is
`posterior_eap_fixed_calibration`; `UncertaintyBasis` is
`conditional_on_frozen_point_calibration`. Posterior SD and intervals exclude
calibration-parameter uncertainty.

Prior sensitivity is returned as `not_evaluated_fixed_basis`. The production
score does not alter the frozen prior to manufacture a sensitivity result.
Prior-sensitivity adversarial evidence remains part of G4; a future validated
alternative basis must be a separately identified route or derived artifact.

## Evidence

The implementation suite covers RSM and PCM fit-to-artifact numerical parity,
weighted responses, a complete interaction matrix, score-map recoding,
row/chunk order, RNG and ambient-option invariance, immutable inputs, and the
existing structured refusal set. A direct one-row RSM oracle independently
enumerates category logits at every stored node, forms the posterior, and
reconstructs EAP, posterior SD, and grid interval without calling production
probability, expansion, or fitted-object scoring helpers.

The added G3 fixtures cover:

- default missing-response refusal and explicit omission;
- mixed scored/omitted rows and zero-valid Person suppression;
- unidentified repeats, distinct event IDs, and repeated event-ID refusal;
- lower- and upper-endpoint EAP provenance;
- one-response sparse review and bounded quadrature-edge mass;
- calibration/schema/score-map/prior/quadrature/readiness identities; and
- conditional uncertainty and non-JML wording.

After the implementation and record update,
`test-fixed-calibration-lifecycle.R` passed 192 expectations in 23 tests, and
`test-fixed-calibration-g3-scoring.R` passed 33 expectations in 5 tests, each
with zero failures, warnings, or skips. The complete repository test suite also
finished with exit status zero. Its 58 skips are explicitly gated long-running,
external-dependency, unavailable-replay, or frozen-earlier-identification
checks; its 42 warnings are existing category-support, review-readiness, and
information-criterion warnings outside the G3 scorer. They are not counted as
G3 evidence. A source-tarball `R CMD check --no-manual --ignore-vignettes`
also completed with `Status: OK` under R 4.6.1 on arm64 macOS; the temporary
check used the still-unbumped 0.2.3 `DESCRIPTION`, so this is an integration
check of the current development payload, not the future G6 release check or a
cross-platform G4 pass. G4 must add disjoint confirmation fixtures,
mutation/metamorphic breadth, fresh-session/order/locale/encoding/platform/R-
version matrices, and frozen resource budgets before CORE-05 or CORE-06 can
close.

## Decision

- `CORE04Complete=TRUE`
- `G3ExitComplete=TRUE`
- `PublicAPIAuthorized=FALSE`
- `OptionalLaneAuthorized=FALSE`
- `NextGate=G4-independent-and-operational-evidence`

The next authorized work is G4. Bounded GPCM remains reserved for OPT-02 at
G5 and inherits no pass from this RSM/PCM core result.
