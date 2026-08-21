# Fixed-calibration G1 schema boundary for mfrmr 0.2.4

Specification status: complete, 2026-08-22. Current G1 implementation status
is recorded separately in `fixed-calibration-g1-lifecycle-record-0.2.4.md`.

- Specification: `0.2.4-fixed-calibration-g1-schema-lifecycle-refusal-v1`
- Schema ID: `mfrmr.fixed_calibration`
- Schema version: `1`
- Constructor export authorized: `FALSE`
- Public API authorized: `FALSE`
- CORE-01 complete: `TRUE`
- CORE-02 complete: `TRUE`

## Bounded core

Schema version 1 describes only the minimum 0.2.4 lane: one observed scale,
one latent dimension, RSM or PCM, MML, and an explicit fixed-standard-normal
scoring basis. It contains no dormant `ScaleId`, GPCM slope route, estimated
population model, latent-regression coding, or JML post-hoc prior. Those remain
separate OPT or 0.2.5 questions.

This specification document closes the first G1 planning child. The separate
lifecycle record now supplies construction, save/load, terminal-lineage, and
artifact-only scoring evidence. G1 is complete internally, but neither record
authorizes an exported constructor or a public support claim.

## Semantic structure

The artifact has explicit schema, model, response, expanded-parameter,
constraint, scoring-basis, eligibility, validation, lifecycle, provenance, and
integrity sections. Required semantics have no inference fallback. In
particular, facet signs, score maps, prior identity, quadrature rule, nodes,
weights, and readiness identity are stored rather than regenerated from
familiar names or missing fields.

Parameter coordinates are expanded, named, typed, and canonically ordered.
The raw optimizer vector and training-person design matrix are prohibited.
Direct, group, shared-step, and owned-step anchors have separate typed
selectors. Declaration order is provenance only and can never resolve a
conflict.

## Lifecycle

The registered states are `draft`, `validated`, `frozen`, `superseded`, and
`retired`. Every operation returns a new record or an unchanged read-only
result; it does not mutate its input. Validation is the only route from draft
to validated, freezing is the only route from validated to frozen, and only a
frozen artifact may score. Save/load preserve state and must revalidate on
load. Supersession and retirement create new lifecycle records while the prior
artifact remains historically intact.

## Refusal boundary

The frozen taxonomy contains stable error codes for schema/version/type,
lifecycle, identity, model, response map, coordinates, anchors,
identification, scoring prior, quadrature, source eligibility, prohibited
state, persistence, provenance, and operational scoring inputs. A refusal
identifies its field path and bounded detail and leaves its input unchanged.

Optional hashes remain provenance alarms. Semantic identity is direct typed
equality over the canonical model, response, parameter, constraint, prior,
quadrature, and lane components; a matching hash never overrides a semantic
failure.

## Adversarial exclusions

The artifact prohibits the source fit, raw optimizer vector, training rows,
training design matrix, Person identifiers, source Person coordinates or
estimates, optimizer trace, diagnostic bulk, closures/environments, external
pointers, RNG state, ambient options, and absolute source paths. This is both
a portability boundary and a privacy-minimization boundary.

## Artifact-only scoring contract

Only a frozen artifact may score. Inputs are rejected as a whole rather than
silently dropping invalid rows: column mappings must be exact and distinct;
Person/facet labels must be present; scores must match the frozen score map;
weights must be finite and positive; non-Person levels must be known; and
Person-by-all-facets events must be unique. The scorer reconstructs expanded
facet, shared/owned-step, and interaction coordinates directly and evaluates
the cumulative-logit likelihood against the stored standard-normal
quadrature. It does not call the fitted-object scorer or its index/parameter
reconstruction helpers.

## Subsequent bounded action

G2 typed-anchor and identification closure has since completed internally;
its separate record controls that claim. Do not export the constructor/scorer
or promote optional lanes merely because G1 and G2 passed.

## Verification

The repository schema-contract test passed 61 assertions. The test checks
field ownership and omission policy, expanded-coordinate and typed-anchor
shapes, immutable lifecycle transitions, the artifact-only scoring boundary,
refusal-code coverage, direct semantic identity, prohibited state, roadmap
status, and absence of fitting, scoring, persistence, or process-launch calls
in the specification.
