# Maintenance and Roadmap Checklist

Date: 2026-04-03
Package baseline: `mfrmr` 0.1.5

Companion document:
See `inst/references/MFRMR_MASTER_PLAN_2026-04-03.md` for the refined final
goal, non-goals, milestone logic, prompt templates, and stop rules.
See `inst/references/M1_AUDIT_FACETS_CONQUEST_THEORY_PERFORMANCE_2026-04-03.md`
for the current official-doc, theory, and performance audit snapshot.
See `inst/references/MFRMR_EXECUTION_PROTOCOL_2026-04-03.md` for the
operational rules that classify features, define evidence thresholds, and fix
the M1 execution queue.
See `inst/references/M1_PLANNING_BENCHMARK_2026-04-03.md` for the current
lightweight benchmark entrypoint and interpretation rules.
See `inst/references/M2_LATENT_REGRESSION_BENCHMARK_2026-04-03.md` for the
current latent-regression benchmark entrypoint and interpretation rules.
See `inst/references/M2_LATENT_REGRESSION_IMPLEMENTATION_STATUS_2026-04-10.md`
for the current implemented/not-yet-implemented latent-regression boundary and
beginner-facing follow-up checklist.
See `inst/references/M2_CONQUEST_OVERLAP_BOUNDARY_2026-04-03.md` for the
current claim-control boundary against the ConQuest feature set.
See `inst/references/M3_TAM_SIRT_MIRT_ECOSYSTEM_AUDIT_2026-04-04.md` for the
open-source comparator matrix against TAM, sirt, and mirt.
See `inst/references/M3_ECOSYSTEM_COVERAGE_PLAN_2026-04-04.md` for the
post-M2 coverage queue and differentiation plan.
See `inst/references/M3_GPCM_SPEC_2026-04-04.md` for the current
first-release `GPCM` target, seam audit, and post-fit boundary.
See `inst/references/M3_GPCM_CONSISTENCY_AUDIT_2026-04-04.md` for the
post-fit consistency sweep that separates active `GPCM` support from
explicitly blocked downstream paths.
See `inst/references/M3_GPCM_RECOVERY_BENCHMARK_2026-04-04.md` for the
current narrow synthetic recovery benchmark and interpretation rules for the
first-release `GPCM` branch.
See `inst/references/M3_EXPANSION_FEASIBILITY_AUDIT_2026-04-04.md` for the
adjacent-expansion triage covering interactive visualization, count and
continuous data, Uto-style generalized drift models, multidimensional
extensions, and Mokken-scale scope control.
See `inst/references/M3_PRIORITY_EXECUTION_QUEUE_2026-04-04.md` for the
current post-audit execution order and stop/go gates.

## Scope

This checklist records the execution plan for two linked goals:

1. restore a clean package-quality baseline after the 0.1.4 release; and
2. expand `mfrmr` toward the feature envelope covered by ConQuest and FACETS
   without relying on Stan.
3. expand `mfrmr` toward the relevant open-source comparator envelope
   represented by TAM, sirt, and mirt without abandoning the package's
   many-facet-first workflow strengths.

The plan is intentionally phased. Package-quality fixes come first, because
feature work should start only after `R CMD check` is back to a stable
baseline.

## Current check baseline

- [x] Reproduce the current `R CMD check --as-cran` result on the live source.
- [x] Confirm that the package-specific blocking error is the Dropbox
      conflict-copy Rd file under `man/`.
- [x] Confirm that the old `--run-donttest` example error in the stale
      `.Rcheck` directory no longer reproduces on the current source.
- [x] Confirm a post-fix 0.1.5 `R CMD check --as-cran` baseline outside the
      Dropbox workspace, with only non-package notes remaining.
- [x] Re-evaluate the remaining notes after the 0.1.5 check.

## Phase 0: package-quality fixes

- [x] Add this checklist to the repository as the execution baseline.
- [x] Remove the conflict-copy Rd file from `man/`.
- [x] Add a defensive `.Rbuildignore` rule for the same Dropbox-style Rd
      artifact pattern.
