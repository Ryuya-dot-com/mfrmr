# Post-0.2.2 bounded GPCM and adjacent roadmap

This note tracks bounded-`GPCM` work that remains caveated, blocked, or
deferred after the 0.2.2 release boundary, plus adjacent model-family,
estimation, diagnostic, documentation, and submission-readiness work that
should not be mixed into the 0.2.2 release scope. It is a maintenance roadmap,
not a public support promise. The current public contract remains
`gpcm_capability_matrix()`, `mfrmr_model_family_scope()`, and
`mfrmr_estimation_scope()`.

The 2026-07-05 consolidation folded the temporary `ROADMAP_20260705.md`
planning note into this roadmap. Items that were release-blocking for 0.2.2
but have since been fixed in the working tree are not kept as open roadmap
items here; the remaining entries describe post-0.2.2 work or calendar-bound
submission preparation.

## Current release boundary

0.2.2 supports bounded `GPCM` fitting, core summaries, fixed-calibration
posterior scoring, information, curve/category views, direct simulation-spec
generation, direct parameter-recovery checks, summary-table appendix routing,
fair-average review, residual-bias screening, package-native scorefile export,
report/QC bundles, linking synthesis, role-based design forecasting, and
diagnostic/signal-detection design screening within the caveats documented in
the help pages. It also carries the current score-side expected-score SE
estimand artifact, seeded score-side smoke evidence, DIF/DFF APA reporting
boundary checks, and the opt-in bounded-`GPCM` free population-SD MML path.

The bounded route still requires an explicit step facet and the current
`slope_facet == step_facet` contract. Direct recovery evidence is not design
operating-characteristic evidence, and exploratory diagnostic screens are not
standalone fairness or validity decisions.

Every blocked or deferred capability row is tracked in
`gpcm_runtime_guard_coverage()`. Rows with public helper surfaces must stop
with `mfrmr_gpcm_scope_error`; rows without a public runtime surface are
marked `roadmap_only`. Caveated rows are not guard rows, but this roadmap
still records the evidence needed before their wording can become stronger.
This roadmap should stay aligned with that coverage table and
`gpcm_capability_matrix()`.

## What would count as a complete package-native GPCM route?

In Muraki's formulation, the generalized partial credit model is the PCM with
varying slope parameters. For `mfrmr`, a complete package-native `GPCM` route
would therefore mean more than estimating one bounded slope table. It would
require all of the following to be implemented and validated:

- **General slope design**: slopes can be specified, estimated, constrained,
  and reported independently of the step facet. This includes
  `slope_facet != step_facet`, item-level slopes, facet-level slopes,
  slope-by-design-term structures where identifiable, equality constraints,
  fixed slopes, unit-slope `PCM` reduction, rating-scale `RSM` reduction, and
  two-category `2PL` reduction.
- **Identification and covariance basis**: positive slopes, latent-scale
  anchoring, step-profile constraints, threshold/location parameterization,
  Hessian/observed-information covariance, and standard-error propagation are
  all defined for the general slope design rather than only for the current
  geometric-mean-one `slope_facet == step_facet` case.
- **Estimation engine coverage**: MML estimation, convergence diagnostics,
  missing-category handling, sparse support warnings, fixed-calibration
  scoring, and optional JML or heavy-backend routes all use the same general
  GPCM likelihood. If posterior predictive or MCMC routes are advertised, they
  must be computed from that same likelihood rather than named as placeholders.
- **Many-facet design integration**: the role-based MFRM interface can express
  which facets enter the additive location component and which terms carry
  discrimination, without silently changing the score metric or reusing
  Rasch-family sufficiency assumptions.
- **Downstream helper closure**: information, expected scores, residuals,
  category curves, fair averages, bias/DFF/DIF screens, design simulations,
  recovery summaries, APA/QC/export bundles, and plot payloads either fully
  consume the general slope design or explicitly stop with a synchronized
  capability-matrix row.
- **Score-side contract**: complete `GPCM` support would not imply
  FACETS-style raw-score-to-measure equivalence, because free discrimination
  breaks raw-score sufficiency. It would require a general, explicitly named
  score-side estimand and uncertainty contract for slope-aware expected-score
  outputs, plus reduction tests showing that unit slopes recover the
  Rasch-family score-side behavior.
