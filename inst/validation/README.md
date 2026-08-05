# mfrmr validation artifacts

This directory contains repository-only release-review helpers and evidence
artifacts. `.Rbuildignore` excludes it from the CRAN source tarball so optional
stress protocols cannot add package size or check time. Release decisions can
still be reconstructed from the public source repository, check logs, and
documented validation criteria.

Most package users can ignore this directory. Start with `README.md`,
`?fit_mfrm`, `?mfrm_results`, `?mfrm_report`, and `mfrmr_output_guide()` for
analysis guidance. The files here support package release checks and
maintenance review; public release notes stay in `NEWS.md`.

The repository-root `ROADMAP.md` is the single source of truth for public
release direction and support boundaries. `internal-roadmap-0.2.3.md` owns
maintainer sequencing, local-tool identities, candidate gates, and validation
operations. Other files in this directory may add evidence or preserve history
but do not broaden current API scope.

## Evidence types

| Type | What it is for |
| --- | --- |
| Gate helper | A script that checks whether version labels, terminology, evidence files, and check logs still agree. |
| Fixed/status artifact | A compact Markdown or CSV record of evidence from a seeded or previously reviewed workflow. |
| Optional stress helper | A script for slower validation runs that should not run during ordinary CRAN checks. |
| Scope excerpt | A bounded roadmap or capability note used to keep unsupported claims out of public helpers. |

## Primary files

- `internal-roadmap-0.2.3.md`: repository-only maintainer roadmap containing
  detailed release sequencing, evidence invalidation, local external-tool
  identities, and completion gates that do not belong in user-facing roadmap
  prose.
- `readiness-contract-0.2.3.md`: frozen internal WP0 contract separating fit,
  parameter, and metric-specific comparison readiness. It defines component
  precedence, the conservative legacy `InferenceReady` mapping, typed
  condition policy, and saved-0.2.2 behavior without claiming runtime
  implementation or statistical confirmation.
- `readiness-contract-0.2.3.R`: dependency-free repository validator and
  machine-readable catalog for readiness states, reason codes, condition
  classes, deterministic fit derivation, and legacy mapping.
- `readiness-contract-fixtures-0.2.3.csv`: 36 exact positive, negative,
  migration, and FACETS-comparison expectations covering balanced, sparse,
  two-rater, category-support, extreme-score, numerical, and external-result
  boundaries. These are structural expected answers, not completed fits or
  release evidence.
- `release-readiness.R`: release-readiness review. Source this file and run
  `mfrmr_release_readiness_review(pkg_dir = ".")` from the package root. The
  review checks version labels, metadata agreement, `--as-cran` provenance,
  the local check log, the CI check workflow, public terminology, current-
  versus-future API truth, candidate identity, numeric pass-count prose, and
  candidate-linked gate-result rows against the checklist, and the release
  evidence files.
  For 0.2.3 and later it fails closed until a versioned
  `release-candidate-manifest-<version>.csv` binds package/source/runtime and
  registry identities to the exact tarball, selected check log, frozen gate
  specification, and checklist hashes. A placeholder manifest must not be
  created before M3; absence is intentionally reported as a concern.
  `release-gate-results-<version>.csv` is also required from M4 onward; every
  result must match the manifest commit/specification, resolve to a checklist
  item and scenario, and point to a retained relative evidence path whose
  SHA-256 matches.
- `release-evidence-map-0.2.0.md`: narrative review map linking release
  claims to mathematical, statistical, UX, documentation, and engineering
  evidence.
- `release-evidence-map-0.2.2.md`: source-grounded evidence map for the
  0.2.2 bounded-`GPCM` recovery-review refinements, including the boundary
  between cited model literature and package-specific validation labels.
- `release-evidence-checklist-0.2.2.csv`: structured checklist used by the
  readiness helper and by manual release review for the current release. Older
  checklists are retained as historical release evidence.
- `release-gate-spec-0.2.3.md`: planning specification for the 0.2.3
  numerical, recovery, information-criterion, dimensionality, external,
  public-contract, and engineering gates. A `draft` status is not permission
  to run confirmation or evidence that a gate passed.
- `facets-jml-stress-plan-0.2.3.md`: draft.21 plan for recording one selected
  FACETS executable/report/parser identity and running paired, truth-first JML
  RSM/PCM simulation stress tests across connected, anchor, sparse/topology,
  edge, and optional definition-matched fit/DFF families. It treats FACETS as
  an independent comparator rather than ground truth and contains no completed
  release evidence.