- [x] Bump `DESCRIPTION` from 0.1.4 to 0.1.5.
- [x] Record the maintenance release rationale in `NEWS.md`.
- [x] Run `R CMD build`.
- [x] Run `R CMD check --as-cran`.
- [x] Archive the exact check outcome in the working notes.

## Phase 1: finish generalizing the existing Rasch-family workflow

Goal: remove helper-layer restrictions that lag behind the package's existing
arbitrary-facet estimation core.

- [x] Generalize `extract_mfrm_sim_spec()` beyond the hard-coded
      `Rater` / `Criterion` assumption for fit-derived two-facet workflows.
- [x] Generalize `simulate_mfrm_data()` so fit-derived `step_facet` handling is
      no longer limited to the literal names `Criterion` or `Rater`.
- [x] Extend `compute_information()` to support `PCM` fits.
- [x] Expand `predict_mfrm_units()` and
      `sample_mfrm_plausible_values()` beyond current `MML`-only scoring.
- [x] Audit whether any automatic nesting relation beyond the current
      `RSM`-in-`PCM` check is truly defensible on a shared likelihood basis;
      current conclusion: no additional automatic relation is warranted in the
      present model space, so the restriction should remain and be documented.
- [x] Add explicit binary-response examples and tests documenting that binary
      data are already supported as ordered two-category responses.
- [x] Add public design-variable aliases for custom two-facet planning
      workflows so plots and recommendations can accept role-aware names
      without breaking the existing internal design-grid schema.

## Phase 2: population-model extensions

Goal: add the highest-leverage ConQuest-style extensions that fit naturally on
top of the current `MML` implementation.

Planning references:

- `inst/references/M2_LATENT_REGRESSION_READINESS_AUDIT_2026-04-03.md`
- `inst/references/M2_LATENT_REGRESSION_MASTER_PLAN_2026-04-03.md`
- `inst/references/M2_LATENT_REGRESSION_STATISTICAL_SPEC_2026-04-03.md`

- [x] Add `fit_mfrm()` API/data-contract scaffolding for latent regression,
      including `population_formula`, person-level covariate validation, and
      an explicit not-yet-implemented stop path.
- [x] Propagate the inactive `population` scaffold through fit summary,
      config metadata, and replay-script metadata so the posterior basis is
      explicit even before latent-regression estimation is implemented.
- [x] Add internal population-aware quadrature/config plumbing so the current
      `MML` path can later accept person-specific nodes without silently
      changing ordinary fits.
- [x] Extend the latent-regression scaffold to track included/omitted persons
      and response rows under complete-case policies.
- [x] Complete the latent-regression fit-object contract for active
      population-model fits and extend replay/export beyond the current
      inactive scaffold.
- [x] Implement a first-version latent-regression estimation branch without introducing
      Stan.
- [x] Add population-model-aware posterior scoring and approximate plausible
      values for active latent-regression fits while preserving the legacy
      fixed-calibration path for ordinary `MML` / `JML` scoring.
- [x] Add simulation and prediction helpers for latent-regression scenarios.
- [x] Add recovery studies and regression-specific tests.
- [x] Broaden the first-version covariate contract from numeric-only source
      columns to `stats::model.matrix()`-compatible person-level covariates,
      including numeric, logical, factor, ordered-factor, and character
      predictors.
- [x] Preserve categorical `xlevels` and contrast provenance across fitting,
      scoring, plausible-value sampling, simulation specs, fit-derived
      simulation extraction, replay/export metadata, manifests, and reference
      benchmark summaries.
- [x] Add a package-native ConQuest-overlap dry-run benchmark harness for the
      implemented `RSM` / `PCM` latent-regression branch via
      `reference_case_benchmark(cases = "synthetic_conquest_overlap_dry_run")`.
      This checks the bundle/normalization/audit contract without claiming that
      ConQuest itself was executed.
