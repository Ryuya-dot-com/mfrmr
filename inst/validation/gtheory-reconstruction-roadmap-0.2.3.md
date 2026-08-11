# Typed G-theory and D-study reconstruction roadmap

Status: repository-only Draft.80 roadmap with Draft.81--Draft.83d2b2b1g4
parser, estimation, incidence, allocation, backend, simulation, and source-
audited weak-information diagnostic slices recorded, 2026-08-10.

This document proposes a source-grounded reconstruction of the existing
`mfrm_generalizability()` and `mfrm_d_study()` layer. It does not expand the
0.2.3 public support claim. The current exported helpers remain the caveated
univariate main-effects baseline until the gates below are implemented and
passed.

## Decision

This is a strong development direction for mfrmr, provided it is developed as
a typed design-and-estimand system rather than a clone of the archived
`gtheory` function names.

The target is an observed-score G-theory complement to MFRM, not an automatic
reliability interpretation of an MFRM likelihood and not a joint GT-IRT model.
The G-study refits observed scores with a declared mixed-model design. The
D-study transforms identified variance or covariance components for a declared
future measurement design. Rasch/MFRM separation, marginal reliability,
G-theory `E rho^2`, and dependability `Phi` remain distinct metric families.

## Source and implementation audit

As of 2026-08-09:

- CRAN removed `gtheory` 0.1.2 on 2025-03-24 because maintainer email was
  undeliverable. Its archived `gstudy()` accepted an arbitrary `lmer` formula,
  offered univariate and stratum-based multivariate routes, and its `dstudy()`
  calculated relative and absolute error summaries plus weighted composites.
- The archived package is a feature reference, not a numerical oracle. Its
  documented unbalanced route uses median main-facet counts for an overall
  result, and parts of its multivariate score machinery remain commented in
  the archived source. mfrmr must not reproduce those approximations silently.
- The current `gtheoryr` 0.1.0 package intentionally supports only simple
  crossed persons-by-items and items-within-person designs. It is useful as a
  narrow external fixture, not evidence for arbitrary-facet designs.
- The current `csemGT` 1.0.0 package focuses on conditional SEM and D-study
  extrapolation for a persons-by-items crossed design, including analytical and
  item-resampling uncertainty. It is a future conditional-error reference, not
  an arbitrary-facet G-study backend.
- GeneralizIT 0.1.2 is a maintained Python implementation for univariate
  crossed/nested, unbalanced, and missing-data designs. Its Henderson-method
  implementation is a useful independent overlap candidate after a source and
  estimand audit; it is not assumed to be ground truth.
- Local `lme4` 2.0.6 can fit crossed and nested Gaussian mixed models, expose
  variance/covariance blocks, detect singularity, decompose singular structures
  with `rePCA()`, and perform full-refit parametric bootstrap with `bootMer()`.
- Local `glmmTMB` 1.1.14 supports Gaussian REML, structured and unstructured
  random-effect covariance blocks, stratum-dependent dispersion models,
  profile intervals, simulation/refit, and experimental bootstrap support.
  Positive-definite Hessian and convergence diagnostics are not interchangeable
  with `lme4::isSingular()` and need a backend-specific contract.

Primary source links:

- <https://cran.r-project.org/package=gtheory>
- <https://cran.r-project.org/package=gtheoryr>
- <https://cran.r-project.org/package=csemGT>
- <https://search.r-project.org/CRAN/refmans/gtheory/html/gstudy.html>
- <https://search.r-project.org/CRAN/refmans/gtheory/html/dstudy.html>
- <https://pypi.org/project/generalizit/>
- <https://doi.org/10.1016/j.softx.2025.102235>
- <https://lme4.github.io/lme4/articles/lmer.pdf>
- <https://lme4.github.io/lme4/reference/isSingular.html>
- <https://lme4.github.io/lme4/reference/confint.merMod.html>
- <https://lme4.github.io/lme4/reference/bootMer.html>
- <https://glmmtmb.github.io/glmmTMB/reference/glmmTMB.html>
- <https://glmmtmb.github.io/glmmTMB/articles/covstruct.html>
- <https://glmmtmb.github.io/glmmTMB/reference/confint.glmmTMB.html>
- <https://glmmtmb.github.io/glmmTMB/reference/bootmer_methods.html>
- <https://glmmtmb.github.io/glmmTMB/reference/diagnose.html>

## Current mfrmr baseline and its exact limit

The current helper constructs only

```r
Score ~ 1 + (1 | Object) + (1 | Facet1) + ...
```

through `lme4::lmer()`. It treats all object-by-facet, facet-by-facet,
higher-order interaction, and replicate error as one `Residual` component.
`mfrm_d_study()` then applies `highest_order`, `single_condition`, or `none`
scaling to that collapsed residual. This is a useful one-observation-per-cell
sensitivity analysis, but it is not an arbitrary crossed or nested G-study.

The existing surface remains available for compatibility. Its result must keep
an explicit model identity such as `main_effects_collapsed_residual_v1`; it
must not silently acquire stronger meaning after a richer engine is added.

## Proposed public shape

The eventual interface may accept:

```r
spec <- mfrm_gt_spec(
  formula = Score ~ 1 +
    (1 | Person) + (1 | Rater) + (1 | Item) +
    (1 | Person:Rater) + (1 | Person:Item) +
    (1 | Rater:Item),
  object = "Person",
  facets = c("Rater", "Item"),
  effect_map = ...,     # required when semantics are not uniquely derivable
  nesting = NULL,
  strata = NULL
)

g <- mfrm_generalizability(
  fit,
  formula = spec$formula,
  design = spec,
  backend = "lme4",
  interval = "none"
)

d <- mfrm_d_study(
  g,
  design_grid = data.frame(n_Rater = 2:4, n_Item = 6),
  decision = c("relative", "absolute"),
  interval = "parametric_bootstrap"
)
```

Names are provisional. The design object, not the spelling of these helpers,
is the durable contract.

An arbitrary mixed-model formula is necessary but not sufficient. A term such
as `A:B` does not by itself say whether `B` is nested in `A`, whether the term
is an object interaction, whether a facet is random in the universe of
admissible observations, or how it changes under a D-study. When the answer is
not provable from the typed design, mfrmr must require an explicit effect map or
fail closed.

