# 0.2.3 claim-disposition profile

Status: repository-only portfolio overlay, 2026-08-11. This profile reduces
the release programme to the evidence needed for retained 0.2.3 claims. It is
not a new statistical gate, does not change any evidence status, does not
promote a pilot, and authorizes no simulation, confirmation, external-program
execution, candidate freeze, or release.

## Bound source

| Artifact | SHA-256 |
| --- | --- |
| `release-evidence-checklist-0.2.3.csv` | `0dab2a0530fb725a7e715ca1fc48fedada2fcd88fc9a6e597b6665d9e15d8f55` |
| `claim-disposition-profile-0.2.3.csv` | `545409821e4674a45cc10e3f03483fdbfa87b4762ad5da4521efcafba0f66eff` |

The profile contains exactly one row for each of the checklist's 106 `Item`
values in the same order. `ChecklistRow` is an audit key, not a permanent
semantic identifier. A checklist addition, deletion, reorder, or item rename
requires a deliberate profile revision; it must not inherit a disposition by
position.

`mfrmr_release_readiness_review()` now verifies both recorded SHA-256 values,
the exact row/order/item mapping, the 53/32/21 class counts, class-specific
scope contracts, the nine conditional fallback codes, and allowed evidence
states. It derives the current scope decision from the checklist rather than
trusting the prose counts below. Profile integrity is a release-review gate;
the number of open spine rows is a current portfolio decision, not evidence
that the integrity audit itself failed.

## Disposition result

| Portfolio class | Rows | Effect when incomplete |
| --- | ---: | --- |
| `release_spine` | 53 | 0.2.3 release is NO-GO until the retained supported-core scope passes. |
| `claim_conditional` | 32 | Only the named claim is NO-GO; the recorded fail-closed fallback must be enforced on every affected public surface. |
| `deferred` | 21 | No 0.2.3 release effect; the work remains a later-version prototype, infrastructure record, or external research reference. |

The mapping reduces an undifferentiated 106-row programme to a 53-row release
spine. It does not assert that those 53 rows currently pass. The current
checklist snapshot contains 25 `not_run`, 24 `review`, and four `ok` spine
rows. The completed rows are the deterministic v3 readiness-contract schema,
exact-model reductions, estimator-vocabulary contract, and tracked-repository
external privacy/license boundary; they do not close runtime readiness
propagation, a general numerical tolerance, ecosystem positioning, external
tool identity, metric eligibility, or any external-equivalence claim. The 32 conditional rows
contain 10 `not_run`, 21 `review`, and one `ok`; that completed execution-
integrity row does not promote its parent GPCM claim.
Nine current `concern` rows are deferred G-theory infrastructure rows and no
longer count as 0.2.3 release concerns.

## Interpretation rules

1. `PortfolioClass` and `EvidenceStatus` are orthogonal. Disposition says what
   can block; status says what evidence currently exists.
2. A `release_spine` row applies only to `retained_supported_core_only`. If its
   original checklist scenarios also mention a conditional parameter class,
   that mention does not pull the conditional claim back into the spine.
3. A `claim_conditional` row applies only to `named_claim_only`. Incompleteness
   is acceptable only after the exact `FallbackCode` is implemented in fit,
   summary, print, plot, export, report, capability, and documentation surfaces
   that could otherwise expose the claim.
4. A `deferred` row is `excluded_from_0_2_3_release_scope`. Historical
   `blocker_if_failed` wording inside an execution-specific contract can still
   govern execution of that deferred study, but it cannot block a bounded
   0.2.3 release.
5. No favorable aggregate can replace a failing spine cell. Conversely, an
   unresolved deferred or disabled conditional row cannot be used to keep the
   whole release programme open indefinitely.

## Release spine

The 53 mandatory rows retain only the current public model and release
contract:

- exact candidate, seed/data partition, and external input identity;
- canonical numerical checks, exact reductions, optimizer ceiling, and
  matched-engine retained-solution evidence;
- ADEMP registry, retained-core recovery, Monte Carlo precision, connected,
  weak-link, two-Rater, category, extreme-score, disconnected, recession,
  readiness-propagation, and sparse-estimability behavior;
- formula/free-dimension/sample-size/migration/weight/JML-boundary and
  interpretation guards for information criteria, but not automatic ranking
  under unresolved external or integration bases;
- the unidimensional import guard;
- ConQuest binary/RSM/PCM MML core, FACETS identity and RSM/PCM JML core,
  metric-specific eligibility, and privacy/license boundaries;
- public vocabulary, ecosystem positioning, current/future scope, unsupported
  route guards, and the machine-readable support envelope;