- [ ] Run a true external ConQuest reference case against the exported overlap
      bundle and compare extracted ConQuest tables with `audit_conquest_overlap()`,
      separating numerical agreement from broader ConQuest feature parity.
- [ ] Add or retain benchmark fixtures that cover the remaining edge cases:
      actual external ConQuest extracted tables. The current harness already
      covers the continuous numeric covariate route, complete-case omission via
      `synthetic_latent_regression_omit`, and the deliberately unsupported
      ConQuest-overlap export case for model-matrix-expanded categorical
      covariates.
- [x] Add a beginner-facing latent-regression checklist to the README and/or a
      vignette: required columns, recommended `method = "MML"`, how to pass
      `person_data`, how `population_policy` works, and how to read the fitted
      population component. Current completion: README and `fit_mfrm()` help
      quick-start path; a longer vignette can remain optional.
- [x] Strengthen `summary(fit)` for active latent-regression fits so the
      printed output leads with model status, posterior basis, covariates,
      categorical coding, omitted persons/rows, zero-count category caveats,
      and the recommended next helper.
- [x] Add a compact coefficient-reporting table for latent-regression fits,
      with estimate, scale, residual variance, coding notes, and a clear
      warning that coefficients are population-model parameters rather than
      post hoc regressions on EAP/MLE scores. Current completion:
      `summary(fit)$population_coefficients`, `summary(fit)$population_coding`,
      and summary-table bundle methods-appendix roles.
- [x] Add manuscript-reporting guidance for latent regression: what to report
      in Methods, what to report in Results, how to phrase posterior scoring
      and plausible values, and which ConQuest-parity claims remain unsafe.
      Current completion: `reporting_checklist()` population-model rows and
      `build_apa_outputs()` population-model prose plus Table 5 note/caption
      text.
- [x] Add table-format guidance for beginners: population coefficients,
      population residual variance, omitted-person audit, posterior summaries,
      and category-usage caveats.
- [ ] Add plot-interpretation guidance after the model contract is fully
      benchmarked: coefficient plots, observed-vs-predicted person summaries,
      posterior/PV distributions, covariate-stratified latent distributions,
      and ConQuest-overlap audit plots.
- [x] Extend `reporting_checklist()` and summary-table bundles so active
      latent-regression fits surface the above manuscript/reporting tasks
      without forcing users to inspect nested object components manually.
- [x] Add help-page examples that use one continuous and one categorical
      covariate end-to-end, but keep them small enough for examples and avoid
      claiming full ConQuest parity.
- [ ] Re-run a full package check after the latent-regression documentation and
      beginner-facing summary changes land.

## Phase 3: new response-model families

Goal: expand beyond the current ordered-category Rasch scope in increasing
order of implementation proximity.

- [x] Add inactive `GPCM` API scaffolding and explicit not-yet-implemented
      guardrails so the future ordered-extension path is fixed without
      overstating support.
- [x] Fix a one-major-branch-at-a-time execution rule so `GPCM` remains the
      active primary branch until its stop/go gates are closed.
- [x] Add `GPCM` parameter/config scaffolding for `slope_facet`, including
      positive-slope identification on the log scale and explicit reduction
      metadata pointing back to `PCM` when all slopes equal 1.
- [x] Add internal `GPCM` probability / log-likelihood helpers and exact
      `PCM`-reduction regression tests while keeping the public fitting path
      disabled.
- [x] Evaluate `GPCM` as the first ordered-category extension beyond
      `RSM` / `PCM`.
- [x] Activate the narrow first-release `GPCM` fit path for `MML` / `JML`,
      core summaries, and fixed-calibration posterior scoring.
- [x] Extend `GPCM` support to the design-weighted information summary helper.
- [x] Extend `GPCM` support to fit-level Wright/pathway/CCC plots plus
      category curve/structure reports and graph-only output bundles where the
      generalized probability kernel is sufficient.