- `facets-4.5.0-stress-pilot-0.2.3.R`: repository-only paired RSM/PCM
  generator, mfrmr JML runner, FACETS 4.5.0 batch adapter, normalizer, and
  reviewer. Its expanded registry includes two-rater, category-imbalance,
  planted-interaction, and local-residual-dependence cells. Direct execution
  requires `--work-dir=<path>`; raw proprietary output stays outside the
  package tree.
- `facets-4.5.0-stress-pilot-record-0.2.3.md`: compact draft.18 record of the
  first 44-run, one-seed pilot, including tool identity, scenario accounting,
  recovery/agreement warnings, disconnected fail-closed behavior, and the
  weak-link diagnostic gap. It freezes no tolerance and is not confirmation.
- `interaction-bias-pca-stress-pilot-0.2.3.R`: repository-only diagnostic
  runner that keeps fitted interactions, residual bias screening, and
  residual PCA separate while reusing exact paired FACETS scenario seeds.
- `interaction-bias-pca-stress-pilot-record-0.2.3.md`: compact draft.19 record
  of the one-seed two-rater, category-imbalance, checkerboard-interaction, and
  local-dependence pilot. It records false-readiness risks and next calibration
  requirements; it is not confirmation or a diagnostic decision rule.
- `gpcm-stress-covering-grid-0.2.3.R`: repository-only pairwise covering-grid
  generator and runner for the prespecified GPCM stress envelope. It retains
  mandatory corners, partitions smoke/pilot/confirmation seeds, records the
  unsupported one-slope-level generator as a known gap, applies missingness,
  category-support, topology, weight, repeated-cell, interaction, bias, drift,
  and residual-PCA challenges, and keeps every external numeric comparison
  ineligible until an exact estimand and normalizer contract exists. Its
  thresholds remain unfrozen calibration inputs.
- `gpcm-stress-covering-grid-smoke-record-0.2.3.md`: hashed draft.41 record of
  the deterministic seven-row smoke profile. It documents six executed cells,
  one known generator gap, zero false-ready results, zero external numeric-
  eligible rows, and an executable residual-PCA lane while explicitly
  withholding recovery, coverage, diagnostic-sensitivity, and release claims.
- `target-scale-sparse-stress-pilot-0.2.3.R`: draft.47 guarded executor for
  the six already-prespecified executable `target_sparse` covering-grid cells.
  It measures cell time and R heap high-water proxies, binds runtime and
  artifact identity, refuses overwrite, and keeps one-replicate capacity
  feasibility distinct from the declared five-replicate pilot.
- `target-scale-sparse-stress-pilot-record-0.2.3.md`: hashed draft.47 record
  of the authoritative six-cell v3 run. It records zero unexpected failures,
  zero false-ready results, exact fail-closed disconnected controls, one
  inference-ready PCM-MML review cell, a blocked mixed-adversity GPCM-MML cell,
  and a residual-PCA computability warning without freezing a threshold or
  claiming FACETS-scale capacity parity.
- `target-scale-baseline-bridge-pilot-0.2.3.R`: draft.48 guarded executor for
  balanced and matched-sparse RSM/PCM/GPCM 400-Person baselines plus a
  common-truth two-Rater PCM bridge gradient. It pairs identical data across
  JML/MML, records Windows process-lifetime peak memory, refuses overwrite,
  and keeps residual PCA disabled until its computability contract is fixed.
- `target-scale-baseline-bridge-pilot-record-0.2.3.md`: hashed draft.48 record
  of the authoritative 13-cell/26-route v2 run. It separates scale from
  adversity, records zero unexpected failures and zero false-ready routes,
  rejects a minimum-overlap conclusion from one nonmonotone seed, and keeps
  the differently seeded v1 bridge results explicitly superseded.
- `jml-bottleneck-decomposition-pilot-0.2.3.R`: draft.49 guarded PCM
  computation profiler for Person/row growth, fixed-row Rater-panel topology,
  fixed-row Criterion/step growth, fixed-parameter row exposure, forced
  extremes, and explicit BFGS/L-BFGS-B controls. It records design and
  optimizer counters without treating total elapsed time as objective time.
- `jml-bottleneck-decomposition-pilot-record-0.2.3.md`: hashed draft.49 record
  of the authoritative 14-cell/34-route v3 run. It identifies an actionable
  auto-optimizer hypothesis on the complete Person-size path, shows that BFGS
  does not repair panel/step/extreme cases, and refuses pure-dimension or
  capacity claims where topology, support, and phase timing remain confounded.
- `jml-lp-attribution-pilot-0.2.3.R` and its record: draft.56 guarded
  attribution of LP-base, R-dispatch, and solver time, with independent GLPK
  parity over 40 PCM/RSM/bounded-GPCM conditional-additive targets. The
  independent result never affects a fit, and the validation-only dependencies
  do not enter `DESCRIPTION`.
