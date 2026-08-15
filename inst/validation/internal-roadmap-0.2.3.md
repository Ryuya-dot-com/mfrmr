# mfrmr internal development and validation roadmap

Status: repository-only maintainer plan, refined 2026-08-15.

The repository-root `ROADMAP.md` is the single source of truth for public
release direction. This file owns internal sequencing, candidate gates, local
tool identities, and validation operations. `NEWS.md` records completed
user-visible changes. Other files under `inst/validation/` provide
technical evidence or historical context and are subordinate to this roadmap.
The roadmap is repository-only and is excluded from source-package tarballs.

## 2026-08-15 ConQuest-first strategic reset

This section is the controlling overlay for future 0.2.3 sequencing. Where an
older draft sequence below conflicts with it, this section controls. Historical
candidate, execution, and calibration records remain immutable evidence; they
are not rewritten to make the current strategy appear older than it is.

### Strategic decision

Matched ConQuest comparison is the highest-priority external work for the
remaining 0.2.3 programme, subject to four limits:

1. ConQuest is an independent implementation, not ground truth.
2. External agreement cannot override structural nonidentification, boundary
   status, optimizer failure, or a failed internal oracle.
3. Binary/RSM/PCM MML, item-only free-score GPCM MML, and generalized-item
   multifacet GPCM are different comparison strata. Evidence cannot move
   between them by label similarity.
4. The comparison must answer a retained package or release decision. It must
   not expand merely because the executable is temporarily available.

The primary question is therefore not whether two files or parameter vectors
are identical. It is:

> After matching the statistical model, response support, identification,
> integration target, and reported coordinate map, do independent ConQuest and
> mfrmr implementations give compatible numerical and user-facing decisions
> over the declared support envelope, while all failures remain visible?

### Current evidence baseline

| Comparison stratum | Current state | What is established | What remains open |
| --- | --- | --- | --- |
| Binary/RSM/PCM complete-crossing MML | Candidate 003 closed at the exact-reported-decimal layer | All 19 cross-engine and 38 q31/q61 integration rows passed the prospectively frozen rules; additive A matrices were exact | Hidden-solution intervals, inference readiness, sparse allocation, endpoint behavior, fit/DFF/rank consequences, and general equivalence |
| Additive RSM/PCM MML with Person/Rater/Criterion | Narrow complete-crossing core closed | Population, Rater, Criterion, step, and deviance coordinates agree under the matched transform | Connected sparsity, weak links, unequal workload, missingness, and category stress |
| Item-only GPCM MML | Exact probability and coordinate map established; one native microcase remains review evidence | The free-population mfrmr identification maps one-to-one to ConQuest `scoresfree`; the prior fixed-standard-normal default was correctly demoted to legacy scope | A disjoint prospectively governed candidate, raw-token precision policy, integration ladder, and acceptance rule |
| Many-facet free-slope GPCM | Model-identity gate open | ConQuest generalized-item scores and mfrmr single-owner complete-predictor slopes are known not to coincide automatically | A proof of common probability/free-dimension identity; otherwise this lane remains a documented non-overlap |
| ConQuest JML free-score GPCM | Unsupported direct lane | The installed/manual contract does not support JML estimation of item scores | No numerical comparison is admissible unless the product contract changes |
| Decision-level invariance | Open | Parameter-level core agreement is encouraging | Person/Rater ordering, classifications, fit, DFF, information criteria, and reporting consequences require separate metrics and gates |

Candidate 003 is not rerun. Its run-once authorization was consumed and its
result is retained as a narrow historical confirmation. A successor may reuse
its lessons and frozen core tolerances only where the estimand and precision
contract are unchanged; it must use new data, a new execution identity, and a
new claim-specific design for every extension.

### Runtime and expiry risk

The current local install is explicitly supplied as
`/Applications/ConQuest/ConQuest`. A semantic no-fit probe on 2026-08-15
returned:

- self-reported version `5.47.5 Demonstration Version`;
- self-reported expiry `1 September 2026`;
- terminal marker `End of Program`; and
- process status zero under the x86_64/Rosetta launch route.

This creates an immediate continuity risk. Before the expiry date, the project
must preserve enough non-proprietary semantic fixtures to validate a future
replacement executable without making the expiring binary a runtime or release
dependency. The plan must not respond to the deadline by launching a broad,
under-specified simulation.

The successor runtime preflight must:

- accept the executable path as an explicit argument; no new workflow may
  require the `/Applications` path or one machine layout;
- record the program's own version and expiry text, architecture, invocation
  route, locale, run date, and exit status;
- require a terminal success marker and absence of registered semantic error
  messages;
- run a data-free `quit;` sentinel before any fit;
- keep process availability distinct from model-estimation success; and
- classify an expired, changed, unavailable, or sandbox-incompatible runtime
  without reclassifying prior scientific evidence.

Executable and artifact hashes may remain optional provenance and accidental-
replacement alarms. They are not scientific acceptance criteria. A matching
hash does not prove a matched model or a valid result; a changed hash does not
prove a changed estimand. Historical SHA-bound candidates remain sealed rather
than being retroactively edited.

### Evidence hierarchy

Future ConQuest work proceeds through six layers. A later layer cannot repair a
failed earlier layer.

| Layer | Question | Required evidence | Adversarial failure examples |
| --- | --- | --- | --- |
| C0 runtime semantics | Did the intended program execute normally? | Self-reported version, terminal marker, status, error-pattern review, required outputs | Status zero after command rejection; expired demo; Rosetta or settings-write failure |
| C1 model identity | Are the two programs fitting the same statistical object? | Category map, response family, model terms, A/C matrices, free dimension, constraints, population model, weights, missingness, step/slope ownership | Same label but different retained categories; generalized-item slope versus single-owner slope; different constants or anchors |
| C2 independent mathematics | Does each implementation satisfy the declared model independently? | Probability oracle, marginal-likelihood oracle, constraint residuals, reduction cases, gradient/stationarity checks | Shared normalizer bug; both programs close because the same incorrect transformation was reused |
| C3 numerical agreement | Are eligible coordinates/objectives compatible under a prospective rule? | Raw tokens, precision status, coordinate-wise differences, q sensitivity, complete denominators | Correlation hides an affine shift; rounding manufactures agreement; failed rows disappear |
| C4 decision consequences | Do remaining differences change supported conclusions? | Ordering, classification, information redistribution, fit/DFF status, readiness, reporting decisions | Small parameter differences reverse a weak-link ranking or threshold decision |
| C5 transport envelope | Does the result survive declared design adversity? | Disjoint deterministic controls and precision-planned replication over retained strata | Complete crossing passes while sparse bridges, rare categories, or workload imbalance fail |

### Canonical model signatures

Every comparison arm must have a human-readable semantic signature before any
result exists. The minimum fields are:

- response family and ordered category support;
- Person unit, response row, and observation weight semantics;
- active facets, level sets, signs, and reference/centering constraints;
- shared versus facet-specific step structure;
- slope owner, step owner, slope action, and latent dimension count;
- population regression formula, covariate coding, variance convention, and
  Person inclusion rule;
- integration method, nodes, bounds, and common evaluation target;
- free dimension and independently reconstructed design matrices;
- optimizer/stopping controls and accepted termination evidence;
- extreme-score and other boundary conventions; and
- exact set of parameters, predictions, and decisions eligible for comparison.

Semantic signatures are reviewed directly. A digest may detect an altered
manifest, but it cannot replace review of these fields.

### Priority comparison portfolio

#### P0: semantic runtime continuity before 2026-09-01

1. Implement a reusable, non-fitting runtime preflight with an explicit
   `conquest_exe` argument.
2. Preserve a small non-proprietary fixture set: command text, input schema,
   expected model dimensions, expected output schemas, and semantic success/
   failure transcripts. Do not commit licensed proprietary output merely to
   make replay convenient.
3. Add negative controls for an unknown command, missing data file, incomplete
   output set, and status-zero semantic failure.
4. Document the replacement-binary rule: a new ConQuest version reruns the
   no-fit sentinel and the smallest frozen numerical sentinel first. Broader
   evidence reopens only if that sentinel or a model contract changes.

P0 changes infrastructure only. It does not create a new equivalence claim.

#### P1: freeze the successor comparison specification

Create one machine-readable registry that separates:

- complete-crossing Binary/RSM/PCM core;
- connected sparse and unequal-workload additive RSM/PCM;
- category-support and extreme-score controls;
- item-only GPCM MML; and
- known non-overlap/unsupported lanes.

For every row, predeclare the eligible estimand, expected coordinates, failure
denominator, integration ladder, numerical unit, acceptance status, and claim
that could change. A row with no decision consequence is removed before
execution.

The specification must include deliberately failing controls. A runner that
cannot reject a category-map mismatch, free-dimension mismatch, disconnected
design, unsupported JML free-score request, or missing output is not ready to
evaluate agreement.

#### P2: additive RSM/PCM adversarial deterministic envelope

The next scientific comparison extends the closed benign core with small,
truth-known, exactly reconstructable fixtures in this order:

1. connected sparse assignment with more than one independent bridge;
2. weak single-bridge assignment retained as a sensitivity case;
3. unequal Rater workload with the same estimand and category support;
4. planned missing rows versus explicit missing values;
5. rare boundary categories and an unused intermediate-category negative
   control;
6. nonextreme versus extreme Person strata; and
7. disconnected structural rejection.

Each design is first deterministic and small enough for an independent
probability and marginal-likelihood reconstruction. Only comparison-eligible
fits from both programs enter coordinate differences. Nonconvergence,
nonidentification, unsupported category support, and boundary mismatch remain
separate observed outcomes in the full denominator.

The principal metrics are not one global correlation. They are:

- maximum and signed coordinate differences by parameter class;
- marginal deviance on a matched constant basis;
- q-to-q integration movement within each program;
- fitted-category probability differences on prespecified rows/cells;
- Person EAP and posterior-SD differences only where posterior definitions
  match;
- Rater/Criterion ordering and practically tied-pair status;
- readiness and failure-state agreement without allowing external agreement
  to promote mfrmr readiness; and
- changes in any retained model-choice or reporting decision.

#### P3: item-only GPCM candidate

The item-only `scoresfree` overlap receives a disjoint candidate only after P0
and P1 pass. It must include:

- at least one unit-slope PCM reduction and multiple non-unit slope controls;
- both intercept-only and one prespecified latent-regression covariate design;
- common item/category support with every transition observed;
- an integration ladder that distinguishes finite-grid drift from optimizer
  discrepancy;
- independent probability and continuous-target likelihood reconstruction;
- relative-slope, population-scale, transition-threshold, deviance, and fitted-
  probability coordinates;
- raw exported tokens and an explicit `reported-resolution-limited` state;
- a prospectively frozen candidate rule that does not reuse the opened native
  microcase as its own confirmation; and
- a permanent exclusion of many-facet owner claims unless C1 proves the exact
  generalized-item mapping.

TAM item-only GPCM remains a useful third implementation, but it is not a vote.
ConQuest--mfrmr, TAM--mfrmr, and ConQuest--TAM differences stay separate, and
none can override a failed independent oracle or missing covariance needed for
SE transformation.

#### P4: precision-planned replicated confirmation

Replication begins only for P2/P3 cells whose deterministic results leave a
retained decision uncertain. Before data generation, record:

1. the independent sampling unit;
2. the target failure or disagreement rate;
3. the confidence/MCSE precision required to change the decision;
4. sequential stop, expand, and abort rules;
5. handling of failed/ineligible fits; and
6. the maximum claim permitted by a pass.

Do not choose a universal replication count. Bias, RMSE, coverage, ordering,
convergence, and rare failure rates require different precision calculations.
No result may be dropped because one program failed to return a comparable
estimate.

#### P5: release and maintenance handoff

The final handoff must state, separately:

- the exact matched overlap that passed;
- the versions and platforms actually observed;
- the designs and parameter classes covered;
- all ineligible, failed, and negative-control outcomes;
- which public decisions are supported, caveated, disabled, or deferred;
- the smallest sentinel that must rerun after likelihood, constraint,
  category, integration, parser, or ConQuest-version changes; and
- why ConQuest remains optional and absent from normal package runtime and CRAN
  checks.

### Adversarial review matrix

Before a comparison is accepted, reviewers must answer each question with
evidence rather than assurance.

| Threat | Required challenge | Acceptance boundary |
| --- | --- | --- |
| External program treated as truth | Independent analytic/reduction oracle | Agreement is evidence only after both implementations pass independently |
| Same name, different model | Reconstruct probability, free dimension, A/C matrices, constraints | Any unresolved mismatch makes numeric comparison ineligible |
| Correlation hides bias | Report affine slope/intercept and coordinate maxima without deviance dominating scale | Correlation is descriptive and never a pass rule |
| Rounding manufactures closeness | Retain raw tokens and reported precision; compare at declared resolution | No hidden digits or undocumented rounding interval are inferred |
| Integration errors cancel | Within-engine q ladder plus common-target re-evaluation | Cross-engine closeness cannot pass if within-engine movement is unresolved |
| Easy fixture bias | Sparse, weak-link, workload, category, extreme, and disconnected controls | Complete crossing alone supports only the complete-crossing claim |
| Failed rows disappear | Fixed complete denominator and typed failure states | Conditional agreement is reported separately from full-envelope success |
| Optimizer code zero is trusted | Terminal state, history/export consistency, independent objective/stationarity checks | Status zero alone is insufficient |
| Boundary conventions are mixed | Separate finite, unbounded, adjusted-display, and posterior estimands | Only like-with-like numerical comparisons are eligible |
| Shared transformation bug | Independently implemented probability and likelihood oracle | The production mapper cannot be its own sole validator |
| Hashes substitute for science | Mutate semantically important fields while preserving irrelevant bytes and vice versa | Semantic changes control invalidation; hashes are provenance only |
| Version expiry creates urgency bias | Freeze decisions before execution and cap scope | Deadline cannot authorize an under-specified run |
| Platform specificity is hidden | Record architecture/Rosetta/locale and use smallest cross-version sentinel | One macOS binary does not establish cross-platform behavior |
| Parameter agreement lacks user value | Evaluate ordering, probabilities, uncertainty eligibility, readiness, and reporting decisions | No broad user claim follows from coordinate agreement alone |

### Failure taxonomy and response

Every failure receives exactly one primary class, with secondary evidence
retained:

| Failure class | Response |
| --- | --- |
| `runtime_unavailable_or_expired` | Hold external execution; retain prior evidence and run no fallback model under the same label |
| `semantic_execution_failure` | Reject the arm even if process status is zero |
| `model_identity_mismatch` | Stop numerical comparison; either correct the specification prospectively or record a non-overlap |
| `structurally_unidentified` | Fail before optimization; do not use external finiteness as identification evidence |
| `external_nonconvergence` | Retain the row in the denominator and withhold coordinate comparison |
| `mfrmr_optimizer_or_readiness_review` | Retain external results descriptively; do not let agreement promote readiness |
| `boundary_convention_mismatch` | Compare typed statuses or matched display conventions, not raw finite numbers |
| `reported_resolution_limited` | Report the visible resolution and withhold sub-resolution claims |
| `integration_unresolved` | Extend or reformulate the integration comparison before interpreting solver differences |
| `numerical_disagreement` | Reconstruct objectives and transformations independently before assigning an implementation defect |
| `implementation_defect` | Correct code, add a reduction/regression test, invalidate only affected evidence, and rerun the smallest sufficient sentinel |
| `unknown` | Fail closed and narrow the claim; do not pool with passed rows |

### Promotion, stop, and invalidation rules

A comparison claim may advance only when:

- C0--C3 all pass for every required row;
- all expected rows are present, including negative and failed controls;
- the rule was frozen before candidate output was opened;
- no internal oracle, structural, boundary, or readiness gate failed;
- the claimed design envelope is no broader than the tested envelope; and
- user-facing consequences have been evaluated when the claim mentions
  interchangeability, ranking, scoring, fit, or reporting.

Stop or narrow immediately when:

- the exact model map is not provable;
- a negative control becomes numerically eligible;
- the runtime version/expiry cannot be established semantically;
- output precision is inadequate for the proposed tolerance;
- convergence or integration movement exceeds the prospective contract;
- a rule must be changed after candidate results are visible; or
- additional replication cannot change the retained decision.

Evidence invalidation is dependency-based rather than file-based. A wording,
plot, or export-layout change does not reopen numerical ConQuest evidence when
the fitted object and semantic scale contract are unchanged. A change to the
likelihood, category retention, constraint map, population model, integration,
retained-solution rule, external parser, or coordinate transform reruns the
smallest affected sentinel before any broader study.

### Canonical execution checklist

This is the only mutable progress surface for the ConQuest-first programme.
The preceding sections define scope and acceptance logic; historical candidate
records retain their original state. Use `[x]` only when the named evidence is
present in the repository and reviewable. A started, blocked, skipped, or
externally successful task remains `[ ]`. Each completion update must add the
evidence path and date in parentheses; it must not silently weaken the item.

If an acceptance rule changes after candidate output is visible, leave the old
item and record intact, add a new prospective item/candidate, and explain the
dependency invalidation. Do not turn a failed check into a pass by changing its
wording.

#### Locked foundations

- [x] Make matched ConQuest comparison the highest-priority external lane while
  retaining internal identification, oracle, boundary, and readiness vetoes
  (`internal-roadmap-0.2.3.md`, 2026-08-15).
- [x] Separate additive Binary/RSM/PCM, item-only GPCM, many-facet free-slope
  GPCM, and unsupported JML free-score strata (current evidence baseline,
  `internal-roadmap-0.2.3.md`, 2026-08-15).
- [x] Seal Candidate 003 as consumed historical evidence; do not rerun it or
  enlarge its claim retrospectively
  (`conquest-six-arm-candidate-003-execution-result-record-0.2.3.md` and
  `conquest-six-arm-candidate-003-numerical-review-record-0.2.3.md`,
  2026-08-12).
- [x] Treat executable/artifact hashes as optional provenance alarms rather
  than scientific acceptance criteria (`internal-roadmap-0.2.3.md`,
  2026-08-15).
- [x] Record the installed runtime's semantic identity: ConQuest 5.47.5
  Demonstration Version, expiry 2026-09-01, x86_64/Rosetta route, terminal
  marker, and status zero (Runtime and expiry risk section of
  `internal-roadmap-0.2.3.md`, 2026-08-15).
- [x] Keep FACETS outside the executable validation path in this environment;
  its retained comparison evidence and non-execution contracts must not imply
  a new local FACETS run
  (`facets-multifacet-confirmation-design-record-0.2.3.md` and
  `test-facets-multifacet-precision-contract.R`, 2026-08-15).

#### Review sequencing and irreversible-information priority

- [x] Split the monolithic independent-review gate into a minimum
  pre-execution fatal-gate audit and an independent post-output evidence review;
  permit a declared same-author maintainer audit only for the sealed diagnostic,
  never for evidence promotion, widening, P3, or public claims
  (`conquest-minimum-diagnostic-authorization-record-0.2.3.md`, 2026-08-15).
- [x] Freeze the smallest meaningful external P2 diagnostic slice as the paired
  connected-multibridge RSM/PCM rows on identical data, q=`31;61`, with exactly
  four ConQuest and four mfrmr fits
  (`conquest-minimum-diagnostic-authorization-0.2.3.R`, 2026-08-15).
- [x] Freeze fifteen non-waivable fatal gates covering current runtime semantics,
  expiry, explicit path, P1/P2 construction, exact scope, empty output boundary,
  ordinary-test independence, clean tree, execution cap, auditor identity,
  author-overlap disclosure, no-claim acceptance, and checklist completion
  (`conquest-minimum-diagnostic-authorization-0.2.3.R`, 2026-08-15).
- [x] Bind a current data-free runtime sentinel and completed minimum audit to a
  separate authorization record; do not launch a model from the construction
  contract itself
  (`conquest-minimum-diagnostic-live-authorization-record-0.2.3.md`,
  2026-08-15).
- [x] Implement and dry-test a fail-closed harness that consumes only the live
  authorization, requires a new empty output directory, uses unique prefixes,
  and retains every expected output or failure without fitting during tests
  (`conquest-minimum-diagnostic-harness-0.2.3.R`, 2026-08-15).
- [x] Launch exactly the authorized two-row P2 diagnostic candidate before the
  live authorization expires. The run-once harness retained four
  expected-dimension mfrmr fits, then stopped after the ConQuest RSM/q31 arm
  aborted at a negative latent-variance estimate; the other three ConQuest
  arms were not launched
  (`conquest-minimum-diagnostic-execution-observation-record-0.2.3.md`,
  2026-08-15).
- [x] Classify the retained outcome as a fixture population-signal defect, not
  a cross-engine result: Rater/category and Criterion/category margins are
  exactly balanced and the X groups have identical mean Person total scores.
- [x] Supersede the deterministic response generator with a prospectively
  frozen nondegenerate-signal fixture while preserving graph connectivity,
  category support, dimensions, common data, and the existing metric/stop
  contracts. Require nonzero covariate score separation, non-collapsed Person
  signal, and nontrivial facet sufficient statistics before authorization.
- [x] Freeze one no-search PCM-generating replacement seed and thirteen pre-fit
  gates. Retain its 12/13 result and reject candidate 002 because one
  Rater-by-Criterion-by-category cell is empty; do not search seeds or fit a
  model (`conquest-p2-replacement-nondegenerate-fixture-record-0.2.3.md`,
  2026-08-15).
- [x] Give candidate 003 a prospectively defined support-guaranteeing response
  design rather than seed selection. It must retain probability weighting and
  pass the same population/facet-signal, graph, shape, and full-cell support
  gates before any mfrmr fit preflight. The frozen realization passes 13/13;
  because full-support conditioning changes the joint sampling law, it is not
  parameter-recovery or calibration evidence
  (`conquest-p2-candidate-003-coverage-conditioned-fixture-record-0.2.3.md`,
  2026-08-15).
- [x] Run a separate mfrmr-only candidate-003 preflight at q=31/61 for RSM and
  PCM. Retain expected/free dimensions, convergence/readiness states,
  population-variance behavior, integration movement, and every failure. A
  failed or boundary-collapsed fit blocks external execution rather than
  triggering fixture repair or seed search. All four fit-level gates passed,
  but both q31--q61 pairs exceeded the frozen `2e-6` coordinate and deviance
  limits, so the preflight is consumed and external execution is blocked
  (`conquest-p2-candidate-003-mfrmr-preflight-observation-record-0.2.3.md`,
  2026-08-15).
- [x] Close candidate 003 before external binding: do not create its ConQuest
  output root, refresh its runtime sentinel, change its threshold, rerun its
  mfrmr preflight, or search a replacement seed. Retain the four
  `design_rank_not_evaluated` holds without relabelling them inference-ready
  (`conquest-p2-candidate-003-mfrmr-preflight-observation-record-0.2.3.md`,
  2026-08-15).
- [x] Freeze and test a first successor integration ladder before generating
  candidate 004.
  Separate the diagnostic starting grid from the governing dense-grid pair,
  justify the choice from integration theory and pre-candidate evidence, retain
  a complete coordinate/deviance denominator, and do not tune the `2e-6` budget
  from candidate-003 output. The `31;61;121` contract is now frozen with
  q31--q61 diagnostic, q61--q121 governing at the unchanged P2 budget, and a
  q121--continuous gate. Its thirteen-fixture no-fit audit was consumed and
  rejected the fixed q121 ceiling because both unequal-workload rows failed
  q61--q121 and q121--continuous limits; thresholds remain unchanged
  (`conquest-p2-successor-integration-observation-record-0.2.3.md`, 2026-08-15).
- [x] Freeze and test a bounded design-adaptive density ladder before candidate
  004.
  Require q31--q61 as a complete-denominator diagnostic, search only the
  predeclared adjacent dense pairs up to a fixed node cap, select the lowest
  pair that passes unchanged coordinate/deviance budgets for every numerical
  arm, and require its higher node to pass a continuous-target gate. If no pair
  passes, stop rather than extend or relax the rule. The finite
  `31;61;121;241` contract and q241 hard ceiling are frozen; its thirteen-row
  truth-oracle audit reached the ceiling: all 13 q121--q241 movements pass, but
  the two unequal-workload q241--legacy-continuous comparisons still fail.
  Further nodes and threshold changes remain unauthorized
  (`conquest-p2-adaptive-density-observation-record-0.2.3.md`, 2026-08-15).
- [x] Qualify a log-centered continuous P2 oracle before candidate 004. Freeze
  its mode-location, scaling, tail, integration-error, and agreement rules
  before evaluation; compare it with q121, q241, and the legacy adaptive
  integral over all thirteen truth fixtures. A qualified replacement may
  govern future candidates but cannot reclassify consumed contracts. The
  `[-12,12]` mode-centered split-integral contract, explicit numerical/tail
  error bound, q121/q241 agreement gates, and hard tolerances were frozen
  before evaluation. All 13 rows pass; maximum q121 and q241 deviance
  movements are `1.01e-10` and `2.27e-12`, while only the legacy reference
  retains the two unequal-workload discrepancies. The new oracle governs
  future P2 candidates without reclassifying consumed contracts. Its reported
  numerical error is not an interval-arithmetic certificate, and this is not
  independent cross-software validation
  (`conquest-p2-log-centered-continuous-oracle-observation-record-0.2.3.md`,
  2026-08-15).
- [x] Generate one disjoint candidate-004 fixture under the now-qualified
  integration reference. Use a new candidate identity and seed, the same
  thirteen pre-fit gates, probability-weighted support conditioning, and a
  separate lineage gate. The seed-`2026081504` realization passes 13/13 and is
  distinct from candidate 003; all twelve cells accepted their first complete
  block, which does not remove the conditioning rule
  (`conquest-p2-candidate-004-fixture-observation-record-0.2.3.md`,
  2026-08-15).
- [x] Freeze and run a candidate-004 mfrmr-only preflight. Predeclare expected
  dimensions, convergence/readiness and variance gates, the diagnostic q31
  layer, the bounded q61/q121/q241 whole-slice selection rule, and the
  log-centered continuous target before fitting. A failure consumes candidate
  004 without changing nodes, thresholds, seed, or data. The candidate-004
  mfrmr preflight contract is frozen: six initial q31/q61/q121 fits, two q241
  fits only after a complete dense-pair-1 failure, unchanged `2e-6`/`1e-7`
  movement gates, fitted-coordinate continuous reevaluation, and a q241 hard
  ceiling. The initial six-fit phase passed at q61--q121, so q241 was not run.
  q31--q61 remains visibly above `2e-6`; all six fits retain non-inference-ready
  design-rank holds. No external execution follows automatically
  (`conquest-p2-candidate-004-mfrmr-preflight-observation-record-0.2.3.md`,
  2026-08-15).
- [x] Bind and execute fit-eligible candidate 004 in a new empty external output root, a
  fresh data-free runtime sentinel, a new minimum audit, and a run-once
  ConQuest authorization. None is implied by fixture or internal-fit success.
  The fresh sentinel passes and the candidate-004 four-arm q61/q121 live
  authorization is frozen through 2026-08-16 with all fifteen fatal gates
  passing. The candidate-004 run-once harness is frozen with both families at
  q61/q121, thirty-two required native outputs, exact unopened-boundary
  validation, and a semantic failure stop. All four authorized arms were run
  once: each returned status zero, reached the terminal marker, raised no
  registered semantic error, and produced 8/8 native outputs. This completes
  only the execution denominator, not numerical agreement
  (`conquest-p2-candidate-004-execution-observation-record-0.2.3.md`,
  2026-08-15).
- [x] Apply the already-frozen exact-reported-decimal, integration-movement,
  probability, constraint, and ordering rules to all four candidate-004 arms.
  Retain any reported-resolution limit or failed coordinate without rerunning
  the candidate, changing a threshold, or dropping an atomic row. The
  candidate-004 numerical-review contract is now frozen before its full metric
  computation: it retains both q61 and q121 cross-engine rows, reconstructs all
  sum-zero coordinates, requires four semantic A matrices, types EAP/SD as
  ineligible, and separates this two-row numerical core from the wider P2
  design portfolio
  (`conquest-p2-candidate-004-numerical-review-contract-record-0.2.3.md`,
  2026-08-15). The same-author technical review then passed every complete
  denominator: 4/4 A matrices, 52/52 raw tokens, 64/64 cross-engine
  coordinates, 4/4 cross-engine deviances, 64/64 q movements, 4/4 q-deviance
  movements, 480/480 conditional probabilities, and 18/18 ordering rows.
  EAP/SD remain typed-ineligible and all mfrmr fits retain the
  `design_rank_not_evaluated` hold
  (`conquest-p2-candidate-004-numerical-observation-record-0.2.3.md`,
  2026-08-15).
- [x] Challenge the candidate-004 reviewer with semantic positive and negative
  controls before independent review. Semantic A-matrix row reordering and
  numeric storage-mode changes pass, while coefficient, response, parameter-
  label, iteration-sequence, and denominator mutations fail closed. These
  controls do not use byte identity and do not reopen external execution
  (`conquest-p2-candidate-004-reviewer-adversarial-controls-record-0.2.3.md`,
  2026-08-15).
- [x] Disaggregate candidate 004's internal design-rank hold without refitting
  or using ConQuest agreement as a substitute. Audit the additive constrained
  design, nonlinear variance map, observed-pattern score span, retained
  information, fixed-quadrature local state, and global/continuous MML state
  separately. The candidate-004 rank-hold contract is frozen and explicitly
  forbids local full rank from clearing the global hold. The saved-fit review
  passes every local layer: additive ranks are 9/9 for RSM and 13/13 for PCM,
  observed-pattern score ranks are 10/10 and 14/14, and all four fixed-q local
  states are full-rank sufficient. Global marginal and continuous-integral
  identification and weak-information classification remain open, so all four
  fit-level readiness states remain `review/not_evaluated`
  (`conquest-p2-candidate-004-rank-hold-contract-record-0.2.3.md`,
  `conquest-p2-candidate-004-rank-hold-observation-record-0.2.3.md`,
  2026-08-15).
- [x] Choose the next gate by claim, not by ritual. For promotion of only the
  bounded exact-reported-decimal ConQuest comparison, request independent
  review while retaining the non-inference-ready caveat. For an inference-
  ready or general-identification claim, first freeze and satisfy a global and
  continuous-integral MML identification argument. Neither path may borrow the
  other path's evidence. The bounded path is selected and its review handoff is
  frozen with reviewer non-overlap, raw-artifact primacy, fifteen mandatory
  tasks, complete denominators, explicit nonclaims, and no-rerun rules. No
  reviewer is assigned and no review result is implied
  (`conquest-p2-candidate-004-independent-review-handoff-record-0.2.3.md`,
  2026-08-15).
- [x] Reassess the independent post-output review by expected information gain.
  Candidate 004 now remains retained without an active promotion target, and
  its dormant review handoff is not reported complete or cancelled. It no
  longer blocks a distinct truth-known adversarial simulation, P2 design work,
  or later P3 consideration. External review remains an optional design
  challenge or final-evidence audit, not a substitute for an independent
  mathematical oracle
  (`conquest-adversarial-simulation-program-record-0.2.3.md`, 2026-08-15).

#### P0 -- semantic runtime continuity

- [x] Implement one reusable non-fitting preflight that receives
  `conquest_exe` explicitly and has no machine-specific default that can create
  scientific evidence accidentally
  (`conquest-semantic-runtime-preflight-0.2.3.R`, 2026-08-15).
- [x] Make the preflight send only the data-free `quit;` sentinel before any
  model-fitting command is eligible
  (`conquest-semantic-runtime-preflight-0.2.3.R` and its test, 2026-08-15).
- [x] Capture the program's own version/edition/expiry text, executable
  architecture, invocation route, locale, run date, exit status, and terminal
  success marker as typed fields
  (`conquest-semantic-runtime-preflight-record-0.2.3.md`, 2026-08-15).
- [x] Maintain a semantic-error registry and fail when a registered error occurs
  even if the process exits with status zero
  (`conquest-semantic-runtime-preflight-0.2.3.R` and its test, 2026-08-15).
- [x] Add deterministic controls for an unavailable executable, an unknown
  command, a missing data file, an incomplete output set, a missing terminal
  marker, and a status-zero semantic failure
  (`test-conquest-semantic-runtime-preflight.R`, 2026-08-15).
- [x] Prove through tests that runtime availability and model-estimation success
  are distinct states and that neither can rewrite earlier evidence
  (`test-conquest-semantic-runtime-preflight.R`, 2026-08-15).
- [x] Preserve only non-proprietary command/input/output-schema fixtures and
  success/failure transcripts needed to test a replacement executable
  (`conquest-semantic-runtime-preflight-0.2.3.R` and its record, 2026-08-15).
- [x] Document and test the replacement rule: a changed ConQuest runtime must
  pass the no-fit sentinel and the smallest frozen numerical sentinel before
  broader external evidence is reopened
  (`conquest-semantic-runtime-preflight-0.2.3.R`, its test, and its record,
  2026-08-15).
- [x] Run the reusable preflight once against the explicit current path and
  retain its semantic record before 2026-09-01
  (`conquest-semantic-runtime-preflight-record-0.2.3.md`, 2026-08-15).
- [ ] Close P0 only after executable evidence confirms that all C0 failure
  controls fail closed and ordinary package tests do not require ConQuest.
  Reviewer identity is not a closure criterion; a later external audit may
  challenge the retained evidence. P0 closure blocks interpretation and
  widening, but not prospective design work or the first sealed diagnostic
  after every minimum fatal gate passes.

#### P1 -- prospective semantic registry

- [x] Create a single machine-readable registry covering the retained P2/P3
  rows and the known non-overlap/unsupported rows
  (`conquest-successor-semantic-registry-0.2.3.R`, 2026-08-15).
- [x] Give every row a human-readable canonical model signature with all fields
  listed under `Canonical model signatures`
  (`conquest-successor-semantic-registry-0.2.3.R` and its test, 2026-08-15).
- [x] Reconstruct and record prospective category maps, free dimensions,
  constraints, and population/integration targets independently of exported
  parameter labels (`conquest-successor-semantic-registry-record-0.2.3.md`,
  2026-08-15).
- [x] Bind the disjoint P2 additive fixtures and independently reconstruct their
  exact observed A/C coefficient maps and free dimensions before numerical
  eligibility (`conquest-p2-additive-adversarial-fixtures-record-0.2.3.md`,
  2026-08-15).
- [x] Bind the disjoint P3 item-only fixtures and independently reconstruct
  their exact observed-support A/C coefficient maps and free dimensions
  (`conquest-p3-item-only-adversarial-fixtures-record-0.2.3.md`, 2026-08-15).
- [x] Assign each row exactly one comparison stratum; forbid evidence transfer
  across strata by shared names such as GPCM or slope
  (`conquest-successor-semantic-registry-0.2.3.R`, 2026-08-15).
- [x] Predeclare eligible estimands, coordinate transforms, numerical units,
  raw-token precision states, q ladders, and boundary conventions by row
  (`conquest-successor-semantic-registry-0.2.3.R`, 2026-08-15).
- [x] Predeclare the complete denominator and typed outcome for every expected
  row, including external failure, mfrmr readiness review, structural rejection,
  and deliberately ineligible controls
  (`conquest-successor-semantic-registry-record-0.2.3.md`, 2026-08-15).
- [x] Attach one retained package/release decision to every passing row and
  remove rows that cannot change a decision
  (`conquest-successor-semantic-registry-0.2.3.R`, 2026-08-15).
- [x] Include negative controls for category-map mismatch, free-dimension
  mismatch, disconnected design, unsupported JML free-score requests, missing
  outputs, and semantic status-zero failure
  (`test-conquest-successor-semantic-registry.R`, 2026-08-15).
- [x] Freeze metric-specific acceptance, stop, expansion, and invalidation
  rules before any successor candidate output is opened
  (`conquest-p2-metric-boundary-contract-record-0.2.3.md` and
  `conquest-p3-metric-precision-contract-record-0.2.3.md`, 2026-08-15).
- [ ] Close P1 only after executable contract checks confirm C1 eligibility,
  complete denominators, negative-control rejection, and claim boundaries.
  Reviewer identity is optional and cannot replace those checks. P1 closure
  remains mandatory for interpretation and widening, not for prospective
  design work or the first non-interpretive sealed diagnostic.

#### P2 -- additive RSM/PCM adversarial envelope

- [x] Build a small deterministic connected-sparse fixture with more than one
  independent bridge and a truth-known, exactly reconstructable design
  (`conquest-p2-additive-adversarial-fixtures-0.2.3.R`, 2026-08-15).
- [x] Add a weak single-bridge sensitivity fixture without treating it as the
  sole evidence for connected sparsity
  (`conquest-p2-additive-adversarial-fixtures-0.2.3.R`, 2026-08-15).
- [x] Add an unequal-Rater-workload fixture while holding the estimand and
  ordered category support fixed
  (`conquest-p2-additive-adversarial-fixtures-0.2.3.R`, 2026-08-15).
- [x] Add paired planned-missing-row and explicit-missing-value fixtures with a
  prospectively stated equality expectation for their retained response rows
  and continuous target
  (`conquest-p2-additive-adversarial-fixtures-record-0.2.3.md`, 2026-08-15).
- [x] Add rare boundary-category cases and an unused intermediate-category
  negative control (`conquest-p2-additive-adversarial-fixtures-record-0.2.3.md`,
  2026-08-15).
- [x] Add separate nonextreme/extreme Person fixtures
  (`conquest-p2-additive-adversarial-fixtures-0.2.3.R`, 2026-08-15).
- [x] Type every finite, unbounded, adjusted-display, and posterior quantity
  before an extreme-Person numerical comparison
  (`conquest-p2-metric-boundary-contract-record-0.2.3.md`, 2026-08-15).
- [x] Add a disconnected-design negative control that must stop before numeric
  agreement is evaluated
  (`test-conquest-p2-additive-adversarial-fixtures.R`, 2026-08-15).
- [x] Implement independent probability and continuous-target marginal-
  likelihood oracles for every deterministic P2 fixture
  (`conquest-p2-additive-adversarial-fixtures-0.2.3.R` and its test,
  2026-08-15).
- [x] Freeze parameter-class coordinate metrics, matched-constant deviance,
  within-engine q movement, fitted probabilities, eligible EAP/posterior SD,
  ordering/ties, readiness states, and decision consequences
  (`conquest-p2-metric-boundary-contract-0.2.3.R` and its record, 2026-08-15).
- [ ] Review P2 fixtures, identities, oracles, raw-token policy, complete
  denominator, and expiry-aware execution cap comprehensively after the first
  slice is classified and before evidence promotion or widening.
- [ ] Authorize and run only the smallest frozen external P2 slice after the
  current runtime and minimum fatal-gate audit are bound; machine-verifiable
  P0/P1 closure remains required before interpreting or expanding the result.
- [ ] Diagnose every outcome under the failure taxonomy before authorizing a
  wider deterministic slice or any replication.
- [ ] Close P2 only when C0--C5 pass for the exact claimed additive envelope, or
  record a narrower/failed conclusion without dropping ineligible rows.

#### P3 -- disjoint item-only GPCM candidate

- [x] Retain the existing exact probability/coordinate map between mfrmr's
  free-population identification and ConQuest `scoresfree` as prerequisite
  evidence, not candidate confirmation (`conquest-gpcm-overlap-record-0.2.3.md`,
  2026-08-12).
- [x] Define a disjoint, prospectively governed dataset and execution identity;
  do not reuse the opened native microcase as confirmation
  (`conquest-p3-item-only-adversarial-fixtures-record-0.2.3.md`, 2026-08-15).
- [x] Include at least one unit-slope PCM reduction and multiple non-unit-slope
  controls with all item transitions observed
  (`conquest-p3-item-only-adversarial-fixtures-0.2.3.R`, 2026-08-15).
- [x] Include an intercept-only population and one prespecified latent-regression
  covariate design with matched inclusion and variance conventions
  (`conquest-p3-item-only-adversarial-fixtures-record-0.2.3.md`, 2026-08-15).
- [x] Prove the continuous-target and finite-integration contracts using
  independent probability and marginal-likelihood reconstruction
  (`conquest-p3-item-only-adversarial-fixtures-0.2.3.R` and its test,
  2026-08-15).
- [x] Freeze a q ladder and distinguish `integration_unresolved` from optimizer
  or cross-engine disagreement before execution
  (`conquest-p3-metric-precision-contract-0.2.3.R`, 2026-08-15).
- [x] Freeze relative-slope, population-scale, transition-threshold, deviance,
  fitted-probability, raw-token, and reported-resolution rules
  (`conquest-p3-metric-precision-contract-record-0.2.3.md`, 2026-08-15).
- [x] Keep TAM pairwise differences separate as optional third-implementation
  evidence; never use a two-against-one vote to override an oracle failure
  (`conquest-p3-metric-precision-contract-0.2.3.R`, 2026-08-15).
- [x] Exclude many-facet slope-owner claims unless a separate C1 proof establishes
  identical probabilities, constraints, and free dimensions
  (`conquest-p3-metric-precision-contract-0.2.3.R`, 2026-08-15).
- [ ] Authorize the external candidate only after P0/P1 pass and the smallest
  P2 external slice has been classified without an unresolved infrastructure
  defect.
- [ ] Diagnose every expected row under the complete denominator and failure
  taxonomy before any confirmation decision.
- [ ] Close P3 only for the exact item-only GPCM envelope that passes C0--C5;
  never generalize by the GPCM name to multifacet free-slope models.

#### P4 -- conditional replicated confirmation

- [x] Decide from P2/P3 deterministic evidence whether any retained decision is
  still uncertain; record `replication_not_needed` when none can change. The
  selected candidate-004 fixed-artifact claim requires independent
  recalculation but not sampled replication; repeating the same-author pipeline
  cannot supply independence
  (`conquest-p4-replication-necessity-decision-record-0.2.3.md`, 2026-08-15).
- [x] Do not activate a replication design for the selected claim. Independent
  sampling unit, target disagreement/failure rate, confidence or MCSE
  precision, and maximum generalized claim remain typed not applicable.
- [x] Do not freeze replication counts or sequential rules when replication is
  not needed. Any future generalized claim requires a new prospective,
  metric-specific design rather than inheriting one universal count.
- [x] Generate no P4 rows for the selected claim; therefore no failed or
  ineligible sampled fit can be omitted from a nonexistent denominator.
- [x] Treat the fixed-artifact decision as already resolved for replication;
  ConQuest expiry pressure cannot broaden it into a sampling claim.
- [x] Close P4 for the selected bounded claim as
  `replication_not_needed`. Cross-data-set disagreement rates, recovery,
  coverage, portability, wider P2, and P3 remain separate unselected or
  deterministic-gate-first claims.

#### P4S -- successor adversarial simulation program

- [x] Select a new population-level question instead of retroactively widening
  candidate 004. Candidate-004 data and thresholds cannot accept the successor
  claim, and its independent-review handoff is nonblocking and dormant.
- [x] Freeze nine failure-mode scenario classes across the intended RSM/PCM
  envelope: complete crossing, connected sparse multiple bridges, weak single
  bridge, unequal Rater workload, paired missingness, rare boundary categories,
  extreme Persons, unused-category rejection, and disconnected-design
  rejection.
- [x] Make one independently generated scenario-by-family dataset the sampling
  unit. Retain every generated dataset in an unconditional outcome ledger and
  require unconditional execution/eligibility companions for conditional
  numerical summaries.
- [x] Separate structural disposition, both engine outcomes, truth and oracle
  errors, bias/RMSE, common-coordinate disagreement, quadrature sensitivity,
  and false-ready/false-pass decisions. Defer uncertainty coverage until its
  covariance estimand and interval rule are proven.
- [x] Require disjoint smoke, calibration, and untouched confirmation data.
  Calibration cannot enter confirmation, and no universal replication count
  is preselected
  (`conquest-adversarial-simulation-program-record-0.2.3.md`, 2026-08-15).
- [x] Complete the six missing cross-family or disjoint deterministic
  template gaps as seven new arms, yielding nine scenario classes x RSM/PCM =
  eighteen prototype arms. Validate the complete, sparse, weak-bridge,
  workload, missingness, rare-category, and extreme-Person contracts directly.
  For the disconnected negative control, require the full population-location
  plus constrained conditional predictor to have rank 8/9 in RSM and 12/13 in
  PCM because X is confounded with the two Person--Rater components; do not use
  the graph label alone. Keep unused-category rejection as a support/boundary
  claim despite its full algebraic predictor rank
  (`conquest-adversarial-simulation-template-contract-record-0.2.3.md`,
  2026-08-15).
- [x] Freeze four exact DGP profiles and implement code-path-separated neutral
  primitives. Caller-supplied open-interval uniforms feed base-normal latent
  transforms and a direct cumulative-step inverse-CDF response generator; a
  reconstructed-A probability oracle and log-centered continuous oracle remain
  outside the generation path and call neither fit engine. Across 672
  probability cases the maximum path difference is `4.4408920985e-16`; a
  one-Person-per-arm complete/rare RSM/PCM sentinel has zero observed
  continuous log-likelihood difference and maximum declared deviance error
  envelope `5.52333797532e-13`, below the frozen `1e-8` mechanics threshold.
  The quadrature component is an estimate, not a proof. Full-arm continuous
  qualification remains in G3
  (`conquest-adversarial-simulation-dgp-oracle-contract-record-0.2.3.md`,
  2026-08-15).
- [x] Freeze a mechanics-only smoke seed band and output schema, complete the
  full-Person continuous-oracle qualification, then authorize no more than one
  disjoint dataset per scenario-family arm. Seeds `987001:987018` are sealed
  inside the reserved `987000:987099` smoke namespace. Direct and
  reconstructed-A category coefficients agree to `4.44089209850063e-16`; the
  compiled integrand agrees with the original G2 direct path to
  `1.4210854715202e-14` across 960 probes. All 192 Person integrals converge,
  with maximum arm-level declared deviance-error envelope
  `1.75458265678942e-10` below the frozen `1e-8` mechanics threshold. No
  sampled response, fit, or ConQuest output was generated or opened
  (`conquest-adversarial-simulation-smoke-authorization-record-0.2.3.md`,
  2026-08-15).
- [x] Generate exactly one sealed smoke dataset per scenario-family arm into
  the frozen six-table schema. Retain all eighteen arms unconditionally and
  use the results only for generation, replay, schema, and structural-prefit
  mechanics; do not estimate operating characteristics or tune any rule.
  Eighteen unique arms and seeds were retained; 7,032 response-representation
  rows reconcile, all fourteen eligible and four expected-rejection structural
  dispositions pass, semantic replay passes, and no prototype response vector,
  fit, or ConQuest output was used. The stale rank-field adapter and lossless
  CSV type-inference review incidents remain recorded rather than discarded
  (`conquest-adversarial-simulation-smoke-execution-record-0.2.3.md`,
  2026-08-15).
- [x] Freeze the calibration seed band, failure taxonomy, permitted exploratory
  summaries, and runtime/storage cap without generating or opening calibration
  responses. Calibration now owns 450 identities in disjoint namespace
  `988000:989999`, begins with a 90-dataset tranche A, retains failures and
  unconditional companions, permits no result-driven stop/expansion rule, and
  remains execution-closed
  (`conquest-adversarial-simulation-calibration-freeze-record-0.2.3.md`,
  2026-08-15).
- [ ] Freeze a separate run-once engine-mechanics authorization over the 18
  retained G3 datasets before opening calibration. The four structural
  negative controls must remain prefit stops; the fourteen eligible datasets
  permit at most one q61 attempt per engine (28 attempts total), with a fresh
  ConQuest semantic sentinel and exact runtime/resource boundary.
- [ ] Run the frozen disjoint calibration band solely to estimate failure,
  variability, runtime, and storage; retain every row and do not reuse
  calibration rows for a confirmation claim.
- [ ] Set metric-specific decision loss, precision/MCSE targets, replication
  counts, untouched seeds, and stop/expand/abort rules before confirmation.
- [ ] Run and classify P2 RSM/PCM confirmation before considering the separate
  P3 item-only GPCM stratum. Many-facet free-slope GPCM remains excluded until
  a separate model-identity proof passes.

#### P5 -- release and maintenance handoff

- [x] State the exact matched overlap, observed ConQuest versions/platforms,
  covered designs, and covered parameter/decision classes. The P5 ledger keeps
  the six-arm and later minimum-diagnostic candidate number lineages distinct
  and binds every retained overlap to ConQuest 5.47.5 Demo on x86_64/Rosetta
  (`conquest-p5-evidence-disposition-ledger-record-0.2.3.md`, 2026-08-15).
- [x] List all negative-control, ineligible, failed, boundary-limited,
  integration-limited, and unresolved outcomes using the fixed denominator.
  The ledger retains failed and withheld arms, 13 prefit gates, four
  integration-limited checks in each affected slice, 96+96 typed-ineligible
  posterior rows, readiness/identification holds, the six-arm Binary oracle/
  rank gap, two structural negative controls, seven reviewer-control classes,
  two missing independent reviews, and the unopened 5,073-outcome wider P2
  denominator.
- [x] Map the evidence to public decisions that are supported, caveated,
  disabled, or deferred; do not claim general software interchangeability.
  Only the existing pure-R handoff boundary is supported; all numerical
  promotion remains caveated, disabled, or deferred, and this internal map
  authorizes no public text change.
- [x] Define the smallest dependency-based sentinel for changes to likelihood,
  constraints, category handling, integration, parsers, transforms, or the
  ConQuest runtime. The candidate-004 sentinel now separates versioned
  historical evidence from current-source applicability, routes semantic
  changes to raw-artifact recalculation, a new runtime sentinel, a successor
  candidate, contract-integrity review, or evidence quarantine, and never uses
  byte equality as a scientific gate
  (`conquest-p2-candidate-004-dependency-sentinel-record-0.2.3.md`,
  2026-08-15).
- [x] Confirm that ConQuest remains optional and absent from package runtime,
  ordinary tests, source-package requirements, and CRAN checks. The installed
  package retains only pure-R handoff/normalization APIs; it contains no
  executable discovery, launch, fixed machine path, dependency, external
  validation tree, or external ConQuest test. A normal vignette-bearing source
  tarball passed `R CMD check --no-manual` without ConQuest
  (`conquest-optional-package-boundary-audit-record-0.2.3.md`, 2026-08-15).
- [ ] Update the release spine and public support boundary only after the exact
  preceding gates relevant to each claim are complete.

#### Per-run Go/No-Go checklist template

Copy this block into every successor candidate record. All items must be
checked before external output is opened; otherwise the run is not authorized.

- [ ] The row exists in the frozen registry and changes a named retained
  decision.
- [ ] Runtime C0, exact model identity C1, and independent oracle C2 have passed.
- [ ] Category support, missingness/weights, A/C matrices, free dimensions,
  constraints, population target, and integration target are explicit.
- [ ] Eligible coordinates, raw-token precision, boundary conventions, q
  ladder, tolerance, complete denominator, and failure classes are frozen.
- [ ] Required negative controls reject correctly.
- [ ] Input/output locations are isolated, expected output schemas are listed,
  and semantic failure cannot pass through status zero.
- [ ] The executable identity and expiry-aware scope cap are recorded.
- [ ] The smallest sufficient run has been chosen and no already-opened fixture
  is being reused as its own confirmation.
- [ ] Reviewer, authorization date, and prospective record identity are present.

Any unchecked item is a No-Go. After output is visible, a failed early layer
cannot be repaired by later agreement: stop, classify, narrow the claim, and
create a new prospective candidate only if the retained decision still
requires one.

This checklist displaces new model families, broad G-theory execution, and
unfocused high-replication simulation. Internal invariance, readiness, and
boundary work continues when it is a direct prerequisite for interpreting a
ConQuest row; it does not become secondary merely because an external program
is available.

## Current position

- CRAN currently distributes 0.2.2, published on 2026-07-27. That published
  package is the immutable public baseline for all 0.2.3 development.
- The exact 0.2.2 source asset is `mfrmr_0.2.2.tar.gz`, SHA-256
  `dddeaaba8d2d0684784fa774b349e8fa1d13570143341daad4aa31e2990e5d00`,
  built from tagged source commit `03915badf336eeaeb7ef7fbb5119c2880c541e63`.
- That asset passed a local full-manual `R CMD check --as-cran
  --run-donttest`, official Win-builder R-devel, the five-platform package
  matrix, the full non-CRAN suite, and pkgdown. The repository-only CRAN
  preparation change was squash-merged as `10cf3e8`; its tree also passed the
  post-merge package matrix and pkgdown.
- Version 0.2.2 was accepted and published by CRAN on 2026-07-27. The submitted
  tarball, tag, and release asset remain frozen. CRAN adds repository metadata
  and an `MD5` manifest to its distributed source, so the submitted compressed
  digest and CRAN-distributed compressed digest are distinct identities even
  though the audited package payload agrees.
- The `development/0.2.3` branch now carries package identity 0.2.3. This is
  an unreleased development target, not a release candidate: candidate freeze,
  confirmation, and submission remain prohibited until the M3-M5 evidence and
  identity gates pass.
- `DESCRIPTION` records lifecycle `development` and public baseline 0.2.2;
  `DESCRIPTION` and `CITATION.cff` intentionally carry no release date until
  an explicit candidate freeze.
- If CRAN later asks for a 0.2.2 correction, that work branches from the
  published/tagged source and must not absorb unfinished 0.2.3 implementation.

The central sequencing decision is deliberate: numerical trust and external
overlap evidence come before new model families. Operational calibration and
multiple observed scales come before native multidimensional latent-trait
estimation. An external multidimensional challenge to the current
unidimensional claim belongs to 0.2.3 validation; a native multidimensional
engine and dimension-specific score production remain 0.3-or-later work.

For this roadmap, three similarly named concepts are kept separate:

- an **element anchor** fixes a Person or facet level and is already supported
  in 0.2.2, including group anchors and pre-fit review;
- a **threshold/step anchor** fixes all or part of an RSM/PCM threshold ladder
  and belongs to the single-scale calibration work in 0.2.4; and
- a **scale-specific anchor** is indexed by an explicit observed `ScaleId` and
  cannot be completed until the multi-scale architecture in 0.2.5.

`Umean`/`Uscale`-style score-display transformations are not estimation
anchors. Likewise, PCM thresholds that vary by the current `step_facet` are
item- or facet-specific step ladders on one observed score scale; they are not
multiple independent scales.

The dependency order is therefore: validate the current single-scale contract
in 0.2.3, make that contract reusable through typed calibration and step
anchors in 0.2.4, and only then add explicit multi-scale parameter indexing in
0.2.5. Existing fitted-object EAP/posterior scoring in 0.2.2 is not the same as
loading a versioned frozen calibration for operational scoring of new data.

### Generalized-MFRM model-family dependency lock

`generalized-mfrm-model-ladder-0.2.3.md` is the controlling technical
refinement for GPCM model identity. It classifies the implemented likelihood
as an aligned single-owner relative-slope GPCM: exactly one facet owns both
the slope and step blocks, `slope_facet == step_facet`, and the latent trait is
unidimensional. Draft.63 adopts separate criterion-owned and rater-owned
evidence strata plus the machine-readable
`gpcm-model-identity-contract-0.2.3.csv`. That hashed map remains part of the
historical Draft.66 lineage; P1r/P1s supply the current-default scale/support
overlay without rewriting it. The existing pooled
`NUM-GPCM-BOUND` label is retained only for historical calibration traceability
and cannot promote either substantive owner interpretation.

Every future GPCM evidence identity must carry at least `SlopeOwner`,
`StepOwner`, `SlopeComposition`, and `LatentDimensionCount`, in addition to the
estimator, latent-scale, category-map, constraint, and topology identities
already required by the release gate. This distinction applies to simulation,
recovery, DFF/DRF, fit, external comparison, cache/replay, and public support
rows. A rater-indexed slope is model-conditional discrimination until
role-specific recovery and attribution evidence earns any stronger
`consistency` interpretation.

The dependency order after the current aligned route is: decouple one slope
owner from one step owner; then define multiplicative criterion/task-by-rater
slope blocks and their factor-separation constraints; then consider a native
multidimensional generalized model. Rater-by-criterion severity interactions,
centrality/extremity response-style models, hierarchical latent-rating models,
and repeated-rating local-dependence models are alternative branches, not
automatic steps in that nesting sequence. They may supply generator-only
diagnostic challenges in 0.2.3 without becoming native fit methods.

Draft.63 changes evidence identity, not the likelihood. Existing criterion-
owned stress and attribution runners remain calibration inputs, but they do
not satisfy the rater-owned gate. The next execution slice must stamp the four
model-family identity fields, ability-scale contract, and actual runtime
content identity into every GPCM manifest/result before owner-specific pilot
evidence is regenerated. Confirmation remains unauthorized.

Draft.64 adds the owner-specific execution slice in
`gpcm-owner-specific-pilot-0.2.3.R`. Its smoke manifest crosses both owners,
JML/MML, and core/weak/negative support designs while hashing the loaded
runtime, runner, identity contract, manifest, and retained data. The guarded
unit execution proves dispatch and fail-closed support behavior only; it does
not close owner-specific recovery, coverage, precision, runtime, fit, DFF, or
external gates. The larger pilot expands 24 owner/estimator/design cells to
five disjoint seeds each (120 run rows) and remains authorization-guarded and
unrun, so confirmation remains unauthorized.

Draft.65 freezes the pre-pilot execution structure in
`gpcm-owner-specific-execution-contract-0.2.3.md`. One full-manifest execution
identity now covers runtime, runner, both contracts, optimizer ceiling, and
quadrature. The primary pilot freezes the package-default `maxit = 400` and
q=31 Gaussian--Hermite basis; q=5 remains smoke-only, and a later higher-node
MML sensitivity lane must receive a separate identity rather than being
pooled into primary recovery. Deterministic modulo shards alter workload
placement only. Atomic one-row checkpoints permit strict interruption/resume and reject orphan,
identity-mismatched, or altered payloads. Bernoulli summaries retain every
planned row in the denominator and report MCSE plus 95% Wilson intervals;
numeric recovery reports finite and missing/ineligible counts, failures,
evidence-ready counts, and finite-value MCSE. A hashed completion marker can
exist only after all declared checkpoints validate. These are execution-
integrity controls, not recovery evidence. At Draft.65 freeze the live pilot
was unrun and confirmation remained unauthorized.

Draft.66 records the first completed owner-specific pilot and its corrective
rerun in `gpcm-owner-specific-pilot-record-0.2.3.md`. Draft.65 exposed that
the intended observed 1/3/4 internal-zero challenge was being fitted after
automatic recoding to 1/2/3. Draft.66 fixes `keep_original = TRUE`, changes
the execution identity, and completes all 120 rows/checkpoints. All 20
internal-zero rows now fail closed before optimization; the other 100 rows
match Draft.65 on every non-identity result field. Overall, 88 fits return,
32 failures remain in denominators, and identity violation, inference-ready,
and false-ready counts are zero. Weak-bridge JML recovery is the dominant
signal, but five-replicate Wilson intervals and MCSE are too wide for a
threshold. Next come unexpected-JML failure attribution, paired common-data
owner/estimator contrasts, separately identified MML node sensitivity,
replication expansion, and recovery/coverage beyond optimizer slopes. No
gate, numeric rule, owner-consistency claim, or confirmation state is
promoted.

Draft.67 closes the two-row JML artifact-loss mechanism without treating it as
a recovery or boundary proof. The fixed common-data optimizer panel and exact
trace are recorded in
`gpcm-owner-jml-optimizer-attribution-record-0.2.3.md`. Both unexpected
Draft.66 failures involved a non-representable log-slope proposal, but their
substantive paths differed: rater-owned workload imbalance was an early BFGS
line-search accident, while criterion-owned weak bridge remained an extreme
slope/boundary path under both BFGS and L-BFGS-B. This rejects a wholesale
optimizer switch. The narrower implementation makes the parameter cache
transactional and rejects only the typed non-representable slope proposal
during direct-optimizer line search. In the full 40-row BFGS recheck, all fits
return, exactly two rows record a rejection, the other 38 objectives reproduce
within `4.55e-12`, and the weak-bridge case remains convergence-failed and
inference-ineligible. The next active order is therefore joint weak-link
geometry, separately identified MML node sensitivity, paired owner/estimator
attribution, expanded recovery/coverage replication, and only then numeric
freeze. Artifact retention is improved; no gate is promoted.

Draft.68 completes the separately identified MML integration lane under
`gpcm-mml-integration-sensitivity-contract-0.2.3.md`; exact execution and
results are in `gpcm-mml-integration-sensitivity-record-0.2.3.md`. Forty exact
owner-pilot datasets are each fitted at q=31/61/91 and evaluated on one common
q=91 grid. All 120 fits return, but seven code-zero fits remain gradient review
and none becomes inference-ready. q=31 common-grid regret reaches 0.5443,
while q=61 regret is at most 0.001471. q=31-to-q=91 changes reach 0.0914 for
identified log slopes, 0.6011 for steps, 0.0745 EAP RMSE, and 0.0591
posterior-SD RMSE. Thus q=31 remains only a comparison starting grid; small
structural-objective regret cannot stand in for Person-estimand stability.
Zero-common-Person MML remains population-assumption-linked and blocked. The
next integration step is direct q61-to-q91 parameter comparison with
prospectively proposed tolerances inside expanded replication, not a default-q
change. Marginal-MML slope geometry and paired owner/estimator attribution
remain ahead of any freeze.

Draft.69 implements the first estimator-specific marginal-MML slope-boundary
instrument under `gpcm-mml-slope-boundary-contract-0.2.3.md`. For the declared
finite quadrature rule it expresses each Person-pattern derivative as a
posterior-node-weighted conditional derivative, checks utility maximum/minimum
compatibility at every node, enumerates all ordered constant sum-zero
two-level rays, and reconstructs each compatible boundary likelihood
independently. A constructed sparse control is certified and follows the
direct likelihood-path oracle; ordinary data, row permutation, reconstruction,
and execution-limit controls also pass. This closes the absence of MML
boundary instrumentation, not marginal identification: the certificate is
only sufficient for a fixed-node/fixed-additive path, has no readiness effect,
and neither positive nor negative results make finite optimizer slopes primary.

Draft.70 completes the first retrospective cross-q application under
`gpcm-mml-boundary-grid-calibration-contract-0.2.3.md`; exact execution and
results are in `gpcm-mml-boundary-grid-calibration-record-0.2.3.md`. All 40
Draft.68 datasets and 120 q arms complete. Every arm is
`none_certified_fixed_quadrature_marginal`, with exact boundary-likelihood
reconstruction and identical state, certified direction set, and target status
across q=31/61/91 for every dataset. Draft.68 own-grid and common-q91
likelihoods reproduce with maximum difference zero. Direct q61-to-q91 maxima
are 0.001471 common-grid regret, 0.00619 log slope, 0.0132 facet, 0.0553 step,
0.00552 EAP RMSE, and 0.00790 posterior-SD RMSE. These values sharpen the
prospective design but do not freeze tolerances: the datasets were already
inspected, five replicates do not characterize tails, q91 is not a proven
continuous-integral limit, and the zero positive count gives no positive-path
detection estimate.

The next active order is therefore: (1) prospectively freeze positive,
near-boundary, negative, and sufficient-test-silent challenge strata across
q=31/61/91; (2) run untouched owner/design seeds under a separately declared
q61-to-q91 candidate rule, retaining failures in every denominator; (3)
calibrate a separately versioned readiness-propagation rule only after positive
and negative classification behavior is known; and then (4) begin paired
JML/MML recovery and coverage. Fit and DFF operating characteristics remain
separate from integration and boundary geometry.

Draft.71 executes the first item under
`gpcm-mml-boundary-challenge-contract-0.2.3.md`; the failed frozen expectations
and exact identities are retained in
`gpcm-mml-boundary-challenge-record-0.2.3.md`. All 30 deterministic fits and
likelihood reconstructions complete, and all 12 mixed-negative or positive-
weight-discordant expectations pass. However, criterion/rater forward,
reverse, and zero-weight positive expectations fail in all 18 dense-grid arms:
every q=31/61/91 result is none-certified. The q=5 reference remains positive
only for that exact coarse objective. Gaussian--Hermite extrema expand from
about +/-2.86 at q=5 to +/-9.89, +/-14.50, and +/-18.02, so finite additive
coordinates no longer keep each observed response at the required utility
extremum on every node. The all-node sufficient condition is therefore not a
viable bridge to continuous-normal or readiness claims.

This concern reorders the active sequence. Readiness propagation and
stochastic classification calibration are paused. The next core slice must
derive a broader Person-marginal half-line condition that permits adverse
conditional outer nodes to lose posterior mass, proves its limit and derivative
behavior over the complete ray rather than a selected t grid, and keeps finite
q, continuous-normal, and moving-additive theorems separate. A new
q=5/31/61/91 deterministic challenge must pass before untouched-seed owner
classification work resumes. Direct q61-to-q91 recovery calibration may
continue as a separate numerical lane, but it cannot substitute for the
boundary proof. Fit/DFF operating characteristics remain downstream and
separate.

Draft.72 begins that corrective slice under
`gpcm-mml-person-marginal-path-contract-0.2.3.md`; selected verification is in
`gpcm-mml-person-marginal-path-prototype-record-0.2.3.md`. The analytic oracle
reconstructs the exact finite-q objective, first derivative, curvature,
surviving-node boundary likelihood, and leading tail coefficient. On the
Draft.71 q=31 positive control, 36 Person-node derivative cells are adverse at
each selected t while all 12 posterior-weighted Person derivatives and the
total derivative are positive. Analytic first derivatives and curvature match
their stable central checks to approximately `3e-12` and `2e-15`; generalized
boundary improvement and the tail coefficient are both approximately
`9.0542e-9`. At q=61/91, 58/61 and 81/91 positive-compatible nodes per Person
survive, making explicit how adverse outer nodes lose limiting mass.

This is mechanism/formula progress, not the missing proof. All selected points
could be positive while an unobserved interval is negative, ordinary doubles
do not provide outward error bounds, and the leading tail term lacks a
certified remainder. `HalfLineCertified`, `TailCertified`, and readiness remain
false. The active mathematical order is now: outward-rounded value/derivative
bounds; deterministic compact-interval subdivision with typed exhaustion; a
tail remainder joined to that interval; genuine sign-changing and near-zero-A
counterexamples; then the full owner/q/polytomous challenge. Only after those
pass may stochastic classification or readiness propagation resume.

Draft.73 advances a separate JML-estimator maturity lane under
`jml-extreme-profile-limit-contract-0.2.3.md`. The existing typed Person audit
correctly reports independently free all-minimum/all-maximum Persons at signed
infinity, but the structural coordinates and stored objective still come from
a finite joint optimizer trace. The repository-only prototype now removes
exactly those Person likelihood contributions, reoptimizes the remaining JML
coordinates, and reconstructs the original likelihood along signed finite
ability caps. Selected RSM, PCM, and aligned-owner GPCM controls approach the
reduced supremum monotonically and end within `5.92e-12`; anchored Persons are
not removed and constraint-coupled extremes fail closed. Raw and profile-limit
values remain distinct, and the result explicitly denies a finite original-
JML maximum and any finite-item bias-correction interpretation.

This establishes an extended-boundary computation identity, not estimator
maturity. Next, the raw finite trace and profile-limit structural result must
enter a prespecified recovery grid with extreme proportion, Person exposure,
weights, missingness, topology, rater workload, category support, interactions,
and owner-specific GPCM strata. That grid must remain factorially separate
from external extreme-score adjustment and finite-item-bias correction. Only
after recovery, supported uncertainty, failure accounting, and candidate-
linked runtime evidence may a production/public decision be considered.

Draft.74 executes the first paired slice under
`jml-extreme-profile-recovery-contract-0.2.3.md`. Ninety RSM, PCM, and aligned
Criterion-owned GPCM datasets cross low/high Person exposure, forced extreme
fractions 0/0.10/0.25, and five fixed seeds. All 90 raw fits return, all
forced Persons have the correct signed unbounded type, 68 finite-cap profile
paths verify, 22 no-free-extreme cases use the declared no-op, and every one
of 2,700 structural recovery rows pairs. No extreme fit is falsely marked
inference-ready. The GPCM path extends to cap 64 because its limiting rate
depends on the smallest fitted positive slope; the maximum terminal gap is
`1.94e-11`.

The maximum aligned raw/profile structural change is only `5.94e-6`, and the
two recovery RMSE summaries agree at displayed precision. This is informative
without being reassuring in the wrong way: the profile operation resolves
non-attainment, but it does not remove the remaining JML incidental-parameter
bias. Person recovery is excluded and profile SE/coverage remain unavailable.
Five replicates, complete crossing, one GPCM owner, and no weights,
missingness, weak links, workload imbalance, interactions, anchors, or
external modes preclude a numeric rule or estimator choice. The next active
JML order is expanded replication and adversity, then a separately identified
FACETS/TAM/immer extreme-adjustment and bias-correction grid, supported
uncertainty, and only afterward a production decision. Confirmation remains
unauthorized.

Draft.75 starts that external-convention grid with a source-audited identity
and normalization smoke, not with a package ranking. Installed TAM 4.3-25 and
immer 1.5-13 help and loaded function bodies are bound to exact hashes and
mode arguments. A common expanded cumulative-difficulty surface avoids direct
comparison of opposite-sign/corner-constrained basis coefficients. The four
paired RSM/PCM microdatasets retain all 36 planned method rows and 864
successful structural coordinates; four TAM `adj = 0` modes with forced
extremes fail and remain ineligible. On no-extreme data, location-aligned
mfrmr/TAM raw differences are at most `3.88e-6` and TAM/immer raw differences
at most `1.25e-5`. With forced extremes, TAM `adj = .3` and immer
`jml, eps = .3` differ by at most `8.06e-8`; all classical postscale identities
reproduce to `8.88e-16`.

The more important result is semantic. immer `jml` is original unadjusted JML
only when no Person is extreme; `eps_adj` changes both Person and item
sufficient statistics; and `jml_bc` combines its extreme handling with an
`(Ibar - 1) / Ibar` postscale. TAM separates `adj` from a later
`(I - 1) / I` postscale. They coincide on the complete nine-pseudoitem smoke
but can diverge under missing or unequal exposure. Therefore Draft.75 selects
no correction and freezes no tolerance. Draft.76 supersedes the narrow
60-dataset proposal with the factor-structured program below. GPCM remains
outside this specific overlap because immer's design-matrix PCM JML is not
mfrmr's aligned single-owner slope GPCM. Confirmation remains unauthorized.

Draft.76 makes sample and design adversity first-class identities. The
22-dataset feasibility smoke crosses RSM/PCM with Persons, realized responses
per Person, Rater and Criterion counts, 3--6 categories, assignment density,
workload imbalance, forced and natural endpoint rates, Gaussian-copula local
dependence, guarded Rater anchors, MCAR, observed-Rater MAR, score-MNAR, and a
combined-adversity cell. Observations per Person are treated as a derived
quantity because they are algebraically determined by assigned Raters,
Criteria, and observed fraction. A full Cartesian product is rejected in favor
of factor blocks and targeted interactions.

All 22 datasets generate. Two anchor rows retain their truth anchor tables but
stop before fitting because a common mfrmr/TAM/immer anchor basis is not yet
proved. The two one-Rater-per-Person low-information rows correctly fail the
structural-rank screen: no common Persons link Raters. The other 18 datasets
retain all 162 method rows. Eleven contain observed extreme Persons, producing
22 retained TAM `adj = 0` failures and reducing original-raw eligibility for
mfrmr raw and immer `jml` to 7/18 even though their numerical fits return.

Sparse assignment exposes the anticipated correction divergence directly:
TAM uses `31/32`, based on 32 potential pseudoitems, while immer uses `7/8`,
based on eight observed responses per Person. Across fitted cells, their
factors range `0.9375--0.97917` and `0.84027--0.95833`. Their returned marginal
basis SE vectors also remain unchanged after classical point-estimate
postscaling. Common-surface coverage is therefore unavailable pending a proved
native-basis truth mapping or a prespecified refit/bootstrap covariance.

The 3,050 metric rows keep bias, RMSE, Spearman rank, pairwise order,
truth-SD/RMSE recovery separation, returned fit, finite surface, numerical
convergence, and estimand eligibility separate. Recovery separation is not
reported Rasch/FACETS separation. Common-surface coverage and definition-
matched reported facet separation have zero eligible rows. Local-dependence
and MNAR results are misspecification robustness only.

The next guarded manifest is 29 profiles x two models x five replicates = 290
datasets. Five replicates can expose feasibility and gross interactions but
cannot estimate coverage or rare failures. The order after that pilot is:
common anchor mapping; covariance/coverage identity; reported-separation
definition; stronger external convergence extraction; then high-replication
calibration with prespecified Monte Carlo precision and untouched confirmation
seeds. No correction or sample-size recommendation is authorized.

Draft.77 executes that guarded pilot and adds the missing execution-integrity
layer. Dataset-level checkpoints bind the manifest row, generator/fitter/metric
bodies, loaded mfrmr/TAM/immer function identities, R/platform/RNG contract,
and payload hash. Publication is same-directory temporary-write, verification,
and rename; unexpected or stale files fail closed. A completion marker binds
all 290 checkpoint file hashes and the deterministic aggregate. An independent
resume reconstructed all 290 cells without refitting and matched result hash
`bd506dfdad21d1bafa3ee45409e64a77d8d63e5b75483a35db304644a224ab53`
and marker hash
`9bf8b8db3ce45ccd416d0fe12d5906bd33c104d5aa00db8925edfd410faa999c`.

The manifest accounts for 230 fitted datasets and 2,070 mode rows, 40 expected
structural-rank failures, and 20 anchor guards. The structural failures are not
incidental: `EXPOSURE_LOW`, `RATERS_LOW`, `DENSITY_LOW`, and the combined
low-information profile all assign only one Rater per Person and contain no
common-Person Rater links. They cannot supply a low-information recovery
estimate. The next design replaces those cells with prespecified connected
bridge fractions and separates total Raters, assignment degree, density, and
realized exposure more carefully. Apparent high-density benefits remain
aliased with having only two Raters and are not promoted.

Of the 230 fitted datasets, 126 contain observed extreme Persons. Original-raw
eligibility is therefore 104/230 for mfrmr raw and immer `jml`; TAM raw returns
on 103/230, including one separate no-extreme failure. mfrmr raw returns on all
230 while its extended profile returns on 228. TAM adjusted and combined modes
return on all 230 but meet the iteration-before-ceiling proxy on 192; TAM
raw/classical meet it on 84. All three immer modes meet that proxy on 230.
Return, numerical convergence, extreme-boundary identity, and evidence
eligibility remain distinct denominators.

The five-replicate traces show the expected finite-item contraction direction
without selecting a correction. On common original-raw-eligible rows, TAM and
immer classical corrections reduce cumulative-surface RMSE in 95.1% and 94.2%
of cells; their correction factors range `0.875--0.96875` and
`0.75--0.9375`. Those corrected points are not original-JML maximizers, and the
unchanged returned marginal SE vectors cannot provide corrected-estimand
coverage.

Method-specific reference ratios identify priorities, not thresholds. Median
cumulative-surface RMSE ratios are about `2.43` for 30% score-MNAR, `2.01` for
sparse-load-MAR, `1.71` for local dependence 0.50, `1.48` for 48 Persons, and
`0.53` for 480 Persons. The fixed-exposure Person comparison does not establish
that incidental-parameter bias vanishes. Rank recovery and location RMSE can
move differently, and truth-SD/RMSE recovery separation remains distinct from
reported Rasch/FACETS separation.

Draft.78 completes the first connected low-exposure/low-density redesign. Its
18 profiles x RSM/PCM deterministic smoke has 30 connected datasets retaining
270 method rows and six disconnected negative controls stopping before
optimization. The runner makes bridge-Person count, Person degree, density,
workload imbalance, Rater-graph components, shared-Person edge weights, and
weighted algebraic connectivity explicit before and after response-level
missingness.

Six bridges leave the planned eight-Rater chain in two components; 12 bridges
connect it. The 12-bridge designs have identical cross-Rater algebraic
connectivity with 60, 120, or 480 total Persons, showing that additional
single-Rater Persons do not increase linking information. This is not a
12-bridge recommendation: the positive construction still has minimum edge
weight one and remains weakly linked. Fixed-degree and fixed-density Rater
sequences are retained as different conditional contrasts because density,
degree, and Rater count cannot be three orthogonal effects.

Natural extreme Persons occur in 20/30 connected datasets. Original-raw
eligibility is 10/30 for mfrmr raw and immer `jml`; TAM raw/classical return on
9/30. Most TAM adjusted/combined fits reach the 500-iteration smoke ceiling,
so their return state and iteration-before-ceiling proxy remain separate.
Common coverage and reported facet separation still have zero eligible rows.

Draft.79 completes the matched path, cycle, distributed, and hub structural
smoke at 8, 12, and 24 bridge Persons. It adds articulation-Rater, cut-edge,
single-link-Person failure, removal robustness, cycle rank, and edge-weight
diagnostics. Thirty connected RSM/PCM datasets retain 270 method rows; six
observed-disconnected controls stop before optimization. The first run is
intentionally interrupted after one atomic checkpoint, resumes the other 35,
and a second process reconstructs all 36 with the same aggregate and marker
hashes.

At 12 bridges, hub algebraic connectivity exceeds cycle and path, yet the hub
has one articulation Rater and seven cut edges. One targeted link loss
disconnects path and hub; cycle survives as a vulnerable path and distributed
survives with two articulation Raters and two cut edges. Spending 24 bridges
inside only four Raters leaves the global design in five components. No bridge
count or one scalar network diagnostic can therefore become the release rule.

The smoke also rejects immediate execution of its declared five-replicate
performance manifest. Every connected dataset contains a natural extreme
Person, so original-raw eligibility is 0/30 for mfrmr raw and immer `jml`, and
TAM raw/classical return on 0/30. Only 10/30 TAM adjusted/combined fits stop
before the 800-iteration ceiling. Running more identical cells would not close
raw estimand or convergence identity.

The next ordered slice is therefore: split operational sparse-topology/extreme
and raw-JML-eligible high-information designs without conditioning away
extremes; extract or calibrate stronger engine-specific convergence evidence;
then refreeze matched-topology replication and Monte Carlo precision. Common
anchor basis, native transformed covariance or frozen refit/bootstrap
uncertainty, and definition-matched reported separation remain before high-
replication confirmation. GPCM transfer remains later and partitions
Criterion-owned and Rater-owned model identities. Draft.79 changes no public
default, bridge cutoff, topology preference, sample-size recommendation,
correction, threshold, or readiness state.

### Draft.80 typed G-theory and D-study reconstruction contract

Draft.80 adds `gtheory-reconstruction-roadmap-0.2.3.md` as a separate
observed-score measurement-design track. It does not reinterpret an MFRM fit as
a joint GT-IRT model and does not broaden the 0.2.3 public G/D-study claim.
The existing `mfrm_generalizability()` remains a univariate main-effects
`lme4` fit with collapsed interaction/residual variance, and
`mfrm_d_study()` remains a sensitivity projection of that exact surface.

The source audit establishes both opportunity and caution. Archived `gtheory`
0.1.2 accepted arbitrary `lmer` formulas and included univariate, stratum-based
multivariate, and weighted composite routes, but CRAN removed it in March 2025
and its documented unbalanced summary uses median main-facet counts. Current
`gtheoryr` 0.1.0 covers only simple persons-by-items crossed and items-within-
person designs. Current `csemGT` 1.0.0 adds a narrow persons-by-items
conditional-SEM/D-study reference, while GeneralizIT 0.1.2 supplies a separate
Python/Henderson-method univariate overlap candidate. Local `lme4` 2.0.6 and
`glmmTMB` 1.1.14 supply modern fitting,
covariance, diagnostic, and bootstrap primitives, but do not supply the
G-theory D-study meaning of an arbitrary formula.

Draft.80 therefore requires a formula plus a typed design/effect map. The map
identifies the object, random and fixed facets, nesting graph, profile strata,
component members, universe/error role, exact `ScaleBy` facets or allocation
operator, observed replication, and estimability state. A parsed `A:B` term
cannot by itself decide whether `B` is nested in `A`, whether the component is
relative or absolute error, or which future facet counts divide it. Any
unresolved role stops before a coefficient.

For a balanced fully crossed `p x r x i` design, the algebra oracle separately
scales `p:r / n_r`, `p:i / n_i`, and `p:r:i,e / (n_r n_i)` for relative error,
then adds `r / n_r`, `i / n_i`, and `r:i / (n_r n_i)` for absolute error. The
highest interaction and residual are not reported separately without within-
cell replication. Nested, partially crossed, sparse, and unequal-allocation
designs require a nesting graph plus component-specific incidence/rank and
allocation audits; observed median counts cannot silently define a D-study.

Balanced ANOVA/MoM, `lme4` REML/ML, and `glmmTMB` REML/ML remain different
estimators. Raw negative MoM components remain visible. The likelihood
backends constrain variances nonnegative, so a zero/boundary/singular estimate
is retained as such and is never described as a raw negative component or a
successful repair. `lme4` singularity/`rePCA` and `glmmTMB` Hessian,
convergence, correlation, and optimizer-sensitivity states remain backend-
specific.

Uncertainty uses full-refit parametric bootstrap as the proposed primary route:
each replicate refits the canonical G-study, repeats identification, and
recomputes every D-study scenario. Marginal variance-component interval
endpoints are not plugged into a nonlinear coefficient as the default.
Failed, boundary, and ineligible bootstrap replicates remain in the ledger.

Multivariate work follows the univariate algebra. Each effect has a stratum
covariance matrix; composite `E rho^2` and `Phi` use `w' Sigma w`. Off-diagonal
D-study scaling requires explicit common, partially shared, or independent
facet allocation across strata. Counts alone and `sqrt(n_a n_b)` do not define
that covariance. Raw symmetry, PSD, rank, and stratum-order checks precede any
scalar composite, and a PSD repair is separately labelled rather than silently
substituted.

The ordered implementation sequence is Draft.81 parser/algebra oracle;
Draft.82 balanced univariate MoM/lme4; Draft.83 nesting, partial crossing,
imbalance, and missingness; Draft.84 checkpointed uncertainty; Draft.85
multivariate covariance prototype and exact lme4/glmmTMB overlap; and Draft.86
external/reproducible-reporting gate. Version placement is 0.2.3 contract and
prototypes, possible 0.2.4 univariate candidate, 0.2.5 multivariate prototype
aligned with explicit scale/stratum identity, and 0.3.0 schema stabilization.

Draft.80 freezes no backend preference, supported arbitrary-formula grammar,
CI method, coefficient threshold, optimal D-study design, sample-size rule,
multivariate claim, public default, checklist promotion, candidate, or
confirmation state.

### Draft.81 typed parser and balanced algebra prototype

Draft.81 executes the first narrow slice of the Draft.80 plan through
`gtheory-design-algebra-contract-0.2.3.md`,
`gtheory-design-algebra-prototype-0.2.3.R`, and its result record. It adds no
export and performs no fit. The parser accepts an intercept-only fixed part and
random intercepts, normalizes term/member order against one declared object
and its facets, retains original `/` nesting edges separately from
`reformulas` expansion, and builds stable component, universe-role, `ScaleBy`,
replication, nesting, and estimability fields plus SHA-256 identities.

The coefficient-positive subset is complete crossing with one or two random
facets, all lower-order components, one collapsed highest-order/residual
component, explicit residual scaling by all random facets, and positive integer
balanced planned counts. The frozen p x i oracle returns relative error `.2`,
absolute error `.25`, `G=5/6`, and `Phi=4/5`. The p x r x i oracle returns
relative error `.30`, absolute error `13/30`, `G=10/13`, and `Phi=30/43` from
separately recorded divisors and contributions. Eight dedicated tests with 46
expectations pass.

Draft.81 does not hide estimator boundaries. Negative raw inputs remain in the
component and contribution tables with `AlgebraReady=FALSE`; no truncation is
performed. Positive fixtures may be algebra-ready, but all rows remain
`DecisionReady=FALSE` because no component estimation or uncertainty exists.
Missing residual semantics, incomplete decompositions, unsupported
nesting operators, component-name mismatches, and the unreplicated highest-
order interaction/residual alias all fail before coefficient output. Parsing a
nested formula is not evidence that conditional counts or allocation operators
exist.

This moves only `gtheory_typed_design_algebra` from `not_run` to `review` as a
roadmap guard. It is not `ok`. Draft.82 now supplies the balanced ANOVA/MoM,
matched `lme4` extraction, raw-negative/boundary distinction, and declared
collapsed-residual reduction described next; nested, partially crossed,
unbalanced, missing, interval, multivariate, and broader public compatibility
gates remain open.

### Draft.82 balanced ANOVA/MoM and lme4 estimator prototype

Draft.82 adds `gtheory-balanced-estimation-contract-0.2.3.md`,
`gtheory-balanced-estimation-prototype-0.2.3.R`, and its execution record. It
keeps the Draft.81 one-/two-random-facet, complete-crossed, one-observation-per-
cell boundary and adds no package export or dependency.

The raw estimator reconstructs every marginal interaction effect, verifies
orthogonal sum-of-squares closure, and inverts the balanced expected-mean-
square system from the highest-order residual downward. It retains mean
squares, degrees of freedom, EMS coefficients, subtracted higher-order
contributions, raw components, and negative/zero/interior states. The p x i
fixture recovers `p=1`, `i=.2`, `p:i,e=.8`; the p x r x i fixture recovers
`p=1`, `r=.12`, `i=.18`, `p:r=.24`, `p:i=.30`, `r:i=.08`, and
`p:r:i,e=.48`. Its SS/MS tables independently match saturated base-R `lm`
ANOVA output.

Matched local lme4 2.0.6 REML fits agree with those interior vectors within
`1.2e-5`. ML remains separately labelled and differs from REML on the same
data. In the negative control, raw Item MoM is `-.04444444`, while REML returns
approximately zero under the nonnegative variance parameterization and is
singular. The former is not a likelihood maximum; the latter is a constrained
REML boundary point, not a corrected raw MoM estimate or an unconstrained
maximum.

The explicit `main_effects_collapsed_residual_v1` route reproduces the four
variance components returned by current `mfrm_generalizability()` to its
documented six decimal places. It remains governed by the current residual-
scaling sensitivity contract and is rejected by the typed interaction-specific
D-study dispatcher.

Seven dedicated tests and 71 expectations pass. Algebra-ready results remain
`InferenceReady=FALSE` and `DecisionReady=FALSE`; no interval, bias/RMSE,
coverage, estimator preference, sample-size rule, external equivalence, or
public design family is claimed. `gtheory_univariate_crossed_nested` and
`gtheory_current_surface_compatibility` move only to roadmap `review`, not
`ok`. Draft.83 must add nesting, partial crossing, imbalance, missingness,
allocation, and component-specific rank/replication evidence.

### Draft.83a observed-design incidence and rank audit

Draft.83a adds `gtheory-design-incidence-contract-0.2.3.md`,
`gtheory-design-incidence-audit-0.2.3.R`, and its execution record as a
repository-only pre-fit gate. It accepts a Draft.81 typed specification even
when later D-study scaling remains unsupported, because its purpose is to
audit the observed incidence structure before a backend is allowed to make a
stronger claim.

The audit hashes canonical input, retained rows, and omission patterns without
using raw row numbers. It treats complete, MCAR, covariate-MAR, MNAR-
sensitivity, and unknown missingness as declared provenance rather than a
tested causal mechanism. Nested child labels receive ancestry-qualified
identities, so repeated labels across Sites cannot create false graph links.
Global and pairwise components, incidence density, degree/load imbalance,
full-cell coverage/replication, conditional child counts, and model-term
fixed-effect-equivalent rank increments remain separate outputs.

Seven tests and 69 expectations pass across complete p x r x i,
sparse-connected p x i, disconnected islands, nested Site/Rater, fully
replicated saturated p x i, missing-row/replay, nonnumeric-score, and rank-
capacity controls. The nested `Site` fixed-equivalent column is explicitly
labelled as absorbed by the `Site:Rater` hierarchy; it is not misreported as
proof that the random Site variance is unidentified. Conversely, full
fixed-equivalent rank is not proof of covariance-parameter identifiability.

`IncidenceScreenPassed` is therefore only a structural screen.
`EstimationEligibility` remains `not_adjudicated_draft83a`, and
`CoefficientEligible` and `DecisionReady` are always false. The
`gtheory_univariate_crossed_nested` checklist row remains `review`, not `ok`.
Draft.83b now supplies the planned allocation algebra described next;
Draft.83c1 now supplies the covariance/information and lme4 audit;
Draft.83c2 now supplies matched glmmTMB diagnostics; Draft.83d1 freezes the
recovery registry and denominators; Draft.83d2a now supplies deterministic
generation; Draft.83d2b0 now supplies scalable structural pre-fit
adjudication; Draft.83d2b1 now supplies atomic execution with a retained weak-
information concern; and later Draft.83d2 slices must calibrate that gate
before smoke recovery and zero-false-ready evidence.

### Draft.83b component-specific allocation operator

Draft.83b adds `gtheory-allocation-operator-contract-0.2.3.md`,
`gtheory-allocation-operator-prototype-0.2.3.R`, and its execution record. The
repository-only operator takes an explicit planned Scenario x prospective-
object Unit x random-facet support with positive weights summing to one. It
never derives a future plan from observed medians or normalizes weights
silently.

For component `C`, full-cell weights are marginalized to its typed `ScaleBy`
condition identities and transformed by `lambda_uC = sum_g a_uCg^2`.
Uniform crossed weights reduce exactly to `1/n_r`, `1/n_i`, and
`1/(n_r n_i)`. Nested Site/Rater support uses conditional child identities,
giving `1/2` for Site and `1/6` for Site:Rater in the frozen two-by-three
fixture without using the 12-cell Cartesian overcount as a denominator.

Unequal units keep separate component concentrations, effective counts, G, and
Phi. A scenario scalar is available only for identical full supports and
weights. Cross-unit `sum_g a_uCg a_vCg` records shared-condition covariance;
object-containing components retain a zero cross-object covariance multiplier.
Equal unit coefficients under disjoint Item support deliberately remain
scenario-ineligible.

Seven tests and 71 expectations pass across exact p x i / p x r x i Draft.81
reduction, nested conditional levels, unequal units, shared/disjoint support,
raw negatives, replay, and malformed/operator-capacity failures. Component
application remains `EstimationReady=FALSE`, `InferenceReady=FALSE`, and
`DecisionReady=FALSE`. The crossed/nested checklist row remains `review`.

Draft.83c1 supplies the lme4 half of that binding, described next. Draft.83c2
now adds the separately identified matched-glmmTMB route; Draft.83d1 freezes
the registry/denominator identity; Draft.83d2a supplies deterministic
generator identity; Draft.83d2b0 supplies scalable structural pre-fit identity;
Draft.83d2b1 executes atomic fits but fails its near-boundary false-ready gate;
and subsequent Draft.83d2 slices must calibrate weak information before fitted
components can enter a recovery pilot.

### Draft.83c1 covariance-design, expected-information, and lme4 audit

Draft.83c1 adds `gtheory-covariance-information-contract-0.2.3.md`,
`gtheory-covariance-information-audit-0.2.3.R`, and its execution record. For
each typed variance component it builds `K_c=Z_c Z_c'` on the exact Draft.83a
retained rows and audits the rank and right null space of the stacked
`vech(K_c)` covariance design. It then evaluates ML and REML expected
information separately at an explicit named variance point; REML uses the
intercept-residualizing `P` operator rather than assuming its rank matches ML.

The frozen saturated p x i negative control identifies the exact
Person:Item/Residual alias. A distinct one-Item control is structurally full
rank and ML-informative but loses the Item direction under REML. Sparse
connected and disconnected designs can both retain full covariance/information
rank, so Draft.83a connectivity remains an independent necessary gate. Nested
Site/Rater components use ancestry-qualified identities.

The lme4 route stores semantic `VarCorr()` identities, backend/version and
ML/REML identity, optimizer code, messages, gradient/Hessian availability,
`isSingular()`, fitted boundary states, default-control identity, backend
function hashes, and linked covariance/information hashes. A balanced interior
fixture passes the narrow point-estimation gate; a
finite optimizer-code-zero boundary fit remains `boundary_nonregular`. Eight
tests and 103 expectations pass.

`InferenceReady`, `CoefficientEligible`, and `DecisionReady` remain false.
Dense covariance matrices are capacity-guarded and remain a prototype
implementation. Draft.83c2 now supplies the matched backend comparison
described next. Draft.83d1 now supplies the pre-simulation registry described
after it; Draft.83d2a supplies its deterministic generation layer; and
Draft.83d2b0 supplies its exact scalable structural pre-fit layer. The
Draft.83d2b1 atomic execution layer is complete but retains a near-boundary
false-ready concern. Weak-information calibration, sampling recovery, and the
zero-false-ready gate therefore remain open.

### Draft.83c2 matched glmmTMB/lme4 point-estimation parity

Draft.83c2 adds `gtheory-glmmtmb-parity-contract-0.2.3.md`,
`gtheory-glmmtmb-parity-prototype-0.2.3.R`, and its execution record. The
glmmTMB route is restricted to the exact Draft.83c1 Gaussian identity-link,
intercept-only, independent scalar random-intercept, homogeneous-dispersion,
no-zero-inflation, retained-row, and ML/REML overlap. It records glmmTMB/TMB
versions, actual default controls and function hashes, semantic `VarCorr`
components, optimizer code/message/objective, gradient, `pdHess`, boundary
tolerance, and the common covariance/information identities.

Interior p x i ML/REML, p x r x i ML/REML, and nested Site/Rater fixtures match
components, intercept, and full Gaussian logLik under explicit smoke
tolerances. Backend grouping order such as Rater:Site maps back to typed
Site:Rater. The negative-component control is more informative: glmmTMB has
optimizer code zero and `pdHess=TRUE`, but Item is below the declared boundary
tolerance and its Person/Residual estimates and REML logLik materially differ
from lme4. Both fits remain nonregular and matched parity is false.

Eight tests and 93 expectations pass. These are deterministic point-estimation
overlap checks, not equivalence margins or estimator-selection evidence.
`InferenceReady`, `CoefficientEligible`, and `DecisionReady` remain false.
Draft.83d1 now freezes how recovery and exact false-ready rates must be
evaluated without pooling away backend-specific failures.

### Draft.83d1 G-theory ADEMP registry and denominator contract

Draft.83d1 adds `gtheory-ademp-registry-contract-0.2.3.md`,
`gtheory-ademp-registry-prototype-0.2.3.R`, and its record. It registers 24
covering scenarios across Person count, within-Person observations, raters,
criteria, score categories, assignment sparsity/topology, workload imbalance,
endpoint concentration, local dependence, anchor rate, missingness, and
variance regularity. Twenty metrics form 480 explicit scenario-metric routes,
and the executable one-replicate smoke manifest contains 89 paired fit units.

The registry does not assume one truth across incompatible stress families.
Continuous independent Gaussian cells retain generating component truth;
bounded ordinal cells target a complete finite-potential observed-score
projection; local-dependence cells report independence-reference deviation;
boundary/identification controls emphasize false readiness; and nonzero anchor
rates remain blocked because the current Gaussian random-intercept G-study has
no anchoring operation. Missingness mechanisms remain declared sensitivity
strata rather than empirically verified causal labels.

Person rank recovery, facet-level rank/RMSE, and a G-theory effect-recovery
ratio are kept separate. The last is explicitly not Rasch/FACETS separation.
Component, G, and Phi coverage remain unavailable until Draft.84 supplies a
validated interval. A backend standard error cannot fill that missing gate.

Result stages are monotone from planned through generated, pre-fit eligible,
fit attempted/returned, optimizer converged, finite components, and point-gate
passed. Fit-return and convergence rates use attempted fits; gate and false-
ready rates use planned units; bias/RMSE additionally require declared truth
and an available value; and every absent row remains unrecorded rather than a
typed failure. A four-row audit fixture proves false readiness and incomplete
accounting remain visible.

Nine tests and 77 expectations pass. `SimulationExecuted`,
`RecoveryEvidenceReady`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` remain false. Smoke replication one is a schema check only;
pilot/confirmation counts and precision criteria are not frozen. Draft.83d2a
implements the hashed generator, assignment/omission mechanisms, and
projection truth described next; Draft.83d2b0 then supplies structural pre-fit
adjudication. Draft.83d2b1 then executes method adapters and atomic attempt
rows, retaining a failed near-boundary false-ready result; later Draft.83d2 work
must calibrate weak information before effect extraction and recovery.

### Draft.83d2a deterministic G-theory ADEMP generation layer

Draft.83d2a adds `gtheory-ademp-generator-contract-0.2.3.md`,
`gtheory-ademp-generator-prototype-0.2.3.R`, and its record. The exact
Draft.83d1 registry now replays to 22 generated scenario identities and two
typed anchor blocks. Each generated identity binds separate complete-
potential, assigned, and post-missingness tables; nominal and, where
registered, complete finite-table observed-score projection truth; generated
level effects; realized assignment/missingness/score audits; eleven function
hashes; and one generator hash.

The assignment layer realizes every registered density and observation count
per Person, while connected-cycle sparsity and moderate/high hub workload
remain separate. Bounded 3/5/7-category cells retain endpoint rates
0.50/0.25/0 and target finite observed-score projection rather than latent
Gaussian variance. Exact 20% MCAR, observed-load MAR, score-MNAR, and unknown
omissions remain separate mechanisms. Residual AR(1) cells reproduce the
registered 0.25/0.50 perturbations; exact-zero and near-zero Rater variances
retain distinct generated effects.

The currently auditable nested cell is deliberately restricted to Person,
Site, Site:Rater, Criterion, and residual components. Interaction-rich nested
models remain pending because the present fixed-effect-equivalent rank screen
does not establish their covariance identification. The simplified nested
cell passes incidence audit, while disconnected Person/Rater islands and an
unreplicated saturated highest-order component fail as designed.

Ten tests and 185 expectations pass. The aggregate generator-smoke hash is
`1ed0856cc91ceb36115806dcf0f135ef7491d9e1ef53106276c0fd81584e0844`.
Only `GenerationEvidenceReady` becomes true for executable rows;
`EstimationReady`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` remain false. Draft.83d2b0, described next, attaches the
structural pre-fit audit to all 89 manifest units. Draft.83d2b1 must then
record one atomic backend result or typed failure for every unit. That execution
is now complete with the concern recorded below; later Draft.83d2 slices must
calibrate weak information before extracting centered effects and demonstrating
zero false readiness. Replication-count calibration and Draft.84 intervals
remain later gates.

### Draft.83d2b0 scalable G-theory ADEMP pre-fit layer

Draft.83d2b0 adds `gtheory-ademp-prefit-contract-0.2.3.md`,
`gtheory-ademp-prefit-prototype-0.2.3.R`, and its record. It binds every
Draft.83d2a analysis table to the Draft.83a observed-design audit, an exact
scalable covariance-component rank audit, and every corresponding Draft.83d1
manifest unit.

This slice corrects an important category distinction. Fixed-effect-equivalent
rank remains useful for saturated mean-design diagnostics, but it is not the
rank of the variance-component covariance design. For the registered
independent scalar random-intercept family, each covariance derivative is an
equality indicator. Exact supported equality signatures therefore preserve
the full covariance-design rank and null space without materializing
`vech(K_c)`. The 19,200-row N=300 cell is audited at rank 7/7; the dense seven-
component representation would require 1,290,307,200 design cells.

Nineteen scenarios and 77 fit units are structurally eligible with likelihood
information still pending. Three scenarios and 12 units are blocked:
`GT-SPARSE-CYCLE-LOW` and `GT-NEG-DISCONNECTED` confound `Person:Rater` with
Residual, while `GT-NEG-ALIASED` confounds the unreplicated
`Person:Rater:Criterion` component with Residual. Missing declared levels
restrict level-recovery metrics, and unknown missingness remains a sensitivity
label; neither is silently converted into a causal or full-metric claim.

Eight tests and 71 expectations pass. All manifest rows retain
`FitAttemptAuthorized=FALSE`, `AtomicResultRecorded=FALSE`,
`RecoveryEvidenceReady=FALSE`, `InferenceReady=FALSE`,
`CoefficientEligible=FALSE`, and `DecisionReady=FALSE`. Draft.83d2b1, recorded
next, freezes method-specific adapters and likelihood-information/regularity
rules and records an atomic success or typed failure for each of the 89 planned
units. Pre-fit-blocked units do not call a backend. This scalable proof does
not extend to random slopes, structured residuals, multivariate covariance, or
latent GPCM/GT-IRT likelihoods.

### Draft.83d2b1 atomic point-fit execution and retained concern

Draft.83d2b1 adds `gtheory-ademp-fit-contract-0.2.3.md`,
`gtheory-ademp-fit-prototype-0.2.3.R`, and its record. All 89 manifest units
now receive one atomic success or typed failure. The 12 Draft.83d2b0 blocks
never call a backend; all 77 eligible balanced-MoM/lme4/glmmTMB attempts
return. Fifty-seven point gates pass and 32 failures are typed as pre-fit,
regularity, or local-curvature failures. The execution hash reproduces in two
fresh R processes and exact accounting passes.

This slice separates backend-local curvature from full expected information.
lme4 uses its profiled `theta` Hessian, glmmTMB uses the inverse of its fixed-
parameter covariance, and MoM records nonlikelihood equation completion. None
is relabelled as the complete Draft.83c1 expected-information matrix. Negative
raw MoM components also remain raw rather than being clipped.

The negative-control gate does not pass. Exact-zero, disconnected, and aliased
controls yield zero passed point gates, but all four near-zero variance routes
pass: their fitted Rater variances are about 0.0039--0.0052 although the
nominal generator variance is `1e-10`. Optimizer completion, finite components,
an absolute `1e-8` boundary tolerance, and positive local curvature therefore
do not constitute an adequate weak-information screen. The runner retains
`ZeroFalseReadyPassed=FALSE` and all recovery/inference/readiness flags false.

The next Draft.83d2 slice must pre-register an observable weak-information
calibration before effect extraction. It must include zero, near-zero, small-
positive, and ordinary-positive controls and vary component level count,
observations per level, sparse topology, and workload imbalance. A truth-aware
gate or post hoc increase of the boundary tolerance is prohibited. Only after
false-positive/false-negative behavior is calibrated may centered-effect and
G/Phi recovery enter a feasibility pilot.

### Draft.83d2b2a weak-information diagnostic covering smoke

Draft.83d2b2a adds
`gtheory-weak-information-calibration-contract-0.2.3.md`,
`gtheory-weak-information-calibration-prototype-0.2.3.R`, and its record. The
registry crosses five information/design strata with exact-zero, numerical-
near-zero, two small-positive, moderate-positive, and ordinary-positive Rater
variance regions, then evaluates lme4 and glmmTMB under ML and REML. All 120
one-replicate units are attempted, returned, restored to canonical manifest
order, and atomically accounted.

The covering result rejects the previous whole-model point gate as a target-
component resolution rule. It passes 82/120 units, including 27/40 registered
zero or near-zero negative controls. It also blocks 3/12 deliberately narrow
positive controls, all in the high-information variance-0.04 cell. The latter
failure can be caused by another component's boundary or whole-model curvature,
which is precisely why target weakness and nuisance fit failure must not be
collapsed into one bit.

Ten application-time observables are implemented without reading generating
truth: component estimate/fractions, level and exposure descriptors, boundary
and curvature state, and matched backend and ML/REML contrasts. A reduced-
component likelihood comparison is registered but not implemented because its
boundary null requires a separate calibration contract; full-refit component
intervals remain Draft.84 work. `ThresholdFrozen`,
`CalibrationEvidenceReady`, `ConfirmationAuthorized`,
`RecoveryEvidenceReady`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` remain false.

Draft.83d2b2b is therefore a replicated feasibility pilot rather than a
threshold application. It must freeze replication counts and Monte Carlo
precision, preserve paired seeds, compare a small prespecified rule set by
design stratum, and define an indeterminate region and failure behavior before
untouched confirmation seeds exist. It may not derive a universal minimum
number of Raters or observations per Rater from this one-replicate smoke.

### Draft.83d2b2b0 replicated pilot plan and authorization firewall

Draft.83d2b2b0 adds `gtheory-weak-information-pilot-contract-0.2.3.md`,
`gtheory-weak-information-pilot-prototype-0.2.3.R`, and its record. The
independent Monte Carlo unit is one scenario-by-replicate dataset. lme4 and
glmmTMB ML/REML routes share it and are paired observations, not four
independent replications.

Four nonoverlapping replicate bands are frozen. Schema uses IDs 2--3 over
three baseline controls (24 fits); feasibility uses 101--125 over all 30 cells
(3,000 fits); calibration uses 201--300 (12,000 fits); and confirmation uses
501--700 (24,000 fits). Worst-case cell-by-method Bernoulli MCSE is 0.10 for
feasibility, 0.05 for calibration, and about 0.035 for confirmation. Primary
error rates remain scenario- and method-specific; pooling topology, level
count, exposure, or method to manufacture precision is prohibited.

The 24-fit schema execution passes atomic accounting and returns all fits. It
is already viewed and therefore cannot enter pilot denominators. Feasibility
is authorized but unrun. Calibration and confirmation manifests are auditable
metadata, while their execution fails closed. Confirmation remains sealed
until a selected rule, both cutpoints, the indeterminate zone, failure
behavior, backend scope, and source hashes are frozen.

Four candidate architectures use target fraction, target-to-residual ratio,
backend-specific relative uncertainty, or same-backend full-versus-reduced
likelihood drop. lme4 profiled relative-SD curvature and glmmTMB joint log-SD
covariance retain distinct labels; neither becomes a generic component SE.
The likelihood drop receives no ordinary chi-square p-value under the boundary
null. `ThresholdFrozen`, `CalibrationEvidenceReady`,
`ConfirmationAuthorized`, `ConfirmationViewed`, `RecoveryEvidenceReady`,
`InferenceReady`, `CoefficientEligible`, and `DecisionReady` remain false.

The subsequent source audit supersedes that feasibility authorization before
any seed in 101--125 is generated. The historical b2b0 identities remain an
immutable planning record, but their execution permission is no longer the
active contract.

### Draft.83d2b2b1a source-audited boundary diagnostic refits

Draft.83d2b2b1a adds
`gtheory-weak-information-inference-audit-0.2.3.md`,
`gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R`, and its
record. Self and Liang's boundary asymptotics, Crainiceanu and Ruppert's exact
one-component LMM result, Greven et al.'s finite-sample extensions, and current
lme4/glmmTMB/RLRsim contracts are mapped to the registered six-random-
component model.

The audit withdraws `target_relative_se_profiled` and both candidate rule
families that require it. lme4 supplies a profiled relative-SD coordinate;
when its profiled criterion Hessian is finite positive definite, the validation
runner records the local scale `sqrt(2 * diag(H^-1))`. glmmTMB supplies a joint
log-SD coordinate and covariance, whose doubled local scale is only a first-
order relative-variance diagnostic. These coordinates are neither common
component standard errors nor valid boundary Wald tests.

The already viewed schema is refitted as 24 full/reduced pairs, or 48 backend
fits. All pairs return with identical retained-row counts and one likelihood-
df difference. Raw ML LRT and REML RLRT differences are available for all 24;
four glmmTMB values between approximately -3.6e-7 and -5.7e-7 remain untruncated
inside a -1e-6 numerical tolerance. Twenty backend-coordinate local diagnostics
are available. Four lme4 target-boundary fits have no profiled Hessian and
remain explicitly unavailable. No chi-square law, universal mixture law,
p-value, interval, or resolved state is assigned.

The exact-zero schema rows can have positive target estimates and nonzero
likelihood drops, while positive-reference rows can reach a target boundary.
This is schema evidence that point positivity, zero-null separation, local
coordinate computability, positive-component recovery, and D-study stability
are distinct. It is not an operating-characteristic estimate.

The next slice must register a custom parametric bootstrap under the fitted
reduced model on the exact observed incidence pattern. Its unit, bootstrap
draw count, Monte Carlo uncertainty, optimizer/failure denominator, nuisance-
boundary handling, and ML/REML/backend scope must be frozen before a small
viewed bootstrap schema is run. Only a later replacement identity may
reauthorize the 25-replicate feasibility phase. `FeasibilityEvidenceReady`,
`CalibrationEvidenceReady`, `ThresholdFrozen`, `ConfirmationAuthorized`,
`InferenceReady`, `CoefficientEligible`, and `DecisionReady` remain false.

### Draft.83d2b2b1b exact-design bootstrap mechanics

Draft.83d2b2b1b adds
`gtheory-weak-information-bootstrap-contract-0.2.3.md`,
`gtheory-weak-information-bootstrap-prototype-0.2.3.R`, and its record. It
separates the 3,000-row resolution-score feasibility computation, fitted-null
bootstrap mechanics, and independent outer calibration of test operating
characteristics. Only the middle layer is executed.

For the three already viewed baseline controls at outer replicate 2, all four
lme4/glmmTMB ML/REML routes fit observed full/reduced models. Each reduced fit
generates `B=3` backend-native unconditional responses while preserving exact
rows, order, factor levels, incidence, missingness, fixed-effect design, and
non-target random terms. The 12 observed plus 36 bootstrap pairs require 96
backend fits. All pairs return; 36/36 design checks and distinct generated-
data identities pass; 16 small negative raw likelihood differences remain
untruncated; and no difference is below the frozen -1e-6 tolerance.

Every planned bootstrap draw remains in the denominator. If `E` available
draws exceed the observed raw statistic and `F` draws fail, the recorded
computational bounds are `(1+E)/(B+1)` and `(1+E+F)/(B+1)`. A point value is
formed only when `F=0`. Simulation/identity and refit failures remain distinct,
and a response hash survives a later refit failure. The schema has no failures,
but eight of 36 bootstrap pairs have at least one non-target component at the
1e-8 boundary tolerance.

This is a plain plug-in parametric bootstrap, not a finite-sample exact test
and not the separately published shrinked parametric-bootstrap procedure for
nuisance boundary components. Its `B=3` grid width is 0.25. The 12 values
cannot estimate size, power, a production `B`, a threshold, or backend
superiority. A naive 30-cell x 25-outer-replicate x four-method plan with
`B=199` would require 1,200,000 fits and is not authorized.

The next slice must freeze the replacement no-inner-bootstrap 3,000-row
resolution-feasibility manifest, measure route/boundary runtimes, and design a
tractable outer operating-characteristic study with an explicit nuisance-
boundary method choice. `ResolutionFeasibilityAuthorized`,
`BootstrapOperatingCharacteristicsReady`, `FeasibilityEvidenceReady`,
`CalibrationEvidenceReady`, `ThresholdFrozen`, `ConfirmationAuthorized`,
`InferenceReady`, `CoefficientEligible`, and `DecisionReady` remain false.

### Draft.83d2b2b1c replacement feasibility and runtime authorization

Draft.83d2b2b1c adds
`gtheory-weak-information-feasibility-contract-0.2.3.md`,
`gtheory-weak-information-feasibility-prototype-0.2.3.R`, and its record. It
rebinds the never-generated replicate-101--125 band to a new 3,000-row,
750-independent-dataset, 6,000-full/reduced-fit manifest. Manifest construction
does not call the generator, pre-fit layer, or a backend. Each generated
dataset will be shared by exactly four method routes, and every scenario x
method cell retains 25 independent replicates.

Runtime is measured on all 30 already viewed replicate-1 design x variance
cells and four methods. All 120 full/reduced pairs return, but only 111 common
feasibility scores are available. Six rows have a raw likelihood difference
below -1e-6; four rows fail optimizer/likelihood availability; one row belongs
to both groups. Eighteen available small negative values remain untruncated,
22 target-boundary rows and eight nuisance-boundary rows remain explicit. All
eight nuisance boundaries occur in the one viewed few-level design, which is
not a claim that other designs are free of that risk.

The timing-excluded execution and authorization hashes reproduce. Two serial
central projections are approximately 32.6--33.0 minutes; x4 sensitivity is
about 2.2 hours. Timing varies across runs and is excluded from scientific
identity, estimator comparison, and performance guarantees. The full/reduced
method pair is the atomic checkpoint unit; a dataset is complete only after
four method rows; stale or partial identity mismatches are recomputed or
rejected.

All eight narrow authorization gates pass. The separate authorization record
sets `ResolutionFeasibilityAuthorized=TRUE` for the exact frozen manifest.
The contract and runtime objects cannot self-authorize and retain that flag as
false. The coming run may report only scenario x method score availability,
raw distributions, optimizer/boundary/material-negative frequencies, and
exact failure accounting. It cannot select a threshold, run an inner
bootstrap, stop early, calibrate size/power, or support a D-study decision.
`FeasibilityEvidenceReady`, `BootstrapOperatingCharacteristicsReady`,
`CalibrationEvidenceReady`, `ThresholdFrozen`, `ConfirmationAuthorized`,
`InferenceReady`, `CoefficientEligible`, and `DecisionReady` remain false.

### Draft.83d2b2b1d atomic feasibility execution

Draft.83d2b2b1d adds
`gtheory-weak-information-feasibility-runner-contract-0.2.3.md`,
`gtheory-weak-information-feasibility-runner-0.2.3.R`, its execution record,
and an explicit full validation tier. Each full/reduced method pair is written
atomically, and a dataset marker is valid only after the four expected route
hashes validate. Timing, execution order, filesystem location, and checkpoint
reuse are excluded from the scientific identity.

All 3,000 pairs and 750 datasets are present. All pairs return, but common
scores are available for 2,804 rows. Seventy-nine rows fail the registered
optimizer/likelihood-identity condition, 126 have a finite raw likelihood
difference below -1e-6, and nine belong to both groups. Seven further raw
differences are non-finite and already in the failure set; they are not signed
material-negative values. The 759 available small negative values remain
untruncated. A full resume performs zero route computations,
reuses all 3,000 checkpoints, and reproduces execution hash
`04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b`.

The descriptive result is heterogeneous. High-information availability is
457/600 because 101 routes have materially negative likelihood differences.
The few-level design has 283/600 nuisance-boundary routes and Spearman
ordering of only about 0.14--0.26, despite 576/600 common-score availability.
At generating Rater variance 0.0025, 228/500 routes reach the target boundary,
compared with 202/500 at exact zero. Boundary attainment is therefore not a
monotone component-resolution rule.

`FeasibilityEvidenceReady=TRUE` records complete descriptive accounting only.
Before untouched calibration replicates 201--300 can be generated, a new
contract must freeze (a) a numerical-likelihood sensitivity for the already
viewed high-information routes and (b) separate plain versus prespecified
nuisance-boundary bootstrap operating-characteristic lanes. Scenario x method
availability, size, power, Monte Carlo uncertainty, positive-component
bias/RMSE/coverage, and D-study stability cannot be pooled. Threshold,
calibration, confirmation, inference, coefficient, and decision readiness
remain false.

### Draft.83d2b2b1e numerical-likelihood sensitivity

Draft.83d2b2b1e adds a source-grounded optimizer sensitivity contract, atomic
runner, execution record, and explicit 18,000-fit test tier. The 3,000 viewed
feasibility routes are each re-fitted under default, strict same-algorithm, and
different-algorithm profiles for 9,000 full/reduced pairs. All route and
dataset identities validate, and a full resume reuses every checkpoint and
reproduces execution hash
`37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94`.

The same-algorithm strict profiles reproduce all full and reduced objectives
exactly. lme4 bobyqa returns 1,500/1,500 available comparisons, removes all 34
finite default-lme4 material-negative differences, and attains the highest
recorded full and reduced objective in 1,495 routes. glmmTMB BFGS is not a
parallel remedy: only 1,169/1,500 differences are finite, 401 are materially
negative, and 331 are non-finite. Across backends, 433 route signs are
optimizer-sensitive, 334 are incomplete, and 30 remain material-negative
under every profile. The separately maximized envelope remains below -1e-6
on 69 routes.

All 2,993 finite default differences exactly replay b1d. Seven old and new
default values are both non-finite, but the frozen rule defined replay only as
a finite absolute difference no greater than 1e-10. The rule is not relaxed
after viewing. `DefaultReplayPassed=FALSE` and
`NumericalSensitivityEvidenceReady=FALSE`; all calibration, bootstrap-
operating-characteristic, threshold, confirmation, inference, coefficient,
and decision flags remain false. A successor must prospectively type same-
non-finite replay and add a backend-specific glmmTMB stabilization lane before
replicates 201--300 can be generated.

### Draft.83d2b2b1f typed numerical replay

Draft.83d2b2b1f prospectively defines five mutually exclusive replay states
and applies them only to the immutable b1d and b1e atomic ledgers. It performs
no generation, fitting, optimization, bootstrap, calibration, or D-study.
All 2,993 finite default values match within 1e-10. The other seven values are
`NA_real_` in both ledgers and agree on pair return, likelihood availability,
within-tolerance flag, and comparison state. There are zero finite,
non-finite-state, or finite/non-finite mismatches, and no non-finite row is
promoted to an available comparison.

`TypedReplayAdjudicationReady=TRUE` closes only the missing b1e state
definition under a new identity. The immutable b1e
`DefaultReplayPassed=FALSE`, `NumericalStabilizationReady=FALSE`, and
`NumericalSensitivityEvidenceReady=FALSE` remain controlling. The next
prospective glmmTMB stabilization lane must separately bind named start
parameter blocks, cold and current-optimum restarts, scaled/unscaled gradient
diagnostics, Hessian diagnostics, and alternative algorithms, with all failed
rows retained. It may not select a start rule, optimizer, or objective-spread
threshold from the viewed successful subset.

### Draft.83d2b2b1g glmmTMB stabilization design

Draft.83d2b2b1g converts the preceding requirement into a prospective,
machine-validated design without authorizing a fit. The 1,500 viewed b1e
glmmTMB routes expand to six profiles: cold nlminb and BFGS roots, a
same-algorithm restart from each root, and a cross-algorithm warm start from
each root. This symmetric DAG has 9,000 full/reduced pairs, 18,000 planned
fits, 3,000 cold-root pairs, 6,000 dependent pairs, and no missing parents or
duplicate route identities.

Warm starts bind all ten public glmmTMB parameter blocks in canonical order,
including zero-length blocks and conditional random-effect modes. They may
move only from parent full to child full or parent reduced to child reduced on
the same route. Parent failure produces a typed dependent failure and cannot
fall back to a cold fit. Each returned fit must retain optimizer identity,
outer and sdreport gradients, `pdHess`, inverse-covariance diagnostics, and a
frozen Richardson gradient-Jacobian eigenspectrum. `diagnose()` is
supplementary and cannot define eligibility.

Five tests and 73 expectations establish the DAG, start signature, manifest,
and fail-closed upstream identities. `ManifestReady=TRUE`, but
`StabilizationRunnerImplemented=FALSE`,
`StabilizationExecutionAuthorized=FALSE`,
`NumericalStabilizationReady=FALSE`, and
`NumericalSensitivityEvidenceReady=FALSE`. The next slice must implement
atomic checkpoints, parent-start equality, derivative hashes, interruption/
resume, and a small viewed-data covering smoke before a separate execution
authorization is considered.

### Draft.83d2b2b1g1 stabilization runner and covering smoke

Draft.83d2b2b1g1 implements one six-profile base route as the atomic unit and
authorizes only replicate 101, all five designs, exact-zero/reference-positive
variance, and ML/REML. The resulting 10 datasets, 20 base routes, 120 pairs,
and 240 planned fits are selected without reading a numerical result. All 20
route checkpoints and ten dataset markers validate; a second execution reuses
all 20 checkpoints and reproduces every atomic row and scientific hash.

The complete state partition is 84 diagnostic-complete, 21 finite material-
negative, 11 non-finite objective/likelihood, two parent-unavailable, one full
failure, and one reduced failure. All returned snapshots have exact fixed-
coordinate equality, and all returned dependent fits have matching parent
final/child input hashes. The four failure rows originate in two BFGS fits
whose backend returns but whose immediate `last.par.best` fixed coordinates
are not bitwise equal to `fit$fit$par`; their dependent consequences remain in
the denominator.

A viewed diagnostic measures one mismatch at about 2.80e-10 and finds no
change after objective re-evaluation. This value cannot become a post hoc
tolerance. The mathematically cleaner successor is a prospective operation
that hashes the original joint state, deterministically replaces its fixed
coordinates with the reported top-level vector, and separately records the
pre-alignment discrepancy. It requires negative controls and a new identity.

`SmokeRunnerMechanicsReady=TRUE`, but `FullExecutionAuthorized=FALSE`,
`NumericalStabilizationReady=FALSE`, and
`NumericalSensitivityEvidenceReady=FALSE`. The smoke cannot choose an
optimizer/start rule or authorize calibration, inference, or D-study output.

### Draft.83d2b2b1g2 deterministic alignment replay

Draft.83d2b2b1g2 replaces no optimizer and adopts no observed tolerance. For
every returned fit it hashes the immediate raw joint state, deterministically
sets only `aligned_joint[lfixed()] <- fit$fit$par`, requires bitwise equality,
and passes the aligned joint state explicitly to `parList`. Random-mode
coordinates are unchanged. The rule is applied uniformly even where the raw
fixed coordinates already agree.

The exact b1g1 120-row denominator is re-executed under a new contract and
checkpoint root. All 240 fits return, all align exactly, all 80 dependent
transfers verify, and a no-fit resume reuses all 20 base routes. Four pair
returns are recovered and none is lost. Across the 117 common full and 119
common reduced returns, top-level parameter hashes, objectives, and log
likelihoods have zero mismatch. The one typed likelihood-drop difference is
the recovered finite value from the formerly unavailable reduced snapshot.

This closes only start-state transport. Fourteen non-finite
objective/likelihood states, 21 finite material-negative drops, maximum outer
gradients near 0.028/0.017, and negative Richardson relative eigenvalues
remain. Therefore `AlignmentMechanicsReady=TRUE`, but
`FullExecutionAuthorized=FALSE`, `NumericalStabilizationReady=FALSE`, and all
calibration, inference, coefficient, and D-study gates remain false. The next
slice must prospectively adjudicate likelihood, gradient, and curvature
evidence before it can reconsider the full 18,000-fit run.

### Draft.83d2b2b1g3 no-refit numerical adjudication

Draft.83d2b2b1g3 replaces the precedence-based smoke label with parallel
numerical axes without changing or refitting a model. The installed
`logLik.glmmTMB` implementation is part of identity: it returns the negative
raw objective only for `pdHess=TRUE`, and otherwise returns `NA`. Therefore all
120 finite raw full/reduced objectives coexist with only 106 pairwise reported
likelihood differences; the other 14 are exactly curvature-masked, not
unexplained nonfinite objectives.

Optimizer termination is also independent: 119 pairs have two code-zero fits,
while one full fit has code 1 beneath the earlier nonfinite primary state.
Sdreport and Richardson PD signs agree for all fits, giving 106 both-PD, seven
full-only, five reduced-only, and two neither-PD pairs. Both gradient surfaces
are available throughout, but their hashes disagree for one full and one
reduced fit at the same two b1g2 raw/aligned state discrepancies. Raw unscaled
gradient magnitudes cannot define stationarity.

The objective-based finite trace partition is 75 positive, 22 small negative,
and 23 material negative. Independently taking the best observed full and
reduced objective across the frozen six profiles yields 12 positive and eight
small-negative route envelopes and no material-negative envelope. This is
best-observed search evidence, not an attained global maximum, optimizer
selection, or LRT. The exact-zero reduced variance lies in the closure rather
than at a finite full log-SD coordinate.

`AdjudicationSchemaReady=TRUE` and
`ObjectiveLikelihoodSeparationReady=TRUE`, but
`StationarityCriterionReady=FALSE`,
`NumericalEligibilitySufficientRuleFrozen=FALSE`, and
`FullExecutionAuthorized=FALSE`. The next prospective slice must retain raw
gradient vectors plus parameter/objective scales and define scale-aware
stationarity summaries before fitting. It must not derive a cutoff from the
observed 0.028/0.017 maxima.

### Draft.83d2b2b1g4 scale-aware stationarity instrumentation

Draft.83d2b2b1g4 executes that prospectively frozen measurement layer on the
unchanged 120-pair denominator. Each of 240 returned fits retains a hashed
sidecar containing the named top-level parameter vector, raw TMB outer
gradient, sdreport fixed gradient, raw and symmetric Richardson matrices,
eigenvalues, and all derived vectors. Existing b1g2 parameter hashes,
objectives, reported likelihoods, and raw nested drops have zero mismatches;
the repeated outer-gradient and Richardson hashes also agree for every fit.
All 20 base routes resume without fitting and reproduce execution
`a825ab427da7e4a8160e428a7a6b00038f364b1c15049df6d5e4bf03bbbbbade`.

The new schema deliberately separates coordinate meanings. Raw and
objective/parameter-relative gradients are available for all 240 fits.
Richardson eigenvalues are positive for 224 fits, but Cholesky factors are
numerically available for 221, so spectral positivity cannot stand in for
factorability. lme4-compatible `solve(chol(H), g)` and Newton-whitened
`solve(t(chol(H)), g)` vectors are both available for those 221 but are not the
same statistic. A direct relative Newton step is available for only 218 fits.
The two b1g3 outer/sdreport hash disagreements are now quantified as maximum
absolute differences about `2.16e-7` and `2.09e-8` rather than classified by a
tolerance.

Across 40 route/model strata, the profile with the smallest raw gradient
matches the best observed objective only 18 times; corresponding counts are
18 for the objective-relative metric, 26 for the lme4-compatible metric, 29
for Newton decrement, and 27 for the relative Newton step. This is evidence
against selecting an optimizer by one gradient summary, not evidence for a
preferred alternative.

`ScaleAwareMeasurementSchemaReady=TRUE` and raw derivative retention is
ready, but `StationarityCriterionReady=FALSE`,
`NumericalEligibilitySufficientRuleFrozen=FALSE`, and
`FullExecutionAuthorized=FALSE`. The next slice must specify a calibration
design with independent high-accuracy reference states and both false-ready
and false-unready targets. It must prespecify handling for non-PD,
Cholesky-unavailable, boundary, and direct-step-unavailable fits and may not
tune a cutoff from these 240 viewed fits.

### Draft.83d2b2b1g5 independent stationarity-calibration design

Draft.83d2b2b1g5 completes that design prerequisite without generating a
reserved dataset. It separates finite first-order stationarity, second-order
curvature/factorability, profiled log-SD boundary limits, and statistical
target-component resolution. Simulation generating truth labels only the last
of these; it cannot certify numerical stationarity.

The eight-stage high-accuracy reference architecture retains objective,
automatic and Richardson derivatives, deterministic multistart solver
envelopes, damped-Newton polishing, Hessian inertia, and nuisance-reoptimized
boundary profiles. Disagreement is `reference_unresolved`, not a majority-vote
success. Analytic affine fixtures verify congruence preservation of Hessian
inertia and invariance of Newton decrement while exposing coordinate
dependence of raw, objective-relative, lme4-compatible, and relative-step
summaries.

The sealed workload has 3,000 independent datasets, 12,000 paired-method base
units, 144,000 prospective candidate fits, and 24,000 reference problems.
`DesignSchemaReady`, `CandidateArchitectureFrozen`,
`ReferenceArchitectureFrozen`, and `CoordinateAuditReady` are true.
`ReferenceToleranceFrozen`, `StationarityCriterionReady`, numerical
calibration execution, full execution, bootstrap, inference, and D-study
readiness remain false at this design stage. Draft.83d2b2b1g6 is the ordered
analytic and nonreserved reference gate before replicate 201 may be generated.

### Draft.83d2b2b1g6 high-accuracy reference calibration

Draft.83d2b2b1g6 completes that narrow reference gate without opening any
reserved seed. The first diagnostic replay exposed why a single
`epsilon^(2/3)` derivative tolerance is insufficient for a composed Laplace
objective near 2,200: ordinary Richardson differencing amplified objective-
scale cancellation and disagreed with AD by `1.9e-6` to `1.17e-5`. Those
viewed discrepancies were not adopted as a cutoff.

The corrected contract chooses a central-difference interval without
consulting AD. It scans `epsilon^(1/3) * 2^(-4:8)`, minimizes adjacent-step
instability, retains a componentwise roundoff/truncation resolution envelope,
and requires the AD difference to fall within that independently constructed
envelope. TMB's `last.par.best` random-effect start is reset to one hashed
anchor before every evaluation, so call order cannot change the audited
surface. An adversarial analytic gradient error changes only the comparison
result, not the selected step or finite-difference table.

All six analytic fixtures recover their intended numerical states. On
nonreserved baseline-complete replicates 901--902, all four full/reduced
glmmTMB REML objectives resolve as finite local minima and pass nlminb/BFGS/
Nelder--Mead objective consensus, adaptive derivative agreement, Hessian
symmetry, positive-definite curvature, and content-addressed sidecar checks.
Both full-model profiles support a finite interior; all twelve fixed-log-SD
points pass free-coordinate curvature and Newton-decrement checks after
nuisance polishing.

Contract `60e04706736c0e7273dfa321d0d41a3a9ed4bb8362a0b7d428f8507653ecce9a`,
manifest `87b42667d3dbeb2ecd045b23b32cf23a5f9919b0d26ac75c5771baf691770d3a`,
and execution `28f155c91065cb56ebe695234eab7867392e25fe413ab362717e760f5e775e72`
reproduce. `NonreservedReplayReady=TRUE` and the narrow
`ReferenceToleranceFrozen=TRUE`; `StationarityThresholdFrozen`,
`StationarityCriterionReady`, reserved calibration, full stabilization,
bootstrap operating characteristics, inference, coefficients, and D-study
decisions remain false or unauthorized. Draft.83d2b2b1g7 next audits whether
the prerequisites for an authorization identity actually exist.

### Draft.83d2b2b1g7 stationarity-calibration preauthorization audit

Draft.83d2b2b1g7 completes a fail-closed audit without opening any reserved
seed. The b1g5 historical manifest assigned six profiles to all four method
lanes. The operative registries contain six glmmTMB profiles and three lme4
profiles, so the prospective candidate-fit upper bound is 108,000 rather than
144,000. The 3,000 datasets, 12,000 dataset-method units, and 24,000 reference
problems are unchanged. b1g5 remains immutable; future execution must bind the
new corrected manifest.

The audit freezes profile aggregation within one dataset-method-model-role
ledger as minimum returned finite objective plus fixed exact-tie priority.
Neither a stationarity metric nor generating truth may select a profile. It
also freezes a typed boundary/first-order/curvature state algebra: only a
stationary-zone score with factorable positive-definite curvature is
numerically eligible; spectral positivity without factorability and near-
singular curvature are indeterminate.

Contract `b293987e768ec0e998d3224a6df0689f0ab8b6f2268704ef422e333865d82765`
and corrected manifest
`7cce9d42faccfbbdf928c9ec4978fef25c50aa562750141fbab45a53b75885f8`
reproduce. Five focused tests and 71 expectations pass. The b1g6 receipt
covers only glmmTMB REML: glmmTMB ML has no nonreserved replay, and lme4
ML/REML lack likelihood-faithful high-accuracy reference mechanics. The
production boundary probe, acceptance policy, and exact-resume runner are
also absent. `PreauthorizationAuditReady=TRUE` therefore coexists with
`CalibrationAuthorizationReady=FALSE`, `CalibrationExecutionAuthorized=FALSE`,
and every downstream inferential/decision flag false. The next gate is
nonreserved method-coverage work, not replicate 201; b1g8 completes the
glmmTMB ML half of that remaining work.

### Draft.83d2b2b1g8 glmmTMB ML reference coverage

Draft.83d2b2b1g8 leaves the b1g6 REML identity unchanged and binds a distinct
glmmTMB ML surface through `MethodId="glmmTMB_ml"`, `Likelihood="ML"`, and
`REML=FALSE` at contract, manifest, row, and sidecar levels. The same
nonreserved generator hashes for replicates 901--902 are used, but all four
polished objectives differ from REML by more than `1e-3`; the likelihood mode
is therefore not a cosmetic label. Absolute ML and REML objectives are not
used to choose an estimator.

All four full/reduced ML objectives resolve as finite local minima and pass
three-algorithm consensus, AD-independent adaptive differences, Hessian
symmetry, and positive curvature. Both six-point full-model profiles support
finite interiors and all twelve nuisance fits pass stationarity. A second
complete execution reproduces atomic rows, sidecar hashes, and execution hash
exactly.

Contract `1216ae3591fc026a61b4fb6581ebe79e33d34e4e2b6bf04a969a4c93c3e06689`,
manifest `2974db4aefd07636d286b8227edb6dd50b481764e9dd7060296bd379a2688434`,
and execution `46ea4be751a3c54904bac28da31f15e5e05f347b9e8f10a1194887f55557807d`
reproduce. Six focused tests and 64 expectations pass. glmmTMB ML and REML
reference mechanics are now ready, but lme4 ML/REML remain unimplemented.
`ReferenceMethodCoverageComplete`, calibration authorization, production
stationarity, confirmation, inference, coefficients, and D-study decisions
remain false. The ordered next gate is likelihood-faithful lme4 reference
construction and nonreserved validation; b1g9 below completes only its
objective-identity prerequisite.

### Draft.83d2b2b1g9 lme4 objective-reference preflight

Draft.83d2b2b1g9 completes the algebraic prerequisite to that lme4 work
without reading nonreserved or reserved responses. For zero-offset, unweighted
independent random intercepts it constructs an independent dense Gaussian
oracle in lme4's relative-SD theta coordinates. The oracle profiles fixed
effects and residual scale, evaluates both the ML deviance and REML criterion, and supplies
closed-form gradients. Both objectives agree with
`lmer(..., devFunOnly=TRUE)` at about `1e-12`; analytic and Richardson
gradients agree within `5e-9`; selected fitted criteria agree with independent
objectives and `-2*logLik`; and exact-zero full-to-reduced identities hold in
both modes.

The installed lme4 2.0.6 implementation is part of the contract identity.
`devfun2()` source forces `refitML()` and fails its own local basedev/optimum
reproduction control. `deviance.merMod(..., REML=TRUE)` routes to an ML
criterion and differs from `REMLcrit()`. Both routes are source-hash-bound
negative controls, not eligible accessors. Audit
`83faaaf570bd814c000924aa21396ade00958fb8134cec553a0eaa985382ca67` and
contract `20d6fb656ac2f2996e5881a07729a3e4fb2f417859f90efde7ee72784ba62092`
reproduce in seven tests with 67 expectations.

`Lme4ObjectivePreflightReady=TRUE` does not advance the two-of-four method
coverage count. The likelihood-preserving box solver, nuisance-reoptimized
boundary profile, nonreserved lme4 ML/REML replay, acceptance policy,
production runner, calibration, confirmation, inference, and D-study
decisions remain false or unauthorized.

### Draft.83d2b2b1g10 lme4 ML/REML reference coverage

Draft.83d2b2b1g10 completes the two remaining nonreserved reference lanes.
The reference variable remains nonnegative relative-SD theta; ML and REML
retain distinct closures and accessors. Nine main fits per objective combine
three deterministic starts with `nlminb`, `L-BFGS-B`, and `bobyqa`.

The initial fail-closed replay exposed insufficient derivative and profile
resolution. No viewed discrepancy became a cutoff. Instead, the b1g9 dense
algebra was reconstructed with sparse Cholesky solves at n=1600, giving an
independent analytic objective and gradient. Analytic-gradient Newton polish
then reduced final maximum gradients below `8.1e-11`, so the final contract
requires raw KKT rather than relying only on the separately retained Newton-
decrement state.

All eight full/reduced objectives pass consensus, sparse-oracle objective and
gradient agreement, adaptive differences, raw KKT, Newton decrement, positive
free curvature, and sidecar integrity. All four seven-point theta profiles
pass nuisance gates, rise monotonically toward zero, and match separately
optimized reduced objectives within `2.3e-11`. Contract
`419fbf43fd1b86ab494aa96224916c0bfa9c1e1ef2668f8877d9d39659bcc7e0`,
manifest `f26d4a2fe5670d9b9395f97669f0ef368f9c5067580394ff5b20acccf5e8580b`,
and execution `b84c1d53f8653bb5329a0a165e2249b36e5d12e10c26099ab15cbdfac4281e8a`
reproduce exactly in nine tests with 137 expectations.

`ReferenceMethodCoverageComplete=TRUE` now means exactly four of four
prespecified backend-likelihood lanes. It does not rank estimators or authorize
calibration. The acceptance/indeterminate policy, production boundary probe,
exact-resume runner, reserved calibration, confirmation, inference, and
D-study decisions remain false or unauthorized.

### Draft.83d2b2b1g11 truth-blind acceptance-policy freeze

The 24-candidate primary grid crosses three eligible score families with the
eight previously registered zones. The policy binds all four nonreserved
reference receipts, preserves scenario x method x model-role rate denominators,
and distinguishes safety false ready, false boundary handoff, false unready,
missed boundary, indeterminate, not-evaluable, and reference-unresolved states.
One-sided 95% Clopper--Pearson upper bounds remain nonzero after zero observed
events: 0.029513 for 0/100, with 59 zero-event trials required before the upper
bound is no greater than 0.05. These are calibration comparison scores, not
unqualified post-selection confidence intervals.

Any observed safety false ready or false boundary handoff rejects a candidate.
All 20 method x model-role x reference-class combinations must be observed and
correctly classified at least once, preventing an always-indeterminate rule
from winning. If no candidate passes, the immutable result is a negative
calibration with no threshold. Policy `7962e47df285812d8c785f206d51925b44a13d02037b7b40a619cb80ce833a62`,
audit `cfdaa73ddc0beb6cc6ca3fbdc2cd7c73bd899bf9e6bebaab675ccc7bd88b16f7`,
and contract `1dcc877da78d3975271b33629b3d67bd9f0f48d675fb1ed62e5704baa46b8b1a`
reproduce in nine focused tests with 102 expectations.

`AcceptancePolicyFrozen=TRUE` and `MonteCarloDecisionPolicyFrozen=TRUE` do not
freeze a cutpoint. Production boundary-probe, runner, calibration,
stationarity-criterion, confirmation, inference, and D-study readiness remain
false or unauthorized. The ordered next gate is a coordinate-correct
production boundary probe, followed by the exact-resume runner.

### Draft.83d2b2b1g12 coordinate-correct production boundary probe

The application probe now retains the actual backend coordinates. lme4's
relative-SD theta has the finite lower endpoint zero, whereas glmmTMB's log-SD
has no finite zero-variance coordinate. Every registered target value
reoptimizes all nuisance coordinates, and the two paths receive a common
boundary meaning only when the terminal full-model objective matches the
separately fitted reduced model.

Monotone material improvement yields `boundary_limit_supported`; monotone
material worsening yields `finite_interior_supported`. Flat, nonmonotone, or
endpoint-mismatched finite paths remain `boundary_probe_inconclusive`, and a
failed nuisance path remains `not_evaluable`. A small first derivative is not
sufficient. The primary warm-started L-BFGS-B nuisance fit permits one frozen
same-point `nlminb` fallback after a finite unsuccessful return, retaining the
solver identity and code.

Seven analytic controls plus lme4/glmmTMB x ML/REML full/reduced fixtures pass
in eight tests with 120 expectations. Policy
`fb7f938a0e1e5b7be598a180f7d5c06eb3176ebea7f1bfc269491befa865cb6c`,
audit `272e5ee2c274c8972ecde6feb039db02e9beb937d4db910555812c35af627eab`,
and contract `53a36d72388eb8b4e096ef817aaf94959aa1b3fd3257190cf5c0a8164383d9da`
reproduce. `ProductionBoundaryProbeReady=TRUE` is narrow; runner,
calibration, stationarity criterion, confirmation, inference, and D-study
readiness remain false or unauthorized. The ordered next gate is the exact-
resume atomic runner.

### Draft.83d2b2b1g13 exact-resume stationarity runner

The runner fixes one dataset x method as the atomic checkpoint. Each unit
contains all backend optimizer profiles for both model roles, two high-
accuracy reference problems, and 48 truth-blind candidate decisions. The
three ledgers remain independently counted and hashed: the sealed workload is
3,000 dataset markers, 12,000 atomic units, 108,000 candidate-fit rows,
576,000 decision rows, and 24,000 reference rows. Evaluator exceptions and
malformed output expand to complete typed failure denominators.

Checkpoint identity binds contract, run manifest, atomic unit, complete
ledgers, and content hashes. Timing and reuse metadata are excluded from the
scientific identity. A dataset marker requires four valid method checkpoint
hashes. On nonreserved mechanics replicates 901--902, cold, three-unit-
interrupted/resumed, and complete-reuse executions share exact execution hash
`4cdbb0ed2ba69588f81e3fcbd3df634b92a4b7e1929bac387cd6a8562a18100f`;
corrupting one checkpoint causes exactly one recomputation and recovers that
same hash. Nine tests with 129 expectations pass.

`RunnerImplementationReady=TRUE` is limited to accounting and resume
mechanics. `ProductionEvaluatorAdaptersFrozen=FALSE`,
`ReservedRunManifestFrozen=FALSE`, calibration authorization/execution,
stationarity criterion, confirmation, inference, and D-study readiness remain
false. The next gate must freeze the four production evaluator adapters and a
runtime-, shard-, output-, and function-identified reserved manifest through a
response-free preflight. It must not open 201--300. Only an independently
audited later authorization artifact may reconsider replicate 201.

### Draft.83d2b2b1g14 production-adapter and reserved-manifest preflight

The four real lme4/glmmTMB x ML/REML candidate and high-accuracy-reference
adapters now bind the deterministic generator, structural pre-fit audit,
objective-only profile selection, scale-aware diagnostics, coordinate-specific
production boundary probe, and separately frozen reference mechanics. Their
two top-level and 15 dependency hashes are joined to the installed R/package
runtime identity.

One nonreserved replicate-902 dataset completes all four atomic units with 36
candidate-fit, 192 candidate-decision, and eight reference rows. Thirty-five
fits return; the glmmTMB ML full BFGS-from-BFGS restart remains a typed
`start_snapshot` failure in the denominator. All references resolve, candidate
and reference generator hashes agree, truth and metrics do not select a
profile, and complete reuse reproduces execution
`b9ad747a62b1e14cf1da1e0e4cee8a0a341db969596df3e2de87b25ba908caae`.

The reserved manifest fixes shards `R0201`--`R0300`, one full replicate per
shard. Each has 120 atomic units, 1,080 candidate fits, 5,760 decisions, and
240 references, reproducing the exact sealed total. It binds output root,
runtime, adapters, dependencies, and every assignment, but remains
`ExecutionAuthorized=FALSE`.

`ProductionAdapterPreflightReady=TRUE` means only executable identity and
nonreserved schema readiness. Calibration authorization/execution/data/results,
stationarity threshold/criterion, confirmation, inference, coefficient,
decision, and D-study readiness remain false. The ordered next gate is a
separate response-free one-way authorization audit with destination permission,
capacity, same-filesystem, early-stopping, and confirmation-isolation checks.
It must not open replicate 201 while being constructed.

### Draft.83d2b2b1g15 response-free one-way authorization preflight

The exact b1g14 workload is now represented by 100 separately hashed
prospective manifests, `R0201`--`R0300`. Each non-executable shard contains
one replicate over 30 scenarios and four methods: 120 atomic units, 1,080
candidate fits, 5,760 decisions, and 240 references. Their exact union
reconstructs 3,000 datasets, 12,000 units, 108,000 fits, 576,000 decisions,
and 24,000 references without generating any response.

The real output parent passes target-absence and an actual RDS write,
same-directory checked rename, identical readback, cleanup, and `df -Pk`
capacity probe. A frozen nonreserved four-lane measurement is extrapolated
under a 32x disk safety multiplier plus 32 GiB residual and a 4x runtime
planning multiplier. The resulting admission bounds are 47,775,834,368
available bytes, 296.823333 serial hours, and 2.968233 hours per shard, with
`MaxConcurrentShards=1` and no early stopping. These are conservative planning
bounds, not performance or statistical claims, and must be rechecked at
activation.

`AuthorizationReadinessAuditReady=TRUE` and
`AuthorizationActivationEligible=TRUE` mean only that a later activation
review has a complete response-free input. They deliberately coexist with
`ExecutionAuthorizationRecordIssued=FALSE`,
`CalibrationAuthorizationReady=FALSE`, and
`CalibrationExecutionAuthorized=FALSE`. No calibration or confirmation
response is generated or inspected, and no threshold, inference, coefficient,
decision, or D-study result advances. The ordered next gate is a separately
reviewed immutable activation artifact and authorized single-shard runner. It
must repeat runtime, target, filesystem, and capacity checks and bind only the
exact prospective manifest before replicate 201 can be reconsidered.

### Draft.83d2b2b1g15a Monte Carlo value and precision audit

The apparent 108,000-fit / 576,000-decision scale is now separated from its
scientific denominator. Only 3,000 scenario-by-replicate datasets are
independent, and the primary scenario x method x model-role cell has at most
100 planned trials. Four methods are paired on each dataset; roles, optimizer
profiles, candidate decisions, and references are repeated computations.

With a complete resolved denominator, 0/100 has a one-sided 95% exact upper
bound of 0.029513, and a true 3% safety-event rate appears at least once with
probability 0.952447. At rates 0.05/0.95 the MCSE is 0.021794 and at 0.80 it is
0.040000. Reference-unresolved rows reduce the denominator, so these remain
planning values; actual cellwise MCSE and bounds must be recomputed after a
complete run.

The 30-by-100 design is retained for numerical candidate selection, safety-
error rejection, and a valid negative calibration. It is not general
validation. For comparison, Bernoulli MCSE at most 0.01 requires 475 trials at
probability 0.05/0.95 and 1,600 at probability 0.80; continuous bias, RMSE,
rank, separation, and D-study measures need their own pilot variances and
precision targets. `NumericalCalibrationDesignPurposeJustified=TRUE` therefore
coexists with `CalibrationPrecisionEvidenceReady=FALSE` and false broad-
performance flags.

This audit changes neither b1g15 activation eligibility nor authorization.
Draft.83d2b2b1g16, below, subsequently applies stronger reproducibility and
single-writer requirements before any activation artifact can be considered.

### Draft.83d2b2b1g16 pre-activation hardening audit

The response-free double-check stops before large calibration. The registered
phase-specific ledger contains 9,756 datasets and 9,756 unique seeds: six
schema-smoke, 750 feasibility, 3,000 calibration, and 6,000 confirmation rows.
Calibration and confirmation seed sets are disjoint.

Seed uniqueness is necessary but not sufficient. On nonreserved replicate
901, the current `set.seed(seed)` generator yields different score and
generator hashes under ambient `Mersenne-Twister` and `Wichmann-Hill` states.
It neither supplies uniform/normal/sample kinds explicitly nor records them in
generator identity. The b1g14 runtime hash also omits RNG, matrix-product,
BLAS/LAPACK, locale/timezone, glmmTMB parallel, and thread-environment state.

Four gates pass: seed accounting, shard partition, complete denominators, and
confirmation isolation. Eight gates block: RNG self-containment, extended
runtime binding, explicit serial threads, vanilla child-process isolation,
reserved-only runner, exclusive writer lock, atomic activation/resume root,
and per-shard filesystem/capacity recheck. The narrower b1g15 readiness result
remains historical evidence, but its activation-eligibility conclusion is
superseded. `LargeSimulationMayStart=FALSE`; no authorization record is issued
and replicate 201 remains unopened.

The ordered repair is to fix and identify RNG generation, re-freeze all
affected downstream nonreserved artifacts, then implement and negatively test
the isolated locked shard runner. Only a later separately reviewed artifact
may reconsider authorization, with no outcome-dependent early stopping and no
confirmation access.

### Draft.83d2b2b1g17 RNG-hardened generator replay

The first b1g16 repair is complete without rewriting historical evidence. The
b1g2a generator remains unchanged, while a separately versioned wrapper fixes
uniform, normal, and sample RNG kinds to
`Mersenne-Twister/Inversion/Rejection`, records them together with the complete
historical parent identity, and restores the caller's RNG kind and
`.Random.seed` on success and error.

All 30 registered scenarios at nonreserved replicate 901 were generated under
both Mersenne-Twister and Wichmann-Hill caller configurations. Hardened
generator hashes, historical parent hashes, and analysis-data hashes agree for
every scenario, with no caller-state restoration failure. A no-pre-existing-
seed path also restores seed absence. Requests for calibration 201--300 or
confirmation 501--700 fail before generation.

Five component gates pass: explicit RNG, complete cross-ambient replay,
caller-state restoration, dual historical/hardened identity, and reserved-band
exclusion. `RNG-ADAPTER-01` remains blocked because the real candidate and
reference adapters still call and hash the historical generator. Therefore
`HardenedGeneratorReady=TRUE` and `RNG01ProspectivelyResolved=TRUE` coexist
with `AuthorizationRNG01Closed=FALSE`, `LargeSimulationMayStart=FALSE`, and
`Replicate201MayBeOpened=FALSE`.

The next ordered slice must rebuild the nonreserved production adapter,
reference, manifest, checkpoint, and preflight identities against the hardened
generator. Old hashes must not be edited in place. Only after exact nonreserved
dry-run and resume/tamper parity may the authorization-level RNG gate close;
runtime, thread, process, lock, root, and per-shard capacity work remains
independent and subsequent.

### Draft.83d2b2b1g18 hardened production-adapter rebase

The nonreserved adapter connection is now complete under a new descendant
identity. Historical b1g14 preparation and evaluators remain unchanged. New
preparation calls the b1g17 generator, checks exact historical analysis-data
reduction, recomputes the structural pre-fit identity, and rejects calibration
and confirmation replicates before generation.

Historical and hardened paths independently execute replicate 902 through
glmmTMB/lme4 x ML/REML. After excluding generator/pre-fit identity columns and
reference sidecar hashes that must change, all 36 candidate rows, all 192
candidate decisions, and all eight reference state/failure rows agree exactly.
Both retain 35 returned fits, one typed glmmTMB ML `start_snapshot` failure, and
zero unresolved references. Candidate and reference calls independently agree
on hardened generator and pre-fit hashes. A second hardened execution reuses
all four checkpoints and reproduces its execution hash.

This yields `NonreservedAdapterRebaseReady=TRUE` and
`RNGAdapterComponentProspectivelyResolved=TRUE`. It does not create a reserved
entry point or rebuild the 100-shard prospective manifest. Therefore
`ReservedAdapterEntryPointReady=FALSE`, `AuthorizationRNG01Closed=FALSE`,
`LargeSimulationMayStart=FALSE`, and replicate 201 remains sealed.

### Draft.83d2b2b1g19 hardened reserved-lineage rebase

The response-free reserved lineage now reduces exactly to the b1g14 workload:
3,000 datasets, 12,000 atomic units, 108,000 candidate fits, 576,000 decisions,
24,000 references, and 100 one-replicate shards. Dataset/unit IDs, assignment,
and all denominators agree. The historical unit identity did not bind adapter
or generator contracts, so b1g19 retains it only as paired provenance and
rehashes every unit against the b1g17/b1g18 lineage. All 12,000 unit and all 100
shard identities change; no historical scientific hash appears in the active
registry.

All 100 prospective shard manifests validate independently and remain inert:
response generation, fitting, output creation, execution, early stopping, and
confirmation use are false. Replicate 501 is rejected, and the b1g19 output
root remains absent. Thus `ReservedManifestRebaseReady=TRUE` does not imply an
executable entry point: `ReservedAdapterEntryPointReady=FALSE`,
`RuntimeContractExtensionReady=FALSE`, `AuthorizedSingleShardRunnerReady=FALSE`,
`AuthorizationRNG01Closed=FALSE`, and replicate 201 remains sealed.

The immediately following b1g20 slice consolidates the shared runtime,
process, lock, root, and capacity mechanics. The scientific runner and its
separate authorization decision remain later work.

### Draft.83d2b2b1g20 reusable authorization kernel

The shared runtime/process/lock/root/capacity work is now consolidated into one
response-free kernel rather than split across further narrow evidence layers.
An isolated `Rscript --vanilla` child reproduces an extended runtime identity
with explicit RNG, C locale, UTC timezone, suppressed startup files, serial
glmmTMB control, and five numerical-library thread variables fixed to one.
Atomic lock contention, initial activation versus exact resume, unmarked-root
rejection, fresh write/rename/readback, and conservative capacity checks pass
without creating the reserved target.

Nine gates now pass: RNG, lineage, runtime, thread, process, lock, root,
capacity, and confirmation isolation. Only `RUNNER-01` and
`AUTH-RECORD-01` remain. Thus `AuthorizationKernelReady=TRUE` is a reusable
infrastructure result, while `AuthorizationRNG01Closed=FALSE`,
`LargeSimulationMayStart=FALSE`, and replicate 201 remains sealed.

No additional preauthorization abstraction layer should be introduced unless
the actual runner reveals a genuinely new failure mode. The next implementation
priority is one reserved-only runner reduced first against nonreserved data,
then a separate immutable authorization decision. After numerical-rule
calibration, priority returns to G-study/D-study recovery and full-refit
uncertainty rather than further execution-framework elaboration.

### Draft.83d2b2b1g21 guarded single-shard runner reduction

The actual hardened scientific path is now joined to the b1g20 execution
boundary. In a disposable nonreserved replicate-902 root, one isolated
`Rscript --vanilla` child evaluates all four glmmTMB/lme4 x ML/REML units under
an exclusive lock and a manifest/runtime activation marker. The content-
addressed job capsule binds target, lock owner, activation, contract, and
manifest identities before the child independently rereads the markers.

The first run retains all 36 fit rows, 192 candidate decisions, eight
references, 35 returned fits, and one typed failure. These rows reduce
semantically to the direct b1g18 hardened execution. A second child observes
an exact resume, computes zero units, reuses four checkpoints, and reproduces
execution/checkpoint/marker hashes. Job, worker, contract, manifest, and result
mutations fail closed. This establishes `GuardedSingleShardRunnerReady=TRUE`
and closes `RUNNER-01`.

This remains non-authorization evidence. The guard rejects reserved 201--300
unless a separate immutable authorization record exists, rejects confirmation
501--700 before generation, supplies no issuance function, and leaves the
reserved root absent. `ReservedAdapterEntryPointReady`,
`AuthorizedSingleShardRunnerReady`, `AuthorizationRNG01Closed`,
`LargeSimulationMayStart`, and `Replicate201MayBeOpened` remain false. The only
remaining activation blocker is `AUTH-RECORD-01`.

The next step is one explicit go/no-go authorization decision, not another
infrastructure layer and not a large simulation. If issued, it must bind one
exact b1g19 shard and a fresh b1g20 site receipt; that shard must be reviewed
before continuation. After stationarity calibration, priority returns to
G-study/D-study recovery and full-refit uncertainty, then nested/crossed and
multivariate claims.

### Draft.83d2b2b1g22 execution-authorization decision

The explicit go/no-go audit refuses authorization. The b1g21 reduction remains
valid, but exact-source inspection shows that its preparation entry point
stops on reserved replicates and the inherited b1g13 execution loop is
nonreserved-only. Consequently a record that merely named the b1g21 source
would not create an executable, record-bound reserved path.

Five gates pass: exact R0201 lineage and denominators, isolated runtime,
nonreserved scientific reduction, exact runner-source audit, and confirmation
exclusion. Three gates block: `RESERVED-ENTRY-01`, `ACTIVE-MANIFEST-01`, and
`SITE-RECEIPT-01`. The frozen decision is `no_go_refused_not_issued`.
Authorization, replicate 201, calibration, inference, and large simulation all
remain false; no response, fit, or reserved root was created.

This refines the coarse b1g21 `AUTH-RECORD-01` label into concrete
prerequisites. The next task is bounded implementation, not more policy:
provide a record-bound reserved-only entry point and exact R0201 active-
manifest conversion, reduce its evaluator/checkpoint semantics against
nonreserved evidence, and keep the path inert until a separate record and a
fresh site receipt are issued. If those checks later pass, exactly one shard
may be considered; its complete denominators must be reviewed before any
continuation.

### Draft.83d2b2b1g23 record-bound reserved entry implementation

The missing reserved-capable mechanics now exist without opening R0201.
Exact-source audit identified three independent nonreserved admissions: the
b1g17 generator, b1g18 preparation adapter, and b1g13 checkpoint runner. b1g23
removes exactly one expected admission expression from each parent abstract
syntax tree, source-hashes the parent and reused core, and binds the unchanged
scientific bodies to one record/manifest/capability admission.

An ephemeral capability can be created only from a hash-valid b1g23 contract,
active manifest, and mode-specific record. Preparation and generation
revalidate it. A future reserved generation receives a new identity binding
the issued record and active manifest while retaining the complete b1g17
parent identity. The R0201 conversion preserves all 120 prospective atomic
identities as provenance, recomputes active identities, and retains exact
30/120/1,080/5,760/240 denominators.

The executable evidence remains nonreserved replicate 902. Its 36 fits, 192
decisions, and eight references exactly equal b1g21, including 35 returned
fits and one typed failure; exact resume computes zero and reuses four units.
Four focused tests with 75 assertions pass.

This closes only the implementation portions of `RESERVED-ENTRY-01` and
`ACTIVE-MANIFEST-01`. No production issuance function or record exists, no
active R0201 manifest is constructed, and the reserved root/lock remain
absent. `FreshSiteReceiptBound`, `AuthorizationRecordIssued`,
`Replicate201MayBeOpened`, and `LargeSimulationMayStart` remain false. The
next bounded step is a fresh runtime/site six-gate issuance decision that may
authorize at most R0201; complete single-shard review must precede expansion.

### Draft.83d2b2b1g24 fresh-site one-shard issuance

The separate production issuer now exists as a response-free boundary. It
binds the exact b1g23 entry contract and R0201 prospective manifest to newly
collected b1g20 isolated-runtime and site receipts. Six rows are recomputed:
entry implementation, active-manifest conversion, isolated runtime, target-
specific site readiness, exact one-shard scope, and confirmation isolation.
The gate registry and nested receipt objects enter the decision and record
identity; stored pass flags alone cannot authorize execution.

GO and NO-GO have deliberately different roles. A failed site gate creates a
hash-valid, auditable `no_go_record_must_not_be_issued` preflight, but the
record issuer rejects it. The observed six-gate GO creates one production
record for R0201 and an unexecuted active manifest with exact
30/120/1,080/5,760/240 denominators. The parent b1g23 production validator
independently revalidates the record, so b1g24 cannot self-authorize around the
record-bound entry contract.

Fifty-one focused assertions cover both decisions, portable identities,
active unit identity rebinding, absent response/pre-fit/checkpoint state, and
decision/record/manifest/audit mutation. No reserved root or lock is created.
The result changes `Replicate201MayBeOpened` only for an exact fresh issuance
instance; it does not mean that replicate 201 has run. `LargeSimulationMayStart`
remains false.

The next priority is one persistent R0201 execution through the existing
record-bound isolated runner, followed by mandatory inspection of all
1,080 candidate fits, 5,760 decisions, 240 references, typed failures,
numerical diagnostics, time/storage, and exact-resume state. That review—not
elapsed time alone—determines whether the numerical-rule calibration can
continue. R0202, the remaining 99 shards, Draft.84 uncertainty, and Draft.85
multivariate estimation remain downstream and receive no authorization from
b1g24.

### 2026-08-11 portfolio-purpose checkpoint

The higher-level portfolio audit in
`portfolio-purpose-and-conquest-audit-0.2.3.md` supersedes R0201 as the next
priority without invalidating the b1g24 issuance result. The GO/NO-GO sequence
closed real RNG, runtime-identity, reserved-entry, locking, root-lifecycle,
resume, and complete-denominator defects. It is now terminal infrastructure:
no further authorization layer is planned, and technical issuability does not
establish scientific necessity.

R0201 remains unexecuted until the claim-disposition profile identifies one
retained 0.2.3 decision that the numerical-rule calibration can change, why a
deterministic reduction or external microcase cannot answer it, and what
precision and sequential escalation rule apply. Absent that dependency, the
30-by-100 calibration is deferred. Its nominal n=100 per primary cell is not
reused for bias, RMSE, rank recovery, facet-effect recovery, coverage, D-study
stability, or multivariate claims.

Immediate priority returns to the release spine and matched external evidence.
Wave C starts with an additive Person/Rater/Criterion RSM/PCM complete-crossing
microcase, explicit native-export precision, and native A-matrix adjudication;
only then may a connected sparse/unequal-workload case be considered.
Candidate-bound binary/polytomous replication remains later than this schema
gate. The exact probability-level audit in
`conquest-gpcm-overlap-record-0.2.3.md` now establishes one narrow bounded-
GPCM common stratum: item-only MML with active latent regression. Under
`theta = beta_0 + X beta + sigma epsilon`, mfrmr's geometric-mean-one slopes
map to ConQuest Taux as `Tau_i = sigma a_i`, with the regression, item, and
step coordinates transformed at the same time. The installed ConQuest 5.47.5
completed that 31-node microcase and reproduced the transformed structural
coordinates and deviance descriptively. It remains review-only because the
mfrmr fit did not pass its terminal-gradient readiness rule, CSV rounding and
a prospective tolerance are unresolved, and no candidate was bound.

This item-only map does not extend to a standard multifacet `scoresfree` run.
ConQuest then owns scores by generalized-item facet combinations, whereas the
current mfrmr kernel gives one selected Criterion or Rater the slope that
multiplies all active facet terms. ConQuest JML also cannot estimate item
scores. Display rounding, shared output labels, C-matrix labels, or unmatched
estimator/owner modes cannot create a many-facet agreement claim.

The first corrective artifact is now complete in
`claim-disposition-profile-0.2.3.csv` and its companion record. It maps all 106
checklist items in exact order to 53 `release_spine`, 32
`claim_conditional`, and 21 `deferred` rows. Every conditional row has an
explicit fail-closed fallback, and mixed checklist rows apply to the spine only
for their retained supported-core scope. The profile changes no evidence
status and creates no new gate.

That deterministic follow-up is now complete in
`conditional-fallback-coverage-audit-0.2.3.md`. All nine fallback classes have
a fail-closed public decision route. The audit corrected the JML fallback
vocabulary, added machine-readable residual-PCA non-promotion fields to
result/summary/plot surfaces, and propagated exact GPCM slope/step owner plus
the non-consistency interpretation through fit summaries and central GPCM
boundary tables. It ran no simulation or external engine and promotes no
conditional claim. The next task is to work the 53-row spine by dependency
and decision value, beginning with deterministic shared contracts and exact
external-core microcases.

`release-spine-priority-queue-0.2.3.md` now assigns all 53 spine rows exactly
once to five dependency waves: 23 deterministic contract/scope rows, six
numerical/model-identity rows, seven external-core rows, nine retained-core
recovery/sparse rows, and eight candidate/release rows. The first bounded
closure is complete: row 22 `readiness_contract_schema` is `ok` under contract
v3 after the 36-row dependency-free validator, conservative legacy-TRUE and
legacy-FALSE mapping, a rejected blocked-to-ready mutation, and the
public/private vocabulary boundary all passed. Row 23 runtime propagation
remains `review`; schema closure cannot be borrowed by fit/report/export
surfaces or by unfinished statistical states.

The first bounded row-23 slice is now stable and documented in
`readiness-propagation-stable-slice-audit-0.2.3.md`. For native retained-core
RSM/PCM fits, one v3 fit record reaches summary, convergence review,
`mfrm_results`, manifest, export, and replay provenance. Manifest and replay
objects carry exact fit/component/parameter tables; replay recomputes the new
fit's readiness and warns on disagreement rather than copying source status.
Optimizer-code convergence is no longer stored under the manifest's
`Converged` label as inference readiness. Deterministic JML/MML PCM positive
and iteration-limit paths and legacy-unknown adapters pass. Row 23 is still
`review`: parameter/step/interaction coverage depends on open WP1--WP3 states,
and lower-priority saved/export adapters plus exact-candidate binding remain
open. A real fit serialized by the frozen 0.2.2 tarball now maps to
`legacy_unknown/FALSE`; a current-development fresh-session replay recomputes
a separate `ready/TRUE` decision and emits the required mismatch warning. The
central results/report/checklist/APA routes retain exact
fit/component/parameter records; an adversarial APA test also prevents a
diagnostic precision flag from upgrading a blocked fit. This retained-core
slice has reached its deliberate stopping boundary. No simulation or external
engine was used, and lower-value adapter polishing is deferred behind shared
mathematical release-spine contracts.

### 2026-08-11 additive ConQuest Wave C checkpoint

The additive external microcase has now been reduced before native execution
from an over-wide 3-Rater/4-Criterion draft to a 96-Person, 2-Rater,
2-Criterion, four-category complete crossing. A balanced two-level regression
covariate retains the population slope while exact design reuse reduces the
strict MML all-pattern audit from about 1.61 billion prospective
pattern/design evaluations to 512. The independent free dimensions are 7 for
RSM and 9 for Criterion-step PCM. This is a methodological correction, not a
sample-size preference.

The source-bound q31/q61 RSM/PCM preflight is complete. All four fits converge;
an independently implemented probability/Gauss-Hermite marginal-likelihood
oracle agrees within `1.14e-13`; and the all-pattern local ranks are 7/9 with
nullity zero and no tolerance sensitivity. q31/q61 deviance differences of
about `2.3e-12`--`2.5e-12` are observations only because no acceptance
threshold was set prospectively. `InferenceReady = FALSE` remains visible:
the current policy treats the completed all-pattern information calculation as
a local diagnostic rather than structural-identification proof.

The preliminary native-runtime NO-GO was then corrected. Restricted Codex
launches crashed in registry/settings XML persistence, but the user showed the
same executable running in Terminal. An unsandboxed `quit;` control printed
version 5.47.5 and `End of Program`, and the SHA-matched executable completed
all four sealed arms. The old ACER support draft is therefore withdrawn; the
crash evidence describes sandbox compatibility, not general ConQuest
availability.

RSM q31/q61 completed 96 iterations and PCM q31/q61 completed 95. All native
A matrices exactly match the independent 7/9-dimensional sum-zero bases. For
each model, q31/q61 final coordinates are identical at the CSV digits.
Native-minus-mfrmr displayed coordinate differences are at most `2.74e-6`,
but no CSV rounding rule or acceptance threshold is established. The native
history column named `LogLikelihood` contains positive deviance and is handled
explicitly. The comparison also caught and repaired a reference-export defect
that had written PCM step estimates as missing; the validator now requires
every reference estimate to be finite.

Wave C has therefore moved from a false runtime block to
`four_arm_native_outputs_ready_tolerance_and_candidate_missing`. It is still
not a scientific-equivalence or release result.

The subsequent five-layer adjudication deliberately did not turn the opened
maximum difference into a self-passing `EXT-CQ-TOL`. Calibration may inform a
prospective rule for a disjoint candidate, but cannot pass itself under a
newly chosen threshold. Representation, optimizer termination,
integration stability, scientific acceptance, and exact candidate binding now
have separate machine-readable rows. The ConQuest IC normalizer's former
`export_tolerance` is an internal handoff-consistency threshold, now named
`handoff_tolerance`; CSV resolution and cross-engine tolerance remain unknown.
The decision is `hold_no_post_hoc_tolerance_freeze`. The broad external claim
is retained as a future gate, but the present claim is descriptive only. An
independently adjudicated pre-confirmation `EXT-CQ-TOL` and
`IC-INTEGRATION-TOL` record
must precede candidate binding and the fresh four-arm rerun. Sparse extension
and large simulation remain unauthorized.

The first independent deterministic task during that pause is complete. Row
71 `estimator_vocabulary` now closes structurally: `MML` and `JML` remain the
canonical estimator labels, `JMLE` remains an input alias, and legacy `JMLE`
fields are normalized at summary, console, manifest, and replay boundaries.
The focused runtime and public-documentation tests pass. This is a public-
contract repair only; it does not imply equal MML/JML maturity or substitute
for any external comparison.

### Future Draft.85a0 multivariate supplied-matrix algebra preflight

The multivariate mathematical layer has been implemented early as a
repository-only supplied-matrix preflight without changing the ordered
estimation gates. `gtheory-multivariate-algebra-contract-0.2.3.md`, its R
prototype, and record represent each semantic component by a stratum
covariance matrix `Gamma_c`, a prospective allocation Gram operator
`Lambda_c`, and the contribution `Gamma_c o Lambda_c`.

Universe-score, relative-error, and absolute-error covariance matrices are
formed before a composite quadratic form. Explicit condition weights produce
common, partial, or zero cross-stratum overlap; counts and
`1/sqrt(n_a n_b)` cannot substitute for that operator. The two-stratum oracle
gives G/Phi 0.6719368/0.6204380, 0.6967213/0.6488550, and
0.7234043/0.6800000 under common, one-of-two shared, and independent Rater
samples. Exact one-stratum reduction and a three-stratum order fixture also
pass.

Nine tests and 66 expectations reject indefinite, asymmetric, reordered, or
mis-scaled matrices and invalid weights while retaining raw PSD/rank state.
`AlgebraReady=TRUE` refers only to supplied matrices. No covariance estimator,
long-form Stratum incidence audit, joint interval, PSD repair, backend
selection, public object, or support claim exists. `EstimationReady`,
`InferenceReady`, `CoefficientEligible`, and `DecisionReady` remain false.

This preflight does not replace the remaining Draft.83d2 or Draft.84 gates.
Future Draft.85b must
bind a typed Stratum design to estimated component covariance matrices, and
Draft.85c must establish sparse/unequal/missing two-/three-stratum recovery,
PSD/rank recovery, shared-facet operator recovery, and full-refit uncertainty.

### Release horizon

| Version | Position | Primary exit decision |
| --- | --- | --- |
| 0.2.2 | Published stabilization and contract baseline | Frozen historical evidence; maintenance only unless CRAN requests a correction. |
| 0.2.3 | Numerical trust and external validation | State exactly where current RSM, PCM, bounded GPCM, JML, and MML are validated, caveated, exploratory, or unsupported. |
| 0.2.4 | Fixed calibration and operational scoring | A typed, versioned calibration can be saved, reloaded, and applied to new data with unknown or incompatible inputs failing closed. |
| 0.2.5 | Multiple observed scales and mixed response structures | Explicit `ScaleId` routing reduces exactly to the one-scale contract and cannot pool or link incompatible scales silently. |
| 0.3.0 | API, evidence, and ecosystem consolidation | Stable object schemas, compatibility/deprecation policy, reproducible case studies, performance envelope, and contributor review are in place. |
| 1.0.0 | Validated core stability contract | The declared core—not FACETS feature parity—has replicated recovery/external evidence, stable schemas, failure-mode coverage, and public support boundaries. |

Research tracks such as native multidimensional MFRM, unrestricted GPCM,
Bayesian backends, and multivariate G-theory do not inherit a release number
merely because code exists. Each enters only after its own estimand,
identification, recovery, reduction, and public-contract gates are defined.

## 0.2.2: published stabilization and contract baseline

0.2.2 is a substantial stabilization release, not a broad API-expansion
release. Its accepted scope is:

- unidimensional `RSM`, `PCM`, and explicitly bounded `GPCM` fitting;
- direct and group anchors for Person/facet elements within a one-scale fit,
  together with anchor review and linking/drift helpers;
- a coherent data-review, fit, diagnostic, report, export, and replay path;
- numerical-readiness states shared across direct, hybrid, and EM MML routes;
- fitted-scale summaries, native and FACETS-style visualizations, and reusable
  draw-free plot data;
- conservative bias, DFF/DIF, Q3-style, and residual-screening language;
- current `eRm` import compatibility and bounded ConQuest overlap tooling;
- package-native bounded-GPCM score-side uncertainty with the corrected
  expected-score delta factor;
- explicit FACETS positioning, including duplicate-observation, agreement,
  score-side, and unsupported-feature boundaries; and
- reproducibility manifests, validation artifacts, documentation, and the hex
  sticker used in the README and pkgdown site.

The following are not 0.2.2 release blockers and must not be described as
current 0.2.2 features:

- same-candidate external numerical comparison against ConQuest or FACETS;
- a calibrated MML joint-stationarity and parameter-recovery gate;
- freely estimated latent population SD;
- model-family or estimation-scope registry helpers beyond the exported 0.2.2
  capability surfaces;
- configurable-prior EAP sensitivity helpers;
- moderation-specific DFF/DIF helpers;
- mixed response families, multiple observed score scales, general threshold
  anchoring, or fixed-calibration operational scoring;
- unrestricted GPCM, multidimensional latent traits, posterior-predictive
  checks, MCMC, or multivariate G-theory.

### 0.2.2 source-alignment exit record

The submitted candidate completed the following checks:

- [x] Keep `DESCRIPTION`, `CITATION.cff`, `NEWS.md`, `cran-comments.md`, tag,
  tarball, and check log on the same version and release date.
- [x] Build one exact candidate tarball and record its SHA-256 digest
  (`dddeaaba8d2d0684784fa774b349e8fa1d13570143341daad4aa31e2990e5d00`).
- [x] Run a full-manual `R CMD check --as-cran --run-donttest` on that exact
  tarball and retain the full log (`Status: OK`; 282.60 seconds wall time).
- [x] Restrict `\dontrun{}` to the two examples requiring separately generated
  ConQuest files, restrict interactive-only examples to the local Shiny viewer,
  and keep the CRAN-side package workload below ten minutes (153 seconds for
  this candidate: examples including `donttest`, tests, and vignette
  rebuilding). The 261-second sum of all timed top-level components is retained
  as diagnostic context rather than used as the package-controlled gate.
- [x] Audit README, NEWS, vignettes, generated help, and first-screen runtime
  guidance for maintainer-oriented wording while retaining documented API and
  status vocabulary.
- [x] Document `maxit` as a prespecified computational ceiling, make
  iteration-limited fits explicitly review-only, and require numerically ready
  JML and MML fits before estimator-agreement checks.
- [x] Confirm the full non-CRAN suite and all required CI matrix jobs complete
  for the example-policy source before merge.
- [x] Run the updated repository release-readiness review against the exact
  tarball and check log for the final example-policy source (all nine gates
  `ok`).
- [x] Confirm source-package contents exclude repository-only roadmaps and
  validation helpers.
- [x] Regenerate pkgdown from the final source and inspect key pages and logo.
- [x] Obtain explicit manual approval before retagging, replacing an asset, or
  submitting to CRAN.
- [x] Archive the official Win-builder R-devel result (`Status: OK`; 55-second
  installation and 335-second check) before the temporary result expired.
- [x] Submit the immutable tarball to CRAN without rebuilding it after the
  repository-only preparation merge.

Published 0.2.2 follow-up is operational, not permission to broaden the
package:

- [x] Record CRAN acceptance and publication on 2026-07-27. No CRAN-requested
  source correction is present in the repository record reviewed on
  2026-08-03.
- [x] Verify the CRAN package page and automatically built Windows/macOS
  binaries for 0.2.2.
- [ ] Resolve or attribute the current r-devel Debian GCC CRAN NOTE reporting
  residual `~/tmp/scratch/Rtmp*` directories. Until then, describe the public
  matrix as 12 `OK` and one `NOTE`, not as all-OK.
- [x] Keep any future CRAN-requested 0.2.2 correction isolated from 0.2.3 and
  require an explicit version policy before editing the published line.

## 0.2.3: numerical trust and external evidence

0.2.3 is a numerical-trust release for the existing single-scale contract. Its
purpose is to make release claims harder to earn, not to maximize the number of
new functions. Small API changes are allowed only when they expose evidence or
prevent an unsupported interpretation. A new response family or scoring
architecture requires a later release.

The central claim is deliberately narrower than feature development:

> mfrmr 0.2.3 adds no new model family. It systematically establishes
> parameter recovery, supported standard-error coverage, matched external
> comparisons, and the applicable design envelope for the RSM, PCM, bounded
> GPCM, JML, and MML surfaces published in 0.2.2.

Terminal-gradient checks, limited ConQuest overlap, FACETS positioning, and
the fit/diagnose/report workflow already existed in 0.2.2. Their 0.2.3 task is
not reimplementation; it is promotion from fixed or narrow demonstrations to
prespecified, replicated, candidate-linked evidence. Any surface that cannot
earn that promotion remains caveated, exploratory, blocked, or deferred.

### Release contract

The release owns these outcomes:

- a candidate-linked MML stationarity and recovery gate shared by direct,
  hybrid, and EM routes;
- parameter-recovery and supported-interval coverage evidence separated by
  estimator, model, parameter class, and design cell rather than pooled into a
  single success rate;
- a prespecified stress envelope for connected, weakly linked, sparse, and
  deliberately disconnected designs, including minimum-rater panels and
  severely imbalanced category support;
- separate operating-characteristic gates for fixed interaction recovery,
  additive-model bias screening, and exploratory residual-PCA signals;
- a candidate-linked dimensionality challenge that separates exploratory
  residual evidence, confirmatory external model comparison, and the practical
  value of any proposed dimension-specific score;
- an explicit MML information-criterion contract that records the likelihood
  basis, free-parameter count, independent sampling unit, exact formula, and
  integration evaluation used for every reported criterion;
- a same-candidate ConQuest MML overlap gate for the supported overlap region;
- a mandatory, candidate-linked FACETS JML RSM/PCM stress core covering
  connected recovery, element/group anchors, sparse topology, and edge cases,
  with additional fit/DFF rows promoted only when their definitions match;
- a machine-readable support envelope that ties maturity and operational
  status to exact recovery, external-tool, and candidate evidence identities;
- versioned, machine-readable gate criteria and evidence manifests; and
- release tooling that cannot silently reuse a log, tarball, external result,
  threshold set, or prose pass count from another candidate.

The public estimator vocabulary remains `MML` and `JML`. `JMLE` remains only a
backward-compatible input alias that resolves to `JML`; `MMLE` may describe a
statistical estimator in prose but is not a third `fit_mfrm()` method label.
JML and MML estimate persons differently, so agreement between their person
measures is not a release gate. Comparisons must name a common estimand and
transformation before a tolerance is applied.

### Estimator ecosystem and maturity boundary

One fitting interface is a workflow property, not evidence that its estimators
have equal inferential maturity. The 0.2.3 gate therefore treats each estimator
and correction convention as a separate method, even when the model formula
and output labels look similar.

| Surface | Audited reference state | 0.2.3 validation role | Boundary that must remain visible |
| --- | --- | --- | --- |
| mfrmr MML | Native RSM, PCM, and bounded-GPCM route with direct/hybrid/EM engine paths. | Primary recovery, stationarity, supported-interval, and ConQuest/TAM MML lane. | Population distribution and integration are part of the estimand; evidence cannot be borrowed from JML. |
| mfrmr JML | Native RSM/PCM/bounded-GPCM route without a classical finite-item bias correction; structural-parameter SEs are observation-information approximations rather than a full profile-likelihood Hessian. | FACETS/TAM/immer comparison, education, and exploratory analysis; any stronger claim is earned separately by recovery and coverage. | Incidental-parameter bias, extreme scores, approximate uncertainty, and person-specific information remain explicit. |
| TAM | CRAN 4.3-25 supplies MML and `tam.jml()`; the latter documents extreme-score adjustment, a default finite-item bias reduction, and fixed item/person parameters. | Independent MML overlap and JML sensitivity/reference lanes. | `tam.mml.mfr()` design-matrix handoff to `tam.jml()` does not make TAM's JML correction automatically valid for mfrmr's arbitrary-facet exposure patterns. |
| immer | CRAN 1.5-13 supplies design-matrix CML/CCML, unadjusted/adjusted/bias-corrected JML modes, and a hierarchical rater model; development 1.6-1 is retained only as a separate sensitivity identity. | Rasch-family conditional-estimator references, JML convention grid, and a local-dependence/model-misspecification challenge. | CML/CCML do not estimate the same person quantities as JML/MML, and HRM is a different latent-data model fitted by MCMC rather than another additive-MFRM estimator switch. |

The primary external identities are the CRAN releases current at the source
audit: TAM 4.3-25 and immer 1.5-13. TAM 4.4-2 and immer 1.6-1 development
snapshots may be run as separately labelled sensitivity strata. Development
and CRAN results are never pooled, and a later installed version requires a new
identity record, source audit, and comparison stratum.

The executable comparison matrix, eligibility rules, stress axes, output
schema, and architecture decision gates are maintained in
`tam-immer-estimator-stress-plan-0.2.3.md`. That file is subordinate to this
roadmap and the release-gate specification; it contains no completed evidence.

The JML convention grid is deliberately adversarial. On the same generated
observations and common parameter coordinates it includes mfrmr's uncorrected
JML, FACETS' selected convention, TAM's unadjusted and documented
adjusted/bias-reduced modes, and immer's unadjusted, extreme-score-adjusted,
and bias-corrected modes. Extreme and nonextreme persons are summarized
separately. Truth recovery, supported-interval coverage, failure behavior, and
between-program differences are four different outputs; agreement cannot
substitute for recovery.

A classical multiplicative JML correction is not copied merely to reproduce an
external value. Under arbitrary facets, sparse assignments, missingness,
unequal rater workloads, and design-matrix pseudoitems, the effective item or
occasion count in a factor such as `(I - 1) / I` is not automatically unique.
Any native correction proposal must first define that exposure quantity,
reduce to the established balanced case, preserve identification and anchors,
and improve prespecified bias/RMSE without unacceptable coverage, boundary, or
failure-rate cost. Otherwise JML remains uncorrected and explicitly caveated.

Native CML/CCML is not promised by this comparison. The first decision point is
an adapter and matched external study limited to identifiable Rasch-family
structural parameters; person measures and bounded-GPCM claims are excluded.
Only after accuracy, missingness/category limits, computation, maintenance, and
user demand are quantified may an architecture decision record choose native
implementation, an adapter, or continued external-reference status.

HRM remains an alternative data-generating and local-dependence model. It must
not appear as `method = "HRM"`. Any future implementation needs a distinct model
family/API or companion package, a latent true-rating estimand, identification
and MCMC diagnostics, posterior checks, and its own recovery gate. Likewise,
the label `GMFRM` is prohibited unless a proposal disambiguates generalized
response discrimination, rater-consistency parameters, and local-dependence
structure; these are not interchangeable generalizations.

The following remain outside 0.2.3:

- threshold/step anchors and frozen-calibration operational scoring (0.2.4);
- multiple observed `ScaleId` values, scale-specific anchors, scale-specific
  PCM, and mixed response structures (0.2.5);
- freely estimated latent population SD, configurable-prior EAP sensitivity,
  and moderation-specific DFF/DIF as new public contracts;
- new exported model-family or estimation-scope registries beyond structured
  evidence needed for the existing 0.2.3 support boundary;
- unrestricted GPCM, native multidimensional latent-trait estimation,
  dimension-specific score production, posterior-predictive checks, MCMC, and
  multivariate G-theory; and
- native CML/CCML, a new JML bias-correction option, and hierarchical rater or
  other latent local-dependence model families; and
- a package/runtime dependency on ConQuest, FACETS, TAM, or immer. Their locally
  executed synthetic validation is release evidence, not code required to
  install or use mfrmr.

### Work sequence and evidence invalidation

| Milestone | Work | Required exit artifact |
| --- | --- | --- |
| M0: freeze the published 0.2.2 baseline | Keep the accepted asset and tag immutable. Conduct 0.2.3 gate-specification, pilot, and package work only under the explicit 0.2.3 identity; any later 0.2.2 correction branches from the published tag. | CRAN acceptance is recorded, and correction and development paths remain separate before M3. |
| M1: draft the gate specification | Define scenario IDs, estimands, parameter transformations, readiness states, evidence roles, blocking rows, information-criterion formulas/sample-size bases, dimensionality discovery/confirmation partitions, candidate Q matrices, consequence criteria, and explicit pilot-required numeric criteria. | Versioned draft `inst/validation/release-gate-spec-0.2.3.md` and `inst/validation/release-evidence-checklist-0.2.3.csv` committed with review; confirmation remains unauthorized. |
| M2: instrument, pilot, and freeze | Add independent gradient/objective checks, scenario generators, corrected MML information-criterion instrumentation, external normalization, a TAM dimensionality runner, integration-stability checks, fail-closed import guards, and candidate manifests. Pin the local FACETS 4.5.0 binary/report/parser identity without making upstream-version difference a stop rule, build the paired JML RSM/PCM stress runner, and pilot its core/anchor/sparse/edge families. Add TAM/immer runners that preserve every JML adjustment mode, isolate CML/CCML structural estimands, and treat HRM as an alternative-model stress lane. Use pilot-only data to calibrate every unresolved criterion, then freeze the specification before confirmation. | Reproducible internal, ConQuest/TAM, FACETS, and immer pilot reports with criterion changes recorded plus a reviewed `0.2.3-frozen.*` specification/checklist containing no unresolved blocker criterion and no release decision. |
| M3: freeze one candidate | Freeze source commit, dependency lock information, external-tool executable/report identities, parser/generator versions, input/partition/Q-matrix/topology fingerprints, integration controls, seeds, failed-run policy, and tarball digest. | Candidate manifest that uniquely identifies every internal and external input and stratifies rather than silently pools external-program versions. |
| M4: run confirmation | Run the locked recovery/stress matrix, FACETS JML core, ConQuest/TAM MML comparisons, TAM/immer JML convention grid, eligible immer CML/CCML rows, dimensionality challenge, and matched external rows without changing criteria or reusing discovery/pilot data as independent confirmation. | Candidate-linked internal and external evidence with every blocker classified and every expected scenario/replicate accounted for. |
| M5: release handoff | Run full regression, cross-platform CI, manuals, URL checks, CRAN-time examples, Win-builder, package-content audit, and public-claim audit. | All blocker rows `ok`, all caveats visible, and an exact checked tarball. |

The repository now contains `0.2.3-draft.51` planning and pilot artifacts at
`inst/validation/release-gate-spec-0.2.3.md` and
`inst/validation/release-evidence-checklist-0.2.3.csv`, with the TAM/immer
execution contract in `inst/validation/tam-immer-estimator-stress-plan-0.2.3.md`.
They deliberately record unresolved pilot-calibrated criteria and therefore do
not authorize confirmation or constitute release evidence. The source-grounded M1 review is
recorded in `inst/validation/release-gate-m1-review-0.2.3.md`; the exact IC
arithmetic/policy fixtures begin M2 instrumentation. M1 is content-complete
but remains an open repository milestone until these artifacts receive the
normal commit/review handoff. M2 completes only after package instrumentation
and pilot work have resolved every blocking criterion and the specification
is promoted to a reviewed `0.2.3-frozen.*` identity.

Draft.19 retains the FACETS lane introduced in draft.17 and the first
paired one-seed RSM/PCM stress pilot: 22 scenarios per model, 44 successful
FACETS 4.5.0 reports, truth-first normalization, and mfrmr readiness capture.
The deliberately disconnected RSM/PCM cells reached `hold_disconnected`, but
the single-bridge cells remained `pass_linked` despite degraded parameter
agreement. This is a diagnosed gap: binary connectivity cannot serve as a
weak-identification gate. M2 must add bridge-strength, articulation,
component-balance, and local-information diagnostics before any freeze.

Draft.19 also adds nine extension scenarios per model and a separate
interaction/bias/PCAR runner. The extension showed that the current audit can
label a two-rater one-rater-per-Person design `pass_linked` even when no
Persons are shared, and can label a PCM dataset `pass` when one category
contains 94.2% of responses and another is unused. The severe category
threshold vector was centered to sum zero and both batches were rerun, so this
finding is not attributed to an avoidable location-constraint mismatch. It
also showed that a weak
planted interaction can be missed by the residual bias screen, that severe
category imbalance can create large spurious fitted interactions, and that
weak-overlap residual PCA eigenvalues can diverge despite nearly identical
row residuals. These are pilot diagnoses, not support claims. M2 must add a
Person-sharing graph and minimum-rater-panel state, model-specific category-
information states, multi-seed interaction/bias operating characteristics,
and null/non-null PCAR calibration before the gate is frozen. FACETS Table 14
bias evidence remains separate until a definition-matched `?B` control and
parser exist.

Draft.20 adds an adversarial divergence audit before any FACETS difference is
allowed to calibrate a tolerance. It reclassifies three draft.19 observations:

- the zero-common-Person two-rater main-effect design has one exact free
  null direction after the declared centering constraints; common Criteria do
  not identify a rater contrast confounded with nested Person-group location;
- the severe PCM row is not a common parameter comparison because FACETS
  dropped unsupported categories separately by Criterion while mfrmr retained
  the declared four-category, three-step rectangular structure; the important
  current defect is false readiness and a normalizer that did not reject the
  dimension mismatch, not a demonstrated likelihood-kernel error; and
- the largest weak-overlap Person differences are FACETS finite adjusted
  extreme displays versus optimizer-dependent finite proxies to theoretically
  unbounded mfrmr JML measures. Nonextreme Person MAE was far smaller and must
  be reported separately.

The repository audit and full interpretation are in
`facets-mfrmr-divergence-audit-0.2.3.R` and
`facets-mfrmr-divergence-audit-record-0.2.3.md`. M2 now requires a constrained
estimability check, a category-map/retained-step comparison contract, typed
extreme-score output, and definition-specific interaction/bias/PCAR contracts
before the next paired pilot. These are prerequisites to tolerance
calibration, not completed release gates.

### Draft.37 near-term corrective program

Draft.21 converted the draft.20 diagnosis into an implementation sequence.
Draft.22 completes the structural WP0 contract and makes that contract the
fixed input to WP1--WP5. Draft.23 begins WP1 with the estimator-specific sparse
linear-block preflight described below. Draft.24 adds the estimator-ecosystem
boundary and makes correction mode part of external comparison identity.
Draft.25 adds the first bounded post-fit information instrument for nonlinear
coordinates without promoting that instrument to a weak-information rule.
Draft.26 makes the nonlinear free-to-model coordinate transformations explicit
and numerically checked while keeping them separate from response-likelihood
identification. Draft.27 combines the additive and log-slope coordinates in
the retained JML GPCM conditional response kernel, while refusing to reuse
that conditional object as an MML person-integrated identification result.
Draft.28 adds a separate MML observed-Person-pattern score decomposition, while
refusing to reinterpret observed-pattern rank as the structural map over all
possible response patterns.
Draft.29 adds the next bounded MML layer: exhaustive finite response-pattern
enumeration and score-outer-product expected information on each retained
Person observation design, while retaining the result as local geometry rather
than a global structural-identification decision.
Draft.30 removes exact duplicate Person-design computation from that bounded
layer by canonicalizing the observation layout and reusing the all-pattern
result only when facet, step, slope, interaction, and applicable latent-
regression design rows are identical.
Draft.31 begins WP2 by separating declared category semantics from
data-supported free-step estimation. It adds a model-scoped preflight, typed
category blocker, parameter-scoped step statuses, and the first exact and weak
support fixtures without adding threshold anchors or a multi-scale API.
Draft.32 begins WP3 with the Person sufficient-score boundary slice. It
separates the unbounded JML primary value from the finite optimizer trace,
distinguishes direct or implicit fixed constraints and constraint-coupled
review cases, preserves finite MML/EAP estimates, suppresses ordinary SE/CI
for typed boundaries, and gives FACETS-style endpoint placement an explicit
display-only meaning. Generalized non-Person and interaction separation, a
named finite adjustment formula, and complete WP4 propagation remain pending.
Draft.33 adds the next WP3 instrument: a bounded linear-program certificate
over the exact retained adjacent-category contrast design. It holds Person
coordinates fixed and reuses the optimizer's facet signs, anchor/group
Jacobians, two-way interaction basis, and step constraints to test each
expanded non-Person facet, interaction, and step target in both directions.
The certificate is stored internally and is not yet promoted over the finite
optimizer iterate in public tables; that promotion requires WP4 propagation.
GPCM log-slope directions, joint Person-structural recession directions,
target-size execution evidence, and general independent solver parity remain
pending. Draft.34 replaces the certificate's dense constraint allocation with
the solver's sparse triplet interface, retains a small dense-reference route,
and adds an independent finite-grid oracle for prespecified low-dimensional
microcases without claiming general solver independence or FACETS-scale parity.
Draft.35 adds the companion joint Person-structural additive cone. It targets
the constraint-coupled extreme Persons left unresolved by draft.32 and all
structural expanded parameters while allowing every retained free Person and
structural coordinate to move together. A prespecified group-constrained
two-Person/two-Item fixture proves the necessary gap: neither coordinate block
contains a recession direction alone, but their joint cone does. Public-table
propagation remains deferred to WP4.
Draft.36 adds a separate nonlinear GPCM slice without pretending that the
linear cone has become nonlinear. With retained Person, facet, interaction,
and step coordinates fixed, it enumerates every ordered positive/negative
pair allowed by the sum-zero expanded log-slope constraint. A pair is
certified only when every positive-group observed category maximizes its
unscaled cumulative adjacent utility, every negative-group observed category
minimizes it, at least one contributing row has a strict utility span, and the
independently reconstructed retained likelihood agrees with the optimizer
objective. The audit records the limiting likelihood and expanded/free
direction loadings. A checkerboard fixture with fixed Persons exposes one
slope tending to infinity and the other to zero despite finite optimizer
output. Its unanchored counterpart is a required adversarial negative: it has
no strict slope-only ray at the retained symmetric point, yet has an improving
path when Person coordinates move jointly. Consequently `scope_complete` is
separate from `structural_identification_complete`, and a none-certified
result can never become a finite-GPCM claim.
Draft.37 begins WP4 with one runtime fit-readiness builder. It stores the
Input, Estimability, Category, Boundary, and Numerical component rows and
derives `FitReadiness`, the conservative compatibility `InferenceReady`
scalar, all reason codes, and audit provenance once. Native fit summaries,
`summary(fit)`, results bundles, convergence consumers, and plot-readiness
screening now consume the stored fit record. MML is not downgraded merely by
an inapplicable JML audit. Applicable incomplete audits and genuinely
unpropagated structural or slope targets fail closed, while a joint cone made
only of already typed free extreme-Person directions does not create a second
false candidate. The explicit legacy adapter returns `legacy_unknown` and
never promotes an old Boolean. Convergence, summary, results, and fit-plot
entry points all pass saved pre-contract objects through that adapter; a
synthetic old object with successful optimizer fields remains review-only.
The contract identifier is user-safe and does not expose internal work-package
labels.

Draft.38 adds the first non-Person parameter slice and makes the GPCM
asymmetry explicit. The readiness contract moves to v2 because a slope can
have certified low and high paths simultaneously (`unbounded_both`) and an
applicable estimator-specific audit can remain `not_evaluated`; neither state
was representable in v1. Certified fixed-additive JML slope paths receive
typed primary boundaries. A scoped negative retains only a finite numerical
trace because Person, facet, step, or slope coordinates may still move jointly.
MML receives no conclusion from the conditional JML certificate and remains
review-only until a marginal boundary argument is implemented. Local Hessian
SE/CI values are retained under `Optimizer*` names but ordinary inferential
fields are withheld. The one-level unit-slope reduction is fixed rather than
estimated. This remains a partial WP4 implementation:
full facet/interaction/step parameter records, remaining reports/exports/replay consumers,
serialized 0.2.2 migration evidence, and WP5 metric eligibility remain open.

Draft.39 closes a misleading summary path and decomposes the GPCM comparison
problem before more external runs are attempted. `summary.mfrm_fit()` no longer
places a finite optimizer slope into the primary minimum, maximum, or geometric
mean when parameter readiness is absent. Primary summaries remain missing;
the numerical stopping values are labelled `Optimizer*`, accompanied by the
parameter-status mixture and counts eligible for SE and external comparison.
The public scope guide now also states that FACETS' reported element
discrimination is a post-fit Rasch diagnostic, TAM's free GPCM slope route is
not its many-facet route, and immer has no matched free-GPCM MFRM estimator.
Those facts change the validation design: FACETS and immer cannot be treated as
free-slope numeric gold standards, and a TAM row is eligible only after an
exact re-expression and identification audit.

Draft.40 adds the first bounded joint nonlinear GPCM path family. For each
ordered positive/negative slope pair, the expanded log-slope rates are fixed
at `+1` and `-1`, while all constrained additive coordinates may move along a
sparse linear-program direction. A certificate requires a strictly favorable
observed-category direction in the high-slope group, weak support in every
unchanged-slope group, a strictly favorable aggregate leading term as the
low slope tends to zero, exact reconstruction of the retained likelihood, and
an analytic boundary likelihood no worse than the retained fit. The
unanchored two-Person checkerboard now supplies a positive case missed by the
fixed-additive slope check; a repeated balanced-outcome design is the negative
control. Direct likelihood paths, row reversal, workload ceilings, solver
failure, and MML non-reuse are tested. This is deliberately recorded as a
competitive boundary candidate, not a global GPCM result: the primary value
and ordinary uncertainty remain unavailable, a negative result is scoped to
this path family, and more general rate vectors, curved paths, and the marginal
MML problem remain open.

Draft.41 makes the prespecified GPCM stress envelope executable without
pretending that a pilot manifest is confirmation. The repository-only
`gpcm-stress-covering-grid-0.2.3.R` runner constructs a deterministic mixed-
level pairwise covering array over 12 axes. The pilot manifest contains 70
cells, including 12 mandatory adversarial corners, and covers all 1,330
required two-axis level combinations. Separate `PCM_JML` and `PCM_MML` cells
prevent the lower-model reference from being hidden inside a free-slope GPCM
label. The smoke, pilot, and confirmation seed ranges are disjoint; only the
confirmation profile is labelled as confirmation, and confirmation remains
unauthorized. The current public simulator cannot generate a genuine
one-slope-level case because it requires at least two criterion levels while
GPCM requires the slope and step facet to coincide. Those cells remain an
explicit non-executable gap rather than being silently replaced by equal true
slopes across two estimated slope levels.

The runner applies connected sparse, one-bridge, zero-shared-Person, routed,
and disconnected assignments; MCAR, Person-, rater-, and outcome-dependent
deletion; rare, dominant, floor, ceiling, internal-zero, and boundary-zero
category support; repeated cells, explicit Occasion, unequal and zero weights;
Person-by-rater and slope-related interactions; and local-dependence, bias,
and drift signals. Every retained dataset receives a digest and support record,
including category counts, common-Person counts, duplicate counts before and
after Occasion, and positive-weight rows. Fit results keep primary slope
availability, optimizer-only log-slope RMSE, readiness, boundary state,
false-ready status, and optional exploratory residual PCA separate. All
external numeric comparison flags remain false, all numeric thresholds remain
`pilot_required_not_frozen`, and every output is `calibration_only` until the
matched estimator/normalizer and candidate contracts are complete.
The hashed one-seed smoke outcome is retained in
`gpcm-stress-covering-grid-smoke-record-0.2.3.md`; it records six executed
cells, one known generator gap, zero runner failures, zero false-ready rows,
and zero external numeric-eligible rows without promoting those counts to
recovery, coverage, diagnostic-sensitivity, or release evidence.

Draft.42 adds the isolated-attribution layer required by the draft.41 smoke
diagnosis. `gpcm-isolated-attribution-pilot-0.2.3.R` fixes one reference data-
generating cell and changes exactly one of 11 axes per challenge. Every
retained data cell is regenerated under the same seed for four explicitly
different analysis routes: GPCM-JML, GPCM-MML, PCM-JML, and PCM-MML. A route
set is usable only when all four retained-data hashes agree. Person estimates
retain joint-fixed versus marginal-EAP labels; PCM is an exact truth-recovery
route only for the unit-slope reduction; step, slope-level, rater, and Person
dimension changes carry parameter-class coordinate exclusions. Finite GPCM
optimizer slope error remains a diagnostic trace and cannot enter primary
recovery while slope comparison eligibility is absent.

The structural pilot manifest has 40 arms and five common-seed replicates,
giving 800 route rows. It includes an explicit one-slope-level generator gap
and reserves a disjoint confirmation seed range. Full execution is resource-
significant and requires an explicit authorization after dry-run inspection;
confirmation cannot be authorized through this runner. The hashed draft.42
smoke runs 24 rows spanning the reference, two raters, internal category zero,
zero shared Persons, Person-by-rater interaction, and local dependence. It
records 22 fitted objects, two expected JML fail-closed results, zero retained-
data identity violations, zero false-ready rows, zero primary-slope recovery-
eligible rows, and zero external-numeric-eligible rows. Ready PCM rows under
planted interaction/local dependence demonstrate that numerical readiness is
not model adequacy. Residual PCA differences remain descriptive until a
replicated null/non-null calibration freezes no earlier than WP7.

Draft.43 adds a guarded replicated-feasibility layer and, more importantly,
records an internal-invariance failure discovered before external comparison.
`gpcm-attribution-replicated-pilot-0.2.3.R` prespecifies 10-arm feasibility,
30-arm core, and 40-arm expanded tiers, retains the four-route/data-cell
contract, reports Wilson intervals and Monte Carlo standard errors, and adds a
complete route/hash ledger. Core and expanded execution remain explicitly
guarded; the runner cannot authorize confirmation or freeze a threshold.

The first 80-route feasibility analysis exposed implausible MML-only Person
recovery and residual-PCA values after category- or outcome-dependent row
filtering. The cause was not a GPCM kernel or marginal-likelihood difference:
Person-pattern posterior rows retained first-observed order, but the fitted
Person table attached internal Person-level order. This paired EAP and
posterior SD values with the wrong Person labels. Commit `655f6bf` aligns the
posterior summaries by their returned Person indices and adds a row-reversal
regression. On the exact same manifest and retained-data hashes, only eight
MML Person/EAP-derived diagnostic rows changed; every structural recovery,
objective, support, readiness, boundary, and reason field remained unchanged.
The corrected internal-zero/outcome-deletion Person correlations returned to
about 0.93--0.95 and the spurious PC1 values near 13--16 returned to about
2.1--2.6. Pre-fix MML Person and EAP-derived diagnostic rows are invalidated.

The same audit also showed that optional validation capability is evidence
identity. Without `lpSolve`, PCM-JML additive recession auditing correctly
became `not_evaluated` and readiness fell to review; this was a fail-closed
capability omission, not a statistical failure. The authoritative v4 rerun
used `lpSolve` 5.6.23 and reproduced all pre-fix readiness strings while
retaining only the intended EAP corrections. It completed 80/80 routes, 20/20
paired cells, zero identity violations, zero fit failures, and zero false-
ready rows. Two replicates cannot calibrate a rate or diagnostic rule: even
0/2 has a Wilson 95% upper bound near 0.658. The run remains feasibility-only.
Its 1,072-second wall time versus 405.4 seconds of recorded fit time also makes
atomic checkpoint/resume, capability hashing, and staged PCA prerequisites to
the 600-row core tier, not optional conveniences. Full identity, hashes,
invalidation rules, and next gates are in
`gpcm-attribution-replicated-feasibility-record-0.2.3.md`.

Draft.44 removes the all-or-nothing writer as a prerequisite to the guarded
core tier without changing its statistical authorization. The replicated
runner now checkpoints a complete four-route `DataCellId` rather than an
individual route. This is the smallest reusable unit on which common retained-
data identity is auditable. A same-directory temporary RDS must round-trip and
match its payload hash before an atomic rename publishes the checkpoint;
existing targets are never overwritten.

Checkpoint-v1 identity binds the selected and declared manifests, tier,
replicates, optimizer/quadrature/PCA controls, the content of the actually
loaded mfrmr runtime, the three validation runners, R/platform/RNG, numerical
runtime reporting, and the versions, runtime content, or absence of `digest`, `Matrix`,
`lpSolve`, and `psych`. Absolute paths are provenance fields but not hash
inputs. Resume is explicit and rejects schema, execution, cell-manifest,
payload, ScenarioId, route-set, DataCellId, or declared-manifest disagreement.
Unexpected RDS files fail closed; orphan unpublished partial files are ignored.

Aggregate outputs receive an atomic completion marker only after every listed
CSV/RDS and default checkpoint hash is known. Synthetic interruption,
configuration mismatch, orphan-partial, artifact modification, and clean-run
equivalence tests pass. A real reference cell also agrees with the old
four-route execution on every result field except elapsed runtime and is
identical after checkpoint reload. The historical draft.43 v4 artifacts
predate checkpoint-v1 and cannot be resumed or relabelled. Full identity,
hashes, and scope are recorded in
`gpcm-attribution-checkpoint-resume-record-0.2.3.md`.

Draft.45 closes the small-design cross-model MML metamorphic slice without
freezing a numerical tolerance. The repository-only runner prespecifies ten
semantic-equivalence transformations across RSM, PCM, and bounded GPCM:
row reversal/permutation, unused and reordered factor levels, nonlexical
Person/facet labels, missing outcomes versus explicit filtering, zero weights
versus filtering, appended zero-weight levels, positive non-unit weights, and
a combined filter/label/factor transformation. It compares Person posterior
summaries, facets, steps, GPCM slopes, retained-observation expectations and
residual quantities, objective values, semantic keys, and result states.

The first execution deliberately exposed an orchestration defect: runner
controls `maxit = 100`, `reltol = 1e-7` permitted optimizer code zero while
both relabelled fits remained at `NumericalState = review`, producing five
screen failures. The response was not to widen tolerances. The authoritative
v3 uses the public production controls (`maxit = 400`, `reltol = 1e-9`), which
activate bounded gradient polishing, and requires both fits to be numerically
ready. All 30/30 comparisons then passed; maximum objective, parameter, and
retained-observation differences were `3.112007e-09`, `1.862395e-05`, and
`6.113984e-06`. Missing/zero-weight encodings retained their intentionally
different input provenance while preserving every downstream result. The
runner also rejects an existing output directory so a prior bundle cannot be
overwritten; intermediate v2 had identical metric maxima before this storage
guard was added. The thresholds remain `pilot_required_not_frozen`; this is a
software-property pilot on one design, not recovery, coverage, or external
agreement. Full
identity and hashes are recorded in
`mml-metamorphic-grid-record-0.2.3.md`.

Draft.47 begins target-scale execution without relabelling it as a statistical
pilot. A guarded runner executes all six previously declared executable
`target_sparse` cells at 400 generated Persons, one replicate per cell. The
cells span GPCM/PCM, JML/MML, 2--12 Raters, sparse/disconnected assignment,
multiple missingness and category-support challenges, weights, Occasion,
interactions, bias/drift, local dependence, and residual PCA. All six ran in
about 110 seconds on the recorded R 4.5.1 runtime, with zero unexpected runner
failures and zero false-ready rows. Two exactly rank-deficient disconnected
controls failed before optimization; two returned blocked/review states; one
PCM JML fit retained extreme-Person exclusions; and one imbalanced/missing
PCM MML fit was inference-ready. That ready cell is a replicated recovery and
diagnostic target, not proof of adequacy. The mixed-adversity free-slope GPCM
MML cell reached its iteration limit and remained blocked.

The target PCA route also exposed a computability-contract gap: a returned
exploratory object can coexist with `psych` messages that the smoothed-
correlation determinant or objective is undefined. Condition-message capture,
matrix-rank/smoothing state, and a stricter PCA availability vocabulary are
required before diagnostic promotion. The authoritative v3 bundle embeds an
artifact inventory and validates hashes, sizes, safe paths, execution identity,
and confirmation prohibition in a fresh session. Earlier v1/v2 bundles are
retained as superseded evidence-integrity diagnostics. Full results and hashes
are in `target-scale-sparse-stress-pilot-record-0.2.3.md`.

Draft.47 closed the atomic-resume slice of WP7, the current small-design MML
metamorphic slice of WP6, and the first target-scale construction/runtime
feasibility slice. It did not close target-scale support bounds. Its immediate
open items were balanced RSM/PCM/GPCM baselines, weak-bridge gradients, OS
peak-resident-memory measurement, the declared five-replicate pilot,
recovery/coverage, malformed-input and replay properties, active population/
anchor/interaction variants, external normalization, statistical criterion
freeze, and confirmation. Draft.48 addresses only the first three at a one-
replicate calibration level; the wider gates remain open and core confirmation
execution is still unauthorized.

Draft.48 separates scale from adversity in the mixed draft.47 cells. It executes
complete balanced and clean matched-sparse 400-Person RSM/PCM/GPCM baselines,
plus a two-Rater PCM common-Person gradient at 0, 1, 2, 5, 10, 20, and 40.
Each of the 13 data cells is passed unchanged to JML and MML; all 13 pairs have
one data hash. All bridge levels use the same truth seed and one truth hash,
removing the seed confounding discovered in the superseded v1 bridge output.
The authoritative v2 completed all 26 routes with zero unexpected failures,
one expected zero-overlap JML fail-closed route, zero false-ready routes, and
nine inference-ready routes. This remains one-replicate calibration evidence.

The clean baselines materially change the causal diagnosis. At 400 Persons,
complete MML RSM/PCM fits were ready in about one second, whereas every clean
12-Rater/12-Criterion MML baseline completed in 2.5--17 seconds but retained a
terminal-gradient review; GPCM additionally retained an incomplete marginal-
boundary audit. Clean sparse JML RSM, PCM, and GPCM took about 204, 480, and
232 seconds and all reached the fixed iteration limit. Therefore sample size
alone and GPCM nonlinearity alone cannot explain target-scale behavior. JML
free-Person/extreme handling and design dimension, and MML numerical/boundary
contracts, require distinct profiling lanes.

The common-truth bridge traces are nonmonotone. Zero-overlap JML fails exact
estimability, while zero-overlap MML remains review-only under
`population_assumption_linked`. Positive-overlap MML routes are numerically
ready, but one seed cannot define adequate overlap. Positive-overlap JML moves
between `ready_with_exclusions` and iteration-limited blocked states. Binary
connectivity, numerical readiness, or the best observed RMSE must not become a
support threshold. Replicated estimator-specific recovery, local information,
extreme-score, anchor, interaction, imbalance, and failure strata remain
required. Process-lifetime peak working set is now recorded, but isolated-
process memory attribution and capacity limits remain open. Full results and
hashes are in `target-scale-baseline-bridge-pilot-record-0.2.3.md`.

Draft.49 decomposes the JML computation hypothesis before increasing the full
stress grid. Its 14 PCM data cells and 34 routes vary nested Person/row counts,
fixed-row Rater-panel topology, fixed-row Criterion/step panels, fixed-
parameter row exposure, and forced extreme Persons. Each cell has identical
JML/MML input, and selected JML cells add explicit BFGS/L-BFGS-B controls. All
routes executed with zero unexpected failures and zero false-ready states.
This remains one-replicate 60-iteration calibration, not a runtime envelope,
optimizer rule, recovery result, or estimator ranking.

The complete P050/P100 auto routes used BFGS and were ready. At 217 and 417
free parameters, P200/P400 auto switched to L-BFGS-B and blocked, whereas
explicit BFGS on the same data was ready in similar elapsed time. P200 explicit
L-BFGS-B reproduced auto. The current 200-parameter auto threshold is therefore
an actionable hypothesis for the complete nonextreme Person-size path. It is
not a global fix: R12, C12, and forced-extreme BFGS controls remained blocked.
No threshold changes before a replicated 180--260-parameter cross-model grid
and memory audit.

At 2,400 fixed rows, JML time rose from about 6.6 to 19.0 seconds across the
3--12 Rater panel and from about 6.6 to 15.3 seconds across 4--12 Criteria.
The Rater contrast also introduced 0, 3, and 42 zero-common-Person pairs, so it
is a panel/topology contrast rather than a pure parameter-dimension effect. At
fixed JML dimension 249, 1,200 rows were slower and less well conditioned than
2,400, while the 7,200-row cell was slowest but ready. Forced extremes doubled
P200 total fit time and blocked both optimizers. These nonmonotone results rule
out row count, free dimension, optimizer, or connectivity as a single capacity
rule. These findings made internal phase timing the next prerequisite:
preparation, sparse design/rank, boundary/recession audits, optimizer, and
readiness assembly had to be measured separately before a corrective
implementation. Draft.50 supplies that attribution below. Full Draft.49
results and identities are in
`jml-bottleneck-decomposition-pilot-record-0.2.3.md`.

Draft.50 instruments the exact execution phases before changing optimizer or
capacity policy. The timer is internal, opt-in, attached only after readiness,
and decision-nonintervening. A fixed seven-cell/19-route Draft.49 subset passes
the 18-phase contract with zero false-ready rows. All semantic-result hashes,
readiness states, numerical states, and optimizer methods are unchanged across
the coarse v1, refined v2, and workload-complete v3 bundles.

The profile overturns the leading performance interpretation without
invalidating the separate numerical-readiness finding. Across 12 JML routes,
structural and joint recession audits consume 201.94 of 211.25 instrumented
seconds, while optimization consumes 3.70 seconds. Every Person-fixed
structural audit returns `none_certified` only after enumerating 46--126 target
directions. The joint audit already uses a global-cone screen and enumerates
targets only when that screen certifies a ray. The current optimizer dispatch
can still change terminal-gradient readiness at P200/P400, but it is not the
primary elapsed-time bottleneck.

The immediate Draft.51 change-local hypothesis is therefore an exact
structural global-cone prescreen, not an audit bypass. A negative cone screen
must imply that no target-specific recession direction exists under the same
contrast cone and tolerances. Existing sparse/dense, row-order, finite-grid,
anchor, interaction, dependency, size-limit, solver, and MML guards must match;
positive-cone controls must retain target enumeration. The 19 v3 routes must
retain semantic hashes, boundary/readiness states, and fail-closed behavior
while recording solver-work counters and materially reducing no-cone phase
time. Shared design/contrast construction, reusable LP models or warm starts,
and alternative solvers are later hypotheses. The replicated cross-model
optimizer-dispatch grid remains separate and cannot substitute for this
certificate-preserving performance correction. Full results and identities
are in `jml-phase-profile-pilot-record-0.2.3.md`.

Draft.50 verification covers all 127 package-aware `testthat` files and an
exact 491-entry local source tarball. The exact tarball completes install,
static checks, ordinary examples, tests, and vignette rebuilding under
`R CMD check --no-manual`; the sole NOTE is caused by Rd cross-references to
four unavailable suggested packages. This is not a complete `--as-cran`
result: the current environment lacks ten suggested packages, network access,
and `pdflatex`, and the force-suggests-false `--run-donttest` attempt exceeded
the ten-minute tool bound. These gaps remain release-engineering work and are
not converted into a candidate or `Status: OK` claim.

Draft.51 implements the certificate-equivalent structural global-cone
prescreen. The prescreen uses the same nonnegative observed-category contrast
cone and tolerances as target enumeration: if the maximum summed contrast
margin is not positive, no strictly improving row and therefore no
target-specific certificate can exist. A positive cone retains the full legacy
target enumeration. The audit exposes a versioned state and actual cone/target
LP-call counts; dependency, design, mapping, solver, coordinate, nonzero,
constraint, target-direction, and MML guards remain fail closed.

Adversarial tolerance review rejected direct reuse of the ordinary target LP's
`10 * objective_tolerance` early-negative rule: a `5e-7` contrast can satisfy
the target certificate while an unsafe `1e-7` cone objective tolerance reports
negative. The authoritative prescreen therefore records objective tolerance
`1e-10` and certificate tolerance `1e-7`; the counterexample is a regression.
The pre-guard v4 output is superseded by guarded v5 evidence.

The fixed seven-cell/19-route v5 rerun preserves every v3 and v4 semantic hash,
readiness, numerical, boundary, optimizer, structural, and joint state. On the
same 12 JML fitted objects, screened and unscreened structural target-status
hashes match 12/12. All selected structural cones were negative: 908 legacy
target LP calls became 12 cone LP calls and zero target LP calls. Structural
phase time fell from 139.63 to 13.80 seconds and JML outer-fit time from 212.68
to 86.57 seconds; all 12 JML routes were faster. These one-run PCM values
freeze no performance rule. Positive-cone behavior remains protected by
separated-Rater and interaction fixtures, including sparse/dense, row-order,
anchor, retained-row, size-limit, MML, and injected solver-failure controls.
Full results and identities are in
`jml-structural-cone-prescreen-pilot-record-0.2.3.md`.

Draft.52 attributes the remaining joint recession work without changing the
production audit. Phase schema v6 preserves every v5 semantic, readiness,
numerical, boundary, optimizer, structural, and joint state across the fixed
19 routes. Seven negative joint cones consume 13.53 seconds and no target LPs;
five positive cones consume 48.99 seconds and trigger 346 target LP calls, but
none certifies a selected target direction.

A separate fixed-runtime refit of the three distinct positive-cone cells
projects each stored cone through the full target map. All 43 nonzero cone
coordinates and expanded-target projections are exactly ordinary free extreme
Persons already typed `unbounded_low/high`; structural coordinates and all 118
selected target projections are zero. The existing readiness aggregator
correctly treats such a cone as confirmation of a propagated Person boundary,
so this is computation and responsibility duplication rather than a detected
false-readiness path. A diagnostic row-and-coordinate quotient that profiles
those Persons out is negative in all three cells and takes 0.56 seconds versus
30.16 seconds for the three original joint phases. These unequal one-run
workloads freeze no performance rule.

Draft.53 implements the quotient screen only in conjunction with a guarded
selected-target nullspace test. Each proposed ordinary free extreme Person is
verified as a strict one-sided contrast ray confined to that Person's rows and
absent from selected targets. The row-and-coordinate quotient then receives a
guarded strict-cone LP. A negative quotient may skip enumeration only when
common-column-scaled sparse QR gives stable equal base and target-augmented
ranks at `1e-12`, `1e-10`, and `1e-8`. Rank increase, tolerance sensitivity,
mapping/ray failure, solver failure, or size limits retain the old enumeration
or its old target-limit state.

The target-changing flat-direction counterexample forces fallback despite a
negative quotient strict cone. Real RSM safe, row-order, target-limit,
structural-positive, constraint-coupled, interaction, and bounded-GPCM
conditional-additive controls match complete legacy target states; MML and
readiness remain unchanged. The fixed v8 profile preserves all 19 v6 semantic,
readiness, numerical, boundary, optimizer, structural, joint, and target-status
comparisons. Five routes profile 84 Person coordinates across duplicated
optimizer routes; their three-tolerance rank increments are all zero. Joint
target LP calls fall from 346 to zero, joint phase time from 62.52 to 18.82
seconds, JML outer time from 87.10 to 43.53 seconds, and all-route outer time
from 94.67 to 50.91 seconds. These one-run PCM timings freeze no rule. The
completed v7 bundle is superseded because it hashed but did not print the rank
ladder; v8 is authoritative. Full findings and identities are in
`jml-joint-quotient-nullspace-prescreen-pilot-record-0.2.3.md`.

Draft.53 verification also builds a clean exact 491-entry local source tarball
and passes `R CMD check --no-manual` with `Status: OK`. Tarball and check-log
hashes are kept in the package-external
`.check-draft53-standard-no-manual-v3/verification-receipt.txt` to avoid
self-referential mutation of a packaged roadmap. The first 497-entry artifact
is superseded because it incorrectly included six hidden change-local scripts
and received the corresponding hidden-file NOTE. This is neither an
`--as-cran` result nor a candidate gate pass; full-manual, `--run-donttest`,
dependency-present, external, candidate-linked, and confirmation checks remain
open.

Draft.54 attributes the remaining recession work and implements one optional
shared-geometry path. A single full Person-plus-structural adjacent design,
expanded-target system, and observed contrast is projected onto the exact non-
Person columns/rows for the structural audit and reused by the joint audit.
The path is accepted only after version, state, sparse-object, row, column, and
optimizer-index validation; failed or malformed shared construction is
discarded and both audits rerun their legacy construction. MML does not enter
the path, and no shared object is stored in a fit.

Whole-audit identity, exact sparse-column projection, and core-level fallback
tests pass for RSM, criterion-step PCM, direct/group anchors, interaction,
nonuniform/zero weights, missing-score removal, bounded GPCM's supported common
step/slope facet, and malformed/injected-failure controls. The fixed 19-route
component bundle passes all fits, ordinary phase contracts, component
contracts, canonical Draft.53 comparisons, and false-ready checks. Every JML
route constructs the three shared objects once and neither audit reconstructs
them. Against the same-day Draft.53 canonical replay, combined structural and
joint time falls from 33.00 to 21.07 seconds, JML outer time from 44.12 to 31.71
seconds, and all 12 JML routes are faster. These one-run PCM results freeze no
rule. Full findings and identities are in
`jml-shared-recession-geometry-pilot-record-0.2.3.md`.

Draft.54 verification also builds a clean exact 492-entry local source tarball
and passes `R CMD check --no-manual` with `Status: OK`. Artifact and check-log
hashes remain in the package-external
`.check-draft54-standard-no-manual-v4/verification-receipt.txt` to avoid a
self-referential packaged hash. This is neither an `--as-cran` result nor a
candidate gate pass; full-manual, `--run-donttest`, dependency-present,
external, candidate-linked, and confirmation checks remain open.

The comparison also corrected an evidence-identity defect: the former
serialized target-status hash could differ for `identical()` tables whose R
internal representation differed after projection. The versioned canonical-v1
hash now uses type-explicit values and explicit missing encodings. An unchanged
Draft.53 runtime replay matches the original v8 bundle on all 16 selected
semantic/state fields for all 19 routes; its target hashes change only because
the identity representation changed.

Draft.55 replaces repeated triplet-vector growth in the observed-contrast
builder with exact stored-entry counting, score-specific transition templates,
and one preallocated observation-block fill. The former implementation remains
an internal reference path. A 977-expectation change-local test passes exact
`dgCMatrix` identity for 1--10 steps, zero/dense/sparse designs, category
extremes and imbalance, malformed inputs, observation permutation, zero
columns, two-Rater weighted/missing anchored PCM, interaction RSM, and bounded
GPCM. Five guarded cases with seven alternating-order replicates preserve exact
output identity; median constructor time falls 85.7--99.7% and cumulative R
allocation falls 93.3--99.96%. The allocation metric is not peak RSS and no
performance rule is frozen.

The fixed 19-route component bundle passes every fit, phase, component,
canonical-baseline, and false-ready contract. Against Draft.54, contrast time
falls from 10.28 to 0.11 seconds, combined structural/joint time from 21.07 to
10.64 seconds, and JML outer time from 31.71 to 21.34 seconds; all 12 JML routes
are faster. MML is unaffected. LP solver calls now consume 8.01 of 10.60 JML
component seconds. The constructor v1 evidence is superseded because staging
paths leaked into inventory row names; v2 fixed promotion verification and v3
also unifies installed-package identity with the Draft.49--54 convention. Full
findings and identities are in
`jml-contrast-constructor-pilot-record-0.2.3.md`.

Draft.55 verification also builds a clean exact 493-entry local source tarball
and passes `R CMD check --no-manual` with `Status: OK`. Its CRAN-light test path
has 397 passing expectations, three skips, and zero failures or warnings. A
separate 10-shard regression against the same fixed tarball's installed package
and check-expanded tests covers all 126 test files exactly once: 1,726 tests,
11,945 passing expectations, 83 skips, 38 allowlisted warnings, and zero
failures, errors, or unexpected warnings. The aggregate validates a common
runner/tar identity and every source-test hash. A monolithic `NOT_CRAN=true`
attempt reached the 30-minute ceiling while still in tests and is not a pass or
failure; the sharded result is not represented as a second `R CMD check`.
Artifact, standard-check, and sharded-regression hashes remain in the package-
external `.check-draft55-standard-no-manual-v1/verification-receipt.txt`. This
is not an `--as-cran`, full-manual, dependency-present, external, candidate, or
confirmation pass.

Draft.56 attributes LP-base construction, R-side assembly/dispatch, and
`lpSolve::lp()` execution separately without changing production dispatch. The
authoritative v3 bundle preserves all 19 Draft.55 fixed-route semantic,
readiness, boundary, and target-status comparisons with zero false-ready rows;
the seven MML routes produce no LP events. Across the fixed portfolio plus four
RSM/GPCM controls, 40 bases trigger 40 capacity and eight strictness solves.
Base construction takes 0.06 seconds, run-LP work 8.64 seconds, the underlying
solver 8.58 seconds, and R assembly/dispatch 0.06 seconds. The 99.31% solver
share is one diagnostic run, not a frozen performance rule. v2 records a
99.77% share with identical classification/capacity results, demonstrating both
the stable attribution and the instability of sub-percentage timing claims.

An independent sparse GLPK route matches `lpSolve` on all 40 target results:
32 negative cones, eight certified additive recession directions, and maximum
capacity difference `1.421085e-14`. Thirteen sparse/dense, near-boundary, flat-
direction, and forced-failure controls pass. Additional baseline/instrumented
controls cover a two-Rater missing/weighted RSM, an interaction RSM, a two-
Rater strongly imbalanced bounded GPCM with protected category support, and an
eight-Rater sparse-panel bounded GPCM. All four preserve semantic hashes and
readiness and pass 11 independent comparisons. GPCM coverage remains the
conditional-additive LP; nonlinear slope recession is not closed.

The v1 bundle is superseded for interpretation because it covered only the
fixed PCM routes. v2 adds cross-model controls but lacks the runtime-content
hashes that v3 records for all solver capabilities. The promoted v3 record is
`jml-lp-attribution-pilot-record-0.2.3.md`. `Rglpk` and `slam` remain validation-
only and do not enter `DESCRIPTION`. Because independent timing is single-run
and always follows `lpSolve`, its apparent difference cannot select a solver.

Draft.57 reacquires all 40 Draft.56 targets exactly, representing 28 unique
problem identities, and evaluates `lpSolve` and GLPK with one excluded warm-up
and seven included alternating-order replicates per target. All 560 timed calls
are safe and match the captured production result; all 280 paired comparisons
agree, with 140 first-position and 140 second-position calls per solver. GLPK
totals 13.32 seconds versus 60.05 for `lpSolve`, but this is a calibration
hypothesis rather than a speed or dispatch rule.

The broader qualification rejects immediate GLPK candidacy. Cross-model
generated properties pass 94 of 96 solver rows. Both failures are the same
positive joint RSM cone after deterministic positive row scaling from `1e-3`
through `1e3`: `lpSolve` retains the expected certified capacity 147, whereas
GLPK returns nonoptimal status 1 at the capacity stage. Failure-status controls
also show that `lpSolve` reports the unbounded fixture as status 0 with value
`1e30`, while Rglpk collapses infeasible and unbounded cases to status 1 and
returns status 0 with an `NA` objective for a nonfinite input. External box-
bound and post-solve validation reject all unsafe results, but zero of two
solver routes preserves every requested failure class. Six fresh-process
PCM/RSM/GPCM memory cells complete, yet their process-lifetime peaks do not
freeze an allocation envelope. `CandidateQualified`, `SolverDispatchEligible`,
and confirmation authorization remain false; `Rglpk`, `slam`, and `ps` remain
validation-only.

Draft.58 completes that bounded normalization question without promoting a
solver. Across six positive/negative PCM/RSM/bounded-GPCM sources and six
deterministic scale exponents, all 144 formulation-solver rows retain bound
provenance. Raw formulations qualify 66/72 rows: GLPK fails closed on six
positive joint cones at the larger row-scale exponents. Solver-only L1 row
normalization qualifies 72/72 while retaining original strict objectives,
theoretical bounds, and original-scale post-solve certificates. The formerly
failed RSM cell reproduces 12/12 parent expectations across formulation,
solver, and three independent child processes. Four actual deadline controls
observe worker start, complete the two success children, and kill only the two
forced child trees with exit 15 and no result artifact.

This qualifies normalization only as a bounded hardening candidate. It does
not cure Draft.57's failure-status-specificity limitation, qualify GLPK, alter
`lpSolve`, add dependencies, freeze runtime/capacity criteria, or authorize
confirmation. The solver-local branch now stops unless model-level evidence
shows preventable failures on supported fits. Release-spine priority returns to
topology/exposure-matched target-scale positive RSM/GPCM cones, nonlinear GPCM
slope and curved-path recession, residual-PCA computability, and replicated
ADEMP recovery/coverage. A later production-normalization proposal must bind a
versioned candidate and prove fit-level semantic/readiness invariance; speed or
the present six-source ladder alone cannot reopen dispatch selection.

Draft.59 performs that model-level check and rejects target-scale
normalization. Three 400-Person complete, balanced-sparse, and random-sparse
designs pair RSM and bounded GPCM under exact topology and exposure hashes.
All 64 raw/normalized and `lpSolve`/GLPK rows are fail-closed safe, but only 61
preserve the raw-capacity versus complete-target provenance relation. Raw and
normalized `lpSolve` qualify 15/16 and 13/16 captured problems; both GLPK
formulations qualify 15/16. `TargetNormalizationQualified` and
`ProductionNormalizationNeedObserved` are false, so neither normalization nor
solver selection advances.

The target-scale run exposes a higher-priority reliability problem. A balanced
sparse RSM joint problem records capacity 504 and a strictness failure under
the production two-second native timeout; a matched random-sparse RSM problem
can certify capacity 252 in one execution and fail strictness in another.
Ordinary and capture fits match on five of six routes, while random-sparse RSM
changes from `not_evaluated_solver` to `certified_recession` and drops the
boundary-incomplete readiness reason. A post-failure timeout-zero reference
changes three of ten positive/failed formulation outcomes to certified
original-scale directions. All results remain safe, but safe classification
variation is not an acceptable final numerical contract.

Consequently the solver-selection branch remains closed while a distinct JML
recession-replay blocker opens. Draft.60 must use fresh processes and a frozen
timeout/policy ladder over the captured positive, strictness-failed, and
negative RSM problems, recording capacity and strictness stages separately.
No-timeout execution is attribution only; a bounded retry or other policy must
be deterministic, preserve negative controls, validate every returned
direction on the original scale, and retain an explicit worst-case limit.
Nonlinear GPCM, PCA computability, and ADEMP work remain the subsequent main
spine rather than being displaced by further solver benchmarking.

Draft.60 isolates that replay blocker across seven exact Draft.59 problems,
four policies, and four order-balanced fresh-process repetitions. All 112
workers complete without a parent kill and all final results remain safe. The
current two-second policy has six of seven stable cells and matches the
OS-bounded native-zero reference on only five: problem 8 changes between one
capacity failure and three strictness failures, while problem 13 repeats the
same strictness failure four times despite four reference certificates. Thus
repeatability alone cannot define numerical correctness.

The bounded two-then-eight-second retry and the bounded single-ten-second
policy each produce seven of seven stable cells, match all seven reference
outcomes, and preserve both negative controls. Fifteen two-second stage calls
return status 1; none is accepted. All seven subsequent eight-second retries
and every required ten-second or reference stage return status 0 solutions
that pass original-scale split-box, primal, objective-reconstruction,
target-floor, and certificate checks. The 30-second parent reference completes
without a kill, but native timeout zero remains attribution-only.

Both bounded policies therefore advance only to fit-level comparison. No
policy is selected because the frozen problems do not justify choosing the
retry or single-attempt workload contract from elapsed time. Draft.61 must
repeat the complete Draft.59 fits under validation-only policy wrappers,
preserve optimizer and semantic identities, verify boundary/readiness
propagation and all-target call counts, and define a finite audit-level bound.
Production change, runtime freeze, blocker closure, and confirmation remain
false. Nonlinear GPCM, PCA, and ADEMP work resume after a single replay policy
is either justified at fit level or the supported envelope is explicitly
restricted.

Draft.61 performs the prespecified full-fit comparison over the six exact
Draft.59 RSM/GPCM routes, four policies, and three fresh-process repetitions.
All 72 workers and fits complete safely with zero parent kills and invariant
optimizer hashes. The current two-second policy is stable on five of six
routes and reference-matched on only four; balanced-sparse RSM is a stable
false negative and random-sparse RSM is unstable. Both bounded candidates are
stable and reference-matched on all six routes while preserving all-target
call sequences, readiness consequences, and original-scale certification.

`bounded_single_10s` is selected only as the Draft.62 implementation
candidate. Under the frozen equal-20-second maximum positive-target bound it
uses no more solver attempts than the retry policy in all 18 matched
route/replicate cells and fewer in six, for 66 versus 77 attempts. Elapsed time
does not enter selection. Production change, replay-blocker closure, runtime
freeze, checklist promotion, and confirmation remain false. Draft.62 must
implement the policy explicitly and rerun affected unit, target-scale,
full-regression, and package-check evidence before the blocker can close.
General nonlinear GPCM, PCA computability, and ADEMP recovery/coverage remain
separate open work and must not inherit a pass from this conditional-additive
fit-policy result.

Draft.62 implements the selected bounded single-ten-second policy as the
versioned internal contract `mfrmr-jml-recession-fit-policy-v1`. The additive
structural and joint recession audits now give each capacity and strictness
stage one native ten-second attempt, do not retry an unaccepted result, and
retain a maximum 20-second native allowance for a positive target that needs
both stages. Nonzero or malformed solver results still fail closed and every
accepted direction still passes the original-scale certificate. This is a
fit-policy change only: the likelihood, optimizer, parameterization,
readiness derivation, fitted-object schema, exported API, and nonlinear GPCM
joint-pair audit are unchanged. In particular, the nonlinear GPCM audit keeps
its separate two-second default because Draft.61 supplied no evidence for
changing it.

The post-implementation native exercise observes rather than replaces the
production target-LP route. Across the same six complete, balanced-sparse,
and random-sparse RSM/GPCM routes and three fresh-process repetitions, all 18
fits complete safely with no parent kill. All 18 reproduce the selected
Draft.61 candidate's complete result identity and target-call outcome; the 51
native target calls use ten-second inputs, require 66 solver attempts, and
produce six of six stable route cells. The final exact tarball has SHA-256
`7ceb2848958f2f70084e987342eb3e58e6a38b2b41964ceb0d385ea276d92624`.
Its sharded full non-CRAN regression covers all 129 test files with 13,172
passing expectations, 38 expected fail-closed warnings, 23 optional-capability
skips, and zero failures or errors. Its temporary-filesystem package check
completes code, tests, examples, and vignettes with one offline optional-
Suggests Rd-cross-reference NOTE and no WARNING. This is not a complete-
dependency, manual, `--as-cran`, or release-candidate check.

Once those final source-linked checks pass, the narrow recession replay
blocker is resolved and the selected policy may remain in production. That
decision does not freeze a supported workload envelope, promote any checklist
criterion, or authorize confirmation. WP6 therefore returns to nonlinear
GPCM joint geometry, residual-PCA computability, broader sparse/active-
structure stress, and replay serialization. WP7 still owes replicated
platform profiling, ADEMP recovery and coverage, metric-specific external
eligibility, Monte Carlo precision, candidate identity, and the complete
confirmation plan.

Draft.51 verification exercises all 127 package-aware test files. The exact
491-entry source tarball, SHA-256
`bd72d5256d4f721ed735d08306bf6b8cba029108c913707b942095070d56a1df`,
passes `R CMD check --no-manual` with `Status: OK`; its check-log SHA-256 is
`d267352a743fed66d215e42bc57d88bc7f0ad7e948e6d74591a451f13b78e061`.
The repository-only runtime-identity test passes separately against the fixed
installed Draft.51 package. This is not `--as-cran`, a candidate, or a release
gate pass: manual, `--run-donttest`, dependency-present, external, and later
candidate-linked checks remain open.

### GPCM discrepancy decomposition and stress envelope

No scalar "FACETS minus mfrmr" or "TAM minus mfrmr" result is interpretable
until the following layers have been separated. A difference discovered in an
earlier layer blocks numeric aggregation in every later layer; it is recorded
as a specification difference, not repaired by choosing a favorable output
column or rescaling after results are seen.

| Layer | Adversarial question | Required evidence before comparison | Failure classification |
| --- | --- | --- | --- |
| Response kernel | Do cumulative adjacent-category utilities, signs, category origins, and observation weights define the same probabilities? | Probability and log-likelihood equality at prespecified parameter points, including K=2 and unit-slope reductions. | `different_model_kernel` |
| Active structure | Does every row activate the same Person, facet, interaction, step, and slope term? | Row-level design digest and retained-row identity; structural absence is distinct from missing data. | `different_active_design` |
| Step structure | Are thresholds common, scale-specific, or element-specific, and are empty internal categories retained, collapsed, or rejected? | Declared/observed/category maps, free dimensions, anchors, and transformed threshold equality. | `different_category_or_step_estimand` |
| Slope structure | Is discrimination fixed, jointly estimated, post-fit diagnostic, grouped, or designed; which facet indexes it? | Parameter-role map and proof that the slope enters the fitted likelihood. | `different_slope_estimand` |
| Identification | Which location, slope, and latent-variance constraints define the numerical scale? | Analytic transformation plus likelihood and Jacobian checks; transformations are frozen before output is viewed. | `identification_not_matched` |
| Estimator | Are Persons optimized, integrated, conditioned out, adjusted, or hierarchically modeled? | Method, adjustment, quadrature/conditioning, prior/population, and extreme-score convention identity. | `different_estimator` |
| Global geometry | Can Person, facet, step, and slope coordinates escape jointly even when a conditional slice is bounded? | JML joint nonlinear and MML marginal boundary audits with positive and negative controls. | `boundary_not_evaluated` |
| Information | Is uncertainty based on local observed, expected, sandwich, profile, bootstrap, or posterior information? | Parameter-ready estimand plus estimator-specific coverage; local optimizer Hessians remain diagnostic traces. | `uncertainty_not_comparable` |
| Data support | Do missingness, sparse bridges, two-rater overlap, weights, duplicate cells, and category imbalance leave the same effective information? | Retained contribution digest, topology and local-support strata, and zero false-ready exact controls. | `support_not_matched` |
| Diagnostics | Are bias, interaction, residual PCA, fit, and discrimination outputs fitted parameters, conditional screens, or post-fit summaries? | Named estimand, conditioning set, null/non-null operating characteristics, and multiplicity policy. | `diagnostic_not_parameter_agreement` |
| Output transform | Are logits, orientations, user scales, endpoints, finite adjustments, and labels identical? | Reversible transform record; extended-real boundaries never enter finite MAE/RMSE. | `output_transform_not_matched` |

The GPCM simulation program uses a prespecified covering design rather than an
uninterpretable full Cartesian product. Every core seed is crossed with the
mandatory corner cases below, while additional pairwise combinations fill the
covering array. Draft.41 instantiates this as 70 pilot cells covering all 1,330
two-axis level combinations. Discovery, calibration, and confirmation seeds
remain disjoint.

| Axis | Required levels | Why it can expose a false agreement or false difference |
| --- | --- | --- |
| Estimator | JML; MML-direct; applicable lower-model reference | Conditional and marginal boundary or uncertainty evidence is not transportable. |
| Slope levels | 1, 2, 4, and at least 12; balanced and highly unequal exposure | One level is fixed PCM; two levels maximizes constraint coupling; many levels tests sparse coordinate scaling. |
| True slope spread | zero; mild; strong; near-zero/high pair; monotone and non-monotone association with severity | Separates exact reduction, useful discrimination, confounding, and boundary behavior. |
| Categories | K=2, 3, 5, 7; different K only as a deliberate unsupported/multiple-scale control | Checks binary reduction, threshold dimension, and the present single-scale boundary. |
| Category prevalence | balanced; rare interior; dominant middle; floor; ceiling; internal zero; boundary zero | Distinguishes weak information, exact step recession, Person extremes, and arbitrary category collapsing. |
| Rater panel | 2, 3, 6, and many; complete overlap, one shared Person, and zero shared Persons | Separates algebraic identification from fragile or absent empirical linkage. |
| Assignment | complete; sparse connected; weak bridge; disconnected; rater-by-proficiency routing | Tests topology, informative assignment, and latent-distribution sensitivity. |
| Missingness | none; MCAR; Person-dependent; rater-dependent; category/proficiency-dependent | A common missing rate can conceal different effective likelihoods and biased slope recovery. |
| Cell structure | unique cells; repeated cells treated as independent; explicit Occasion; unequal weights; zero weights | Distinguishes input multiplicity from modeled dependence and retained-row identity. |
| Interactions | none; Person-by-rater; rater-by-criterion; slope-correlated and slope-orthogonal | Detects whether free slopes absorb local bias or whether omitted interaction is misread as discrimination. |
| Diagnostics | residual PCA null/local-dependence signal; bias null/non-null; rater severity drift | Tests Type-I proxy and sensitivity separately; no diagnostic threshold is selected from the confirmation data. |
| Sample size | small, standard, and target-scale sparse | Exposes incidental-parameter trends, quadrature limits, dense allocation, and execution ceilings. |

Each eligible cell reports parameter bias/RMSE, supported SE availability and
coverage, primary-versus-optimizer classification, false-ready rate, fit and
parameter failure rates, category-support decisions, transformation residuals,
runtime/memory, and Monte Carlo uncertainty. Diagnostic cells additionally
report null flag rate, signal sensitivity, target localization, and the rate at
which a slope absorbs a generated interaction. Results are stratified by
estimator, support condition, parameter class, and external program/mode;
pooled averages cannot satisfy a blocker.

External roles are fixed as follows:

- ConQuest 5.47.5 `scoresfree` is now the candidate bounded-GPCM MML
  reference for the exact item-only active-latent-regression stratum. The
  transform is `z=(theta-beta_0)/sigma`, `beta_CQ=beta/sigma`,
  `Tau_i,CQ=sigma a_i`, `delta_i,CQ=a_i(delta_i-beta_0)`, and
  `step_ik,CQ=a_i step_ik`. Default unconditional MML, JML free-score,
  generalized-item multifacet, and multidimensional rows are different
  strata and remain rejected or deferred. This narrow kernel/integration
  reference cannot close Criterion- or Rater-owned MFRM evidence.
- local FACETS 4.5.0 supplies the RSM/PCM and fixed/equal-discrimination
  many-facet reference plus deliberately different post-fit discrimination,
  bias, interaction, and residual outputs. Table 7 discrimination is never a
  free-slope recovery target. The published 4.5.1 changes concern the R
  G-theory menu, display/report fixes, missing-label reporting, and Table 7
  subgroup t-test precision/variance; none authorizes transporting 4.5.1
  estimation claims into the local 4.5.0 run. The version difference is kept
  as provenance and sensitivity context, not a stop rule.
- TAM 4.3-25 `tam.mml.2pl(..., irtmodel = "GPCM")`, grouped GPCM, or
  `GPCM.design` is the candidate free-slope MML reference only for a design
  that can be re-expressed exactly. `tam.mml.mfr()` cannot supply estimated
  slopes, so combining its facet design with a separate slope output is
  prohibited.
- immer 1.5-13 supplies PCM-design JML/CML/CCML reductions and HRM
  alternative-model challenges. It supplies no free-GPCM numeric gold
  standard.
- an independent package-native probability/objective/gradient oracle remains
  mandatory even where an external result is eligible; software agreement
  alone cannot validate a shared convention error.

Source identities for this decomposition are the FACETS 4.5.1 manual and
official change log retrieved 2026-08-04, the CRAN TAM 4.3-25 reference manual,
and the CRAN immer 1.5-13 reference manual. Their URLs and retrieval dates
belong in the external candidate manifest; a version change creates a new
stratum rather than silently replacing these inputs.

Draft.46 rechecks those official sources on 2026-08-05 and changes roadmap
governance after the draft.45 metamorphic pass. CRAN still distributes mfrmr
0.2.2, TAM 4.3-25, and immer 1.5-13; FACETS 4.5.1 remains the current upstream
release while the licensed local 4.5.0 executable remains the required primary
execution stratum. No comparator-version rebase is needed. The substantive
change is portfolio control: 87 checklist rows cannot be interpreted as 87
undifferentiated serial release blockers.

The 0.2.3 exit decision now has three portfolios:

| Portfolio | Meaning | Release treatment |
| --- | --- | --- |
| `release_spine` | Candidate identity; core numerical/readiness guards; ADEMP recovery and failure-mode envelope; sparse target envelope; minimal metric-matched external overlap; public support envelope; exact-candidate engineering. | Must pass for the frozen candidate. |
| `claim_conditional` | GPCM primary slope/uncertainty, JML uncertainty or adjustment, automatic IC ranking, inferential diagnostics, dimensionality consequences, and external aggregation beyond a matched metric-mode slice. | Blocks that claim, not automatically the entire release. Unfinished claims must be disabled, remain unavoidably caveated/exploratory, or be deferred on every public surface. |
| `deferred` | Native multidimensional, CML/CCML, HRM, posterior-predictive/MCMC/heavy backends, unrestricted GPCM/ecosystem parity, FACETS-scale capacity parity, 0.2.4 calibration, and 0.2.5 multiple-scale work. | Does not block a bounded 0.2.3 unless public scope is deliberately expanded. |

No existing checklist row is deleted or promoted by this reclassification.
The next governance artifact must map each `(Gate, Item)` to one portfolio and,
for every conditional claim, name the fail-closed fallback. Until that
machine-readable profile is reviewed, the current checklist remains an
inventory rather than a release-minimum count. Full reasoning and official
source URLs are recorded in `roadmap-reassessment-record-0.2.3.md`.

The program's objective is not to maximize new diagnostics. It
is to establish one source of truth for whether a fit, a parameter, and an
external comparison are usable, and to make every downstream surface consume
that source rather than reconstructing readiness independently.

The dependency order is:

```text
WP0 contract/fixtures
  -> WP1 constrained estimability ----+
  -> WP2 category/step support -------+-> WP4 readiness propagation
  -> WP3 JML boundary/extreme states -+       -> WP5 eligible comparison slices
                |                              -> WP6 internal scale/performance
                +-> WP7 design/precision prespecification

Frozen release-spine profile + affected WP1--WP6 slices + candidate identity
  -> WP7 confirmation
```

WP1--WP3 may use separate fixtures, but a claim is not complete until WP4
proves that its state reaches every affected summary, diagnostic, report,
plot, export, and replay surface. WP5 accepted/rejected fixtures may proceed
for stable RSM/PCM metric slices while unrelated GPCM or diagnostic propagation
remains open. WP6 construction/runtime work may proceed in parallel when it
makes no inferential promotion. WP7 may prespecify replication, MCSE, seeds,
and manifests, and may run calibration pilots for explicitly stable slices.
Any later code/contract change invalidates its affected rows by dependency
identity. Confirmation remains prohibited until the release-spine profile,
affected WP1--WP6 slices, criteria, and candidate identity are frozen.

| Work package | Depends on | Current state | Implementation boundary | Required exit artifact |
| --- | --- | --- | --- | --- |
| `WP0-READINESS-CONTRACT` | draft.20 diagnosis | `complete_structural_v3` | Freeze internal state names, scopes, severity/precedence, condition classes, object fields, legacy-object behavior, and exact adversarial fixtures before changing fit logic. | `readiness-contract-0.2.3.md`, its repository validator, 36-row fixture registry including nine GPCM slope states, and privacy/semantic tests; no external tolerance. |
| `WP1-ESTIMABILITY` | WP0 | `in_progress_mml_all_pattern_design_reuse` | Build the estimator-specific free-parameter map and constrained design; detect structural aliases before optimization; distinguish exact alias from weak fitted information. | Unit/property tests, alias diagnostics, sparse-design benchmark, and zero false-ready exact controls. |
| `WP2-CATEGORY-STEP` | WP0 | `in_progress_support_preflight` | Audit declared, observed, retained, free, fixed, and unsupported category/step coordinates globally and by current `step_facet`; do not add threshold anchors. | RSM/PCM/GPCM reduction and missing-category fixtures plus parameter-scoped status tables. |
| `WP3-JML-BOUNDARY` | WP0 | `in_progress_bounded_joint_nonlinear_gpcm_paths` | Detect JML element separation/extreme sufficient scores on the actual contributing row pattern; replace optimizer-dependent finite primary values with typed boundary states. The Person primary-state slice, sparse-triplet Person-fixed structural certificate, companion joint Person-structural additive cone, retained-additive GPCM slope-only monotone paths, and ordered-pair linear-additive/constant-log-slope joint path family are implemented. Positive joint paths remain candidates because the GPCM likelihood is globally non-concave; negative results are scoped. More general rate vectors, curved paths, global arguments, independent general solver parity, broader model/basis properties, and target-scale evidence remain pending. | JML extreme/nonextreme fixtures, MML non-reduction guard, constrained facet/interaction/joint/slope-path certificates, sparse/dense and independent microcase parity, nonlinear joint-path positive and negative controls, and explicit optional-display contract. |
| `WP4-READINESS-PROPAGATION` | WP1--WP3 | `in_progress_gpcm_joint_candidate_slice` | Derive fit-, parameter-, and output-level readiness once and propagate it without surface-specific reinterpretation. The fit record, deterministic precedence, conservative scalar, fail-closed synthetic legacy-object path, summary/results/convergence/plot front doors, target-aware unpropagated-candidate rule, typed slope-only GPCM boundaries, and candidate-specific joint GPCM reasons under contract v3 are implemented. Competitive joint candidates remain `not_evaluated` with no primary value or ordinary uncertainty; complete facet/interaction/step and remaining output propagation depend on unfinished WP1--WP3 states. | Cross-surface snapshot/semantic tests and a real serialized 0.2.2-object migration fixture. |
| `WP5-COMPARISON-CONTRACT` | affected WP4 slice | `in_progress_core_slice_unblocked` | Make FACETS, TAM, immer, and other external normalization metric-specific and fail closed before numeric aggregation; identify estimator, adjustment, person treatment, and software stratum explicitly. Begin deterministic accepted/rejected fixtures and stable RSM/PCM metric slices now; unrelated GPCM, diagnostic, CML/CCML, and HRM rows remain ineligible until their own dependencies pass. | Eligibility/rejection ledger with denominator accounting, method-mode identity, and no silent row loss. |
| `WP6-SCALE-AND-ADVERSARIAL` | affected WP1--WP4 slice | `in_progress_replay_blocker_resolved_nonlinear_gpcm_pca_ademp_resume` | Verify sparse computation, basis invariance, row-order and label invariance, malformed-input behavior, optional-capability fail-closed behavior, and target-size runtime/memory without claiming FACETS capacity parity. Drafts.43--61 establish execution identity, exact guarded reductions, sparse construction, solver attribution, rejected alternatives, and selection of the bounded single-ten-second candidate. Draft.62 implements that policy for additive structural/joint audits and reproduces all 18 selected-candidate result identities and call outcomes over the six target-scale routes, with affected regression and package evidence bound to the implementation record. The narrow native-timeout replay blocker is resolved; no capacity or runtime envelope is frozen. Resume nonlinear GPCM joint geometry, PCA computability, serialization/replay, and broader active-structure grids. | Benchmark envelope and metamorphic/negative-test report; capability manifest; no dense design allocation at target sizes. |
| `WP7-REPILOT-AND-FREEZE` | frozen release-spine profile plus affected WP0--WP6 slices | `in_progress_replay_resolved_profile_and_precision_remaining` | Prespecify replication counts, MCSE targets, failure denominators, seeds, and manifests in parallel. Calibration pilots may run only for explicitly stable slices and are invalidated by later affected code/contract changes. Draft.62 resolves only the additive JML recession replay blocker after native six-route identity, affected full-regression, and exact-tarball package checks. General nonlinear GPCM, replicated platform timing, PCA criteria, ADEMP recovery/coverage, external eligibility, the supported workload profile, and the complete statistical precision plan remain open. Confirmation stays unauthorized until profile, criteria, candidate identity, and all other release-spine blockers are frozen. | Claim-disposition profile, complete pilot registry, atomic resumable execution, method-mode-specific exclusions, prespecified precision plan, resolved release-spine blockers, and still no confirmation result. |

#### Corrective-program execution lanes

The work packages use three non-interchangeable execution lanes:

1. The **change-local contract lane** runs the smallest deterministic unit,
   adversarial, privacy, and terminology set that can reject the current edit.
   It is a development feedback gate, not statistical or release evidence.
2. The **branch regression lane** runs every repository test, including the
   non-CRAN suite, before a work-package handoff. If infrastructure time limits
   require a split run, the sorted test-file manifest must be partitioned
   exhaustively with no omitted file, every partition must retain its exit
   status, and warnings/skips must be reconciled across partitions. Passing
   only the change-local lane cannot substitute for this lane.
3. The **candidate evidence lane** runs the frozen scenario registry,
   cross-platform package matrix, heavy recovery/resampling, and external-tool
   comparisons against one manifest-bound candidate. Branch-regression output
   cannot be relabelled as candidate evidence, and candidate thresholds cannot
   be changed after this lane begins.

Runtime budgets for the first two lanes must be piloted separately. Slow
simulation, resampling, and external comparisons may be scheduled outside the
change-local lane, but no blocker may disappear from the exhaustive branch or
candidate manifests. WP6 owns the target-size estimability runtime/memory
envelope; G7 separately owns CRAN-controlled time.

#### WP0 frozen boundary

The normative structural record is
`readiness-contract-0.2.3.md`. Its machine-readable vocabulary, derivation,
legacy mapping, condition-class registry, and validator are in
`readiness-contract-0.2.3.R`; exact expected cases are in
`readiness-contract-fixtures-0.2.3.csv`. The contract identity is
`mfrmr-readiness-0.2.3-v3`.

WP0 is structurally complete, not statistically confirmed. In particular, it
freezes that `InferenceReady` is `TRUE` only for `FitReadiness = ready`, while
parameter-scoped output preserves estimable coordinates from a
`ready_with_exclusions` fit. It freezes fail-closed legacy mapping and
metric-specific comparison eligibility. It does not claim that current fit,
summary, plot, export, or normalizer code implements those states; that claim
is prohibited until WP1--WP5 pass their runtime and propagation tests.

WP0 also resolves pre-fit blocker behavior: invalid input, exact structural
nonidentification, and unsupported free category/step coordinates will use
typed errors carrying structured preflight records. Boundary exclusions and
numerical review remain inspectable on returned fits. No 0.2.3 public bypass
for an exactly unidentified fit is planned.

#### Three readiness scopes

The current scalar readiness vocabulary is insufficient. Draft.21 requires
three linked scopes while retaining one conservative first-screen summary:

| Scope | Required internal record | Examples of non-ready states |
| --- | --- | --- |
| Fit | `FitReadiness` plus component states | invalid input, unsupported model, structurally unidentified, numerical failure, review required |
| Parameter | one row per displayed or fixed coordinate | aliased, unsupported step, weak information, JML unbounded low/high, fixed/anchored, estimable |
| Comparison | one row per external metric and parameter class | model-contract mismatch, category/step mismatch, constraint mismatch, unidentified, unmatched boundary convention, eligible |

`InferenceReady` remains a compatibility summary during 0.2.3, not the data
model for new logic. WP0 must decide and test its conservative mapping before
WP1 changes runtime behavior. In particular:

- exact fit-level nonidentification can never map to `TRUE`;
- an optimizer success code cannot improve a worse design/category state;
- an excluded unbounded JML Person must not appear as a finite primary
  estimate, but other demonstrably estimable parameter classes need not be
  silently discarded; and
- reports must show whether readiness applies to the whole fit, a restricted
  set of parameters, or a comparison only.

The machine-readable component fields frozen by WP0 are:

`InputState`, `EstimabilityState`, `CategoryState`, `BoundaryState`,
`NumericalState`, `FitReadiness`, `ParameterStatus`, `ComparisonEligibility`,
`ReasonCodes`, `ReadinessScope`, and `ReadinessContractVersion`.

They remain internal schema rather than public API promises. The first-screen
precedence is fail closed: blocked, legacy unknown, review,
ready-with-exclusions, then ready. Multiple reason codes are retained; a
single most-severe label must not erase the causal audit trail. Exact state
vocabulary and derivation are owned by the WP0 contract rather than duplicated
here.

#### WP1: constrained estimability contract

The pre-fit audit is estimator- and parameterization-specific:

- JML includes free Person/facet coordinates and the linearly indexed
  step/interaction coordinates, then applies centering, direct/group anchors,
  fixed values, and structural absences before structural location rank is
  judged. Nonlinear bounded-GPCM slope coordinates require their model
  Jacobian/information audit and are not certified by an additive design rank.
- MML integrates Person effects and therefore must not reuse the JML Person-
  column rank rule. Panels linked only through a common latent distribution are
  labelled `population_assumption_linked`; their interpretation requires
  assignment and population-invariance evidence even when the marginal model
  is algebraically identified.
- Anchored coordinates are removed from the free vector and enter as known
  offsets. Linear/group constraints are represented explicitly; they are not
  approximated by dropping an arbitrary display column.
- Interaction columns and step coordinates enter the audit only under the
  model that actually fits them. A main-effect audit cannot certify an
  interaction model.

The implementation uses a staged computation. A graph/structural screen and a
sparse free-coordinate location or derivative design come first as applicable.
Sparse symbolic/numerical QR checks structural rank; a tolerance ladder and
selected singular-value, Jacobian, or fitted-information diagnostics
distinguish exact alias from near-alias. Dense SVD is limited to small
explanation fixtures. Rank, tolerance, evaluation point, scale, contrast
basis, free dimension, and any null-space explanation are recorded. A single
universal condition-number cutoff is prohibited.

Required invariance tests cover row permutation, level relabelling, alternative
full-rank contrast bases, equivalent anchor parameterizations, and harmless
zero-column removal. Required negative controls cover disconnected components,
zero-common-Person JML panels, nested rater/Person groups, single bridges,
unused interaction cells, and anchors that do or do not restore a common
frame. A basis-dependent pass/fail result is a blocker.

##### Draft.23 implementation slice

The package now builds a sparse adjacent-category-logit design in the actual
free coordinates for RSM/PCM. It includes free JML Person coordinates, omits
them for MML, and applies the optimizer's facet/group-anchor Jacobians, facet
signs, two-way sum-zero-marginal interaction basis, and RSM/PCM within-ladder
step constraints. Columns are normalized before a recorded sparse-QR tolerance
ladder; small negative controls receive bounded dense-SVD null explanations,
while large designs do not cross the bounded dense-allocation threshold.
Tolerance-ladder disagreement is retained as a diagnostic field only. It does
not produce the `weak_information` readiness state until a fitted-information
layer and a pilot-calibrated rule have been reviewed and frozen.

Exact rank deficiency now raises a structured `mfrmr_estimability_error`
before optimization. The condition carries the contract identity, rank,
nullity, parameter-block counts, coordinate map, reason codes, tolerance
results, and bounded null directions without printing Person identifiers in
the error message. A full-rank MML fixed-effect block is also compared with a
counterfactual free-Person JML design. If only MML is full rank, the fit is
labelled `population_assumption_linked` and remains review-only; shared
Criterion levels alone do not become shared-Person evidence.

Current exact controls cover balanced JML, row permutation, level relabelling,
RSM/PCM step coordinates, zero-common-Person JML versus MML, two alternative
Rater anchors that restore rank, a missing interaction cell, and the equality
of sparse constraint Jacobians with the optimizer expansion. Existing
disconnected cases were reclassified by rank rather than by graph appearance:
some remain full rank under their declared constraints but still retain a
linking hold, whereas a balanced two-component Rater/criterion split stops as
an exact alias.

##### Draft.25 fitted-information instrumentation slice

For a retained nonlinear fit that passes the existing terminal stationarity
gate and has at most 80 free coordinates, the package now evaluates a dense
numerical Hessian of the same negative log-likelihood and analytical gradient
used by the direct optimizer. The stored record identifies the evaluation
point, model and estimator, free dimension, execution limit, nonlinear blocks,
explicit free-coordinate difference step, retained and reevaluated objective,
objective difference, terminal gradient, Hessian asymmetry, full-vector
symmetric-eigenvalue tolerance ladder, and nonlinear-block diagonal summary.
Deterministic integration controls cover bounded-GPCM `log_slopes`
and latent-regression `log_sigma2`; nonstationary, malformed-vector, oversized,
and unavailable cases retain explicit not-evaluated states.

This is instrumentation, not a decision rule. The 80-coordinate limit is a
dense-Hessian execution cap, not an estimability threshold. No eigenvalue,
rank, diagonal, or condition result produces `weak_information`, changes
readiness, completes the nonlinear preflight, or licenses external agreement.
Those semantics remain prohibited until the pilot grid establishes a
parameterization-aware rule and WP4 propagates the frozen result consistently.

##### Draft.26 nonlinear transformation instrumentation slice

Every retained fit with free bounded-GPCM `log_slopes` or latent-regression
`log_sigma2` now receives a separate free-to-expanded transformation audit.
For GPCM it records the sum-zero log-slope and positive geometric-mean-one
slope Jacobians; for latent regression it records the log-variance and positive
residual-variance Jacobians. Analytic derivatives are checked against
coordinate-scaled central differences. The record includes dimensions,
expected and tolerance-ladder ranks, natural-coordinate ranges, constraint
residuals, absolute and scaled derivative differences, conditioning, malformed-
vector/configuration states, and exact coordinate-system labels.

This audit is deliberately marked `parameterization_only`. Full-column rank
means only that the declared free-to-expanded map is locally nondegenerate at
the retained finite vector. It does not show that the response likelihood
contains information about the coordinate, does not combine the nonlinear
coordinate with the additive design, and cannot produce structural
identification, weak-information, readiness, or external-comparison decisions.
The fitted-information record remains a separate local likelihood diagnostic.

##### Draft.27 JML GPCM conditional response-kernel slice

For retained JML GPCM fits, the package now evaluates the Jacobian of every
adjacent-category logit, `a_s * (eta - step)`, with respect to the full
optimizer free vector. The additive Person/facet/interaction/step block is
scaled by the observed slope; the log-slope block applies the sum-zero
log-slope expansion and the exact `a_s * (eta - step)` chain rule. The record
contains the optimizer-coordinate map, local rank ladder, bounded null
directions, execution size, and an independent coordinate-scaled central-
difference comparison. Deterministic controls establish derivative agreement,
row-order invariance, and exact reduction of the additive block to the existing
PCM design at unit slopes. A numerical-differentiation size cap does not stop
the sparse analytic calculation or create an inferential state.

The estimator boundary is intentionally asymmetric. MML integrates Person
coordinates, so it records
`not_evaluated_marginal_person_pattern_required` instead of treating the JML
conditional-observation Jacobian as a marginal identification result. The
bounded observed-information Hessian remains separately available for eligible
MML fits, but it is a local fitted-likelihood diagnostic and is not a substitute
for a person-pattern response map or a calibrated rule.

##### Draft.28 MML observed Person-pattern score slice

For bounded nonlinear MML fits, the runtime now decomposes the retained
marginal log likelihood into one observed response-pattern contribution per
Person and evaluates its conventional score over the exact optimizer free
coordinate order. Each Person row is obtained from the same analytic MML
derivative kernels at the same quadrature rule as the retained fit. The stored
record verifies that the pattern log marginals reconstruct the full negative
log likelihood and that their score rows sum to the negative of the full
objective gradient. Each row is also checked independently against coordinate-
scaled central differences of that Person's log marginal contribution.

The bounded record contains Person-row and free-coordinate counts, quadrature
points, optimizer severity, execution limits, score-Jacobian rank ladder,
parameter-block map, bounded parameter-only null directions, row-norm summary,
objective/gradient reconstruction error, and derivative error. Observation-row
permutation is tested at a fixed retained vector. Person identifiers and the
score matrix itself are not copied into the fitted audit object.

This is an observed-pattern local diagnostic. It does not enumerate all
possible response patterns, does not reuse the JML conditional kernel, and does
not classify structural identification, weak information, or readiness. In a
deterministic eight-Person GPCM control the derivative and gradient identities
hold while the observed-pattern matrix is rank deficient; this is retained as
a direct negative control against converting observed-pattern rank into a
structural decision. Execution caps are computational states only.

##### Draft.29 MML all-pattern expected-information slice

For each bounded nonlinear MML fit that remains within the recorded execution
envelope, the runtime now fixes each Person's retained observation design and
enumerates every finite category-response vector on that design. Rows omitted
as missing are not recreated or imputed: a Person with fewer retained rows has
a correspondingly smaller response-pattern space. This first exhaustive
implementation requires unit row weights because an arbitrary powered
likelihood is not the same normalized finite response-pattern distribution.
Nonunit weights receive an explicit non-evaluated state.

For every pattern, the package evaluates the marginal probability and analytic
score in the exact optimizer coordinate order. The stored audit verifies that
each Person's pattern probabilities sum to one, that probability-weighted
scores have expectation zero, and that score outer products form a symmetric
positive-semidefinite expected-information matrix. Selected patterns from the
first and last retained Person designs are checked against coordinate-scaled
central differences. The fitted object stores workload, normalization,
identity, eigenvalue, rank-ladder, derivative, and execution summaries, but not
Person identifiers, pattern rows, score rows, or the expected-information
matrix itself.

The default envelope is at most 100 Person designs, 4,096 patterns for any one
design, 5,000 actually evaluated patterns after exact design reuse, 80 free
coordinates, and 400,000 evaluated pattern-by-coordinate score elements. The
conceptual Person-by-pattern total is recorded separately. These values are
implementation caps, not supported capacity claims. Exact controls cover
complete and one-row-missing GPCM
designs, row permutation, latent-regression beta and residual variance,
nonunit-weight rejection, and execution-limit rejection. In the balanced
eight-Person GPCM control, all 2,048 patterns give probability-mass error below
`6e-16`, expected-score error below `5e-15`, central-difference error below
`7e-10`, and local rank 7 of 7, whereas the realized observed-pattern score
matrix in draft.28 has rank 5 of 7. A one-node, zero-vector control makes the
GPCM slope direction locally zero, demonstrating that even exhaustive-pattern
rank remains evaluation-point and integration-rule dependent.

##### Draft.30 exact Person-design reuse slice

The exhaustive evaluator now canonicalizes the retained observation rows
within each Person and creates an internal exact design signature from the
ordered facet, step, slope, and interaction indices. When a latent-regression
population model is active, the aligned numeric population-design row is part
of the signature. Person identifiers and observed scores are excluded. Thus,
Persons with the same measurement design can share one all-pattern evaluation,
while a different missingness layout, facet assignment, interaction cell, or
population covariate row prevents reuse.

Each unique design is evaluated once. Its probability-weighted score matrix is
scaled by the square root of the exact group multiplicity, so its crossproduct
equals the sum of the corresponding Person-level expected-information
matrices. Probability-mass and expected-score identities are still expanded
per conceptual Person. The audit stores only Person-design count, unique-design
count, reused-design count, largest group, conceptual/evaluated pattern counts,
and their ratio; signatures, covariates, Person identifiers, pattern rows, and
score matrices are not retained.

Deterministic controls compare the reused path with a forced non-reuse path. In
the balanced eight-Person GPCM fixture, 2,048 conceptual patterns reduce to 256
evaluated patterns; the two expected-information matrices differ by less than
`6e-14`, expected scores by less than `2e-16`, and probability masses are
identical. One missing row creates exactly two design groups and 320 evaluated
patterns rather than 1,856. Row reversal preserves the one-group result. In
the continuous-covariate latent-regression fixture, all 50 design rows remain
distinct; forcing two covariate rows to equality reduces the group count by
exactly one. An exploratory local timing changed from approximately 1.67 to
0.22 seconds for the balanced fixture, but this machine-specific observation
is not a frozen benchmark or capacity claim.

WP1 is not complete. The JML conditional, MML observed-pattern, and MML
all-pattern expected-information results are retained-point diagnostics. A
global or parameter-grid structural argument, active latent-variance and GPCM
property grids, alternative contrast/anchor/slope-facet grids, exact local-rank
controls away from degenerate integration rules, sparse target-size memory and
runtime evidence, a scalable alternative when unique designs themselves still
have exponentially large response spaces, an alternative to the
bounded dense Hessian, and calibrated weak-information classification remain
pending. No FACETS tolerance or supported-capacity claim follows from this
implementation slice.

#### WP2: category and step contract

Every fit records a category-support table with at least:

`ScaleScope`, `StepScope`, `DeclaredCategories`, `ObservedGlobal`,
`ObservedWithinScope`, `RetainedForFit`, `FreeStepCount`, `FixedStepCount`,
`UnsupportedCategory`, `UnsupportedStep`, `ZeroType`, `InformationState`, and
`ReasonCode`.

The rules are model-specific:

- RSM estimates one common ladder in the current fit. Global absence of an
  internal category creates a common-step recession direction; absence only
  within one facet level is primarily a local-information issue when the
  category is supported elsewhere.
- PCM uses the current `step_facet` ladders, so support must be checked within
  every ladder. A global category count cannot establish a local PCM step.
- bounded GPCM inherits the applicable category/step checks and additionally
  keeps slope information separate; a stable slope cannot rescue an
  unsupported internal-category step contrast.
- a declared but unobserved boundary category is preserved as data semantics,
  and is routed to weak/element-boundary review rather than misclassified as
  an unsupported step-shape coordinate. Threshold anchors and reusable
  assertions remain 0.2.4 work.

Structural zero, sampling zero, rare-but-observed, and severe concentration
remain distinct. Count, proportion, and entropy may trigger review but cannot
by themselves prove identification. Exact unsupported coordinates are decided
from the parameter/support map; weak information is calibrated later from
fitted information and recovery. FACETS `K`, category dropping, dummy-weight,
and threshold-anchor cases are external policy controls, not new 0.2.3 mfrmr
features.

##### Draft.31 category/step preflight slice

Every new fit now builds `category_support_audit` before optimization and
stores it in both `config` and `data_review` when a fit is returned. The
required scope table distinguishes declared, globally observed, observed
within the fitted ladder, retained, free, fixed, derived, unsupported, zero-
type, and information-state fields. Separate category-count, expanded-step
status, and local facet-support tables preserve the evidence behind the scalar
category state. `ScaleScope = single_observed_scale` is an explicit internal
one-scale reduction key, not a public `ScaleId` feature or a claim that the
future multiple-scale schema has been designed.
Raw row counts and positive-weight support are stored separately; all exact
support decisions use positive-weight observations, so frequency-weight
semantics cannot be inferred from row presence alone.

The exact preflight follows the actual within-ladder sum-zero free-coordinate
map. If internal category `c` has zero positive-weight observations, the
direction that increases the step below `c` and decreases the step above `c`
drives only that category probability toward zero while leaving every other
category exponent unchanged. This is an exact likelihood recession direction,
even though observations can occur on both sides of both cumulative
transitions. Conversely, absence of a boundary category does not by itself
create this step-shape direction and is retained as weak/element-boundary
evidence. A small fixed-eta numerical control confirms finite step estimates
for lower- and upper-boundary gaps but diverging adjacent steps for an internal
gap. RSM applies the internal-gap decision to its one shared ladder; a category
absent only within a Rater, Criterion, or other local facet level is review
evidence when it is supported globally. PCM and bounded GPCM apply the decision
independently to every current `step_facet` ladder; a stable GPCM slope cannot
override a missing internal category.
The current within-ladder sum-zero parameterization has `K - 2` free step
coordinates and one derived expanded step for `K` categories. Therefore a
binary ladder has no free step coordinate and is not falsely blocked merely
because one local scope is response-constant; that pattern remains weak or
boundary evidence for later contracts.

An unsupported free step raises `mfrmr_category_readiness_error`, carrying the
fit-scope category state, reason codes, scope table, category counts, and
parameter-scoped step statuses, before the optimizer runs. The condition
message does not print Person identifiers. Declared categories remain in the
audit and descriptive data review. Empty internal categories are exact
unsupported contrasts; empty boundary categories, singleton category cells,
and singleton cumulative-side cells remain `weak_information`. Entropy and
concentration are recorded but do not yet trigger a numerical threshold.

Deterministic controls now cover balanced PCM, a globally supported internal
category absent from one PCM ladder, RSM reduction of a boundary category
absent only locally, a globally empty internal category, bounded-GPCM
inheritance, a boundary-gap negative control, the binary no-free-step negative
control, row reversal, facet relabeling, reason-code/class behavior, and
condition-message privacy. The existing public boundary-gap regression remains
valid and is now explicitly protected against false blocking. Repeated design
evaluation also preserves the category condition class, state, and reason
codes, and returns a typed zero-row result schema when every replicate stops at
preflight instead of collapsing to an unusable zero-column table.

WP2 remains in progress. The singleton weak rule is a conservative structural
review trigger, not a calibrated operating threshold. Severe concentration,
local information eigenstructure, recovery-based weak classification,
structural-zero declarations, threshold anchors, reusable frozen calibration,
multiple observed scales, and metric-specific FACETS category/drop/`K`
eligibility remain pending. WP4 must still combine category, estimability,
boundary, input, and numerical components into the one stored readiness record
and propagate it to all summaries, reports, plots, exports, and replay paths;
until then a returned weak-category fit can still carry the legacy numerical
`InferenceReady` scalar and must not be described as end-to-end readiness
complete.

#### WP3: boundary and extreme contract

Boundary detection applies to every estimated JML element for which an
extreme sufficient-score argument is valid, not only Persons. It uses the
model-implied attainable minimum/maximum on the exact contributing observations
after missingness, signs, and supported positive weights. Fixed/anchored
elements, separated interaction cells, and ordinary large finite estimates
receive different statuses.

For an unanchored JML extreme, the primary measure is typed as unbounded; its
direction and response count remain available, while standard error and
ordinary finite-fit statistics are unavailable unless separately justified.
An optional adjusted display must name its formula and adjustment and cannot
overwrite the primary field. FACETS-compatible adjustment is a comparison
convention, not the mfrmr estimator target. MML/EAP Persons remain finite by
the population/prior model and must not be relabelled as JML-unbounded merely
because their observed response pattern is extreme.

##### Draft.32 Person sufficient-score boundary slice

Every new fit now builds a Person-scoped boundary audit after optimization and
stores it in `config$boundary_audit` and `data_review$boundary`. The audit uses
the retained preparation data, so missing or non-contributing rows cannot make
an otherwise nonextreme pattern appear extreme. Under the standard free-Person
JML parameterization, an all-minimum or all-maximum retained response pattern
has `ParameterStatus = unbounded_low` or `unbounded_high`; the primary
`Estimate` is negative or positive infinity. The optimizer's finite stopping
iterate is retained only in `OptimizerEstimate` with
`OptimizerEstimateUse = numerical_trace_only`, while `DisplayEstimate` is
missing and `DisplayAdjustment = none`. `ResponseRows` and
`WeightedResponseTotal` retain the contributing row count and positive-weight
total used by the classification.

The constraint Jacobian separates three cases before applying that rule. A
directly anchored or implicitly constraint-fixed Person is `fixed`, including
an extreme response pattern; an individually free Person is eligible for the
sufficient-score boundary result; and a centered or group-coupled extreme is
retained as `weak_information` with `weak_design_information` until a
constraint-aware recession-direction proof is implemented. This fail-closed
case prevents both automatic infinity and automatic finite-MLE claims under a
substantive coupled constraint. MML Persons remain finite EAP values with
`mml_extreme_response_prior_regularized` and are never assigned an optimizer
Person coordinate that the marginal model does not estimate.

The Person table, fit summary, and diagnostic measure table now preserve the
typed status. A fit with a proven Person exclusion records
`BoundaryState = has_exclusions`; the legacy `InferenceReady` scalar becomes
`FALSE`, while the estimable coordinates remain inspectable. Diagnostic SE,
CI, and formal-inference eligibility are unavailable for the unbounded Person.
The FACETS-style Wright renderer may place such Persons at the ruler endpoints
when `extreme_placement = "ends"`; this is recorded as a plot placement, not a
finite adjusted estimate. With `extreme_placement = "estimate"`, the row is
omitted from the finite ruler rather than replaced by the optimizer trace.
Native finite-density summaries exclude the unbounded rows.

Deterministic controls cover low/high free JML boundaries, direct anchoring,
constraint-coupled fail-closed behavior, finite MML/EAP non-reduction, missing
rows, fit-summary scalar behavior, diagnostic SE/CI exclusion, and both Wright
placement modes. Existing cross-constraint correlation tests now compare only
common `estimable` Persons; typed boundaries cannot enter those numeric
aggregates accidentally.

WP3 remains in progress. Response-constant non-Person levels are never treated
as sufficient evidence by themselves: additive facet, interaction, and step
claims now require the constrained likelihood recession certificates below.
The resulting candidates are still internal and do not yet replace finite
optimizer iterates in public non-Person tables. The stored fit-level record now
fails closed when an applicable candidate has not been propagated, but it does
not manufacture a primary parameter value. Slopes remain outside the linear cone;
draft.36 audits a separate fixed-additive nonlinear path without changing that
linear claim. No FACETS-compatible finite adjustment formula has been added. Reports,
exports, replay, serialized legacy-object evidence, and external normalizers
remain WP4--WP5 work and may not reconstruct or upgrade the stored state
independently.

##### Cross-gate solution and decision-stability order

`gpcm-solution-decision-stability-roadmap-0.2.3.md` now binds the endpoint,
numerical, uncertainty, readiness, fit, DFF, and ranking work without adding a
new checklist row. Its order is mandatory for the retained GPCM work: P0 common
objective/gradient/free-dimension, deterministic starts, transformed
coordinates, and decision signatures; P1 boundary and quadrature adjudication;
P2 typed Hessian/profile/bootstrap/posterior uncertainty and coverage; P3
fit/DFF/rank/separation operating characteristics; and P4 matched external and
consequence stability. Later stages cannot repair a failure in an earlier
stage. In particular, a code-zero optimizer, locally positive Hessian, dense-
grid objective tie, or high rank correlation cannot promote a dominated,
boundary, nonidentified, or decision-sensitive result.

The panel is deliberately staged rather than factorial. The historical
fixed-standard-normal q=31/61/91 calibration remains sensitivity evidence and
cannot be transported to the current free-population default or used to freeze
a tolerance. Large simulation remains reserved for coverage and error-rate
questions that deterministic algebra, boundary paths, and microcases cannot
answer.

The first P0 instrument and execution record are now complete in
`gpcm-solution-stability-p0-0.2.3.R` and
`gpcm-solution-stability-p0-record-0.2.3.md`. The fixed benign
free-population GPCM-MML microcase registers seven starts before fitting,
reuses one canonical objective, compares analytic and independent numeric
scores, reconciles five total-free-dimension counts, and maps every candidate
to labelled additive, step, slope, and population coordinates. All seven are
eligible for descriptive comparison under the existing optimizer rule, but
all seven remain `P0StabilityEligible = FALSE`: no solution tolerance,
boundary rule, or integration rule is frozen. The compact signature also
leaves boundary, Hessian, interval, DFF, fit, rank, and separation fields
explicitly unevaluated. Thus this closes P0 instrumentation for one microcase,
not P0 evidence scope. At that point the next admissible GPCM slice was the
bounded endpoint/near-boundary audit and separate marginal-MML slope/variance
profiles; P2--P3 work could not be used to bypass it.

That bounded Person slice is now complete as P0b in
`gpcm-endpoint-solution-stability-p0b-0.2.3.R` and its execution record. The
reflected exact-high, exact-low, 19/20 near-high, and 19/20 near-low fixtures
retain all five categories and the same seven-start registry. All 28 candidate
vectors returned, yet each scenario has only one existing-rule pass,
`variance_low`; it improves the common objective over the default by about
1.72--4.19 and lies in a qualitatively different population-variance basin.
The default source EAPs are finite but accompany enormous variances and
`PopulationConverged = FALSE`. Accordingly all candidates remain
`P0StabilityEligible = FALSE`; neither the diagnostic lowest-objective label
nor the derivative-step calibration authorizes selection.

That observation narrowed P1 relative to the earlier generic start-by-q cross:
profile `log_sigma2` in both directions first and make any q=31/61/91 cross
conditional on profile quality. Population variance, slope-only movement, and
joint movement remain separate states, and candidate EAP/posterior-SD
consequences follow only after those source-fit gates. Isolated Rater endpoints
and constant-response controls remain a different fixed-facet lane. No large
simulation is admissible here.

P1a is now complete in
`gpcm-population-variance-profile-p1a-0.2.3.R` and its execution record. At
each of ten q=31 log-variance values it fixes that one coordinate and
independently reoptimizes the other 23 from the default and `variance_low`
P0b anchors, including the package's objective-nondegrading gradient-polish
policy. All 80 vectors returned. The four diagnostic minima occur at the
low-variance anchors (`sigma2` about 0.025--0.030), are interior to the finite
grid, and pass the existing nuisance rule. None of the four high-variance tail
envelope rows passes nuisance stationarity. Exact and near reflected curves
also retain maximum objective discrepancies of about 0.00065 and 0.0128,
respectively; no retrospective tolerance is set.

This is a conditional GO only for a low-basin q=31/61/91 calibration. The
default/high basin remains a diagnostic start and cannot enter an equivalence
or solution-selection denominator unless stationarity is repaired. Common
dense-grid reevaluation must remain separate from a continuous-integral
certificate. P2 uncertainty and P3 downstream metrics remain blocked, and the
complete 80-row polished path is opt-in so ordinary regression testing does
not turn this bounded gate into a persistent runtime burden.

P1b is now complete in
`gpcm-low-basin-quadrature-p1b-0.2.3.R` and its execution record. It refits the
four P1a-qualified low-basin candidates independently at q=31, 61, and 91 and
evaluates every returned vector at held-out q=121. All 12 qualified arms pass
the existing native numerical rule; across their 12 q pairs the maximum common
objective difference is about `1.14e-13`, labelled-coordinate differences stay
below `1e-11`, and the maximum common EAP difference is about `5.42e-12`.
Exact and near high/low reflection differences are also stable across q, but
no reflection tolerance is inferred.

The predesignated default/high-variance lane remains diagnostic-only by
construction. Zero of its 12 arms passes native stationarity, and the held-out
evaluator exposes objective, score, population-scale, and EAP instability that
cannot be explained by printed decimal rounding. Accordingly P1b closes only
the finite-q calibration of one local basin. It does not select a package
solution or certify the continuous integral. The next efficient slice is the
population-boundary plus source-solution selection contract, alongside the
separate fixed-facet Rater endpoint lane; adding more q values, Hessian work,
downstream DFF/fit/rank work, or broad simulation cannot bypass those gates.

P1c is now complete in
`gpcm-zero-variance-boundary-p1c-0.2.3.R` and its execution record. For fixed
nuisance coordinates, q=1 exactly evaluates the `sigma2 -> 0+` degenerate
population likelihood; all 12 returned boundary vectors match a separate
conditional-GPCM oracle to within about `1.71e-12`, and q=1 is exactly
invariant over finite placeholder log variances from `-32` through `32`.

That mathematical identity does not produce a usable profiled boundary.
Three starts per reflected scenario all return finite values, but zero of 12
nuisance fits passes the existing stationarity rule. Expanded slopes are
highly start sensitive, reaching about 36,532 in one diagnostic trace with
ratios up to about `1.58e17`; these values are not converted into cutoffs.
Increasing a representative run from 800 to 3,000 maximum iterations leaves
the same precision-limited point, so repetition alone is not the next step.
Fixed-nuisance natural-variance paths are retained diagnostically but excluded
from the decision because their source traces are ineligible.

The next efficient P1 slice is therefore a prespecified joint
`sigma2 -> 0`/log-slope path using the exact q=1 oracle. It must distinguish a
nonattained improving boundary from a stiff but finite local trace. The upper-
variance joint path remains separate. Until both and the source-selection rule
are resolved, the q-stable interior candidate remains local and Hessian,
DFF/fit/rank, and broad simulation remain inadmissible.

P1d is now complete in
`gpcm-zero-variance-log-slope-path-p1d-0.2.3.R` and its execution record. The
observed P1c geometry points to Criterion C4 in every reflected scenario. P1d
therefore fixes a single explicit compensation ray: `sigma2` falls as
`exp(-2t)`, C4 slope grows as `exp(t)`, and the other three log slopes fall by
`t/3`. This preserves sum-zero log slopes and holds C4
`slope * population SD` constant. The P1c fixed-nuisance dominated-convergence
argument is not uniform on this sequence, so q=1 transport is prohibited and
q=121 remains the fitting evaluator.

All 48 two-route finite points return. Same-vector q=61/91/121 objective
ranges are at most about `1.74e-11`, and an independent directional derivative
ladder differs from the analytic derivative by at most about `4.93e-6`.
Nevertheless only 14/48 points pass the existing nuisance-stationarity rule:
all eight `t = 0` points, six of eight `t = 2` points, and zero of 32 points at
`t >= 4`. Terminal objectives are 3.52--4.51 larger than their interior
anchors, but routes differ by as much as about `0.197` and terminal derivative
signs differ. Every scenario therefore remains
`bounded_joint_path_inconclusive`; neither recession nor finite turnback is
certified.

The failure is now localized to nuisance coordinate geometry rather than
quadrature density. At large `t`, Rater facets contract toward zero while some
step coordinates and route differences expand. The next efficient gate is to
derive which step, facet, and population-location combinations must scale to
keep GPCM category logits finite, then optimize the resulting reduced joint
limit or a well-scaled finite representation. Raising `maxit`, densifying `t`,
starting Hessian/DFF/fit/rank work, or launching broad simulation would not
resolve the identified problem. The upper/joint variance boundary remains a
separate later gate.

P1e is now complete in
`gpcm-coordinate-scaled-joint-limit-p1e-0.2.3.R` and its execution record. For
the declared C4 ray, write `epsilon = exp(-t)` and `rho = exp(-t/3)`. The exact
finite transform uses C4 location/steps and Rater divided by `epsilon`, and
C1--C3 locations/steps multiplied by `rho`. Criterion-specific locations
`x_c = beta - gamma_c` remove the divergent population-intercept/criterion-
facet cancellation while preserving `sum(gamma_c) = 0`. The resulting affine
Jacobian has rank 20 at every finite point, and nuisance round trips differ by
at most about `1.39e-17`.

All 32 finite transformed fits pass the declared transformed-coordinate rule;
only one of those same raw vectors passes the raw absolute-gradient rule. The
largest analytic/numeric transformed-gradient difference is about `2.20e-7`.
This demonstrates scale-sensitive stopping behavior without relabelling the
raw package solution as inference-ready. Finite objectives approach the direct
limit monotonically in absolute difference, from about `0.0315`/`0.0241` at
`t = 4` to about `1.05e-5`/`8.06e-6` at `t = 10` for exact/near fixtures.

The independently implemented direct limit keeps C4 latent-normal and Rater
terms, while C1--C3 lose those terms under this rate allocation. Its analytic
gradient agrees with an independent derivative to at most about `1.79e-7`.
All eight two-route fits pass, q=61/91/121 ranges and route differences are at
most about `3.41e-13`, and the limit objectives are 3.38--4.15 above the
qualified interior candidates conditional on the fixed path coefficient.
Each reflection is therefore labelled
`declared_c4_ray_two_route_stationary_limit_above_interior`.

P1f is now complete in `gpcm-slope-rate-cone-p1f-0.2.3.R` and its execution
record. With `u_c` denoting the log-slope rate divided by the positive
population-SD decay rate, finite random coefficients require `sum(u_c)=0` and
`u_c<=1`. The affine map `w_c=(1-u_c)/J` is an exact bijection to the standard
simplex. Its zero-coordinate faces give all nonempty retained-random target
sets: 14 for four criteria, distributed 4/6/4 over target-set sizes 1/2/3.
P1e's symmetric C4 rate is the barycenter of a two-dimensional face, not a
vertex.

P1f independently implements the canonical face likelihood with free
`lambda_c=lim(a_c sigma)>0`. Exact coordinate conversion recovers all eight
P1e objectives within about `1.14e-13`, and analytic/numeric gradients agree
within about `1.51e-7`. The released C4 `log(lambda)` gradient is 2.42--2.89;
a signed `0.001` probe lowers every objective. P1e is therefore a
nonstationary fixed-coefficient submodel of its C4 face, so its earlier local
comparison cannot close the whole face.

The next efficient P1 slice is prespecified multistart optimization of the 14
canonical faces. The empty-target stratum needs a separate deterministic-
Rater rate hierarchy, and curved or rate-nonconvergent paths remain
unclassified. The upper/joint variance path, source-selection rule, Hessian,
DFF/fit/rank, and broad simulation remain later gates.

P1g is now complete in
`gpcm-c4-face-to-deterministic-rater-p1g-0.2.3.R` and its execution record.
The preliminary free-log-coefficient fits shrink `lambda_C4` to roughly
`2.34e-6`--`2.82e-5`, exposing the coordinate artifact
`dL/dlog(lambda)=lambda*dL/dlambda`. P1g instead uses finite coordinates
`B=lambda*q`, `V4=lambda*u4`, and `G4=lambda*H4`. P1f/P1g objectives agree
exactly at the eight converted starts and their scaled gradients agree with
independent differences to about `1.70e-7`.

All 56 two-route fixed-lambda fits are eligible. Route differences are at most
about `5.76e-10`, q=61/91/121 ranges at most about `4.55e-13`, and scheduled
gradient differences at most about `2.06e-7`. Both routes increase from
`lambda=0` across the declared grid, with positive natural-lambda derivatives
at every positive point. The direct endpoint matches an independent
conditional oracle to about `1.93e-12` and lies 2.58/2.08 objective units above
the exact/near qualified interiors.

This locally adjudicates the declared C4 grid and its maximal-slope
deterministic-Rater endpoint. It does not globally close the C4 face, the other
13 random-target faces, or the remaining empty-target hierarchy. The next
efficient screen reuses this construction for C1--C3 single-target faces;
multiple-target faces, the upper boundary, source selection, Hessian,
DFF/fit/rank, and broad simulation remain later.

P1h is now complete in `gpcm-single-target-face-screen-p1h-0.2.3.R` and its
execution record. It applies the exact P1g scaled likelihood to C1--C3 and
reuses C4 evidence without refitting it. Qualified-interior target coefficients
lie within the common 0--0.2 grid. The descending route begins from slope-
weighted interior coordinates; the reverse route begins at the frozen C4
endpoint. Exact P1f/P1h objective differences are at most about `2.27e-13`
and identity-gradient differences at most about `1.68e-7`.

All 168 new fits pass. Route differences are at most about `1.21e-9`,
q=61/91/121 ranges at most about `5.68e-13`, and scheduled gradient differences
at most about `2.28e-7`. Direct conditional oracles agree with the 24 fitted
endpoints to about `2.50e-12`. All positive-grid coefficient derivatives are
positive and all C1--C3 endpoints lie above the qualified interior. Combined
with P1g, all four single-target grids and all four singleton deterministic-
Rater strata are screened.

This does not resolve the six two-target or four three-target random faces.
Nor does it resolve the 11 multi-criterion deterministic-Rater strata in the
empty-random-product hierarchy. The next efficient P1 slice is the six two-
target faces paired with their two-criterion Rater endpoints. Three-target
vertices, the upper boundary, source selection, Hessian, DFF/fit/rank, and
broad simulation remain later gates.

P1i is now complete in `gpcm-two-target-radial-screen-p1i-0.2.3.R` and its
execution record. For each of the six target pairs it uses the exact positive-
`tau` decomposition `lambda_c=tau*kappa_c`, geometric-mean `tau`, and
product-one relative coefficients. The analytic likelihood, nuisance
gradient, natural radial derivative, and `tau=0` conditional oracle are
independently checked. P1f/P1i objective differences are at most about
`1.14e-13` and q=61/91/121 ranges at most about `5.68e-13`.

The 336-fit run returns 318 eligible fits. Ten of 24 scenario-by-pair grids are
locally adjudicated; their finite-ratio paired-Rater endpoints remain above
the qualified interior. Fourteen are inconclusive because the descending and
reverse routes approach different relative-coefficient branches. The maximum
objective gap is about `0.0599`, and affected endpoint `d=log(kappa_1)` values
reach below `-7`. This is a missing coefficient-ratio boundary chart, not a
reason to increase `maxit` or densify the radial grid.

The next efficient P1 slice must derive the slower/faster target-rate limits,
including the Rater rescaling and the exact conditions under which they reduce
to an already-screened singleton stratum. Three-target faces stay closed until
that hierarchy is classified. The remaining deterministic-Rater hierarchy,
upper boundary, source selection, Hessian, DFF/fit/rank, and broad simulation
remain later gates.

P1j is now complete in `gpcm-ordered-ratio-boundary-p1j-0.2.3.R` and its
execution record. Its ordered coordinates set `lambda_slow=mu`,
`lambda_fast=mu*rho`, and `B=mu*q`. They transport all 288 positive P1i
points with maximum objective difference about `2.27e-13` and make `rho=0`
exactly identical to the frozen singleton-target likelihood.

All 672 ordered singleton rows pass objective, nuisance-gradient, and natural-
`mu` derivative identity checks. The scheduled independent natural-`rho`
derivatives agree within about `6.32e-8`. Only 280/672 analytic boundary
derivatives are nonnegative: 392 directions admit local improvement into the
two-target face, including all 96 rows at each of `mu=0.1` and `mu=0.2`.

This closes the coefficient-ratio likelihood identity but not its profile.
The next efficient P1 slice is a boundary-aware optimization with `rho` free
on `[0,1]` at each frozen `mu`, using both singleton and transported-P1i
starts. The two ordered orientations cover each unordered pair. Three-target
faces, the remaining Rater hierarchy, upper boundary, source selection,
Hessian, DFF/fit/rank, and broad simulation remain later gates.

P1k is now complete as a representative negative pilot in
`gpcm-fixed-mu-ratio-profile-p1k-0.2.3.R` and its execution record. It
optimizes nuisance coordinates and natural `rho` on `[0,1]` at every frozen
`mu` for exact-high and near-high fixtures, using singleton-boundary and
P1i-derived equal-side starts. Lower, interior, and upper KKT conditions are
evaluated separately.

All 336 fits are eligible. Maximum q range is about `5.69e-13`, maximum KKT
sup-norm about `9.72e-5`, and maximum scheduled independent gradient
difference about `2.19e-8`. The solutions distribute over 113 lower, 188
interior, and 35 upper ratio locations.

The two starts reproduce the same solution in 125/168 cells, the same
objective but different coordinates in ten, and competing eligible KKT
objectives in 33. Objective gaps reach about `0.0667`. All best observed
representative pair values remain 2.07--2.58 above the qualified interior, but
this does not select a basin or certify a face.

P1l subsequently takes the next efficient slice: fixed-`rho` nuisance
continuation for the 43 nonmatching cells, with the 33 objective-discordant
cases completed before the coordinate-only lane. The mechanism-level result is
recorded below. Reflected fixtures, three-target faces, the remaining Rater
hierarchy, upper boundary, source selection, Hessian, DFF/fit/rank, and broad
simulation remain later gates.

##### Draft.34 Fixed-rho nuisance-continuation mechanism audit

P1l now executes that continuation in separate objective-discordant and
coordinate-only registries. The priority registry adds the returned P1k points
to an eleven-point fixed-`rho` base grid and produces 766/766 eligible fits;
the identifiability registry produces 260/260. At every common `rho`, the two
directions agree within about `1.21e-9` in objective and `1.36e-5` in nuisance
coordinates. All 43 route discrepancies therefore coalesce to one observed
nuisance solution.

The 33 objective-discordant P1k cells are not one homogeneous multiple-basin
class. Twenty-two have positive-to-negative envelope-derivative brackets,
consistent with an observed profile maximum between endpoint-side minima. Six
have negative-to-positive brackets around one profile minimum, and five are
increasing over the scheduled grid. All ten coordinate-only cells have a
single minimum bracket. Every P1k lower-route candidate has the better
objective. Eleven high-side P1k candidates passed the `1e-4` numerical KKT
rule but are not exact second minima; the 22 maximum-bracket cases retain
endpoint-side competition on the observed curve.

This is the intended de-escalation: the next step is not a larger simulation,
three-target enumeration, or dense rectangular `mu`/`rho` grid. P1m therefore
uses a small local one-dimensional audit that brackets representative turning
points, checks endpoint ordering, and states what remains unproved between
grid points. Only then should the contract be transported to exact-low and
near-low reflections. Continuous barrier certification, ratio-face closure,
source selection, Hessian, DFF/fit/rank, and broad simulation all remain false.

##### Draft.35 Local profile turning-point audit

P1m freezes four representatives through a metric-first, `CellId` tie-breaking
rule: objective maximum, objective minimum, monotone increasing, and
coordinate-only minimum. It tightens nuisance stationarity from the P1l screen
to a `2e-6` gradient sup-norm. When BFGS/L-BFGS-B stop at objective-rounding
scale, a Richardson-Hessian Newton correction is accepted only when it reduces
the gradient and stays within an explicit machine-epsilon objective allowance.

All 87 points pass. The maximum and two minimum roots narrow to widths between
about `5.96e-8` and `7.16e-8`; refined envelope derivatives are no larger than
about `2.37e-8` in absolute value. Both route starts agree within about
`1.14e-13` in objective and `2.53e-7` in nuisance coordinates. Nuisance-Hessian
minimum eigenvalues remain near `5.64`. On the independently checked maximum,
the objective-Hessian perturbation has spectral norm only 0.60% of that
minimum eigenvalue and preserves positive definiteness.

The monotone representative remains objective-nondecreasing with positive
derivatives at nine points; its smallest observed derivative is about
`3.91e-5`. This is deliberately not called continuous monotonicity. P1m closes
the local representative-mechanism question while leaving
`ContinuousMonotonicityCertified` and `ContinuousGlobalProfileCertified`
false. P1n therefore takes an algebraic category-reversal map for the low
reflections, with fitting only on identity failure. Three-target faces, the
remaining hierarchy, source selection, inferential Hessian, DFF/fit/rank, and
broad simulation remain later gates.

##### Draft.36 Exact category-reflection transport

P1n derives and verifies the exact high-to-low map. For zero-based score `k`
among `0,...,M`, replace it by `M-k`, negate the category location, and map
`d_h` to `-d_(M+1-h)`. The reflected category log numerator differs from the
original only by a category-constant term. In the ordered-ratio coordinates,
Rater and location coordinates change sign, each full step vector is
reverse-negated, and positive `mu` and `rho` remain unchanged. The resulting
20-dimensional free-coordinate map is nonsingular and involutive.

At the marginal level, the transformed predictor at node `z` equals the
negative original predictor at node `-z`. Both endpoint fixture pairs preserve
row identity and reflect their scores exactly; the 61/91/121 Gaussian rules
mirror nodes and weights within `2.49e-14`. All 87 P1m stored points preserve
the marginal objective within `2.28e-13`, mirrored posterior within
`1.03e-14`, transported analytic gradients within `2.17e-13`, and twice-
reflected coordinates within `2.09e-17`. Four independent central-gradient
checks agree within `1.86e-8`, so no low-fixture fallback refit is required.

Hessians transport by `H_high=t(T)*H_low*T`. Because the identified step map
need not be orthogonal, P1n invokes Sylvester inertia preservation rather than
claiming equal eigenvalues. This closes only the four reflected local
mechanisms. The next compact task is to materialize the exact map over the
complete P1k/P1l finite-grid registry. Continuous ratio closure, three-target
faces, source selection, inferential Hessian, DFF/fit/rank, and simulation
remain false.

##### Draft.37 Reflected four-fixture finite-grid registry

P1o applies the P1n involution to all 336 P1k and 1,026 P1l stored points.
Every one of the 1,362 objective/gradient identities passes; maximum
differences are `3.41e-13` and `8.90e-13`. The 168 high-side cells comprise
125 P1k route-agreeing cells plus 43 P1l continuation cells. Transport produces
168 low-side cells, or 84 cells in each of four fixtures, without a fallback
fit. Thus `FullFourFixtureFiniteGridRegistryCompleted` is true.

This is a natural stopping point for the finite-grid lane. It does not make
`ContinuousGlobalProfileCertified`, face closure, source selection, Hessian
inference, or DFF/fit/rank true. Before further ratio-grid or three-target
work, the release-scope decision should ask whether a continuous theorem is
actually required for 0.2.3; otherwise the finite claim should remain bounded
and effort should move to a different release dependency.

##### P1p GPCM release-scope disposition

P1p is a no-fit claim audit over P1o, the public GPCM capability registry, the
106-row checklist, and its exact claim-disposition overlay. It finds no public
continuous ratio-profile claim and no independent release-spine obligation for
one. `FiniteGridClaimRetained` and `ContinuousRatioWorkDeferred` are therefore
true together: the bounded evidence is kept without converting it into a
continuum theorem.

The next GPCM release-spine item is row 88,
`gpcm_owner_evidence_partition`, still in `review`. Criterion-owned and
Rater-owned aligned GPCM evidence must retain separate model, estimator,
ability-scale, category-support, and runtime identities. Conditional fit and
DFF rows retain `retain_gpcm_fit_as_exploratory_no_decision` and
`disable_gpcm_dff_inferential_promotion`. P1p authorizes neither a public GPCM
promotion nor broad simulation.

##### P1q owner-identity propagation and scale separation

P1q reads the sealed Draft.66 bundle without fitting or rewriting it. The
declared manifest, result rows, and 120/120 checkpoint payloads retain the
seven historical identity axes, and every checkpoint matches the sealed
execution SHA. Nevertheless, none of nine frozen tabular surfaces directly
retains the full identity because exact `RatingMin`, `RatingMax`, and declared
support are absent; grouped summaries also drop step owner, slope composition,
dimension, ability-scale, and runtime fields.

A derived four-stratum registry recovers the declared 1--4 support only from
the hashed execution contract and binds full identity to seven derived
aggregate surfaces. It leaves the frozen bundle unchanged and adds no
statistical evidence. Draft.66 MML remains a historical
`standard_normal_latent_distribution` execution: its runner did not pass the
identification branch explicitly, whereas the current default is
`free_population`. Current production replay now emits the identification and
rating bounds explicitly, so the remaining defect is evidence coverage, not a
reason to alter the current replay API. Identity propagation needs no further
simulation. Row 88 remains `review`; the next bounded step is an explicit
prospective owner/scale/support contract and only then a small paired current-
default smoke.

##### P1r current-default paired-owner admission contract

P1r freezes the next design before generating data. Two non-unit source-owner
datasets (Criterion and Rater) each feed Criterion/Rater fitted-owner routes
under JML and explicit `free_population` MML. The eight rows share a dataset
seed within each four-route block and distinguish aligned from deliberately
misspecified alternate-owner fits. This permits common-data attribution but is
not a replicated operating-characteristic design.

All rows require exact 1--4 support, `keep_original = TRUE`, one dimension,
aligned step/slope owner, geometric-mean-one relative slopes, complete
crossing, real runtime/runner/contract hashes, and a recomputed manifest
content hash. Thirteen prospective manifest/data/result/checkpoint/aggregate/
replay surfaces retain the full 12-field source-owner, fitted-owner,
estimator-scale, support, and runtime identity. An external normalizer is only
conditional and cannot be admitted later without the same fields. The
contract was complete before execution; P1s below records the later admitted
smoke. Additional replication, recovery, owner-superiority, external, broad-
simulation, selection, and confirmation claims remain false or unauthorized.

##### P1s current-default paired-owner identity smoke

P1s executes the eight P1r routes without changing data, starts, quadrature,
or optimization limits by outcome. Both source-owner datasets retain one data
hash across their four fitted-owner/estimator routes. All eight fits return;
config, public manifest, replay, and public summary identity agree on every
route; and all 12 required evidence surfaces retain the full identity. The
conditional external-normalizer surface is not instantiated and supplies no
external evidence.

Pre-admission review found three harness/audit defects rather than adapting a
model result: JML effective identification was initially compared with the
irrelevant MML input argument; optional objective extraction was not scalar
safe; and MML nonlinear-block selection recycled a candidate-only logical
vector against all parameter names. The latter was reproduced with warnings
as errors, corrected by candidate intersection before size testing, and
covered by the full estimability audit tests. Only corrected v3 is admitted.

The identity subproblem is complete but row 88 remains `review`. All eight
routes have optimizer code zero yet `FitReadiness = review` and
`InferenceReady = FALSE`; two routes also retain terminal-gradient review.
Current free-slope GPCM estimability and boundary audits deliberately remain
incomplete. Additional owner-smoke replication and broad simulation remain
unauthorized. The next dependency is the mathematical and numerical basis for
estimator-specific free-slope readiness, followed only then by frozen owner-
specific recovery, uncertainty, support, fit, and DFF rules.

##### Draft.33 Person-fixed structural recession certificate

Every retained JML RSM/PCM fit now attempts a bounded linear-program audit of
the additive structural coordinates when `lpSolve` is available. For each
observation, the audit converts the adjacent-category design into the exact
observed-versus-alternative category contrasts. A candidate direction is a
certificate only when every contrast margin is nonnegative after an independent
post-solve check and at least one margin is strictly positive. A structural
null direction therefore cannot masquerade as separation.

Person free coordinates are set to zero in this slice. The remaining design
uses the same free-coordinate map as optimization, including raw facet signs,
direct and group anchors, centering, two-way sum-zero-marginal interactions,
and RSM/PCM within-ladder step constraints. Each expanded facet level,
interaction cell, and step is tested separately for positive and negative
recession. The result distinguishes `unbounded_high`, `unbounded_low`,
bidirectional ambiguity, fixed coordinates, no recession certified in the
audited subspace, solver failure, dependency absence, and execution-limit
non-evaluation. Direction loadings and contrast-margin certificates retain the
optimizer coordinate identity without exposing response or Person identifiers.

Deterministic controls include a two-Rater sum-zero separation, a
response-constant Rater that is not separable once the other Rater's mixed
responses are respected, facet-sign reversal, direct-plus-implicit anchoring,
a checkerboard Rater-by-Criterion interaction, MML non-reduction, and bounded
execution-limit failure. The instrument is intentionally not a completed
boundary contract: its candidate statuses do not yet overwrite public facet,
interaction, step, or slope tables and do not change the Person-scoped
fit-level `BoundaryState`.

Draft.34 supersedes the dense construction in this paragraph, and draft.35
adds the joint additive companion described below. WP3 still requires an
independent general solver/parity fixture, equivalent-basis and broader
model-grid invariance properties, a joint nonlinear GPCM argument beyond the
retained-additive slope-only path, and measured runtime/memory evidence at the
prespecified sparse target sizes. Only after
those checks may WP4 promote a certified structural direction to the primary
parameter state and propagate its SE/CI, plot, report, export, replay, legacy,
and external-comparison effects.

##### Draft.34 sparse LP and independent microcase oracle

The default certificate now sends the constraint system to `lpSolve` as
row-column-value triplets. It no longer constructs the dense matrix containing
the positive and negative split variables. The box constraints and the
target-floor augmentation use the same triplet representation. A deliberately
bounded `dense_reference` route remains available only for parity tests and
small diagnostic reproduction.

The audit records variables, constraints, structural coordinates, target
directions, sparse nonzero count, dense-reference equivalent elements, and the
actual representation. Execution stops before solver entry when any frozen
engineering ceiling is exceeded. These are computational guardrails, not
evidence that the statistical model is weak or that FACETS-scale capacity has
been achieved. The legacy dense-element argument remains a compatibility
guard for internal callers but is no longer the default allocation rule.

Three layers now reject implementation drift. First, every solver result still
passes the observed-category contrast-margin certificate. Second, the sparse
triplet and dense-reference formulations produce the same direction status and
target capacity on both the two-Rater and checkerboard-interaction fixtures,
and the two-Rater result is invariant to retained row order. Third, a test-only
finite-grid oracle enumerates all `{-1, 0, 1}` directions in low-dimensional
microcases and agrees with the LP classifications for the checkerboard
interaction. The finite grid is an independent microcase oracle, not a complete
cone solver for arbitrary dimension or fractional rays.

A 20,000-row by 100-coordinate synthetic constraint-construction control
verifies that the default object stores only sparse triplets and avoids the
dense-reference allocation. It is an engineering allocation test, not a full
fit benchmark, recovery result, or FACETS comparison. WP6 must still measure
end-to-end runtime and peak memory across representative balanced, two-Rater,
sparse-linked, missing, interaction, and category-imbalanced fits before any
capacity claim or release ceiling is frozen.

##### Draft.35 joint Person-structural additive certificate

Every retained JML RSM/PCM fit now stores a second bounded audit beside the
Person-fixed structural result. Its contrast matrix contains all retained free
Person and additive structural optimizer coordinates simultaneously. The
global cone is screened first by maximizing the sum of nonnegative observed-
category margins. A positive result is accepted only after the same independent
post-solve minimum-margin and strict-row checks used for target certificates.
When no global ray exists, selected targets are classified without launching a
separate pair of linear programs for every target.

The joint audit does not duplicate draft.32 indiscriminately. Ordinary free
extreme Persons retain their exact sufficient-score status. Person-level joint
targets are restricted to constraint-coupled low/high cases that draft.32 left
as `weak_information`; all expanded facet, interaction, and step targets remain
eligible. The cone itself nevertheless includes every free Person coordinate,
so a structural direction that is possible only while Persons move cannot be
missed by holding non-targeted Persons fixed. Separate Person, structural, and
total additive-coordinate ceilings fail closed before solver entry. The
target-direction ceiling is applied only after a global ray is certified; a
no-ray result therefore does not launch or budget target-specific LPs merely
because the fitted object contains many expanded targets.

The primary adversarial fixture has two Persons and two Items with a fixed
Person-group mean. Its retained contrast inequalities have no nonzero feasible
strict direction in either the Person-only or structural-only subspace. The
full two-coordinate cone has the ray in which the Person contrast and Item
contrast move together. The LP consequently certifies the unresolved extreme
Person and both Item directions, and every stored direction contains loadings
from both blocks. A test-only exhaustive `{-1, 0, 1}` oracle independently
reproduces the global and target classifications. Sparse/dense formulations,
retained-row reversal, a nonseparated negative control, execution ceilings,
and MML non-reduction are also deterministic controls.

This closes the linear joint-movement gap only. It is not an independent
general-purpose cone-solver comparison, an end-to-end sparse capacity result,
the separate draft.36 nonlinear GPCM slope-path certificate, or a public
readiness propagation change.
The finite public `weak_information` Person and structural optimizer values are
deliberately retained until WP4 defines precedence, primary values, SE/CI
suppression, plotting, reports, exports, replay, legacy objects, and external
comparison eligibility from one stored readiness record.

##### Draft.36 retained-additive GPCM log-slope boundary paths

For a retained JML GPCM observation, draft.36 reconstructs the unscaled
cumulative category utilities from the exact adjacent `eta - step` values.
Along a constant expanded log-slope direction `q`, the derivative of the
observed log probability has the sign of
`q * alpha * (u_observed - E[u])`. It is therefore nonnegative for every
finite path point when a positive-loading group always observes a maximum-
utility category and a negative-loading group always observes a minimum-
utility category. At least one positive utility span is required so a null
direction cannot pass as a boundary path.

The geometric-mean-one identification is sum-zero on expanded log slopes.
Every nonzero constant direction has at least one positive and one negative
loading; any compatible pair alone is a valid direction. Enumerating all
ordered distinct level pairs is therefore complete for this fixed-additive,
constant-ray scope. The audit independently rebuilds the current weighted log
likelihood, rejects an objective mismatch, computes the high-slope and zero-
slope limiting likelihoods, records expanded and optimizer-coordinate
loadings, and fails closed before allocation when observation, utility,
slope-level, or pair limits are exceeded. MML is explicitly not applicable
because its Person-integrated pattern likelihood is a different object.

The fixed-Person checkerboard control has exact high compatibility for one
Criterion and exact low compatibility for the other. The optimizer stops at
finite log slopes near `+14.31` and `-14.31`, while the independent objective
oracle is monotone along the certified direction and approaches the stored
boundary likelihood. Row reversal gives the same certificate; public slope
tables retain the finite trace until WP4.

The more important negative control removes the Person anchors. At the
retained symmetric stationary point every base utility is tied, so no strict
slope-only ray is certified. Moving the two Person coordinates apart while
the two log slopes diverge nevertheless gives a monotonically improving joint
nonlinear path. This is not a defect in the scoped certificate; it is the
counterexample that prevents `scope_complete = TRUE` from being read as
`structural_identification_complete = TRUE`. A none-certified result means
only that no audited constant slope-only ray exists at the retained additive
point. WP3 remains open until broader joint nonlinear path logic, model/basis
properties, and target-scale evidence are addressed. Draft.37 now makes an
unpropagated positive candidate a fit-level review cause, but WP4 must still
determine its primary parameter value, SE/CI suppression, and complete
report/export/replay/external-eligibility propagation.

#### WP4--WP5: propagation and comparison eligibility

One readiness builder owns state derivation. Print, summary, diagnostics,
reports, plots, exports, support-envelope rows, and replay manifests consume
the stored record. They may format it but may not infer a different state from
warnings, parameter magnitude, or optimizer text. A saved 0.2.2 object without
the contract is `legacy_unknown`; it is never silently upgraded by current
display code. A deliberate re-audit/refit route may create a new-version
record with provenance.

External eligibility is metric-specific rather than one Boolean per run. The
normalizer checks response family, estimator, included observations/weights,
active facets, signs, category map, retained/free step dimension, anchors,
constraints, coordinate transformation, parameter status, and extreme-score
convention. A scenario may therefore permit a nonextreme Person comparison
while rejecting extreme display values, or retain prediction sensitivity while
rejecting PCM parameter MAE. Every rejection is counted by reason; aggregate
denominators report expected, eligible, rejected, missing, and failed rows.

#### WP6--WP7: scale discipline and repilot

The implementation must not construct a dense response-by-parameter matrix for
large sparse designs. WP6 benchmarks the graph screen, sparse design build,
rank audit, fitted-information audit, storage overhead, and downstream report
cost separately. Pilot target sizes are chosen from current mfrmr use and
resource measurements; they are not inferred from FACETS' advertised maximum.
If exact null-space explanation is too expensive, fail-closed classification
remains mandatory and the detailed explanation may be a bounded diagnostic.

WP7 first reruns deterministic fixtures, then the affected two-rater,
single-bridge, disconnected, category-absence, severe-concentration, and
extreme-score pilots on new pilot seeds. FACETS remains 4.5.0 for the primary
local stratum. The rerun must show:

- zero false-ready exact unidentified controls;
- zero unsupported-step parameters labelled estimable;
- no optimizer-dependent finite primary estimate for typed JML extremes;
- unchanged supported balanced reductions within frozen regression tolerance;
- no ineligible external row entering a numeric aggregate; and
- complete reason-coded accounting before any weak-information threshold or
  external tolerance is frozen.

Only after those structural outcomes pass may multi-seed recovery calibrate
weak-information and operating-envelope thresholds. Failure narrows 0.2.3
claims or keeps the affected surface blocked; it does not accelerate 0.2.4 or
0.2.5 features as a workaround.

#### Change containment, risk register, and decision log

Implementation is divided into reviewable commits in WP order. A contract/test
commit precedes each behavior change; rank, category, boundary, propagation,
normalization, and pilot changes are not combined into one unreviewable
refactor. Until WP7 completes, no commit may add a response family, public
`ScaleId`, threshold anchor, frozen-calibration API, or general active-facet
dispatcher.

| Risk | Adversarial failure | Required control |
| --- | --- | --- |
| Numerical rank masquerades as exact algebra | A tolerance or contrast choice changes pass/fail. | Structural screen, sparse-QR tolerance ladder, basis-invariance fixtures, recorded diagnostics, and `review` when exactness cannot be established. |
| Safety audit destroys sparse scalability | A dense matrix exhausts memory before the model can be assessed. | Sparse construction, dimension forecast before allocation, bounded explanations, target-size memory/runtime gates, and an explicit unsupported-size state rather than bypass. |
| Correct certificate is recomputed target by target without a global exclusion screen | A fail-closed audit dominates runtime even when the feasible recession cone is empty, or a later optimization weakens the Draft.51 equivalence. | Retain the versioned Draft.51 structural prescreen, positive-cone enumeration, solver/size fail-closed guards, frozen-route semantic comparisons, and target-status equivalence tests. Extend the same evidence discipline to joint attribution; never skip an audit merely because it is slow. |
| Fail-closed becomes indiscriminate | One extreme Person suppresses otherwise estimable facet results, or a local category rarity blocks a common RSM ladder. | Fit/parameter/comparison scopes, model-specific rules, reduction fixtures, and reason-coded exclusions. |
| Legacy behavior changes silently | A saved 0.2.2 object acquires 0.2.3 readiness semantics when printed. | Contract version, `legacy_unknown`, explicit re-audit/refit provenance, and serialized-object tests. |
| External software defines mfrmr | FACETS category dropping or adjusted extremes are copied merely to reduce numerical differences. | Truth-first evaluation, explicit estimand choice, separate display convention, and architecture decisions independent of agreement magnitude. |
| Valid rows disappear from aggregates | A normalizer silently drops hard cases and improves MAE. | Expected/eligible/rejected/missing/failed denominators and immutable reason ledger. |
| Pilot becomes confirmation by repetition | Seeds or thresholds are changed until results look acceptable. | Registered pilot seeds, one declared escalation rule, spec revision for every criterion change, and disjoint confirmation seeds after freeze. |
| Near-term fixes hard-code the future API | One-scale assumptions are embedded in fields later meant for `ScaleId`. | Use explicit scope keys internally, reserve versioned schema fields, and require one-scale reduction without exposing premature multi-scale behavior. |

Each WP decision record contains: decision ID/date, affected estimand and
surface, alternatives considered, selected rule, rejected shortcuts,
fixture/evidence IDs, compatibility impact, performance impact, open risks,
and which later evidence it invalidates. A rule promoted from pilot to frozen
also records the pilot registry and why the chosen threshold is scientifically
meaningful rather than merely observed to pass.

WP completion does not mean that every initially proposed behavior survives.
If a safe and scalable rule cannot be supported, the permitted outcomes are a
narrower support envelope, a visible review/blocked state, or deferral. The
impermissible outcomes are silently skipping the audit, loosening a criterion
after viewing confirmation, or expanding later features to route around an
unresolved core defect.

Draft.17 promoted FACETS from a conditional supplied-output row to a mandatory
JML RSM/PCM validation lane and adds
`inst/validation/facets-jml-stress-plan-0.2.3.md`. The 2026-08-03 environment
audit found that the official site advertises FACETS 4.5.1, while the selected
local `Facets.exe` has file metadata 4.5.0 and SHA-256
`dfb0afb0faa18f026d1b3b4175f22e42cc3764430eb83cbd368c7a572b3593a1`,
and retained 2026-05-07 reports identify FACETS 4.4.5. These are three distinct
identities. FACETS 4.5.0 is used for current pilot execution. Identity is
recorded for reproducibility, but the upstream-version difference does not stop
the batch. Existing 4.4.5 reports remain historical, and different versions
are summarized as separate sensitivity strata rather than pooled.

The current M2 development branch now contains the first package-side G3
instrumentation: one internal Person-basis AIC/BIC/SABIC builder, a retained-
vector `Npar` assertion, explicit JML/non-unit-weight/legacy states, stored-
value and integration/constraint fail-closed checks in `compare_mfrm()`, and
independent free-dimension fixtures. Repository-only common-GHQ evaluators now
separate fixed-vector integration drift from independent-refit drift. The
six-scenario fixed-vector and refit matrices are recorded as
`review`; together they support the draft public boundary that q<31 retains
raw ICs but cannot generate automatic comparison conclusions. Draft.5 also
adds the repository-only external-IC v1 arithmetic/identity contract and makes
public TAM imports fail closed for JML and multidimensional objects. Draft.6
adds the separate dimension-aware TAM runner, a 32-fit true-1D/true-2D
product-quadrature/deterministic-QMC matrix, and exact 1024-node QMC replay
checks. Draft.7 adds explicit ConQuest stopping controls and a matrixout-history
handoff that audits deviance, free dimension, the final exported parameter
vector, unit weights, exact bundle-to-export Person IDs, run metadata, and
output fingerprints without parsing the free-form summary report. Draft.8
fixes the generated ConQuest benchmark controls at parameter change `1e-8`,
deviance change `1e-10`, and 2000 iterations. In one 60-Person, 31-node binary
pilot, the ConQuest-minus-mfrmr deviance difference fell from approximately
`5.33e-4` under ConQuest's default stopping rule to `-4.14e-7` under the strict
controls, within the six-decimal ConQuest CSV resolution; the largest audited
transformed-parameter difference was `5.77e-6`. This resolves the apparent
likelihood-constant discrepancy for that pilot only. Draft.9 adds a
repository-only binary node-ladder preparer/reviewer that never launches
ConQuest. Under strict mfrmr and ConQuest controls, q=31, 61, 91, and 121 all
passed the arithmetic handoff with the same six-decimal ConQuest deviance;
the repeated q=31 native CSV set was byte-identical. The q=7 and q=15 rows
were rejected because the terminal history vector did not match the retained
native exports. Draft.10 adds a repository-only four-category RSM/PCM
preparer/reviewer, again without launching ConQuest. On one byte-identical
120-Person, five-item, q=31 input, both model families passed the native
history/export handoff with matched free dimensions (RSM 9; PCM 17), exact
sum-zero reconstruction, maximum absolute deviance difference `1.25e-6`, and
maximum transformed-parameter difference `1.60e-6`; the cross-engine
RSM-minus-PCM deviance-drop difference was `1.11e-6`. Draft.11 extends that
runner to q=7, 15, 31, 61, 91, and 121 plus a fresh q=31 repeat for each model.
Every q=31--121 RSM and PCM core row passed the arithmetic handoff; ConQuest
deviance was constant at its six-decimal export resolution, the maximum
absolute cross-engine deviance difference was `1.25e-6`, and the maximum
transformed-parameter difference was `1.6743e-6`. Within each model, all five
native q=31 CSV files were byte-identical across the two runs. The low-node
rows remained diagnostic only: RSM q=7/q=15 and PCM q=15 were extractable but
showed material objective and parameter drift, while PCM q=7 was rejected for
a `1e-6` final-history/export mismatch. This completes same-platform
likelihood/constraint mapping, the polytomous node ladder, and same-platform
repetition only. Independent platform/version replication, replicated and
confounded dimensionality cells, multi-node/platform stochastic integration,
weak-link/near-boundary cells, numeric freeze, and confirmation remain
pending.

Draft.12 adds the first repository-only G1 canonical-score pilot. Five fixed
binary/RSM/PCM/GPCM runs use q=31 and a three-step independently implemented
central-difference ladder at both the retained solution and a deterministic
nonzero-score probe. Across the ten run/point summaries, the largest absolute
analytic-versus-numeric difference was `6.91e-9`, and the largest numeric
step-ladder range was `6.91e-8`. The existing bounded-GPCM implementation was
also clarified: it has no optimizer box bounds, but maps `n-1` free log slopes
to sum-zero expanded log slopes and then exponentiates them. The independently
checked transformation Jacobian differed by at most `3.00e-10`, and exact
binary RSM=PCM and unit-slope GPCM=PCM probability/objective/common-score
reductions held. These are fixed-fixture pilot and structural-regression
results only. `NUM-SCORE-TOL`, an expanded near-boundary grid,
independent-engine replication, and confirmation remain unresolved.

The bounded non-unit GPCM follow-up removes the special-case-only ambiguity in
that pilot. On the same fixed q=31 direct-MML fixture, an independently
expanded positive-slope map, GPCM softmax kernel, Person-wise marginal
objective, and numeric free-coordinate score agree with the package at the
retained solution, the earlier high-dispersion point, and forward/reverse
finite stress points spanning slopes `exp(-3)`--`exp(3)`. At the calibrated
`1e-5` central-difference step, the largest whole-vector and slope-block
differences were `5.95e-7` and `1.25e-8`; probabilities, objective, and slope
transforms agreed exactly at recorded precision. The 47 focused expectations
include fail-closed mutations. This is review evidence only: it partly shares
additive/step/population expansion, freezes no general `NUM-SCORE-TOL`, and
does not replace owner-specific, five-category, sparse-topology, confirmation,
or external-overlap evidence.

Draft.13 adds the first repository-only G1 common-vector engine-path pilot.
Four fixed binary/RSM/PCM runs compare direct, hybrid, and converged-EM plus
common-direct-polish solutions; raw EM is retained as a diagnostic path, and
the polish must start from its exact hashed retained vector. Every one of the
four path vectors was re-evaluated through the direct, EM, and hybrid contexts
under identical q=31 likelihood, score, coordinate, and constraint structures.
The objective and score evaluator ranges were exactly zero over all 16
run/path summaries. Across the 12 mandatory path pairs, the largest objective
difference was `1.47e-10`, and the largest free or sum-zero-expanded parameter
difference was `5.73e-6`. These maxima are calibration observations, not
thresholds. The scope registry also makes the current engine boundary
explicit: additive RSM/PCM enter this pilot, while GPCM has only a direct
engine and EM/hybrid requests fall back to direct; interaction and latent-
regression requests with unsupported engines are likewise fallback rows, not
parity evidence. `NUM-OBJECTIVE-TOL`, `NUM-PARAMETER-TOL`, expansion across
fixtures/platforms, independent replication, and confirmation remain
unresolved.

Any source change that can alter the installed package or a validation result
invalidates M3-M5 evidence. A documentation-only change may retain numerical
evidence only when the manifest proves that the package payload and claimed
scope are unchanged. Changing a confirmatory tolerance after seeing a result
creates a new gate-specification version and requires the complete
confirmatory run to be repeated.

Following 0.2.2 acceptance, the canonical integration source moves directly
to `Version: 0.2.3` so unpublished behavior cannot masquerade as the CRAN
0.2.2 package. This version identity names the development target; it does not
authorize M3 candidate freeze, confirmatory evidence, or release claims. A
candidate becomes valid only when the exact source, tarball, check log, frozen
specification, checklist, and gate results are bound by the candidate manifest.

### Gate model

| Gate | Blocking requirement | Evidence that does not suffice |
| --- | --- | --- |
| Candidate identity | Source commit, tarball digest, package version, dependency/runtime metadata, seeds, and external input fingerprints agree. | A branch name, a newer file modification time, or an unpaired check log. |
| Numerical stationarity | The retained MML solution passes the common canonical free/transformed-coordinate score rule and objective/parameter cross-engine checks. | Optimizer code zero, `maxit` exhaustion, or one engine's native message alone. |
| Recovery envelope | Prespecified core cells meet their bias, RMSE, supported-interval coverage, failure-rate, and Monte Carlo-precision criteria for each claimed parameter class. | One successful seed, aggregate correlation, or pooled results that hide a failed cell. |
| Sparse/design behavior | Connected sparse cells are classified correctly; disconnected and unidentified negative controls fail closed and cannot become inferentially ready. | Convergence without connectivity, category support, or identification evidence. |
| Information criteria | Comparable MML fits expose the same observed-data likelihood basis, free dimension after constraints, Person-based sample size for the current fixed-facet model, exact AIC/BIC/SABIC formula, and locked integration evaluation. | Response-row `N`, summed observation weights, JML incidental-parameter IC ranking, an unlabeled native `aBIC`, or a ranking that changes across the integration ladder. |
| Dimensionality challenge | Prespecified synthetic 1D/2D controls, matched mfrmr/TAM 1D fits, independently confirmed TAM alternatives, integration-stability checks, rater-by-criterion confounding checks, and consequence classifications meet their locked criteria. | A naive LRT p-value, significance driven only by large N, a Q matrix generated and confirmed on the same data, one QMC node count, or better multidimensional fit without score-utility evidence. |
| External overlap | Matched ConQuest/TAM MML rows, the pinned FACETS 4.5.0 JML RSM/PCM stress core, the TAM/immer JML convention grid, and eligible immer CML/CCML structural rows pass locked, estimand-specific rules; optional FACETS fit/DFF and immer HRM challenge rows retain their distinct roles. | Correlation alone, any external program as truth, pooled adjustment/version modes, unmatched constraints, CML person comparisons, HRM-as-estimator reasoning, or comparison of MML/EAP persons with JML persons. |
| Public contract | Code, help, README, vignettes, capability tables, exports, and runtime guards state the same support boundary. | A roadmap sentence or callable internal helper by itself. |
| Engineering release | Exact-candidate checks, full suite, platform matrix, manuals, package contents, URLs, examples, timing, and Win-builder are acceptable. | A source-tree check that was not run on the upload tarball. |

`blocker`, `caveat`, and `roadmap` remain separate states. A blocker failure is
0.2.3 `No-Go`. A caveat may ship only when it is unavoidable in first-screen
output and documentation. A roadmap row must be guarded from ordinary use and
must not be advertised as implemented.

### MML stationarity and independent numerical checks

- [x] Add and run the draft.12 fixed-fixture pilot that verifies analytic score
  components against an independently implemented central-difference
  reference on small binary, RSM, PCM, and bounded-GPCM fixtures. This checks
  instrumentation and supplies calibration data; it is not confirmation.
- [x] Define the canonical free-parameter score for the current models and
  store the bounded-GPCM coordinate system and transformation Jacobian. The
  current positive-slope GPCM route is transformed, not box-constrained, so no
  projected-gradient rule applies to it.
- [ ] Expand the score pilot by model/parameter class and near-boundary slope
  regime, then freeze absolute/scaled `NUM-SCORE-TOL` before confirmation.
- [x] Add a general non-unit GPCM oracle that independently reconstructs the
  positive-slope transform, response kernel, Person-wise marginal objective,
  and numeric free-coordinate score at retained, high-dispersion, and finite
  forward/reverse stress points. Keep this calibration-only and leave rows
  5--6 in review.
- [x] Prespecify the remaining criterion-owner/rater-owner, five-category,
  sparse/workload-imbalanced, weak-link, and category-imbalance cells plus
  parameter-class-specific absolute/scaled score, Jacobian, and margin rules.
  The resulting no-execution contract has eight cells, 128 mandatory
  scenario/point/class strata, and 63 fail-closed expectations.
- [x] Implement an exact identity-bound runner and execute the frozen eight-
  cell v2 calibration once. Retain its `rejected` result: all 128 evidence rows
  were complete, while 33/672 coordinate rows and three Jacobian point rows
  failed the conjunctive scale rule.
- [x] Attribute the failed strata without changing v2. A fine objective-step
  ladder demonstrated the extreme-slope locality/cancellation tradeoff, while
  an independently reconstructed Person-posterior sufficient-statistic score
  passed all 48 attribution strata with maximum difference `1.05e-9`.
- [x] Specify v3 before opening new evidence: use independent analytic-score
  agreement everywhere, finite differences with one combined absolute-plus-
  relative allowance only inside the prespecified log-slope envelope
  `[-3, 3]`, and an explicit non-promoting boundary/readiness handoff outside
  it. Retrospective calibration is not confirmation; preserve the eventual
  frozen rule unchanged for disjoint exact-candidate confirmation.
- [x] Implement one identity-bound bounded v3 replay of the same deterministic
  eight cells. The artifact-reuse audit found that the v2 bundle preserves all
  128 structural/finite-difference strata, but independent analytic evidence
  covers only 48/128 strata and the 32 Jacobian summaries lack the entrywise
  scales needed for exact combined ratios. Record all denominators and
  entrywise comparisons; do not reverse-engineer a pass from separate maxima,
  call the replay confirmation, or use it to prove a boundary.
- [x] Reject the first nominal v3 pass after repeatability failed, replace
  random approximate-tie `max.col()` stabilization with deterministic first-
  maximum selection across likelihood/prediction paths, retain owned cache-key
  snapshots, and rebuild v2 attribution and v3 under the corrected payload.
  Corrected v2 retains the 33-coordinate/three-Jacobian rejection; corrected
  v3 completes 128 strata and 384 entrywise Jacobian rows and passes its
  bounded retrospective rule while every fit remains inference-unready.
- [x] Review and freeze the corrected v3 calibration rule and exact source
  identity before opening disjoint exact-candidate confirmation. Freeze review
  found that the first corrected identity omitted the numerical coordinate/
  Jacobian helper; source-bound v2, attribution, and v3 artifacts now name it,
  reproduce the same numerical tables, and pass a nine-source/full-denominator
  seal. This freezes only the bounded rule for confirmation and does not claim
  a boundary, finite extreme-slope maximum, or general score tolerance.
- [x] Specify and seal disjoint exact-candidate confirmation fixtures and
  fixture hashes without changing the frozen v3 rule. Three deterministic
  noncalibration structures crossed with both slope owners fix six scenarios,
  96 evidence strata, 560 coordinates, 24 points, and 376 Jacobian rows. No fit
  or confirmation result was opened.
- [x] Implement a record-consuming, dry-run-by-default confirmation runner and
  a separate fresh-process/output-absence execution authorization contract.
  Exact design/source/payload/freeze/manifest hashes, class-specific and
  Jacobian-specific denominators, stale-record rejection, and occupied-target
  negative tests pass. The actual default decision remains
  `no_go_not_issued`; no confirmation result was opened.
- [x] In one fresh process, recompute preflight, issue one exact target-bound
  authorization record, and consume it once without result-dependent retry or
  setting change. Retain the complete `rejected` result: every numerical
  component passed, but a constructed six-level boundary was represented as
  `3.0000000000000009` and failed the frozen raw inclusive classifier.
- [x] Specify v4 without execution: derive a representation-aware inclusive-
  boundary rule from binary64 input/summation/comparison error bounds, preserve
  zero allowance for retained extremes, leave all four numerical comparison
  rules unchanged, and require the exact consumed authorization row in the
  result bundle. Opened v3 fixtures are calibration-only.
- [x] Apply the prespecified v4 classifier retrospectively to the opened v3
  bundle without fitting. Exactly one intended boundary changes region and all
  retained extremes remain unchanged. Record the honest incomplete result:
  the reclassified point lacks a saved finite difference and the old bundle
  lacks its consumed authorization row, so v4 is not freeze-ready.
- [x] Seal one new calibration-only deterministic boundary fixture without
  fitting. Fix one Criterion-owned six-level forward-boundary scenario with
  4 evidence rows, 24 coordinates, 1 point, and 30 Jacobian rows; permanently
  mark it ineligible for later v4 confirmation.
- [x] Implement its dry-run runner and separate target-bound authorization
  without fitting. Bind exact source/payload/design/rule/manifest identities,
  same-process issuance, authorization-source and row hashes, exact absent
  target, and the 4/24/1/30 denominator; require the consumed row to be embedded.
- [x] In one fresh process, issue and immediately consume the exact target-bound
  row without retry. Independently validate the saved 4/24/1/30 result,
  issued/consumed hashes, source chain, target resolution, aggregation, and
  non-promotion boundary. All numerical rules pass; the fit remains `review`.
- [x] Conduct a no-execution v4 freeze review over the full rule,
  retrospective, completion, authorization, and validator lineage. Record the
  repository-relative/non-absolute target form explicitly and freeze only the
  bounded calibration rule and interpretation.
- [x] Seal a new structurally disjoint v4 confirmation family without fitting.
  Reuse no v3/completion identities or response constructions; fix six
  Criterion/Rater-owned scenarios and 96/888/24/688 denominators across sparse,
  balanced, and workload-imbalanced 5/6/7-category designs.
- [x] Implement the v4 confirmation dry-run runner, separate same-process
  authorization, and prospectively sealed independent validator. The absent
  absolute-target, issued/consumed-row, source/manifest, fixed 96/888/24/688
  denominator, incomplete-result, and mutation guards passed 74 no-fit
  expectations before execution.
- [x] Consume the v4 confirmation authorization exactly once without retry.
  All frozen score and Jacobian comparisons passed, but two Criterion-owned
  fits reached the iteration limit and were `blocked`. The runner omitted fit
  readiness from its final aggregation and reported a false-positive candidate
  pass; the sealed validator also exposed a separate names-attribute defect.
  The immutable no-fit retrospective audit therefore records
  `rejected_runner_false_positive_and_blocked_fits`. No retry, rule adjustment,
  general tolerance, boundary, inference, or 0.2.3 promotion is authorized.
- [x] Add and run the draft.13 fixed-fixture pilot that compares direct,
  hybrid, and converged-EM-plus-common-direct-polish routes at the same
  retained parameter vectors, objective, quadrature, coordinate order, and
  identification constraints. This instruments the contract; it does not
  freeze agreement tolerances or establish confirmation evidence.
- [x] In that pilot, retain raw EM and native optimizer states only as
  diagnostics; neither can override the common-vector or canonical-score
  rules, and EM-plus-polish must start from the exact hashed raw-EM vector.
- [ ] Expand the engine-path pilot by fixture, parameter class, and platform,
  then freeze absolute/scaled `NUM-OBJECTIVE-TOL` and
  `NUM-PARAMETER-TOL` before confirmation.
- [x] Implement the deterministic 0.2.3 `maxit` stable slice: use a
  prespecified ceiling sequence, never select a preferred later result, keep
  iteration-limited fits review-only, and validate release-evidence attempts
  against an invariant specification hash and first-eligible-run rule. Row 8
  remains `review` until exact-candidate confirmation applies the same contract.
- [x] Add exact reduction checks: two-category polytomous cases reduce to the
  intended binary model, RSM/PCM unit-slope cases agree, and bounded-GPCM
  score-side transformations use the same retained fit.
- [x] Close release-spine row 9 structurally after extending those reductions
  to a separately implemented category-kernel/person-marginal oracle, explicit
  free/expanded step and slope identities, and fail-closed numeric mutation
  tests. This does not close the broader score-tolerance rows 5--6.
- [ ] Keep JML regression and FACETS-overlap checks distinct from the MML
  recovery gate; no JML-versus-MML equality criterion is permitted.

### Recovery and sparse-data stress envelope

- [x] Execute all six previously declared executable 400-Person
  `target_sparse` covering-grid cells as a guarded one-replicate capacity-
  feasibility run. Record zero unexpected runner failures and zero false-ready
  rows, but keep the one ready PCM-MML cell, blocked free-slope GPCM-MML cell,
  and all runtime/memory values out of recovery or capacity-limit claims.
- [ ] Define core cells across response family, sample size, facet-level count,
  category support, anchor pattern, link density, and bounded-GPCM slope
  regime. Select replication counts from a prespecified Monte Carlo standard-
  error target rather than convenience.
- [ ] Separate ordinary sparse-but-connected, weak-link/bridge, articulation,
  zero-common-person-pair, disconnected, empty-category, and extreme-score
  scenarios. Do not pool these into one generic `sparse` label.
- [x] Add pilot cells for complete two-rater assignment, one rater per Person
  with zero common Persons, and a three-Person bridge. The one-seed result
  diagnoses false-readiness risk but does not freeze a minimum design.
- [ ] Add a Person-sharing graph and report rater-panel size, common-Person
  counts, bridge strength, articulation, component balance, and local
  information. A binary response-graph connection must not override a weak or
  unidentified rater comparison.
- [ ] Construct the constrained free-coordinate design implied by active
  facets, centering, anchors, and structural absences; reject exact rank
  deficiency before fitting and expose aliased directions. Only after full
  rank is established may fitted information diagnose weak identification.
- [x] Add pilot cells for middle-category dominance, single-category
  dominance with an unused category, and skewed targeting; retain category
  counts, maximum proportion, and normalized entropy by model.
- [ ] Freeze model-specific category-support states using minimum counts,
  concentration/entropy, local facet support, and threshold information. A
  globally consecutive category range is not sufficient evidence of usable
  step information.
- [ ] Make external normalization compare the declared category map, retained
  category map, and free step dimension by scale/step-facet level before any
  element or Person tolerance. Category-dropping and `K` controls remain
  failure-policy evidence unless the fitted dimensions genuinely match.
- [x] Represent a standard free extreme JML Person primary result as typed
  low/high unbounded status rather than an optimizer-dependent finite value;
  preserve the finite iterate only as a numerical trace, keep MML/EAP finite,
  and exclude the boundary from ordinary SE/CI and finite ruler placement.
- [ ] Generalize the boundary proof to eligible constrained non-Person and
  interaction elements, add any named finite adjustment only outside the
  primary estimand, and make external Person comparisons stratify nonextreme
  and explicitly adjustment-matched rows.
- [ ] Record numerical convergence, identification, data/design readiness,
  inferential readiness, bias, RMSE, interval coverage where defined,
  terminal score, objective, condition indicators, and elapsed time by cell.
- [ ] Pair every FACETS core replicate with the same generated observations and
  truth record used by mfrmr. Judge truth recovery for each program separately
  before judging transformed mfrmr-minus-FACETS differences; agreement between
  two biased estimates is not validation.
- [ ] Use microcases, baseline cells, one-factor stresses, targeted interactions,
  and sensitivity cells instead of an unreviewed full Cartesian product. Freeze
  the selected cells and Monte Carlo precision rule before confirmation.
- [ ] Require disconnected or unidentified negative controls to fail closed.
  A negative control reported as numerically and inferentially ready is a
  blocker even if its optimizer converged.
- [ ] Use three execution tiers: a deterministic CRAN smoke tier, a release-
  blocking core tier outside CRAN, and an extended sensitivity tier that cannot
  hide a failed core cell.
- [ ] Retain per-replicate results outside the package, compact aggregate
  evidence in the repository, and a manifest linking both to the candidate.

### Interaction, bias-screening, and residual-PCA stress

- [x] Add one-seed zero-marginal Rater-by-Criterion checkerboards at 0.4 and
  1.0 logits and retain additive bias-screen and fitted-interaction results
  separately. The weak RSM bias screen missed its target in this seed; this is
  a calibration finding, not a power estimate.
- [ ] Calibrate null false-positive and non-null detection behavior over
  effect size, cell information, sample size, topology, category support,
  multiplicity method, and numerical-readiness state. Report Monte Carlo
  uncertainty and failed-replicate accounting; do not promote `p <= .05` and
  `|t| >= 2` as an automatic decision rule.
- [x] Add planted local response dependence and compare mfrmr residual PC1 to
  its residual-permutation cutoff and to FACETS raw-residual PC1 as descriptive
  sensitivity. Retain the weak-overlap discrepancy even though matched
  standardized residuals correlate above 0.996.
- [x] Exercise the residual-PCA route in the 400-Person target feasibility
  cells. Retain the case in which `psych` reports an undefined smoothed-
  correlation determinant/objective even though an exploratory object returns;
  do not reinterpret this as a valid PCA diagnostic.
- [ ] Capture residual-PCA condition messages, residual-matrix dimension/rank,
  pairwise support, and smoothing/repair state, then derive a fail-closed
  computability status before null/non-null calibration.
- [ ] Freeze the residual definition, missing-pair correlation/smoothing rule,
  permutation unit, quantile precision, and null/alternative seed grid. PCAR
  remains exploratory hypothesis generation and cannot name a latent
  dimension without an independently fitted alternative and consequence
  analysis.
- [ ] Build FACETS Table 14 bias controls with explicit `?B` terms only after
  centering, estimand, SE, degrees-of-freedom, and multiplicity conventions are
  definition-matched. Do not compare Table 14 mechanically with
  `estimate_bias()` merely because both use the word bias.

### Information-criterion contract for fitted MML objects

For the current marginal MML models, persons are the independent likelihood
units after the latent person parameter is integrated out, while item, rater,
criterion, step, and interaction effects remain fixed parameters. The 0.2.2
implementation instead uses response-row count, or the sum of observation
weights, in the BIC penalty. That value may remain as descriptive/legacy `N`,
but it must not remain the implicit BIC sample size in 0.2.3.

- [x] Add an auditable criterion record to fitted MML objects and
  `compare_mfrm()`: deviance `D = -2 logLik`, free-parameter count `k`,
  `ICSampleSize`, `ICSampleSizeBasis`, formula identifier, and integration
  evaluation identity. Compute the common panel as
  `AIC = D + 2k`, `BIC = D + log(N_person) k`, and
  `SABIC = D + log((N_person + 2) / 24) k`, with an explicit
  `sclove_n_plus_2_over_24` formula identifier.
- [x] Count `k` as the dimension of the free optimization vector after all
  anchors, centering constraints, and fixed parameters. MML posterior person
  estimates are not free model parameters; estimated latent-regression,
  variance/covariance, slope, step, and interaction coordinates are. Assert
  the stored count against the retained optimization vector.
- [x] Keep response rows, weighted response total, and unique Persons in
  separate fields; do not silently repurpose the legacy summary `N`. Regression
  fixtures show that unbalanced and missing response layouts do not convert
  fixed-facet MML BIC back to response-row N.
- [x] At the deliberate development-version transition, add the visible
  0.2.2-to-0.2.3 NEWS migration note and align `DESCRIPTION` and
  `CITATION.cff` on 0.2.3 while preserving the historical 0.2.2 NEWS section.
- [x] Fail closed for non-unit observation weights until their sampling
  semantics are explicit. In particular, `sum(Weight)` is not automatically
  the number of independent Persons. In 0.2.3, explicit all-unit weights are
  equivalent to the unweighted path, while every non-unit observation-weight
  fit—including a weight constant within Person—remains descriptive and
  carries `ICComparable = FALSE`.
- [x] Keep JML outside primary AIC/BIC/SABIC ranking. Its fitted person effects
  are incidental parameters whose number grows with the Person sample, so a
  finite raw value must be labelled descriptive rather than treated as the
  same asymptotic criterion used for marginal MML.
- [ ] Normalize external MML comparisons by recomputing AIC, Person-based BIC,
  and common `SABIC` from each engine's comparable deviance, `k`, and Person
  count. Preserve each engine's native IC fields and exact formula separately.
  TAM's native `aBIC` must not be relabelled as common `SABIC`; the audited TAM
  4.3-25/source snapshot uses `log((n - 2) / 24)`, whereas the prespecified
  common Sclove form uses `log((n + 2) / 24)`. Every later external run must
  re-record its installed TAM version and formula rather than assuming this
  snapshot remains unchanged.
  - [x] Add repository-only contract `mfrmr_external_ic_v1`, backed by the
    package's single common-panel formula builder. It keeps every native
    criterion and formula separate, requires explicit observation,
    likelihood, constraint, integration-evaluation, and integration-comparison
    identities, and suppresses deltas/weights until convergence and integration
    stability both pass.
  - [x] Add seven arithmetic/fail-closed fixtures plus a TAM 4.3-25 adapter
    check showing that native `aBIC = D + log((n - 2) / 24)k` is preserved and
    differs from common Sclove `SABIC = D + log((n + 2) / 24)k`.
  - [x] Extend the generated ConQuest handoff with an estimate `matrixout`
    history CSV, explicit stopping controls, and a repository-only adapter. It
    audits deviance, free dimension by two independent paths, the final
    exported parameter vector, unit weights, exact bundle-to-export Person
    IDs, run metadata, convergence-evidence identity, integration-evaluation
    identity, and output fingerprints without parsing the free-form summary
    report.
  - [x] Run one strict-control, 31-node binary development pilot. Its deviance
    matched mfrmr within the six-decimal ConQuest export resolution and its
    largest audited transformed-parameter difference was `5.77e-6`; this is
    pilot evidence, not a frozen tolerance or release result.
  - [x] Add a repository-only strict binary ladder at
    `q = 7, 15, 31, 61, 91, 121` plus an independent same-platform q=31
    rerun. The q=31--121 arithmetic rows shared the same six-decimal ConQuest
    deviance, and all five native q=31 CSV files were byte-identical across
    runs. The adapter rejected q=7 after ConQuest retained an earlier
    higher-likelihood solution and rejected q=15 because its final history and
    exported vectors differed by up to `8.7e-5`. This is pilot calibration,
    not an integration-stability pass.
  - [x] Add a repository-only four-category q=31 RSM/PCM pilot on one fixed
    120-Person, five-item input. The native free dimensions were 9 and 17,
    reconstructed item and step constraints had zero residual, both objective
    differences were at most `1.25e-6`, and transformed-parameter differences
    were at most `1.60e-6`. The RSM-minus-PCM deviance-drop difference across
    engines was `1.11e-6`. This is same-platform mapping evidence only.
  - [x] Extend the same fixture to matched RSM/PCM ladders at
    `q = 7, 15, 31, 61, 91, 121` plus fresh same-platform q=31 repeats. Every
    q=31--121 core row passed, the largest cross-engine deviance and
    transformed-parameter differences were `1.25e-6` and `1.6743e-6`, and each model's
    five native q=31 CSV files were byte-identical across repeats. RSM q=7/q=15
    and PCM q=15 remained arithmetically extractable but numerically unstable;
    PCM q=7 failed closed on a final-history/export mismatch. This calibrates
    the ladder but freezes no tolerance.
  - [ ] Repeat the binary and polytomous cores on an independent
    platform/version, complete and freeze the integration review, and run
    candidate-linked mfrmr/TAM/ConQuest pilots before treating any normalized
    comparison as release evidence.
- [ ] Evaluate compared criteria on a common, locked quadrature/QMC basis and
  require delta-criterion/model-order stability over the integration ladder.
  An IC calculated from a deviance whose numerical drift is large relative to
  the model difference is not release evidence.
  - [x] Add a repository-only fixed-retained-vector common-GHQ evaluator with
    source-objective, data, constraint, weight, method, and readiness guards.
  - [x] Run a deterministic six-scenario matrix over
    `q = 7, 15, 31, 61, 91, 121`, covering RSM/PCM, bounded GPCM, a sparse
    linked assignment, Rater-by-Criterion interaction, latent regression, and
    a wide-latent near-tie stress. q=31--121 retained every criterion ordering;
    the maxima were raw drift `0.039737`, pairwise-gap drift `0.009244`, and
    relative gap drift `0.01601` against q=121.
  - [x] Add an independent-refit/common-q=121 layer for all six scenarios. The
    q=31--121 core retained all orderings; q=7 reversed AIC/SABIC in the
    wide-latent cell, while common-q reevaluation restored the reference
    ordering and isolated the principal coarse-grid effect as integration
    approximation.
  - [x] Fail closed below q=31: q<15 is screening-only, q=15--30 is
    review-only, and raw canonical criteria cannot generate deltas, weights,
    preferred-model labels, evidence ratios, or LRT until q>=31.
  - [x] Add the first TAM 1D/2D product-quadrature and deterministic-QMC
    calibration layer. In the true-1D control, product q=15 reversed all three
    common IC signs while q=21--41 agreed; the 512--4096 QMC ladder retained
    signs but showed maximum gap drift 0.188 across the two controls. Exact
    1024-node refits reproduced every deviance and retained parameter.
  - [x] Add a first 1024-node `QMC = FALSE` four-seed audit. Maximum criterion-
    gap seed drift was 3.966 in the true-1D control and 2.866 in the true-2D
    control; true-1D raw deviance-gain sign changed across seeds.
  - [ ] Add weak-link/near-boundary and cross-platform cells, multi-node
    stochastic TAM repeats, and replicated dimensionality controls; then review
    and freeze the ladder and `IC-INTEGRATION-TOL` before confirmation. Treat
    q>=31 for mfrmr and the observed TAM q>=21 behavior as pilot starting
    points, not automatic proof of numerical stability.
- [x] Present raw and delta criteria as complementary evidence, not an
  automatic dimensionality verdict or literal model probability. SABIC is a
  small-sample sensitivity criterion, not a universal tie-breaker; when
  `N_person <= 22`, its Sclove penalty is non-positive and cannot be a blocker.
  BIC/SABIC also remain sensitive to tiny systematic gains at large N and to
  boundary/singular models, so consequence and calibration gates still apply.
- [x] Test package-native exact formulas, constraint-aware `k`,
  Person-versus-row `N`, missing layouts, weight-policy suppression, JML and
  legacy-object suppression, stored-value tampering, integration identity,
  and agreement across fit summaries, `compare_mfrm()`, and reporting bundles.
- [x] Add imported TAM native-IC provenance, formula verification, estimator
  and dimension guards, plus repository external-normalizer metadata tests.
- [ ] Complete end-to-end agreement through ConQuest exports and
  candidate-linked release evidence.

### Dimensionality challenge: explore, confirm, then test consequences

The 0.2.3 dimensionality work is an external challenge to the supported
unidimensional contract, not a native multidimensional `mfrmr` feature. TAM may
fit prespecified multidimensional MML alternatives in release evidence, while
`mfrmr` continues to fit and report one latent dimension. A better-fitting TAM
model cannot silently create a multidimensional `mfrmr` support claim.

| Stage | Required work | Permitted conclusion |
| --- | --- | --- |
| Explore | Use substantive theory, design review, residual PCAR/parallel-analysis patterns, and Q3-style residual correlations to propose item/criterion clusters, local-dependence pairs, rater effects, and candidate Q matrices. | A versioned hypothesis set for confirmation; no dimensionality decision and no subscore claim. |
| Confirm | Freeze Q matrices, axis labels, variance/covariance constraints, response family, data partition, integration policy, and comparison metrics. First establish matched TAM-versus-mfrmr 1D overlap, then compare TAM 1D with each prespecified TAM multidimensional alternative on untouched persons or an external sample. | Evidence for or against the specified 1D model relative to specified alternatives; not proof that every omitted structure is absent. |
| Test consequences | Evaluate whether the confirmed structure changes score precision, prediction, classification, ranking, invariance, or an external decision enough to justify a different reporting policy. | Total-score-only, multidimensionality-as-nuisance/sensitivity, or a future subscore research case; 0.2.3 does not produce native dimension scores. |

- [ ] Split discovery and confirmation by Person, stratified as needed to retain
  rater/criterion coverage and connectivity. If sparse design prevents an
  honest holdout and no external replication exists, label the result
  same-sample sensitivity evidence rather than independent confirmation.
  Cross-fitting may recover precision, but every fold assignment and
  aggregation rule must be frozen before confirmatory results are viewed.
- [ ] Keep residual exploration broad enough to challenge a mistaken Q matrix.
  Inspect PCAR loadings and scree/parallel evidence together with residual-pair
  clusters and content/design labels; a quiet result for one candidate Q does
  not establish global unidimensionality.
- [ ] Treat fixed PCAR eigenvalue and residual-correlation cutoffs as
  exploratory only. Their null behavior depends on sample size, item/facet
  count, category structure, missingness, targeting, and residual definition;
  use a design-specific simulated or bootstrap reference before a statistic can
  enter a blocking row.
- [ ] Preserve the current `q3_statistic()` naming boundary. It uses
  standardized residuals aggregated to Person-by-facet-level cells, and its
  relative-pair flag is not the published raw-residual
  `Q3* = Q3_max - mean(Q3)`. Do not relabel it as Q3*. A formal Q3* gate needs
  an explicit residual/unit-of-analysis definition, multiplicity policy, and
  design-specific parametric bootstrap; otherwise report `Q3-style` only.
- [ ] Use a four-model attribution grid where the design permits it: 1D
  additive facets, 1D plus rater-by-criterion interaction, multidimensional
  additive facets, and multidimensional plus that interaction. Include fully
  crossed, weakly crossed, and deliberately confounded synthetic cells. If
  rater assignment and criterion structure make the interaction inseparable
  from a latent dimension, classify the design as unidentified rather than
  awarding the fit gain to either explanation.
- [ ] Use TAM 1D versus TAM multidimensional fits for formal within-engine model
  evidence. Use mfrmr 1D versus TAM 1D to establish the external baseline. Do
  not apply a direct mfrmr-1D-versus-TAM-multidimensional LRT or cross-engine
  IC ranking until observation likelihoods, constants, parameter counts,
  constraints, Person-based sample sizes, exact IC formulas, and integration
  bases are demonstrably comparable. Retain native engine criteria for audit,
  but make decisions from the normalized common panel.
  - [x] Implement the pilot-only within-TAM binary 1D/2D grid with common
    Person-basis IC arithmetic, per-Person/per-response gain, Q hashes,
    integration identities, parameter drift, and selection suppression.
  - [ ] Replicate the truth cells and freeze integration, failure, and practical
    criteria before this becomes formal model evidence.
- [ ] Do not use the ordinary chi-square LRT p-value as a blocker. One dimension
  can correspond to a zero variance or perfect-correlation boundary of the
  multidimensional model, invalidating the regular chi-square reference. First
  prove the nesting relation; when a boundary remains, use a prespecified
  parametric-bootstrap deviance-difference reference and report boundary,
  singular-fit, and failed-replicate frequencies.
- [ ] Do not turn large-N significance into practical multidimensionality.
  Alongside any calibrated p-value, report deviance/log-likelihood gain per
  Person and per response, AIC, Person-based BIC, and Sclove SABIC where their
  bases are valid, held-out predictive gain where feasible, residual reduction,
  dimension correlations, parameter stability, and numerical uncertainty.
  Freeze a smallest practically relevant gain during M2 pilot work; do not
  invent it after observing the confirmatory data. Agreement among ICs does not
  replace the practical-consequence test.
- [ ] Treat TAM QMC variation precisely. With `QMC = TRUE`, finite-node
  integration is nonstochastic, but its approximate deviance can drift with
  `snodes`; `QMC = FALSE` adds stochastic variation. For the 2D core, compare
  product-quadrature node ladders with locked QMC node ladders, repeat any
  stochastic integration, and require the model ordering, retained parameters,
  and deviance difference to be stable relative to the prespecified numerical
  uncertainty. Record TAM version, Q hash, node sequence/count, QMC setting,
  seed where operative, convergence controls, and starts.
  - [x] Record the first deterministic 512--4096-node QMC ladder and verify at
    1024 nodes that two fresh refits return exactly identical deviances and
    retained parameters for both models in both synthetic controls.
  - [x] Record the first four-seed `QMC = FALSE`, 1024-node audit with operative
    seeds in every integration-evaluation identity; its seed drift remains
    review-only and cannot choose a favored run.
  - [ ] Expand stochastic integration over node counts and required platforms,
    freeze its seed aggregation and failure policy, then freeze the numerical
    uncertainty rule.
- [ ] Separate structural fit from score-reporting value. A statistically
  multidimensional model may represent local dependence, testlets, or nuisance
  rater behavior and still provide no useful individual subscore. Before any
  future subscore claim, compare each direct dimension score with prediction
  from the total score using prespecified mean-squared-error/PRMSE-style value,
  conditional precision and information, replication stability,
  classification/rank changes, and external-criterion increment where one is
  defensible. If the added value is absent, retain a total score and describe
  multidimensionality only as model/sensitivity evidence.
- [ ] Make synthetic decisions release-blocking but keep empirical-case claims
  conditional. A true-1D core must control false multidimensional selections;
  a prespecified true-2D core must show useful detection power, including weak
  and highly correlated dimensions. A real-data improvement is a scoped
  sensitivity result, not ground truth and not permission to expose native
  multidimensional scores.
- [x] Make `import_tam_fit()` fail closed for `tam.jml` and `ndim > 1` rather
  than relabelling or flattening them. Supported 1D imports preserve the TAM
  MML class, dimension count, version, native IC fields/formulas, and a
  conservative stop-before-iteration-ceiling status.
- [x] Extract multidimensional validation evidence through a separate
  dimension-aware repository runner that cannot be imported as a native
  multidimensional mfrmr fit.
- [ ] Calibrate the fuller TAM convergence review, including final-history
  reevaluation differences, singular/boundary cases, warnings, and failed
  replicates, until a native multidimensional object contract is designed for
  0.3 or later.

### External comparison gate

- [ ] Make ConQuest the mandatory 0.2.3 external core for matched
  unidimensional MML binary, RSM, and PCM cases. Add a latent-regression case
  only when both design matrices and coefficient transformations are explicit.
  - [x] Instrument same-platform pilot coverage for binary and four-category
    RSM/PCM cases; keep every row non-comparison-ready until independent
    replication, integration review, tolerance freeze, and candidate-linked
    confirmation are complete.
- [ ] Compare the same observations, missingness, category maps, model,
  constraints, quadrature, starting-value interpretation, convergence target,
  facet orientation, and reported parameter transformation wherever the two
  programs permit matching.
- [ ] Report absolute and signed differences by parameter class, objective or
  deviance differences where comparable, and readiness/provenance metadata.
  Correlation may be descriptive but cannot be the acceptance statistic.
- [ ] Classify every non-passing row as parameterization, identification,
  numerical, reporting, unsupported, or unresolved. An unresolved core row is
  `No-Go`; an unsupported row must remain outside the public claim.
- [ ] Record the selected FACETS 4.5.0 executable/report identity using
  deterministic binary, RSM, and PCM microcases. Bind executable SHA-256, file
  metadata, report-header version, command/control/input/output hashes,
  parser/generator hashes, locale, and run date. A version discrepancy is
  reported without stopping unrelated runs; different versions are never
  silently pooled.
- [ ] Run the mandatory FACETS JML RSM/PCM stress core defined in
  `inst/validation/facets-jml-stress-plan-0.2.3.md`: ordinary connected
  recovery, element/group anchors, sparse/weak-link topology, and edge cases.
  Require complete replicate accounting and frozen truth, coverage,
  false-ready, and transformed-difference rules.
  - [x] Run a one-seed, 22-scenario-per-model calibration pilot with the local
    FACETS 4.5.0 executable; account for all 44 reports and preserve the result
    as non-confirmatory review evidence.
  - [x] Run nine extension scenarios per model for two-rater panels, severe
    category imbalance, checkerboard interactions, and residual local
    dependence; bind the diagnostic rerun to exact FACETS-manifest seeds.
    Preserve the result as draft.19 calibration evidence only.
  - [x] Run the draft.20 divergence audit on the completed 18-row extension
    and 44-row expanded pilot. Preserve its rank, retained-category, and
    extreme-score decomposition as diagnosis only; it rejects invalid
    comparison rows and does not validate a model.
  - [ ] Add the audit contract to the paired normalizer so unmatched category
    maps/step dimensions, rank-deficient designs, and unmatched extreme-score
    displays cannot enter parameter-agreement aggregates.
  - [ ] Add quantitative bridge-strength, articulation, component-balance, and
    local-information diagnostics. A single bridge must not inherit the same
    readiness meaning as a robustly crossed design merely because both graphs
    are technically connected.
- [ ] Treat FACETS fit and DFF/DIF evidence as separately promotable rows. They
  enter the public support envelope only after statistic definition, null/non-
  null generator, multiplicity, estimand, and acceptance rule match; attractive
  output or familiar labels are insufficient.
- [ ] Do not use FACETS JML person measures as an external target for MML EAP
  person scores. Compare model parameters or JML outputs only where estimands,
  constraints, and extreme-score handling match.
- [ ] Add a TAM/immer JML convention grid using identical generated rows,
  category maps, weights, facet design matrices, free-coordinate
  transformations, and truth. Preserve at least these identities separately:
  mfrmr uncorrected JML; TAM unadjusted, extreme-adjusted, and documented
  bias-reduced JML; immer unadjusted, extreme-adjusted, and bias-corrected JML.
  Do not choose or pool modes after seeing which agrees most closely.
- [ ] For every JML mode, report structural-parameter bias/RMSE, supported SE or
  interval coverage, extreme and nonextreme Person behavior, false-ready and
  failed-run rates, and the transformed between-program difference. A missing
  SE is an explicit unsupported cell, not zero uncertainty. Current mfrmr
  observation-information SEs remain exploratory until the coverage gate is
  passed; the grid does not imply a profile-likelihood Hessian.
- [ ] Stress the JML convention grid across balanced and unequal Person
  information, two-rater panels, sparse/weak links, planned and unplanned
  missingness, category imbalance, extreme scores, and increasing Persons with
  fixed per-Person observations. The last axis is the incidental-parameter
  control and must not be replaced by a large-N pooled summary.
- [ ] Add immer CML and CCML only as conditional Rasch-family structural-
  parameter references. Verify sufficient-statistic conditioning, design-
  matrix rank, constraint basis, category support, and missingness eligibility.
  Exclude Person estimates, bounded GPCM, latent-regression, and any quantity
  eliminated by conditioning. CML/CCML evidence cannot be relabelled as a
  native mfrmr capability.
- [ ] Add an immer HRM-generated local-dependence challenge after its latent
  true-rating, rater-severity/variability, prior, MCMC convergence, and label-
  switching contracts are frozen. Evaluate how the current additive mfrmr
  diagnostics fail or respond under this alternative. Do not include HRM rows
  in engine-equivalence tolerances and do not infer that HRM is preferred from
  one misspecified additive fit.
- [ ] Record CRAN and development TAM/immer identities as separate strata,
  including package version, source/repository identity, R version, dependency
  versions, function arguments/defaults, design-matrix hash, input/output hash,
  and normalizer version. A changed default is a new method-mode identity even
  if the package version is unchanged locally.
- [ ] Keep proprietary binaries and identifier-bearing case files outside the
  package while retaining commands, synthetic/public inputs, normalized
  aggregate outputs, hashes, versions, and run dates needed for audit.
- [x] Derive and test the exact ConQuest/mfrmr item-only active-latent-
  regression GPCM likelihood and coordinate map, then complete one native
  structural microcase. Keep it as deferred review evidence: no numerical row
  is eligible until a new candidate, raw-token rule, integration ladder,
  mfrmr fit readiness, and prospective tolerance are all bound. Reject
  standard multifacet and JML rows rather than silently expanding the map.

### FACETS coverage and release tooling

- [x] Extend `facets_feature_coverage()` with separate axes for surface
  coverage, statistical contract, validation evidence, and operational status,
  while retaining the current `Status` column for compatibility.
- [x] Distinguish familiar visual grammar, matched numerical evidence, and
  operational interchangeability as three different claims.
- [x] Require `--as-cran` provenance, metadata agreement, candidate identity,
  gate-specification identity, and current-versus-future API truth in release-
  readiness output.
- [x] Replace brittle prose-only pass counts with candidate-linked evidence or
  regenerate exact counts at each release.
- [x] Add negative tests ensuring future calibration, threshold-anchor,
  multi-scale, and unrestricted-GPCM terms cannot be reported as current 0.2.3
  support.
- [ ] Add a candidate-linked, machine-readable support-envelope registry with
  estimator, model, parameter/statistic, design conditions, maturity state,
  operational state, caveat, criterion ID, and evidence-manifest hash. Unknown
  combinations must resolve to `unsupported`, not inherit a nearby row.
- [ ] Add the FACETS batch audit: isolated synthetic run directories, one
  process by default, timeout and exit-code capture, exact expected-output
  inventory, parser failure tests, and a repository privacy/license scan.

### 0.2.3 Definition of Done

0.2.3 may become a release candidate only when:

- [ ] the M1 draft was reviewed and the M2 gate specification was frozen after
  pilot calibration but before confirmatory evidence;
- [ ] every numerical, recovery, sparse-design, dimensionality-challenge,
  information-criterion, ConQuest-core, pinned FACETS 4.5.0 JML-core,
  public-contract, and engineering blocker is `ok` for one exact candidate;
- [ ] no failed cell is hidden by aggregation and no unresolved external core
  discrepancy remains;
- [ ] every retained caveat appears in first-screen guidance, help, and the
  capability surface that exposes the affected result;
- [ ] package-controlled CRAN workload remains below ten minutes while the
  complete release-blocking evidence runs outside CRAN and is reproducible;
- [ ] a clean-room reviewer can reproduce the gate decision from the candidate
  manifest without access to private case-level data; and
- [ ] the machine-readable support envelope resolves every advertised model,
  estimator, statistic, and design row to exact evidence or an explicit caveat,
  exploratory, blocked, or unsupported state; and
- [ ] the release notes explicitly state that threshold anchors, frozen
  calibration, multiple scales, scale-specific PCM, native multidimensional
  estimation, and dimension-specific score production remain later work.

## 0.2.4: operational calibration

0.2.4 should make stable calibrations reusable without implying that every
model is suitable for high-stakes scoring. The first implementation target is
one observed score scale; multi-scale indexing remains deferred to 0.2.5.
Public implementation starts only after the 0.2.3 Definition of Done is met;
schema sketches may be prepared earlier, but they are not current API.

- [ ] Define a typed `mfrm_calibration` bundle containing model specification,
  parameter role and scope, identification constraints, element/group anchors,
  category map, scale namespace, training-data/schema fingerprints, provenance,
  source package/API versions, and content hash. Unknown schema versions,
  missing identities, and altered contents fail closed.
- [ ] Add single-scale threshold/step anchor support, distinguishing partially
  anchored ladders, fully fixed ladders, and starting values, with explicit
  sum-to-zero/origin, degree-of-freedom, and conflict checks.
- [ ] Add documented starting-value import and transformation contracts.
- [ ] Add scoring from a versioned frozen calibration, with explicit handling
  of unknown levels, missing categories, disconnected cases, and out-of-range
  scores; keep it distinct from 0.2.2 fitted-object posterior scoring.
- [ ] Propagate calibration identity into reports, exports, and replay
  manifests.
- [ ] Separate creation, validation, migration, and application APIs so a fit
  object, an arbitrary parameter table, and a validated frozen calibration
  cannot be substituted for one another by class coercion or column naming.
- [ ] Reserve an unambiguous scale namespace in the calibration schema without
  claiming that a 0.2.4 fit can contain multiple observed `ScaleId` values.
- [ ] Validate round trips, reduction cases, and external overlap before using
  operational-scoring language.

## 0.2.5: multiple observed scales and mixed response structures

This release addresses observed-score complexity while retaining a
one-dimensional latent trait unless a separately validated design says
otherwise. Its entry condition is a stable 0.2.4 calibration-bundle identity,
round-trip scoring, threshold-anchor conflict handling, and reduction-test
contract. Multi-scale work must not be used to repair an unresolved 0.2.3
numerical or 0.2.4 calibration problem.

- [ ] Represent multiple independent rating scales through an explicit
  per-observation `ScaleId`; do not infer scale identity from category values.
- [ ] Define a separate per-observation `ObservationModelId` for response
  family, active facets, sign/weight/offset, and permitted interactions. Do
  not overload `ScaleId` with both category-scale and likelihood-routing
  semantics; structural facet absence is not an ordinary missing value.
- [ ] First establish the reduction case of multiple RSM/binary scales with
  scale-specific category maps and score supports.
- [ ] Then add scale-specific PCM with ragged threshold blocks, so scales and
  `step_facet` levels may have different category counts without padding them
  into the current global rectangular step matrix.
- [ ] Extend the 0.2.4 calibration bundle and threshold-anchor contract so
  every scale-specific parameter is namespaced by `ScaleId` and cannot be
  applied to the wrong scale.
- [ ] Define mixed binary, RSM, and PCM likelihood contributions only after the
  single-scale and homogeneous multi-scale reduction tests pass.
- [ ] Define active facets by observation only after scale assignment and
  likelihood dispatch are explicit and auditable.
- [ ] Extend plotting, information, diagnostics, exports, and calibration
  bundles so scale-specific quantities cannot be silently pooled.
- [ ] Add design audits for partial crossing, structurally inactive facets,
  sparse scale links, and scale-specific identification. Scales without a
  defensible common-person, common-element, or anchor link must fail closed
  rather than be silently reported on one metric.
- [ ] Demonstrate that multiple observed scales retain one latent dimension;
  treat multidimensionality as a separate 0.3-or-later model claim.

## 0.3.0: API, evidence, and ecosystem consolidation

0.3.0 is a consolidation release, not a container for whichever research
feature happens to finish first. Its entry condition is completion of the
0.2.3 evidence contract and stable 0.2.4/0.2.5 reduction cases. Its exit gates
are:

- [ ] Freeze versioned schemas for fits, diagnostics, comparisons,
  calibrations, support-envelope rows, and evidence manifests; publish explicit
  migration or rejection behavior for older objects.
- [ ] Define a compatibility and deprecation policy covering argument names,
  estimator aliases, print/report fields, serialized objects, and one full
  minor-release warning cycle where technically safe.
- [ ] Provide public, synthetic, end-to-end case studies for supported RSM/PCM
  and bounded-GPCM routes, including an intentionally unsupported design that
  demonstrates fail-closed behavior.
- [ ] Publish reproducible benchmark bundles and a performance envelope by
  sample size, response count, facet-level count, model, engine, memory, and
  runtime; performance evidence does not relax numerical gates.
- [ ] Obtain an independent methodological/code review of identification,
  parameter transformations, recovery, interval interpretation, external
  comparisons, and high-stakes caveats, with dispositions retained publicly.
- [ ] Establish contributor-facing validation instructions, known-answer data,
  generator/normalizer versioning, and a CI tier that detects evidence-schema
  drift without requiring proprietary software.

## Research tracks after core consolidation

These are separate research programs, not promises attached to 0.2.x or 0.3.0.

- restricted multidimensional `RSM`/`PCM`, followed only later by any
  multidimensional GPCM route;
- decoupled single-family GPCM in which `slope_facet` and `step_facet` can
  differ, followed only after its reduction and identification gates by a
  multiplicative criterion/task-by-rater slope model;
- unrestricted unidimensional GPCM with general slope design, covariance, and
  downstream-helper closure, including explicit cell-slope negative guards;
- freely estimated latent population variance and configurable-prior EAP
  sensitivity after their identification and recovery contracts are defined;
- moderation-specific DFF/DIF methods with calibrated null/non-null behavior,
  rather than extending the current direct screening labels by name alone;
- rater-by-criterion severity interactions and response-style
  centrality/extremity models, kept distinct from discrimination slopes;
- posterior-predictive diagnostics and optional Bayesian/heavy backends;
- typed profile or multivariate observed-score G-theory under the ordered
  Draft.80 design/covariance gates, with joint GT-IRT/GPCM remaining separate;
- alternative polytomous, rater-process, mixture, unfolding, and general
  design-matrix families, including hierarchical-rater and repeated-rating
  local-dependence models; and
- larger-scale performance work after the statistical and reporting contracts
  are fixed.

Each extension needs its own estimand, identification argument, negative
tests, recovery evidence, external overlap where possible, and public support
boundary. Experimental implementation alone is not a release claim.

## 1.0.0: validated core stability contract

1.0.0 means that a deliberately bounded core is stable; it does not mean
feature parity with FACETS, TAM, ConQuest, or every MFRM formulation. Release is
authorized only when:

- the core estimands, identification constraints, object/calibration schemas,
  public names, and migration policy are declared stable;
- all supported core rows have independently rerun, versioned truth-recovery,
  interval, external-overlap, negative-control, and cross-platform evidence;
- the published support envelope states where evidence is absent or designs
  are unsupported, with unknown combinations failing closed;
- operational scoring has round-trip, stale-calibration, unknown-level,
  incompatible-scale, and provenance-tampering tests; and
- at least one external reviewer can reconstruct representative claims from
  public synthetic inputs and retained manifests without proprietary case data.

## Explicit icebox

The following remain outside committed release scope until a separate proposal
defines estimands, identification, reduction cases, computational cost, and
evidence gates: unrestricted GPCM; native multidimensional MFRM and subscores;
Bayesian/MCMC backends; posterior-predictive checks; joint GT-IRT/GPCM and
multivariate G-theory outside the typed observed-score Draft.80 subset;
mixture, unfolding, and rater-process families; automatic DIF/DFF decision
rules; and distributed/high-performance engines. An experimental branch or a
callable internal helper does not remove an item from the icebox.

## Feature maturity and common Definition of Done

Every public capability is assigned exactly one maturity state: `experimental`,
`validated`, `stable`, `deprecated`, or `unsupported`. Operational readiness
(`ready`, `caveated`, `blocked`, or `not_applicable`) is recorded separately;
maturity and readiness are not synonyms.

A capability may be promoted only when all applicable items are complete:

1. the estimand and user decision it informs are explicit;
2. identification, constraints, scale orientation, and reduction cases are
   specified and tested;
3. public API, object schema, errors, warnings, and migration behavior are
   documented;
4. truth-recovery, uncertainty/coverage where supported, numerical, and
   negative-control evidence pass prespecified rules;
5. matched external evidence is supplied where a defensible overlap exists,
   without treating external software as ground truth;
6. sparse, extreme, missing, disconnected, and malformed inputs have explicit
   outcomes and cannot become falsely ready;
7. tests, examples, reference documentation, support-envelope rows, and release
   notes agree;
8. runtime, memory, dependency, privacy, licensing, and reproducibility costs
   are acceptable for the declared execution tier; and
9. an independent review and candidate-linked evidence manifest are complete.

## Permanent development principles

1. The public support boundary is defined by exported code, help pages, tests,
   and release evidence together—not by an aspirational planning note.
2. A helper being callable does not make its output inferentially or
   operationally ready.
3. External comparisons are evidence within a matched overlap region, never a
   blanket equivalence claim.
4. Screening results remain screening results; they do not become fairness,
   validity, or high-stakes decisions through formatting.
5. Unsupported designs fail closed or carry an unavoidable caveat.
6. CRAN-time tests stay lightweight; slower evidence is reproducible and
   retained outside the installed package.
7. Release artifacts are tied to an exact source commit and tarball digest.
8. Changes to this sequence belong in this file first; subordinate validation
   notes may add technical detail but may not redefine the release order.
9. Pilot evidence may define a criterion; confirmatory evidence may only apply
   the frozen criterion. Changing it invalidates the confirmatory decision.
10. The published CRAN 0.2.2 baseline and next-version development remain
    isolated; any later correction starts from the published tag.
11. Residual exploration may generate a model, but cannot independently confirm
    that model on the same observations without an explicit sensitivity label.
12. Better multidimensional fit and useful dimension-specific scores are
    separate claims with separate evidence requirements.
13. An information-criterion label never hides its likelihood basis, free-
    parameter count, independent sampling unit, exact formula, or integration
    evaluation.
14. FACETS, ConQuest, TAM, and immer are independent comparators, not truth.
    Simulation truth, estimand matching, and between-program agreement are
    reported as separate questions.
15. External evidence binds the executable, version reported by the output,
    parser/generator identity, input/output hashes, and candidate. Version
    differences do not stop execution, but remain separate evidence strata;
    stale-output reuse is classified explicitly.
16. Estimator correction and extreme-score adjustment are part of method
    identity. Results from unadjusted, adjusted, bias-corrected, marginal, joint,
    and conditional likelihood routes are never silently pooled.
17. A hierarchical rater model or other local-dependence model is a competing
    model family, not an optimization backend for the current additive MFRM.
18. Internal metamorphic invariance is checked before external agreement. A
    row-order, label, filtering, weight, or serialization failure is an
    internal defect and cannot be reinterpreted as FACETS, TAM, or immer
    disagreement.
19. Optional validation capability is part of evidence identity. Dependency
    absence must fail closed and be distinguished from an evaluated
    statistical failure; official validation environments record exact
    capability versions without making every optional dependency a runtime
    installation requirement.
20. Reuse occurs only at the smallest complete comparison unit. A route-level
    fragment, unpublished temporary file, aggregate without a valid completion
    marker, or checkpoint whose package, runner, capability, manifest, or
    control identity differs is recomputed or rejected, never silently pooled.
