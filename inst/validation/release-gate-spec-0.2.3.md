# mfrmr 0.2.3 release-gate specification

## Document state

| Field | Value |
| --- | --- |
| Target release | 0.2.3 |
| Specification ID | `0.2.3-draft.53` |
| Date | 2026-08-05 |
| Status | M1 is recorded and M2 remains in progress. Draft.45--49 supply MML metamorphic, portfolio, capacity, target-scale, and JML decomposition evidence; draft.50 attributes JML phases; draft.51 implements the guarded structural global-cone prescreen; and draft.52 attributes positive joint-cone work to ordinary free extreme Persons already typed by the sufficient-score audit. Draft.53 combines a verified known-Person row-and-coordinate quotient, guarded strict-cone screen, and common-scale selected-target nullspace rank ladder. The authoritative v8 fixed profile preserves all 19 v6 semantic/readiness/boundary/target-status comparisons, replaces 346 joint target LP calls with five quotient LP calls, reduces joint phase time 69.9% and JML outer time 50.0%, and records zero rank increment at three tolerances in all five exclusion routes. The completed v7 bundle is superseded because its rank ladder was hashed but not directly printed. A clean exact 491-entry local source tarball passes `R CMD check --no-manual` with `Status: OK`; this remains a change-local standard check, not an `--as-cran` or candidate gate pass. The performance result remains one-replicate calibration, not a frozen capacity or runtime rule. General RSM/GPCM and target-scale positive-quotient coverage, shared-geometry attribution, replicated optimizer controls, topology/exposure controls, ADEMP recovery/precision, isolated-process capacity, PCA computability, estimator-specific weak-information rules, metric-specific external eligibility, candidate identity, confirmation, and release engineering remain pending. No checklist row or numeric criterion is passed/frozen, and confirmation remains unauthorized. |
| Current draft delta | Draft.53 adds `mfrmr-jml-known-person-quotient-prescreen-v1` and `mfrmr-jml-selected-target-nullspace-screen-v1` inside the joint additive audit. Only Persons already classified as ordinary free low/high extremes are proposed; each coordinate must be a strict one-sided ray confined to that Person's rows and absent from selected targets. A negative quotient cone can skip target enumeration only when base and target-augmented sparse-QR ranks are stable and equal at `1e-12`, `1e-10`, and `1e-8`. Target-changing flat directions, tolerance sensitivity, mapping/ray/solver/rank failure, and execution limits retain the old enumeration or limit state. Legacy joint state and selected-target classifications are preserved. Phase schema v8 exposes LP and rank work directly and compares all 19 routes with v6. Draft.54 attributes remaining joint/structural time before any shared geometry, warm-start, solver, or optimizer-dispatch change. Public claims, portfolios, numeric thresholds, and confirmation authorization remain unchanged. |
| Confirmation authorized | No |
| Evidence checklist | `release-evidence-checklist-0.2.3.csv` |
| FACETS stress plan | `facets-jml-stress-plan-0.2.3.md` |
| TAM/immer stress plan | `tam-immer-estimator-stress-plan-0.2.3.md` |
| M1 review record | `release-gate-m1-review-0.2.3.md` |
| Public direction | Repository-root `ROADMAP.md` |
| Internal sequence | `internal-roadmap-0.2.3.md` |

This document turns the 0.2.3 roadmap into a testable gate contract. It is a
planning artifact, not evidence that any gate has passed. In particular,
numeric rows marked `pilot_required` must be calibrated on pilot data, changed
to `frozen_numeric`, and reviewed before any confirmatory result is viewed.
Until then, M2 remains incomplete and M3-M5 evidence cannot be generated.

The specification and checklist are repository evidence. `.Rbuildignore`
excludes `inst/validation` from the CRAN source package, so these protocols do
not add CRAN check time or create a public package API.

## Scope and non-scope

0.2.3 strengthens evidence for the existing single-observed-scale,
unidimensional `RSM`, `PCM`, and bounded-`GPCM` contract. It may add small
public fields or guards when needed to prevent an unsupported interpretation.
It does not add:

- native multidimensional latent-trait estimation or dimension scores;
- multiple observed `ScaleId` values or scale-specific PCM;
- threshold/step anchors or frozen-calibration operational scoring;
- unrestricted GPCM, posterior-predictive checks, MCMC, or multivariate
  G-theory;
- native CML/CCML, a new JML bias-correction option, or a hierarchical rater or
  other latent local-dependence model family; or
- a package/runtime dependency on ConQuest, FACETS, TAM, or immer. Locally
  executed synthetic external validation remains release evidence outside
  CRAN.

The public estimator labels remain `MML` and `JML`. `JMLE` is an input alias
for `JML`, not a separate estimator. Person estimates from MML and JML are not
assumed equal and are not compared without a named common estimand.

## Gate states and evidence roles

### Release decisions

| Checklist value | Meaning |
| --- | --- |
| `blocker_if_failed` | A failure or unresolved result is a 0.2.3 No-Go. |
| `caveat_if_incomplete` | It may ship only when the limitation is unavoidable in the affected first-screen output and documentation. |
| `roadmap_if_missing` | It must remain guarded and outside the advertised 0.2.3 scope. |

### Evidence status

Every result row uses one of:

- `not_run`: no candidate-linked result exists;
- `ok`: the frozen acceptance rule passed;
- `concern`: a blocking requirement failed or could not be established;
- `review`: a prespecified caveat requires human classification;
- `not_applicable`: the frozen scenario registry proves the row is outside the
  candidate's claimed scope.

`review` is not a synonym for pass. A blocker row cannot finish as `review`.

### Evidence roles

| Role | Permitted use |
| --- | --- |
| `unit` | Exact formula, schema, reduction, and fail-closed regression checks. |
| `pilot` | Criterion calibration and feasibility only; never release confirmation. |
| `confirmation` | Locked release decision on untouched simulation seeds, Persons, or external data. |
| `sensitivity` | Robustness context that cannot hide a failed confirmation row. |
| `external` | Matched result produced by a named external engine and normalized under a recorded contract. |
| `engineering` | Candidate-linked build, check, timing, CI, and artifact evidence. |

Pilot and confirmation rows must have disjoint seed registries and, for an
empirical dimensionality challenge, disjoint Person partitions or a clearly
labelled same-sample sensitivity status.

### Criterion states

| State | Meaning |
| --- | --- |
| `frozen_structural` | Exact schema, identity, formula, prohibition, or fail-closed rule that does not require pilot calibration. |
| `pilot_required` | The metric or design is named, but its numeric value or grid must be calibrated before confirmation. |
| `frozen_numeric` | Pilot calibration is complete and the numeric rule is frozen for confirmation. |
| `candidate_required` | The rule is defined but can be evaluated only after a candidate or external result exists. |
| `roadmap_guard` | The route remains unavailable or deferred in 0.2.3. |

## Freeze and invalidation rules

M2 may freeze the gate only when all of the following are true:

1. every blocker row has a complete scenario definition, metric, direction,
   threshold, aggregation rule, and missing/failed-replicate policy;
2. no blocker row remains `pilot_required`, contains `TBD`, or relies on an
   unstored software default;
3. candidate Q matrices, model constraints, partitions, seed registries,
   integration ladders, and consequence criteria have stable identifiers;
4. the specification and checklist hashes are recorded and reviewed; and
5. no confirmatory result has been inspected under the proposed thresholds.

Pilot findings may revise the current draft, but each revision increments the
specification ID and records the reason. The first confirmation-eligible
version is named `0.2.3-frozen.1`. Any later change to a blocker scenario,
metric, tolerance, Q matrix, partition, seed, integration policy, or
aggregation rule invalidates all M3-M5 evidence and requires a new frozen
version.

## Candidate and evidence identity

### Candidate manifest

The M3 manifest must record at least:

| Field | Requirement |
| --- | --- |
| Package identity | Version, source commit, tree hash, tarball SHA-256, and selected check-log SHA-256. |
| Gate identity | Specification ID/hash and checklist hash. |
| Runtime identity | R version, platform, dependency versions, compiler, and relevant environment flags. |
| Data identity | Scenario ID, input hash, category map, missingness map, weight policy, and Person partition hash. |
| Model identity | Family, estimator, facets, interactions, anchors/constraints, free-parameter map, and starting-value hash. |
| Integration identity | Engine, nodes, QMC setting, sequence/hash, seed where operative, and evaluation policy. |
| External identity | Program, version/edition, run date, command/input/output hashes, and normalization version. |
| Random identity | Generator seed registry, bootstrap seed registry, and failed-replicate policy. |

The release-readiness reader expects
`release-candidate-manifest-0.2.3.csv` as a two-column `Field`,`Value` table
with exactly one non-empty row for each of `CandidateId`, `PackageVersion`,
`SourceCommit`, `SourceTreeHash`, `TarballSHA256`, `SpecificationId`,
`CheckLogSHA256`, `SpecificationSHA256`, `ChecklistSHA256`, `RVersion`, `Platform`,
`DependencyIdentity`, `Compiler`, `EnvironmentFlags`,
`DataRegistryIdentity`, `ModelRegistryIdentity`, `IntegrationRegistryIdentity`,
`ExternalRegistryIdentity`, and `SeedRegistryIdentity`. SHA-256 and Git object
fields must use lowercase or uppercase hexadecimal without a prefix. A
registry may state `not_applicable` only when the frozen scenario registry
proves that it is outside the candidate scope.

Beginning with 0.2.3, the current README, current NEWS section, and
`cran-comments.md` must not preserve numeric test/check pass counts as
free-standing prose. Engineering status is reconstructed from candidate-linked
logs and hashes; if a human-readable count is needed, it is regenerated from
that exact evidence for the release rather than copied from a previous run.
Historical NEWS sections are immutable and are not reclassified by this rule.

No local absolute path, user name, identifier-bearing case data, license key,
or proprietary binary is retained in repository evidence.

### Result-row schema

Every generated gate result must contain:

`Gate`, `Item`, `ScenarioId`, `CandidateCommit`, `SpecId`, `EvidenceRole`,
`Metric`, `Estimate`, `Threshold`, `Direction`, `MonteCarloSE`, `NumericalSE`,
`ReplicatesPlanned`, `ReplicatesRetained`, `FailedReplicates`, `Status`,
`EvidencePath`, and `EvidenceHash`.

For an exact structural check, `Estimate`, `MonteCarloSE`, and `NumericalSE`
may be empty, but `Status`, the exact rule, and evidence identity may not be.
Aggregates must link to retained per-replicate evidence outside the package.

The release-readiness reader expects these rows in
`release-gate-results-0.2.3.csv`. `CandidateCommit` and `SpecId` must match the
candidate manifest. Each `EvidencePath` is a repository-relative path without
parent traversal and its `EvidenceHash` must match the retained file's
SHA-256. Every checklist `Gate`/`Item` and every named semicolon-separated
`ScenarioId` must resolve to at least one result row; `ALL` is the only
wildcard. Blocker and roadmap-guard items finish only when every matched row
is `ok`. A caveat item may finish as `review` only when no matched row is
`concern`, `not_run`, or missing; that review state propagates to the overall
readiness decision.

## Scenario registry

The final frozen registry may split a row into more cells, but may not omit the
following scenario classes.