- [x] Extend `GPCM` support to direct simulation-spec generation and
      `simulate_mfrm_data()`, while rejecting planning/reporting paths
      explicitly where validation is not yet complete.
- [x] Extend the residual-based diagnostics stack to first-release `GPCM`
      where Muraki-style category probabilities and score information are
      sufficient, while keeping fair-average, bias-adjusted, and writer/QC
      workflows explicitly blocked.
- [x] Open `plot_qc_dashboard()` for first-release `GPCM` as a residual-based
      triage surface with an explicit unavailable fair-average panel, rather
      than routing users into a deeper fair-average stop.
- [x] Audit fair-average semantics against FACETS and keep score-side
      fair-average reporting blocked for first-release `GPCM` until a
      slope-aware adjusted-score contract is validated.
- [x] Add a shared `planning_scope` contract so simulation specs,
      design/signal planning objects, forecast objects, and summary/plot/
      recommendation surfaces all expose the current role-based planner
      boundary explicitly.
- [x] Add a shared `planning_constraints` contract so simulation specs and
      planning/forecasting outputs also expose which design variables remain
      mutable under resampled, skeleton, threshold-specific, or slope-specific
      simulation contracts.
- [x] Add a combined `planning_schema` contract so simulation specs and
      planning/forecasting outputs can carry the planner boundary, role
      descriptor, and current mutability map together.
- [x] Extend that planner metadata with a `facet_manifest` plus explicit
      future-branch markers so current two-role planning objects expose a
      machine-readable arbitrary-facet scaffold without overstating scope.
- [x] Add a schema-only `future_facet_table` and future input-contract marker
      so the arbitrary-facet branch has a stable facet-count schema before any
      broader planner is activated.
- [x] Let current planner entry points accept `design$facets(named counts)`
      for the currently exposed facet keys, while still translating into the
      existing two-role design contract.
- [x] Add a matching schema-only `future_design_template` so future-branch
      code can start from a machine-readable nested design stub instead of
      reconstructing it from the current two-role planner state.
- [x] Bundle the schema-only arbitrary-facet scaffold into a nested
      `future_branch_schema` so future code can read one stable contract
      rather than stitching together separate facet-table and design-template
      fields.
- [x] Route the current `design$facets(...)` normalizer through that nested
      `future_branch_schema`, so the future arbitrary-facet branch already has
      one authoritative schema-only parsing contract.
- [x] Add a dedicated nested `future_branch_schema$design_schema` object so
      branch-specific code can read one explicit design-schema contract rather
      than reconstructing axes and defaults from general metadata.
- [x] Add a schema-only internal grid builder that consumes that
      `future_branch_schema$design_schema` object and emits canonical/public/
      branch-facing design grids without activating arbitrary-facet planning
      semantics yet.
- [x] Attach a schema-only `future_branch_preview` contract so planning
      objects can expose the default nested branch grid whenever concrete
      default counts are available, while still marking preview as unavailable
      when only facet labels are known.
- [x] Attach a matching `future_branch_grid_semantics` contract so branch
      code can read canonical/public/branch-facing grid columns and the
      active feasibility rule from one schema-only object.
- [x] Attach a schema-only `future_branch_grid_contract` so branch code can
      read the default nested design, default branch grid, schema, and
      semantics from one materialized future-branch object.
- [x] Add a matching materializer helper so live planning objects, planning
      schemas, sim specs, and direct grid-contract objects all resolve the
      same schema-only future-branch grid through one contract path.
- [x] Add a branch-side `future_branch_grid_bundle` so future arbitrary-facet
      code can consume one internal object carrying the materialized grid plus
      the underlying contract, schema, and grid semantics.
- [x] Add matching bundle materializers and grid-view helpers so live planning
      objects, planning schemas, sim specs, and nested branch metadata all
      expose one branch-side path to canonical/public/branch grid views.
- [x] Add a matching future-branch grid-context helper so branch-side code can
      read varying/fixed design axes and fixed values from one schema-only
      object instead of recomputing them from raw canonical grids.