## Typed design contract

Every design receives a canonical identity containing at least:

| Field | Required meaning |
| --- | --- |
| `ScoreColumn` | Numeric observed-score response used by the G-study. |
| `ObjectFacet` | Object of measurement, usually `Person`. Exactly one in the first univariate phases. |
| `RandomFacets` | Conditions sampled from the universe of admissible observations. |
| `FixedFacets` | Conditions held fixed; no automatic transport to a random-facet D-study. |
| `FormulaCanonical` | Canonical parsed fixed and random terms, not only user text. |
| `NestingGraph` | Directed acyclic parent-child relations and conditional level counts. |
| `Strata` | Multivariate profile dimensions, their order, and score scale compatibility. |
| `EffectMap` | One row per fitted variance/covariance component. |
| `MissingnessContract` | Observed/omitted rows, declared mechanism, and eligibility boundary. |
| `BackendIdentity` | Backend/version, REML/ML, controls, function hashes, warnings, and convergence state. |

The effect map contains:

| Field | Meaning |
| --- | --- |
| `ComponentId` | Stable semantic identifier independent of backend print labels. |
| `Members` | Set of object/facet variables contributing to the component. |
| `ContainsObject` | Whether the object of measurement participates. |
| `UniverseRole` | `universe_score`, `relative_error`, `absolute_only`, `both_errors`, `fixed_condition`, or `unresolved`. |
| `ScaleBy` | Ordered set of planned facet counts or allocation operators used in the D-study. |
| `NestingParents` | Parent facets whose conditional allocation changes the divisor. |
| `ObservedCellReplication` | Whether the component is distinguishable from residual error. |
| `EstimabilityStatus` | Identified, aliased, boundary, singular, unsupported, or not fitted. |

No component with `UniverseRole = "unresolved"` enters `E rho^2`, `Phi`, SEM,
or a composite coefficient.

## Fully crossed univariate algebra

For an object `p` crossed with random facets `r` and `i`, a saturated
random-intercept decomposition may include

```text
p, r, i, p:r, p:i, r:i, p:r:i, residual
```

The highest-order interaction and residual are separately estimable only with
replication inside `p:r:i` cells. Without replication, the design must retain a
single explicitly labelled confounded component rather than report both.

For planned counts `n_r` and `n_i`, the ordinary balanced scaling is:

```text
relative error = sigma2(p:r) / n_r
               + sigma2(p:i) / n_i
               + sigma2(p:r:i,e) / (n_r n_i)

absolute error = relative error
               + sigma2(r) / n_r
               + sigma2(i) / n_i
               + sigma2(r:i) / (n_r n_i)

E rho^2 = sigma2(p) / (sigma2(p) + relative error)
Phi     = sigma2(p) / (sigma2(p) + absolute error)
```

These equations are an exact oracle only for their declared balanced random-
facet design. The implementation derives each divisor from `ScaleBy`; it does
not infer the whole residual divisor from the number of columns in a design
grid.

## Nested and partially crossed designs

`(1 | Site/Rater)` expands computationally to site and site-by-rater terms,
but this expansion does not supply the G-theory universe definition. The
nesting graph must say that Rater levels are sampled conditionally within Site
and must retain the conditional planned counts.

If a facet is nested within the object, for example unique Raters within each
Person, a population-wide Rater main effect is not separately linked across
Persons. That component cannot be relabelled as an ordinary crossed Rater
effect. It may contribute to person-specific relative error under a declared
superpopulation design, but absolute main-effect interpretations and cross-
Person Rater comparisons fail closed.

Partially crossed and sparse designs require an incidence/rank audit before
fitting. Connectivity is necessary but not sufficient. The audit retains
component-specific ranks, observed combinations, replication, isolated levels,
and overlap topology.

## Unbalanced allocation and missingness

REML/ML mixed models can fit many unbalanced designs under their model and
missing-data assumptions, but that does not make a D-study based on a median
facet count exact.

The D-study therefore has two separate modes:

1. `balanced_counts`: explicitly planned counts with exact component-wise
   symbolic scaling; and
2. `allocation_operator`: a declared object-by-facet or stratum-by-facet
   allocation/weight structure that transforms every component.

Observed medians or harmonic means may be reported descriptively, but never
substituted silently for a design operator. Outcome missingness is recorded as
MCAR, covariate-dependent MAR, score-dependent/MNAR sensitivity, or unknown.
Unknown and MNAR states cannot become decision-ready simply because the mixed
model returned a finite estimate.

Observed median counts cannot silently define a D-study.

## Estimation families and negative variance components

The estimator is part of the result identity:

| Estimator | Role | Boundary contract |
| --- | --- | --- |
| Balanced ANOVA/MoM oracle | Exact textbook fixtures and visibility of unconstrained sampling estimates. | Negative raw components remain visible. Optional truncation/reallocation is a separately named transformation. |
| `lme4` REML/ML | Primary Gaussian crossed/nested likelihood backend. | Components are constrained nonnegative; zero, singularity, `rePCA`, gradients, warnings, and optimizer checks remain visible. A constrained zero is not called a raw negative estimate. |
| `glmmTMB` REML/ML | Secondary parity, heterogeneous-dispersion, and structured-covariance backend. | Requires finite objective, positive-definite Hessian, backend diagnostics, boundary/correlation checks, and optimizer-sensitivity review. |

Backend disagreement cannot be resolved by selecting the more favorable
coefficient. The common formula, retained rows, effect map, estimation method,
and D-study transformation must match before numerical comparison.

The primary supported response remains Gaussian observed score. Ordinal-link,
latent-variable, and joint GT-IRT/GPCM models are separate research families;
they do not inherit evidence from this layer.

## Confidence intervals

Intervals for a derived D-study coefficient must propagate joint uncertainty
across all component estimates. Plugging marginal variance-component interval
endpoints into the D-study formula is not a valid default.

The proposed primary route is full-refit parametric bootstrap:

1. simulate from the fitted G-study under a fixed seed and design;
2. refit the same canonical formula and backend controls;
3. rerun identification and boundary diagnostics;
4. recompute every requested D-study scenario; and
5. retain successful, failed, boundary, and ineligible replicates separately.