| Scenario ID | Evidence role | Required design |
| --- | --- | --- |
| `NUM-BIN-REDUCE` | unit/confirmation | Two-category RSM and PCM reduction to the intended binary model. |
| `NUM-RSM-CORE` | pilot/confirmation | Connected unidimensional RSM across planned Person counts and facet sizes. |
| `NUM-PCM-CORE` | pilot/confirmation | Connected PCM with unequal supported step ladders in the current rectangular contract. |
| `NUM-GPCM-BOUND` | pilot/confirmation | Bounded GPCM covering unit, near-flat, moderate, and boundary-adjacent slope regimes. |
| `NUM-ENGINE-PARITY` | pilot/confirmation | Direct, hybrid, and EM-plus-polish evaluated at the same retained parameter vector and quadrature. |
| `REC-SMALL-CORE` | pilot/confirmation | Small supported designs used to calibrate finite-sample recovery limits. |
| `REC-STANDARD-CORE` | pilot/confirmation | Typical connected designs for every claimed parameter class. |
| `DES-SPARSE-LINKED` | pilot/confirmation | Sparse but connected rater assignment with explicit common-Person links. |
| `DES-WEAK-BRIDGE` | pilot/confirmation | Weak links, bridge levels, and articulation cases. |
| `DES-TWO-RATER` | pilot/confirmation | Two-rater complete and sparse panels, stratified by shared-Person support and local information. |
| `DES-RATER-NO-COMMON-PERSON` | unit/confirmation | Two-rater negative control with no common Persons; unsupported comparisons must fail closed. |
| `DES-DISCONNECTED` | unit/confirmation | Deliberately disconnected negative control that must fail closed. |
| `DES-EMPTY-CATEGORY` | unit/confirmation | Empty or near-empty category support with a prespecified support classification. |
| `DES-CATEGORY-IMBALANCE` | pilot/confirmation | Middle/single-category dominance, skewed targeting, concentration, entropy, and local support by model. |
| `DES-EXTREME-SCORE` | pilot/confirmation | Extreme Person/facet score patterns separated from optimizer status. |
| `IC-FORMULA` | unit | Exact AIC, Person-BIC, and Sclove-SABIC formulas. |
| `IC-FREE-DIMENSION` | unit | Constraint-aware parameter count under centering, anchors, steps, slopes, interactions, and latent regression. |
| `IC-WEIGHT-POLICY` | unit | Unit weights, constant-within-Person frequency weights, and row-varying weights. |
| `IC-INTEGRATION` | pilot/confirmation | Common-evaluation quadrature/QMC ladder for delta-criterion stability. |
| `DIM-SYN-TRUE-1D` | pilot/confirmation | True 1D false-selection control across targeting and sparse-design cells. |
| `DIM-SYN-TRUE-2D` | pilot/confirmation | Prespecified 2D alternatives spanning moderate and high dimension correlations. |
| `DIM-SYN-INTERACTION` | pilot/confirmation | Rater-by-criterion interaction without latent multidimensionality. |
| `DIM-SYN-CONFOUNDED` | pilot/confirmation | Deliberately inseparable interaction/dimension negative control. |
| `DIAG-BIAS-NULL` | pilot/confirmation | Additive null grid for conditional bias-screen false-positive and multiplicity behavior. |
| `DIAG-BIAS-NONNULL` | pilot/confirmation | Planted zero-marginal facet interactions across effect size and cell information. |
| `DIAG-PCAR-NULL` | pilot/confirmation | Prespecified residual-PCA null grid across topology and missingness. |
| `DIAG-PCAR-LOCAL` | pilot/confirmation | Planted local response dependence with exploratory PCAR sensitivity and attribution controls. |
| `DIM-EMP-DISCOVERY` | pilot | Residual PCAR/Q3-style hypothesis generation on discovery Persons only. |
| `DIM-EMP-CONFIRM` | confirmation | Frozen TAM alternatives on untouched Persons or an external sample. |
| `EXT-CQ-BINARY` | external | Matched unidimensional ConQuest binary MML core. |
| `EXT-CQ-RSM` | external | Matched unidimensional ConQuest RSM MML core. |
| `EXT-CQ-PCM` | external | Matched unidimensional ConQuest PCM MML core. |
| `EXT-TAM-MML-1D` | external | Matched TAM unidimensional MML reference, separate from its dimensionality and JML lanes. |
| `EXT-FACETS-QUALIFY` | external | Deterministic binary, RSM, and PCM microcases binding executable metadata/hash to report-header version and exact artifacts. |
| `EXT-FACETS-RSM-CORE` | external | Paired JML RSM truth recovery and transformed parameter agreement over the mandatory connected core. |
| `EXT-FACETS-PCM-CORE` | external | Paired JML PCM truth recovery and transformed parameter agreement over the mandatory connected core. |
| `EXT-FACETS-ANCHOR` | external | Element/group anchor and scale-origin cases within current mfrmr support; threshold anchors remain excluded. |
| `EXT-FACETS-SPARSE` | external | Sparse, weak-link, bridge, and disconnected topology classification and false-ready checks. |
| `EXT-FACETS-EDGE` | external | Extreme score, category support, missingness, and failure-classification cases. |
| `EXT-FACETS-DFF` | external | Optional definition-matched fit/DFF null and non-null rows; never part of core merely because FACETS emits them. |
| `EXT-TAM-JML-RAW` | external | TAM JML with bias reduction and extreme-score adjustment disabled, compared on eligible common RSM/PCM structural estimands. |
| `EXT-TAM-JML-ADJ` | external | TAM JML with its documented extreme-score adjustment and bias reduction disabled. |
| `EXT-TAM-JML-BC` | external | TAM bias-reduced JML with extreme-score adjustment disabled. |
| `EXT-TAM-JML-BC-ADJ` | external | TAM documented default bias-reduced and extreme-score-adjusted JML mode, never pooled with either factor alone. |
| `EXT-IMMER-JML-RAW` | external | immer unadjusted JML on the matched Rasch-family design-matrix overlap. |
| `EXT-IMMER-JML-EPS` | external | immer extreme-score-adjusted JML with adjusted and nonextreme Person rows reported separately. |
| `EXT-IMMER-JML-BC` | external | immer bias-corrected JML as a distinct estimator convention. |
| `EXT-IMMER-CML` | external | immer CML structural-parameter reference on eligible Rasch-family rows; no Person or bounded-GPCM claim. |
| `EXT-IMMER-CCML` | external | immer CCML structural-parameter reference on eligible Rasch-family rows; no Person or bounded-GPCM claim. |
| `ALT-IMMER-HRM-LD` | sensitivity | HRM-generated latent-rating/local-dependence challenge to additive mfrmr diagnostics, never an engine-equivalence row. |
| `ENG-CRAN-SMOKE` | engineering | Deterministic CRAN-side package workload. |
| `ENG-FULL-CORE` | engineering | Complete non-CRAN blocker suite and cross-platform matrix. |

The frozen registry must give every simulation cell an ADEMP record: aim,
data-generating mechanism, estimand, fitted method, and performance measures.
Sample sizes, level counts, assignment densities, category probabilities,
effect sizes, and replication counts remain `pilot_required` in this draft.

## G0: candidate identity

Candidate identity is exact, not tolerance based.

- Every internal and external evidence row must resolve to one manifest.
- Source commit, installed-package source, tarball, and check-log package
  version must agree.
- The gate specification, checklist, Q matrices, Person partitions, scenario
  registry, seed registry, and integration registry must match their hashes.
- An external result without executable hash/file metadata, output-reported
  version, command/control/input/output hashes, date, locale, parser/generator
  and normalizer fingerprints is unresolved for release comparison. An
  executable/report version difference is retained as a separate evidence
  stratum and does not stop unrelated pilot execution.
- A stale result from another candidate is a blocker even when its numerical
  values would pass.

## G1: MML stationarity and numerical agreement

### Canonical score

The gate operates on the identified free parameter vector after equality
constraints. The current bounded-scope GPCM implementation is not optimized
under box bounds: `n-1` free log slopes are expanded to `n` sum-zero log
slopes, then exponentiated to positive slopes with geometric mean one. Its G1
rule therefore uses the transformed free-coordinate score and stores both the
log-slope and positive-slope Jacobians; it does not call this a projected
gradient. If a future implementation introduces a genuine inequality or box
constraint, that route requires a separately declared projected-gradient/KKT
rule before entering this gate. The analytical score is checked against an
independently implemented central-difference or automatic-differentiation
reference on small binary, RSM, PCM, and bounded-GPCM fixtures.

The draft.12 fixed pilot uses q=31, two fixed hashed fixtures, a relative-step
ladder of `1e-4`, `3e-5`, and `1e-5`, and both retained-solution and
deterministic nonzero-score points. All ten run/point references were
computable; the maximum absolute/scaled score difference was `6.91e-9`, and
the largest numeric step-ladder range was `6.91e-8`. The GPCM log/slope
Jacobian check reached a maximum difference of `3.00e-10`. Exact binary
RSM=PCM and unit-slope GPCM=PCM log-probability, probability, objective, and
common-score reductions also held. These values are recorded in
`numerical-stationarity-pilot-record-0.2.3.md` as pilot calibration and
structural-regression evidence only.

The current package review tolerance
`max(1e-4, 10 * reltol)` is a pilot baseline, not the frozen 0.2.3 release
criterion. Pilot work must determine whether a scaled score is also required
when parameter classes have materially different curvature.

### Retained solution

- Direct, hybrid, and EM-plus-polish routes are compared at a common retained
  parameter vector, likelihood implementation, quadrature, and constraints.
- Optimizer code zero and EM relative change are secondary evidence. Neither
  can override a failed canonical score check.
- `maxit` is a prespecified ceiling. Iteration-limited fits remain review-only
  and cannot pass a blocker row through repeated ad hoc reruns.
- Objective and transformed parameter differences use pilot-calibrated
  absolute and relative tolerances by parameter class.
- Binary reduction, unit-slope reduction, and step/slope transformation checks
  are exact regression blockers.

The draft.13 fixed pilot applies this contract to binary and four-category
additive RSM/PCM fits at q=31. It records four paths per run: public direct,
public hybrid, converged raw EM as a diagnostic, and common direct polish
started from the exact hashed raw-EM vector. The mandatory parity set is
direct, hybrid, and EM-plus-common-direct-polish; raw EM readiness or native
relative-likelihood convergence cannot satisfy the row by itself.

Each retained path vector is evaluated through all direct, EM, and hybrid fit
contexts after their quadrature, identification, coordinate order, objective,
and score structures are shown to be identical. Across all 16 fixed run/path
summaries, both the objective evaluator range and the coordinate-wise score
evaluator range were exactly zero. Across the 12 mandatory path pairs, the
largest objective difference was `1.47e-10`, the largest free or expanded
parameter difference was `5.73e-6`, and the largest mandatory-path common
score was `5.06e-5`. All mandatory paths happened to be inference-ready and no
path emitted a warning. These are pilot observations only:
`NUM-OBJECTIVE-TOL` and `NUM-PARAMETER-TOL` remain `pilot_required` until the
grid is expanded and a reviewed margin rule is frozen.

Engine parity currently applies only to additive equal-slope RSM/PCM. GPCM has
one supported direct engine; requesting EM or hybrid falls back to direct and
cannot count as independent parity evidence. Model-estimated interactions and
latent regression likewise fall back to direct for unsupported engine
requests. The fixed scope registry and fail-closed tests preserve this
boundary. Full details are recorded in
`mml-engine-parity-pilot-record-0.2.3.md`.

## G2: recovery and sparse-design behavior

Core recovery is evaluated separately for every claimed parameter class and
scenario cell. The minimum record is bias, RMSE, interval coverage where the
interval is supported, standard-error availability, run success,
inference-ready rate, Monte Carlo standard error, terminal score, objective,
condition indicator, and elapsed time.

Readiness has three scopes: fit, parameter, and comparison. The stored fit
record retains input, estimability, category, boundary, and numerical component
states; parameter output retains one status per displayed/fixed coordinate;
external normalization retains eligibility per metric and parameter class.
The legacy scalar `InferenceReady` is only a conservative compatibility
summary and cannot be the sole input to a 0.2.3 gate.

Draft.47 continues to bind this gate to readiness contract
`mfrmr-readiness-0.2.3-v3` in
`readiness-contract-0.2.3.md`, its repository-only schema validator, and the
36-row adversarial fixture registry. `InferenceReady` is `TRUE` only for fit
state `ready`; every other fit state maps to `FALSE`. A
`ready_with_exclusions` fit retains separately estimable parameter rows, but
old Boolean-only consumers cannot call the whole fit ready. Saved objects
without the contract are `legacy_unknown`, regardless of their former scalar.
This structural freeze completes WP0 only. It does not make current runtime
surfaces compliant and does not satisfy the propagation or confirmation gate.

Draft.43 also binds Person-indexed MML posterior alignment and validation
capability to this gate. Any MML Person, expected-score, residual, fit, bias,
or residual-PCA evidence produced before commit `655f6bf` is rejected unless
the retained Person order is independently proven aligned. Row permutation
must leave EAP and posterior SD values invariant by Person ID. Dependency-
limited JML boundary runs remain valid fail-closed capability observations but
cannot substitute for an evaluated boundary audit. The two-replicate
feasibility run freezes no operating-characteristic or diagnostic threshold.

Draft.44 binds long-run reuse to checkpoint schema
`mfrmr-gpcm-repilot-checkpoint-v1`. Only a complete four-route data cell can
be reused. Selected/declared manifests, execution controls, loaded-package
bytes, validation-runner bytes, capability versions/content or absence, R/platform,
and RNG contract enter execution identity; absolute paths do not. Resume is
explicit and rejects unexpected RDS files or any schema, execution, cell,
payload, scenario, route, and manifest mismatch. A same-directory verified
temporary payload is published by rename, and a final completion marker is
valid only while every listed aggregate and default checkpoint hash agrees.
Historical draft.43 outputs predate this schema and remain non-resumable. This
closes no statistical recovery, coverage, diagnostic, or comparison gate.

Draft.45 adds the repository-only MML metamorphic contract before any new
external numeric comparison is eligible. Ten transformations are crossed with
RSM, PCM, and bounded GPCM under one retained-data design. A comparison passes
only when semantic key sets agree, all declared metric differences are within
pilot screening tolerances, model-result states agree, and both fits have
`NumericalState = ready`. Missing and zero-weight encodings may retain distinct
input-provenance/readiness audit fields, but they may not change the effective
rows or downstream fit quantities. The 30/30 v3 pass is software-property
pilot evidence only. It does not freeze the tolerances or replace sparse
target-size, recovery, coverage, diagnostic, or external-comparison evidence.

Draft.46 changes release-scope governance without changing an evidence result.
The current 87-row checklist is an inventory and cannot be used as a count of
equally mandatory serial tasks. Each `(Gate, Item)` must be assigned to one of
three portfolios before criterion freeze: `release_spine` (must pass for the
candidate), `claim_conditional` (must pass only to promote its named claim;
otherwise the claim is disabled, unavoidably caveated, or deferred), or
`deferred` (outside bounded 0.2.3 scope). Every conditional row must name its
fail-closed fallback and affected public surfaces. No row is deleted, passed,
or converted to confirmation evidence by portfolio assignment.

