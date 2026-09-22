# Draft.81 typed G-theory parser and algebra contract

Status: repository-only prototype contract, 2026-08-09.

This contract implements the first executable slice of
`gtheory-reconstruction-roadmap-0.2.3.md`. It performs no G-study fit, changes
no exported function, and does not promote a 0.2.3 support claim. The current
`mfrm_generalizability()` / `mfrm_d_study()` surface remains the separately
identified `main_effects_collapsed_residual_v1` compatibility path.

## What Draft.81 does

`gtheory-design-algebra-prototype-0.2.3.R` provides repository-internal
functions that:

1. parse two-sided, intercept-only, random-intercept mixed-model formulas;
2. retain the original `/` nesting syntax separately from backend expansion;
3. canonicalize grouping members in declared object/facet order;
4. construct a typed effect map with `UniverseRole`, `ScaleBy`, nesting,
   replication, component-form, and estimability fields;
5. remove nonsemantic input ordering and row-name differences, then hash the
   canonical design and every algebra result;
6. calculate component-wise balanced-count D-study contributions; and
7. retain raw negative component estimates while denying decision-ready
   status.

`reformulas::findbars()` / `nobars()` are used when available, with the local
`lme4` implementation as a compatibility fallback. The original syntax tree
is still inspected because `findbars()` expands `(1 | Site/Rater)` to Site and
Site-by-Rater terms and therefore cannot by itself preserve whether nesting was
declared.

## Executable supported subset

Positive coefficient calculation is limited to a Gaussian observed-score
design declaration satisfying every condition below:

- exactly one object of measurement;
- one or two random facets and no fixed facet;
- complete crossing;
- intercept-only fixed and random parts;
- every lower-order component in the saturated decomposition;
- no separately fitted highest-order object-by-all-facets component;
- a single `Residual` explicitly declared to collapse that highest-order
  interaction with within-cell residual error;
- `residual_scale_by` equal to every random facet exactly once; and
- `residual_role = "both_errors"`, because the collapsed component enters both
  relative and absolute error; and
- a `balanced_counts` grid with positive integer `n_<Facet>` columns.

Thus the supported p x i formula contains p and i, while the supported
p x r x i formula contains p, r, i, p:r, p:i, and r:i. The component-wise
divisor is the product of only the planned counts named by that component's
`ScaleBy`. Nothing infers a residual divisor from the number of grid columns.

The algebra returns both contribution tables and scenario summaries:

```text
relative error = sum(both/relative components: estimate / ScaleBy divisor)
absolute error = relative error
               + sum(absolute-only components: estimate / ScaleBy divisor)
G               = object / (object + relative error)
Phi             = object / (object + absolute error)
```

No clipping to [0, 1] is applied. If a raw component is negative, the raw
coefficient calculation remains inspectable but `AlgebraStatus` is
`raw_negative_component` and `AlgebraReady` is false. A positive hand fixture
can be `AlgebraReady`, but every Draft.81 row has `DecisionReady=FALSE` and
`DecisionStatus=prototype_no_estimation_or_uncertainty`. Draft.81 does not
implement truncation, reallocation, likelihood constraints, or an estimator.

## Fail-closed cases

The parser may retain a design that is not algebra-eligible so its failure is
auditable. Coefficient calculation stops before producing a table when:

- residual role or scaling semantics are unresolved;
- a formula uses `/` without matching explicit nesting metadata;
- any nesting or fixed-facet D-study operator is requested;
- a required crossed component is absent;
- a term lies outside the declared object/facet set;
- highest-order interaction and residual are both requested without cell
  replication; or
- a replicated saturated design is requested before its replicate-error
  scaling contract exists.

Random slopes, transformed responses, non-intercept fixed terms, duplicate
semantic components, cyclic or contradictory nesting metadata, noninteger
balanced counts, nonnumeric component estimates, and mismatched component
identities are rejected directly. The collapsed residual uses
`ComponentForm=collapsed_highest_order_residual` while retaining the standard
`EstimabilityStatus=identified`; backend boundary/singularity states remain a
later estimator concern.

Nested formulas are deliberately parsed but not scored. `(1 | Site/Rater)`
can be canonicalized only when its `Site > Rater` relation is declared; Draft.83
must still supply conditional counts/allocation operators and an incidence/rank
audit before any nested coefficient is eligible.

## Frozen hand oracles

The p x i fixture uses the frozen components `p = 1`, `i = .2`, and
`p:i,e = .8`. At `n_i = 4`, relative error is `.2`,
absolute error is `.25`, `G = 5/6`, and `Phi = 4/5`.

The p x r x i fixture uses:

```text
p=1, r=.12, i=.18, p:r=.24, p:i=.30, r:i=.08, p:r:i,e=.48
n_r=2, n_i=3
```

Its relative error is `.24/2 + .30/3 + .48/6 = .30`; absolute error adds
`.12/2 + .18/3 + .08/6`, giving `13/30`; therefore `G = 10/13` and
`Phi = 30/43`.

## Non-claims and next gate

Draft.81 is an algebra oracle, not evidence that variance components can be
recovered from data. It does not address imbalance, missingness, partial
crossing, conditional nesting counts, boundary inference, local dependence,
bootstrap intervals, multivariate covariance, or joint GT-IRT/GPCM models.

Draft.82 must add balanced ANOVA/MoM and matched `lme4` REML/ML estimation under
the same semantic component table, reproduce these hand calculations from
fitted components, expose negative-MoM versus constrained-boundary identities,
and verify compatibility with the existing collapsed-residual helper. Until
then the checklist row remains a roadmap guard under review, not an `ok`
release criterion.
