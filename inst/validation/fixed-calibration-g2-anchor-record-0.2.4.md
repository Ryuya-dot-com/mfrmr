# Fixed-calibration G2 typed-anchor record (0.2.4)

Status: complete for the internal one-scale RSM/PCM MML core; public API gate
closed.

## Decision

The strict typed route now treats facet elements, facet groups, shared RSM
steps, and PCM owner-specific steps as separate namespaces. Relative slopes
and population coordinates have reserved names and coordinate systems, but
remain unavailable because OPT-02 and OPT-01 are not promoted.

This work does not alter the existing public `fit_mfrm()` arguments. It adds an
internal constraint path that can be reviewed before a public surface is
chosen. No public 0.2.4 API is authorized by G2.

## Identification rule

Each step ladder has `K-1` expanded transitions and retains an exact
sum-to-zero constraint. If `a` transitions are fixed and `u=(K-1)-a` remain
unanchored, the free dimension is `max(u-1,0)`. The last unanchored transition
in canonical internal score order is derived from the sum constraint. When all
transitions are fixed, their values must sum to zero or construction refuses.

RSM has one shared ladder. PCM has one independent ladder for each level of
the declared step-owning facet. A PCM declaration naming a different facet or
an RSM declaration using an owner-specific namespace refuses before parameter
sizing or optimization.

The same step specification now drives:

- optimizer parameter counts;
- expanded parameter reconstruction;
- analytic gradient projection;
- deterministic initial coordinates;
- the sparse estimability Jacobian; and
- category-support classification of free, derived, and fixed transitions.

This removes the failure mode in which an anchor table and the optimizer use
different free dimensions.

## Conflict and canonicalization rule

Declaration order is provenance, not precedence. Normalization validates exact
selector shapes and the `expanded_logit` coordinate system, then orders by
typed namespace and the model's facet/level/transition dictionaries.

- Identical selector/value declarations deduplicate and emit an
  `ANCHOR_DUPLICATE_DEDUPLICATED` note.
- The same selector with different values refuses with `ANCHOR_CONFLICT`.
- A group member assigned to multiple groups or one group assigned multiple
  means also refuses with `ANCHOR_CONFLICT`.
- Direct anchors and group membership may coexist only when their combined
  fixed/group-mean constraint is feasible.
- Unknown owners, levels, transitions, wrong family ownership, and wrong
  coordinate systems have distinct refusal codes.

Artifact review independently checks canonical order and verifies fixed anchor
values against the stored expanded coordinates. Group declarations must equal
the mean of their stored member coordinates.

## Adversarial evidence

The executable contract is
`inst/validation/fixed-calibration-g2-anchor-contract-0.2.4.R`; regression and
mutation evidence is
`tests/testthat/test-fixed-calibration-g2-anchors.R`.

The fixtures cover:

- exact empty-spec reduction to the predecessor sum-zero parameterization;
- identical canonical output under declaration reversal;
- identical-duplicate notes and different-value conflicts;
- shared and owner-specific partial anchors with exact free dimensions;
- analytic step-gradient projection against central differences;
- full-column-rank sparse step Jacobians;
- all-facet/all-step fixation with exact probability reconstruction;
- objective equality after reparameterizing a fitted RSM point;
- extraction and semantic review of an anchored calibration artifact;
- fully fixed sum/group incompatibility;
- unknown transition, wrong owner, and wrong coordinate system refusal;
- missing/unused-category reporting that does not relabel fixed transitions as
  estimated; and
- reversal of the external score map while keeping transition indices tied to
  canonical internal score order.

The predecessor estimability, category-support, identified-step, G0, G1 schema,
and lifecycle suites are rerun as regression evidence. GPCM remains callable on
its existing unanchored fitted-object path, but typed slope/step operational
calibration is not promoted by this core result.

## Gate disposition

CORE-03 and G2 are complete for the bounded internal RSM/PCM MML lane. G3 has
since closed CORE-04 with a complete operational-scoring policy and
disposition contract. CORE-05 through CORE-08 remain open, and G4 independent
and operational evidence is the next critical gate.

## Verification

- The G2 anchor suite passed 83 assertions with zero failures, warnings, or
  skips.
- The focused G0/G1/G2/release-readiness rerun passed 979 assertions with zero
  failures, warnings, or skips.
- The broad repository suite reached 29,155 passing assertions. Its only two
  failures were the public-roadmap boundary detecting internal evidence terms;
  after those terms were moved back to repository-only records, the complete
  release-readiness context passed in the focused rerun. The broad run's 42
  expected review warnings and 58 declared optional/long-tier skips were not
  counted as G2 evidence.
- A vignette-complete source build passed `R CMD check --no-manual` with
  `Status: OK`. The checked source-tar identity was
  `20bdf41ff1d40e355d0fd0bab99e12a0b4dcf99fd9c4896754d6a14322c3b61c`.
- `git diff --check` passed. The package metadata still identifies 0.2.3 and
  the new functions remain unexported; version/public-surface promotion is a
  later release gate, not a consequence of G2.