WP5 deterministic eligibility work may begin for stable RSM/PCM metric slices
without borrowing incomplete GPCM or diagnostic readiness. WP6 target-size
construction/runtime evidence may proceed without waiting for external
normalization. WP7 may prespecify replication, Monte Carlo precision, seeds,
and manifests, and may run calibration pilots only on dependency-stable
slices. A later affected code or contract change invalidates those rows.
Confirmation remains globally prohibited until the portfolio profile,
release-spine dependencies, numeric criteria, and candidate identity are
frozen. The governing rationale and rechecked official version sources are in
`roadmap-reassessment-record-0.2.3.md`.

Draft.47 begins the noninferential target-size slice authorized by that
governance decision. The six selected rows are exactly the executable
`target_sparse` rows from the already-hashed 70-cell pilot manifest; no cell
was added or removed after viewing a result. Each has 400 generated Persons
and one executed seed, while the later pilot remains explicitly declared as
five replicates per cell. All six executed with zero unexpected runner failure
and zero false-ready state. Two disconnected exact-rank controls failed before
optimization, two returned blocked/review states, one PCM JML fit retained
extreme-Person exclusions, and one imbalanced/missing PCM MML fit was ready.
The ready fit is not a recovery or diagnostic pass. The mixed-adversity GPCM
MML fit reached the fixed iteration limit and remained blocked; its optimizer
slope error is ineligible as primary recovery evidence.

Four returned fits reached exploratory residual PCA. In the most complex GPCM
cell, `psych` reported that the smoothed-correlation determinant and parts of
the objective were undefined even though an object returned. Diagnostic
promotion therefore requires a new fail-closed PCA computability state that
captures messages, matrix rank/support, and smoothing/repair provenance. The
run's R `gc()` high-water values are memory proxies, not OS peak resident
memory or a supported-size ceiling. The authoritative independently validated
bundle and all hashes are recorded in
`target-scale-sparse-stress-pilot-record-0.2.3.md`. Balanced target baselines,
weak-bridge gradients, OS memory, the five-replicate pilot, recovery/coverage,
and every numeric criterion remain open.

Draft.48 executes those target baselines and weak-bridge gradients as a new
one-replicate calibration layer. Complete balanced and clean matched-sparse
RSM, PCM, and GPCM data are each fitted by JML and MML without changing the
generated data. The two-Rater PCM bridge cells use 0, 1, 2, 5, 10, 20, and 40
common Persons under one truth hash. The authoritative v2 completes all 26
routes, preserves all 13 paired data hashes, has zero unexpected failures and
zero false-ready rows, and records one expected exact zero-overlap JML failure.
The v1 bridge rows are superseded because different overlap levels used
different truth seeds.

All clean 12-Rater/12-Criterion JML cells reached the iteration limit after
roughly 204--480 seconds. Their MML partners completed in roughly 2.5--17
seconds but remained review-only because of terminal-gradient and, for GPCM,
marginal-boundary contract gaps. This separates a JML scale/design-dimension
bottleneck from MML numerical-readiness work; it does not justify loosening a
tolerance. At positive bridge overlap, MML was ready while JML alternated
between extreme-Person exclusions and iteration-limited blocking. The recovery
traces were nonmonotone. Neither binary connectivity nor numerical readiness
therefore freezes minimum overlap. Replicated common-truth recovery, local
information, failure denominators, MCSE, and estimator-specific criteria are
required. Process-lifetime OS peak memory is recorded but is not per-cell
allocation or a capacity limit. PCA remains unrun pending its computability
state. Results and hashes are in
`target-scale-baseline-bridge-pilot-record-0.2.3.md`.

Draft.49 decomposes the draft.48 JML computation hypothesis with 14 PCM data
cells and 34 routes. Person/row growth, fixed-row Rater panel/topology,
fixed-row Criterion/step growth, fixed-parameter row exposure, and a matched
forced-extreme control are fitted on identical JML/MML inputs. Selected JML
cells add explicit optimizer controls. All routes executed with zero unexpected
failure and zero false-ready result under the fixed 60-iteration calibration
ceiling.

The P200 and P400 complete nonextreme auto routes switched to L-BFGS-B and
blocked, whereas explicit BFGS on the same data was ready in similar time;
P200 explicit L-BFGS-B reproduced auto. This places a replicated optimizer-
dispatch grid around the current 200-parameter threshold on the corrective
path. It does not authorize a threshold change: BFGS remained blocked for the
R12 panel, C12 step panel, and forced-extreme controls. Fixed-row Rater results
also changed zero-common-Person pair topology, so they are not a pure Rater-
dimension experiment.

At fixed 249-parameter dimension, the 1,200-row sparse cell was slower and less
well conditioned than 2,400 rows, while the 7,200-row cell was the slowest but
ready. Forcing 20 low and 20 high Persons under the P200 truth approximately
doubled JML time and blocked both optimizers. The largest single-axis fit was
about 51 seconds, leaving the hundreds-of-seconds draft.48 result as a compound
interaction rather than a single row/dimension effect. Phase-specific timing
now rejects the optimizer as the primary elapsed-time explanation in these
cells: structural and joint recession certification dominate, while the
optimizer accounts for only a small JML share. Draft.51 implements the
mathematically equivalent structural global-cone prescreen before target
enumeration without bypassing certificate or fail-closed states. The fixed v4
rerun preserves all 19 semantic/readiness states and all 12 same-fit structural
target classifications. In the selected negative-cone PCM routes, 908 legacy
target LP calls become 12 cone LP calls and structural phase time falls from
139.63 to 13.80 seconds. Joint recession attribution now precedes any further
performance implementation. The full records are
`jml-bottleneck-decomposition-pilot-record-0.2.3.md`,
`jml-phase-profile-pilot-record-0.2.3.md`, and
`jml-structural-cone-prescreen-pilot-record-0.2.3.md`.

Draft.23 implements the RSM/PCM linear-coordinate portion of the estimability
gate. Sparse QR acts on the optimizer's constrained Person/facet/interaction/
step basis; exact deficiency stops before optimization with a structured
condition. MML is audited without free Person columns and is compared with a
counterfactual free-Person JML design so assumption-only panel linkage remains
explicit. Dense SVD is restricted to bounded explanation fixtures. This does
not complete G1/G2: nonlinear GPCM slope and latent-variance coordinates,
fitted information, weak-information calibration, target-size performance,
and the broader property grid remain unresolved.

Draft.25 adds only the first fitted-information instrument. For stationary
retained fits with nonlinear free coordinates and total free dimension at most
80, the runtime stores a symmetric-eigenvalue tolerance ladder from a dense
numerical Hessian of the same direct negative log-likelihood and analytical
gradient used in fitting, with an explicit free-coordinate step, objective
reevaluation/difference, gradient maximum, Hessian asymmetry, and a nonlinear-
block diagonal summary. It records
explicit nonstationary, malformed-vector, dimension-limit, and unavailable
states. The dimension cap is computational, not inferential. This result cannot
create `weak_information`, change readiness, certify nonlinear structural
identification, or satisfy G1/G2 before its pilot-calibrated rule is frozen.

Draft.26 adds a distinct nonlinear parameterization audit at the retained
vector. Analytic GPCM free-log to sum-zero-log to positive-slope Jacobians and
latent free-log-variance to positive-variance Jacobians are checked against
coordinate-scaled central differences. Dimensions, expected and tolerance-
ladder ranks, constraint residuals, derivative differences, natural-coordinate
ranges, and conditioning are retained. This is explicitly not a response-
likelihood/design Jacobian: transformation full rank cannot classify structural
identification, weak information, readiness, or external eligibility.

Draft.27 adds the retained JML GPCM adjacent-logit response-kernel Jacobian in
the full optimizer coordinate order. It combines constrained additive columns
with the sum-zero log-slope chain rule, records a local rank ladder and bounded
null explanations, verifies analytic derivatives against central differences,
and checks unit-slope reduction plus row-order invariance. The corresponding
MML field fails closed with an explicit person-integrated-pattern requirement;
the conditional JML kernel is not relabelled as marginal evidence. Neither the
JML local rank nor the MML boundary changes readiness or freezes a threshold.

Draft.28 adds the observed-Person-pattern MML marginal score decomposition for
bounded nonlinear fits. Person log-marginal contributions reconstruct the full
objective, analytic score rows reconstruct the full score, and each row is
checked against central differences in the exact optimizer coordinate order.
The record omits Person identifiers and the score matrix, imposes explicit
execution caps, and keeps the observed-pattern rank diagnostic separate from
an all-possible-pattern structural map, fitted information, weak-information
classification, and readiness.

Draft.29 adds bounded exhaustive response-pattern enumeration for every
retained Person observation design under unit row weights. It verifies marginal
probability normalization and the zero expected-score identity, accumulates
the score-outer-product expected information in optimizer coordinates, and
checks selected response patterns against independent central differences.
Missing rows shorten the retained design rather than being imputed; nonunit
weights and combinatorial or dimensional overflow receive explicit
non-evaluated states. Workload and numeric summaries are retained without
storing Person identifiers, pattern rows, score rows, or the information
matrix. The resulting rank is local to the retained parameter vector,
quadrature rule, and observed designs and does not classify structural or weak
identification or alter readiness.

Draft.30 canonicalizes the retained row layout and evaluates exhaustive
patterns once for each exact Person-design signature. The signature includes
facet, step, slope, and interaction indices and, when applicable, the aligned
latent-regression population-design row; it excludes Person identifiers and
observed scores. Expected information is reconstructed by exact group
multiplicity. A forced non-reuse path must agree numerically, while missing
layouts and distinct population-design rows must remain separate. The fitted
record exposes only conceptual and evaluated workload summaries and group
counts. This exact reuse reduces duplicate computation but does not solve the
exponential response space of a unique long design or establish a target-size
capacity claim.

- Replication counts are selected from a frozen Monte Carlo-precision target,
  not convenience or elapsed time alone.
- A pooled mean cannot rescue a failed sample-size, family, facet, category,
  slope, or link-density cell.
- Connected sparse, weak-link, bridge, articulation, disconnected,
  empty-category, and extreme-score cases retain separate labels.
- Two-rater panels retain complete, shared-Person sparse, and zero-common-
  Person labels. The audit records rater-panel size, the Person-sharing graph,
  common-Person counts, bridge strength, articulation, component balance, and
  local information; binary connectivity alone cannot confer readiness.
- Before optimization, the constrained free-coordinate design must be checked
  for exact rank. A connected graph cannot confer readiness when a rater
  contrast is aliased with nested Person locations. After full rank is
  established, singular values and fitted information diagnose weak rather
  than exact identification; no universal condition-number cutoff is frozen
  in this draft.
- The constrained audit is estimator-specific. JML includes free Person
  coordinates; MML integrates them and must identify when a rater link rests
  on a common latent-population assumption rather than shared Persons. Main-
  effect rank cannot certify an interaction fit.
- Category support records counts, maximum proportion, normalized entropy,
  local facet support, and threshold information by model. A consecutive
  global category range cannot confer readiness when a category is unused or
  almost all responses occupy one category.
- External parameter tolerances are applied only after declared and retained
  category maps and free step dimensions agree within every relevant
  step-facet level. A category-dropping FACETS fit is an edge-policy control,
  not a numerical comparison to mfrmr's retained rectangular PCM steps.
- Extreme JML Person results are compared by low/high/unbounded status. A
  FACETS adjusted display measure is not compared to an optimizer-dependent
  finite proxy as though both were the primary JML estimand; nonextreme Person
  measures remain a separate numeric stratum.
- The same boundary contract applies to other JML element classes when their
  sufficient score is extreme. MML/EAP Person results remain governed by the
  population/prior model and are not relabelled as JML-unbounded.
- `DES-DISCONNECTED` and other unidentified negative controls must not become
  inferentially ready. A false-ready result is a blocker.
- The deterministic CRAN smoke tier demonstrates execution only. Release
  recovery decisions come from the non-CRAN confirmation tier; extended
  sensitivity cannot hide a failed core cell.

Bias, RMSE, coverage, failure-rate, and Monte Carlo-precision thresholds are
`pilot_required`. Existing helper defaults are not silently adopted as
release thresholds.

The draft.19 one-seed extension and draft.20 divergence audit are calibration
evidence for these rules. The constrained main-effect audit found nullity one
for the zero-common-Person two-rater design. The severe PCM row was reported as
ready despite unsupported mfrmr steps, while FACETS dropped categories and
fit a smaller per-Criterion step dimension. Its raw parameter MAE is therefore
not a common-estimand discrepancy. Large weak-overlap Person maxima were
concentrated in FACETS-adjusted extreme scores; nonextreme MAE was 0.1465 for
RSM and 0.1190 for PCM. These outcomes define fail-closed targets and
comparison strata; they do not set a numeric support boundary.

## G3: information-criterion contract

### Common MML panel

For the current fixed-facet marginal MML likelihood, Persons are the
independent likelihood units after the latent Person parameter is integrated
out. Let `D = -2 logLik`, `k` be the dimension of the free optimization vector
after constraints, and `N_person` be the number of independent Persons. The
common panel is:

