# Draft.85b1 multivariate G-theory matched-backend record

Date: 2026-08-24
Scope: repository-only matched Gaussian ML/REML point-estimation prototype
Result: adapter smoke passed; matched-backend point readiness is blocked by
the local `glmmTMB`/TMB dependency mismatch

## Outcome

The prototype binds a strict component map, component-joint group identity,
explicit observation links, the complete Draft.85b0 audit, fixed and random
design hashes, covariance-derivative rank, and semantic covariance extraction
to one common `lme4`/`glmmTMB` Gaussian model. Eight focused tests and 101
expectations pass without failure, warning, error, or skip.

No exported function, package help page, vignette, NEWS entry, or public
support envelope changed. All recovery, inference, coefficient, decision, and
public-support readiness flags remain false.

## Deterministic positive control

The fixture contains 480 rows: 24 Objects, five global Raters, two Items, and
two ordered strata. The typed model contains global `Object`, `Rater`, and
`Object:Rater` unstructured 2 x 2 covariance components plus independent
homoskedastic residual variance.

The structural audit reports:

```text
free covariance coordinates      10
covariance-derivative rank        10
random coefficients              298
retained observations            480
```

Canonical component ordering is `Object`, `Rater`, `Object:Rater`,
`Residual`, regardless of input map order. Row reversal reproduces the full
specification, row-binding, fixed-design, random-block, and covariance-design
hashes. Backend covariance and fixed-effect names are checked before
reindexing; malformed names fail.

The sealed specification rejects unknown top-level fields/attributes, unknown
backend columns, ordered-factor substitutions, response or row mutation,
false eligibility flags, and stale fixed/random/covariance designs. It stores
only the Draft.85b0 audit hash and canonical formula string; the backend
formula is regenerated from the component map. Normalized fit artifacts also
use an exact schema and do not retain the raw backend object.

At the declared smoke tolerances, explicitly diagnostic fits give:

| Criterion | max covariance absolute difference | max fixed-mean absolute difference | log-likelihood absolute difference | numerical parity |
| --- | ---: | ---: | ---: | --- |
| REML | 8.762925e-05 | 1.793843e-13 | 7.106848e-08 | pass |
| ML | 7.021595e-05 | 3.806434e-05 | 2.744036e-08 | pass |

The zero-tolerance comparison fails as required. Raw backend parameter vectors
are not treated as comparable.

## Fail-closed controls

The focused suite rejects or blocks:

- a mutated Draft.85b0 condition-scope identity and changed retained score;
- invalid universe-role aliases, reversed interaction-member semantics, and a
  non-independent residual declaration;
- stratum-local members in an unstructured component;
- an `Object:Rater` component with marginally shared members but no shared
  joint tuple;
- non-unique within-stratum observation links, omitted scores, and reserved
  tuple delimiters;
- an altered ML/REML semantic model identity;
- post-specification backend-data/schema mutation, unknown fields and
  attributes, and a false point-fit eligibility promotion;
- post-fit component-order, fixed-name, likelihood-criterion, observation-
  count, gate-state, and top-level-schema mutation;
- exact-equality parity under zero tolerances; and
- singular/boundary covariance as a ready point fit.

The singular control preserves boundary status even when the optimizer also
reports a warning. A finite point and an optimizer return code therefore do
not become estimation readiness.

## Environment disposition

The observed local versions are:

```text
lme4                 2.0.6
glmmTMB              1.1.14
glmmTMB build TMB    1.9.23
runtime TMB          1.9.25
TMB ABI              2
```

Because the build and runtime TMB versions differ, the ordinary glmmTMB entry
fails before fitting. The table above was produced only with the explicit
non-ready diagnostic override. Each glmmTMB fit is classified
`backend_dependency_version_mismatch`; its `PointEstimationGatePassed` is
false; consequently `MatchedBackendPointReady` is false for both ML and REML.
The numerical similarity is retained as wiring information, not formal parity
evidence.

## Interpretation and next work

This closes the typed global-component adapter smoke, not multivariate
G-theory validation. The two backends share the same declared model and
related parser infrastructure, so agreement cannot substitute for an
independent covariance oracle or truth recovery. Draft.85c remains responsible
for independent `K`-matrix reconstruction, sparse/unequal/missing designs,
two-/three-stratum recovery, PSD and rank boundaries, composite G/Phi, and
full-refit uncertainty. A local-facet diagonal adapter is explicitly deferred
until exact lme4/glmmTMB parser equivalence and reduction behavior are tested.
