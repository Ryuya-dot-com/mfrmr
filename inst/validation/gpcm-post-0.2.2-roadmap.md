# Bounded-GPCM technical evidence supplement after 0.2.2

Status: subordinate validation supplement, reviewed 2026-07-26; model-family
refinement added 2026-08-08.

The repository-root `ROADMAP.md` controls release sequencing. This file only
records technical exit criteria for bounded-GPCM capability rows that remain
caveated, blocked, or deferred. It must not be read as a list of current API
functions or as authorization to broaden the 0.2.2 release.

The current executable contract is `gpcm_capability_matrix()` together with
`gpcm_runtime_guard_coverage()`. In 0.2.2, bounded GPCM requires an explicit
step facet and the documented `slope_facet == step_facet` structure. Direct
recovery evidence is not design operating-characteristic evidence, and
diagnostic screens are not standalone fairness or validity decisions.

The model-family interpretation and dependency order are refined in
`generalized-mfrm-model-ladder-0.2.3.md`. Under that vocabulary, the current
route is an **aligned single-owner relative-slope GPCM**. Criterion-owned and
rater-owned calls share a response kernel but do not share a substantive
estimand or an empirical evidence claim. Before the 0.2.3 gate can promote a
role-specific claim, its evidence must record `SlopeOwner`, `StepOwner`,
`SlopeComposition`, and `LatentDimensionCount`; pooled bounded-GPCM evidence
cannot promote both owner roles.

In particular, a rater-owned slope may be described as rater-indexed
conditional discrimination only within the fitted model. Calling it rater
consistency, reliability, competence, or absence of random error requires
separate recovery and attribution evidence against category-use, targeting,
interaction, multidimensional, and local-dependence alternatives.

## Complete package-native GPCM exit criteria

The bounded label remains required until all relevant parts of the following
contract are implemented and validated:

- slopes can be specified, estimated, constrained, and reported independently
  of the step facet where identified;
- positive-slope, latent-scale, location, and step-profile constraints have a
  documented covariance and uncertainty basis;
- estimation, fixed-calibration scoring, diagnostics, information, category
  curves, exports, and replay consume the same general likelihood;
- unit-slope reductions recover PCM behavior and two-category reductions
  recover the intended binary model;
- score-side output has an explicitly named estimand and never relies on
  Rasch-family raw-score sufficiency when discrimination is free; and
- seeded recovery, stress, negative-identification, and matched external
  comparisons are retained as release evidence.

Until then, “bounded GPCM” is the correct public term.

## Current 0.2.2 bounded-GPCM surfaces

The 0.2.2 capability registry marks core fitting, fixed-calibration scoring,
information, and curve/category views as supported within the bounded design.
It marks the following as supported with caveats:

- exploratory residual and diagnostic follow-up;
- summary-table, casebook, weighting, model-choice, APA/QC, and export routes;
- fair-average and residual-bias review;
- linking synthesis;
- direct simulation specification and recovery review;
- design and population forecasting;
- diagnostic and signal-detection design screening;
- DFF/DIF screening;
- package-native scorefile export; and
- replayed optimization diagnostics.

The exported DFF/DIF path in this release is `analyze_dff()` /
`analyze_dif()` plus its documented tables, reports, and plots. Refit rows are
exploratory conditional screens and do not receive ETS classes, formal
inference eligibility, or primary-reporting eligibility.

The package does not currently advertise free latent population-SD fitting,
configurable-prior EAP sensitivity, moderation-specific DFF/DIF APIs, or
public model-family/estimation-scope registries. Those ideas require separate
implementation, documentation, tests, and release review in a later version.

### FACETS output-contract score-side review

Capability status: `blocked`.

`facets_output_contract_review()` remains blocked for bounded GPCM. The
package-native scorefile route may be used only with its caveat columns and
must not be described as FACETS score-side numerical equivalence.

Evidence already present for 0.2.2:

- the observation-level expected-score estimand is named separately from
  Rasch-family measure-to-score semantics;
- bounded-GPCM score-side standard errors use the corrected delta factor
  `ScoreSlope * Var * ScoreSideLogitSE`; and
- unit-slope and focused score-side checks guard the implemented bounded route.

Evidence required before any status promotion:

- define the remaining FACETS-compatible uncertainty and transformation
  contract for each claimed overlap surface;
- add matched external fixtures that can be reproduced without redistributing
  proprietary software or case-level private data;
- retain negative tests for unsupported score-side designs; and
- keep sensitivity-model output separate from operational scoring claims.

Promotion must be row-specific. Partial scorefile support does not unblock a
full FACETS output-contract review.

### Posterior-predictive and Bayesian workflows

Capability status: `deferred`.

Current marginal, pairwise, Q3-style, residual, and category-support results
are exploratory diagnostics. Naming a discrepancy is not posterior-predictive
computation.

Evidence required before any status promotion:

- define replicated-data discrepancy measures and their conditioning sets;
- include Q3-style local-dependence and residual-PCA discrepancies without
  treating fixed heuristics as calibrated critical values;
- review false-positive and sensitivity behavior outside CRAN-time tests;
- document priors, constraints, diagnostics, and generated quantities for any
  optional Bayesian backend; and
- verify overlapping likelihoods and reductions against the native bounded
  route.

Posterior-predictive output must remain separate from automatic pass/fail QC.

## Caveated design, DFF/DIF, and linking evidence

Design evaluation and forecasting should state slope regime, category support,
sample size, and linkage conditions before performance metrics. Stronger
wording requires replicated ADEMP-style cells across sparse/common-link
designs and slope regimes.

DFF/DIF support remains direct slope-aware screening. Stronger subgroup claims
require null and non-null fixtures, severity and range-restriction effects,
group imbalance, sparse links, and matched external checks. A screen-positive
row is not by itself a fairness, invariance, or bias conclusion.

For 0.2.3, subgroup refits replay the baseline response family, resolved rating
range, step/slope facets, weighting, optimizer, MML engine, and numerical
controls; the non-target anchors are the intentional linking change. Active
latent regression, facet interactions, and group-anchor constraints fail closed
until their subgroup linking contracts are implemented. `min_obs` remains a
cell-computability guard, not a universal sample-size or power rule. This
model-identity guard does not promote the refit contrast beyond screening.

`build_linking_review()` is an exploratory index over direct anchor, drift, or
chain evidence. Stronger operational wording requires a fixed calibration
identity contract and examples separating sparse-link design problems from
fitted-model recovery failures.

## Relationship to later releases

The 0.2.3 work package owns calibrated MML joint-stationarity, recovery, and
matched ConQuest/FACETS evidence for the existing overlap scope. Operational
calibration follows in 0.2.4, and multiple observed scales follow in 0.2.5.
Unrestricted GPCM, multidimensional traits, posterior-predictive computation,
and heavy backends remain 0.3-or-later research programs unless the root
roadmap is explicitly revised.

Within 0.2.3, the next gate-specification revision should either split the
current bounded-GPCM evidence into criterion-aligned and rater-aligned strata
or keep the untested owner role explicitly caveated/unsupported. Decoupled
slope and step owners, multiplicative criterion-by-rater slopes, rater-by-
criterion severity interactions, centrality/extremity response-style models,
and local-dependence rater models remain separate later-family or alternative-
model proposals; none is implied by completing the aligned route.

When a capability changes, update the implementation, capability registry,
runtime guard coverage, help, tests, release evidence, and this supplement in
the same change. A planning sentence alone never changes support status.
