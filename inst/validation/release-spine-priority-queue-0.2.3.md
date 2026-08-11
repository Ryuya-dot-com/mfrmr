# 0.2.3 release-spine priority queue

Status: repository-only dependency ordering, 2026-08-11. The queue covers all
53 `release_spine` rows from `claim-disposition-profile-0.2.3.csv` exactly
once. It changes no acceptance rule and does not authorize simulation,
external execution, confirmation, candidate freeze, or release.

## Portfolio decision

Checklist order is an inventory order, not an efficient execution order. The
release spine is therefore arranged into five dependency waves. A later wave
may be prepared early, but its result cannot close a row whose earlier
identity or contract dependency is still open.

| Wave | Purpose | Rows | Admission rule |
| --- | --- | ---: | --- |
| A | Freeze deterministic shared contracts and public scope | 23 | Use unit, schema, reduction, terminology, and fail-closed tests; no simulation. |
| B | Close numerical/oracle and model-identity slices | 6 | Use exact reductions, metamorphic cases, and bounded pilots only where the row requires them. |
| C | Establish metric-matched external core | 7 | Bind executable/input/output identities and raw numeric tokens before comparison; never pool engine modes. |
| D | Establish retained-core recovery and sparse behavior | 9 | Use ADEMP and decision-specific precision; retain every failure denominator. |
| E | Bind the exact candidate and reproduce release engineering | 8 | Run only after affected A--D code and criteria are frozen; rerun candidate-bound evidence. |

The counts sum to 53. Conditional and deferred rows are absent by design.

## Wave A: deterministic shared contracts and scope (23)

1. row 22 `readiness_contract_schema`
2. rows 5, 6, 8, 9 `canonical_score_reference`,
   `gpcm_transformed_score`, `maxit_ceiling_contract`,
   `exact_model_reductions`
3. row 23 `readiness_scope_and_propagation`
4. row 31 `three_tier_evidence_boundary`
5. rows 32--38 and 41 `common_formula_contract`,
   `free_parameter_dimension`, `person_sample_size_basis`,
   `legacy_n_migration`, `legacy_object_contract`,
   `weight_sample_size_policy`, `jml_ranking_boundary`, and
   `interpretation_guard`
6. row 54 `multidimensional_import_guard`
7. rows 71--76 `estimator_vocabulary`, `ecosystem_positioning_claims`,
   `current_future_scope_alignment`, `internal_wording_audit`,
   `unsupported_route_guards`, and `machine_readable_support_envelope`
8. row 92 `gpcm_generalized_family_scope_guards`

Row 22 is first because it fixes the state vocabulary consumed by readiness,
comparison, reporting, and migration work. Its structural closure does not
close row 23. The remaining Wave A order should prefer shared contracts that
can invalidate several downstream surfaces over isolated wording edits.

## Wave B: numerical/oracle and model identity (6)

- row 7 `engine_solution_agreement`;
- rows 19--21 `extreme_score_and_separation`,
  `jml_structural_recession_certificate`, and
  `jml_joint_recession_certificate`;
- row 87 `mml_metamorphic_invariance_grid`; and
- row 88 `gpcm_owner_evidence_partition`.

These rows mix deterministic proofs with bounded pilot obligations. Exact
algebra, independent objective/gradient checks, and metamorphic identities
come before replication. Owner-specific results remain separate; no pooled
GPCM umbrella may promote criterion- and rater-owned evidence together.

## Wave C: external core (7)

1. row 59 `facets_tool_identity`, row 64
   `metric_specific_comparison_eligibility`, and row 66
   `external_privacy_and_license_boundary` establish admission.
2. rows 55--57 `conquest_binary_core`, `conquest_rsm_core`, and
   `conquest_pcm_core` then run as independent, candidate-replayable,
   raw-token-preserving microcases.
3. row 60 `facets_jml_core_stress` remains method-mode-specific and retains
   adjustment, extreme-score, and failed-run denominators.

External programs are comparators, not a vote. Screen rounding, shared labels,
or agreement after an undocumented transformation cannot satisfy this wave.

## Wave D: retained-core recovery and sparse behavior (9)

- rows 10, 11, 13 `ademp_scenario_registry`, `core_parameter_recovery`, and
  `monte_carlo_precision`;
