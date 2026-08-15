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

Ordinary repository tests retain the G-theory contract, schema, hash,
mutation, and fail-closed checks. The isolated fitting and exact-resume layer
for the guarded shard runner, production adapter, hardened adapter, and
record-bound entry point is intentionally opt-in:

```sh
MFRMR_RUN_GTHEORY_SLOW=true Rscript -e 'devtools::test(filter = "gtheory-weak-information-(guarded-shard-runner|hardened-adapter-rebase|production-adapter-preflight|record-bound-entry-point)")'
```

An ordinary skip is not evidence that this layer passed. Release evidence must
identify whether the opt-in layer ran and retain its test log.

## Primary files

- `internal-roadmap-0.2.3.md`: repository-only maintainer roadmap containing
  detailed release sequencing, evidence invalidation, local external-tool
  identities, and completion gates that do not belong in user-facing roadmap
  prose. Its 2026-08-15 controlling overlay makes matched ConQuest work the
  highest-priority external lane, with semantic runtime continuity, adversarial
  model-identity checks, decision-level consequences, and precision-planned
  confirmation ahead of broader simulation or new model families. A canonical
  P0--P5 checklist is the overlay's sole mutable progress surface and includes
  an all-checked Go/No-Go template for every successor external run.
- `conquest-semantic-runtime-preflight-0.2.3.R` and
  `conquest-semantic-runtime-preflight-record-0.2.3.md`: reusable ConQuest C0
  boundary requiring an explicit executable path and data-free `quit;`
  sentinel. It records version/edition/expiry, architecture, invocation,
  locale, exit and terminal semantics; rejects status-zero semantic failures;
  keeps runtime and estimation states separate; and requires the smallest
  frozen numerical sentinel before a changed runtime can reopen broader
  prospective execution. Ordinary tests inject a fake runner and never launch
  ConQuest.
- `conquest-successor-semantic-registry-0.2.3.R` and
  `conquest-successor-semantic-registry-record-0.2.3.md`: prospective P1
  registry separating 14 comparison candidates, six fail-closed controls, and
  three non-overlap/unsupported rows. Each row carries a human-readable model
  signature, independently reproducible free dimension where applicable,
  complete denominator, decision consequence, and claim ceiling. Fixture A/C
  maps and metric rules are now supplied by the separate P2/P3 overlays;
  independent P0/P1 review remains pending, so the registry authorizes no
  ConQuest execution or comparison.
- `conquest-p2-additive-adversarial-fixtures-0.2.3.R` and
  `conquest-p2-additive-adversarial-fixtures-record-0.2.3.md`: disjoint,
  deterministic 48-Person/4-Rater/3-Criterion RSM/PCM fixture suite covering
  multibridge and weak-link connectivity, workload imbalance, two missingness
  representations, category and extreme-score stress, and disconnected
  rejection. Independent A/C coefficient maps reproduce direct probabilities,
  and all thirteen fixtures have finite continuous-target likelihood oracles.
  This construction layer authorizes no comparison; the separate contract
  below freezes metric rules while independent review and execution stay open.
- `conquest-p2-metric-boundary-contract-0.2.3.R` and
  `conquest-p2-metric-boundary-contract-record-0.2.3.md`: prospective P2
  boundary-state, metric, denominator, and stop/expansion freeze. It keeps
  native finite/unbounded, adjusted-display, and posterior quantities distinct;
  reuses unchanged exact-reported-decimal coordinate/deviance budgets; derives
  the conditional-probability bound from the independent A matrix; and retains
  147 metric rows/5,073 atomic outcomes. EAP/SD remain typed ineligible pending
  posterior-identity proof. Independent review and execution remain pending.
- `conquest-minimum-diagnostic-authorization-0.2.3.R` and
  `conquest-minimum-diagnostic-authorization-record-0.2.3.md`: separates the
  minimum pre-execution fatal-gate audit from independent post-output evidence
  review. It freezes exactly the paired connected-multibridge RSM/PCM rows,
  q=31/61, four ConQuest fits, four mfrmr fits, and fifteen non-waivable gates.
  A declared same-author audit may authorize only this sealed diagnostic;
  evidence promotion, widening, P3, and public claims still require independent
  review.
- `conquest-minimum-diagnostic-live-authorization-0.2.3.R` and
  `conquest-minimum-diagnostic-live-authorization-record-0.2.3.md`: binds the
  2026-08-15 data-free ConQuest 5.47.5 sentinel and disclosed maintainer audit.
  All fifteen fatal gates pass, authorizing only the four ConQuest/four mfrmr
  fits through 2026-08-16. Evidence promotion, widening, P3, and public claims
  remain false; the binding file cannot execute an engine.
- `conquest-minimum-diagnostic-harness-0.2.3.R` and
  `conquest-minimum-diagnostic-harness-record-0.2.3.md`: fail-closed run-once
  harness for exactly the two connected-multibridge rows at q=31/61. It
  validates semantic inputs and commands without hashes, rejects any opened or
  additional candidate path, retains fit/runtime/output failures, and keeps
  every evidence-promotion and public-claim authority false. Ordinary tests
  exercise only the preparation and semantic gates; they launch no model.
- `conquest-minimum-diagnostic-execution-observation-0.2.3.R` and
  `conquest-minimum-diagnostic-execution-observation-record-0.2.3.md`: retains
  the first run-once outcome: four expected-dimension mfrmr fits, followed by
  a ConQuest RSM/q31 negative-variance estimation abort and three unattempted
  native arms. Engine-independent counts expose an exactly balanced,
  covariate-unseparated fixture signal, so the current candidate cannot rerun
  and the fixture contract must be superseded before new authorization.
- `conquest-p2-replacement-nondegenerate-fixture-0.2.3.R` and
  `conquest-p2-replacement-nondegenerate-fixture-record-0.2.3.md`: freezes one
  no-search PCM-generating replacement seed and thirteen engine-independent
  gates. It repairs the population/facet-signal collapse but is rejected before
  fit because one Rater-by-Criterion-by-category cell is empty. The failed seed
  cannot be searched away; a support-guaranteeing successor design is required.
- `conquest-p2-candidate-003-coverage-conditioned-fixture-0.2.3.R` and
  `conquest-p2-candidate-003-coverage-conditioned-fixture-record-0.2.3.md`:
  freezes a single-seed, probability-weighted block-conditioning successor.
  It passes all thirteen unchanged pre-fit gates and authorizes only a separate
  mfrmr internal preflight. The conditional joint sampling law cannot support
  truth-recovery, calibration, external-execution, or equivalence claims.
- `conquest-p2-candidate-003-mfrmr-preflight-0.2.3.R` and
  `conquest-p2-candidate-003-mfrmr-preflight-record-0.2.3.md`: freezes the
  run-once, four-fit mfrmr-only gate for candidate 003. Expected dimensions,
  convergence, an interior variance floor, exact readiness-state handling, and
  q31--q61 movement are prospective; ConQuest execution and every claim remain
  unauthorized. The single run was consumed and failed its two integration
  gates; the observation contract below retains that result.
- `conquest-p2-candidate-003-mfrmr-preflight-observation-0.2.3.R` and
  `conquest-p2-candidate-003-mfrmr-preflight-observation-record-0.2.3.md`:
  retains four expected-dimension, interior-variance fits and four explicit
  design-rank holds, plus complete RSM/PCM q31--q61 movement failures. Candidate
  003 cannot rerun or launch ConQuest; a successor integration contract must
  precede any disjoint candidate.
- `conquest-p2-successor-integration-contract-0.2.3.R` and
  `conquest-p2-successor-integration-contract-record-0.2.3.md`: prospectively
  separates required q31--q61 diagnostics from governing q61--q121 and
  q121--continuous layers for a future disjoint P2 candidate. It cannot rescue
  candidate 003 and copies no P3 numerical budget. Its thirteen-fixture no-fit
  audit was consumed and rejected the fixed q121 ceiling.
- `conquest-p2-successor-integration-observation-0.2.3.R` and
  `conquest-p2-successor-integration-observation-record-0.2.3.md`: retains all
  thirteen truth-oracle rows and the two unequal-workload failures. Candidate
  004 remains held until a bounded design-adaptive density contract passes
  without changing the numeric budgets.
- `conquest-p2-adaptive-density-contract-0.2.3.R` and
  `conquest-p2-adaptive-density-contract-record-0.2.3.md`: freezes the bounded
  `31;61;121;241` ladder and whole-slice lowest-passing-pair rule. q241 is a
  hard ceiling; missing arms, remaining integration failure, and any proposed
  threshold change stop rather than expand the search. Its no-fit audit reached
  that ceiling and stopped on the legacy continuous-reference gate.
- `conquest-p2-adaptive-density-observation-0.2.3.R` and
  `conquest-p2-adaptive-density-observation-record-0.2.3.md`: retains 13/13
  q121--q241 finite-grid passes and the two persistent unequal-workload
  continuous-reference failures. Further q expansion is closed; the continuous
  oracle itself must be qualified next.
- `conquest-p2-log-centered-continuous-oracle-0.2.3.R` and
  `conquest-p2-log-centered-continuous-oracle-record-0.2.3.md`: freezes a
  mode-centered, split-integral reference with explicit numerical and normal-
  tail deviance-error bounds. Its thirteen-fixture audit is held until after
  this contract is committed; consumed candidates cannot be reclassified.
- `conquest-p2-log-centered-continuous-oracle-observation-0.2.3.R` and
  `conquest-p2-log-centered-continuous-oracle-observation-record-0.2.3.md`:
  retains the 13/13 qualification pass, the q121/q241 agreement, and the two
  legacy unequal-workload discrepancies. It qualifies the new repository
  reference and authorizes candidate-004 generation only; fitting, external
  execution, and evidence promotion remain blocked.
- `conquest-p2-candidate-004-coverage-conditioned-fixture-0.2.3.R` and
  `conquest-p2-candidate-004-coverage-conditioned-fixture-record-0.2.3.md`:
  freezes candidate 004's new identity and seed, unchanged thirteen-gate
  denominator, probability-weighted support conditioning, and separate
  candidate-003 lineage gate. Generation remains unopened; fitting and
  external execution are unauthorized.
- `conquest-p2-candidate-004-fixture-observation-0.2.3.R` and
  `conquest-p2-candidate-004-fixture-observation-record-0.2.3.md`: retains the
  disjoint candidate's 13/13 gate pass and full-cell coverage. It authorizes
  only a separately frozen mfrmr preflight contract; no fit or external run is
  authorized by the fixture result.
- `conquest-p2-candidate-004-mfrmr-preflight-0.2.3.R` and
  `conquest-p2-candidate-004-mfrmr-preflight-record-0.2.3.md`: freezes the
  six-fit q31/q61/q121 initial phase, conditional two-fit q241 phase, inherited
  fit gates, whole-slice dense-pair selection, and fitted-coordinate log-
  centered target. Its execution remains unopened and cannot launch ConQuest.
- `conquest-p2-candidate-004-mfrmr-preflight-observation-0.2.3.R` and
  `conquest-p2-candidate-004-mfrmr-preflight-observation-record-0.2.3.md`:
  retains the six structurally/numerically eligible but not inference-ready
  fits, diagnostic q31 movement, and q61--q121 dense-pair/continuous-target
  pass. q241 was not run; external execution still requires a new review.
- `conquest-p2-candidate-004-live-authorization-0.2.3.R` and
  `conquest-p2-candidate-004-live-authorization-record-0.2.3.md`: binds a fresh
  data-free ConQuest sentinel and disclosed same-author fifteen-gate audit to
  exactly four q61/q121 external fits. It permits no new mfrmr fit, evidence
  promotion, wider execution, P3 work, or public claim.
- `conquest-p2-candidate-004-harness-0.2.3.R` and
  `conquest-p2-candidate-004-harness-record-0.2.3.md`: freezes a fail-closed
  four-arm q61/q121 bundle with exact wide data, command semantics, output registry,
  run-once journal, and semantic stop rule. Tests prepare only temporary
  unopened bundles and never execute ConQuest.
- `conquest-p2-candidate-004-execution-observation-0.2.3.R` and its record:
  retain the completed four-arm execution denominator, including semantic
  termination and 32/32 required native outputs, without numerical promotion.
- `conquest-p2-candidate-004-numerical-review-contract-0.2.3.R`, its record,
  and the corresponding numerical observation: freeze and apply the inherited
  reported-decimal, matched-deviance, quadrature, probability, ordering,
  typed-ineligible, and nonpromotion rules. The complete same-author numerical
  core passes, while independent review and inference readiness remain open.
- `conquest-p2-candidate-004-rank-hold-contract-0.2.3.R`, its observation, and
  their records: disaggregate additive, observed-pattern, fixed-quadrature
  local, global marginal, continuous-integral, and weak-information layers.
  Local ranks pass without clearing the global identification or readiness
  holds.
- `conquest-p2-candidate-004-reviewer-adversarial-controls-record-0.2.3.md`:
  retains semantic positive and negative reviewer controls without treating
  serialization or byte identity as scientific evidence.
- `conquest-p2-candidate-004-independent-review-handoff-0.2.3.R` and its
  record: select only the bounded RSM/PCM q61/q121 claim and freeze reviewer
  independence, raw-evidence primacy, fifteen required tasks, full
  denominators, explicit nonclaims, and fail-closed no-rerun adjudication. The
  independent review itself remains unperformed.
- `conquest-p2-candidate-004-dependency-sentinel-0.2.3.R` and its record:
  classify semantic changes to likelihood, constraints, category handling,
  integration, parsers, transforms, runtime identity, frozen contracts, and
  raw evidence. Historical preservation is separated from current-source
  applicability; consequences are recalculation, a new runtime sentinel, a
  successor candidate, contract review, or evidence quarantine rather than a
  byte-level acceptance rule.
- `conquest-optional-package-boundary-audit-0.2.3.R` and its record: verify
  that pure-R ConQuest handoff APIs do not become an executable, path,
  dependency, ordinary-test, source-package, or CRAN-check requirement. The
  recorded vignette-bearing source tarball passed `R CMD check --no-manual`
  without ConQuest.
- `conquest-p5-evidence-disposition-ledger-0.2.3.R` and its record: keep the
  early six-arm and later P2 minimum-diagnostic candidate lineages distinct;
  state the exact runtime/design/parameter/decision overlap; retain failed,
  withheld, ineligible, integration-limited, and unresolved denominators; and
  map supported, caveated, disabled, and deferred public decisions without
  authorizing a public text change.
- `conquest-p4-replication-necessity-decision-0.2.3.R` and its record: close
  replicated confirmation as `replication_not_needed` only for the selected
  candidate-004 fixed-artifact claim. Independent review remains required;
  cross-data-set rates, recovery, coverage, portability, wider P2, and P3
  cannot inherit this narrow decision.
- `conquest-p3-item-only-adversarial-fixtures-0.2.3.R` and
  `conquest-p3-item-only-adversarial-fixtures-record-0.2.3.md`: disjoint,
  deterministic 96-Person/4-Item PCM/GPCM suite covering a unit-slope
  reduction, non-unit relative slopes, and intercept-only/covariate population
  models with all transitions observed. Independent observed-support A/C maps
  reproduce 240 direct probabilities, and q=31/61/121 likelihoods converge to
  independent whole-line targets. This construction layer authorizes nothing;
  the separate metric contract below reaches independent offline review.
- `conquest-p3-metric-precision-contract-0.2.3.R` and
  `conquest-p3-metric-precision-contract-record-0.2.3.md`: prospective P3
  estimand-specific budgets, decimal-token interval policy, integration-state
  precedence, 23 metric types, 61 metric rows/861 atomic outcomes, and complete
  stop/invalidation rules. q31--q61 is diagnostic; q61--q121 and q121 versus
  continuous targets govern integration eligibility before cross-engine
  metrics. TAM remains optional separate pairwise evidence with no voting.
  Independent review and every external execution/comparison claim stay open.