- `jml-solver-qualification-pilot-0.2.3.R` and
  `jml-solver-qualification-worker-0.2.3.R`: draft.57 guarded reacquisition,
  balanced alternating timing, generated metamorphic properties, failure-
  status controls, and isolated-process peak-memory calibration. A completed
  negative result is preserved without making a solver candidate or dispatch
  decision.
- `jml-solver-qualification-pilot-record-0.2.3.md`: hashed draft.57 record of
  280/280 ordinary paired matches, 94/96 property rows, an RSM positive-cone
  GLPK scaling failure, insufficient failure-status specificity for both
  high-level solver routes, and an explicit no-candidate/no-dispatch decision.
- `gpcm-isolated-attribution-pilot-0.2.3.R`: draft.42 repository-only
  one-axis attribution manifest and paired runner. It changes one of 11 axes
  around a fixed GPCM reference, sends each retained dataset through GPCM-JML,
  GPCM-MML, PCM-JML, and PCM-MML, verifies four-route data identity, and keeps
  Person-estimand, parameter-coordinate, primary-slope, and lower-model roles
  separate. The 40-arm, five-replicate pilot manifest has 800 rows; full
  execution requires an explicit resource authorization.
- `gpcm-isolated-attribution-smoke-record-0.2.3.md`: hashed draft.42 record of
  the 24-row reference/two-rater/category-zero/zero-shared-Person/interaction/
  local-dependence smoke. It records zero pair-identity violations and zero
  false-ready rows while treating residual PCA and optimizer slope errors as
  descriptive calibration traces only.
- `gpcm-attribution-replicated-pilot-0.2.3.R`: draft.43 repository-only tiered
  orchestration over the isolated-attribution runner, extended in draft.44
  with complete-cell atomic checkpoint/resume, execution/capability identity,
  and a hashed completion marker. It prespecifies guarded feasibility/core/
  expanded arm registries, Wilson intervals, Bernoulli and numeric Monte Carlo
  error, route-set completeness, metric summaries, and runtime forecasts
  without authorizing confirmation or freezing a criterion.
- `gpcm-attribution-replicated-feasibility-record-0.2.3.md`: hashed draft.43
  record of the corrected 80-route feasibility run. It documents the MML EAP
  Person-order defect and its invalidated pre-fix rows, the exact corrective
  public tarball/check identity, dependency-sensitive JML boundary capability,
  two-replicate uncertainty, runtime, residual-PCA cautions, and prerequisites
  for the guarded core tier.
- `gpcm-attribution-checkpoint-resume-record-0.2.3.md`: draft.44 structural
  record for four-route data-cell checkpoints, execution/capability identity,
  atomic publish, fail-closed resume, aggregate completion markers, synthetic
  interruption/adulteration tests, and real reference-cell parity. It removes
  the all-or-nothing writer as a core-tier runtime blocker without authorizing
  the still-unfrozen core design.
- `mml-metamorphic-grid-0.2.3.R`: draft.45 repository-only guarded runner for
  10 row, label, factor, missingness, and weight equivalence transformations
  across RSM, PCM, and bounded-GPCM MML. It compares semantic parameter and
  observation keys, separates input provenance from retained-data invariance,
  requires numerical readiness, and keeps all tolerances pilot-only.
- `mml-metamorphic-grid-record-0.2.3.md`: hashed draft.45 record of the
  authoritative 30/30 v3 pilot pass, including the superseded loose-
  convergence v1 failure, execution identity, maximum differences, and the
  remaining target-size, replay, external, and statistical gates.
- `roadmap-reassessment-record-0.2.3.md`: draft.46 governance record that
  rechecks official comparator versions, diagnoses the accidental 87-row
  serial scope, and separates the mandatory release spine, claim-conditional
  promotion, and deferred research. It revises execution order without
  passing evidence, freezing criteria, or authorizing confirmation.
- `facets-mfrmr-divergence-audit-0.2.3.R`: repository-only contract audit for
  completed paired pilots. Before interpreting parameter differences it checks
  constrained main-effect rank, declared versus FACETS-retained category/step
  dimensions, and nonextreme versus extreme Person comparison strata.
- `facets-mfrmr-divergence-audit-record-0.2.3.md`: draft.20 adversarial
  diagnosis that reclassifies the severe PCM and raw extreme-Person gaps,
  records the exact zero-common-Person rank deficiency, and defines the staged
  0.2.3--0.2.5 correction architecture. It is not confirmation evidence.
