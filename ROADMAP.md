# mfrmr roadmap

Status: public roadmap, updated 2026-09-30. This document sets priorities and
completion conditions; it does not promise release dates or unimplemented APIs.
See [NEWS](NEWS.md) for changes and the [README](README.md) for use and examples.
Start with [Active development milestones](#active-development-milestones)
for the authoritative scope, work order and completion decision. The
[release pillars](#release-pillars-and-current-consistency-priorities-2026-09-27)
explain the user purposes; the [portfolio decisions](#portfolio-decisions-and-long-term-maintenance)
explain longer-term priorities. Detailed sections retain evidence and model
restrictions, not additional independent queues of "next" tasks.

The working target is the integrated **0.2.4**. The local tree is labelled
`0.2.4.9000`; the older rc.6 candidate is a separate source checkpoint.
Joint-slope GMFRM and corrected-JML development remain unfinished parts of
the agreed program. Neither a numerical prototype nor a passing historical
archive makes the current program complete. Removing an agreed outcome requires
an explicit scope decision; it must not be hidden by changing version labels.

Mathematical completeness of the supported API and usable assessment workflows
take priority over publication novelty, model counts or software feature parity.
Correct concrete errors in targets, identification, uncertainty and saved output.
Finite validation cannot establish universal coverage or capacity guarantees.
The September 28 review uses local source and retained evidence; GitHub, website
and CRAN statements below are checkpoint records, not refreshed remote status.

## Release pillars and current consistency priorities (2026-09-27)

The working release target is an integrated **0.2.4** organized around three
user purposes. This is a scope target, not a claim that the newer source has
been released or that all two-slope outputs have been qualified. The
existing rc.6 tag and its evidence remain unchanged. Freeze the final version
metadata only with the assembled source at D3.

| Pillar | User question | Delivered foundation and remaining acceptance condition |
| --- | --- | --- |
| Generalized many-facet Rasch measurement | How do ability, severity, category use and discrimination explain ratings? | Public RSM/PCM and one-slope-family GPCM; provisional task/rater product-slope MML--EM with summary and conditional fitted curves. Complete G2/G3 before claiming qualified joint-slope inference: identification and uncertainty targets, remaining output consumers and numerical/sampling qualification. GMFRM names a family generalized from MFRM, not strict equal-discrimination Rasch measurement. |
| Multivariate generalizability theory | How dependable are criterion and composite scores under alternative assessment designs? | Existing crossed/nested G/D-study point estimates, incomplete-source MINQUE(0) and scoped paired plan intervals. Preserve score covariance, weights, missingness, source versus future design and uncertainty meanings. It is not a joint latent GMFRM/G-theory model. |
| Rater feedback and assessment decision support | What should a teacher, assessor or researcher review or change, and how uncertain is that recommendation? | Existing diagnostics, plots, saved reports, portable scoring and individual feedback sheets. Sheets currently accept native additive RSM/PCM only; GPCM and extended models are rejected. Connect supported GMFRM outputs under their own inference contract before claiming integrated GMFRM sheets. Retain source/scale, comparison population, assignment exposure and uncertainty; do not equate severity, slope or misfit with rater competence. |

The third pillar is a coherent applied workflow, not another model family.
External features, clustering and assigned-score imputation support these
purposes; they do not require new competing entry points. A useful finished
workflow connects rating-data review, model choice, relevant diagnostics,
feedback, assessment planning and reusable output. GMFRM and G/D results retain
separate estimands even when they use the same assessment. A report may link
them; it must not pool incompatible numbers or manufacture a common reliability.

**Execution order within D2/D3:**

1. Settle the existing two-owner model/output contract (G2), alongside affected
   single-owner, RSM/PCM and corrected-JML consistency work. Audit the actual
   prediction, intervals, fit/bias, Wright/Pathway, feedback and save/replay
   routes for each supported model. Adapt legitimate targets and explicitly
   refuse unsupported ones; relabelling an ordinary-model result is insufficient.
2. Complete the numerical identities and selected statistical checks below
   (G3), including the [dependence gates](#dependence-testlets-and-random-effects-integration-order-2026-09-28). Freeze model, scale, target and handling of unavailable results before
   interpreting a sampling study. Do not use old PCM/JML results to admit
   two-owner MML. Research status of corrected JML remains separate; exclusions
   from an agreed release scope must be explicit rather than silently deferred.
3. Finish the user workflow and visual explanation (G4): one beginner-oriented
   route per purpose, model-specific limitations, exact tables behind plots,
   saved replay, consistent help/NEWS. GPCM feedback-sheet support and the
   supported plot choices must be stated precisely, not inferred from exports.
4. Freeze the assembled source and complete D4/D5 checks for that source.
   Completion means the admitted workflows agree mathematically and operationally
   and have matching evidence. It does not mean every G-theory structure,
   multidimensional model or general coverage guarantee has been implemented.

**Current public-integration audit (2026-09-29).** In this execution order,
G2 means the **joint-slope fit/output contract** in the joint-task/rater table
below. The historical PCM/GPCM equal-slope-test work also used a G2 label;
that completed single-family calculation does not close joint-slope G2.
The public `fit_mfrm()` now dispatches an explicit pair of slope owners to
fixed-N(0,1) MML--EM, reusing the existing fit class. The admitted route is
summary/print, provisional conditional category or information curves, separately
checked component-slope intervals, descriptive same-data posterior response
diagnostics, plots, saved fit/plot results, reports and exports. Unsupported arguments are refused;
unchanged single-family calls keep their existing estimation defaults.
Numerical convergence does not promote primary slope estimates or intervals.
The capability table now marks two-family fitting/EM as provisional scope,
while formal corrected-JML structural intervals remain unavailable. Its separate
explicit-order fit/output/EAP route is described under J1–J4. One-family GPCM EM still falls back
to direct. This is partial G2 delivery, not completed G2/G3/G4 or a new release.

Continue joint-slope G2 through these deliverables, in order, using existing
classes and retaining current single-family behavior:

1. **Fit specification and result identity.** Admit the agreed two-family
   specification through `fit_mfrm()` only with an explicit scope and unchanged
   existing defaults (implemented for the scoped route above). Store the model equation, ordered owner roles, step owner,
   population/scale constraints, estimator and actual engine. The internal
   no-anchor, unit-weight, fixed-N(0,1), two-facet contract is the starting scope,
   not evidence for other structures. Preserve numerical failure and local
   versus global identification distinctions.
2. **Summary and printed meaning.** The shared scale contract, slope/settings
   summaries and printed scale descriptions now preserve both owners. They
   distinguish the first family's geometric-mean-one reference from the free
   second family on fixed N(0,1), without pooling their estimates or promoting
   optimizer values to primary estimates. Focused checks cover overlapping
   level labels, Unicode names, nonconvergence, unavailable uncertainty and
   save/reopen; the saved public single-family summary is unchanged. This
   closes the shared summary defect. The internal result adapter now exercises
   these methods with actual EM estimates and a current readiness record;
   public two-family dispatch now preserves these meanings. Targeted public
   tests also cover nonconvergence and exact replay; expanded profiles remain
   unavailable until their output contracts are adapted.
3. **Prediction, diagnostics and figures.** Route supported response targets
   through the shared evaluator. Conditional probability/information curves
   now have a public route with literal-equation checks, owner labels and
   unavailable intervals preserved through plots and reports. Same-data posterior
   predictive response diagnostics now integrate ability at the retained two-family
   calibration, preserving row identities and incomplete assignments. Independent
   continuous integration, mixture variance, row selection, unresolved groups and
   saved plot/report/export paths have focused checks. These descriptive Infit/Outfit
   summaries have no expectation-one reference or calibrated fit cutoffs; slope
   covariance is not required. Explicitly review Wright/Pathway,
   infit/Q3/PCA and bias targets; support must not be inferred from a common
   probability kernel. Reuse the supported result/plot/report classes and
   explain any unsupported target. Structural covariance calculation does not
   automatically admit confidence intervals, IC/LRT or calibrated fit tests.
4. **Complete the use case.** The provisional fit-to-summary-to-figure-to-report
   and saved-export route now has a targeted test with named facets and a known
   unobserved crossing. Keep
   portable calibration/new-person scoring and rater-feedback sheets explicit
   until each is adapted; internal RDS replay is neither feature. G3 statistical
   qualification still gates the corresponding public inference claim and G4
   gates the integrated release. Do not start another broad simulation before
   fixing the estimator, target, failure handling and consumer contract.

This audit does not remove the agreed joint-slope or corrected-JML milestones
from 0.2.4. It identifies unfinished work; the current tree is not a completed
release solely because the single-family routes or numerical examples pass.

### Sparse assignment, anchors and population variation

More perspectives are needed, but not an indiscriminate full factorial study.
The next checks must answer whether a supported result remains interpretable,
not simply whether an optimizer returns. Existing evidence includes the
[147-fit, three-seed PCM/JML anchor pilot](inst/validation/rater-anchor-sparse-stress-pilot-record-0.2.3.md),
the [80-dataset single-slope-family pilot](inst/validation/gpcm-separated-owner-pilot-record-20260926.md)
at ability SD 1.2, and [two-owner numerical evidence](inst/validation/gmfrm-mml-em-20260927.md).
None qualifies the full combination of two-owner slopes, sparse links, anchors
and varying populations. Historical readiness rules also differ from today's
output-specific inference rules. No broad two-owner sampling study is currently
established by these records.

| Question | Priority contrast | What must be kept distinct |
| --- | --- | --- |
| Does the assignment identify the target? | Complete, all-rater common-person set, rotating panels, connected random panels, weak bridge, bridge loss/disconnection; match total ratings in the primary budget comparison and report per-person/pair exposure. | Observed common persons are links, not fixed ability parameters. Graph connectivity does not establish slope separation or full marginal rank. A connected random roster is an explicit design condition, not representative of all random draws. |
| Are links informative across the ability range? | Range-spanning versus central/restricted linking persons; equal overlap counts; common links chosen independently versus associated with ability/group. | Similar density can hide different information. Use generating ability only to define simulation conditions; real-data link selection cannot assume true abilities are known. |
| What do anchors actually fix? | No external anchors, exact externally fixed values, perturbed values, calibration estimates with uncertainty; vary where anchors sit in the network and their scale coverage. | Severity/location anchors need not identify scale or both slope families. Fixed-value conditional intervals do not include external calibration uncertainty. The scoped two-owner fitter currently has no anchor support: keep those cases in supported-model lanes until the anchor contract is implemented. |
| What changes when ability SD changes? | On a declared generating logit scale use SD 0.5, 1, 2; then separate normal scale normalization, group-specific mean/SD, and skew/mixture misspecification. | Same nominal parameter values on different identified scales are not the same truth. Public single-owner estimated-population MML and provisional two-owner fixed-N(0,1) MML have different constraints. Do not fix two slope-family means and population SD simultaneously. |
| How do other sources of heterogeneity matter? | Hold other factors fixed while varying rater severity, task location and discrimination spread; for multivariate G theory vary person covariance, cross-criterion correlations and near-zero nuisance components. | Ability SD is not rater SD. Correlation and variance changes must preserve a valid generating covariance. Increasing person variance alone can raise G/Phi without improving measurement error; inspect SEM on the declared score scale. |
| Do missingness and dependence change the conclusion? | Planned nonassignment versus missing assigned scores; independent loss versus selective loss; common-performance or rating-occasion dependence as deliberate model misspecification; a latent effect does not establish halo. | Do not fill unassigned ratings or label every sparse design MAR. Existing incomplete-source G-study support does not support arbitrary unequal future D-study rosters. |
| Is the numerical result stable enough to interpret? | Alternative starts, stricter integration/reference calculation at prespecified representative and adverse cases; scale person count, facet counts and ratings per person separately. | Approximation error, optimization, statistical identification and sampling error are separate outcomes. Record memory/time and every failed/unavailable case, not just successful fits. |

The scale check comes first. In the two-owner equation, writing
`theta = mu + sigma*z` gives equivalent standardized parameters
`a_task' = a_task`, `a_rater' = sigma*a_rater`,
`b_task' = b_task/sigma`, `s_rater' = (s_rater-mu)/sigma`, and
`tau_rater' = tau_rater/sigma`. Task log slopes and task locations retain their
sum-zero constraints. Test equality of conditional probabilities and joint
Person marginal likelihood before scoring recovery against transformed truth.
Anchors, if introduced, must transform consistently; one globally equivalent
normal scale does not resolve different ability distributions across rater
panels. Under correctly transformed truth, an SD manipulation can still change
response targeting, category exposure and finite-sample information; it is not
by itself evidence of population-model misspecification.

Reuse saved paired outcomes first. Then use a small prespecified diagnostic
stage to identify consequential failures, followed by confirmation only for
retained inference claims. Select replication counts by Monte Carlo precision,
not a wall-clock cutoff or significance hunting: nominal 95% coverage needs
about 119 independent datasets for a 2-percentage-point MCSE and 475 for one
point, before allowing for unavailable intervals. These are planning
approximations, not coverage guarantees. Report bias/RMSE, interval width,
availability, conditional coverage, reported-and-covered frequency and MCSE;
multiple correlated targets from one dataset are not independent replications.
Include conditional bias by severity/ability and false-flag/sensitivity results
only where truth defines an actual diagnostic target. Prespecify extra work
and stopping reasons; resume interrupted jobs without silently dropping cases.
The primary sparse-design references are [Wind and Ge (2021)](https://doi.org/10.1177/0013164420988108)
and the complementary G/MFRM literature, not a universal minimum anchor rate.

### Dependence, testlets and random effects: integration order (2026-09-28)

This section governs dependence-related additions to G2--G4. It refines the
existing scope rather than opening a combined-model implementation now.
**Two discrimination families do not remove local dependence.** The current
two-owner likelihood multiplies ratings conditional on one ability and fixed
facet parameters. A large slope is not evidence that this independence
assumption holds, and adding slopes can change the apparent fit without
correctly representing shared performance variation.

| Model feature | What is shared, and by whom? | Current implementation and decision |
| --- | --- | --- |
| Fixed facet locations and one/two slope families | Parameters describe named levels; responses are independent conditional on ability and the specified fixed context. Estimated parameters have uncertainty, but are not thereby random effects. | Public one-family GPCM and provisional two-family MML--EM. Complete G2/G3; do not advertise a dependence correction. |
| Person-local testlet effect | A latent effect is shared by repeated ratings within a Person/block pair. Reusing the block label for another Person creates a different effect. | `fit_mfrm_testlet()` implements RSM with one common local variance and nonoverlapping blocks. It does not estimate a separate variance for every task. |
| Shared random rater severity | One latent rater effect applies across all persons rated by that rater; effects follow a declared population distribution. | `fit_mfrm_random_rater()` implements approximate RSM MML. Existing/new-rater prediction and retained individual-interval restrictions remain distinct. |
| Random slopes or combined slope/testlet/shared-rater models | Discrimination itself could follow a population distribution, possibly correlated with severity, while further effects share selected ratings. | Not implemented by having two fixed slope families. Requires a new identified likelihood, integration and inference contract; later extension under the gates below. |
| Multiple substantive abilities | Ratings depend on more than one intended construct. | Still deferred. A testlet adds latent dependence dimensions even if there is only one substantive ability; it is not evidence for a second substantive trait. |

A testlet effect is itself a random effect. The distinction from a shared
rater effect is its sharing structure and target, not whether random effects
are used.

**Specify the sharing unit before the formula.** For a speaking rubric,
Person-by-Task can represent a performance effect shared across criteria and
assessors. Person-by-Task-by-Rater can instead represent a rating-occasion
impression shared across that assessor's criterion ratings. Person-by-Rater
can represent an effect extending across that person's tasks. These are
competing assumptions, not interchangeable labels for halo. A shared rater
severity effect extends across persons and is different again. The data need
replication at the relevant levels to distinguish them. The current testlet
route permits one chosen nonoverlapping block definition; it cannot fit all
these overlapping sources together. A nonzero variance does not identify a
psychological cause such as halo, and a near-zero estimate does not prove
local independence when replication is weak.

Conditional independence means factorization after conditioning on **all**
the model's shared latent effects. Ratings can remain marginally dependent
after those effects are integrated out. Person-local blocks permit nested
integration within each person. A shared rater crosses persons, so the
marginal likelihood cannot be obtained by independently redrawing that rater
for each person. EM is an optimizer, quadrature/Laplace are integration
choices, and a normal random-effect distribution is not a Bayesian prior on
all model parameters. For future slope/testlet combinations, explicitly decide
whether the local effect is inside or outside the slope multiplier; the
choice changes the effect's units and variance interpretation.

**Milestones and acceptance gates.** Retain G2--G4 as the tracking units:

| Order | Work and completion evidence | Scope disposition |
| --- | --- | --- |
| G2: effect and prediction contract | For each existing model record the response equation, effect-sharing keys, population/identification, conditional versus integrated prediction target, and existing/new Person, rater or block handling. Check save/replay, diagnostics and plot labels against this contract. Never substitute a conditional mode for a population-integrated prediction without labelling it. | Required for the integrated 0.2.4 workflows, alongside two-owner public API work. Reuse existing result classes; no new universal formula/API is presumed. |
| G3: distinguish slope heterogeneity from dependence | Use the contrasts below to assess parameter distortion, curve/score uncertainty and misleading feedback when local dependence is omitted. Reuse matched RSM testlet/shared-rater evidence first. Two-owner misspecification tests remain tests of the independence model unless a matched dependence-aware estimator exists. | Required evidence for the claims retained at release; do not claim a combined estimator from a generating model or reference calculation. |
| G3: qualify diagnostics and comparisons | Separate descriptive residual patterns from calibrated tests. Match events, categories, scale, population and likelihood normalization. Zero local variance is a boundary; do not reuse the regular PCM/GPCM chi-square test or assume a universal 50:50 mixture. Check independent-unit assumptions before sandwich/bootstrap inference. | Repair unsupported claims now. New automatic thresholds, variance tests or shared-effect robust intervals require their own validation. Person clustering alone need not handle shared-rater dependence. |
| G4: user workflow | Explain model choice with a rubric example; retain uncertainty basis and unobserved-context flags in reports. Plot comparable conditional or integrated curves on common axes; keep residual-pair exposure counts and unavailable cells visible. Wright maps remain location displays; ordinary infit/Pathway cutoffs do not automatically transfer. | Finish applicable existing displays and document unsupported routes. A residual-dependence heatmap is a candidate only after its estimand and null calibration are defined; it is not implemented by this plan. |
| Later combined model | First specify one practical decision requiring both existing sources. Demonstrate identified special-case reductions, accurate joint integration, boundary handling, prediction targets and maintainable common consumers. Start with a justified simplest response model before adding random slopes/correlations. | Joint shared-rater/testlet, PCM/GPCM testlets and random slopes stay later work. This does not defer the agreed two-fixed-slope integration. |

The first G2 delivery check now closes a concrete reporting omission:
testlet results/reports export the saved scoring roster, not only observed
block counts. Missing assigned scores, source column names and unselected
Persons remain recorded. Testlet settings identify Person/block integration
and roster replacement; random-rater probability settings identify observed
conditional versus replacement-population integration and shared rater IDs.
Focused checks cover independent probability integration, Person-local scoring,
CSV/RDS/report propagation and old scores lacking roster fields, without
refitting during reporting. GPCM scoring already retains its prior/population
basis and is unchanged by this repair. This does not complete the model-wide
prediction/diagnostic audit or the public two-owner contract.

For a future combined model, reduction checks must match identification and
population conventions: zero testlet variance should recover its matched
no-testlet model; unit slopes should recover the matched equal-slope kernel.
Zero random-rater variance removes rater heterogeneity; it does **not** recover
an arbitrary fixed-rater MFRM with unequal severities. Near-zero variance and
weak identification must retain their status rather than being regularized
into ordinary intervals. Accurate local integration is not proof of accurate
profile endpoints or sampling coverage.

**Selected stress-test contrasts, not a Cartesian expansion.** Predeclare and
complete each selected case list; use existing Monte Carlo precision/stopping
rules above, with no automatic deletion of cases at a time cutoff.

| Question | Paired contrast | Decision evidence |
| --- | --- | --- |
| Are slopes absorbing unmodelled dependence? | Independently vary slope heterogeneity and zero/moderate/strong Person-local variation on the same identified scale. Include equal-slope data with dependence and two-family data without it. | Bias/RMSE and uncertainty by owner, score/curve distortion and false feedback flags; likelihood gain alone is insufficient. |
| Is local variation distinguishable from ability? | At comparable rating budgets vary tasks per person versus repeated criteria per task, balanced versus unequal block sizes, and few versus many blocks. | Variance separation, boundary/availability frequency and uncertainty. More within-task criteria need not add the information of independent tasks; effects depend on response targeting and the specified model. |
| Can assignment separate shared sources? | Common performances, rotating/random panels and weak/lost bridges; vary persons per rater and repeated ratings per Person/block independently. Include differing ability distributions across panels. | Check design rank/information and assignment assumptions. Location anchors do not remove dependence or supply missing replication; planned nonassignment is not an imputation target. |
| Does approximation alter the decision? | Reuse saved representative/adverse fits, increasing Person and local integration orders separately; verify the shared-rater integral independently where relevant. | Distinguish numerical error from misspecification and sampling error. A Person quadrature check does not qualify a shared-rater Laplace approximation. |
| Does prediction generalize to the intended unit? | Hold out complete performances/blocks for a new-performance target, persons for new persons, or raters for replacement raters; state what observations remain available for conditioning. | Use target-matched predictive scores and uncertainty; random row splits can leak a shared block effect and answer an easier conditional question. |

**G/D-study connection.** Neither local latent variance nor the sampling
covariance of slope estimates is a multivariate G-study variance component.
Keep observed-score G/D studies as the available complementary planning route.
A model-based task-versus-criterion allocation extension must define the future
roster, score composite and conditional or population-average target, then
propagate the joint response covariance and calibration uncertainty. Summing
per-rating marginal information as though dependent ratings were independent
is not that calculation. Testlet modelling alone does not enforce equal task
weights or establish halo.

Foundations: [Wang and Wilson (2005), Rasch testlets](https://doi.org/10.1177/0146621604271053)
and their [random-effects facet model](https://doi.org/10.1177/0146621605276281)
motivate the existing local-effect interpretations; [Bradlow, Wainer and Wang
(1998)](https://www.ets.org/research/policy_research_reports/publications/report/1998/ihdw.html)
study precision consequences of testlet effects and designs. [Rijmen (2009)](https://www.ets.org/research/policy_research_reports/publications/report/2009/hycg.html)
clarifies formal relations among testlet, bifactor and second-order models.
These references motivate model distinctions, not validation of mfrmr's
specific estimators or a reason to equate every GMFRM/multilevel formulation.

### One-ability checks and exploratory residual networks (2026-09-28)

One substantive ability remains the current measurement target; native
multidimensional GMFRM remains later work. This does not defer checking whether
a one-ability model is adequate for the intended decisions. Separate (a)
evidence against the fitted model, (b) a hypothesis about what explains the
misfit, and (c) fitting/comparing a specified alternative. Neither an absence
of flags nor a preferred multidimensional model proves the construct theory.

**Current implementation audit.** `analyze_residual_pca()` has overall and
facet-level standardized-residual PCA and a within-column permutation reference.
The latter fixes residuals/missingness and does not simulate ratings or refit.
`q3_statistic()` pairs standardized residuals averaged within Person/facet-level
cells; it is not original raw-residual Yen Q3. Marginal-fit companions are
descriptive and are not calibrated M2/C2 tests. Assignment and rater score
networks are implemented. Residual PCA now also has an opt-in fitted-model
bootstrap for additive RSM/PCM MML with fixed N(0,1), fixed quadrature, unit
weights and no anchors/shrinkage. It retains every refit attempt and withholds
an affected reference if any replicate is unavailable. Residual-network/EGA,
Q3 bootstrap calibration and a native multi-ability fitter/comparison remain
unimplemented. The [earlier TAM dimensionality pilot](inst/validation/tam-dimensionality-pilot-record-0.2.3.md)
checks prespecified 1D/2D structures and integration in external binary Rasch
examples; it does not qualify many-facet GMFRM comparisons or a released API.

The next work should strengthen interpretation and statistical support before
adding another model-selection entry point:

| Priority | Work and acceptance condition | Dependency and release status |
| --- | --- | --- |
| 1: coherent diagnostic inputs | Reuse existing residual/PCA/Q3 outputs. Declare observation unit, node/column map, raw versus standardized residuals, aggregation, weights, posterior basis, pairwise overlap and unavailable comparisons. Preserve signed associations and source settings through plots/replay. Different matrices answer different questions; do not silently equate overall combined-facet columns with criterion-level summaries. | Existing scope/interpretation and help integration belong in 0.2.4. Current help audit complete; no new statistical test is implied. |
| 2: model-generated reference | For a declared supported model, simulate joint Person rating patterns under the fitted one-ability null, preserve the intended assignment/observation mechanism, refit with the same identification/integration policy, and recompute a prespecified statistic. Record every attempted replicate and failure. Calibrate family/max-statistic decisions when scanning many pairs. | First executable PCA route implemented for additive RSM/PCM MML with fixed population/quadrature. Same-design generation/refitting is reused, all attempts and scope availability are retained, and summary/plot/ggplot labels identify the reference. This establishes the mechanism, not G3 error-rate qualification: true-null false flags, sensitivity and sparse-design availability remain to be assessed. GPCM, JML, estimated populations, Q3/max-statistic calibration and dependent latent effects are not admitted by this route. |
| 3: residual-network exploration | Define nodes and edge estimands before rendering: residual correlations versus partial correlations, conditioning variables, regularization, edge/community stability and missing-edge handling. Reuse existing matrices/counts and an established optional graph backend after qualification; do not add dependencies or automatic dimension selection now. | Proposed exploratory extension, not implemented. A residual graph is neither raw-response EGA nor a jointly fitted residual network model. Independence assumptions determine resampling units; shared raters can invalidate independent-Person bootstrap. |
| 4: explicit alternatives | Define substantive dimensions and loading/Q structure in advance, with enough informative indicators, scale/covariance identification and a scoring use. Compare a one-ability, dependence-aware and substantive multi-ability explanation where compatible external models exist. Freeze discovery versus confirmation data and prediction targets. | Native multidimensional GMFRM remains later work. External TAM/mirt comparison is optional earlier evidence only for matched response equations, events, constraints, population and integration; imports currently support one dimension. No ordinary chi-square LRT is presumed for correlation-one or unidentified-loading reductions. |

The [2026-09-28 RSM/PCM pilot](inst/validation/residual-model-bootstrap-20260928.md)
completed its full 96-dataset roster and 3,744 refits. Criterion references were
available throughout; all 48 sparse overall/rater references were unavailable
despite successful model estimation. Matched-null first-component flags were
0–1/12 per cell, versus 3–5/12 when scanning all component cutoffs. The block
condition yielded 11–12/12 first-component flags, but SD misspecification only
1/12. The small outer count and 39 inner draws do not qualify error rates.
Consequences are implemented in scope messages, plotting and help: no automatic
fallback aggregation, no dimension-count conclusion and no familywise claim.
The reference path skips unused marginal tables after an exact-value replay
check. A visual audit also repaired residual-PCA ggplot conversion that had
incorrectly used generic tabular bars. Further statistical work must answer a
specific stronger reporting claim; this pilot does not admit GPCM or require
an open-ended simulation grid. Testlet and correlated-trait interpretations
can coincide for the declared block generator, so cause identification is not
an achievable classifier target in that cell.

A model-generated reference can challenge the null without fitting the
alternative. To assess sensitivity, generating two-ability data does not
require adding a public multidimensional estimator either. Reuse existing
controls and prespecify a small set that separates: true one-ability local
independence; one ability plus testlet/rater dependence; two substantively
organized abilities; and assignment/population misspecification. Vary latent
correlation, node exposure and weak links only where they answer the chosen
question. Keep true-null false-flag rates, alternative sensitivity, diagnostic
availability, score/decision impact and Monte Carlo uncertainty separate.
A failed null replicate cannot be silently replaced to obtain a successful
reference distribution. More permutations or bootstrap draws do not repair
a misspecified null or insufficient design.

For network analyses, communities aligned with task blocks, assessors or
assignment panels are competing explanations for a cluster aligned with rubric
content. A community algorithm can partition noise; a sparse graph can reflect
regularization. Never report community count, residual-component count or
component count plus one as the number of substantive abilities. Undefined
pairwise correlations are not zero edges. Do not hide indefinite correlation
matrices behind automatic repair; any changed estimator must be explicit.
For ordinal original scores an appropriate ordinal correlation model may be
needed, whereas continuous fitted residuals are not automatically ordinal
variables. Highly unequal overlap is not summarized by one arbitrary sample
size for a penalized network.

Confirmatory evidence may include prespecified subdomain score comparisons on
a common scale, external relations, limited-information fit and target-matched
held-out prediction. A naive paired t-test on independently treated EAPs, after
selecting subsets on the same data, is not a qualified replacement. Retain
sampling covariance, shrinkage and selection uncertainty. A network cannot
alone distinguish multidimensionality, local dependence and rater/assignment
misspecification; substantive evidence remains necessary.

The existing [visual diagnostics guide](vignettes/mfrmr-visual-diagnostics.Rmd#checking-one-substantive-dimension-without-fitting-a-multidimensional-model)
now gives this user route, API availability and primary references: Christensen,
Makransky and Horton (2017) on Q3 reference distributions; Golino and Epskamp
(2017) on EGA; Epskamp, Rhemtulla and Borsboom (2017) on joint residual network
modeling. These support distinct methods, not equivalence with the current
standardized/aggregated residual screen. A future common diagnostic result may
summarize available evidence, but must not manufacture a pass/fail verdict or
another wrapper that merely repeats existing tables.

### Visualization follows the decision, not the model dimension

Multivariate score components do not require a 3D graphic. Current D-study
plots are 2D: task/other-condition counts on one axis, G/Phi or SEM on the
other, with the remaining facet count represented by lines. The metrics use
separate panels; score/composite choice is explicit. A separate comparison
plot displays differences and approximate intervals. Current point-projection
plots have ggplot conversion; comparison plots are base graphics only.

| Decision | Current or planned display | Acceptance condition |
| --- | --- | --- |
| Add tasks or raters? | Existing 2D lines/points, exact values and G/Phi or SEM panels. | Counts and weights explicit, unavailable values retained, color plus shapes/line types, no implied confidence bands or interpolation estimates. |
| Compare many two-facet combinations? | Next useful extension: a labelled heatmap or small multiples within the existing plot API; not yet implemented. | Use saved scenarios, distinguish absent/unavailable cells from zero, preserve nested per-parent counts and metric units, supply an accessible table and matching base/ggplot behavior. Do not smooth discrete designs into a purported fitted surface. |
| Is a proposed improvement large and precise enough? | Existing prespecified plan-difference interval plot. | Keep paired uncertainty, pointwise interpretation and the difference between no evidence of improvement and equivalence. |
| Explain a covariance source across criteria? | Existing component tables; a signed covariance/correlation display is a later targeted option. | Do not present negative/indefinite estimates as positive variance shares or discard them silently; scales and availability remain explicit. |

3D is optional later exploration if a concrete comparison benefits from it,
not a release gate. Any 3D view would need an equally usable 2D/table route;
rotation, perspective and hidden values must not be required to read a result.
Prioritize purposeful selection, common axes for comparable panels, readable
labels, monochrome operation and explicit title/annotation controls. Do not
claim every current base plot already has those controls. No new graphic
backend is required to finish the present model contracts.

## Current releases

mfrmr 0.2.4.9000 is under development and has not been released.
The development branch includes individual fixed-rater feedback sheets, a
purpose-based plot guide, additional saved-result ggplot conversions, session
plot defaults, random-rater bootstrap diagnostics and separate-owner GPCM MML.
These additions have focused local evidence; they are separate from the checked
0.2.4 candidate described below and do not inherit its platform-check results.
Development commit `e6f8397b` passed its own
[five-environment CI](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36234591527).
The subsequent description corrections are integrated into local and GitHub
`main` at `08a5ee9b`. That exact source has a successful local source build,
including 15 vignettes, and all five environments passed its own
[CI](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36236715063).
The [website workflow](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36236714819)
was pending at that checkpoint; its present state is not verified in this review.
Subsequent local changes implement conditional portable GPCM MML, scoped
RSM/PCM and shared-owner GPCM JML portability, prior sensitivity and an
experimental relative-slope profile route. These changes are not in local
HEAD `08a5ee9b`; the assembled working tree has completed the scoped local checks,
but not its hosted/publication integration gate. Earlier CI results do not apply
to this whole changed source. The later local source freeze now passes normal
package checks and a complementary illustrated-archive/manual check; matching
hosted CI and publication remain open.

| Source or evidence layer | What is established | What remains separate |
| --- | --- | --- |
| Frozen rc.6 (`a7529b73`, implementation `6f541bfa`) | Recorded candidate archive, platform, website and Windows checks below. | Later APIs and repairs are absent; a candidate is not CRAN acceptance. |
| Committed development checkpoint (`08a5ee9b`) | Recorded integration of feedback/interface additions and separate-owner MML, with its own CI. | Later uncommitted additions have separate local evidence and still need matching hosted checks. |
| Local development (`0.2.4.9000`, after that checkpoint) | Implementations, scoped external scoring comparisons, frozen source manifest, illustrated archive and successful local package/documentation checks described below. | Commit/main integration, matching platform/publication evidence and a release-version decision. |
| JML inference research | Exact profile-score/population-root calculations, a paired 200-dataset comparison of one-step correction, design-aware iterations with sparse/unequal-roster covariance, and exact owner-total expectations verified on a 32-rating sample. A generalized internal observed-data equation and full-Jacobian covariance now pass independent non-prototype checks and a three-judge/four-category sample calculation. | An explicit experimental shared-owner corrected-JML fit/output route is now connected locally. Conditional observed-row response diagnostics and conditional new-Person/portable EAP are now connected. Residual-bias treatment, statistically justified automatic order selection and formal structural intervals remain open. |

No overall completion percentage is assigned: implemented functionality,
statistical qualification, source integration and publication have different
denominators. Closing one does not close the others.

mfrmr 0.2.4 is a release candidate. It has not been released on CRAN.
The current candidate is
[`v0.2.4-rc.6`](https://github.com/Ryuya-dot-com/mfrmr/releases/tag/v0.2.4-rc.6).
It combines reusable calibration,
external-feature analysis, assigned-score imputation, fixed-facet intervals,
rater-feedback tools, multivariate observed-score G/D studies and the documented
shared-rater/testlet workflows with the latest GPCM inference and API improvements.

The tag points to `a7529b73`, which adds only package-excluded result records to
implementation commit `6f541bfa`. The implementation passes
[all five CI environments](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36155335441):
macOS/R-release, Windows/R-release and Ubuntu/R-release, R-devel and R-oldrel-1.
Every package check reports `Status: OK`; international-input and saved-result
portability checks also pass. These are ordinary package checks, not five new
exhaustive or `--as-cran` runs.

The attached source archive and SHA256 were verified by downloading both after
publication. The archive includes 15 matching tutorials and 72 figures with
alternative text. Its local checks combine the initial exhaustive check,
focused repairs and complementary checks described under M5; they are not
represented as another exhaustive run. The archive SHA256 is
`0f1f21c042512318a3b3c8ffbce246bcdab21db1d3dc2dce2cf5e091c58155e1`.

The matching [website build](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36155335057)
and [Pages deployment](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36159750653)
succeed. Published help and tutorial source links identify `6f541bfa`.
Seven extended-model examples use saved synthetic results for quick inspection;
complete recalculation instructions remain available. The GPCM guide retains
known adverse coverage results and distinguishes numerical availability from
statistical accuracy.

Earlier candidates, including rc.5, remain unchanged evaluation snapshots.
They also report package version `0.2.4`; retain the exact tag or archive checksum
with saved analyses. Earlier Win-builder checks refer to their uploaded sources.
The same rc.6 archive has now completed Win-builder checks for R-release and
R-devel: both have zero errors, zero warnings and one NOTE about maintainer
information and update frequency. Examples, tests, vignette rebuilding and
manuals pass; the logs and binaries have been preserved locally. URL review
found no problems, and the current
CRAN-index review found no reverse dependencies in the five dependency categories.
No CRAN submission is recorded here. Candidate publication, a final release
decision and CRAN acceptance remain separate; successful package checks do not
establish general statistical guarantees.

| Workflow | Frozen rc.6 position | Role in the planned 0.2.4 |
| --- | --- | --- |
| Portable calibration and new-Person scoring | Implemented for the stated fixed-normal RSM/PCM MML scope. | Preserve the supported workflow and corrections during integration. |
| External-feature clustering and imputation sensitivity | Included in the candidate, including hierarchical trees, plots and setting comparisons. | Preserve descriptive interpretation and paired imputation comparisons. |
| Multivariate observed-score G/D studies | Crossed/nested point projections and explicit normal-theory intervals for prespecified two-crossed-facet plan differences are included. | Preserve the supported designs, uncertainty assumptions and metric-specific availability. |
| Structural/model extensions | Person-by-(Child-within-Parent) multivariate G/D-study point estimates are included in the baseline. Shared-rater and testlet RSMs are included for their bounded conditional/descriptive scope; broader inference remains unqualified. | Retain the G/D-study and two RSM workflows specified below; the matching candidate, archive and help are published. |

## Active development milestones

This section governs the assembled `0.2.4.9000` working tree and supersedes
older forward-looking sentences elsewhere. Some additions are committed and
others remain local; the combined 0.2.4 scope is not complete or frozen.
GitHub publication is a source checkpoint, not statistical qualification.

### Scope and completion decisions

Read each row as a user outcome, not a promise that every model supports every
operation. "Implemented" means an existing callable route within its stated
scope; it does not mean the latest combined archive is release-qualified.
Research calculations are identified separately. These statuses must not be
collapsed into a percentage based on function or test counts.

| User outcome | Present state | Required completion or explicit decision |
| --- | --- | --- |
| Explain and reuse a one-slope-family GPCM analysis | MML separate slope/step owners, scoped inference/comparison, profiles, fitted-object and portable MML/JML scoring are implemented. One-family GPCM EM still falls back to direct. | Preserve estimator, actual engine, calibration scale, prior and uncertainty target throughout summary, plots, reports and replay. Retain adverse coverage findings. Decide any engine expansion on its own evidence; internal joint-slope EM does not complete public single-family EM. |
| Fit and interpret two fixed slope families | Scoped public MML--EM, owner summaries, conditional fitted curves, plots and saved reports are available provisionally. Experimental component-slope intervals now connect full marginal information and local numerical checks to confint(), plots and saved reports; statistical qualification and remaining consumers are unfinished. | Complete joint-slope G2, its output-specific G3 qualification and G4 delivery. State the admitted facet, population, anchor and prediction scope. A valid point fit, a confidence interval, model ranking, portable scoring and individual feedback require separate decisions; one cannot inherit the others' support. |
| Use corrected JML with matching uncertainty | Generalized internal equations, explicit-order root solving and full-Jacobian Person covariance pass non-prototype engineering checks. Point/covariance outcomes and attempted starts are separate; internal parameter tables reuse existing builders. Limited repeated-sample evidence remains separate. Explicit experimental shared-owner fitting, summaries, point/distribution plots, reports and saved exports are now connected. No automatic order selection exists. | J2 now includes conditional new-Person EAP and portable format 5, with fresh adjusted-equation checks and retained correction identity. Qualify the retained inferential scope separately. Conditional observed-row probabilities and descriptive residuals are connected; calibrated fit tests are not implied. Explicit-order support and automatic selection are separate deliverables; J3 requires evaluation of the selected procedure. Failure to qualify an interval does not erase a valid point estimate, but an exploratory SE is not a substitute for promised formal inference. Any narrower release scope must be decided explicitly. |
| Choose an assessment plan with multivariate G/D studies | Crossed/selected nested point estimation, incomplete-source MINQUE(0), composites, 2D projections and scoped paired plan intervals are implemented. | Retain a complete data-to-plan-to-plot/report route with score units, cost/count assumptions, covariance admissibility and metric-specific availability. Distinguish sparse source data from supported complete future plans. Reuse existing evidence; general structures, unequal future rosters and a joint latent GMFRM/G-theory estimator are not implied. |
| Deliver useful rater feedback | Fixed-rater sheets, diagnostics, figures and reports exist; individual sheets accept additive native RSM/PCM, not GPCM or the extensions. | Preserve exposure, reference, uncertainty, category use, unexpected ratings and recipient privacy. Finish supported model-aware reporting and decide the scope of any sheet extension explicitly. A numerical discrimination estimate alone does not support a competence judgment or training recommendation. |
| Investigate local dependence and alternative rating models | Separate shared-rater and Person-local testlet RSMs, their scoring and descriptive comparisons are implemented with limited uncertainty. | Preserve sharing units and conditional/new-unit targets, compare ordinary MFRM on matched data/model assumptions, and verify applicable displays. No silent transfer of ordinary fit thresholds, variance tests or uncertainty. Combined effects, random slopes and multidimensional ability remain later structures. |
| Use external features and incomplete assigned scores | Hierarchical/PAM and numeric PCA/k-means workflows, setting/imputation comparisons and assigned-score completion/pooling routes are implemented. | Preserve facet IDs, feature coding/scaling, assignment rosters, observed scores and pooling targets through saved results. Clusters remain descriptive; unassigned ratings are not imputed. Existing support does not imply extended-model MI or pooled Person scores. |
| Select an API, understand its output and reproduce it | Existing guides, output objects, plot conversions and persistence provide the foundation; coverage varies by model and output. | One recommended route per task; explicit defaults and unavailable operations; accessible figures with exact data; compatible saved results and matching help/NEWS. Author review is available evidence, not a completed novice usability study. |

The user's order remains: **finish implemented workflows → qualify statistical
support → complete agreed model extensions → integrate as 0.2.4**. These are
priority rules, not a requirement to finish every research idea in a phase.
Joint-slope and corrected-JML contracts must be specified while consolidating
their shared consumers; confirmatory evidence follows a fixed procedure.
Maintain the three release pillars together rather than treating the last
numerical investigation as the entire release.

### Integration checkpoints

The D labels are persistent checkpoint identifiers, not a command to postpone
help or output design until after method development. D1 and D2 constrain each
other; D3 waits for their required outcomes and explicit scope decisions.

| Milestone | Present state | Work and exit condition |
| --- | --- | --- |
| D0 — Identify source and evidence | Candidate, committed development, working-tree changes and research records are distinguishable. | Associate evidence with source, model, estimator, target and input scope. Record an invalidation reason when code changes; do not inherit a previous archive's checks. |
| D1 — Settle statistical admission decisions | Single-family approximate outputs have stated limits. Joint-slope qualification and corrected-JML scope remain open. | Decide separately whether point estimates, uncertainty, diagnostics and comparisons are supported. Freeze each selected procedure before confirmation; retain unavailable results and adverse findings. An inconclusive study is neither success nor an automatic instruction to expand it. |
| D2 — Consolidate the delivered user workflow | Common probability/variance and fixed-value uncertainty repairs, scoring/replay and residual-plot fixes have focused evidence. Joint-slope curves, component intervals, posterior response diagnostics and saved outputs are partially connected; corrected-JML point/response/EAP workflows are connected under their separate scope. Remaining consumers and statistical admission are open. | Complete the scope table above through existing classes. Check named owners, scale/estimator identity, target-matched derivatives, failure states and actual plotted values from fit through report/reopen. Keep established G/D, features/MI and feedback workflows on the regression path. |
| D3 — Freeze the combined scope and source | Open; the retained archive predates subsequent changes. | Close required D1/D2 outcomes or record an explicit agreed scope change. Reconcile DESCRIPTION, capability tables, help, examples, NEWS and README. Freeze one manifest and archive; its version must reflect the integrated 0.2.4 decision, without retagging rc.6. |
| D4 — Check and integrate that source | Earlier snapshots passed their own checks; the latest combined source lacks matching release evidence. | Run affected integration and package checks for the frozen source, fix failures, then verify main integration, five-environment CI and installed/site examples for the corresponding commit/archive. Check CRAN-facing URLs, reverse dependencies and Windows against that candidate. Do not routinely rerun unchanged statistical experiments or the whole suite after small edits. |
| D5 — Release and maintain | Open; local completion, main integration, GitHub release, CRAN submission and acceptance are different states. | Publish matching source/documentation/assets under the applicable authorization. Record the actual state of each channel; acceptance is external. Maintain regression witnesses, saved-object migration and a way to identify affected versions when estimates or interpretation change. |

The two-owner GMFRM work is part of the current G2/G3 completion program for
the working 0.2.4 scope, not a public capability admitted by the numerical
prototype alone. The pillar/consistency section above sets the completion
order; the following admission list records public-route readiness, not a
reason to abandon the unfinished two-owner contract.

Current admission list: retain the previously integrated feedback, plotting,
separate-owner MML and diagnostic changes; add the implemented conditional
scoring/prior corrections, portable GPCM MML, scoped portable RSM/PCM and
shared-owner GPCM JML, and explicit experimental one-slope MML profiles.
An explicit experimental corrected-JML point workflow, response diagnostics and conditional new-Person/portable EAP are now connected locally.
Formal JML structural intervals, automatic correction-order selection, portable ML/WLE,
separate-owner JML and broader latent structures remain open work, not delivered
features. Existing agreed feature families (features/MI, G/D studies and the
two RSM extensions) remain in the integration scope under their stated limits.

D2/D3 were complete for an earlier local checkpoint, not the current scope.
Do not start another simulation merely because the preceding benchmark finished.
**Local completion** requires every agreed release outcome to be implemented
and checked, or its change explicitly decided; unresolved required features
cannot be relabelled limitations to close the cycle. Source, help and saved
outputs must agree, and the identified archive must pass applicable local
checks. **Publication completion** additionally requires the corresponding
main/CI/site/release evidence. CRAN submission and acceptance are recorded
separately. Neither endpoint means the entire long-term roadmap is complete.

At the retained September 27 checkpoint, the portable-calibration public-API check passed, including its
capability, saved-output and documentation contracts. The previously skipped
check-installed case now passes from a separate installed library, alongside
RSM/PCM JML, GPCM MML/JML fresh-process replay and saved profile-output checks.
A GPCM test was repaired to verify the child process loads the installed
package rather than development source. A `--no-build-vignettes` archive also
passes file-selection/source comparison; it is not a submission archive.
See the [integration record](inst/validation/claim-reconciliation-0.2.4.md#2026-09-27-installed-replay-and-development-source-packaging).
README, capability help, portable/GPCM tutorials and NEWS distinguish scoped
JML EAP from unimplemented formal JML inference. The subsequent local gate
now also passes: the normal test selection includes the five new public-route
test files, and a source-matched illustrated archive contains 15 tutorials and
87 images with alternative text. Its documentation/PDF-manual complement passes
without repeating the source-identical tests/examples. See the
[local completion record](inst/validation/claim-reconciliation-0.2.4.md#2026-09-27-complete-the-scoped-local-development-integration).
The illustrated archive SHA256 is
`402b95c90184d3e1cbc7a054fee537063aab51c0737f817cf2dacaf09250e5a5`.
These local checks do not qualify later source changes or close hosted CI,
publication, CRAN submission or broader statistical qualification.

### Next work and evidence needed to move on

1. **Qualify the joint-slope result contract.** Public dispatch and a minimal
   fit-to-curve-to-saved-report route are connected. The next decision is the
   evidence required to qualify inference for this fixed-population,
   no-anchor scope: identification beyond local rank, slope-factor separation,
   boundaries and sampling performance. Experimental component-slope intervals
   now retain local rank, stationarity and q-versus-2q-1 integration checks;
   their availability does not close statistical qualification. Retain the distinction between
   numerical convergence and inferential readiness. Use the existing algorithm
   checks; do not repeat broad simulations before fixing the target and rules.
   The next statistical check must report attempted fits, interval availability,
   conditional coverage and returned-and-covered proportions separately for
   prespecified component slopes. Start with common-Person versus rotating-panel
   overlap and weak slope separation. If normal ability SD is varied, transform
   truth to the fixed-N(0,1) model before measuring bias/coverage: with first-family
   geometric mean one, second-family slopes multiply by SD, locations/steps
   divide by SD, and the ability mean shifts the free second-family locations.
   This normal-scale change alone is not population misspecification; shape or
   assignment-dependent distribution changes pose a different question.
   The [first matched sparse-allocation study](inst/validation/gmfrm-sparse-intervals-20260928.md)
   now fixes these targets for common-Person and rotating-pair designs at SD
   1/.5 (100 repetitions each). Its original 1e-4 local optimization cutoff
   unnecessarily excluded fits with very small corrections in SE units. The
   revised rule retains a warning above 1e-4 and refuses above 0.01, without
   changing the estimates or other numerical checks. Reanalysis of saved fits
   must remain distinct from independent confirmation. A remaining
   numerical issue was integration sensitivity for Persons with many ratings.
   Replaying all 100 common-Person SD=1 datasets at 61 points, with unchanged
   EM controls, now returns intervals in 100/100 cases and passes each saved
   61-versus-121 check. Prespecified t1/r1 coverage is 93/100 and 98/100;
   this resolves the observed numerical failure, not sampling qualification.
   The existing quadrature-sensitivity API now retains two-family fixed-grid
   comparisons and their interval checks. Do not confuse the earlier failure
   with an unidentified assignment graph or loosen unrelated requirements.
   Next address residual bias/SE discrepancies (also present at SD=1 after
   quadrature repair: t3 coverage 90/100) and the near-zero-slope
   failure with a fixed inferential procedure and independent confirmation;
   do not expand every simulation dimension before making that decision.
   An explicit single-component profile route now reuses the existing constrained
   likelihood search for both slope families, preserving owner/level identity,
   all nuisance coordinates and fixed-N(0,1) scale constraints. A retained
   240-Person example checks both a dependent first-family component and a
   free second-family component against literal marginal likelihood endpoints.
   It exposed a missed higher-grid curvature-refinement trigger (repaired
   without loosening tolerances) and a distinct off-estimate quadrature failure.
   These numerical checks do not establish bias correction or better coverage.
   The model/Wald versus explicit-profile rule and evaluation targets were
   then frozen before independent sampling; unresolved endpoints and
   near-zero-slope source qualification remain separate.
   The [independent feasibility protocol](inst/validation/gmfrm-profile-feasibility-20260929.md)
   fixes 20 new datasets per design/SD condition, Task t3 and Rater r3, 121-node
   neutral-start fits and unchanged profile controls. It assesses availability,
   failure stages and cost before a larger coverage study; it cannot close G3
   or select a default interval method. Cell aggregation reuses the EM marginal
   objective to reduce profile-search cost, with original-evaluator, endpoint
   and failure-state checks. This computational change is not statistical
   qualification or point-estimate bias correction.
   All 80 feasibility datasets are now complete. At SD=.5, 14 sources missed
   the stricter 1e-7 EM score tolerance after 500 iterations; 25 of the 26
   converged sources had unresolved Task t3 profiles with substantial
   disagreement between constrained starts, including seven with individually
   passing raw-gradient checks. All 26 corresponding Rater r3 profiles were
   available. At SD=1, three component profiles failed upper-side integration
   checks. These findings preclude treating the method as a routine Wald
   replacement or moving directly to a larger coverage run. Numerical repairs
   now refine the fixed-count EM M step, scale two-family constrained BFGS by
   Person and contract failed outward brackets without changing acceptance
   requirements. Matched replay of all 40 low-SD datasets gives 40 converged
   sources and Task t3 intervals in 19/20 common-Person and 20/20 rotating-pair
   cases, versus 1/20 and 0/20 originally. A remaining weak-slope case did not
   return its lower endpoint even after quadrupling the profile iteration
   limit. The two-family search now retries failed optimization in fixed
   curvature coordinates; this returns the complete interval at the original
   400-iteration stage limit. The two affected retained profiles were replayed;
   this is not a rerun of all 45 calls under the new procedure.
   Two of the three original SD=1 integration failures returned complete
   profiles after contraction. The third now returns both endpoints after an
   explicit public 121-to-181-node refit, checked at 361 nodes. No automatic
   grid change, relaxed tolerance or reinterpretation of the original failures
   was introduced. The observed numerical problems now have checked remedies;
   general weak/boundary behavior and statistical accuracy remain open.
   Next freeze the revised inferential procedure, its integration/failure
   handling and an independent bias/SE/coverage comparison before enlarging
   sampling. Do not reuse these development cases as that confirmation. The detailed
   [results and failure attribution](inst/validation/gmfrm-sparse-intervals-20260928.md#2026-09-29-profile-computation-and-independent-feasibility)
   preserve full denominators and Monte Carlo uncertainty. The
   [matched repair record](inst/validation/gmfrm-sparse-intervals-20260928.md#2026-09-30-numerical-repairs-on-retained-feasibility-data)
   separates computational recovery from qualification. G3 remains open.
2. **Adapt outputs by their target.** Conditional curves now use the correct
   slope product without intervals. Component-slope intervals now have an
   explicit experimental contract and saved numerical checks. Next resolve
   the statistical scope before extending location/curve intervals. A scoped
   same-data posterior residual target is now available through
   mfrm_response_diagnostics(), with fixed calibration, row-level integration
   checks and saved plots/reports/exports. Formal fit tests, reference cutoffs,
   Q3/PCA and dimensionality claims are not supplied by this route.
   Wright/Pathway maps, model ranking, new-person/portable scoring and individual
   feedback sheets remain explicitly unavailable. Each requires its own
   interpretation and tests; none follows automatically from a shared fit class.
3. **Advance corrected JML against its own question.** The internal equation
   and matching full-Jacobian covariance now accept generalized observed inputs;
   independent full-response calculations and a three-judge/four-category
   sparse sample pass. Explicit-order runtime solving now retains attempts,
   separates point/covariance outcomes and reuses existing parameter-table
   builders. The explicit public fit/output workflow and conditional observed-row
   probabilities/residuals are now connected without inheriting ordinary JML
   likelihood/SE assumptions. Conditional later-Person/portable EAP now uses
   its own adjusted-equation admission checks and preserves correction identity.
   Do not broaden inference merely because output integration works.
   Reuse the 200-dataset one-step and 400-dataset order
   comparisons to decide residual-bias treatment and the supported inferential
   scope; the new engineering sample does not establish coverage or choose an
   order. An automatic policy remains a separately evaluated procedure.
   Do not use this lane to delay unrelated output repairs or quietly drop it
   from the agreed scope.
4. **Review all three pillars before freezing.** Reuse the educational
   assessment walkthrough to check measurement, individual feedback and G/D
   plan comparison as complementary analyses. Verify their row selections,
   scales, weights and intended populations; shared data does not make their
   estimands identical. Include existing features/MI as optional branches.
   Cross-domain role checks must include a substantively different design,
   not just replacing "rater" with "judge" in the same example.

For each new verification, state the decision it can change, the existing
evidence it reuses and the affected claim. The following allocation keeps
validation sufficient without turning every uncertainty into another grid:

| Work changed or claim proposed | Necessary check | What does not follow |
| --- | --- | --- |
| Parameter, probability or covariance calculation | Independent small-case equations/derivatives, limiting cases and affected shared consumers; R/compiled agreement where both paths change. | Agreement between two callers of one kernel is not independent estimator validation. |
| New inferential claim or estimator policy | Prespecified matched sampling contrasts, declared target/sampling unit, availability and coverage with Monte Carlo uncertainty; numerical failures retained. Use the sparse/anchor/population contrasts above only where the model supports them. | No universal coverage, no dropping failures at a time limit, and no automatic replication expansion after an inconvenient outcome. |
| Summary, plot, help or saved-result change | Targeted value/label/availability and round-trip checks, rendered examples and affected compatibility paths. | No full statistical rerun solely for presentation changes. A returned plot class is not visual or numerical correctness. |
| Computational scaling | Profile a stated workload across Person count, facet levels and ratings per Person; measure OS memory/time and numerical agreement. | A measured configuration is not a general capacity ceiling. A resource guard is not a statistical failure. |
| Candidate source integration | One source-identified package/integration check and matching platform, installation, website and submission checks as applicable. | Old checks and old Windows uploads do not validate a changed archive. |

The current five-environment workflow covers macOS release, Windows release
and Linux release/devel/oldrel-1. Its push/PR selection is lightweight; five
green cells do not mean every test or research runner executed. Before the
freeze, reconcile the selected tests with the admitted APIs and record which
full-suite or slow checks are required, which earlier evidence is reused and
why. Keep a separate installed-package/fresh-process check for saved artifacts.

### Usability and maintenance acceptance

A beginner-oriented walkthrough must let a reader identify the model and
estimator, explain what an interval conditions on, recognize an unavailable
comparison, and reproduce the table behind a plot. Assess those tasks rather
than asking whether the manual seems clear. Author walkthroughs can close
documentation defects; claims about novice comprehension require actual
reader evidence. Do not invent it or postpone necessary repairs while waiting.

Keep one recommended entry for each distinct operation and reuse existing
result classes. Preserve old calls and saved artifacts where their meaning
remains valid; otherwise explain the migration and affected results. Do not
mark a specialist helper superseded merely because another function has a
broader name. Core installation and the main beginner walkthrough must work
without sirt, TAM, ConQuest, network access or private validation data.
Optional external-comparison examples declare their dependencies and remain
separate reproducible checks of explicitly matched targets.

Plots must retain unavailable states, readable labels, non-color distinctions,
exact underlying values and working title/annotation controls. Automatic
refitting or expensive interval calculations must not be hidden inside
`print()`, a report or a saved-plot replay. Retain regression cases for known
calculation/interpretation defects and document changes to numerical defaults,
covariance meaning and artifact schemas. These are ongoing maintenance
obligations, not a demand for identical features in every model class.

### Portfolio decisions and long-term maintenance

The 2026-09-27 beginner-workflow review makes corrected JML integration an
explicit product target, rather than leaving users to run research scripts or
choose correction orders unaided. Its intended entry is `fit_mfrm()`, followed
by the existing summary, diagnostics, plots, reports and scoring routes. This
is not an implemented argument or a change to today's MML default. A supported
approximate estimator does not require a universal coverage theorem, but it
does require a declared model/design scope, matching covariance, numerical
checks, retained limitations and evidence for the claims actually presented.

Beginner usability is not an estimator property: JML, MML and Bayesian fitting
answer questions under different assumptions. Specialists also use frequentist
methods, and a Bayesian interface can be usable by beginners. Reduce unnecessary
syntax and technical choices without hiding assumptions or changing the user's
estimation target. No claim of user-tested ease is supported yet.

The intended distinctive strength is the assessment workflow: inspect the
assignment, estimate an appropriate model, distinguish severity from rating
quality, explain uncertainty and unexpected ratings, deliver individual
feedback, and reuse a calibration with its assumptions retained. Existing
RSM/PCM individual-rater sheets are a concrete delivery feature; GPCM and
extended-model sheets are not currently supported. G/D studies complement this
route for future design decisions and must not be presented as the same model.
External TAM/ConQuest checks remain mathematical references for matching targets,
not a feature-parity objective or evidence of unique numerical superiority.

The previous sequence made progress on JML methodology but drifted beyond the
GPCM work package's explicit order-5 integration gate. Its numerical evidence
is retained. The correction is to restore the user's order: finish implemented
workflows, qualify the claims actually retained, extend models for specified
needs, and integrate. It is not to discard research or call open inference done.

| Perspective | Priority and success condition | Boundary or reopening trigger |
| --- | --- | --- |
| Rater feedback and practical adoption | Keep reviewable feedback the primary user outcome: exposure, severity with its available uncertainty, category use and unexpected ratings, with a declared reference and recipient-appropriate language. Preserve the implemented fixed-rater HTML sheets and their privacy checks. | Severity, misfit and feature clusters are not rater quality or proof of a training need. Actual graduate-student/rater reading evidence is still absent; author review and accessible markup alone cannot close that gap. Do not invent participant findings. |
| Scoring across cohorts | Finish the existing calibration lifecycle rather than add a parallel API. Clearly retain source model, scale, scoring prior, eligibility and conditional uncertainty. | Fixed-parameter TAM/ConQuest agreement checks matching computations, not free-estimator equivalence, calibration-aware intervals or validity in a changed population. Cohort transport and prior sensitivity answer different questions. |
| Statistical support | Rank a new study by the decision it can change: false flags, a declared contrast, or a planning choice. State target, failure accounting, practical accuracy and Monte Carlo precision before computation. | Reproduced wrong results or misleading labels require repair. Known undercoverage cannot be cured by finite output, more datasets or a generic warning. An approximate output needs a defensible scoped use, explicit limits and consistent defaults. Universal coverage/diagnostic guarantees are not feasible acceptance criteria. |
| Assessment design | Use existing G/D scenarios to compare tasks, raters and criteria with stated workload units; distinguish complete future plans from incomplete source ratings. | General nesting/fixed facets, unequal future allocation and new plan-contrast intervals remain extensions. A testlet variance does not identify halo, enforce equal task weights or by itself supply G-theory reliability. |
| JML research | The one-step correction has a prespecified 200-dataset comparison in one complete design. Later research implements iterated corrections, actual sparse/unequal rosters, matching fixed/random-roster sandwich calculations and deterministic approximation bounds; engineering checks pass after a retained solver follow-up. | Higher order does not improve bias monotonically; residual displacement remains. Select or restrict correction order and solver policy without generating truth, and resolve scalable expectations before broader qualification. No general coverage claim or public formal JML interval follows. Research progress does not replace source integration. |
| Scope and maintenance | Before adding any model, name the assessment decision and compare the supported simpler model or external route. Budget fit/scoring, uncertainty, diagnostics, meaningful maps, save/replay, help and failure handling together. | Add one justified structure at a time. Wright/Pathway displays, Infit, bias tests and IC/LRT support are model-specific decisions, not automatically inherited methods. Multidimensional MFRM remains deferred. |
| Compatibility and resources | Preserve old saved results and portable formats 1–4 with representative fixtures, explicit schema/algorithm identity and refusal of incompatible inputs. Measure realistic time and memory when an affected path or target workload warrants it. | Default changes and result corrections need migration guidance. Number of Persons alone is not a capacity limit: facet levels, pattern length, sparsity and parameter count matter separately. No mandatory full-suite or stress-grid repetition for documentation edits. |

Manage work by these gates, not by API counts or accumulating studies. During
integration, new research joins the critical path only when it resolves a
defect in an admitted result or is an explicit scope decision. After integration,
choose between adoption/feedback, planning and inference from a named unresolved
user decision and available evidence. Do not automatically promote the last
experiment's follow-up above all other work.

The requested follow-up on JML residual bias, sparse allocation and approximation
is recorded in the [design-aware method review](inst/validation/jml-inference-review-20260927.md#design-aware-iterations-sparse-rosters-and-numerical-approximation).
Fourth-order adjustment reduces population-root displacement in the examined
complete and sparse cases, but the sparse second-order result worsens it and
neither fourth-order result is exactly unbiased. Four-versus-six-rating sample
calculations now respect actual assignments and fixed roster counts; a smaller
solver step resolves the retained opposing-start failures. Deterministic
pruning has checked score/Jacobian bounds, not a demonstrated general speedup.
This closes a scoped research engineering increment, not the remaining method
decisions or public JML inference. The admitted public archive is unchanged.

The subsequent [order-sensitivity review](inst/validation/jml-inference-review-20260927.md#order-sensitivity-without-generating-truth)
reuses the same samples to compare corrections with paired Person influence
covariance. It verifies the derivative of the difference by targeted refits.
Observed stability cannot identify a shared residual bias or bound the
unexamined correction tail, so no automatic order is selected. Keep explicit
research orders and all-coordinate sensitivity results; any future adaptive
rule requires evaluation of its selection and uncertainty together. A small
change relative to a marginal SE is not a bias/coverage acceptance criterion.

The [exact owner-total calculation](inst/validation/jml-inference-review-20260927.md#exact-expectations-on-owner-totals)
now bypasses full response enumeration for the tested two-owner structure.
It agrees with the previous scores/Jacobians/covariances and handles a declared
400-Person, 32-rating computational example using 1,089 total states instead of
4,100,625 response count patterns. Actual Person contributions remain intact;
no simulation noise is added to expectations. This is computational engineering
evidence, not a validated statistical exposure range. Retain this exact route
for the scoped method work; a fixed correction/solver procedure and independent
statistical qualification remain the active decisions. Additional slope owners
or dependent responses require their own computational and method review.

The [preliminary publication review](inst/validation/jml-publication-positioning-20260927.md)
identifies substantial prior art: Dhaene–Jochmans score adjustments,
Dhaene–Weidner (2023) outcome aggregation/operator representations, and
Lord–Wingersky-type IRT recursions. Computational improvement in this repository
does not establish academic novelty. A possible contribution is the model-specific
exact reduction retaining actual response contributions and matching covariance;
its distinction from existing results matters for a possible paper, but does
not gate API repairs or necessary statistical qualification. Neither an original general estimator nor
unbiased/formal JML inference is claimed.

The three newly supplied Zotero PDFs have now been read page by page in text,
with the key equations/proofs and selected tables/figures checked visually.
The [operator decomposition](inst/validation/jml-total-expectation-20260927.md#operator-decomposition-and-prior-art)
maps the implementation to prior methods: retain the within-total response
component and iterate only the conditional mean component. This is an exact
reformulation of an existing correction, not evidence of a new estimator.
Dhaene–Weidner equation (22) centers the sandwich at a population moment root;
its posterior-operator identification results and conjectured bias rates do not
qualify our MLE plug-in method. Before further sampling studies, specify the
API decision and fixed inference policy, including residual bias; novelty is
not the admission criterion. IRT score-combination applications motivate future reporting, but their
fixed-calibration posterior uncertainties are not JML structural-parameter
intervals and do not close this research gate.

Direct review of Bonhomme's October 2011 author manuscript of *Functional
Differencing* now separates valid moments from identification and exact
projection from finite plug-in correction. For Criterion ownership, conditioning
on owner totals also removes the Criterion location contrast; the conditional
component alone cannot identify it. More correction is therefore not an
automatic route to unbiased, identified inference. The existing research gate
now explicitly requires a coordinate-level account of retained information,
alongside the fixed correction/solver policy and treatment of residual bias,
before broader sampling qualification. The count-moment recurrence is also
written as ordinary coefficient differentiation, not claimed as a new principle.
The subsequently supplied Andersen (1972) and Liou (1994) PDFs have now been
read in full and their recurrences/derivatives checked visually. They establish
prior art for conditional moments as coefficient derivatives, including
polytomous recursions and information calculations. Our finite JML correction,
conditioning statistic and covariance still differ from their CML calculations;
no new derivative principle is claimed. Retain positive forward convolution:
Liou's subtractive alternatives have parameter-dependent accuracy costs, and
their historical timings do not justify an implementation change. The missing
full-text comparison is closed; coordinate-level identification, residual bias
and a fixed inference policy remain open. No public estimator, interval,
help/NEWS claim or release criterion has been completed by this literature review.

The detailed work packages below preserve earlier decisions. New status updates
belong in the active table and the relevant evidence record; avoid another
competing "next work" list. Revisit the portfolio at a source freeze, a rejected
method or a concrete user finding. A release-version decision must reconcile
the retained rc.6 candidate, this expanded development source and migration
costs; no tag is replaced and no version number is selected by this audit.

### D1: separate-owner evaluation record and retained limits

The question is whether criterion discrimination and rater-specific category
use can be estimated and reported usefully when raters share performances but
the assignment is incomplete. Keep one positive slope family, centered step
contrasts, the existing complete-predictor slope action and the default estimated
normal population. JML, two simultaneous slope families and portable calibration
are outside this evaluation.

1. **Fix targets and the data-generating model first.** Specify relative slopes,
   step contrasts and prespecified rating-context probabilities separately.
   Use the independent scalar generator already checked against the likelihood.
   Declare the category structure, links between raters, true parameters and
   intended interpretation before generating results. Do not equate slope
   discrimination with rater quality or category use with a causal training effect.
2. **Start with a small, interpretable pilot.** Use complete versus connected
   incomplete assignments at two sample sizes, keeping the generating model
   otherwise fixed. At most 40 datasets per cell are a diagnostic pilot, not a
   coverage qualification. Include deterministic confounded-design rejection and
   both owner-order kernel checks from existing tests rather than simulating
   those failures repeatedly. Measure fitting, inference and storage costs before
   choosing a confirmation budget; no nested bootstrap grid starts automatically.
3. **Keep every planned dataset in the accounting.** Report convergence,
   identification, quadrature/information eligibility, bias/RMSE, interval width,
   unconditional availability and coverage with Monte Carlo uncertainty. Show
   conditional-on-availability coverage separately. Calibration-probability and
   relative-slope intervals are distinct targets. A matched PCM comparison must
   preserve step ownership, population and constraints; null-test calibration
   requires a separately declared unit-slope condition.
4. **Make a decision before adding conditions.** Repair a reproduced numerical
   defect, narrow the usable scope, or register a confirmation study with sample
   size derived from the desired Monte Carlo precision and a measured budget.
   Preserve adverse results. Do not claim nominal coverage from the pilot, or
   broaden the grid merely to explain earlier runs. Existing small-sample GPCM
   undercoverage remains relevant caution, not evidence for this new structure.

The first four-cell pilot is complete. In the correctly specified model, all
planned fits and target intervals were available. Removing one of three raters
per Person widened the slope intervals by about 45–53%; no estimator defect was
reproduced. The small repeated-sampling check does not establish 95% coverage:
even perfect coverage in a cell of 20 datasets has a 95% Monte Carlo lower bound
near 83%. See the [pilot result and cost review](inst/validation/gpcm-separated-owner-pilot-record-20260926.md).
Do not repeat that pilot. A confirmation study needs an explicit target and
precision decision; D2 can proceed while stronger interval claims remain open.

General simulation/design APIs and dedicated weighting reviews should be
extended only after the role semantics, replay and intended decision are clear.
Until then they explicitly refuse separate owners; same-design parametric
resampling through `bootstrap_mfrm_gpcm()` is already connected.

### D2: compatibility and delivery decisions

Use `mfrm_results()` for retaining analysis outputs, `plot()`/`as_ggplot()` for
views of the appropriate result, `mfrm_report()` for reports and
`export_mfrm_results()` for an analyst bundle. These are coordinated operations,
not a mandatory linear pipeline or replacements for every specialist function.
Keep the individual recipient sheet distinct from an analyst archive.

Inventory the relevant arguments by meaning before renaming them: plot geometry,
metric and display view are not all interchangeable `type` arguments. Add aliases
only with tests for old/new equivalence, conflicts, omitted arguments, NULL and
saved replay. Mark a function superseded only when its replacement covers its
actual task. Extend the plot conversion inventory when a user workflow exposes
a gap; exhaustive conversion is not a prerequisite to a useful release.

The fixed-rater walkthrough now connects saved results to individual sheets,
interval figures, analyst reports and archive/reopen operations. The reporting
guide uses the same entry points and keeps specialist manuscript tools visible.
The executable walkthrough and existing feedback tests pass locally. This is
an author-checked workflow, not evidence of novice comprehension. The selected
argument/default review is complete for the integration scope below. A full
package-wide rename and actual reader evaluation remain separate follow-up work.

The primary fitted-model plot route now accepts named `level` alongside the
existing `ci_level` spelling, rejecting simultaneous use. Saved fixed-facet
intervals retain their computed level; saved core plot conversion rejects
unsupported settings rather than silently ignoring them. Source help explains
why ordinary fitted plots use `show_title = FALSE`, while newer interval plots
use `title = NULL`. Keep these compatibility distinctions visible instead of
changing existing scripts silently. Selected-route regression checks cover
actual interval widths, old/new spelling equivalence, plot-data/result/ggplot
forwarding and saved rendering. This does not rename every specialist helper.

### D3: fixed integration scope and retained limits

This table records the earlier `08a5ee9b` integration checkpoint. The active
D3 admission list above also includes subsequent scoring/profile work.
The checkpoint started from rc.6 functionality and added the following work. This is a source-scope decision, not a claim that
all research extensions are complete or a decision to publish a new version.

| Included workflow | Retained behavior and limit | Basis for integration |
| --- | --- | --- |
| Individual fixed-rater feedback | Native additive RSM/PCM sheets, plain/researcher guidance, HTML and tables; saved diagnostics and eligible individual intervals. No automatic rater-quality decision, PDF API or extended-model recipient sheet. | Saved-value and missing-input tests; identifier omission; recipient HTML persistence; analyst RDS/export replay; executed fixed-rater walkthrough. |
| Plot discovery and saved conversion | Selected purpose guide, accessible gallery, PCA, hierarchical trees, silhouettes, feature profiles, imputation co-membership and pooled fixed-facet intervals. The guide identifies unsupported conversions and alternatives. | Route/converter checks and existing saved-result evidence. Screening-performance, univariate D-study and multivariate plan-difference ggplot conversion remain unavailable; native plots and data extraction remain usable. |
| Plot settings and compatibility | Common session presets; eight title aliases; named `level` on ordinary fitted-model plots; explicit rejection of invalid saved-plot overrides. Existing argument positions/defaults remain intact. | Old/new equivalence, interval-width, omission/NULL/conflict, rendering and replay checks. Geometry, metric and display-view arguments keep their different meanings; specialist helpers are not universally renamed or deprecated. |
| Separate-owner GPCM MML | One positive slope family, possibly a different step owner, existing scale identification and full-predictor slope action; connected fitting, scoring, approximate inference, matched PCM comparison, same-design resampling and reports. | Independent likelihood/derivative checks, owner identity and confounding checks, actual export/reopen checks and the fixed diagnostic pilot. No general coverage or sparse-design guarantee. JML separate owners, two slope families, portable GPCM beyond the qualified scope below, separate-owner weighting review and general design simulation remain unsupported. |
| Random-rater uncertainty reporting | Saved refit numerical/variance-boundary diagnostics and clearer explanation of unresolved interval endpoints. | Existing refit/report/replay tests and retained statistical evidence. No changed interval formula, general coverage qualification or automatic replacement of infinite limits. |
| Distribution and documentation corrections | CI registry/metadata fixes, honest unavailable-PCA reporting in development checks, aligned help/NEWS/tutorial statements. | Reproduced failures and focused repairs; the earlier five-environment run and a new combined-source check under D4. |

The selected output routes keep their own result objects: fixed-rater and GPCM
reports use `mfrm_results()`, while feature, imputation and G/D-study results
use their documented dedicated objects. `mfrmr_output_guide()` is the route
map; wrapping every analysis in one object or converting every figure is not
an integration requirement. The known conversion gaps are explicit exclusions,
not completed implementations. Actual novice comprehension and the latest
tutorial's browser appearance have not been verified; do not advertise either
as established accessibility/usability evidence.

At that checkpoint, main integration and a local archive were complete for
`08a5ee9b`, and its five environments passed. This does not close current D4.
Publication review must verify actual website deployment,
including source links and development-version labels. Do not transfer results from an
older commit merely because the version matches.
Reuse the retained numerical studies and saved-workflow evidence. Repeat a
targeted check only for a changed path or failure, and run broader checks once
for the combined package rather than per documentation correction. No final
release tag or CRAN submission is recorded by this development integration.

### Next GPCM work package: inference and portable scoring

**Development implementation with qualification and release decisions still open.** The practical question is
whether an assessment team can calibrate a rubric, explain discrimination and
its uncertainty, and score a later cohort reproducibly without refitting the
calibration. Keep educational performance assessment as the worked example;
use generic Person, task, criterion and rater roles in the API. Retain existing
feedback, feature/MI and G/D-study workflows as maintenance commitments rather
than restarting their development. Multidimensional models and additional
slope families are not prerequisites for this work package.

| Order | Work and initial scope | Completion or decision condition |
| --- | --- | --- |
| 0. Resolve population and boundary prerequisites | User priority on September 26: settle source-solution stability and the meaning of estimated-population scoring before extending portability. Reuse the current likelihood/information checks and historical variance/slope boundary evidence; see the prerequisite milestone below. | Distinguish actual instability, an unevaluated diagnostic and a model assumption. Establish and test output-specific numerical acceptance and failure rules. A review-only persistence workaround does not complete this milestone. |
| 1. Fix the model, scoring target and external comparison | MML GPCM, one positive slope family, current full-predictor slope action. Define relative versus population-standardized slopes separately. For portable scoring, start with an intercept-only normal population estimated during calibration and frozen thereafter, known facet levels and categories, unit observation weights and no new interaction structure. Use a shared-owner reference first, then a separate-owner reference. | Write the parameter/scale map and an explicit supported-input table. Set comparison quantities and numerical tolerances from independent calculations, integration sensitivity and output precision before accepting results. Do not impose both unit population variance and geometric-mean-one slopes as a mere scale conversion. |
| 2. Decide and implement the needed inference improvement | Reuse the existing slope/curve studies and 80-fit separate-owner pilot. The first profile-likelihood implementation target is one prespecified relative slope in a regular MML solution; preserve the sum-zero log-slope constraint and reoptimize all nuisance parameters, including the population. | Independent likelihood checks, unit-slope reductions and profile endpoint checks must pass. Retain unresolved, unbounded or multimodal results. Compare with the current Wald result under declared conditions and measure cost. A profile is not automatically cheaper, better covered or a remedy for probability-curve undercoverage. Decide to retain it, narrow it or stop; do not keep expanding a failed study. Standardized targets require their own constrained profile, not rescaled endpoints. |
| 3. Implement a portable MML GPCM artifact | Extend the existing extraction, validation, freeze/save/load and scoring lifecycle. Store both owners, slopes, steps, facet/category maps, scale constraints, population parameters, scoring algorithm and numerical settings. Explicitly record anchor/interaction support or refuse unsupported fits. | Scores from the artifact agree with the supported fitted-object route and an independent calculation. A fresh session needs neither the source fit nor training data. Shared- and separate-owner cases pass; if only one is admitted, the public capability table must explicitly restrict the release. Existing RSM/PCM artifacts retain their semantics. JML and latent-regression portability remain outside the initial scope. |
| 4. Verify external agreement and the complete user workflow | Compare matching fixed-calibration probabilities and scores with TAM and local ConQuest. Connect score summaries, review reasons, plots and saved outputs through the existing calibration API. | Finish the comparisons specified below, including disagreements and unsupported comparisons. Execute one calibration-to-next-cohort tutorial, save/load it and check results, English plots, accessible encodings and omitted/flagged cases. Distinguish author review from actual novice-reader evidence. Help, capability tables and NEWS must describe only delivered behavior. |
| 5. Admit a release scope and stop | Select completed inference and/or portability features without extending the frozen rc.6 retrospectively. | Check the admitted combined source once on the normal platform matrix; tie the release archive, help and results to that source. Decide the version before producing a release archive. CRAN checks/submission are separate from main publication. If a method fails its criteria, explicitly defer it; that does not invalidate an independently completed scoring workflow. |

The population/boundary prerequisite has reached the limited conditional-scoring
disposition recorded below. Portable extraction/replay is implemented within
that scope. Order 2's one-relative-slope profile and its output connections are
implemented experimentally. The finite comparison with Wald is complete on
all 100 saved datasets in one declared small-sample cell; see the
[finite comparison protocol](inst/validation/gpcm-profile-comparison-20260927.md).
It is a post-fit diagnostic reanalysis, not current-estimator confirmation.
Only 53 profiles were fully available, versus 98 Wald intervals. Retain the
explicit experimental route, without recommending routine replacement; the
result and stopping decision are recorded below. Order 4's scoped local workflow
and artifact-to-external-score comparison are complete, as recorded below.
The next work is order 5's combined-source and release-version review, not
another automatic simulation expansion.
Neither numerical implementation nor a
few endpoint checks establish interval coverage. Release admission (order 5)
still requires a scope/version decision and checks on the combined source.

#### Population and boundary prerequisite milestone

The initial blanket-review portable-GPCM prototype was removed from package
source and preserved under `validation-results/portable-gpcm-paused-20260926/`.
After P1--P4, development implementation resumed using the accepted conditional
source checks and per-person integration checks described below. The paused
prototype itself is not the accepted implementation. Neither replay agreement
nor the accepted local checks establish population transport or a global maximum.
The [current-code audit](inst/validation/gpcm-population-scoring-audit-20260926.md)
separates conservative implementation rules from demonstrated mathematical
and numerical limits.

| Sequence | Question to resolve | Required result and stopping condition |
| --- | --- | --- |
| P0 — Reconcile existing evidence and output rules | Which failures are observed, and which statuses are assigned without evaluating the fitted case? | Trace population scoring, global readiness, output-specific information checks and boundary-path diagnostics. Reuse saved regular, weak-information and boundary examples. Do not restart the old boundary grids or the 80/800-fit studies. The initial code/evidence audit is complete; its findings are not a statistical qualification. |
| P1 — Establish source-solution stability with an estimated population | Do the same response data support stable population, slope and step estimates, or competing/limiting solutions? | Reuse the existing likelihood, derivatives and nuisance-refit machinery. Profile population variance while reoptimizing slopes, steps, locations and population mean; inspect a prespecified relative-slope profile with population free. Check common-objective values, nuisance stationarity, starts and independent integration at informative points. Preserve unresolved searches and competing solutions. Start from retained representatives; add a case only for a missing failure mechanism. No arbitrarily large finite slope cutoff substitutes for a boundary diagnosis. |
| P2 — Implement output-specific acceptance and failure handling | When may conditional scores be computed, and when are calibration intervals or model comparisons unsupported? | Separate finite fixed-parameter posterior computation from evidence about the estimated calibration. Connect source checks and observed instabilities to explicit supported/review/unavailable results, without labeling every estimated population invalid or accepting every converged fit. A finite-grid ray certificate is not a continuous-integral certificate; absence of a detected path is not proof of a finite global maximum. Exercise regular cases and existing adverse examples before changing defaults. |
| P3 — Assess the scoring consequences of population assumptions | How much do scores and intervals depend on retaining the calibration population for the intended next cohort? | Use the existing fixed-calibration oracle and comparator results for numerical accuracy. Specify a small, decision-relevant prior-sensitivity comparison, keeping recalibration and altered scoring priors distinct and retaining both identities. Numerical agreement alone cannot qualify transport or frequentist coverage. Any additional repeated-sampling study needs a target, practical criterion, Monte Carlo precision and bounded cost before execution. |
| P4 — Admit the resolved scope before resuming portability | Which source states and population assumptions can the software support and explain? | Record the accepted rule, counterexamples, remaining limitations and user-visible defaults. Only then resume the artifact schema/API, tutorial and save/reload checks. Resolve or explicitly exclude unstable cases within the agreed scope; a generic warning or blanket restriction is not the completion criterion. Do not require a theorem about every possible GPCM dataset or promise universal coverage. |

P1 has reached the representative-case decision point through the
[current-source nuisance-profile check](inst/validation/gpcm-joint-profile-20260926.md).
All 60 planned attempts are now executed, including the 19 omitted by the
initial ten-minute checkpoint; the original 41 results are unchanged. There
are 43 original stationarity passes, 16 returned stationarity failures (14
improved by the separate one-step curvature follow-up), one local-posterior
scale error, and six integration-movement failures overlapping the passes.
Both unconstrained starts agree. The targeted repair now handles the
trial-evaluation overflow without a slope cap and prevents stale cache hits.
The failed search and both remaining tail searches meet the native gradient
criterion after repair/preconditioning. Three high-variance conditions meet
that criterion after warm-start refits at order 301 and agree with independent
integration within 1.37e-7 NLL. These are representative local checks, not
universal boundary exclusion or two new starts at the higher order. This
investigation has reached its planned decision point. Its observed numerical
checks and historical adverse cases inform the P2 rules below and the remaining
P4 implementation acceptance. Do not expand the
profile grid merely to accumulate more cases. A time checkpoint is not a
statistical completion condition. The initial
scope remains one normal intercept-only population and one relative-slope
family, with shared and separate owners. Existing normal-population support does not cover informative
assignment, disconnected designs or arbitrary nonnormal cohorts. Those are
different assumptions and claims, not defects that a file-format extension
can repair. Profile likelihood is used to investigate actual competing and
weakly identified solutions; its confidence-interval performance requires
separate evidence and is not presumed superior to Wald intervals.

P2 is now implemented locally for native GPCM MML and intercept-only normal
population scoring: fresh local information and source-integration checks can
admit conditional scores without rewriting global readiness. Per-Person
integration checks separately govern the reported EAP/SD. Actual source
failures remain review-only, and invalid parameters or inconsistent stored
priors cannot be enabled by review. Positive GPCM/RSM/PCM examples, coarse-grid
failures, the existing rank-deficient example, summaries, plausible values and
exports have been checked; see the updated
[acceptance record](inst/validation/gpcm-population-scoring-audit-20260926.md).
Covariate-dependent populations retain explicit review.

P3's declared normal-prior sensitivity comparison is complete; see the
[design, results and scope decision](inst/validation/gpcm-prior-sensitivity-20260926.md).
All 120 retained synthetic persons were scored under five priors with nested
one/three/six-rating subsets (1,800 calculations), with fixed calibration and
independent moment/interval-CDF checks. All numerical criteria passed. Median
personal maximum EAP shifts across alternative priors decreased from 0.5926
to 0.2358 to 0.1360, but the largest shifts were 0.7281, 0.8132 and 0.7974.
The largest six-rating shift involved all-lowest-category patterns and was
1.053 baseline posterior SDs. More ratings therefore cannot serve as a blanket
prior-sensitivity exemption. The patterns are reused calibration data, not an
independent future cohort; transport and coverage are not established.

P4's fitted-object acceptance is now implemented locally:
`predict_mfrm_units()` and `sample_mfrm_plausible_values()` accept
`scoring_prior = list(mean = ..., sd = ...)`, with `NULL` retaining the current
prior and numerical results. No new public entry point is introduced. Original
and scoring prior values remain distinct and unrounded through estimates,
summaries, draws, figure data and exported tables. Source qualification is
unchanged; supplied priors automatically receive per-person numerical checks.
Invalid priors and background-covariate population overrides are refused.
Review-only sources remain review-only. The help compares two priors on the
same response rows using a labelled ggplot; colour is not required to distinguish
the scenarios.

Acceptance checks reuse the saved P3 reference for ordinary/all-lowest-category
patterns at one/three/six ratings, with retained, shifted-mean and wider priors.
They cover unchanged default scores/draws, invalid inputs, source and integration
failures, unchanged calibration, summary/draw/export identities, and missing or
inconsistent prior records. RSM MML and PCM JML scoring routes were also checked;
the JML calculation remains post hoc posterior scoring, not JML calibration
inference. See the [implementation record](inst/validation/gpcm-prior-sensitivity-20260926.md).

The population/boundary prerequisite admits the limited conditional-scoring
scope. Portable GPCM now extends the existing extraction/validation/freeze/save/
load/score workflow in development, with shared or separate step/slope owners,
one slope family, unit weights, no anchors/interactions and an estimated
intercept-only normal population. Source likelihood, gradient, unregularized
information and integration checks are evaluated at extraction; original global
audit states and their passing conditional decision remain in file format 2.
Replay validates those stored records without pretending to recheck omitted
training responses. Each score batch must pass adaptive reference comparisons
under the actual prior; failed numerical checks stop scoring. A supplied normal
prior remains distinct from the frozen prior throughout summaries and plot data.
RSM/PCM file format 1 keeps its default semantics.

The implementation acceptance evidence is recorded in
[portable GPCM validation](inst/validation/portable-gpcm-20260927.md): native and
independent posterior agreement, both owner arrangements, fresh-session replay,
corrupt/unsupported-input rejection, prior/output identities and existing
RSM/PCM lifecycle checks. A regular shared-owner calibration needed a finer
scoring grid for extreme new patterns, showing why extraction checks alone are
insufficient. These are conditional posterior calculations, not general
calibration, global-maximum or coverage guarantees.

Remaining work is integration into a new release candidate and its required
package/platform checks after the development scope is fixed. The profile-
likelihood interval milestone was evaluated separately below. JML portability
was outside this initial MML increment; its later scoped implementation is
described under JML completion criteria. Covariate populations, simultaneous
slope families and broader anchors/interactions remain outside this scope. Do not rerun old profile grids or large simulations
merely because the artifact implementation has changed.

#### One-relative-slope profile implementation (2026-09-27)

Development `confint(fit, method = "profile", slope = "...")` now accepts one
prespecified relative slope, with either shared or separate owners. All nuisance
parameters, including the estimated normal population, remain free under the
sum-zero log-slope constraint. Scope is intercept-only normal MML, unit weights,
no anchors/interactions; standardized profiles, contrasts, JML and covariate
populations are not included. Model/sandwich defaults remain unchanged.

Two starts, unchanged gradient/integration tolerances and checked cutoff roots
retain unresolved searches. The existing single curvature polish handles an
observed BFGS stopping-precision failure without discarding the original stages.
No crossing within the finite search is recorded as unresolved, not as proof
of an infinite bound. Sampled nonmonotonicity and better source likelihoods are
retained; remote/disconnected regions are not certified absent.

The two retained representative fits pass independent continuous-likelihood
checks at both endpoints. Shared-owner intervals differ substantially from
Wald, while separate-owner limits are close. Saved likelihood curves (the
profile-result plotting default), explicit interval plots, ggplot/payload replay,
Wald comparisons, endpoint/check tables and result/report/archive integration
are implemented without a new exported entry point. See the
[implementation and endpoint record](inst/validation/gpcm-profile-intervals-20260927.md).

**Disposition:** retain as an experimental, explicitly requested development
method for sensitivity analysis. Numerical implementation is complete in this
scope. The finite shared-owner comparison below is complete; it does not
support routine replacement of Wald or general coverage qualification.
The separate-owner validation exposed a failed start and reused
25 unchanged successful attempts when completing 13 failed/new evaluations;
its accumulated validation time is not a clean from-scratch method benchmark.
A profile is not admitted as a remedy for the earlier probability-curve
undercoverage or as an operational classification rule.

The prespecified R01 comparison used all 100 saved N=40 rotating-rater fits,
without source refitting or selective replacement. Profile returned both limits
for 53/100 (exact 95% Monte Carlo interval 42.8%–63.1%); Wald for 98/100.
All 53 available profiles covered, versus 89/98 available Wald intervals.
On the 53 common-available datasets, Wald covered 49: this selected comparison
does not establish general profile superiority. Profile nonavailability is a
clear concern under the declared .90 availability margin. Eleven profiles
failed source checks and 36 had unresolved constrained searches. No interval
nonexistence, general Wald adequacy or improved probability coverage follows.

Median full-call time was 8.80 seconds for profile versus 0.38 for Wald, under
the same two-worker local workload; all 100 cases completed in 564.2 seconds.
No extra fitting, threshold relaxation or successful-case rescue was used.
See the [comparison protocol](inst/validation/gpcm-profile-comparison-20260927.md)
and [result/disposition](inst/validation/gpcm-profile-intervals-20260927.md#finite-post-fit-comparison-and-stopping-decision).
This closes the finite diagnostic and method-disposition step, with an adverse
availability result; it does not close operational inference qualification.
Keep public limitations and proceed to combined-workflow/release-scope review.
Reopening the numerical method requires a concrete improvement and a new
comparison; no automatic grid expansion or universal coverage theorem is a
prerequisite. Portable scoring remains a separate completed scoped feature.

Earlier preparatory evidence for D4: a fixed-calibration comparison with TAM
now covers shared and separate slope/step owners and four new response patterns
per fixture. Category probabilities, EAP and posterior SD agree after the
explicit scale transformation and integration review. The initial lower-grid
stability failure is retained. This checks the existing fitted-object scorer,
not a portable artifact or free-estimation equivalence; see the
[fixed-scoring comparison](inst/validation/gpcm-fixed-scoring-tam-20260926.md).
After the user's Rosetta installation, the local ConQuest comparison verified
both fixed models and their numerical parameters after save/reload. Display
labels changed, so identity checks use the parameter indices and design.
Across both fixtures and three seeds, maximum EAP differences were 0.00713
at a posterior budget of 20,000 and 0.00243 at 200,000. These stochastic
differences are retained, not declared deterministic equality; printed-parameter
effects were checked separately. See the
[native comparison and runtime record](inst/validation/gpcm-fixed-scoring-conquest-20260926.md).
The historical external fixed-model fixture is complete within that scope.
Portable artifact implementation and its own save/reload scoring comparisons
are now complete within the admitted conditional scope; the workflow review
below distinguishes reused evidence from the new separate-owner comparison.

#### Combined user workflow and retained release scope (2026-09-27)

The [executed workflow record](inst/validation/portable-gpcm-20260927.md#combined-workflow-and-external-comparison)
closes the scoped local order-4 review. Both owner arrangements pass extraction,
validation, freezing, a genuinely new R scoring process with only the artifact
and response CSV, summary/plots, full-precision score and disposition exports,
prior sensitivity, and saved-result replay without refitting or rescoring.
The public tutorial's extraction/scoring/prior chunks were executed verbatim;
the fitting example reuses its documented retained model in this review.
Do not present that as a new calibration-fit validation or novice-reader trial.

The walkthrough includes distinct text IDs, central/endpoint/very sparse
responses and an all-missing Person. Five people have scores and one stays
unscored in each six-person example. Plots now disclose the unscored count and
label zero as the scale origin, not as the mean of every scoring prior.
Summaries distinguish the actual reported-score integration check from an
unused fixed-grid comparison. Training-model reports and new-cohort score
tables are explicitly different output routes.

The original separate-owner external-comparison fit fails the newer source
integration check; do not admit it by overriding review. A new fixed-model
TAM/local-ConQuest comparison uses the already retained, eligible adaptive fit.
The shared-owner external results are reused only after checking exact model
identity with the extracted artifact. Both frozen artifacts match external
designs/priors exactly. Across eight fixed response patterns, maximum portable
EAP/SD discrepancy against TAM is below 2e-13. ConQuest model persistence is
verified; at 200,000 posterior nodes the maximum EAP/SD discrepancies across
three retained seeds are .00243/.00166, reflecting its stochastic scoring.
Do not call this free-calibration equivalence or posterior-interval equivalence.

| Included in the next combined-source review | Explicit boundary |
| --- | --- |
| Conditional fitted-object scoring and declared normal-prior sensitivity | Passing local numerical checks; excludes calibration uncertainty, global-optimum and cohort-transport guarantees. |
| Portable GPCM MML with shared or separate owners | One slope family; estimated intercept-only normal population; unit weights; known levels/categories; no anchors/interactions. Existing RSM/PCM artifact semantics retained. |
| One-relative-slope profile API and saved outputs | Experimental, explicit sensitivity route; no routine replacement of Wald, improved-coverage claim or automatic profile computation. |
| The connected calibration-to-score workflow and corrected summaries/figures | Author-executed examples and stored-output checks; not evidence of general usability, diagnostic accuracy or population validity. |

Do not reopen numerical grids merely to improve this table. Order 5 still needs
a single check of the assembled source/archive, matching platform results and
a release-version decision. Existing rc.6 results and the same DESCRIPTION
version do not qualify this changed source. No CRAN submission or tag is
created by this local workflow review. The following JML work extends this
initial MML-only increment and is included in the active integration list.
External posterior-interval endpoints, latent-regression portability and wider
model structures remain outside this increment; neither TAM nor ConQuest is required by
ordinary package tests.

#### JML completion criteria (2026-09-27)

**Corrected JML through the existing API.** Complete the following integration
milestones in order. Keep corrected point estimation distinct from qualifying
its approximate intervals, and both distinct from selecting a correction order.
Do not hold all useful output until unrestricted inference is solved.

| Milestone | Deliverable and acceptance condition | Current status |
| --- | --- | --- |
| J1: observed-data estimator | Generalize the exact reference beyond hard-coded two-rater/two-criterion/three-category coordinates to a declared shared-owner input scope. Preserve observed allocation, categories, parameter identification and extreme-score semantics. State separately which RSM/PCM reductions are implemented; an implementation of corrected GPCM does not automatically qualify them. Return the corrected equation identity, explicit order, attempts and matching full-Jacobian Person covariance. Test at least one non-prototype structure and parameter-label permutation against independent calculations. | Internal explicit-order estimator implemented and target-checked for the declared shared-owner scope. General-input equations/covariance pass independent non-prototype checks; the runtime solver reproduces saved order-2/4 roots with a prespecified two-start/fallback policy. Attempts, unresolved or conflicting roots, point estimates and covariance failures are retained separately. This is numerical qualification, not coverage or a global root-uniqueness proof. Corrected RSM/PCM reductions are not implemented; fixed anchors, nonunit weights, interactions, separate-owner JML and dependent responses remain outside this scope. |
| J2: fit and output integration | Add an explicit correction option to `fit_mfrm()` without changing existing uncorrected JML calls or the MML default. Recompute Person profiles, probabilities and diagnostics using corrected structural estimates. Preserve estimator identity through summary, plot, report, save/replay and eligible portable scoring. Keep a valid point estimate when its covariance is unavailable, with the cause retained. Do not label an adjusted estimating-equation root as an unadjusted maximum-likelihood solution or inherit ordinary likelihood IC/LRT automatically. | Scoped local integration implemented: explicit `jml_correction_order` and sampling assumptions now return the existing fit class. Summary, labelled tables, point/distribution plots, ggplot conversion, results, reports and saved replay preserve estimator/order, local-root uncertainty and failed outcomes. A valid point survives covariance failure. Ordinary likelihood inference and unsupported diagnostics are refused; Person profiles retain extreme limits without invented SEs. Help/NEWS distinguish the experimental point workflow from structural coverage. Conditional observed-row probabilities, means, variances and descriptive residuals now use the corrected calibration and reprofiled Persons through mfrm_response_diagnostics(). Extreme probabilities and defined Infit are retained when Outfit is undefined; saved identity, plots, reports and exports preserve these meanings. Formal fit tests and calibrated cutoffs are not supplied. Conditional later-Person EAP and portable format 5 are now implemented, with fresh adjusted-equation/Jacobian checks, calibration/order identity, independent posterior integration and fresh-process replay. This completes the scoped local point/output/EAP implementation; formal structural inference, corrected Person ML/WLE and release qualification are not implied. Saved score batches use their own summaries/plots rather than attachments to mfrm_results(). |
| J3: supported automatic policy | Compare a prespecified rule using observable design/support information with fixed orders on independent samples. Evaluate the entire selected procedure, including failures, bias, interval inclusion and computational cost. Store policy version, chosen order, reason, alternative sensitivity and override. Unsupported input or unresolved selection must be explicit; never silently switch JML to MML or corrected to raw JML. | No validated selector exists. Current orders 2/4 reverse MSE preference across two settings; neither is a universal best choice. A deterministic recommended policy is possible only within its tested scope. |
| J4: beginner acceptance | Explain in plain language what was estimated, why the supported policy was used, whether correction materially changes the conclusion and what can be reported. Confirm on realistic assignment examples and actual novice reading/use evidence. Keep optional expert controls; do not require users to learn internal score operators. | A plain-language corrected-JML walkthrough now explains explicit order, allocation assumptions, the numerical solution, RootSE and supported reports/plots. Automatic-policy guidance and participant usability evidence remain unavailable. |

The [2026-09-28 general-input check](inst/validation/jml-general-inputs-20260928.md)
removes the earlier fixed-coordinate obstacle. Its maximum discrepancy from
the frozen exact equations is 1.66e-12; the independent larger-structure tests
also pass. The subsequent internal runtime integration adds explicit-order
fitting, separate point/covariance outcomes and native parameter-table checks.
J1's internal computational deliverable is implemented for its declared scope.
The public J2 point-estimation/output increment is now implemented locally and
recorded in help and NEWS. Conditional observed-row response diagnostics are
now connected to the same saved workflow. Conditional new-Person/portable EAP
now completes the scoped J2 implementation locally. Residual-bias and formal
inference qualification, the J3 selection policy and J4 novice-use evidence remain open. Targeted tests reuse
saved numerical evidence rather than adding another sampling grid. This does
not close the combined 0.2.4 release gates.

Automatic selection could lower cognitive load, reduce arbitrary tuning and
make common analyses reproducible. It can also conceal unresolved residual bias,
select the smallest SE rather than the smallest error, behave unstably near a
decision threshold and invalidate intervals that ignore selection. AIC is not
an automatic correction-order criterion for these non-likelihood equations.
Agreement between orders cannot detect shared bias. A bootstrap-based selector
would need its own sampling-model justification and end-to-end evaluation, not
just a minimum bootstrap SE. Initially, automatic support checks and numerical
fallbacks are distinct from a statistically validated automatic order choice.
J2 now exposes explicit `jml_correction_order` and `jml_correction_sampling`;
`NULL` preserves the existing estimator. No automatic selector is advertised.

**Model identity.** The current one-slope-family GPCM-MFRM is a restricted
generalized many-facet IRT model. It is not the complete Uto--Ueno GMFRM:
their equation 9 combines task and rater slope families with rater-specific
steps. Separate step/slope owners in MML do not add a second slope family;
JML still requires shared ownership. A bias correction changes the estimator,
not the response model. Report the response equation, owner structure and
estimator separately; free discrimination also relaxes strict Rasch invariance.
See the [model explanation](vignettes/mfrmr-gpcm-scope.Rmd#relationship-to-generalized-many-facet-models)
and [Uto and Ueno (2020)](https://doi.org/10.1007/s41237-020-00115-7).

#### Joint task and rater slopes: MML--EM integration (2026-09-27)

The requested first two-family extension follows Uto--Ueno equation 9:
`a_task * a_rater * (theta - task_location - rater_location - rater_step)`.
Both slope families remain fixed facet parameters, so the Person integral
is still one-dimensional. It is not a random-rater or multidimensional model.
Muraki (1992) supplies the GPCM MML--EM foundation. `sirt::rm.facets()` is a
useful two-slope EM implementation reference, but generally scales ability
only and uses item category intercepts. Its free-estimator output is not an
equality reference for this different response equation.

| Milestone | Acceptance condition | Current status |
| --- | --- | --- |
| G1: identified numerical core | Explicit response equation; task log slopes and task locations sum to zero; rater-specific steps sum to zero; free rater slopes with fixed N(0,1). E-step combines all ratings of each Person. Constrained numerical M-step retains ascent and marginal-score stopping. Check analytical scores, unit-factor reductions and independent-start direct MML on the same quadrature. | Internal implementation and focused checks pass. A 240-Person, 3-task, 3-rater example agrees within 3.8e-6 in parameters; 31/61-node parameter change is 8.84e-5. This is algorithm verification, not recovery or integration accuracy in general. |
| G2: existing fit/output contract | Integrate an explicit multi-owner specification into `fit_mfrm()` and existing result classes without changing single-owner calls or the default estimator. Preserve declared column names, owner/level identity, scale constraints and step ownership through prediction, diagnostics, plots, reporting and save/replay. Unsupported routes must give a specific reason. | In progress: the internal EM estimator uses common parameter/likelihood machinery, owner-aware maps and slope tables, local identification diagnostics and joint-covariance targets. Names are now declared independently of domain labels and data-column order, including non-syntactic/Unicode names; person and score columns are configurable. Self-contained RDS replay preserves numerical settings, original identities, nonconvergence and unobserved-crossing labels. Named roles and estimation/response equivalence have focused tests. Conditional response evaluation is shared with the existing curve API; full-coordinate probability/information derivatives and cross-family covariance propagation have focused checks. Known-but-unobserved contexts remain labelled in curve results, reports and default captions. Shared summaries now retain per-owner counts, distinct scale references and unavailable estimates; print descriptions and saved summaries have focused checks, with the existing single-family summary unchanged. An internal adapter now assembles actual EM estimates into the existing fit class with current readiness, posterior moments and the per-Person marginal-score stopping rule; fresh-process summary and response checks pass. Expanded profiles and IC ranking remain unavailable. Public multi-owner dispatch is now available provisionally with explicit EM/fixed-N(0,1) settings and an ordered slope_facet pair. Conditional fitted curves, plots, minimal saved results/reports and export are connected. Experimental component-slope intervals now use full observed marginal covariance, source identity, local Person-score rank, stationarity and higher-order integration checks. They retain separate owner/level/scale fields and unavailable outcomes through confint(), plotting, tables and exports. An explicit component profile now reoptimizes all nuisance coordinates for one named owner/level and retains its likelihood trace, same-target Wald comparison and failed endpoints through the same output routes. Numerical verification is not coverage qualification. Same-data posterior predictive response diagnostics now retain both slope families, observed row identities, incomplete assignments and unresolved integration through existing plots/reports/exports. Independent continuous integrals verify probabilities and mixture variances; row selection retains each complete Person record. These descriptive summaries do not supply calibrated cutoffs or formal fit tests. Curve/location intervals, ordinary diagnostics, ranking, new-person scoring and portable calibration remain open. |
| G3: uncertainty and statistical support | Use observed marginal information (Louis or independently differentiated marginal scores), not frozen-Q curvature. Evaluate boundary/global identification, slope-factor separation, distribution sensitivity, bias and interval performance. Sparse allocation must include common Persons, rotating/random panels and lost/weak bridges, not merely missing task cells. Compare sirt only in explicitly matched submodels; preserve alternative-model interpretation elsewhere. | Statistical qualification remains open. On the saved 240-Person example, the shared 13-coordinate observed Hessian agrees with the independently differentiated marginal scores to 4.45e-11; the covariance is unregularized and full rank. This checks the calculation, not sampling coverage. An initial 16-row binary design contrast detects rank 4/6 with one rating per Person versus 6/6 with four joint ratings at the same interior vector, despite connected task-rater crossings in both. This fixed-quadrature local check and the earlier positive observed-information example do not qualify general sparse designs, boundaries or interval performance. Experimental component-slope interval calculations now pass independent-Hessian/cross-family covariance and output checks on the retained example. A converged five-node fit fails the q-versus-2q-1 sensitivity rule, while the 31-node fit passes. These deterministic cases do not qualify sampling coverage or turn numerical safeguards into statistical decision thresholds. The first matched sparse study now completes 100 repetitions in each of four allocation/SD conditions. Reanalysis with a small-residual warning retains 11/100, 100/100, 100/100 and 99/100 interval availability for common SD=1, rotating SD=1, common SD=.5 and rotating SD=.5. The 89 common SD=1 refusals were quadrature-related. A subsequent neutral-start replay of all 100 datasets at 61 points, with unchanged EM controls, returns 100/100 interval sets and passes each 61-versus-121 check; t1/r1 coverage is 93/100 and 98/100. The existing quadrature-sensitivity API now retains two-family fixed-grid comparisons and interval checks. Sampling discrepancies remain: t3 coverage is 90/100 at SD=1, and the earlier .5-SD log bias and 90/99 task coverage are unresolved. The warning-rule reanalysis left estimates unchanged; the later quadrature refits change them slightly. Both reuse the same data and are not independent confirmation; see the sparse-allocation validation record. |
| G4: release integration | Explain both slope families in beginner-facing terms without equating rater slope with competence. Validate examples and applicable output routes; document limitations and complete targeted regression and release checks. | In progress. The guide now includes a beginner-facing provisional two-family fit-to-curve-to-report example and capability limits. Help and NEWS describe explicit inputs, algorithm controls, experimental component-slope intervals and unavailable curve/location intervals. Plots/reports preserve the warnings and numerical checks. This does not qualify general sampling performance, model ranking, diagnostics or portable two-slope calibration; integrated release checks remain open. |

**Connection to existing multivariate G/D studies.** Retain complementary
analyses of the observed ratings as the immediate user route: GPCM for category
responses and rater effects, multivariate G/D studies for score-component
covariances and assessment planning. The existing G/D APIs are implemented;
a GMFRM-to-G-study conversion and joint estimator are not. Hirai and Koizumi
(2013) provide a direct multivariate G-theory/MFRM precedent, but their G-study
omits raters and does not qualify generalization to new raters. Preserve each
analysis's rows, aggregation, criteria, weights and generalization population.
The updated GPCM/workflow guides explain this connection and its limitations.

The G2/G3 joint covariance work supplies parameter-uncertainty infrastructure,
not G-study variance components. A future model-based planning route must
first specify whether it generalizes over a fixed task/rater pool or a random
population, and whether its target is latent ability, expected scores or future
observed scores. It must propagate calibration uncertainty and the response
variation appropriate to that target. Acceptance requires agreement with the
declared target in matched special cases and evaluation of dependence and
sparse assignment. Joint latent/random-facet integration, as distinct from
complementary analysis, remains a later scope decision informed by Briggs and
Wilson (2007); it does not delay the current single-ability G2/G3 contract or
make multidimensional ability an implicit requirement. See the [user-facing
comparison and sources](vignettes/mfrmr-gpcm-scope.Rmd#how-does-this-relate-to-multivariate-g-theory).

**Named facets, explicit model roles.** The internal two-owner problem now
accepts declared person/score columns and an ordered pair of slope-facet
columns. The first facet carries centered locations and geometric-mean-one
slopes; the second has free locations/slopes and owns the centered step sets.
These roles follow the explicit specification, not English labels or data
column order. Structured locations/slopes, optimizer maps, response contexts,
covariance targets and replay inputs retain original names. Common data/output
reserved names are rejected explicitly to prevent collisions. This does not
add more than two measurement facets, a third independent step owner, arbitrary
signs, anchors or public multi-owner dispatch. Keep those scope changes distinct
from renaming the present two-facet model.

The common table and internal-result step now preserves **owner plus level**
as the slope identity. The next public consumer step must retain that pairing. Task slopes have geometric mean one; the free rater slopes
use the declared fixed-standard-normal ability scale. Their reference value
of one therefore must not be described as the average rater's discrimination.
Effective products belong to a task-rater context and carry both component
owners. Public inference, plot annotations and feedback must retain these
meanings before routing through existing one-owner consumers. Preserve
nonconvergence, unavailable intervals and unobserved-context labels through
all consumers. The internal RDS replay verifies reconstruction, not a released
portable-calibration format, new-Person scoring or inference qualification.

The two GM1 slope constraints used by sirt accompany an estimated population
SD. Copying both constraints while also fixing SD to one would unnecessarily
restrict overall discrimination. The current internal extension fixes the
population and only the task-slope geometric mean; population extensions need
their own explicit reparameterization. Numerical EM steps need not solve a
closed-form M-step or reach a global optimum. Their trace is retained, and an
iteration limit is not convergence. This MML work does not implement or qualify
the corrected-JML milestones above.

Evidence and reproducible command:
[joint-slope EM verification](inst/validation/gmfrm-mml-em-20260927.md).

**Literature refinement: Wang--Liu (2007) and Wang--Wu--Qiu (2025).**
The former combines an item-slope full-predictor GPCM with person-level latent
regression. `population_formula` and `person_data` already implement conditional
normal latent regression in the public single-owner MML route; do not present
latent regression itself as a missing feature. A future two-owner population
extension should reuse that interface and coding/scoring provenance rather
than add another fitter or regress EAP point estimates as error-free data.
Item-owned steps in Wang--Liu and rater-owned steps in Uto--Ueno remain explicit
model choices, not interchangeable labels. The 2007 article's appendix uses a
reference slope fixed to one and estimated residual SD; external matching
requires a scale transformation to the package's relative-slope convention.

The 2025 preprint's derivative-based feedback supports extending existing
response/information curves with ability-conditional expected-score sensitivity,
then optional population-averaged summaries using declared task weights and a
common reference population. For the current two-slope kernel, use
`d E(Y|theta)/d theta = (a_task*a_rater)*Var(Y|theta)` and
`I(theta) = (a_task*a_rater)^2*Var(Y|theta)`. These are different quantities.
The derivative identities are tested; a new normalized capability API is not
implemented. Do not call such a summary absolute scoring accuracy or certify
rater competence without an external criterion. Two raters assigned different
ability distributions must also be compared on a shared reference distribution.

Before adopting a normalized summary, independently verify its denominator,
pointwise versus population-averaged range, score scale, task mixture and joint
covariance propagation. The preprint treats binary scores; it is not validation
of a polytomous extension. Its Appendix A/B derivative simplifications require
correction; its normalizer approximation is not an exact 0--1 normalization.
These issues do not invalidate the useful conditional-curve idea. Review details
and an independent numerical countercheck are in the linked verification record.

Keep the current quadrature-based MML--EM reference. Laplace is a candidate
integration approximation, not a substitute objective called JML. It must be
checked against the reference under few ratings per Person, extreme patterns
and heterogeneous slopes before adoption. Recompute posterior modes for each
candidate structural parameter vector and retain the curvature correction and
its parameter dependence. A slope normalization must preserve the effective
slopes by compensating the population scale. Neither a 10-iteration cap nor a
small SD change alone is an acceptable convergence criterion here. This work
refines G2/G3 and existing feedback plans; it does not add an independent model
family or displace corrected-JML work.

JML estimation exists for RSM, PCM and shared-owner GPCM. Its portability and
inference need their own qualification; the MML milestones are not substitute
evidence. RSM/PCM portability and shared-owner conditional GPCM JML portability
are now implemented and locally verified within their distinct source scopes.

1. **Portable JML-calibrated EAP — scoped RSM/PCM and GPCM complete locally:**
   reuse the public lifecycle and scoring kernel with file format 3 for RSM/PCM, a labelled
   post-hoc N(0,1) reference prior and optional normal-prior sensitivity.
   Admitted source scope: current finite/identified RSM/PCM JML, unit weights,
   no anchors or interactions. Fresh joint-likelihood agreement and gradient
   checks supplement existing source readiness; they are not MML integration
   tests or JML interval qualification. New score batches check EAP/SD integration.
   Native/artifact/independent-session scoring, prior provenance, missing and
   endpoint dispositions, stored-source evidence and invalid-source refusals
   pass targeted checks. A low-grid scoring failure is retained; no tolerance
   was relaxed. See the [JML implementation record](inst/validation/portable-jml-20260927.md).
   Shared-owner GPCM JML uses file format 4, unit weights, no anchors or
   interactions and the same labelled reference-prior meaning. Fresh joint
   objective/gradient agreement and positive-definite, unregularized curvature
   over free Person and structural parameters qualify conditional scoring;
   these checks do not complete the global identification or boundary audit.
   Original incomplete audit states persist. Known infinite Person/slope
   estimates and certified additive/slope boundaries override local curvature
   and block extraction. Independent likelihood, derivative, curvature and
   posterior-integration checks, both owner types and separate-process replay
   pass. See the [GPCM JML record](inst/validation/portable-gpcm-jml-20260927.md).
   The actual JML calibrations have now also been checked as fixed inputs in
   TAM and local ConQuest under two declared priors. This closes the scoped
   external scoring gap, not free-JML estimation or boundary qualification.
   The [external scoring and literature record](inst/validation/gpcm-jml-external-scoring-20260927.md)
   separates numerical agreement, stochastic approximation, scoring literature
   and package cutoffs. The binary Rasch foundation for JML bias/boundary/
   inference has now been reviewed; transfer to many-facet GPCM and
   design-specific qualification remain part of milestone 3.
   Dense source-curvature checking has quadratic memory cost; general
   large-design performance, wider structures, weights and anchors are not
   qualified. The combined-source/archive and platform checks remain pending.
2. **A distinct ML/WLE scoring decision:** specify whether likelihood-only or
   bias-adjusted new-Person scoring is required, including infinite extreme
   scores and uncertainty. This is a different target from EAP portability;
   do not add a method alias that changes the estimand silently.
3. **JML structural inference:** open. The
   [literature and implementation review](inst/validation/jml-inference-review-20260927.md)
   distinguishes variability around a JML limit from coverage of the true
   parameter. Complete the following in order before exposing slope intervals:
   The [allocation-dependent population challenge](inst/validation/jml-scope-challenge-20260927.md)
   now evaluates both shared owners, sparse/unequal rosters and orders 0/1/2/4.
   All 12 corrected cases pass their two-start/covariance checks; one of four
   raw-JML cases remains unresolved. Higher-order correction reduces residual
   displacement in these cases, but order 4 does not uniformly minimize the
   bias-squared-plus-variance proxy. Keep orders 2 and 4 as explicit candidates
   for independent sampling validation, not automatic or qualified public
   defaults. No coverage conclusion follows from the population calculation.
   The subsequent [paired sampling study](inst/validation/jml-scope-challenge-20260927.md#independent-order-2order-4-sampling-decision)
   completes 200 N=400 datasets each for Criterion/unequal and Rater/sparse.
   Both orders return reviewed roots and sandwich intervals in all 400
   datasets. Order 4 reduces log-slope RMSE from .07064 to .06933 in the
   first setting but increases it from .09084 to .09372 in the second;
   both paired MSE differences exclude zero in their normal Monte Carlo
   intervals. Log-slope truth inclusion is 93.5%-94.5%, with wide MC intervals;
   this does not qualify general 95% coverage. Rater/sparse needs fallback
   starts in 22/200 order-2 and 34/200 order-4 fits. This closes the declared
   two-condition sampling comparison, not milestone 3. Keep explicit orders;
   define the supported observed-data estimator/covariance/failure contract
   before API integration. Do not expand the simulation grid automatically
   or mistake the five-coordinate research reference for a general estimator.
   - Specify the structural target, identification, permitted response design
     and finite/extended boundary estimand. Binary Rasch asymptotics are a
     foundation, not a qualification of many-facet free slopes.
   - Derive the nuisance-adjusted curvature and the sampling covariance for
     the stated regime. Reuse the existing independent joint derivative
     checks, and verify the new transformation separately. A Schur complement
     or an invertible Hessian alone does not establish the sampling covariance
     or eliminate incidental-parameter bias. Local profile-curvature algebra
     and relative-log-slope transformations now pass independent conditional
     Person reoptimization checks for both saved shared-owner fixtures. Their
     N=14 profile-gradient matrices have rank 13 for 17 structural coordinates,
     so these fixtures do not qualify a full empirical sandwich. This does not
     prove that every slope contrast is inestimable, and it is not a new
     minimum-N rule. Sampling covariance qualification remains open.
   - Justify any bias treatment, or explicitly restrict the supported design
     and approximation. Do not transfer a classical item-count multiplier to
     free slopes or unequal exposure without a derivation and validation.
     Exact response enumeration now demonstrates nonzero expected profile
     scores at the truth in a two-Rater/two-Criterion GPCM, with dependence on
     ability. One plug-in recentering step reduces but does not eliminate
     that score bias; it is a research candidate, not a selected estimator.
     A common multiplicative slope correction cancels under the current
     geometric-mean identification and is ruled out for relative slopes.
     Before adopting a score adjustment, verify its roots, residual parameter
     bias and Jacobian; covariance must use the adjusted estimating equation,
     not the raw-JML Hessian. Do not inherit likelihood-ratio tests or IC
     rankings from an unadjusted likelihood for a changed estimator.
     The exact population-root benchmark now solves all five structural
     coordinates under a declared three-point ability mixture: adjusted roots
     are closer to truth in the four checked owner/exposure designs, but
     residual displacement remains. Initial direct root solving passed 16/24
     attempts; eight retained failures required objective minimization (raw
     JML) or a different root algorithm (adjusted). Resolved starts agree
     within 2.75e-9. The adjusted Jacobian is nonsymmetric. This closes the
     small-design root preflight, not finite-sample bias/coverage or global
     uniqueness. The subsequent sample-level prototype now solves empirical
     equations and calculates a Person-level sandwich using the full adjusted
     Jacobian. One 400-Person sample per existing design was checked. Initial
     roots passed both starts in 7/8 method/design cases; changing the solver
     from the original failed start resolved the eighth. A weak raw-JML case
     needed smaller perturbations to verify its local influence derivative,
     with unchanged tolerance. All failures are retained. One adjusted slope
     moved farther from truth, so this is not evidence of uniform improvement.
     See the [sample/covariance record](inst/validation/jml-inference-review-20260927.md#sample-estimator-and-matching-covariance-2026-09-27).
     A subsequent prespecified 200-dataset paired comparison for the
     Criterion-owner, 8-rating, 400-Person design completes its finite
     method-development question: log-slope RMSE falls from .1759 to .0551;
     truth inclusion rises from 62.0% to 96.5% (adjusted Wilson MC interval
     93.0–98.3%). Raw population-root inclusion is 95.5%, supporting a bias
     explanation for its poor truth inclusion. Both research methods return
     all 200 intervals; two adjusted starts require the prespecified fallback.
     These are research sandwich intervals, not a newly supported public JML
     route. Residual bias remains; other populations, sparse/unequal designs,
     larger structures and scalable expectations remain open. See the
     [paired-study decision](inst/validation/jml-inference-review-20260927.md#paired-repeated-sample-decision-2026-09-27).
     Do not automatically add replications or another grid. Advance the
     residual-bias/design decisions alongside D2/D3 integration; this result
     does not replace package integration or qualify general JML inference.
   - Evaluate sample size and observed ratings per Person independently,
     starting with the supported unit-weight, shared-owner, no-anchor model.
     Distinguish adding observations from adding facet levels/parameters;
     include connected sparse/unequal exposure and extreme responses.
     Report bias, empirical variation, interval width, interval availability,
     coverage among available intervals, and true-value inclusion over all
     attempted replicates, with Monte Carlo uncertainty and separate failure
     counts. Prespecify simulation precision before selecting replication counts.
   - Publish only the qualified scope through existing interval, diagnostic,
     plot and help routes. Release acceptance can retain documented JML
     scoring with inference unavailable; it must not label this milestone
     complete or advertise general coverage on that basis.
4. **Separate-owner JML:** extend identification and likelihood/derivative
   checks for this structure before granting the MML feature set. Reuse
   existing shared-owner boundary evidence where applicable, without treating
   it as validation of the new structure.

External comparisons must align model, identification, response adjustments,
item bias correction and scoring target. TAM's documented `tam.jml()` defaults
include `adj = 0.3` and `bias = TRUE`; mfrmr's unadjusted JML is not that default
procedure. A fixed-parameter ConQuest MML/EAP comparison tests a scoring kernel,
not free JML calibration or JML interval coverage. Reuse the retained JML
comparison records before commissioning new runs. The scoped RSM/PCM and
shared-owner conditional GPCM portions of milestone 1 are completed locally.
Broader portability and milestones 2–4 remain open; this is not completion of
JML as a whole.

#### External comparison requirements

Use three distinct comparisons, with exact versions and source identities:

* **Free calibration:** reuse the retained item-only TAM and ConQuest mappings
  and fixtures, then check changed estimation paths where needed. Compare
  transformed slopes/steps, category probabilities and the same marginal
  likelihood. A many-facet additive-intercept model need not equal mfrmr's
  full-predictor multiplication. Do not present a different-model fit as a
  numerical replication, or matching point estimates as matching intervals.
  Transformed parameter intervals require the joint covariance or an equivalent
  likelihood calculation; marginal SE columns alone cannot validate them.
* **Fixed-calibration scoring:** supply the same fixed response functions and
  new responses. First compare category probabilities and Person log
  likelihoods, then EAP and posterior SD on the same scale and prior; compare
  equal-tail intervals only when both routes expose the same target. A fixed
  many-facet response function may be expressible through generalized-item
  intercepts and scores even when free estimation constraints differ. Derive
  and test that representation before claiming agreement. TAM's WLE/MLE route
  is a separate comparison if those estimators are admitted, not an EAP oracle.
* **Persistence and input meaning:** compare before/after save/load and in a
  fresh session; check row and declared facet/category order, incomplete known
  assignments, missing assigned scores, extreme patterns, no usable ratings
  and unknown levels. Preserve explicit omissions and rejection reasons.
  Unassigned cells are not imputed; a new rater or task is not assigned a zero
  effect. Test malformed artifacts and compatibility without requiring users
  to install either comparator to run ordinary package tests.

TAM documents fixed item/loading parameters and new-response scoring in its
[fitting](https://alexanderrobitzsch.github.io/TAM/reference/tam.mml.html) and
[scoring](https://alexanderrobitzsch.github.io/TAM/reference/tam.wle.html)
references. ConQuest documents `anchor_parameters`, `anchor_tau`, population
anchors and ability estimators in its
[command reference](https://conquestmanual.acer.org/s4-00.html).
Use the locally installed ConQuest executable and synthetic fixtures. The
existing [TAM](inst/validation/tam-gpcm-item-only-overlap-record-0.2.3.md) and
[ConQuest](inst/validation/conquest-gpcm-overlap-record-0.2.3.md) records are
historical calibration evidence, not completed portable-scoring comparisons.
Both comparators enter the planned evidence; document an unsupported target or
unavailable output explicitly instead of silently substituting another method.
If a required comparison cannot be completed, record a release-scope decision
rather than marking the comparison passed. Retain runnable scripts and results
outside the CRAN package, with a compact public account of what they establish.

#### Statistical evidence, defaults and stopping rules

Freeze the scoring prior with the artifact by default. Reestimating the next
cohort's distribution or supplying a new prior is a separately named operation
with a new identity and an explicit comparison; it must not silently alter EAP
scores. Posterior SDs and intervals condition on the frozen point calibration.
They do not include calibration uncertainty or establish transportability to a
different cohort. Estimated-population metadata therefore needs a schema
extension beyond the existing fixed-normal RSM/PCM artifact. A portable object
is not an import/export promise for every external model.

MML RSM/PCM retain artifact schema version 1; MML GPCM uses version 2 with
explicit slope ownership/action/identification, a frozen estimated-normal prior
and conditional source-check evidence. JML RSM/PCM and shared-owner GPCM use
versions 3 and 4 respectively, with an explicitly post-hoc reference prior;
JML has not estimated that prior. Names such as `quadrature_eap_v2` identify
the scoring algorithm independently of the artifact version. Validation and
scoring dispatch by both identities; older RSM/PCM artifacts remain supported.
Keep original RSM/PCM objects readable and numerically reproducible; any
migration must be explicit and preserve their scoring basis. Validate positive
slopes, complete owner-level maps, normalization, category coding and finite
population parameters before freezing. Changing any of these changes the
calibration's semantic identity. Reuse the existing lifecycle and score-result
classes rather than introducing another public calibration API.

For any new repeated-sampling study, fix the target (slope, probability, Person
score or test), practically useful accuracy, Monte Carlo precision and decision
rule before running it. Declare availability, bias/RMSE, interval width and
coverage with Monte Carlo uncertainty, including unresolved cases. Use the existing pilot timings to choose a bounded
budget, adjusting for actual profile costs. Separate complete from connected
incomplete assignments and point-estimate error from interval availability and
coverage. Retain every planned case and adverse result. Informative missingness,
weak/disconnected designs and population misspecification need separate claims;
neither external agreement nor a large simulation supplies a universal guarantee.
No repeat of the existing 80-fit pilot, automatic nested bootstrap grid or broad
full-suite rerun is required for writing this plan. Broaden verification only
for a changed path, a reproduced failure or an explicit new statistical claim.

### Later extensions and explicit reopening conditions

| Candidate | Dependency and decision before work resumes |
| --- | --- |
| Shared-rater interval qualification | The current bootstrap remains a candidate. Reopen only after a concrete numerical/method improvement, a justified narrower target or a feasible measured computation plan. Reuse the 800-dataset review and retained draws. More inner draws alone do not repair unavailable tails. |
| Broader GPCM profiles and scoring | Scoped MML profiles and MML/JML portability belong to current integration. Broader profile targets, portable ML/WLE and latent-regression portability require separate decisions. Agreed corrected-JML and two-fixed-slope work remain in the active 0.2.4 program, not deferred by this later-work row. |
| G/D-study planning extensions | Begin with a concrete task-versus-rater allocation decision using existing cost/scenario tools. A new nested-plan interval or general structure requires its own target, identification and evidence; observed-score G-theory remains distinct from latent MFRM. |
| Random-effects/testlet extensions | Follow the [dependence integration gates](#dependence-testlets-and-random-effects-integration-order-2026-09-28): define sharing units, prediction populations, matched reductions and joint integration before combining models or adding random slopes. Existing numerical support does not qualify new uncertainty. |
| Multidimensional MFRM | Remains deferred until dimensions, loadings, covariance identification and scoring/reporting decisions are agreed. It is not a dependency for D0–D5 or for the [one-ability diagnostic work](#one-ability-checks-and-exploratory-residual-networks-2026-09-28); explicitly matched external comparisons can precede a native fitter. |

At D3, research outside the agreed scope may remain documented limitations.
Unfinished agreed outcomes require completion or an explicit scope decision;
broken supported routes, silent owner changes, misleading uncertainty labels
and incompatible saved outputs must be repaired. Stop at the agreed D4/D5
endpoint, not when every long-term research candidate has been implemented.

## Purpose and priorities

mfrmr helps users calibrate ratings, compare Persons and facets on an explicit
measurement scale, reuse a calibration, and plan assessments with a clear
account of what the results support. The agreed development order for 0.2.4 was:

1. Finish the implemented development workflows: APIs, examples, tables,
   plots, exports, saved results and failure behavior.
2. Qualify statistical support for the retained uncertainty, imputation and
   rater-feedback targets, reusing the completed G/D-study evidence.
3. Extend the models for specified assessment designs and analysis targets.
4. Integrate the completed work from stages 1–3, together with the existing
   calibration workflow and corrections, into mfrmr 0.2.4.

The post-release plan below retains the principle of finishing and qualifying
workflows before broadening models. A reproduced
calculation or interpretation defect is corrected when found. Completion requires
working functionality under stated conditions, applicable evidence and clear
failure behavior. Research results or documentation alone do not implement an extension.

The estimation core remains frequentist MML/JML. EAP scoring conditional on a
fitted calibration does not make calibration fully Bayesian. Observed-score
G-theory, exploratory feature groups and latent MFRM estimates answer different
questions; they must retain their own scales, assumptions and interpretations.

## Focus for 0.2.4

The release outcome is an assessment workflow that connects rating-design
review, estimation, qualified uncertainty, rater feedback, assessment planning
and reproducible output. Educational performance assessment is the principal
example; the same explicit roles can describe music, clinical assessment or
judged performances without claiming validation in every domain.

The authoritative current scope is the [active scope table](#scope-and-completion-decisions).
The table below preserves the **rc.6 baseline**, not the complete expanded
0.2.4 program. That candidate's recorded integration, platform and publication
checks do not qualify subsequent local additions or close the joint-slope and
corrected-JML work. The M0–M6 records below describe that historical checkpoint;
current completion is governed by D0–D5.

| Retained rc.6 baseline | Outcome retained in the expanded release | Explicit boundary |
| --- | --- | --- |
| Existing MFRM and portable calibration | Preserve supported RSM/PCM, GPCM/JML, anchors, linking, diagnostics, new-Person scoring and corrected saved analyses. | Existing model-specific restrictions remain; new engines or unrestricted inference are not implied. |
| Exploratory external features | Separate Person/rater/task tables; mixed-feature and hierarchical clustering; numeric PCA/k-means; setting and paired-imputation comparisons; interpretable profiles and figures. | Descriptive groups, not latent measurement classes, causal effects or automatic selection of a best partition. |
| Assigned-score multiple imputation | Review supplied ordinal completions, preserve assignment and observed scores, fit on a common scale and pool eligible non-Person fixed-facet targets; provide a statistically examined example. | No filling unassigned cells, automatic choice of an imputation model, pooled EAPs or imputation for the two new model classes. |
| Statistical support for feedback | Fixed-facet one-way sandwich intervals with the correct target; planned-roster evaluation of false flags, detection and unavailable results; ordinary-model bias analysis with its existing limits. | A working-model interval does not remove misspecification bias. Screening is evidence for review, not automatic rater exclusion. |
| Multivariate observed-score G/D studies | Preserve crossed and selected nested estimation, composites, scenarios and supported paired plan-difference intervals. Complete a fixed-task-set / sampled-rater example using fixed score components where that representation is valid. | This example does not add a general fixed-facet solver. Arbitrary nesting, unequal future allocations and universal G-theory structures are outside 0.2.4. |
| Shared-rater and Person-local testlet RSMs | Finish the two locally implemented models as bounded workflows: fit, appropriate Person scoring, rater feedback, declared uncertainty, predictions, same-data ordinary-MFRM comparisons and saved output. | One substantive ability and adjacent-category RSM. Joint shared-rater/testlet, PCM extensions, heterogeneous/correlated local effects and new substantive dimensions are later work. |
| Model-aware diagnostics and figures | Define and verify response moments and descriptive Infit/Outfit for the two extensions; provide model-aware location/Wright displays, fit pathways and comparison figures from matching result objects. | Classic fit cutoffs, standardized tests and likelihood-ratio rules are not automatically transferable. Formal extended-model DRF/bias tests and automatic decisions are outside this release. |
| Help, reporting and migration | Runnable question-to-result tutorials, English plots, consistent help/NEWS, static reports and CSV/HTML/RDS replay; preserve refusals and uncertainty meanings. | The extended-model Shiny viewer and complete feature parity across every result class are not release requirements. |

Conditional Person intervals remain a legitimate, explicitly conditional
output: they hold calibration fixed and are not presented as intervals that
propagate calibration estimation. General calibration-aware Person/contrast
intervals are a later inferential extension. Their absence does not permit
mislabeling current intervals. Existing shared-rater interval undercoverage,
population restrictions and numerical approximation require explicit output
restrictions. Both extensions now omit automatic fixed-facet and step bounds;
shared-rater individual bounds are also omitted. Explicit normal approximations
and the separate approximate population-SD profile remain available under
stated checks and limitations. This output decision does not improve coverage
or turn an unqualified inferential claim into a supported one.

The ability-population decision is to add an estimated normal ability
variance to both RSM extensions before release, retaining fixed N(0,1) as
an explicit restricted option. With a unit Rasch slope, fixing that variance
is a substantive assumption, not just a choice of units. Both local APIs now
estimate ability variance and accept an explicit known SD. Shared-rater
uncertainty, profiles, bootstrap refits and saved reports use the same population
contract. The testlet path now has a bounded estimated-population comparison: accounting
for local dependence improved interval coverage relative to ordinary RSM but
increased point-score error in two balanced conditions. Small/sparse coverage
and regular calibration-interval qualification remain inconclusive. Shared-rater
conditional scoring and local calibration-likelihood changes now have bounded
independent numerical support. The retained interval-output decision is now
implemented, with cross-workflow integration evidence for the earlier source.
Current-source integration remains subject to the milestones below. The extension does
not add substantive dimensions, heterogeneous ability groups or latent
regression. Existing fixed-population checks apply only to their original
branch. Comparisons and descriptive fit summaries must retain matched data,
population assumptions and a declared response-probability definition.

Broader ambitions are kept visible in the later-work section. Moving a
required outcome out of this table changes the release scope and must be
identified as such; it cannot be recorded as implementation completion.

## Milestones and the end of this development cycle

This M0–M6 table records completion of the **rc.6 source**, not later local
development. Use D0–D5 for the assembled working tree.

Milestones describe completed user outcomes and evidence, not elapsed time,
numbers of APIs or numbers of passing expectations. There is no promised
release date. The statistical question and model definition are settled before
additional confirmation simulations or a final source freeze.

| Milestone | Completion condition | Current-source status |
| --- | --- | --- |
| M0 — Release scope | Agreed functionality, output meanings and exclusions are explicit. | Scope retained. The completion order below replaces the open-ended sequence of GPCM case investigations. It does not defer the agreed GPCM APIs to another release. |
| M1 — Existing workflows | Calibration/scoring, features, assigned-score MI, feedback and G/D planning run through saved output. | Implemented with earlier workflow evidence. Common-MML cautions reach fixed-facet inference and MI pooling. The current-source educational walkthrough is now complete; optional features/MI/G/D outputs were checked using saved results. This does not qualify every statistical target. |
| M2 — Statistical and model decisions | Freeze the estimator, targets, qualification rules and evaluation protocol before confirmation work. | The registered engineering numerical checks and claim/evidence mapping are complete. The broad grid is not a required deliverable. A 17-case historical replay identified two changed admissions. Numerical coordinate and representative boundary-output checks are complete. A prespecified retrospective analysis now evaluates standardized differences and curves on all 800 saved fits; the adverse probability-coverage result persists in a matched current-estimator refit of its complete 100-dataset cell. Attribution to an old optimizer is ruled out for that cell. The per-family release dispositions below settle the retained inference scope; no stronger coverage claim is accepted. |
| M3 — Qualified model workflows | Numerical and statistical evidence supports the retained model outputs under declared conditions; adverse results remain visible. | Release disposition settled for the retained approximate outputs, as specified below. This is not a finding that every nominal interval has adequate coverage: probability families show substantial undercoverage, and bootstrap repeated-dataset accuracy remains unqualified. The agreed APIs remain available with those limits; no improved-coverage claim or new interval method is included. Earlier shared-rater/testlet restrictions remain in force. |
| M4 — User and maintenance integration | Representative workflows, defaults, warnings, figures, exports and help agree on the same source. | Changed GPCM paths and common-MML consumers have focused evidence. Actual weak/unavailable/unbounded interval displays, Markdown reasons and CSV/RDS replay now pass representative review. The current-source educational assessment-to-feedback walkthrough is complete, including its precision-decision repair and optional saved-result branches. Independent novice usability testing has not been performed. |
| M5 — Local completion | Freeze one source/archive after M1–M4; run applicable integrated checks and resolve failures. | Complete locally for the September 26 successor. The initial full suite found three failures, all repaired and checked with 516 focused expectations. Source-documentation and fresh-session complements pass; the final archive passes 0 errors / 0 warnings / 1 maintainer/update-frequency NOTE. Full tests/examples/manuals were not repeated: the exact repair delta and reusable evidence are recorded in the [integration record](inst/validation/claim-reconciliation-0.2.4.md#2026-09-26--complete-local-integration-of-the-retained-inference-scope). |
| M6 — Public release | The same successor source passes applicable platform checks and has matching main/release assets/help/site. | Candidate publication complete for rc.6: all five platform checks pass, matching help/tutorials are deployed, and the tagged archive/checksum are verified after download. Final release and submission decisions remain separate. Earlier Win-builder uploads retain their original source identity. |

M1 workflow finishing and M2 read-only model/statistical decisions can progress
together. M2 precedes new confirmation work; M3 and M4 precede M5. Corrections
to reproduced calculation or interpretation defects interrupt this order.
Documentation is maintained during implementation, not postponed entirely to M4.

Local completion supplies a reviewable release candidate; it is neither a
GitHub final release nor CRAN acceptance. CRAN submission and the external
review outcome are separate from M6. A current local-development instruction
does not itself start publishing. The current scope cannot be declared done
while an included model, diagnostic or statistical decision is unresolved.

If evidence rejects a proposed method, repair it, restrict the affected
inferential output to a justified scope, or propose an explicit scope change.
Do not silently defer an entire required workflow, relabel a known failure as
success, or keep adding simulations until a favorable result appears.

Portable calibration remains part of the integrated release. Its current scope
is one observed scale, fixed-standard-normal RSM/PCM MML, supported direct/group
facet anchors and stored two-way facet interactions. Fitting-integration review
refits at each requested order, extraction uses the reviewed highest-order fit,
and scoring settings remain separate. Save/load and fresh-session scoring must
preserve categories, scale, anchors and settings; incompatible inputs must be
refused. No order is universally sufficient. Portable intervals condition on
the saved calibration and prior, without calibration-estimation uncertainty.

Existing ICC, residual-reporting and shrinkage/replay corrections must also
survive integration. Migration guidance must distinguish reprinting, recomputing,
rescoring and refitting. Earlier checks support unchanged content only; the
expanded 0.2.4 needs its own source identity and final verification. See
[updating saved analyses](README.md#updating-saved-analyses) and
`vignette("mfrmr-portable-calibration", package = "mfrmr")`.

## Current implementation and remaining evidence

The table below records **rc.6 capability and statistical limits**. It is
retained as baseline evidence; the active milestones govern later changes. The September 26 successor completes M5 locally. Evidence is reused only for
unchanged source and matching scope, with the exact repair delta recorded.
This implementation is now in `main`; its five-platform checks and website
deployment pass. The matching rc.6 tag and downloadable archive are verified.

| Workstream | Current status and completion condition |
| --- | --- |
| Numeric k-means/PCA | Implemented and checked locally with explicit geometry, component selection, paired feature imputations, plots, comparisons and executed help examples. Included in GitHub rc.5; the later recommended PAM name and guidance are included in rc.6. Group validity and inferential guarantees are not established. |
| Assigned-response multiple imputation | Implemented and checked locally for reviewed supplied imputations and fixed-standard-normal RSM/PCM MML analyses. Event eligibility, assignment, categories and observed evidence are preserved; eligible non-person facet targets use covariance-aware Rubin pooling. The joint-RSM tutorial includes forty posterior predictive completions, shared Person draws, calibration uncertainty, sampling diagnostics, category probabilities and a separate lower-score assumption. In its 30-missing-score example, direct observed-score MML and MI contrasts are 0.463 and 0.468 logits; the lower-score assumption gives 0.667 logits. All eighty completed-data fits are eligible. A paired 200-dataset comparison now adds bounded evidence: under the tested MAR design, MI coverage is 96.5% among 198 available intervals (95% Monte Carlo bounds 92.9--98.6%); two posteriors miss the sampling-diagnostic threshold. Under low-score-dependent MNAR, coverage is 26.0% with +0.574-logit bias despite a similar missing fraction near 14%. The planned comparison is complete. Preserve this scope through integration; proper imputer priors versus MML moments remain an approximation, and arbitrary imputers/designs or general coverage are not qualified. EAP pooling and other model families remain outside this route. |
| Robust intervals and coverage | A one-way sandwich API is implemented and checked locally for fixed-facet RSM/PCM MML estimates and contrasts, using persons or declared larger independent clusters. Help, plots, independent derivative checks and a 1,600-dataset bounded comparison are complete. All intervals were available; generating-truth coverage still fell to 87% in the joint skewed/sparse scenario. The method targets the working model's limiting parameter and does not remove misspecification bias. This bounded target, its public interpretation and local integration are complete. Small-cluster, multiway/crossed, G/D-study and variance-boundary extensions remain later work. |
| Rater diagnostic accuracy | A planned-roster API, plot and tutorial are implemented locally, with unavailable outcomes retained and per-target/family rates distinguished. A prespecified 1,000-trial matched-budget study reused 200 results and fitted 800 new datasets. The tested Infit/Outfit union detected only 6/100 and 2/100 contaminated-rater cases under two sparse assignments; false-family flags were 0/100 except 1/100 in one missingness condition. All screens were computable, but three fits required category-support review. Threshold calibration, other departures including differential rater functioning, and broader accuracy remain open. Flagging alone does not justify rater exclusion. |
| Random-rater MFRM | Implemented locally: shared normal rater effects, estimated or known normal ability SD, approximate MML, observed/replacement-rater probabilities, population-SD profiles, conditional Person scoring, ordinary-model comparisons, descriptive diagnostics, model-aware maps and saved reports. A prespecified 800-dataset estimated-population study found individual-rater conditional coverage of 91.6–91.8% with six raters and 94.0–94.1% with 24; finite-interval availability was 99% and 87–88%. None met the combined qualification criterion. Automatic individual-rater bounds are withdrawn; `confint(fit, parm = "raters")` and `plot(fit, intervals = "normal")` retain explicitly requested approximations without implying corrected coverage. Bootstrap intervals remain an unqualified alternative, not the default. A separate saved-case review resolves all 53 Person-integration failures by higher-order refitting with unchanged tolerances and adds explicit stability/refit guidance. This does not revise the original coverage study or establish a universally adequate order. An independent fixed-calibration posterior comparison now supports all 48 selected conditional Person EAPs/SDs and 96 interval endpoints at the stated numerical tolerances on twelve full/reduced rosters. Original raw-quantile precision limits and the saved-draw CDF refinement remain distinct; this is not coverage qualification. The local calibration-likelihood approximation now has bounded independent support at 128 distinct parameter points in eight saved datasets, with a maximum .0071-log-likelihood error allowance against the .05 tolerance. This does not establish absolute likelihood normalization, full SD-profile accuracy or boundary inference. Calibration bounds are now omitted by default and explicitly requested through `confint(..., parm = "calibration")` or the summary/results options. Rater-SD profiles remain separate explicit approximations; no regular variance interval is added. Earlier known-population pilots remain evidence for their own scope. PCM, anchors and broader populations/designs remain beyond this bounded route. |
| Testlet MFRM | A local RSM fit, conditional continuous Person scoring, plots, saved results and tutorial are implemented for explicit non-overlapping memberships, estimated normal ability variance and a common local variance. Explicit known ability SD retains the earlier fixed-population model; old saved fits retain N(0,1). Independent likelihood/gradient and continuous-interval checks support the new calculation, including zero-variance handling. Matched ordinary-model facet, predictive and conditional Person comparisons, descriptive diagnostics and model-aware Wright/fit-pathway displays are implemented locally. A 480-dataset estimated-population comparison is complete, with original outcomes retained separately from a verified fourteen-case numerical start-selection repair. The repaired replay supports conditional coverage in the two larger balanced conditions; small/sparse conditions and regular calibration intervals remain inconclusive. Dependence modeling improves coverage relative to ordinary RSM but increases EAP mean-square error in two balanced conditions. Earlier fixed-population evidence retains its own scope. A new executed task/criterion tutorial compares fixed-budget model-conditional precision and unequal-block score sensitivity, while distinguishing halo hypotheses, task-specific variance and policy weighting. This completes an application example, not statistical qualification or a heterogeneous-variance extension. Default calibration bounds are now omitted; explicit normal approximations preserve numerical/boundary guards and the selected level through plots and saved reports. |
| Multidimensional MFRM | Deferred at the user's request. Dimension membership, loading constraints, latent covariance and scale remain undecided. It is not a 0.2.4 completion requirement. |
| Broader G-theory structures | Existing one/two-facet crossed and selected nested designs are retained. A runnable fixed-task-set / sampled-rater example uses existing fixed score components, with rater-count plots and direct weighted-score checks for complete and incomplete sources. A general arbitrary-design solver is later work, not a claim attached to that example. |

No method can guarantee nominal coverage or diagnostic accuracy for arbitrary
unidentified designs, distributions and unspecified missingness mechanisms.
The statistical work will state its conditions and evaluate performance under
those conditions; code execution and one successful simulation are insufficient.
Missing scores on assigned ratings remain distinct from unassigned combinations.
A general response-imputation route must preserve that distinction and the
measurement reference used to combine downstream estimates.

## Remaining work for the current source

This section preserves the **rc.6 completion record**, including its original
remaining-work table. It is not the active order for the changed working tree.
The approved workflows in
[Focus for 0.2.4](#focus-for-024) remain included, including the additional
GPCM inference targets below. A closed investigation is not necessarily a
validated method: a negative result may establish a stated limitation, but
cannot justify an inaccurate advertised output. Any proposed removal of an
agreed feature must be identified as a scope change.

A reproduced error in a supported result must be repaired. An implemented
feature with insufficient evidence remains verification work. A failure can
be retained as a limitation only if its status, estimates, unavailable bounds
and interpretation are consistent throughout the supported user workflow.
Providing a finite answer for every dataset is not a release condition.
Research extensions already excluded from the scope do not hold up these repairs.

| Remaining work | Classification | Current evidence | Condition for completion |
| --- | --- | --- | --- |
| Common-MML covariance consumers: fixed-facet intervals, practical equivalence, MI pooling, diagnostics and comparisons | Focused impact review and propagation repair completed (M1/M4); statistical qualification remains separate | Source tracing and RSM/PCM contract tests cover successful and failed information. Cautions now reach fixed-facet/equivalence/pooled tables and plots; MI retains imputation identity, fixed-facet reports retain warnings, diagnostic delta outputs and quadrature reviews retain details. | The branch tests inject reviewed covariance metadata into eligible fits; they do not estimate real-data frequency or coverage. Recheck only if the information contract changes. Carry these outputs into the planned current-source workflow integration and independent qualification. |
| Fixed estimator and output qualification | Engineering checks and per-family release dispositions completed (M2) | [Confirmation protocol](inst/validation/gpcm-inference-confirmation-protocol-0.2.4.md) fixes the source pair, targets, rules, seeds and resource stops. All 32 engineering arm/cell jobs pass independent probability, NLL, derivative and target checks. Failure-aware summaries and isolated source loading were checked. The main-phase timing projection exceeds its 24-hour envelope; no confirmation data have been generated. | Use the release dispositions below. The numerical and representative output checks are complete; retained APIs supply approximations, not newly established coverage guarantees. New performance claims need matching evidence. Preserve protocol versions and failure accounting; the original broad grid is not mandatory. |
| Independent evidence for changed inference | Numerical review and release disposition complete; stronger performance claims unqualified (M2/M3) | Earlier multi-dataset studies and the saved-case audits are available. The 499-refit pilot is one dataset, not independent coverage evidence. Cases used to develop the repair are regression cases, not a holdout. | Use the target-specific evidence map, not mandatory completion of protocol v1. If asserting a new sampling-performance or repair-benefit claim, supply matching independent evidence and MC uncertainty; pair comparator arms only where the question requires them. Historical replay is not a holdout. Keep ordinary intervals, standardized differences, curves and bootstrap/LRT qualification distinct; resolve adverse results without changing thresholds to pass. |
| Extreme slopes, empty categories and boundary approaches | Representative safe-failure/output checks complete (M2/M4); broader boundary inference not qualified | The saved steep-slope case, eleven saved zero-boundary candidates and an empty-category representative remain ineligible. Actual weak, unavailable and unbounded interval examples now retain states/reasons through figures, Markdown, CSV and RDS. This is representative display evidence, not every boundary case or every presentation route. | Retain the checked summaries, intervals/comparisons, plots, reports and starting-value/integration guidance in M5. A reproduced incorrect admitted result still requires repair. Formal boundary estimation needs its own specified target and evidence; a new universal solver is not required for this release. |
| Reconcile changed bootstrap results | Provenance reconciliation and output repair complete (M2/M4) | The original object has 408 admitted / 91 unresolved; the assembled category-case reanalysis has 470 / 29. Seeds and all 62 replaced rows match their retained records. Two later finite repairs remain separate. Reanalysis history now follows print, intervals and report tables. | Neither saved object is a full run of the current estimator. Preserve both unchanged; do not claim 472 accepted or current-procedure bootstrap performance. A complete new bootstrap is needed only to make a corresponding new performance claim; repeated-dataset coverage remains unqualified. |
| Assessment-to-feedback and planning workflows | Current-source educational walkthrough complete; author integration review (M4) | The 282-rating educational example runs from rubric/assignment review through RSM MML, diagnostics, feedback, figures, report/export and RDS reload. Saved precision now reaches result/report decisions correctly. Existing PCA/group/MI and complete/incomplete D-study outputs retain matching summaries and plot data without refitting. Earlier extended-model evidence is retained. | Preserve the explicit category choice, session-dependent screening explanation and dedicated branch routes during final integration. This is author review, not a novice-reader study, coverage validation or fresh qualification of every model/option. See the assessment-workflow record below. |
| Current-source help and local archive | Complete locally (M5) | The September 26 archive has executed/replayed updates for three articles, twelve unchanged article outputs, 72 described figures and a verified 15-entry vignette index. The full test findings and focused repairs are reconciled; the final archive passes its applicable checks with one maintainer/update-frequency NOTE. | Preserve the frozen source and its evidence. Any later runtime change needs impact-specific checks; the earlier CI/Windows snapshots do not validate this archive. |
| Successor CI, Windows and publication | Candidate handoff (M6) and planned submission checks complete | `6f541bfa` passes all five CI environments, including Windows/R-release. Matching website deployment and rc.6 assets are verified. Both current Win-builder logs are reviewed: zero errors/warnings and one maintainer/update-frequency NOTE each. URL and CRAN reverse-dependency checks are complete. | Settle the final release/submission decision using the checked source/archive. Earlier Win-builder results retain their original source identity. CRAN submission and acceptance remain distinct. |

The claim/evidence mapping is now recorded in the
[retained-claims review](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--map-retained-claims-to-evidence-and-audit-changed-admissions).
The 30.54-hour, 8,000-dataset/two-arm plan is retained as an unexecuted protocol,
not a mandatory release deliverable. No source, margin or result was silently
changed to reduce its cost.

A current-source replay of 17 saved historical cases gives exact endpoint
agreement for ten eligible controls and keeps five originally unavailable
cases unavailable. Two formerly unavailable cases now receive cautioned
intervals. Their likelihood/integration checks agree with independent reference
calculations. A failed direct cross-coordinate SE comparison was explained by
the nonzero-gradient term in the Hessian transformation, with the original
failure retained. This is numerical evidence, not fresh coverage evidence or
proof that all historical optimizer results remain unchanged.

The earlier difference evidence concerned relative slopes and different
contrasts. A further [saved-fit target reanalysis](inst/validation/gpcm-saved-target-reanalysis-0.2.4.md)
now evaluates the two standardized differences and explicit probability and
information grids on all 800 historical fits. It uses matching saved generating
truths and current interval calculations, without refitting. This supplies
target-specific retrospective evidence, not an independent current-estimator
confirmation or bootstrap coverage. The 400 historical null LRT pairs remain
part of this 800-fit corpus, not extra independent evidence.

The representative interval-display/replay review is complete, with repairs
for invisible unavailable curve intervals, clipped cautions and missing
Markdown status/reasons. See the
[display review](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--preserve-unavailable-and-weak-inference-through-figures-and-reports).
Only plotting and report composition changed; numerical evidence is retained.

The **current-source assessment-to-feedback walkthrough is complete** at its
stated educational-example scope. It exposed and repaired a dropped precision
assessment in ordinary result/report decisions; the supported, unsupported and
unreviewed states remain distinct, and fit restrictions still take precedence.
The guide now connects category policy, screening settings, archived results
and the optional feature/MI/G/D routes. See the
[assessment-workflow record](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--complete-the-educational-assessment-to-feedback-walkthrough).
Do not repeat this walkthrough or the completed display review without a
relevant change or failure.

The **GPCM probability-interval evidence** informs the release dispositions
below. The saved-fit reanalysis finished in 185.7 seconds without generating data or optimizing models. In the
small incomplete unequal-rater-slope condition, the nominal-95% sandwich
Bonferroni family covered 82/98 available datasets (83.7%, MC interval
74.8–90.4%), or 82/100 planned datasets. This adverse result is retained in the
public guide; multiplicity adjustment is not a remedy for a poor marginal
approximation. Standardized-difference and information results have their own
tables and counts of planned and available datasets. This does not establish that all current-estimator
fits behave the same way or that bootstrap intervals solve the problem.

The [matched-refit attribution check](inst/validation/gpcm-probability-refit-attribution-0.2.4.md)
is now complete. All 100 datasets in that adverse cell were refitted under the
current numerical implementation with ordinary initialization and unchanged
settings. Objectives, parameters, probabilities and interval endpoints are
exactly unchanged; family availability and coverage also remain unchanged.
The computation took 479.5 seconds. An independent analytic probability
Jacobian/full-covariance propagation agrees with public output on the two
prespecified refits (maximum endpoint error below 2e-9). The optimizer-version
difference does not explain this cell's shortfall. This is not proof of global
optimality, integration accuracy, or approximation error as the only cause.

Close this attribution task; do not repeat the same 100 fits or launch the
broad grid to seek a better-looking coverage result. Printing and default
curve subtitles now identify approximate intervals; numerical availability
is not a nominal-coverage certification. Keep the API and its calculated
values without arbitrary sample-size refusal or outcome-tuned widening.

### Release dispositions for GPCM inference

These decisions settle what the retained APIs mean in 0.2.4. They do not turn
an adverse result into successful statistical qualification. All agreed APIs
remain included; no entire workflow is deferred or removed. The release
provides explicitly approximate inference, with numerical checks and the
following target-specific evidence, rather than a new finite-sample guarantee.

| Retained family | Disposition for 0.2.4 | Claim not established |
| --- | --- | --- |
| Relative/standardized slopes; model and independent-cluster sandwich covariance | Retain approximate log-Wald intervals with full joint covariance, numerical cautions and unavailable outcomes. Reuse independent calculations and historical design-specific sampling evidence; changed numerical branches have separate regression evidence. | Uniform nominal coverage, general misspecification robustness, or fresh sampling qualification of every changed branch. |
| Ratios and differences | Retain declared-scale, covariance-aware delta intervals and finite-family Bonferroni adjustment. Standardized differences have the separate 800-fit retrospective evaluation. | Coverage for arbitrary contrasts or designs, or transfer of relative-contrast performance to a different scale. |
| Probability curves | Retain fixed-native-ability logit-delta intervals as approximate calibration uncertainty. Numerical transformations are checked; all 100 matched current refits reproduce the adverse cell. | Nominal 95% family coverage: the observed sandwich Bonferroni rate is 82/98 available, with MC bounds 74.8–90.4%, or 82/100 planned. This claim is rejected for the evaluated procedure/condition; no remedy is asserted. |
| Information curves | Retain log-delta intervals for information per rating, with their own numerical and retrospective sampling evidence. | Total-test information uncertainty, Person-score uncertainty or a continuous simultaneous band. |
| PCM/GPCM LRT and local IC | Retain asymptotic testing and likelihood-based ranking only after their separate matching, nesting, counting and numerical checks. The 400 historical null pairs remain a subset of the 800-fit corpus. | Finite-sample test calibration for arbitrary sparse designs, automatic scoring-policy selection or proof of global maximization. |
| Basic bootstrap slopes / PCM-null bootstrap LRT | Retain fitted-model simulation, correct basic quantiles / null-test counting and unresolved-outcome bounds. Original and selected-update results remain distinguishable through saved output. | Repeated-dataset coverage/Type I error, a current-procedure performance estimate from the assembled pilot, or a remedy for probability-curve undercoverage. |

The bootstrap provenance question is closed by retaining the original 408/91
run and the separately labelled 470/29 selected-update analysis. The later
two repaired finite cases have not been spliced into either object. Checks
match all seeds and all 62 replacement vectors to saved records, with unchanged
input-file hashes. The reporting repair preserves selected-update history
through interval cautions, printing and result/report tables. It changes no
draw, interval endpoint, estimation rule or acceptance decision.

The probability nominal-coverage claim and bootstrap repeated-dataset accuracy
remain unresolved statistical capabilities, not hidden release achievements.
Improved procedures require a justified method and independent evaluation;
they are not silently claimed by this release decision. The broad grid and
nested study remain unexecuted. General guarantees were already outside the
stated scope; no agreed API is being moved to another release.

**M5 and M6 candidate publication are complete for rc.6.** The final
archive SHA256 is `0f1f21c042512318a3b3c8ffbce246bcdab21db1d3dc2dce2cf5e091c58155e1`.
The initial full suite passed 23,290 expectations and found three failures;
these are repaired, with 516 focused expectations passing. The final archive
passes its applicable check with 0 errors, 0 warnings and one NOTE for maintainer
information/update frequency. Examples and manuals passed initially and were
not repeated. The final delta is limited to input routing, two test files,
NEWS/date and the restored vignette index; numerical core and article bytes
are unchanged. Source documentation and fresh-session checks complement the
installed suite; 32 repository-research skips retain their existing scope.

Do not repeat the 100 matched refits, 800-fit reanalysis or full suite without
a relevant change or failure. The five-platform run and website deployment
were separately authorized after local completion. Tagged release publication,
Win-builder upload and CRAN submission remain separate. Probability undercoverage and unqualified bootstrap sampling claims
remain as stated in the release dispositions.

The common-MML consumer repair remains supported by its focused checks; those
checks do not establish weak-information frequency or sampling coverage. See
the [consumer-review record](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--preserve-common-mml-cautions-across-consumers).
The steep-slope case is not an automatic next optimization project.

Before an independent study starts, specify each question, generating model,
assignment/missingness mechanism, target and old/new comparator. Fix seeds not
used to develop the repair, replication/Monte Carlo precision, practical
accuracy and performance criteria, and a resource/stop budget. Separate
conditional coverage among available intervals from covered-and-returned
frequency over all planned datasets; report failure and width distributions.
A bootstrap study additionally needs a fixed replication/failure-handling
rule. Numerical tolerances do not substitute for these statistical decisions.
If an implementation defect changes the protocol, retain the earlier results
and identify which evidence needs renewal rather than silently reusing it.

The local endpoint is a coherent current source with the included outcomes
supported at their declared level, warnings/refusals preserved across outputs,
and a checked installable archive. A practical limitation is not made complete
by adding a warning if the output still contradicts its advertised target.
Conversely, universal coverage, convergence for every sparse dataset,
multidimensional MFRM, arbitrary G-theory structures, new GPCM slope families
and full cross-software equivalence are not hidden prerequisites. Their
existing exclusions are unchanged; this review adds no new deferral.


## GPCM inference follow-up after local integration

The user approved implementation of the additional inference targets found in
the review. The scope below belongs to the current 0.2.4 local source. Earlier
archive checks are historical evidence for their own source, not checks of
these additions. Default relative/model intervals remain compatible.

| User outcome | Implemented route | Qualification and completion boundary |
| --- | --- | --- |
| Preserve an explicit population model while checking quadrature | `mml_quadrature_sensitivity()` replays formulas, person covariates, factor coding and the same canonical design; slope endpoints and eligibility are compared. | Intercept-only and categorical-covariate refits are verified. Matched PCM/GPCM decisions must be compared on common grids. No universal grid cutoff is selected. |
| Use one information calculation for IC/LRT and intervals | Shared joint observed information with a configurable dense-matrix workspace budget. | A 120-Person, 27-criterion model with 83 free coordinates returned all 27 slope intervals and passed the IC solution check. This is one numerical case, not a general capacity guarantee; the workspace estimate excludes likelihood arrays and other process memory. |
| Quantify standardized slopes and specified comparisons | `confint()` supports population-SD-standardized slopes, named slope ratios/differences, corresponding Wald tests and Bonferroni adjustment. | Includes the full scale covariance and cross terms. With covariates, standardized means residual-population-SD scaling. Adjustment covers the requested finite family. |
| Assess working-model uncertainty with independent clusters | `method = "sandwich"`, default Person clusters or an explicit complete larger-cluster map. | Requires sufficient score-vector rank and many independent clusters. It cannot remove estimation bias or repair informative assignment. Richardson derivatives independently agree with the Person score calculation. |
| Use a fitted-model simulation alternative | `bootstrap_mfrm_gpcm()` and saved-result `confint()` implement basic parametric bootstrap intervals or a matched PCM/GPCM bootstrap LRT. | Every planned trial and failure is retained; unresolved draws bound intervals/p-values. Small runs verify mechanics only. This bootstrap route is separate from the experimental profile method; a general small-sample coverage/size guarantee is not included. |
| Show uncertainty in fitted curves | `mfrm_curve_intervals()` and its plot method supply category probability and per-rating information intervals. | Known native-scale ability grid, full calibration covariance, optional sandwich/Bonferroni, color plus line type and removable annotations. A finite-grid adjustment is not a continuous simultaneous band. |
| Reuse selected inference in feedback and reporting | Saved slope/curve intervals and bootstrap results connect to `apa_table()`, `plot()`, `plot_data()`, `as_ggplot()` and named `mfrm_results(intervals = ...)` routes. Reports and exports retain target, level, method, multiplicity, cluster settings and unresolved outcomes. | Source identity is checked; replay reloads saved results. Wright/Pathway location and fit displays retain their own targets. Discrimination intervals do not classify rater quality or choose scoring weights. |
| Carry RSM/PCM fixed-facet intervals through the same reporting workflow | Saved `mfrm_facet_intervals()` results connect to APA tables, named `facet_` result plots, base/ggplot customization, reports and exported replay. Help and the RSM/PCM example are updated and executed. | This is M4 integration, not a change of estimator, covariance or coverage qualification. Selected interval methods do not replace ordinary Wright/Pathway uncertainty. |

At that checkpoint, the completion order used the
[source register](#remaining-work-for-the-current-source). The current tree
instead follows [Active development milestones](#active-development-milestones).
The historical sequence was:
retain the completed common-MML consumer checks and registered protocol,
reuse the completed engineering, changed-inference and supported-workflow
reviews, M5 archive checks and the completed five-platform checks and candidate
publication under M6. A single dataset with many bootstrap refits
is not a repeated-dataset coverage study. Changing the point estimator requires
paired evidence of benefit and a documented target change; it is not an automatic
response to one low-coverage cell.

The release dispositions above settle the retained approximate APIs; stronger
statistical performance claims remain unqualified. The focused M4 checks now
cover agreement among the changed outputs, help, NEWS and retained evidence.
The September 26 successor completes M5 locally, as recorded above. The saved-inference follow-up
also corrects displayed replay code in summaries/HTML/viewer output so it saves
and reloads the complete result; reconstructing from the fit alone would omit
attached inference. Starter export indexes now expose the saved RSM/PCM and
GPCM inference figures with descriptions. The changed paths have focused
regression evidence, without repeating the numerical studies. The September 26
M5 record supplies the new source identity and applicable integrated checks.
M6 requires matching platform checks and publication; those gates are not
inferred from one successful simulation. The September 27 one-slope profile
implementation has its own experimental scope above; profile coverage, JML
inference, additional slope structures and cross-software joint-interval
equivalence remain separate work. Bootstrap remains the simulation alternative.

### Evidence available for the remaining decisions

Earlier studies cover relative/standardized slopes, model/sandwich intervals
and selected assignment/sample-size contrasts under declared normal-population
conditions. They include low coverage in a small incomplete condition and wide
intervals; neither sandwich estimation nor bootstrap is qualified as a universal
remedy. Those results apply to their original estimator and admission rules.
See the [inference-extension record](inst/validation/claim-reconciliation-0.2.4.md#september-24-gpcm-inference-extensions)
and [design/reporting follow-up](inst/validation/claim-reconciliation-0.2.4.md#september-24-gpcm-inference-reporting-and-design-follow-up).

The saved 499-refit pilot and its selected replays retain all failures. The
recorded singleton-only change raises availability from 408 to 470 while all
three standardized 95% basic intervals remain zero to infinity. Later audits
separate unused categories, zero-discrimination approaches, premature stopping
and severe integration sensitivity. This is one-dataset diagnostic evidence,
not repeated-dataset coverage. The original pilot has not been rewritten with
the later repaired estimates.

Two premature-stopping cases now recover better finite solutions through the
native API, with agreement at 61/101 quadrature nodes. A remaining ill-conditioned
information case now passes numerical refinement without an eigenvalue floor,
with explicit cautions through the GPCM output routes. Its weakest standardized
slope still has a 95% log-Wald interval around 1e-25 to 1e21. Numerical verification
does not establish useful precision or boundary coverage. The saved boundary
candidates remain ineligible. Details and reusable source-specific checks are
in the [optimizer record](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--recover-finite-gpcm-solutions-before-relaxing-inference-rules)
and [information review](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--verify-weak-mml-information-instead-of-blanket-exclusion).

These completed repairs close the reproduced numerical problems under their
tested conditions. The subsequent common-MML consumer review repairs warning
propagation. Those repairs alone did not establish sampling qualification or
workflow completion; the later release dispositions, representative output
checks and M5 integration above supply the separate release decisions.
M6 candidate publication is verified for rc.6. The earlier sequence of repeated case investigations is
superseded by that register. A new general boundary estimator is not inferred
from finding an unavailable interval; the demonstrated refusal/output behavior
and remaining statistical limits remain in force.

## Rater feedback across application areas

The first application is educational performance assessment, with feedback
to raters as a central use. The APIs should also support appropriately modeled
ratings in music, psychology, health-professions education and judged sports.
Column names identify roles such as the rated unit, judge, task, criterion and
occasion. Application-specific score maps, model assumptions and reference
constraints must remain explicit. Repeated performances by one person do not
become independent merely by giving each performance a new ID.

Music assessment provides evidence that linking design and model fit affect
the interpretation of rater-adjusted results
([Wind, Engelhard, and Wesolowski, 2016](https://doi.org/10.1080/10627197.2016.1236676)).
A figure-skating study illustrates detailed feedback to individual judges
([Looney, 2004](https://pubmed.ncbi.nlm.nih.gov/14757990/)). These applications
motivate examples and validation questions; they do not establish support for
every scoring system or every model used in those papers. Preserve individual
ordered ratings rather than substituting weighted competition totals.

The feedback workflow should connect rater coverage and overlap, signed
severity with its reference and uncertainty, category use, fit and selected
rating discrepancies. Existing diagnostics and plots provide the components.
Local refinement now preserves unavailable diagnostics, screening settings
and fit restrictions across dashboard tables, plots and exported reports;
the README connects coverage, category use and case review using existing
APIs. A single 5,000-person rotating-rater probe completed and exposed costly
pairwise diagnostic assembly; that path now runs faster with identical outputs
on the saved fit. A guarded final optimizer restart subsequently resolved the
terminal-gradient review in this workload without relaxing its tolerance;
OS memory use was also measured. A subsequent same-data integration review
found changes beyond the chosen numerical budgets at 31 points. One 61-point
refit followed by a 121-point evaluation met those movement budgets for facet
SEs, local parameter displacement and the selected person-score probes.
This is evidence for that workload, not a sufficient grid for all data or a
guarantee of interval coverage or capacity. A small paired simulation pilot
now supplies preliminary rater-interval evidence for complete, rotating-pair
and weakly linked assignments under a matching response/population model.
Remaining evaluations are selected through M2 for the retained release
claims; this historical workload is not an automatic queue for more pilots.
Severity, inconsistency and differential functioning answer different questions. Screening flags
support rubric review and additional common ratings, not automatic rater
exclusion or a demonstrated effect of training.

Stress evaluation will distinguish computational capacity from the accuracy
of rater feedback. At comparable rating budgets, vary common linking sets,
overlapping panels, weak bridges and disconnected assignments, then examine
rater precision and false flags as well as person scores. Separate planned
nonassignment from missing assigned ratings and selective nonresponse.
Larger samples cannot repair a design that does not identify the intended
contrast. Design-dependent sensitivity is documented for sparse rater-bias
screening ([Wind and Ge, 2021](https://doi.org/10.1177/0013164420988108)).

Increase person counts, facet counts and response-pattern length separately,
recording elapsed time, memory, convergence, unavailable results and numerical
agreement. Comparisons with TAM or ConQuest require a shared model and
estimand; their capacity is not a demonstrated capacity of mfrmr. Existing
tests and stress results will be reused where applicable, with additional
work directed at the remaining feedback and scale questions.

## Generalizability theory

The planning question is how tasks, raters or score weights affect the
dependability of a score used for ranking or for absolute decisions. For
component and composite scores, between-score covariances matter; averaging
separate reliability coefficients does not answer the composite question.

The functions `mfrm_multivariate_gstudy()` and
`mfrm_multivariate_d_study()` provide the following scope:

| Part | Implemented scope | Interpretation boundary |
| --- | --- | --- |
| G-study model | One or two named random facets: crossed, or one nested within the other with persons crossed. Score components are fixed, with one observation per retained cell. ANOVA handles complete balanced data; MINQUE(0) handles identifiable incomplete or unequal configurations. | Identities, including parent/child pairs, must be shared across persons and scores. Naming an Occasion facet does not model growth. Fixed facets, nesting within persons and partially shared identities are unsupported. |
| Covariance components | Three components for one facet; seven for two crossed facets; five for Person-by-(Child-within-Parent). Raw negative or indefinite estimates are retained. | Highest-order interaction and within-cell error are combined. Numerical rank and covariance admissibility do not establish estimation precision. |
| D-study | Future complete balanced scenarios preserving the crossed/nested structure, original scores, named weighted composites and signed differences, with G/Phi and SEMs. | Incomplete or unequal source designs require an explicit future grid. Nested child counts are per parent, not total pool sizes. Projections do not estimate reliability of the sparse roster; unequal future allocations are unsupported. |
| Output | Metric-specific availability, component diagnostics, base plots, ggplot conversion for point projections and exact plotted values. | A non-PSD component does not automatically suppress every metric. Calculability does not validate the whole covariance model. No automatic design recommendation is provided. |
| Prespecified plan differences | `mfrm_multivariate_d_compare()` supplies approximate paired-delta intervals and base plots for two common random facets, including incomplete MINQUE(0) sources, when `assumption = "normal"` is explicit. | These are pointwise normal-theory approximations. One-facet, nonnormal-robust, nested/fixed-facet and simultaneous intervals, adaptive weight/plan selection and informative-missingness correction remain unsupported. |

The existing `mfrm_generalizability()` / `mfrm_d_study()` main-effects workflow
remains separate. Neither workflow estimates reliability on the MFRM latent
scale or pass/fail classification accuracy. Explicit missing-row omission
records exclusions; it does not correct selective assignment or nonresponse.

The implemented workflows answer the following questions within their stated
scope. Integration preserves these paths; extensions require a named need and
evidence for the additional claim.

| User question | Available in the candidate | Integration requirement or separate extension |
| --- | --- | --- |
| Can I use the current point projections correctly? | Data → G-study → future scenarios/composites → tables and plots, with saved-result reuse. | Preserve metric-specific omissions, score units, weights and limitations in displayed and saved output. Changing only future counts or score weights reuses the G-study. |
| How uncertain is the improvement between two feasible plans? | `mfrm_multivariate_d_compare()` supplies approximate paired-delta intervals for prespecified G/Phi/SEM differences under normal random effects with two crossed facets. | Preserve the sampling target, explicit assumption and unavailable-interval reasons. Existing bounded checks do not qualify nonnormal-robust, nested or simultaneous intervals; these remain separate extensions. |
| Does a sparse source design estimate the quantities needed for planning? | MINQUE(0) estimates separable covariance components from supported incomplete designs; D-studies project explicit complete future plans. | Reuse existing recovery evidence. Investigate a named unresolved allocation, distribution or missingness condition only when needed for the intended use. Rank, connectivity or a returned coefficient alone cannot establish precision or correct selective missingness. |
| Does my assessment require task-specific rater teams? | Person-by-(Child-within-Parent) point estimation and projections, with independent QR/kernel and projection checks. | Preserve the meaning of child counts per parent. Other nesting, partly shared raters and nested intervals remain separate extensions; current checks do not establish recovery for arbitrary sparse allocations. |

For planning uncertainty, preserve dependence between scenarios and composites;
separate intervals cannot simply be treated as uncertainty in their difference.
Distinguish uncertainty for a prespecified comparison from inference after
selecting the largest estimate. Evaluate how often a plan choice differs and
how much true dependability it loses; these are different criteria. The paired
comparison API now supplies approximate pointwise intervals for two crossed facets
under an explicit normal random-effects assumption. Existing saved-result
comparisons and targeted distribution checks support this bounded method;
they do not establish robustness across score distributions and designs.

The implemented uncertainty scope uses the common-facet model and prespecified
complete future plans. Automatic weight selection, optimal sparse assignments,
simultaneous guarantees and informative-missingness correction are outside
that scope. When the assumptions or supported design do not match the intended
use, do not interpret the returned approximation as a qualified interval.
Point projections retain their own model and design requirements.
Equal rating counts need not imply equal examinee burden or cost.

See [the G-theory workflow](README.md#multivariate-g-theory). The existing
GENOVA comparisons remain useful checks of formulas and negative-component
conventions; full software equivalence is not a development or release goal.

## External features, grouping, and missing values

The implemented workflow reviews one row per Person, rater or task
and clusters those entities separately. Gower/PAM supports mixed features;
Gower with average or complete linkage supplies hierarchical partitions and
dendrograms. Profiles, silhouettes and setting comparisons help users interpret
results without identifying groups as ability levels, rater quality or latent
measurement classes.

`mfrm_cluster_imputed()` accepts user-fitted `mice` completions and an explicit
set of eligible missing feature cells. Observed values, IDs, feature types,
missingness reasons and imputation diagnostics are preserved. Co-membership
across completions describes sensitivity to that model; it is not Rubin pooling,
sampling stability or a posterior probability of class membership.

`mfrm_cluster_compare()` compares group counts, feature selections, weights and
methods on the same entities. Imputed comparisons use paired completions from
the same retained model. Removing a clustering feature does not remove it from
the imputation model. No setting or consensus partition is selected automatically.

| User need | Current workflow or condition for an extension |
| --- | --- |
| Use the existing descriptive workflow | The executable tutorial connects ID/omission accounting, profiles, plots and paired imputation comparisons. Preserve these paths during integration and reuse existing stress evidence within its tested workload; input caps are not runtime or memory guarantees. |
| Relate person, rater and task groups | Preserve separate feature tables and join classifications to planned/observed ratings by ID. Descriptive relationships must not become causal group effects or a joint clustering model. |
| Use numeric PCA/k-means | The local `mfrm_pca()` / `mfrm_cluster_kmeans()` route retains explicit standardization, squared-distance weights, retained components and initialization. Paired imputation comparisons and original-unit profiles are available; validate selected features and interpretation of the transformed space. |
| Make claims about stable groups or classify new entities | Specify the sampling or prediction target separately from imputation sensitivity. Evaluate it before adding a stability statistic or assignment API. |

Missing external attributes, unassigned ratings and missing assigned responses
remain distinct. The assigned-response MI workflow is implemented locally and
included in the 0.2.4 plan. It preserves rating structure and combines eligible
downstream estimates and uncertainty on a common scale. Its joint-RSM example and paired MAR/MNAR comparison now support the stated
bounded MAR use while retaining severe MNAR bias and undercoverage. Supplied
imputation models still require substantive justification and sensitivity
review; filling every empty cell or labeling missingness MAR is not a correction.
Ward linkage, pooled trees, joint cross-facet imputation and pooled inferential
group effects are outside the present external-feature workflow.

See [external-feature examples](README.md#external-features-and-exploratory-groups)
and `vignette("mfrmr-external-features", package = "mfrmr")`.

## Rater assignment and anchors

Design support asks which allocation serves a declared Person or facet target
within total workload, per-rater workload and examinee-burden constraints.
The unit of cost must be explicit: a performance, a scored response and an
individual criterion rating need not have the same cost.

The current simulation API already supplies common linking Persons through
`sparse_linked`, balanced rotation, random subsets, empirical assignment profiles
and explicit Person-by-facet skeletons. `describe_mfrm_data()` can review the
planned/observed design before fitting; post-fit connectivity/network routes
add inspection. This is representation and diagnostic support, not comprehensive
estimator qualification or automatic assignment optimization.

An important correction to the recent JML evidence: its "sparse" and "unequal"
rosters omit Person-Rater-Criterion cells, but every Person is still rated by
both raters. The Person-Rater projection is fully crossed. The 400-dataset
order comparison therefore does not validate scarce common-person links,
multi-panel chains or random many-rater allocation. No fixed anchors were used.

The next allocation audit should use the following distinct families, reusing
existing generators/skeletons and earlier design records rather than creating
another general design API. First establish input, graph and model-rank behavior;
select subsequent statistical comparisons from the estimation decision they
can change, without automatically launching a factorial grid.

| Assignment family | Existing representation | Qualification still needed |
| --- | --- | --- |
| Fully crossed reference | `assignment = "crossed"` | Named estimator/target baseline at the chosen workload. |
| Common examinees across all raters | `sparse_linked` with declared `link_persons` and all raters on those persons | Number and composition of links, critical-person loss, population differences and subgroup precision. Common persons are not fixed ability anchors. |
| Distributed overlapping subsets | `rotating` or a balanced `sparse_linked` assignment | Ring/chain bottlenecks and critical-link loss at matched rating cost; two-rater population cases are insufficient. |
| Random subsets | `sparse_linked` with `assignment_mode = "random"` | Retain disconnected draws and workload imbalance; distinguish random allocation from ability-dependent allocation. Random assignment is not a guarantee of connection. |
| Common rater bridging panels | Explicit `design_skeleton` | Asymmetric leverage, loss/misfit of the bridge rater, and comparison with distributed links at the same cost. |
| Task-specific spiral or nested assignment | Explicit `design_skeleton` | Person/Rater/Task projections and full-model rank; ordinary rotation uses all criteria and is not a general spiral constructor. Graph connection alone can coexist with confounded model terms. |
| Disconnected or nearly disconnected panels | Explicit skeleton or loss of a declared critical link | Detect nonidentification and loss of usable precision. Population assumptions or fixed anchors must not be described as observed empirical links. |

Treat supplied fixed anchors as a separate axis: none, known values, estimated
calibration values and drift/error, with matching conditional or propagated
uncertainty. Treat missing assigned ratings separately from unassigned cells.
Do not confuse the older typed anchor catalog, prospective network plans and
completed fits when reporting coverage of this matrix. The existing
[incomplete-design gap audit](inst/validation/rater-anchor-incomplete-design-refinement-record-0.2.4.md)
already identifies missing equal-cost topology and critical-link-loss comparisons.
Eckes's Table 9.1 was checked in the user's 2023 ePDF edition, Section 9.1,
printed pp. 151--155 (PDF pages 153--157); this is a targeted page review, not
a new claim to have reviewed the whole book. The linking guide now provides
three executable examples and distinguishes observed links from fixed anchors.

A later assignment extension should reuse existing assignment and coverage review,
retain disconnected/failed cases and subgroup disadvantages, and compare
estimation error or qualified interval performance for a named target.
Connectivity, balanced workload and an anchor percentage alone cannot select
a design. Facet precision cannot substitute for Person-difference precision.

Direct anchors, group anchors and estimated linking have different uncertainty.
A future comparison that refits models must repeat any estimated linking or
selection and preserve covariance between compared results. Design evaluation
for observed fixed raters can proceed within its own supported model; design
for replacement raters requires the matching random-rater prediction model.

## Random-effects MFRM and testlet covariance

This is a requested model-extension track for generalization beyond observed raters:
how uncertain is a Person comparison when different raters are sampled?
Current fixed-facet MML, post-fit shrinkage and observed-score G-theory do not
jointly estimate a random-facet MFRM.

The local implementation uses one observed scale, unit weights,
adjacent-category RSM probabilities, one random-rater intercept shared across
Persons, fixed task/criterion effects and a normal Person distribution with
estimated variance by default. A known SD is an explicit restricted option.
Observed-rater intervals and replacement-rater probabilities at specified
abilities are distinct outputs. Conditional Person scoring has an independent
fixed-calibration posterior comparison on twelve full/reduced rosters. Its
bounded numerical support does not establish repeated-sampling coverage. A
separate eight-roster comparison now supports local calibration-likelihood
changes; it does not qualify an entire SD profile or variance boundaries.

The 800-dataset interval comparison did not qualify automatic individual-rater
normal bounds; these are now withheld by default. Explicit normal approximations
and bootstrap comparisons retain their limitations, unavailable refits and
variance boundaries. Availability, width and coverage must be assessed together;
bootstrap availability alone does not make it a qualified replacement.

Reuse an existing computation only when its probabilities, effect sharing,
constraints and target match. A cumulative-link ordinal model or a new random
effect integrated independently for every Person is a different model.
Person-local testlets require a different covariance structure. PCM, sampled
tasks, covariance and random slopes follow concrete needs after this initial
scope; they are not all prerequisites for a first bounded random-rater method.

The initial local testlet workflow now accepts explicit non-overlapping
membership within a Person, retains fixed facet roles and fits one common
normal local variance, with normal ability variance now estimated by default.
An explicit known ability SD retains a fixed-population analysis.
Nested-quadrature checks, continuous conditional Person
scoring, saved fits, plots and beginner guidance form a usable bounded route.
Scoring uses the complete supplied rating set, without implicitly appending
responses or conditioning on saved local modes. Prior-only and unavailable
rows remain explicit. Estimated variance boundaries withhold regular
calibration intervals; no regular variance interval is supplied.

Both local model routes now connect stored calibration and explicitly supplied
predictions or random-rater bootstrap intervals to the common results,
static-report and CSV/HTML/RDS export workflow. Reports preserve numerical
checks, missing-score accounting and interval limitations without refitting.
Model-aware comparison, scoring, descriptive diagnostics and figures are
implemented locally. The retained interval-output decision is implemented:
fixed-facet and step estimates/approximate SEs remain the default, with explicit
normal bounds and a separate approximate rater-SD profile. Numerical/boundary
restrictions and unavailable rows remain. M3/M4 cross-workflow source, output,
help and evidence reconciliation is complete for the retained 0.2.4 scope.
The interactive viewer and broader inferential
extensions have the separate scope stated above.

Calibration-aware Person uncertainty remains a later extension. For testlets,
the 480-dataset estimated-population study and numerical-selection repair now
support the stated conditional-coverage criterion in two larger balanced
conditions. Small/sparse conditions and regular calibration intervals remain
inconclusive; Person point estimates do not uniformly improve relative to
ordinary RSM. Numerical comparisons of additional memberships, categories and
unequal blocks do not establish their coverage. Retain earlier fixed-population
results under their original assumptions. Correlated or heterogeneous testlets
and joint shared-rater/testlet models remain separate extensions.

## Model scope

Joint multidimensional MFRM is deferred while the existing APIs, shared help,
visualization and reporting boundaries are consolidated. Dimension assignment,
loading constraints and covariance identification remain undecided; this
deferral does not imply implementation or completion.

| Area | Current restriction or trigger for further work |
| --- | --- |
| RSM/PCM | Preserve supported fitted-model workflows and fixed-normal MML portability. Local development also implements scoped JML-calibrated EAP portability with an explicitly post-hoc prior. Neither route propagates calibration uncertainty. |
| GPCM | The frozen rc.6 uses one shared slope/step owner; development MML also permits separate owners with one slope family. MML IC ranking, the matched PCM/GPCM LRT and approximate relative-slope intervals have separate checks; see G1--G3 below. Small incomplete designs retain coverage/precision limits. JML intervals and additional slope structures remain separate work. Development portable GPCM now has the qualified conditional scope above. |
| JML | Uncorrected estimates retain infinite extreme Persons; display replacements do not change primary estimates. Exploratory SEs do not qualify formal structural intervals. Scoped RSM/PCM and shared-owner GPCM portable EAP is implemented locally for eligible sources. Explicit experimental shared-owner profile-score adjustment is connected to fit/output APIs; conditional new-Person/portable EAP now uses distinct adjusted-equation checks. Residual-bias qualification, formal inference, automatic order selection, ML/WLE portability and separate-owner JML remain open. |
| Estimated populations and Fair Scores | Existing conditional/diagnostic output retains its limits. New population intervals, omnibus DRF inference or inferential FairZ methods require their own target and evidence. Inclusion requires a specific stage-2/3 scope decision; the new release order does not itself qualify them. |
| Multiple observed scales | Require explicit scale identifiers and a concrete separate-scale use case. Do not silently pool or link scales. Inclusion requires a specified model-extension scope. |

See [model and interpretation boundaries](README.md#model-and-interpretation-boundaries)
for the current output rules. Fixing a numerical or reporting defect does not
by itself qualify a new inferential claim.

## Before CRAN submission: interface and GPCM review

The September 24 review revises the earlier proposal to put API integration
entirely in 0.2.5. mfrmr 0.2.4 has not reached CRAN. Several confusing entry
points, including feature clustering, supplied-imputation review and the two
RSM extensions, are new relative to CRAN 0.2.3.1. Clarifying their canonical
names and behavior before first CRAN publication avoids teaching an interface
that immediately needs migration. GitHub candidates already exist, so those
calls and saved objects still need compatibility. Existing CRAN interfaces
such as `fit_mfrm()` require particular care.

The agreed submission scope now includes completing MML information-criterion
comparison, PCM/GPCM likelihood-ratio testing and relative-slope intervals for
the existing GPCM. These are 0.2.4 release requirements, not default 0.2.5
deferrals. They do not add another slope family or substantive ability
dimension. Naming changes and documentation of missing functionality do not
complete these requirements.

| Before submitting 0.2.4 | Completion condition | Work that is not bundled into it |
| --- | --- | --- |
| Clarify GPCM terminology and reconcile claims | Help, summaries, capability guidance and comparisons distinguish the one-facet slope/step structure from limits on estimation, uncertainty and scoring. Correct contradictory instructions. | Removing guards merely to stop using the word bounded. |
| Integrate the principal API routes | Complete the [API work package](#first-integration-work-package-api-names-arguments-and-help), prioritizing misleading new names and arguments/defaults that change the analysis. Adopt justified canonical names, preserve old calls and saved objects, and make help/examples/NEWS agree. | A cosmetic rename of every export, a new universal wrapper, or silent changes to defaults or `predict()` return values. |
| Complete existing-model GPCM inference | Implement and verify output-specific MML IC comparison, matched PCM/GPCM LRT and approximate relative-slope intervals. Eligible regular cases must return useful output; unstable, singular or incompatible cases must retain explicit reasons. Close G1--G3 below before final source freeze. | Deferring the three whole operations to 0.2.5, treating explanatory restrictions as implementation, or merely deleting guards. Universal coverage and a global-maximum theorem are not required. |
| Freeze and verify the revised candidate | Review the complete source/help/migration changes, check affected behavior, then verify one final archive and its applicable platform checks. Preserve the identity of the earlier Windows result. | Repeating the full suite after each wording edit or treating a previous archive's result as a check of new code. |

This trade-off accepts some release delay and a final candidate check to avoid
avoidable user confusion and a second migration immediately after release.
Unrestricted GPCM, separate slope/step structures and additional slope families
would change the statistical scope and remain separately admitted work. If the
eligibility review exposes an unreliable advertised result, repair or withdraw
that claim before submission; a limitation paragraph cannot make it correct.

The September 24 **retain-with-restrictions** proposal is superseded by the
user's instruction to resolve these three operations in 0.2.4. The earlier
disposition is not a final scope decision or evidence that the shared
eligibility policy is the right design.
The current implementation retains numerical fitting, curves,
conditional scoring and descriptive sensitivity comparisons
within their documented limits. The local IC implementation now separates
solution checks from interval/test readiness, including the estimated-population
PCM comparison. The matched PCM/GPCM LRT and approximate relative-slope
intervals are now implemented locally, with separate eligibility checks and
targeted sampling evidence. For the earlier G1--G3 snapshot, package integration
and source freeze were completed locally under M5; these results do not establish
universal finite-sample inference. The review found and repaired an actual
legacy-output defect: missing slope-eligibility metadata could expose ordinary
SEs and intervals. Current likelihood/solution checks are now required, and
diagnostic covariance values remain separate from qualified approximate bounds.

Statistical qualification is output-specific. IC comparison requires
its own common-likelihood, solution and integration evidence, whereas slope
intervals additionally require an uncertainty method and assessment of its
sampling behavior. Neither output waits for all proposed GPCM extensions.
That earlier source reconciled the principal API choices with saved results,
summaries, figures, reports and installed help. Category policy and actual
score recoding remain distinct, including unknown metadata in older objects.
The feedback guide and GPCM inference decisions are included in the checked
archive. The M5 record identifies the full run, test repairs and reused results;
older Windows checks do not validate this successor. Its five-platform CI now
passes, its website is updated and its rc.6 tagged assets are verified under M6. Package checks do not turn restricted outputs into
universal statistical guarantees.

## GPCM: specific restrictions and their exit conditions

GPCM is implemented. In 0.2.4, one selected facet has level-specific positive
discriminations and category steps, and `slope_facet` must equal `step_facet`.
The slope multiplies the full adjacent-category predictor. Relative slopes
have geometric mean one; default MML estimates the normal ability population,
while the explicitly fixed-standard-normal option is a narrower specification.
This is a one-dimensional, single-facet discrimination structure. It does not
estimate task and rater slopes simultaneously.

Public model names now use **GPCM**, without a blanket *bounded* qualifier.
One substantive ability dimension is shared with the current MFRM response
models, and is not a reason to give GPCM a restrictive name. Structural
choices and unavailable operations are described separately. Ordinary GPCM with
item slopes does not require simultaneous task/rater slopes; those represent
an additional model. The [GPCM tutorial](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.html) explains
the current parameterization and interpretation.

The local pre-submission API integration replaces the blanket label in help,
model messages, route tables and tutorials with an explicit model description
and the status of the requested operation. This wording change preserves
the substantive model structure. The three inference outputs now use separate
MML checks: information-criterion comparison, the matched PCM/GPCM test, and
pointwise relative-slope intervals. This is pre-freeze work; a release number
alone is not a reason to defer a justified correction. Longer fitting alone
does not establish adequate categories, nonsingular information, model
compatibility or interval coverage. JML intervals and additional slope
structures remain outside these implementations.

| Stage | What it would change | Evidence required before calling it complete |
| --- | --- | --- |
| 0.2.4 pre-submission integration | Readers can distinguish model structure, estimation checks, uncertainty, scoring and diagnostic availability. | Fit help, tutorial, capability table, summaries and comparisons agree on the current behavior. No claim that a new name unlocks an unavailable interval or prediction. |
| 0.2.4 existing-model inference | The current single-facet GPCM provides MML IC comparison, a matched PCM/GPCM LRT and approximate relative-slope intervals for eligible fits. | Complete G1--G3, propagate their separate decisions through summaries, weighting reviews, plots and saved output, and reconcile help/examples/NEWS. Reuse existing numerical evidence and run only missing target-specific checks. JML inference and additional slope structures remain separate. |
| First structural extension | For example, criterion-specific discrimination with rater-specific category steps, using one slope family. | Specify separate slope/step roles and identifiable data patterns; recover the current model when roles coincide and PCM at unit slopes. Verify probabilities, derivatives, parameter maps, numerical behavior, uncertainty and the retained scoring/reporting paths. This removes the equality restriction only for the admitted scope. |
| Experimental inference in development | One-relative-slope profile-likelihood intervals, a saved profile plot and a matched Wald comparison are implemented; see the current work package. | Reoptimize nuisance parameters subject to the existing identification constraints. Retain failed searches, unbounded endpoints and numerical/integration diagnostics. Qualify coverage, interval availability and computing cost for the chosen target; superiority over Wald or lower cost than bootstrap is not assumed. |
| Operational GPCM extension | Save a reviewed GPCM calibration and score new Persons without refitting that calibration. | Carry slopes and their owner, steps and their owner, category coding, population/scoring reference, anchors, constraints and schema version. Match supported in-fit versus saved-calibration scores, fresh-session replay and explicit rejection of incompatible new data. Conditional scoring and calibration uncertainty remain distinct. |
| Further model proposals | Simultaneous task/rater slope families, moderated effects or other structures. | A separate substantive need, constraints separating the effects, informative designs, matched numerical/statistical evidence and useful output. These proposals are not prerequisites for completing the preceding stages. |

Separate slope/step ownership still uses one slope family; it does not estimate
rater and criterion slopes simultaneously. Its first implementation should keep
the current full-predictor slope action unchanged. Rater-specific steps describe
category use conditional on that model, not an automatic diagnosis of a rater's
habit. Rater location and step contrasts need separate identification, adequate
crossing and category support, especially in incomplete designs.

The September 26 numerical verification checks two slope levels versus
three step levels and the reversed ownership, complete and incomplete crossed
rosters, and fixed/adaptive MML integration. Direct scalar category recursion
and independent R integration agree with the marginal likelihood; analytical
gradients agree with finite differences, and unit slopes reproduce PCM values
and nuisance gradients. These are checks at specified parameter points with
a known standard-normal ability distribution, not fitting, identification,
recovery, interval qualification or a newly available public model.

The September 26 local development implementation now admits separate owners
for additive **MML**, with one positive slope family, geometric-mean-one
identification and unchanged full-predictor slope action. Estimation, fitted-object
scoring, information, eligible slope/curve intervals, matched PCM comparison,
same-design parametric bootstrap, saved inference and exports preserve both owners.
CCC and expected-score pathways show every step/slope pair; the joint profiles
do not inherit a single-facet Infit flag. The fit-versus-measure pathway retains
its separate individual-facet diagnostics.

The fitted checks cover 120 persons, three step-owning raters and two
slope-owning criteria; an interchange of facet names preserves the likelihood
and parameter vector. A rotating two-rater assignment also yields a numerical
solution and eligible approximate slope intervals. A perfectly confounded
rater/criterion assignment is rejected before optimization (rank 4/5). A matched
free-population PCM comparison adds one slope contrast, not two step contrasts.
Three parametric bootstrap refits preserve the structure; these are integration
checks, not resampling-accuracy evidence. Existing equal-owner inference,
comparison, reporting and plot regressions remain intact.

**Completion boundary for this tranche:** the connected local MML workflow and
its help/NEWS are implemented. JML, dedicated weighting reviews and general
simulation/design helpers explicitly retain the same-owner restriction. No
claim of finite-sample coverage, general identification under arbitrary sparse
designs, global optimum certification or equivalence to unrestricted generalized
MFRM follows. Evidence is in
`validation-results/gpcm-separated-owners-20260926/fit/` and the claim ledger.
This is development-version work; the frozen 0.2.4 candidate is unchanged.

**Original admission question (pilot completed; stronger claims remain open):**
assess separate-owner estimation under a small,
predeclared set of practically relevant crossed/incomplete designs, distinguishing
convergence, information availability, parameter recovery and interval coverage.
Choose simulation size from the decision and Monte Carlo precision, reuse the
present kernels/fixtures, and stop if identification fails. Extending general
simulation/design APIs or recommending operational use requires this evidence;
a new profile interval or portable calibration is a separate milestone. Do not
launch a large factorial experiment merely because the model now fits.

Profile likelihood is a candidate method, not an established repair for the
observed probability-interval undercoverage. A relative slope, a
population-standardized slope and a category probability are different targets;
improving one interval does not qualify the others. Model misspecification and
nonregular cases are not repaired by replacing a Wald interval with an ordinary
likelihood-ratio cutoff. The existing likelihood and derivatives can be reused,
but the joint information matrix alone does not produce a profile. Numerical
search reliability and time must be measured, as discussed by
[Fischer and Lewis](https://doi.org/10.1007/s11222-021-10012-y).

Qualification must match the output: a parameter interval, a predictive
quantity and an information-criterion comparison do not have identical
requirements. The present shared readiness policy is an implementation choice
to reassess, not a theorem that all GPCM outputs require one universal boundary
certificate. Any narrower eligibility rule needs its own justified conditions,
failure handling and evidence; it must not merely bypass the existing guard.

The three historical **single-family inference** milestones have distinct
acceptance conditions. Their G labels belong to that work package; they do
not close the current joint-slope G1--G4 milestones:

1. **G1 — MML IC comparison:** reuse the current same-data/likelihood, parameter-count
   and integration checks, then define and verify solution-quality and
   identification conditions independently of slope-CI availability. Exercise
   stable interior fits and numerical/singular counterexamples. No CI-coverage
   or universal global-optimum theorem is required to implement this rule.
2. **G2 — PCM/GPCM LRT:** align the population model, steps and other constraints,
   verify the unit-slope null and free-dimension difference, then assess the
   chi-square approximation under PCM. With only G relative slopes differing,
   the null supplies G-1 restrictions. Slope one is interior; parameter
   positivity alone does not justify a boundary-mixture reference. Neither
   default-model labels nor the IC rule automatically authorize this test.
3. **G3 — Slope intervals:** reuse joint free-coordinate covariance and log-slope
   transformations, specify the approximate interval and its eligible fits,
   and assess availability/coverage in declared relevant designs. Preserve
   failed/singular cases and distinguish relative from standardized slopes.
   Exact coverage under arbitrary misspecification is not an acceptance gate.

Resolve G1 before expanding numerical studies. Keep MML and JML separate and
reuse existing witnesses with their source/model limitations. A numerical or
statistical failure requires repair or a clearly explained reconsideration;
it does not silently move an entire required operation to the next version.
The earlier M5 source completed G1--G3, downstream integration and applicable
package checks. The follow-up above subsequently completed its own September 26
M5 integration; it is not covered by the earlier frozen archive below. A broad
data-design guarantee is not part of either endpoint.

Initial G1--G3 integration status (before the follow-up above): G1 has focused checks plus two
same-data PCM/GPCM comparisons, with Criterion or Rater slopes. It reevaluates
local solution information for GPCM and estimated-population RSM/PCM. It retained
the then-existing 80-free-coordinate execution limit, subsequently replaced by
shared joint information and a workspace budget. It keeps
IC eligibility separate from interval/LRT readiness. This is not a universal
solution or capacity guarantee. G2 now implements the matched PCM/GPCM MML
LRT through `compare_mfrm(..., nested = TRUE)` and the corresponding optional
weighting-review argument. It verifies the shared population design, facet/step
constraints and interactions, and G-1 free relative-slope restrictions; numerical
solution checks remain independent of slope-interval availability. The test is
asymptotic, retains explicit failure reasons and does not choose a scoring policy.
Its targeted null validation and limits are recorded under
`validation-results/gpcm-lrt-20260924/`; this is not a general finite-sample
size guarantee. G3 now provides `confint(fit, parm = "slopes", level = 0.95)`
and the same calculation through diagnostics. Joint information includes
population-parameter estimation, and the log-slope transformation preserves the
geometric-mean-one constraint. Stored flags alone cannot authorize intervals.
Summaries, attached diagnostics, weighting tables and interval guides retain
the separate decision; Wright/Pathway locations and plug-in information curves
do not acquire slope-uncertainty bands.

The targeted G3 check reused all 400 G2 null fits and added 400 unequal-slope
fits (two owners, two designs, 100 replicates per cell). All crossed-N100 fits
returned intervals, with level-specific coverage of 92--98%. For N40 with two
of three raters per Person, unit-slope coverage was 95--97% with full
availability. Unequal-slope availability was 96--97%, and coverage among
available intervals was 90.6--97.9%; coverage-and-return over all planned
replicates reached as low as 87%. Four regularized-information cases and three
category-support cases stayed unavailable. Very wide intervals and undercoverage
in some small-sample cells remain explicit limitations. These are model-based
pointwise approximations, not standardized-slope, simultaneous or robust bounds.
See `validation-results/gpcm-slope-intervals-20260924/` for the plan, saved
results, per-level Monte Carlo intervals, width summaries and API checks.

G1--G3 implementation and targeted local validation were completed for these
stated outputs. That earlier source completed M5 local integration, with
the full-run findings repaired and a frozen successor archive checked. The
integration record distinguishes the initial full run from focused repairs
and content-identical reuse. Earlier Win-builder results cannot validate this
archive; current-source CI and rc.6 publication are verified separately under M6.

Portable GPCM calibration is a separate lifecycle extension: it must retain
slopes, steps, population/scoring reference, anchors and versioned identity.
Its next implementation and external-comparison sequence is defined under
[Inference and portable scoring](#next-gpcm-work-package-inference-and-portable-scoring).
Fitted-object GPCM scoring does not already provide that artifact. Conversely,
portable scoring, Bayesian estimation, FACETS output equivalence and a theorem
covering every global likelihood path are not all mandatory prerequisites for
qualifying one clearly stated MML inference target. The required evidence must
match the claim; numerical convergence alone remains insufficient.

There is no defensible calendar date for removing all restrictions together.
Terminology and the retained approximate-inference scope have been reconciled;
separate slope/step ownership is implemented in development MML. Slope action
remains a distinct structural question, as specified below. Release each
qualified capability when its own conditions are met, without waiting for
multidimensional MFRM or calling the result unrestricted. If an inference
investigation fails, retain its limitation explicitly rather than leaving a
whole model indefinitely described only as "bounded".

### ConQuest/TAM model and inference decisions

Use the [GPCM guide](vignettes/mfrmr-gpcm-scope.Rmd#what-can-and-cannot-be-compared-across-programs)
to distinguish a coordinate change from a model change. TAM's documented
Example 14c combines a many-facet intercept design with estimated slopes;
ConQuest supplies generalized-item scores and a scoring design. Neither is
automatically the current mfrmr model, where one facet's slope multiplies
the complete adjacent-category predictor. The programs also support broader
latent-variable designs; their availability is not evidence that mfrmr
already implements those structures or needs them all for 0.2.4.

| Work | Decision and completion evidence | Release relationship |
| --- | --- | --- |
| Current-model explanation | State slope action, population identification and each inference target. The frozen rc.6 uses a shared owner; development MML permits separate owners, while JML requires the same owner. Include the TAM many-facet route and ConQuest scoring design, with exact versus different-model comparisons distinguished. | Preserve source-specific scope in help and releases; do not assign development features to the frozen candidate. |
| Standardized-slope uncertainty | Implemented locally by `confint(scale = "standardized")`, with the full scale Jacobian, cross-covariances and an explicit target. Independent derivative/algebra checks and reuse of saved normal-population fits examine numerical and sampling behavior. | Cross-software joint-interval equivalence and broader distribution/design performance remain unqualified. Marginal external SEs cannot substitute for missing cross-covariances. |
| Slope action | Decide whether users need slopes on ability with additive rater effects, alongside the current slope on the complete predictor. Require an explicit formula, identification, unit-slope reduction, probability/derivative checks and design-specific performance evidence. | Separate structural extension. Preserve the current default and saved-model meaning; changing only argument names cannot implement it. |
| Slope/step ownership | Separate-owner MML with one slope family is implemented in development. Preserve its constraints and free dimensions through the planned inference and portable-scoring comparisons. Additional slope blocks remain separate proposals. | Separate from slope action and from multidimensionality. Existing implementation is not a qualification of every sparse design. |
| Comparison and interoperability | For numerical replication, align observations, categories, normal population model, constraints and numerical accuracy. Retain source versions and parameter ordering. Different models may be compared by IC on compatible likelihoods, using each model's free dimensions; establish nesting separately before an LRT. | Reuse existing TAM 4.3-25 and ConQuest 5.47.5 evidence within its scope. A new covariance adapter requires its own evidence; general parity is not a release gate. |

For slope-action work, prioritize whether a user needs the rater-severity
contrast to have the same log-odds effect across criteria. Existing algebra and
sampling records already show that the two formulations can differ and that a
connected acyclic rater-by-criterion design may not distinguish them. Reuse
that evidence; validate only new estimator or inference claims. Future
acceptance must cover score calculation, information, residual diagnostics,
bias analysis and saved-result compatibility for the new formula, rather than
assuming existing downstream methods transfer unchanged.

## Response time and decision processes

These remain later research directions. A response-time model needs a defined
event and actor, appropriate time units, missing/censored-time treatment and
an identified relation to the measurement target. Response production time
must not be duplicated because several raters score the same response; rater
scoring time is a separate observation.

A diffusion model requires suitable choice-and-time data and its own likelihood.
Polytomous ratings or essay completion times alone do not supply that model.
A concrete assessment need and data take precedence over adding these names
to the API.

## External comparison

Use a comparator to answer a specific formula, convention or interoperability
question. Match model, parameterization, estimator, scale and uncertainty
meaning first; numerical agreement is supporting evidence within that scope.
It does not establish statistical validity or a promise of feature parity.

The mirt, TAM and eRm adapters preserve supported source scales and conventions.
TAM multi-facet displays do not reconstruct separate facet coordinates, and
marginal SEs cannot reconstruct a missing joint covariance. Imported objects
are not native fits or portable calibrations. Preserve these distinctions in
any future adapter extension.

## Version direction

The active scope table governs the release target. The development suffix is
not a decision to move agreed work to 0.2.5. Keep old candidate tags and their
evidence immutable; publish the completed source under matching new metadata.

| Horizon | Outcome | Release boundary |
| --- | --- | --- |
| Integrated 0.2.4 — active target | Finish the retained baseline and agreed GMFRM/JML, G/D and feedback/interface work through the active scope table. | D1/D2 remain open; freeze only after the required outcomes or explicit scope decisions are resolved. Obtain evidence for that exact source. The earlier rc.6 publication and checks do not make this expanded release complete. |
| rc.6 — historical candidate | Retain the published source, assets and recorded checks as an immutable checkpoint. | Its M0–M6 evidence remains attached to its source. Do not replace the tag or describe its Windows/CI results as checks of later development. Candidate publication is not CRAN acceptance. |
| Maintenance releases, if needed | Correct reproducible calculation, interpretation, installation or compatibility defects. | Preserve supported behavior where possible; identify affected versions, explain any changed result and provide recovery or migration instructions. Research extensions do not delay necessary repairs. |
| Subsequent feature releases — not a hidden 0.2.4 checklist | Select a concrete unmet planning, inference or model need after integration, using actual feedback. | Candidates include unequal future G/D allocations, additional dependence structures, portable ML/WLE and multidimensional models. Changing slope action or adding beyond the agreed two fixed families requires a new model decision. None is automatically assigned to 0.2.5, and none silently replaces current obligations. |
| A future stable API release | Make the supported interfaces, saved objects and migration policy predictable over time. | Stability depends on user experience, reproducible evidence and maintenance capacity; it does not require every model on the research list. Neither 0.3.0 nor 1.0 is a promise of universal statistical validity. |

## Post-release priorities

The principal user outcome is feedback that helps a rater or assessment team
decide what to review, what additional ratings to collect and what the analysis
cannot establish. Educational performance assessment remains the main example.
Music, clinical assessment and judged sport inform the role and design checks;
renaming columns is not validation in another application area.

The API and current-GPCM decision rows below are carried forward as maintenance
responsibilities after their pre-submission completion, not postponed from 0.2.4.
The table retains the long-term priorities and the user's emphasis on rater
feedback. Immediate execution follows the active D2/D3 reconciliation and D4
integration gate; the original GPCM work package now has locally implemented
outputs to integrate. Thematic "first" or "next" headings below do not restart
completed work or put another research grid ahead of integration. Reopen shared-rater
interval research only under its stated conditions; do not repeat it simply
because it appears earlier in this thematic list. The completed PCA/k-means,
assigned-score MI, multivariate
G/D-study and two RSM extensions are the starting point, not new features to
implement again.

| Priority | User outcome | Next bounded work | Condition for completion or moving on |
| --- | --- | --- | --- |
| Continuous maintenance and adoption | A new user can choose an analysis, understand a limitation and reproduce a saved report. | Address demonstrated failures in setup, defaults, messages, examples, accessibility and saved-result reuse. Walk through an educational assessment from raw ratings to feedback, with a graduate-student reader when available. | The reproduced problem is fixed and its affected paths are checked. A usability claim requires actual reader evidence; an author walkthrough alone is not a user study. |
| Interface integration and maintenance | Users can find the right operation and predict what its arguments, defaults and result mean. | Finish the work package below before submission across the principal estimation, scoring, diagnostics, G/D planning, features and imputation routes; subsequently use actual feedback to refine it. | One recommended entry per distinct task, clear argument decisions, matching help/examples/results and tested compatibility. This is a 0.2.4 pre-submission requirement. |
| GPCM integration and subsequent research | Users can explain discrimination and reuse a calibration for a later cohort. | Integrate the implemented profile/scoring scope and retained external evidence first. Select subsequent inference work under its own target and maintenance gate. | Keep conditional MML/JML scoring distinct from calibration inference; do not require all later structures or universal coverage. |
| Rater uncertainty research, conditional on reopening | Show how uncertain an observed rater's severity is when calibration was estimated from finite data. | Reuse the completed shared-rater review; resume only for a concrete method improvement, narrower target or justified computation plan. | Declare the repeated-sampling target and qualify coverage, availability and usefulness together. If evidence is inadequate, keep the explicit limitations and conclude the investigation rather than automatically adding another model or simulation grid. |
| Next planning focus: feasible assessment designs | Compare whether additional tasks, raters or criteria are worth their workload for the intended decision. | First use existing G/D scenarios with explicitly supplied costs and constraints; identify the first planning question they cannot answer. The leading statistical extension is uncertainty for a prespecified comparison of two supported nested plans. | Show a usable plan comparison, with cost units, assumptions and uncertainty where qualified. A new nested interval method needs its own covariance and performance evidence; a cost table does not implement unequal future allocations. |
| Later uncertainty targets | Compare Persons or raters while carrying the relevant shared calibration uncertainty. | Choose one prespecified contrast and its observed/new-entity target. Assess few-cluster or multiway methods only for a specified sampling/dependence structure. | Preserve covariance, anchoring and any estimated linking; compare with the current conditional or working-model result. Support remains limited to the examined model and design. |
| Selected model/design extensions | Answer a demonstrated assessment question that the supported workflows cannot answer. | Consider the candidates below after defining the decision, data and simpler alternatives. | New likelihoods or covariance structures require identification, independent numerical checks, statistical evidence, usable output and an affordable maintenance path. |

### First integration work package: API names, arguments and help

This work package is now assigned to 0.2.4 before CRAN submission. Its earlier
allocation to the next feature release is superseded. It prioritizes existing
workflow meaning and compatibility; it does not require renaming every export.

Readable help is part of API design. The fitting entry currently combines data
roles, score coding, model assumptions and numerical settings in more than forty arguments.
A glossary added after that interface does not by itself make those choices
understandable. The first redesign covers the path from a user's question to
the appropriate function, its defaults, its result and the next interpretation.

| Current source of confusion | Required design decision |
| --- | --- |
| `mfrm_cluster()` specifically uses Gower/PAM, while `mfrm_cluster_kmeans()` names its algorithm. | Implemented locally: `mfrm_cluster_pam()` is the recommended entry, with `mfrm_cluster()` retained as an identical alias. New and old calls preserve partitions, result classes and saved-result methods. |
| `mfrm_response_imputations()` reviews supplied completions; it does not generate imputations. | Implemented locally: `review_mfrm_imputations(..., impute_ids = ...)` names the operation and event-ID selection. The old wrapper preserves its argument order and output class; fitting and pooling use the same reviewed completions. |
| `predict()` returns category probabilities for shared-rater models but Person scores for testlet models. | Separate ability scoring from response prediction in the recommended routes. Explain the supported fitted/new-Person roster for each. Existing `predict()` calls must not silently start returning a different quantity. |
| `keep_original` can change which category steps are fitted. | Implemented locally in fitting, data review and anchor review: `category_policy = "preserve"`/`"collapse"`. The old boolean and default are retained, explicit conflicts fail, and replay retains the existing representation. Data-review and fit summaries now show the policy separately from actual score recoding; unknown legacy metadata is not inferred. No new category information or default change is implied. |
| `level`, `ci_level`, `conf_level` and `interval_level` appear in related interfaces. | Retain current spellings in 0.2.4 rather than add duplicate arguments solely for appearance. The help must identify parameter intervals, latent-effect intervals and conditional Person scoring. Standard R generics retain their conventions; any later consolidation needs a specific usability benefit. |
| `newdata`/`new_data`, `missing = "fail"`/`"error"`, and category declarations differ between workflows. | Retain existing spellings and choices for 0.2.4. Document what is omitted, how the analysis sample changes and whether the complete shared-effect roster is needed. These interfaces do not all have the same target; do not silently treat an observation-row filter as output-only Person selection. |
| `person_sd = NULL` estimates a variance in extensions, while a numeric value fixes it; ordinary-model population defaults differ. | Explain estimate versus fix explicitly, distinguish these inputs from starting values, and put population assumptions in the first-use comparison. Do not equalize them through an undocumented default change. |
| Guide, table, report, review and export functions compete for the same first screen. | The beginner route remains compact. `mfrmr_output_guide("feedback")` now connects rater-feedback questions to model-specific intervals, residual review and known-truth accuracy, with matching saved-output routes. Preserve R's `summary()`, `plot()` and `confint()` conventions rather than renaming their standard `x`/`object` arguments for cosmetic consistency. |

Help pages will start with the question answered, the required input and a small
interpreted result. Explain essential arguments first, then statistical choices,
then computation and display options. For each consequential default, show what
omission or `NULL` means, a valid example, and what changes in the analysis.
Long-form ratings, column names, actual values and fitted objects must be
distinguished explicitly. Technical derivations remain available after that
introduction. Document the matching model restrictions on the same page.

The same vocabulary must appear in installed help, the website, examples,
warnings and returned tables. Where two functions share semantics, maintain one
source for that explanation; do not copy a paragraph across statistically
different arguments just because their names match. Organize the documentation
around rating review, model fitting, ability scoring, response prediction,
rater feedback, planning, features, missing scores and reporting. Observed-score
G-theory and external-feature clustering do not require a fitted MFRM.

Completion requires executable old/new-call comparisons for adopted renames,
explicit errors for conflicting old/new arguments, preserved saved-object and
S3 behavior, and a migration table naming the canonical route. Deprecations
need an announced transition across a subsequent feature release where safe;
the 0.2.4 interface is not broken simply to make spelling uniform. A long
argument list is not solved by hiding everything in `...` or an undocumented
control list, and a second universal wrapper is not a substitute for clearer
existing entries. Reuse current tutorials and improve them around actual
reader failures rather than adding a parallel set of guides.

### Next interface and feedback delivery

The September 26 rc.6 baseline review confirms 208 exports, 35 `plot_*` names and 44
registered `plot()` methods. Among the 35 names, first arguments are `x` (20),
`fit` (13), `fits` (1) and `reference` (1); eight expose `main`, none expose
`title`, ten expose `ci_level`, and 28 expose `preset`. Two of these 35 names
are the extraction helpers `plot_data()` and `plot_data_components()`, so these
counts are not a count of distinct figure types. Counts describe the reviewed
source, not a target for reducing exports.

The recommended results/report/export route, beginner/feedback guide and
primary-versus-specialist pkgdown sections already exist. They need a clearer
task-based presentation. `plot(res)`, `mfrm_report(res)` and
`export_mfrm_results(res)` consume the same saved results object; they are not
a pipe in which the plot becomes report input. Specialized table, bias and
replay-bundle operations remain useful where that route is not equivalent.

The following records the original interface/feedback plan and its local
progress. Much of it is now implemented; remaining gaps are not a new blanket
release requirement. The release version remains undecided. These changes do
not alter the checked rc.6 implementation. The progress note below distinguishes
local additions from the remaining work. The first implementation should make
plot/report capabilities and recommended routes explicit, then use those routes
for individual rater sheets.

| Work | Delivery and completion condition |
| --- | --- |
| Recommended and specialist routes | Extend the existing guide and reference sections with input/output roles and precise alternatives. Mark a function `superseded` only when a tested replacement covers its supported task; retain `apa_table()`, focused bias reports and specialist exports where they have a distinct role. Distinguish recommendation from stability. The current guide's `Lifecycle` column mixes `stable`, `advanced` and `compatibility`; user level and compatibility role must be kept distinct from formal lifecycle stages without breaking existing guide consumers. |
| Argument consistency | Prefer `title` for equivalent plot titles and `level` for an interval that is actually computed. Keep `x` for standard S3 methods and meaningful multi-input names. Keep `metric` distinct from view/style selection. Add compatible aliases only after specifying omission, explicit `NULL`, conflicting arguments and positional-call behavior. Preserve old/new numerical and display results; do not recalculate a saved interval when changing its plot. |
| ggplot coverage | Publish and check a matrix of result class, plot type and relevant component, identifying dedicated support, generic fallback, refusal and alternative route. Existing dedicated conversions and explicit refusals are the baseline. Compare estimates, units, group ordering, intervals, unavailable rows, warnings and display controls using saved payloads. Add dedicated conversions for useful gaps; arbitrary column matching is not evidence of equivalent graphics. |
| Purpose-based gallery | Reuse the guide and existing tutorial figures for severity, fit, category functioning, sparse-design review, features and D-study planning. Each thumbnail links to an executed example, supported objects, base/ggplot status, alternative text and a data table. Gallery entries must agree with the capability matrix; no separate competing registry is needed. |
| Individual rater feedback | Produce one rater-scoped HTML sheet with print styling and a plain-language/researcher presentation, using reviewed saved results without automatic refitting. Include severity and its available uncertainty, rating exposure, fit, category use, selected unexpected ratings and an explicit comparison reference. Keep ordinary and extended-model diagnostic meanings distinct. Missing sections must say why; severity is not rater quality and flags do not automatically justify exclusion. Verify that another rater's or a Person's identifying details do not leak into the distributed sheet. PDF delivery follows a verified rendering route. |
| Consistent appearance | Reuse the existing preset resolver and internal ggplot theme. Specify precedence as explicit call setting, then session option, then package default; resolve and save the chosen appearance for replay. Preserve removable titles/notes, monochrome and non-color cues, and avoid mutating the user's global ggplot theme. The session option is now implemented locally for common-preset routes, as detailed below. A public theme remains a separate proposed convenience. |

Local development progress (0.2.4.9000): `mfrmr_output_guide("plots")` now
provides 29 selected purpose-based routes with result-creation help, exact
plot calls, data components, conversion status and alternatives. Existing
guide scopes retain their format. The visual-diagnostics tutorial and help
use the same guide. The tutorial now includes six linked previews for scale
location, response fit, categories, subset coverage, feature hierarchies and
composite D-study planning. Each leads to an executed example and numerical
data; labels and conversion status come from the guide. Keyboard navigation,
image alternatives and narrow-screen layout are checked locally. This completes
the first selected gallery, not a complete conversion inventory or argument
migration. Dedicated converter equivalence across all views, components and
display controls remains part of the completion conditions above.

The first individual-sheet implementation is now available locally through
`mfrm_report(..., style = "rater")`, without a new exported entry point.
Its scope is native additive RSM/PCM results, with explicit facet/rater
selection, optional saved individual fixed-facet intervals, and plain-language
or researcher presentation. HTML, Markdown, tables and the standalone object
exclude the source fit, source row identifiers and other people's identifying
fields. Matching interval contrasts and saved diagnostics are checked before
projection; multiple matching interval attachments require a choice. Category
coding, weights, model reference and missing sections remain explicit. Tests
cover numerical reuse, selection, missing inputs, unsupported models and source
identifier/attribute leakage. The example chunk executes, and local browser
checks cover narrow screens, table semantics, visible keyboard focus and print
CSS. This is not a general deidentification guarantee or a recipient usability
study. PDF export, extended-model sheets and intended-reader evaluation remain
open; the checked rc.6 candidate is unchanged.

The first argument-consistency change is also implemented locally: the eight
`plot_*` helpers that expose `main` now also accept `title`. They cover marginal
fit/pairwise, unexpected responses, interrater agreement, facet chi-square,
bubble, bias interaction and facet dashboard plots. A shared resolver and
inherited help define omission, explicit `NULL` and conflicts. `main` is still
supported without deprecation; its `NULL` default meaning and all legacy
positional calls are preserved. `title = NULL` suppresses the heading. The
21 view-specific payloads match their saved pre-change defaults, custom-main
and positional-call baselines. Targeted tests also check actual base rendering,
dashboard S3 forwarding, remaining review notes and supported ggplot replay.
The new tutorial example executes from saved diagnostics. This completes the
first title-alias group, not the broader `level`/view-argument or appearance
integration. An added title argument does not imply new ggplot coverage.

Visual inspection of that example exposed a separate existing bubble-converter
error: it replaced saved radii with a constant point size and discarded saved
facet colours. Conversion now retains radius ratios, colours, facet order and
reference lines; the native monochrome preset also selects gray colours.
Unequal-count/SE tests distinguish radius from area scaling, and the help now
correctly states that count-based circle area (not radius) is proportional to
count. Physical sizes differ between rendering systems; this is not a claim
of complete visual equivalence across all plot families.

Session appearance defaults are now implemented locally through
`options(mfrmr.plot_preset = "publication")`. Explicit settings take precedence;
the unset default remains `"standard"`. The 42 direct common-preset entries and
eight report-bundle forwarding branches use the shared resolver. Paired plots
forward the resolved parent choice to both sources. Saved plot payloads retain
their preset for supported conversion, without consulting a changed session
option or changing the global ggplot theme. The 27 pre-change default payloads
remain identical. Targeted checks cover option validation, all four presets,
explicit overrides, saved-payload conversion and forwarding from results.
This completes the session-option part of appearance integration. A public
theme, plots with their own palette controls, and full converter equivalence
remain separate; the checked rc.6 candidate is unchanged.

The first additional converter family is implemented locally for the three
external-feature PCA views: scree, scores and loadings. Dedicated conversion
preserves the selected components, equal score-axis units, retained-component
symbols, feature order and saved group colours/shapes. It retains excluded IDs
and transformation metadata through `plot_data()` and does not refit PCA or
clustering. Both default and explicit table conversion use the complete view;
other components cannot bypass it. This addresses the PCA gap, not all cluster plots or the full plot inventory.

Saved external-feature dendrogram conversion is now also implemented locally.
It uses recorded binary merges and heights, preserves leaf order and group
boxes, and retains exclusions and label/preset choices. Tied-height cuts follow
saved memberships rather than a new horizontal threshold. Tests compare the
layout with stats dendrogram midpoints and heights for both supported linkages,
and check ties, zero-height trees, replay and refusal of misleading component
selection. No clustering or recutting is performed. The purpose guide includes this dedicated conversion.

Imputation co-membership conversion is now also implemented locally. Saved
fractions calculated over all imputations, requested ID order, labels and
zero-to-one scale are retained. Unavailable cells use both grey fill and
crosses. Selection does not renormalize values; hiding labels does not sample
cells. Matrix/source metadata, including exclusions, remain extractable from
the ggplot. Tests cover ordering, selection, unavailable/zero cells, singleton
and all-unavailable views, save/load, and unchanged global settings. The purpose guide includes this dedicated conversion.

Silhouettes and numeric/categorical partition profiles now also have dedicated
conversion. Silhouettes retain negative widths, saved order and overall-mean
references; group labels do not depend on colour. Numeric profiles retain
original-unit means/medians and counts, with slight vertical offsets to show
coincident summaries. Categorical profiles retain unused levels, original
order, group counts and the fixed zero-to-one scale. Neither clustering nor
uncertainty is recomputed. The selected guide's clustering/PCA conversion gaps
are now covered. This is not the full package plot inventory.

Pooled-facet interval conversion is now also implemented locally: saved MI
t-interval endpoints, target order, contrast coefficients, degrees of freedom
and information cautions are retained without repooling. Fixed targets have
no intervals; unbounded endpoints and unavailable intervals receive explicit
symbols. Default/table conversion cannot fall back to generic bars. Tests
include small-df t intervals, fixed targets, infinite/missing endpoints and
replay with interval-calculation calls blocked. The selected guide now has
22 dedicated, two native, two generic and three unavailable routes.
Screening-performance plots and the two remaining G/D-study conversion
families remain explicit gaps; the model/inference roadmap is separate from
this display work.

The representative local workflow integration review now connects saved
fixed-rater results, individual sheets, interval figures, analyst exports and
exported replay scripts. It also checks PCA/group views, a small completed
feature-imputation workflow and an existing 40-imputation response-score
interval result after save/load. Reporting and conversion reuse saved values
without estimation calls. Tutorials now distinguish recipient HTML from the
analyst's RDS, and a first-completion view from all completed feature analyses.
This closes that connection check, not the full interface or release review:
intended-reader evaluation, remaining specialized plot conversions and the
statistical work packages remain open. The rater-uncertainty evidence/budget review is complete for this tranche and
separate-owner GPCM MML is now connected locally. Its D1 pilot and integration
disposition are recorded above. The current priority is combined-source
integration; additional converters are not an automatic prerequisite. Rater-interval qualification resumes only under its stated triggers. Evidence is recorded
in the [validation record](inst/validation/claim-reconciliation-0.2.4.md).

The [lifecycle definitions](https://lifecycle.r-lib.org/articles/stages.html)
distinguish `superseded` (a better alternative, continued support, no warning)
from deprecation. Missing badges alone do not mean an API is unstable, and
`deprecate_soft()` is not required simply because another route is recommended.
Any actual deprecation needs its own migration policy and affected-call checks.

Completion of the first delivery means users can find a supported operation and
predict what it renders, not that every specialized function has been renamed.
A later sheet delivery must be reviewed by its intended reader before claiming
novice usability. Further GPCM development follows the separate-owner qualification,
profile-interval and portable-calibration conditions above; those three topics
are not silently bundled into the first interface release.

### Rater uncertainty work package: retained evidence and reopening conditions

The first target is an interval for an **observed rater's latent severity**,
relative to the modeled rater population mean, in the existing shared-rater RSM.
It is not an interval for a future rater, a
Person ability or a change caused by training. The current bootstrap API
targets model-based prediction error across generated Person and rater effects,
conditional on the supplied rating arrangement. Average performance over those
effects does not guarantee coverage for each fixed true rater severity.
Selecting that target explicitly is the first decision; it must not be changed
after inspecting results to obtain a more favorable conclusion.

The 800-dataset comparison already shows that automatic normal bounds did not
meet the combined coverage and availability criterion. Those results and the
existing bootstrap implementation are reusable evidence and code, not a
qualified replacement interval. Before further computation, separate remaining
errors in numerical approximation from the uncertainty method's statistical
performance, and establish which saved fits and draws remain applicable.
An earlier 24-dataset bootstrap pilot also remains limited: its outer sample
and 99 draws per fit were too small for a precise coverage decision, and its
original population specification must be respected when reusing the results.
It is evidence to plan from, not a reason to repeat the same small pilot.

The September 26 evidence review separates three completed observations:

| Evidence | Reusable conclusion | Decision it does not support |
| --- | --- | --- |
| 800 estimated-ability-population datasets | The saved accounting reproduces 53 unresolved Person-quadrature checks and one further estimated rater-variance boundary; all optimizer and information checks passed. | Raising quadrature or ignoring unavailable cases has not demonstrated better interval coverage. |
| Eight saved-calibration likelihood comparisons, completed earlier | The 144 planned local comparisons met their declared tolerance, including reference uncertainty. Reuse this result. | It is not an exact-MLE, variance-boundary, whole-profile or repeated-sampling guarantee; do not restart the same comparison by default. |
| 24 known-ability-population bootstrap datasets, 2,376 retained refits | Saved endpoints replay unchanged. The method and failure-preserving calculation are available for development. | These are not qualification data for the current estimated-ability-population default. Missing historical refit checks cannot be inferred from a generic failure flag. |

New bootstrap results now retain numerical, information and quadrature checks
in each trial record and carry them through existing reports and exports.
This closes an evidence-recording gap without altering the estimator,
studentization, interval endpoints or qualification decision. The current
milestone is target definition and evidence reconciliation, with method
qualification still open.

Before the next qualification run, specify a fixed numerical-resolution
procedure, estimated/fixed population choices, outer-study precision and
bootstrap-tail precision, and a computation budget. Apply the declared
procedure to all planned cases; preserve original results if it revises an
earlier numerical procedure. Numerical development on these saved cases is
not independent confirmation. Do not retry failed cases until they pass or
transfer the known-population pilot's favorable rates to the new default.
If the required precision is impractical within the chosen budget, retain
explicit candidate status and move to the already scoped GPCM ownership work;
an open research guarantee must not indefinitely block maintenance or the
rest of the roadmap. Recipient-sheet support for this model still requires
its own target-specific presentation and reader review.

**Current computation decision (September 26).** Do not start the nested
qualification study in this local tranche. At 499 bootstrap draws, the saved
normal-interval between-dataset variability and observed availability imply
about 908 planned datasets across the four conditions for an illustrative
coverage MCSE of one percentage point: about 454,000 fits, including sources.
Historical median elapsed-fit proxies sum to about 874 hours. This is a
planning sensitivity, not a predicted wall time or a proven bootstrap sample
requirement; bootstrap variability and numerical settings can differ.

Even ignoring the coverage-precision requirement, the existing availability
criterion needs at least 72 independent datasets per condition if every one
succeeds: only then does a two-sided exact 95% lower bound reach 95%. Four
conditions at B = 499 already imply 144,000 fits (about 299 summed proxy hours).
That best-case availability count is not enough to qualify coverage. Increasing
B improves empirical-tail resolution but does not resolve persistently missing
roots: at 95% and B = 499, 13 unresolved roots for a rater make both limits
infinite. Outer failure proportions cannot be substituted for inner-bootstrap
failure probabilities. Calculations and assumptions are retained in
`validation-results/rater-uncertainty-budget-20260926/`.

The scoped GPCM ownership extension is now implemented; use the active
milestones for its integration and later work. Reopen random-rater
qualification when a specific numerical/method change, a justified narrower
use case or a feasible computing plan can change this decision. Retain the
candidate method and its adverse/limited evidence; do not relabel this
disposition as completion of the interval-qualification milestone.

Evaluation must retain failed fits and unavailable or unbounded intervals.
Report coverage among all returned intervals and among finite intervals
separately, together with finite/unbounded/unavailable proportions, widths and
the proportion of all planned cases producing a finite interval that covers
the target. An unbounded interval is not a successful finite result. Examine
shrinkage and sparse or weakly linked designs rather
than relying only on a favorable pooled average. A comparison with ordinary
MFRM uses the same observations and an explicit scale and target; the two
models' rater uncertainty measures are not interchangeable by name.

Choose the comparison methods, practically acceptable performance and Monte
Carlo precision before generating new results. Start from the smallest study
that can resolve the specific remaining decision. Replications of a coverage
study and draws within a bootstrap have different roles and both need adequate
precision. A more complicated interval is useful only if its gain justifies
its computation and interpretation. Reporting, figures, help and saved replay
must preserve the chosen target and failed results.

Rater contrasts, extended-model bias tests, simultaneous screening decisions and
Person intervals are separate targets. They do not become qualified because an
individual-rater interval passes. There is no commitment to a general coverage
or diagnostic-accuracy guarantee across all designs and missingness mechanisms.

### How subsequent candidates will be selected

| Candidate | Concrete reason to reopen it | Required boundary |
| --- | --- | --- |
| Nested, fixed-facet or sparse-future G-theory | A named assessment cannot express its task/rater sampling or feasible future plan using the current crossed/nested workflows. | Begin with one structure and intended score/composite. Distinguish fixed tasks represented as score components from a general fixed-facet solver; distinguish incomplete source data from an unequal future allocation. Do not implement all structures under a single claim of general G-theory. |
| Testlet planning or task-specific dependence | Decisions about adding tasks versus rubric criteria, or revising a particular task, require quantities the common local variance cannot supply. | Compare the current common-variance model and ordinary RSM first. Specify true membership and enough repeated information before a heterogeneous-variance extension. Local dependence alone does not diagnose halo, and modeling it does not impose equal task weights. |
| PCM extensions or joint shared-rater/testlet effects | A real rubric needs different category structures, or both shared-rater and Person-local dependence materially change the same decision. | Add one structure at a time, with the existing RSM and zero-effect reductions. Establish what typical sparse data can identify; an external model may be the better route. |
| Missing-response sensitivity | Selective missing assigned ratings could change the reported rater or planning conclusion. | Preserve observed scores and the assignment roster. A sensitivity model states how its assumptions differ; it does not identify MNAR from the observed data or fill unassigned cells. Extended-model MI and pooled Person scores need separate justification. |
| Calibrated screening or bias analysis | A specified review action needs known false-flag and detection behavior, beyond the current descriptive fit/threshold displays. | Define the affected rater/group and error criterion, preserve failed/unavailable cases and examine relevant null and non-null designs. Checking many raters or choosing thresholds after looking at results requires its own treatment. Existing Infit/Outfit bands are not universal tests or evidence that training will help. |
| Feature stability or new-entity assignment | Users need reproducible group descriptions under sampling variation, or must assign new raters/tasks using an existing feature analysis. | Keep imputation sensitivity distinct from sampling stability. New-entity use must retain the fitted feature coding, scaling, PCA and assignment rule, and assess prediction separately from in-sample clustering. Do not infer rater quality from an external-feature group. |
| Larger workloads | An actual target workload exceeds demonstrated time or memory, or a dependency change causes regression. | Vary Persons, facet levels and response-pattern length separately; measure memory, time, numerical agreement and unavailable results. Report a tested configuration, not a universal capacity limit. Optimize only an identified bottleneck while preserving the statistical target. |
| Multiple scales and multidimensional MFRM | A substantive decision needs separate scales or distinct traits that a one-scale analysis cannot represent. | Multiple observed scales and latent dimensions are different proposals. Multidimensional MFRM remains deferred pending construct definitions, loading and covariance identification, useful subscores and a tractable computation plan. It is not a prerequisite for the next release. |

These candidates are not a hidden checklist for the next version. Threshold
selection, new model families and more plots are not progress unless they improve
a named user outcome. GRM, explanatory item models, response-time/process models,
mixtures and new backends retain their separate entry conditions. Existing
GPCM, JML and portable-calibration defects still receive maintenance priority;
their broader inference or model scope does not expand automatically.

## Milestones after 0.2.4

The numbered items below are a reusable review process for a selected work
package. The D0–D5 table above gives the current execution order and status. These
review steps apply to a selected work package. Maintenance can proceed
alongside it; a blocked research result must not hold necessary fixes hostage.
Help, examples and output design develop alongside the method; milestone 4 is
their final integration review, not a reason to postpone them until computation
is finished.

| Milestone | Reviewable outcome | Decision |
| --- | --- | --- |
| 1. Define the decision | One user question, target quantity, representative rating design, current workaround and declared exclusions. | Confirm that the proposed work changes a useful decision; otherwise retain the existing workflow or use an external tool. |
| 2. Establish the method or interface | For a statistical change: literature-to-equation correspondence, independent small-case calculations, identification and numerical checks, with reusable evidence. For API integration: explicit operation/input/output semantics, defaults and a compatibility/migration design. | Fix the relevant acceptance criteria before implementation or a new confirmation study. Stop or narrow the proposal if these cannot be supported; a spelling change does not require a new statistical experiment. |
| 3. Evaluate the claim | A statistical comparison reports uncertainty, failures, adverse conditions, time and memory as relevant. An interface change checks equivalent old/new calls, consequential defaults/NULLs, conflicting arguments and saved-object behavior. | Adopt only the demonstrated scope, repair a specific defect, or conclude that the proposal is not supported. Distinguish source/author checks from evidence that new readers understand the workflow. |
| 4. Complete the user workflow | Input review through summaries, meaningful accessible plots, saved results, migration and an executable question-to-answer tutorial. | Check beginner interpretation, defaults, missing results and consistency with existing APIs. Avoid a new wrapper where current functions already answer the question. |
| 5. Release and review | A defined feature set, affected regression checks, candidate/platform checks, compatible documentation and verified publication. | Release only the admitted work; explain unresolved limits and use actual feedback to choose the next package of work. Research failure does not create a reason to release an empty feature version. |

Review priorities at each completed or rejected work package and before the next
release scope is fixed. Revisit the user need if a study grows mainly to explain
its previous study, if maintenance cost exceeds the likely benefit, or if a
simpler existing workflow gives the same actionable answer. Reuse applicable
evidence and run new checks only for changed behavior, a failure or an explicit
new claim. API compatibility and dependable maintenance can justify a later
stable release without completing this entire research list.

## Compatibility principles

- Preserve model, scale, categories, anchors, score/composite identity and
  uncertainty meaning across saved results, tables, figures and exports.
- Explain incompatible inputs and saved-object migration in user-facing terms;
  internal study identifiers and execution records belong in maintainer material.
- Keep examples executable, plots in English, and missing results visible.
  An unavailable estimate must not become zero or a successful check.
- Add work when it can change a stated user outcome. Reuse applicable evidence;
  repeat or broaden checks for changed behavior, a failure or a justified
  release integration need. Test counts and documentation volume are not
  completion criteria.