- `readiness-contract-0.2.3.md`: frozen internal WP0 contract separating fit,
  parameter, and metric-specific comparison readiness. It defines component
  precedence, the conservative legacy `InferenceReady` mapping, typed
  condition policy, and saved-0.2.2 behavior without claiming runtime
  implementation or statistical confirmation.
- `readiness-contract-0.2.3.R`: dependency-free repository validator and
  machine-readable catalog for readiness states, reason codes, condition
  classes, deterministic fit derivation, and legacy mapping.
- `claim-disposition-profile-0.2.3.csv` and `.md`: the hash-bound single
  portfolio overlay mapping all checklist items to the mandatory release
  spine, claim-specific fail-closed fallbacks, or deferred work. The central
  release-readiness review verifies its integrity and reports the current
  spine-open decision without treating deferred concerns as release blockers.
- `external-repository-boundary-audit-0.2.3.R` and its record: deterministic
  tracked-file privacy/license audit for external-comparison assets. It
  retains only finding classes and repository-relative paths, recomputes the
  external artifact manifest, and does not inspect or authorize ignored local
  result directories.
- `conquest-gpcm-overlap-contract-0.2.3.R`, its machine-readable registry,
  and companion record: exact item-only active-latent-regression map between
  mfrmr's geometric-mean-one slopes plus estimated residual variance and
  ConQuest's variance-one `scoresfree` Taux. The record binds one completed
  native MML microcase, documents the resulting default-identification
  correction, and explicitly separates the legacy fixed-standard-normal,
  standard multifacet generalized-item, JML free-score, and multidimensional
  strata. It launches no external program and promotes no comparison row.
- `readiness-contract-fixtures-0.2.3.csv`: 36 exact positive, negative,
  migration, and FACETS-comparison expectations covering balanced, sparse,
  two-rater, category-support, extreme-score, numerical, and external-result
  boundaries. These are structural expected answers, not completed fits or
  release evidence.
- `exact-model-reduction-closure-record-0.2.3.md`: structural closure of the
  binary RSM/PCM and unit-slope GPCM/PCM identities using route-to-route
  equality, an independently implemented marginal-likelihood oracle, explicit
  free/expanded parameter-transform residuals, and fail-closed mutation tests.
- `gpcm-extreme-and-surface-audit-0.2.3.md`: deterministic five-category
  challenge separating JML infinite Person measures, MML prior-regularized
  EAPs, boundary-constant Rater support, certified relative JML facet recession
  directions, and central summary/diagnostic/plot readiness propagation. Its
  compact endpoint roadmap adds high/low symmetry, isolated versus joint
  attribution, negative and anchor controls, near-extreme support,
  interaction/category cases, estimator-specific semantics, and downstream
  fit/DFF eligibility without authorizing a large simulation. It changes no
  GPCM capability status.
- `gpcm-estimator-asymptotics-0.2.3.R`, its contract, smoke record, and pilot
  record:
  nested matched GPCM cells that separate increasing Persons at fixed exposure
  from increasing exposure at fixed Persons under JML and MML. The one-seed
  smoke retains all failures and optimizer slope traces without assigning an
  incidental-bias limit, correction, estimator preference, Bayesian-necessity
  decision, or release threshold. The guarded 20-replicate pilot adds
  coordinate-specific error, Monte Carlo uncertainty, paired method contrasts,
  and MML population-scale recovery while retaining the same non-authorization.
- `gpcm-latent-distribution-stress-0.2.3.R`, its contract, and pilot record:
  coupled normal, skewed-gamma, and symmetric-mixture Person distributions at
  sparse and dense exposure. The pilot separates structural recovery from
  normal-population moment sensitivity and does not authorize a Bayesian or
  estimator-selection route.
- `gpcm-solution-decision-stability-roadmap-0.2.3.md`: cross-cutting roadmap
  from canonical objective/gradient/free-dimension and multiple-start/
  quadrature checks through boundary adjudication, Hessian/interval
  eligibility, coordinate transformation, and exact DFF/fit/rank/readiness
  decision signatures. It records current implemented versus open layers and
  authorizes no tolerance, simulation, or capability promotion.
- `gpcm-solution-stability-p0-0.2.3.R` and
  `gpcm-solution-stability-p0-record-0.2.3.md`: seven-start canonical-objective,
  gradient, free-dimension, semantic-coordinate, and decision-signature
  instrument plus its benign-microcase record.
- `gpcm-endpoint-solution-stability-p0b-0.2.3.R` and
  `gpcm-endpoint-solution-stability-p0b-record-0.2.3.md`: reflected exact and
  19/20 near Person endpoint extension. It records finite EAP provenance but
  start-sensitive population scale, keeps every candidate review-only, and
  narrows the next work to variance-profile and start-by-q adjudication rather
  than a broad simulation.
- `gpcm-population-variance-profile-p1a-0.2.3.R` and
  `gpcm-population-variance-profile-p1a-record-0.2.3.md`: q=31 finite-grid
  local nuisance profiles from the P0b default and low-variance basins. The
  low-variance anchor is a qualified local minimum in all four reflected
  endpoint cases, whereas the high-variance tails remain nonstationary. The
  diagnostic envelope is not promoted to a global profile or boundary result;
  its complete 80-row execution is opt-in rather than part of ordinary tests.
- `gpcm-low-basin-quadrature-p1b-0.2.3.R` and
  `gpcm-low-basin-quadrature-p1b-record-0.2.3.md`: independent q=31/61/91
  refits of the P1a-qualified low-variance basin plus a predesignated
  diagnostic-default lane. Every returned vector is reevaluated on held-out
  q=121 for objective, analytic/numeric score, labelled coordinates, EAP, and
  posterior SD. The low lane is coherent across finite q; the nonstationary
  default lane is excluded before comparison. No tolerance, continuous-
  integral certificate, solution selection, or downstream inference is
  promoted, and the 24-arm execution is opt-in.
- `gpcm-zero-variance-boundary-p1c-0.2.3.R` and
  `gpcm-zero-variance-boundary-p1c-record-0.2.3.md`: exact q=1 implementation
  of the fixed-nuisance `sigma2 -> 0+` GPCM likelihood, with an independent
  direct conditional-likelihood oracle, three nuisance starts, a prior
  derivative-step ladder, and a diagnostic q=121 natural-variance path. All
  12 finite boundary traces remain nonstationary and comparison-ineligible;
  observed slope dispersion redirects the next gate to a joint zero-variance/
  slope path without freezing a cutoff or selecting a solution.
- `gpcm-zero-variance-log-slope-path-p1d-0.2.3.R` and
  `gpcm-zero-variance-log-slope-path-p1d-record-0.2.3.md`: bounded two-route
  profile of the observed C4 joint lower-boundary ray. The construction keeps
  C4 `slope * population SD` invariant under sum-zero log-slope identification
  and therefore forbids transporting the fixed-nuisance q=1 limit. q=61/91/
  121 evaluations remain coherent, but only 14/48 points pass nuisance
  stationarity and no `t >= 4` point does. The result is inconclusive and
  redirects the next gate to a coordinate-aware reduced limit rather than
  denser paths, a larger iteration ceiling, or solution selection.
- `gpcm-coordinate-scaled-joint-limit-p1e-0.2.3.R` and
  `gpcm-coordinate-scaled-joint-limit-p1e-record-0.2.3.md`: exact finite
  reparameterization and independently derived direct limit for the declared
  symmetric C4 ray. All 32 transformed finite fits and all eight direct-limit
  fits pass their scale-specific rules; direct-limit routes agree to floating-
  point precision and lie 3.38--4.15 objective units above the interior
  candidate conditional on a fixed `slope * population SD` coefficient. Raw-
  coordinate gradients remain reported. P1f later establishes that the fixed
  coefficient is not stationary when released, so P1e adjudicates only its
  declared fixed-coefficient path.
- `gpcm-slope-rate-cone-p1f-0.2.3.R` and
  `gpcm-slope-rate-cone-p1f-record-0.2.3.md`: exact affine identification of
  the normalized finite-random-product rates with a standard simplex,
  enumeration of all 14 nonempty proper four-criterion target faces, and a
  canonical reduced likelihood with free positive target coefficients. The
  independently checked likelihood recovers P1e exactly but exposes its fixed
  C4 coefficient as nonstationary. No face optimization, empty-target
  deterministic-Rater hierarchy, global boundary, or source selection is
  claimed.
- `gpcm-c4-face-to-deterministic-rater-p1g-0.2.3.R` and
  `gpcm-c4-face-to-deterministic-rater-p1g-record-0.2.3.md`: exact
  `lambda`-scaled C4 coordinates, a two-route seven-point face profile, and a
  direct `lambda=0` conditional-GPCM endpoint retaining C4 Rater effects. All
  56 fits pass and the endpoint is stable but remains above the qualified
  interior. The result covers neither an unseen C4 interior basin nor other
  random-target/deterministic-Rater faces and authorizes no solution choice.
- `gpcm-single-target-face-screen-p1h-0.2.3.R` and
  `gpcm-single-target-face-screen-p1h-record-0.2.3.md`: C1--C3 application of
  the exact P1g coefficient-scaled likelihood. All 168 new fits pass and their
  singleton deterministic-Rater endpoints remain above the interior. Combined
  with frozen P1g evidence, all four single-target grids are screened. No
  multiple-target face, multi-criterion Rater stratum, or source solution is
  claimed.
- `gpcm-two-target-radial-screen-p1i-0.2.3.R` and
  `gpcm-two-target-radial-screen-p1i-record-0.2.3.md`: exact two-target
  geometric-mean radial and free-relative-coefficient chart for all six pairs.
  Of 336 two-route fits, 318 are eligible and 10/24 scenario-by-pair grids
  reach consistent finite-ratio endpoints above the qualified interior. The
  other 14 expose coefficient-ratio branching, so two-target closure,
  three-target work, source selection, and downstream inference remain false.
- `gpcm-ordered-ratio-boundary-p1j-0.2.3.R` and
  `gpcm-ordered-ratio-boundary-p1j-record-0.2.3.md`: exact ordered
  `lambda_slow=mu`, `lambda_fast=mu*rho` transport. All 288 positive P1i
  points and all 672 P1h/P1g `rho=0` nesting rows pass their identity checks,
  but only 280 boundary `rho` derivatives are nonnegative. The likelihood
  boundary is identified while fixed-`mu` ratio profiles and face closure
  remain open.
- `gpcm-fixed-mu-ratio-profile-p1k-0.2.3.R` and
  `gpcm-fixed-mu-ratio-profile-p1k-record-0.2.3.md`: representative
  exact-high/near-high optimization of natural `rho` on `[0,1]` with explicit
  KKT signs. All 336 fits are eligible, but only 125/168 cells reproduce the
  same objective and coordinate; ten are objective-only matches and 33 retain
  competing tolerance-eligible KKT objectives. P1l supplies their subsequent
  mechanism classification; reflections and face closure remain open.
- `gpcm-fixed-rho-basin-continuation-p1l-0.2.3.R` and
  `gpcm-fixed-rho-basin-continuation-p1l-record-0.2.3.md`: scoped two-direction
  nuisance continuation over an eleven-point natural-`rho` base grid plus the
  P1k returned points. All 766 objective-discordant and 260 coordinate-only
  lane fits pass. At common `rho`, all 43 cells coalesce to one nuisance
  solution. The objective lane contains 22 maximum brackets, six minimum
  brackets, and five monotone-increasing profiles; all ten coordinate-only
  cells are minimum brackets. This is finite-grid mechanism evidence, not a
  continuous profile, reflected-fixture, or face certificate.
- `gpcm-profile-turning-point-p1m-0.2.3.R` and
  `gpcm-profile-turning-point-p1m-record-0.2.3.md`: four deterministically
  selected representatives for the P1l maximum, minimum, monotone, and
  coordinate-only-minimum mechanisms. All 87 strict points pass; three
  turning brackets narrow below `7.2e-8`, two starts coalesce, and nuisance
  Hessians are positive definite. The monotone representative remains
  increasing on nine points. Local mechanisms are supported, while continuous
  monotonicity, global profile certification, reflection, and inference remain
  false.
- `gpcm-category-reflection-transport-p1n-0.2.3.R` and
  `gpcm-category-reflection-transport-p1n-record-0.2.3.md`: exact algebraic and
  numerical transport of the four P1m local mechanisms to the exact-low and
  near-low fixtures. All 87 stored points preserve marginal objective,
  mirrored posterior, and transformed gradient without refitting; four
  independent numeric-gradient checks also pass. This closes reflected
  representative transport only. Full finite-grid transport, continuous
  profile closure, face closure, and inference remain false.
- `gpcm-reflected-finite-grid-registry-p1o-0.2.3.R` and
  `gpcm-reflected-finite-grid-registry-p1o-record-0.2.3.md`: no-refit transport
  of all 1,362 stored P1k/P1l points into a 336-cell, four-fixture registry.
  The finite-grid portfolio is complete and every identity passes; continuous
  ratio-profile, face-closure, and inference flags remain false.
- `gpcm-release-scope-disposition-p1p-0.2.3.R` and
  `gpcm-release-scope-disposition-p1p-record-0.2.3.md`: no-fit binding of P1o
  to the public GPCM registry and 106-row claim portfolio. It retains the
  finite-grid claim, defers an unadvertised continuous ratio theorem, preserves
  fit/DFF fallbacks, and selects `gpcm_owner_evidence_partition` as the next
  GPCM release-spine blocker without authorizing simulation or promotion.
- `gpcm-owner-identity-propagation-p1q-0.2.3.R` and
  `gpcm-owner-identity-propagation-p1q-record-0.2.3.md`: no-fit audit of the
  sealed Draft.66 120-row owner bundle and 120 checkpoints. It distinguishes
  intact historical row identity from incomplete self-description in frozen
  aggregates, constructs a non-mutating seven-surface identity envelope, and
  records that the fixed-standard-normal MML pilot does not represent the
  current `free_population` default. No additional simulation is needed for
  identity transport; current-default owner evidence and row 88 remain open.
- `gpcm-owner-current-default-contract-p1r-0.2.3.R` and
  `gpcm-owner-current-default-contract-p1r-record-0.2.3.md`: no-fit prospective
  contract for two source-owner datasets crossed with two fit owners and two
  estimators. Its eight routes explicitly separate JML Person coordinates from
  `free_population` MML, retain exact 1--4 support and runtime identity on 13
  future surfaces, and fail closed on pairing, scale, support, content-hash, or
  authority drift. P1s subsequently executed the admitted smoke; P1r remains
  the immutable prospective contract.
- `gpcm-owner-current-default-smoke-p1s-0.2.3.R` and
  `gpcm-owner-current-default-smoke-p1s-record-0.2.3.md`: completed eight-route
  current-default identity smoke. All fits, all route identity checks, and all
  12 required public evidence surfaces pass. The run also exposed and led to
  correction of recycled nonlinear-block selection in the GPCM MML
  estimability audit. All eight fits remain review-only and zero are inference
  ready, so row 88, recovery, owner ranking, external comparison, additional
  replication, broad simulation, fit/DFF promotion, and confirmation remain
  open or unauthorized.
- `gpcm-owner-external-reproducibility-preflight-p1t-0.2.3.R` and
  `gpcm-owner-external-reproducibility-preflight-p1t-record-0.2.3.md`: no-fit
  source/version-bound classification of the admitted P1s eight-route
  denominator against ConQuest, TAM, immer, and sirt. All 32 full
  route-by-program cells are unsupported, lack an established exact route,
  reduce to PCM, or use a non-equivalent kernel. Five separately labelled
  projection/near-neighbour lanes remain, but none authorizes execution or a
  P1s external-reproduction claim.
- `gpcm-nonlinear-local-estimability-p1u-record-0.2.3.md`: implementation and
  mathematical record for the estimator-specific retained-point rank
  classifier. It separates the JML conditional adjacent-logit certificate,
  the MML observed-pattern sufficient subset certificate, and exhaustive MML
  fallback from global identification, weak information, boundary, and
  readiness claims. The admitted P1s fits are not rerun or reclassified.
