# mfrmr roadmap

Status: public roadmap, updated 2026-10-02. This document describes user
priorities and supported or planned capabilities. Planned features are not
available merely because they appear here. See [NEWS](NEWS.md) for changes
and the [README](README.md) for analysis examples.

## Current releases

mfrmr 0.2.4.9000 is under development and has not been released.
The working release target is an integrated **0.2.4**. Earlier 0.2.4 release
candidates represent earlier source versions; their checks do not establish
that the current development version is ready for release.

The expanded release is unfinished. Two-slope-family GMFRM and corrected JML
are part of the agreed development program, with experimental implementations
and unresolved statistical questions. Their inclusion here is not a claim of
completed inference or a decision to move this work to a later release.

## Focus for 0.2.4

The release has three complementary purposes:

| Purpose | Question for the user | Current foundation and remaining work |
| --- | --- | --- |
| Generalized many-facet measurement | How do ability, severity, category use and discrimination explain ratings? | RSM/PCM and one-slope-family GPCM, with provisional two-slope-family fixed-grid EM and adaptive direct MML routes. Finish the supported inference, scoring and model-specific outputs without treating successful computation as evidence of accurate intervals. |
| Multivariate observed-score G/D studies | How would tasks, raters and score weights affect the dependability of an assessment? | Crossed and selected nested designs, incomplete-source estimation, composites, plots and scoped plan-comparison intervals. Preserve the distinction between the observed design and the future plan. |
| Rater feedback and assessment decisions | What should an assessor or assessment team review, and how uncertain is the conclusion? | Diagnostics, individual RSM/PCM and experimental two-family GPCM feedback sheets, saved reports and calibration reuse. Finish the connections supported by each model and make unavailable operations clear. |

Educational performance assessment is the principal application. Music,
clinical assessment and judged sport also motivate the design, provided their
rating structure and assumptions match the selected model. Arbitrary column
names do not make every assessment design supported.

The priority is a general-purpose API with explicit mathematical targets,
reliable numerical calculations and consistent uncertainty/reporting semantics.
Empirical cases challenge those contracts; each application area need not
acquire a dedicated workflow or decision engine. Simulated recovery and
interval coverage remain necessary for statistical claims.
The GPCM guide includes an empirical writing-data review. Adaptive integration
resolved the retained concentrated-posterior numerical case; lower-order and
fixed-grid failures remain documented. Uneven assignment still needs substantive
review, and inferential and feedback claims remain unqualified. A separate clinical-assessment design
review distinguishes the current model from published extensions. Real-data
fit, known-truth simulation and practitioner usability answer different
questions and do not substitute for one another.

For consequential ranking, distinguish official rule-based results, latent
ability and future-performance outcomes. The GPCM guide now reviews actual
Olympic figure-skating records, including changing panels, selective
advancement and score aggregation. Winner-error rates, uncertain or unavailable
decisions, ties, calibration covariance and weak links need explicit evaluation
before any winner-inference claim. No winner-probability or simultaneous
Person-rank confidence-set API is currently provided; a high G coefficient
does not supply one. This requirement sharpens the scope of assessment support
without turning every competition's scoring rules into a new estimator.

The development order is to finish implemented workflows, establish the
statistical support for their claims, complete the agreed model extensions,
and integrate them as 0.2.4. G-theory, latent measurement and external-feature
clustering retain distinct quantities and interpretations, even when applied
to the same assessment.

## Validation across sample sizes and assessment designs

