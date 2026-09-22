# Draft.83b component-specific G-theory allocation-operator contract

Status: repository-only D-study allocation algebra contract, 2026-08-09.

Draft.83b follows the Draft.83a observed-incidence audit but remains independent
of model fitting. It defines how an explicitly planned prospective allocation
transforms each typed variance component. It does not infer a future design
from observed medians, harmonic means, or fitted-data workloads, and it does
not change the public `mfrm_generalizability()` or `mfrm_d_study()` helpers.

## Mathematical operator

For prospective object-score unit `u`, let the unique planned condition rows
have positive weights `w_uh` that sum to one. For component `C`, Draft.81's
`ScaleBy` map projects each full condition row `h` to a component condition
identity `g`. Its marginal weight is

```text
a_uCg = sum of w_uh over rows h mapping to component condition g.
```

The component scaling factor is

```text
lambda_uC = sum_g a_uCg^2
```

and its contribution to that unit's score variance is

```text
lambda_uC * sigma2_C.
```

This identity assumes the Draft.81 independent, exchangeable random-intercept
levels for component `C`, with covariance `sigma2_C I`. A structured or
correlated condition covariance requires the more general quadratic form
`a' Sigma_C a`; it cannot reuse the squared-weight operator by name alone.

`1 / lambda_uC` is reported as an effective count. It is a descriptive
concentration identity, not necessarily an integer or the number of observed
levels. For uniform weights over `n` component conditions, `lambda=1/n`.
For crossed uniform Raters and Items, this reduces exactly to:

```text
Rater component       1 / n_r
Item component        1 / n_i
Rater:Item component  1 / (n_r n_i)
```

Thus the balanced-count algebra is a reduction case of the allocation
operator, not a separate approximation.

## Planned allocation input

Every allocation row identifies exactly one:

- scenario;
- prospective object-score unit;
- level of every random facet; and
- strictly positive scoring weight.

Weights must sum to one within every Scenario x Unit. Draft.83b never silently
normalizes them. A Scenario x Unit x full-facet cell may occur only once. A
duplicate could mean repeated observations, an already aggregated cell, or an
input error, and those alternatives imply different residual scaling.
Replicate-error scaling therefore remains unsupported until an explicit
replicate/residual operator exists.

Scenario, unit, factor identities, weights, and row order are canonicalized
into an allocation hash. Reordering rows does not change operator or result
identity.

## Nested support

Nested child levels use the same ancestry-qualified identities as Draft.83a.
For `Site > Rater`, raw `R1` under Site S1 is distinct from raw `R1` under Site
S2. An explicitly planned two-Site, three-Raters-per-Site allocation therefore
has:

```text
lambda_Site       = 1 / 2
lambda_Site:Rater = 1 / 6
```

The allocation rows define the active structural support. Draft.83b reports
the Cartesian effective-level count descriptively but does not use it as a
nested denominator. There is no median conditional-count shortcut.

A facet nested within the object remains blocked. Such a design needs an
explicit superpopulation definition saying whether person-specific conditions
contribute to relative error, absolute error, or another target. Conditional
labels alone cannot supply that estimand.

Fixed facets also remain blocked. Transporting a condition from fixed to
random is a universe-definition change, not an allocation convenience.

## Unequal allocations and scalar coefficients

Draft.83b returns unit-specific scaling factors and, after a component vector
is supplied, unit-specific `G` and `Phi` algebra. It does not average unequal
unit coefficients.

A scenario-level scalar is available only when every unit has the same full
condition support and weights, the unit coefficients agree within the frozen
tolerance, and all raw components pass the algebra guard. Otherwise the state
is `heterogeneous_unit_specific_only`, scenario scalar fields are missing, and
the unit rows remain inspectable.

This deliberately blocks a subtle false reduction: two units may have equal
effective counts and numerically equal coefficients while using disjoint
Raters or Items. Those designs do not have the same cross-unit covariance and
cannot be collapsed merely because their marginal coefficients match.

## Cross-unit sharing and overlap

For two units `u` and `v`, the allocation overlap for component `C` is

```text
omega_uvC = sum_g a_uCg * a_vCg.
```

It is zero for disjoint condition support, equals the diagonal concentration
for identical operators, and otherwise records partial or unequal overlap.
For components that do not contain the object, this is the covariance
multiplier induced by shared condition effects. For object-containing
interactions, distinct prospective objects have independent component levels,
so the covariance multiplier is zero even when their Rater/Item allocations
overlap.

The overlap table is retained for future population/composite covariance work.
Draft.83b does not form a population-average or multivariate coefficient from
it. A capacity ceiling fails explicitly rather than dropping unit pairs.

## Component application

The component point vector is supplied separately and must match the typed
effect map exactly. Per unit:

```text
universe variance = sum contributions with universe_score role
relative error    = sum relative_error and both_errors contributions
absolute error    = relative error + absolute_only contributions

G   = universe / (universe + relative error)
Phi = universe / (universe + absolute error)
```

Raw negative components remain visible and make the algebra non-ready. No
truncation, redistribution, constrained-boundary relabelling, or choice of a
more favorable unit occurs.

An operator can be component-scaling ready before components exist. An applied
result can be algebra-ready while remaining:

```text
EstimationReady = FALSE
InferenceReady  = FALSE
DecisionReady   = FALSE
```

The components in the fixtures are supplied truths/point values, not estimates
from an unbalanced model. Draft.83b therefore supplies no recovery, standard
error, interval, sample-size, or public-support evidence.

## Frozen controls and next gate

The dedicated tests freeze:

- exact p x i and p x r x i reduction to every Draft.81 divisor and
  coefficient;
- a balanced nested Site/Rater operator with reused raw child labels;
- unequal unit weights with noninteger effective counts;
- shared versus disjoint condition support and covariance multipliers;
- equal unit coefficients with disjoint support but no scenario scalar;
- raw negative components;
- row-order and component-order replay; and
- nonnormalized, duplicate, nonpositive, capacity, mismatched-design, and
  object-nested failures.

Draft.83c must bind this operator to retained-row-identical lme4/glmmTMB fits,
covariance-design/information-rank diagnostics, boundary states, and backend
convergence evidence. Draft.83d remains responsible for recovery,
coefficient-denominator identity, and zero-false-ready operating
characteristics across sparse, unequal, nested, and missing designs.