- `gpcm-jml-fixed-objective-boundary-classification-p1v-record-0.2.3.md`:
  implementation and decision record for the JML-GPCM boundary classifier. It
  combines slope-only recession and competitive joint-boundary results under
  the exact unpenalized no-box JML objective, distinguishes finite optimizer
  traces from finite maxima, and keeps negative, numerical, workload,
  unit-slope, PJML, finite-box, and MML states separate.
- `gpcm-jml-terminal-gradient-stability-p1w-record-0.2.3.md`: implementation
  and decision record for the fixed-objective JML-GPCM terminal-gradient
  audit. It reconciles the retained objective, analytic and selected numeric
  score coordinates, optimizer/polish diagnostics, and parameter-block norms;
  makes certified boundary paths primary; and limits negative cases to local
  retained-point first-order evidence without freezing a scientific threshold
  or changing readiness, inference, recovery, or FACETS comparison status.
- `gpcm-jml-general-rate-boundary-p1x-record-0.2.3.md`: derivation,
  implementation, and decision record for the canonical constant-rate
  extension of the joint JML-GPCM boundary audit. It proves the finite
  positive/zero/leading-negative/deeper-negative partition, retains the
  ordered-pair reduction, supplies a pair-negative/general-positive direct
  likelihood example, and keeps workload, curved-path, MML, inference,
  recovery, and FACETS boundaries fail-closed.
- `gpcm-jml-asymptotically-affine-transport-p1y-record-0.2.3.md`: positive-
  only theorem, production implementation, and counterexample record for
  carrying certified constant-rate JML-GPCM boundaries to curved paths with
  vanishing additive and sum-zero log-slope residuals. A zero-rate oscillation
  proves that bounded nonvanishing residuals cannot share this conclusion;
  negative curved-path, MML, inference, and FACETS claims remain false.
- `gpcm-jml-boundary-compactification-p1z-record-0.2.3.md`: structural theorem,
  production audit, and direct construction record for reducing arbitrary
  unbounded finite-dimensional JML-GPCM parameter sequences to convergent
  normalized subsequences and finite primary P/Z/L/D slope-role patterns. It
  separately demonstrates an unresolved divergent secondary scale inside a
  zero primary-rate coordinate and therefore makes no global boundary,
  curved-path, MML, inference, readiness, or FACETS claim.
- `gpcm-jml-rate-hierarchy-p2a-record-0.2.3.md`: finite-depth lexicographic
  decomposition of declared expanded sum-zero log-slope rate stages. It proves
  the sharp `J-1` slope-coordinate depth bound, verifies that slower
  active-coordinate restrictions need not themselves sum to zero, and gives
  two common-primary paths with different secondary slope roles and likelihood
  limits. Additive hierarchies, arbitrary-path likelihood classification,
  MML, inference, readiness, and FACETS claims remain false or open.
- `gpcm-jml-lexicographic-limit-p2b-record-0.2.3.md`: analytic declared-path
  likelihood limits for at most two positive-power stages in each JML-GPCM
  log-slope and cumulative-utility block. It verifies infinite-, zero-, and
  finite-slope regimes plus direct finite-distance convergence while keeping
  path extraction, parameter-space reachability, remainders, global boundary,
  MML, inference, readiness, and FACETS claims false or open.
- `gpcm-jml-parameter-path-reachability-p2c-record-0.2.3.md`: forward
  retained-design reachability for caller-declared free-additive coordinate
  paths. It maps constrained coordinates to adjacent and cumulative utilities,
  verifies basis transport, reconstructs current-fit P2b inputs, and avoids a
  tolerance-dependent inverse projection. Production path extraction,
  arbitrary utility inversion, remainder-stable ties, global boundary, MML,
  inference, readiness, and FACETS claims remain false or open.
- `gpcm-jml-sequence-remainder-diagnostic-p2d-record-0.2.3.md`: transient
  optimizer-stage endpoint accounting, finite Euclidean direction/scale
  description, and the narrow negative-power scaled-logit remainder theorem.
  It verifies that stage vectors do not persist in returned fits and that only
  declared vanishing within-row logit contrasts extend a completed P2c limit.
  Optimizer path extraction, certified scales, arbitrary utility/slope
  remainders, global boundary, MML, inference, readiness, and FACETS claims
  remain false or open.
- `gpcm-jml-parameter-sequence-flag-p2e-record-0.2.3.md`: exact nonlinear
  free-parameter to reference-logit-contrast mapping followed by a finite-
  dimensional further-subsequence flag theorem. It classifies bounded and
  scale-separated contrast-flag likelihood limits without assuming power-law
  scales, while production sequence extraction, common subsequence limits,
  competitiveness, finite-JMLE existence, global boundary, MML, inference,
  readiness, and FACETS claims remain false or open.
- `gpcm-jml-global-existence-p2f-record-0.2.3.md`: global finite-attainment
  and non-attainment adjudication for non-unit GPCM/JML. It certifies finite-
  JMLE nonexistence for parameter-reachable zero-supremum paths, free extreme-
  Person rays, and strict global additive recession cones. It also records the
  compact-upper-level-set implication of a complete boundary-limsup gap while
  refusing to treat P2e further-subsequence classification or a negative
  bounded search as a complete envelope. Finite existence in the remaining
  cases, MML, inference, readiness, and FACETS equivalence stay open.
- `gpcm-jml-exponential-balance-p2g-record-0.2.3.md`: exact finite
  exponential-sum classification for affine JML-GPCM slope--utility balance
  paths. It aggregates equal combined exponents before the P2e flag limit and
  uses bounded response-image parameter escapes as nonproperness witnesses.
  Production certifies the canonical zero-utility path only under an exact
  structural zero-offset check; nonzero anchors fail closed. The complete
  bounded-image escape family, finite attainment, MML, inference, readiness,
  and FACETS equivalence remain open.
- `gpcm-jml-response-quotient-closure-p2h-record-0.2.3.md`: exact binary
  two-Person/two-slope-owner counterexample showing that the finite response-
  equivalence quotient image need not be closed. A P2g path approaches a
  finite contrast target that an exact affine row relation excludes from the
  finite GPCM image. Fibre collapse alone is therefore insufficient; response-
  image boundary completion and a complete limsup envelope remain necessary.
  Competitiveness, finite-JMLE existence, MML, inference, readiness, and
  FACETS equivalence remain open.
- `gpcm-jml-binary-closure-envelope-p2i-record-0.2.3.md`: complete finite
  response-image, bounded-escape-axis, and likelihood-limsup envelope for the
  exact binary two-Person/two-slope-owner P2h operator. Positive success and
  failure mass in every cell gives an explicit nonseparated fixture whose
  independent optimum lies on a missing response boundary, proving finite-
  JMLE nonexistence. A guarded current-fit wrapper reconstructs the exact
  operator and masses without changing stored production status. General
  GPCM closure, MML, inference, readiness, and FACETS equivalence remain open.
- `gpcm-jml-response-image-face-chart-p2j-record-0.2.3.md`: general fixed
  zero-offset finite-image chart using positive inverse-slope feasibility,
  complete necessary simplex-face enumeration, and sufficient first-order
  finite-path lifts. It exactly recovers P2i while a three-owner rank-one
  counterexample proves that a nonnegative face alone is not sufficient for
  general closure membership. Higher-order lifts, nonzero offsets, the complete
  general likelihood envelope, MML, inference, readiness, and FACETS
  equivalence remain open.
- `gpcm-jml-higher-order-face-lifts-p2k-record-0.2.3.md`: exhaustive ordered
  inverse-slope-owner rate hierarchies for targetwise closure membership in a
  fixed zero-offset operator. Linear leading-coefficient systems either build
  explicit product-one finite paths or, when every hierarchy is strictly
  excluded, certify that the target lies outside the closure. It resolves P2j
  first-order-open faces without weakening earlier P2j certificates. Symbolic
  whole-operator strata, the boundary likelihood envelope, MML, inference,
  readiness, and FACETS equivalence remain open.
- `gpcm-jml-saturated-response-envelope-p2l-record-0.2.3.md`: positive-mass
  ordered-category saturated-response theorem for a fixed zero-offset GPCM
  operator. The unique independent adjacent-logit optimum is passed to P2j/P2k:
  a finite-image target certifies a finite global JMLE, while a missing closure
  target gives an exact nonattained supremum and a finite product-one path. An
  outside-closure target has a constrained maximum strictly below the saturated
  bound, but its value and finite representability remain open. The mass matrix
  is a grouped-row representation of the existing ordered likelihood, not a
  new nominal, count, or frequency-response family; production, MML, inference,
  readiness, and FACETS equivalence remain unchanged.
- `maxit-ceiling-contract-0.2.3.R` and
  `maxit-ceiling-stable-slice-audit-0.2.3.md`: repository-only attempt-registry
  validator and evidence record enforcing a prespecified increasing ceiling
  prefix, fixed specification identity, individual-fit readiness, and
  first-eligible-run selection. Unit/runtime evidence is complete; row 8 stays
  in review until the same rule is applied to the exact candidate.
- `readiness-propagation-stable-slice-audit-0.2.3.md`: deterministic retained-
  core RSM/PCM record showing exact v3 readiness provenance through manifest,
  export, replay, results, report, checklist, and APA routes, plus the real
  frozen-0.2.2 saved-fit migration and current-development fresh-session replay
  result. Unresolved parameter, lower-adapter, and exact-candidate blockers
  keep checklist row 23 in review.
- `generate-legacy-0.2.2-fixture.R` and
  `../../tests/testthat/fixtures/mfrm-fit-0.2.2-pcm-jml.rds`: hash-guarded
  generator and compact real fit serialized under the frozen 0.2.2 tarball.
- `validate-legacy-0.2.2-replay-roundtrip.R`: installs the current development
  source in a temporary library, executes the generated replay in a fresh R
  session, and requires independent readiness recomputation plus a source/new
  mismatch warning.
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
- `generalized-mfrm-model-ladder-0.2.3.md`: pre-M2 model-family and evidence-
  dependency refinement. It names the current aligned single-owner relative-
  slope GPCM, separates criterion- and rater-owned evidence, defines the four
  required model-identity axes, and keeps multiplicative, multidimensional,
  response-style, interaction, and local-dependence families outside the
  current claim. Draft.63 adopts its scenario strata as evidence keys without
  promoting any gate or adding a likelihood.
- `gpcm-model-identity-contract-0.2.3.csv`: hashed machine-readable Draft.63
  mapping used by the historical Draft.66 owner execution. It retains that
  run's estimator/ability-scale identity and must not be rewritten as if the
  sealed MML pilot used today's default. P1r/P1s are the current-default
  owner/scale/support overlay; guarded generalized-MFRM strata remain here as
  explicit non-claim rows.
- `gpcm-owner-specific-pilot-0.2.3.R`: Draft.64--66 repository-only runner for
  identity-stamped criterion-owned and rater-owned aligned GPCM smoke/pilot
  cells across JML/MML and support-topology controls. It provides deterministic
  shards, atomic one-row checkpoints, strict resume/completion validation, and
  planned-denominator Monte Carlo summaries. The primary pilot is fixed at
  `maxit = 400` and q=31; lower-node runs remain smoke-only or require a
  separately registered sensitivity identity. The smoke execution is a
  guarded software/evidence-schema check; the corrected 120-row pilot is
  complete as calibration evidence, while threshold freeze and confirmation
  remain unauthorized.
- `gpcm-owner-specific-execution-contract-0.2.3.md`: Draft.66 corrected pilot
  contract for the 24-cell/five-replicate manifest, non-adaptive stopping,
  failed-replicate denominators, MCSE/Wilson reporting, deterministic sharding,
  checkpoint identity, and hashed completion. It freezes execution structure,
  not a recovery threshold or a confirmation decision.
- `gpcm-owner-specific-pilot-record-0.2.3.md`: completed Draft.66 120-row
  calibration record. It documents the superseded Draft.65 internal-category
  recoding defect, the exact corrected identities and hashes, all failed-row
  denominators, Wilson/MCSE summaries, weak-link recovery signals, and the
  still-open boundary, integration, coverage, fit, DFF, and confirmation work.
- `gpcm-owner-jml-optimizer-sensitivity-0.2.3.R`: historical Draft.66
  common-data attribution runner. It crosses the 40 non-negative JML pilot
  datasets with fixed BFGS/L-BFGS-B policies, traces non-representable slope
  proposals, and writes a hashed calibration-only completion bundle. It is
  pinned to the completed Draft.66 runtime and cannot be silently reused as a
  current-runtime result.
- `gpcm-owner-jml-boundary-rejection-recheck-0.2.3.R`: Draft.67 full 40-row
  BFGS recheck after transactional parameter-cache updates and typed
  non-representable-slope line-search rejection. It requires the validated
  historical sensitivity bundle, retains exact data pairing, and records
  artifact retention separately from convergence and inference readiness.
- `gpcm-owner-jml-optimizer-attribution-record-0.2.3.md`: exact identity,
  optimizer-pair, expansion-trace, implementation, and recheck record. It
  distinguishes the recovered workload line-search accident from unresolved
  criterion weak-bridge boundary risk and promotes no threshold or gate.
- `gpcm-mml-integration-sensitivity-contract-0.2.3.md`: Draft.68 fixed
  q=31/61/91 direct-MML sensitivity contract over 40 exact owner-pilot
  datasets. It requires common q=91 likelihood evaluation, paired structural
  and Person-estimand differences, dataset-level checkpoints, complete
  denominators, and continued blocking of zero-common-Person controls.
- `gpcm-mml-integration-sensitivity-0.2.3.R`: identity-stamped Draft.68 runner
  implementing the 120-fit grid, common-grid reevaluation, finite-count/MCSE
  summaries, exact three-arm data pairing, atomic checkpoint/resume, and
  completion inventory. It cannot choose q adaptively or authorize
  confirmation.
- `gpcm-mml-integration-completion-validator-0.2.3.R`: independent post-run
  validator for the Draft.68 bundle. It recomputes the exact artifact
  inventory, regenerates the frozen dataset manifest, validates every atomic
  checkpoint, and verifies q-grid/data pairing without mutating the bundle.
- `gpcm-mml-integration-sensitivity-record-0.2.3.md`: completed calibration
  record showing material q=31-to-dense-grid structural and Person-estimand
  differences, nonmonotone optimizer review across node counts, close q=61
  common-grid objectives, and the remaining need for direct q61-to-q91
  parameter tolerance calibration on expanded independent data.
- `gpcm-mml-slope-boundary-contract-0.2.3.md`: Draft.69 mathematical and
  implementation contract for fixed-quadrature marginal GPCM slope-path
  instrumentation. It derives the nodewise sufficient condition, boundary
  likelihood reconstruction, exhaustive ordered-pair scope, fail-closed
  limits, and explicit prohibition on continuous-integral, finite-MLE, or
  readiness claims.
- `gpcm-mml-slope-boundary-implementation-record-0.2.3.md`: exact Draft.69
  runtime/source/test identities, positive and negative controls, direct
  likelihood-path oracle results, distribution-check provenance, limitations,
  and the then-pending cross-q owner calibration.
- `gpcm-mml-boundary-grid-calibration-contract-0.2.3.md`: Draft.70
  retrospective contract for applying the marginal slope-path instrument to
  the exact Draft.68 q=31/61/91 panel and directly comparing q61 with q91.
  It prohibits tolerance freeze, confirmation, and readiness use.
- `gpcm-mml-boundary-grid-calibration-0.2.3.R`: identity-stamped Draft.70
  runner with 40 atomic dataset checkpoints, q-grid state/direction/target
  comparisons, direct structural and Person-estimand differences, exact
  Draft.68 reproduction fields, and a complete SHA-256 inventory.