Percentile/basic interval choice, minimum successful replication rate, Monte
Carlo error, and boundary handling remain pilot-calibrated. Component-wise
profile intervals are supplementary. Wald intervals are never the only
decision-ready route for boundary-prone variance or covariance components.

Each interval records target, method, confidence level, seed stream, planned
and successful replicates, failure reasons, boundary frequency, and Monte
Carlo precision. A numerically high coefficient with an unavailable interval
does not receive a high-stakes-ready status.

## Multivariate G-theory

Multivariate G-theory is introduced only after the univariate design algebra is
verified. Data are retained in long form with an explicit `Stratum`/profile
dimension. Component-specific covariance matrices may be estimated with
stratum random slopes such as `(0 + Stratum | Person)` and analogous
interaction blocks.

For stratum-weight vector `w`, the composite coefficients are

```text
E rho^2(w) = (w' Sigma_p w) / (w' (Sigma_p + Sigma_delta) w)
Phi(w)     = (w' Sigma_p w) / (w' (Sigma_p + Sigma_Delta) w)
```

where `Sigma_p`, `Sigma_delta`, and `Sigma_Delta` are D-study covariance
matrices, not averages of univariate coefficients.

Counts alone do not determine off-diagonal D-study scaling. If two strata use
the same Raters or Items, their covariance differs from a design using
independent facet samples. The multivariate design must therefore declare, for
each component, the cross-stratum sharing/overlap or an explicit averaging
operator. For one shared facet, a covariance contribution generally depends
on the number and weights of shared facet levels divided by the two marginal
allocation totals; it is not automatically divided by `sqrt(n_a n_b)`.

Before a matrix enters a coefficient, mfrmr checks symmetry, dimensions,
stratum order, finite values, positive semidefiniteness under a declared
tolerance, effective rank, and compatibility of universe/error matrices.
Any PSD repair is separately labelled and both raw and repaired matrices are
retained. Indefinite or rank-deficient results never disappear behind a scalar
composite.

The future Draft.85a0 supplied-matrix algebra preflight is now complete. It
represents every component by a stratum covariance `Gamma_c` and an explicit
prospective allocation Gram matrix `Lambda_c`, with D-study contribution
`Gamma_c o Lambda_c`. Common, partially shared, and independent facet samples
therefore differ through exact weighted overlap rather than a count shortcut.
The preflight reproduces one-stratum G/Phi, verifies two- and three-stratum
order, retains PSD/rank state and component quadratic contributions, and fails
for indefinite/asymmetric/order-mismatched matrices or invalid weights.

This early algebra preflight receives supplied covariance matrices. It does
not implement `Stratum`-aware incidence auditing, random-slope covariance
estimation, missing-stratum handling, joint intervals, or public multivariate
objects. Draft.83d2 and Draft.84 remain execution prerequisites; future
Draft.85b/c own estimation and recovery.

## Reproducible result contract

Every G/D-study bundle retains:

- canonical formula and typed design/effect-map hashes;
- retained-data and missingness hashes;
- package, backend, R/platform, optimizer, and control identities;
- raw backend variance/covariance parameters and semantic component tables;
- identification, alias, singularity, Hessian, gradient, and boundary audits;
- exact D-study component contributions and divisors/operators;
- interval seed/checkpoint/completion identities and failed-replicate ledger;
- report tables that distinguish estimate, uncertainty, identification, and
  decision-use status; and
- the source MFRM fit identity while stating that the G-study is a separate
  observed-score refit.

## Ordered implementation slices

### Draft.80: contract only (complete)

- Freeze this typed design, estimator, D-scaling, interval, multivariate, and
  reporting roadmap.
- Preserve the existing simplified public API and its caveats.
- Add no `glmmTMB` runtime dependency and make no multivariate support claim.

### Draft.81: parser and algebra oracle (repository prototype complete)

- Implemented an internal random-intercept formula/design parser without
  fitting.
- Canonicalized crossed terms and retained original nested syntax separately
  from backend expansion; nested scaling remains deliberately unsupported.
- Implemented component-wise balanced-count D-study scaling for the narrow
  one- and two-random-facet crossed subset.
- Passed hand-calculated p x i and p x r x i positive fixtures plus unresolved,
  nested, raw-negative, malformed, and highest-order alias controls.
- Recorded the exact scope, hashes, and eight-test/46-expectation result in
  `gtheory-design-algebra-record-0.2.3.md`. This is structural review evidence,
  not variance-component recovery or a public support claim.

### Draft.82: balanced univariate G-study (repository prototype complete)

- Added balanced orthogonal ANOVA/MoM and `lme4` REML/ML point estimators under
  the Draft.81 semantic component table.
- Recovered frozen complete p x i and p x r x i component vectors, independently
  matched saturated base-R ANOVA sums/mean squares, and matched lme4 REML on
  interior fixtures.
- Retained ML as a distinct estimator and reproduced raw-negative MoM versus
  constrained-zero/singular REML behavior without post-hoc relabelling.
- Reproduced the existing public helper's four main-effect/collapsed-residual
  components under an explicit compatibility identity that cannot use the
  typed interaction D-study algebra.
- Recorded seven tests and 71 expectations in
  `gtheory-balanced-estimation-record-0.2.3.md`. This remains structural fixture
  evidence, not Monte Carlo recovery, interval, estimator-selection, external-
  overlap, or public support evidence.
- Brennan and independently matched archived/current external-package overlaps
  remain for Draft.86 after estimator and design semantics are sufficiently
  stable; no external package is treated as truth.

### Draft.83: nesting, partial crossing, imbalance, and missingness

- Draft.83a is complete as a repository-only pre-fit observed-design audit. It
  canonicalizes retained/omitted rows; applies conditional identities to
  nested child levels; records global and pairwise incidence, workload, full-
  cell replication, and fixed-effect-equivalent component-rank increments;
  and retains disconnected, missingness-conflict, metadata-mismatch, and
  capacity negative controls.
- Draft.83a does not equate connectivity or fixed-equivalent rank with random-
  covariance identifiability. Its estimation state is unadjudicated and all
  coefficient and decision-ready fields are false. Seven tests and 69
  expectations are recorded in
  `gtheory-design-incidence-record-0.2.3.md`.
