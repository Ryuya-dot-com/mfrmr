# 0.2.3 claim-disposition profile

Status: repository-only historical portfolio snapshot, superseded for current
0.2.3 release sequencing by the 2026-08-16 distribution-first section of the
internal roadmap. This profile records how the earlier research programme was
partitioned. It is not a current release gate and does not itself promote evidence. The bound
checklist now records the separately audited candidate-003 ConQuest
Binary/RSM/PCM exact-reported-decimal passes; it still authorizes no broad
scientific-equivalence claim, simulation, sparse/GPCM extension, or release.

## Bound source

| Artifact | SHA-256 |
| --- | --- |
| `release-evidence-checklist-0.2.3.csv` | `baa8a883a5e278fc101c5febb9bf402a643e144671a016a885c7e706b475c175` |
| `claim-disposition-profile-0.2.3.csv` | `545409821e4674a45cc10e3f03483fdbfa87b4762ad5da4521efcafba0f66eff` |

The profile contains exactly one row for each of the checklist's 106 `Item`
values in the same order. `ChecklistRow` is an audit key, not a permanent
semantic identifier. A checklist addition, deletion, reorder, or item rename
requires a deliberate profile revision; it must not inherit a disposition by
position.

`mfrmr_release_readiness_review()` verifies both recorded SHA-256 values,
the exact row/order/item mapping, the 53/32/21 class counts, class-specific
scope contracts, the nine conditional fallback codes, and allowed evidence
states so that this historical snapshot cannot silently change. It reports
`CurrentReleaseGate=FALSE`. The SHA values protect only this repository record;
they are not installed-package dependencies, scientific criteria, or current
candidate requirements. The number of open rows is descriptive history, not a
0.2.3 release decision.

## Disposition result

| Historical portfolio class | Rows | Original effect; current interpretation |
| --- | ---: | --- |
| `release_spine` | 53 | Originally marked release-critical; now a historical research inventory with no direct release effect. |
| `claim_conditional` | 32 | The named claim remains unavailable unless its evidence closes; implemented fallbacks and narrowed claims control the public surface. |
| `deferred` | 21 | No 0.2.3 release effect; the work remains a later-version prototype, infrastructure record, or external research reference. |

The mapping reduced an undifferentiated 106-row programme to a 53-row historical
spine. It does not assert that those 53 rows currently pass or must pass for
the current bounded release. The current
checklist snapshot contains 25 `not_run`, 21 `review`, and seven `ok` spine
rows. In addition to the deterministic v3 readiness-contract schema,
exact-model reductions, estimator-vocabulary contract, and tracked-repository
external privacy/license boundary, the bounded ConQuest Binary/RSM/PCM
exact-reported-decimal core rows are now complete. They do not close runtime
readiness propagation, ecosystem positioning, external-tool identity across
TAM/immer/FACETS, general metric eligibility, hidden-solution equivalence, or
any broader scientific-equivalence claim. The 32 conditional rows
contain nine `not_run`, 22 `review`, and one `ok`. The new TAM MML calibration
moves only its conditional secondary-overlap row to `review`; its observed
differences freeze no tolerance or candidate and remain excluded from numeric
aggregation. The completed execution-integrity row likewise does not promote
its parent GPCM claim.
Nine current `concern` rows are deferred G-theory infrastructure rows and no
longer count as 0.2.3 release concerns. The remaining deferred rows now contain
six `not_run` and six `review`: the immer CML/CCML boundary moves one external-
reference row to `review` without changing the release decision.

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
5. No favorable aggregate can promote a claim whose required cell fails.
   Conversely, no open row in this superseded portfolio can keep the bounded
   release open merely because it once appeared in the historical spine.

## Historical release spine

The 53 rows below document the earlier programme. They are no longer a single
mandatory current-release contract:

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
unqualified ConQuest parity. Candidate 003 was bound after the candidate-002
semantic failure, then all six Binary/RSM/PCM q31/q61 arms completed in order
with 50 nonempty SHA-bound outputs and exact additive A matrices. All 19
cross-engine and 38 integration rows pass the independently frozen tolerance
table. The completed claim is deliberately narrower: agreement of exact CSV
decimals under the registered models, inputs, constraints, and executable.
The undocumented hidden optimizer interval, scientific equivalence,
inference readiness, DFF/fit/rank/ordering invariance, GPCM free slopes, and
sparse/unequal-workload extension remain open and cannot inherit this pass.
The subsequent TAM 4.3-25 RSM/PCM calibration makes its cases-constraint
location transform explicit and retains 46 finite q31/q61 coordinate rows,
but is not a second vote for equivalence: `EXT-TAM-TOL` and a disjoint TAM
candidate remain absent, and the conditional fallback continues to exclude
secondary external numeric aggregation.

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
  native or equivalence claims. The CML/CCML row now has a 22-row estimand
  boundary, but still has no fit, candidate, tolerance, or comparison pass.
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
3. Retain the completed candidate-003 ConQuest 50-output/54-coordinate/57-row
   evidence and the candidate-002 semantic-failure incident. Do not rerun or
   broaden it. Treat hidden-solution equivalence, inference readiness,
   DFF/fit/rank/ordering invariance, GPCM free slopes, and sparse allocation as
   distinct later claims; require a decision-value argument before extending
   this bounded complete-crossing core.
4. Run a conditional simulation only if its fallback is unacceptable for the
   intended 0.2.3 claim and a written precision calculation shows how the
   result can change promotion.
5. Leave all deferred G-theory execution and large calibration inactive.

The deterministic public-fallback audit has replaced another stress family,
authorization artifact, or high-replication run and is now complete. The
active next task is the first unresolved high-leverage release-spine
dependency.
