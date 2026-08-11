# mfrmr 0.2.3 GPCM score v4 confirmation design

Status: structurally disjoint deterministic fixtures sealed without fitting;
execution remains unauthorized, 2026-08-11. No confirmation result is open.

The design source SHA-256 is
`31b495b46aef7706835030efe3b41d2888242a4a8f7724ead435c2c7648fb11a`.
It binds bounded-v4 freeze source SHA-256
`3baab8bfabf5b05600a2a12057cfcb6b79c7c3c665824675afb6cafa9c56744b`
and the unchanged package payload
`ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a`.

Three new deterministic response structures are each crossed with Criterion-
and Rater-owned slope/step parameterizations:

- `braid5`: 41 Persons, 4 Raters, 7 Criteria, 5 categories, adjacent-rater
  braid with all criteria, 574 rows, 50% unobserved complete-cross cells;
- `weave6`: 49 Persons, 6 Raters, 4 Criteria, 6 categories, rotating three-by-
  three rater/criterion weave, 441 rows, 62.5% unobserved cells;
- `fan7`: 53 Persons, 5 Raters, 8 Criteria, 7 categories, common-hub workload
  fan and rotating five-criterion assignment, 525 rows, 75.24% unobserved
  cells and rater maximum/minimum load ratio 4.42.

Every Rater-category and Criterion-category cell has positive support. Both
Person--Rater and Person--Criterion bipartite graphs are connected. Fixture
SHA-256 values are respectively
`7d751e4436ea6be7ae9bad5d1d990b527fb81f5ee5b3335dc9475225a779dbd0`,
`53e53bdc816338008a07459d434c69a1b7acabfa41ef5dd215d2fefd8dcb2a7b`,
and
`50bb1b0c48f7ee9154315d5794d9c44a60f842f6df986e57191cc7c78ddc899f`.

The prior v3 confirmation and v4 completion design sources are hash-bound and
regenerated solely for identity comparison. New versus protected Person,
Rater, Criterion, and fixture-hash overlaps are all zero. Response namespaces,
assignment mechanisms, dimensions, category counts, and response formulas are
new. No v3 or completion result is used to build these responses.

Each of six scenarios fixes the four points `retained_solution`,
`coupled_free_probe`, `finite_slope_stress_forward`, and
`finite_slope_stress_reverse` across owner-additive, other-additive, step, and
log-slope coordinates. The complete future denominator is 96 evidence rows,
888 coordinate rows, 24 point rows, and 688 entrywise Jacobian rows. This is a
small deterministic implementation-mathematics confirmation, not a recovery
simulation.

The decision is
`v4_confirmation_design_sealed_execution_not_authorized`.
`FutureExecutionMustRecordAbsoluteTarget = TRUE` is prospective and closes the
path-form ambiguity observed in calibration without changing the frozen
calibration decision. A dry-run runner, exact six-scenario manifest, separate
same-process authorization, absent absolute target, and issued/consumed row-
hash checks are now implemented. A runner-independent validator is sealed and
bound into authorization. Seventy-four no-fit expectations pass. The default
remains NO-GO pending a deliberate pre-execution review. No fit, result,
general tolerance, boundary, inference, or release promotion is authorized.

This paragraph records the design-stage boundary. The later single authorized
execution and authoritative negative disposition are recorded in
`gpcm-score-v4-confirmation-result-record-0.2.3.md`; the design was not retried.