The study includes a final explanatory report, paired estimator/model
comparisons and scientific figures, plus acceptance checks of the applicable
public results/report/plot and saved-replay workflows. The
[output acceptance contract](inst/validation/internal-roadmap-0.2.4.md#final-report-model-comparisons-and-visualization-acceptance)
keeps these deliverables explicit. Numerical fitting alone is not completion;
research figures do not implement a missing public API. Comparisons preserve
the data, scale, population and uncertainty target, and do not manufacture
likelihood rankings across MML/JML or unsupported corrected/two-family models.

The first input freeze is complete for A/B: **108 conditions x 50 replicates =
5,400 condition records**, derived from 2,100 paired parent cohorts. It retains
all seven sample sizes, both SDs and RSM/PCM/GPCM truths. The saved input/RNG
registry and read-back, shared-response and reordered/parallel reproduction
checks are recorded in the
[A/B specification](inst/validation/internal-roadmap-0.2.4.md#ab-generating-truth-and-assignment-specification).
The [C input freeze](inst/validation/internal-roadmap-0.2.4.md#c-facet-structure-with-explicit-workload-controls)
adds 6,000 condition records and 600 exact A/B aliases across N=20/60/240/480,
SD=1 and all three generating models. It covers two/three non-Person facets,
three/six raters, two/four Tasks, three/five Criteria and three/four/five
categories under the specified contrasts. Shared responses, literal assignment
schedules, native probabilities and corrected-JML capacity/roster counts have
been checked.

The [D input freeze](inst/validation/internal-roadmap-0.2.4.md#d-mml-scale-slope-families-and-output-decisions)
adds 4,800 new response views and verifies 600 historical input reuses; another
2,800 records alias A/B controls. It prepares PCM, either one-family GPCM and
two-family GPCM comparisons across the stated slope truths, preserving the
different population scales and the historical pairing laws. Response-scale
identities and saved-input links pass their checks. The N=240 original generator
and latent draws were not archived: saved responses/truths/seeds reproduce
exactly, while reconstructed latent targets retain that provenance limitation.
The 208 existing fit candidates still need compatibility checks for the new
procedure.

The [E input freeze](inst/validation/internal-roadmap-0.2.4.md#e-robustness-mechanisms-and-matched-controls)
adds 13,800 views from 600 paired parent cohorts across population shape,
targeting, category sparsity, assignment, missingness, dependence and weak links.
It retains N=20/60/240/480, SD=1 and all three truth families. Every saved response,
assignment and deletion mask passes an independent mechanism check. Planned and
observed scores remain separate, including zero-observation Persons and absent
links; no support-based redraw occurs. These checks qualify input generation,
not estimator robustness or interval coverage.

**A-E input preparation is complete: 612 unique conditions x 50 = 30,600 records**
(30,000 new views plus 600 retained inputs). Shared cohorts and C/D aliases are
not additional independent replications. These are prepared inputs, not completed
estimates or an interim performance report. Fit/source/output and resource checks,
broad fitting, F scoring, comparative figures and final reporting remain pending;
retained historical evidence remains in scope.

mfrmr is a general-purpose R package. Validation covers **MML, ordinary JML
and corrected JML**, with the response models and outputs each actually
supports. Adding small-cohort assessment to the priorities does not remove
medium- or large-sample conditions from the evaluation.

The planned common sample-size range is 20, 30, 40, 60, 120, 240 and 480
Persons, with existing 400-Person JML studies retained as separate evidence
anchors. These are evaluation conditions, not minimum sample-size advice,
package capacity limits, or a claim that all corresponding methods and
intervals have been validated. Existing completed studies, numerical examples
and unexecuted plans retain their different evidential status.

| Validation question | Work required |
| --- | --- |
| What changes with sample size? | Compare small through larger cohorts under matched rating designs; assess bias, precision, output availability and supported interval coverage. Preserve existing larger-sample findings, including adverse results. |
| What changes with information per Person? | Distinguish adding Persons from adding ratings to each Person. For JML, more Persons do not by themselves resolve all bias from estimating many Person effects with limited individual information. For MML, more ratings can also change integration demands and conditional scoring precision. |
| What changes with facets and allocation? | Evaluate the number of facets, their levels, score categories, category-step ownership, crossing/nesting and uneven assignment separately. Adding model parameters is different from adding observations. Unsupported structures need an explicit reason. |
| Which estimator answers the same question? | Match response equations, identifiable scales and outputs before comparing MML and JML. Separate MML population assumptions, ordinary-JML Person-parameter estimation and explicit-order JML correction. Compare native Person scoring separately from calibration under a common scoring rule. |
| Does numerical success support interpretation? | Distinguish convergence, finite/identified estimates, usable uncertainty and calibration to the intended target. Account for extreme responses, failed estimates and unavailable intervals. Validate any eventual model/order-selection or feedback rule as a complete procedure. |

Ordinary JML needs its own assessment; evidence for the corrected estimator
does not establish ordinary-JML performance. Corrected JML additionally needs
evidence about residual bias, correction-order tradeoffs and covariance under
the declared rating-assignment sampling scheme. Local root standard errors
do not settle these questions. State-space and memory restrictions of its
current exact calculation must also be distinguished from statistical failure.

The [JML uncertainty specification](inst/validation/internal-roadmap-0.2.4.md#jml-uncertainty-and-candidate-evaluation-specification)
now separates public point delivery, consistent-start solutions, RootSE,
research candidate intervals and Person scoring. The expanded orders-2/4
comparison will evaluate a labelled candidate using consistent roots and the
saved full covariance, including location differences, truth inclusion, width
and delivery. This supplies no public structural CI and does not require a new
population-root sweep for every condition. Paired order uncertainty uses saved
cross-order influence covariance; agreement between orders cannot select an
unbiased estimator. Ordinary-JML formal uncertainty first needs a bridge from
its actual public points to a declared finite/extended-profile solution and
a compatible covariance/centering argument. Its screening SEs are unchanged.

Latent regression is a separate required scope: the current A/B intercept-only
population comparison does not evaluate background-variable effects. The
[D-LR specification](inst/validation/internal-roadmap-0.2.4.md#d-lr-latent-regression-and-its-connection-to-jml)
first reuses normal A/B responses with explicitly generated null/informative
Gaussian covariates, retaining all N, SD and exposure comparisons and R=50.
This Gaussian core now has 216 prepared conditions (10,800 linked views on
2,100 existing parent cohorts) and 14,400 additional initial fit slots. Its
7,200 intercept-only control slots are shared with A/B and counted once.
Eight prespecified PCM/GPCM initial calls at N=20/240 returned all 24 population
point targets without warnings/errors; fresh-process summary replay passed
with estimation blocked. These are two-cohort workflow checks, not R=50
performance or interval evidence. All eight remain at inference-readiness
review, and full D-LR fitting has not started.
Further categorical, sparse, correlated and misspecified cases need their
condition/stream allocation. A-E plus the Gaussian core has 150,200 planned
initial fit slots; that total excludes those further D-LR extensions.
Population effects/residual variance, structural uncertainty and future scoring
have separate targets. JML has no corresponding population regression estimate.
The current review fixes scoring-time restandardization of transformed
predictors by retaining the fitted R terms, with checked legacy reconstruction.
Population-coefficient intervals, latent-regression native-location intervals
and portability remain unfinished; neither this repair nor the historical
N=80/320 preliminary population study qualifies those outputs.

The [normal-population transfer review](inst/validation/jml-inference-review-20260927.md#october-1-structural-inference-gaps-and-a-normal-tail-bound)
now separates finite score moments from residual structural bias. A bound on
normal-tail contributions narrows the remaining theoretical work, but does
not establish general truth intervals for the planned low-exposure designs.
The subsequent [derivative/tail analysis](inst/validation/jml-inference-review-20260927.md#full-derivatives-and-normal-tail-transfer)
also bounds the complete equation-Jacobian and covariance-moment tails, and
shows that the proposed leading bias coefficient is normal-integrable in the
fixed-design model. The central remainder, root selection and matching sampling
limits still need proof; the compact-ability centering rate is not yet qualified
for the expanded population scope.
The ordinary public/profile bridge and corrected-JML centering justification
remain separate requirements; no correction order or public interval is added.
The [ordinary-JML residual derivation](inst/validation/jml-inference-review-20260927.md#october-1-ordinary-jml-residual-bridge)
now relates the retained joint iterate to its extended-profile gradient,
including finite extreme-Person contributions and nuisance residuals. A local
parameter-error bound additionally needs a selected root and neighborhood
curvature. These conditional results separate numerical error from sampling
variation and structural bias; current-source numerical qualification and a
compatible inferential procedure remain open. That derivation was analytic;
the subsequent numerical pilot is recorded below.

Following the user's request for small new computations, the
[bounded JML normal-range pilot](inst/validation/jml-inference-review-20260927.md#bounded-numerical-pilot-after-authorization)
completed independent derivative/expectation checks and four new datasets
(N=40/120, SD=1/2), paired across ordinary JML and orders 2/4. Complete derivatives
and the eight returned corrected covariances agree with independent references.
The N=40/SD=2 ordinary fit is blocked after an iteration limit; both corrected
orders at N=40/SD=1 retain unresolved alternate starts. These are numerical and
delivery witnesses, not coverage or bias estimates. The fixed-exposure remainder
and saved underflow/start failures remain substantive next issues; large paused
studies are not resumed.

The subsequent [facet-structure pilot](inst/validation/internal-roadmap-0.2.4.md#bounded-facet-structure-pilot-after-authorization)
compares five designs at N=20/240, keeping eight responses per Person,
three categories and two criteria while varying the rater pool and adding
two-/four-level Task effects. All ordinary-JML/MML calls return numerical
traces; 17 of 20 corrected calls return consistent-start roots, and three
reach the declared process limit. N=20 fixed-roster score-rank obstructions
prevent full covariance in the six-rater and four-task designs even when a
point is returned. All ten N=240 corrected calls return local-root covariance.
Seven MML points require q61 integration refinement under the higher-grid
gradient rule; all pass the subsequent q121 review with small point movement.
These paired one-replicate witnesses preserve all outcomes and do not qualify
bias, coverage, ordinary-JML structural inference or the wider planned designs.

The primary ordinary-model/one-family comparison uses centered facet effects
and explicitly estimated-normal MML; fixed-standard-normal fitting remains a
separate assumption/default-workflow comparison. JML does not estimate that
population distribution. Extreme training responses, category-support refusals
and scoring-source refusals remain part of output availability, alongside error
among returned estimates. Common-prior EAP is evaluated separately from native
Person estimates and does not supply structural confidence intervals.

The evaluation is organized around six comparisons: ordinary RSM/PCM
calibration, shared-owner GPCM with and without JML correction, changes in facet
structure and rating exposure, MML-specific slope/owner extensions, robustness
to population and assignment assumptions, and scoring/reporting from the same
calibrations. The basic calibration blocks include small through larger N;
additional structure/robustness contrasts have selected small and larger
anchors. This is not an exhaustive Cartesian grid or a fixed fit-count quota.

The initial controlled truths distinguish common steps, criterion-specific
steps and nonconstant relative slopes. The unit-slope PCM datasets also supply
the free-slope GPCM null comparison, so method comparisons reuse the same
responses. Fixed pair counts preserve the requested small N without adding
Persons for divisibility; additional independent rating events form a separate
exposure comparison. Broad performance mapping and precise confirmation of a
particular claim need different repetition planning. Counts of model fits are
not counts of independent datasets, and descriptive precision is not a
minimum-sample-size recommendation.

The facet comparisons distinguish adding task levels with more ratings from
adding levels at a fixed rating count. Robustness comparisons include population
shape changes at fixed mean/SD, missingness mechanisms at matched expected
missing rates, and response dependence with unchanged conditional category
probabilities. Their assignment laws are explicit: fixed planned rosters and
iid random rosters imply different covariance targets. These are design
specifications, not completed validation. The expanded comparison map must be
allocated to existing evidence, broad performance assessment or precise
confirmation before choosing repetitions; it is not a uniform execution quota.

Before sampling, check which designs the current algorithms can represent.
For corrected JML, increasing category/owner exposure can exceed the exact-state
limit independently of N; many small fixed-roster groups can also prevent the
current covariance from having full rank. Report these limits alongside
statistical performance, without silently changing the design to obtain a fit.

The MML slope-family comparison now fixes a response-preserving normal-scale
mapping and tests equal, either single-family and two-family slope truths.
Small-N extensions retain the requested N through explicit integer assignment
rules. The current two-family interval rank check remains the reference
procedure; its exclusions are not a general model-identification theorem.
Location-contrast intervals for estimated-population ordinary/one-family MML
now have an experimental native-scale consumer. Existing two-family location and
slope consumers need target-specific statistical qualification. Ordinary-JML
screening SEs and corrected-JML RootSE do not fill either structural-CI gap.

The implemented location-interval extension follows a
[source-based specification](inst/validation/internal-roadmap-0.2.4.md#native-mml-location-interval-extension-specification).
It reuses full joint marginal information and the existing contrast/result
objects for experimental native-scale model intervals in estimated-population
RSM/PCM and one-family GPCM. It requires local solution and covariance-grid
checks, preserves numerical refusals with their points, and does not impose
the two-family empirical score-rank gate on this model-Hessian procedure.
Population-relative contrasts need uncertainty in the estimated SD and its
cross-covariances; dividing native interval bounds by fitted SD is insufficient.
New sandwich support also needs complete parameter scores and a covariance
target matching fixed/random roster sampling. Both remain separate extensions.
The scoped consumer and saved-output path now pass focused checks on five
branch witnesses: estimated-population RSM/PCM, shared/separate-owner GPCM and
fixed-N(0,1) one-family GPCM, including fixed/adaptive integration and saved replay.
The fixed-normal witness used one new fit of an existing A/B dataset and exposed
a repaired population-metadata check; interval evaluation preserved its fitted
values. Help/NEWS now describe the experimental scope. Untested combinations
and finite-sample coverage remain unqualified; existing ordinary/two-family
interval rules remain in place.

The development study's selected-output summary now distinguishes incomplete
jobs, errors, unavailable outputs and design exclusions. It keeps conditional
interval inclusion separate from returned-and-covered rates over all eligible
replications, and paired error comparisons retain both marginal delivery counts.
Deterministic accounting checks and the two added consumer witnesses pass.
A repository-only stage runner now connects direct fixed-grid ordinary/one-family
native MML location outputs to scoring-source review, integration-only refinement
at q=31/61/121, immutable phase saves and the selected-output ledger. In one
retained N=60 GPCM workflow witness, scoring first qualified at q=121 while the
location intervals retained q=31. Deliberate interruption, restart and replay
without numerical recomputation passed; only q=61 and q=121 were newly fitted.
This is a workflow check, not a completed 50-replication condition.
The runner now also admits adaptive two-family location outputs under their
own per-Person scoring and empirical-score-rank requirements. A new N=20 witness
has 22 parameters: its intervals are excluded by the current rank rule, while
its point/scoring path still runs. q31 failed integration review; q61 returned
optimizer code zero but missed the terminal-gradient requirement, ending the
chain with source-reviewed points unavailable. A retained N=120 fit passed
scoring and six Rater location intervals at q31. Neither result estimates a
small-sample success rate or establishes general identifiability.

A separate single-call JML adapter saves ordinary/corrected fits before source
review, retains raw points, root states and local root covariance, and supports
restart/replay without refitting. The retained N=20 ordinary/order-2/order-4
witnesses preserve one scoring refusal and two conditional source admissions;
no new JML fits or structural truth intervals were produced. All five new
workflow jobs passed fresh-process replay without numerical computation.
The multi-output layer now shares fitting and scoring-source review across
declared facet locations and log-slope components, preserving each output's
selected stage and scale. Six retained jobs (nine fit stages) passed without
new fits or response generation; fresh-process replay and stage-matched public
results/report/plot-data checks also passed. Individual interval consumers
retain their own information calculations and acceptance rules. This does not
complete any new 50-replication condition. Other output families, bulk dispatch,
broad sampling, comparisons and the final report remain open. Ordinary-JML
structural covariance/bias and corrected-JML centering/generalizability remain
method questions; successful execution does not settle them.

Initial-call recovery is now a separate development ledger from scoring-source
admission. It maps prespecified location differences, native locations,
log slopes and canonical category probabilities to generating truth, keeping
finite numerical returns and the stored-numerical-pass subset separate.
Probability-grid errors and their Monte Carlo SEs use independent datasets as
the replication unit. One retained N=20 PCM dataset now has all eight A/B
calibration arms connected to recovery and paired summaries, with fresh-process
replay verified. This is a workflow/cost witness, not completed R=50 evidence;
scoring admission, interval selection and broader conditions remain separate.
The same eight fits now feed the declared Rater/Criterion differences and
GPCM slope-interval evaluation. All 14 eligible MML intervals returned at q31
in this one case; three MML scoring-source paths required a q61 refit, while
their already admitted q31 intervals remained unchanged. The 17 JML structural
interval targets remain unsupported. Fixed-normal PCM uses its existing public
interval procedure, with its own diagnostics. Truth joins, full-covariance
contrast propagation and stage-matched results/report/plot replay are checked;
no new public interval method or sampling-coverage qualification is claimed.

Scoring validation reuses these calibrations and distinguishes native training
scores, common-prior EAP, retained-prior scoring and the population-relative
two-family scale. Independent same-population, fixed-ability and shifted-cohort
panels have separate targets. Crossing calibration exposure with new-Person
scoring exposure distinguishes better calibration from more individual rating
information. Error and posterior-interval inclusion are
reported with score delivery; Monte Carlo uncertainty is based on independent
calibration replicates, not the total number of scored Persons. Saved-score
replay is distinct from scoring a new batch with a frozen calibration.
Estimated-population RSM/PCM portability remains unavailable; two-family
portability retains its fixed prior and no repeated-event extension. Numerical
scoring refinement does not repair a failed calibration-source check or supply
calibration uncertainty.

The retained N=20 PCM case now has all nine declared held-out batches connected
to eight calibration arms and two prior labels (144 jobs). Default-31 versus
refined delivery, conditional inclusion and paired errors retain calibration
replicates as their uncertainty unit. This execution exposed a public numerical
check gap: retained-prior ordinary RSM/PCM could return scores without the
EAP/SD comparison required for an explicitly supplied identical prior.
`predict_mfrm_units()` now checks every native batch; help/NEWS and saved-output
validation follow the same contract. All 18 affected saved PCM batches were
re-scored without recalibration or new responses and matched their checked
reference-prior scores/SD/bounds exactly. Source eligibility remains a separate
requirement. The original and repaired execution epochs remain distinct;
542 focused expectations and fresh-process score/summary/export replay passed.
This is one calibration replicate, not R=50 scoring performance or a completed
crossing of calibration exposures. Native training scores, the C-E scoring
adapters, full-map dispatch and the final comparison report remain open.

The numerical protocol now fixes initial settings, bounded integration
refinement and the calibration stage attached to each output. Retained replay
procedures keep their identities. Future random streams are allocated by
scientific comparison/replicate, independently of worker order. Selected broad
mapping rows now use **50 datasets per condition for the first stage**, following
the user's whole-roadmap decision. Maximum dataset-delivery Monte Carlo standard
error is .070711; near .95 coverage it is .030822 only if all 50 intervals return.
This replaces the earlier R=100 / .05 availability target and supports descriptive
mapping, not precise interval qualification or rare-failure guarantees. More
precise claims require their own variance/delivery-based allocation. A/B keeps
all 108 condition records, seven N values, both SDs and linked exposure arms:
5,400 condition-dataset records and 21,600 initial model/data configurations.
The [expanded allocation](inst/validation/internal-roadmap-0.2.4.md#expanded-allocation-shared-controls-and-scheduling-priorities)
assigns the same first-stage R=50 to C/D/E, with shared controls and identical
MML fits counted once. It also includes the previously uncounted A/B fixed-normal
population alternative: 7,200 extra configurations on the same inputs.
For one-family GPCM that arm retains geometric-mean-one slopes, so it restricts
common discrimination as well as the population; it is not merely rescaling.

The selected A-E map totals 30,600 first-stage condition-dataset records, including
600 stored-input candidates selected by original replicate IDs 1--50, and
135,800 initial calibration slots. The D-LR Gaussian core adds 10,800 linked
covariate views, no new responses, and 14,400 initial slots, giving 150,200
planned initial slots across A-E and that extension. All 1,200 stored inputs and all compatible
historical results remain retained with their actual sample and replication counts. The
[allocation registry](inst/validation/mfrm-wide-map-allocation-20261001.py)
enumerates 612 unique input-condition templates plus 68 aliases and checks the
counts; it has not generated response data or fitted models. Saved-stage reuse may
fill some slots; starts, numerical refinement, covariance checks and F scoring
add work. These are planning counts, not an approved compute budget or runtime
estimate. Schedule complete comparisons with their controls and small/large N:
common A/B, basic facet/allocation and slope-family comparisons, routine
missingness and weak links first; remaining elementary sensitivities next;
the two specified joint adverse comparisons last. Later priorities remain
required work. Historical JML N=400 evidence keeps its original allocation.
Source bridges, output gaps, executable generator/stream manifests and measured
workload review remain open. There is no automatic second batch of 50 or extension
until a significance/coverage threshold passes. Precise independent confirmation
has its own claims and allocation. Broad fitting has not started, and the paused
study remains separate. Six model-defined missingness-control rates are now
computed and agree across two integration coordinates. Generator checks and
checkpointing of resource-censored corrected fits remain before scaling those workflows.

A static source audit found no numerical change in the reviewed MML fitting
core or component-slope interval path relative to the frozen 400-case replay.
Retain those results under their original procedure; newly added location
intervals, scoring and output-specific refinement need their own evidence.
Earlier research JML solvers differ from the public procedure, whereas the
paused public order-2 study shares the reviewed current corrected-solver code
and settings. Its records remain preserved and incomplete. These distinctions
avoid blanket reruns without transferring findings to unevaluated outputs.

The work order is to define comparable targets and supported outputs, resolve
the issues affecting each output, freeze its evaluation design, and then assess
the declared procedure. Priorities are divided into complete comparisons,
retaining controls, small/large N and admitted methods; a priority group is not
one automatic launch. A missing MML interval consumer needs implementation
and numerical verification, while formal JML uncertainty needs a justified
target and procedure. More repetitions cannot replace either. An unresolved
corrected-JML interval question does not block ordinary-JML point/scoring work
or an independent MML decision once their own contracts are ready. Results,
plots and saved replay reuse these calibrations and their source-specific
checks; an additional report format does not require another sampling study. The
[internal comparison blocks](inst/validation/internal-roadmap-0.2.4.md#comparison-blocks-and-the-decisions-they-support)
record conditions, evidence reuse, dependencies and completion criteria.
The [family allocation ledger](inst/validation/internal-roadmap-0.2.4.md#family-allocation-ledger-and-work-order)
records selected, retained, deferred and confirmation work separately.
Results must lead to clear supported domains and limitations in help, plots,
reports and scoring. The
current work is design review; it adds no new inferential guarantee or change
to fitting defaults. G/D studies, missing-score workflows and feedback retain
their separate targets and validation requirements.

## Model scope

| Model or estimator | Available in the development version | Important boundary |
| --- | --- | --- |
| RSM/PCM | MML/JML fitting and established diagnostics, scoring, reporting and calibration workflows. | Population, anchor, category and interaction choices affect the meaning and availability of results. |
| One-slope-family GPCM | MML permits separate slope and step owners; JML uses a shared owner. Scoped MML intervals, profiles, comparisons and portable MML/JML EAP scoring are implemented. | Slopes multiply the complete adjacent-category predictor. Formal JML structural intervals and portable ML/WLE are unavailable. One-family GPCM does not yet have its own public EM implementation. |
| Two-slope-family GPCM / GMFRM | Explicit ordered facet roles, fixed-standard-normal fixed-grid EM or adaptive direct MML, summaries, conditional curves, experimental component log-Wald and location/contrast normal intervals, descriptive posterior response diagnostics, saved reports and separately checked fitted-object/portable conditional new-Person EAP with matching score attachments. Fixed-grid EM also supports profiles. | Exactly two non-Person facets, no anchors or population covariates, and one ability dimension. EAP intervals exclude calibration uncertainty. Curve/step intervals, model ranking, ordinary fit/bias tests and Wright/Pathway maps remain unavailable. Adaptive profiles are unavailable. Statistical qualification is unfinished. |
| Corrected GPCM JML | Explicit correction order, shared slope/step owner, adjusted-equation fitting, summaries, descriptive residuals and conditional new-Person/portable EAP. | Experimental; residual bias may remain. No automatic order selection, formal structural intervals, corrected Person ML/WLE or corrected RSM/PCM implementation. Local root standard errors are not qualified confidence intervals. |
| Random-rater and testlet extensions | Separate shared-rater and Person-local testlet RSMs, with scoped scoring and descriptive comparisons. | These are distinct models with limited uncertainty support, not a combined random-effects GMFRM. |

GMFRM denotes a generalization of many-facet measurement; unequal
discrimination is not strict equal-discrimination Rasch measurement. The
estimation core is frequentist. EAP scoring conditional on calibration does
not make the calibration model fully Bayesian.

### GPCM: specific restrictions and their exit conditions

The two-family route still has a declared slope product and identification
scheme. Removing a restriction requires a defined response equation, an
identified scale, matching uncertainty and useful output. It cannot be achieved
by changing the label used for the model.

Profiles are optional sensitivity analyses; better coverage than Wald
intervals has not been established for the current two-family procedure.
Numerical convergence, accurate integration and sampling performance are
separate requirements. Small or weakly determined slopes can affect all three.

Saved fitted objects, portable calibration and new-Person scoring are different
capabilities. Conditional scoring intervals omit calibration uncertainty unless
explicitly stated otherwise. A saved report does not add a missing scoring model.

## Generalizability theory

`mfrm_multivariate_gstudy()` and `mfrm_multivariate_d_study()` support one or
two named random facets, crossed or with one nested within the other while
Persons are crossed. Score components are fixed. ANOVA handles complete
balanced data; MINQUE(0) handles identifiable incomplete or unequal sources.

D-studies project complete balanced future scenarios with the supported
structure, weighted composites or signed score differences. Sparse source
data require an explicit future plan; these projections do not estimate the
reliability of an arbitrary sparse future roster. Negative or indefinite
component estimates remain visible, and availability is assessed separately
for each metric.

`mfrm_multivariate_d_compare()` supplies approximate paired-delta intervals
for prespecified plan differences with two crossed facets under an explicit
normal-random-effects assumption. Nonnormal-robust, nested and simultaneous
intervals, adaptive weight selection and unequal future allocations remain
outside this scope.

Tables and 2D plots should make tasks, raters, weights, workload and uncertainty
understandable. A multivariate score does not require a 3D display. These
observed-score analyses do not estimate latent MFRM reliability or pass/fail
classification accuracy, and missing-row omission does not correct selective
assignment or nonresponse.

## Rater feedback across application areas

Feedback connects exposure and overlap, severity with its reference and
available uncertainty, category use, fit and selected unexpected ratings.
Individual sheets accept native additive RSM/PCM and experimental two-family
GPCM MML fits. The latter separates location and component slope, retains
saved experimental slope intervals and descriptive posterior residuals, and
keeps unresolved rows visible. Location/step intervals are not displayed in these
sheets; separately requested location/contrast intervals belong in the analyst report.
One-family GPCM, interaction, imported, random-rater and testlet models require
their other supported reports.

Severity, discrimination, inconsistency and differential functioning answer
different questions. None alone measures assessor competence or establishes
that training, exclusion or rubric revision will help. Useful feedback keeps
missing results visible and protects other recipients' information.

The next integration work must preserve these meanings from summary and
figure through report and reopening. Beginner-facing guidance should explain
what to review and what the result cannot establish. Clear writing and author
review do not replace evidence from actual novice readers.

## External features, grouping, and missing values

Mixed-feature PAM and hierarchical clustering, numeric PCA/k-means,
dendrograms, profiles and setting comparisons are implemented. Persons,
raters and tasks are grouped separately from their own feature tables and
joined to ratings by ID. Groups are descriptive, not latent ability levels,
causal effects or rater-quality classes.

Feature-imputation comparisons preserve the supplied imputation model and
eligible cells. Co-membership across completions is sensitivity to that model,
not Rubin pooling or sampling stability. Assigned-response imputation review,
fitting and eligible pooling are separate workflows. Unassigned ratings are
not imputed; observed scores and the planned assignment remain intact.
Missingness assumptions need substantive justification, and current support
does not imply extended-model imputation or pooled Person scores.

## Rater assignment and anchors

There is no single recommended percentage of common ratings or anchors.
Assessment teams need guidance for complete and incomplete rating designs,
including direct anchors, group anchors, and unanchored linking.

The relevant questions include:

1. What contrasts are identified in complete versus connected
   incomplete assignments, and how much information supports them?
2. Do all-rater common Persons, rotating panels or random subsets cover the
   ability range and provide useful overlap at a comparable rating budget?
3. What changes when bridges weaken or disappear, or when the linked groups
   differ in ability distribution?
4. Which values are fixed externally, and is uncertainty conditional on those
   values or intended to include their calibration uncertainty?

Observed common Persons connect data; they are not automatically fixed ability
anchors. Connectivity alone does not establish slope identification or adequate
precision. Evidence from one allocation pattern will not be generalized to all
sparse designs. Planned nonassignment, missing assigned ratings and selective
nonresponse remain distinct. The two-family fitter currently has no anchor
support; anchor findings from simpler models do not establish that support.

## Random-effects MFRM and testlet covariance

Shared-rater effects and Person-local testlet effects use different sharing
units and prediction populations. Existing implementations must retain those
distinctions when compared with ordinary MFRM on matched data. Ordinary fit
cutoffs or regular chi-square variance tests cannot be transferred automatically.

Task-versus-criterion planning and task-specific dependence are useful future
questions. A local variance alone does not diagnose halo, impose equal task
weights or supply a G-theory reliability coefficient. Combining effects or
adding random slopes requires a separately defined and evaluated model.

## One-ability checks and residual exploration

A one-ability model can be investigated using substantive structure, residual
patterns, conditional comparisons and appropriately calibrated simulation.
Residual PCA or a residual network can reveal patterns to investigate; neither
alone proves the number of traits. Sparse pair exposure, shared effects and
model-fitting uncertainty affect interpretation. Descriptive residuals do not
automatically provide calibrated dimensionality tests.

Native multidimensional MFRM remains deferred. It is not necessary to implement
every alternative model before investigating a one-ability assumption, although
formal model comparison requires explicitly compatible models and targets.

## External comparison

TAM, ConQuest, sirt and GENOVA are references for explicitly matched models,
scales and quantities. Agreement in conditional probabilities, fixed-calibration
scoring or a variance formula does not establish free-estimator equivalence,
interval coverage or suitability for another design. Reproducing all features
of another package is not the goal. Core analysis and beginner examples should
work without optional external software.

## Before CRAN submission: interface and GPCM review

### First integration work package: API names, arguments and help

Finish one recommended route per task through existing functions and result
classes. Explain essential inputs and consequential defaults before expert
controls, including what omission or `NULL` changes. Keep ability scoring
separate from response prediction and distinguish different uncertainty targets.

The recommended PAM and imputation-review names have compatible older aliases.
Keep established argument spellings where a cosmetic rename would add
ambiguity. Standard `summary()`, `plot()` and `confint()` conventions remain
useful. Any deprecation needs a specific replacement and a migration path.

Help, examples, returned tables and plots must agree about model support.
Figures should use readable labels, non-color distinctions, exact plotted data
and usable title/annotation controls. Reports and saved-plot replay must not
silently start expensive fitting or interval calculations.

## Milestones and the end of this development cycle

Completion means that the agreed analyses work within their declared scope,
have evidence appropriate to their claims, and remain interpretable through
plots, reports and saved reuse. The unfinished joint-slope and corrected-JML
work cannot be declared complete merely by adding a limitation to the help.
A change to the agreed release scope requires an explicit decision.

Final checks must concern the assembled source and its documentation. Local
completion, repository publication, CRAN submission and CRAN acceptance are
different states. Completion of 0.2.4 does not mean every future model or a
universal accuracy or capacity guarantee has been delivered.

## Post-release priorities

After the integrated release, choose work from demonstrated assessment needs:

- Improve adoption, individual feedback, accessibility and calibration reuse.
- Extend G/D planning for a specified unsupported structure or feasible roster.
- Investigate calibrated screening or dependence when it changes a review decision.
- Address missing-response sensitivity, feature stability or new-entity assignment
  with explicit inference or prediction targets.
- Improve measured bottlenecks for actual workloads while preserving results.
- Consider additional slope structures, multidimensional models or process models
  only after defining their constructs, identification and useful outputs.

Broader structures are not automatically assigned to 0.2.5. Maintenance of
supported analyses and compatibility continues alongside selected extensions.

## Milestones after 0.2.4

Each selected extension should connect a user question to a defined method,
appropriate evaluation, a complete usable workflow and a maintained release.
An inconclusive result can justify revising the approach or retaining the
existing method; it does not automatically require a larger experiment.

## Compatibility principles

- Preserve model, scale, categories, anchors, score identity and uncertainty
  meaning across saved results, tables, figures and exports.
- Keep valid older calls and saved objects compatible; explain changes and
  migration when results or formats must change.
- Keep examples usable, plots in English and unavailable results visible.
- Keep implementation history and operational decisions in maintainer material,
  with analysis guidance in help and user-visible changes in NEWS.

Maintainers should use the [internal work plan](inst/validation/internal-roadmap-0.2.4.md)
for execution order and evidence requirements.