```text
AIC   = D + 2 k
BIC   = D + log(N_person) k
SABIC = D + log((N_person + 2) / 24) k
```

The SABIC formula identifier is `sclove_n_plus_2_over_24`.

Every fitted MML object and comparison row must expose `Deviance`, `LogLik`,
`Npar`, `ResponseRows`, `WeightedResponseTotal`, `Persons`, `ICSampleSize`,
`ICSampleSizeBasis`, `AIC`, `BIC`, `SABIC`, the formula identifiers, and the
integration-evaluation identity.

### Migration and free dimension

0.2.2 uses response rows, or summed observation weights, in the BIC penalty.
0.2.3 corrects that basis without silently changing the meaning of the legacy
summary `N`: response rows, weighted response total, Persons, and IC sample
size remain separate fields, and NEWS identifies the behavior change.

`k` excludes MML EAP Person estimates and includes every estimated free
latent-regression, population variance/covariance, facet, step, slope, and
interaction coordinate. It must equal the retained optimization-vector
dimension after anchors and constraints.

`Npar` is the canonical 0.2.3 field. The existing lower-case `npar` comparison
column remains a compatibility alias during the 0.2.x series and must equal
`Npar`; it is never counted as a second source of truth.

### Comparability rules

| Fit type | AIC/BIC/SABIC ranking |
| --- | --- |
| Unweighted inference-ready MML on the same observations and likelihood basis | Eligible after all identity checks. |
| MML with an explicitly supplied all-unit weight column | Same as unweighted MML. |
| MML with any non-unit observation weight, including a value constant within Person | Suppressed with `ICComparable = FALSE` in 0.2.3. |
| JML | No primary AIC/BIC/SABIC ranking; any raw value is descriptive. |
| Cross-engine MML | Eligible only after likelihood constants, observations, constraints, `k`, `N_person`, and integration evaluation are matched. |

The non-unit-weight rule is structural rather than pilot-calibrated. In the
current marginal likelihood, multiplying every conditional response
contribution for a Person by a common weight is not generally equivalent to
replicating that Person as independent latent draws. Therefore the label
"Person-frequency weight" does not by itself justify an effective-Person BIC
sample size. A later weighting contract may introduce a different likelihood
with explicit sampling semantics; 0.2.3 does not infer one from the supplied
row weights.

External comparisons recompute the common panel from comparable `D`, `k`, and
`N_person`. Native fields remain separately named and retain their formula.
In the audited TAM 4.3-25/official-source snapshot, native `aBIC` uses
`log((n - 2) / 24)` and must not be relabelled as the common Sclove SABIC.
Every external run records and rechecks its installed version and native
formula.

### Stored-value and object-version rules

Every newly fitted 0.2.3 MML object records `ICContractVersion`, `Deviance`,
`LogLik`, `Npar`, `ResponseRows`, `WeightedResponseTotal`, `Persons`,
`ICSampleSize`, `ICSampleSizeBasis`, `WeightPolicy`, `ICEligible`,
`ICSelectable`, `ICStatus`, `AIC`, `BIC`, `SABIC`, `SABICSelectable`, formula
identifiers, the integration-evaluation identity, `ICQuadraturePoints`,
`ICIntegrationTier`, `ICIntegrationStatus`, and
`ICIntegrationSelectable`.
`N` retains its 0.2.2 response-row or summed-weight meaning for compatibility;
it is not an IC input.

When `ICEligible = FALSE`, the canonical `AIC`, `BIC`, and `SABIC` fields are
`NA`; a backward-compatible raw quantity, if retained, must use an explicitly
legacy/descriptive field name. This keeps a displayed value from bypassing the
comparison guard.

`compare_mfrm()` recomputes the common panel from canonical `LogLik`, `Npar`,
and `Persons`, and verifies any stored criterion against that recomputation.
It does not inherit a stale summary value as the comparison value. A mismatch
between stored and recomputed values is a concern and suppresses ranking.

An object without the 0.2.3 contract identity is classified
`legacy_or_unknown`. Its stored 0.2.2 AIC/BIC may be displayed as explicitly
legacy descriptive output, but it cannot be mixed into a 0.2.3 ranking or
silently reinterpreted with Person-based BIC. Refit under the current package
to obtain comparable criteria.

### Numerical and interpretive guards

- ICs are evaluated at a common locked integration setting. Their ordering and
  delta values must be stable over the frozen quadrature/QMC ladder within a
  pilot-calibrated numerical tolerance.
- When QMC/deviance drift is not small relative to a model difference, the IC
  comparison is unresolved.
- At `N_person <= 22`, the Sclove SABIC penalty is non-positive; SABIC may be
  displayed with a warning but cannot block or select a model.
- Delta ICs are relative evidence within a candidate set. Neither Akaike nor
  BIC-derived weights are described as assumption-free literal model
  probabilities.
- BIC/SABIC do not repair boundary/singularity or make a tiny large-N gain
  practically important. No IC is a standalone dimensionality gate.

### Current integration-pilot state

The first working-tree `IC-INTEGRATION` pilot was run under `0.2.3-draft.2`,
then extended to a deterministic six-scenario matrix under draft.3. Draft.4
adds an independent-refit layer and a fail-closed public integration tier.
All three development layers are recorded in
`ic-integration-pilot-record-0.2.3.md`; none is candidate-linked confirmation.
The policy `fixed_retained_vector_common_ghq_v1` holds each candidate's free
parameter vector fixed and changes only the common GHQ evaluation grid. This
isolates integration approximation from optimization and verifies that the
source-grid evaluation reproduces the retained objective first.

The development pilot ladder uses q = 7, 15, 31, 61, 91, and 121, with q=121 as the
reference ceiling. q=7 and q=15 are diagnostic stress points. q=31 through
q=121 are candidate core points, not a frozen release ladder. The following
are candidate rules for calibration, not `frozen_numeric` criteria:

- source-grid objective reproduction within
  `1e-10 * max(1, abs(stored objective))`;
- unchanged criterion ordering over the candidate core ladder;
- maximum absolute raw-deviance drift no larger than 0.10;
- maximum absolute pairwise criterion-gap drift no larger than 0.10 and no
  larger than 10% of the corresponding non-tied reference gap; and
- no automatic preference when the reference gap is within the declared
  numerical tie tolerance.

The absolute 0.10 candidate is one twentieth of the conventional delta-IC 2
screening scale already described in the package help; it is a calibration
anchor rather than a result-tailored pass line. The broader pilot must still
challenge it with further weak-link, boundary-adjacent, and deliberately
near-tied candidates. TAM product-quadrature and QMC ladders require their own
evaluator and cannot inherit the mfrmr GHQ result. `IC-INTEGRATION-TOL`
therefore remains `pilot_required`, and confirmation remains unauthorized.

The six retained draft.3 cells had no fit failure or warning. Across the
candidate q=31--121 core, every criterion ordering was stable; the largest
raw drift was 0.0397363, pairwise-gap drift was 0.00924359, and relative gap
drift was 0.0160086. These observed values sit inside all three candidate
rules but do not freeze them. The wide-latent cell, whose estimated latent
variance was approximately 9, changed AIC/SABIC ordering when q=7 and q=15
were included. This is a direct warning against treating equal coarse-grid
identities as sufficient IC evidence.

The draft.4 policy `independent_refit_then_common_ghq_v1` separately refitted
all six matrix scenarios at q = 7, 15, 31, 61, 91, and 121 from ordinary
deterministic starts, then reevaluated every retained solution at common
q=121. All fits remained warning-free and the q=31--121 ordering remained
stable. Across the six scenarios, the largest core native criterion-gap
drift was 0.00944565, the largest common-q=121 gap drift was 0.000202065, the
largest parameter drift was 0.00484794, and the largest common-reference
deviance excess was 0.000734096. In the wide-latent cell, the native q=7
AIC/SABIC ordering reversed, but reevaluating both q=7 solutions at q=121
restored the q=121 preference. The q=15 native gap was already order-stable
but differed from the reference AIC gap by about 10.5%. These results locate
the observed coarse-grid problem primarily in integration evaluation and do
not justify automatic ranking at q=7 or q=15.

Accordingly, contract `mfrmr_ic_person_v2` separates formula eligibility from
selection readiness:

| GHQ points | Integration tier | Public comparison policy |
| ---: | --- | --- |
| below 15 | `coarse_screening` | Raw canonical ICs may be inspected, but automatic ranking is screening-only and suppressed. |
| 15--30 | `intermediate_review` | Raw canonical ICs are review-only; automatic ranking remains suppressed. |
| 31--60 | `standard_start` | Same-basis eligible fits may enter comparison; this is a starting grid, not proof of integration stability. |
| 61 or more | `dense_sensitivity` | Same-basis eligible fits may enter comparison and can provide denser-grid sensitivity evidence. |

Below q=31, `ICEligible` may remain true while `ICSelectable` is false;
`compare_mfrm()` suppresses delta criteria, criterion weights, preferred-model
labels, evidence ratios, and LRT. This is a fail-closed draft policy, not a
frozen declaration that every q>=31 comparison is adequate. Close,
consequential, wide-latent, or otherwise sensitive comparisons still require
a prespecified denser common-grid check. Weak-link/boundary cells,
cross-platform replication, TAM QMC evaluation, and the practical reference
ceiling remain unresolved before the ladder and tolerance can be frozen.

### Current external-IC normalization state

Draft.5 adds the repository-only contract `mfrmr_external_ic_v1`. It calls the
same internal common-panel builder used by newly fitted mfrmr objects, so the
normalized panel has one formula source:

- `AIC = D + 2k`;
- `BIC = D + log(N_person)k`; and
- `SABIC = D + log((N_person + 2) / 24)k`.

The record keeps engine-native fields and formula identifiers separately.
The TAM 4.3-25 adapter verifies native AIC/BIC arithmetic and retains native
`aBIC = D + log((n - 2) / 24)k`; it never copies that value into common
`SABIC`. Seven deterministic fixtures cover ready MML arithmetic, unchecked
integration, JML suppression, the small-N SABIC boundary, inconsistent
deviance/log-likelihood, and incomplete identity. A local TAM 4.3-25 PCM
development run also exercised the object adapter. These are pilot/unit
observations, not candidate-linked external evidence.

Arithmetic eligibility and comparison readiness are distinct. A record can
show reproducible common criteria while remaining non-comparable. Delta
criteria, weights, and preferred labels require all candidates to have:

- MML, finite consistent deviance/log-likelihood, free dimension, and Person
  count;
- one shared observation-set, likelihood-basis, constraint-basis, and
  integration-comparison identity;
- an engine-specific integration-evaluation identity;
- reviewed convergence status `pass`; and
- integration-stability status `pass`.

The public `import_tam_fit()` route now accepts only verified unidimensional
`tam.mml` objects. It rejects `tam.jml` rather than relabelling it as MML and
rejects `ndim > 1` rather than exposing a flattened one-scale imported fit.
Native TAM criteria and version provenance remain descriptive on supported 1D
imports, which cannot enter the current mfrmr IC contract automatically.
Dimension-aware TAM evidence belongs to the separate repository runner.

Draft.7 adds `mfrmr_conquest_ic_handoff_v1` to the ConQuest bundle and the
repository-only external normalizer. The generated command retains the
estimate `matrixout` history as CSV. The adapter reads its documented third
matrix column as deviance, checks the history free dimension independently
against the combined parameter/regression/covariance export rows, checks the
final history vector against those exports, and requires the case-EAP PIDs to
match the expected bundle Person IDs exactly. In ConQuest 5.47.5 the native CSV header calls that objective
column `LogLikelihood` even though its positive values are the deviance stated
in manual section 4.9.2 and match the human summary table; the audit preserves
this header discrepancy rather than silently trusting the label.
The adapter is locked to audited ConQuest 5.47.5; a later engine version must
receive a schema/objective audit before it can enter the handoff.

Draft.8 fixes the generated ConQuest benchmark controls at parameter change
`1e-8`, deviance change `1e-10`, and 2000 iterations. In the 60-Person,
six-item, one-covariate binary pilot, ConQuest's default stopping rule ended at
iteration 42 with deviance `424.739512`, approximately `0.000533` above mfrmr.
The strict run ended at iteration 132 with deviance `424.738979`, versus mfrmr
`424.738979414`; the difference `-4.14e-7` is within the six-decimal ConQuest
CSV resolution. The largest exported transformed-parameter difference was
`5.77e-6`. This removes an apparent additive likelihood-constant discrepancy
for this one pilot but does not freeze a tolerance or establish RSM/PCM and
cross-platform agreement.

Draft.9 adds repository-only contract
`mfrmr_conquest_binary_ladder_v1`. It prepares but never launches the external
program, then reviews strict runs at q=7, 15, 31, 61, 91, and 121 plus a second
same-platform q=31 run. The q=31--121 rows all passed the arithmetic handoff:
ConQuest deviance was `424.738979`, the maximum absolute cross-engine deviance
difference was `4.142e-7`, and the maximum transformed-parameter difference
was `5.762e-6`. The five native q=31 CSV outputs were byte-identical across
the two runs. The q=7 row was rejected after ConQuest retained an earlier
higher-likelihood solution and its final history/export vectors differed by
up to `0.036778`; q=15 was rejected despite deviance-criterion termination
because its final history/export vectors differed by up to `8.7e-5`.

