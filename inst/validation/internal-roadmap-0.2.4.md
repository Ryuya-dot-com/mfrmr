# mfrmr internal development and validation roadmap

Status: authoritative maintainer execution plan for integrated 0.2.4,
updated 2026-10-01. Repository-only; excluded by `.Rbuildignore`.

**Latest execution instruction:** the October 1 full-range design review and
subsequent whole-roadmap R=50 decision take precedence over older launch/deadline
statements. Completion may extend beyond October 2 18:00 JST. The initial
design-review hold was followed by approval of saved-fit tests, bounded new
numerical pilots, and preparation of 50 datasets per condition across the broad
MML/JML roadmap. A-E inputs are now prepared as recorded below. Complete the
method/output/resource checks before broad fitting; the old prepared MML queue
and paused 3,000-fit corrected-JML study are not automatically resumed.
The [MML and JML validation plan](#mml-and-jml-validation-plan)
is the current cross-estimator scope and task sequence. Older method-specific
launch plans below are evidence records, not separate instructions to execute.

This file owns current sequencing, completion criteria and evidence decisions.
[ROADMAP](../../ROADMAP.md) owns reader-facing direction and support boundaries;
help and NEWS describe actual behavior. Update current status here in place.
Dated validation records preserve evidence, not competing queues of next tasks.
The [older internal plan](internal-roadmap-0.2.3.md) is historical.
The previous expanded roadmap is preserved at development commit `7f4f530c`
(`git show 7f4f530c:ROADMAP.md`); its dated protocols and restrictions are not
silently discarded or treated as new work.

## Purpose, scope and work discipline

The target remains **integrated 0.2.4**, currently labelled `0.2.4.9000`.
Three pillars must advance together:

1. Generalized many-facet measurement: appropriate estimation and interpretation
   of ability, facet locations, category use and discrimination.
2. Multivariate observed-score G/D studies: dependable planning for criterion
   and composite scores under supported assessment designs.
3. Rater feedback and assessment decisions: understandable diagnostics,
   recipient-appropriate reports and reproducible calibration reuse.

Educational performance assessment is the reference use. The immediate goal
is a general-purpose API with an explicit model/estimand contract; coverage of
additional application domains is not a release gate. Empirical examples can
reveal numerical or design failures, but cannot validate a model for a domain.
Features, clustering and assigned-score MI support these pillars. They do not
supply a fourth independent model-development queue or a common reliability
coefficient linking incompatible estimands.

Preserve the user's order: **finish implemented workflows → establish
statistical support → complete agreed model extensions → integrate as 0.2.4**.
Inference and output contracts constrain one another; necessary API/help work
continues while statistical work proceeds. Do not wait for every research
question before fixing an incorrect label, probability or saved result.

**September 30 priority correction, requested by the user:** mathematical and
statistical adequacy precede further runtime optimization. The immediate work
is D1's inferential target, residual-bias and uncertainty decisions together
with their D2 consequences. Then optimize the retained procedure, and finally
review examples and submission checks. The 600-second ceiling remains a D3/D4
release requirement; it does not make Windows profiling the current research
priority. Retain the measured engineering improvements, without interpreting
faster calculations or passing regression tests as inferential qualification.

Joint-slope GMFRM and corrected JML remain agreed unfinished work. Formal JML
inference cannot be marked complete by exposing RootSE, nor can a promised
consumer be replaced with a generic warning. Required outcomes must be
completed or their change explicitly decided with the user. This does not
require every existing method to support every model: each supported or
unavailable operation needs a defensible target and a clear reason.

Do not start a new simulation because the last one finished. A new task needs
a named user outcome, the decision it can change, existing evidence to reuse,
a bounded check and an exit condition. Counts of functions, tests, figures or
commits are not progress measures. No overall percentage is calculated from
heterogeneous milestones; report completed outcomes and remaining blockers.

## Source and evidence identity

| Layer | Current meaning |
| --- | --- |
| Development checkpoint `7f4f530c` | Accumulated package code, help, tests and validation records through September 30. Two-family and corrected-JML statistical support remains unfinished. This is not a release freeze. |
| Adaptive inference follow-through after `875c1a99` | Numerical qualification, public component log-Wald support and descriptive posterior residuals for adaptive direct two-family MML. Existing full-information implementation and acceptance thresholds are reused; no new estimator, fitting default or coverage evidence. See the September 30 adaptive-information record. |
| Prior development `08a5ee9b` | Recorded five-environment CI for that source. It does not qualify the accumulated checkpoint. Remote status was not refreshed for this reconciliation. |
| Historical rc.6 | Preserve source/tags/assets and their evidence. Never retag it or reuse its platform/Win-builder checks as evidence for newer source. |
| September 27 local archive | Its packaging, installed replay and manual/tutorial evidence is retained in the claim ledger. Later changes require their own affected checks and final assembled-source qualification. |

Evidence is attached to source, data, model, estimator, target and control
settings. A repaired calculation retains the earlier failed result and a
reason for invalidating only affected evidence. A matched replay is not an
independent confirmation. RDS replay is not portable calibration. Local `main`
and a clean worktree are not evidence of a push, hosted CI or publication.

Workspace reconciliation on 2026-09-30 corrected `../README.md`,
`../releases/README.md` and `../release-candidates/README.md`: the active tree
is `development/` on `main`; published CRAN is 0.2.3.1 (August 25); its earlier
rejection remains a historical event, not its final status. These indexes are
outside the package Git repository and are maintained in place. Remote
`ls-remote` verified main at `08a5ee9b` and development/0.2.4 at `9020ca2a`;
the latter is a historical branch, not the current source authority. Ahead/
behind numbers are snapshots, not permanent branch labels.

Current readiness lookup now refuses an older release's evidence when a 0.2.4
record is absent. A `.9000` source may locate its corresponding 0.2.4 record,
but the existence of a 0.2.0/0.2.3 checklist or evidence map does not qualify it.
The current frozen evidence map/checklist have not yet been assembled; their
absence remains visible until D3 rather than being filled by historical files.

The missing `/private/tmp/...icc-candidate-20260921` registration was pruned.
The clean `~/mfrmr-pr6` and saved site-edit worktrees were removed normally after
checking tracked, untracked and ignored files. Commits `532d59e7`, `2b12b82f`
and `4df7e072` remain referenced by their existing branch/remote refs. Only the
active development worktree remains. No branch was reset, deleted or merged.

## Current delivery and remaining decisions

| Outcome | Implemented scope | Required closure or explicit decision |
| --- | --- | --- |
| RSM/PCM and one-family GPCM | Existing RSM/PCM routes; MML separate slope/step owners; scoped inference/comparison and profiles; portable MML and scoped JML EAP. One-family GPCM EM falls back to direct. | Preserve actual engine, scale, prior, anchor and conditional-uncertainty identity in all supported consumers. Keep adverse coverage findings. Do not infer single-family EM from two-family EM. |
| Ordinary JML validation | RSM/PCM and shared-owner one-family GPCM fitting, with existing boundary/readiness checks, descriptive location precision and scoped scoring/reporting. | Evaluate ordinary JML in its own right across N and per-Person exposure, facet structure and allocation. Conditional location SEs, local curvature and fixed-calibration scoring are not validated joint structural intervals. Corrected-JML evidence does not qualify the ordinary estimator. |
| Two-family GMFRM fitting | Explicit ordered owners, fixed N(0,1), fixed-grid EM or adaptive direct MML, common fit class, arbitrary column names, no anchors, unit weights, exactly two non-Person facets. | Finish target-specific statistical admission and consumer decisions; local rank and numerical agreement do not establish global identification or sampling performance. |
| Two-family outputs | Summary/print; conditional category/information curves without intervals; experimental component Wald/profile and location/contrast normal intervals; descriptive same-data posterior response diagnostics; plot/report/export/reopen; separately checked fitted-object/portable conditional new-Person EAP, with matching saved-score attachments for tables/reports/export; experimental individual rater sheets from saved model-specific results. | Location/contrast coverage remains unqualified; curve/step intervals, ordinary fit/bias/Q3/PCA, Wright/Pathway and model ranking/LRT remain open or unsupported. Conditional EAP excludes calibration uncertainty and does not qualify coverage or population transport. For each remaining consumer, specify the target and required implementation/evidence or an explicit release-scope decision; do not inherit support from the shared fit class. |
| Corrected JML | Shared-owner explicit-order adjusted-equation estimator, matching local full-Jacobian covariance, point/distribution output, conditional residuals, new-Person EAP and portable format 5. | Resolve residual-bias treatment and formal inferential scope. No validated automatic order selector, structural CIs, corrected Person ML/WLE, corrected RSM/PCM, anchors or separate-owner corrected JML. Keep a valid point if covariance fails. |
| Multivariate G/D studies | One/two random facets, crossed or Child-within-Parent with Persons crossed; ANOVA/MINQUE(0); composites/differences; complete future plans; 2D plots; prespecified crossed normal-theory paired-delta intervals. | Complete the existing data-to-plan-to-report route with metric-specific availability, raw covariance estimates, score units, explicit future counts and cost assumptions. General fixed/nested structures, unequal future rosters and a joint latent GMFRM/G model are not implemented. |
| Individual feedback | Native additive RSM/PCM and experimental two-family GPCM sheets, recipient privacy, exposure/reference, category use and saved response review. | Preserve model-specific targets and unresolved outcomes; GMFRM sheets do not display location/step intervals; separately requested location/contrast intervals belong in analyst reports. Calibrated feedback decisions remain unavailable. Severity, slope, misfit and feature groups must not become competence or training-effect claims. |
| Dependence models | Separate shared-rater and Person-local testlet RSM fitting/scoring and descriptive comparisons, with limited uncertainty. | Preserve sharing units and conditional/new-unit populations. Use matched ordinary-RSM comparisons. Ordinary fit cutoffs, zero-variance LRTs and Person-only robust SEs do not automatically transfer. |
| Features and missing scores | PAM/hierarchical/PCA/k-means, setting and imputation comparisons, assigned-response review/fitting/eligible pooling. | Preserve IDs, coding/scaling, roster, observed scores and pooling target in saved outputs. No filling unassigned ratings, inferential group effects, extended-model MI or pooled Person scores by implication. |
| Beginner/API consistency | Existing guides, recommended aliases, saved objects and accessible plotting foundation. | One recommended route per task; explicit omitted/NULL/default meanings and actual plotted values; compatible old calls; no internal execution language in help/NEWS. Author review is not novice participant evidence. |

### GPCM operations still unavailable

These names match the current capability registry. Each row identifies what
would have to change; listing it here does not supply implementation or evidence.
The older 0.2.2 technical supplement and historical checklist counts do not
cover newly added capabilities or close a current decision.

| Capability area | Current decision and requirement |
| --- | --- |
| Formal structural confidence intervals for corrected JML | Unfinished D1 work within the agreed scope. Fix the correction order/procedure, covariance target and residual-bias handling before evaluating formal coverage. Local RootSE and conditional portable EAP do not provide these intervals. Change of the agreed outcome requires the dated user decision below. |
| FACETS output-contract score-side review | Unavailable for GPCM. Package-native score export does not establish FACETS numerical equivalence. Reopen only for a specified transformation/uncertainty target with matched external evidence. It is not required for native 0.2.4 scoring. |
| Posterior-predictive and Bayesian workflows | Bayesian estimation and replicated-data model checks remain deferred. Existing fixed-calibration same-data posterior response diagnostics are descriptive and do not implement those procedures. A new discrepancy, conditioning set and calibrated decision claim require separate design/evidence. |

## Integration milestones and exit conditions

These D identifiers are the only release-level checkpoints. Older repeated
G2/D2 labels in historical records do not close these milestones.

| Milestone | Status | Reviewable exit condition |
| --- | --- | --- |
| D0 — Evidence identity | Reconciled on 2026-09-30 after correcting workspace records; repeat before freeze | Source and scope of each result, workspace indexes, active branch, retained worktrees and actual published baseline agree. Local, committed, archived and published states are distinct. |
| D1 — Statistical support | Open | Fix each retained estimator/interval/diagnostic procedure and failure policy; evaluate MML, ordinary JML and corrected JML across the declared small-to-large-N and per-Person-exposure scope. Resolve joint-slope and corrected-JML decisions. Cover facet structure, sparse/unequal exposure and the relevant population/dependence assumptions; retain numerical safeguards and their source-specific evidence. Report adverse and unavailable outcomes by method and target. Follow the current no-computation instruction during design review; the October 2 deadline has been relaxed. A domain-specific workflow, universal coverage or unlimited capacity guarantee is not required. |
| D2 — Complete delivered workflows | Open | Supported fit → summary/uncertainty → meaningful plot/diagnostic → report/export → reopen/scoring paths agree on model, owner, scale, population and uncertainty. Verify these general API contracts with suitable retained examples, preserving unavailable outputs and arbitrary facet names; no domain-specific workflow is required. Existing G/D, features/MI and RSM/PCM feedback stay on the regression path. Unsupported routes have explicit tested reasons. Close the task-to-function acceptance table below against the installed guide, help, examples and saved replay; export counts are not acceptance evidence. |
| D3 — Freeze scope and source | Not reached | Required D1/D2 outcomes are closed or changed by explicit agreement. DESCRIPTION, capability tables, help, examples, NEWS, README and version metadata agree. Produce one identified submission-quality archive without changing old tags. Retain a complete phase-timed local check and a demonstrated optimization plan against the 600-second check budget; an unmeasured or over-budget source does not close D3. |
| D4 — Validate and integrate that source | Not reached for current scope | Run affected integration and package checks; fix failures; verify matching main integration, five-environment CI, installed/site examples, URLs, reverse dependencies and Windows results. Require matching Windows check time below 600 seconds, separated from installation, and a supported/missing optional-dependency matrix with no unexplained feature skips. Reuse source-identical evidence; no routine repeated whole-suite or numerical studies after small edits. |
| D5 — Publish and maintain | Not reached for current scope | Matching source/documentation/assets are published under applicable authorization. Record GitHub release, CRAN submission and acceptance separately; retain regression witnesses and migration information. |

Local completion requires implementation/decisions through D3 and applicable
local checks of the identified archive. Publication completion additionally
requires matching hosted and release evidence. A clean development checkpoint
closes neither endpoint. Stop the release cycle at its agreed endpoint, not
when all long-term research has been attempted.

## MML and JML validation plan

**Purpose and current state (October 1):** establish where the general-purpose
package's estimates and supported uncertainty are useful across sample sizes
and assessment structures. MML, ordinary JML and corrected JML are coequal
validation strands with different assumptions and available outputs. They are
not interchangeable estimators and need not support identical models. This
plan expands small-sample coverage while retaining the larger-sample evidence;
it does not replace either with an application-specific product. All new
fitting, simulation, generation, timing and automatic resumptions remain held.

### Common design, with estimator-specific questions

The shared sample-size scope is **N=20, 30, 40, 60, 120, 240, 480**. Retain
**N=400** as an explicit JML evidence/comparison anchor; do not interpolate its
results to 480, discard it to make a uniform grid, or repeat it merely for
cosmetic uniformity. A larger operational design can justify another endpoint,
but none of these values is a package capacity limit. Not every factor must be
fully crossed with every N; omissions must have a stated reason and cannot
be described as evaluated. The finalized matrix must represent small and
larger samples for each retained method/claim, not only in aggregate.

| Design axis | Required comparison | MML question | Ordinary/corrected JML question |
| --- | --- | --- | --- |
| Person count N | Change N while retaining response equation, facet levels, per-Person exposure and roster rule; document integer allocation changes. | How do bias, uncertainty and numerical integration behave across independent Persons? | Does error diminish or concentrate around a displaced limit when per-Person information stays limited? More Persons also introduce more Person nuisance parameters. |
| Information per Person | Hold N and parameter structure fixed; add independently generated ratings under a declared response model. Preserve the old L=1/4 exposure contrast where relevant. | How do posterior concentration, scoring precision and integration sensitivity change? | Does additional exposure reduce profiling/incidental-parameter bias and improve the correction's bias/variance tradeoff? A duplicate of an observed row is not new independent evidence. |
| Joint growth | Increase N and exposure, then separately allow facet levels to grow. | Can accuracy and usable runtime be maintained as the model/design grows? | Do the proposed centering/covariance arguments apply in that particular growth regime? Neither a binary-Rasch theorem nor fixed-length behavior automatically transfers to many-facet GPCM. |
| Facet count and levels | Distinguish Task x Rater / Criterion x Rater from Task x Criterion x Rater and justified additional facets; vary levels and category count separately. | Which fitting and output paths actually admit each model? | Which parameters are estimable under the actual crossings, and how do structural dimension, nuisance information and correction-state count grow? |
| Assignment and sampling | Crossed, paired, unequal exposure and weak links; fixed assignment counts versus newly sampled assignments. | Is comparison driven by observed links or the imposed population model? | Do the profile/equation target and covariance match the repeated-sampling design? Preserve rare/singleton rosters rather than merging them to obtain a covariance. |
| Population, targeting and dependence | Normal SD changes, then selected skew/mixtures, ability-associated assignment, rare categories, missing assigned scores and within-performance dependence. | Separate population misspecification from numerical failure and from changes of identified scale. | Ability distributions affect sampling performance even though ordinary JML does not fit a normal population model. Separate model/assignment bias from incidental-parameter and correction bias. |

The existing three-Task/six-Rater/three-category, SD=.5/1, two-roster MML
conditions remain a main comparison. The ordinary and corrected JML
two-owner/exposure cases and three-rater/four-category witness retain their
original N=400, truth, ability mixtures and exposure rules. These historical
families are not interchangeable. Applied rubric/multi-task/full-panel blocks
extend their coverage; they do not replace them. Include fixed-model N growth
and sparse larger-model designs in addition to fully crossed examples.

### Model, method and output contracts to freeze

| Strand | Current admitted fitting scope | Decisions needed before sampling qualification |
| --- | --- | --- |
| RSM/PCM MML | Ordinary additive facets; fixed N(0,1) or explicitly estimated normal population; interactions/anchors only in their admitted routes | Match the population assumption to the comparison. `mfrm_facet_intervals()` currently covers fixed-population/fixed-grid fits, not estimated-population fits. Decide the required target/consumer extension before promising matched severity CIs. |
| One-family GPCM MML | One slope owner; step owner may differ; default estimated-normal population with relative slopes | Separate shared-owner cross-JML comparisons from separate-owner MML questions. Slope/curve intervals do not supply the currently missing public severity-contrast interval consumer. |
| Two-family GPCM MML | Exactly two non-Person facets, fixed N(0,1), first-family relative slopes, second-family free slopes/locations and steps | Resolve the observed-Person-score rank policy and full-information/finer-integration requirements for model-based intervals. N<p is a known current output exclusion, not a model nonidentification theorem. Any rule change defines a new procedure; do not tune it to successful small-N cases. |
| Ordinary RSM/PCM JML | Existing ordinary additive-facet fitting; only supported interaction/anchor/weight settings | Review finite versus boundary solutions, effect separation, extreme Persons, parameter-specific bias and the meaning of reported conditional precision. Do not convert current conditional location SEs into joint-calibration CI claims. |
| Ordinary one-family GPCM JML | Shared slope/step owner, relative-slope identification; finite-solution and boundary review | Preserve the complete adjacent-category response equation and scale. Review structural bias separately from solver/curvature success. Two-family JML and separate-owner JML are not comparison arms supplied by the current implementation. |
| Corrected GPCM JML | Explicit correction order, one shared slope/step owner, centered additive fixed facets, unit-weight observed ratings, declared categories; no anchors/interactions | Resolve residual structural displacement, full-Jacobian root covariance, fixed/random-roster target, correction-order policy and feasible state space. Formal structural intervals remain unfinished; RootSE describes a local equation-root target. Corrected RSM/PCM is not implemented. |

### Resolved baseline comparison contracts

The October 1 source review fixes the following design choices for blocks A/B.
These are specifications for the future study, not new performance findings or
changes to package defaults. The A/B truth and assignment specification below
now supplies the next design layer; execution settings and replication
allocation remain to be frozen. The
[ordinary-JML source review](jml-inference-review-20260927.md#october-1-ordinary-jml-and-matched-comparison-contract)
records the supporting functions and distinctions from research estimators.

| Contract | Decision for the primary A/B comparison |
| --- | --- |
| Observations and response equation | Same unit-weight rating events and explicitly declared 0:(K-1) ladder; `category_policy="preserve"`. No anchors, interactions, shrinkage or data-dependent category collapse. RSM uses common steps; PCM and one-family GPCM explicitly use Criterion steps; GPCM uses Criterion slopes multiplying the complete adjacent-category predictor. |
| Identification | All non-Person facet locations and each step vector centered. One-family GPCM has mean log slope zero; RSM/PCM slopes equal one. Ordinary calls use `noncenter_facet="Person"`; corrected JML imposes its centered-facet convention internally and rejects an explicit unsupported `noncenter_facet` argument. Person coordinates are not centered/rescaled after each generated sample. |
| MML population | Primary ordinary RSM/PCM and one-family GPCM comparators estimate an intercept-only normal population, explicitly `population_formula=~1` with matching Person IDs; GPCM uses `gpcm_mml_identification="free_population"`. Correct normal cores vary population SD=.5/1 on the same structural scale. Fixed N(0,1) fitting is a separately labelled assumption/default-workflow arm; it is misspecified when the generating distribution differs on that scale. |
| Ordinary JML | `jml_correction_order=NULL`: the public simultaneous Person/structural likelihood fit, without score adjustment, classical multiplicative correction, trimming extreme Persons or a hidden profile-limit refit. No fitted population model is passed to JML. The finite-solution estimand and actual returned-algorithm behavior are reported separately when a finite joint maximum is unavailable. |
| Corrected JML | Shared-owner GPCM with separately declared orders 2/4 and assignment-sampling assumption. Its adjusted equation and local-root checks define the estimator. Do not replace this with an external package's classical correction, or borrow the ordinary-JML likelihood/Hessian interpretation. |
| Primary structural targets | Prespecified Rater 1 minus Rater 2 and Criterion 1 minus Criterion 2 location contrasts, plus Task 1 minus Task 2 in the three-facet extension; report all level/contrast recovery as supplementary evidence. For GPCM retain all centered log-slope coordinates. Evaluate category probabilities at canonical theta=-2,-1,0,1,2 in the same planned rating contexts with equal context weights. Do not select contrasts from the fitted most-extreme levels. |
| Primary uncertainty scope | Ordinary-JML location SEs remain observation-information screening approximations; corrected-JML RootSE remains local-root variation. Neither is a qualified public structural truth interval. Evaluate the explicitly labelled corrected research candidate separately, with its own consistent-root gate, target maps and delivery accounting. The missing matched MML severity-contrast consumer and formal JML structural inference remain open D1/D2 work. |
| Person scoring | Compare native fitted-cohort output separately from common-prior conditional EAP via `predict_mfrm_units(..., scoring_prior=list(mean=0, sd=1))` where source/batch checks admit it. The shared N(0,1) scoring prior is chosen independently of generating SD; it is not an estimated JML population or an oracle prior. Include independent held-out Persons and retain source refusals. |

The common centered-facet/geometric-mean-one representation makes A/B
parameters and a fixed theta grid commensurate; estimated MML population SD
does not redefine that grid. Do not standardize a JML sample by the empirical
SD of noisy Person estimates to manufacture a matching population parameter.
Population-standardized curves using each MML fit's estimated mean/SD are a
different target. Two-family MML in D retains its own fixed-population scale;
comparison with A/B requires an explicit response-preserving transformation or
a shared response target, not raw subtraction of differently scaled slopes.
Discrete-mixture historical JML cases remain valuable robustness/reference
conditions, not correctly specified normal-MML cases.
Grid probabilities are evaluation targets from the recorded response equation;
an internal evaluator is a research calculation, not evidence that another
public curve/interval function has been implemented or qualified.

The primary ordinary-JML Person result for an independently free all-low/all-high
Person is -Inf/+Inf, with a finite optimizer value retained only as a trace.
Anchored or constraint-coupled extremes have different statuses and are outside
the unanchored A/B core. A boundary Person does not by itself prove that every
facet contrast is unidentified. Conversely, finite printed facet values alone
do not prove the structural extended-profile optimum was reached. Preserve
returned numerical estimates with their status, report finite/qualified points
separately, and keep the research profile-limit estimator as a distinct arm if
later justified. No extreme-score replacement or silent deletion is allowed.
An unbounded native Person estimate against a finite true ability has infinite
squared error. Do not drop it and call the remaining finite-only RMSE overall
Person recovery; report boundary frequency and the conditional finite subset
explicitly. The common-prior EAP comparison answers a separate scoring question.

**October 2 extreme-Person clarification.** The public `fit_mfrm()` interface
has no pre-fit extreme-Person exclusion option. Ordinary JML retains the input
rows; its Person-audit label `has_exclusions` describes nonfinite parameters,
not removed data. Corrected shared-owner GPCM retains Persons and their
assignment patterns, with zero structural-equation contributions at the
infinite profile limits. MML retains their marginal-likelihood contributions
and reports population-dependent EAPs and posterior SDs. Help now states these
distinct meanings, separately from new-Person scoring and display adjustment.
The [existing profile-limit prototype](jml-extreme-profile-limit-prototype-0.2.3.R)
can remove independently free extreme-Person rows from a reduced structural
objective under its explicit constraint and dimension checks. It remains a
research estimator, not a public preprocessor or a bridge already established
for ordinary JML covariance and bias. The primary R=50 arms and planned-dataset
denominators are unchanged; no method receives a hidden extreme-response filter.

Scoring availability is its own outcome: current ordinary-JML source checks
reject known training-Person boundaries even if some structural estimates are
useful. New-Person extreme responses under an admitted fixed calibration can
instead receive finite conditional EAP. Corrected JML has equation-based source
checks and can retain scoring when its covariance is unavailable; it does not
inherit the ordinary source test. Common-prior scoring therefore compares
both conditional score error and delivery over all planned calibrations, not
only the intersection of accepted sources. Estimated-population RSM/PCM has
fitted-object scoring but no corresponding portable artifact; record that
output gap separately from failed fitting.

Before generation, an unsupported design/API combination can be marked as a
scope exclusion. After generation, empty categories, lost observed levels,
extremes, failed fits or refused scores stay in the denominator of the original
planned datasets for that admitted design. No redraw until support appears.
Any conditional-on-success error or coverage must identify its subset and
appear alongside the unconditional delivery rate. Known-truth calibration is
only an explicitly labelled research reference, never an input to fitting or
selection. Conditional EAP bounds exclude calibration uncertainty.

### JML requirements that a sample-size grid alone would miss

At fixed limited per-Person exposure, increasing N is not by itself a general
remedy for structural JML bias. The retained Haberman review distinguishes
fixed test length from growing test length in binary Rasch; it does not prove
the corresponding claims for every GPCM. The corrected-JML N=400 studies
already separate coverage of the method-specific population root from coverage
of generating truth and show that orders 2/4 can reverse their MSE preference.
Reuse those results to choose the next question; neither covariance accuracy
around a root nor a smaller score residual establishes centering on truth.

The proposed tasks therefore include ordinary JML as a baseline in its own
right, correction benefit/harm on matched supported inputs, and N x exposure
contrasts. A fixed order with a justified domain and an automatic order rule
are different procedures. The latter needs observable inputs, a defined
fallback and separate evaluation of the entire selection rule. Do not choose
orders using generating truth, smallest printed SE, or apparent agreement
between orders. Exact-centering constructions that lost identification in the
retained review are counterevidence, not a ready replacement estimator.

Static source inspection also sets two design constraints for corrected JML:

- With p structural coordinates and G observed fixed-roster groups, centering
  actual Person contributions within each group gives rank at most N-G.
  `mfrm_jml_adjustment_covariance()` additionally requires N>p and at least two
  Persons per group, then checks the actual rank and full Jacobian. Thus N-G>=p
  is a necessary dimensional condition for that full covariance, not a
  sufficiency or coverage rule. Random-roster centering has a different target
  and rank bound; it must not be selected merely to bypass fixed-roster failure.
  Tiny groups also affect covariance estimation even when rank passes.
- For each roster, the correction enumerates slope-owner totals. With K
  categories and m_g ratings assigned to owner level g, its current state count
  is `product_g[1+(K-1)*m_g]`, capped at 5,000, with a separate observed-count
  memory guard. More ratings/owner levels/categories can exceed this limit
  even when N is small. Classify this as implementation capacity, not statistical
  nonconvergence; no pruning, larger cap or approximation is authorized here.

These facts follow from `R/core-jml-adjustment.R`, not a new numerical run.
They are distinct from the additional observed-score condition in the two-family MML
model-Hessian interval procedure: a singular empirical meat actually limits
the full sandwich covariance being constructed. Keep points when only
covariance fails, according to the existing result contract.

#### JML uncertainty and candidate-evaluation specification

**October 1 source/design decision; no computation or public interval added.**
Use ordinary and corrected JML as separate estimation procedures. The first
comparison needs a reproducible account of point recovery, uncertainty targets
and delivery; it does not require manufacturing an identical public CI option
for every estimator. Preserve the unresolved structural-inference work, with
the following output-level decisions.

| Output / procedure | Source finding and interpretation | Decision for the expanded comparison |
| --- | --- | --- |
| Ordinary-JML displayed location SE | `calc_facet_se()` uses inverse square root of within-level observation information. `build_measure_se_table()` labels JML precision exploratory and formal inference unsupported; it does not supply the joint covariance of two locations. | Retain screening SEs/bands with their existing labels. Do not create a location-difference SE by adding squared printed SEs or count these bands as the common structural truth-CI arm. |
| Ordinary finite-joint or extended-profile structural uncertainty | The GPCM scoring guard checks joint curvature but returns no structural sampling covariance. Finite structural tables do not establish that the public joint optimizer attained an extended-profile optimum when Person estimates are unbounded. | A separate profile-solution/covariance/centering argument is required before an ordinary-JML structural interval consumer. Retain point recovery and boundary/source statuses now; neither MML covariance nor adjusted RootSE is a substitute. |
| Corrected public point | `point$available` can be true for either `consistent_roots` or `root_with_unresolved_starts`; the summary's `Converged` is true in both. Conflicting roots are not selected. | Count returned local points and consistent-start points separately. Keep unresolved-start points and their status; do not use `Converged` alone as the interval gate. |
| Corrected covariance / RootSE | The public covariance uses the full nonsymmetric equation derivative and actual centered Person contributions. It may be returned for an unresolved-start local point; it targets local root variation. | Retain availability, sampling law and root status. It is neither the ordinary likelihood Hessian nor a guarantee of centering on structural truth. |
| Corrected research interval candidate | The paused order-2 protocol additionally requires `consistent_roots`, available full covariance, positive finite target variance and finite bounds. | Carry that explicitly labelled candidate rule into the new orders-2/4 mapping for the prespecified targets below. This is a new study specification, not a public CI, a resumption or an amendment of the paused study. |
| Person scoring | Corrected scoring admits locally checked consistent or unresolved-start roots independently of RootSE. Ordinary source scoring rejects its known training-Person boundaries. | Preserve F's source-specific point/scoring contract. A research interval refusal cannot retrospectively remove an admitted point/EAP score, and a finite EAP cannot qualify structural inference. |

**Ordinary-JML next method decision.** Write the free structural coordinates
as beta and Person coordinates as theta. At a regular finite joint optimum,
profile curvature is `H_bb - H_bt H_tt^{-1} H_tb`. Inverting H_bb alone treats
Person estimates as known. Even the correctly formed profile curvature does
not, by algebra alone, give sampling covariance or truth coverage when the
number of Person parameters grows at fixed individual exposure. A future
profile-score covariance would need the derivative of the *profiled* Person
contributions, including their dependence on the fitted theta, and the declared
fixed/random-roster sampling law. It would first describe variation around its
profile-equation target; residual structural bias remains a separate question.

Reuse the retained finite and extreme-response/profile-limit records for the
first bridge after the hold. Establish exactly which public returned structural
points solve the declared ordinary profile problem before adding covariance.
When H_tt degenerates at an extreme Person, do not use a regularized inverse,
finite optimizer trace or silent deletion to claim that the finite-interior
formula applies. An extended-profile route requires its own verified endpoint
handling and source identity. A separately fitted research profile estimator
must stay a separate procedure if it changes the public structural point.

The [ordinary-JML residual bridge](jml-inference-review-20260927.md#october-1-ordinary-jml-residual-bridge)
now derives, for independently free Persons in the stated fixed-design scope,
the exact identity `g_profile = r_beta - e_beta - Hbar_betaI Hbar_II^{-1} r_I`.
The bars are Hessians integrated from conditional Person minima to the finite
public trace; e_beta is the finite-trace extreme contribution. A structural
error bound requires an existing selected profile root and positive curvature
throughout the connecting neighborhood, not merely convergence code zero or
a point Hessian. For inferential transfer, the procedure discrepancy must be
negligible relative to the target contrast's justified sampling scale; this
does not bound its bias relative to structural truth. Current-source numerical
qualification is still open. The next bounded check will reuse compatible
saved finite/extreme examples at unchanged structural values before any
separate structural reference solve. The earlier three-saved-MML-fit approval
did not itself authorize JML calculation. The subsequent request for small new
estimation/simulation/derivative checks permits a bounded bridge, but no such
new ordinary-JML bridge has yet been executed. Preserve the existing finite
profile-information and extreme-profile prototype evidence rather than
repeating those studies or silently replacing the public estimator.

The adjusted problem's internal `evaluate(..., order=0)` is not an ordinary
public JML arm: its constructor still enumerates owner totals and enforces the
5,000-state cap before evaluating an order. Using that constructor as the
ordinary reference would impose a correction-specific limit on ordinary JML
and would not cover RSM/PCM. Any ordinary bridge must respect the ordinary
model's scope without importing those enumeration limits. No order-0 public
option, bootstrap interval or new estimator is introduced here. Resampling
Persons or conditioning a parametric bootstrap on noisy fitted abilities is
not, by itself, evidence that incidental-parameter bias has been removed.

**Corrected candidate definition.** For each separately fitted order k=2/4,
use the unchanged public controls, starts, root/covariance gates and sampling
choice. Let N be contributing Persons, A the derivative of their mean adjusted
equation and U_c their actual contribution matrix centered within fixed rosters
or globally for random rosters. The saved public influence rows are
`F_k = -U_c A^{-T}` and its covariance is `V_k=F_k' F_k/N^2`.
The second inverse is transposed; an adjusted equation is not generally a
likelihood gradient. Do not replace actual contributions with owner-total
conditional means, change centering after a rank failure, or add an unrecorded
small-sample factor. Preserve the current full-covariance rank/derivative gates;
any target-specific relaxation would be a different procedure.

Apply a named full-coordinate row L to the fitted structural beta, using the
retained centered expansion: `t_hat=L beta_hat`, `v=L V_k L'`. Include the
primary R1-R2 and C1-C2 differences, T1-T2 when present, and all centered
log-slope levels; keep the already specified supplementary expanded targets.
On an eligible consistent root, the research candidate is
`t_hat +/- qnorm(.975)*sqrt(v)`. For positive component slopes, form bounds on
the log scale and exponentiate, requiring finite positive display bounds;
do not form symmetric slope-scale bounds from delta RootSE. Named constraint-
fixed targets have no inferential interval. An invalid/nonpositive variance or
nonrepresentable bound leaves the matching point and a specific refusal.
No automatic order choice, simultaneous interval, p-value or quality label is
added. The fit already computes its root covariance; applying these saved
maps does not call for another optimizer, root search or independent dataset.

**What the mapping measures.** For every admitted condition/order, retain:

- Planned dataset count; actual contributing Persons; returned local points;
  consistent-start points; covariance returns; candidate interval returns;
  source/batch score delivery; and distinct reasons for each loss. The public
  point, candidate interval and F scoring denominators must not be conflated.
- Bias/RMSE and their Monte Carlo uncertainty on the stated available-point
  subsets, joint availability for paired comparisons, interval width and
  truth inclusion among eligible intervals. Also report interval-and-truth
  delivery over all planned datasets. Capacity exclusions remain separate
  from generated-data failures; no redraw to obtain the requested count.
- Compare root SE with empirical variability on the same interval-eligible
  subset, explicitly acknowledging that it is selected by the candidate gates.
  Report bias on that subset too: an SE match does not remove miscentering,
  and nominal-looking inclusion can result from wide intervals compensating
  for bias. The current R=50 first stage is descriptive mapping, not precise
  interval qualification.

Generating truth is already defined in A/B/C/E. It is therefore possible to
evaluate this *candidate's* truth inclusion without solving every condition's
population adjusted equation. Root-target inclusion is evaluated only where a
compatible independently retained population root exists, matching the response
law, ability distribution, roster proportions, exposure, constraints and order.
Do not use the same Monte Carlo estimates' average as a known population root,
or transfer an N=400 discrete-mixture root to a normal small-N design. A new
population-root calculation needs a specific unresolved explanatory question;
it is not a prerequisite added to every mapping cell. The N=400 studies remain
essential retained evidence, and the paused study's original denominator and
candidate identity remain intact.

**Paired order sensitivity.** Reuse the existing research
[order-sensitivity contract](jml-inference-review-20260927.md#order-sensitivity-without-generating-truth)
when interpreting orders 2/4. A signed point difference can be retained when
both points are available. A local paired SE additionally requires compatible
covariance/influence records, consistent roots for this research summary, and
matched Persons, observed data, parameter maps, roster law and order identities.
For the same scalar target, use
`Var(t_4-t_2) = sum_i[(F_4 L' - F_2 L')_i^2]/N^2`,
which retains cross-order covariance. Adding the two marginal variances treats
the paired estimates as independent and is incorrect. No extra derivatives or
fitting are needed when the full influences are already saved. Missing paired
SEs do not erase point differences; zero paired variance leaves a standardized
ratio undefined. This is descriptive sensitivity around different roots, not
a test of either order's bias or a selection rule. Across-replicate MSE
differences and their MCSE remain separate performance measures.

The foundational sources retain their original scopes:
[Haberman's binary-Rasch report](https://www.ets.org/research/policy_research_reports/publications/report/2004/hytm.html)
and [Dhaene and Weidner's approximate functional differencing](https://arxiv.org/html/2301.13736v2).
The latter explicitly distinguishes increasing individual exposure from
increasing the number of units; neither reference establishes the present
GPCM's truth-interval validity. Keep the retained centering/identification
counterexamples and order-MSE reversals. A future public structural interval
requires a declared estimand, source/boundary rule, compatible sampling
covariance, centering justification and design-specific coverage evidence.
An observed order difference, ordinary information inverse or RootSE field
cannot close that gate. This work adds no fit repetitions to the family ledger;
the saved transformations and summaries are additional analysis work after
the hold, and precise confirmation still needs its own claim/allocation.

Before freezing the study aggregation, verify on compatible retained records
that the original order-2 expanded-coordinate candidate is reproduced, contrast
variances agree with an independently written expansion map, and paired
influences reproduce both marginal and difference covariances. Exercise missing
covariance, unresolved starts, fixed/redundant targets, reordered identifiers
and mixed sampling-law refusals. Saved-summary replay must not invoke fitting
or equation differentiation. Reuse the existing candidate/order-sensitivity
fixtures; a new numerical fixture is justified only for an uncovered branch.
These affected engineering checks remain held and do not constitute a new
sampling study or qualification of public structural intervals.

**Normal-population transfer: a narrower analytic result.** The subsequent
[structural-inference review](jml-inference-review-20260927.md#october-1-structural-inference-gaps-and-a-normal-tail-bound)
derives a profile-score bound for a fixed roster, structural compact
neighborhood and positive slopes. Nonextreme profile abilities grow at most
as log(L); absorbing extreme patterns have zero structural score. For fixed
correction order, `sup_y ||U_k,L|| <= 2^k*C*L*(1+log(L))`. Thus finite moments
of the infinite Person estimates are not needed to obtain finite score moments
at fixed exposure. This does not establish public/profile point equivalence,
a selected regular root or small-N covariance accuracy.

For a bounded-mean/variance normal family, an expanding cutoff proportional
to sqrt(log(L)) controls the score-moment tail at any chosen fixed polynomial
rate. The [subsequent derivative/tail analysis](jml-inference-review-20260927.md#full-derivatives-and-normal-tail-transfer)
now extends this to the complete evaluation Jacobian and covariance moments.
A nonextreme fitted-Person total-curvature lower bound and implicit
differentiation give polynomial-in-L derivative envelopes; differentiating
the correction includes derivatives of the plug-in transition itself. The
current whole-equation numerical derivative targets these terms. The leading
fixed-order bias coefficient has an exponential-polynomial ability envelope
and is normal-integrable, but integrating a coefficient is not integrating
the remainder. The central-region expansion/remainder, its full evaluation
derivatives, local-root branch and matching covariance limits still need
uniform arguments on the expanding range. The retained compact-family truth-centering rate cannot
be transferred by simply citing normal tails or increasing correction order.
Neither this proof step nor the finite-L root covariance gives a data-based
bound on residual structural bias. C/E require their own design/sampling
assumptions; informative missingness and dependence remain separate issues.
Next, trace those constants/remainders and the ordinary public/profile bridge
using the existing derivations and source. No new root sweep, simulation
allocation, clipping of generated abilities or public interval is introduced.

### Evidence reuse and present status

**Bounded numerical exception after the user's request.** The
[normal-range pilot](jml-inference-review-20260927.md#bounded-numerical-pilot-after-authorization)
now adds exact derivative/expectation witnesses and four new paired datasets
(N=40/120 by normal SD=1/2, one replicate each) using the saved Criterion-owner
unequal design. It retains all ordinary/order-2/order-4 outcomes. One ordinary
fit is blocked at its iteration limit; two corrected outputs have unresolved
alternate starts even though their local covariance matches the reference.
The complete derivative and eight available corrected covariances pass their
independent numerical comparisons. Initial runner argument errors and a
reference-underflow interruption are retained with source/input accounting;
the final reconciled summary is `jml-normal-range-pilot-20261001/verified-summary.rds`
under `validation-results`. These small checks supersede the hold only for
this declared work; they do not resume the paused study or qualify empirical
coverage, bias removal, new facets or dependence. Existing broad-study evidence
and the approved three-fit MML checks keep their separate roles.

#### Bounded facet-structure pilot after authorization

The user's subsequent continuation authorizes a small C-design diagnostic,
implemented in [the facet runner](mfrm-facet-structure-pilot-20261001.R).
It is not a launch of the expanded allocation. N=20 and N=240 each use normal
mean 0 / SD 1 abilities, three response categories, two Criterion levels and
exactly eight conditionally independent responses per Person. Criterion owns
both centered steps and geometric-mean-one slopes. The five analysis conditions
at each N are:

| Condition | Non-Person facets and levels | Question at fixed individual workload |
| --- | --- | --- |
| Base | Rater 3, Criterion 2 | Two raters x two criteria x two independent events; omit Task from the fitted model. |
| Six raters | Rater 6, Criterion 2 | Double the rater pool while each Person still sees two raters. |
| Null Task | Rater 3, Criterion 2, Task 2 | Reuse the base responses exactly; include the two event labels as a true-zero Task effect. |
| Two tasks | Rater 3, Criterion 2, Task 2 | Introduce Task effects (-.2,.2); each Person sees both tasks. |
| Four tasks | Rater 3, Criterion 2, Task 4 | Duplicate the Task-effect distribution (-.2,.2,-.2,.2); each Person sees only two tasks. |

Thus there are ten analysis conditions but eight distinct response datasets.
Seeds 98100201/98100202 use L'Ecuyer-CMRG and do not consume the broad-study RNG
schedule. Within N, abilities, randomized Person-to-roster allocation and
response uniforms are shared across conditions; these are paired diagnostic
comparisons, not independent replications. Rater effects are (-.3,0,.3),
duplicated for six raters; Criterion effects are (-.4,.4), steps are
(-.6,.6)/(-.9,.9), and log slopes are (-.2,.2). Cyclic balanced rosters follow
the C-design pairing rules; N=20 has unavoidable allocation imbalance. All
declared categories and generated extreme Persons are retained.

The preflight verifies full rank of the additive Person/facet location design
and 81 owner-total states per roster. Structural dimensions are 6/9/7/7/9;
roster counts are 3/15/3/3/12. At N=20, six raters create ten singleton rosters
and a within-roster score-rank ceiling of 5 for 9 coordinates; four tasks create
four singleton rosters and a ceiling of 8 for 9 coordinates. Fixed-roster full
covariance is therefore impossible in these two designs, regardless of point
convergence. At N=240 those arithmetic obstructions disappear, which does not
by itself establish empirical rank, conditioning or accurate intervals.

All ten conditions are attempted with direct fixed-q31 estimated-population
MML, ordinary JML and explicit correction orders 2/4: 40 fit calls, maxit=400,
the declared public starts, BFGS/reltol=1e-9 for uncorrected methods, and the
fixed-roster law for correction. Two independent worker processes have a
predeclared 120-second limit per job including package loading; a limit is
resource censoring, not a proof of nonconvergence. Raw returned fits are saved
before inspection. Inputs, package sources, compiled library, runner and fit
outcomes are retained under `validation-results/mfrm-facet-structure-pilot-20261001`.

**Completed numerical findings.** All ten ordinary-JML and all ten q31 MML
calls return finite optimizer traces and pass their raw-gradient convergence
check; their public fit readiness remains `review`. All returned corrected
points have `consistent_roots`, meaning agreement of the checked public starts,
not a proof of global uniqueness:

| Corrected design | N=20, orders 2 / 4 | N=240, orders 2 / 4 |
| --- | --- | --- |
| Base | Both points and covariances returned | Both points and covariances returned |
| Six raters | Both points returned; both covariances refused for singleton rosters | Both points and covariances returned |
| Null Task | Both calls reached the 120-second process limit | Both points and covariances returned |
| Two tasks | Both points and covariances returned | Both points and covariances returned |
| Four tasks | Order 2 point returned, covariance refused; order 4 reached the process limit | Both points and covariances returned |

The three resource-censored calls retain their full denominators, frozen inputs
and status files; they have no serialized final fit and cannot be classified
as mathematical nonconvergence or used to assess covariance availability.
The 17 returned corrected points have maximum mean-equation residual
8.692501e-11. The N=20 six-rater and four-task returned scores actually attain
the rank ceilings 5 and 8, respectively. The 14 available covariances match
reconstruction using a halved complete-equation derivative step: maximum
scaled Jacobian difference 2.916679e-9, meat difference zero and relative
covariance difference 2.849752e-8. These checks reuse the native score kernel;
they test step stability and matrix/roster accounting, unlike the earlier
independent response-pattern derivative reference. The ordinary public points
have extended-profile mean residual at most 4.454882e-6 without changing their
structural coordinates. This is a residual witness, not a structural-root
distance certificate or a sampling-covariance construction.

The [retained-point checks](mfrm-facet-structure-checks-20261001.R) also compare
the literal generating probabilities with native evaluation (maximum absolute
discrepancy 3.330669e-16). MML q31 fixed versus adaptive q61 log-marginal changes
are at most 2.073304e-5 per Person; adaptive q31/q61 changes are at most
1.456613e-13. Nevertheless, **seven q31 optimizer points fail the original
raw-gradient tolerance 1e-4 when evaluated with fixed q61**: N=20 six raters
and two tasks, and all five N=240 conditions. The largest q61 gradient is
.001461024. Small likelihood changes alone therefore do not establish the
retained-point stationarity requirement.

A separate frozen, integration-only follow-up refits exactly those seven
saved inputs at q61, retaining the same maxit, tolerance, BFGS, population
model and public default starts. Selection uses only the higher-grid gradient;
it does not use interval availability or truth error. All seven refined points
pass their own convergence check and fixed-q121 gradient review (maximum
8.456015e-5; q61/q121 gradient change at most 1.994588e-7). Maximum structural
movement from the original q31 points is 5.447969e-5. Thus the refinement is
material to the numerical certificate here, with small point movement. No
MML covariance, boundary qualification or interval coverage is established by
this pilot. The remaining three q31 points retain their successful q61 gradient
reviews. The follow-up protocol and runner are saved in the output directory.

Accounting is **47 calibration calls: 40 initial calls plus seven integration
refits; 44 returned fits and three resource-censored calls**. No new data or
corrected-JML retries enter the refinement. `verified-summary.rds` and
`verified-rows.csv` reconcile all stages, original/retained point paths, source
hashes and unassessed versus unavailable covariance; `summary.rds` retains the
initial 40-call record. Subsequent numerical work should diagnose the three
censored cases with their saved inputs and explicit solver-stage accounting
before increasing repetitions. Small-sample inference work must preserve the
fixed-roster rank obstruction instead of switching sampling laws to obtain SEs.

This deliberately tractable K=3 / Criterion=2 subset does not execute or
replace C's K=4, Criterion=3/5, added-workload or wider-N comparisons. Each
condition has one replicate: bias, failure probability and coverage remain
unestimated. The derivative/remainder proof, ordinary public/profile bridge,
informative assignment/missingness and dependent responses remain separate
requirements.

| Evidence | What is available | How it enters this plan |
| --- | --- | --- |
| Adaptive MML matched replay | 400 datasets at N=240, four conditions; numerical availability improved but adverse component coverage/SE and a refused interval remain | Retain all records and both point/interval denominators. Method-development reuse is not independent confirmation; changed procedures need labelled re-evaluation. |
| MML core proposal and old confirmation proposal | Eight N=120/480 timing cases; 800 prepared core inputs with 792 unrun; 2,000-case proposal unexecuted | Reuse compatible preparations only after the final design/authorization. Timing success is not coverage evidence; neither prepared runner is automatically the next launch. |
| Earlier ordinary-JML calibration records | RSM/PCM external-engine factor pilot with five replicates per profile; six paired PCM/GPCM datasets at N=40 | Reuse parameterization, extreme-response and unsupported-design findings. These are engineering/calibration records from older sources, not confirmation of current public JML performance or model-selection error rates. |
| Ordinary/one-step JML comparison | 200 datasets at N=400 on a common design, with truth/root diagnostics | Retain ordinary-JML performance and correction gains/limits in that exact research implementation. Do not transfer its failure rate to another solver/API procedure. |
| Corrected-JML order comparison | 400 datasets at N=400 across two owner/exposure conditions, paired orders 2/4; subsequent target/exposure reviews | Retain MSE reversals, residual bias and all-coordinate results. These are essential larger-sample evidence, not optional background. |
| General-input and public corrected-JML bridges | Larger facet/category engineering witness, public/research equation-covariance comparisons and six exposure timing cases | Establish specific computation/output identities, not broad coverage or general scalability. |
| Additional corrected-JML study | Paused at 113/3,000 fit records and 57 generated inputs; no completed sampling summary | Preserve its frozen protocol and interruption accounting. Decide whether it answers a retained release question before any resumption. Do not selectively summarize it as a completed study or silently replace its cases/procedure. |

Use the [JML inference review](jml-inference-review-20260927.md),
[ordinary/adjusted comparison protocol](jml-sample-comparison-20260927.md),
[order-comparison protocol](jml-order-sampling-20260927.md),
[general-input record](jml-general-inputs-20260928.md), and
[MML design review](gmfrm-mml-em-20260927.md#october-1-small-cohort-and-facet-structure-review)
for source identities, findings and limits. The related primary sources are
[Haberman (2004)](https://doi.org/10.1002/j.2333-8504.2004.tb01947.x) and
[Dhaene and Weidner (2023)](https://doi.org/10.1007/s13209-023-00283-1).
Their assumptions, conjectures and limited models do not automatically qualify
this package's corrected GPCM or interval consumers.

#### Static source audit and reusable units

October 1 source review compared the retained files with the current working
tree, without loading R, deserializing fit records or running any numerical
consumer. Reuse has four separate units: generated inputs, individual fitting
stages, target-specific uncertainty records, and scoring outputs. Equality at
one unit does not establish equality of the other three.

| Retained source / record | Verified source or inventory finding | Reuse decision and remaining check |
| --- | --- | --- |
| MML matched replay, `validation-results/gmfrm-adaptive-matched-20260930/source` | `R/core-optimizer.R`, `R/core-gmfrm-em.R`, `R/mfrm_core.R`, both retained C++ files and `src/mfrmr.so` are byte-identical to the current files. Changes in `R/api-estimation.R` and `R/api-gpcm-intervals.R` are documentation only; `R/core-gpcm-product-slopes.R` changes a comment and the local-Wald description, not its calculations. Both adaptive procedure/replay scripts are byte-identical. | Preserve the old point and component-slope interval evidence with its original procedure. This audit gives no reason for a blanket 400-case refit. It does not establish the prospective output-specific stopping policy's performance. |
| MML new output consumers | `R/api-prediction.R` adds two-family source/scoring paths; `R/api-facet-intervals.R` adds two-family location/contrast inference. These consumers were not part of the frozen replay. | Existing fits can be candidate inputs to these consumers after source/data checks; their outputs and performance are unmeasured by the old slope-interval summary. A failed consumer is not automatically a reason to refit. |
| Prepared MML core | Directory inventory has 800 saved inputs and eight numbered completed job files. The saved generator is byte-identical to `inst/validation/gmfrm-design-screen-20261001.R`; the preparation script links the frozen MML package and reuses the eight pilot results. | The eight N=120/480 cells, 100 inputs each, remain candidate development inputs for the historical full-slope truth in D. They are not new small-N/rubric/null-slope data. Keep the eight fits and 792 unrun jobs separate; no automatic resume. |
| Research JML 200-case and 400-case studies | The sample/order runners use starts `(0,0,-.8,-.8,0)` and `(-.3,.4,-.3,-1.1,-.25)` and require both reviewed roots to agree. The order runner's small-step fallback has maxit=150 and includes derivative stability in root review. The current public procedure uses different deterministic starts/stages, maxit=400 in the planned call, and a separate `root_with_unresolved_starts` point status. | Retain the original bias/MSE/coverage findings under their research procedures. Equation/covariance identities do not transfer optimizer delivery rates. Public-solver evaluation requires its own labelled result; do not relabel the research ordinary profile solver as public joint JML. |
| Public corrected-JML pilot and paused study | The three `R/core-jml-adjustment*.R` files in `validation-results/jml-observed-inference-20261001/source` are byte-identical to current files. The public wrapper explicitly calls order 2, fixed-roster covariance and maxit=400. Its candidate intervals additionally require `consistent_roots`. Inventory confirms 57 input and 113 fit files in the paused study. | These records are not made obsolete by the research/public solver distinction above. Retain their original N=400, exposure, order and candidate-interval identities. Neither an incomplete sampling summary nor a new order-4/small-N result is supplied; resumption remains a separate scope decision. |

This is a scoped source audit, not fresh numerical equivalence or a complete
provenance validation. The retained MML binary's MD5 is
`65bc36d69ba885e935d19f7f3e2cd3d9` in both locations; it was compared as a file,
not loaded. Package dependencies/runtime, RDS manifest contents and every
input/result hash were not rechecked here. The matched runner also preserves
nine reused jobs' earlier source identities, including the repaired weak-
information record; the main snapshot must not be attributed to every retained
stage. Keep those recorded exceptions when validating provenance before reuse.

After the hold, a bridge to the prospective workflow first checks each saved
stage's data, model, initialization, node count, controls and source identity.
Apply the declared source/interval checks to matching stages, preserving the
stage-specific points and failures. Reuse qualifying stages; fit an additional
stage only if the new prespecified refinement rule requires a stage absent
from the record. A changed final-stage decision may require new scoring or
interval evaluation without requiring a new calibration fit. Do not count
these development bridges as fresh independent confirmation or infer new
coverage from unchanged numerical code alone.

### Comparison blocks and the decisions they support

The following is the working condition-to-question matrix, replacing an
MML-only fit quota. **These blocks are planned, not a frozen sampling
protocol.** "Full N range" means 20/30/40/60/120/240/480; the historical JML
N=400 conditions retain their own design and truth. The baseline range belongs
to ordinary JML as well as MML. Additional burden/robustness contrasts use
N=20/60/240/480 as specified small/large anchors; they do not imply that the
omitted N values or every Cartesian combination has been evaluated.

| Block / question | Concrete comparisons and method arms | Evidence and decision produced |
| --- | --- | --- |
| A. Ordinary calibration: what can users obtain before adding discrimination or correction? | Full N range; Criterion=3, Rater=3, K=4, crossed versus two raters per Person. Separate correctly specified RSM and criterion-step PCM generating models; ordinary MML and ordinary JML on the same responses within each model. Shared truth, constraints and declared MML population treatment precede comparison. | Use the older RSM/PCM factor pilot and six-pair N=40 record for design/estimand checks only. Evaluate location contrasts, response probabilities and scoring; determine finite/boundary behavior and the actual meaning of ordinary-JML precision. RSM/PCM comparison here does not qualify a model-selection rule. |
| B. Shared-owner GPCM: when does JML correction help or harm? | Full N range on the same two-facet baseline, Criterion owning steps and the single slope family. Compare one-family MML, public ordinary JML and separately fixed correction orders 2/4 where admitted. At the four burden anchors, vary per-Person exposure L=1/2 in the two-rater-per-Person design while holding N and facet levels fixed; the all-three-rater corrected arm remains at L=1 because L=2 exceeds its state cap. Retain the original N=400 designs and L=1/4 contrast separately. | Reuse the 200-dataset ordinary/one-step and 400-dataset order studies, with an explicit research/public procedure bridge. Assess paired bias/MSE and availability, root versus truth uncertainty, and order-specific limits. An order-1 research result is not automatically the current public ordinary or corrected arm. No automatic order selector is introduced. |
| C. Facet structure: which source of variation or information changed? | N=20/60/240/480; Rater=3 versus 6 at fixed two raters per Person; Task x Criterion x Rater starts at 2 x 3 x 3, K=4, two raters per Person-task, then changes Tasks 2 to 4 or Criteria 3 to 5 separately. Compare changing versus retaining rater pairs across tasks. Vary K=3/4/5 separately in the two-facet baseline at fixed levels/exposure. Keep the all-rater panel as a separate added-workload comparison. RSM/PCM and admitted one-family MML/JML arms; corrected JML only within its capacity. | Separate task/criterion/rater contrasts, information per level, overlap and workload. Category-ladder comparisons need within-ladder recovery targets, not pooled errors on different raw score scales. Current two-family MML is not a three-facet arm. No concatenating Task and Criterion to claim separate effects. Record where points, covariance or the entire computation are unavailable and why. |
| D. MML-specific generalization: do extra slope families and owner choices earn their complexity? | Retain the three-Task/six-Rater/K=3, SD=.5/1, common/paired-roster core across the full N range and its N=240 evidence. Add the rubric baseline with criterion-owned steps. In compatible two-facet designs compare equal, one-family and two-family slope structures under a matched population/scale contract; keep separate slope/step ownership as an explicitly MML-only question. | Preserve the 400-case replay, including adverse coverage and unavailable intervals. Decide the score-rank policy, severity-contrast consumer gaps and which numerical/interval procedure warrants confirmation. Do not create nonexistent two-family or separate-owner JML arms for symmetry. |
| E. Robustness: which conclusions depend on the response, population or assignment assumptions? | Selected common-model designs at N=20/60/240/480, following the baseline SD comparisons: skew/mixture, weak targeting/rare categories, unequal or ability-associated allocation, missing assigned scores and within-performance dependence. Use E's specified mechanisms, matched controls and limited combined cases; additional D-specific robustness claims need explicit conditions. | Both MML and JML need this block; absence of a fitted normal population in JML does not imply immunity. Separate changed estimands, bias, weak information and numerical failure. Preserve empty declared categories. Do not label coverage of a misspecified component as truth coverage without a defined target. |
| F. User outputs: does calibration quality carry through to scoring and reuse? | Use the same admissible fitted records from A–E for results, declared contrasts, curves and saved-calibration replay. Distinguish native scoring from a common scoring rule/prior. Separate calibration-cohort and independent held-out Persons, including ability tails and extreme responses. | Check target-specific score error, probability calibration, availability and the stated conditional uncertainty. Reuse artifacts rather than initiate an unrelated simulation. Conditional EAP intervals do not include calibration uncertainty; formal feedback, ranking or selection rules remain separate claims. |

Blocks A/B supply ordinary-JML validation in their own right. Block D is not
a prerequisite for them, and failure to qualify corrected-JML truth intervals
does not block evaluating ordinary-JML points or existing scoring outputs.
Conversely, success in A/B does not settle MML-specific two-family inference.
Anchors, nonunit weights, interactions and other already admitted options need
an explicit retained-evidence/open-gap entry under their native method; they
are not silently qualified by these unanchored unit-weight baselines or forced
into a corrected-JML arm that rejects them. A new extension needs its own
scientific justification, not merely an empty cell in this table.

The older records referenced in A are the
[RSM/PCM external-engine pilot](tam-immer-jml-factor-pilot-record-0.2.3.md)
and [paired PCM/GPCM calibration](pcm-gpcm-jml-paired-calibration-record-0.2.3.md).
Their source versions, low replication counts and extreme-response eligibility
rules remain attached to any reused finding.

### D-LR: latent regression and its connection to JML

**October 2 scope correction.** A/B's estimated intercept-only population is
not a validation of regression on background variables. D-LR is required
work in the broad roadmap, using R=50 per admitted condition, alongside the
existing small/medium/large-N, facet and historical evidence. The Gaussian
core inputs are prepared as recorded below; categorical and other extensions remain
to be allocated. The existing 30,600 input records and 135,800 calibration
slots describe A-E as previously enumerated and do not silently include this
addition. No full D-LR sampling run has started. The
older 80,000-run population-interval proposal is not resumed by this addition.

**Question and target.** For `theta | X ~ N(X gamma, sigma_e^2)`, estimate
the covariate effects and residual variance jointly with facets, steps and
slopes. Report `gamma`, `log(sigma_e^2)`, structural contrasts and conditional
new-Person scores separately. Residual variance is not marginal ability
variance. Regression on estimated EAP/JML scores is a different procedure;
it cannot replace this response-level model or inherit its uncertainty.
Ordinary/corrected JML do not estimate `gamma`: if both `gamma` and each
residual ability `u_i` were free in `theta_i=X_i gamma+u_i`, replacing them
by `gamma+c` and `u_i-X_i c` would preserve every response probability.
Any JML-based regression proposal therefore needs its own identifying
assumptions and estimator, rather than another argument to the present JML.

**First comparison, reusing the normal A/B responses.** Add observed covariate
views at `rho=0` and `.5`. For a saved generating `theta ~ N(0,s^2)`, draw an
independent standard normal `Z` and set
`X = rho*theta/s + sqrt(1-rho^2)*Z`. This explicitly generated joint-normal
law implies `theta | X ~ N(rho*s*X, s^2*(1-rho^2))`. It reuses the saved
abilities, responses, facet parameters and assignments without changing their
distribution. `rho=0` assesses an unnecessary predictor; `.5` gives an
informative predictor while keeping the same marginal ability distribution.
Truth is used by the generator and recovery evaluator only; fitting/scoring
receive observed X and responses. Covariate streams need their own immutable
registry linked to the original input checksums, disjoint from A-F streams.

Retain all seven N values (20/30/40/60/120/240/480), SD=.5/1, the admitted
RSM/PCM/GPCM truth/owner configurations and linked full/paired-L1/L2 exposure
views. Match explicit `~ X` with the existing `~ 1` MML arm on the same data
and identifiable response scale. Both normal population specifications have
well-defined targets in this first comparison; an intercept-only fit does
not estimate a covariate coefficient. Reuse compatible ordinary/corrected
JML fits for structural and common-prior score comparisons; covariates do
not require refitting those unchanged response-only likelihoods/equations.
No JML regression-coefficient or residual-variance result is fabricated.

**Gaussian-core allocation and bounded initial-call protocol.** The
[input preparer](mfrm-wide-map-lr-inputs-20261002.R) links both rho values to
each of the 108 A/B conditions: 216 conditions, each with original replicate
IDs 1--50, hence 10,800 covariate/response views. They contain 4,200 covariate
tables sharing 2,100 existing parent cohorts, not 10,800 independent cohorts
or new response datasets. All exposure views and both rho values share the
same Person-level Z within a parent; X is not sample-centered or standardized.
The existing A/B scope admits RSM under S-RSM, PCM and GPCM under S-PCM,
and GPCM under S-GPCM. Thus 14,400 new latent-regression initial fit slots
pair with 7,200 distinct intercept-only control slots already in A/B.
Controls are reuse candidates subject to source/procedure compatibility,
not newly completed or universally reusable fits. A-E plus this Gaussian
core totals 150,200 planned initial slots; numerical refinements, scoring,
other D-LR extensions and historical-protocol decisions remain separate.

Reserve L'Ecuyer unit streams 4,751--6,850 after the existing E registry,
using one training-covariate substream and a reserved future-covariate head
per parent. Preserve every A-E registry/bundle and the existing F reservations.
The parent registry and bundle checksums bind the response input, covariates,
generating regression coefficients and residual variance. Fit adapters expose
only observed response columns and Person/X, never theta, Z or generating truth.

Before any D-LR fit outcome is examined, select S-PCM, SD=1, paired-L1,
replicate 1 at N=20 and N=240, both rho values and both admitted fitted models
(PCM/GPCM): eight initial calls. Use direct fixed-grid MML, 31 nodes, BFGS,
maxit=400, reltol=1e-9, the public initialization and unchanged responses.
No alternative start, fitting retry, truth-based selection or grid promotion
belongs to this initial-call witness. Retain every warning/error, population
point, convergence diagnostic, public population-summary table and missing
target. Compare saved summary replay without fitting. Regression intercept,
X coefficient and log residual variance have known generating values here;
reported errors from these two cohorts are workflow evidence, not bias,
coverage, power or R=50 performance estimates. Public population intervals
remain unavailable. This witness does not replace the calibration/scoring
numerical review needed before the full execution protocol is qualified.

**Completed Gaussian inputs and bounded calls, October 2.** The preparer
completed all 2,100 bundles, 10,800 views and 14,400 allocation records under
`validation-results/mfrm-wide-map-r50-20261001/lr-inputs/`. The global next
unused unit ordinal is now 6,851. Input checks retained the original response
hashes and confirmed no duplicate condition/replicate keys and exactly 50
replicates per condition. All 6,850 reserved A-E/D-LR unit-stream starts are
distinct. Fresh-process checks regenerated the prespecified N=20/480 S-PCM,
SD=1, replicate-1 parent bundles in reversed order and with two workers:
both exactly matched the saved bundles, with global RNG state and immutable
input checksums unchanged. The targeted input tests passed 32 expectations.
These checks establish input identity and the stated Gaussian construction,
not statistical performance of an estimator.

| N | Linked covariate/response views | Additional initial LR slots |
| --- | ---: | ---: |
| 20 | 1,800 | 2,400 |
| 30 | 1,200 | 1,600 |
| 40 | 1,200 | 1,600 |
| 60 | 1,800 | 2,400 |
| 120 | 1,200 | 1,600 |
| 240 | 1,800 | 2,400 |
| 480 | 1,800 | 2,400 |
| Total | 10,800 | 14,400 |

The [bounded initial-call runner](mfrm-wide-map-lr-witness-20261002.R) then
completed exactly the eight prespecified PCM/GPCM calls on the two N=20/240
parent cohorts. These use Rater=3 by Criterion=3, categories 0--3 and six
ratings per Person; this run does not vary the facet count or levels. All
eight returned optimizer code 0, no captured warnings/errors and all three
finite population targets (24 values). Every convergence record nevertheless
has `inference_ready=FALSE` and `fit_readiness="review"`; no population SE or
interval was supplied. The formula environment is reduced to base R before
the fit call, and only observed responses and Person/X enter estimation.
No intercept-only controls, alternative starts or higher-node fits were run
in this witness. Records, source hashes, the pre-outcome protocol, points and
public tables are retained under
`validation-results/mfrm-wide-map-lr-witness-20261002/`. A separate R process
blocked fitting/optimization and reproduced all eight saved summaries and
save/read round trips exactly, with zero estimation calls and unchanged
original evidence hashes. The input job table is an immutable allocation,
not a live completion ledger; these eight initial results are recorded in
the witness directory. Full R=50 fitting, numerical qualification, paired
performance comparisons and final reporting remain pending.

**Required extensions before a general latent-regression claim.** Add
conditionally normal categorical predictors with balanced and rare groups;
continuous-plus-categorical models; correlated predictors and weak information;
and targeted C facet/level changes at the existing small/large-N anchors.
For categorical effects, generate `theta` conditional on the group: merely
dichotomizing the Gaussian X above does not preserve a conditional-normal law.
Separate correctly specified cases from nonlinear mean, heterogeneous residual
variance, nonnormal residuals and predictor-associated assignment. Missing
background variables, missing ratings and group/facet confounding need separate
mechanisms and matched controls. Retain empty groups, extreme Persons, rank
failures and complete-case losses without replacement. These extensions need
their explicit condition/stream allocation before generation; this paragraph
is not a claim that their design or implementation is complete.

**Inference and output decisions.** Reuse the retained
[RSM/PCM full-information review](population-full-information-record-0.2.4.md)
and [40-dataset preflight](population-coverage-record-0.2.4.md), preserving
their historical source and N=80/320 scope. They support bounded numerical
work, not R=50 small-sample coverage. Population coefficients/variance remain
public point estimates without a population `vcov()` or formal CI API. Joint
information must include regression, residual variance and all structural
nuisance coordinates; a regression-block inverse alone is insufficient.
The recent native-location interval route admits intercept-only populations,
not covariates; existing GPCM slope/curve inference has its own scope/checks.
An output-specific extension and sampling qualification must precede a broader
interval claim. Evaluate bias, empirical variation versus SE, conditional
coverage and interval-and-truth delivery separately; never hide failures in
the successful subset. F must use independently generated new Persons with
their background variables, distinguish covariate shift from changed
`theta | X`, and retain the omission of calibration/population uncertainty
from plug-in EAP intervals. Latent-regression portability remains unavailable.

**Concrete scoring repair in this review.** `~ scale(X)` previously learned
new centering/scaling on the scoring cohort, changing the conditional prior
for the same Person and failing for a singleton. Population preparation now
retains R's prediction-aware terms and scoring reuses them, including polynomial
and spline bases. Legacy transformed fits reconstruct terms only from training
data that reproduce the stored design; otherwise they stop. Scoring-cohort
rank is not an estimation-rank requirement. This fixes predictor interpretation,
not statistical qualification, source eligibility or an interval API. The
bounded tests cover single/batch invariance, factor interactions, saved replay,
legacy refusal and complete-case preparation. That repair did not launch a
D-LR study; the later eight initial calls are recorded separately above.

### A/B generating truth and assignment specification

**A/B input specification, October 1; R=50 preparation authorized.** The following
values define the new controlled baseline, not empirical population estimates
or typical-use claims. They do not replace the historical MML or N=400 JML
truths. Their role is to distinguish estimator behavior under shared steps,
owner-specific steps and nonconstant relative slopes, while preserving the
same location scale, Persons and rating design within each comparison.

For Person i, Rater r, Criterion c and category k=1,2,3, use the adjacent-category
equation `log[P(Y=k)/P(Y=k-1)] = a_c * (theta_i - b_r - d_c - tau_ck)`.
Categories are 0,1,2,3. All probabilities follow from this equation and
normalization; slope multiplies the complete predictor. Conditional on theta
and the fixed facets, core rating events are independent. Dependence is a
separate robustness mechanism, not silently introduced by repeated ratings.

| Quantity | Specified truth and reason |
| --- | --- |
| Person population | iid `theta_i ~ N(0, sigma^2)`, sigma=.5 or 1. The same structural parameters remain fixed as sigma changes. Do not force realized sample mean/SD to their population values. |
| Rater locations b_1,b_2,b_3 | (-.3, 0, .3), centered; primary Rater 1 minus Rater 2 contrast is -.3. This is a controlled moderate spread, not a universal severity threshold. |
| Criterion locations d_1,d_2,d_3 | (-.4, .1, .3), centered; primary Criterion 1 minus Criterion 2 contrast is -.5. This reuses the scale of the historical task-location vector, not its original model/evidence identity. |
| Shared-step truth, S-RSM | Every criterion has steps (-.6, 0, .6); all slopes equal 1. Fit RSM by ordinary MML and JML. |
| Owner-step truth, S-PCM | Criterion 1 steps (-.6, .2, .4); Criterion 2 (-.8, -.1, .9); Criterion 3 (-.4, -.1, .5); all slopes equal 1. Each row sums to zero, and their column means equal the S-RSM vector. Fit PCM by ordinary MML/JML. Reuse the same datasets for the free-slope GPCM null comparison. |
| Nonconstant-slope truth, S-GPCM | Same locations and steps as S-PCM; centered log slopes (-.2, .2, 0), so slopes are (exp(-.2), exp(.2), 1) with geometric mean 1. Fit shared-owner GPCM by MML, ordinary JML and corrected JML at separately fixed orders 2/4. |

S-PCM also admits the same four GPCM arms as S-GPCM. This asks how free slope
estimation/correction behaves when all true slopes equal one, including
spurious slope dispersion; it does not qualify an automatic PCM/GPCM selector.
This reuses responses rather than generating a redundant fourth truth family.
Changing S-RSM to S-PCM preserves the mean step vector but changes individual
category probabilities; do not claim equal information. S-GPCM changes only
slopes relative to S-PCM. These modest truths do not cover near-zero slopes,
severe targeting or arbitrary location/slope associations; those remain E
conditions. Report absolute bias and log-slope error rather than relative bias
divided by a zero true location/log slope.

**Primary assignment.** Each Person is assessed on all three criteria. The
full-panel arm assigns all three raters (9 ratings per Person); the paired arm
assigns the same two raters across the criteria (6 ratings per Person). Use
the pair order (R1,R2), (R2,R3), (R3,R1); divide N by three and allocate its
remainder to the first pairs. Counts are fixed before responses. Randomly map
Persons to these slots independently of ability; the corrected-JML covariance
target is `fixed_rosters`. Fixed counts do not mean conditioning simulated
abilities on equal roster means or variances.

| N | Pair counts: 12 / 23 / 31 | Independent Persons per Rater: R1 / R2 / R3 |
| --- | --- | --- |
| 20 | 7 / 7 / 6 | 13 / 14 / 13 |
| 30 | 10 / 10 / 10 | 20 / 20 / 20 |
| 40 | 14 / 13 / 13 | 27 / 27 / 26 |
| 60 | 20 / 20 / 20 | 40 / 40 / 40 |
| 120 | 40 / 40 / 40 | 80 / 80 / 80 |
| 240 | 80 / 80 / 80 | 160 / 160 / 160 |
| 480 | 160 / 160 / 160 | 320 / 320 / 320 |

At N=20 the paired design supplies 120 ratings but only 20 independent Persons;
the full panel supplies 180 ratings. Every criterion has 2N versus 3N ratings.
The one-Person rater imbalance at N=20/40 remains in the design record; no extra
Persons are added for divisibility. The full-panel arm has one fixed roster,
the paired arm three. Both preserve connections among all three raters. These
count properties alone do not guarantee identification or covariance quality.

**Exposure extension.** At N=20/60/240/480 and both SDs, extend each truth family
in the paired design from L=1 to L=2: a second independently generated rating
event for every assigned Person-Rater-Criterion cell, with the same ability
and facet truth. This gives 12 ratings per Person while keeping the number of
distinct raters, criterion levels and Persons unchanged. Use an event identity
in the study record even if fitting aggregates counts. It is neither a second
Task facet nor a duplicate of an observed score. The corrected-GPCM owner-total
count is 2,197 per roster; this passes only the known capacity check. Do not
extend the full three-rater panel to L=2 for corrected JML, whose count would
exceed the current limit.

**Six-rater assignment for C.** At two raters per Person, use these five rounds
of disjoint pairs, in the listed order, and repeat the 15-pair cycle as needed:
`(16,25,34); (15,64,23); (14,53,62); (13,42,56); (12,36,45)`.
Take the first N slots and randomize Person assignment independently of ability.
Every complete round adds one Person per rater; an incomplete round changes
rater counts by at most one. At N=20 all 15 pairs appear but ten have only one
Person, so the current corrected-JML fixed-roster covariance is unavailable.
This is retained as a design/output limitation, not repaired by changing the
sampling target. The C specification below supplies the corresponding truths
and task-specific schedules.

**Pairing and data identity.** All methods see exactly the same assigned
responses within a condition. For a fixed N/SD/truth repetition, pair the full
panel and two-rater L=1 conditions using the same Persons and shared responses
on common cells; pair L=2 with its L=1 first events. Any generated potential
responses outside a condition's assignment stay outside the estimator input.
Use independent repetition streams; N, SD and truth families need not share
randomness. Retain paired-repetition identities for roster/exposure differences
and do not count the paired condition records as globally independent datasets.
The development input freeze uses
[`mfrm-wide-map-ab-inputs-20261001.R`](mfrm-wide-map-ab-inputs-20261001.R).
Its 2,100 parent cohorts provide the 5,400 A/B condition records, with 50
replicates in each of 108 conditions. Input preparation does not freeze a fit
procedure or qualify estimator performance. The saved verification record,
not this planned count, establishes preparation completion.

**Completed A/B input freeze.** The generator saved all 2,100 parent bundles
and 5,400 condition views under
`validation-results/mfrm-wide-map-r50-20261001/ab-inputs/`. The `inputs.csv`
registry contains condition/replicate IDs, shared-parent identities, view names,
bundle checksums and observed/extreme-response counts. `rng-registry.rds`
preserves the first 2,100 distinct CMRG unit streams, four named component
substreams, the first unused F substream per parent and the next unused unit
stream. Future blocks must append rather than start again at the master seed.
The original allocation-only registry remains a design snapshot.

`verified-inputs.rds` confirms all 108 x 50 records, 7,335,000 response rows
across the overlapping views, exact prescribed pair/exposure counts, retained
extreme responses and matching shared observations. Every bundle was read back.
The vectorized generator agrees with a separate scalar adjacent-category
recurrence and its log-odds identity within 1.066e-14 on the prespecified grid.
Two edge cohorts (N=20/SD=1/S-GPCM and N=480/SD=.5/S-RSM) regenerate identically
in reversed serial order and with two workers. These are generator/RNG checks,
not estimator or repeated-sampling results. The 5,400 views are not 5,400
independent cohorts; each individual condition has 50 independent replicates.
No A/B fits or F scoring panels have been run. C, D and E inputs and their
generator checks are now complete below, with historical inputs and the earlier
evidence retained. Broad-map fitting and scoring remain pending.

### C: facet structure with explicit workload controls

**Input freeze completed; fitting has not started.** Use N=20/60/240/480 and SD=1
for these contrasts, with the three A/B truth families and their method arms
where supported. The A/B SD=.5/1 comparisons remain; this C block does not
claim that every structure-by-SD interaction has been evaluated. Location,
step and slope values not explicitly changed below inherit A/B. Define task
difficulty t_j through the same predictor, replacing theta by theta-t_j.
The two-family MML route is not a three-facet method arm.

| Comparison | Truth and assignment | Question answered / limit |
| --- | --- | --- |
| Rater levels 3 to 6 | Six severities (-.3,0,.3,-.3,0,.3), preserving the exact empirical distribution of the three-rater truth. Use the specified 15-pair cycle at two raters per Person; separately compare full panels of 3 versus 6 raters. | Paired designs keep 6 ratings per Person while reducing information per rater/changing overlap. Full panels increase ratings from 9 to 18. These are different contrasts, not two estimates of a pure rater-count effect. |
| Add a null Task facet at unchanged workload | Reuse the existing paired L=2 data at these N/SD=1 values. Label the two event replicates Task 1/2, with true task effects (0,0), and the same rater pair across tasks. Compare the existing two-facet fit with a three-facet fit on exactly those ratings. | Measures the cost of estimating an unnecessary facet while holding observations fixed. Re-labelling is valid here because both events were independently generated with the same equation; it does not justify treating real tasks as exchangeable replicates. |
| Represent nonzero Task effects | Two tasks have effects (-.2,.2), with all criteria scored by two raters per task. Compare keeping the rater pair across tasks with the cyclic changing-pair rule below. | Task 1 minus Task 2 has truth -.4. Compare the same-pair arm with the null-Task arm to assess effect recovery, and same versus changing pairs to assess allocation at 12 ratings per Person. |
| Task levels 2 to 4, added ratings | Four effects (-.2,.2,-.2,.2), preserving the empirical difficulty distribution. Every Person receives all four tasks, all three criteria and two raters per task. Evaluate both same and cyclic changing pairs. | Ratings rise from 12 to 24. This estimates the combined effect of more task levels and more information, not a constant-workload complexity effect. Current corrected JML exceeds its 5,000-state limit; keep that exclusion explicit. |
| Task levels 2 to 4, fixed ratings | For four tasks, assign each Person only two adjacent tasks using the cyclic task-pair rule below; use the same rater pair across those tasks. Keep the same four task effects. Compare with the two-task same-pair arm. | Both supply 12 ratings per Person and one -.2/one +.2 task. Changes concern the number of separately estimated tasks and their links. At N=20, fixed-roster corrected-JML covariance is excluded by the roster/rank counts even though its state count is admissible. |
| Criterion levels 3 to 5 | Use the two-task changing-pair arm, K=4, all criteria scored; extend the criterion truths by the moment rules below. Preserve the original three levels and primary contrasts. | Ratings rise from 12 to 20. The contrast combines additional rubric coverage and more parameters; matching truth moments does not hold all response information or parameter associations fixed. |
| Categories K=3/4/5 | Use the original two-facet paired design and fixed locations/slopes. Generate centered steps using the explicit shape rule below. K=4 reuses the A/B data. | Changes the ordinal outcome and number of step parameters at fixed rating count. Report within-ladder probability/parameter recovery and normalized expected score E[Y]/(K-1), not pooled raw score RMSE across different ladders. Equal endpoint step span is not equal information. |

**Task allocation.** Write P1=(R1,R2), P2=(R2,R3), P3=(R3,R1). Starting-group
counts are the A/B pair counts. Same-pair allocation uses P_g for every task;
changing-pair allocation uses `P[1+((g+j-2) mod 3)]` on task j. Both have three
whole-Person roster patterns, so changing partners is not confounded with
changing the number of covariance strata. This restricted cyclic schedule
does not represent every possible task-specific assignment.

For four tasks with two observed per Person, write Q1=(T1,T2), Q2=(T2,T3),
Q3=(T3,T4), Q4=(T4,T1). Before independently randomizing Person labels, slot s
gets `Q[1+((s-1) mod 4)]` and `P[1+((s-1) mod 3)]`. The 12-slot cycle covers
every task-pair/rater-pair combination. All four N values are divisible by four,
so each task is observed on N/2 Persons; rater counts differ by at most one.
At N=20 all 12 fixed roster patterns occur, four as singletons. The corrected
GPCM has p=15, N-G=8 and 2,197 owner-total states. Its full fixed-roster
covariance cannot pass; changing the covariance sampling option is not a fix
for this unchanged design. These are algebraic counts, not fit results.

**Five-criterion truth.** For any centered three-vector x of criterion locations
or log slopes, append `+sqrt(mean(x^2))` and its negative. Thus the original
three entries, mean zero and mean square are preserved; log slopes remain
zero in S-RSM/S-PCM. For S-PCM/S-GPCM, let h=(-.6,0,.6) and D be the three A/B
step rows minus h. Append step rows `h+w` and `h-w`, where
`w=sqrt(.28/18)*(1,-2,1)`. Here .28 is the sum of squared entries of D.
All five rows remain centered, their mean is h, and their mean squared
departure from h is unchanged. S-RSM retains h for every criterion. These
rules preserve stated marginal moments, not the full joint distribution of
difficulty, slope and step shape. No claim of an isolated parameter-count
effect is made from this added-workload comparison.

**Category truth.** For j=1,...,K-1, set `q_j=-1+2*(j-1)/(K-2)`.
S-RSM uses `tau_cj=.6*q_j`. For S-PCM/S-GPCM use
`tau_cj=(.6+u_c)*q_j+v_c*(q_j^2-mean(q^2))`,
with u=(-.1,.25,-.15) and v=(-.3,.15,.15). This reproduces the three declared
K=4 rows, centers each row at every K and keeps the mean row .6*q.
For K=3 the quadratic shape term vanishes, as only one free centered step
coordinate per owner remains. Preserve all declared categories and refusal
records; no category collapse or redraw is used to stabilize the comparison.

**C pairing freeze, before generating its responses.** For each N/SD=1/truth/
replicate, reuse the saved A/B abilities and independent random Person-to-slot
permutation. All ten new C designs share this cohort. A common potential-rating
array has Persons varying fastest, then Rater (1:6), Criterion (1:5), Task/event
(1:4). Its Rater<=3, Criterion<=3, event<=2 uniforms come from the frozen A/B
response substream; verify their scores against the saved A/B observations.
Remaining cells use C's new response substream in array order. Distinct cells
remain conditionally independent within every design. Reuse a cell's uniform
across design/truth modifications only within this declared pairing group;
N and generating-family groups remain separate.

This makes the first two Tasks of four-Task panels, the first three Criteria
of the five-Criterion panel and shared same/changing-pair observations exact
subsets when their response equations agree. Six-rater panels retain the first
three raters' original observations. K=3/5 share assignment and uniforms with
the K=4 control, but have different category probabilities and scores. The
null-Task condition is only a saved-input alias with `Task=Event`, not another
response draw. Four-Task/two-observed allocation keeps its specified cyclic
slots, rather than substituting A/B's blocked pair slots.

C reserves the next 600 unit streams after A/B for these extensions, retaining
an explicit A/B cohort link and fixed component positions. Ability/assignment
positions are reserved but unused because those quantities are inherited;
missingness and future F slots remain unused. This creates 6,000 new condition
records and 600 aliases, not 6,600 new independent cohorts. Every condition
still has 50 independent replicate groups. C's pairing groups also depend on
their A/B controls; reports and Monte Carlo calculations must preserve that
link. No response-based redraw, rebalance or selection is allowed.

**Completed C input freeze.** The
[C generator](mfrm-wide-map-c-inputs-20261001.R) saved all 600 extension bundles
under `validation-results/mfrm-wide-map-r50-20261001/c-inputs/`. They contain
6,000 new condition views (120 conditions x 50); the input registry also maps
600 null-Task aliases (12 conditions x 50) to their original A/B bundle, view
and checksum. The new views contain 16,800,000 response rows, with explicit
shared-cohort identities; none of these counts is a count of additional
independent cohorts. A/B plus C now have 11,400 distinct prepared condition
records, with the 600 C aliases counted only as reuses. D's input completion is
recorded below, followed by E's completion. All broad-map calibration/scoring
work remains pending.

`verified-inputs.rds` records read-back of every bundle, exact shared-response
subsets and reversed-serial/two-worker regeneration of two edge cohorts.
The 132 condition specifications pass additive-location design-rank checks;
these do not establish full GPCM identification. On all 33 N=20 design/truth
combinations, probabilities at theta=-3/0/3 agree with the package's R
probability implementation within 7.772e-16 and a separate scalar recurrence
within 3.331e-16. No optimizer, corrected equation evaluation or numerical
derivative was run. Native corrected-problem construction independently
confirms the N=20 GPCM parameter/state/roster counts and refuses all four
over-capacity designs as specified. Category extrema remain retained.

`verified-registry-links.rds` adds a saved-data audit of all 600 extensions:
literal six-rater and four-Task slot assignments, five-Criterion truth moments,
the direction of paired Task shifts, all 600 exact A/B aliases, and agreement
between the planned method arms and capacity exclusions. The C allocation
remains 23,200 initial calibration slots. The completed-input check verifies
checksums without regenerating responses. `audit-links.R` preserves this audit.

The physical inputs confirm the planned limitations: at N=20 the six-rater
paired design has ten singleton rosters and covariance rank ceiling 5 for 15
GPCM coordinates; four Tasks with two observed has four singletons and ceiling
8 for 15 coordinates. Admitted point attempts remain in scope, while these
fixed-roster covariance exclusions remain explicit. Six-rater full panels,
four-Task full panels (same/changing pairs) and the five-Criterion/two-Task
panel exceed the current corrected-JML state cap at every N. Other methods'
eligibility is retained. Passing a count check is not a covariance or coverage
guarantee; the statistical study is not complete merely because inputs exist.

These are additive two-/three-facet contrasts. One-facet/binary references,
anchors, interactions and further occasion/random-facet structures retain
their own evidence and scope entries; this block does not qualify those
features or silently authorize a new estimation engine.

### D: MML scale, slope families and output decisions

**Input freeze completed; broad fitting has not started.** Compare PCM, one-family
GPCM with slopes on the first owner, one-family GPCM with slopes on the second
owner, and two-family GPCM on the same two-facet data. The second owner owns
steps in every arm; changing step ownership is not part of the slope-family
contrast. The first three arms explicitly estimate a normal mean/variance;
the two-family arm retains its fixed N(0,1) representation. Separate slope/step
ownership is an admitted MML arm, not a new JML capability. These comparisons
assess recovery and the cost of extra parameters, not an automatic model-choice
rule; two-family likelihood ranking remains unavailable.

**A common response scale.** Write the generating adjacent predictor as
`a_i*c_j*(theta-b_i-s_j-tau_jk)`, with geometric mean(a)=1, centered b and
centered step rows, and theta=mu+sigma*z. The equivalent two-family coordinates
are `a_i*=a_i`, `c_j*=sigma*c_j`, `b_i*=b_i/sigma`,
`s_j*=(s_j-mu)/sigma` and `tau_jk*=tau_jk/sigma`. The second owner's locations
are free; centering them again would destroy this identity. This is the existing
normal-population scale identity, not a new numerical result.

For fitted PCM/one-family comparators, evaluate population-relative response
probabilities at `theta=mu_hat+sigma_hat*z`; evaluate the two-family fit at z,
using z=-2,-1,0,1,2 and identical rating contexts/weights. Truth uses the
generating mu/sigma, never the realized sample moments. Location contrasts
divide by the fitted sigma and effective slopes multiply by it when expressing
these comparator estimates on the same population-relative scale. If the
one-family slope owner is the second facet, its relative slopes enter the free
second component; if it is the first, the second component is constant sigma.
For PCM both relative components are one. Raw locations/slopes from differently
identified fits must not be subtracted. These z targets differ from A/B's
fixed canonical-theta targets and from predictions at known absolute ability.
Under omitted slope heterogeneity, report response approximation and declared
parameter discrepancies without calling a misspecified likelihood target true.

| Data family | Generating truths and scope | Reuse and question |
| --- | --- | --- |
| Historical Task x Rater | Three tasks, six raters, K=3; locations (-.4,.1,.3) and six equally spaced values from -.3 to .3; task slopes exp(-.2,0,.2), rater slopes equally spaced from .75 to 1.25; rater step rows (-w,w), w equally spaced from .45 to .7. Normal SD=.5/1, mean 0. Retain full N=20/30/40/60/120/240/480 and the two historical roster types. | Preserve the completed N=240 cases, adverse findings and compatible N=120/480 pilot records. Both varying slope families remain a main condition, not a small-N appendix. |
| Nested slope truths within that family | Let g be the geometric mean of the six original rater slopes. Cross task slopes equal to 1 versus their original values with rater slopes all equal to g versus their original values. Other truths stay fixed. Add the three reduced truths at N=20/60/240/480, SD=.5/1 and both rosters; the fourth truth is the retained full model. | Holding each component's geometric mean fixed makes equality/heterogeneity explicit. The response information can still change. PCM, either one-family route and two-family fitting receive the same data in each cell; a smaller model can be correctly specified in its matching null truth after scale conversion. |
| Rater x Criterion rubric | Use A/B S-PCM and S-GPCM, second owner Criterion, K=4, with their existing full/paired rosters, N range and SDs. Add first-owner Rater slopes exp(-.2,0,.2) to each of these two truths at N=20/60/240/480 and both SDs/rosters. | The two existing truths supply the equal-slope and second-family-only cases without generation. The two additions complete the first-only/both-family comparison on four burden anchors. No new RSM data are needed for this question; its common-step question stays in A. |

In a correctly specified reduced historical truth, the PCM/one-family
normalization absorbs g into abilities, locations and steps, so its population
SD is g*sigma rather than the original sigma. This is a response-preserving
representation change; the population-relative targets above reconcile it.

The historical common-Person design assigns N/5 Persons to all six raters and
the remaining Persons to one rater each; every assigned rater scores all three
tasks. For new N not compatible with the old equal-group generator, allocate
the single-rater Persons by quotient/remainder across the six raters. For the
rotating-pair design use pairs (12,34,56,23,45,61), balanced by quotient/remainder
in that order, and independently randomize Person labels. This preserves N,
keeps Person counts per rater within one, and agrees with the old allocation
counts when divisibility permits. Both rosters have 6N ratings, but the former
has 3 or 18 ratings per Person and the latter has 6. Retained inputs and seeds
are unchanged; the old generator's divisibility checks are not a reason to
round N=20/40 upward. The R=50 input preparation now implements this generalized
allocation; broad fitting remains unstarted.

**D pairing/source freeze before new response generation.** Historical full
conditions use original replicate IDs 1--50: N=240 comes from the original
saved cases behind the matched replay; N=120/480 comes from the prepared core.
Keep each saved data frame, seed and generator identity unchanged. The N=240
four SD/roster conditions share one standardized ability vector and response
uniforms per replicate; N=120/480 retain their separate scenario streams.
Recover latent draws with the recorded original RNG only after exact case/
truth/seed verification; this is deterministic reconstruction, not new evidence
or replacement of the saved responses. Preserve the already documented N=240
generator-file hash mismatch and its exact-data reproduction bridge; do not
invent a cause or claim original-source identity.

For new historical N=20/30/40/60, allocate one CMRG unit per N/replicate. Share
standardized abilities and full Task/Rater potential-response uniforms across
SD=.5/1 and both rosters; independently randomize Persons into each roster's
fixed slots using the assignment substream. Reduced slope truths at
N=20/60/240/480 reuse their matching full-truth abilities, assignment and
uniforms. Only the response equation changes. All methods then use exactly the
same resulting observations within a condition. The older N=120/480 independent
scenario design and the N=240/new-small-N paired design remain labelled;
Monte Carlo comparisons must use their actual pairing groups.

Rubric first-only/both-family truths inherit their A/B S-PCM/S-GPCM parent,
ability, assignment and first-event uniforms. Apply the added Rater slope to
the complete adjacent predictor, retaining the full/paired response subsets.
The original A/B S-PCM/S-GPCM inputs are direct aliases for equal/second-only
controls. These transformations add response views, not independent cohorts.
No outcome-based redraw or success-conditioned input selection is allowed.
Reserve D streams after C's immutable stream head: 200 new historical units,
450 historical-reuse groups and 800 rubric extensions. Inherited draws do not
consume the reserved ability/assignment/response positions; F slots are reserved
but not generated. This is an input/target freeze, not a fit-procedure freeze.

**Completed D input freeze.** The
[D generator](mfrm-wide-map-d-inputs-20261001.R) saved 1,450 parent/extension
bundles under `validation-results/mfrm-wide-map-r50-20261001/d-inputs/`.
`inputs.csv` maps 164 conditions x 50 original replicate IDs: 4,800 new response
views, 600 retained historical inputs and 2,800 exact A/B aliases. The 5,400
distinct D records beyond A/B bring A/B+C+D to **16,800 distinct prepared
condition records**. These are not independent cohort counts or completed fits.
The new historical small-N cells use 200 independent parent cohorts; transformed
historical and rubric truths preserve the pairing specified above. New response
views contain 5,460,000 rating rows. No optimizer, scoring or numerical derivative
was run; D still has 28,600 planned initial calibration slots.

`target-contracts.rds` records canonical truths, fixed-normal coordinates,
estimated-population normalizations and each correctly specified model arm.
`verified-inputs.rds` confirms all saved views, native probability agreement
and scale identities within 7.772e-16, including an analytic nonzero-mean witness
(mu=.7). Reversed serial and two-worker regeneration agree for new historical,
retained-core extension and rubric edge cases. These checks establish response
and representation identities, not statistical performance or identification.

`verified-registry-links.rds` and `audit-links.R` verify all 2,800 literal A/B
aliases, all 200 new historical assignment schedules, retained pairing groups,
model-arm/target contracts and preservation of all original 400 historical cases
and 800 prepared core inputs. The selected 600 inputs pass saved-data,
structural-truth and seed checks. The 208 existing fit candidates pass record
integrity checks; compatibility with the prospective source/output/stopping
procedure is still pending, so no fit slot is removed on that basis.

The N=240 source limitation remains explicit: the original generator file and
latent ability/uniform vectors were not archived. The archived later reproducer
has a different generator hash; its prior 400-case bridge and this turn's
selected-input checks reproduce the saved responses, structural truths and
seeds exactly. That does not establish original-source or original-latent-vector
identity. Reduced-truth extensions use labelled reconstructed draws. F's
calibration-cohort accuracy summaries must likewise label reconstructed-latent
targets rather than present them as independently verified original abilities.
E's mechanism/input preparation is completed below. All broad-map fitting,
scoring and report generation remain pending.

**Current rank gate and its interpretation.** Retain the existing two-family
interval procedure as a named reference. Its observed-Person-score matrix must
have rank p; for the historical design p=22, so N=20 cannot pass. The rubric
design has p=16 and is not excluded on that count alone. At an exact stationary
interior fit the score rows sum to zero, giving rank at most N-1. Neither
increasing quadrature nor relaxing optimization until the rows cease to sum
to zero is a repair. A failure is a current interval-policy exclusion, not
proof that the model's full response distribution is unidentified. Points and
eligible conditional scoring still have separate questions at those N.

The model-Hessian covariance and an empirical outer product of Person scores
are different matrices. An empirical full-parameter sandwich built from those
score rows requires full score rank for a nonsingular covariance; that is not
a general mathematical requirement for inverting a model Hessian. The existing gate is an additional conservative
check of local separation. Any proposed replacement must establish the relevant
model/design information, boundary and numerical checks and evaluate the new
procedure against retained adverse cases before fresh sampling qualification.
No gate is removed now, and an N>p rule is not a small-sample adequacy criterion.

**Public interval consumer priorities.** The matched A/B comparison needs
severity/difficulty contrasts on its canonical centered-facet scale. The
consumer extension, implemented and checked on the branch witnesses below, is
`mfrm_facet_intervals()` for estimated-population RSM/PCM and one-family GPCM
MML. Its covariance must come from inversion of the full joint marginal
information, including population, slopes and steps, followed by the fitted
location expansion and contrast map. A location-only Hessian or independent
printed SEs cannot replace that covariance. Preserve failed-source reasons,
point estimates, scale metadata and saved-report identity. Adaptive/fixed
integration eligibility must follow the chosen source checks explicitly.
This is an experimental consumer, not a validated sampling-coverage claim.

Two-family location/contrast and component-slope intervals already have public
experimental consumers; their coverage needs separate assessment by target.
Population-relative transformed contrasts/curves require a full Jacobian
including estimated mu/sigma and their cross-covariances. Passing an estimated
theta grid as fixed input to the current curve helper omits that transformation
uncertainty. Use those common-scale quantities as point targets until a named
interval procedure exists; their absence does not close the native contrast-CI
work. Effective product, step and two-family curve intervals remain distinct
unimplemented outputs, not automatically supplied by the full covariance.

#### Native MML location-interval extension specification

**October 1 status: implementation, five branch witnesses and saved-output checks
passed; sampling qualification remains open.** The new route in `mfrm_facet_intervals()` and
`core-native-location-inference.R` reuses joint covariance and adds source,
local-solution and same-vector finer-grid qualification. The original three
retained examples passed table/plot/report attachment checks. That focused file
passed 105 expectations; the expanded three-fit replay check passed 30, reusing saved
intervals with covariance and fitting calls blocked. These counts overlap in
the separate-owner replay and are not independent statistical replications.
The first run exposed two errors caused by absent integration-mode metadata in
older fixed-grid RSM fits; the new source guard now follows the existing
`mfrmr_adaptive_integration()` default without editing the saved fit. Malformed
explicit integration modes remain errors. No failures, test errors or unexpected
warnings remained in the affected checks.

| Retained fit | Persons | Integration orders | Native location intervals | Standardized covariance change |
| --- | ---: | --- | ---: | ---: |
| Paired-rating RSM, estimated intercept-only normal population | 100 | Fixed 61 versus 121 | 2/2 | 2.257493e-12 |
| GPCM, shared Rater slope/step owner, estimated normal population | 40 | Fixed 61 versus 121 | 3/3 | 2.678870e-6 |
| GPCM, Criterion slope/Rater step owners, estimated normal population | 120 | Adaptive 31 versus 61 | 3/3 | 6.495345e-10 |
| PCM, estimated intercept-only normal population; saved Rater 3 x Criterion 2, K=3 | 120 | Fixed 31 versus 61 | 3/3 | 1.424988e-4 |
| GPCM, fixed N(0,1); A/B Rater 3 x Criterion 3, K=4, full-panel SD=1 replicate 1 | 60 | Fixed 31 versus 61 | 3/3 | 7.558765e-3 |

The two additional branch checks are in
`validation-results/native-location-branches-20261001/`. PCM reuses the saved
`gpcm-separated-owners-20260926/fit/pcm.rds` result. The fixed-normal GPCM witness
was selected before fitting from prepared A/B data and required one new q=31
fit, with the prespecified public initialization/BFGS/maxit=400/reltol=1e-9
controls. No new calibration data or automatic higher-q fit was generated.
The first interval call exposed a source-check bug: public fixed-normal fits
use `posterior_basis="legacy_mml"`, whereas the consumer expected an incompatible
label. The repair accepts the actual label together with explicit fixed-normal
identification and inactive population metadata. Altered population/identification
records still fail before information evaluation. All subsequent interval checks
use the unchanged fit; the initial error remains saved.

The current focused file passes 180 expectations, including covariance maps,
the two added branches, inconsistent-source refusals and all five saved
plot/report/export replays with fitting/covariance recomputation blocked.
These replace, rather than add independent replications to, earlier test counts.
The fixed-normal witness has scaled gradient 7.815e-6 and finer-grid score
displacement .005920; both it and the retained PCM pass the original tolerances.
Help, the output guide and NEWS now describe the implemented native model-only
scope. The fixed-normal fixture is retained for regression tests. This one fit
is not automatically booked as a completed broad-map job: procedure/source and
output selection must still be matched by the execution runner.

Interval calculation left fitted parameters and global readiness unchanged. The RSM
contrast covariance agrees with its existing independent continuous-information
reference at the test tolerance of 1e-5. Fixed/redundant contrasts, source
mismatches, finer-grid nonfinite/unstable covariance, and the retained-matrix
memory budget were checked. The single-rating nonidentification example refuses
intervals before Hessian evaluation and preserves its points. These are bounded
numerical/software checks, not repeated-sampling or general small-N coverage.

The retained results, original failure report, passing checks, source hashes and
session are in
`validation-results/native-location-20261001/focused-tests.rds`.
That earlier three-fit check used no new estimation or data generation. The
additional checks above close the missing intercept-only PCM and fixed-normal
one-family GPCM branch witnesses. Other untested combinations and general
finite-sample adequacy remain open; neither software tests nor experimental
help wording establish them.

The
user question is whether a fitted rater/criterion location or a difference
between two levels of the same facet is precise enough to interpret. This is
not a difference between different facets, a rater-quality test, or a comparison
of raters' complete response curves. It supplies A/B's native structural target;
D's population-relative transformations have a separate interval target.

**Source audit that defined the implementation boundary.**

| Component | Finding before this extension | Required change or reuse |
| --- | --- | --- |
| Public admission | `R/api-facet-intervals.R::mfrm_facet_intervals()` rejects active-population RSM/PCM, all one-family GPCM, and ordinary adaptive fits before calculating a target. | Extend admission only for the new declared scope below; deleting the guards alone is insufficient. Preserve the current fixed-N(0,1) ordinary and experimental two-family procedure identities. |
| Full covariance | `R/mfrm_core.R::compute_mml_parameter_covariance()` differentiates the full marginal objective, with an adaptive evaluator when requested. `build_param_sizes()` includes population beta and log_sigma2, as well as slopes, steps and facet coordinates. | Reuse the complete unregularized inverse and existing memory/refinement controls; do not implement a separate location-only Hessian or suppress nuisance coordinates. |
| Target transformation | `mfrm_facet_contrasts()` already aligns named coefficients, expands the fitted constraints and identifies fixed native targets. | Reuse for native locations/contrasts, with a full-parameter target Jacobian and stored target identity. No new scale argument in this first extension. |
| Local qualification | `mfrm_ic_fit_check()` rechecks likelihood/gradient/information for active-population or GPCM fits; the one-family slope check additionally verifies slope coordinates/tables. Neither alone establishes finer-grid stability of location covariance. | Reuse the applicable checks with their thresholds and source identities, adding the explicit covariance quadrature review below. Do not relabel an IC or scoring check as a validated location interval. |
| Sandwich scores | `mfrm_person_likelihood_scores()` assembles ordinary facet/interaction/step scores only. `mfrm_mml_person_scores_numeric()` differentiates the complete Person marginal log likelihood; `mfrm_cluster_sandwich()` aggregates those vectors. | The ordinary analytic shortcut cannot simply be enabled for new population/slope parameters. The complete numeric path is a candidate for a later sandwich extension, subject to derivative and sampling-law checks. |
| Saved GPCM results | `R/api-gpcm-reporting.R` currently admits `mfrm_facet_intervals` only for two-family fits and checks `settings$two_family`. | Admit the new one-family location result by its explicit procedure/source identity; extend table dispatch and retain the same saved plot/report/export workflow. RSM/PCM already have a facet-result attachment path. |

The first added procedure is **experimental native-scale, pointwise
model-information inference**, using the existing function/class and
`method="model"`. Added scope: direct MML, fixed or adaptive integration,
unit weights, additive non-Person facets with their centered constraints, no
anchors/interactions; estimated intercept-only normal RSM/PCM, and one-family
GPCM with fixed N(0,1) or estimated intercept-only normal population and shared
or separate slope/step owners. This covers the missing A/B and D native
comparators. Preserve slope GM1 constraints and the original population choice.
Tests of regression-population information are retained below, but latent-
regression consumers, anchors, interactions and non-unit weights in these new
routes need separately declared extensions; they are not removed from the
package's existing model scope. The already supported ordinary fixed-population
route, including its anchors/interactions and sandwich option, is unchanged.

For the new scope, a requested sandwich method must be explicitly unavailable,
not silently changed to model covariance. Model misspecification in E remains
a reason to study failures of model intervals, not to label them robust.
There is no new ordinary/corrected-JML interval, population-coefficient/SD
interval, joint test, equivalence decision, profile or multiplicity procedure.
Passing this consumer's local checks does not promote the fit's global
`InferenceReady` flag or settle incomplete identification/boundary audits.

**Native target and nuisance uncertainty.** Let psi contain every fitted free
coordinate, b_f(psi) the constrained location vector of the selected facet,
C the requested coefficient matrix, and d=C b_f(psi). With the complete
observed negative-log-likelihood Hessian H and V=H^{-1}, use
`Var(d_hat) = J_d V J_d'`. The native J_d has C times the facet expansion in
the facet columns and zeros elsewhere; nevertheless its covariance includes
population/slope/step estimation through the full inverse. In particular, for
location coordinates gamma and nuisance coordinates eta, the location block
is `(H_gg - H_ge H_ee^{-1} H_eg)^{-1}`, not `H_gg^{-1}`. This is the block-inverse
identity, not a new numerical result or a finite-sample coverage argument.
Report native ability units before multiplication by slopes. With unequal
slopes or steps, a location difference need not produce a uniform expected-
rating difference. Normal bounds are d_hat +/- z * SE on this native scale.

**Numerical contract for the added procedure.** Preserve the current source
likelihood, category-support, finite-parameter, optimizer, unregularized full-
information and weak-information refinement checks, including the existing
minimum integration tier. Reject inconsistent expanded location/step/slope
tables or population coding before presenting their points. Known exact ridges
or boundary certificates cannot be overridden by a tiny positive numerical
eigenvalue. For GPCM, retain its slope-identity checks even for a location target.
After the applicable local solution checks pass:

- At the retained parameter vector, calculate H_q and V_q, its objective and
  gradient g_q, then the same quantities at q_plus=2q-1 with the same integration
  method. Both full inverses must be finite, positive-definite and unregularized.
  Do not move the parameter vector, refit, replace the saved fit's grid or use
  a covariance from a different optimum. Reuse these two evaluations across
  all requested contrast rows. Account for simultaneously retained matrices
  within the existing information-workspace budget before allocating them;
  do not bypass that budget or create a second per-target differentiation loop.
- Adopt the existing two-family *numerical comparison* measures: require
  `sqrt(g_q' V_q g_q) <= .01`, retain a warning above 1e-4, and require inverse
  residual `norm(H V - I, "I") <= 1e-6` at both orders. The applicable existing absolute
  full-gradient check must also pass; the .01 bound does not replace it.
- With `R_q=chol(H_q)`, require standardized grid score displacement
  `sqrt((g_plus-g_q)' V_q (g_plus-g_q)) <= .01` and full covariance change
  `norm(R_q (V_plus-V_q) R_q', "2") <= .01`. Record both grid orders, all
  comparisons and failed checks. These adopted tolerances define a proposed
  numerical procedure; they are not calibrated coverage thresholds and the
  two-family sampling evidence does not transfer to it.
- Keep the coarse-stage covariance/point when the checks pass. A finite pure
  quadrature-comparison failure can trigger the previously declared study
  q=31/61/121 refinement policy. Nonfinite fine-grid evaluation, failed local
  information, a known ridge or another failed check is not a generic retry.
  q=121 may use q_plus=241 for evaluation only. The public interval consumer
  itself never runs this refitting ladder.

Do **not** add an empirical Person-score full-rank requirement to this new
model-Hessian procedure or copy the current two-family N>p gate. An observed
Hessian is not an outer product of observed Person scores. This design choice
does not weaken the existing two-family reference or establish small-N coverage;
its empirical rank gate remains unchanged and separately reviewable. If a
future model-Hessian procedure is adopted there, give it a new identity and
evaluate it against the retained adverse records.

**Failure and saved-result contract.** Bad arguments, unsupported scope or
inconsistent source metadata are errors. For a valid source within the new
scope, a failed numerical check returns the matching finite native point with
unavailable SE/bounds, `CIEligible=FALSE` and a specific reason. Constraint-fixed
native targets retain their exact value and zero variance but no inferential
bounds; they are excluded from coverage denominators and reported as fixed.
A model interval is available only with finite positive target variance and
finite bounds. A singular covariance across redundant contrast rows does not
invalidate individually estimable pointwise rows; no joint Wald statistic is
calculated. Retain full and target covariances, C/J_d, population/owner/scale
metadata, source signature, numerical checks, cautions and procedure identity.
Existing English plots/report/export must show the scale, experimental status
and unavailable points without recomputation. Native and standardized results
must never share an ambiguous label or be attached to a different source stage.

**Why D's standardized interval is a separate extension.** For a within-facet
zero-sum contrast d and lambda=log(sigma^2), its population-relative target is
`t=d/sigma=d*exp(-lambda/2)`. Its full derivative is J_d/sigma in the structural
columns and `-t/2` in the log_sigma2 column, giving
`Var(t_hat) ~= [Var(d_hat) + d^2 Var(lambda_hat)/4 - d Cov(d_hat,lambda_hat)] / sigma^2`.
This derivative follows from the declared scale map; it has not been evaluated.
The population mean cancels for a zero-sum difference. An individual location
may additionally require the role-specific mean shift, so an arbitrary row of
C cannot be standardized as if it were a difference. Dividing native CI bounds
by sigma_hat omits variance and cross-covariance terms. This first extension
therefore returns native intervals only; D retains standardized point targets
until its own full transformation/interval consumer is qualified. That later
consumer must also determine fixed targets from the complete transformed
Jacobian: a fixed nonzero native contrast divided by an estimated SD is no
longer fixed.

**Sandwich follow-up and sampling law.** The generic clustered construction
first sums estimating functions within the independent cluster, then forms
outer products, as specified in the primary
[sandwich documentation](https://sandwich.r-forge.r-project.org/reference/vcovCL.html).
That establishes the aggregation rule, not this package's adequacy at N=20.
For a new consumer, verify derivatives for every free coordinate and the
declared independent sampling unit. Under fixed roster counts and a
misspecified working model, roster-specific mean scores can be nonzero even
when their total is zero; an uncentered outer product then includes a
between-roster mean component absent from conditional sampling variation.
This is a consequence of the sampling-law decomposition, not a newly observed
software failure. Thus A/B's fixed counts, E's iid random rosters and larger
independent clusters require explicit covariance targets; switching a method
label or applying G/(G-1) cannot settle them. Keep this issue for the sandwich
extension instead of enabling an unjustified robust claim now.

**Evidence reuse and acceptance after the hold.** The
[independent RSM/PCM information fixtures](mml-independent-information-conditions-record-0.2.4.md)
already address full covariance, constraint maps and pair-contrast SEs across
13 numerical examples. The
[population full-information review](population-full-information-record-0.2.4.md)
retains positive-information examples and the single-rating exact-ridge control,
including same-vector grid comparisons. These records support the underlying
calculations in their exact scope; regression fixtures do not constitute
completed public-consumer checks or repeated-sampling coverage. Reuse them and
the existing one-family inference/interval-reporting fixtures before new data.
Required affected checks are: native contrast variance against an explicit
full-coordinate map; both owner arrangements and population options; fixed
versus adaptive qualification at retained points; exact-ridge/weak-information/
fine-grid refusal with points preserved; constrained or redundant targets;
and save/reload/plot/report/export with fitting/covariance calls blocked during
replay. Only add a numerical fixture for a missing supported branch. No blanket
rerun of completed studies or new Monte Carlo sample solely to test serialization.
With implementation and the branch/replay checks complete, freeze the consumer
with the selected execution procedure and include its
availability/coverage in the existing A/B allocation; independent precise
confirmation still needs its own claim and repetition budget. Help/NEWS describe
the implemented experimental scope, with sampling coverage explicitly unqualified.

### E: robustness mechanisms and matched controls

**Input freeze completed; broad fitting has not started.**

Use N=20/60/240/480, SD=1 and all three A/B truth families for the elementary
profiles below. The new default here is **iid random assignment**: each Person
independently receives one of the three rater pairs with probability 1/3,
independently of theta unless specified otherwise. Include this unperturbed
random-roster control; do not substitute the A/B fixed-count result. Every
method sees the same data. Prespecify `random_rosters` for corrected JML in
these iid-Person experiments, because assignment/missingness are regenerated
with Persons, not to bypass a covariance failure seen after fitting.

| Profile | Generating mechanism and its control | Interpretation |
| --- | --- | --- |
| E0: random-roster control | Normal theta and the iid uniform three-pair assignment above, with complete assigned ratings. | Separates changing the assignment-sampling scheme from adding a robustness perturbation. Counts need not be balanced in each sample; retain draws with absent facet levels or weak links. |
| E1: population shape | Right skew: theta=Exp(1)-1; left skew: theta=1-Exp(1); mixture: theta=.8*S+.6*Z, where P(S=-1)=P(S=1)=.5 and Z is independent standard normal. | Each population has mean 0 and variance 1, matching E0. Shape changes are not disguised changes of mean/SD, and samples are not standardized after drawing. Normal-MML is deliberately misspecified in these cases. |
| E2: poor targeting | Normal theta with mean -2.5 or +2.5 and SD=1; structural parameters unchanged. | The primary free-population MML family still contains the true population. Sparse categories and extreme responses here are information/targeting challenges, not normal-shape misspecification. |
| E3: sparse interior category | For S-PCM/S-GPCM replace Criterion 2's steps with (1.5,-1.5,0); for S-RSM use that common row for all criteria. | A centered but disordered step vector is a valid response model; low use of an interior category may trigger the current declared-ladder refusal. The profile does not force a particular observed frequency. |
| E4: unequal allocation | Independently sample pairs 12/23/31 with probabilities .6/.3/.1, independent of ability. | Two raters and six ratings per Person remain fixed; expected information per rater becomes unequal. Compare with E0. |
| E5: ability-associated allocation | With normal theta, let z=theta and pair probabilities be `1/3+.25*tanh(z)`, `1/3`, `1/3-.25*tanh(z)`. | Probabilities are positive and sum to one; symmetry preserves marginal pair probabilities 1/3. This changes ability-assignment association without introducing marginal allocation imbalance in expectation. Do not assume a common unconditional normal population remains the correct likelihood conditional on the observed roster. |
| E6: independent missing scores | Delete each assigned score independently with probability .15 or .30. | Planned assignment is unchanged. Distinguish missing assigned scores from ratings never assigned; retain originally planned N and the actual observed exposure. |
| E7: rater-dependent missing scores | Deletion probabilities .05/.15/.25 for R1/R2/R3, independent of scores/ability given rater. Compare with E6 at .15. | Under uniform assignment the expected missing fraction is .15 in both cases; this isolates redistribution of missingness toward particular observed raters. |
| E8: score-dependent missingness and matched-rate control | Delete a generated score y with probabilities q_y=(.05,.10,.20,.35) for y=0,1,2,3. The control deletes independently with constant q_bar equal to the expected score-dependent deletion rate under the same generating truth. | Use the model-defined rates computed below, averaged over planned cells/population, before sampling; do not estimate them from each generated sample. This compares mechanisms at equal expected missing rates, not an arbitrary MNAR case against 15% MCAR. |
| E9: within-performance dependence | Use the two-task nonzero-effect same-pair design, iid uniform rater-pair assignment, and the normal-copula rule below at rho=0/.25/.5. | The rho=0 control has the same design and exact conditional category marginals. Changing rho alters conditional dependence, not the marginal response equation or ability variance. |
| E10: weak links | Six raters with duplicated A/B severities. Each Person gets one pair: with probability b choose uniformly among nine between-group pairs linking {1,2,3} to {4,5,6}; otherwise uniformly among six within-group pairs. Compare b=.6/.2/.05. | b=.6 is uniform over all 15 pairs. Every b preserves expected Persons per rater N/3 and six ratings per Person, while changing links. Do not redraw until a bridge occurs; its absence has probability (1-b)^N. |

**Matched missingness rates, computed during the R=50 preparation.** For each
truth and population shape, average `sum_y q_y P(y | theta,r,c)` equally over
the nine rater/criterion cells, then integrate over the generating population.
Uniform random pair assignment gives each cell expected response weight 1/9.
These population expectations do not depend on N or the realized response data.

| Truth | Normal N(0,1) q_bar | Right-skew Exp(1)-1 q_bar |
| --- | ---: | ---: |
| S-RSM | .175211795507 | .167000023758 |
| S-PCM | .175443128394 | .167160258004 |
| S-GPCM | .174217285296 | .166078124575 |

The [rate calculation](mfrm-missingness-control-rates-20261001.R) evaluates both
a density-weighted ability integral and a uniform-quantile integral, with
absolute/relative integration tolerances 1e-10 and coordinate-agreement
tolerance 1e-8. All six pairs agree, maximum difference 7.444046e-14;
reported quadrature error estimates are at most 5.246156e-11. Both paths use
the same literal response-probability equation, so this is an integration
check, not an independent generator or fitted-method validation. Use the full
saved precision from `validation-results/mfrm-missingness-control-rates-20261001/verified-rates.rds`
in generation. This resolves the previously unevaluated control rate; no
simulated responses, deletion draws or fitted models were produced by that
rate calculation. The subsequent E input freeze below completes the generator's
assigned/observed-row accounting and paired-control checks.

The b=0 boundary is a separate algebraic/capability case, not another large
Monte Carlo cell. There is no design-based link between rater-group locations
under freely estimated JML Persons; within-group contrasts may still exist.
A common-population MML analysis can introduce a link through its population
assumption, which is different evidence from shared Persons. Preserve this
distinction in interpretation and reuse retained identification checks before
requesting any new boundary calculation.

**Dependence without changing the marginals.** For each Person-task, draw a
shared standard normal Z_it and independent standard normals e_itrc; all are
independent of theta and other Persons/tasks. Set
`U_itrc=Phi(sqrt(rho)*Z_it + sqrt(1-rho)*e_itrc)` and use U to invert the
declared categorical CDF for that rating. Each U is marginally uniform, so
P(Y=k | theta, task, rater, criterion) remains exactly the specified PCM/GPCM
or RSM probability. rho is a latent normal correlation, not an observed-score
ICC. Shared dependence is within a performance across raters/criteria;
Persons remain the independent sampling units. This controlled mechanism
does not represent every additive testlet effect or real rater dependency.

**Missingness accounting and covariance.** Keep a planned-assignment record
and a separate observed-score record. Record Persons with zero observed
ratings, lost facet levels, category support and N actually entering the fit;
do not remove their datasets from delivery denominators. Random-roster
covariance describes the selected estimating equation and observed-Person
sampling target, not removal of informative-assignment/missingness bias.
The relation between inference conditional on contributing Persons and the
original planned cohort remains part of any proposed interval claim. A future
study with fixed planned-stratum counts and random within-stratum missingness
would need its own covariance contract; it cannot inherit this iid design by
merely changing the sampling option.

**Selected joint adverse cases, not a full stress-factor crossing.** At N=20
and 480, for every truth family use the following complete 2-by-2 comparisons:

- Population shape (normal/right skew) by missingness mechanism (score-dependent
  q_y/matched-rate independent q_bar). Normal cells reuse E8; the two right-skew
  cells are new. Use the separately computed *model-defined* q_bar for each
  shape in the table above. This is an interaction of two declared mechanisms, not proof of
  arbitrary combined robustness.
- At the same two-task/six-rater design, crossing link probability b=.6/.05
  with rho=0/.5. Keep two raters per Person across tasks, all three criteria,
  SD=1 and the same task effects. All four cells are required: E9's three-rater
  and E10's single-performance controls are not substitutes for this design.

No result in E automatically qualifies an interval, a feedback rule or model
selection. Report recovery relative to the declared structural/Person targets,
response calibration, output availability and limitations together. Under
misspecification, a fitted likelihood parameter or local equation root need
not equal a generating parameter; those different targets must remain named.

**E input pairing and generation freeze.** Reserve 600 new CMRG units after D
(N=20/60/240/480 x three truths x 50 replicates), independent of the A/B cohorts.
Within each N/truth/replicate, share the primitive ability, assignment, response
and deletion draws across E's named comparisons. This gives 20 elementary views
per unit, plus six joint-adverse views at N=20/480: 13,800 condition records,
not 13,800 independent cohorts. Every generating condition still has 50
independent replicate groups. Do not reinterpret E0 as an A/B fixed-count alias.

Draw one ability uniform U per Person: normal theta=qnorm(U), right-skew
theta=-log(1-U)-1, left-skew theta=1+log(U); the mixture uses .6*qnorm(U) plus
an independent equiprobable -.8/+.8 sign. Targeting adds +/-2.5 to the normal
draw. These are population transformations, never sample standardization.
Use the same independent assignment uniform for the three-pair CDF under
uniform, unequal or ability-dependent probabilities. For six-rater links,
another assignment uniform selects between/within group at probability b;
the first selects uniformly within the chosen list. Within-group pairs are
12/13/23/45/46/56 and between-group pairs are
14/24/34/15/25/35/16/26/36. All b values share those primitives; bridge sets
are nested, while expected per-rater exposure stays equal.

Generate potential-response uniforms in Person/Rater/Criterion/Task order,
Person fastest, on a six-rater, three-criterion, two-task grid. Single-performance
views use the first-event cells with no Task effect; two-task views apply
(-.2,.2) inside the slope-multiplied predictor. For copula views use the normal
quantiles of these uniforms as the independent errors and separately drawn
Person-by-Task shared normals. rho=0 uses the original uniforms exactly;
rho=.25/.5 use the specified copula transformation. The same pair is retained
across both tasks. Sharing primitives with single-performance controls does
not make their different marginal response equations identical.

The missingness substream supplies a separate uniform for every potential
cell. E6--E8 share the complete E0 responses and assignment; their masks change
only the declared deletion probability. Right-skew joint missingness reuses
the complete E1-right-skew responses, with its own saved model-defined rate.
E8's normal cells are referenced in the joint comparison rather than generated
again. Store complete planned ratings, deletion probabilities/masks and a clean
observed-score input separately; latent deleted scores must never enter a fit.
Keep the planned Person roster, zero-observation Persons, lost levels and
empty categories in accounting. All methods use the identical observed input.
F substreams are reserved but no F panels or model fits are generated here.

**Completed E input freeze.** The
[E generator](mfrm-wide-map-e-inputs-20261001.R) saved all 600 parent bundles and
13,800 views (276 conditions x 50) under
`validation-results/mfrm-wide-map-r50-20261001/e-inputs/`. Each registry row
identifies the clean observed-score input, paired cohort, planned and observed
Persons/ratings, deletion count, zero-observation Persons, lost levels, category
support, bridge count and mechanism/control. Planned latent responses are
separate from fitting inputs. The views contain 21,060,000 planned ratings,
20,226,927 observed ratings and 833,073 missing assigned ratings; these are
overlapping-view counts, not independent response or Person counts.

The generator's probabilities agree with native PCM/GPCM kernels and a separate
adjacent-category recurrence within 8.882e-16. Ten normal-copula marginal-CDF
integrals at rho=.25/.5 agree with the intended marginal probabilities within
6.662e-16. The ability-dependent assignment's integrated marginal probability
is 1/3; six-rater pair enumeration preserves expected exposure at every b.
These checks concern the specified mechanism, not the fitted working model's
validity. An explicit all-missing accounting fixture retains the planned cohort
and lost levels without inventing observed scores. Reversed serial/two-worker
regeneration is identical for N=20/60/480 GPCM examples.

`audit-links.R` independently verifies all saved complete responses by adjacent
ratios, all primitive RNG draws, literal assignment laws, deletion thresholds,
observed subsets, model/facet allocation and matched controls, without calling
the E generator or fitting functions. `verified-registry-links.rds` records the
passing checks and `mechanism-accounting.csv` their per-record accounting.
Its first run stopped on the left-skew quantile check: subtracting a very small
U from 1 lost precision (maximum discrepancy 4.156e-11 across all parents).
Using the exponential upper-tail quantile directly matches all saved abilities
exactly; `audit-check-correction.rds` retains the correction. No generated input
or random draw changed. The completed-input rerun checks hashes without
regeneration. The A-D/E unit streams are disjoint, and the RNG head now follows E.

All original replicate IDs remain. Ninety condition records contain at least
one zero-observation Person. No facet level disappears in these particular
draws; empty categories do occur. For N=20 and b=.05, E10 has no between-group
Person in 17/50 S-RSM, 21/50 S-PCM and 17/50 S-GPCM records. Their paired joint
views reuse the same assignments, not additional independent realizations.
These records are preserved for delivery/identification assessment, not labelled
solver failures before fitting. No dataset is redrawn or removed for support.

This completes **A-E's 612 unique conditions x 50 = 30,600 input records**:
30,000 new views and 600 retained historical inputs, with 3,400 C/D aliases
counted only as reuses. It does not complete the 135,800 planned initial
calibration slots (55,200 in E), F scoring, model comparisons, figures or final
report. No E fitting, scoring or numerical differentiation was run. Required
consumer/source/output and execution-resource checks remain before broad fitting.

### F: Person scoring, future cohorts and saved reuse

**Purpose and scope.** Determine whether an admitted calibration produces
useful Person scores, which priors/scales those scores refer to, and whether
the supported saved workflow preserves them. Reuse A-E calibrations; F does
not create a separate calibration-study grid. The original design/source review
performed no scoring. The October 2 execution below first connects retained
A/B calibrations to these panels; other families remain pending. The source
contracts are `predict_mfrm_units()` in `R/api-prediction.R`,
`mfrm_calibration_capabilities()` in `R/api-calibration.R`, and the source,
event and scoring checks in `R/core-fixed-calibration.R`.

| Scoring target | Procedure and scale | Interpretation / comparison |
| --- | --- | --- |
| Native calibration-cohort scores | Retain each fit's existing Person output: MML posterior scoring, ordinary-JML Person estimates and corrected-JML profiles conditional on its adjusted calibration. Preserve the recorded algorithm and finite/boundary/unavailable status. | These Persons helped estimate calibration. Native outputs answer different estimation questions; they are not held-out accuracy or a common EAP comparison. Infinite Person estimates are not clipped, and a corrected structural fit does not imply bias-corrected Person ML. Do not manufacture interval bounds from a printed SE/SD. |
| Common-prior scoring in A/B/C/E | Re-score the same supplied response rows under each admitted calibration through `predict_mfrm_units()`, explicitly `scoring_prior=list(mean=0, sd=1)`. Keep training-cohort re-scoring separate from independent Persons. Use the canonical theta scale. | Holds the scoring prior/rule fixed to compare the effect of estimated calibration. N(0,1) is a prespecified reference even when the generating SD is .5, the population is shifted or nonnormal. It is neither an estimated JML population nor a known-correct prior in every condition. |
| Retained-prior workflow | Separately use `scoring_prior=NULL`: estimated intercept-only normal for the corresponding MML fits, reference N(0,1) for JML, and fixed N(0,1) for two-family MML. | Assesses the current fitted-model workflow, including population estimation. Compare paired scores with the common-prior arm where supported. Identical JML priors can reuse results while retaining both arm labels; they are not independent scoring replications. |
| D population-relative scoring | Use each MML fit's retained prior. Transform estimated-population scores and bounds by `(value-mu_hat)/sigma_hat`, and SD by division by sigma_hat; two-family scores already use z. Truth is `(theta-mu)/sigma` from the generating population. | This compares the same population-relative latent target using D's response-preserving scale map. The plug-in transformation does not add uncertainty in mu/sigma. A canonical N(0,1) override on a one-family fit is not a common z prior, and the two-family API rejects prior overrides. |

Overlapping Person labels in `new_data` do not update or link a training Person:
the API scores the supplied rows under frozen calibration. Use distinct IDs for
independent cohorts and store cohort identity outside the fit. The scorer sees
responses and declared IDs/design only, never true abilities or population
moments used for evaluation. Do not change `fit$population` or add artificial
facets to force a common prior or an unsupported scoring design.

**Independent scoring panels.** Use separate random streams for calibration,
held-out abilities, assignments, responses and missingness. Within a condition
and calibration replicate, all estimators/priors receive exactly the same
panels, including planned Persons with no observed responses. Generate panels
independently for different calibration replicates. The following panel sizes
are a scoring workload specification, not a calibration N or a precision claim:

| Panel | Prespecified sample and assignments | Question / pooling rule |
| --- | --- | --- |
| F-pop: same-population scoring | M=60 new Persons per calibration record, drawn from that condition's generating population. In A-D use nominal balanced roster proportions: full panels, equal three-/six-/15-pair cycles, or the 12-combination Task/rater schedule as applicable; the historical common-Person design has 12 all-rater Persons and eight single-rater Persons per rater. Repeated events retain their declared independent-event identity. E instead regenerates its stated random/informative assignment, dependence and missingness mechanisms. | Estimates per-Person error and delivery in the declared future population. Sixty permits exact nominal allocations for these fixed schedules without changing M across calibration N. Do not inherit accidental small-N count imbalances or replace the design with only contexts that survived fitting. The difference between fixed planned allocation and E's random allocation remains explicit. |
| F-exposure: calibration versus individual scoring information | For the A/B paired L=1/2 comparison at N=20/60/240/480, both SDs and all three truths, cross calibration L=1/2 with scoring L=1/2. Use one M=60 held-out cohort and its two independent events per assigned cell; L=1 uses the first event. Share this panel between the paired calibration conditions within each replicate. | The diagonal cells are F-pop; the two off-diagonal scoring calls isolate better calibration from giving each new Person more responses. No new calibration fits are required. Compare these cells with their shared-replicate dependence retained; do not attribute the entire diagonal improvement to calibration quality. |
| F-grid: ability-specific scoring | At calibration N=20/60/240/480, use 30 new Persons at each of five fixed values: canonical theta=-2,-1,0,1,2 for the original A/B two-facet L=1 baselines; z=-2,-1,0,1,2 for D's historical full two-family truth and the rubric both-family truth. Retain the selected condition's SD and roster variants. Thirty permits exact three-/six-pair and historical common-Person allocations within each grid value. | Complements the possibly sparse tails in F-pop. These are five distinct fixed-ability experiments, not a sample from the population. Report them separately; do not average them with equal weights and call the result population RMSE or nominal posterior coverage. C/E and all D null truths are not automatically multiplied into this panel. |
| F-shift: changed future cohort | For the original A/B paired L=1, SD=1 conditions at N=20/60/240/480, reuse each calibration and score M=60 under theta distributed as N(.75,1) and N(0,.5^2). The N(0,1) panel is F-pop. Structural parameters and assignments remain fixed. | Isolates transfer to a shifted mean or narrower population without refitting calibration. Use only the already specified retained/reference priors, not the known new generating distribution. This differs from E's changes to the calibration population; it does not establish arbitrary population transport or two-family shift robustness. |

F-pop is the primary population scoring panel. F-exposure, F-grid and F-shift are
specified targeted contrasts; they are not reasons to refit the calibration or apply every
stress factor to every scoring panel. Any future use of newly estimated cohort
priors is a different procedure. These sizes leave final Monte Carlo precision
dependent on the number and variability of independent calibration replicates;
more scored Persons cannot replace missing calibration replications.
Increasing calibration N at fixed scoring exposure can reduce calibration
error without eliminating limited-information error in individual scores.
For C's other workload changes, F-pop reflects the combined calibration and
future-rating design; do not claim that it isolates calibration precision.

**Scoring calls, refusal and numerical controls.** Use `interval_level=.95`,
`n_draws=0` and `readiness_policy="error"` for the primary fitted-object route.
Start at `scoring_quad_points=31`. A batch EAP/SD integration-check failure
may receive the prespecified 61 then 121 scoring-node retries on exactly the
same calibration, rows and prior; stop at the first passing order. Record
default-31 delivery separately from delivery under this refinement procedure.
Do not refit calibration, alter source tolerances, retry a failed source check
with more scoring nodes, or enable `"review"` and count it as qualified output.
Malformed inputs, unsupported designs and nonfinite computations retain their
own refusal reasons. A different rescue policy defines a different procedure.

Each F-pop/F-shift cohort is one fixed 60-Person scoring batch; each F-grid
ability value is one fixed 30-Person batch. Preserve the actual API behavior if
one Person's failure rejects a whole batch. No adaptive subdivision to rescue
the primary result. A later diagnostic per-Person call cannot replace that
record. Missing assigned scores are represented in the scoring input and its
planned-ID ledger; scoring may omit them, but no artificial prior-only score is
added for a Person with zero usable ratings. Unknown levels in a future panel
stay unknown even if they were planned in calibration: a level lost during
calibration is an output limitation, not permission to drop those Persons.

Training-source boundary checks can refuse post-hoc JML scoring even when
finite facet estimates were printed. Conversely, lack of corrected-JML
RootSE or failure of the two-family structural interval rank gate does not
alone exclude a calibration from its separate point-scoring checks. Classify
source admission, batch computation, per-Person score delivery and interval
delivery separately. Naturally occurring all-low/all-high response patterns
remain in their original denominators; deterministic extreme-pattern fixtures
are engineering checks, not additional draws in a coverage study.

**Error, interval inclusion and Monte Carlo uncertainty.** For each calibration
replicate retain planned count M; delivered-score and delivered-interval counts;
signed error and squared-error sums; interval widths and truth-inclusion counts;
and paired errors on common returned Persons. Report bias/RMSE conditional on
returned scores alongside score availability over all planned Persons. Report
truth inclusion conditional on returned intervals, interval availability and
returned-and-containing-truth frequency over all planned Persons. A failed
source contributes zero delivery, not zero error. If nothing is returned, error
and conditional inclusion are undefined. Never turn absent bounds into narrow
intervals or compare RMSE only on undisclosed successful datasets.
For native JML profiles with infinite estimates, retain the resulting infinite
full-cohort squared error against finite truth; any finite-subset summary is
labelled separately. The finite-score Monte Carlo formulas below must not be
applied to an infinite native error or used to replace it with post-hoc EAP.

The interval is a calibration-conditional posterior interval. Its nominal .95
mass under the scoring model is not a guarantee of .95 frequentist inclusion
at every fixed theta. F-pop inclusion also depends on the prior, model and
estimated calibration. The evaluation must not relabel these intervals as
including calibration/population-parameter uncertainty. F-grid describes
ability-specific shrinkage and inclusion; it has no automatic .95 pass rule.

The independent uncertainty unit is the calibration replicate, containing its
paired methods, Persons and panels. For ratios of delivered-person sums, use
replicate-level numerator/denominator contributions rather than treating R*M
Persons as independent calibrations. For a ratio t=mean(S_r)/mean(D_r), the
first-order Monte Carlo SE is `sd(S_r-t*D_r)/(sqrt(R)*mean(D_r))` when the
denominator is positive and regular; RMSE further uses the square-root delta
map away from zero. Retain zero-delivery replicates. Sparse delivery/degenerate
variance is an explicit precision limitation, not a nominally exact interval.
Use analogous paired contributions for error differences and record both
methods' marginal and joint availability. Population, grid and shifted-cohort
summaries remain separate; their common calibration induces dependence.

F evaluates latent-score accuracy. It does not establish prediction of a new
rating merely by substituting EAP into a response curve. Such a predictive
claim would need a distinct withheld response and a declared posterior
predictive calculation. A-E's probabilities at known generating ability and
F's scored abilities remain different targets. Automatic pass/fail, ranking,
feedback and treatment decisions retain their own loss/error requirements.

**Saved workflows and their actual scope.**

| Calibration / workflow | Admitted reuse and boundary | Evidence to retain |
| --- | --- | --- |
| Estimated-population RSM/PCM | Fitted-object scoring and saved score/result objects; portable calibration is currently unavailable. Fixed-N(0,1) RSM/PCM portability does not fill this gap for A's primary comparator. | Record the capability exclusion. Do not refit under another population solely to obtain an export or call it a numerical failure. |
| One-family MML and ordinary/corrected JML | Use the admitted model-specific extract/validate/freeze/save/load/score route after its own source checks. Estimated-population one-family MML requires an intercept-only population. | Preserve owners, constraints, correction order/sampling target where applicable, retained/actual prior, source identity, category codes and scoring algorithm. No training Person estimates are part of the calibration artifact. |
| Repeated events | Fitted-object ordinary/one-family routes accumulate the supplied independent rating rows; portable scoring requires distinct `event_id` values for intentional repeated Person-facet events. | L=2 events are not duplicate accidental rows. Preserve event identity and compare the same event likelihood. Existing repeated-event fixtures supply contract evidence; no new occasion effect is implied. |
| Two-family MML | Fitted-object and format-6 portable scoring preserve ordered owners, second-owner steps, fixed N(0,1) and known levels. Prior overrides and repeated Person-facet events are refused. | Preserve source/batch checks and `ObservedContext` for new combinations of known levels. A new combination is a model-based extrapolation, not empirical validation or estimation of a new level. |
| Saved score/result/report replay | Re-summarize or export the retained score/result without fitting or scoring again. Loading a frozen calibration and scoring another batch is a different operation that necessarily performs scoring integration. | Compare unrounded estimates, SD/bounds, interval algorithm/level, prior, IDs, availability and reason metadata. A CSV of estimates is not a full replay object. Old grid-endpoint interval artifacts keep that identity; they are not silently converted into continuous-quantile evidence. |

For eligible portability comparisons, match response/event rows, prior, scoring
order, integration mode and interval algorithm. Choose extraction settings that
match the retained scoring procedure; do not compare a refined fitted score to
a stale low-order artifact. Preserve the original artifact and identify any
new extraction separately. Use existing numerical comparison tolerances in the
relevant scoring/portable tests, not rounded printed agreement. Reuse fixtures
for unknown levels, empty responses, duplicate events, source refusals and
legacy formats rather than multiply each misuse case across the sampling map.
Apply these deterministic replay checks to representative retained successes
and refusals for each supported method/format; sampling qualification still
comes from the Person-score assessment, not from file-format agreement.

**October 2 execution contract: retained A/B calibrations.** The repository-only
[F runner](mfrm-wide-map-f-scoring-20261002.R) and
[eight-arm execution](mfrm-wide-map-f-witness-20261002.R) use the preceding
PCM N=20, SD=1, paired-L1 calibration case. All eight sources retain their
independently selected calibration stage. There are no calibration refits or
new calibration data. Independent future responses use the original parent
bundle's reserved `F_first_unused` substream. Each population/grid/shift cohort
gets distinct ability, assignment, response and reserved missingness substreams;
the calibration streams and A-E global head are unchanged. L=1 and L=2 reuse
the same 60 Persons and first events, with nominal pair counts 20/20/20.

All nine declared held-out batches for this condition are included: F-pop 60,
F-exposure the same 60 with two events, five F-grid batches of 30, and two
F-shift batches of 60. The two prior labels and eight calibration arms give
144 declared batch jobs. The scorer sees only IDs, facet levels and scores;
truth is joined after immutable batch selection. Exact public batch-integration
refusals alone may retry at 61/121 scoring nodes. Source failures, nonfinite
computations and other errors do not trigger a retry or batch subdivision.
Default-31 and refined delivery remain separate; all planned Persons, including
unscored Persons, remain in the denominator. A frozen job roster must complete
before the witness summary is produced. Broad R=50 summaries with missing
declared replicates withhold performance rates.

The two prior labels were deliberately executed separately. In the first
execution epoch, source inspection found that fixed-normal ordinary PCM and
ordinary PCM-JML with retained prior did not run the public EAP/SD batch comparison used by explicit-prior calls and
conditional-source paths. The ledger records `not_performed_by_public_procedure`
for that existing route, rather than fabricating a passed check or transferring
the reference-prior call's admission. The reference-prior arm is the common
checked comparison; the retained-prior arm describes the actual public workflow.
That first epoch preserved the then-current public procedure. The repair below
now applies the existing batch accuracy gate to every native scoring route.

Each calibration contributes error sums and delivery/inclusion counts. MCSEs
use calibration-level ratio contributions, retain zero-delivery replicates,
and are undefined for this R=1 execution. Paired comparisons retain marginal
and common-Person availability. Neither matching priors, shared L events nor
five fixed-ability panels add independent calibration replications. Native
training scores, training-cohort re-scoring, C-E scoring adapters, portability
and the full R=50 execution remain separate pending work.

**Completed F execution and public scoring repair, October 2.** All 144 jobs
completed in the first epoch, using 283 scoring attempts (902 seconds in this
case); 139 attempts stopped at the batch integration gate and were eligible
for the prespecified node refinement. No other scoring errors or warnings
occurred. The selected orders were 19 at 31, 111 at 61 and 14 at 121. All
6,240 method/prior/panel Person targets returned scores and conditional bounds
after refinement, but 780 of those targets belonged to the 18 retained-prior
ordinary PCM jobs whose original route did not perform the batch comparison.
Their unchecked returns must not be described as passed numerical checks.
The 330 distinct future Persons, the reused L=1/L=2 cohort and the paired prior
labels still represent only one independent calibration replicate.

The missing check had a measurable effect with the same prior and calibration.
In the 12-response held-out panel, retained-prior 31-node PCM-MML differed from
the checked, explicit N(0,1) route by up to .005816587 in EAP and .008506647 in
posterior SD. PCM-JML differences reached .001878822 and .003752990. These
exceed the existing 1e-5 numerical comparison tolerance; they are numerical
workflow evidence, not a comparison of statistical bias or prior quality.

`predict_mfrm_units()` now runs the existing EAP/SD reference comparison for
every native batch, including retained-prior RSM/PCM. The same default error
and explicit-review behavior applies. No calibration estimator, source
tolerance, posterior interval definition or scoring prior changed. New outputs
record that integration checks are required; summary/export refuses removed
or inconsistent records. Legacy outputs preserve their earlier contract.
The population-source qualification check remains ahead of batch validation:
passing score integration cannot promote an unresolved source calibration.
Help and NEWS describe the behavioral change.

The separate [repair execution](mfrm-wide-map-f-score-repair-20261002.R) reused
all 18 affected batches. One passed at 31 nodes, 15 required 61 and two required
121. All 780 score targets returned, with EAP, SD and both endpoints exactly
equal to the previously checked explicit-prior results. No calibration fit or
new response generation was involved. Parsed-source comparison establishes
that the scoring source/estimation helpers were unchanged. The final saved
output validation guard was tightened after these calculations; only that
validator changed, and all saved scores replayed under it without rescoring.

Fresh-process replay preserved all first-epoch 144 jobs and public summaries,
then all 18 repaired jobs/summaries under the final validator. Both repaired
PCM methods exported their saved 12-response score tables with matching
values/metadata; all 18 missing-review attachments were refused. Targeted
tests passed 79 F generator/execution/accounting checks and 463 public
scoring/prediction checks, without failures, warnings or skips. One existing
test of unresolved population-source output exposed the need to retain its
source guard before the broader batch check; that order is now tested, as
are stale and legacy output schemas. This is not an all-package release check.

Evidence is in `validation-results/mfrm-wide-map-f-scoring-20261002/` and
`validation-results/mfrm-wide-map-f-score-repair-20261002/`, with separate
source epochs, immutable phases, generator streams, Person-level ledgers,
calibration-level contributions, paired comparisons and test/replay records.
Do not silently overwrite the first epoch or pool its unchecked delivery with
the repaired procedure. This completes the declared held-out workflow for
this one A/B case, not R=50 performance, both sides of the calibration-L
comparison, C-E/F scope, native training-score evaluation or the final report.

**Extreme new-Person evidence, October 2.** A read-only review of the saved
panels found nine all-maximum and three all-minimum future Persons: six high
in the theta=2 panel, two low in the theta=-2 panel, and three high/one low in
the mean-shift panel. All 12 remained in the refined reference-prior ledger
for each of the eight arms: 96 finite EAP/posterior-SD outputs, all carrying
`public_EAP_SD_pass`. These are conditional scores under the explicit N(0,1)
prior, not native JML Person MLEs. No responses were generated or scores
recomputed for this review. This confirms retained extreme new-Person scoring
for the admitted sources in one calibration replicate; it does not establish
calibration with extreme training Persons, bias or interval coverage. The
read-only counts and focused checks are retained alongside the existing F
evidence as `extreme-response-review.rds`.

### Final report, model comparisons and visualization acceptance

**User clarification after the R=50 allocation.** Completion includes a
decision-oriented synthesis, paired method/model comparisons and interpretable
figures, as well as fitting. It also includes checking the applicable public
results/report/plot/saved-replay workflows. The simulation evidence and public
API delivery have separate acceptance criteria; producing research plots does
not implement a missing public function. These are required outputs of the
existing A-F study, not extra calibration replicates or an internal dashboard.

| Deliverable | Content required to answer the question | Acceptance evidence |
| --- | --- | --- |
| Integrated statistical report | For each A-F question: why these data/contrasts answer it, bias/RMSE and response/scoring error, numerical and output availability, defined interval performance, MCSE, practical interpretation and limits. Preserve small/mid/large N and adverse findings. | Every planned condition/attempt has a status; each conclusion links to its procedure, target, denominator and saved result. Partial blocks are labelled incomplete. Clear answers accompany the tables. |
| Paired estimator and model comparisons | MML/ordinary JML/orders 2/4 share data where admitted; model contrasts retain population, scale and owner identities. Show marginal and joint availability beside paired error differences. D uses the declared population-relative mapping. | Original and refined stages remain identifiable. No comparison silently changes the data, truth, scale, correction order or returned-case denominator. |
| Scientific figures | Bias/RMSE and output delivery versus N/exposure; qualified interval width/inclusion versus its stated target; facet/level/category panels; held-out score error versus ability. Show generating/reference and fitted quantities together where that is the decision, rather than relying on delta-only displays. | English labels, units, readable non-color distinctions, plotted data and Monte Carlo uncertainty saved. Unavailable/censored cells remain visible. Do not join different historical procedures into one curve or call conditional inclusion unconditional coverage. |
| Public model-comparison workflow | Exercise `compare_mfrm()` only on supported, same-basis saved fits, including an eligible ordinary/one-family comparison and an incompatible/refused case. Inspect comparison and nesting checks before AIC/BIC/LRT interpretation. | No MML-versus-JML likelihood ranking, corrected-JML likelihood ranking or two-family `compare_mfrm()` support is manufactured. `nested=TRUE` does not bypass the existing gate. Method recovery comparison is separate from automatic model-selection validation. |
| Public results, report and plot workflow | For representative supported RSM/PCM/one-family/two-family/corrected outputs, inspect `mfrm_results()`, `mfrm_report()` and the relevant plot methods, including attached contrasts, scores and comparison results where supported. | Tables, plotted values, interval meaning, source-stage metadata, cautions and unavailability agree. Retain a meaningful refusal example rather than suppressing it for a clean report. Reuse existing fixtures before generating new ones. |
| Saved reuse and distribution | Save the fitted/result/attached-output objects, machine-readable summaries and figure data; render readable local reports and exportable scientific figures. | Replay of already computed outputs agrees at unrounded precision without refitting/recomputing expensive intervals. Scoring new Persons remains an explicitly separate operation. A static CSV cannot substitute for a complete replay object. |

The final report distinguishes numerical correctness, repeated-sampling
performance and usability of the public workflow. AIC/BIC and LRT require a
compatible likelihood and their own source checks. Fifty replications and
descriptive model comparisons do not validate a new automatic selector, rater
ranking or high-stakes decision rule. Formal ordinary/corrected-JML structural
inference retains its unresolved method requirements. Conditional Person
posterior intervals retain their separate target and calibration-uncertainty
limitation. Existing G/D-study plots and assessment-feedback workflows have
their own acceptance work; this calibration simulation does not qualify them
merely by producing a final report.

Prepare the summary schema and denominator rules before bulk fitting. Run
public reporting/replay checks on suitable retained fixtures as their source
contract becomes ready; statistical figures use completed comparison blocks.
The integrated report is final only after every agreed block/output is either
assessed or explicitly recorded with its supported exclusion, unresolved
limitation or insufficient precision. Raw fit counts alone are not completion.

**Selected-output accounting implemented before bulk fitting.** The
[development summary helper](mfrm-wide-map-output-summary-20261001.R) accepts
one prespecified condition/arm/replicate/target/output row, with a reference
label/value and an input identity. Point and interval outputs retain their own
selected source stage; the helper neither chooses a stage nor constructs an
interval from a printed SE. Generating-parameter and population-equation-root
references cannot be silently mixed in paired errors. Unknown references remain
explicitly unevaluated. F Person scoring is not covered by this structural helper.

The summary keeps eligible versus fixed/unsupported/design-excluded targets,
not-started/running/interrupted/error outcomes, returned-but-unavailable outputs
and available outputs separate. An incomplete group has counts but no completed
performance rates. Available-case error/width and conditional inclusion retain
their actual denominators; returned-and-covered uses all eligible repetitions.
With no returned intervals it is zero when the reference is known, while
conditional coverage is undefined. Paired squared-error differences preserve
both marginal availability counts and their common-returned denominator, with
the paired Monte Carlo SE. Different inputs or reference targets are refused.

The deterministic accounting tests pass 28 expectations, including 19/20
conditional inclusion versus 19/50 returned-and-covered, zero delivery,
unfinished work, duplicate-stage rejection and unequal paired delivery.
These artificial accounting fixtures are not simulated estimator results.
The two actual PCM/fixed-normal GPCM interval objects also pass the selected
point/interval schema with reference-based performance suppressed; evidence is
in `native-location-branches-20261001/output-ledger-check.rds`. The first scoped
execution adapters and shared-fit location/slope outputs are now connected as
described below. Other target adapters, full-map dispatch, model comparisons
and final report generation remain open. These helpers are repository-only
and add no public API.

**Native MML stage execution and restart witness.**
The [stage runner](mfrm-wide-map-mml-stages-20261001.R) covers one declared
facet-location family and the separate scoring-calibration source in direct,
fixed-grid estimated-intercept RSM/PCM or one-family GPCM, and now adaptive
two-family fixed-population GPCM. It saves the initial
fit, scoring-source review and interval evaluation separately, with immutable
data/settings/source bindings and payload checksums. A completed phase is reused
after interruption; partial optimizer iterates are not resumed. One worker must
own a job directory. A hard process loss can leave the last phase marked running;
the incomplete phase remains unfinished and is retried on explicit job resume.
Solver/output errors are saved as completed attempts, separately from operational
interruption. A changed source or job specification is refused instead of
silently combining versions; source changes can still be bridged by a separately
documented targeted review rather than requiring a full repeated study.

The runner uses the existing consumer thresholds. Native interval refinement
requires a sole failed `Quadrature comparison` check, finite discrepancies,
passing coarse/fine inverse residuals and passing original stationarity. An
inverse failure or missing diagnostic does not trigger a fit. Scoring-source
refinement requires the finite integration table produced after the preceding
local checks. Each output retains its first passing stage; a terminal refusal
remains unavailable, and a higher-q fit error does not erase an earlier selected
output. q=121 is the final fitting order. The ledger's point rows here mean
**source-reviewed structural points**; the unqualified initial-call points remain
in `q31-fit.rds` and must be reported separately in the eventual study report.
Person scores themselves are not calculated by this runner.

The [bounded witness](mfrm-wide-map-mml-stage-witness-20261001.R) reused the
previously selected `AB:full-L1:N60:SD1:S-GPCM`, replicate 1, fixed-N(0,1) fit.
It has 60 Persons, Rater 3 x Criterion 3, four categories and 540 observations;
Criterion owns slopes and steps. Input checksum and exact saved fitting arguments
matched. The four R-file changes since fitting concern interval handling/help,
but the original compiled-library checksum was not recorded. Accordingly the
import is explicitly a workflow witness, not an automatically accepted broad-map
calibration slot. The new stages retain their current R/C++ source, loaded binary,
dependency versions and numerical environment. No responses were regenerated.

| Calibration grid | Comparison grid | Absolute NLL change | Maximum gradient change | Maximum finer-grid gradient | Scoring source |
| --- | --- | --- | --- | --- | --- |
| 31 | 61 | 0.0057710 | 0.0403940 | 0.0403944 | Refused |
| 61 | 121 | 0.000030677 | 0.000485503 | 0.000443760 | Refused |
| 121 | 241 | 0.000000006670 | 0.000000099199 | 0.000058796 | Passed |

The unchanged scoring thresholds are NLL change <= 1e-5, gradient change <= 1e-4
and finer-grid gradient <= 1e-4. All three Rater intervals had already passed
their own checks at q=31 and kept that stage's points/covariance. The separate
source-reviewed points first qualified at q=121. Thus an interval passing its
numerical checks does not by itself qualify that fit for scoring, and a refined
scoring point must not silently replace the point attached to an earlier interval.

The witness deliberately interrupted immediately before q=61 fitting. On resume,
all three q=31 phase files were reused byte-for-byte; only q=61 and q=121 were
newly fitted. Completed replay, including a fresh R process, passed with fitting,
source review and interval functions replaced by errors. The six selected rows
passed the output ledger with `Reference=none`, suppressing sampling-performance
claims. Evidence is in `validation-results/mfrm-wide-map-mml-stages-20261001/`.
At that first runner version, 46 deterministic execution expectations and 28 accounting expectations passed,
including reverse point/interval stage selection, non-integration refusal,
q=121 exhaustion, later fit errors, interrupted review reuse, source/input changes
and corrupt saved-output refusal. These are control-flow tests and one numerical
workflow witness, not coverage evidence or completed R=50 conditions.

**Two-family location execution and output-specific exclusions.**
The v2 runner preserves the declared adaptive controls (q31/61/121, BFGS,
maxit=500, reltol=1e-10, neutral_em, fixed N(0,1), ordered owners and
second-owner steps/uncentered locations). Scoring refinement uses the public
per-Person NLL/gradient limits of 1e-6. Interval refinement requires a sole failed
`Quadrature sensitivity` check, finite discrepancies, passing original score,
inverse and scaled-gradient checks. Missing diagnostics, rank failure or
optimization review do not launch a higher-q fit. Job identity now also binds
the information-memory budget and selected-output extraction verifies the job
specification before assigning condition/arm/input labels.

For a two-family model with I first-owner levels, J second-owner levels and K
categories, the current parameter dimension is p=2(I-1)+KJ. If observed N<p,
the current interval procedure's N-by-p Person-score rank requirement is
impossible. The execution plan marks that interval output `design_excluded`
without attempting it; point fitting and its distinct source review remain
eligible. N>=p does not establish rank or identification and retains the full
numerical checks. This exclusion describes the current consumer, not a theorem
that the model or model-Hessian uncertainty is unidentifiable at N<p.

The [two-family witness](mfrm-wide-map-two-family-witness-20261001.R) preselected
the existing D `historical-full-common:N20:SD1:H-both`, replicate 1, response view
and the retained `core-n120-s1-common_persons` fit. Both have Task 3 x Rater 6,
three categories and two Raters per Person; the first has 120 response rows and
the second 720. No responses were regenerated and neither old queue resumed.

| Witness | Calibration-source result | Rater location interval result | New fits |
| --- | --- | --- | --- |
| N=20, p=22 | q31 had finer-grid NLL change 0.01649/Person and maximum mean gradient 0.11052, triggering q61. q61 returned code 0 but terminal-gradient severity `review` (maximum absolute gradient about 1.12e-4, limit 1e-4); source review refused it and no q121 fit ran. Raw points and both stages remain saved. | Design exclusion: N<p; no interval calculation attempted. | q31 and q61 only |
| Retained N=120, p=22 | q31 passed: finer-grid NLL change 1.23e-14/Person and maximum mean gradient 3.63e-9. | All six q31 Rater intervals passed; score rank 22, standardized score displacement 5.41e-10 and covariance change 1.23e-10. These Rater locations are uncentered on fixed N(0,1). | None |

Do not call the N=20 optimizer result a convergence-code failure: it returned
code zero and the fit's coarse Converged flag is TRUE. The explicit gradient
review prevented scoring-source admission. Do not count its statically excluded
intervals as attempted solver failures, or remove its attempted point outputs
from the ledger. These two selected development cases do not estimate failure
rates. Evidence, frozen source, exact response identities, separate output plans,
saved phases and replay records are in
`validation-results/mfrm-wide-map-two-family-stages-20261001/`.

**Ordinary and corrected JML execution.**
The [single-call JML runner](mfrm-wide-map-jml-stages-20261001.R) reuses the
atomic phase/identity machinery but has no quadrature ladder or automatic
correction-order selection. It admits the specified ordinary BFGS controls or
an explicit corrected order 2/4 and fixed/random roster law; unsupported MML
arguments and corrected optimizer/reltol overrides are refused. Fits are saved
before source review. The raw public facet points, numerical/readiness record,
corrected root status, Person estimates including infinities and local root
covariance remain attached to their original procedure. Covariance availability
does not control root selection or source admission. Unresolved starts are not
relabelled consistent roots. A source error is a completed refusal, while an
interrupted phase remains resumable; neither causes a new fit/order attempt.

The point ledger again means source-reviewed structural points, using the
existing ordinary or corrected-JML scoring consumer. Initial-call estimates
remain separate for the eventual primary recovery analysis. Formal structural
CI rows are `unsupported` for these JML arms: observed-information screening SE
and corrected RootSE are retained evidence, not manufactured truth intervals.
The [JML witness](mfrm-wide-map-jml-stage-witness-20261001.R) reused three pilot
fits on the same 20 Persons, Rater 3 x Criterion 2, three categories, 160 observed
rows. Ordinary JML's source remained `review_only` (input review and unevaluated
identification/boundary states). Orders 2 and 4 retained `consistent_roots` and
passed the adjusted-equation source checks, with residuals 1.27e-11/8.09e-11 and
remaining steps 1.69e-11/2.28e-10. Both saved local root covariances were available;
no structural truth-inference claim follows. No JML fit or response dataset was
newly generated. Evidence is in `validation-results/mfrm-wide-map-jml-stages-20261001/`.

The MML execution checks now pass 67 expectations; JML adds 29, alongside the
28 accounting checks. All five actual workflow jobs pass replay in a fresh R
process with fit/source/interval functions replaced by errors and phase bytes
unchanged. The previous v1 witness retains its original frozen source and
meaning; it is not relabelled as v2 evidence. These original runners cover one
declared location family per job; the following layer shares fit stages across
several declared consumers. Full A-E dispatch, other target families and F
Person scoring remain open.
JML structural covariance/centering and applicability under broader ability,
assignment, missingness and dependence conditions remain unresolved method work.

**Shared fitting for multiple location and slope outputs.**
The [multi-output layer](mfrm-wide-map-multi-output-20261001.R) fixes the output
list before execution. One MML fit and one pending calibration-source review
serve every declared consumer at each q31/61/121 stage; JML uses one fitting
call and one source review. Only outputs with an integration-only failure
continue to a finer stage. Earlier qualified or terminal outputs are retained
even when another output requires refinement, fails or is interrupted. Interval
consumers retain separate public information calculations; sharing fits does
not mean that covariance is computed only once. Interrupted phases reuse the
completed fit, review and preceding consumer files.

Targets retain kind, owner and level. The ledger uses native location and
log-slope coordinates with explicit scale references, while the saved public
slope objects retain their original positive scale. Paired point summaries
refuse mismatched coordinates or scales even if numerical references coincide.
One-family relative-slope intervals retain their existing public procedure,
which has no documented finer-grid check; they cannot by themselves trigger
integration refinement. No stronger numerical or coverage claim is inferred.

The [retained witness](mfrm-wide-map-multi-witness-20261001.R) used six prior
jobs and nine saved fit stages, with no new fits or generated responses:

| Existing job | Shared location/slope outputs | Selected availability |
| --- | --- | --- |
| N=60 one-family GPCM, Rater 3 x Criterion 3 | Six locations and three log slopes | Nine source-reviewed points at q121; nine intervals at q31 |
| N=120 two-family GPCM, Task 3 x Rater 6 | Nine locations and nine log slopes | All 18 point and 18 interval outputs at q31 |
| N=20 two-family, same facet sizes | Same 18 targets | Raw points retained; source-reviewed points unavailable after q61; all 18 intervals design-excluded because N<p=22 |
| N=20 ordinary/order-2/order-4 JML, Rater 3 x Criterion 2 | Five locations and two log slopes per method | Ordinary source refused; seven points available for each corrected order. All 21 interval rows remain unsupported. |

These are four existing data views, not six independent replications, and none
is credited as a new R=50 result. The witness reused two saved Rater interval
objects and evaluated the other eligible location/slope consumers. All six
jobs replayed in a fresh process with fitting/source/consumer functions blocked
and immutable phase bytes unchanged. Stage-matched `mfrm_results()`, reports
and plot-data tables preserved all 27 available intervals without inference;
attaching q31 intervals to the q121 fit was refused. Separate point and interval
stages remain separate report objects, not a mixed-source result. This is
public-object replay evidence, not the final comparative study report.
The 45 new control-flow/scale checks and 28 accounting checks pass; the fixtures
do not estimate statistical performance. Evidence and frozen helper source are
in `validation-results/mfrm-wide-map-multi-output-20261001/`, linked to the
unchanged model-source archive from the two-family stage witness.

**Initial-call recovery and the first PCM comparison connection, October 2.**
The [recovery adapter](mfrm-wide-map-recovery-20261002.R) connects the two-facet
A/B targets to the frozen input's generating truth. It reads the initial q31
MML or single JML fit phase, independently of scoring-source admission and any
later selected q61/q121 point. Input checks bind response rows, category coding,
owner/level labels and centered native coordinates; model and correction-order
identities are checked against the declared job. Edited truth/input contracts
and mismatched saved data are refused. No sample-wise recentering, fitted-SD
standardization or oracle refit is applied.

Two explicitly named analyses retain the same planned replication denominator:
`initial_finite_return` records finite public numerical values, including
optimizer traces that are not certified finite/profile optima;
`initial_numerical_pass` additionally requires the stored ordinary convergence
flag and severity `pass`, or the corrected available `consistent_roots` status.
The latter does not perform fresh derivative/integration checks or establish
identification, centering, scoring readiness or interval validity. Original
numerical/readiness, root, Person and slope status fields remain attached.
The existing source-reviewed point ledger retains its distinct meaning.

The primary structural rows are the first-minus-second Rater and Criterion
locations and all GPCM centered log slopes, with individual locations retained
as supplementary rows. PCM/RSM slopes are fixed outputs and do not count as
estimated successes or paired estimated-slope comparisons. A named contrast
matrix is available for the existing interval consumer; this adapter itself
constructs no intervals and does not combine printed SEs. Category probabilities
are evaluated at theta=-2,-1,0,1,2 over every planned Rater x Criterion context
and category, with equal grid weights. These are research evaluation targets,
not new public curve APIs. Both the generating formula and the extraction from
saved method outputs passed recurrence/native-probability cross-checks.

Per-target error summaries retain finite-return counts, bias/error and RMSE,
with error MCSE and delta-method RMSE MCSE when at least two outputs return.
Availability MCSE is a plug-in binomial calculation; its zero at an observed
boundary is not evidence of zero delivery uncertainty. The grid summary first
forms one mean squared probability error per dataset. Its MCSE and paired-loss
MCSE use those dataset losses, never the number of grid cells as independent
replications. Missing grid cells make that dataset's complete-grid error
unavailable. Unstarted/interrupted attempts suppress completed performance
rates; method comparisons report both marginal and common-returned counts.
Fixed-target, input, scale and reference checks remain in force.

The [PCM witness](mfrm-wide-map-recovery-witness-20261002.R) preselected frozen
`AB:paired-L1:N20:SD1:S-PCM`, replicate 1: 20 Persons, Rater 3 x Criterion 3,
four categories, 120 rows, and fixed pair counts 7/7/6. This draw had no all-low
or all-high Persons. It generated no responses and fitted all eight declared
settings: PCM and GPCM MML with estimated/fixed normal populations, ordinary
PCM/GPCM JML, and GPCM correction orders 2/4 with fixed-roster covariance.
All eight returned finite targets and passed their stored numerical criteria;
orders 2/4 had consistent roots and available local-root covariances. No truth
interval follows. The final six ordinary/MML fits took 0.24--0.99 seconds each;
orders 2 and 4 took 27.62 and 33.12 seconds. These times include each public fit's
own work, not later MML source/interval qualification or F scoring, and cannot
price other N, exposure or exact-state dimensions.

An initial local `~1` formula captured its construction frame and failed
serialized fingerprint checks after the first PCM-MML fit. That failure archive
is preserved separately. Binding the literal intercept formula to `baseenv()`
fixed serialization; only that first fit was repeated, giving nine fit calls
for eight settings. Its parameter vector and objective were bit-identical
before and after the fix. All final phase bytes, eight recovery results and
28 paired comparisons replayed in a fresh process with fitting, scoring-source,
scoring and information functions blocked. The 44 recovery checks and 28
existing accounting checks passed without skips. Evidence, frozen helper source
and replay checks are in `validation-results/mfrm-wide-map-recovery-20261002/`.

This one-dataset workflow/cost witness is not credited as a completed R=50
condition or evidence of comparative bias/coverage. Error MCSEs remain undefined
at R=1. Small/middle/large N, both SDs, all declared A-F comparisons and the
final report/figures remain required. The following subsection connects this
case's target-specific interval execution. The F section records this case's
held-out scoring execution and ensuing public accuracy-check repair. Broader F
scoring, full-map dispatch and complete-comparison costing remain open before bulk execution, along with the
ordinary/corrected-JML method questions.

**Primary contrasts and interval recovery, October 2.**
The shared-output runner now admits prespecified zero-sum facet contrasts.
It passes the named coefficient matrix to the existing public
`mfrm_facet_intervals()` consumer, retaining that public object, its point,
covariance and source stage. Canonical coefficient hashes accompany target
names; different coefficient definitions cannot silently enter one paired
comparison. Location differences and individual levels are distinct targets.
The MML stage helper now also admits fixed-population RSM/PCM. Its existing
public object uses `Status`; a copied ledger table normalizes that field without
editing the public object or adding native-location checks it did not perform.
The native-location and two-family integration-only retry rules are unchanged;
neither the existing fixed-normal ordinary interval nor the one-family slope
consumer gets a fabricated covariance-grid refinement rule.

The [truth adapter](mfrm-wide-map-interval-recovery-20261002.R) joins those
declared contrasts and log-slope coordinates to the frozen generating values
after selection. It labels the interval procedure and keeps source-reviewed
points and interval outputs on their respective stages. Initial-call recovery
remains in its separate ledger. Formal JML intervals stay `unsupported`, with
no RootSE or screening-SE substitution; fixed PCM slopes are not requested
interval targets. All output errors/refusals retain their reasons and eligible
denominators. The shared output summaries retain conditional inclusion and
returned-and-covered separately; their R=1 values are descriptive single-case
indicators, not estimates qualifying repeated-sampling coverage.

The [interval witness](mfrm-wide-map-interval-witness-20261002.R) reused the same
eight saved initial fits and unchanged response data from the preceding PCM
witness. Three integration-only scoring-source failures triggered q61 fits;
there was no q121 fit, JML refit or new response generation.

| MML arm | First admitted scoring source | First admitted intervals |
| --- | --- | --- |
| PCM, estimated normal population | q61 | Both location differences at q31 |
| PCM, fixed N(0,1) | q31 | Both location differences at q31, using the existing fixed-population procedure |
| GPCM, estimated normal population | q61 | Both location differences and all three relative slopes at q31 |
| GPCM, fixed N(0,1) | q61 | Both location differences and all three relative slopes at q31 |

All eight methods' source checks admitted their 31 planned point targets in
this particular draw. All 14 eligible MML intervals returned; the 17 JML
interval targets remained unsupported and are not failed interval attempts.
The three new fits took 0.84, 1.63 and 0.72 seconds; these same-data refinement
stages are not independent replications. The earlier interval points and
covariances were not recomputed or replaced when their scoring source refined.

Fresh-process replay of all eight jobs, with fit/source/interval computation
blocked, preserved every immutable phase and the truth joins. Public results,
reports and plot-data tables preserved the 14 intervals at their matching q31
fit. All three attempted q31-interval/q61-fit attachments were refused. The
eight location-difference variances agreed with propagation through the saved
full parameter covariance and constraint Jacobian, including the cross terms.
The targeted checks passed 67 MML-stage, 45 shared-output, 28 accounting and
38 contrast/interval-recovery expectations, with no skips. Evidence and frozen
helper source are in `validation-results/mfrm-wide-map-intervals-20261002/`;
the earlier source epochs and their archives retain their original meanings.
This closes this case's interval/ledger/reporting connection, not the R=50
study, other structures, broader coverage or the JML method requirements.

### Inference decisions and evidence allocation

The decisions below identify the procedure/target that can be studied. They do
not change current estimators or declare the unfinished structural-inference
work complete. A public interval consumer, a research interval and a reported
SE are different deliverables.

| Strand | Decision for the next comparison | Evidence needed for the remaining claim |
| --- | --- | --- |
| Ordinary JML | Evaluate the actual unadjusted public estimator, its boundaries and point/scoring availability. Keep observation-information location SEs as screening precision; no Wald truth-CI arm is manufactured from them. | Separate numerical/finite-solution failures from structural bias with N and exposure. The research profile-limit estimator requires a named bridge and separate results; it cannot silently replace the public fit on extreme-response datasets. Formal structural uncertainty remains an open method question. |
| Corrected JML point estimation | Compare orders 2 and 4 as separately prespecified procedures on the same eligible inputs, reporting paired errors and each arm's availability. Preserve fixed/random-roster sampling distinctions and exact-state exclusions. | Reuse the N=400 bias/order evidence to identify adverse comparisons. Neither the smaller fitted RootSE, the closer agreement of orders nor the better result at known simulated truth selects an order for users. An automatic selector is not part of this evaluation. |
| Corrected JML uncertainty | Keep RootSE attached to the local adjusted-equation root. Apply the specified consistent-root research candidate and paired-order maps in the expanded comparison; preserve the paused order-2 protocol separately, without restart or pooling. | Truth-inference claims need centering, matching covariance and a specified procedure. Descriptive truth inclusion uses generating truth and does not require a new population root in each condition. Neither this calculation nor root covariance supplies a public structural-CI method. |
| MML component and location intervals | Retain the existing two-family checks and assess each implemented target separately. Prepare the missing matched MML facet-contrast consumer described in D. | The 400-case component-slope replay supplies numerical/adverse-case evidence, not independent confirmation or location-contrast coverage. A changed interval rule or new consumer needs source-specific checks followed by its own fresh confirmation. |
| Scoring and reuse | Reuse admitted A-E calibrations; native Person estimates, reference-prior scoring and fixed-N(0,1) two-family EAP retain their different conditioning/scale contracts. | Calibration-conditional score bounds do not cover calibration uncertainty. Held-out response/scoring performance and unavailable sources must be assessed together; dependent Persons scored from one calibration do not multiply independent calibration replications. |

**What the existing JML growth argument can and cannot settle.** The retained
derivation fixes facet dimension, compact ability/structural domains and roster
proportions, and increases independent within-cell replication L. Its stated
centering regime is conditional on those assumptions and cannot qualify the
new normal, skewed or dependent designs by citation to that derivation. At
fixed L, a nonzero contrast displacement between the population equation root
and structural truth need not disappear as N grows. Greater N can then narrow
a root-centered interval around the wrong structural value. Historical
finite-condition coverage and order-4 improvement in some coordinates do not
remove that problem in other conditions.

Design-preserving split correction remains a research candidate, not the
chosen public repair. The historical unequal/sparse rosters do not admit the
required identical halves; the new L=2 comparison's splittability alone would
not establish the required bias expansion, joint covariance or useful coverage.
Do not launch another large root-grid calculation or silently extend L until
an asymptotic argument appears favorable. First state the justified target,
assumptions and falsifiable procedure, using retained derivations and results.
Keep the agreed structural-inference gap visible while point/scoring decisions
proceed independently.

**Allocate evidence by the user decision before repetitions.** These rows
connect the existing D1/D2 obligations to the selected map. They classify the
evidence needed, not which agreed work may be dropped from 0.2.4. All allocated
A-E comparisons remain in scope; precise confirmation is separately assigned
to a retained quantitative claim. Descriptive evidence can inform limitations
without establishing a recommendation or qualified interval.

| Claim / block | User decision and public route | Evidence to use | Required closure / limit |
| --- | --- | --- | --- |
| Known rank/state/capability exclusions | Can this model return the requested fit, interval or score on this design? `fit_mfrm()` and the relevant consumer must distinguish support from a failed numerical attempt. | Static source/algebra evidence; retained identification and refusal witnesses. | Revisit only after a relevant procedure/design change. Exclude only the proved impossible output; do not spend repetitions to rediscover it or suppress eligible points. |
| Missing or unfinished interval procedures | Can a facet difference be accompanied by an interpretable interval in `mfrm_facet_intervals()` / `mfrm_results()`? | The native MML full-information/contrast specification and retained fixtures; ordinary-JML profile/centering work; corrected-JML residual-bias/covariance evidence and labelled research candidate. | Implement and verify the named MML consumer before claiming its availability; settle a structural target/procedure before a formal JML CI claim. More repetitions, RootSE or successful replay cannot close these method gaps. Agreed formal-inference work stays open. |
| A/B ordinary and corrected calibration | How do estimated facet effects, discrimination and Person scores change with method, N and ratings per Person? `fit_mfrm()` / summaries and F scoring. | Broad paired assessment across the full declared N/SD scope; compatible external/public bridges and N=400 studies. Include the fixed-population alternative with its actual restrictions. | Report error together with delivery, boundaries and paired-comparison eligibility. An improvement/adequacy claim names its target, domain and precision before fresh confirmation; this map alone recommends neither a universal winner nor a minimum N. |
| C facet/workload changes and new D null/owner comparisons | What changes when adding a facet, levels or a slope family to the admitted model? | Matched workload/null controls and shared A/B inputs/fits where specified. | Describe recovery, delivery and burden within the evaluated design. A benefit/cost recommendation needs its stated domain; null comparisons do not validate automatic model selection or unsupported structures. |
| D historical full two-family model | How dependable are the returned component/location estimates and experimental intervals across small and larger cohorts? | N=240 development evidence and compatible pilot/input records; missing N conditions and output-specific evidence. | Fresh confirmation uses a frozen complete procedure for the named target and retains adverse coverage/near-boundary cases. Component coverage does not qualify location intervals; inspected records remain development evidence. |
| E single and joint perturbations | What limitations should users expect with unequal assignments, missing scores, dependence or a changed population? | Descriptive recovery/delivery with mechanism-matched controls and unchanged generating targets. | Report affected outputs and assumptions, including unavailable results. A robustness guarantee needs a quantitative claim and qualified target; changing an interval's label cannot repair misspecification bias. |
| F scoring, results and saved reuse | Can users score a new cohort and reopen, plot or report the same supported result? `predict_mfrm_units()`, calibration scoring and saved-result consumers. | Statistical scoring panels share calibrations; retained independent integration and save/reload/report fixtures address numerical and software identity. | Assess score error, posterior inclusion and source/delivery failures using calibration-level MCSE. Separately verify target-preserving replay. No new independent calibration study solely for a report format; conditional score bounds still omit calibration uncertainty. |

For each retained conclusion, record its intended public wording, method/output,
evaluated domain, exact source/evidence, adverse or unavailable outcomes and
remaining gap in the existing D1/D2 rows. A completed descriptive comparison
closes that comparison's accounting; it does not close an unimplemented
consumer or formal-inference decision. Conversely, implementing a consumer
or passing saved-output checks supplies no sampling qualification.
The existing G/D, feature/MI, feedback, anchor and dependence-model evidence
keeps its own targets and affected regression requirements. The A-F map does
not replace those obligations or require a duplicate broad simulation for
every unchanged output. An automatic model/order selector or winner-inference
rule would require its own agreed decision and evaluation of the complete
rule; this allocation adds no such procedure or general-purpose guarantee.

An application-specific acceptability margin remains open where the intended
decision is not yet specified. Descriptive bias/RMSE, delivery, widths and
Monte Carlo uncertainty can be reported without inventing such a margin.
Neither favorable pointwise comparisons across selected cells nor a low fit
failure rate supplies a package-wide recommendation or a minimum N. This
allocation preserves domain visibility while assigning evidence by output and
purpose. The selected descriptive map uses first-stage R=50; static exclusions,
retained studies and claim-specific confirmation have different allocations.
The declared numerical and stream rules still require verification and a frozen
protocol; precise confirmation and measured workload remain open.

### Calibration procedures and bounded numerical refinement

**Protocol choices, not executed validation or new package defaults.** Use the
same observed unit-weight response rows and declared category ladder in every
admitted arm. Keep the planned-assignment/Person ledger separately; remove
missing scores consistently before calibration, since corrected JML requires
observed scores. Do not remove a dataset for an empty category, lost level,
extreme Person or failed fit. Parameter-specific missing targets remain visible.

| Arm | Explicit initial fitting settings | What is part of the procedure |
| --- | --- | --- |
| Ordinary RSM/PCM and one-family GPCM MML | Direct engine, fixed integration, q=31, BFGS, maxit=400, reltol=1e-9; estimated intercept-only population and identification/owners as specified in A-D | Retain the public initialization and bounded optimizer polish/curvature repairs in the frozen source. Higher integration orders use the same model, engine, controls and public initialization, not truth or another method's estimates. Fixed-population reference arms keep their separately declared population contract. |
| Two-family GPCM MML | Direct engine, adaptive integration, q=31, BFGS, maxit=500, reltol=1e-10, gpcm_mml_start="neutral_em"; fixed N(0,1), ordered owners and second-owner steps | Uses the retained adaptive procedure's initial controls and both public starts. The EM-derived vector is an initialization, not an EM fallback fit. Preserve the selected adaptive objective and convergence status even if a worse candidate would return intervals. Historical fixed-grid EM remains a separate comparator. |
| Ordinary RSM/PCM and shared-owner GPCM JML | BFGS, maxit=400, reltol=1e-9, jml_correction_order=NULL; model/constraints as specified in A-C/E | Use the public initialization and source-defined optimizer repairs. Do not add external random starts, trim extreme Persons, clip native infinite estimates, switch to a profile-limit estimator or import corrected estimates as starts. No MML quadrature arguments or population fit are imposed. |
| Corrected shared-owner GPCM JML | Explicit order 2 or 4, maxit=400, and the prespecified fixed_rosters/random_rosters law | Public neutral and deterministic perturbed starts; source-defined Broyden/Newton stages and root checks. Do not pass unsupported optimizer/reltol/noncenter_facet arguments. Keep consistent roots, unresolved starts and multiple roots distinct; covariance failure does not select or refit a root. |

`maxit` is a stage ceiling, not a total iteration/runtime budget. For two-family
adaptive fitting it applies to the EM seed and each direct optimization stage;
for corrected JML it applies separately to each root-solving stage/start. The
public corrected call passes 400 even though its internal helper's default is
150. Internal repairs are part of the named source version, not free external
retries. Record their stages, evaluations and elapsed cost without claiming
that equal maxit gives equal effort across methods. Keep the current 5,000-state
corrected-JML cap and configured information-memory limit (default 256 MiB);
no per-case increase to make a result available.

**Keep fitting, integration review and output selection separate.** Every MML
record retains the initial q=31 result with its original status. The planned
refinement ladder is q=31/61/121. Advance only when a prespecified output's
otherwise-admitted calculation has a documented integration-only failure:

- The calibration source check used for scoring has completed its other local
  checks and records finite coarse/finer NLL/gradient discrepancies outside its
  unchanged thresholds. Use the existing ordinary/one-family or two-family
  source-check tolerances, including their different total/per-Person scales.
- An implemented structural interval consumer reports integration sensitivity
  as its only failed numerical requirement. The existing two-family component
  procedure's exact trigger is a sole failed `Quadrature sensitivity` check.
  An unimplemented consumer is not a reason to launch a refit.

Do not infer this classification from a generic error or a favorable change in
truth coverage. Nonconvergence, insufficient score rank, boundary/source failure,
unsupported categories or missing/nonfinite diagnostics cannot be repaired by
this automatic quadrature ladder. A deficient structural interval does not
veto the distinct scoring-source check: a valid point/scoring question remains
even where that interval is algebraically excluded. q=121 is the final fitting
order, not an assertion of integration adequacy; finer-rule evaluations within
the source checks may use more nodes without fitting another model. A higher-q
fit failure ends that refinement chain, retaining the earlier records/statuses.

For the point/scoring comparison, name both the **initial-call** result and the
**source-reviewed** result, the latter being the first stage passing that
calibration-source check. F uses the latter with its own separate scoring-node
ladder. A finite earlier point remains recorded when source review fails, but
must not be labelled a qualified scoring calibration. Each structural interval
uses the first stage passing its own declared checks and keeps that stage's
point estimate, scale and covariance together. Its source can therefore differ
from the point/scoring source. Never attach a q=61 interval to a q=31 point or
silently replace F's calibration after inspecting an interval. Report stage
identity and availability separately, and count a shared fit once when outputs
reuse exactly the same data, source and numerical settings.

This output-specific rule is a new study workflow. It is not identical to the
historical interval-triggered 400-case MML replay, whose saved terminal fits,
initialization histories and results retain their original meaning. Reuse a
saved stage only after its exact data/source/settings and required checks have
been matched; do not relabel all 400 terminal points as source-reviewed F
calibrations. The separate paused corrected-JML order-2 protocol also retains
its identity and is not resumed or merged by these specifications.

**Selection and interruptions.** Numerical choices cannot depend on simulated
truth, estimated bias, a smaller SE, inclusion of truth, the desired method
ordering or the most favorable returned output. Retain the current public
objective/root selection rules, including unresolved alternatives. A machine
interruption is an unfinished job, not a statistical failure or replacement
dataset: resume the same immutable input/job after authorization. An observed
solver/source/output refusal is a completed attempted outcome. Distinguish
operational missingness from statistical non-delivery; no complete-study
summary while planned jobs remain unaccounted for.

### Source identity and random-number allocation

The source snapshot is made only after the selected procedure and required
consumer work have been settled. Record the R/package/dependency versions,
compiled library, relevant R/C++ code, generator, procedure, aggregation code,
protocol and input checksums. Record numerical library/thread settings as
environment metadata. A source change affecting an estimator, gate or selected
output defines a new procedure identity; a different file timestamp alone does
not qualify or invalidate old evidence. Reuse requires a targeted source/output
bridge, not a repeated full study solely to make hashes uniform.

For newly generated studies, specify
`RNGkind("L'Ecuyer-CMRG", normal.kind="Inversion", sample.kind="Rejection")`
and master seed 2026100101. A/B reserves unit streams 1--2,100; C appends
2,101--2,700, D appends 2,701--4,150 for linked response extensions and
historical reuse groups, and E appends 4,151--4,750 for its new parent cohorts.
The saved registries retain their
component states and predecessor checksums. The current head is
`validation-results/mfrm-wide-map-r50-20261001/rng-head.rds`, pointing to E's
registry and its next unused stream (ordinal 4,751). Future new units must
continue from that head; linked F panels use their parents' reserved F substreams.
Do not reset to a former head. Use R's `parallel::nextRNGStream()` for
immutable study-unit streams and `nextRNGSubStream()` for generation components.
These functions provide the stream/substream mechanism described in the
[R parallel documentation](https://stat.ethz.ch/R-manual/R-devel/library/parallel/html/RngStream.html);
the job registry and pairing rules below are this study's design choices.
Record the R version and all three RNG kinds, consistent with the
[R RNG documentation](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Random.html).

An append-only registry maps `(protocol epoch, development/confirmation phase,
pairing group, replicate)` to one saved stream state. New rows get unused
stream states; changing row order, worker count or resume order cannot reassign
an existing state. Within each unit reserve fixed substreams for ability,
assignment, response and missingness, then separate slots for each F panel and
its corresponding components. Reserve optimizer RNG separately if a future
procedure actually needs it; current deterministic starts do not consume data
streams. Allocate by scientific unit, never worker/process number. Persist the
initial states verbatim and use a fixed generation row order. Do not hash a
condition label into a small integer seed or let a failed fit advance the next
condition's stream.

| Sharing rule | Required identity and interpretation |
| --- | --- |
| Methods/orders on one dataset | Reuse exactly one generated response dataset, its missingness and planned roster. A different estimator is not a new data draw. |
| Explicit A/B and C pairing | Preserve A/B full/paired shared Persons and response events, and L=1 as the first-event subset of L=2; C's null-Task arm is the declared relabelling of those events. Build linked inputs from their common parent record rather than relying on coincidentally equal seeds or loop order. |
| D null/data reuse | Existing A/B S-PCM/S-GPCM inputs are aliases for the corresponding D truths. Rubric extensions inherit their A/B abilities, assignment and uniforms. Historical reduced truths inherit the matching full-truth draws; N=240/new-small-N SD/roster groups and the older independent N=120/480 scenarios preserve their distinct pairing laws. Reserved extension streams do not replace inherited draws; equal seed numbers alone are not evidence of identical data. |
| E matched mechanisms | Distinct from A/B. Each N/truth/replicate shares the specified E primitive draws across its 20 elementary views and six joint views where applicable. Deletion controls use identical complete responses; rho controls use identical assignments and marginal response equations. Preserve that dependence in paired comparisons and interaction summaries. |
| F comparisons | Methods and priors share the panel; F-exposure also shares its cohort and first/second events across the paired calibration-exposure arms. Other F panels have distinct substreams. All summaries preserve their common calibration dependence. |
| Other conditions and confirmation | Use distinct study-unit streams unless the condition protocol explicitly specifies a common-random-number comparison. New confirmation has a disjoint phase registry after the procedure is frozen; no inspected development input becomes fresh confirmation by changing its filename or fit settings. |
| Historical/prepared inputs | Preserve their original seeds, RNG kinds and frozen data/checksums, including the old Mersenne-Twister studies. Do not regenerate them under CMRG, reassign their role as fresh confirmation, or restart the paused study automatically. |

Streams specify intended reproducibility, not a completed guarantee across
unrecorded R/compiler/platform changes. Verify
serial versus reordered/parallel generation on a small affected fixture and
verify the required paired-input identities. Saved inputs are authoritative.
Restart reads that input and job identity before any RNG call; duplicate jobs
cannot create extra independent replications. No new RNG dependency, simulation
framework or background process is needed for this design.

### Condition accounting and precision decisions

The A/B baseline has `7 N x 2 SD x 2 rosters x 3 truth families = 84` condition
records per repetition. Method calls per N/SD/roster are 2 for S-RSM, 6 for
S-PCM (two PCM plus four GPCM arms), and 4 for S-GPCM: **336 fit attempts per
complete baseline repetition**. The paired L=2 extension adds
`4 N x 2 SD x 3 truths = 24` conditions and 96 fit attempts. Together these
are **108 condition records and 432 fit attempts per full repetition** before
additional numerical starts, uncertainty checks, scoring or C/D/E work.
S-PCM null-GPCM fitting is already included, not another generated dataset.

Equal allocation of 50 repetitions means 5,400 condition records and 21,600
fits; this replaces the earlier R=100 first A/B mapping allocation following
the user's whole-roadmap R=50 decision. For scale only, 500 would mean 54,000
and 216,000. These are arithmetic
planning counts, **not generated inputs, an approved compute budget or a launch
decision**.
Historical N=400 JML records and the MML core retain their own counts/protocols;
the fixed-population assumption comparison and C/D/E blocks are counted
separately in the expanded allocation below. Do not describe 108 paired
condition records as 108 independent calibration replications within one condition.

The specified C map adds 120 condition records per full repetition and reuses
12 A/B records for the null-Task comparison. Under the current method/capacity
contracts it adds 464 fit calls, including the additional null-Task fits and
excluding corrected-JML calls beyond the exact-state cap. E has 14 elementary
single-performance/three-rater profiles, three dependence profiles and three
weak-link profiles: 240 condition records across four N and three truths.
The two combined comparisons add 12 and 24 records respectively, for 276 E
records and 1,104 method calls per full repetition. Known b=0 identification
limits are not multiplied into that count. Thus the A/B/C/E *coverage map*
contains 504 condition records and 2,000 admitted fit calls per uniform full
repetition, before D, starts, scoring and numerical review. This count is not
an execution budget and does not require uniform replication over the map.
The now-specified D adds both reused-input method arms and new slope truths;
its deduplicated count and the separate A/B population-assumption arms appear
in the expanded allocation. The A/B/C/E subtotal is not the full study burden.

Before launch, each scientific claim must select which rows need retained
evidence/static checking, broad descriptive sampling or fresh precise
confirmation. Capacity exclusions and algebraic nonidentification do not
need hundreds of attempted fits to reconfirm them. Keep every domain and its
evidence status visible; a row with only descriptive or static evidence is not
silently labelled sampling-qualified. The expanded map makes uniform 500-fold
execution particularly inappropriate as an unreviewed default, even with the
deadline relaxed. Resolve output claims and numerical procedures before
allocating repetitions; do not replace the old 2,000-fit quota with a larger one.

This is why the next study must distinguish a broad descriptive assessment
from precise confirmation of a particular output/claim. Preserve all declared
sample-size/model domains in the broad assessment. Freeze the methods and the
claimed domains of a confirmation study before its fresh data; improving a
method after screening does not make the screening data independent validation.
Unconfirmed conditions remain visible. No isolated favorable condition can
support a recommendation for the whole package or a minimum sample size.

| Decision | Prespecified interpretation and remaining precision choice |
| --- | --- |
| Is an output available? | For dataset-level delivery, report its rate over all planned datasets and a pointwise binomial Monte Carlo interval, with causes of refusal. R=50 has maximum MCSE .070711, R=100 .05, R=500 about .0224 and R=625 .02; a broad low-precision result is not a rare-failure guarantee. F's per-Person delivery uses calibration-replicate contributions instead of a binomial calculation over all scored Persons. Choose the required rate precision before assigning R. |
| Does correction reduce error? | Report paired squared-error differences for the predefined contrasts/log slopes, their MCSE/intervals and both methods' availability. An interval excluding zero is pointwise evidence of a direction in that condition, not a universal winner or necessarily a practically useful gain. The variance of paired errors, not a binomial formula, determines repetition needs. |
| Are intervals calibrated to their stated target? | Only evaluate a named, implemented interval procedure. For one structural contrast per independent calibration and nominal .95 coverage, 475 returned intervals give planning MCSE .01 near .95; .01 uniformly over all proportions would require 2,500. F's Person intervals need its separate clustered evaluation and posterior-target interpretation. Fixed attempt counts must allow for expected refusals, without resampling until enough successes. These counts do not guarantee a coverage-equivalence decision. Root coverage does not qualify structural truth coverage. |
| Is a method suitable for a particular assessment decision? | Requires a justified application-specific error/width margin and the complete decision rule. Such a margin is not supplied by these artificial truth values. Until defined, give bias/RMSE, widths and delivery with uncertainty; do not invent a universal logit cutoff or call N=20 sufficient. |
| Is the evaluation complete? | Every prespecified attempt/output is accounted for; intended contrasts are reported with Monte Carlo uncertainty and adverse/unsupported cases; claims match the evaluated source and domain. Insufficient precision remains an explicit result. Repetitions are not added until a significance or coverage threshold passes. |

**Allocation rule to apply before launch.** Adopt the following precision
roles; these are study-design choices, not acceptable clinical/educational
error margins or a claim that every proposed cell must now be run:

- Static/capability rows receive zero Monte Carlo fits for an already proved
  exclusion. They do not remove an admitted point/scoring question in the
  same design. Retained evidence is used only for its matched procedure/target;
  more than the planned minimum is kept rather than discarded for uniformity.
- A selected broad-mapping row uses a planning target of dataset-delivery
  maximum MCSE .070711 with R=50 independent planned datasets under the
  worst-case Bernoulli bound. The user's breadth-first R=50 decision replaces
  the earlier .05 / R=100 mapping target; it does not achieve that old precision.
  This also yields descriptive bias/RMSE and their
  actual MCSEs, not a guarantee of useful precision for small paired effects.
  F reuses those R calibrations; its Person-level ratios use the separate
  replicate-level variance. This is the baseline allocation for an explicitly
  selected mapping row, not an instruction to multiply the whole coverage map
  by 100 without reviewing its source/output purpose and cost.
- A claim needing dataset-delivery MCSE at most .02 uses the worst-case floor
  R=625. This is still an estimate of availability, not a rare-failure guarantee
  or automatic statistical qualification. A claim about structural coverage
  or paired error can require a larger R and a different precision calculation.
- For conditional structural coverage, state a planning coverage value or range
  and interval-delivery assumption separately. Near .95 coverage and target
  MCSE .01, 475 returned independent intervals is a planning count. With a
  defensible lower delivery assumption pi_min, choose the fixed attempted R
  before sampling; if count assurance is required, require
  `P(Binomial(R, pi_min) >= 475) >= .95`. This .95 is a planning assurance level,
  not the coverage acceptance margin. It does not guarantee .01 MCSE if the
  actual coverage is far from .95. Worst-case coverage precision and a
  coverage-equivalence decision require their own allocation.
- For a paired MSE difference or an F ratio, specify its precision in the
  declared target's units. Using compatible retained/development variance V
  of the per-calibration difference or ratio influence contribution, plan
  `R >= ceiling(V / epsilon^2)`. Include a justified delivery allowance when
  conditioning on jointly returned outputs; do not treat the available-pair
  variance as the variance of every attempted dataset. Unknown V or pi_min
  remains a planning gap. If a development stage is needed after the hold,
  bound it in advance and exclude its inspected data from fresh confirmation.

Choose the maximum requirement over the prespecified primary claims served by
that dataset family, retaining paired methods/conditions together. Different
claims may share inputs without sharing all expensive inference/scoring calls.
Freeze attempted R rather than generating until a desired number of successes
is reached. If the realized MCSE, delivery or result is disappointing, report
that outcome; do not continue until a method wins or coverage passes. Any later
study has a new protocol/phase identity and reports the earlier result too.

The saved JML order-comparison `paired.csv` illustrates why a single inherited
R is insufficient: at N=400 and 200 paired datasets per condition, log-slope
MSE-difference MCSE is .00006885085 in the unequal-Criterion case and
.00014597553 in the sparse-Rater case. These are reads of existing summaries,
not recalculations. They do not provide variance inputs for the new N=20,
three-level slope owners, additional facets or different exposures. Likewise, 399/400 returned
intervals in the inspected MML replay cannot serve as a delivery lower bound
for every new small-N condition or new location-contrast consumer.

The family-level ledger below assigns retained evidence and working mapping
allocations for A-E. Before launch it must expand into exact condition/output records
with a paired-input identity and all numerical stages priced. A row lacking
compatible precision evidence or an implemented output is not silently assigned
500 repetitions. All declared domains, including deferred ones and historical
larger samples, stay visible; deferral is not validation or removal from the
package's scope.

Pointwise Monte Carlo intervals are not simultaneous claims over many methods,
parameters and conditions. Any package-wide superiority or simultaneous
coverage claim requires a separately specified multiplicity/decision rule.
The planning basis follows
[Morris, White and Crowther (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6492164/),
especially matching methods on datasets, retaining failed analyses and choosing
replications by performance-measure precision. The proposed parameter values,
rosters and precision tradeoffs here are maintainer design choices, not findings
or thresholds taken from that paper. The descriptive mapping allocation below is a
working design choice; precise confirmation and measured workload estimates
remain open. Old four-condition timings do not price this design. The user's
small-pilot authorization and subsequent whole-roadmap R=50 request supersede
the earlier blanket planning hold for those tasks; they do not resume paused
studies or establish that every comparison is ready for bulk fitting.

#### Whole-roadmap first-stage allocation: 50 datasets per condition

**User decision after the facet pilot.** Apply R=50 to the first descriptive
mapping across A-E, including ordinary MML/JML, explicit corrected orders and
MML-specific model arms where admitted. F reuses those calibrations. Preserve
the full N=20/30/40/60/120/240/480 baseline, SD=.5/1 comparisons, facet/category
changes, assignment/missingness/dependence and the historical N=400 evidence.
This is a reduction in first-stage repetition, not a narrowing of the domain.
The 50 attempts are per generating condition, not per method or per parameter;
all matched methods see the same responses. Null-Task and D control aliases
do not generate additional independent datasets. The recent K=3/Criterion=2
pilot remains separate development evidence, not replicate 1 of the broader
K=4/Criterion=3 protocol.

| What R=50 can establish descriptively | Precision / limitation |
| --- | --- |
| Whether delivery problems recur and how outcomes vary | Maximum binomial MCSE .070711 (7.07 percentage points); a reported proportion changes by 2 points per outcome. |
| Conditional 95% structural coverage of a named implemented interval | Planning MCSE .030822 (3.08 points) near .95 only if all 50 independent intervals return; fewer returned intervals give less precision. Coverage is descriptive, not qualified by proximity to .95. |
| Bias and paired MSE differences | Report actual MCSE: sample SD of the per-replicate error or paired squared-error difference divided by sqrt(the relevant returned count). Failure conditioning stays explicit. Fifty alone guarantees no useful error precision or detectable improvement. |
| No observed failures | With 0/50 failures, the exact one-sided 95% binomial upper bound is .058155, not zero. A true 1% failure is seen at least once with probability only .394994. |

All attempts, numerical errors, unresolved starts, unavailable outputs and
resource limits remain in their respective denominators. Do not generate until
50 successes occur. Algebraically impossible outputs retain R=0 computation
and an explicit capability exclusion, while admitted methods/points still use
the condition's 50 datasets. A fixed-roster covariance refusal is not repaired
by changing the sampling law. Ordinary-JML screening SEs and corrected RootSE
do not become structural truth intervals because replication has increased.
Pointwise MCSE statements are not simultaneous package-wide guarantees.

There is no automatic second batch of 50. If later confirmation is justified,
choose its fixed attempt count from the named claim's precision and delivery,
and use a distinct phase after the procedure is frozen. The first-stage
results remain reported even if inconclusive. Conditions cannot be added or
dropped because a preferred estimator did well or badly.

The [allocation enumerator](mfrm-wide-map-allocation-20261001.py) expands the
existing comparisons into 612 unique input-condition templates plus 68 aliases,
checks model-arm counts and priority totals, and writes the allocation-only
registry in `validation-results/mfrm-wide-map-r50-20261001`. It creates no
responses, RNG streams or fitted models. Detailed generator identities, target
gates and immutable input/stream manifests must precede execution of each
complete comparison. E8's six model-defined missingness rates pass the
integration-coordinate check; E's assigned/observed-row and paired-control
generator checks are now complete. A-E's input/stream freezes are recorded above;
the allocation file itself is not rewritten as an execution ledger.

The [development stage logger](jml-stage-checkpoint-20261001.R) now records
corrected-JML solver entry/return, reviewed attempts, covariance stages and
periodic equation evaluations in an atomic `latest.rds` and an event log. It
instruments a local copy of the existing function; production code, starts,
tolerances and root selection are unchanged. On the retained N=20 two-facet
order-2 example, the canonical replay exactly matches every saved internal
result field, including all solver attempts, points and covariance. An earlier
replay matched all numerical fields but used the raw `Score` column name in
its specification; the verified runner uses the public path's `score_k`
preparation. Read-back also exposed incomplete replacement of attempt-history
lists and stale prior-stage fields; the final logger replaces complete records
and clears stage-specific context. Final evidence is `base-order2-final` and
`interruption-final`, indexed by `verified-checkpoints.rds` under
`validation-results/jml-stage-checkpoint-20261001/`. Three completed replays of
one saved base input and two deliberate interruptions are instrumentation
checks, not independent replications. Two initial logger setup failures
occurred before fitting; the intermediate records remain labelled and retained.

A deliberate interruption of the retained N=20 null-Task order-2 calculation
after its first periodic checkpoint left readable stage/start, last evaluated
coefficients and residual, and the completed neutral-start attempt. The current
perturbed-start record contains no stale prior solver and no completed-result
file. This verifies
interruption accounting, not convergence or a solution of the earlier
120-second censored case. Partial iterates are diagnostic records, not fitted
objects or approved restart values. The three original censored pilot cases
remain unresolved; stage-level investigation and a fixed resource policy are
still needed before scaling. The pilot's 81-state timing does not price the
broader 2,197-state and other designs.

#### Family allocation ledger and work order

**Current R=50 first-stage allocation; generator/output freezes remain per comparison.**
Select the complete A/B baseline and its paired L=2 extension for the first
broad mapping allocation. This preserves all seven N values, both SDs, all
three truth families and the public MML/ordinary-JML/corrected-JML comparisons
where admitted. The L=2 arm is needed to separate adding Persons from adding
information per Person, especially for JML. These are 108 condition records,
not the old four MML conditions. Their common initial precision target is
dataset-level delivery MCSE <=.070711, giving 50 attempted datasets per condition;
parameter error and correction-order differences remain descriptive with their
actual MCSEs. No precise superiority, truth-coverage or minimum-N claim follows.

| Family / evidence role | Primary target, precision and supporting evidence | Attempt allocation and reuse | Additional work / dependency |
| --- | --- | --- | --- |
| A/B L=1 — first mapping | Delivery of named point/scoring outputs, MCSE <=.070711; structural contrasts/log slopes, response recovery and corrected research-candidate inclusion descriptive. The delivery bound needs no pilot variance; compatible error variances are unavailable. | 84 conditions x R=50; 4,200 new condition-dataset records and 16,800 initial fit calls. Pair all admitted methods on each input; S-PCM supplies the null-GPCM fits. | Seven N values, two SDs and both rosters remain. JML screening/RootSE fields are not qualified truth intervals; the named corrected candidate is a research output using saved root covariance, not extra fitting. New MML interval consumers have a separate implementation gate. |
| A/B paired L=2 — first mapping | Same delivery precision; paired L=2 minus L=1 recovery and delivery. No small-effect precision guarantee. | 24 conditions x R=50; 1,200 augmented condition-dataset records and 4,800 initial fit calls. Share Persons/first rating events with the corresponding paired L=1 conditions. | Generates second rating events, not 1,200 unrelated new cohorts. Keep the declared fixed-roster law and supported correction-state limits. |
| C — required expanded mapping | Facet/level/category recovery, delivery and workload contrasts. Delivery MCSE <=.070711 gives working R=50; error/coverage precision remains descriptive. | 120 new conditions x 50 plus 12 A/B null-Task aliases x 50; 23,200 additional calibration slots. Preserve N=20/60/240/480. | The expanded table separates fixed-workload and added-workload questions and excludes only impossible corrected calls. Numerical stages and interval/scoring work remain additional. |
| D historical full truth — retained + expanded mapping | Two-family slope recovery and historical interval findings; new scale-matched comparisons have different outputs. Use working R=50 for delivery mapping, not precise confirmation. | Four N=240 cells select 200 saved inputs for this stage; eight N=120/480 cells select 400 prepared inputs. Preserve all original 400/800 records. Sixteen N=20/30/40/60 cells plan 800 new inputs. Four MML arms give 5,600 calibration slots before stage reuse. | Keep all 400 completed and eight pilot two-family records. The first-stage IDs contain 200 completed and eight pilot reuse candidates, subject to exact stage/source checks. Do not resume 792 old jobs as a substitute for the new workflow. |
| D nested historical truths — required expanded mapping | Equal/first-only/second-only/both-slope comparisons on population-relative response and parameter scales. Delivery MCSE <=.070711; paired-error precision is not established. | Three reduced truths x four N x two SD x two rosters x R=50 = 2,400 new records; 9,600 calibration slots. The full truth aliases the preceding row. | Four MML arms share each dataset; no two-family JML arm. Preserve native-scale transformations and target-specific rank exclusions. |
| D rubric truths — reused A/B + expanded mapping | Slope-family null/heterogeneity and scale-matched MML output behavior. Delivery MCSE <=.070711 gives working R=50. | 56 A/B L=1 cells alias 2,800 inputs and 4,200 primary MML fit slots. Their new model arms add 7,000 slots; 32 added-truth cells add 1,600 inputs and 6,400 slots. | Exact data/owner/settings identity is required for fit reuse. These are extra model arms on shared inputs, not additional independent replications; outputs/stages still need their own checks. |
| E — required expanded mapping | Population, assignment, missingness, dependence and weak-link contrasts; delivery MCSE <=.070711 with working R=50, error/coverage descriptive. No general robustness claim. | 276 conditions x 50 = 13,800 new records and 55,200 calibration slots. Controls are counted once; A/B fixed rosters do not replace E0. | Input/mechanism checks passed; fit/source/output preflight remains. Schedule elementary matched comparisons before the two specified interaction blocks. No redraw for support failures. |
| A/B fixed-population assumption — shared inputs, additional MML arms | Compare fixing N(0,1) with the primary estimated-normal assumption at SD=.5/1. Working R=50 uses exactly the A/B records; it is not a new population draw. | 144 additional MML configurations per full repetition, hence 7,200 slots; zero additional calibration datasets. | Same controls/owners as the corresponding primary fit, with the explicit population restriction below. This arm is not implicitly multiplied through C/D/E. |
| F — attached to admitted calibration panels | Native/cohort/common-prior/shifted-cohort score error, posterior inclusion and delivery. Ratio MCSE is clustered by calibration; no Person-level epsilon is assigned from a binomial bound. | Reuse the selected calibration replicates. For first-mapping A/B, use its R=50 and the specified F panels; no extra calibration fits solely for F. | Additional scoring/integration calls are required and must be priced. A source refusal remains in delivery denominators. Fixed-grid/shift/exposure panels keep their specified subsets, paired events and priors. |
| Earlier JML N=400 — retained | Original 200-case comparison and two 200-case order conditions support their named research targets; preserve adverse order reversals. | No new repetitions allocated to these completed studies. | Public-solver transfer, if sought, is a labelled development bridge using exact inputs, not automatic rerunning or independent confirmation. |
| Public corrected-JML paused study — preserved, decision deferred | Original order-2 candidate-interval/exposure question at N=400; no completed sampling result. | Preserve 113 fit records / 57 inputs and the original 3,000-fit protocol; zero resumed jobs now. | Decide whether that exact question remains needed. Resume only under its original identity or create a separate procedure; never pool a changed protocol into its denominator. |
| Proved capability exclusions — static | State cap, fixed-roster covariance capacity and unsupported consumers/designs. | R=0 for the proved impossible output. | Preserve eligible points/scoring and alternative methods in the same condition; exclusions are not stochastic failures or whole-model nonidentification. |
| Claim-specific independent confirmation — not yet allocated | A named stable procedure/output/domain; availability MCSE <=.02 uses floor R=625, structural coverage near .95 uses 475 returned intervals with justified delivery allowance, paired errors/F ratios require epsilon and compatible variance. | Attempted R unresolved until the claim and planning inputs are fixed. Fresh phase/streams; neither the old 2,000 proposal nor inspected development inputs fill it. | No automatic 500 per cell, favorable-cell selection for a broad claim, or significance-driven extension. Implementation and residual-target questions apply to the affected output. |

The first A/B allocation therefore represents **5,400 condition-dataset
records and 21,600 initial fit calls**, before retries, covariance/source checks
or F scoring. Linked L=1/L=2 records are not independent cohorts. This is a
concrete planning burden, not an assertion that the workload is affordable or
a replacement fit-count target. Price and freeze it before execution; if
resource review requires a revision, document which comparison/precision is
changed rather than quietly dropping a method, N value or failed dataset.

C, D and E now have the same working delivery-precision allocation, with their
distinct targets and scheduling priorities below. This does not make A/B
sufficient for general-purpose validation or make expanded work contingent on
finding a favorable estimator. Unknown error variances still prevent assigning
precise error/coverage confirmation budgets. Retained MML and JML large-N
evidence stays visible. A frozen-input bridge adds no independent datasets;
scoring panels add no calibration replicates; two methods on one input do not
double its sample size.

#### Expanded allocation, shared controls and scheduling priorities

**Current allocation after the whole-roadmap R=50 decision; bulk fitting has not started.** Use R=50
attempted datasets per admitted mapping condition in C/D/E, for the same maximum
dataset-delivery MCSE .070711 used in A/B. This resolves the repetition choice for
descriptive delivery, not for detecting a small MSE change, rare failures or
precise conditional coverage. Retained larger studies keep all their records.
Each row below has a distinct scientific contrast and a control; structural
exclusions get zero calls only for the affected method/output. These selected
conditions are not an exhaustive crossing of all package capabilities.

The tables count **condition records and distinct initial model/data
configurations per full replicate**, before multiplying by 50. A configuration
is a calibration slot that may be filled by an exactly compatible saved fit;
it is not necessarily a new optimizer call. Internal starts, refinement stages,
uncertainty checks and F scoring are additional work. Aliased data and identical
fits are counted once, including sharing across blocks.

| C comparison | Additional condition records | Additional calibration slots | Control and priority |
| --- | ---: | ---: | --- |
| Six raters, paired assignments | 12 | 48 | A/B three-rater paired baseline; P1, fixed ratings per Person. |
| Six raters, full panels | 12 | 32 | A/B three-rater full panel; P2, added ratings and facet burden. Corrected calls exceeding the state cap are excluded. |
| Null Task facet | 0 (12 aliases) | 48 | A/B paired L=2 inputs; P1, added nuisance facet at unchanged observations. Three-facet fits are new. |
| Two nonzero Tasks, same/changing rater pairs | 24 | 96 | Null-Task and same-pair controls; P1, facet effects and allocation at equal workload. |
| Four Tasks, all observed, same/changing pairs | 24 | 64 | Matching two-Task arms; P2. Corrected calls exceed the state cap. |
| Four Tasks, two observed per Person | 12 | 48 | Two-Task same-pair arm; P2, fixed workload. N=20 covariance exclusion does not remove admitted point fits. |
| Five Criteria | 12 | 32 | Three-Criterion two-Task changing-pair arm; P2. Corrected calls exceed the cap. |
| Three/five categories | 24 | 96 | Four-category A/B baseline; P2, same rating count with declared within-ladder targets. |
| C subtotal | 120 | 464 | 6,000 additional condition-dataset records and 23,200 slots at R=50. |

All C rows retain N=20/60/240/480, SD=1 and all three truth families. Different
caps change the number of method calls, not the number of generating conditions.
Do not count a null-Task relabelling as another generated response dataset.

| D comparison | Condition records | Additional slots after A/B fit reuse | Control and priority |
| --- | ---: | ---: | --- |
| Historical full two-family truth | 28 | 112 | Seven N values, both SDs, both historical rosters; P1. Includes the 12 retained/prepared cells, not just new small samples. |
| Historical three reduced slope truths | 48 | 192 | Full truth at the four N anchors; P2. Complete equal/first-only/second-only/both truth comparison, with common component geometric means. |
| Rubric equal/second-only truths | 56 A/B aliases | 140 | A/B L=1 S-PCM/S-GPCM; P1, supplies matched null controls for the added truths. |
| Rubric first-only/both-family truths | 32 | 128 | Four N anchors, both SDs/rosters; P1, completes the rubric slope-family comparison. |
| D subtotal | 108 additional + 56 aliases | 572 | 5,400 distinct D records beyond A/B, of which 600 are retained/prepared; 28,600 additional slots at R=50. |

For the rubric aliases, 28 S-PCM cells already have PCM and second-owner GPCM
MML fits in A/B; 28 S-GPCM cells already have second-owner GPCM MML fits. Thus
84 configurations per replicate are shared, leaving `28*2 + 28*3 = 140` new
ones for the four-model comparison. The additional D truths need four MML
models per dataset, regardless of which happens to fit best. Two-family-only
uncertainty exclusions do not remove the other models or its point/scoring
questions. The source/scale conversion is the specified D transformation,
not post-hoc rescaling by empirical Person estimates.

| E profiles | Additional condition records | Additional calibration slots | Matched control and priority |
| --- | ---: | ---: | --- |
| E0: random-roster baseline | 12 | 48 | Common control for single-performance perturbations; P1, counted once. |
| E1: three population shapes | 36 | 144 | E0 with mean/variance held fixed; P2. |
| E2: two targeting shifts | 24 | 96 | E0 with SD fixed; P2. Estimated-normal MML remains correctly specified for the population shape. |
| E3: sparse interior category | 12 | 48 | E0 with changed steps only; P2. |
| E4: unequal pair probabilities | 12 | 48 | E0 at fixed ratings per Person; P1. |
| E5: ability-associated allocation | 12 | 48 | E0 with the same marginal pair probabilities; P2. |
| E6: two independent missing rates | 24 | 96 | E0; P1. |
| E7: rater-dependent missingness | 12 | 48 | E6 at .15 mean missing rate; P2, do not duplicate that control. |
| E8: score-dependent/matched-rate independent missingness | 24 | 96 | Complete mechanism pair; P2. Use the computed truth-specific normal rates above; generator pairing remains to verify. |
| E9: rho=0/.25/.5 dependence | 36 | 144 | Same two-Task design, rho=0 control included; P2. Single-performance E0 is not that control. |
| E10: b=.6/.2/.05 weak links | 36 | 144 | Same six-rater design, b=.6 control included; P1. |
| Shape x missingness | 12 | 48 | At N=20/480, normal cells alias E8; two right-skew mechanism cells are new; P3. |
| Links x dependence | 24 | 96 | Four cells at N=20/480; P3. Three-rater E9 and single-performance E10 are not substitutes for its controls. |
| E subtotal | 276 | 1,104 | 13,800 new condition-dataset records and 55,200 slots at R=50. |

Elementary E rows use N=20/60/240/480, SD=1 and the three truth families;
interaction rows use both specified N extremes and all three truths. Other
than the explicitly aliased controls, inputs keep the previously specified
stream/pairing rules. Equal settings or similar labels do not imply identical
response draws. Fixing Person counts by roster would change E0's sampling law.

**The previously uncounted A/B population-assumption arm.** On all 108 A/B
records, add fixed-N(0,1) MML for the same response model(s): one RSM fit for
S-RSM, PCM and one-family GPCM for S-PCM, and one-family GPCM for S-GPCM.
Use `population_formula=NULL` without population Person data, and explicitly
`gpcm_mml_identification="fixed_standard_normal"` for one-family GPCM. Keep the
corresponding primary arm's constraints, owners, data and numerical controls;
do not transform or regenerate the input. This is the ordinary RSM/PCM default
population assumption but an explicit restricted alternative for one-family
GPCM, whose current default is free population. Fixing N(0,1) while retaining
geometric-mean-one slopes also restricts common discrimination; this is not
equivalent to an unrestricted GPCM expressed on a fixed-variance scale. It adds
`7*2*2*(1+2+1) + 4*2*(1+2+1) = 144` configurations per replicate, with no
additional inputs or JML fits. It measures the population restriction on the
declared canonical scale, not a harmless change of coordinates. This allocation
does not extend that alternative through C/D/E or qualify arbitrary targeting/
shape misspecification; those primary comparisons retain estimated-normal MML.
Its F panels reuse the same A/B cohorts, and identical retained/common scoring
priors can reuse scores while keeping the arm labels.

| Working descriptive allocation | Unique condition-dataset records | Of these, new records needed | Initial calibration slots after cross-block fit aliases |
| --- | ---: | ---: | ---: |
| A/B primary | 5,400 | 5,400 | 21,600 |
| C additions | 6,000 | 6,000 | 23,200 |
| D additions | 5,400 | 4,800 | 28,600 |
| E additions | 13,800 | 13,800 | 55,200 |
| A/B fixed-population alternative | 0 | 0 | 7,200 |
| Total for this selected map | 30,600 | 30,000 | 135,800 |

These 30,600 first-stage records are not all independent cohorts: the declared
L=1/L=2 event links and other paired comparisons remain. The 600 verified D input
reuses are original replicate IDs 1--50 in each of the 12 stored cells:
200 from the four completed-replay cells and 400 from the eight prepared core
cells. This fixed prefix uses no convergence, interval or truth-error selection.
All original 400 completed and 800 prepared inputs remain preserved. Compatible
existing results beyond ID 50 retain their actual denominator in retained-evidence
summaries; newly paired comparisons use their explicitly shared IDs. They are
not discarded to make every historical summary have R=50, nor are extra fits
silently launched on IDs 51--100. Inspected data never become fresh confirmation.

Within the first-stage IDs, 208 two-family slots have completed/pilot records
as potential stage-reuse candidates. Their record integrity is checked, but
input reuse alone does not remove a fit slot: the source/output bridge must
establish compatibility. All 600 inputs pass saved-data/truth/seed checks,
preserving the allocation of 30,000 new records. The N=240 generator/latent
identity limitation remains as recorded in D; reuse is not fresh confirmation.
Historical N=400 JML evidence remains additional retained evidence under its
original protocol, not another 50-repetition row in this total.

**Scheduling decision and resource limit.** P1 gives the common A/B comparisons
(including the population alternative), basic facet/allocation contrasts,
the historical/rubric two-family comparison and routine missingness/weak links
first scheduling priority. P2 completes facet burden, category, null-truth and
single-mechanism sensitivity questions. P3 completes the two specified joint
adverse comparisons, reusing only their exact controls. P1/P2/P3 are priorities,
not labels of evidential strength or permission to omit later work. The normal
and right-skew missingness cells must all be available before reporting that
interaction, regardless of their scheduling priority.

The priority totals, with the same cross-block aliases as above, are:

| Priority | Condition-dataset records at R=50 | New records needed | Initial calibration slots |
| --- | ---: | ---: | ---: |
| P1 | 14,400 | 13,800 | 74,200 |
| P2 | 14,400 | 14,400 | 54,400 |
| P3 | 1,800 | 1,800 | 7,200 |
| Total | 30,600 | 30,000 | 135,800 |

Per full replicate P1 contains A/B primary plus fixed-population fits (576
slots), C six-rater paired/null-Task/two-Task arms (192), D historical full and
all rubric truths (380), and E0/E4/E6/E10 (336). P2 contains the other C (272),
historical reduced D truths (192) and elementary E profiles (624); P3 has the
joint E comparisons (144). All 600 stored inputs belong to P1. This keeps
the totals auditable without treating every priority as one launch command.

P1 itself is too broad to be a single initial execution batch. The complete
A/B RSM, PCM and GPCM truth comparisons can be separate work units: each has
1,800 condition-dataset records, with 5,400, 14,400 and 9,000 initial slots
respectively, including its fixed-population alternative. Each retains all
seven N values, both SDs, both baseline rosters and the paired L=2 anchors;
the PCM truth includes its null-GPCM fits and both correction orders. These
are divisions of the existing allocation, not extra data or new studies.
C, D and E units follow the named matched comparisons in their tables, sharing
controls instead of regenerating them. Their joint questions require all
declared arms before a complete comparative conclusion. Source/consumer
readiness determines which complete unit can proceed after the hold; a
favorable estimator result does not choose the next condition or its R.

Schedule complete scientific comparisons with their controls, declared small
and larger N, all admitted methods and both SDs where specified. Do not wait
for every A/B cell before starting a ready C/D/E comparison, or fill small N
first and report large N as though already assessed. Allocate work across
replicates within the same source epoch without interpreting an unfinished
partial result as a completed study. A block can proceed only after its own
consumer/generator checks and source freeze; a new missingness-rate integral
or an unresolved structural interval does not authorize changing another
block's target. Fix an allocation revision before execution if resource review
requires one, recording its effect on scope or precision.

The **135,800 slots describe the selected map's planning burden**. They are
not a measured compute budget or a release fit-count target. No duration
is inferred from old four-condition timings. Starts/refinement, full covariance,
source checks, F's multiple priors/panels and replay are outside that slot count;
accepted sources and reused stages affect actual cost. The next execution
freeze must price complete comparison batches and their outputs. Retain
compatible per-stage time/memory records and distinguish calibration, numerical
qualification and scoring. Do not extrapolate a two-family historical fit time
to corrected JML, new facet patterns or all F panels. Resource review can
reorder ready comparisons without changing the declared conditions or R;
changing either requires an explicit scope/precision revision before launch.
Additional population-root sweeps and unsupported-output retries are not bundled into
this allocation. Precise confirmation remains separately sized from its own
claim, compatible variance/delivery evidence and fresh data; reaching these
descriptive counts cannot qualify a method or finish the release.

### Design feasibility before spending simulation repetitions

For each proposed design record N, the number p of free structural coordinates,
roster counts, ratings per owner level, category count, connectivity and current
API support. Derive capacity exclusions before fitting; actual identification,
solver behavior and covariance rank still require their own evidence.
For the current shared-owner corrected GPCM,
`p = sum_f(levels_f - 1) + owner_levels * (K - 2) + owner_levels - 1`.
The following are source-based integer counts, not simulations or timing runs:

| Proposed design (Criterion owns slopes and steps) | p / owner-total states per roster | Consequence for the current corrected-JML procedure |
| --- | --- | --- |
| Criterion=3, Rater=3, K=4; two raters per Person, L=1/2/4 | p=12; states `(1+6L)^3` = 343 / 2,197 / 15,625 | L=1/2 pass the 5,000-state count check only; L=4 exceeds it even at large N. The historical two-owner L=1/4 study has different state counts and is not invalidated by this example. |
| Criterion=3, K=4; all three versus all six raters per Person, L=1 | p=12 / 15; states `10^3` / `19^3` = 1,000 / 6,859 | The six-rater full panel exceeds the cap; so does L=2 with three raters. This does not exclude the six-rater roster with only two ratings per criterion per Person, whose state count remains 343. |
| Task=2, Criterion=3, Rater=3, K=4; two raters per Person-task | p=13; states `13^3` = 2,197 | If all nine ordered task-specific pair patterns are represented as fixed rosters at N=20, covariance rank is at most N-G=11<13, even when every group has at least two Persons. Point fitting is not excluded by this covariance count. Using only three repeated-pair patterns changes the allocation contrast; it is not a repair of the same design. |
| Task=4, Criterion=3, Rater=3, K=4; two raters per Person-task | p=15; states `25^3` = 15,625 | Exceeds the exact-state limit. Keep the multi-task question for other admitted methods and show this corrected-JML capacity gap. |
| Task=2, Criterion=5, Rater=3, K=4; two raters per Person-task | p=21; states `13^5` = 371,293 | Exceeds the exact-state limit. More criteria also change parameter burden and dependence risk, not just runtime. |

The six-rater paired design needs its own roster check: if all 15 rater pairs
appear at N=20, the at-least-two-Persons-per-fixed-roster requirement is already
impossible. This is independent of its admissible 343-state count. More Persons
can remove that count obstruction but cannot guarantee covariance quality.

For the nine-roster example the full exposure pattern defines a group; grouping
only by total number of ratings would be incorrect. These necessary conditions
do not predict coverage or guarantee any fit will succeed. Preserve the
separate observed-count memory guard. Do not silently raise limits, merge
rosters, drop owner levels, substitute random-roster covariance or duplicate
observed scores. An approximate correction would be a new procedure requiring
error control and validation, not a routine performance optimization.

Record both **coverage of the requested design domain** (including unsupported
models and capacity exclusions) and **performance among prespecified eligible
attempts**. Do not waste repetitions on an algebraically impossible output,
count an unsupported API as stochastic nonconvergence, or hide such exclusions
from the overall assessment of package usefulness.

### What must be frozen and what counts as a result

Each block needs one condition record linking the scientific question to its
method/source, response equation, truth or other estimand, identifiable scale,
facet/step/slope roles, N/exposure/roster rule, population/dependence mechanism,
extreme-response handling, numerical settings/retries, output and decision.
The A-E truths, specified contrasts, assignment laws and MML scale mappings,
and F's scoring targets, panels, numerical refinement and saved-reuse scope are
now recorded above, with an initial claim-to-evidence allocation. Calibration
settings, bounded refinement, output-stage selection, the future RNG allocation
and repetition-selection rules are now specified. Necessary interval-consumer
work, any new inferential gate, source bridges/final procedure snapshots,
executable fitting/scoring workflows, their selected-output adapters and
application-relevant margins
remain open.
The condition allocation and model-defined missingness rates are available;
A-E's actual input/stream freezes and generator checks are complete as
recorded above. Calibration and F settings
are prespecified choices, not newly validated computation.
The design specification is not an executable frozen protocol.
Use known generating
truth only for evaluation, never initialization or method/order selection
unless explicitly labelled as an oracle reference.

| Output/decision | Required result and denominator | Qualification rule to fix before confirmation |
| --- | --- | --- |
| Public structural point estimates | Bias, RMSE and tail error by prespecified contrast/parameter; probabilities on a common scale; finite/boundary/unavailable counts over all eligible datasets | State which scientific error matters. Report paired method differences on common eligible returned pairs alongside each method's full availability; never hide failures by reporting common successes alone. |
| Structural uncertainty, where a defined procedure exists | Empirical SD versus reported SE, width, conditional coverage among returned intervals, interval availability and returned-and-covered frequency over all eligible datasets | Name the interval and target. Local-root coverage, generating-truth coverage and public conditional precision are different outcomes. No universal logit tolerance or inherited old four-condition coverage margin. |
| Person scoring | Error by ability region, score availability and the coverage definition of actual returned bounds, for training and held-out Persons separately | Freeze the scoring rule/prior and whether calibration uncertainty is included. Many scored Persons sharing a calibration do not become independent calibration replications. |
| Design/capacity or interpretation limit | The precise failing contract and affected outputs, retaining valid points when only uncertainty is unavailable | Report supported domain, a concrete repair, an unresolved limitation or insufficient evidence. Successful optimization alone cannot mark a claim supported. |

Choose replications per scientific comparison from Monte Carlo precision, not
from the number of fit records. For a proportion q estimated from R independent
eligible outcomes, the planning MCSE is `sqrt(q*(1-q)/R)`; coverage among
returned intervals uses its returned count and requires an availability
allowance. R=500 gives about .0097 at q=.95 when all 500 are usable, not a
guarantee that a coverage-equivalence criterion will pass. Paired method MSE
differences need the variance of their within-dataset differences; use compatible
retained evidence for planning, with its uncertainty, rather than coverage's
binomial formula. Multiple parameters, orders or fits on one dataset do not
multiply the independent replication count. Any common random numbers across
conditions must be retained in between-condition uncertainty calculations.

Development screening and independent confirmation have separate roles and
data identities. A procedure changed after examining a result needs fresh
confirmation for the affected claim; unchanged compatible evidence is reused.
An inconclusive result remains inconclusive under the prespecified analysis;
do not add repetitions until a threshold passes. No new total budget or elapsed-
time estimate is claimed from the old four-condition timings.

### Ordered work and reviewable exit conditions

These are tasks within D1/D2, not additional release milestones. Progress is
assessed by their decisions and usable outputs, not by completed fit counts.

| Order / task | Concrete work and dependency | Exit condition |
| --- | --- | --- |
| 1. Common contracts and evidence map — A-F specifications, static source audit and expanded family allocation recorded | Carry the specified truths, workload contrasts, assignment laws, MML scale mappings, scoring panels and paired-data accounting into exact condition records; retain the A-E descriptive allocation and settle claim-specific confirmation separately. | Each retained claim has a comparison block, public/research procedure identity and evidence gap; unsupported or unstudied combinations explicit. No model is omitted merely because its results are inconvenient. |
| 2. Method-specific inferential decisions — native MML consumer and JML candidate-evaluation contracts specified; formal JML inference open | Preserve the two-family rank policy; retain the native model-Hessian extension, ordinary-JML profile/boundary bridge and corrected orders-2/4 research-candidate/paired-sensitivity specification. Residual-bias treatment for public structural intervals remains unresolved. Use existing derivations and adverse cases first. | For each claimed output: an unchanged justified procedure, a concrete correction with validation requirements, or an explicit unresolved scope decision. All agreed work stays visible; MML progress cannot close JML. |
| 3. Necessary implementation/output work — five native-consumer branch witnesses and selected-output accounting pass; sampling qualification open | Preserve the experimental native MML consumer's checked source/target and saved-output scope. Connect the prespecified execution stages to the accounting helper. Reuse corrected-JML full covariance/influences for labelled study contrasts, candidate bands and paired-order summaries; preserve source, target and refusal identity. Ordinary-JML covariance depends on its separate profile/centering decision. | Affected numerical/contract checks pass; help/NEWS describe actual functionality. One fixed-normal branch fit and deterministic accounting checks do not complete the sampling study. Internal research candidates are not counted as public features. |
| 4. Freeze the sampling protocol — expanded descriptive allocation and priorities specified; exact records, verification and costing pending | Complete source bridges, target-specific margins where needed, generator checks using the computed missingness rates and claim-specific confirmation allocations; verify the declared start/refinement/stream rules, then freeze source and price complete comparison batches and their outputs. | Each condition has a purpose, output identity and justified attempted R; shared inputs and all stages are counted correctly. Reuse decisions retain source/target identities, and the paused study remains separate. Any resource-driven revision states its scope/precision cost before execution. No fixed 2,000/3,000-fit quota or deadline-driven truncation. |
| 5. Execute and assess — held | Only after the no-computation instruction is lifted and tasks 1–4 are settled for that block/output: required preflight, affected checks, then resumable prespecified studies. Use fresh data for any confirmation after method tuning. | All planned attempts accounted for; bias/RMSE, tails, SE calibration, width, conditional coverage, availability and delivery reported by method/target/condition, with Monte Carlo uncertainty and adverse cases retained. |
| 6. Integrate claims and workflows — follows each settled result | Translate findings into supported scope, actionable failure explanations and the existing D2 acceptance table. G/D, MI and feedback retain their own targets and tests. | Supported user tasks work end to end; unavailable uncertainty is explicit without discarding valid points. MML/JML conclusions are consistent across results, plots, help, NEWS, examples and saved reuse. |
| 7. Complete D3–D5 — unchanged release obligations | Freeze assembled source, optimize retained calculations, perform required platform/package checks and publish only within authorization. | Match source-specific evidence and the existing check-time/platform/optional-dependency requirements; do not equate statistical-study completion with release completion. |

Dependencies apply to an affected output, not to every strand as a single
serial queue. **A-F now have generating/scoring targets, explicit comparison/
assignment rules, scale mappings and saved-reuse scope, with capacity and
identification exclusions retained.**
The current two-family MML interval gate remains the reference; a replacement
and formal JML structural intervals remain open method work. The missing
matched MML location-contrast consumer now has a native-scale, model-information
specification, implementation and passing checks on three retained fits;
qualification of the remaining supported combinations is open. The bounded
pilots and R=50 preparation do not close those gaps. Standardized/sandwich
extensions have separate unresolved targets.
**Remaining pre-execution work** is the other chosen method specifications,
the scoped consumer's remaining branch checks and any resulting fixes, numerical
source bridges and claim-specific confirmation allocations in the family
ledger, followed by exact condition/output records and review of the expanded
workload and comparison priorities.
The allocation registry and six model-defined missingness rates are now
available. Executable generators, the actual stream registry and affected
numerical preflight remain to complete before broad fitting. The new refinement workflow cannot inherit the old replay's
qualification without a matched-stage/source bridge. F uses the same
calibrations and its specified scoring panels;
its runtime is additional scoring work, not additional independent calibration
replications. Work on a settled
point/scoring contract can proceed without pretending an unresolved interval
claim is settled. This does not lift the present computation hold or remove any
agreed release requirement; proposed scope changes must remain explicit.

Primary scientific outputs are facet locations/contrasts, slopes where modeled,
category/response behavior and Person scoring. Coverage is evaluated only for
an explicitly defined interval procedure; research root intervals and current
screening SEs must not be relabelled public truth intervals. Automatic feedback,
model/order selection and consequential ranking require validation of their
complete decision rules, beyond component recovery. Method-specific unavailable
results, statistical boundary/weak-information outcomes, software defects and
capacity exclusions remain distinct. Neither convergence alone nor successful
execution at one large N closes D1.

## CRAN check-time budget: release prerequisite (D3/D4)

The retained August 25 incoming-pretest notification for 0.2.3.1 explicitly
reports `Overall checktime 12 min > 10 min`. Treat **600 seconds for the check
itself** as this package's submission ceiling, with a **480-second local target**
to leave headroom. Installation and build times are reported separately.
The [CRAN policy](https://cran.r-project.org/web/packages/policies.html) requests
minimal CPU use and feature coverage in retained checks; its public text does
not state a universal 600-second rule. The concrete threshold is supported by
this package's actual rejection. A previously accepted package or an `OK`
status above 600 seconds is not permission for another over-budget submission.

Retained observations, not measurements of the current development source:

| Source / environment | Install | Check | Static R-code analysis | Examples | Tests | Vignette rebuild | PDF / HTML manual |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0.2.3.1 incoming Windows, August 25 | separate | 701 s | 270 s | 82 s | 41 s | not separately timed | 45 / 38 s |
| rc.6 Win-builder R-release, September 26 | 128 s | 1,538 s | 309 s | 82 s | about 780 s (`13m`) | 27 s | 68 / 127 s |
| rc.6 Win-builder R-devel, September 26 | 133 s | 1,587 s | 356 s | 81 s | about 780 s (`13m`) | 26 s | 68 / 51 s |

Phase labels are rounded service timings; their sum need not equal the
notification total. Logs are in `validation-results/cran-preflight-20260926/`
under `winbuilder-R-release/` and `winbuilder-R-devel/`; notifications and
archive attribution remain in the [claim ledger](claim-reconciliation-0.2.4.md).
The older rejection evidence is in the workspace's
`release-candidates/cran-submission/2026-08-25/pretest-rejection-0.2.3.1/`.

The freshly retrieved [CRAN check page](https://cran.r-project.org/web/checks/check_results_mfrmr.html),
updated 2026-09-30 00:56 CEST, shows 0.2.3.1 r-devel Windows installation
107 s, check **638 s**, total **745 s**. Do not label 745 s as check-only time.
The [package page](https://cran.r-project.org/package=mfrmr) confirms version
0.2.3.1 published on 2026-08-25. Browser-search caches can show older checks;
verify the page's timestamp and version when refreshing this record. The
retrieved HTML and HTTP headers are retained under
`validation-results/roadmap-prerequisites-20260930/`.

The retained 0.2.3 archive has 147,801 lines in 81 R files; the development
checkpoint has 177,616 lines in 139 R files (about 20% more, including comments
and roxygen). This flags a measurement need, not a linear timing law: loaded
function/AST complexity, repeated analysis, R/codetools versions and hardware
matter. The rc.6 test phase alone exceeded 600 seconds, so static-analysis
optimization by itself cannot solve the observed problem.

Provisional phase allocations for the 480-second local target are: static
analysis 180 s, examples 45 s, tests 120 s, vignette rebuild 30 s, PDF/HTML
manuals together 60 s, remaining check phases 45 s. These are planning budgets,
not achieved results or independent acceptance thresholds; reallocate from
measured evidence while retaining the overall ceiling and headroom.

Required deliverable: one source/command/environment-bound timing table for
static analysis, examples, tests, vignette rebuilding, PDF/HTML manual and
other check overhead, plus install/build/check totals, CPU/elapsed distinction,
R/codetools/optional-package versions, thread settings and actual skips. Use the
built tarball with normal CRAN examples/tests/vignettes/manuals enabled and
`NOT_CRAN=false`; a `--no-tests`, `--no-examples`, `--no-manual` or partial check
cannot close this requirement. Distinguish the historical ordinary-example
profile from submission-relevant `--as-cran` defaults, including `donttest`
execution; do not silently change or equate their workloads.

Once the retained statistical procedure is fixed, the optimization sequence is:
reuse old logs → time the selected installed-package
tests by file with supported optional dependencies → remove repeated expensive
fitting from presentation/compatibility checks using valid synthetic fixtures,
while retaining small real estimation/uncertainty checks for every supported
feature → move genuinely long sampling/refit studies to the explicit complete
CI tier → profile measured static-analysis/manual bottlenecks and simplify
only proven duplication → rerun changed phases → run one assembled full check.
The September 30 runtime pass added the existing GMFRM EM/public-workflow and
corrected-JML public-workflow files to the CRAN selector after measuring them
with dependencies present. D2/D4 must still map all admitted features to an
exercised small check. Do not disable code analysis, hide failures,
remove all coverage of an optional model or use extra cores to evade the budget.

D3 needs measured source-matched local results and an evidence-backed path to
600 seconds on Windows. D4 needs actual matching Windows results below that
ceiling; a local 480-second result is not a cross-platform guarantee. If the
ceiling cannot be met, report the measured bottleneck and ask for a concrete
scope/engineering decision before submission. Any CRAN exception requires
explicit correspondence; it must not be inferred from 0.2.3.1 acceptance.

### Retained engineering checkpoint — further timing work follows D1/D2

Workspace identity is reconciled. The [September 30 runtime record](cran-check-time-20260930.md)
now identifies an installed baseline, measured repeated-calibration and
planning-table costs, targeted repairs, added model checks and the subsequent
archive-bound phase profile. The complete command took 468.66 s including a
rounded 27-second installation; check-only time is approximately 442 s, below
the provisional local 480-second target. The test phase took 230 s with 4,930
passes. Its undeclared-test-dependency warning was repaired through DESCRIPTION
and the matching dependency check; a second complete check is not claimed.
The metadata-only successor archive preserves all other 795 files. The subsequent
[Windows run](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36648663039)
at `4c32dd9e` took approximately **1,472 seconds of checking**, including
214 seconds static analysis and about 900 seconds of selected tests. Its
README assertion failure is repaired locally. Isolated diagnosis identified
a missing makeindex tool; after adding it, Windows generated the indexed
663-page manual successfully in 20.55 seconds. HTML math rendering was skipped
without V8 in the complete run; V8 is now provisioned but that check remains
unverified. This is not a clean or under-budget whole-check result. Retain these
measurements while resolving D1/D2; neither targeted Windows profiling nor
another assembled check is the immediate next task. Later, a test-only
optimization cannot leave adequate headroom, so reuse the manual evidence and
static-analysis profile as well. Local timing does not close the Windows ceiling
or qualify the unfinished statistical scope. New statistical work must answer
the prespecified D1 question; this priority change does not authorize an
unbounded new simulation grid.

The completed local optimization aggregates adaptive-MML category derivatives before
sparse projection. It preserves the finite-sum objective, mode/scale derivatives,
quadrature rules and admission tolerances. On one retained GPCM calibration,
three alternating before/after measurements reduced the local review median
from 4.367 to 3.395 seconds (22%). Independent gradient, covariance, scoring and
output checks pass; this is neither a whole-test-phase reduction nor Windows
qualification. No test was removed or mocked to obtain that speedup.
Per-function code-usage profiling found distributed cost across 2,401 functions;
the ten slowest accounted for about 6% of timed calls. A wholesale decomposition
of a few large functions therefore lacks evidence as the immediate remedy.
After the mathematical/statistical procedure and admitted workflows are settled,
obtain test-file timings on Windows from the installed package and map
the dominant tests to their required feature checks before shrinking fixtures
or moving repeated studies. Retain one real fit/uncertainty path per admitted
feature. Run the assembled Windows check only after affected measurements
support a materially smaller total; the remaining budget is still unresolved.

The next complete Windows measurement uses the existing check runner's `cran-timing`
profile and a Windows-only manual workflow dispatch, with manuals enabled and
RTMB >= 2.0/nleqslv present. The shared timing decision now requires the whole
check minus installation, including rounding uncertainty; the earlier
examples/tests/vignettes-only rule was insufficient. Its partial-log success
must not be reused. The runtime record also retains eight pre-existing
repository assertion failures. Their affected checks now pass after reconciling
the portable-scope wording, prose count and GPCM roadmap lookup: current
capabilities use this plan rather than the 0.2.2 supplement or unrelated
checklist counts. This closes those documentation inconsistencies, not D1/D2.

## Detailed D1/D2 evidence and release follow-through

The ordered task table in the [MML and JML validation plan](#mml-and-jml-validation-plan)
governs current work. The detail below retains requirements, implementation
history and source-specific findings; dated launch recommendations do not
override the common design review or the current computation hold.

**September 30 clarification:** the user prioritizes a general-purpose API,
not domain-specific operational products. Empirical writing, clinical and
sport cases are optional sources of counterexamples and design constraints;
they do not each require a bespoke end-to-end workflow or a new release gate.
Preserve the existing statistical claims and their mathematical checks.
Reuse model-generic fitting, integration, uncertainty and reporting APIs;
do not add a sports scoring engine or winner-selection API from an example.

### 1. Fix the inferential procedure and unresolved consumer decisions (D1/D2)

The first deliverable is a common model/estimator/output decision protocol
covering MML, ordinary JML and corrected JML, with method-specific inference
requirements and an operation-by-model review of remaining consumers. The
two-family MML protocol is one part of that work. Reuse current classes and
existing numerical witnesses. Do not create another wrapper or start a broad
coverage grid before the relevant protocol and computation plan are reviewable.

The protocol must identify component/scale targets, model/Wald versus explicit
profile roles, optimizer starts and restarts, integration-refinement policy,
source and endpoint failures, boundary handling, estimands and practical
acceptance criteria. Source-fit and profile iteration budgets are distinct.
A grid increase is an explicit refit; all triggered retries and their cost
belong to the evaluated procedure. Do not select favorable targets or discard
unavailable intervals after looking at results.

Determine which missing consumers need only a correct existing target and
which require new inference. Descriptive report/plot repairs proceed without
waiting for interval qualification. New-Person scoring, portable calibration,
individual sheets, maps and inferential diagnostics each need an explicit
contract; neither ordinary-model reuse nor relabelling is sufficient.

Exit: the procedure, sample-size/precision rationale, failure accounting and
consumer decisions are fixed before new independent evaluation. Unresolved
release commitments remain visible; a narrow experiment cannot close them.

**October 1 response-availability reporting:** a saved-result review found that
`mfrm_results()` labelled response diagnostics `available` regardless of their
unresolved rows. The retained adaptive writing case reproduced the same label
with 205, 1,369 and 1,370 available rows out of 1,370. Detailed rows were retained,
but the summary and first-screen wording did not distinguish those outcomes.

The shared `response_overview` table now counts selected rows, available
standardized residuals, unresolved calculations, missing scores, zero-variance
rows and source rows not selected. Counts come from rows, not overlapping facet
groups. Native RSM/GMFRM, corrected-JML and extension result statuses use these
counts. Partial/subset/zero-variance results require review; entirely unavailable
residual output remains unavailable. Corrected-JML limiting point masses retain
their defined raw quantities and are not counted as failed probability calculations.
Two-family and extension report first screens expose the counts and status.
Complete residual availability still means descriptive output, not model adequacy.

Response-diagnostic, GMFRM, corrected-JML, ordinary-versus-extension comparison,
extension-results, individual GMFRM feedback and adaptive-workflow checks passed.
Updated response-diagnostic help parsed and rendered without warnings; the
diff whitespace check passed. No full package/platform check was repeated.
Tests include
missing and unselected rows, complete failure, zero variance and older saved
GMFRM results without the new overview. The three retained adaptive outputs
were collected with matching saved slope intervals and all seven rater sheets;
the 121-point output retained finite descriptive means for all seven raters.
Fresh-process reports, plots, rater sheets and CSV overview values matched with
fitting, probability integration and interval calculation disabled. Original
artifact hashes, fitted points, residual rows and numerical thresholds were
unchanged. The earlier fixed-grid 318/1,370 result remains separate evidence;
the public roadmap now acknowledges the already-resolved adaptive numerical case.

Legacy replay is now covered as well. Previously, an old `mfrm_results` object
without `response_overview` could show its saved `available` status in
`summary()` while the current report correctly showed unresolved rows. A shared
compatibility step reconstructs only the missing overview, response status and
table index on a local copy before summary, report, HTML, export or native-viewer
preparation. The original object and file are unchanged; a newly exported RDS
includes the recovered display metadata. Existing overviews and results without
response diagnostics pass through unchanged.

The original fixed-grid writing RDS reproduced the mismatch and now reports
318 available and 1,052 unresolved rows consistently. In a fresh process with
fitting, residual integration and inference disabled, summary/report/viewer
payload/HTML/CSV/new RDS/replay agreed, while original fit and diagnostic objects
remained identical and the input-file hash was unchanged. Additional response,
GMFRM, corrected-JML, ordinary-versus-extension comparison, general-results and
extension-results tests passed. They cover old records with missing scores,
selected subsets, all-unavailable residuals and zero-variance rows, as well as
idempotent restoration and preservation of the caller's object. This does not
add Shiny support for extension classes or upgrade pre-rendered historical files.

The frozen 400-case MML reader was inspected without interim aggregation:
conditional coverage uses returned intervals, delivery uses all attempted
datasets, and paired comparisons retain dataset pairing and both-available
strata. This reporting repair neither changes that procedure nor qualifies
coverage. Additional corrected-JML evaluation remains paused; D1/D2 remain open.

**October 1 two-family location/contrast intervals:** the existing
`mfrm_facet_intervals()` now accepts native two-family MML with `method = "model"`.
The first owner's locations remain sum-centered and the second uncentered on
fixed N(0,1). Named within-facet contrasts use the fitted constraint map and
the location block of the inverse **full** marginal information; other locations,
steps and slopes remain estimated nuisance parameters. Source identity, category
support, stable Person-score rank, stationarity, inverse accuracy and finer-grid
checks reuse the existing complete-covariance gate without relaxing thresholds.
Failures retain fitted points, missing SEs/bounds and reasons, even if the
original information was invertible. Constraint-fixed targets have no interval.
No fitted parameters, global readiness or inference decisions are overwritten.

The 240-Person joint-information fixture independently checks both location
maps, named/reordered and reversed contrasts, their covariance terms and the
fixed sum. It distinguishes inversion of full versus location-only information
and independent-SE addition. Shared level labels under non-English owner names,
source mismatch, unsupported methods, failed source/refinement checks and
unavailable output propagation are covered. Existing facet, slope, public-model,
reporting, feedback and guide regression checks were reused. Initial new-test
failures exposed a missing default plot reference line of text, attribute-only
expectation mismatches, an overly broad CSV file selection and a test cleanup
that replaced mock restoration; these were corrected before final verification.
Final targeted checks passed for the new location route, RSM/PCM facet intervals
and reporting, two-family public workflow/slope intervals/recipient sheets,
GPCM inference reporting/capabilities, output/plot guides and example policy.
The capability checks ran with `NOT_CRAN=true`; the earlier CRAN-mode skips are
not used as evidence for those routes. The default base location plot was
rendered and inspected, and changed help topics parsed/rendered without warnings.
No full package/platform qualification was repeated or claimed.

The retained adaptive-start case `001-common_persons-1.rds` supplied a separate
actual direct-adaptive check without refitting: all 22 free coordinates passed
the source/full-information checks, with 31/61-node covariance change
2.63e-12 and standardized score shift 7.46e-10. The first-rater location and
first-minus-second contrast had SEs .152172 and .192584. These are numerical
witnesses, not coverage evidence. A fresh process reproduced its saved tables,
plot payload and report with fitting/information/inference calls disabled.
CSV values, source checks and contrasts are retained by the existing results
and report routes; base and ggplot labels use fixed-N(0,1) location units and
state experimental status. Individual sheets still display slope intervals
only and direct location/contrast inference to the analyst report.

Location or location-difference coverage remains unqualified. Slopes and step
profiles can differ between raters, so a location contrast is not a uniform
expected-rating difference or a competence claim. This adds no sandwich,
profile, simultaneous, curve/step or selection inference and no coverage study.
The component-only 400-case matched protocol is unchanged and cannot qualify
these targets; D1/D2 remain open and corrected-JML evaluation remains paused.

**October 1 G/D saved-output context:** review of the existing dedicated route
found that D-study printing omitted composite weights, while a saved paired
comparison lacked the source design and row accounting. D-study/comparison
printing now separates observed source pools and used/omitted rows from
complete future plans and prints the unnormalized score weights. Comparisons
retain a small source-design/row-count record without ratings or identifiers;
older saved comparisons report absent source context and remain readable.
Summary tables, coefficients, interval calculations and plot values are unchanged.
Help and the output guide distinguish complete RDS objects from table-only CSVs.

The multivariate G-study, nested G-study, paired-comparison, D-study plot and
output-guide tests passed. Their existing independent component/covariance
checks were reused; new checks cover source/future count separation, signed and
named weights, explicit omitted rows and older saved comparisons. A fresh R
process reproduced print, summary and plot data exactly with G-study, D-study
and interval calculation disabled; coefficient CSV round-trip values agreed.
This reused the existing crossed test fixture and the workflow's installed
`sirt::data.ratings1`: 135 Persons, seven observed raters, all 274 rows and five
fixed score columns, fitted by one-facet MINQUE(0), with equal score weights
and complete future plans of two/three/four common raters. One of three source
component matrices was non-PSD; its warning and the separately calculable
metric values were retained. This is an output/replay check, not validation of
the random-rater assumptions or a recommendation based on those projections.
No new simulation or generic report wrapper was added. The matched MML replay
had 356/400 records and no final summary at this checkpoint; corrected-JML
evaluation remains paused and D1/D2 remain open.

**October 1 individual two-family feedback:** the existing
`mfrm_report(res, style = "rater", facet = ..., rater = ...)` now accepts
native two-family GPCM MML for either explicitly selected slope owner. It
separates location and component slope and their different references, shows
category-step offsets only for the step owner, and describes retained exposure
and observed counterpart levels without treating them as planned completion.
Optional saved component intervals retain their experimental method, confidence
level, multiplicity and unavailable endpoints. Location/step intervals and
calibrated rater-quality, training-effect or comparison decisions remain absent.

Saved posterior response rows supply descriptive residual summaries and cases,
with available, unresolved and not-included rows counted separately. A mean is
unavailable if any saved row for that recipient is unresolved; the first notice
states unresolved or subset status. Same-data conditioning and excluded
calibration uncertainty remain explicit. Object, tables, Markdown and standalone
HTML contain selected numeric fields and fixed prose, without source fits,
Person/other-facet identifiers, original row numbers or free-form source notes.
Explicit labels and recognizable rating patterns still require review before
distribution. Existing RSM/PCM sheets and the renderer are reused; reporting
does not fit, integrate or create intervals.

Validation: `gmfrm-rater-feedback`, `rater-feedback`, `gmfrm-public-workflow`,
`gpcm-capability-matrix`, `output-guide` and `example-policy` passed. Cases cover
both owner roles, matching/ambiguous/unavailable intervals, interval-label
inconsistency, partial and missing diagnostics, arbitrary non-English column
names/shared level labels, private-field stripping, HTML escaping and
fresh-process replay with fitting/integration disabled. The new test file is in
the representative CRAN selector. Updated Rd files parse/render; the final
source-based Rd regeneration completed without warnings and extraneous changes
were removed. Chrome visual inspection caught a wide table; interval/residual
fields now render vertically and the inspected tables fit their cards.

The saved empirical writing results were reused without refitting: all seven
rater sheets retain the 1,370 saved rows and 1,052 unresolved response rows;
all seven residual averages remain unavailable. The selected empirical HTML
also visibly retains the unavailable slope interval and unresolved-row notice.
This verifies an honest reporting route, not the suitability of those numerical
results for substantive feedback. No new study or full package check was run;
D1 and the broader D2 outcome remain open.

**October 1 saved-score attachments:** `mfrm_results(fit, scores = scores)`
accepts two-family `predict_mfrm_units()` output and format-6 portable scores.
The shared extraction/scoring source check now saves an exact source fingerprint
using the existing serialization/fingerprint helper. It binds the fitted
parameters, data, owner/category coding, integration controls, displayed point
tables and readiness record without adding training responses to a portable
file. Collection compares that saved identity, not a newly computed likelihood
or scoring result. Older output remains readable standalone; attaching it
requires regenerating scores and, for older portable files, re-extracting the
calibration from the saved fit. Refitting is unnecessary.

The result retains the complete score object plus unrounded `person_scores`
and `scoring_*` tables. Source and batch checks, conditional interval meaning,
review-only estimates, row omissions and portable not-scored/row-disposition
records flow to reports, CSV and saved replay. Native omission counts do not
enumerate a not-scored roster, so that count remains NA. This is a table/report
attachment, not a new score plot. Inconsistent saved tables/components/status
are refused by summary, report, plot and export before export files are written.
No calibration uncertainty, coverage or population-transport claim is added.

The subsequent saved-output review fixed two reproducible inconsistencies:
changing the interval-level setting could relabel existing bounds, and changing
saved calibration coordinates could still permit attachment through the retained
source fingerprint. Native and format-6 readers now compare interval labels with
the saved score rows; format 6 also checks its recorded algorithm and quadrature
order against the frozen scoring basis. Attachment compares actual calibration
values, owner/category coding, constraints and observed contexts with the supplied
fit, without likelihood evaluation or rescoring. Deliberately requesting a new
interval level through scoring remains supported. An internally valid artifact
with an edited free slope cannot be attached to the original fit.

The follow-up `gmfrm-scoring`, `gmfrm-portable`, `gmfrm-scoring-results` and
`example-policy` tests passed, including rounded summaries, non-default/named
interval levels, arbitrary column names, review-only and all-missing outcomes,
and fresh-process replay. The three scoring files are now included in the
representative CRAN test selector. This is source-level regression evidence,
not a completed assembled-package or timing check. The matched MML replay
continues; the additional corrected-JML study remains paused.

Validation passed: `gmfrm-scoring-results`, `gmfrm-scoring`, `gmfrm-portable`,
`gmfrm-public-workflow`, `gmfrm-adaptive-workflow`, `extended-results` and
`gpcm-capability-matrix`. Checks include different-source refusals, old-output
compatibility, source-review and batch-review cases, all-missing portable
Persons and deliberately inconsistent result tables. Fresh-process replay and
CSV preserve numerical values (tolerance 1e-13), interval/prior labels and IDs
such as `001`, `1` and literal `NA`, while fitting, scoring and integration are
blocked. Updated help parses/renders and `git diff --check` passes. A full
assembled-package check was not run; statistical qualification remains open.

**October 1 portable two-family scoring:** format 6 extends the existing
extract/validate/freeze/save/load/score lifecycle. It stores ordered slope
components, first-owner location/log-slope centering, free second-owner
locations/slopes, second-owner centered steps, original categories, fixed
N(0,1) prior and passing extraction evidence. Observed facet combinations and
default input mappings are included in the semantic identity. No training
responses, Person estimates or executable fit is stored. Existing formats
1--5 retain their meaning; readers without format 6 reject it.

Extraction requires the fitted-object source checks to pass. Stored evidence
is validated on replay, without claiming a fresh source-data check. Every
new batch must independently pass the existing EAP/SD integration criteria;
there is no review override. New combinations of known levels are allowed and
flagged in `row_dispositions$ObservedContext`. Prior overrides, repeated-event
extensions and nonunit weights are refused. Missing-response omission is
explicit, and all-missing Persons are retained as not scored. Reserved
scoring/disposition names cannot be used as portable facet names. Constraints,
coordinates, category codes, evidence and source-column identity are checked
before lifecycle transitions and scoring.

Validation: fixed and adaptive portable scores agree with fitted-object scores
at tolerance 1e-10; the fixed-grid example also agrees with independent literal
response-equation integration at tolerance 1e-7. Tests cover arbitrary owner
names/order, unseen pairs, missing responses, structural/evidence corruption,
lifecycle refusals and insufficient integration. A fresh R process reproduces
the saved-artifact result with fitting and source-data operations blocked.
The summary printer's missing engine record was repaired and verified.
Affected native workflow/capability tests and legacy schema, scoring, lifecycle,
one-family GPCM and corrected-JML portable tests passed. Direct installation
and the installed public CSV/fresh-process tests passed. That installed test
run had two documentation assertions fail because direct `R CMD INSTALL`
does not bundle the vignette Rmd; the source documentation test passed. The
source run skips the installed-only replay, which was verified separately in
the installed run. Updated help files parse/render and `git diff --check`
passes. This is affected-workflow evidence, not a full `R CMD check` or final
assembled-source qualification.

This completes portable fixed-calibration computation, not the unfinished
statistical qualification. The saved-score attachment extension is recorded above.
Calibration uncertainty, global identification, boundary absence, population
transport and sampling coverage remain outside the available claims. The
matched MML replay continues and corrected-JML remains paused.

**October 1 new-Person scoring:** the existing `predict_mfrm_units()` route
now implements the conditional posterior target with both slope components,
the original locations/second-owner steps and fixed N(0,1) prior. Unit weights,
known levels and original category codes are required; repeated Person-facet
rows and prior/population overrides are rejected. Missing rows are reported
and omitted; no prior-only score is supplied. New combinations of known levels
use component products without changing the fitted crossing design. Default
column mapping uses owner names, including when the original `facets` argument
has a different order from `slope_facet`.

Admission reuses the saved-calibration identity/convergence check and compares
the fitted integration with a finer rule: NLL change per calibration Person
and maximum absolute refined gradient per Person must each be at most 1e-6.
These are numerical criteria, not statistical qualification. Source failures
require explicit review; corrupt calibration or failed convergence cannot be
enabled by review. Every batch independently compares reported EAP/SD with two
adaptive reference orders at the existing 1e-5 tolerance. Continuous posterior
quantiles reuse the shared CDF integration, including its omitted-tail bound.
Calibration covariance is neither required nor propagated.

Tests compare the reported EAP, SD and interval endpoints with a literal
two-family response equation and independent scalar continuous integration;
they cover extreme scores, partial assignments, arbitrary owner names and
new crossings. Saved score objects retain both owner roles, calibration values,
category coding and separate source/batch checks. The existing plausible-value
wrapper retains the same qualification for discrete posterior draws. This is
a fitted-object implementation, not held-out predictive validation, a portable
calibration implementation, or completion of D1/D2. The portable extension is
recorded above; broader statistical claims remain open. No additional
large study was started; corrected-JML remains paused.

Validation passed: the complete two-family scoring and adaptive-workflow
test files; public workflow and capability-matrix tests; existing prediction,
conditional-scoring and scoring-prior regressions. A fresh R process reproduces
scores from the saved fit while fitting/covariance functions are blocked, and
summarizes saved scores while integration is blocked. Help files parse/render
and `git diff --check` passes. This is targeted implementation verification;
no new population-coverage or held-out prediction study was run.

**October 1 consumer repair:** `mfrm_results(fit)` now collects saved
two-family estimates and numerical status by default; omitted/NULL/empty
`include` selects fit/plot sections. Both computation policies avoid new
diagnostic calculations, and explicit unsupported requests still fail.
Bare-result replay now saves/reloads the complete object, preserving source
settings and unresolved status without requiring a separate in-memory fit.
Complete non-Person slope, location and step tables now follow the saved fit
through results, reports and CSV/RDS export. Location constraints, step owners
and unavailable intervals are explicit. The existing empirical writing fit
retains all 12 locations and 21 steps: the report's 20-row display limit is
disclosed, while both results/report CSVs retain every row. This was checked
without refitting; old result objects can regenerate these report tables from
their saved fit. Fixed-grid public workflow, the adaptive fitting/output case
and one-family inference reporting regressions pass.
The fixed-grid/adaptive workflow, ordinary results and GPCM reporting tests
pass, including export/replay and checks that saved-output paths do not refit
or integrate. This closes the default results-entry gap, not D1/D2 or any
new inferential claim. The additional corrected-JML study remains paused.

Two-family summary/HTML guidance now distinguishes unsupported ordinary
diagnostics from missing computations and respects the plot registry's
required-figure flag. `plot(res)` and `as_ggplot(res)` use the sole available
saved display; multiple displays require an explicit type, and absent plots
give attachment guidance. Existing unavailable bounds and plotted data are
preserved without refitting. Public workflow, response-diagnostic replay,
GPCM reporting/owner-summary and ordinary readiness regression tests pass;
ordinary required-Wright-map warnings remain intact.

#### Practitioner questions and empirical design anchors (September 30)

The user requires realistic use settings in addition to parameter recovery
and coverage. These are linked requirements, not competing priorities. All
nine packaged score datasets are synthetic; the `ej2021_*` names do not mean
empirical TestDaF records. The principal completed two-family study used 240
Persons, 3 tasks, 6 raters, 0–2 scores, no assigned missingness and assignment
independent of normal ability. Its common-Person and rotating-pair comparison
is useful but does not qualify a typical real assessment workflow by itself.

| Applied anchor and question | Evidence / current restriction | Required next decision |
| --- | --- | --- |
| Empirical Austrian writing assessment (`sirt::data.ratings1`, sirt 4.2.133): which category-use/response-sensitivity patterns merit rubric or rater review? | All 135 Persons, 7 observed raters, 5 criteria and 1,370 ratings retained. 89 Persons have one rater, 27 two, 2 six, 17 seven. There are 29 observed roster patterns (13 singletons), 9 unused rater factor levels and 5 empty rater/criterion/category cells. A planned roster is unavailable. Native two-family fits at 61/121 nodes converge but curves/diagnostics remain numerically sensitive. | Resolve the observed approximation/solution sensitivity before substantive feedback or a new large simulation. Preserve conditional independence, single-ability, population and step-owner questions; do not call the more complex model preferable merely because it fits. |
| Medical interview OSCE: review rubric-specific rater behavior in a small cohort with two common raters and three subgroup raters. | Uto et al. (2024), DOI 10.1371/journal.pone.0309887; Dryad DOI 10.5061/dryad.tmpg4f56q describes 30 Persons, 5 raters, 30 rubric items and four categories. The downloaded scores remain unavailable (HTTP 403); only the published design was reviewed. Its rater/item interactions and item-owned steps exceed the current two-family model. | Retrieve/verify the public data through an available legitimate route and reconcile its coding/assignment before fitting. A restricted fit is not replication of the published extension. Do not add a model merely to make this dataset fit. |
| Judged sport: could an apparent measurement improvement change a championship decision? | Official 2026 Olympic women's skating protocols: 29 short-program and 24 free-skating performances; 9 judges per segment, 13 distinct judges, 5 shared; 3 components and 1,431 component marks. All 53 PCS and 24 final totals reconstructed, retaining published technical scores. No GMFRM fitted and no winner inference qualified. | Separate rule-based results, latent ability and future-performance winners. Preserve actual judge IDs, segment effects and advancement. Require decision-specific uncertainty/loss before any selection claim; the present two-family model cannot absorb all these roles by relabelling. |

The empirical writing runner is `gmfrm-practitioner-20260930.R`; its evidence
is recorded in [the existing GMFRM review](gmfrm-mml-em-20260927.md#september-30-empirical-practitioner-workflow).
The observed network is connected. Still, the 61/121-node fit comparison changes
conditional category probabilities by up to .169784 on the same grid (also
within [-2,2]). The 61-node calibration's 121/243-node response check returns
318/1,370 rows, and no group has a complete Infit/Outfit summary. Every row
from Persons with six/seven raters fails that numerical check. This association
does not prove its cause. It makes concentrated within-Person information a
necessary integration challenge alongside sparse overlap. Increasing the grid
or relabeling a failure is not automatically a validated remedy. Source fit,
integration at fixed parameters and a changed local solution must be separated.

Before the next independent simulation, freeze a small set of question-led
paired scenarios using the observed writing roster as a **design template**.
Its absent cells are observed omissions, not a declared future assignment or
a known missingness mechanism. Generated responses must have a separately
documented model, truth and seed; empirical fitted parameters are not known truth.

| Practitioner question | Prespecified contrast to add to the evaluation protocol | Decision-relevant evidence beyond recovery/coverage |
| --- | --- | --- |
| Is allowing two slope families useful for this rubric? | Equal slopes, one varying family and both varying families on the same rating rows; match response equation, population/scale and category-step ownership before comparing methods. | Stability of category probabilities/expected scores in observed contexts and which apparent feedback differences remain uncertain. No automatic AIC/LRT ranking until that consumer is qualified. |
| Is the link dependent on a few commonly rated Persons? | Original roster versus a cost-matched redistribution of repeated ratings; separately remove a common-Person bridge. Distinguish common Persons/common raters from fixed parameter anchors. | Within-Person exposure, overlap distribution, available facet contrasts and impact of losing links. Preserve disconnected/unsupported results in the denominator. |
| Could intake allocation masquerade as a rater effect? | Independent allocation baseline, then ability-associated allocation with prespecified group means/SDs; include SD .5/1/1.5 with the appropriate scale transformation. Separate nonnormality from assignment changes before combining them. | Spurious severity/slope differences and population-assumption sensitivity. Do not interpret an effect as training need solely from an observational roster. |
| Are rare categories or the same-performance rubric structure driving results? | Empty/rare tail categories, category compression, and a declared Person-by-performance dependence term in separate misspecification conditions. Retain the original score ladder. | Output availability, category-probability calibration and sensitivity of feedback. No truth-coverage label for a fitted component without a matching estimand under misspecification. |
| What happens when a planned rating is not collected? | Begin with an explicit planned roster, distinguish unassigned cells from assigned score missingness, then compare score-independent and score-dependent omissions. | Complete-row retention, missingness disclosure and sensitivity of available outputs; no filling unassigned cells and no implicit GMFRM MI support. |

This is a question/contrast specification, not permission to cross every factor
into a large grid. Select the contrasts that can change the admitted practitioner
claim; freeze numerical procedure, values, estimands, loss/accuracy criteria,
repetitions/MC precision and computation estimate before sampling. Report failures
and output availability by exposure/roster/category support, not just averaged
over a dataset. Hold out a complete Person for new-Person prediction only if
that scoring route is supported; same-data posterior residuals cannot count as
held-out accuracy. No pass/fail or rater-competence accuracy can be estimated
without a defined decision rule and an appropriate reference target.

**Exit conditions (clarified September 30):** each retained general API claim
has a mathematical target, an explicit numerical procedure, relevant
simulation/independent numerical evidence and consistent output semantics.
Reuse empirical examples where they reveal a failure condition; domain
coverage is not an additional completion requirement. A real-data fit cannot
establish coverage, and simulated recovery cannot establish the truth of an
empirical model. The writing case identifies a general concentrated-posterior
integration problem to resolve before optimization; it does not require a
special writing-assessment API.

**Fixed-parameter progress:** the existing adaptive quadrature review now
accepts the two-family crossing specification through
`mml_quadrature_sensitivity(..., adaptive_quad_points = ...)`. No new public
function or numerical kernel was needed. Both saved 61/121-node calibrations
were checked at all 135 Persons against literal continuous integration;
61-node adaptive log-integral and moment discrepancies were below 2e-8 and
8e-8 respectively. Fixed-grid errors reverse the likelihood ordering of
those two saved calibrations. This isolates an integration error without
refitting, but does not identify the accurately integrated optimum or promote
interval eligibility. Next mathematical work must qualify the calibration
procedure against accurate integration before another coverage study;
diagnostic posterior moments do not establish two-family Person scoring.

**Calibration progress:** two-family moving-node gradients now pass independent
Richardson differences for binary and polytomous responses, incomplete crossings,
non-default owner names, and orders 1/3/15. Reusing the existing direct optimizer
and adaptive evaluator, both saved EM starts at adaptive order 31 and the
public neutral-start fit at order 61 converge to nearby solutions: maximum
free-coordinate difference below 3.7e-6 and common continuous NLL 1177.482535.
All 135 Person integrals were compared against a literal continuous reference;
maximum log-integral discrepancy was 2.31e-8 at order 61 and 1.52e-11 at 121.
The retained local Hessian is positive definite; this is not a global solution,
boundary, sampling-coverage or model-adequacy certificate.

`fit_mfrm(..., mml_engine = "direct", mml_integration = "adaptive")` now uses
that existing evaluator with the same two-family model. Engine/integration,
replay, summaries, conditional curves, reports and order-sensitivity refits
are preserved. Fixed-grid EM retains its existing interval and diagnostic
scope. Adaptive component log-Wald and posterior residual qualification are
recorded below; adaptive profiles remain unavailable explicitly.

**Observed-information progress:** the retained neutral-start adaptive-61 fit
now supplies experimental component log-Wald intervals through the existing
`confint()` API. All 36 free-coordinate scores and full observed information
were compared with an independent literal-response/Louis calculation at order
121, retaining every location, step and cross-family term. Standardized
information discrepancy is 2.94e-6 or smaller; maximum Person-score error is
9.47e-10. All 12 component intervals pass the unchanged local numerical checks.
The 61-to-121 standardized score displacement and covariance change are 8.32e-8
and 3.16e-7. This is numerical qualification of a local approximation on reused
data, not coverage, global-identification or model-adequacy evidence.
The independent oracle also checks binary/four-category incomplete crossings;
saved interval/report/export identity and low-order rejection have regression
coverage. Adaptive profiles remain blocked explicitly because their constrained
search evaluator has not been qualified for moving nodes. The fixed-grid EM
profile route is unchanged.

**Posterior-residual progress:** `mfrm_response_diagnostics()` now accepts
adaptive direct two-family fits, using fresh adaptive source-likelihood/gradient
checks and the shared adaptive integration basis. Selected output rows retain
their complete Person conditioning records. The unchanged 1e-7 row-wise
probability check compares q with 2q+1; failures remain in group denominators.
Reusing the saved 135-Person, 1,370-rating calibration, orders 7/61/121 return
205/1,369/1,370 rows, and 0/10/12 complete criterion/rater groups respectively.
All 1,370 rows were checked with independently coded literal continuous
integrals; the adaptive-121 maximum probability/variance errors are 9.87e-14
and 4.13e-13. At exactly the same calibration, fixed orders 121/243 return only
251 passing rows and have maximum high-order probability error .003544.
This separates integration error from a change of fit and does not replace
the historical fixed-fit result (318/1,370 at a different calibration).
Saved complete and partial results retain their source, settings, rows, groups,
plots and report meanings without reintegration. See the
[residual record](gmfrm-mml-em-20260927.md#september-30-adaptive-posterior-residuals).

#### Retained adaptive interval procedure: fixed before feasibility replay

The neutral-only initialization below records the first September 30 protocol.
It is superseded by the dated initialization revision later in this section;
the targets, interval gates, conditional quadrature rule and failure accounting
remain unchanged. Both executed procedures keep their own source snapshots.

**Decision and target, September 30.** Evaluate the public adaptive direct MML
procedure below for pointwise 95% intervals on *all* identified component
slopes. The first family's log slopes sum to zero; the second family's slopes
are free on the fixed N(0,1) scale. Use the full observed marginal information
and the existing Jacobian for the constrained family. Products, curves,
contrasts, simultaneous rankings and Person intervals are different targets.
In the retained SD=.5 scenario the second-family truth is multiplied by .5,
while locations/steps are divided by .5. This is a correctly specified scale
change, not a misspecification experiment. No fitted estimate supplies truth.

**Observable algorithm.** Every dataset starts from the public neutral start
with `optimizer="BFGS"`, `maxit=500`, `reltol=1e-10`,
`mml_engine="direct"`, `mml_integration="adaptive"`, and 31 points. Preserve
the declared zero-based category ladder, owners, unit weights and original
observed roster. Request `confint(fit, method="model", level=.95)` for all
components without multiplicity adjustment. The package's existing gradient
polishing is part of the procedure: if code zero has an excessive gradient,
it tries the fixed sequence 1e-11, 1e-13, 3e-14, 1e-14 from the selected
parameters, each with the 500-iteration stage cap, stopping once the gradient
review passes. This is up to five optimizer stages per fit, not a 500-iteration
total budget. BFGS does not trigger the L-BFGS-B fallback; adaptive integration
does not trigger the fixed-grid curvature restart. Save every stage and cost.

If the interval object's **only** failed check is `Quadrature sensitivity`,
refit once at 61 points from the public neutral start and reapply every check.
The same rule permits one final neutral-start refit at 121 points. Each fit's
information/score comparison is q versus 2q-1 at unchanged parameters. Select
the first stage passing all checks; otherwise retain the final attempted fit
and missing intervals. A failure of any other check, an exception, an iteration
limit or failure at 121 stops the procedure. There is no external optimizer
restart, truth-based start, profile fallback, target selection, clipping,
regularization, tolerance relaxation or retry chosen from estimated coverage.
Each retry is an explicit changed calibration; retain all earlier attempts.

The numerical gates remain exactly the implemented ones: adequate categories,
source identity/convergence, positive unregularized full information, stable
full local score rank, fresh per-Person score at most 1e-6, standardized Newton
displacement at most .01 (warning above 1e-4), inverse residual at most 1e-6,
and refined-grid score displacement/covariance change at most .01. Interval
availability does not prove a global interior maximum. Near-zero/infinite
slopes, weak curvature and source/endpoint failures remain separately visible;
do not introduce an arbitrary positive slope floor to make intervals available.
An unavailable covariance does not erase a finite converged point estimate.

**Bounded execution check.** Before an all-case replay or independent sampling,
reuse the first two saved replicates of all four September 28 conditions
(common Persons/rotating pairs crossed with SD=1/.5), plus rotating-pair
SD=.5 replicate 26, the retained near-zero-slope example. These nine jobs are
fixed before adaptive results are inspected. No data generation, new seed,
winner/rater decision or coverage qualification occurs in this check. Its
purpose is to exercise the full procedure, preserve refusal behavior and
measure realistic cost, including Hessians and retries. Refine integration
only under the rule above. The runner also checks the retry decision against
synthetic check tables (pass, quadrature-only, mixed failure and terminal order).
Exit when all nine source-bound records, dispositions and costs are retained;
numerical failures count as completed observations, not jobs to replace.

**Statistical accounting and next gate.** A subsequent matched replay would
use all 400 previously generated datasets, including already successful and
failed cases, with the frozen procedure. Keep baseline/revised estimates,
intervals and failure reasons paired by dataset. Report all nine components
separately: point convergence, interval availability, bias/RMSE, empirical
log-estimate SD versus root mean log variance, log width, coverage among
returned intervals, and returned-and-covered frequency among all attempts.
Show both all-converged and interval-returned point-estimate denominators;
otherwise conditioning can disguise a change in sampling variability. Paired
availability/coverage differences use the dataset as the independent unit.
An unavailable interval is not counted as observed conditional noncoverage.
No pooling of slopes within a dataset increases the replication count.

**October 1 completion and current decision:** all 400 matched records and
summaries are saved (11:43 JST). Adaptive intervals are available on 399/400
datasets, versus 310/400 revised fixed-grid EM and 95/400 historical strict EM.
The additional 89 are common-Person SD=1 cases; all shared-returned coverage
indicators are unchanged. Source/input/result identities and all 108 summary
rows were checked. Numerical availability is substantially improved, while
finite-sample inference remains unresolved: Task t3 in common-Person SD=1 has
90/100 coverage and RMS model SE / empirical SD .850; a near-zero Rater r4
estimate in the single refused dataset materially changes the all-point SD
relative to the returned subset. Keep both denominators and the refusal.
See the [completed review](gmfrm-mml-em-20260927.md#october-1-completed-matched-replay-and-independent-study-decision)
for bias, RMSE, width, Monte Carlo bounds and the paired comparison.

**October 1 first scope revision (subsequently superseded below):** the prepared four-condition,
500-repetition study is held, not the current launch recommendation. It would
estimate performance precisely at N=240 but would not establish a sample-size
range or expose several relevant rating-design failures. Retain its immutable
inputs/source as an unexecuted proposal. The completed 400-case replay remains
exploratory evidence, not independent confirmation.

The first replacement proposed a staged design: 12 core conditions
(N=120/240/480 x ability SD=.5/1 x the two existing rosters), plus 12 targeted
conditions for N=60, SD=1.5, task/rater counts, unequal exposure, weak bridges,
weak slopes, rare categories and a matched pair of writing-roster templates.
See the [revised design and execution gates](gmfrm-mml-em-20260927.md#october-1-revised-scenario-design)
for exact contrasts, exclusions and replication precision. The core screen
reuses the four existing N=240 cells and proposes 100 replicates in each new
cell: 800 new core fits, then a separately budgeted 1,200 targeted fits. These
were intended as diagnostic screens, not nominal-coverage qualification. This
proposal is now held. `gmfrm-design-screen-20261001.R` implements
the scenario generator and no-fit preflight; it is not a study runner.

The eight new core timing cases completed at 13:39 JST, with nine intervals
returned in each; this is execution evidence, not coverage qualification.
`gmfrm-core-screen-20261001.R` prepares 800 fixed inputs and reuses those eight
cases, leaving 792 fits. For two workers, the pilot stage times imply about
48 hours remaining; extrapolating the older timings strictly in proportion
to N instead gives about 35 hours. Neither is a confidence bound, and one
case per cell does not estimate the runtime distribution. Both put completion
after the original October 2 18:00 checkpoint. The user has since relaxed that
deadline and explicitly requested no new computation during scientific review;
**the remaining core computation is held for design reconsideration.**

The old four-condition run's **71–72 hours for 2,000 fits** applies only to
that old mixture. The targeted block's greater numbers of facet levels and
four-category writing cases were not timed. Neither those estimates nor the
new core pilot prices a small-cohort/multifacet redesign. Corrected-JML sampling
remains paused. Neither D1 nor release readiness is closed. This entry
supersedes historical statements below that the matched replay is ongoing.

**October 1 latest scope correction: preserve general-purpose coverage.**
The user explicitly requires the past larger-sample conditions as well as the
neglected 20–60-Person range: mfrmr is a general-purpose R package. Adding
small-cohort priority must not demote medium/large samples to background or
redefine the package around three small-cohort applications. Include both facet
count and levels per facet, and prioritize substantive adequacy over finishing
by October 2 18:00 JST. **Do not run estimation, simulation, input generation
or timing pilots while this design review is in progress.** Deadline permission
is not launch permission. Preserve the completed 400-case replay, eight timing
cases and immutable prepared proposals; the 792 remaining core cases and old
2,000-case study are not the next recommended launches.

The preceding N=120/240/480-centered design placed N=60 at the edge and varied
Task/Rater levels within only two non-Person facets. That misses both priorities.
Revise the primary question to which supported model and rating design provide
useful severity/contrast, Person-scoring and discrimination outputs across
small, medium and large samples. Compare RSM/PCM, one-family and two-family GPCM via MML where their
target and scale can be matched; do not equate a successful complex-model fit
with better small-sample inference or restart corrected-JML work automatically.

The main sample-size scope is **N=20/30/40/60/120/240/480**. Retain the original
three-Task/six-Rater/three-category, SD=.5/1 and two-roster conditions as a
full-range comparison with the completed N=240 evidence. N=120/480 currently
have timing cases only, not coverage results; reuse compatible records/inputs
without conflating readiness with validation. If a procedure changes, keep old
and new arms distinct and reassess retained data as appropriate. The current
no-computation hold remains in force.

Treat non-Person facet count, levels, slope ownership, step ownership and score
categories separately. Distinguish increasing N at fixed model/design from
increasing N together with facet levels and sparse allocation. Include selected
complexity, exposure and misspecification contrasts at small and larger N;
neither range substitutes for the other. Do not fix another all-factor grid or
2,000-fit total first. Distinguish added workload from reallocated workload,
independent Persons from repeated rubric scores, and observed fixed-facet
effects from population-of-raters/tasks claims. The MML study is one validation
strand, not the complete definition or qualification of this general-purpose
package. The present N=480 endpoint is not a package limit.

Static source review confirms a capability boundary: the two-family route
requires exactly two non-Person facets, both slope owners. Task x Criterion x
Rater cannot be tested merely by increasing Task/Rater levels or concatenating
facets. Ordinary RSM/PCM have broader additive-facet implementation scope;
extending the two-family route to additional facets is a separate scientific
and implementation decision. The existing simulation-spec extractor also does
not supply a general multifacet generator. No new performance claim follows
from this source inspection.

The [small-cohort and facet-structure review](gmfrm-mml-em-20260927.md#october-1-small-cohort-and-facet-structure-review)
records candidate applied designs, source boundaries, parameter burden,
scale/estimand matching, local dependence and allocation concerns, failure
accounting, and the decisions required before any new computation. It reuses
the published N=30 OSCE design already identified in the practitioner review;
the user's usage priority is not presented as a measured market proportion.
No conditions or replication counts for this new framework are frozen yet.

**Continuation: source-level findings that precede a new study.** The existing
two-family model-based interval check requires the N-by-p matrix of observed
Person likelihood scores to have column rank p. Thus N<p makes interval
return impossible through this check, regardless of ratings per Person. The
old three-task/six-rater/three-category model has p=22 and cannot pass at N=20.
This algebraic output restriction is distinct from inability to fit the model
or structural nonidentification. The earlier retained example with four
Persons and full-pattern rank 6/6 already demonstrates that distinction at
its specified parameter vector. Do not rerun it or remove the check merely
to make small-N intervals available. Review the check's role in model-Hessian
inference separately from empirical-score/sandwich covariance requirements;
any revision changes the procedure to be evaluated.

A second source-level mismatch affects the proposed comparison. Ordinary
RSM/PCM defaults fix N(0,1), whereas one-family GPCM defaults estimate a normal
population. Moreover, `mfrm_facet_intervals()` rejects estimated-population
ordinary fits and one-family GPCM; `confint()` on GPCM supplies slope intervals,
not the missing severity-contrast consumer. Do not compare defaults as if only
slopes differed, or count unsupported outputs as numerical failures. Resolve
the desired matched population/scale and whether a bounded consumer extension
is necessary before claiming a common interval comparison. Post-hoc
`facet_shrinkage`, including its `laplace` alias, is not penalized MML.

The [concrete no-fit design review](gmfrm-mml-em-20260927.md#follow-up-decisions-that-can-be-made-without-fitting)
supplements that full-range core with three applied blocks: single-performance
rubric assessment, Task x Criterion x Rater assessment, and rater training on
common performances. It specifies crossed versus paired rosters, fixed-workload
versus added-workload contrasts, criterion-owned steps as the primary rubric
hypothesis, distinct rater-owned-step comparisons, and severity/Person-scoring
targets. These blocks include small cohorts and appropriate medium/large-N
comparators; criterion-owned steps are a rubric-block hypothesis, not a
package-wide preference replacing the original rater-owned-step conditions.
The three-facet block uses existing additive-model candidates; it
does not silently authorize extending the two-family engine. All remain design
proposals. No fitting, generation, timing or numerical checks were executed
in this continuation; the only edits are to these planning records.

**Historical four-condition confirmation proposal (held):**
Only after reviewing that matched replay decide whether the unchanged local
Wald method warrants an independent study or whether bias/weak-information
treatment must change first. Earlier undercoverage/bias is not invalidated by
more accurate adaptive integration. For a retained unchanged method, the
initial independent evaluation is limited to those four correctly specified
conditions, with 500 independent datasets per condition and a new fixed seed
family (93020000 + replicate). At 95% interval availability this supplies about
475 returned intervals per component and MCSE about .01 for 95% coverage;
at full availability the MCSE is .00975. These are precision calculations,
not assurances of availability, coverage or power to detect small bias.
In fact, with 500 returned intervals and true coverage .95, the exact-interval
coverage margin below is met with probability only .7124. At 1,000 it is
.9709; at 100 no possible count meets the margin. This does not justify
automatically doubling repetitions or applying that gate to the new screen.
This proposal has not been launched and is superseded as the immediate next step.

For each component/condition, a *limited* nominal-coverage claim requires
observed availability at least .95 with an exact 95% binomial lower bound at
least .90, and its exact 95% conditional-coverage Monte Carlo interval entirely
within [.92,.98]. These are declared practical margins for this evaluation,
not theoretical validity thresholds or universal rater-use criteria. Report
bias, SE calibration and widths even if these margins pass. Failure or an
inconclusive interval leaves that claim unsupported; do not automatically add
replicates, change thresholds or switch interval methods. Monte Carlo intervals
are pointwise, with no simultaneous-coverage or universal model guarantee.
The existing real-roster, rare-category and informative-allocation questions
remain outside these four conditions and must constrain any broader claim.
The planning/reporting distinction follows
[Morris, White and Crowther (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6492164/).

Report measured fit/inference/retry time and forecast compute/elapsed cost
before launching the next gate, applying the October 2 escalation rule below.
Do not use a wall-clock cutoff to drop simulated failures or truncate the
fixed repetition count. Source, protocol and every input file are hashed;
completed records can resume only with identical identities.

**Consumer decisions at this procedure boundary.** These preserve current
support without silently cancelling unfinished release commitments:

| Consumer | Target and implementation decision |
| --- | --- |
| Component intervals / plots / reports / replay | The procedure above evaluates existing public log-Wald output. Preserve both owner identities, scale, numerical checks and missing results throughout; no new wrapper/API. |
| Fixed-grid component profiles | Remain an explicit separate method using their own constrained likelihood, LR cutoff and endpoint budgets. Existing profile evidence is retained; no adaptive profile or automatic fallback is admitted by this study. |
| Conditional curves / posterior residuals | Existing fixed-calibration descriptive targets continue. Component interval performance does not add curve bands, reference fit cutoffs or held-out predictive accuracy. |
| New-Person and portable scoring | The October 1 fitted-object route implements conditional EAP/SD/continuous intervals with both slope owners, original step/category coding and fixed population identity; independent integration and saved-output checks are separate from this component-interval study. Portable format 6 now preserves the same conditional target and checked extraction decision without training data; matching saved scores now attach to results for tables/reports/export; statistical qualification remains open D2 work. Posterior residual moments alone do not supply scoring. |
| Location/contrast intervals; remaining curves and maps | October 1 adds experimental model-based normal intervals using constrained blocks of the inverse full marginal information, with target-specific scale/reference labels and saved checks. Their coverage is unqualified. Curve/step intervals and maps still require their own target, transformed covariance/scale and interpretation; no ordinary-model fallback. |
| Individual rater sheets | The October 1 route now reuses saved two-family location/slope/step values, optional experimental component intervals and descriptive posterior residuals with recipient privacy. Location/step intervals are not displayed in these sheets; analyst reports can retain separately requested experimental location/contrast intervals. Calibrated feedback decisions remain unavailable; no ordinary fit reference is transferred. |
| Fit tests, model ranking, rater competence and consequential selection | Require model/decision-specific reference distributions, loss or calibration evidence. These remain unavailable; this component study supplies neither a likelihood-ratio test nor a decision rule. |

Corrected-JML centering and structural-versus-root uncertainty remain separate
unresolved work. This protocol closes the procedure specification for its
bounded check, not D1/D2 or the integrated release. Evidence and execution
scripts: [GMFRM record](gmfrm-mml-em-20260927.md#september-30-adaptive-two-family-calibration).

**Feasibility decision after the frozen run:** all nine cases completed;
seven returned all nine intervals at order 31 and two withheld them for
regularized/near-singular joint information. Every fit passed the raw-gradient
convergence check. No case triggered the quadrature-only refinement rule.
In rotating-pair SD=.5 replicate 1, the neutral adaptive fit has continuous
NLL 1558.971232 versus 1471.593412 at the retained EM parameters. Both match
independent continuous integration to 1.78e-15 per Person at adaptive order 61.
Using those EM parameters as the starting value of the *same* adaptive
optimizer reaches NLL 1471.593412 and returns all nine intervals. This
post-run internal diagnosis is not a replacement observation or a public
initialization option. The original seven-of-nine result remains unchanged.

**Repair required by the first run:** establish an observable, reproducible starting-value
and solution-selection rule for public adaptive fitting before replaying all
400 datasets or launching independent coverage work. The neutral-only
candidate is held; increasing quadrature or relaxing information checks does
not address this counterexample. Compare candidate solutions using the same
accurate objective, preserve every start/failure and avoid choosing from truth
or interval coverage. The separate near-zero-slope replicate 26 still has
unresolved boundary/global-solution status. Its refusal is not proof of either.

**Initialization revision fixed before matched replay (September 30).** The
public adaptive candidate now runs both the neutral vector and a fixed-grid
EM-derived vector through the same requested adaptive objective/optimizer.
The EM seed uses the requested quadrature order, maxit outer iterations,
100 M-step iterations and mean-score tolerance 1e-6; a finite unconverged
EM vector can be a starting value but is not called an adaptive solution.
Select the lowest finite terminal adaptive NLL, retaining its convergence
status even if a worse candidate converged. Exact ties retain neutral first.
If a known starting objective is better than every terminal candidate beyond
roundoff, mark the selected point unresolved. Preserve all candidate vectors,
errors, warnings, optimizer stages, seed trace and elapsed costs. A failed
alternative is disclosed; failure of every adaptive attempt returns an error
carrying the initialization record. No truth, interval outcome or numerical
threshold change participates in selection.

`gpcm_mml_start=NULL` resolves to `"neutral_em"` for this route;
`"neutral"` explicitly retains the earlier procedure. Stored calls pin the
effective choice; quadrature refits of older fits without the field retain
neutral initialization. The revised bounded replay uses the same nine cases
with the same 31/61/121 conditional rule, retaining original records and all
failures. Existing small workflow/gradient/interval tests cover ordinary and
arbitrary-name behavior; selection/error rules are also tested without fitting.
This is a source-identified repair evaluation, not independent coverage evidence.

**Revised bounded result and current next decision.** All nine cases finish at
order 31. Every neutral candidate exactly reproduces its original parameters;
the new policy selects neutral four times and the EM-derived candidate five
times. The two earlier poor solutions improve from NLL 1558.971232 to
1471.593412 (replicate 1) and 1582.001696 to 1484.228253 (replicate 26).
Independent continuous integration agrees to 1.78e-15 per Person at both
31 and 61 nodes. The seven other cases keep their likelihoods and all nine
intervals, but the total interval availability remains seven of nine.
Replicate 1's total gradient is 1.5142e-4 against the unchanged 1e-4 threshold;
its information checks are not reached. Replicate 26 passes the gradient
review but fails the full unregularized information check, with a minimum
slope .00135593. Neither a global maximum nor a true boundary has been proved.
The better unfinished point stays visible; no worse point or relaxed gate
replaces it.

The public initialization repair, policy-preserving replay, reporting and
targeted regression checks are implemented. Next assess the retained
stationarity failure and weak-information point under the same objective
before spending the large replay/coverage budget. No new coverage claim
follows from the better likelihoods. Exact source, both failures, all nine
saved-output replays and the independent-integral checks are in the
[initialization record](gmfrm-mml-em-20260927.md#september-30-public-adaptive-initialization-revision).

The revised run took 1,016.773 seconds on two workers. Ordinary cases averaged
165.914 seconds (132.350--204.260); the difficult replicate 26 took 394.665.
Ordinary-case projections are 9.2 hours for 400 matched cases and 46.1 hours
for 2,000 independent cases, with minimum/maximum scenarios of 7.4--11.3 and
36.8--56.7 hours. These exclude difficult-case frequency and unobserved retries;
they are not upper bounds. The combined mean projection is about 55.3 hours
and would pass the October 2 checkpoint from this review. Neither large study
has started; re-estimate the actual retained procedure and apply the consultation
rule before an over-budget launch.

**Stationarity repair fixed before selective replay (September 30).** Reuse
the existing single guarded curvature restart for adaptive GPCM with a fixed
population and at most 64 free parameters, only when the existing polish
ladder ends with `code_zero_large_gradient`. The requested optimizer/maxit
and selected reltol are unchanged. The proposal requires finite positive
curvature, reciprocal condition at least 1e-10, a strictly smaller raw gradient
and no objective increase beyond 64 machine eps times max(1, absolute NLL).
Failed proposals remain recorded. The original gradient and interval gates
still apply; no weak-direction correction or acceptance threshold is changed.

Replay all starts and interval checks for the three previously saved cases
where this new branch can run: 001-common_persons-1, 001-rotating_pairs-0.5,
and 002-common_persons-1. These are selected by saved optimizer state, before
new outcomes, not by interval success or truth. The other six have no candidate
meeting the new branch condition; retain their original fit/source records
as reused evidence, not fresh refits under a new source label. Refresh only
replicate 26's interval output to check the new refusal detail, which reports
the actual refinement/inversion/displacement values and unchanged limits.
All likelihood, quadrature, initialization and inference settings otherwise
remain fixed. The bounded check is expected to take minutes from the retained
case timings; it is not the 400-case replay or an independent coverage study.

**Selective replay outcome and current next gate.** All three public refits
pass the original gradient/information/score-rank/31-versus-61 gates and return
all nine intervals. The stalled example's sixth `curvature_restart` stage
reduces its total gradient from 1.5142e-4 to 1.8192e-7 without worsening NLL.
Independent Louis derivatives and the full nuisance-adjusted covariance agree
(relative log-slope covariance error 6.46e-7). Together with the six unchanged
fit records, eight of nine cases now return all component intervals. The
remaining weak-information refusal is retained with its actual diagnostic
values. Independently stable weak curvature and standardized displacement
.0279765, versus the required 1e-4, explain why its small raw gradient is
insufficient; a true boundary/global optimum remains unproved.

The BFGS procedure now permits at most six stages per start: the original
stage, up to four ordinary polishing stages and at most one guarded curvature
restart when still needed. The 500-iteration ceiling applies separately to
each optimizer stage; the Hessian/proposal work is additionally recorded.
All initialization, quadrature and inference rules remain as frozen above.
The next evidence gate is the previously specified matched comparison on all
400 retained datasets, preserving paired failures and denominators before
considering new independent coverage work. Neither nine-case numerical
availability nor unit-test success qualifies sampling coverage.

Three selective refits took 439.392 seconds on two workers, plus 48.038 for
the weak interval refresh. Combining updated affected-case times with unchanged
ordinary-case costs gives a planning mean of 184.478 seconds per case; the
retained difficult case still took 394.665. Approximate two-worker projections
are 10.2 hours for 400 matched cases and 51.2 hours for 2,000 independent cases,
with ordinary minimum/maximum scenarios of 7.4--12.8 and 37.2--64.1 hours.
Mixed-run/concurrent-test timings and unmeasured tails preclude hard bounds.
No large study has started. Recheck expected completion against the October 2
18:00 JST consultation rule before launch. Details and source/reuse identity:
[stationarity record](gmfrm-mml-em-20260927.md#september-30-adaptive-stationarity-and-weak-information-review).

**Matched replay execution specification (September 30, before launch).** Run
the frozen `neutral_em` adaptive procedure on all 400 retained September 28
datasets. Reuse the nine verified procedure records with their actual source
identities (three stationarity refits, five unaffected earlier fits, and the
weak fit with its refreshed refusal); fit the other 391 datasets. No data or
random seeds are generated. The principal paired comparator is the saved
revised fixed-grid EM interval procedure (310/400 datasets available); retain
the original strict procedure (95/400) as a separately named historical arm.
All three arms use the identical saved observations and component truths.

Report log-slope bias, RMSE and empirical SD both among all numerically
qualified finite points and among returned intervals. A qualified point must
have `Converged = TRUE`, optimizer diagnostic severity `pass`, finite objective
and parameters, and a finite positive component estimate. Retain other point
estimates and diagnostic reasons in the rows, without promoting them to
qualified estimates or removing their datasets from availability denominators.
Reported model variance and log width use the returned subset. Unavailable
intervals have missing conditional coverage, and false returned-and-covered
status. Each condition/component has exactly 100 independent replicate units;
the nine components and the four shared-random-number conditions are not
additional independent replicates.

For each arm report binomial MCSEs and exact 95% Monte Carlo intervals for
availability, conditional coverage and returned-and-covered frequency. For
adaptive minus revised fixed-grid EM report paired availability and delivery
differences with `sd(within-dataset difference) / sqrt(100)`. Conditional
coverage compares two ratios with possibly different returned subsets; its
MCSE is the paired first-order delta estimate based on the difference of
influences `(D - p*A)/mean(A)`, where A is availability and D is delivery.
Also label a separate both-available paired coverage comparison. A missing
denominator yields missing coverage/MCSE, never zero coverage. These intervals
describe Monte Carlo precision; this development-informed matched replay does
not constitute independent coverage qualification. Do not compare saved
fixed-grid and adaptive objective values as if they were the same objective.

The runner snapshots package R sources, compiled binary, supporting files,
procedure and aggregation code, hashes all input and prior-result files,
and executes from that snapshot on two workers. It saves each complete case
atomically, including failed fits/inference and every quadrature stage. Resume
only matching-source/input records; a process lock prevents duplicate runs.
Aggregate only after all 400 records exist. The planned remaining elapsed time
is about 10 hours (ordinary-case scenarios about 7--13 hours), before October 2
18:00 JST from a September 30 evening launch. Difficult cases, retries and
machine suspension can extend this estimate. No 2,000-case independent study
is authorized by this execution step; review the matched evidence first.

**Launch status.** Started September 30 at 21:42:49 JST with 391 pending
jobs and two workers. Nine prior records were verified and retained. The
saved-input accounting check reproduced both historical availability totals,
and a temporary 400-record equal-arm fixture gave exactly zero paired contrasts
and MCSEs; incomplete aggregation and mismatched resume identities are rejected.
The run lives in `validation-results/gmfrm-adaptive-matched-20260930/` and uses
its own frozen runner and package source. `execution.log` records completed
jobs; `summary.rds` is written only after all 400 paired records exist. No
adaptive coverage result or independent-study decision is available at launch.

The original neutral-only nine-case run took 552.207 elapsed seconds on two workers (1,060.104 summed
fit/inference elapsed seconds). The eight ordinary feasibility cases averaged
129.978 seconds each, range 114.825--186.385. A simple two-worker extrapolation
is 7.2 hours for the 400-case matched replay and 36.1 hours for 2,000 independent
cases; using the observed minimum/maximum gives 6.4--10.4 and 31.9--51.8 hours.
These ranges are workload scenarios, not predictive intervals or guaranteed
limits; no actual quadrature retries were observed and tail behavior is poorly
measured. The combined mean projection leaves little room before the October 2
checkpoint and its upper scenario exceeds it. Re-estimate after the initialization
repair and apply the existing escalation rule before launching; neither large
study was started. Full evidence and the unchanged refusal outcomes are in the
[procedure record](gmfrm-mml-em-20260927.md#september-30-adaptive-interval-procedure-feasibility).

**Cross-cutting review at this checkpoint:** existing G/D evidence remains
limited to the declared observed-score designs and scoped normal-theory plan
comparisons. Assigned-score MI retains bounded MAR support and the adverse
MNAR finding (26% contrast coverage); descriptive rater screening retains low
detection in its matched-budget study. Those studies were reviewed, not rerun
or requalified by the new slope intervals. Corrected-JML structural centering
is still unresolved. README/help/capability wording now distinguishes adaptive
log-Wald/residual support from fixed-grid-only profiles. CONTRIBUTING's older
package-workload-only timing rule conflicted with D3/D4 and now uses the full
600-second check ceiling, with build/installation reported separately. The
historical claim ledger points to this current plan instead of implying that
its earlier local closure freezes the expanded source. No new assembled check,
remote CI or release publication is claimed.

#### Consequential ranking: define the decision before evaluating it

The sport case is a concrete data/target review for D1/D2, not another model
release commitment or a reason to abandon the writing-data integration issue.
`gmfrm-sport-decision-20260930.R` reconstructs published scoring quantities;
[the existing evidence record](gmfrm-mml-em-20260927.md#september-30-consequential-ranking-in-judged-sport)
identifies sources, arithmetic checks and limits. It supplies a verified
non-language data structure; it does not close a model-specific inference gate.

Before admitting a ranking decision, fix these elements of the protocol:

1. **Target and action.** Distinguish reconstruction of the official result,
   selection by a prespecified latent construct/composite, and prediction of
   the winner of a new performance. Define whether the action selects one,
   returns a candidate set, requests further assessment or abstains. Preserve
   official tie/advancement rules and their historical version. Observed
   official winners and panel consensus are not known latent truth.
2. **Population and repetitions.** State whether the same performances are
   rejudged by a new panel, the same athletes perform again, or a new field is
   sampled. These require different uncertainty. For decision evaluation,
   the repeated unit is a complete competition under that contract, not
   independent rows sampled out of a shared panel/performance. Resampling
   Persons changes the competitor field; judge deletion is sensitivity, not
   a winner probability. Preserve common calibrations and dependence.
3. **Challenging contrasts.** Retain a clear leader, a practically close
   leading group and an exact tie. Specify their gaps on the declared target
   scale before responses are generated; do not define them retrospectively
   from fitted SEs. Compare complete panels with cost-matched linked sparse
   panels, then loss of a bridge. Review narrow elite-cohort SD separately
   from raw-scale changes, ability-associated panel assignment and selective
   advancement. Separately introduce shared-performance dependence and
   judge-by-athlete interactions to test misspecification; these are not
   effects already implemented by two fixed slope families. Common rated
   performances are observed links, not known fixed-ability anchors.
4. **Loss and availability.** Report wrong selections over all competitions,
   over decisions actually issued, and separately the rate of abstention or
   numerical unavailability. Separate a wrong confident singleton from a
   broad candidate set. For a known latent target, record the loss
   `max(truth) - truth[selected]`, candidate-set coverage/size and tie handling.
   Define tied best performers as a set: distinguish selecting any member
   from a confidence set that must retain all tied best performers.
   Returning every athlete must not count as a useful precise decision.
   Always report near-tie and separated-leader results separately; overall
   rank correlation, mean bias and G cannot replace these outcomes.
5. **Uncertainty and acceptance.** A selected best-minus-runner-up contrast
   needs covariance, common calibration uncertainty and selection accounting;
   independent draws from marginal SEs do not provide these. A simultaneous
   contrast/rank procedure needs its own assumptions and evaluation, including
   exact ties/boundaries. Freeze acceptable loss/error, Monte Carlo precision
   and computational cost before an independent study. No universal 95%
   individual interval, G cutoff or probability threshold defines an acceptable
   championship procedure.

The concrete skating fixture also requires correct order of trimming,
rounding and factoring, signed deductions, and different score ladders for
PCS and GOE. The current public support remains design/scoring interpretation
and model-scoped diagnostics, not automatic championship decisions. The
two-family route has neither Person scoring nor a joint athlete-rank
inference consumer; one-family conditional EAP and linear G/D composites
cannot fill that gap. Public help now states these limits at the relevant
entry points. Existing joint-slope and corrected-JML commitments, their
mathematical priorities, and the October 2 escalation condition remain intact.

#### Mathematical review before another study or optimization

Keep four kinds of evidence separate: algebra/model identity, numerical
accuracy, repeated-sample statistical behavior, and package/CRAN execution.
The adaptive-gradient equivalence checks address the first two only. The
following review fixes the next questions across all three release pillars;
it does not silently remove the agreed joint-slope or corrected-JML work.

| Route and target | Evidence already available | Immediate mathematical decision / stopping condition |
| --- | --- | --- |
| Two-family MML: identified component and effective slopes | Literal probabilities, first-family geometric-mean-one constraint with fixed N(0,1), EM/direct objective agreement, gradients and full marginal-information calculations. | Retain the exact response equation, ordered owners and identification. Distinguish connected crossings, within-Person response information and local versus global identification. A connected graph or positive Hessian alone cannot certify all of them. Do not use an EM Q-function Hessian as the observed marginal information. |
| Two-family component Wald/profile intervals | Existing sparse-design and profile studies, integration failures and matched numerical repairs. | Freeze the complete source-fit/refinement/retry procedure and interval target before new coverage evaluation. Profile uses an asymptotic likelihood-ratio cutoff; neither local numerical success nor a repaired endpoint establishes its coverage advantage. Separate bias, covariance error, weak information/boundaries and quadrature error. |
| Explicit-order corrected JML: structural parameters | Exact owner-total equations, full nonsymmetric Jacobian, actual Person contributions, fixed/random-roster decomposition, population roots and 200/400-dataset studies. | Resolve the centering target before formal truth intervals: variance about an adjusted-equation root is not bias removal. Review correction order and exposure-growth assumptions; order stability, a smaller residual, and more Persons do not establish negligible common bias. No automatic order selector or formal interval is admitted from those facts alone. |
| Multivariate observed-score G/D: composite/difference dependability | Existing crossed/nested ANOVA/MINQUE(0), raw covariance components, metric-specific availability and paired-delta checks. | Reconcile random/fixed facets, score units, future complete-plan counts and covariance between criteria/plans. Preserve raw inadmissible estimates and restrictions on normal-theory intervals; do not equate observed-score components with GMFRM latent-parameter covariance. Reuse completed evidence unless an actual mismatch is found. |
| Scoring, feedback, MI and dependence extensions | Existing fixed-calibration scoring, recipient reports, assigned-response MI and separate random-rater/testlet routes. | Keep the conditioning set and sampling unit visible: fixed calibration versus estimated calibration, independent Persons versus shared random raters, assigned missing scores versus unassigned cells. Check the supported target behind each interval, fit cutoff and pooling rule; descriptive feedback is not rater-competence inference. |

**Corrected-JML centering check, revisited September 30.** At a fixed roster
length and fixed order k, write the mean adjusted equation as
g_k(beta) = E[U_k(Y; beta)] and its locally identified root as beta_k*.
The implemented Person sandwich uses the full derivative A = d g_k/d beta
and design-appropriate B: covariance about beta_k* is approximately
A^{-1} B A^{-T}/N under the required sampling/regularity assumptions.
This does not replace beta_k* with the generating parameter beta_0.
For a scalar contrast with nonzero fixed displacement d = c'(beta_k* - beta_0)
and a valid root-centered normal approximation of scale s/sqrt(N), its
truth inclusion is approximately
Phi(z_.975 - sqrt(N)*d/s) - Phi(-z_.975 - sqrt(N)*d/s), tending to zero as N
increases. This is a conditional mathematical deduction, not a new coverage
experiment or a claim that its finite-N normal approximation is exact.
The existing nonzero exact population displacements therefore rule out using
the 400-Person studies as a general fixed-exposure consistency argument.

The current source still computes U_k = (I-P_beta)^k U_0 using MLE plug-in
expectations and retains the derivative of the entire equation. Rechecked
sections 1.2–1.3 (printed pp. 3–4) of the
[Dhaene–Jochmans author manuscript](https://jochmans.github.io/preprints/score%20adjustments/Dhaene-Jochmans%20adjscore.pdf)
distinguish finite-order bias reduction from fixed-stratum-length consistency;
even a fully iterated limit needs identifying information. This is a targeted
source recheck, not a fresh whole-paper reading or a theorem for this GPCM.

**Sampling target resolved, September 30.** The fixed-roster sandwich describes
new independent Persons within each assignment pattern, with fixed pattern
counts and unspecified, possibly different ability distributions. It does not
condition on the same Persons' abilities across reassessments. Random rosters
add variation in pattern composition; they do not require ability-independent
assignment. Exact decomposition of the 12 saved corrected population cases
reproduces the stored covariance and distinguishes response, ability-composition
and roster-composition variation. In those cases the ability-composition share
is at most 0.10% of each coordinate's fixed-roster variance. This closes the
meaning of the existing covariance, not its coverage or the structural-bias
decision. Help, printed summary and saved report tables now carry that meaning.
The empirical asymptotic meat is retained: changing its finite-sample divisor
cannot remove root displacement. Two Persons per pattern is a computational
minimum, not statistical qualification for many small assignment groups.
See the derivation/results in the [JML review](jml-inference-review-20260927.md#september-30-covariance-sampling-target-and-finite-roster-centering).

The next corrected-JML decision remains a justified structural-bias treatment
or exposure-growth regime for a fixed procedure. The T^(-k-1) rate in Dhaene
and Weidner's Conjecture 1 must not be presented as a theorem for this GPCM.
A proposed regime must control bias relative to the matching standard error,
not bias alone, and must preserve information under the actual sparse design.
Do not launch a new coverage study or select an order until that proposal and
its falsifiable evaluation criteria are recorded. This does not defer the
agreed interval outcome or replace the dated escalation rule below.

The retained order-study CSV confirms all 400 datasets were attempted and both
orders returned estimates/covariance. For log slope, order 2/4 truth inclusion
is 94.5%/93.5% in the unequal Criterion case and 94.5%/94.5% in the sparse Rater
case. These imprecise finite-condition results do not settle residual bias or
select a universal order. All coordinates and adverse findings remain in the
linked original records. Public `RootSE` remains labelled local root variation;
it must not become an ordinary structural SE through summary, plot or export.

The [all-coordinate reconciliation](jml-inference-review-20260927.md#september-30-structural-target-before-computational-optimization)
now checks the saved population roots against all 400 study datasets and both
orders without refitting. All 20 coordinate/condition/order summaries agree
with recomputation; nonzero root displacements persist. Order 4 reduces the
examined log-slope population displacements but its paired sample MSE improves
in the unequal Criterion design and worsens in the sparse Rater design.
This establishes the next question, not a universally preferred order.

**Next bounded deliverable:** specify the additional mathematical bias treatment
or declared growth-regime argument needed for the promised structural target,
using the reconciled order/exposure evidence. Do not choose a benchmark's oracle
correction, minimize a fitted SE, or invent an automatic order rule.
In the same review, freeze the two-family inference procedure and its numerical
failure accounting. Only then choose an independent evaluation and justify
its precision/cost. A general theorem or a universal coverage/capacity guarantee
is not required; unresolved agreed claims still require a repair or explicit
user scope decision, not a weaker label presented as completion.

**September 30 centering/identification decision.** The additional-bias route
has now been made concrete in the
[centering and growth review](jml-inference-review-20260927.md#september-30-exact-centering-loses-identification-a-conditional-growth-route).
Exact conditioning on slope-owner totals centers the equation but loses the
owner-location direction: the five-coordinate conditional information has
rank four for Criterion ownership and rank three for Rater ownership in both
saved designs. Rater 1 never crosses Criteria within a Person, giving an
additional explicit invariant slope/location/step transformation. Thus this
candidate cannot replace the full structural estimator. This is not a claim
that the current finite-order JML equation itself has those ranks.

The remaining mathematical candidate holds facet dimension and roster
proportions fixed while multiplying each cell's independent exposure by L.
The full nuisance-adjusted Fisher information retains rank five in all four
saved generating conditions. The subsequent
[fixed-block expansion check](jml-inference-review-20260927.md#september-30-fixed-block-expansion-and-an-exact-expectation-check)
derives the leading negative-profile-score coefficient and the plug-in
operator for the finite GPCM block, including beta-dependent weighted totals
and control of extreme-response tails. For fixed order k, compact abilities
and structural parameters, fixed facets and independent block replications,
the resulting normalized score mean has order O(L^(-k-1)). The October 1
extension below supplies the local two-argument mean/root and matching full
covariance argument in this fixed-block family. With independent Persons and
both N and L growing, a sufficient centering restriction is N/L^(2k+1) -> 0;
the actual contrast bias/SE remains the criterion. Repeating dependent ratings,
unbounded ability distributions or increasing facet dimension is outside this
argument; no finite-sample coverage follows from the information calculation.

All 40 planned mean calculations (eight owner/design/roster settings,
L=1,2,4,8,16, orders 0,1,2) completed in 31.418 seconds. The raw and one-step
leading coefficients agree increasingly at larger exposure, but convergence
is not monotone. The largest retained one-step discrepancy prompted only a
declared two-case extension of that roster, retaining all abilities/coordinates:
its coefficient error was .030379/.012519/.005781 at L=16/32/64. The latter
two cases took 6.719/70.095 seconds. At L=64 that roster has 256 ratings per
Person, so this is evidence for the growth argument, not a usable rating-count
cutoff or a new interval qualification. All original-exposure fields match the
previous research helper, and means match independent full-pattern enumeration.
The all-case and follow-up source identities and adverse/nonmonotone values
remain separate and retained.

A design-preserving split correction is a concrete subsequent implementation
candidate, conditional on a justified leading bias power and compatible
half-design expansions. Neither existing sparse/unequal design can be split
exactly into identical half rosters. Do not round cell counts, drop Persons,
retune correction order or reuse an unpaired covariance to force eligibility.
The [October 1 root/covariance check](jml-inference-review-20260927.md#october-1-local-population-roots-and-full-response-covariance)
derives the nearby structural-root expansion, full response covariance and
root-centered CLT under the stated compact, independent fixed-block conditions.
The numerical calculation keeps the generating conditional moments fixed as
the evaluation beta varies, and adds within-total response variation to the
conditional-mean variance. All eight saved original-exposure roots/covariances
were reproduced, including independent off-truth mean/meat and full-Jacobian
checks. The 24 new cases through L=8 all passed both saved starts and unchanged
review gates. All 32 case calculations took 300.186 seconds in total.

At N=400, the maximum coordinate displacement/SE over the four retained
settings declines from .185752 to .097449/.052335/.012843 for order 2 at
L=1/2/4/8; order 1 declines from .624882 to .285345/.115859/.044887.
All-contrast standardized bias, signed coordinate values and adverse earlier
sample evidence are retained. The full covariance also approaches its limit,
but at L=8 some contrast variances are still about 15% larger than the limiting
information approximation. Omitting within-total variance can reduce a reported
SE to .268 of the full value; the existing public Person sandwich already uses
actual responses, so this is a research-reference safeguard, not a public bug.

Eight proposed L=16 cases remain explicitly unexecuted after a roughly one-hour
cost projection. They are not needed to settle the next decision and are not
counted as successes. Increasing the population grid cannot establish sample
covariance calibration or interval coverage. The next gate is observed-data
availability and truth coverage. The
[October 1 public-procedure protocol](jml-inference-review-20260927.md#october-1-observed-data-procedure-and-independent-evaluation-protocol)
now fixes public order 2, maxit 400, default starts, unchanged numerical
checks and fixed-roster Person covariance. Research candidate intervals
additionally require consistent roots across starts and finite supported
bounds. All expanded locations, steps and log-slope contrasts are included;
positive-slope endpoints are exponentiated. Existing point output and public
CI eligibility are unchanged.

The two retained samples reproduce the research root/covariance, and the
complete actual-Person equation/Jacobian/meat bridge passes at original and
increased exposure. Six pilot fits cover Criterion/unequal, Rater/sparse,
and the existing three-rater/four-category design at paired L=1/4. Their
51.000-second combined fitting time projects to 7.083 hours for 500 independent
replications per design; the planning range is 8--22 hours on one process,
allowing preparation, retries and load variation. Failure accounting,
constrained-coordinate output and the full summary reader passed before launch.

**Launched October 1 at 00:44:37 JST:** 1,500 independent generated inputs,
each with paired original/fourfold exposure, for 3,000 public fits from a new
seed family. Pilot inputs are excluded. Frozen source/protocol, atomic per-arm
records, all failures and all denominators are retained under
`validation-results/jml-independent-inference-20261001/`. The predeclared
pointwise practical margins require availability >=.95 (exact 95% lower bound
>=.90) and a conditional-coverage Monte Carlo interval wholly within [.92,.98].
Report all bias, covariance, width, delivery and paired results regardless of
qualification; do not add repetitions or change margins automatically.
Summaries are produced only after all 3,000 attempts exist. No coverage result,
automatic selector or public interval is admitted merely from launch or the
pilot. D1 and general-input scope remain open. This is separate from the
ongoing 400-case MML matched replay; the independent MML study has not started.

**Paused October 1 at 01:00:49 JST after priority review:** the additional
corrected-JML run was interrupted with 113/3,000 fit records and 57 generated
inputs preserved. The process exited and its lock was removed; saved records,
input hashes/seeds and frozen runner/protocol hashes were checked. The pause
is a scheduling decision, not an interim coverage decision or numerical
failure. No partial coverage summary was produced. `pause.json` records the
state, including the interrupted arm. Do not restart automatically: first
tie the remaining evaluation to a concrete public inference/scope decision
and compare its priority with unresolved public consumers. The separate
400-case MML matched replay continues. Prioritize consumer work that does not
depend on interval qualification; the agreed JML inference work remains open.

The exact conditional-rank rejection, full-information check and split
prerequisite are recorded with independent derivatives, source hashes and the
initial failed rank expectation. No public estimator/CI or scope change was
made. The original October 2 checkpoint was subsequently relaxed as recorded
below; the current scientific-review hold remains in force.

**Current timing and execution instruction (October 1):** the user explicitly
allows completion beyond **2026-10-02 18:00 JST** and prioritizes substantive
adequacy. This supersedes the earlier requirement to consult solely because
the work crosses that checkpoint. It does not authorize a launch: the same
instruction requires multidimensional design review with **no new computation
yet**. Resolve the full sample-size scope, facet structure, comparison methods and
estimands first. Do not launch the prepared core/confirmation studies or a
replacement pilot during that review. Once design and execution are authorized,
report the applicable compute/elapsed estimate; do not reuse the old scenario
mixture's estimate as if it priced the replacement. Neither a date nor partial
results authorize truncating planned datasets. Corrected-JML sampling remains
paused and D1/D2 remain open.

### 2. Resolve statistical claims using existing evidence first (D1)

Apply the common full-range plan to ordinary JML as well as MML and corrected
JML. For ordinary RSM/PCM and shared-owner GPCM, examine finite/boundary
solutions, calibration and Person-score targets, conditional versus joint
uncertainty, and N versus per-Person exposure. Existing corrected-JML studies
provide matched ordinary baselines only where the equation, solver and source
are the same; they do not qualify all public ordinary-JML paths. Preserve the
N=400 evidence alongside the shared N=20–480 design, and treat unsupported
JML model combinations as capability limits, not failed fits.

For joint slopes, numerical identities and retained failure repairs are
already available. Evaluate the revised prespecified procedure on independent
data for the claims retained at release. Include bias, empirical versus
estimated SE, interval width, availability, coverage among returned intervals
and returned-and-covered frequency. Distinguish nonexistence/weak identification,
optimization failure and integration error. Profile-versus-Wald disagreement
is a diagnostic, not proof that profiles are better.

Choose repetitions from Monte Carlo precision and decision consequences, not
a ten-minute cutoff or a desire to obtain significance. Roughly 119 independent
datasets give a 2-percentage-point MCSE for 95% coverage, and 475 give one point
before allowing for unavailable intervals; correlated parameters within one
sample do not increase the independent replication count. These are planning
calculations, not predetermined acceptance thresholds. Reuse existing timings
only for source/procedure/design-compatible work units; the old four-condition
timings do not price the expanded map. Follow the current computation hold;
when execution is authorized, save resumable jobs and report every planned case.
If the prespecified conclusion is inconclusive, decide whether the claim can
be supported, needs a changed method or needs an explicit scope decision;
do not automatically multiply repetitions or add another factor grid.

For corrected JML, reuse the 200-dataset one-step and 400-dataset order
comparisons. Examine residual bias and order sensitivity against the matching
full-Jacobian covariance. Orders 2/4 reverse MSE preference across examined
settings; neither is an established universal default. Automatic selection
needs an observable rule, retained override/reason and independent evaluation
of the entire selected procedure. External fixed-scoring agreement does not
qualify this new corrected estimator or its structural intervals.

Exit: record a supported claim and its domain, a specific remaining repair,
or an explicit unresolved decision. Do not relabel numerical success as
statistical qualification, or erase valid point estimates when inference fails.

### 3. Finish all three assessment workflows together (D2)

Use the existing educational assessment walkthrough and one substantively
different design to review assignment → model → diagnostic/uncertainty →
recipient feedback and G/D plan comparison → saved report/reopen. Preserve
separate estimands, populations, row selections and score scales. Use existing
features/MI as optional branches, with observed values and pooling assumptions
visible. Do not add an unrelated toy study to every completed function.

Check consequential defaults, unavailable results, generic methods, exact
plot values, non-color cues, title/caption removal, alternative text, individual
privacy and compatibility. Existing aliases and standard R argument names
remain unless a demonstrated usability problem justifies a migration. Do not
mark specialist functions superseded merely because a broader wrapper exists.
Run a realistic reader review when available; absence of participant evidence
must remain explicit rather than described as tested beginner comprehension.

Exit: each admitted user outcome in the scope table is executable and
interpretable end to end, with matching help and NEWS. Unresolved GMFRM/JML
scope cannot disappear when the walkthrough uses only RSM/PCM.

### 4. Optimize the retained calculations, then review examples (D3)

After D1's procedure and D2's targets are fixed, resume the engineering sequence
above using the retained timing evidence. Compare objective, gradients,
covariance, interval/score outputs and failure decisions before accepting a
speedup. Preserve independent small mathematical witnesses and all planned
study denominators. If cost prevents a necessary mathematical evaluation,
identify that concrete bottleneck and validate an equivalent computation;
do not make runtime optimization a new parallel feature queue.

Review help examples last against their teaching purpose and actual cost.
Prefer a small runnable example and saved, traceable results for expensive
follow-up displays. Do not hide an unverified method, failing example or the
only test of a feature behind `donttest`/`dontrun`. The
[R check documentation](https://stat.ethz.ch/CRAN/doc/manuals/r-devel/R-ints.html)
states that `_R_CHECK_DONTTEST_EXAMPLES_` defaults to true under `--as-cran`;
`donttest` is not a promise that CRAN submission will skip the code.
The existing timing runner explicitly set that variable false, so its recorded
73-second Windows example phase is ordinary examples only. Before final
qualification reconcile that override and time the submission-relevant
example workload; preserve the old measurement's narrower scope. No examples
or test selectors are changed by this priority revision.

### 5. Freeze, check and publish the integrated source (D3–D5)

Reconcile the supported capability list and version metadata, including the
DESCRIPTION description of multiple slope families, only against the admitted
scope. Build an identified archive. Run integration/package/platform checks
for that source, not inherited historical candidates. Keep check failures and
repairs attributable to their source. Commit, remote integration, CI, site,
release assets, Windows checks and CRAN states are separate verification tasks.
A local cleanup does not trigger external submission or retagging.

## D2 task-to-function acceptance table

This is the reviewable completion artifact, backed by the existing
`mfrmr_output_guide()` and `mfrmr_output_guide("plots")`, not a new guide API.
The current namespace still has 208 exports and 35 `plot_*` names (including
plot-data helpers). Counts do not determine recommendations. For each row,
D2 records: input/result class, model/estimator restrictions, consequential
defaults, recommended entry and alias/specialist role, help/example link,
plot-data/ggplot support, saved replay evidence and unresolved reason. Publish
the applicable mapping through the existing help/guide and pkgdown categories.

| Task | Recommended existing entry / sequence | Acceptance evidence to reconcile |
| --- | --- | --- |
| Review ratings and fit | `describe_mfrm_data()` → `fit_mfrm()` → `summary()` | Workflow help, public-model tests, explicit score scale/roles/defaults |
| Review estimates and uncertainty | `mfrm_results()` with explicitly computed supported intervals; `confint()` where admitted | Output-guide, interval and results tests; model-specific exclusions |
| Choose and customize a figure | `mfrmr_output_guide("plots")` → result `plot()`; `plot_data()` / `as_ggplot()` where supported | Plot-guide and result-class checks; unavailable conversions stated |
| Deliver a report or file bundle | `mfrm_results()` → `mfrm_report()` / `export_mfrm_results()` | Report/export/reopen checks; do not pass the return value of `plot()` as results |
| Give one rater a sheet | `mfrm_report(..., style = "rater")` | `test-rater-feedback.R` and `test-gmfrm-rater-feedback.R`; additive RSM/PCM and experimental two-family MML targets, privacy and replay |
| Reuse calibration | `extract_mfrm_calibration()` → review/freeze → save/load → `score_mfrm_calibration()` | Portable workflow help and installed replay; estimator/prior/format limits |
| Plan multivariate scores | `mfrm_multivariate_gstudy()` → `mfrm_multivariate_d_study()` → prespecified `mfrm_multivariate_d_compare()` | G/D examples, tables/plots and saved-result tests; source/future design distinction |
| Group mixed features | `mfrm_cluster_pam()` or explicitly hierarchical `mfrm_cluster_hierarchical()` | Feature guide; `mfrm_cluster()` remains a compatible alias, not a new algorithm |
| Explore numeric features | `mfrm_pca()` → `mfrm_cluster_kmeans()` when dimension reduction is intended | Numeric-feature tests; scaling, component retention and original-unit profiles |
| Review and pool missing assigned scores | `review_mfrm_imputations()` → `fit_mfrm_imputed()` → `pool_mfrm_imputed()` | Imputation tests; compatible old review name, eligible cells and pooling targets |
| Use dependence extensions | `fit_mfrm_random_rater()` / `fit_mfrm_testlet()` with model-specific scoring/response routes | Extension tests with dependencies present; conditional versus new-unit targets |

The listed entries have been checked against current exports/source. This is
an initial acceptance map, not a claim that every row has completed a new
end-to-end run. D2 closes only when each admitted model/task combination has
its actual help, example and replay evidence, and unsupported combinations
are explicit. Preserve specialist functions unless their role is truly replaced.

## D4 optional-dependency evidence

A passing check with skips is not evidence that the skipped model ran. Retain
a per-environment matrix of dependency/version, covered route, executed checks,
skips and reasons, linked to the source. At least one supported environment
must execute each admitted optional feature with its dependency present;
platform-dependent compiled routes also need appropriate Windows evidence.
Separately check the missing/too-old dependency message and unaffected core
workflows. Installed-version inspection alone is not feature-test evidence.

| Dependency / feature | Required supported case | Unavailable case / boundary |
| --- | --- | --- |
| RTMB >= 2.0 / shared-rater fitting and inference | Small actual estimation and applicable uncertainty/response checks; retain compiled version/platform | Missing or < 2.0 must give the documented actionable message; do not count skips as success |
| nleqslv / corrected JML | Explicit-order fit and supported scoring/output check | Missing solver must not silently switch estimator |
| cluster / feature clustering; mice / supplied imputation workflows | Exercise the admitted clustering and completion-review routes | No fabricated imputation or clustering when unavailable |
| ggplot2 / conversion; lme4 / optional mixed-model comparisons | Execute supported conversions/comparisons and retain version | Keep native/core behavior and clear unavailable routes |
| Other Suggests in DESCRIPTION | Map each admitted optional route to executed or explicitly inapplicable evidence | Explain skips; do not make all optional software mandatory for core use |

The September 24 Windows check skipped six tests because RTMB was 1.9; the
September 26 rc.6 logs contain five other skips and no old/missing-RTMB skip.
Do not merge those evidence states. The September 30 installed runtime checks
execute shared-rater tests with RTMB 2.0 and corrected-JML fitting/covariance/
replay with nleqslv 3.3.7; see the runtime record for source, results and remaining
checks. Dependency absence/version-error branches and the final Windows
environment remain separate evidence requirements.
These checks belong to the existing five-environment/targeted CI process;
no new service or broad duplicate simulation is required.

## Evidence to reuse and unresolved findings

| Record | Evidence that may be reused | What it does not establish |
| --- | --- | --- |
| [GMFRM algorithm and consumers](gmfrm-mml-em-20260927.md) | Literal equations, scores, EM ascent/direct-MML checks, owner identity, summaries, output and local-information tests. | Global identification, universal sparse support or coverage. sirt comparisons are restricted to an explicit common submodel. |
| [Sparse intervals and numerical repair](gmfrm-sparse-intervals-20260928.md) | 400 original datasets; all 100 common-Person SD=1 fits replayed at 61 nodes; subsequent retained numerical failures and independent likelihood checks. | Same-data refits are not independent confirmation. Task t3 coverage 90/100 after the SD=1 integration repair remains an adverse finding. |
| [Profile feasibility](gmfrm-profile-feasibility-20260929.md) | 80 new datasets / 160 requested component profiles under the original fixed procedure; availability, failure stages and cost. | Not a powered coverage comparison and not confirmation of later repaired procedures. |
| [September 30 repairs](gmfrm-sparse-intervals-20260928.md#2026-09-30-control-sensitivity-weak-slope-search-and-user-documentation) | Matched replay: 43 sources and 45 profiles, originally 43/45 complete; later targeted repairs recovered the remaining optimization/integration cases. | No new all-45 success rate: only affected cases were replayed after the last changes. No established coverage advantage or general boundary solution. |
| [Corrected-JML method](jml-inference-review-20260927.md), [sample comparison](jml-sample-comparison-20260927.md), [order comparison](jml-order-sampling-20260927.md) | Reference equations, fixed/random roster covariance, bias/SE/order results and adverse conditions; September 30 all-coordinate population-root/sample reconciliation reuses all 400 datasets. | No validated automatic selector or general structural interval. |
| [General-input JML](jml-general-inputs-20260928.md) | Non-prototype numerical checks, explicit-order fit/output/residual/EAP and fresh-process portable replay. | Engineering samples do not establish coverage, unique global roots or absence of residual bias. |
| [Portable MML GPCM](portable-gpcm-20260927.md), [JML GPCM](portable-gpcm-jml-20260927.md), [RSM/PCM JML](portable-jml-20260927.md) | Defined calibration formats, conditional scoring/prior and replay checks. | Conditional intervals omit calibration uncertainty; transport to another population needs its own interpretation. |
| [Claim/evidence ledger](claim-reconciliation-0.2.4.md) and existing G/D, feature/MI, feedback and dependence records | Earlier mathematical/workflow and source-specific package evidence. | Historical present-tense claims do not override this current plan or qualify later source. |

The existing targeted tests are reusable regression witnesses. For this
roadmap/commit task, package loading, 139 R-file and 273 Rd-page parses and
whitespace checks passed at `7f4f530c`; statistical studies and the full suite
were not rerun. Final current-source release checks remain open.
The subsequent roadmap reconciliation passed the existing public-language and
anchor-guidance checks (54 assertions), all local links in both current plans,
and incoming Markdown anchors to the public roadmap. The existing documentation
check now reads this current internal plan; historical checks keep their sources.

## Design and interpretation requirements

Use a question-driven selection, not a Cartesian expansion of all factors:

- **Assignment and links:** complete, all-rater common Persons, rotating or
  connected random panels, weak bridges and disconnected designs answer
  different questions. Match the primary rating budget and retain exposure.
  Connectivity does not establish slope identification. Reuse the existing
  PCM/JML anchor pilot and single-family sparse pilot within their own scope.
- **Anchors:** common Persons are observations, not fixed parameters. Exact
  anchors, perturbed anchors and estimated calibrations with uncertainty have
  different targets. Two-family anchor support is absent; supported-model
  anchor findings cannot be transferred to it.
- **Population:** under two-family fixed N(0,1), transforming
  `theta = mu + sigma*z` leaves first-family slopes unchanged, multiplies
  second-family slopes by sigma, divides locations/steps by sigma and absorbs
  the mean into the free second-family location. Compare to transformed truth.
  Normal SD changes affect targeting/information but are not by themselves
  distributional misspecification. Group-dependent ability, mixtures and skew
  are separate contrasts, selected only for a retained claim.
- **G/D planning:** preserve covariance admissibility and metric-specific
  results. Incomplete source data do not imply unequal future-plan support.
  Prespecified paired normal-theory differences do not support adaptive plan
  selection, nested/robust intervals or informative-missingness correction.
- **Dependence:** distinguish shared rater, Person-local performance/testlet
  and independent units. A nonzero local variance is not proof of halo;
  a zero variance is a boundary. Separate slope heterogeneity from omitted
  dependence before interpreting discrimination or rater feedback.
- **Dimensionality:** substantive structure, residual patterns and matched
  simulation may assess a one-ability assumption. Residual PCA/networks need
  exposure and null-calibration interpretation. A native multidimensional
  fitter is not a prerequisite for all diagnostic work.
- **External comparison:** compare equations, constraints, scale, data,
  population, likelihood and target before comparing numbers. TAM/ConQuest
  fixed-scoring checks and sirt submodel checks do not qualify corrected JML
  or all GMFRM estimators. GENOVA formula comparisons are not software parity.
- **Capacity:** measure an actual bottleneck with relevant Person/facet counts,
  pattern length, time, OS memory and accuracy. A workload result or a data-size
  cap is not a general capacity guarantee.
- **JML information and correction:** cross Person count with per-Person
  exposure, and track fixed-roster group sizes, structural dimension and
  owner-total state count. An inverse Hessian, RootSE or correction-order
  agreement does not establish centering on generating truth. Keep the raw
  and corrected procedures and their supported outputs distinct.

## Deferred structures and conditions to reopen

These are not a hidden checklist for 0.2.4, and do not defer the agreed
joint-slope/corrected-JML completion work above.

| Candidate | Reopen only when |
| --- | --- |
| Shared-rater interval expansion | A concrete method/numerical change, justified narrower target or feasible computation plan addresses the retained 800-dataset findings. More bootstrap draws alone do not repair unavailable tails. |
| General G-theory, nested intervals or unequal future rosters | A named assessment decision cannot be represented by current plans; define the structure, score/composite, uncertainty target and identification first. |
| Combined shared-rater/testlet effects, random slopes or heterogeneous task variances | A real decision requires them and matched simpler-model comparisons justify the extra structure. Define sharing, integration, identifiability and new-unit prediction together. |
| Broader slope action/families, multidimensional ability, process/mixture models | Constructs, response equations, loading/covariance identification, useful scores, uncertainty and maintenance cost are agreed. Multidimensional work remains explicitly deferred. |
| Portable ML/WLE, latent-regression portability, calibration-aware intervals | A defined scoring target and scale/prior/calibration-uncertainty contract can be validated; portable EAP does not implement these. |
| General diagnostic guarantees or adaptive design/weight selection | The actual decision and error criterion are specified. Finite simulation cannot supply universal guarantees; selected procedures need their own evidence. |

## Maintenance and review rules

After a work package, revise the relevant status row and identify its effect
on D1/D2. If a new study mainly explains the previous study, return to the
user decision before expanding it. Reopen completed work only for changed
behavior, a reproduced failure or a new admitted claim.

Keep internal identifiers, optimizer history, release gates and source hashes
in maintainer material. Public help/NEWS must retain model assumptions,
limitations and actionable numerical guidance without internal chronology.
Preserve independent mathematical checks, failure regression fixtures and
saved-object migration. No extra dashboard or progress artifact is required.
