# ConQuest successor semantic registry record for mfrmr 0.2.3

Status: P1 semantic signatures, claim dispositions, complete denominators, and
negative controls defined; disjoint P2/P3 fixture identities and independent
A/C coefficient maps plus metric-specific rules bound by downstream overlays;
independent review pending, 2026-08-15.

This is a prospective, repository-only record. No successor candidate output
exists, and no comparison or scientific-equivalence claim is authorized. The
separate P2 and P3 overlays now freeze their stratum-specific metric rules but
retain every review and execution gate.

- Specification: `0.2.3-conquest-successor-semantic-registry-v1`
- Contract: `mfrmr_conquest_successor_semantic_registry_v1`

## Decision

The successor portfolio contains exactly 23 rows:

| Role | Rows | Permitted interpretation |
| --- | ---: | --- |
| Prospective numerical comparison | 14 | Eligible only after fixture, C0--C2, matrix, precision, and metric-rule gates pass |
| Negative control | 6 | Must be rejected or typed before numerical aggregation |
| Documented non-overlap/unsupported | 3 | No numerical comparison or evidence transfer is permitted |

The fourteen prospective rows contain eleven additive RSM/PCM cases and three
item-only PCM/GPCM cases. The P2 additive denominator contains its eleven
prospective cases plus five additive negative controls. The status-zero runtime
failure remains in the separate P0 runtime-control denominator. The P3
item-only denominator contains three prospective rows, and the non-overlap
denominator contains three rows. No observed or failed row may disappear from
its declared denominator.

## Canonical statistical axes

Every registry row exposes a 36-field human-readable signature. The signature
includes category support, Person/row/weight semantics, active facets, signs,
constraints, step and slope ownership/action, latent dimension, population
formula and variance convention, Person inclusion, integration target and node
ladder, free dimension and derivation, matrix requirement, optimizer controls,
boundary convention, raw-token policy, eligible decisions, named output schema,
accepted termination evidence, all allowed failure outcomes, denominator, and
claim ceiling.

The comparison-candidate dimensions are independently reconstructed:

| Stratum | Fixed structure | Free-dimension derivation | Dimension |
| --- | --- | --- | ---: |
| Additive RSM MML | 4 Raters, 3 Criteria, categories `0:3`, `~1+X` | population 3 + Rater 3 + Criterion 2 + shared steps 2 | 10 |
| Additive PCM MML | same | population 3 + Rater 3 + Criterion 2 + Criterion steps 6 | 14 |
| Item-only unit-slope PCM MML | 4 Items, categories `0:3`, `~1` | population 2 + item locations 3 + item steps 8 | 13 |
| Item-only free-slope GPCM MML | same, `~1` | population 2 + item locations 3 + log slopes 3 + item steps 8 | 16 |
| Item-only free-slope GPCM MML | same, `~1+X` | population 3 + item locations 3 + log slopes 3 + item steps 8 | 17 |

The additive q ladder is `31;61`. The disjoint item-only PCM/GPCM ladder is
`31;61;121`, so a finite-grid concern cannot be converted into a solver claim
by selecting only one node count. These declarations do not yet contain
metric-specific numerical tolerances.

## Negative controls

All six controls have expected disposition
`reject_before_numeric_comparison`:

1. globally unused intermediate category under declared `0:3` support;
2. disconnected Rater/Criterion assignment;
3. deliberately mismatched category maps;
4. deliberately mismatched free dimensions;
5. one missing required native output; and
6. status zero with a registered semantic failure.

Mutation tests prove that removing the category-map, free-dimension, or output
mismatch invalidates the registry itself. The status-zero control inherits the
separate P0 semantic failure contract; its presence here does not close P0's
pending independent review.

## GPCM separation

Only the two one-dimensional item-only GPCM MML rows use `SlopeOwner=Item`,
`StepOwner=Item`, and the exact complete-predictor slope action. A unit-slope
item-only PCM reduction is a separate row. The following remain permanent
non-numerical rows unless a new prospective registry proves otherwise:

- multifacet ConQuest generalized-item scores versus mfrmr single-facet owner
  slopes;
- ConQuest JML with `scoresfree`, which is unsupported in the observed product
  contract; and
- more than one latent dimension.

Thus a GPCM label, a C-matrix label, or an externally finite estimate cannot
transfer item-only evidence to a multifacet slope-owner claim.

## Open gates

P1 is not complete. Before any successor external output is authorized, the
following remain mandatory:

- independently review the bound P2/P3 fixture identities, response schemas,
  exact observed-support A/C coefficient maps, and free dimensions;
- independently review both metric overlays' raw-token, parameter-class,
  complete-denominator, stop, and dependency-invalidation rules; and
- obtain the P0 and P1 independent reviews.

The standalone base-registry implementation therefore continues to return
`semantic_registry_ready_fixture_matrices_and_numeric_rules_pending`, with
`P1_ready=FALSE`, `ExternalExecutionAuthorized=FALSE`, and
`ScientificEquivalenceInferred=FALSE`. Downstream construction overlays do not
mutate those base-registry gate fields; they supply review evidence that a
future independent P1 adjudication must inspect.

## Artifacts

- `conquest-successor-semantic-registry-0.2.3.R` creates and validates the
  23-row registry, independently derives applicable free dimensions, and emits
  a reviewable signature for every row.
- `test-conquest-successor-semantic-registry.R` checks the partition,
  dimensions, mutation-resistant negative controls, GPCM non-transfer, and
  absence of execution or a machine-specific ConQuest path.
- The P2 additive and P3 item-only fixture records bind their disjoint data,
  observed-support coefficient maps, free dimensions, and independent oracles
  without changing this registry's execution state.
- The P2 boundary and P3 metric-precision records bind stratum-specific metric,
  denominator, and stop rules without transferring evidence across strata.
- This record states the current evidence and the gates that remain open.

Hashes are not acceptance criteria for this registry. Future changes are
reviewed by semantic field and dependency; candidate output cannot be used to
rewrite the rule that judges it.