- rows 14--18 `sparse_connected_behavior`,
  `minimum_rater_panel_and_person_overlap`, `weak_bridge_behavior`,
  `disconnected_negative_control`, and `category_support_behavior`; and
- row 30 `sparse_estimability_performance`.

This is the first wave in which broader simulation can be scientifically
necessary. Each execution must name the estimand, independent sampling unit,
failure denominator, precision target, and decision it can change. The old
G-theory n=100 rule is irrelevant here.

## Wave E: exact candidate and release reproduction (8)

- rows 1--4 `candidate_manifest`, `gate_specification_identity`,
  `data_partition_and_seed_identity`, and `external_input_identity`; and
- rows 77--80 `full_non_cran_regression`, `cran_workload_timing`,
  `exact_tarball_check`, and `release_decision_reproduction`.

Development runs in Waves A--D retain source/runtime/input hashes, but they are
not automatically candidate evidence. The exact candidate must replay every
affected retained result under one identity before release.

## Immediate action

The first bounded closure target is row 22
`readiness_contract_schema`, because it is deterministic, already described as
`complete_structural_v3` in the internal roadmap, and upstream of multiple
fit/comparison/output contracts. The required validator, legacy mapping,
negative mutation, and public/private vocabulary checks are recorded in
`readiness-contract-schema-closure-record-0.2.3.md`.

After row 22, do not jump directly to simulation. Audit row 23 propagation
against the frozen v3 schema and close any deterministic surface gaps first.
If row 23 still depends on unfinished WP1--WP3 states, split only by already
stable retained RSM/PCM slices and keep unresolved GPCM/interaction slices
review-only rather than inventing a new aggregate gate.

That first split is recorded in
`readiness-propagation-stable-slice-audit-0.2.3.md`. Native RSM/PCM JML/MML
fit-level readiness now has exact manifest/export/replay provenance and
deterministic positive, iteration-limit, and legacy-unknown coverage. The
replay fit recomputes readiness and compares it with the source record; it does
not inherit the source decision. Row 23 remains `review` because common
parameter/step/interaction propagation, lower-priority saved/export adapters,
and exact-candidate replay remain open. A fit serialized by the frozen 0.2.2
tarball now fails closed under current code, and a current-development
fresh-session replay independently recomputes `ready` while preserving the
source `legacy_unknown` record and warning on mismatch. Central
results/report/checklist/APA routes retain the exact record, including an
adversarial APA precision-override rejection. This is a sufficient stopping
boundary for the retained-core row-23 slice: the next release-spine work should
advance shared mathematical identities rather than extend adapter inventory or
start simulation.

The next shared identity, row 9 `exact_model_reductions`, is now structurally
closed in `exact-model-reduction-closure-record-0.2.3.md`. Binary RSM/PCM and
unit-slope GPCM/PCM reductions agree in log probability, full category
probability, marginal objective, common score, and free/expanded transforms.
A separately implemented likelihood/marginalization oracle and adversarial
numeric mutations prevent two internal branches or a stale success flag from
manufacturing equality. Rows 5--6 remain `review`, and row 8 remains the next
bounded policy/runtime contract; no broader score tolerance, confirmation, or
candidate result is promoted.

Row 8's deterministic policy/runtime slice is now complete in
`maxit-ceiling-stable-slice-audit-0.2.3.md`. A repository-only registry checks
declared ceiling-prefix order, invariant specification identity, v3 readiness,
and first-eligible-run selection; actual RSM/PCM JML/MML iteration-limit paths
remain blocked across central outputs. The checklist moves from `not_run` to
`review`, not `ok`, because its declared evidence role also requires the exact
candidate. Rows 5--6 are now the remaining upstream numerical contracts, but
their bounded v4 confirmation has now supplied a terminal negative result for
that sealed design. All frozen score and Jacobian comparisons passed, but two
fits were iteration-limited and blocked, and the runner's final aggregation
omitted the fit gate. The authoritative disposition is
`rejected_runner_false_positive_and_blocked_fits`; retry, rule adjustment, and
promotion are prohibited. Rows 5--6 remain `review`. Their next release action
is not another confirmation design: retain the review-only fallback and move
to Wave C matched RSM/PCM external microcases unless a new prospective
contract is later justified by a specific retained claim.