- **External and simulation evidence**: common-data comparisons against
  established GPCM implementations where parameterizations can be matched,
  seeded recovery and stress simulations, coverage/uncertainty checks, and
  negative tests for unidentified or unsupported slope structures are retained
  as release evidence.

Until those conditions are met, the correct label is bounded `GPCM`, not
complete unrestricted `GPCM`.

## Adjacent model-family boundary

The complete-`GPCM` maintenance plan must not silently absorb other polytomous,
rater-process, unfolding, or mixture models. The public helper
`mfrmr_model_family_scope()` records these lanes explicitly:

- **Current ordered-response scope**: `RSM`, `PCM`, and bounded `GPCM`.
- **GPCM completion**: unrestricted slope designs, covariance, score-side,
  and downstream-helper closure inside Muraki's adjacent-category family.
- **Alternative polytomous IRT**: Samejima-style graded response,
  Bock-style nominal response, and sequential / continuation-ratio models.
  These require distinct likelihood and response-process contracts.
- **Rater-dependence and latent-process models**: hierarchical rater models,
  latent-class / signal-detection rater models, rater bundle models, and
  model-estimated interaction/bias extensions. Current diagnostics and
  signal-detection simulations are not substitutes for these estimators.
- **Unfolding and ideal-point models**: hyperbolic-cosine and GGUM-style
  response functions are non-monotone/ideal-point models, not GPCM variants.
- **Rasch-family design-matrix extensions**: MRCMLM, LLTM, and LPCM are
  plausible architecture candidates, but they need a general design-matrix
  parameterization before being presented as supported.
- **Mixture / mixed Rasch models**: latent-class heterogeneity remains outside
  the current mixture-free package scope.

## Adjacent estimation and backend boundary

The complete-`GPCM` plan also must not silently absorb estimation-method work.
The public helper `mfrmr_estimation_scope()` records these lanes explicitly:

- **Current package-native likelihood**: `JMLE` and `MMLE` remain the current
  supported estimator surface, subject to the bounded-`GPCM` caveats recorded
  in `gpcm_capability_matrix()`.
- **CMLE**: conditional maximum likelihood is a plausible post-0.2.2 estimator
  for Rasch-family `RSM`/`PCM` because it can condition on sufficient raw
  scores. It is not the first route for complete free-slope `GPCM`, where
  those sufficiency conditions do not carry over in the same way.
- **PMLE / pairwise-composite likelihood**: this is a later sparse-design or
  large-design route after the conditional likelihood target has been scoped,
  with its own composite-score and standard-error semantics.
- **WLE / MAP / EAP scoring**: these are person/facet scoring refinements, not
  response-model families.
- **Free normal population SD for additive MML**: this is now implemented as
  an opt-in additive `RSM`/`PCM` and bounded-`GPCM` MML route under EM
  (`estimate_population_sd = TRUE`). It estimates the normal latent SD in the
  fitting likelihood, preserves the fixed-SD default for backward
  compatibility, records conditional/profile-like SE/CI fields with wording
  that other fitted parameters are held fixed, and counts sigma in AIC/BIC.
  Latent-regression, model-estimated facet-interaction, and direct/hybrid
  free-SD paths still require separate estimator contracts; full joint SEs are
  a later task.
- **Configurable EAP / reference prior**: this is useful for scoring
  sensitivity, sparse-person scoring, and policy-relevant reference
  populations, but it changes EAPs, posterior SDs, intervals, and
  plausible-value-style draws. The first implemented step is
  `analyze_eap_power_sensitivity()`, which power-scales the existing
  quadrature-grid prior and likelihood under the fixed calibration and reports
  EAP deltas from the unscaled reference. Arbitrary prior families and any
  change to the fitting prior in `fit_mfrm(method = "MML")` still require a
  separate calibration contract.
- **Unified structural/person SE contract**: MML non-person structural SEs,
  MML person posterior SDs, and JML observation-information SEs have different
  conditioning targets. Do not collapse them into one SE claim until a table
  records the estimand, conditioning basis, whether calibration uncertainty is
  included, and the recommended reporting use.
- **Stan / `cmdstanr` backend**: Stan belongs in the optional heavy-backend
  lane for Bayesian sensitivity analyses, hierarchical rater extensions,
  posterior uncertainty, and posterior-predictive checks. It should begin as
  a validation and extension bridge with explicit priors, constraints,
  diagnostics, generated quantities, and equivalence tests against native
  `JMLE`/`MMLE` routes where models overlap.