- `release-evidence-checklist-0.2.3.csv`: machine-readable 0.2.3 gate
  inventory. It preserves the existing `ReleaseDecision` field used by the
  readiness helper and adds scenario, criterion-state, and evidence-status
  fields needed to distinguish planning from candidate-linked evidence.
- `release-gate-m1-review-0.2.3.md`: source-grounded adversarial review of the
  draft gate. It records current implementation gaps, resolves the non-unit-
  weight and legacy-object IC boundaries, and gives the M2 instrumentation
  order. It is not evidence that a release gate passed.
- `numerical-stationarity-pilot-0.2.3.R`: draft.12 repository-only G1 runner
  for five fixed binary/RSM/PCM/GPCM fits. It checks the analytic derivative
  of the retained marginal objective against an independently implemented
  three-step central difference at retained and nonzero-score points, audits
  the free-log to sum-zero-log to positive-slope GPCM Jacobian, and checks
  exact binary and unit-slope reductions. It freezes no tolerance and never
  authorizes selection or confirmation.
- `numerical-stationarity-pilot-record-0.2.3.md`: compact draft.12 record of
  the fixed fixture hashes, ten score-reference summaries, GPCM transformation
  audit, exact reductions, fail-closed tests, and the remaining score-tolerance
  and engine-parity work.
- `mml-engine-parity-pilot-0.2.3.R`: draft.13 repository-only G1 runner for
  fixed additive RSM/PCM direct, hybrid, raw-EM, and converged-EM-plus-common-
  direct-polish paths. It verifies the exact hashed EM-to-polish handoff,
  re-evaluates every retained vector through all three public engine contexts,
  compares free and sum-zero-expanded parameters, and records unsupported
  GPCM/interaction/latent-regression requests as fallback rather than parity
  evidence. It freezes no tolerance and never authorizes selection or
  confirmation.
- `mml-engine-parity-pilot-record-0.2.3.md`: compact draft.13 record of the
  path definitions, common-vector evaluator identity, 12 mandatory path-pair
  observations, engine/fallback boundary, fail-closed tests, and remaining
  objective/parameter-tolerance work.
- `ic-contract-fixtures-0.2.3.csv`: fixed arithmetic and policy cases for the
  Person-basis AIC/BIC/SABIC contract, including unbalanced response density,
  explicit unit weights, unsupported non-unit weights, JML, legacy objects,
  and the small-N SABIC boundary.
- `ic-free-dimension-fixtures-0.2.3.csv`: independent expected free-coordinate
  counts for RSM, PCM, bounded GPCM, interactions, anchors, dummy facets, JML,
  latent regression, and alternative centering. These counts are checked
  against both the parameter-size map and retained optimizer-vector dimension
  by package-side regression tests.
- `ic-contract-audit-0.2.3.R`: repository-only checker for those fixtures and
  for the required IC fields on a fitted object. A fixture pass establishes
  exact contract arithmetic only; integration stability remains a separate
  pilot and confirmation gate.
- `external-ic-fixtures-0.2.3.csv`: seven deterministic external-record cases
  covering common Person-basis arithmetic, native TAM aBIC separation, JML,
  unchecked integration, small-N SABIC, objective inconsistency, and missing
  comparison identity.
- `external-ic-normalizer-0.2.3.R`: repository-only external MML record and
  comparison contract. It preserves native criteria/formulas, computes the
  common panel from the package's single formula builder, includes the
  draft.8 strict ConQuest matrixout-history/native-export adapter and benchmark
  stopping controls, and fails
  closed unless observation, likelihood, constraint, integration,
  convergence, and integration-stability identities are complete. The adapter
  cross-checks the objective, two independent free-dimension counts, final
  parameter vector, unit weights, exact bundle-to-export Person IDs, run metadata, convergence
  evidence, and output fingerprints without parsing the free-form report.
- `external-ic-audit-0.2.3.R`: fixture checker for that normalizer, including
  a negative integration-comparison-identity case. A pass is unit/pilot
  evidence only and does not establish cross-engine likelihood equivalence.
- `conquest-binary-ladder-pilot-0.2.3.R`: draft.9 repository-only preparer and
  reviewer for strict binary q=7/15/31/61/91/121 runs plus a second q=31 run.
  It never launches ConQuest. It verifies shared input identity, uses the
  existing fail-closed matrixout adapter, checks same-platform native-output
  replication, and leaves integration stability, selection, and confirmation
  unauthorized.