## Workspace and review boundary

The 2026-08-11 organization checkpoint found 58 tracked modifications, 325
untracked files, and no staged changes after generated check/object cleanup and
line-ending normalization. This is a development inventory, not a candidate
identity or an instruction to commit all files together. The exact candidate
must still be constructed later under Wave E.

The working tree is divided into five review units:

| Unit | Contents | 0.2.3 handling |
| --- | --- | --- |
| Core runtime and public surface | `R/`, `NAMESPACE`, generated help, central tests, README/vignette/NEWS changes, readiness and JML behavior | Review as one API/schema dependency chain; generated help and public wording must agree with runtime and tests. |
| GPCM evidence lineage | GPCM implementation, contracts, runners, records, tests, and retained result artifacts | Preserve calibration/confirmation identities and the negative v4 disposition; do not rename or rewrite sealed artifacts and do not infer promotion from numerical subchecks. |
| External comparison | TAM/immer and future ConQuest/FACETS inputs, normalizers, contracts, and records | Keep estimator modes and raw numeric precision separate; admit only matched microcases to Wave C. |
| G-theory research archive | Prototype algebra, engine adapters, weak-information infrastructure, tests, and records | Keep reproducible but outside the 0.2.3 public-claim and release-dependency graph; no large run is activated. |
| Release governance | Roadmaps, claim profile, checklist, fallback audit, and release-spine records | May describe or restrict claims but cannot by itself satisfy a numerical, external, recovery, or candidate gate. |

Repository paths embedded in sealed GPCM records and the corresponding
`validation-results/` artifacts remain fixed. The organization checkpoint
found no broken repository-relative validation/result reference. All 0.2.3
validation scripts without an exact-name test are referenced by covering tests
as validators, workers, or corrective runners. The two standalone 0.2.2
fixture generation/replay scripts are documented in `inst/validation/README.md`
and remain outside the ordinary package test path.

This boundary prevents the numerically dominant G-theory archive (185 of the
325 untracked files) and the GPCM evidence lineage (97 of 325) from obscuring
the much smaller active release spine. Review, staging, and eventual commits
should follow these units; no staging or commit is performed by this
checkpoint.

The first Wave C prerequisite is now implemented in
`conquest-numeric-resolution-contract-0.2.3.R`. It retains decoded native CSV
tokens and file SHA-256 before floating-point conversion. ConQuest manual
pp. 328--331 establish the export roles, while p. 394 establishes only that
screen `decimals` is ignored for file output; neither source establishes CSV
rounding or unlimited precision. The contract therefore defaults to
`raw_tokens_retained_rounding_unestablished` and keeps lexical equality,
numeric equality, resolution compatibility, tolerance passage, and scientific
equivalence separate. It opens no external execution and freezes no
`EXT-CQ-TOL`. The next bounded slice is to bind this audit to a no-fit additive
Person/Rater/Criterion RSM/PCM microcase design before any ConQuest run.

That no-fit additive design is now fixed in
`conquest-additive-mfrm-design-0.2.3.R`. One deterministic complete crossing
has 96 Persons, 2 Raters, 2 Criteria, 4 categories, 4 observations per Person,
and 384 total observations. RSM and Criterion-step PCM use byte-identical
inputs at q=31 and q=61, with independently counted free dimensions 7 and 9.
This replaces an over-wide 3-by-4 draft whose strict MML all-pattern audit
would require about 1.61 billion person-design/pattern evaluations; the reduced
case retains both facet constraints and uses a balanced two-level regression
covariate, reducing the exact-reuse audit to 512 pattern/design evaluations.
The generated commands request the native A matrix, but neither fit mfrmr nor
launch ConQuest. The validation decision is `no_go_design_only` because the
candidate, source-bound mfrmr reference, and native design matrix are absent.
The next slice is a no-external-execution mfrmr reference/oracle preflight; the
sparse/unequal-workload microcase remains downstream of this exact complete-
crossing reduction.

