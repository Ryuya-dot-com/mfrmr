# Draft.83b component-specific G-theory allocation-operator record

Status: completed repository-only allocation algebra prototype, 2026-08-09.

## Decision

Draft.83b passes its narrow allocation-algebra gate. Planned weights now act on
each typed component through its own marginal condition identities. Balanced
counts reduce exactly to Draft.81, nested Site/Rater levels use conditional
identities, unequal units remain unit-specific, and shared-condition overlap is
separate from object-interaction covariance.

This is not an unbalanced G-study estimator. Supplied component values are
transformed, not estimated. All estimation, inference, and decision-ready
fields remain false, and no checklist row is promoted beyond review.

```text
EstimationReady=FALSE
InferenceReady=FALSE
DecisionReady=FALSE
```

## Environment and execution

- R 4.6.1
- reformulas 0.4.4
- digest 0.6.39
- Draft.81 design contract `gtheory_design_algebra_draft81_v1`
- Draft.83a incidence contract
  `gtheory_design_incidence_audit_draft83a_v1`
- Draft.83b operator contract `gtheory_allocation_operator_draft83b_v1`

The dedicated command was:

```sh
Rscript -e 'testthat::test_file("tests/testthat/test-gtheory-allocation-operator-prototype.R", reporter="summary")'
```

Result: seven tests and 71 expectations passed without failure, warning, skip,
or error.

## Balanced reduction

For the Draft.81 p x i and p x r x i fixtures, two prospective units receive
the same complete uniform allocation. Every component scaling factor equals
the reciprocal of the matching Draft.81 divisor.

For p x r x i at `n_r=2`, `n_i=3`:

| Component class | Scaling factor |
| --- | ---: |
| Rater and Person:Rater | `1/2` |
| Item and Person:Item | `1/3` |
| Rater:Item and collapsed Residual | `1/6` |
| Person universe variance | `1` |

The applied operator exactly reproduces relative error `.30`, absolute error
`13/30`, `G=10/13`, and `Phi=30/43`. Both units use identical supports and
weights, so one homogeneous scenario scalar is algebra-available. Inference
and decision readiness remain false.

Identity hashes:

- allocation:
  `c4b3811a892d968f24afbde103aeeb103c0f1e525ebcf434cc14fb8c5d70280f`
- operator:
  `68904965a13105c34212d8a9745ed4b33d29a7905085c7a58583fe17c18526cf`
- applied result:
  `574410216dfa15b2ddb5c47c738f08236aab91740ca0ca01f430fa2571d4ae23`

## Nested conditional allocation

The nested fixture plans two Sites and three Raters within each Site. Raw Rater
labels R1--R3 are reused, but the operator retains six conditional Site:Rater
levels. It reports six explicit structural support cells and 12 Cartesian
effective combinations; the latter is not used as a denominator.

The scaling factors are Person `1`, Site `1/2`, Site:Rater `1/6`, and collapsed
Residual `1/6`. With components `1, .1, .2, .7`, relative error is `.7/6`,
absolute error is `.7/6 + .1/2 + .2/6 = .2`, `G=.8955224`, and
`Phi=5/6`. The prior Draft.81 issue `nested_scaling_not_supported` is resolved
only for this explicit planned operator; it does not assert estimation support.

Identity hashes:

- operator:
  `5cd7bfa6b6f6562000dc8d05114d1b84fe74535b75f1c8db56459f52631474a0`
- applied result:
  `1ac92f072872f270df23bbee2be88b2f67ad4853f48b1ae912adee32aee5d2bc`

## Unequal unit allocation

Unit U1 weights two Items `.5/.5`; U2 weights the same Items `.8/.2`. The Item
and collapsed-Residual scaling factors are therefore `.50` and `.68`, with
effective counts `2` and `1/.68`. For components Person `1`, Item `.2`, and
Residual `.8`, the unit results are:

| Unit | Relative error | Absolute error | G | Phi |
| --- | ---: | ---: | ---: | ---: |
| U1 | .400 | .500 | .7142857 | .6666667 |
| U2 | .544 | .680 | .6476684 | .5952381 |

Both unit rows are algebra-ready, but the scenario is
`heterogeneous_unit_specific_only`; `ScalarG` and `ScalarPhi` are missing.
They are not averaged.

Identity hashes:

- operator:
  `99d733a5427081d190144fb8d082918562e46e3adb06fe581e08a70219fd96ec`
- applied result:
  `c12f49daf49dce342079279b9ec8eea06d6fec1ae9e3cd434c216157209d6736`

## Sharing control

For the unequal shared-Item allocation, cross-unit Item allocation overlap is
`.5`; because Item does not contain Person, its covariance multiplier is also
`.5`. The collapsed Residual has the same allocation overlap but contains the
object, so its cross-object covariance multiplier is zero.

In the disjoint control, U1 uses I1/I2 and U2 uses J1/J2 with uniform weights.
Both units have the same scaling factors and identical unit G/Phi, but Item
overlap and covariance are zero. The full operators are not identical, so no
scenario scalar is formed merely from numerical equality.

Disjoint identity hashes:

- operator:
  `5a60a605b0551c39a48b22000908ac226bf6271eee5e441bd5e74b8824485ad0`
- applied result:
  `3cf5b846f35017169f022a84919ee5cfa3ce76b45ab2b683d8a4e19cc4b36448`

## Negative and malformed controls

A raw negative component is retained and returns
`raw_negative_component`; no truncation or scenario scalar occurs.

The prototype stops before an operator is formed when weights do not sum to
one, a full cell is duplicated, a weight is zero/nonfinite, cross-unit overlap
would exceed the declared capacity, the operator and component design hashes
differ, or a facet is nested within Person without a superpopulation error-role
contract. These are semantic failures, not optimizer failures.

## Metacognitive boundary and next work

Draft.83b establishes that balanced counts are one special weight operator and
that equal effective counts do not imply equal sharing. It still does not show
that an unbalanced mixed model can recover the supplied components.
The squared-weight identity also assumes independent exchangeable random-
intercept levels; structured covariance needs `a' Sigma a` and remains a later
contract.

Draft.83c must next distinguish at least three questions:

1. whether the random-effect covariance design has local/global information
   for each component;
2. whether lme4/glmmTMB returns an interior, boundary, singular, or failed fit
   on the exact retained rows; and
3. whether the fitted components can legally enter this exact operator.

Only Draft.83d recovery and false-ready calibration can turn those structural
and numerical states into a supported crossed/nested/unbalanced design subset.