- `conquest-polytomous-rsm-pcm-pilot-0.2.3.R`: draft.11 repository-only
  preparer and reviewer for one fixed four-category RSM/PCM node ladder at
  q=7/15/31/61/91/121 plus a fresh q=31 repeat for each model. It never
  launches ConQuest. It verifies complete per-item category coverage, audited
  native parameter order, history/export identity, free dimensions, full
  item/shared-step/item-specific-step sum-zero reconstruction, core-node
  stability, and same-platform native-output repetition while leaving
  integration stability, selection, and confirmation unauthorized.
- `external-ic-pilot-record-0.2.3.md`: compact record of the seven-fixture
  audit, a live TAM 4.3-25 unidimensional PCM adapter exercise, native aBIC
  separation, and a live ConQuest 5.47.5 binary 31-node objective/free-
  dimension handoff, including the native objective-header discrepancy and
  strict-control follow-up and node ladder, plus the same-platform
  four-category RSM/PCM node ladder and q=31 repeats. Both binary and
  polytomous q=31--121 cores agree within the six-decimal ConQuest export
  resolution, and each repeated q=31 native CSV set is byte-identical. The
  RSM/PCM ladder matches free dimensions and reconstructs all sum-zero
  constraints with zero residual; its low-node rows expose instability or
  fail closed. Every cross-engine result remains non-comparable until
  independent-platform replication, integration review, and frozen-tolerance
  requirements are complete.
- `tam-dimensionality-pilot-0.2.3.R`: dimension-aware repository runner for
  prespecified TAM 1D/2D binary-Rasch controls, product-quadrature and
  deterministic-QMC ladders, conservative convergence review, exact-QMC
  repeat checks, and seed-identified stochastic integration. It never
  authorizes model selection, a regular chi-square LRT, or multidimensional
  mfrmr scores.
- `tam-dimensionality-pilot-record-0.2.3.md`: compact draft.6 record of the
  first 32-fit true-1D/true-2D matrix, eight-fit deterministic-QMC repeat audit,
  and 16-fit stochastic seed audit, including the coarse-product false-
  selection stress and unresolved Type-I-error, power, bootstrap, and
  consequence gates.
- `ic-integration-pilot-0.2.3.R`: repository-only fixed-vector common-GHQ
  evaluator. It reproduces each source-grid objective, then records raw,
  delta, pairwise-gap, and ordering drift over a shared quadrature ladder.
  It does not refit candidates, freeze a tolerance, test TAM QMC, or authorize
  confirmation.
- `ic-integration-pilot-matrix-0.2.3.R`: deterministic six-scenario runner for
  the fixed-vector evaluator. It covers the packaged RSM/PCM core, bounded
  GPCM, a sparse linked design, a Rater-by-Criterion interaction, ordinary
  latent regression, and a wide-latent near-tie stress cell without silently
  dropping failed scenarios.
- `ic-integration-refit-pilot-0.2.3.R`: independently refits a matrix scenario
  at every retained GHQ count, then reevaluates each solution at one common
  reference grid. This separates native refit-plus-integration movement from
  solution movement under a shared likelihood approximation.
- `ic-integration-pilot-record-0.2.3.md`: compact record of the first
  working-tree RSM-versus-PCM evaluator run, the six-scenario fixed-vector
  and refit matrices, and the draft.4 fail-closed public
  integration tiers. Its status remains `review`.
- `mfrmr-development-roadmap.md`: historical validation record retained for
  links from older 0.2.2 evidence. It is not an active roadmap.
- `gpcm-post-0.2.2-roadmap.md`: technical evidence supplement for bounded-
  `GPCM` surfaces that remain caveated, `blocked`, or `deferred`. It is
  subordinate to the root roadmap and the executable capability registry.
- `external-parameter-recovery-simulation-0.2.0.md`: compact review of the
  separate common-data parameter-recovery simulation workflow. The large
  generated datasets and engine outputs are not bundled with the package; this
  file records the release-relevant evidence and its limits.
- `conquest-mml-overlap-0.2.2.md`: aggregate evidence from a matched 31-node
  external ConQuest 5.47.5 run in the documented binary, item-only,
  one-covariate MML overlap scope. It records comparison results and limits but
  does not include identifier-bearing response or case-level files.
- `external-recovery-audit.R`: optional audit helper that reads a local
  `Parameter_Recovery_Simulation/` output directory, checks expected CSV
  schemas, records file fingerprints, and regenerates the compact evidence
  summary tables used for release review.
- `generate-vignette-artifacts.R`: regenerates the small CSV files under
  `inst/extdata/vignette-artifacts/` that let CRAN-style vignette builds show
  representative workflow output without rerunning fitting and simulation
  chunks.