Draft.10 adds repository-only contract
`mfrmr_conquest_polytomous_rsm_pcm_v1`. It prepares one deterministic
120-Person, five-item, four-category input and matched q=31 latent-regression
fits using ConQuest `item + step` for RSM and `item + item*step` for PCM. The
reviewer verifies complete category coverage, audited native 5.47.5 parameter
label order, history/export identity, free dimensions, item sum-zero, shared
RSM step sum-zero, and item-specific PCM step-row sum-zero constraints. It
never starts the external executable.

Both same-platform runs terminated on the deviance criterion after 63
iterations. RSM retained 9 and PCM 17 free parameters in both engines; all
reconstructed sum-zero residuals were exactly zero. The largest absolute
ConQuest-minus-mfrmr deviance difference was `1.24811e-6`, the largest free or
full transformed-parameter difference was `1.604646e-6`, and the
cross-engine difference in the RSM-minus-PCM deviance drop was `1.10628e-6`.
Every row remains `ComparisonReady = FALSE` because integration stability is
still `review` and no tolerance has been frozen.

Draft.11 replaces the one-pair pilot contract with
`mfrmr_conquest_polytomous_rsm_pcm_ladder_v1` and applies that same fixed input
to q=7, 15, 31, 61, 91, and 121 plus a fresh q=31 directory for each model.
Every q=31--121 RSM and PCM core row passed the arithmetic handoff. ConQuest
deviance was constant at six-decimal export resolution within each core; the
maximum absolute cross-engine deviance difference was `1.24811e-6`, the
maximum free or full transformed-coordinate difference was `1.674273e-6`,
and the maximum cross-engine difference in the RSM-minus-PCM deviance drop was
`1.10628e-6`. The mfrmr core deviance ranges were `5.96e-8` for RSM and
`8.7637e-7` for PCM. Within each model, all five native q=31 CSV files were
byte-identical across the two runs.

The low-node rows are deliberately retained. RSM q=7 and q=15 passed the
schema/arithmetic handoff but differed from mfrmr by `4.437555` and
`-0.227498` deviance units; PCM q=15 differed by `-0.116292`. PCM q=7 was
rejected because its terminal history and native export vectors differed by
`1e-6`. Thus `accepted_arithmetic` means that a native result can be audited,
not that cross-engine agreement or integration stability has passed.

This handoff now establishes reproducible arithmetic, one same-platform binary
repeat, a useful coarse-node diagnostic boundary, and same-platform
polytomous likelihood/constraint mapping, node-ladder, and repeat evidence
only. Independent platform/version replication, integration-tolerance freeze,
and candidate-linked mfrmr/TAM/ConQuest runs remain pending;
`mfrmr_external_ic_v1` must not be used to manufacture cross-engine
comparability by assigning identical identity strings without that evidence.

## G4: dimensionality challenge

The dimensionality challenge follows three stages and never creates a native
multidimensional mfrmr feature.

### Current draft.6 TAM runner state

Contract `mfrmr_tam_dimensionality_pilot_v1` keeps multidimensional TAM
objects in repository evidence and outside `import_tam_fit()`. Its first
binary-Rasch matrix uses one prespecified true-1D and one prespecified true-2D
control, fixed Q hashes, product grids of 15/21/31/41 nodes per dimension, and
deterministic QMC grids of 512/1024/2048/4096 nodes. All 32 fits preserved the
observation set, had finite fit/IC-consistent objectives and positive-definite
latent covariance matrices, stopped before the iteration ceiling, and emitted
no warnings or hard failures. Ten remain `review` because TAM's final reported
objective did not equal the last iteration-history value.

The true-1D 15-point product row reverses all three common-IC signs; the
21--41 point rows agree and have maximum criterion-gap drift 0.000102. The
true-2D product rows retain all signs, with maximum full-ladder gap drift
0.025685. Deterministic-QMC signs are stable, but maximum gap drift reaches
0.188133. Two independent 1024-node QMC refits for each model/control reproduce
deviances and retained parameters exactly, separating finite-node drift from
run-to-run randomness for these TAM 4.3-25 cells.

The first `QMC = FALSE` audit uses 1024 stochastic nodes and four operative
seeds. Every external integration-evaluation identity includes its seed. The
maximum criterion-gap seed difference is 3.965763 in the true-1D control and
2.865980 in the true-2D control; true-1D raw deviance-gain sign changes across
seeds. No hard failure or warning occurred, but all stochastic results remain
review-only. A single stochastic run or a retrospectively favored seed cannot
enter release evidence.

These are single-seed calibration observations. Every normalized record keeps
integration stability unchecked, selection is unauthorized, no ordinary
chi-square LRT p-value is produced, and no dimension score is returned.
Replicated truth cells, multi-node/platform stochastic integration and its
seed-aggregation rule, platform review, boundary bootstrap, empirical
partitioning, interaction attribution, and consequence criteria remain
unresolved.

### Explore

Substantive theory, design review, residual PCAR/parallel evidence, and
Q3-style residual patterns generate candidate clusters, local-dependence
pairs, rater effects, and Q matrices. The discovery output is a versioned
hypothesis set only.

The current `q3_statistic()` uses standardized residuals aggregated to
Person-by-facet-level cells. It is not relabelled as raw-residual Yen Q3 or the
published maximum-relative-to-mean Q3*. Fixed residual cutoffs remain
exploratory. A formal blocking Q3* route requires an explicit residual unit,
multiplicity policy, and design-specific parametric bootstrap.

`analyze_residual_pca()` is likewise an exploratory hypothesis generator.
Before confirmation, `DIAG-PCAR-NULL` and `DIAG-PCAR-LOCAL` freeze the residual
unit, missing-pair correlation and smoothing rules, permutation unit, retained
quantile precision, topology/missingness grid, and failed-replicate policy.
The draft.19 pilot detected planted local dependence but also flagged one
balanced single-seed row, and weak-overlap PC1 differed between mfrmr and
FACETS despite row-residual correlations above 0.996. External raw PCA and
mfrmr permutation PCAR are therefore separate sensitivity definitions, not a
pooled statistic.

Fixed `Rater:Criterion` interaction recovery and `estimate_bias()` screening
also remain separate. `DIAG-BIAS-NULL` and `DIAG-BIAS-NONNULL` estimate
conditional false-positive and detection behavior across effect size, cell
information, category support, topology, multiplicity, and numerical-
readiness state. A conventional p-value/t screen is not a frozen automatic
decision rule. FACETS Table 14 enters only through a separately parsed `?B`
control after its estimand and uncertainty definitions are matched.

### Confirm

- Freeze Q matrices, labels, variance/covariance constraints, response family,
  partition, integration policy, starts, metrics, and failure policy.
- Establish matched mfrmr-versus-TAM 1D overlap before using TAM alternatives.
- Compare TAM 1D with prespecified TAM multidimensional models on untouched
  Persons or an external sample.
- Use the four-model attribution grid where identified: 1D additive; 1D plus
  rater-by-criterion interaction; multidimensional additive; and
  multidimensional plus interaction.
- A deliberately confounded design is classified unidentified; fit gain is
  not assigned to either explanation.
- Do not use a direct cross-engine LRT. Within-engine nesting must be proved.
  When 1D lies on a variance/correlation boundary, use a frozen parametric-
  bootstrap deviance-difference reference rather than the ordinary chi-square
  p-value.
- Report deviance gain per Person and response, normalized AIC/BIC/SABIC,
  held-out predictive gain where feasible, residual change, dimension
  correlations, parameter stability, failed/singular replicate rates, and
  numerical integration uncertainty.

True-1D false-selection control, true-2D detection power, bootstrap size,
smallest practically relevant gain, and QMC-stability thresholds are
`pilot_required`. The pilot and confirmation seed/Person registries must be
disjoint.

### Test consequences

A better-fitting multidimensional model does not by itself justify subscores.
The consequence stage checks incremental prediction beyond the total score,
conditional precision/information, replication stability, classification and
rank changes, invariance, and an external criterion only where defensible.

The final classification is one of:

1. `total_score_only`: no confirmed material departure requiring a reporting
   change;
2. `multidimensionality_as_sensitivity`: structural improvement without
   defensible individual subscore value;
3. `future_subscore_research`: replicated practical value that motivates a
   later native model but does not add scores in 0.2.3; or
4. `unresolved`: identification, integration, replication, or consequence
   evidence is insufficient.

`unresolved` cannot support an unqualified unidimensionality claim.

## G5: external comparison

ConQuest is the required 0.2.3 external MML core for matched unidimensional
binary, RSM, and PCM cases. Each row matches observations, missingness,
categories, model, constraints, quadrature, starts, convergence review,
orientation, and parameter transformation as far as the programs permit.
Correlations are descriptive; blocker tolerances apply to signed/absolute
differences on named estimands.

TAM supplies a second MML reference where its unidimensional likelihood,
population, design matrix, constraints, and integration evaluation can be
matched. This row remains distinct from TAM's within-engine 1D/2D
dimensionality challenge and from every TAM JML mode; none may borrow another
row's likelihood or recovery conclusion.

FACETS 4.5.0 is the selected 0.2.3 external JML stress implementation for RSM
and PCM. The environment record in `facets-jml-stress-plan-0.2.3.md` captures
orientation, constraints, parser behavior, and executable/report identity but
does not stop pilot execution when the current upstream release differs. The
binary microcase does not by itself validate polytomous recovery. Mandatory
core families cover connected recovery, current element/group anchors,
sparse/weak-link topology, and edge cases. Threshold anchors remain 0.2.4
scope. Fit and DFF/DIF rows remain optional promotions until definitions,
null/non-null generators, multiplicity, and tolerances are frozen.

FACETS is not ground truth. For every paired replicate, mfrmr and FACETS are
first evaluated separately against the common generating truth, then compared
on explicitly transformed common estimands. Agreement between two biased
solutions cannot pass recovery. FACETS JML Person measures are not targets for
MML EAP scores, and no JML-versus-MML equality criterion is permitted. No
proprietary program is launched by package tests, and no proprietary binary,
license material, or identifier-bearing external case file is committed.

Before a FACETS row reaches a numeric tolerance, its comparison contract must
verify the category map, retained scale/step dimension, active facets,
constraints/anchors, parameter orientation, estimability, and extreme-score
policy. A failed contract is retained as definition or failure-behavior
evidence and is never averaged into an engine-agreement statistic.
Eligibility is metric-specific: rejected extreme Person rows need not suppress
a valid nonextreme comparison, while an unmatched PCM step dimension rejects
parameter MAE even if row predictions are retained as descriptive sensitivity.
Every aggregate reports expected, eligible, rejected-by-reason, missing, and
failed denominators.

FACETS evidence is generated in isolated synthetic run directories with exact
replicate accounting, timeouts, exit/stderr capture, one process by default,
and fail-closed stale-output detection. The official-site version, executable
file metadata, report-header version, executable SHA-256, controls, inputs,
outputs, parser/generator versions, and candidate manifest are retained as
distinct fields. Different versions are analyzed as separate sensitivity
strata rather than silently pooled; the batch continues.

TAM and immer add estimator-convention evidence, not a vote among programs.
The primary identities are CRAN TAM 4.3-25 and CRAN immer 1.5-13. Audited
development snapshots TAM 4.4-2 and immer 1.6-1 may be executed only as
separately labelled sensitivity strata. Package version, source identity, R and
dependency versions, function/default arguments, response/design-matrix hash,
output hash, and normalizer version are mandatory provenance. A change in a
default adjustment creates a different method-mode identity even if the
package label otherwise appears unchanged.

The JML grid includes mfrmr uncorrected JML and, where supported, TAM and immer
unadjusted, extreme-score-adjusted, and bias-corrected modes. Each mode is
declared before pilot results are inspected. Comparisons reuse the same
observations, weights, category map, active facets, design-matrix columns,
constraint/free-coordinate map, parameter orientation, and generating truth.
Unadjusted and adjusted/corrected results are never pooled. Extreme and
nonextreme Person rows receive separate denominators; any finite display for a
theoretically unbounded extreme measure is not treated as ordinary parameter
recovery.

Truth recovery, interval coverage or explicit SE unavailability, false-ready
and failed-run behavior, and transformed between-program differences are
reported separately by model, parameter class, design cell, and method mode.
The grid must include balanced exposure, unequal workload, two raters,
sparse/weak-link assignment, planned and unplanned missingness, category
imbalance, extreme scores, and an incidental-parameter sequence in which the
number of Persons grows while observations per Person remain fixed. Agreement
between two biased modes cannot pass, and the best-agreeing mode cannot be
selected post hoc.

A correction such as `(I - 1) / I` is reference evidence, not a native mfrmr
specification. With arbitrary facets, missingness, unequal exposure, and
design-matrix pseudoitems, the effective `I` must be defined before transport.
A future native correction needs a separate proposal, balanced-case reduction,
identification/anchor proof, and prespecified improvement in bias/RMSE without
unacceptable coverage, boundary, or failure-rate cost.