- **Nonparametric latent distribution**: estimating a flexible or discrete
  latent distribution while keeping parametric item/facet response functions
  is an MML extension, not the same as a mixture model with class-specific
  item/facet parameters.
- **Nonparametric response-function diagnostics**: empirical or kernel-smoothed
  category curves should enter first as visualization and model-check evidence,
  not as operational scoring.
- **Mixture / mixed Rasch estimation**: latent classes with class-specific
  parameters require a separate likelihood, class-count, label-switching, and
  reporting contract.

Any future row promoted from this boundary into implementation should receive
a dedicated capability-matrix row, source-basis note, negative tests, and
release wording before it is advertised as supported.

## Consolidated post-0.2.2 priorities from the 2026-07-05 audit

The 2026-07-05 audit confirmed that the immediate 0.2.2 diagnostic-network and
anchor-review gaps were release-stabilization work, not new roadmap scope.
Those fixes are covered by the tests and validation artifacts for 0.2.2. The
remaining roadmap priorities are:

### Submission and packaging preparation

These are calendar-bound or packaging/documentation tasks, not model-family
work.

- Keep visible public repository activity accruing before JOSS submission.
  The local submission notes treated repository age/visible history as the
  highest-leverage JOSS risk because it cannot be compressed by more code.
- Record the CRAN release history and archive link in submission-facing
  materials at submission time.
- Resolve any literal placeholder text in `MFRM_JOSS/paper.md`, keep
  `CITATION.cff` synchronized with the submitted release, and cut an archival
  release tag / DOI for the version submitted.
- Re-run full pre-submission checks, win-builder, and reverse-dependency
  checks immediately before CRAN submission rather than relying on earlier
  0.2.2 stabilization logs.

### Model-family and diagnostic priorities

- Complete unrestricted `GPCM` remains the highest non-current model-family
  target. It is the package's own highest post-0.2.2 tier and the most concrete
  externally verifiable gap against packages that fit free discrimination GPCM
  routes.
- Extend model-estimated DFF/bias interaction terms to bounded or unrestricted
  `GPCM` only after the GPCM identification, covariance, and slope-design work
  lands. Until then, GPCM DFF/DIF support remains screening evidence.
- Add posterior-predictive follow-up diagnostics for strict marginal,
  pairwise, residual, and category-support checks. The current strict
  diagnostics remain exploratory screens until replicated-discrepancy
  computation exists.
- Consider an explicit `Pendant` / `IsLeaf` column in
  `mfrm_network_analysis()` node metrics. The 0.2.2 stress tests show that
  literal self-rater nodes are often leaf nodes rather than articulation
  points; exposing that label would reduce downstream misinterpretation.

### Estimation and uncertainty priorities

- Promote the unified SE / uncertainty-estimand contract above WLE and
  population-SE work in execution order. The package already computes multiple
  uncertainty quantities correctly, but the reporting contract should state the
  estimand, conditioning basis, calibration-uncertainty inclusion, and
  recommended use for each SE/SD/interval source.
- Add gradient-aware optimizer refinement for the native JMLE/MML BFGS route.
  The 0.2.2 convergence status labels plateau-large-gradient fits after the
  optimizer returns; a future opt-in route should use a gradient threshold to
  trigger tighter-refinement reruns rather than leaving this as a manual
  workflow.
- Add equating-constant options beyond simple mean offset in
  `build_equating_chain()`, such as mean-sigma scaling or robust/trimmed
  offsets, before making stronger multi-wave equating claims.
- Treat omnibus subgroup parameter-invariance tests as research-only unless a
  reviewer asks for them by name. They are distinct from the existing
  element-level DIF/DFF screens but overlap with the same validity argument.

### User-facing adoption and code consistency

- Add a plain-language conceptual vignette or README section before the
  procedural workflow: what a many-facet Rasch model is, what a facet means,
  how RSM/PCM/GPCM differ, and how to read logits, fit statistics, and Wright
  maps.
- Update or retire the cheatsheet if it still reflects an older workflow and
  does not point users toward `mfrm_results()` / `mfrm_report()` as the current
  first-screen route.
