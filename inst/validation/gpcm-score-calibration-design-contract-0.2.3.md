# mfrmr 0.2.3 bounded GPCM score-calibration design contract

Status: repository-only design freeze, 2026-08-11. No calibration dataset is
generated, no fit is run, and no confirmation or release action is authorized.

The current machine contract is
`mfrmr_gpcm_score_calibration_design_v2`. Before the eight-cell calibration was
opened, a single Criterion/core runner preflight showed that the v1
expanded-log-Jacobian cap `1e-10` was below the already documented
central-difference roundoff (`1.40e-10`) at coupled/stress points. V2 changes
only that cap to `5e-10`; the fixtures, score rules, points, other Jacobian
caps, and all authorization boundaries are unchanged. The preflight is not one
of the 128 calibration evidence rows.

## Why this design exists

The unit-slope reduction and the four-point non-unit oracle remove important
formula and transformation ambiguities, but they do not yet span both aligned
GPCM slope/step owners, five categories, or difficult linked assignments. The
existing 120-row owner recovery pilot already studies broader empirical
behavior. Repeating or enlarging it would be an inefficient way to answer the
narrower implementation question.

This contract therefore uses only eight calibration cells: Criterion and
Rater ownership crossed with core, one-Person weak bridge, workload imbalance,
and category imbalance. Each owner pair uses the same nonstochastic fixture:
40 Persons, four Raters, four Criteria, and five categories with positive
support in every Rater and Criterion ladder. The scores are deterministic
cyclic patterns rather than model-generated observations because no recovery
claim is being estimated. All fits use direct MML, q=31, and aligned
`slope_facet == step_facet`. q=31 fixes the objective being differentiated; it
is not evidence that q=31 is adequate for substantive integration.

## Evaluation grid

Each cell is evaluated at four points:

1. the retained direct-MML vector;
2. a coupled deterministic probe perturbing every free coordinate and setting
   expanded slopes on a geometric sequence from about 0.45 to 2.20;
3. a forward finite slope stress with expanded log slopes from -3 to 3; and
4. the reverse finite slope stress.

Every point must report owner-additive, other-additive, step, and free-log-
slope coordinate classes separately. The complete evidence unit is therefore
8 x 4 x 4 = 128 scenario/point/class rows. Missing coordinates, a missing
class, a failed fit, a non-finite objective, or an incomplete derivative
ladder is a rejection, not numerical zero.

Local dependence, missingness mechanism, DFF, fit indices, interval coverage,
and recovery are intentionally absent. They are different statistical claims
and already have separate gates. Adding them here would confound an
implementation score check with an operating-characteristic study.

## Independent derivative and margin rule

The reference objective remains the independently expanded non-unit slope
map, GPCM softmax kernel, and Person-wise fixed-quadrature marginal objective.
The derivative changes from a three-point to a coordinate-scaled five-point
central stencil. Relative steps are `1e-3`, `3e-4` (primary), and `1e-4`.
The pre-existing four-point fixture showed the expected fourth-order
truncation/roundoff pattern before this broader grid is run.

For each coordinate, scale is

`max(1, abs(analytic score), abs(primary reference score))`.

The adaptive allowance is

`1e-8 + 1e-9 * scale + 10 * reference spread + 10 * roundoff bound`,

where reference spread is the range over the three five-point scores and the
roundoff bound is

`32 * machine epsilon * max(1, max absolute objective evaluation) /
minimum absolute coordinate step`.

A coordinate must meet all three conditions: absolute difference below its
hard cap, scaled difference below its hard cap, and absolute difference no
larger than the adaptive allowance. Hard caps are `2e-6` absolute and `2e-7`
scaled for both additive classes and steps; the log-slope caps are `1e-6` and
`1e-7`. These are frozen calibration-evaluation guards, not the final general
`NUM-SCORE-TOL`.

For the log-slope class, the expanded-log Jacobian absolute difference must be
at most `5e-10`, the positive-slope Jacobian difference at most `1e-7`
absolute and `1e-8` scaled, and the geometric-mean residual at most `1e-12`.
Every scenario, point, class, and coordinate must pass; pooling cannot hide a
failed stratum.

## Decision and authorization boundary

The machine-readable contract and its failure-closed decision function may
report `calibration_rule_pass` only when all 128 evidence rows and every
Jacobian obligation pass. Even that state leaves
`GeneralNUMSCORETOLStatus = pilot_required`, because the final tolerance must
be reviewed after the bounded calibration and then applied unchanged to
disjoint exact-candidate confirmation data.

The design does not authorize its own execution. A later execution record must
bind exact runner, package, fixture, retained-row, and result identities. No
large replication study is justified by this numerical contract; if one of
the eight cells fails, the next action is mathematical/numerical attribution,
not automatic expansion of the grid.