- Draft.83b is complete as a repository-only component-specific planned-weight
  operator. Each component uses the squared marginal weights of its own
  `ScaleBy` identities; crossed uniform plans reduce exactly to Draft.81,
  nested support uses ancestry-qualified levels, unequal units remain
  unit-specific, and shared/disjoint cross-unit overlap is retained. Seven
  tests and 71 expectations are recorded in
  `gtheory-allocation-operator-record-0.2.3.md`.
- Draft.83b fits no model. Algebra-ready supplied component vectors remain
  estimation-, inference-, and decision-ineligible. Object-nested facets,
  replicate-error scaling, and fixed-facet transport remain blocked pending
  separate universe/operator contracts.
- Draft.83c1 is complete as a repository-only covariance-design,
  expected-information, and lme4 point-fit audit. It constructs semantic
  `K_c=Z_c Z_c'` derivatives, reports structural and ML/REML information rank
  with component-labelled null spaces, binds lme4 to the exact Draft.83a
  retained rows, and keeps optimizer convergence, singularity, and boundary
  regularity separate. Eight tests and 103 expectations are recorded in
  `gtheory-covariance-information-record-0.2.3.md`.
- Draft.83c1 point-estimation qualification is still not coefficient
  eligibility. Its disconnected control can have full covariance and
  information rank while failing Draft.83a; its boundary control can have
  optimizer code zero while remaining singular and nonregular.
- Draft.83c2 is complete as a repository-only matched Gaussian glmmTMB/lme4
  point-estimation audit. It adds semantic glmmTMB component extraction,
  default-control and function identities, optimizer/gradient/`pdHess`/
  boundary diagnostics, and exact component/intercept/full-logLik comparison.
  Interior p x i ML/REML, p x r x i ML/REML, and nested Site/Rater controls
  pass the matched overlap. Eight tests and 93 expectations are recorded in
  `gtheory-glmmtmb-parity-record-0.2.3.md`.
- The boundary negative control has glmmTMB `pdHess=TRUE` but is nonregular and
  materially disagrees with lme4; numerical and matched-overlap parity remain
  false. Draft.83c2 therefore selects no backend and supplies no coefficient
  eligibility.
- Draft.83d1 is complete as a repository-only pre-simulation ADEMP registry.
  It registers 24 covering scenarios, 20 metrics, 480 scenario-metric routes,
  and an 89-unit paired one-replicate smoke manifest. Gaussian component truth,
  finite observed-score projection, missingness and local-dependence
  sensitivity, boundary/identification controls, and anchor-rate
  nonapplicability remain separate.
- Draft.83d1 also freezes monotone result stages and exact denominators for fit
  return, convergence, point-gate, metric availability, false readiness, and
  typed failed cells. Coverage remains unavailable until Draft.84, and the
  G-theory effect-recovery ratio is explicitly not Rasch/FACETS separation.
  Draft.83d1 itself generated no dataset, and pilot/confirmation replication
  counts remain unfrozen.
- Draft.83d2a is complete as a repository-only deterministic generator. It
  produces separately hashed complete-potential, assigned, and analysis tables
  for 22 executable scenarios and typed blocks for two anchor scenarios. Exact
  assignment density/counts, workload imbalance, bounded-score projection,
  four missingness mechanisms, local dependence, boundary draws, and
  disconnected/aliased controls replay under one generator identity. Ten
  tests and 185 expectations are recorded in
  `gtheory-ademp-generator-record-0.2.3.md`.
- Draft.83d2b0 is complete as a repository-only structural pre-fit gate. It
  binds every generated dataset and manifest unit to the Draft.83a incidence
  audit plus an exact scalable covariance-component rank audit. Equality-
  signature compression matches the feasible Draft.83c1 dense oracle and
  evaluates the 19,200-row N=300 cell without forming derivative matrices.
  Nineteen scenarios/77 fit units are eligible and three scenarios/12 units
  are blocked. Eight tests and 71 expectations are recorded in
  `gtheory-ademp-prefit-record-0.2.3.md`.
- Draft.83d2b1 has executed method-specific balanced-MoM, lme4 ML/REML, and
  glmmTMB ML/REML adapters for all 89 planned units. The 12 pre-fit-blocked
  units receive typed failures without a backend call; all 77 eligible attempts
  return. Fifty-seven point gates pass and 32 typed failures retain exact
  accounting. Six focused tests contain 58 evaluated expectations plus one
  explicit resource-tier skip; the full runner separately reproduces one
  execution hash twice.
- Draft.83d2b1 retains a blocking concern: all four near-zero variance routes
  pass the current point gate, so zero false readiness fails. Exact-zero,
  disconnected, and aliased controls remain blocked.
- Draft.83d2b2a is complete as a repository-only weak-information diagnostic
  registry and one-replicate covering smoke. Five design/information strata,
  six target Rater-variance regions, and four ML/REML x backend routes produce
  120/120 returned atomic fits. The existing whole-model gate passes 82 units
  but yields 27/40 false-ready negative controls and 3/12 false-block positive
  controls. Ten truth-blind observables are available, while a reduced-model
  likelihood diagnostic and full-refit intervals remain later work. These
  counts show that target-component weakness and nuisance-component failure
  must be separated; they are not operating-characteristic estimates.
- Draft.83d2b2b0 is complete as the replicated pilot-plan and authorization
  firewall. Schema IDs 2--3, feasibility IDs 101--125, calibration IDs
  201--300, and confirmation IDs 501--700 are disjoint. The corresponding
  plans contain 24, 3,000, 12,000, and 24,000 fits; methods are paired within
  one scenario-replicate dataset and primary rates cannot pool design strata.
  Four rule architectures and a four-state resolution outcome are registered,
  but no rule or cutpoint is selected. The 24-fit schema run passes atomic
  accounting and remains ineligible as pilot evidence.
- Draft.83d2b2b1a is complete as a repository-only source and diagnostic-refit
  audit. It withdraws the former common target-relative-SE score because lme4
  relative-SD/profiled-criterion and glmmTMB log-SD/joint-covariance scales are
  not commensurate component standard errors. Twenty-four already viewed
  full/reduced pairs return, raw ML/REML likelihood differences remain
  untruncated and p-value-free, and 20 backend-local scales are available.
  This prospectively supersedes the historical 25-replicate feasibility
  authorization before any reserved seed is generated.