- Group the `fit_mfrm()` help arguments into essential, design/
  identification, and advanced-estimation sections, or provide a narrower
  quick-start wrapper.
- Add a short glossary for recurring terms such as logit, Infit/Outfit, ZSTD,
  separation/reliability/strata, EAP/MAP/MLE, Wright map, anchor, DIF, and DFF.
- Finish adopting the plot `preset=` system for remaining hardcoded-color
  plotting helpers and add a `facets=` filter to `facet_statistics_report()`
  for consistency with the other facet-filtered report and network helpers.

## Roadmap work packages

### GPCM score-side export contract

Capability rows:

- `FACETS output-contract score-side review` (`blocked`)
- `Score-side scorefile export under bounded GPCM`
  (`supported_with_caveat`; keep FACETS-equivalence wording out of scope)
- `APA writer and fit-based export bundles` (`supported_with_caveat`; keep
  operational wording constrained by this score-side contract)

Surface to keep blocked until the full contract is validated:

- `facets_output_contract_review()`

Caveated surfaces that must continue to carry `gpcm_boundary` until the
score-side contract is validated:

- `facets_output_file_bundle(include = "score")`
- `build_apa_outputs()`
- `build_visual_summaries()`
- `run_qc_pipeline()`
- `build_mfrm_manifest()`
- `build_mfrm_replay_script()`
- `export_mfrm_bundle()`

Required evidence before unblocking:

- Estimand and uncertainty design: see
  `gpcm-score-side-estimand-0.2.2.md`, which names the observation-level
  estimand, records the raw-score non-sufficiency argument, and specifies
  the corrected score-scale delta factor (`dE/dtheta = a * Var`) for the
  score-side SE route.
- Status 2026-06-13: the package-native scorefile route now computes
  bounded-`GPCM` `ScoreSideSE` on the expected-score scale with
  `ScoreSlope * Var * eta_se`; the full FACETS output-contract score-side
  review remains blocked until the remaining review-contract exit criteria
  below are satisfied.
- Companion verification script:
  `gpcm-score-side-simulation-0.2.2.R` performs independent kernel identity
  checks and a Monte Carlo comparison of legacy versus corrected score-side
  SEs. Its default output goes to `validation-results/`; only adequately
  replicated evidence runs should be written into `inst/validation`.
- Keep `gpcm_score_side_contract()` synchronized with this roadmap and
  `gpcm_runtime_guard_coverage()`.
- Define the bounded-`GPCM` score-side estimand separately from Rasch-family
  measure-to-score semantics.
- Keep native structural expected-score SEs and selectable score-side delta
  SEs in the scorefile route synchronized with the MML diagnostics contract,
  and separately define the FACETS-compatible uncertainty contract needed for
  full output-contract review.
- Preserve unit-slope `GPCM` reduction tests against the `PCM` route.
- Add negative tests that fail if unsupported score-side rows are silently
  emitted.
- Add release-note wording that keeps sensitivity-model output separate from
  operational scoring claims.

Exit criteria:

- `gpcm_capability_matrix()` can move exactly scoped score-side rows from
  `blocked` to `supported_with_caveat` or `supported`.
- Export bundles identify unsupported sections explicitly when partial support
  remains.

### GPCM design operating characteristics and forecasting

Capability rows:

- `Design evaluation and population forecasting under bounded GPCM`
  (`supported_with_caveat`)
- `Diagnostic and signal-detection design screening under bounded GPCM`
  (`supported_with_caveat`)
- `Differential facet functioning screening under bounded GPCM`
  (`supported_with_caveat`)

Surfaces available as bounded-`GPCM` sensitivity evidence:

- `evaluate_mfrm_design()`
- `predict_mfrm_population()`
- `evaluate_mfrm_diagnostic_screening()`
- `evaluate_mfrm_signal_detection()`
- `analyze_dff()` / `analyze_dif()`
- `analyze_dff_moderation()` / `analyze_dif_moderation()`
- `dif_interaction_table()`
- `dif_report()`
- `plot_dif_heatmap()` / `plot_dif_summary()`

These helpers are available only for the current role-based design layer and
only when the requested design matches the bounded slope structure carried by
the simulation specification. They report design-level sensitivity evidence
and slope-aware operating-characteristic readouts, not direct posterior
scoring for observed units, calibrated inferential tests, operational scoring
or screening adequacy, or full arbitrary-facet planning.