- full non-CRAN, CRAN workload, exact tarball, and reproducible release
  engineering; and
- MML metamorphic invariance plus the current aligned single-owner GPCM model
  identity and generalized-family non-claim guard.

This makes the ConQuest relationship operationally important without claiming
ConQuest parity. The item-only binary/RSM/PCM rows remain necessary external
anchors. The additive complete-crossing Person/Rater/Criterion microcase is
now present as same-platform calibration, with all four RSM/PCM q31/q61 arms
complete and native A matrices exact. Its rounding/tolerance and candidate-
bound rerun are still open. The opened result has now been adjudicated without
freezing a self-passing post hoc tolerance: calibration may inform a future
candidate rule, but the current public statement is descriptive,
while the broad scientific-equivalence claim remains a future gate requiring
an independently justified pre-result `EXT-CQ-TOL`. The connected
sparse/unequal-workload microcase
should follow only after that core decision; neither case should become a new
general-parity gate.

## Conditional claims and exact fallbacks

| Fallback code | Rows | Public result while incomplete |
| --- | ---: | --- |
| `retain_jml_point_estimates_and_exploratory_observation_table_se_no_ordinary_uncertainty_adjustment_or_correction` | 1 | Keep estimator-labelled point output and explicitly exploratory observation-table SEs; do not present them as profile-likelihood uncertainty or claim an incidental-parameter adjustment/correction. |
| `suppress_gpcm_primary_slope_and_ordinary_uncertainty` | 12 | Keep the bounded-GPCM route explicitly non-primary for slope and ordinary slope uncertainty. |
| `disable_automatic_ic_ranking_retain_raw_components` | 2 | Retain labelled raw IC components; produce no automatic model-ranking conclusion. |
| `retain_unidimensional_scope_no_dimension_selection_or_subscores` | 10 | Keep one latent dimension; produce no automatic dimension decision or dimension-specific score claim. |
| `retain_diagnostic_as_exploratory_no_inferential_decision` | 2 | Bias/interaction and residual-PCA outputs remain exploratory screens. |
| `exclude_secondary_external_numeric_aggregation` | 2 | Keep TAM and TAM/immer results separate and descriptive; do not aggregate them into equivalence evidence. |
| `disable_rater_owned_gpcm_primary_route` | 1 | Do not promote the rater-owned slope/step route as a primary supported interpretation. |
| `retain_gpcm_fit_as_exploratory_no_decision` | 1 | GPCM fit output remains exploratory and cannot drive an automatic fit decision. |
| `disable_gpcm_dff_inferential_promotion` | 1 | Do not expose uniform/nonuniform GPCM DFF as a validated inferential decision. |

These are real fallbacks, not prose waivers. If a fallback cannot be made
unavoidable in the affected public surfaces, its row effectively returns to
the release spine.

## Deferred portfolio

The 21 deferred rows are intentionally heterogeneous but share one release
effect: none blocks 0.2.3.

- Three external research rows retain CML/CCML, hierarchical-rater/local-
  dependence, and optional FACETS fit/DFF work as references rather than
  native or equivalence claims.
- Four future-GPCM rows retain broader external GPCM, posterior prediction,
  FACETS-style score-side parity, and heavy backends as later research.
- Fourteen G-theory rows retain the typed algebra, univariate engine,
  uncertainty, multivariate prototype, current-surface guard, and b1g16--b1g24
  execution infrastructure outside the 0.2.3 release dependency graph.

In particular, `gtheory_one_shard_issuance` being `concern` does not request an
R0201 run. Its execution-specific controls remain valid if that study is later
reactivated, but the portfolio disposition stays deferred until a retained
claim and decision-specific precision argument justify the run.

## Ordered next work

1. Treat the completed
   `conditional-fallback-coverage-audit-0.2.3.md` as the controlling record for
   public fallback propagation; reopen it only when a relevant surface or
   fallback changes.
2. Work the 53-row spine by dependency and decision value rather than checklist
   order: deterministic numerical/readiness contracts, external-core
   microcases, retained-core recovery precision, then candidate and release
   engineering.
3. Independently adjudicate the ConQuest CSV resolution/tolerance boundary,
   then rerun the small additive RSM/PCM core on the bound candidate before
   adding one connected sparse/unequal-workload microcase.
4. Run a conditional simulation only if its fallback is unacceptable for the
   intended 0.2.3 claim and a written precision calculation shows how the
   result can change promotion.
5. Leave all deferred G-theory execution and large calibration inactive.

The deterministic public-fallback audit has replaced another stress family,
authorization artifact, or high-replication run and is now complete. The
active next task is the first unresolved high-leverage release-spine
dependency.
