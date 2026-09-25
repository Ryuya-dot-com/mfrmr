# Bounded-GPCM technical evidence supplement after 0.2.2

Status: subordinate validation supplement, reviewed 2026-07-26; model-family
refinement added 2026-08-08; blanket exit rule superseded 2026-09-24.

The repository-root `ROADMAP.md` controls release sequencing. This file only
records technical exit criteria for bounded-GPCM capability rows that remain
caveated, blocked, or deferred. It must not be read as a list of current API
functions or as authorization to broaden a release. The dated 0.2.2/0.2.3
sections below retain historical contracts and evidence, not current version
allocations or an exhaustive description of 0.2.4 capabilities.

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

## Separate GPCM exit decisions, revised September 24

The earlier requirement to keep the word bounded until every model, scoring
and inference extension was complete is superseded. Follow the public
[GPCM stages](../../ROADMAP.md#gpcm-specific-restrictions-and-their-exit-conditions)
and the [active execution plan](internal-roadmap-0.2.3.md#current-execution-order-2026-09-24).
Name the current model and the restriction on the requested operation; a more
precise label does not promote its statistical status.

Before 0.2.4 submission, reconcile the API/help vocabulary and decide the
inferential scope of the existing aligned single-owner MML model. Existing
derivatives and joint covariance are reusable numerical evidence; the current
free-slope boundary-readiness rule and inference guards remain until the named
claim is justified. JML, slope-owner roles and latent-population specifications
retain distinct evidence. Neither extra optimizer iterations nor a matching
external point estimate resolves that decision.

After that decision, separate slope and step facets are the first structural
GPCM extension to assess. Required evidence includes identifiable designs,
positive-slope and scale constraints, current-model and unit-slope reductions,
probabilities/derivatives, parameter mapping and the admitted uncertainty and
downstream workflows. Portable calibration is a separate lifecycle extension;
simultaneous slope families and multidimensional traits are separate models.
MCMC and FACETS-equivalent outputs are not prerequisites for the preceding
decisions. Existing restrictions remain visible for unqualified operations,
and every score-side output must retain its actual estimand rather than borrow
Rasch raw-score sufficiency. Matched external calculations are evidence for a
specific mathematical question, not a requirement of software-wide parity.

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

## Historical release allocation and owner evidence

The old sequence (0.2.3 numerical validation, 0.2.4 calibration, 0.2.5 multiple
scales, 0.3-or-later unrestricted GPCM) is superseded by the public roadmap.
It does not delay the current-model inference decision or separate slope/step
roles until multi-scale or multidimensional work. The owner-specific records
below remain historical evidence with their original limitations; their
instructions to start a particular pilot do not replace the active work plan.

Within 0.2.3, the next gate-specification revision should either split the
current bounded-GPCM evidence into criterion-aligned and rater-aligned strata
or keep the untested owner role explicitly caveated/unsupported. Decoupled
slope and step owners, multiplicative criterion-by-rater slopes, rater-by-
criterion severity interactions, centrality/extremity response-style models,
and local-dependence rater models remain separate later-family or alternative-
model proposals; none is implied by completing the aligned route.

That split is now explicit, but P1q shows that its completed Draft.66 MML
pilot is historical fixed-standard-normal evidence, not evidence for the
current `free_population` default. The sealed rows/checkpoints remain valid;
a derived envelope repairs missing aggregate identity without changing their
meaning. Before any further owner replication, a prospective contract must
state the identification branch and exact category support in every manifest,
result, checkpoint, aggregate, and replay. A small paired common-data smoke is
the next admissible empirical step; broad simulation remains downstream of a
decision-relevant need.

P1r now fixes that smoke prospectively as two source-owner datasets crossed
with two fitted owners and JML/current-default MML, for eight routes. It binds
explicit 1--4 support, scale, runtime, content-hash, pairing, and 13-surface
propagation requirements before any fit. Passing this contract does not pass
the owner gate.

P1s now completes the admitted eight-route execution: every fit returns, every
route identity check passes, and all 12 required surfaces retain the full
current-default identity. A recycled-vector warning in nonlinear estimability
classification was corrected before the admitted v3. The result deliberately
does not pass the owner gate: all eight fits remain `review`, zero are
inference ready, and two retain terminal-gradient review. Repetition or broad
simulation is not the next step. Estimator-specific nonlinear estimability,
boundary completeness, and numerical stability must be resolved before
freezing recovery, uncertainty, fit, DFF, or owner-comparison rules.

When a capability changes, update the implementation, capability registry,
runtime guard coverage, help, tests, release evidence, and this supplement in
the same change. A planning sentence alone never changes support status.