DFF/DIF helpers are available as direct slope-aware screening and reporting
surfaces. Their `gpcm_boundary` rows must remain visible, and DFF wording must
not imply fairness, invariance, or operational subgroup-decision evidence
without external study-design support.

The initial Mantel-Haenszel DIF surface is tracked separately in
`inst/references/mh-dif-r-package-alignment.md`. That note records the
current boundary against the `difR`, `lordif`, and `mirt` help-page surfaces:
native `mfrmr` support is currently limited to a strict two-group
Mantel-Haenszel observed-score screen, while generalized MH, logistic/ordinal
DIF, purification, SIBTEST, and multiple-group IRT parameter tests remain
validation tasks.

Required evidence before unblocking:

- Preserve the separation between direct parameter-recovery checks and design
  operating characteristics in ADEMP terms.
- Validate bounded-`GPCM` data-generating conditions across slope regimes,
  sparse linkage patterns, sample sizes, and score-support stress.
- Define which performance measures are release gates and which are
  diagnostic-only summaries.
- Extend diagnostic-screening and signal-detection evidence across larger
  slope regimes, sparse linkage patterns, sample sizes, and score-support
  stress before using the readouts as stronger screening recommendations.
- Add subgroup DFF fixtures and simulation operating-characteristic evidence
  before using DFF rows as fairness, invariance, or bias claims.
- Add cross-package agreement checks against `difR` before expanding the
  Mantel-Haenszel route, and add separate `lordif` / `mirt`
  comparison fixtures before advertising logistic, ordinal, or IRT parameter
  DIF claims.
- Keep CRAN-time tests lightweight while storing longer design evidence under
  `inst/validation`.

Exit criteria:

- Design summaries report bounded-`GPCM` slope-regime and score-support
  conditions before performance metrics.
- Forecasting output does not imply direct posterior scoring for observed
  units or operational adequacy of a sensitivity model.
- Diagnostic-screening and signal-detection helpers remain
  `supported_with_caveat` until larger slope-aware operating-characteristic
  evidence is stored and linked from the capability matrix.
- DFF helpers retain `gpcm_boundary` in summaries, reports, and plot payloads
  until larger subgroup and external-fixture evidence is available.

### GPCM linking synthesis

Capability row:

- `Operational linking synthesis` (`supported_with_caveat`)

Surface available as bounded-`GPCM` exploratory synthesis:

- `build_linking_review()`

Required evidence before stronger operational wording:

- Define how anchor, drift, and chain evidence should behave when
  discrimination is free.
- Keep direct anchor/drift helpers available as exploratory inputs and keep
  `gpcm_boundary` visible on the combined review.
- Add examples that distinguish sparse-link design problems from fitted-model
  recovery failures.

Exit criteria:

- A bounded-`GPCM` linking review reports its assumptions and caveats before
  any combined decision or route recommendation.

### GPCM posterior predictive checks

Capability row:

- `MCMC and heavy-backend extensions` (`deferred`) for posterior predictive
  computation in the current matrix wording.

Required evidence before unblocking:

- Define bounded-`GPCM` posterior predictive discrepancy measures for marginal,
  pairwise, residual, and category-support checks.
- Document the replication mechanism and the conditioning set used for each
  check.
- Run false-positive and sensitivity reviews outside CRAN-time tests.
- Keep current strict marginal diagnostics labelled as exploratory screens
  until posterior predictive computation exists.

Exit criteria:

- Posterior predictive tables and plots are computed rather than merely named,
  and their interpretation remains separate from automatic pass/fail QC.

### GPCM engine and model-structure extensions

Capability row:

- `MCMC and heavy-backend extensions` (`deferred`)

Potential future scope:

- `slope_facet != step_facet`
- latent-regression bounded `GPCM`
- multidimensional population models
- MCMC or HMC engines
- compiled backend promotion where it changes runtime feasibility rather than
  the statistical contract

Required evidence before unblocking:

- Identification and covariance-basis tests for every additional model
  structure.
- Reduction tests for the unit-slope and constrained-step cases.
- User-facing documentation that separates the core package route from optional
  heavy-backend routes.

Exit criteria:

- New engine or model structures have explicit capability-matrix rows instead
  of silently broadening the current bounded route.