- `gpcm-mml-boundary-grid-completion-validator-0.2.3.R`: separately sourced
  validator that reconstructs the Draft.70 aggregates from checkpoints,
  verifies all 49 listed artifacts and the frozen manifest/source panel, and
  rechecks the non-confirmation controls.
- `gpcm-mml-boundary-grid-calibration-record-0.2.3.md`: completed Draft.70
  record. All 120 arms are none-certified and stable across q, the Draft.68
  likelihoods reproduce exactly, and direct q61-to-q91 differences are
  retained without converting the retrospective maxima into tolerances.
- `gpcm-mml-boundary-challenge-contract-0.2.3.md`: Draft.71 prospective
  deterministic challenge contract, frozen before dense-grid execution. It
  separates both owners' forward/reverse positives, mixed negatives, and
  zero-versus-`1e-8` discordant weights and prohibits expectation revision.
- `gpcm-mml-boundary-challenge-0.2.3.R`: identity-stamped 10-dataset/30-arm
  q=31/61/91 runner with deterministic input hashes, atomic checkpoints,
  frozen-expectation fields, and non-propagating readiness controls.
- `gpcm-mml-boundary-challenge-completion-validator-0.2.3.R`: independent
  validator for all 17 Draft.71 artifacts, regenerated deterministic inputs,
  checkpoint aggregates, expected q order, and non-promotion state.
- `gpcm-mml-boundary-challenge-record-0.2.3.md`: completed concern record.
  All 12 negative expectations pass, all 18 dense-grid positive expectations
  fail, and expanding Gaussian--Hermite node support explains why the q=5
  individual-response all-node certificate does not extend to q=31/61/91.
  Readiness propagation is blocked pending broader Person-marginal geometry.
- `gpcm-mml-person-marginal-path-contract-0.2.3.md`: Draft.72 corrective
  derivation for exact finite-q Person-marginal value, derivative, curvature,
  surviving-node boundary likelihood, leading tail coefficient, and the still-
  required compact-interval/tail proof with outward numerical bounds.
- `gpcm-mml-person-marginal-path-prototype-0.2.3.R`: non-production analytic
  oracle. It retains adverse observation/Person-node derivative counts,
  reconstructs the optimizer objective, and always returns false half-line,
  tail, and readiness flags.
- `gpcm-mml-person-marginal-path-prototype-record-0.2.3.md`: selected-point
  formula verification and mechanism record. Negative Person-node derivatives
  coexist with positive Person-marginal derivatives, and a generalized
  boundary/tail calculation recovers the dense-grid positive path without
  claiming the unsampled half-line.
- `gpcm-mml-continuous-binary-path-0.2.3.R`: repository-only numerical audit
  of an exact continuous-normal two-item binary GPCM half-line theorem. It
  compares the whole-line and symmetric paired integrals and checks the closed-
  form derivative without making the theorem depend on numerical integration.
- `gpcm-mml-continuous-binary-path-record-0.2.3.md`: derivation and bounded
  claim record. The discordant `(1, 0)` marginal increases strictly toward an
  unattained one-quarter boundary, while `(1, 1)` supplies the decreasing-sign
  counterexample; neither result propagates to fitted-object readiness.
- `gpcm-literature-to-contract-0.2.3.md`: source-grounded mathematical and
  implementation audit for the current bounded route, including the supplied
  generalized-MFRM memorandum corrections, the separation of Muraki MML-EM,
  unpenalized identified mfrmr JML, Wijayanto penalized JML, and finite-box
  JML, estimator-specific slope-scale qualification, DFF/fit/sparse-data
  implications, and recent literature.
- `facets-gpcm-jml-comparison-role-contract-0.2.3.R`: deterministic no-fit
  registry of seven estimator identities and eight comparison lanes. It makes
  FACETS PCM/JMLE the only direct common-estimand FACETS route, keeps Table 7
  discrimination diagnostic-only, and separates truth recovery, unit-slope
  reduction, extreme-status, PJML, finite-box JML, and MML sensitivities.
- `facets-gpcm-jml-comparison-role-contract-record-0.2.3.md`: source and
  decision record for that role contract. It binds the contract and focused
  tests while retaining zero external fits, no tolerance, and no GPCM
  promotion, simulation, or confirmation authority.
- `pcm-gpcm-jml-paired-calibration-0.2.3.R`: small repository-only paired
  calibration that fits PCM/JML and criterion-owned GPCM/JML to each of six
  identical four-category datasets under unit and moderate generating slopes.
  It records paired-data identity, readiness, typed likelihood differences,
  apparent fitted slope spread, and log-slope recovery without estimating a
  model-selection rate or authorizing promotion.
- `pcm-gpcm-jml-paired-calibration-record-0.2.3.md`: completed six-pair result
  record. PCM was inference-ready in all six fits and GPCM/JML in none; all
  likelihood gains therefore remain optimizer-trace evidence. FACETS remains
  a comparator for the PCM/JML side only.
- `pcm-gpcm-comparison-ademp-contract-0.2.3.R`: prospective no-fit registry
  for paired PCM/GPCM simulation. It separates JML and MML, exact and
  practical slope truth, both slope owners, readiness, recovery, held-out
  prediction, substantive consequences, gated information criteria, metric
  availability, and complete planned-pair failure denominators.
- `pcm-gpcm-comparison-ademp-contract-record-0.2.3.md`: design and authority
  record for the 16-condition, 27-metric covering registry. Smoke, the
  five-replicate feasibility pilot, broad simulation, model-selection
  evidence, FACETS execution, and confirmation all remain unauthorized.
- `rater-anchor-sparse-stress-pilot-0.2.3.R`: paired three-seed PCM/JML
  calibration crossing seven direct-Rater-anchor configurations with seven
  complete/sparse assignment designs. It separates direct-anchor rate from
  all-Rater common-link size, ratings per Person, anchor range coverage, and
  anchor-value error while preserving common truth and response identities.
- `rater-anchor-sparse-stress-pilot-record-0.2.3.md`: completed 147-fit record.
  Direct anchors could not identify a disconnected one-Rater-per-Person
  design; common links returned fits but did not remove extreme-Person holds;
  two Raters per Person restored many ready fits. Exact range-spanning 25%
  anchors advance only as a feasibility candidate, not a selected percentage.
- `rater-anchor-sparse-prospective-contract-0.2.3.R`: no-fit registry for the
  expanded 16-Rater PCM/JML stress. It fixes eight anchor conditions, seven
  complete/sparse networks, independent response and external-anchor seeds,
  exact resource accounting, paired denominators, and Pareto decision rules.
- `rater-anchor-sparse-prospective-contract-record-0.2.3.md`: structural and
  authority record for the 12-fit smoke and 560-fit feasibility manifests.
  Execution, broad simulation, confirmation, and operational percentage
  selection remain unauthorized.
- `rater-anchor-sparse-prospective-smoke-0.2.3.R`: explicit opt-in runner sealed
  to the 12-fit smoke manifest. It realizes independent external selection and
  value errors, preserves paired identities, audits assignment resources, and
  refuses the feasibility profile.
- `rater-anchor-sparse-prospective-smoke-record-0.2.3.md`: completed smoke
  record. All fits returned, but complete designs retained terminal-gradient
  review and sparse designs retained extreme-Person exclusions; 0/12 were
  inference-ready, so feasibility handoff remains closed.
- `rater-anchor-sparse-smoke-minimal-diagnostic-0.2.3.R`: bounded follow-up
  comparing only maxit 200/400 for the four complete smoke fits and tabulating
  existing sparse extreme-response patterns without refitting them.
- `rater-anchor-sparse-smoke-minimal-diagnostic-record-0.2.3.md`: stop record.
  More iterations changed no retained solution, while two Raters reduced nine
  endpoint-extreme Persons to three. It identifies, but does not resolve, the
  Person-readiness-versus-Rater-recovery estimand decision.
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
- `facets-multifacet-precision-contract-0.2.3.R`: prospective 16-row RSM/PCM
  JML registry that separates total facet dimensions, levels, row growth, and
  sparse topology. It requires eight requested decimals wherever FACETS output
  is configurable, validates the actual decimals written for each metric, and
  keeps displayed `|ZSTD| = 2` rows boundary-indeterminate only for output that
  remains fixed-precision. Its external runner is dry-run by default and
  requires explicit execution; scientific file-byte equality is never an
  acceptance criterion.
- `facets-multifacet-precision-contract-record-0.2.3.md`: completed internal
  six-fit smoke record for total facet counts 3, 4, and 5 at fixed 640-row
  information plus a FACETS 4.5.0 output-precision qualification. The external
  qualification confirms eight-decimal Measure/SE output but two-decimal
  MnSq/ZSTD/df output. A separate strict-convergence 3--5 facet run matched
  every expected element and RSM/PCM step coordinate and found at most 0.000435
  and 0.000268 logits difference, respectively. A five-seed candidate-linked
  pilot retained 29 of 30 convergence-eligible cases, with maxima 0.000633 and
  0.000363; return code zero no longer substitutes for achieved convergence.
  The full external registry, frozen confirmation, sparse/large designs, bias,
  and equivalence remain pending.
- `facets-multifacet-confirmation-design-0.2.3.R` and corresponding record:
  semantic, no-fit 30-seed-per-cell confirmation design for the fixed-
  information RSM/PCM 3--5 facet core. It freezes 180 expected cases, complete
  failed-run denominators, and MCSE rules without hashes, generated responses,
  fits, or external execution. The version-1 design preserves the pre-rule
  boundary and remains unopened.
- `facets-multifacet-acceptance-rule-0.2.3.R` and corresponding record:
  separately frozen, no-fit coordinate rule for that confirmation design.
  Every eligible element and step difference must be at most 0.005 logits,
  with only a machine-epsilon-scale inclusive-boundary allowance. The rule was
  not chosen from pilot maxima and requires neither hashes nor binary floating-
  point identity. Ineligible cases stay in the full denominator and prevent a
  complete-confirmation pass. Execution remains blocked pending an external
  execution adapter and separate authorization.
- `facets-multifacet-confirmation-runner-0.2.3.R` and corresponding record:
  no-fit semantic preflight and result reviewer for the same 180-case design.
  It reconstructs all 9,120 Element and 1,350 Step identities without opening
  responses, recomputes FACETS and mfrmr numerical eligibility instead of
  trusting a supplied flag, verifies coordinate arithmetic, and applies the
  frozen tolerance plus MCSE rules. Complete synthetic evidence exercises the
  entire contract but cannot establish external provenance or authorize a
  claim. Response generation and the confirmation execution adapter remain
  intentionally unimplemented and unauthorized.
- `facets-multifacet-pilot-adapter-0.2.3.R` and corresponding record:
  execution adapter restricted to the six already-open pilot seeds. Dry-run
  preflight creates no response or file; execution retains every Element and
  Step coordinate plus FACETS and mfrmr numerical telemetry, validates report-
  header version 4.5.0, and uses no file hash. Confirmation seeds are rejected.
  Its Windows launcher follows FACETS' native wait route. A local execution
  audit completed all 36 already-open RSM/PCM cases across three to five facets,
  reproduced the one expected FACETS convergence failure, and retained 1,771
  Element plus 267 Step coordinates for the other 35 cases. Every retained
  coordinate passed the separately frozen 0.005-logit rule. These are pilot-
  only checks; no confirmation response was opened and no replacement claim
  was made.
- `facets-rsm-pcm-stress-envelope-0.2.3.R` and corresponding record: six
  already-open truth-first designs separating 40,000-row capacity, distributed
  and weak-bridge sparsity, a typed disconnected negative control, and 10/30
  total facets. The adapter runs mfrmr independently of FACETS entrance state,
  retains coordinate-level recovery eligibility, and never treats one-seed
  Bias/RMSE as Monte Carlo evidence. A rerun qualified a short disposable
  system-TEMP route after a long-path F50 work-file failure, restored the
  bundled example and 640-row controls, and completed all 12 FACETS launches
  with return code zero. Six of ten connected FACETS fits met the frozen
  convergence contract; two of ten connected mfrmr fits passed the strict
  gradient gate; only the 10-facet PCM cell passed both. Its 228 Element and 18
  Step coordinates differed by at most 0.0001136842 and 0.00003751122 logits.
  The four sparse FACETS fits remained above their 0.01 score-residual rule, so
  their comparisons were withheld. Both disconnected mfrmr fits were rejected
  before optimization. Numeric ordering of FACETS score files now covers ten
  and 30 facets. A read-only fixed-point audit then reproduced every
  stored objective, matched selected analytic and numeric gradients within
  `3.76e-7`, and found at most `4.15e-5` logits one-coordinate local movement
  and `3.62e-13` relative objective improvement. It changes no readiness state
  or FACETS claim. An exact likelihood-replication transport then made the same
  ready PCM point fail the raw gate after two identical copies while preserving
  the MLE set. The record therefore narrows the next question to an observed-
  information parameter-displacement scale rather than more repetitions or a
  larger iteration ceiling. Dense correlated-information audits of the four
  10/30-facet fits found positive-definite Hessians, maximum displacement no
  larger than `4.14e-5` logits, at most 4.3% amplification over diagonal
  curvature, and exact replication invariance within `1e-12`. No displacement
  threshold was selected. A matrix-free implementation reproduced those four
  dense solutions within `3.49e-8` relatively and covered the large cases.
  Full-space sparse solves exposed roughly one-logit directions, but every
  maximum belonged to a Person already classified as JML-unbounded. A
  constraint-Jacobian guard then isolated those coordinates without mixing
  estimable Persons; all four boundary-conditioned sparse solves converged,
  with interior maximum movement from `2.17e-5` to `1.21e-4` logits. Centered
  or grouped mappings that mix boundary and estimable levels fail closed. This
  is numerical diagnosis only: it does not produce SEs, change readiness,
  select a threshold, or establish FACETS equivalence. A later unfiltered
  sensitivity run used `Newton = 0.5`; all four sparse FACETS fits then met the
  same declared convergence rule in 596--2,896 iterations. Weak-bridge PCM
  became the second joint comparison cell. All 1,034 FACETS coordinates were
  imported, five extreme Persons were separated as a boundary-policy stratum,
  and all 1,029 ordinary coordinates plus 30 Steps matched identity. The
  approximately 0.0135-logit Person/Rater difference followed the two weakly
  linked rater blocks and is not treated as floating-point noise.
- `facets-readiness-calibration-0.2.3.R` and corresponding record: dry-run by
  default, opened-seed-only calibration of numerical-readiness scales across
  six stress designs, RSM/PCM, and six seeds. The executed 72-case matrix
  retained all 12 typed disconnected rejections and 60 fits. All 60
  retained-point and boundary-conditioned displacement audits completed, while
  only six fits passed the fixed raw-gradient gate and all six changed gate
  result under exact likelihood replication. Mean element residual associated
  more strongly with conditional displacement than raw gradient (`0.842`
  versus `0.590`). Weak-bridge RSM produced a repeated upper tail up to
  `0.005882` logits; balanced F10/F30 cases stayed below `0.000065`. No
  threshold was selected, readiness was not changed, and confirmation remains
  unopened.
- `facets-jml-final-handoff-record-0.2.3.md`: final external handoff for the
  current RSM/PCM JML kernel. A fresh five-facet RSM/PCM sentinel reproduced
  the frozen scientific manifest and maxima (`0.0003622826` Element,
  `0.000210636` Step) exactly, without using file hashes or byte identity.
  Routine FACETS reruns now stop; the record lists the estimator, constraint,
  step/category, boundary, adapter, and version changes that would reopen the
  small sentinel. User-facing diagnostics and reporting are the next priority.
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
- `jml-extreme-profile-limit-contract-0.2.3.md`: draft.73 mathematical and
  output contract for profiling independently free typed extreme Persons to
  the extended JML likelihood supremum while denying a finite full-vector MLE
  or finite-item-bias-correction interpretation.