immer CML and CCML rows are eligible only for matched Rasch-family structural
parameters that remain after conditioning. Their contract verifies the
sufficient statistic, category support, design rank, constraint basis,
missingness treatment, and parameter transformation. Person measures,
bounded-GPCM quantities, latent-regression parameters, and quantities removed
by conditioning are ineligible. These rows are external references and do not
create native `fit_mfrm()` methods.

The immer HRM lane is an alternative-data-generating-model stress test. It
requires a frozen latent true-rating, rater severity/variability, prior, MCMC
diagnostic, and replication contract. It evaluates the behavior of additive
mfrmr readiness, bias, and residual diagnostics under local dependence; it is
not included in parameter/objective engine tolerances, cannot be exposed as
`method = "HRM"`, and cannot establish model preference from one fitted sample.

External numerical tolerances are `pilot_required`; the mandatory scenario
scope and fail-closed provenance rules are structural blockers now.

## G6: public contract

Before release, code, help, README, vignettes, capability tables, reports,
exports, and runtime guards must agree that:

- the current latent trait is unidimensional;
- PCAR/Q3-style output is exploratory hypothesis-generation evidence;
- AIC/BIC/SABIC apply only under the recorded MML comparability contract;
- IC-derived weights are not unconditional model probabilities;
- `JML` is canonical and `JMLE` is only an input alias;
- a common MML/JML interface does not imply equal estimator maturity, and JML
  correction/uncertainty limitations remain visible wherever relevant;
- CML/CCML and HRM are not current `fit_mfrm()` estimator choices, and HRM is a
  distinct latent-data/local-dependence model rather than a backend;
- threshold anchors, frozen calibration, multiple scales, scale-specific PCM,
  native multidimensional scores, and unrestricted GPCM remain later work;
- external comparisons cover matched rows rather than blanket equivalence; and
- repository planning, local paths, development decisions, and private
  evidence language do not leak into installed first-screen output.

Unsupported routes fail closed or display an unavoidable caveat before the
affected quantity is interpreted.

## G7: engineering release

The exact candidate must pass:

- full regression outside CRAN and the required macOS/Windows/Linux R matrix;
- `R CMD check --as-cran --run-donttest` on the exact upload tarball;
- manuals, URLs, examples, package-content, source-truth, and terminology
  audits;
- official Win-builder or the then-current CRAN-equivalent Windows check; and
- a package-controlled CRAN workload below 600 seconds.

The 600-second gate sums ordinary examples, `donttest` examples, tests, and
vignette rebuilding. Dependency installation, manuals, and check
infrastructure remain diagnostic context rather than package-controlled time.
Heavy recovery, bootstrap, and external gates run outside CRAN and remain
candidate-linked and reproducible.

## Numeric criteria still required before freeze

The following criterion IDs are intentionally unresolved in the current
draft:

| Criterion ID | Required frozen content |
| --- | --- |
| `NUM-SCORE-TOL` | Absolute/scaled canonical-score tolerance by model and parameter class. |
| `NUM-OBJECTIVE-TOL` | Cross-engine objective tolerance at common evaluation. |
| `NUM-PARAMETER-TOL` | Transformed parameter tolerance by estimand. |
| `REC-GRID` | Core sample sizes, facet counts, category support, link density, and slope cells. |
| `REC-MCSE` | Replication rule and maximum Monte Carlo uncertainty. |
| `REC-BIAS-RMSE` | Practical bias and RMSE limits by parameter class. |
| `REC-COVERAGE` | Supported-interval coverage limits and SE-availability rule. |
| `REC-FAILURE` | Maximum failed-fit and false-ready rates. |
| `IC-INTEGRATION-TOL` | Maximum acceptable IC/deviance drift across the integration ladder. |
| `DIM-TYPE1` | Maximum false multidimensional selection rate with Monte Carlo margin. |
| `DIM-POWER` | Minimum detection rate for each prespecified true-2D core. |
| `DIM-PRACTICAL-GAIN` | Smallest practical predictive/score consequence. |
| `DIM-BOOTSTRAP` | Bootstrap replication and failed/singular replicate policy. |
| `EXT-CQ-TOL` | ConQuest signed/absolute tolerances by common estimand. |
| `EXT-FACETS-IDENTITY` | Recorded executable SHA-256/file metadata, report-header version, parser/generator identities, and separate-stratum policy for version or stale-output differences. |
| `EXT-FACETS-GRID` | Mandatory RSM/PCM core, anchor, sparse, and edge cells plus optional fit/DFF promotions and explicit exclusions. |
| `EXT-FACETS-TOL` | Truth-recovery and transformed between-program tolerances by model, parameter/statistic, design cell, and estimand. |
| `EXT-FACETS-MCSE` | Replication, complete-case accounting, Monte Carlo uncertainty, failed-run, and escalation rules. |
| `EXT-JML-MODE-GRID` | Frozen TAM/immer function arguments, raw/adjusted/bias-corrected method identities, balanced and adversarial design cells, and explicit exclusions. |
| `EXT-JML-TOL` | Transformed between-program tolerances by structural parameter, nonextreme Person estimand, design cell, and JML convention. |
| `EXT-JML-RECOVERY` | Truth-bias/RMSE and incidental-parameter trend limits by method mode; agreement alone cannot satisfy this criterion. |
| `EXT-JML-COVERAGE` | Supported SE/interval availability, coverage, width, and boundary policy by method mode and parameter class. |
| `EXT-CML-TOL` | CML/CCML structural-parameter transformation, recovery, and matched-overlap tolerance with explicit ineligible quantities. |
| `EXT-EST-MCSE` | Replication, failed-run, complete-case denominator, Monte Carlo precision, and no-post-hoc-mode-selection rules for TAM/immer lanes. |

No placeholder above may be filled after its confirmatory result is viewed.
If pilot evidence cannot support a defensible threshold, the corresponding
claim is reduced or deferred rather than decided ad hoc.

## Revision record