- `first-use-workflow-stress.R`: deterministic first-use workflow stress
  protocol for the complete data -> describe -> fit -> diagnostics ->
  FACETS-organized summary -> Wright-map route. It separates scenario-contract
  agreement from reporting triage and covers linked, sparse, disconnected,
  shared-link, PCM, bounded-GPCM, extreme-score, separation, sentinel-code,
  and weighted cases.
- `first-use-workflow-stress-0.2.2.md`: compact record of the 30-fit core
  matrix and the 300 cross-surface checks run for 0.2.2, with explicit limits
  on what that evidence establishes.

## Recommended local sequence

Run these commands from the package root after any source, roxygen, vignette, or
compiled-code change:

```sh
R CMD build .
_R_CHECK_TIMINGS_=0 R CMD check --as-cran --run-donttest mfrmr_0.2.3.tar.gz
```

Then run:

```r
source("inst/validation/release-readiness.R")
readiness <- mfrmr_release_readiness_review(pkg_dir = ".")
summary(readiness)
```

During 0.2.3 M2 development, run the repository-only IC contract fixtures
before fitting any pilot grid:

```r
source("inst/validation/ic-contract-audit-0.2.3.R")
ic_contract <- mfrmr_run_ic_contract_fixture_audit(".")
print(ic_contract)
stopifnot(identical(ic_contract$status, "ok"))
```

Audit external-IC arithmetic and fail-closed identities separately:

```r
source("inst/validation/external-ic-normalizer-0.2.3.R")
source("inst/validation/external-ic-audit-0.2.3.R")
external_ic <- mfrmr_run_external_ic_fixture_audit(".")
print(external_ic)
stopifnot(identical(external_ic$status, "ok"))
```

Run the fixed G1 canonical-score pilot separately from external-engine work:

```r
pkgload::load_all(".")
source("inst/validation/numerical-stationarity-pilot-0.2.3.R")
numerical <- mfrmr_run_numerical_stationarity_pilot()
print(numerical$score_summary)
print(numerical$gpcm_jacobian$summary)
print(numerical$reduction_results)
stopifnot(
  identical(numerical$status, "review"),
  numerical$summary$AllScoreReferencesComplete,
  numerical$summary$GpcmTransformationJacobianComplete,
  numerical$summary$ExactReductionsObserved,
  identical(numerical$summary$ScoreToleranceStatus, "pilot_required"),
  !numerical$selection_authorized,
  !numerical$confirmation_authorized
)
```

This runner differentiates the same package objective through an independent
algorithm; it does not itself establish direct/hybrid/EM solution parity or
the separate ConQuest/FACETS gates.

Run the fixed additive RSM/PCM engine-path pilot after loading the canonical-
score helpers:

```r
source("inst/validation/mml-engine-parity-pilot-0.2.3.R")
parity <- mfrmr_run_mml_engine_parity_pilot()
print(parity$path_results)
print(parity$common_vector_summary)
print(parity$pairwise_results)
print(parity$scope_registry)
stopifnot(
  identical(parity$status, "review"),
  parity$summary$AllPathReferencesComplete,
  parity$summary$EMPolishStartIdentityComplete,
  parity$summary$AllCommonEvaluatorIdentitiesObserved,
  parity$summary$AllPairwiseReferencesComplete,
  parity$summary$FallbackScopeComplete,
  identical(parity$summary$ObjectiveToleranceStatus, "pilot_required"),
  identical(parity$summary$ParameterToleranceStatus, "pilot_required"),
  !parity$selection_authorized,
  !parity$confirmation_authorized
)
```

Raw EM remains diagnostic even when it happens to be inference-ready. GPCM
engine parity is not applicable while direct is its only supported engine;
EM/hybrid fallback rows cannot satisfy parity.

For the generated ConQuest bundle, retain all four comparison CSV files plus
the additional `*_conquest_history.csv` written from estimate `matrixout`.
`mfrmr_external_ic_from_conquest()` uses the history objective and free
dimension, independently counts the parameter/regression/covariance exports,
checks their final vector, and requires the unit-weight case PIDs to match the
expected bundle Person IDs exactly. A convergence `pass` also requires a named
review-evidence ID. The human summary
is not parsed. The current adapter is version-locked to audited ConQuest
5.47.5, and the resulting record stays non-comparable until the real
likelihood, constraint, and integration identities have passed review.

Prepare and review the strict binary node ladder with:

```r
pkgload::load_all(".")
source("inst/validation/conquest-binary-ladder-pilot-0.2.3.R")
prepared <- mfrmr_prepare_conquest_binary_ladder(
  tempfile("mfrmr-conquest-binary-ladder-")
)
print(prepared$commands)

# Run each generated .cqc file in ConQuest separately and capture its complete
# console stream at the corresponding ExpectedLogFile. The runner never starts
# the proprietary executable itself.
reviewed <- mfrmr_review_conquest_binary_ladder(
  prepared$output_dir,
  pkg_dir = ".",
  engine_version = "5.47.5 Demonstration Version",
  run_date = Sys.Date()
)
print(reviewed$results)
print(reviewed$summary)
stopifnot(!reviewed$summary$ConfirmationAuthorized)
```

Prepare and review the fixed four-category RSM/PCM node ladder separately:

```r
pkgload::load_all(".")
source("inst/validation/conquest-polytomous-rsm-pcm-pilot-0.2.3.R")
poly_prepared <- mfrmr_prepare_conquest_polytomous_pilot(
  tempfile("mfrmr-conquest-polytomous-")
)
print(poly_prepared$commands)

# Run each generated .cqc file in ConQuest separately and capture its complete
# console stream at ExpectedConsoleLog. This helper never starts ConQuest.
poly_reviewed <- mfrmr_review_conquest_polytomous_pilot(
  poly_prepared$output_dir,
  pkg_dir = ".",
  engine_version = "5.47.5 Demonstration Version",
  run_date = Sys.Date()
)
print(poly_reviewed$results)
print(poly_reviewed$summary)
stopifnot(
  !poly_reviewed$summary$AnyComparisonReady,
  !poly_reviewed$summary$SelectionAuthorized,
  !poly_reviewed$summary$ConfirmationAuthorized
)
```

The prepared directories contain Person identifiers, responses, covariates,
and case-level outputs. Use a new restricted directory for each pilot and do
not commit those generated files. Only aggregate, non-identifying results
belong in the repository record.

For a local TAM marginal-MML pilot, use
`mfrmr_external_ic_from_tam()` only after recording real observation,
likelihood, constraint, and integration-comparison identities. Its defaults
remain non-comparable; callers must not set convergence or integration
stability to `pass` without the corresponding review. TAM native `aBIC` stays
separate from the common Sclove `SABIC`. Public `import_tam_fit()` is narrower:
it rejects `tam.jml` and `ndim > 1`, because multidimensional TAM evidence must
remain in the separate dimension-aware repository runner.

Run the first TAM dimensionality pilot and its deterministic-QMC replay with:

```r
source("inst/validation/tam-dimensionality-pilot-0.2.3.R")
tam_dimension <- mfrmr_run_tam_dimensionality_pilot_matrix(progress = TRUE)
print(tam_dimension)
stopifnot(
  identical(tam_dimension$status, "review"),
  all(tam_dimension$fits$ConvergenceStatus != "fail"),
  all(!tam_dimension$pairwise$SelectionAuthorized)
)

qmc_repeat <- mfrmr_run_tam_dimensionality_qmc_repeat_audit(
  "DIM-SYN-TRUE-1D",
  qmc_nodes = 1024L,
  repeats = 2L
)
print(qmc_repeat)

stochastic <- mfrmr_run_tam_dimensionality_stochastic_audit(
  "DIM-SYN-TRUE-1D",
  snodes = 1024L,
  seeds = c(20260731L, 20260732L, 20260733L, 20260734L)
)
print(stochastic)
```

This is pilot-only. The ordinary chi-square LRT is deliberately unavailable,
the parametric bootstrap and score-consequence stages are not implemented,
and one seeded control per truth cannot estimate false-selection rates or
power. Public `import_tam_fit()` must continue rejecting the multidimensional
objects retained by this runner.

The fixed-vector GHQ pilot can then be run on two or more inference-ready,
same-basis MML fits. The source quadrature count must be included in the
ladder:

```r
source("inst/validation/ic-integration-pilot-0.2.3.R")
ic_integration <- mfrmr_run_ic_integration_pilot(
  fits = list(RSM = fit_rsm, PCM = fit_pcm),
  quad_points = c(7, 15, 31, 61, 91, 121),
  reference_quad = 121,
  core_quad_points = c(31, 61, 91, 121)
)
print(ic_integration)
```

Run the deterministic development matrix with:

```r
source("inst/validation/ic-integration-pilot-matrix-0.2.3.R")
ic_matrix <- mfrmr_run_ic_integration_pilot_matrix(progress = TRUE)
print(ic_matrix)
stopifnot(nrow(ic_matrix$failures) == 0L)
```

Then separate native refit-plus-integration movement from retained-solution
movement at a common reference grid:

```r
source("inst/validation/ic-integration-refit-pilot-0.2.3.R")
ic_refit <- mfrmr_run_ic_integration_refit_matrix(progress = TRUE)
print(ic_refit)
stopifnot(nrow(ic_refit$failures) == 0L)
```

The fixed-vector and refit matrices remain small deterministic calibration
sets. They support the draft q<31 comparison guard but do not freeze it.
Additional weak-link/near-boundary cells, cross-platform evaluation, and the
multi-node stochastic TAM integration policy remain necessary before
`IC-INTEGRATION-TOL` can be frozen. The draft.6 deterministic-QMC ladder is an
initial calibration result, not a frozen tolerance.

After the package-side IC fields are implemented, pass representative fits to
`mfrmr_audit_fit_ic_contract()`. An unmodified 0.2.2 fit is expected to return
`concern` because it lacks the versioned Person-basis fields; that negative
control prevents old row-basis BIC values from being silently relabelled.

The release candidate should have `Status: OK` in the local check log,
`ReleaseReadinessStatus = "ok"`, and only `ok` rows in
`readiness$gate_summary`. The `example_policy` row restricts `\dontrun{}` to
the two external-ConQuest-file workflows and `@examplesIf interactive()` to
the local Shiny viewer. The `check_timing` row applies the 600-second threshold
to the summed CRAN-side package workload: ordinary examples, `donttest`
examples, tests, and vignette rebuilding. It also reports the sum of every
timed top-level check component as diagnostic context, without charging
dependency, installation, manual, or other check-infrastructure time to the
package-controlled threshold. A log without workload timings requires review.
Inspect `mfrmr-Ex.timings` as well as the aggregate gate before submission.
Jobs run with `NOT_CRAN=true` are labeled `full_non_cran` and are exempt from
this CRAN-time threshold because their purpose is to execute the deliberately
exhaustive regression suite; the ordinary matrix jobs still enforce the
timing gate.

A missing `Status:` line, a check-log package version that differs from
`DESCRIPTION`, release inputs newer than the matching source tarball or check
log, or a check log older than that tarball is a release blocker reported as a
`concern`. If the local environment cannot verify
external clock time, record that environment-only NOTE in `cran-comments.md`
and rerun the package check with the clock check disabled to confirm that
package checks are otherwise clean.

When public workflow output changes, refresh the vignette artifacts before
building:

```r
source("inst/validation/generate-vignette-artifacts.R")
mfrmr_generate_vignette_artifacts(".")
```

CRAN-time tests are intentionally lightweight because CRAN check hosts have
strict timing constraints. Run the full non-CRAN regression surface separately
when release evidence is needed:

```sh
NOT_CRAN=true Rscript -e 'testthat::test_local(".")'
```

Run the first-use workflow protocol after loading the development tree. The
quick tier is for iteration; the core tier uses every scenario and three
deterministic seeds by default:

```r
pkgload::load_all(".")
source("inst/validation/first-use-workflow-stress.R")

quick <- mfrmr_run_first_use_stress("quick")
summary(quick)

core <- mfrmr_run_first_use_stress(
  "core",
  output_dir = "validation-results/first-use-workflow"
)
summary(core)
```

`ContractPassed` means that software behavior matched the scenario's explicit
Numerical/Data/Design/Stability/Reporting/Plot expectations. It does not mean
the run is manuscript-ready; inspect `UpstreamReportingHold`,
`DiagnosticReviewRequired`, `DiagnosticFollowUpPending`, and the recorded
readiness states separately. Large-data diagnostics, real graphics devices,
and cross-platform UTF-8 rendering remain full/nightly checks rather than CRAN
examples.

If the external common-data simulation workflow has been refreshed, audit it
from the package side before updating the evidence summary:

```r
source("inst/validation/external-recovery-audit.R")
external_review <- mfrmr_review_external_recovery_simulation(
  "../Parameter_Recovery_Simulation"
)
summary(external_review)

source("inst/validation/release-readiness.R")
readiness <- mfrmr_release_readiness_review(
  pkg_dir = ".",
  external_recovery_dir = "../Parameter_Recovery_Simulation"
)
summary(readiness)$external_recovery_status
```

## Cross-platform evidence

GitHub Actions runs the package on macOS, Windows, and Linux across release,
oldrel, and devel R. Warnings are treated as check failures. The workflow also
uploads the check directory as an artifact for each matrix job so that release
review can compare local and CI evidence instead of relying only on the final
job status.

The readiness helper checks the workflow contract from source. It does not
replace reading the uploaded CI artifacts before release. The
external parameter-recovery summary is an additional source-grounded review
artifact, not a substitute for rerunning the package tests or the optional
long-running validation scripts.