- `jml-extreme-profile-limit-prototype-0.2.3.R` and its record: repository-only
  RSM/PCM/aligned-owner-GPCM profile refit and finite-cap oracle. It preserves
  raw fits, rejects constraint-coupled extremes, has no readiness effect, and
  leaves recovery, uncertainty, external convention, and production gates
  open.
- `jml-extreme-profile-recovery-contract-0.2.3.md`: draft.74 paired structural
  recovery contract. It freezes raw finite JML and extended profile-limit as
  distinct estimator identities, excludes Person recovery, and keeps
  adjustment and finite-item bias correction as separate factors.
- `jml-extreme-profile-recovery-pilot-0.2.3.R` and its record: guarded
  90-dataset RSM/PCM/aligned Criterion-owned GPCM calibration across two
  exposure levels and three extreme fractions. It retains all paired
  structural rows, withholds profile uncertainty and evidence readiness, and
  selects no estimator or numeric threshold.
- `tam-immer-jml-mode-comparison-contract-0.2.3.md`: Draft.75 source and
  common-estimand contract for installed TAM 4.3-25, immer 1.5-13, and mfrmr
  RSM/PCM JML modes. It separates original raw eligibility, extreme-score
  adjustment, fuzzy Person/item estimating equations, and classical
  postscaling.
- `tam-immer-jml-mode-comparison-0.2.3.R` and its record: guarded 60-dataset
  pilot declaration plus completed four-dataset normalization smoke. It
  retains loaded-function hashes, every planned mode/failure/recovery row, and
  no-extreme/extreme software identities while keeping all results
  calibration-only and selecting no correction or tolerance.
- `tam-immer-jml-factor-stress-contract-0.2.3.md`: Draft.76 factor and metric
  contract for Persons, realized exposure, Raters, Criteria, categories,
  assignment density, workload imbalance, endpoint rates, local dependence,
  anchors, and missingness. It distinguishes response endpoints from extreme
  Persons and correct-model recovery from misspecification robustness.
- `tam-immer-jml-factor-stress-0.2.3.R` and its smoke record: completed
  22-dataset RSM/PCM feasibility smoke plus the now-executed guarded
  290-dataset pilot manifest. It
  keeps bias, RMSE, rank recovery, truth-SD/RMSE recovery separation, fit
  return, finite output, engine-labelled convergence, and evidence eligibility
  separate. Common-surface coverage and reported facet separation remain
  unavailable until covariance and definition contracts are aligned; anchor
  cells stop before fitting until a common anchor basis exists.
- `tam-immer-jml-factor-checkpoint-contract-0.2.3.md`: Draft.77 atomic
  dataset-checkpoint, execution-identity, resume, and completion-marker
  contract. Existing, unexpected, stale, mutated, or incomplete payloads fail
  closed and a complete resumed run must reconstruct the same aggregate hash.
- `tam-immer-jml-factor-pilot-record-0.2.3.md`: completed 290-dataset
  five-replicate calibration record with 230 fitted cells, 40 structural
  negative controls, 20 anchor guards, 2,070 method rows, and 39,406 metric
  rows. It records factor aliasing, correction traces, method-specific
  reference ratios, and the continuing no-threshold/no-selection boundary.
- `tam-immer-jml-factor-pilot-review-0.2.3.R`: deterministic descriptive
  review of mode accounting, metric eligibility, factor/mode/facet summaries,
  reference RMSE ratios, rank/separation summaries, and common-cell correction
  comparisons. Cross-mode summaries remain diagnostics, not a pooled estimand.
- `tam-immer-jml-connected-design-contract-0.2.3.md` and
  `tam-immer-jml-connected-design-0.2.3.R`: Draft.78 bridge-Person and
  Rater-graph contract plus deterministic 36-dataset RSM/PCM structural smoke.
  Assigned and observed graphs retain absolute bridge count, degree, density,
  workload, components, shared-Person edge weights, and weighted algebraic
  connectivity; fixed-degree and fixed-density slices remain conditional
  contrasts.
- `tam-immer-jml-connected-design-record-0.2.3.md`: completed Draft.78 record
  with 30 connected nine-mode cells and six fail-closed structural negatives.
  It establishes a usable low-exposure topology but freezes no bridge cutoff,
  sample-size rule, correction, method ranking, or readiness state.
- `tam-immer-jml-topology-calibration-contract-0.2.3.md` and
  `tam-immer-jml-topology-calibration-0.2.3.R`: Draft.79 matched path, cycle,
  distributed, and hub bridge allocations plus adversarial one-link loss,
  graph-vulnerability metrics, atomic dataset checkpoints, exact resume, and a
  guarded five-replicate manifest.
- `tam-immer-jml-topology-calibration-record-0.2.3.md`: completed 36-dataset
  structural smoke with 30 connected nine-mode cells, six fail-closed observed-
  disconnected controls, and an independently reconstructed completion marker.
  The unchanged replicated performance manifest remains unexecuted because
  every connected smoke cell has natural extreme Persons and TAM convergence
  evidence remains an iteration-ceiling proxy.
- `gtheory-reconstruction-roadmap-0.2.3.md`: Draft.80 typed observed-score
  G-theory/D-study reconstruction contract. It separates arbitrary mixed-model
  syntax from object/facet/nesting/stratum/effect-map semantics; defines
  component-specific crossed, nested, allocation, interval, boundary, and
  multivariate covariance gates; and preserves the current simplified public
  helpers without broadening 0.2.3 support.
- `gtheory-design-algebra-contract-0.2.3.md`,
  `gtheory-design-algebra-prototype-0.2.3.R`, and
  `gtheory-design-algebra-record-0.2.3.md`: Draft.81 repository-only
  random-intercept parser, typed effect-map builder, and component-wise
  balanced p x i / p x r x i D-study oracle. It retains original nesting
  syntax, raw negative components, and fail-closed unresolved/alias states;
  it fits no model and changes no public helper.
- `gtheory-balanced-estimation-contract-0.2.3.md`,
  `gtheory-balanced-estimation-prototype-0.2.3.R`, and
  `gtheory-balanced-estimation-record-0.2.3.md`: Draft.82 complete balanced
  p x i / p x r x i ANOVA/MoM and matched `lme4` REML/ML prototype. It keeps
  raw negative MoM, constrained likelihood boundary, typed interaction, and
  current collapsed-residual identities separate; all interval, inference,
  decision, nested, imbalanced, and missing-data claims remain open.
- `gtheory-design-incidence-contract-0.2.3.md`,
  `gtheory-design-incidence-audit-0.2.3.R`, and
  `gtheory-design-incidence-record-0.2.3.md`: Draft.83a pre-fit observed-design
  audit for canonical row/missingness identity, conditional nested levels,
  global and pairwise connectivity, workload, cell replication, and
  fixed-effect-equivalent component-rank increments. It marks estimation
  eligibility unadjudicated and never forms a coefficient or decision-ready
  result.
- `gtheory-allocation-operator-contract-0.2.3.md`,
  `gtheory-allocation-operator-prototype-0.2.3.R`, and
  `gtheory-allocation-operator-record-0.2.3.md`: Draft.83b component-specific
  planned-weight D-study algebra. It reduces to Draft.81 under uniform crossed
  weights, uses conditional nested identities, preserves unequal unit results
  and cross-unit sharing, and never treats transformed supplied components as
  fitted, inferential, or decision-ready evidence.
- `gtheory-covariance-information-contract-0.2.3.md`,
  `gtheory-covariance-information-audit-0.2.3.R`, and
  `gtheory-covariance-information-record-0.2.3.md`: Draft.83c1 covariance-
  derivative and ML/REML expected-information rank audit plus exact-retained-
  row lme4 point-fit binding. Structural covariance rank, incidence
  connectivity, likelihood information, optimizer convergence, singularity,
  and boundary regularity remain separate gates; no interval, coefficient, or
  decision-ready claim is added.
- `gtheory-glmmtmb-parity-contract-0.2.3.md`,
  `gtheory-glmmtmb-parity-prototype-0.2.3.R`, and
  `gtheory-glmmtmb-parity-record-0.2.3.md`: Draft.83c2 exact-retained-row,
  matched Gaussian ML/REML glmmTMB/lme4 point-estimation comparison. Interior
  crossed and nested fixtures agree under recorded smoke tolerances; a
  positive-definite glmmTMB Hessian does not override a near-zero boundary or
  material backend disagreement. No backend is selected and no recovery,
  interval, coefficient, or public support claim is added.
- `gtheory-ademp-registry-contract-0.2.3.md`,
  `gtheory-ademp-registry-prototype-0.2.3.R`, and
  `gtheory-ademp-registry-record-0.2.3.md`: Draft.83d1 pre-simulation ADEMP
  registry, estimand/metric routing, paired smoke manifest, and exact failure-
  denominator schema. Gaussian truth, finite observed-score projection,
  missingness/local-dependence sensitivity, boundary/identification controls,
  and blocked anchor semantics remain distinct. It runs no recovery
  simulation and freezes no interval or replication count.
- `gtheory-ademp-generator-contract-0.2.3.md`,
  `gtheory-ademp-generator-prototype-0.2.3.R`, and
  `gtheory-ademp-generator-record-0.2.3.md`: Draft.83d2a deterministic
  generation layer for all 24 registry identities. Twenty-two scenarios
  produce separately hashed full-potential, assigned, and analysis tables;
  two nonzero-anchor scenarios return typed blocks. Exact assignment,
  workload, bounded-score projection, missingness, local dependence, boundary,
  nesting, and negative-control audits pass, but no backend fit, recovery,
  interval, replication-count freeze, or support claim is made.
- `gtheory-ademp-prefit-contract-0.2.3.md`,
  `gtheory-ademp-prefit-prototype-0.2.3.R`, and
  `gtheory-ademp-prefit-record-0.2.3.md`: Draft.83d2b0 exact scalable
  structural pre-fit layer. Equality-pattern signatures reproduce feasible
  dense covariance-rank results, audit the N=300 cell without dense derivative
  matrices, and bind 19 eligible/3 blocked scenarios to 77 eligible/12 blocked
  manifest units. No fit is authorized and no recovery or inference result is
  recorded.
- `gtheory-ademp-fit-contract-0.2.3.md`,
  `gtheory-ademp-fit-prototype-0.2.3.R`, and
  `gtheory-ademp-fit-record-0.2.3.md`: Draft.83d2b1 atomic point-fit execution
  across all 89 manifest units. All 77 eligible attempts return and all 12
  blocked units remain backend-free typed failures, but the near-zero variance
  control yields four false-ready rows. Atomic accounting passes while the
  zero-false-ready gate fails; recovery and inference remain blocked.
- `gtheory-weak-information-calibration-contract-0.2.3.md`,
  `gtheory-weak-information-calibration-prototype-0.2.3.R`, and
  `gtheory-weak-information-calibration-record-0.2.3.md`: Draft.83d2b2a
  truth-blind observable-diagnostic registry and 120-unit covering smoke.
  Atomic accounting passes, while the prior whole-model gate produces 27/40
  false-ready negative controls and 3/12 false-block positive controls. These
  one-replicate counts reject that gate as a component-resolution rule but do
  not freeze a threshold, minimum design, or operating characteristic.
- `gtheory-weak-information-pilot-contract-0.2.3.md`,
  `gtheory-weak-information-pilot-prototype-0.2.3.R`, and
  `gtheory-weak-information-pilot-record-0.2.3.md`: Draft.83d2b2b0 replicated
  pilot-plan and authorization firewall. Disjoint schema, feasibility,
  calibration, and confirmation seed bands preserve scenario-replicate
  independence and four-method pairing. A 24-fit schema run passes, while the
  historical 3,000-fit feasibility identity was superseded before execution
  and the 12,000-fit calibration and 24,000-fit confirmation phases remain
  blocked. No rule is selected.
- `gtheory-weak-information-inference-audit-0.2.3.md`,
  `gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R`, and
  `gtheory-weak-information-diagnostic-refit-record-0.2.3.md`:
  Draft.83d2b2b1a source-audited boundary-inference correction and viewed-
  schema full/reduced refits. The former common target-relative-SE candidate
  is withdrawn; raw ML/REML likelihood differences and backend-coordinate
  local scales remain noninferential diagnostics. All 24 pairs return, while
  the historical feasibility authorization is superseded before any reserved
  seed is generated. A replacement bootstrap contract is required.
- `gtheory-weak-information-bootstrap-contract-0.2.3.md`,
  `gtheory-weak-information-bootstrap-prototype-0.2.3.R`, and
  `gtheory-weak-information-bootstrap-record-0.2.3.md`: Draft.83d2b2b1b
  exact-observed-design fitted-null parametric-bootstrap mechanics. The
  12-route, `B=3` schema executes 96 full/reduced fits, preserves every design
  and generated-response identity, and implements failure-aware plus-one
  bounds. It is explicitly not finite-sample exact or operating-
  characteristic evidence; resolution feasibility, production bootstrap
  calibration, and all inference/readiness flags remain blocked.
- `gtheory-weak-information-feasibility-contract-0.2.3.md`,
  `gtheory-weak-information-feasibility-prototype-0.2.3.R`, and
  `gtheory-weak-information-feasibility-record-0.2.3.md`: Draft.83d2b2b1c
  replacement 3,000-row/6,000-fit descriptive-feasibility manifest, all-cell
  viewed runtime telemetry, pair/dataset checkpoint contract, and narrow
  execution authorization. No replicate-101--125 dataset is generated. The
  120-pair runtime schema returns every route while retaining nine unavailable
  common scores and timing as non-deterministic planning evidence.
- `gtheory-weak-information-feasibility-runner-contract-0.2.3.md`,
  `gtheory-weak-information-feasibility-runner-0.2.3.R`, and
  `gtheory-weak-information-feasibility-execution-record-0.2.3.md`:
  Draft.83d2b2b1d atomic execution of all 3,000 authorized pairs and 750
  untouched replicate-101--125 datasets. A full resume reuses every route and
  reproduces the scientific hash. Common-score availability is 2,804/3,000;
  high-information material-negative likelihood differences and few-level
  nuisance boundaries/weak ordering block any threshold or calibration
  promotion. `FeasibilityEvidenceReady` means exact descriptive accounting
  only; all inferential and D-study decision flags remain false.
- `gtheory-weak-information-numerical-sensitivity-contract-0.2.3.md`,
  `gtheory-weak-information-numerical-sensitivity-0.2.3.R`, and
  `gtheory-weak-information-numerical-sensitivity-record-0.2.3.md`:
  Draft.83d2b2b1e three-profile numerical audit of the already viewed 3,000
  routes. All 9,000 profile pairs and 750 markers resume exactly. Same-
  algorithm tightening is identical; lme4 bobyqa and glmmTMB BFGS behave in
  opposite directions. Seven non-finite default replays were not defined by
  the frozen finite-difference gate, so numerical-sensitivity and every
  downstream readiness flag remain false.
- `gtheory-weak-information-typed-replay-contract-0.2.3.md`,
  `gtheory-weak-information-typed-replay-0.2.3.R`, and
  `gtheory-weak-information-typed-replay-record-0.2.3.md`:
  Draft.83d2b2b1f no-refit adjudication of the immutable b1d and b1e ledgers.
  It records 2,993 finite matches, seven same-typed `NA_real_` diagnostic
  states, and zero mismatches. `TypedReplayAdjudicationReady=TRUE` closes only
  the missing state definition; b1e replay, numerical stabilization,
  numerical-sensitivity evidence, calibration, and decisions remain false.
- `gtheory-weak-information-glmmtmb-stabilization-contract-0.2.3.md`,
  `gtheory-weak-information-glmmtmb-stabilization-prototype-0.2.3.R`, and
  `gtheory-weak-information-glmmtmb-stabilization-record-0.2.3.md`:
  Draft.83d2b2b1g prospective six-profile DAG and exact 9,000-pair manifest
  for the 1,500 viewed glmmTMB routes. It binds all ten start blocks,
  same-model parent lineage, gradients, Richardson Hessians, and typed parent
  failure without selecting a cutoff. The manifest is ready; runner,
  execution, stabilization evidence, calibration, and decisions are not.
