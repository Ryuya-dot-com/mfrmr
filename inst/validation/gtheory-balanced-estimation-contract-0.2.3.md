# Draft.82 balanced univariate G-study estimation contract

Status: repository-only estimator prototype contract, 2026-08-09.

This is the first estimation slice built on the Draft.81 typed design and
component-wise D-study algebra. It is not an exported API and does not alter
the current `mfrm_generalizability()` or `mfrm_d_study()` behavior.

## Supported estimation subset

Draft.82 accepts only a Draft.81 algebra-eligible design with:

- one object and one or two random facets;
- a complete crossing;
- exactly one finite numeric observation in every object-by-facet cell;
- all lower-order random-intercept components;
- one highest-order interaction/residual component labelled `Residual`; and
- no nesting, fixed facet, replicate-error separation, weight, or missing row.

Two estimators consume the same canonical data and typed effect map:

1. `balanced_anova_mom`: orthogonal balanced ANOVA expected-mean-square
   inversion with no nonnegativity constraint; and
2. `lme4_reml` / `lme4_ml`: Gaussian likelihood fits using the exact canonical
   random-intercept formula and lme4's nonnegative variance parameterization.

REML and ML are different estimator identities. Agreement between balanced
MoM and REML on an interior orthogonal fixture is a reduction test, not
permission to pool REML and ML or to select whichever result is preferable.
The frozen raw method identity is
`orthogonal_expected_mean_square_inversion`.

## Mean-square construction

For all nonempty subsets `S` of the object/facet set `F`, Draft.82 reconstructs
the marginal interaction effect and its orthogonal sum of squares. It verifies
that their sum equals the corrected total sum of squares before solving any
variance component.

For a balanced random-effects decomposition:

```text
E[MS_S] = sum over T containing S of
          product(n_f for f in F but not T) * sigma2_T
```

Components are solved from the highest-order term downward. For p x i this
reduces to:

```text
sigma2_pi,e = MS_pi
sigma2_p    = (MS_p - MS_pi) / n_i
sigma2_i    = (MS_i - MS_pi) / n_p
```

For p x r x i, for example:

```text
sigma2_pr = (MS_pr - MS_pri,e) / n_i
sigma2_pi = (MS_pi - MS_pri,e) / n_r
sigma2_ri = (MS_ri - MS_pri,e) / n_p

sigma2_p = (MS_p - n_i sigma2_pr - n_r sigma2_pi
            - sigma2_pri,e) / (n_r n_i)
```

Every mean square, degree of freedom, EMS coefficient, subtracted
contribution, and solved target is retained. This makes the estimator auditable
without treating an `aov()`/`lm()` print table as the semantic component map.

## Negative and boundary contract

Balanced MoM estimates are raw moment solutions:

- negative values remain `negative_raw`;
- exact numerical zeros remain `exact_zero_raw`; and
- no truncation, redistribution, or post hoc correction is performed.

lme4 variance estimates use a constrained nonnegative parameterization:

- an estimate at the tolerance is `constrained_zero_boundary`;
- `isSingular()`, optimizer code, lme4 messages, maximum gradient when
  available, and minimum Hessian eigenvalue when available remain visible; and
- a constrained zero is never described as a raw negative estimate or a
  correction to the MoM estimator.

The MoM solution maximizes no likelihood. The lme4 REML result optimizes the
restricted-likelihood criterion under its variance constraints; ML optimizes
the ordinary likelihood criterion. Neither is relabelled as an unconstrained
solution it did not optimize.

Intervals are absent. `EstimationReady` means only that a component point table
was produced under this narrow design. `InferenceReady` and `DecisionReady`
remain false. A D-study may be algebra-ready while still being inferentially
and operationally ineligible. The estimator-to-D-study bundle retains the
original algebra hash, source-estimation hash, and a new hash covering their
combined identity; appending provenance never leaves a stale result hash.

## Current-surface compatibility identity

`main_effects_collapsed_residual_v1` is a separate lme4 decomposition using
only object and facet main effects. It is required to reproduce the component
table of the current public `mfrm_generalizability()` helper on the same rows,
formula, REML/ML choice, and lme4 version.

It does not inherit the typed interaction-specific D-study algebra. Its
Residual still collapses every omitted interaction and remains governed by the
existing `highest_order`, `single_condition`, `none`, and `sensitivity`
projection contract. A model-identity label, not numerical similarity, decides
which D-study transformation is legal.

## Frozen fixtures and non-claims

The interior p x i and p x r x i fixtures are constructed from orthogonal pure
effects whose expected-mean-square inversion yields the Draft.81 component
vectors exactly. A separate p x i fixture forces a negative raw Item component
while the matched lme4 fit reaches a zero/singular boundary.

These are algebra and estimator-reduction fixtures, not Monte Carlo recovery.
Draft.82 freezes no sampling-bias rule, RMSE tolerance, coverage rule, minimum
sample size, preferred estimator, handling of genuine negative components,
interval method, or public formula subset. Draft.83 remains responsible for
nesting, partial crossing, imbalance, missingness, allocation operators, and
component-specific rank/replication audits.