| Specification | Change |
| --- | --- |
| `0.2.3-draft.1` | Initial roadmap-to-gate translation. |
| `0.2.3-draft.2` | Recorded the M1 source audit; made all non-unit-weight IC ranking fail closed; added legacy-object, canonical-recomputation, and `Npar` compatibility rules; and linked the fixed IC fixture contract. |
| `0.2.3-draft.3` | Added the fixed-vector common-GHQ pilot policy, recorded the first RSM-versus-PCM run and six-scenario development matrix, and named candidate ladder/drift rules while leaving `IC-INTEGRATION-TOL` unfrozen. |
| `0.2.3-draft.4` | Added independent refit-at-grid/common-reference evidence, introduced `mfrmr_ic_person_v2`, and made q<31 comparison-derived selection output fail closed while leaving the ladder and `IC-INTEGRATION-TOL` unfrozen. |
| `0.2.3-draft.5` | Centralized the common IC formula panel, added fail-closed external normalization with native TAM aBIC preservation, and made public TAM imports reject JML and multidimensional objects rather than relabelling or flattening them. |
| `0.2.3-draft.6` | Added a separate dimension-aware TAM 1D/2D runner, recorded the first product-quadrature, deterministic-QMC, and four-seed stochastic-integration truth controls, made stochastic seeds part of integration identity, distinguished final-history review from objective inconsistency, and verified exact same-node QMC replay while leaving every dimensionality criterion unfrozen. |
| `0.2.3-draft.7` | Added explicit ConQuest stopping controls, a matrixout-history export, and a repository-only adapter that cross-check deviance, free dimension, exported parameter vectors, unit weights, Persons, convergence evidence identity, run metadata, and output fingerprints without parsing the free-form summary report; recorded the 5.47.5 objective-header discrepancy and left likelihood-constant, constraint, integration, RSM/PCM, and candidate-linked comparisons unresolved. |
| `0.2.3-draft.8` | Made ConQuest benchmark stopping controls explicit and strict, reran the binary 31-node pilot, and showed that the apparent `5.33e-4` objective discrepancy under ConQuest defaults shrinks to `4.14e-7` at strict convergence, while leaving tolerance calibration, replication, RSM/PCM, platform, and candidate-linked evidence unresolved. |
| `0.2.3-draft.9` | Added a repository-only ConQuest binary node-ladder preparer/reviewer, repeated q=31 with byte-identical native outputs, retained arithmetic agreement over q=31--121, and demonstrated fail-closed q=7/q=15 rejection from final-history/native-export disagreement; independent-platform replication, RSM/PCM, tolerance freeze, and candidate-linked evidence remain unresolved. |
| `0.2.3-draft.10` | Added a repository-only four-category ConQuest RSM/PCM preparer/reviewer, matched q=31 objective/free dimensions and explicit sum-zero coordinate reconstruction on one same-platform input, and retained all rows as pilot-only; independent-platform replication, a polytomous node ladder, tolerance freeze, and candidate-linked evidence remain unresolved. |
| `0.2.3-draft.11` | Extended the fixed four-category ConQuest RSM/PCM pilot to q=7/15/31/61/91/121 ladders and fresh same-platform q=31 repeats; retained objective and transformed-coordinate agreement across both q=31--121 cores, byte-identical native q=31 outputs within each model, and diagnostic low-node instability/fail-closed evidence while leaving independent-platform replication, tolerance freeze, and candidate-linked evidence unresolved. |
| `0.2.3-draft.12` | Added the fixed-fixture canonical free-score pilot, independently implemented three-step central differences at retained and nonzero-score points, the explicit free-log-slope to sum-zero-log to positive-slope GPCM Jacobian contract, and exact binary/unit-slope reductions; corrected the earlier box-constraint/projected-gradient wording while leaving `NUM-SCORE-TOL`, engine parity, expanded boundary-regime calibration, and confirmation unresolved. |
| `0.2.3-draft.13` | Added the fixed-fixture additive RSM/PCM engine-path pilot, exact hashed raw-EM-to-common-direct-polish handoff, common-vector objective/score evaluation through direct/EM/hybrid contexts, free and expanded parameter comparisons, and an explicit GPCM/interaction/latent-regression fallback boundary; left `NUM-OBJECTIVE-TOL`, `NUM-PARAMETER-TOL`, broader grid/platform calibration, and confirmation unresolved. |
| `0.2.3-draft.14` | Bound release-readiness output to an exact candidate-manifest schema, tarball/check-log/specification/checklist SHA-256 identities, a frozen specification ID, explicit confirmation authorization, and machine-checked current-versus-future public API truth; retained missing manifests, draft specifications, unfrozen blocker criteria, and every identity mismatch as concerns, so M3 and confirmation remain unauthorized. |
| `0.2.3-draft.15` | Added a release-readiness guard against carrying numeric test/check pass counts forward in current README, NEWS, or cran-comments prose; historical NEWS sections remain untouched, while current engineering status must come from the exact candidate-linked logs and hashes. |
| `0.2.3-draft.16` | Added fail-closed loading of candidate-linked gate-result rows, exact commit/specification identity checks, retained evidence-path SHA-256 verification, checklist item/scenario completeness, and blocker/roadmap/caveat status propagation into the release decision. |
| `0.2.3-draft.17` | Promoted FACETS from a conditional supplied-output row to a mandatory JML RSM/PCM stress lane; pinned local 4.5.0 with a non-blocking identity record and separate-version strata; separated truth recovery from program agreement; added anchor, topology, missingness, edge, optional DFF, Monte Carlo, stale-output, and support-envelope requirements; and retained all new numeric criteria as pilot-required. |
| `0.2.3-draft.18` | Added the first paired FACETS 4.5.0 RSM/PCM stress driver and one-seed 44-run pilot; expanded missingness, sparse, topology, duplicate, category-support, extreme-score, and contamination cells; verified fail-closed disconnected-design reporting; identified binary connectivity as insufficient for a single-bridge design; recorded 4.5.1 reporting/test sensitivity; and retained every external numeric threshold and confirmation claim as unresolved. |
| `0.2.3-draft.19` | Added two-rater, severe category-imbalance, checkerboard-interaction, and residual-local-dependence FACETS 4.5.0 extension cells plus a separate interaction/bias/PCAR runner; diagnosed false-ready zero-common-Person and category-support states, weak-interaction screening limits, and weak-overlap PCA-definition sensitivity; added scenario IDs and required quantitative design/category/diagnostic gates while retaining all results as one-seed pilot evidence. |
| `0.2.3-draft.20` | Added a repository divergence audit before FACETS tolerances; established exact rank deficiency in the zero-common-Person and other sparse controls, reclassified the severe PCM parameter gap as a retained-category/step-dimension mismatch plus false readiness rather than a demonstrated kernel defect, separated nonextreme Person agreement from FACETS adjusted extreme displays, and required estimability, category-contract, typed-extreme, and diagnostic-definition guards before confirmation. |
| `0.2.3-draft.21` | Converted the divergence diagnosis into eight dependent work packages; separated fit-, parameter-, and metric-level readiness; made JML/MML estimability rules distinct; specified sparse rank and category/step records, generalized typed JML boundary states, required one-source cross-surface propagation and legacy-object handling, and made external eligibility metric-specific with complete rejection accounting before the new-seed repilot. |
| `0.2.3-draft.22` | Completed the structural WP0 readiness contract: froze the internal v1 state vocabulary, deterministic fit precedence, conservative `InferenceReady` mapping, parameter and comparison states, controlled reason codes, typed condition/runtime policy, fail-closed 0.2.2-object mapping, and a validated 27-row adversarial fixture registry. Runtime implementation and every statistical threshold remain pending. |
| `0.2.3-draft.23` | Began WP1 runtime implementation with a sparse adjacent-category-logit rank audit in the actual RSM/PCM free-coordinate basis; added typed pre-optimization errors for exact aliases, counterfactual-JML classification of MML population-assumption linkage, bounded null explanations, and row-order, relabelling, anchor, PCM-step, interaction, and constraint-Jacobian controls. QR tolerance disagreement is diagnostic only and cannot become `weak_information` before the fitted-information rule is piloted and frozen. Nonlinear and fitted-information completion remains pending. |
| `0.2.3-draft.24` | Separated workflow integration from estimator maturity; added the TAM/immer estimator stress plan with raw, extreme-adjusted, bias-corrected, and combined-default JML modes as distinct truth-first comparison strata; limited immer CML/CCML to eligible Rasch-family structural estimands; classified HRM as an alternative latent/local-dependence model; prohibited automatic transport of finite-item correction and ambiguous `GMFRM` naming; and left every new numerical threshold and pilot result unresolved. |
| `0.2.3-draft.25` | Added the first bounded fitted-information instrument for stationary nonlinear fits: a dense numerical observed-information Hessian from the direct objective and analytical gradient, a diagnostic eigenvalue tolerance ladder, nonlinear-block summaries for GPCM log slopes and latent-regression residual variance, and explicit nonstationary/dimension-limit/unavailable states. The 80-coordinate cap is computational; no result classifies weak information, changes readiness, completes nonlinear structural identification, or freezes a release threshold. |
| `0.2.3-draft.26` | Added a separate retained-vector nonlinear transformation audit for GPCM log slopes and latent residual variance; recorded analytic and central-difference Jacobian agreement, dimensions, rank ladders, invariants, ranges, and conditioning; and made the result explicitly parameterization-only. Response-likelihood/design Jacobians, structural or weak-information classification, readiness effects, and frozen thresholds remain pending. |
| `0.2.3-draft.27` | Added the retained JML GPCM adjacent-category-logit Jacobian over the full constrained optimizer vector, joining additive and sum-zero log-slope coordinates; verified analytic derivatives, unit-slope additive reduction, row-order invariance, and nonbinding execution limits; and made MML fail closed with an explicit person-integrated response-pattern requirement. Local structural/weak-information classification, readiness effects, MML response geometry, latent-variance response geometry, and frozen thresholds remain pending. |
| `0.2.3-draft.28` | Added a bounded observed-Person-pattern marginal score decomposition for nonlinear MML fits; verified Person contribution sums against the full objective and analytic gradient, checked each pattern score against central differences, retained observation-row invariance and privacy controls, and recorded an explicit rank-deficient-but-derivative-correct negative control. All-possible-pattern structural geometry, expected-information rules, readiness effects, scale benchmarks, and frozen thresholds remain pending. |
| `0.2.3-draft.29` | Added bounded exhaustive response-pattern expected-information instrumentation for nonlinear MML fits under unit weights; verified probability mass, zero expected score, score-outer-product information, selected central differences, row-order invariance, missing-row semantics, latent-regression coordinates, nonunit-weight rejection, privacy, and execution limits. A degenerate one-node control demonstrates that exhaustive-pattern rank remains local and integration-rule dependent. Global structural arguments, scalable target-size methods, readiness effects, and frozen thresholds remain pending. |
| `0.2.3-draft.30` | Added exact Person-design reuse to bounded MML all-pattern expected information; canonicalized within-Person layouts, included active population-design rows in the signature, reconstructed information by group multiplicity, recorded conceptual versus evaluated workloads, matched a forced non-reuse reference, separated missing and distinct-covariate designs, and retained privacy. Unique long-design exponential cost, target-size benchmarks, readiness effects, and frozen thresholds remain pending. |
| `0.2.3-draft.31` | Began WP2 with a model-scoped category and step-support preflight; separated declared, observed, retained, free, fixed, derived, weak, and unsupported coordinates; derived the exact adjacent-step recession direction for zero-count internal categories under the sum-zero parameterization; kept boundary gaps in separate weak/element-boundary review; distinguished RSM shared-ladder from PCM/GPCM step-scope support; preserved binary no-free-step reduction; retained typed failure provenance and zero-row schemas in design evaluation; and added invariance and privacy controls. Weak-information calibration, structural-zero declarations, threshold anchors, multiple scales, WP4 propagation, WP5 external eligibility, and new-seed recovery remain pending. |
| `0.2.3-draft.32` | Began WP3 with a Person-scoped sufficient-score boundary audit on retained contributing observations; replaced finite optimizer-dependent primary values for standard free JML extremes with typed negative or positive infinity while retaining the iterate as a numerical trace only; retained contributing row and positive-weight totals; separated directly or implicitly fixed, constraint-coupled review, nonextreme JML, and finite prior-regularized MML/EAP cases; removed ordinary SE/CI eligibility from typed boundaries; and made FACETS-style endpoint placement explicit without creating a finite adjusted estimate. Generalized non-Person and interaction recession directions, a named optional adjustment, complete WP4 propagation, external eligibility, and new-seed recovery remain pending. |
| `0.2.3-draft.33` | Added a bounded linear-program certificate for JML additive structural recession with Person coordinates fixed; transformed the exact adjacent-category design into retained observed-versus-alternative contrasts; reused facet signs, direct/group anchors, centering, interaction, and step Jacobians; tested every expanded target in both directions; rejected structural-null-only candidates through strict-margin post-solve checks; retained direction loadings, execution-limit and dependency states, MML non-applicability, and public-table non-propagation. Joint Person movement, GPCM slope recession, sparse target-size execution, independent solver parity, WP4 propagation, and new-seed recovery remain pending. |
| `0.2.3-draft.34` | Replaced dense positive/negative-split LP constraints with the solver's sparse triplet interface; retained an explicitly bounded dense-reference route; recorded variables, constraints, sparse nonzeros, dense-equivalent elements, structural coordinates, target directions, and representation; added independent ceilings for each workload dimension; matched sparse and dense target capacities/statuses in two-Rater and checkerboard-interaction fixtures; retained two-Rater row-order invariance; matched checkerboard interaction directions to a test-only finite-grid oracle; and verified sparse construction on a 20,000-row by 100-coordinate synthetic matrix without allocating its dense equivalent. General independent solver parity, end-to-end target-size runtime/memory, joint Person movement, GPCM slope recession, WP4 propagation, and new-seed recovery remain pending. |
| `0.2.3-draft.35` | Added a companion joint Person-structural additive recession audit over the exact retained observed-category contrast cone; screens global cone existence before target enumeration; includes all free Person coordinates but targets only constraint-coupled extreme Persons unresolved by the sufficient-score rule plus all structural expanded targets; records global and target margin certificates and direction loadings; adds separate Person, structural, and total additive-coordinate ceilings; and defers the target-direction limit until a global ray is certified. A group-constrained two-Person/two-Item fixture proves that the joint ray can exist when both restricted subspaces have none, with sparse/dense, row-order, nonseparated, finite-grid, pre-screen coordinate-limit, post-screen target-limit, and MML non-reduction controls. Public state propagation, nonlinear GPCM slope recession, general independent solver parity, target-size runtime/memory, and new-seed recovery remain pending. |
| `0.2.3-draft.36` | Added a bounded retained-additive JML GPCM log-slope boundary-path audit. It derives monotonicity from observed maximum/minimum cumulative category utilities, exhausts ordered pair rays under sum-zero expanded log slopes, independently matches the retained likelihood to the optimizer objective, stores boundary likelihoods and expanded/free direction loadings, and separates scoped completion from global nonlinear structural identification. A fixed-Person checkerboard, direct objective-path oracle, row reversal, execution limit, and MML non-reduction controls pass; an unanchored checkerboard supplies the required negative counterexample in which no retained-point slope-only ray exists but a joint Person-plus-slope path improves. Public propagation, general joint nonlinear GPCM path coverage, broad properties, target-size evidence, and new-seed recovery remain pending. |
| `0.2.3-draft.37` | Began WP4 runtime propagation with one stored five-component fit record, deterministic precedence, a conservative scalar, controlled new reason codes, and a fail-closed legacy adapter. Fit, summary, result, convergence, and plot front doors consume the record; synthetic saved pre-contract objects cannot regain readiness from an old Boolean, and the exposed contract identifier contains no internal work-package label. Boundary aggregation distinguishes genuinely unpropagated structural/slope targets from a joint cone explained entirely by Persons already typed as unbounded. Complete parameter-primary, report/export/replay, real serialized migration, comparison-eligibility, and confirmation work remains pending. |
| `0.2.3-draft.38` | Revised the readiness contract to v2 and added GPCM slope parameter rows. Certified retained-additive JML paths map to low, high, or two-sided (`unbounded_both`) typed boundaries with extended-real or undefined primary values; scoped negative JML results and free-slope MML results remain applicable-not-evaluated rather than finite claims; unit-slope reductions are fixed. Finite optimizer estimates and local covariance intervals remain explicitly named traces, ordinary SE/CI and numeric comparison eligibility fail closed, and free-slope GPCM fit readiness remains review until estimator-specific joint-JML or marginal-MML boundary work is complete. Other parameter classes, downstream enforcement, and external eligibility remain pending. |
| `0.2.3-draft.39` | Closed the GPCM summary-level primary/optimizer ambiguity and decomposed cross-software GPCM differences by kernel, active design, steps, slopes, identification, estimator, global geometry, information, support, diagnostics, and output transformation. Added the prespecified covering stress envelope spanning two-rater panels, sparse/missing/weighted designs, category imbalance, interactions, bias, residual PCA, slope regimes, and target scale. Restricted FACETS, TAM, and immer to estimand-eligible roles instead of treating similarly named discrimination output as interchangeable. Executable grid completion, estimator-specific global boundary work, numeric criterion freeze, and confirmation remain pending. |
| `0.2.3-draft.40` | Added the first bounded joint nonlinear JML GPCM path family: ordered `+1`/`-1` log-slope rates with simultaneous constrained linear additive movement, sparse LP sufficient conditions, analytic boundary likelihoods, and candidate-specific contract-v3 reasons. The unanchored checkerboard supplies a positive case missed by the slope-only check; balanced repeated outcomes, row reversal, workload limits, direct objective paths, and MML non-reuse provide negative and scope controls. Positive candidates remain without a global primary value, and negative results do not imply finite slopes. General rate vectors, curved paths, marginal-MML boundary work, target-scale evidence, and confirmation remain pending. |
| `0.2.3-draft.41` | Implemented the internal GPCM stress covering-grid runner: four estimator/lower-model modes, 12 total axes, 12 mandatory adversarial corners, 70 pilot cells, and complete coverage of all 1,330 two-axis level pairs. Added disjoint smoke/pilot/confirmation seeds, manifest and retained-data hashes, explicit one-slope-level generator non-executability, missingness/category/topology/cell/interaction/diagnostic transforms, false-ready and primary-versus-optimizer reporting, and an exploratory residual-PCA lane. Initial deterministic smoke controls show zero false-ready results for zero-shared-Person and internal-zero-category cases and reach residual PCA for an Occasion-distinguished local-dependence case. External numeric comparison, thresholds, and every current run remain ineligible, unfrozen, and calibration-only. Full replicated pilot, target-scale evidence, matched external normalizers, candidate freeze, and confirmation remain pending. |
| `0.2.3-draft.42` | Added an isolated one-axis attribution manifest around one fixed GPCM reference and four paired analysis routes per retained dataset. The five-replicate pilot has 40 arms and 800 route rows, common pilot seeds, a disjoint reserved confirmation range, parameter-class coordinate flags, separate JML/MML Person estimands, exact-unit-slope versus misspecified PCM roles, truth-aligned Person/facet/step metrics, optimizer-only slope diagnostics, and a fail-closed full-pilot resource authorization. A 24-row smoke spanning the reference, two raters, internal category zero, zero shared Persons, Person-by-rater interaction, and local dependence produced zero route-data identity violations and zero false-ready rows; two zero-shared-Person JML rows failed closed. Ready additive PCM rows under planted dependence are retained as evidence that numerical readiness is not model adequacy. All slope-primary, external-numeric, threshold, recovery, diagnostic, and confirmation decisions remain ineligible or unfrozen. |
| `0.2.3-draft.43` | Added guarded feasibility, core, and expanded replicated-attribution tiers, complete four-route/hash ledgers, Wilson intervals, numeric and Bernoulli Monte Carlo summaries, and runtime forecasting. The authoritative corrected feasibility run completed 80 of 80 routes and 20 of 20 data cells with zero identity violations, fit failures, false-ready rows, primary-slope eligible rows, or external-numeric eligible rows. Filtered-row arms exposed a common MML EAP Person-order defect; commit `655f6bf` aligns EAP and posterior-SD summaries by Person index and adds row-reversal invariance coverage. Pre-fix Person and EAP-derived diagnostic evidence is invalidated, while identical hashes show structural recovery and readiness were unchanged. A missing `lpSolve` run separately demonstrated dependency-sensitive fail-closed behavior; authoritative v4 used `lpSolve` 5.6.23. With only two replicates, wide Wilson intervals, no atomic resume, incomplete metamorphic grids, unmatched external normalizers, and open recovery/coverage and diagnostic calibration, no criterion, candidate, or confirmation state is frozen. |
| `0.2.3-draft.44` | Added atomic checkpoint/resume at the complete four-route data-cell boundary. Checkpoint-v1 identity combines selected and declared manifest hashes, actual execution controls, loaded mfrmr runtime content, the three validation runners, R/platform/RNG, numerical runtime reporting, and dependency availability/version/content. Verified same-directory temporary files are renamed into place; existing targets and unexpected RDS files fail closed. Resume validates schema, execution, cell-manifest, result payload, ScenarioId, route, DataCellId, and declared-manifest identity. Aggregate output receives a separately atomic completion marker whose artifact inventory and hashes must remain valid. Deterministic interruption, clean-run equality, mismatch, orphan-partial, path-traversal, and adulteration tests pass, and a real four-route reference cell matches the prior execution path except for elapsed runtime. The draft.43 artifacts remain historical and non-resumable. Metamorphic, target-scale, replication/precision, external, statistical-freeze, candidate, and confirmation gates remain open. |
| `0.2.3-draft.45` | Added a guarded ten-transformation by three-model MML metamorphic grid. The runner distinguishes input provenance from retained-data/result invariance, hashes declared and selected manifests separately, compares semantic output keys and quantities, and requires both fits to be numerically ready. A loose-control v1 failed five relabelling comparisons at terminal-gradient review and was retained as a superseded diagnostic rather than repaired by wider tolerances. The production-control v3 passed 30/30 with zero warnings and maximum objective, parameter, and observation differences of `3.112007e-09`, `1.862395e-05`, and `6.113984e-06`. The final runner also refuses existing output directories and deduplicates model requests; v2 retained identical numeric maxima before that storage guard. This is pilot software-property evidence only; thresholds remain unfrozen, and target-size, JML/replay/active-structure, replication/precision, external, candidate, and confirmation gates remain open. |
| `0.2.3-draft.46` | Reassessed the 87-row inventory after the MML metamorphic pass. Introduced `release_spine`, `claim_conditional`, and `deferred` portfolios so optional research does not create an accidental infinite release scope, while an unsupported callable result cannot escape through a generic caveat. Unblocked stable metric-specific WP5 fixtures, noninferential WP6 target-size work, and WP7 precision/manifest prespecification for parallel calibration; confirmation remains blocked until a machine-readable item profile, fallbacks, dependencies, criteria, and candidate identity are frozen. Rechecked official mfrmr/TAM/immer/FACETS versions without changing the local FACETS 4.5.0 execution stratum. No evidence row passed and no criterion was frozen. |
| `0.2.3-draft.47` | Added a guarded capacity-feasibility executor for all six already-declared executable 400-Person `target_sparse` cells. The run covers GPCM/PCM, JML/MML, sparse/disconnected assignment, 2--12 Raters, missingness, category imbalance/absence, weights, Occasion, interaction, bias/drift, local dependence, and residual PCA. All six cells executed with zero unexpected failures and zero false-ready rows; the mixed-adversity GPCM MML cell remained iteration-limited/blocked, two exact-rank controls failed before optimization, one PCM JML cell retained extreme-Person exclusions, and one imbalanced/missing PCM MML cell was ready but not statistically validated. The runner distinguishes one capacity replicate from five declared pilot replicates, refuses overwrite, binds runtime/manifest/artifact identity, and validates the bundle in a fresh session. Residual-PCA messages exposed a missing computability state, and R heap high-water values remain proxies rather than OS capacity evidence. No threshold, checklist row, FACETS-parity claim, candidate, or confirmation state was promoted. |
| `0.2.3-draft.48` | Added a guarded 13-cell/26-route target baseline and bridge pilot. Complete balanced and clean matched-sparse 400-Person RSM/PCM/GPCM cells use identical data across JML/MML; a PCM two-Rater gradient varies 0--40 common Persons under one truth hash. All routes executed with zero unexpected failures and zero false-ready rows. Clean sparse JML routes were iteration-limited and hundreds of seconds; MML partners were much faster but retained gradient/boundary review. Zero-overlap JML failed closed, zero-overlap MML remained population-assumption-linked, and positive-overlap traces were nonmonotone. OS process-lifetime peak memory is now recorded, PCA remains disabled pending its computability contract, the differently seeded v1 bridge output is superseded, and no recovery, overlap, runtime, memory, external, candidate, or confirmation criterion is promoted. |
| `0.2.3-draft.49` | Added a guarded 14-cell/34-route PCM JML bottleneck decomposition across Person/row growth, fixed-row Rater panel/topology, fixed-row Criterion/step growth, fixed-parameter exposure, forced extremes, paired MML controls, and explicit optimizers. P200/P400 auto L-BFGS-B blocked while explicit BFGS was ready, but R12, C12, and extreme BFGS controls remained blocked. Sparse low exposure was slower and less conditioned than a larger cell, while the largest-row cell was slowest but ready; no single monotone capacity rule survived. All routes executed with zero unexpected failure and zero false-ready state. Total elapsed/evaluation is explicitly a proxy including audits. Phase timing and replicated cross-model controls precede any optimizer change; no runtime, recovery, external, candidate, or confirmation criterion is promoted. |
| `0.2.3-draft.50` | Added opt-in, diagnostic-only 18-phase timing after all statistical and readiness decisions, with timed-versus-untimed semantic invariance tests. A fixed seven-cell/19-route subset of Draft.49 completed with all timing contracts, zero false-ready rows, and unchanged semantic hashes/readiness/optimizer states across progressively refined v1--v3 bundles. Structural and joint recession audits consumed 201.94 of 211.25 instrumented JML seconds, versus 3.70 seconds for optimization. Every structural audit enumerated 46--126 target directions and returned `none_certified`; joint target enumeration occurred only after its global cone screen certified a ray. The next corrective slice tests a structural cone prescreen under exact sparse/dense, certificate, fail-closed, and frozen-route equivalence. The optimizer-dispatch grid remains separate, and no runtime, solver, recovery, external, candidate, or confirmation rule is promoted. |
| `0.2.3-draft.51` | Implemented the versioned structural global-cone prescreen with fail-closed solver/size states and actual cone/target LP-call counters. Negative cones skip redundant target enumeration; positive cones retain it. Adversarial review identified a near-boundary false-negative risk in the ordinary target LP cutoff, added a `5e-7` counterexample, and guarded cone exclusion at objective tolerance `1e-10` versus certificate tolerance `1e-7`; v5 supersedes pre-guard v4. Integrated positive/negative, sparse/dense, row-order, anchor, interaction, retained-row, size-limit, MML, and injected solver-failure controls pass. The fixed v5 profile preserves all 19 v3/v4 semantic/readiness/boundary states and all 12 same-fit screened/unscreened structural target-status hashes. The selected negative-cone PCM routes replace 908 target LP calls with 12 cone LP calls, reduce structural phase time 90.1%, and reduce JML outer time 59.3%; all 12 JML routes are faster. All 127 package-aware test files pass, and the exact local tarball passes `R CMD check --no-manual` with `Status: OK`; this is not a complete `--as-cran` or candidate check. These one-run timings freeze no criterion. Joint cone/target attribution, target-scale positive cones, RSM/GPCM coverage, replication, capacity, recovery, external, candidate, and confirmation work remain pending. |
| `0.2.3-draft.52` | Added fail-closed joint cone/target workload counters to phase schema v6 and preserved every v5 semantic/readiness/boundary state across the fixed 19 routes. Seven negative cones used no target LPs; five positive cones consumed 48.99 of 62.52 joint-phase seconds and triggered 346 target LP calls with zero target certificates. A separate guarded three-cell attribution runner projected each cone through the full target Jacobian: all 43 nonzero coordinates were ordinary free extreme Persons already typed by the sufficient-score audit, with zero structural and zero selected-target change. The readiness guard already prevents these Person-only cones from becoming unpropagated candidates. A diagnostic row-and-coordinate quotient was negative in all three cells, but cannot become a fast path until selected-target quotient-null directions are excluded under guarded rank tolerances. No core estimator, boundary, readiness, public API, roadmap, runtime threshold, candidate, or confirmation rule changed. RSM/GPCM coverage, positive constraint-coupled controls, flat-direction counterexamples, fixed-route equivalence after correction, replication, capacity, recovery, external, candidate, and confirmation work remain pending. |
| `0.2.3-draft.53` | Added a verified ordinary-free-extreme-Person row-and-coordinate quotient plus a common-column-scaled selected-target nullspace rank screen to the joint additive JML audit. A negative quotient skips target enumeration only when base and target-augmented sparse-QR ranks are stable and equal at `1e-12`, `1e-10`, and `1e-8`; every uncertain mapping, ray, solver, rank, tolerance, or size state retains legacy work or fails closed. A flat target-changing null-direction counterexample forces fallback; RSM, row-order, target-limit, structural-positive, constraint-coupled, interaction, bounded-GPCM conditional-additive, MML, readiness, and release-readiness controls pass. Authoritative v8 preserves all 19 v6 semantic/readiness/boundary/target-status comparisons, replaces 346 joint target LPs with five quotient LPs, and reduces joint phase time 69.9% and JML outer time 50.0%; all five exclusion routes print zero rank increment across three tolerances. v7 is superseded for incomplete rank observability. The clean exact 491-entry source tarball passes `R CMD check --no-manual` with `Status: OK`; the earlier 497-entry artifact is superseded because it included six hidden change-local scripts. These one-run PCM timings freeze no criterion, and the standard local check is not an `--as-cran` or candidate gate pass; broad model/target-scale, shared-geometry, replication, capacity, recovery, external, candidate, and confirmation work remain pending. |