- `gtheory-weak-information-glmmtmb-stabilization-runner-contract-0.2.3.md`,
  `gtheory-weak-information-glmmtmb-stabilization-runner-0.2.3.R`, and
  `gtheory-weak-information-glmmtmb-stabilization-smoke-record-0.2.3.md`:
  Draft.83d2b2b1g1 atomic six-profile base-route runner and 120-pair viewed
  covering smoke. Twenty checkpoints and ten markers resume exactly. The
  complete denominator includes 84 diagnostic-complete, 21 finite material-
  negative, 11 non-finite, and four fit/dependency rows. Strict fixed-
  coordinate snapshot failure in two BFGS fits blocks full execution; no
  tolerance, optimizer, stabilization rule, or downstream readiness is added.
- `gtheory-weak-information-glmmtmb-alignment-contract-0.2.3.md`,
  `gtheory-weak-information-glmmtmb-alignment-runner-0.2.3.R`, and
  `gtheory-weak-information-glmmtmb-alignment-smoke-record-0.2.3.md`:
  Draft.83d2b2b1g2 deterministic fixed-coordinate alignment and exact replay
  of the same 120-pair denominator. All 240 returned fits align, all 80
  dependent transfers verify, and no-fit resume reproduces. Four b1g1 returns
  are recovered without changing common returned objectives, likelihoods, or
  top-level parameter hashes. Fourteen non-finite and 21 material-negative
  rows retain the numerical blocker; full execution and downstream readiness
  remain false.
- `gtheory-weak-information-glmmtmb-numerical-adjudication-contract-0.2.3.md`,
  `gtheory-weak-information-glmmtmb-numerical-adjudication-0.2.3.R`, and
  `gtheory-weak-information-glmmtmb-numerical-adjudication-record-0.2.3.md`:
  Draft.83d2b2b1g3 no-refit multi-axis adjudication of the exact b1g2 ledger.
  All 120 raw full/reduced objectives are finite; 14 pairwise reported
  likelihoods are curvature-masked under installed glmmTMB semantics. One
  nonzero optimizer code, two gradient-surface hash mismatches, exact
  sdreport/Richardson curvature agreement, the complete signed objective
  partition, and 20 best-observed six-profile envelopes remain separate.
  Stationarity, global optimality, full execution, and downstream readiness
  remain false.
- `gtheory-weak-information-glmmtmb-stationarity-instrumentation-contract-0.2.3.md`,
  `gtheory-weak-information-glmmtmb-stationarity-instrumentation-0.2.3.R`, and
  `gtheory-weak-information-glmmtmb-stationarity-instrumentation-record-0.2.3.md`:
  Draft.83d2b2b1g4 prospective raw-derivative replay and threshold-free
  cross-profile adjudication. All 240 fits retain content-addressed parameter,
  gradient, and Richardson sidecars; b1g2 fitted values and repeated
  derivative hashes reproduce, and no-fit resume is exact. Spectral Hessian
  positivity (224) remains separate from numerical Cholesky availability
  (221) and direct Newton-step availability (218). Raw, objective-relative,
  lme4-compatible, and Newton-type quantities remain distinct; no observed
  value selects a cutoff or optimizer. Stationarity, full execution,
  calibration, inference, and downstream readiness remain false.
- `gtheory-weak-information-glmmtmb-stationarity-calibration-design-contract-0.2.3.md`,
  `gtheory-weak-information-glmmtmb-stationarity-calibration-design-0.2.3.R`,
  and
  `gtheory-weak-information-glmmtmb-stationarity-calibration-design-record-0.2.3.md`:
  Draft.83d2b2b1g5 sealed calibration design. Finite stationarity, curvature,
  profiled boundary limits, and statistical resolution are separate. Affine
  fixtures verify Hessian-inertia and Newton-decrement identities. The
  3,000-dataset reservation maps prospectively to 144,000 candidate fits and
  24,000 reference problems, but no data, tolerance, rule, or downstream
  execution is authorized.
- `gtheory-weak-information-glmmtmb-stationarity-reference-calibration-contract-0.2.3.md`,
  `gtheory-weak-information-glmmtmb-stationarity-reference-calibration-0.2.3.R`,
  and
  `gtheory-weak-information-glmmtmb-stationarity-reference-calibration-record-0.2.3.md`:
  Draft.83d2b2b1g6 analytic calibration and nonreserved reference replay.
  An AD-independent central-difference ladder estimates componentwise
  numerical resolution without using the AD gradient to choose its step, and
  a hashed TMB random-effect start anchor removes evaluation-order dependence.
  Six analytic objectives recover minimum, flat, saddle, and boundary states;
  all four full/reduced objectives on nonreserved replicates 901--902 pass
  three-algorithm consensus, derivative, curvature, nuisance-stationary
  boundary-profile, and sidecar-integrity checks. Reference mechanics are now
  frozen, but the stationarity rule, reserved calibration, full stabilization,
  bootstrap, inference, and D-study decisions remain unauthorized.
- `gtheory-weak-information-stationarity-calibration-authorization-audit-contract-0.2.3.md`,
  `gtheory-weak-information-stationarity-calibration-authorization-audit-0.2.3.R`,
  and
  `gtheory-weak-information-stationarity-calibration-authorization-audit-record-0.2.3.md`:
  Draft.83d2b2b1g7 fail-closed preauthorization audit. It retains six glmmTMB
  and three lme4 profiles, correcting the prospective candidate-fit upper
  bound from 144,000 to 108,000 while leaving 24,000 reference problems
  unchanged. It freezes truth-blind candidate-state precedence and per-role
  objective-only profile aggregation. Reference mechanics are ready for only
  glmmTMB REML; acceptance policy, production boundary probe, runner, reserved
  calibration 201--300, confirmation, inference, and D-study decisions remain
  unauthorized.
- `gtheory-weak-information-glmmtmb-ml-reference-coverage-contract-0.2.3.md`,
  `gtheory-weak-information-glmmtmb-ml-reference-coverage-0.2.3.R`, and
  `gtheory-weak-information-glmmtmb-ml-reference-coverage-record-0.2.3.md`:
  Draft.83d2b2b1g8 nonreserved glmmTMB ML method-coverage replay. It binds
  `REML=FALSE` and ML identity at contract, manifest, row, and sidecar levels,
  reuses the b1g6 mechanics by exact function hash, and evaluates the same
  generated data on a distinct likelihood surface. All four objectives and
  both full-model boundary profiles pass, and a second complete replay is
  identical. Reference coverage advances to two of four lanes; lme4 ML/REML,
  calibration authorization, stationarity, inference, and D-study decisions
  remain false.
- `gtheory-weak-information-lme4-objective-reference-preflight-contract-0.2.3.md`,
  `gtheory-weak-information-lme4-objective-reference-preflight-0.2.3.R`, and
  `gtheory-weak-information-lme4-objective-reference-preflight-record-0.2.3.md`:
  Draft.83d2b2b1g9 analytic lme4 objective preflight. A dense Gaussian oracle
  independently reproduces theta-only profiled ML/REML objectives, analytic
  gradients, fit-criterion accessors, evaluation-order stability, and exact-
  zero full-to-reduced identities. Source-hashed controls exclude `devfun2()`
  and `deviance(..., REML=TRUE)` as REML references in lme4 2.0.6. No
  nonreserved data are read; the box solver, boundary profile, lme4 replay,
  complete method coverage, calibration, inference, and D-study decisions
  remain false.
- `gtheory-weak-information-lme4-reference-coverage-contract-0.2.3.md`,
  `gtheory-weak-information-lme4-reference-coverage-0.2.3.R`, and
  `gtheory-weak-information-lme4-reference-coverage-record-0.2.3.md`:
  Draft.83d2b2b1g10 nonreserved lme4 ML/REML reference replay. Three
  box-constrained algorithms, a sparse independent Gaussian oracle, analytic
  Newton polishing, raw KKT, free curvature, and seven-point nuisance-
  reoptimized theta profiles pass for all eight full/reduced objectives on
  replicates 901--902. A second replay is exact, closing four-of-four method
  lanes. Calibration authorization, production stationarity, inference, and
  D-study decisions remain false.
- `gtheory-weak-information-stationarity-acceptance-policy-contract-0.2.3.md`,
  `gtheory-weak-information-stationarity-acceptance-policy-0.2.3.R`, and
  `gtheory-weak-information-stationarity-acceptance-policy-record-0.2.3.md`:
  Draft.83d2b2b1g11 truth-blind policy freeze. Three primary score families
  crossed with eight existing zones give 24 candidates. Safety false ready,
  false boundary handoff, false unready, missed boundary, indeterminate,
  not-evaluable, and reference-unresolved states retain separate primary-cell
  accounting and one-sided exact-binomial bounds. An always-indeterminate
  candidate cannot pass required decisive-class coverage. The policy and
  four-lane receipts are frozen, but the production boundary probe, runner,
  application threshold, calibration, confirmation, inference, and D-study
  decisions remain false or unauthorized.
- `gtheory-weak-information-production-boundary-probe-contract-0.2.3.md`,
  `gtheory-weak-information-production-boundary-probe-0.2.3.R`, and
  `gtheory-weak-information-production-boundary-probe-record-0.2.3.md`:
  Draft.83d2b2b1g12 production boundary mechanics. lme4 theta zero and
  glmmTMB log-SD limits retain coordinate-specific profiles; a common boundary
  route requires nuisance reoptimization, monotone material improvement, and
  full-profile/reduced-fit endpoint agreement. Flat, nonmonotone, mismatched,
  and failed profiles remain typed. Eight tests with 120 expectations pass,
  including lme4/glmmTMB x ML/REML fixtures. The runner, reserved calibration,
  application threshold, confirmation, inference, and D-study decisions
  remain false or unauthorized.
- `gtheory-weak-information-stationarity-exact-resume-runner-contract-0.2.3.md`,
  `gtheory-weak-information-stationarity-exact-resume-runner-0.2.3.R`, and
  `gtheory-weak-information-stationarity-exact-resume-runner-record-0.2.3.md`:
  Draft.83d2b2b1g13 exact-resume mechanics. One dataset-method checkpoint
  contains every backend profile, both model roles, both references, and all
  48 candidate decisions. Complete typed failure denominators, checkpoint and
  dataset-marker integrity, three-unit interruption/resume, cold-run equality,
  complete reuse, and corrupted-checkpoint repair pass in nine tests with 129
  expectations on nonreserved fixtures 901--902. The sealed 201--300 workload
  is countable but remains unexecutable; production evaluator adapters, its
  reserved run manifest, threshold selection, confirmation, inference, and
  D-study decisions remain false or unauthorized.
- `gtheory-weak-information-production-adapter-preflight-contract-0.2.3.md`,
  `gtheory-weak-information-production-adapter-preflight-0.2.3.R`, and
  `gtheory-weak-information-production-adapter-preflight-record-0.2.3.md`:
  Draft.83d2b2b1g14 response-free production preflight. The real
  lme4/glmmTMB x ML/REML candidate/reference adapters complete one
  nonreserved four-unit dry-run with exact 36-fit, 192-decision, and
  eight-reference ledgers; one typed `start_snapshot` failure is retained.
  Runtime, package, adapter, dependency, output-root, unit, and 100-shard
  identities are frozen for the exact 3,000-dataset workload. Every reserved
  shard remains `ExecutionAuthorized=FALSE`; calibration, threshold,
  confirmation, inference, and D-study decisions remain false or
  unauthorized.
- `gtheory-weak-information-one-way-authorization-preflight-contract-0.2.3.md`,
  `gtheory-weak-information-one-way-authorization-preflight-0.2.3.R`, and
  `gtheory-weak-information-one-way-authorization-preflight-record-0.2.3.md`:
  Draft.83d2b2b1g15 response-free authorization-readiness preflight. One
  hundred prospective shard manifests exactly partition the sealed workload
  but remain non-executable. The actual frozen output parent passes target-
  absence, write, same-directory checked rename, identical readback, cleanup,
  and capacity checks; conservative disk/time planning fixes one concurrent
  shard and prohibits early stopping. Readiness and activation eligibility do
  not issue an authorization record: replicate 201, calibration results,
  threshold selection, confirmation, inference, and D-study decisions remain
  false or unauthorized.
- `gtheory-weak-information-monte-carlo-value-audit-contract-0.2.3.md`,
  `gtheory-weak-information-monte-carlo-value-audit-0.2.3.R`, and
  `gtheory-weak-information-monte-carlo-value-audit-record-0.2.3.md`:
  Draft.83d2b2b1g15a response-free purpose/precision audit. It separates
  3,000 independent datasets and 100 planned trials per primary cell from
  dependent optimizer, candidate, and reference rows. Complete-denominator
  binomial MCSE, zero-event upper bounds, event-detection probabilities,
  paired-method precision, and future fixed-n illustrations reproduce. The
  current design is retained for numerical-rule calibration only; achieved
  precision, broad bias/RMSE/coverage, D-study operating characteristics,
  authorization, and inference remain false or unavailable.
- `gtheory-weak-information-preactivation-hardening-audit-contract-0.2.3.md`,
  `gtheory-weak-information-preactivation-hardening-audit-0.2.3.R`, and
  `gtheory-weak-information-preactivation-hardening-audit-record-0.2.3.md`:
  Draft.83d2b2b1g16 response-free execution hardening audit. It proves that
  the actual 9,756 phase-specific seed rows are unique, then uses nonreserved
  replicate 901 to show that the current generator changes under a different
  ambient RNG kind despite the same integer seed. It also separates portable
  blocker identity from site-specific runtime snapshots and records missing
  runtime, thread, process, reserved-runner, writer-lock, activation-root, and
  per-shard-capacity contracts. Eight required gates block activation;
  `LargeSimulationMayStart=FALSE`, and no calibration or confirmation response
  is generated or inspected.
- `gtheory-weak-information-rng-hardened-generator-contract-0.2.3.md`,
  `gtheory-weak-information-rng-hardened-generator-0.2.3.R`, and
  `gtheory-weak-information-rng-hardened-generator-record-0.2.3.md`:
  Draft.83d2b2b1g17 nonreserved generator repair. A separately versioned
  wrapper leaves the historical counterexample intact while explicitly fixing
  and recording uniform, normal, and sample RNG kinds, retaining the parent
  generator identity, and restoring caller state. All 30 scenarios at
  replicate 901 agree across Mersenne-Twister and Wichmann-Hill caller states;
  existing/no-seed/error restoration and identity mutation controls pass.
  Reserved replicates are rejected. `HardenedGeneratorReady=TRUE` is
  component-local: adapters are not rebased, `AuthorizationRNG01Closed=FALSE`,
  `LargeSimulationMayStart=FALSE`, and no reserved response is generated.
- `gtheory-weak-information-hardened-adapter-rebase-contract-0.2.3.md`,
  `gtheory-weak-information-hardened-adapter-rebase-0.2.3.R`, and
  `gtheory-weak-information-hardened-adapter-rebase-record-0.2.3.md`:
  Draft.83d2b2b1g18 paired nonreserved production-adapter rebase. A new
  descendant preparation and candidate/reference path uses the b1g17 generator
  without modifying b1g14. Historical and hardened replicate-902 four-lane
  executions agree on all numerical, state, selection, failure-denominator,
  and reference-state fields after excluding identity columns that must change.
  The hardened path retains 36 fits, 192 decisions, eight references, one typed
  fit failure, zero unresolved references, and exact four-unit reuse.
  `NonreservedAdapterRebaseReady=TRUE`, but reserved-manifest rebase is
  deferred, `AuthorizationRNG01Closed=FALSE`, and no reserved response opens.