- [x] Embed that context into both `future_branch_schema` and
      `planning_schema` so preview/contract/bundle/context live in one stable
      future-branch object graph.
- [x] Add a schema-only branch summary helper and a deterministic baseline
      selection helper so the future-branch object graph has active internal
      consumers before arbitrary-facet planning logic is opened.
- [x] Add schema-only branch table and draw-free plot-payload helpers so the
      same future-branch object graph already supports branch-side table/plot
      contracts before arbitrary-facet planning is activated.
- [x] Add a schema-only branch report bundle so future-branch code can
      consume summary, baseline recommendation, table views, and draw-free
      plot payloads from one internal contract before arbitrary-facet
      planning is activated.
- [x] Add a schema-only branch report summary so future-branch code can read
      component availability and the baseline design id from one compact
      internal summary contract before arbitrary-facet planning is activated.
- [x] Add a schema-only branch report overview table so future-branch code
      can read compact metrics and axis-state summaries from one internal
      contract before arbitrary-facet planning is activated.
- [x] Add schema-only branch overview-view consumers so future-branch code
      can request `metrics`, `axes`, or `components` from one compact
      internal overview contract before arbitrary-facet planning is activated.
- [x] Add a schema-only branch report catalog so future-branch code can
      enumerate those overview surfaces from one internal contract before
      arbitrary-facet planning is activated.
- [x] Add a schema-only branch report digest so future-branch code can read
      baseline design metadata, available overview surfaces, and fixed/varying
      axis summaries from one internal contract before arbitrary-facet
      planning is activated.
- [x] Add a schema-only branch report-surface registry so future-branch code
      can request `digest`, `catalog`, and compact overview surfaces from one
      internal contract before arbitrary-facet planning is activated.
- [x] Add a schema-only branch report panel so future-branch code can consume
      one selected compact surface together with digest headline metadata and
      the shared surface index before arbitrary-facet planning is activated.
- [x] Add a schema-only branch report operation so future-branch code can
      consume digest, overview tables, the surface registry, and one selected
      compact surface from a single internal contract before arbitrary-facet
      planning is activated.
- [x] Add a lightweight schema-only branch report snapshot so future-branch
      code can consume compact headline metadata and one selected compact
      surface without carrying the deeper nested operation graph.
- [x] Add a selected-surface schema-only branch report brief so future-branch
      code can consume one headline table, one selected compact surface, and
      the surface index without carrying the broader snapshot payload.
- [x] Add a mode-based schema-only branch report consumer and mode registry so
      future-branch code can switch between `brief`, `snapshot`, and
      `operation` payloads from one dispatcher.
- [x] Add an internal schema-only branch pilot object so future-branch code
      can consume one materialized grid view, one draw-free plot payload, and
      one selected report consumer from one active scaffold.
- [x] Add compact pilot-level summary/table/plot consumers so future-branch
      code can read the active scaffold without unpacking the full pilot
      object.
- [x] Add a bundled schema-only active-branch object so future-branch code
      can consume pilot summary, selected table, and plot payload from one
      minimal active scaffold.
- [x] Add a deterministic active-branch design profile so future-branch code
      can read observation counts, expected rater load, and assignment density
      before any performance-based arbitrary-facet planner is activated.
- [x] Add metric-basis metadata to the active-branch profile so exact count
      identities are distinguished from balanced-load expectations and density
      ratios.
- [x] Add an active-branch overview contract so branch-side code can read one
      compact headline table plus metric registry and metric-summary output
      without unpacking the deeper deterministic profile object.
- [x] Add public-facing `summary()` and draw-free `plot()` methods for the
      future active-branch scaffold so deterministic arbitrary-facet planning
      state can be reviewed through one compact summary/table/plot surface
      before psychometric arbitrary-facet planning is opened.
- [x] Cache default-path schema-only branch subcontracts so the future
      active-branch summary/plot surface can be materialized without
      repeatedly rebuilding the same nested report objects.