- Draft.83d2b2b1b is complete as the exact-observed-design fitted-null
  parametric-bootstrap mechanics layer. Three already viewed baseline controls
  at outer replicate 2 x four lme4/glmmTMB ML/REML routes x `B=3` produce 12
  observed and 36 bootstrap pairs, or 96 full/reduced fits. All pairs return;
  exact design and response/data identity checks pass; 16 small negative raw
  likelihood differences remain untruncated; and eight bootstrap pairs expose
  a non-target nuisance boundary. Failure-aware plus-one bounds are
  implemented, including separate simulation and refit failure stages.
- The `B=3` values have grid width 0.25 and are mechanics-only. A replacement
  feasibility identity must separately freeze the 3,000-row no-inner-
  bootstrap resolution computation and an outer operating-characteristic
  study. Zero-null separation remains distinct from positive-component
  bias/RMSE/coverage and D-study stability. Only a later specification may
  select a production `B`, reauthorize feasibility, or view calibration and
  confirmation results. No minimum Rater count, exposure, or sample-size rule
  exists.
- Draft.83d2b2b1c freezes the replacement 3,000-row/750-dataset/6,000-fit
  descriptive-feasibility manifest without generating replicates 101--125.
  Its all-cell runtime schema uses only viewed replicate 1. All 120 diagnostic
  pairs return; 111 common scores are available; six materially negative
  likelihood differences and four optimizer/likelihood failures overlap in
  one row and leave nine unavailable routes. The timing-excluded execution
  hash reproduces, and pair/dataset checkpoint identities are frozen.
- The separate authorization record now permits only the exact descriptive
  feasibility run. It does not permit thresholds, inner bootstrap, early
  stopping, calibration, confirmation, inference, or coefficient decisions.
  Draft.83d2b2b1d now executes all 3,000 atomic rows and 750 dataset markers.
- All 3,000 pairs return, but only 2,804 common scores are available. The 196
  unavailable rows are the union of 79 optimizer/likelihood-identity failures
  and 126 finite materially negative raw likelihood differences, with nine
  overlapping; seven non-finite raw differences are within the failure set and
  are not signed material-negative values.
  A full resume reuses all route checkpoints and reproduces the execution hash.
- High-information routes have only 457/600 common scores available and 101
  material-negative likelihood differences. Few-level routes have 283/600
  nuisance boundaries and only about 0.14--0.26 Spearman truth ordering.
  `FeasibilityEvidenceReady=TRUE` therefore means complete descriptive
  accounting, not an adequate or calibrated component-resolution rule.
- Draft.83d2b2b1e executes the separate viewed-data numerical-likelihood
  sensitivity: 9,000 profile pairs and 18,000 fits resume exactly. Tightening
  the same algorithm changes no objective. lme4 bobyqa removes all 34 finite
  default-lme4 material-negative differences, while glmmTMB BFGS produces 331
  non-finite and 401 finite material-negative differences. Seven default
  non-finite states are not adjudicated by the frozen finite-difference replay
  rule, so `NumericalSensitivityEvidenceReady=FALSE`.
- Draft.83d2b2b1f prospectively types replay on the immutable b1d/b1e ledgers
  without refitting. All 2,993 finite routes and seven same-typed `NA_real_`
  diagnostic states match, with no mismatch or availability promotion.
  `TypedReplayAdjudicationReady=TRUE`, while the immutable b1e replay result,
  `NumericalStabilizationReady`, and
  `NumericalSensitivityEvidenceReady` remain false.
- Draft.83d2b2b1g freezes the backend-specific glmmTMB stabilization design:
  all 1,500 viewed routes expand to a symmetric cold/self-restart/cross-start
  six-profile DAG with 9,000 pairs and 18,000 planned fits. Ten start blocks,
  exact same-model parent lineage, two gradient surfaces, Richardson Hessian
  diagnostics, and typed parent failure are part of identity. The manifest is
  exact, but the runner is absent, execution unauthorized, and no diagnostic
  eligibility cutoff is selected.
- Draft.83d2b2b1g1 implements that atomic runner and executes only the
  factor-selected 120-pair covering smoke. All 20 base-route checkpoints and
  ten dataset markers validate and resume without refitting. Eighty-four rows
  are diagnostic-complete; 21 are finite material-negative, 11 have non-finite
  objective/likelihood, and four retain typed fit/dependency failure. Two BFGS
  fits fail strict bitwise equality between `last.par.best` fixed coordinates
  and `fit$fit$par`, so full execution remains unauthorized.
- Draft.83d2b2b1g2 prospectively defines a tolerance-free fixed-coordinate
  alignment, executes the same complete 120-row denominator under a new
  identity, and verifies exact no-fit resume. All 240 fits return and align;
  the four b1g1 fit/dependency failures are recovered with no losses. Common
  returned objectives, log likelihoods, and top-level parameter hashes have
  zero mismatches. The resulting 14 non-finite, 21 finite material-negative,
  and adverse gradient/curvature diagnostics show that transport mechanics,
  not numerical adequacy, have been repaired.
- Draft.83d2b2b1g3 applies that separate no-refit multi-axis adjudication. All
  120 pair objectives are finite, while 14 reported likelihood pairs are
  exactly explained by glmmTMB's non-PD-Hessian mask. One full optimizer code
  is nonzero beneath the old precedence state. Sdreport/Richardson PD signs
  agree throughout, while one full and one reduced outer/sdreport gradient
  hash differ. The complete objective ordering is 75 positive, 22 small
  negative, and 23 material negative. Best-observed six-profile envelopes are
  12 positive and 8 small negative, but make no global-maximum claim.
- Draft.83d2b2b1g4 prospectively instruments the same 120 pairs and retains
  named parameter vectors, raw outer and sdreport gradients, Richardson
  matrices, and distinct raw, objective/parameter-relative, lme4-compatible,
  Newton-decrement, and Newton-step vectors for all 240 fits. All b1g2 fitted
  quantities and repeated derivative hashes reproduce, and no-fit resume is
  exact. Spectral Hessian positivity holds for 224 fits, but numerical
  Cholesky factors for only 221. Across 40 route/model strata, profiles with
  minimum scaled summaries do not generally equal the best-observed objective
  profile. The schema is measurement-ready but every stationarity state
  remains `not_calibrated`.
