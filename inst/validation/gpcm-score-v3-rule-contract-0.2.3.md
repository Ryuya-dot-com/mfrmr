# mfrmr 0.2.3 GPCM score-rule v3 contract

Status: post-v2 no-execution rule specification, 2026-08-11. V2 remains a
negative calibration. This contract opens no retrospective evaluation or
confirmation data and freezes no final `NUM-SCORE-TOL`.

## Separation introduced by v3

The v2 five-point objective derivative was informative at ordinary and
prespecified stress slopes but lost locality at retained slopes around
`1e5`--`1e6`. V3 therefore stops asking one finite-difference rule to answer
two different questions.

For expanded sum-zero log slopes `z`, the finite-slope validation region is

`max(abs(z)) <= 3`.

This is the inclusive region already exercised by the pre-v2 forward/reverse
stress points, corresponding to positive slopes approximately
`exp(-3)`--`exp(3)`. It is a validation envelope, not an optimizer box and not
a claim that values outside it are mathematically infinite.

- Inside the region, every coordinate requires independent analytic-score
  agreement plus an independent five-point objective derivative under one
  combined absolute-plus-relative/numerical-error allowance.
- Outside the region, every coordinate still requires independent analytic-
  score and transformation agreement, but objective finite differences are
  `not_applicable_extreme_slope`. The point must enter a non-promoting review
  handoff and the source fit must not be inference-ready.

The handoff does not prove a boundary, a recession direction, or nonexistence
of a finite maximum. Those remain estimator-specific boundary-audit questions.

## Combined rules

Every rule has the form

`difference <= absolute_floor + relative_rate * scale +
spread_multiplier * reference_spread +
roundoff_multiplier * roundoff_bound`.

| Rule | Absolute floor | Relative rate | Spread / roundoff multiplier | Status |
| --- | ---: | ---: | ---: | --- |
| independent analytic score | 1e-8 | 1e-10 | 0 / 0 | fixed from the separate attribution contract |
| finite-slope five-point score | 1e-7 | 5e-7 | 10 / 10 | retrospective calibration candidate |
| expanded-log Jacobian | 5e-10 | 1e-9 | 0 / 0 | retrospective calibration candidate |
| positive-slope Jacobian | 1e-9 | 1e-9 | 0 / 0 | retrospective calibration candidate |

Unlike v2, absolute and relative information are components of one allowance;
they are not separate conditions that must both pass. The candidate values are
explicitly informed by the negative v2 calibration and cannot be called
prespecified confirmation thresholds.

## Complete decision unit

The same eight scenario identities, four point identities, and four parameter
classes define 128 mandatory rows. All structural-oracle, analytic-score, and
combined-Jacobian checks are required. Coupled and forward/reverse stress
points must remain in the finite-slope region. A retained point may be finite
or may enter the extreme review handoff, but it cannot be missing or
`not_evaluable`.

The fail-closed decision rejects:

- missing, duplicated, or non-finite evidence;
- a constructed point outside the declared finite region;
- skipped finite differences inside the finite region;
- finite-difference values attached to an extreme handoff as if they proved
  stationarity;
- an extreme handoff whose source fit is inference-ready;
- any failed structural, analytic-score, or combined-Jacobian check; and
- any calibration or confirmation authorization flag.

## Next evidence boundary

The v3 contract must first be applied retrospectively to v2 only as rule
calibration and sensitivity analysis. If retained, it is then frozen with its
source identities. Independent confirmation must use disjoint deterministic
fixtures or exact-candidate data; neither v2 nor its post-result attribution
can supply that confirmation.

The retained artifacts are not sufficient for exact arithmetic
re-adjudication. V2 preserves all 128 structural/finite-difference strata, but
the independent analytic attribution covers only the 48 strata from the three
failed-surface scenarios. Its 32 point-level Jacobian summaries also contain
separate maxima, not the entrywise scales needed to reconstruct the v3
combined ratios. A bounded identity-bound replay of the same eight
deterministic cells must therefore record all 128 analytic strata and the
entrywise Jacobian comparisons. Inferring a combined-rule pass from separate
maxima is forbidden.

Passing v3 would establish a bounded numerical score contract, not GPCM
recovery, interval validity, finite extreme-slope estimates, DFF performance,
fit-index calibration, sparse-design adequacy, or general MFRM equivalence.