- [x] Add deterministic active-branch load/balance diagnostics so branch-side
      code can separate balanced-load expectations from exact integer-balance
      summaries before any performance-based arbitrary-facet planner is
      activated.
- [x] Add deterministic active-branch coverage/connectivity diagnostics so
      branch-side code can read scored-cell counts, exact rater-pair overlap
      identities, and redundancy flags before any performance-based arbitrary-
      facet planner is activated.
- [x] Add deterministic active-branch guardrail classifications so branch-side
      code can read exact linking, pair-coverage, and integer-balance regimes
      before any performance-based arbitrary-facet planner is activated.
- [x] Add deterministic active-branch structural readiness summaries so
      branch-side code can read exact overlap and balance preconditions before
      any performance-based arbitrary-facet planner is activated.
- [x] Add a conservative active-branch structural recommendation so branch-
      side code can rank designs by exact structural tier and total
      observation count before any performance-based arbitrary-facet planner is
      activated.
- [ ] Strengthen the plausible-values workflow so it can be compared more
      credibly with the TAM / mirt scoring ecosystem.
- [ ] Design a nominal-response branch for true unordered multinomial data.
- [ ] Separate the nominal-response interface clearly from the existing ordered
      binary/polytomous interface.
- [x] Add synthetic recovery studies for the new response family.
- [ ] Define which model-comparison diagnostics remain valid across families.

## Phase 4: higher-complexity model families

Goal: postpone the largest design changes until the unidimensional and
Rasch-family roadmap is stable.

- [ ] Add between-item multidimensional support before within-item
      multidimensional support.
- [ ] Do not start multidimensional coding before first-release `GPCM` is
      closed and documented.
- [ ] Evaluate imported design-matrix or explanatory support for constrained /
      generalized models in a form that is defensible against TAM / mirt.
- [ ] Evaluate selected sirt-style rater slope / rater-item interaction
      extensions only after the generalized model layer is stable.
- [ ] Evaluate IRTree support only after the multidimensional design is in
      place.
- [ ] Evaluate FACETS-style count models (`binomial`, `Poisson`) after the
      nominal/generalized modeling layer is stable.
- [ ] Evaluate simplified non-Bayesian time-aware drift extensions only after
      the generalized ordered layer is stable; keep full Bayesian Uto-style
      dynamic models outside the current roadmap.

## Phase 5: strengthen `mfrmr`-specific workflow advantages

Goal: make `mfrmr` distinct even where TAM or mirt already cover adjacent
estimation territory.

- [ ] Continue the descriptor-first arbitrary-facet planning transition.
- [x] Replace duplicated canonical design-variable vectors in current
      planning summaries, recommendation helpers, and plot helpers with shared
      descriptor-driven grouping / ordering helpers.
- [ ] Expand QC, dashboards, and report bundles so they stay coherent across
      future model families.
- [ ] Strengthen linking / anchoring / drift workflow across broader model
      families.
- [ ] Evaluate whether an open-software overlap audit path should eventually
      extend beyond ConQuest-specific bundles where exact overlap is
      defensible.
- [ ] Evaluate an optional interactive 2D visualization layer built on
      `mfrm_plot_data` without making 3D or widget-first plotting a package
      dependency assumption.

## Validation rules

- [x] Keep package-native regression checks via `reference_case_benchmark()`.
- [x] Add an exact-overlap external-comparison bundle only for functionality
      that matches the documented ConQuest overlap boundary.
- [x] Separate internal contract audits from external validation claims.
- [ ] Require synthetic recovery, nested-reduction checks, and API-level tests
      for each new model family.
- [ ] Keep comparator claims against TAM / sirt / mirt feature-specific rather
      than package-global.

## Cross-cutting documentation and theory track

Goal: keep user-facing help pages, interpretation guidance, and theoretical
claims aligned with the actual implemented model scope and evidence base.

- [x] For each user-facing feature expansion, update the relevant help pages
      with: model assumptions, interpretation, limitations, and references.