That source-bound preflight is now complete in
`conquest-additive-mfrm-reference-preflight-0.2.3.R`. All RSM/PCM q=31/q=61
fits converge, the independent probability/Gauss-Hermite marginal-likelihood
oracle agrees within `1.14e-13`, and the all-pattern local information ranks
are the expected 7/9 with nullity zero. The q31/q61 deviance differences are
about `2.3e-12`--`2.5e-12`, retained as observations without a post hoc
acceptance threshold. `InferenceReady = FALSE` remains visible because the
readiness policy does not promote local all-pattern diagnostics to structural
identification. Considered alone, its decision is
`no_go_native_matrix_and_candidate_missing`.

The apparent native-runtime block was a sandbox artifact. The user's Terminal
run and an unsandboxed control showed that the SHA-matched ConQuest 5.47.5
executable runs normally; the earlier `RegistryCheck` crash is retained only
as a restricted-environment observation. The obsolete ACER handoff is marked
withdrawn. The command grammar was also corrected from a comma-separated to a
space-separated implicit-facet declaration.

All four complete-crossing arms have now run. RSM q31/q61 ended at 96
iterations and PCM q31/q61 at 95; the exact native A matrices establish free
dimensions 7/9 and GIN ordering. For each model, q31/q61 final coordinates are
identical at the written CSV digits. Displayed native-minus-mfrmr coordinate
differences are at most `2.74e-6`, but the raw-token state remains
`raw_tokens_retained_rounding_unestablished`. The history column labelled
`LogLikelihood` contains positive deviance. The native review also exposed and
repaired a reference-export bug that had written PCM step estimates as missing.

The combined decision is
`four_arm_native_outputs_ready_tolerance_and_candidate_missing`. Thus Wave C is
no longer runtime-blocked, but it is still not comparison-ready: no independent
rounding/tolerance decision or release candidate is bound, and no scientific
equivalence is inferred.

The opened calibration has now undergone a separate five-layer adjudication
in `conquest-additive-tolerance-adjudication-0.2.3.R`. CSV representation,
optimizer termination, integration, scientific acceptance, and candidate
binding are not interchangeable. The official manual supplies no file-
rounding rule, and the former `export_tolerance=1e-6` was only an internal
history/export handoff threshold; it is now named `handoff_tolerance` and is
explicitly not `EXT-CQ-TOL`. The observed four-arm differences may inform a
prospective error budget for a disjoint candidate, but they cannot define a
new threshold and then pass this same calibration. The controlling
decision is `hold_no_post_hoc_tolerance_freeze`: keep the broad external claim
in the future portfolio, obtain an independently adjudicated pre-confirmation
`EXT-CQ-TOL` and `IC-INTEGRATION-TOL`, bind the exact candidate, and only then
repeat the small core. The connected sparse/unequal-workload microcase and
large simulation remain downstream.

The companion ConQuest/TAM/immer source audit found no official
cross-program tolerance to adopt. ConQuest, TAM, and immer expose within-fit
stopping and integration controls, but none turns those controls into a
scientific agreement rule. The prospective tolerance record must therefore
state its estimand-level decision rationale; copying `convergence`, `convD`,
`conv`, or a written CSV unit is prohibited.

In parallel, deterministic Wave A work may continue if it neither borrows
ConQuest evidence nor activates simulation. Row 71
`estimator_vocabulary` is now structurally closed in
`estimator-vocabulary-closure-record-0.2.3.md`. New and legacy `JMLE` inputs
resolve to `JML` across fit, summary, console, manifest, and replay surfaces;
public documentation retains `MML` and `JML` as the only canonical method
labels. Rows 72--76 remain open, and this wording closure does not establish
equal estimator maturity or external equivalence.

Wave C admission row 66 `external_privacy_and_license_boundary` is now
structurally closed by
`external-repository-boundary-audit-record-0.2.3.md`. The tracked-file audit
recomputes hashes for 93 external-related artifacts across ConQuest, FACETS,
TAM, and immer and found zero proprietary binaries, keys, identifier-bearing
case assets, real local paths, or escaping symlinks. This does not inspect
ignored result directories or establish numerical comparability. Rows 64
`metric_specific_comparison_eligibility` and 59 `facets_tool_identity` remain
the active Wave C admission dependencies; no external rerun is authorized.