## Release decision algorithm

1. Reject evidence whose candidate/specification identity does not match.
2. Mark the release `No-Go` while any checklist item lacks a reviewed portfolio
   assignment or any `claim_conditional` item lacks an explicit fallback and
   public-surface map.
3. Mark the release `No-Go` for any `release_spine` blocker row that is
   `concern`, `review`, `not_run`, or missing.
4. Do not promote the claim controlled by a failed or unfinished
   `claim_conditional` row. Mark the release `No-Go` if that result remains
   primary, uncaveated, or inconsistently classified on any public surface.
5. Keep `deferred` rows guarded and outside the candidate decision; expanding
   public scope moves the affected row back into the spine before freeze.
6. Do not aggregate across a failed core cell or silently drop failed
   replications.
7. Permit a caveat row only when its limitation appears in the first screen,
   help, capability surface, and release notes for the affected result.
8. Keep every roadmap row guarded from ordinary use.
9. Require normalized common-likelihood evidence before cross-engine IC
   comparison and a passed model/category/constraint/estimability/reporting
   contract before parameter tolerances.
10. Require the practical-consequence classification in addition to formal
   dimensionality evidence.
11. Run engineering release checks only after statistical blockers pass for one
   frozen candidate.

## Source anchors

- Cho, S.-J., and De Boeck, P. (2018). A note on N in Bayesian information
  criterion for item response models. *Applied Psychological Measurement*,
  42, 169-172. doi:10.1177/0146621617726791.
- Sclove, S. L. (1987). Application of model-selection criteria to some
  problems in multivariate analysis. *Psychometrika*, 52, 333-343.
  doi:10.1007/BF02294360.
- Self, S. G., and Liang, K.-Y. (1987). Asymptotic properties of maximum
  likelihood estimators and likelihood ratio tests under nonstandard
  conditions. *Journal of the American Statistical Association*, 82,
  605-610. doi:10.1080/01621459.1987.10478472.
- Christensen, K. B., Makransky, G., and Horton, M. (2017). Critical values
  for Yen's Q3. *Applied Psychological Measurement*, 41, 178-194.
  doi:10.1177/0146621616677520.
- Morris, T. P., White, I. R., and Crowther, M. J. (2019). Using simulation
  studies to evaluate statistical methods. *Statistics in Medicine*, 38,
  2074-2102. doi:10.1002/sim.8086.
- TAM source function `tam_mml_ic_criteria()` in the official repository,
  audited at commit `8fc1c216ff8bfd8a354ae760662a4897ae46a291`, records the
  native `aBIC` formula that must remain distinct from the common Sclove SABIC:
  https://github.com/alexanderrobitzsch/TAM/blob/8fc1c216ff8bfd8a354ae760662a4897ae46a291/R/tam_mml_ic_criteria.R
- TAM 4.3-25 manual, including `tam.jml()` adjustment, bias-reduction, and
  fixed-parameter arguments:
  https://cran.r-project.org/web/packages/TAM/TAM.pdf
- immer CRAN package record and current development manual, including
  CML/CCML, JML convention, and HRM surfaces:
  https://cran.r-project.org/web/packages/immer/index.html and
  https://alexanderrobitzsch.r-universe.dev/immer/doc/manual.html