- `gtheory-weak-information-hardened-reserved-lineage-contract-0.2.3.md`,
  `gtheory-weak-information-hardened-reserved-lineage-0.2.3.R`, and
  `gtheory-weak-information-hardened-reserved-lineage-record-0.2.3.md`:
  Draft.83d2b2b1g19 response-free reserved-lineage rebase. The b1g14 workload
  and shard partition reduce exactly, while each of 12,000 atomic-unit and 100
  shard identities is recomputed with the hardened adapter/generator lineage.
  Historical hashes remain explicit provenance and do not enter the active
  registry. The 100 prospective manifests independently validate with response
  generation, fitting, execution, output creation, and confirmation use false.
  `ReservedManifestRebaseReady=TRUE` is narrow: no reserved adapter entry
  point, extended runtime, or locked runner exists, so authorization and large
  simulation remain false and replicate 201 remains sealed.
- `gtheory-weak-information-authorization-kernel-contract-0.2.3.md`,
  `gtheory-weak-information-authorization-kernel-0.2.3.R`,
  `gtheory-weak-information-authorization-kernel-worker-0.2.3.R`, and
  `gtheory-weak-information-authorization-kernel-record-0.2.3.md`:
  Draft.83d2b2b1g20 consolidates shared preactivation infrastructure instead
  of adding another model-specific gate. A reproducible isolated runtime,
  explicit serial thread state, exclusive lock, initial/exact-resume marker,
  unmarked-root rejection, and fresh filesystem/capacity probe pass. Nine
  common gates are ready; only the actual reserved runner and separate
  authorization record block. No response is generated and the target remains
  absent. This is the stopping point for infrastructure-only decomposition.
- `gtheory-weak-information-guarded-shard-runner-contract-0.2.3.md`,
  `gtheory-weak-information-guarded-shard-runner-0.2.3.R`,
  `gtheory-weak-information-guarded-shard-runner-worker-0.2.3.R`, and
  `gtheory-weak-information-guarded-shard-runner-record-0.2.3.md`:
  Draft.83d2b2b1g21 joins the real four-lane hardened evaluator/checkpoint
  path to the isolated runtime, exclusive lock, and activation marker. A
  nonreserved replicate-902 first run and exact resume preserve complete
  denominators and b1g18 semantic results. `RUNNER-01` passes, while reserved
  and confirmation replicates still fail before generation and
  `AUTH-RECORD-01` remains the sole activation blocker.
- `gtheory-weak-information-execution-authorization-decision-contract-0.2.3.md`,
  `gtheory-weak-information-execution-authorization-decision-0.2.3.R`, and
  `gtheory-weak-information-execution-authorization-decision-record-0.2.3.md`:
  Draft.83d2b2b1g22 performs the explicit response-free go/no-go audit and
  returns `no_go_refused_not_issued`. Exact-source inspection refines the
  coarse b1g21 blocker: `RESERVED-ENTRY-01`, `ACTIVE-MANIFEST-01`, and
  `SITE-RECEIPT-01` remain absent. No authorization, response, fit, or reserved
  root is created; replicate 201 and large simulation stay prohibited.
- `gtheory-weak-information-record-bound-entry-point-contract-0.2.3.md`,
  `gtheory-weak-information-record-bound-entry-point-0.2.3.R`,
  `gtheory-weak-information-record-bound-entry-point-worker-0.2.3.R`, and
  `gtheory-weak-information-record-bound-entry-point-record-0.2.3.md`:
  Draft.83d2b2b1g23 implements and nonreserved-reduces the three-level
  generator/adapter/runner record-bound entry and exact R0201 active-manifest
  conversion. Four tests with 75 assertions pass, but no production record,
  active R0201 object, response, root, or lock exists. Fresh runtime/site
  evidence and a separate six-gate one-shard issuance decision remain required.
- `gtheory-weak-information-one-shard-issuance-contract-0.2.3.md`,
  `gtheory-weak-information-one-shard-issuance-0.2.3.R`, and
  `gtheory-weak-information-one-shard-issuance-record-0.2.3.md`:
  Draft.83d2b2b1g24 refreshes exact runtime/site evidence and recomputes all
  six b1g23 issuance gates. One observed GO issues only R0201 and derives its
  unexecuted active manifest; an occupied-target control remains a hash-valid
  NO-GO and cannot issue. No response, fit, checkpoint, root, or lock is
  created, and large simulation remains prohibited pending complete R0201
  execution and review.
- `gtheory-multivariate-algebra-contract-0.2.3.md`,
  `gtheory-multivariate-algebra-prototype-0.2.3.R`, and
  `gtheory-multivariate-algebra-record-0.2.3.md`: future Draft.85a0 supplied-
  matrix preflight. Effect-specific covariance and prospective allocation Gram
  matrices form universe, relative-error, and absolute-error covariance before
  weighted composite G/Phi. Common/partial/independent facet sharing, exact
  one-stratum reduction, PSD/rank, and invalid-matrix controls are tested, but
  no covariance is estimated and no public multivariate claim is added.
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
- `jml-solver-normalization-pilot-0.2.3.R` and
  `jml-solver-normalization-worker-0.2.3.R`: draft.58 guarded six-source scale
  ladder, original-scale post-solve verification, fresh-process reproduction,
  and real child-process deadline controls. Normalization and solver candidacy
  are separate decisions, and neither route can change a production result.
- `jml-solver-normalization-pilot-record-0.2.3.md`: hashed draft.58 record of
  144/144 provenance-safe rows, 66/72 raw versus 72/72 L1-normalized qualified
  rows, 12/12 fresh-process matches, 4/4 deadline controls, a bounded
  normalization candidate, and explicit no-solver/no-dispatch/no-confirmation
  decisions.
- `jml-target-positive-cone-pilot-0.2.3.R`: draft.59 guarded 400-Person
  complete, balanced-sparse, and random-sparse RSM/GPCM topology pairs. It
  separates safe evidence completion from normalization qualification, binds
  ordinary/capture fit identities, and uses timeout-zero only as a post-failure
  attribution reference.
- `jml-target-positive-cone-pilot-record-0.2.3.md`: hashed draft.59 record of
  3/3 topology/exposure matches, 64/64 safe solver rows, 61/64 provenance rows,
  one ordinary/capture RSM joint-state divergence, three of ten timeout-
  reference outcome changes, rejected target-scale normalization, and a new
  recession-replay investigation requirement.
- `jml-recession-replay-policy-pilot-0.2.3.R`: draft.60 guarded fresh-process
  replay of seven exact draft.59 problems under current two-second, bounded
  retry, bounded single-ten-second, and OS-bounded native-zero policies. It
  journals capacity and strictness separately, validates every status-zero
  solution on the original scale, and supports identity-bound checkpoint
  reuse without permitting production selection.
- `jml-recession-replay-policy-worker-0.2.3.R`: isolated draft.60 worker with
  stage-attempt journals and an independent parent-process deadline.
- `jml-recession-replay-policy-pilot-record-0.2.3.md`: hashed draft.60 record
  of 112/112 completed and safe fresh processes, 27/28 stable cells, reproduced
  two-second capacity/strictness instability, two bounded policies qualified
  only for fit-level continuation, and explicit no-selection/no-production-
  change/no-confirmation decisions.
- `jml-recession-fit-policy-pilot-0.2.3.R`: draft.61 guarded full-fit policy
  comparison over the six exact draft.59 RSM/GPCM routes. It captures every
  target call after optimization, rotates four policy orders across three
  fresh-process repetitions, verifies input/optimizer/semantic identities,
  and applies a prespecified attempt-count consequence rule without using
  elapsed time for selection.
- `jml-recession-fit-policy-worker-0.2.3.R`: isolated draft.61 worker that
  installs a validation-only target-LP policy, journals every solver attempt,
  restores the namespace binding, and remains independently bounded by its
  parent process.
- `jml-recession-fit-policy-pilot-record-0.2.3.md`: hashed draft.61 record of
  72/72 completed and safe fits, 23/24 stable policy-by-route cells, only 4/6
  current-policy reference matches, two 6/6 qualified candidates, and the
  prespecified selection of single-ten-second as an implementation candidate.
  Production change, blocker closure, runtime freeze, and confirmation remain
  false.
- `jml-recession-native-policy-validation-0.2.3.R`: draft.62 guarded native
  production-policy validation over the same six target-scale routes and three
  fresh-process repetitions. It observes target calls without replacing the
  production policy and compares complete result and call-outcome identities
  with the selected draft.61 candidate.
- `jml-recession-native-policy-regression-0.2.3.R`: draft.62 sharded full
  non-CRAN regression runner and fail-closed aggregator. It binds the complete
  test inventory, runner source, installed candidate, per-file outcomes, and
  warning ledger before publishing a completion marker.
- `jml-recession-native-policy-validation-record-0.2.3.md`: draft.62 source-
  and candidate-linked implementation record. It resolves only the additive
  JML recession replay blocker after native route identity, affected unit,
  full-regression, and exact-tarball package checks; runtime/capacity,
  nonlinear GPCM, PCA, ADEMP, and confirmation remain open.
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
- `external-comparison-eligibility-contract-0.2.3.R`: repository-only
  row-level admission contract for external metrics. It verifies exact
  family/estimator/correction/penalty/finite-box and
  data/facet/category/anchor/coordinate/identification/boundary/source-
  precision identities, then separates eligible, rejected, missing, failed,
  and unexpected rows before aggregation.
- `external-comparison-eligibility-contract-record-0.2.3.md`: hash-bound
  structural-review record for 25 disposition fixtures across
  ConQuest, FACETS, TAM, immer, and sirt. Passing fixtures do not close
  checklist row 64; program-specific bindings and the WP7 pilot remain
  outstanding.
- `conquest-external-comparison-normalizer-0.2.3.R`: repository-only adapter
  from the source-bound native additive four-arm review to the common
  eligibility ledger. It creates the 36-row expected registry before reading
  differences and retains missing, failed, unexpected, and rejected rows.
- `conquest-external-comparison-normalizer-record-0.2.3.md`: actual retained-
  output binding record. All 36 ConQuest rows are finite. They remain rejected
  for the hidden-solution stratum but are structurally eligible under the
  separately validated exact reported-decimal stratum.
- `conquest-reported-output-precision-contract-0.2.3.R` and its companion
  record: SHA-bound lexical-decimal policy for ConQuest native files. It binds
  each of the 36 retained tokens and file hashes, treats only the written
  decimal as an exact estimand, and leaves file rounding, hidden precision,
  tolerance, candidate comparison, and equivalence unresolved.
- `conquest-binary-external-comparison-normalizer-0.2.3.R`: prospective
  Binary q31/q61 adapter over 18 registered rows: population intercept, slope,
  variance, five free item difficulties, and deviance per arm. It requires
  exact history/export token agreement and audited item-label order when
  native files are supplied. With no retained Binary bundle, all 18 rows stay
  explicitly missing and ineligible.
- `conquest-six-arm-coverage-contract-0.2.3.R` and its companion record:
  canonical 54-coordinate `Binary/RSM/PCM x q31/q61` implementation registry.
  It content-hashes the normalizer and exact reported-decimal coverage surfaces
  separately and records six implemented arms versus four arms with retained
  native calibration evidence. These hashes are mandatory prospective-binding
  identities, not evidence that the missing Binary outputs exist.
- `conquest-reported-point-likelihood-calibration-0.2.3.R` and its companion
  record: evaluates the retained exact RSM/PCM decimal coordinates on the
  independent additive q31/q61 likelihood, including Richardson gradients,
  Hessians, curvature distance, and same-point integration differences. It
  identifies the required clean core as six `Binary/RSM/PCM x q31/q61` arms
  and leaves the missing Binary native evidence, every tolerance, candidate
  binding, DFF/fit/ranking invariance, and equivalence open.
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
- `gpcm-nonunit-score-oracle-0.2.3.R`: repository-only independent non-unit
  GPCM slope/kernel/marginal-objective oracle at retained, high-dispersion,
  and two finite slope-stress points. It is calibration-only, freezes no
  general score tolerance, and never authorizes selection or confirmation.
- `gpcm-nonunit-score-oracle-record-0.2.3.md`: bounded record of the four-point
  non-unit GPCM oracle agreement, finite-difference step calibration,
  fail-closed tests, and the owner/category/topology cells that remain before
  rows 5--6 can leave review.
- `gpcm-score-calibration-design-0.2.3.R`: no-execution eight-cell design and
  fail-closed 128-row decision contract for Criterion/Rater-owned,
  five-category, paired deterministic core/weak-link/workload/category-
  imbalance GPCM score checks.
- `gpcm-score-calibration-design-contract-0.2.3.md`: mathematical rationale,
  five-point derivative ladder, parameter-class absolute/scaled/adaptive
  margin rules, Jacobian caps, and authorization boundary for that bounded
  calibration. It does not freeze the final general `NUM-SCORE-TOL`.
- `gpcm-score-calibration-runner-0.2.3.R`: identity-bound dry-run-by-default
  runner for the complete eight-cell/128-stratum score calibration. Execution
  requires explicit authorization and cannot promote readiness or confirmation.
- `gpcm-extreme-score-attribution-0.2.3.R`: post-result diagnostic that
  independently reconstructs the Person-posterior GPCM sufficient-statistic
  score when objective finite differences lose resolution at extreme slopes.
- `gpcm-score-calibration-v2-record-0.2.3.md`: negative calibration record.
  It retains the 128-row rejection, three extreme retained-slope traces,
  step-ladder attribution, 48-row independent analytic-score agreement, and
  the required finite-slope versus boundary-handoff split for v3.
- `gpcm-score-v3-rule-contract-0.2.3.R`: no-execution fail-closed v3 rule
  registry and 128-row decision schema. It separates the inclusive
  `max(abs(z)) <= 3` finite-slope validation envelope from non-promoting
  extreme-slope review and authorizes neither retrospective evaluation nor
  confirmation.
- `gpcm-score-v3-rule-contract-0.2.3.md`: mathematical interpretation of the
  combined absolute-plus-relative/numerical-error rules, applicability
  boundary, negative controls, and disjoint-confirmation requirement. V2
  remains rejected and no general score tolerance is frozen.
- `gpcm-score-v3-replay-runner-0.2.3.R`: exact-development-namespace,
  identity-bound, dry-run-by-default replay runner. It evaluates finite
  differences only inside the v3 slope envelope and records independent
  analytic scores plus 384 entrywise Jacobian comparisons across the same
  eight deterministic cells.
- `gpcm-score-v3-replay-record-0.2.3.md`: audit record for the random-tie
  reproducibility defect, invalidated pre-fix replay, corrected-payload v2
  rejection/analytic attribution, and completed v3 calibration pass. It
  preserves review-only extreme-slope handoffs and authorizes no confirmation.
- `gpcm-score-v3-freeze-contract-0.2.3.R`: no-fit source-bound freeze seal. It
  binds the numerical helper, eight other validation sources, the complete
  package payload, all retained v2/attribution/v3 artifacts, and every evidence
  denominator. It freezes the bounded rule only for disjoint confirmation and
  does not authorize opening confirmation data.
- `gpcm-score-v3-freeze-record-0.2.3.md`: mathematical and reproducibility
  review of the source-chain omission, superseding source-bound identities,
  unchanged numerical result, and the remaining disjoint-confirmation gate.
- `gpcm-score-v3-confirmation-design-0.2.3.R`: no-fit sealed fixture and
  denominator design for six disjoint exact-candidate cells. It fixes three
  deterministic fixture hashes, 96 evidence strata, 560 coordinates, 24
  points, and 376 Jacobian rows while keeping execution unauthorized.
- `gpcm-score-v3-confirmation-design-record-0.2.3.md`: separation rationale,
  fixed dimensions/hashes, complete denominators, and the fail-closed boundary
  before a record-consuming runner and separate authorization decision exist.
- `gpcm-score-v3-confirmation-runner-0.2.3.R`: dry-run-by-default execution
  kernel binding the sealed design and frozen v3 numerical machinery. It
  requires an exact separate authorization record and absent output target;
  its decision checks class- and point-specific denominators.