- Draft.83d2b2b1g5 freezes the independent calibration design while keeping
  replicates 201--300 sealed. It makes finite stationarity, curvature,
  profiled log-SD boundary limits, and statistical component resolution
  separate state spaces. Affine fixtures verify Hessian-inertia and
  Newton-decrement invariance and expose coordinate dependence in raw,
  lme4-compatible, and relative-step summaries. The prospective workload is
  3,000 independent datasets, 144,000 candidate fits, and 24,000 reference
  problems. Candidate and reference architectures are frozen, but reference
  tolerances, stationarity thresholds, execution, and every downstream gate
  remain false.
- Draft.83d2b2b1g6 freezes only the high-accuracy reference mechanics. Six
  analytic objectives recover their intended numerical states. All four
  full/reduced glmmTMB REML objectives from nonreserved replicates 901--902
  pass three-algorithm consensus, an AD-independent adaptive central-
  difference audit, numerical Hessian symmetry, curvature, and sidecar
  integrity. TMB random-effect starts are reset before every evaluation, and
  every fixed-log-SD boundary-profile point passes nuisance curvature and
  stationarity after Newton polishing. No reserved seed is opened.
- Draft.83d2b2b1g7 audits that proposed authorization and deliberately does
  not issue it. Backend-specific registries correct the prospective b1g5
  candidate-fit upper bound from 144,000 to 108,000: glmmTMB contributes
  72,000 six-profile fits and lme4 contributes 36,000 three-profile fits.
  The 3,000 datasets and 24,000 reference problems are unchanged. Candidate
  states now fail closed across boundary, first-order, and curvature evidence,
  and optimizer profiles are selected per dataset-method-model-role only by
  minimum finite objective plus frozen tie priority. Only glmmTMB REML has
  passed the b1g6 nonreserved reference gate.
- Draft.83d2b2b1g8 applies the unchanged b1g6 high-accuracy mechanics to a
  separately hashed glmmTMB ML (`REML=FALSE`) objective on the same
  nonreserved datasets. All four full/reduced objectives pass multialgorithm,
  AD-independent derivative, positive-curvature, boundary-profile, and
  content-integrity gates. A second full replay reproduces every row and hash.
  Generator hashes equal b1g6 while all four polished objectives differ,
  proving likelihood-mode separation without ranking ML versus REML.
- Draft.83d2b2b1g9 independently fixes the lme4 reference objective before
  any lme4 replay. On a deterministic crossed random-intercept fixture, dense
  Gaussian profiled ML/REML criteria and analytic gradients agree with lme4's
  theta-only deviance closures, fitted criteria, and log-likelihoods; an exact-
  zero full-to-reduced identity holds in both modes. Namespace-hashed negative
  controls exclude `devfun2()` and `deviance(..., REML=TRUE)` from REML
  reference work. Box-constrained optimization, boundary profiling, and
  nonreserved replay remain unimplemented and unauthorized.
- Draft.83d2b2b1g10 completes that nonreserved lme4 ML/REML replay. A
  three-algorithm nonnegative-theta solver, sparse analytic objective/gradient
  oracle, analytic Newton raw-KKT polish, free-curvature check, and seven-point
  nuisance-reoptimized profiles pass for all eight full/reduced objectives on
  replicates 901--902. All zero-theta endpoints match reduced objectives and a
  full repeat is exact. Together with b1g6/b1g8, reference-method coverage is
  now four of four; estimator operating characteristics and calibration
  authorization are not implied.
- Draft.83d2b2b1g11 freezes the truth-blind acceptance and Monte Carlo
  decision policy without opening replicate 201. Three primary score families
  crossed with eight existing zones form 24 candidates. Primary rates remain
  scenario x method x model-role specific; safety false ready, false boundary
  handoff, false unready, missed boundary, indeterminate, non-evaluation, and
  unresolved reference states are distinct. One-sided exact-binomial bounds
  cannot be described as post-selection confidence intervals. Any observed
  safety error rejects a candidate, and required decisive-class coverage
  prevents an always-indeterminate rule from winning. No candidate, cutpoint,
  production criterion, or calibration authorization is created.
- Draft.83d2b2b1g12 implements the lower-cost production boundary probe while
  preserving backend coordinates. lme4 reaches a finite theta-zero endpoint;
  glmmTMB approaches zero variance through decreasing log-SD. Every point
  reoptimizes nuisance parameters, and a shared boundary interpretation
  requires monotone material improvement plus agreement with the separately
  fitted reduced objective. Flat, nonmonotone, endpoint-mismatched, and failed
  profiles remain inconclusive or non-evaluable. Analytic controls and all
  four backend-likelihood fixtures pass without using truth or candidate
  cutoffs; no production stationarity rule is selected.
- Draft.83d2b2b1g13 implements the exact-resume accounting layer without
  opening replicate 201. One atomic dataset-method checkpoint retains every
  registered optimizer fit, both full/reduced roles, both high-accuracy
  references, all 48 candidate decisions, and complete typed failure rows.
  The sealed workload independently resolves to 3,000 dataset markers, 12,000
  atomic units, 108,000 candidate fits, 576,000 candidate decisions, and
  24,000 references. Interrupted, cold, complete-reuse, and one-checkpoint-
  repair fixtures recover the same scientific hash; partial progress is not
  evidence.
- Draft.83d2b2b1g14 freezes the final production evaluator adapters and exact
  reserved-run manifest without opening replicate 201. Real lme4/glmmTMB x
  ML/REML adapters share generator and pre-fit identities, retain
  objective-only profile selection, and complete all four nonreserved atomic
  units with exact 36-fit, 192-decision, and eight-reference ledgers. One
  `start_snapshot` failure remains typed in its planned denominator. Runtime,
  package, dependency, output-root, unit, and 100 one-replicate shard
  identities are fixed; all reserved shards remain non-executable.