- [x] Add literature-backed explanation blocks for the currently expanded
      ordered-response workflow, especially:
      binary-as-ordered-two-category input,
      PCM information curves,
      and fixed-calibration EAP scoring after JML fits.
- [x] Distinguish clearly between:
      implemented theory,
      practical approximation,
      and planned-but-not-yet-implemented methodology.
- [x] Add a documentation checklist to the "definition of done" for each
      roadmap phase:
      code, tests, help pages, examples, and source-backed interpretation.
- [x] Keep comparison language against ConQuest / FACETS restricted to
      overlapping functionality actually implemented in `mfrmr`.
- [x] Run a focused official-doc / theory / performance audit for the M1
      ordered-category baseline and record the outcome in a standalone
      reference note.
- [x] Convert the roadmap into an execution protocol with feature classes,
      claim-control rules, evidence thresholds, and milestone-specific queue
      management.
- [ ] Add a beginner-facing "what should I look at first?" route for
      `summary(fit)`, `summary(diagnose_mfrm(...))`, `reporting_checklist()`,
      `build_summary_table_bundle()`, and the first safe plot calls.
- [ ] Add report-writing guidance that maps package outputs to manuscript
      sections, table shells, figure captions, and interpretation caveats.
- [ ] Add plot-reading guidance for non-expert users that explains what each
      plot can and cannot support as an inferential claim.
- [ ] Keep the beginner-facing route synchronized with the active model scope:
      `RSM` / `PCM` first, bounded `GPCM` only where explicitly validated, and
      ConQuest overlap only for exact benchmarkable cases.

## Evidence base

Primary and official references used to define the roadmap:

- ACER ConQuest Manual: <https://conquestmanual.acer.org/index.html>
- ACER ConQuest Command Reference: <https://conquestmanual.acer.org/s4-00.html>
- FACETS overview: <https://www.winsteps.com/facets.htm>
- FACETS model specification: <https://www.winsteps.com/facetman64/models.htm>
- FACETS fair average: <https://www.winsteps.com/facetman/fairaverage.htm>
- FACETS bias analysis: <https://www.winsteps.com/facetman/biasanalysis.htm>
- Adams, Wilson, and Wang (1997), multidimensional random coefficients
  multinomial logit model: <https://doi.org/10.1177/0146621697211001>
- Muraki (1992), generalized partial credit model technical report:
  <https://www.ets.org/research/policy_research_reports/publications/report/1992/hwvk.html>
- Bock (1972), nominal response model:
  <https://doi.org/10.1007/BF02291411>
- TAM `tam.mml` manual:
  <https://search.r-project.org/CRAN/refmans/TAM/html/tam.mml.html>
- TAM `tam.latreg` manual:
  <https://search.r-project.org/CRAN/refmans/TAM/html/tam.latreg.html>
- TAM `tam.pv` manual:
  <https://search.r-project.org/CRAN/refmans/TAM/html/tam.pv.html>
- mirt `mirt` manual:
  <https://search.r-project.org/CRAN/refmans/mirt/html/mirt.html>
- mirt `mixedmirt` manual:
  <https://search.r-project.org/CRAN/refmans/mirt/html/mixedmirt.html>
- mirt `fscores` manual:
  <https://search.r-project.org/CRAN/refmans/mirt/html/fscores.html>
- sirt `rm.facets` manual:
  <https://rdrr.io/cran/sirt/man/rm.facets.html>

## Notes

- The current `reference_case_benchmark()` helper is useful for internal
  regression auditing, but its own documentation correctly states that it is
  not a substitute for external validation against commercial software or
  published studies.
- Verification snapshot on 2026-04-03:
  - checking the 0.1.5 tarball from a temporary directory outside Dropbox
    now completes with 1 note only:
    - `Days since last update: 4`
  - checking inside the Dropbox workspace can reintroduce a `.DS_Store` note
    in the generated check directory, but the tarball itself does not contain
    `.DS_Store`.
