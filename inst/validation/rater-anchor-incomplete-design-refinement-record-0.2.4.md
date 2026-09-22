# McEwen-informed Rater-anchor design refinement for 0.2.4

Status: **literature audit complete; successor execution closed**

Specification: `0.2.4-draft.1`

Contract: `mfrmr_rater_anchor_incomplete_design_refinement_v1`

## Source

McEwen, Mary R. (2018). *The Effects of Incomplete Rating Designs on Results
from Many-Facets-Rasch Model Analyses*. Doctoral dissertation, Brigham Young
University, All Theses and Dissertations 6689.
<https://scholarsarchive.byu.edu/etd/6689>

The source was retrieved from the local Zotero library as item `5VIBC8I2`, PDF
attachment `FQ3CGTFU`, and BibTeX key
`mcewenEffectsIncompleteRating`. Zotero currently classifies the item as a
journal article without a year; the title page and repository record identify
it as a 2018 doctoral dissertation, which is the bibliographic form used here.

## What the study contributes

McEwen extracted 20 incomplete-design subsets from an existing fully crossed
data set of 24 essays rated by eight Raters. Four fixed Rater assignments were
applied to every incomplete design, producing 80 incomplete-design analyses.
The four equivalent fully crossed reference analyses bring the reported total
to 84.

The 20 incomplete designs comprise 16 coverage-balanced designs and four
coverage-unbalanced designs. The balanced designs span:

- 25%, 50%, and 75% Rater coverage;
- repetition sizes 4, 6, and 8; and
- Ring, Kite, Box, Trapezoids, Hexagon, Unique, and Fully-linked structures.

The four coverage-unbalanced designs are StringOfPearls, AllforOne,
OneforAll, and Wind6x8x.5. They isolate a critical-link loss, a common-Rater
bridge, a common-object bridge, and a two-constant-Rater bridge respectively.

The study's main findings are evidence for design requirements, not universal
operational thresholds:

1. Rater coverage had the largest and most consistent effect. Sparser designs
   had wider dispersion and lower precision.
2. Connectedness was necessary but not sufficient. Designs with the same
   coverage differed according to link distribution and redundancy.
3. Specific Rater assignment mattered more as designs became sparse.
4. Removing one critical link from an already sparse Ring design to form the
   StringOfPearls design materially degraded results.
5. Fully-linked structure was not uniformly superior to carefully distributed
   incomplete links in this one data set.
6. Relative-standing measures were less stable than recovery or correlation
   summaries alone suggested.
7. Rater-centric and object-centric network graphs exposed different weak
   points and should both be audited.

These findings are bounded by a single, small real-data set, eight Raters, 24
essays, one rating scale, selected design structures, and four Rater orders.
They motivate contrasts and diagnostics; they do not establish a generally
optimal coverage, repetition size, topology, or anchor percentage.

## Scenario accounting remains layered

The literature audit does not add unlike denominators together:

| Layer | Current count | Meaning |
|---|---:|---|
| Typed fixed-calibration scenarios | 9 | deterministic anchor-contract semantics |
| Prospective direct-Rater-anchor configurations | 8 | anchor rate, composition, and value-error arms |
| Frozen prospective assignment networks | 7 | complete and sparse network conditions |
| McEwen source catalog | 20 | incomplete rating designs in the dissertation |
| McEwen Rater orders | 4 | paired assignments applied to every source design |

Thus the answer to “how many anchor scenarios exist?” remains **nine** for the
0.2.4 typed anchor contract. The McEwen catalog is a separate empirical design
layer: 20 incomplete designs by four Rater orders, not 80 additional anchor
semantics.

## Gap audit against the frozen 0.2.3 prospective contract

The existing seven-network contract already does four things well: it keeps
direct Rater anchors separate from common linking Persons, preserves a fully
crossed reference, varies link-Person composition, and records rating-resource
cost separately from anchor count.

The source-to-contract audit records ten requirements:

- one is supported: direct-anchor versus rating-link separation;
- three are partial: asymmetric bridge direction, relative-decision outcomes,
  and fully-crossed/reference comparison; and
- six are missing: a coverage ladder, equal-cost topology contrasts,
  repetition-size contrasts, paired Rater orders, a critical-link-loss pair,
  and dual graph projections.

Eight successor contrast families are therefore registered without creating
an execution manifest:

1. 25%/50%/75%/fully-crossed coverage ladder;
2. equal-cost Kite/Box/Hexagon/Fully-linked topology comparison;
3. repetition-size 4/6/8 comparison with coverage, structure, and order held;
4. four paired Rater-order profiles;
5. Ring versus predeclared critical-edge-loss comparison;
6. common-object versus common-Rater bridge direction;
7. constant-Rater bridge versus an equal-coverage distributed-link design;
8. dual-projection structural audit tied to rank, top-n, and cut-score use.

The metric registry adds explicit assignment-resource totals, Rater- and
object-graph connectivity, missing-pair and link-width summaries, articulation
points, parameter recovery, rank agreement, matched rank, top-n classification,
cut-score classification, fully-crossed-reference deviation, and observed
versus adjusted differences. A fit that returns but lacks a required metric
cannot silently disappear from a later denominator.

## Decision

The frozen 0.2.3 contract remains unchanged: eight anchor configurations,
seven assignment networks, and 560 prospective feasibility fits. This audit
does not adopt the 20 source designs as a successor manifest, authorize a fit,
select an anchor percentage, change a public API, or change GPCM scope.

Any successor simulation must first turn the eight contrast families into a
new prospectively frozen manifest with exact assignment matrices, graph
invariants, paired response identities, failure denominators, and
metric-specific precision rules. McEwen's 20-design catalog is evidence for
that design process, not a result to copy uncritically.

`Frozen0_2_3ContractMutated = FALSE`

`SourceDesignsAdoptedAsSuccessorManifest = FALSE`

`SimulationExecuted = FALSE`

`SuccessorExecutionAuthorized = FALSE`

`AppropriateAnchorRateSelected = FALSE`

`PublicApiChanged = FALSE`