- `gpcm-score-v3-confirmation-authorization-0.2.3.R`: independent eleven-gate
  NO-GO/one-target issuance decision. Default calls cannot authorize or open
  confirmation; occupied targets and stale identities fail closed.
- `gpcm-score-v3-confirmation-entry-record-0.2.3.md`: source identities,
  negative-test coverage, actual `no_go_not_issued` state, and the one-fresh-
  process/no-retry boundary for any later execution.
- `gpcm-score-v3-confirmation-record-0.2.3.md`: complete one-time negative
  result. It records the 8.88e-16 inclusive-boundary representation failure,
  otherwise passing numerical components, review-only fits, and the missing
  saved authorization-row provenance that prevents acceptance reuse.
- `gpcm-score-v4-rule-contract-0.2.3.R`: prospective no-execution classifier
  applying an IEEE-754 forward-error allowance only to constructed inclusive-
  boundary points, retaining zero allowance for fitted solutions, and requiring
  exact consumed authorization provenance in future results.
- `gpcm-score-v4-rule-contract-0.2.3.md`: mathematical derivation, unchanged
  numerical-rule boundary, calibration/confirmation separation, and remaining
  review/freeze requirements for v4.
- `gpcm-score-v4-retrospective-calibration-0.2.3.R`: no-fit evaluator binding
  the immutable rejected v3 artifact, reconstructing all 24 slope vectors, and
  refusing to invent the missing boundary finite difference or authorization.
- `gpcm-score-v4-retrospective-calibration-record-0.2.3.md`: unique intended
  reclassification, retained-extreme invariance, incomplete numerical evidence,
  and the required new calibration-only completion fixture.
- `gpcm-score-v4-boundary-completion-design-0.2.3.R`: no-fit single-scenario
  calibration-only fixture sealing the missing 4/24/1/30 evidence denominator,
  full owner-category support, and permanent confirmation ineligibility.
- `gpcm-score-v4-boundary-completion-design-record-0.2.3.md`: fixture/source
  hashes, representation bound, non-reuse rule, and runner/authorization
  prerequisites before one-time completion execution.
- `gpcm-score-v4-boundary-completion-runner-0.2.3.R`: dry-run-by-default
  completion kernel that obtains the one missing finite difference, checks the
  complete 4/24/1/30 denominator, and embeds the consumed authorization row.
- `gpcm-score-v4-boundary-completion-authorization-0.2.3.R`: separate no-fit,
  same-process, exact-target issuance decision binding source, payload, rule,
  design, manifest, row hash, and target absence; default is NO-GO.
- `gpcm-score-v4-boundary-completion-entry-record-0.2.3.md`: exact runner,
  authorization, identity, and manifest hashes; 44 no-fit expectations; and
  the historical pre-execution one-fresh-process boundary.
- `gpcm-score-v4-boundary-completion-validator-0.2.3.R`: independent no-fit
  artifact/source/manifest/authorization/denominator validator, including
  issued- and consumed-row hashes, target resolution, and tamper rejection.
- `gpcm-score-v4-boundary-completion-result-record-0.2.3.md`: immutable result
  identity, complete 4/24/1/30 numerical pass, repository-relative target
  disclosure, review-only fit status, and the pre-freeze result interpretation.
- `gpcm-score-v4-freeze-contract-0.2.3.R`: no-fit six-source/two-artifact seal
  for the unchanged bounded rule, retrospective and completion evidence,
  authorization provenance, path-form disclosure, and non-promotion flags.
- `gpcm-score-v4-freeze-record-0.2.3.md`: mathematical freeze review, exact
  source/artifact identities, repository-relative target disclosure,
  bounded-rule scope, and permission to design—but not execute—new disjoint
  confirmation fixtures.
- `gpcm-score-v4-confirmation-design-0.2.3.R`: no-fit three-fixture/six-scenario
  v4 confirmation design with new identities, support/connectivity checks,
  sparse/load-imbalanced assignments, and fixed 96/888/24/688 denominators.
- `gpcm-score-v4-confirmation-design-record-0.2.3.md`: fixture hashes,
  disjointness audit, assignment/category coverage, absolute future-target
  requirement, and the still-closed execution boundary.
- `gpcm-score-v4-confirmation-runner-0.2.3.R`: dry-run-by-default confirmation
  kernel binding the six sealed scenarios and exact 96/888/24/688 denominator;
  execution requires an exact unconsumed same-process authorization row.
- `gpcm-score-v4-confirmation-authorization-0.2.3.R`: separate no-fit issuance
  decision binding source, payload, freeze, design, rule, replay, fixtures,
  manifest, prospective validator, absolute input path, target absence, and
  issued-row identity.
- `gpcm-score-v4-confirmation-validator-0.2.3.R`: runner-independent no-fit
  result validator sealed before execution; it reconstructs denominator,
  numerical aggregation, authorization hashes, absolute target, and all
  non-promotion decisions.
- `gpcm-score-v4-confirmation-entry-record-0.2.3.md`: source and manifest
  identities, 74 no-fit expectations, absolute-path-before-normalization rule,
  default NO-GO state, and the one-operation pre-execution boundary.
- `gpcm-score-v4-confirmation-retrospective-audit-0.2.3.R`: immutable-artifact
  no-fit audit separating complete numerical agreement from two blocked fits,
  the runner false-positive, and the sealed validator names-attribute defect.
- `gpcm-score-v4-confirmation-result-record-0.2.3.md`: artifact and
  authorization hashes, numerical maxima, six fit outcomes, authoritative
  rejection, no-retry rule, and non-promotion disposition.
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
  evidence, and output fingerprints without parsing the free-form report. Its
  `handoff_tolerance` controls only internal weight/history/export checks. The
  deprecated `export_tolerance` alias is not an export-resolution estimate or
  a cross-engine acceptance threshold; CSV rounding remains explicitly
  unknown.
- `external-ic-audit-0.2.3.R`: fixture checker for that normalizer, including
  a negative integration-comparison-identity case. A pass is unit/pilot
  evidence only and does not establish cross-engine likelihood equivalence.
- `conquest-numeric-resolution-contract-0.2.3.R` and its companion contract
  note:
  repository-only raw-token and file-SHA-256 audit for the five native
  ConQuest CSV outputs. It records lexical precision before floating-point
  conversion, never infers a rounding rule from displayed digits, and keeps
  lexical equality, numerical equality, established-resolution compatibility,
  tolerance passage, and scientific equivalence as separate states. The
  default remains `raw_tokens_retained_rounding_unestablished`.
- `conquest-additive-mfrm-design-0.2.3.R` and its companion contract note:
  no-fit complete-crossing Person/Rater/Criterion RSM/PCM design with fixed
  96-Person/384-observation input, q=31/q=61 arms, independent 7/9 free-
  dimension maps, native A-matrix requirement, raw-token handoff, and explicit
  `no_go_design_only` decision. It neither fits mfrmr nor launches ConQuest;
  the deliberately minimal 2-Rater/2-Criterion design keeps the strict MML
  all-pattern audit tractable; the connected sparse/unequal-workload microcase
  remains downstream.
- `conquest-additive-mfrm-reference-preflight-0.2.3.R` and its companion
  contract note: source-bound mfrmr-only q=31/q=61 RSM/PCM preflight for the
  reduced complete-crossing design. It reconstructs the marginal likelihood
  with an independent probability/Gauss-Hermite oracle, binds the full R
  source tree by SHA-256, and verifies full local rank across all 512 reused
  pattern/design evaluations. Four arms converge and agree with the oracle,
  while `InferenceReady = FALSE` remains explicit because the current policy
  treats the all-pattern result as local diagnostic evidence only. The
  source-only result stays `no_go_native_matrix_and_candidate_missing` and
  never launches ConQuest. The PCM reference exporter now distinguishes facet
  rows from Criterion-owned step rows and the validator rejects any nonfinite
  exported estimate.
- `conquest-additive-native-runtime-probe-record-0.2.3.md`: bounded native
  runtime correction against the SHA-matched installed ConQuest 5.47.5
  executable. Restricted launches crashed during registry/settings XML writes,
  but the user's Terminal run and the unsandboxed control completed normally.
  The controlling state is `runtime_available_unsandboxed`; sandbox failure is
  retained only as an environment-compatibility observation.
- `conquest-native-runtime-support-handoff-0.2.3.md`: unsent, data-free support
  handoff withdrawn after successful unsandboxed execution. It must not be
  sent as a ConQuest product-failure report.
- `conquest-additive-native-rsm-q31-review-0.2.3.R`,
  `conquest-additive-native-pcm-q31-review-0.2.3.R`, and
  `conquest-additive-native-four-arm-review-0.2.3.R`: read-only native-output
  reviewers. They verify command/input identity, exact 7/9-dimensional A-matrix
  bases, export labels and dimensions, raw-token retention, q31/q61 final-token
  identity, and descriptive differences from the source-bound reference. They
  also record that the history column named `LogLikelihood` contains positive
  deviance. They never launch ConQuest or infer a rounding rule, tolerance, or
  scientific equivalence.
- `conquest-additive-native-four-arm-record-0.2.3.md`: four completed RSM/PCM
  q31/q61 native arms and their corrected interpretation. All native A matrices
  are exact; maximum displayed coordinate differences from mfrmr are below
  `2.74e-6`, but the decision remains
  `four_arm_native_outputs_ready_tolerance_and_candidate_missing` because raw
  CSV rounding, a prespecified acceptance threshold, and candidate identity
  are absent.
- `conquest-additive-tolerance-adjudication-0.2.3.R` and its companion note:
  no-fit separation of representation, optimizer, integration,
  scientific-acceptance, and candidate-binding gates. Because the four-arm
  differences are already opened, the adjudicator allows them to inform a
  future candidate error budget but prohibits passing this same calibration
  under a newly chosen `EXT-CQ-TOL`. It retains the broad external claim as a
  future gate, restricts the current statement to descriptive calibration,
  and authorizes neither a candidate run nor a sparse/simulation extension.
- `conquest-prospective-tolerance-contract-0.2.3.R` and its companion record:
  fail-closed validator for a future pre-candidate tolerance freeze. It
  registers all 19 binary/RSM/PCM `EXT-CQ-TOL` rows and all 38 engine-specific
  `IC-INTEGRATION-TOL` rows, binds the canonical table hash and candidate
  identities plus the independently frozen exact reported-decimal source-
  precision policy before output exists, and makes the opened calibration
  permanently ineligible under any newly frozen rule. The generic empty
  template remains `pilot_required`.
- `conquest-prospective-tolerance-basis-0.2.3.md`,
  `conquest-prospective-tolerance-freeze-0.2.3.R`, and their companion record:
  source-bound canonical 57-row future-candidate table. Cross-engine common
  coordinates use symmetric `1e-5` limits, while cross-engine deviance and
  both integration units use `2e-6`. The opened calibration is ineligible,
  the table hash is frozen, and execution, hidden-solution or scientific
  equivalence, DFF/fit/rank invariance, sparse extension, simulation, and
  confirmation remain unauthorized.
- `conquest-six-arm-candidate-binding-0.2.3.R` and its companion record: exact
  pre-execution binding for corrected candidate 002. Candidate 001 is
  explicitly invalid because its RSM/PCM arms were item-only and omitted the
  Rater/Criterion estimands in the frozen table. The successor binds six
  q31/q61 command/input arms, an estimand-derived model-dimension registry, the
  ConQuest executable and source-precision identities, and 50 absent expected
  outputs including additive A matrices. Execution remains false pending the
  exact corrected-reference and handoff preflight. Numerical-reference
  readiness is kept distinct from, and cannot promote, inference readiness.
- `conquest-six-arm-candidate-reference-preflight-0.2.3.R` and its companion
  record: SHA-bound six-arm mfrmr q31/q61 references generated from the exact
  candidate pre-binding commit. RSM/PCM retain independent probability and
  marginal-likelihood oracles plus local full rank; Binary retains an explicit
  weaker converged/finite/internal-coordinate-consistency basis. Every
  within-engine integration row passes the frozen prospective budget, while
  all fits remain non-inference-ready. Its own execution flag remains false;
  only the successor handoff can issue the one-way native-run authorization.
- `conquest-six-arm-execution-handoff-0.2.3.R` and its companion record: exact
  one-way authorization for the six candidate-002 native runs. It binds the
  ConQuest executable, pre-handoff source, six working directories, stdin
  commands, combined console captures, and 50 absent outputs. Authorization is
  consumed by launch and does not authorize output reuse, comparison,
  equivalence, confirmation, sparse/GPCM extension, or simulation.
- `conquest-six-arm-execution-incident-0.2.3.R` and its companion record:
  machine-bound candidate-002 failure evidence. The first Binary arm returned
  process status zero but ConQuest rejected the generated C-style prose
  preamble and estimated no model. The remaining five arms were not launched;
  candidate 002 is non-reusable. The Binary command generator now emits
  command-only input; candidate 003 was subsequently rebuilt under that
  repaired protocol.
- `conquest-six-arm-candidate-003-binding-0.2.3.R`,
  `conquest-six-arm-candidate-003-reference-preflight-0.2.3.R`, and their
  companion records: post-incident source/command/model/input/empty-output
  binding plus six source-bound mfrmr numerical references. RSM/PCM retain
  independent probability and likelihood oracles; Binary retains its explicit
  weaker internal-coordinate basis. All references remain non-inference-ready.
- `conquest-six-arm-candidate-003-execution-handoff-0.2.3.R` and its companion
  record: ordered run-once authorization with a mandatory semantic-success
  gate after each arm. Status zero and `End of Program` are insufficient;
  frozen error patterns must be absent and every native output must be nonempty
  before the next arm can launch.
- `conquest-six-arm-candidate-003-execution-result-0.2.3.R` and its companion
  record: immutable binding for the completed six-arm run. All six semantic
  gates and all 50 outputs pass; the handoff is consumed and rerun is false.
- `conquest-six-arm-candidate-003-numerical-review-0.2.3.R` and its companion
  record: locale-independent 54-coordinate and 57-row exact-reported-decimal
  review. All 19 cross-engine and 38 q31/q61 integration rows pass the
  prospectively frozen table. Hidden-solution/scientific equivalence,
  inference readiness, DFF/fit/rank/ordering invariance, sparse/free-slope
  GPCM extension, large simulation, and release authorization remain false.
- `tam-mml-core-calibration-0.2.3.R` and its companion record: source- and
  TAM-4.3-25-function-bound RSM/PCM complete-crossing calibration. It makes the
  `constraint="cases"` location transformation explicit and retains 46
  transformed coordinate rows, q31/q61 integration movement, both deviances,
  and the mfrmr probability/marginal-likelihood oracle checks. The observed
  values inform a future prospective TAM tolerance only; no TAM tolerance,
  candidate, comparison pass, free-slope GPCM extension, or release decision
  is frozen.
- `immer-conditional-estimand-eligibility-0.2.3.R` and its companion record:
  loaded-function-bound 22-row CML/CCML boundary. Only exactly mapped item,
  step, criterion-step, and rater contrasts can enter a future structural
  reference. Conditioned-out Person/population quantities, unlike conditional
  or composite objectives, unresolved covariance bases, and non-estimated free
  slopes fail closed. No external fit, tolerance, candidate, native mfrmr
  CML/CCML capability, or comparison pass is created.
- `conquest-tam-immer-tolerance-source-audit-0.2.3.md`: version- and
  function-hash-bound review of the official ConQuest, TAM, and immer
  numerical controls. All three document within-fit stopping or integration
  settings, but none supplies a cross-engine scientific-equivalence threshold.
  The finding prevents optimizer tolerances from being recycled as
  `EXT-CQ-TOL`.
- `estimator-vocabulary-closure-record-0.2.3.md`: release-spine row 71
  structural closure. It keeps `MML` and `JML` as the two canonical fitting
  labels, retains `JMLE` only as an input alias, and prevents legacy `JMLE`
  fields from leaking through summary, print, manifest, or replay outputs.
  The closure changes no estimator or numerical result.
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