- Draft.83d2b2b1g15 completes the independent response-free one-way
  authorization preflight. One hundred prospective non-executable manifests
  exactly partition the sealed workload. The frozen output parent passes an
  actual write, checked same-directory rename, identical readback, cleanup,
  target-absence, and site-capacity probe. Conservative 32x storage plus 32
  GiB residual and 4x runtime planning passes under one concurrent shard and
  no early stopping. Authorization readiness and activation eligibility are
  true, but no authorization record is issued and no reserved response is
  opened.
- Draft.83d2b2b1g15a audits the scientific value of that workload without
  opening it. The independent denominator is 3,000 datasets and at most 100
  trials per scenario x method x model-role cell, not 108,000 fit rows or
  576,000 decisions. Complete-denominator 0/100 has a one-sided 95% upper bound
  of 0.029513 and a true 3% event is detected at least once with probability
  0.952447. This supports numerical-rule calibration and a valid negative
  result, but not precise bias/RMSE/coverage, rank, separation, or D-study
  operating-characteristic claims. Reference-unresolved rows reduce the
  actual denominator and cannot be pooled away.
- Draft.83d2b2b1g16 completes a stronger response-free pre-activation
  hardening audit. The actual 9,756 phase-specific scenario-replicate seed
  rows are unique, but a nonreserved replicate-901 negative control proves
  that the same integer seed produces different data under different ambient
  RNG kinds. The b1g14 runtime identity omits RNG, matrix-product mode,
  BLAS/LAPACK, locale/timezone, glmmTMB parallel control, and numerical-library
  thread state. The current path also lacks an isolated vanilla process,
  reserved-only authorized runner, exclusive writer lock, activation marker,
  typed first-activation/resume root lifecycle, and per-shard capacity recheck.
  Eight required blockers supersede b1g15 activation eligibility, so
  `LargeSimulationMayStart=FALSE` and replicate 201 remains sealed.
- Draft.83d2b2b1g17 preserves that negative control while adding a distinct
  RNG-hardened generator identity. All 30 scenarios at nonreserved replicate
  901 reproduce identical hardened, historical-parent, and analysis-data
  hashes under Mersenne-Twister and Wichmann-Hill caller states; caller RNG
  state is restored and reserved bands are rejected. The generator component
  is prospectively ready, but production adapters still bind the historical
  identity. Thus `AuthorizationRNG01Closed=FALSE`, all parent b1g16 blockers
  remain active, and no large simulation may start.
- Draft.83d2b2b1g18 connects that generator to separately identified
  nonreserved production candidate/reference adapters. Paired historical and
  hardened glmmTMB/lme4 x ML/REML execution has exact semantic parity across
  36 candidate rows, 192 decisions, eight references, and the retained one-
  failure denominator; all four hardened checkpoints reuse exactly. Generator,
  pre-fit, sidecar, manifest, checkpoint, and execution identities change as
  required. The reserved adapter entry point and 100-shard manifest remain
  deferred, so `AuthorizationRNG01Closed=FALSE` and replicate 201 stays sealed.
- Draft.83d2b2b1g19 response-free rederives the complete reserved lineage.
  The old and new workload partitions agree on 3,000 datasets, 12,000 units,
  108,000 fits, 576,000 decisions, 24,000 references, and 100 shards, while all
  12,000 unit and 100 shard hashes change under the hardened adapter/generator
  contracts. Historical hashes remain provenance-only and have no overlap with
  the active registry. All prospective manifests prohibit response generation,
  fitting, execution, output creation, and confirmation use. The executable
  reserved entry point and runtime/runner hardening remain pending, so
  `AuthorizationRNG01Closed=FALSE` and replicate 201 stays sealed.
- Draft.83d2b2b1g20 consolidates the reusable execution boundary. An isolated
  vanilla child, explicit RNG/locale/timezone/startup/thread identity,
  exclusive lock, activation/resume marker, unmarked-root rejection, and fresh
  filesystem/capacity probe pass without creating the reserved root. Nine
  common gates pass. Only the actual reserved runner and a separate immutable
  authorization record remain, so large simulation and replicate 201 stay
  prohibited. This ends infrastructure-only decomposition: after the runner
  and numerical-rule calibration, priority returns to recovery and uncertainty.
- Draft.83d2b2b1g21 executes the real four-lane hardened evaluator path in an
  isolated child on nonreserved replicate 902. The first run retains complete
  36-fit/192-decision/eight-reference denominators and reduces semantically to
  b1g18; the second child reuses all four checkpoints and reproduces the
  scientific execution hash. Reserved and confirmation bands fail before
  generation. Thus `RUNNER-01` passes while `AUTH-RECORD-01` alone blocks;
  large simulation and replicate 201 remain prohibited.
- Draft.83d2b2b1g22 expands that coarse authorization blocker through an exact
  source audit. The b1g21 preparation guard rejects reserved replicates and
  b1g13 remains nonreserved-only, so an executable record-bound entry point
  and exact one-shard active manifest do not yet exist. Five gates pass;
  `RESERVED-ENTRY-01`, `ACTIVE-MANIFEST-01`, and `SITE-RECEIPT-01` block. The
  response-free decision is `no_go_refused_not_issued`, with no reserved root
  and no change to the sealed replicate-201 boundary.
- Draft.83d2b2b1g23 implements the missing mechanics without opening R0201.
  The exact b1g17 generator, b1g18 preparation, and b1g13 checkpoint bodies
  are reused after their three nonreserved admissions are replaced by one
  record/active-manifest/ephemeral-capability boundary. Replicate 902 exactly
  reduces to b1g21 and exactly resumes. The R0201 conversion is implemented
  with complete 30/120/1,080/5,760/240 accounting, but no production issuer,
  record, active R0201 object, fresh site binding, reserved root, or response
  exists. Large simulation and replicate 201 remain prohibited.
- Draft.83d2b2b1g24 completes the response-free issuance decision. Fresh
  b1g20 runtime and target-specific site receipts pass all six recomputed
  gates for exact R0201, producing one hash-valid record and one unexecuted
  active manifest with complete 30/120/1,080/5,760/240 denominators. An
  occupied-target control produces a hash-valid NO-GO and issuance refusal.
  No response, fit, checkpoint, root, or lock is created. The exact issuance
  instance may open only R0201; the large simulation and every later shard
  remain prohibited.