- The earlier local HTML-manual note was removed by installing Homebrew
  `tidy-html5` 5.8.0 so that `tidy` now resolves to `/opt/homebrew/bin/tidy`
  instead of the old system binary at `/usr/bin/tidy`.
- Phase 1 progress snapshot on 2026-04-03:
  - fit-derived simulation specs now preserve custom two-facet names and stored
    facet levels
  - `simulate_mfrm_data()`, `evaluate_mfrm_design()`,
    `predict_mfrm_population()`, and
    `evaluate_mfrm_signal_detection()` now honor those fit-derived names
    in the tested two-facet path
  - `compute_information()` and `plot_information()` now support `PCM` fits
    and respect fit-derived custom `step_facet` names and thresholds
  - `predict_mfrm_units()` and
    `sample_mfrm_plausible_values()` now support `JML` fits, including
    tested `PCM` workflows with custom facet names
  - binary responses are now documented explicitly as ordered two-category
    inputs, and the binary `PCM` step-matrix shape bug is fixed
  - `compare_mfrm()` has been audited and should remain conservative:
    in the current package model space, automatic LRT support is restricted to
    `RSM` nested in `PCM` under shared data and constraints
  - help pages and package-level guides now explain the theoretical footing
    and interpretation limits for ordered binary support, `PCM`
    design-weighted information, and post-`JML` fixed-calibration scoring
  - manual simulation specifications now also support custom public two-facet
    names, so planning helpers are no longer limited to literal
    `Rater` / `Criterion` labels in the two-facet path
  - design-planning summaries, plots, signal-detection plots, and
    recommendation helpers now expose public alias metadata and accept
    role-aware names such as `n_judge`, `n_task`, and `judge_per_person`
  - returned planning tables now also duplicate those public alias columns, so
    downstream tabulation can stay in the same naming scheme instead of
    switching back to canonical `n_rater` / `n_criterion` labels
  - planning objects now also carry a role-based design descriptor, and
    plotting/recommendation helpers can resolve design variables by role
    keywords (`person`, `rater`, `criterion`, `assignment`) as a bridge toward
    a future descriptor-first arbitrary-facet design API
  - `evaluate_mfrm_design()` and `evaluate_mfrm_signal_detection()` now share
    a descriptor-driven internal design-grid builder instead of duplicating the
    same canonical two-facet planning grid logic in two places
  - the underlying design grid still uses canonical `n_rater` /
    `n_criterion` / `raters_per_person` columns, so two-facet support is
    generalized across custom public names but not yet across arbitrary
    numbers of non-person facets
  - `predict_mfrm_population()` now carries the same public alias/descriptor
    metadata as the planning objects it wraps
  - planning-facing helpers now also accept `design = ...` overrides with the
    same canonical names, public aliases, and role keywords already exposed by
    the planner metadata, reducing switching between input and output naming
  - the same `design = ...` contract now also reaches manual simulation-spec
    creation and the direct simulation path, so the public planning schema is
    now visible at the package's simulation entry points as well
  - `evaluate_mfrm_design()` and
    `evaluate_mfrm_signal_detection()` now also accept vector-valued
    `design = ...` grids using the same canonical names, public aliases, and
    role keywords as the rest of the current two-role planner
  - the M1 audit note now records the current official ConQuest/FACETS
    overlap boundary, mathematical caveats, and prioritized performance
    opportunities
  - low-risk planning-performance cleanup is in place: design-specific setup
    no longer re-runs inside every replication, and per-replicate facet-table
    filtering has been reduced
  - empirical `resampled` / `skeleton` assignment generation now pre-splits
    template rows instead of re-filtering the full template table for each
    simulated person
  - bias-side plotting now documents `screen_rate` as the preferred public
    label for screening hit rates, while retaining `power` as a
    backwards-compatible alias
  - a lightweight benchmark harness now exists at
    `analysis/benchmark_planning_helpers.R`, with interpretation guidance in
    `inst/references/M1_PLANNING_BENCHMARK_2026-04-03.md`