- Before calibration replicates 201--300 can run, make generation RNG-self-
  contained (completed prospectively in b1g17), rebuild every affected
  downstream nonreserved identity (completed in b1g18), rebuild the prospective
  reserved lineage without opening responses (completed in b1g19), freeze
  the extended runtime/process/lock/root/capacity kernel (completed in b1g20),
  and reduce the real guarded single-shard path against nonreserved evidence
  (completed in b1g21). The b1g22 go/no-go audit shows that a record-bound
  reserved entry point and exact one-shard active-manifest conversion
  (implemented response-free in b1g23) must precede a fresh site receipt and
  separate immutable one-shard issuance decision (completed in b1g24). Next,
  execute only the issued R0201 shard under persistent exact resume and review
  its complete ledger before any continuation. Full calibration execution and
  the nuisance-boundary bootstrap calibration contract remain later steps.
  Thresholds, size/power, positive recovery, D-study stability, confirmation,
  inference, and coefficient decisions remain unavailable.

The 2026-08-11 portfolio-purpose audit now adds a higher-order stop before that
execution sequence. b1g24 is retained as the terminal infrastructure result,
but R0201 is not the next portfolio priority merely because it can be issued.
It remains unexecuted until a retained 0.2.3 claim and a decision-specific
precision argument show that the numerical-rule calibration can change the
release disposition and cannot be replaced by algebra, a deterministic
reduction, or an external microcase. No further authorization layer is
planned. The active priority returns to the claim-disposition profile and the
matched ConQuest/TAM/FACETS external core. Broad recovery, coverage, D-study,
and multivariate conclusions keep separate later precision designs.

### Draft.84: uncertainty

- Add checkpointed full-refit parametric bootstrap for G-study components and
  every D-study scenario.
- Calibrate interval coverage, boundary mass, bootstrap failure, and Monte
  Carlo precision by design stratum.
- Keep profile/component intervals supplementary until their transformation
  contract is verified.

### Draft.85: multivariate covariance prototype

- Draft.85a0 is complete as a repository-only supplied-matrix algebra
  preflight: two-/three-stratum ordering, component covariance x allocation-
  Gram contributions, common/partial/independent sampling, weighted composite
  G/Phi, PSD/rank checks, and weight-policy negatives.
- Draft.85b must add typed long-form `Stratum` incidence and covariance-
  estimation adapters. Compare `lme4` and `glmmTMB` only on an exactly matched
  Gaussian random-slope/covariance overlap.
- Draft.85c must recover component covariance, PSD/rank, sharing operators, and
  composite coefficients under sparse, unequal, missing-stratum, two-, and
  three-stratum designs before any experimental public route.

### Draft.86: external and reporting gate

- Reproduce textbook balanced tables and documented archived-package examples.
- Add independent algebraic recomputation from stored component tables.
- Freeze report schemas, compatibility behavior, deprecation policy, and a
  machine-readable support matrix.
- Promote only validated design families; retain every other formula as
  parsed-but-unsupported or research-only.

## Version placement

| Horizon | G-theory scope |
| --- | --- |
| 0.2.3 | Contract, parser/algebra prototypes, and compatibility guards only. Existing main-effects helper remains caveated. |
| 0.2.4 | Candidate univariate crossed/nested observed-score engine after balanced and adverse-design validation; no automatic high-stakes status. |
| 0.2.5 | Multivariate prototype aligned with explicit observed `ScaleId`/stratum identity, still experimental until covariance and sharing contracts pass. |
| 0.3.0 | Stable schemas, reproducible bootstrap/report bundles, external overlap, and documented supported formula grammar. |
| 1.0.0 | Only the validated subset of designs receives a stable support claim; arbitrary syntax outside that subset continues to fail closed. |

## ADEMP validation grid

The Draft.83d1 covering registry spans:

- Persons and levels per facet;
- observations per Person and replication per highest-order cell;
- complete crossing, nesting direction, partial crossing, and sparse topology;
- presence and magnitude of object-by-facet, facet-by-facet, and higher-order
  interactions;
- balanced versus unequal workload/allocation;
- continuous scores plus 3, 5, and 7 categories and endpoint concentration;
  bounded cells target the complete finite-potential observed-score projection
  rather than the latent Gaussian variance components;
- none, MCAR, covariate-MAR, outcome-dependent/MNAR, and unknown missingness;
- interior, exact-zero, near-zero, correlated-boundary, aliased, and
  rank-deficient variance/covariance states;
- REML, ML, balanced MoM, `lme4`, and matched `glmmTMB` identities;
- one to multiple strata, common versus independent facet sampling, covariance
  rank, and composite weights; and
- D-study counts and allocation operators not used to select the G-study
  model; and
- anchor-rate cells that remain blocked because anchoring is not an operation
  in the current Gaussian random-intercept G-study.

Planned metrics are component bias/RMSE, interval coverage and width, Person
rank recovery, facet-level rank/RMSE/effect-recovery ratio, G/Phi
bias/RMSE/coverage, PSD and rank recovery, D-study denominator identity,
fit/convergence rate, bootstrap success and Monte Carlo error, false-ready
rate, and exact failed-cell accounting. Coverage is routed to Draft.84 because
Draft.83c1/c2 has no validated interval. The facet effect-recovery ratio is not
Rasch/FACETS separation. No favorable pooled mean can hide a failed design
stratum, and no unrecorded cell can be relabelled as a typed failure.

## Promotion gates

1. Formula grammar and effect-map semantics are deterministic and hashable.
2. Every reported component has an identified universe/error role and exact
   D-study scaling rule.
3. Saturated and nested alias-negative controls fail before coefficients.
4. Balanced oracle and independent recomputation agree at frozen tolerances.
5. Sparse, unbalanced, and missing designs meet design-specific recovery and
   false-ready criteria.
6. Boundary, singular, Hessian, optimizer, and interval failures remain visible
   in denominators and report status.
7. Multivariate covariance matrices pass raw symmetry/PSD/rank checks and
   shared-facet D-scaling identities before composite coefficients.
8. Public help, examples, capability matrices, NEWS, and report exports state
   the same supported formula subset.

Until all applicable gates pass, the broad arbitrary-formula and multivariate
portfolio remains `roadmap_only`. Draft.80 freezes no backend preference,
formula subset, CI method, coefficient threshold, sample-size rule, D-study
optimum, or high-stakes claim.
