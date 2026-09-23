# Person-specific testlet API — local checkpoint, 2026-09-23

The initial fixed-N(0,1) checkpoint is retained below. The later
[estimated-population checkpoint](#estimated-ability-population-20260923)
records the current default, migration and its separate evidence.

## Question and scope

Roadmap row 3b needs an explicit rating-level membership model, rather than
promoting a calculation hard-coded to two raters and three criteria. The new
local API combines fitting, numerical checks, conditional Person scoring,
saved results, English plots, help and a runnable beginner tutorial. This is
an initial bounded interface, not completion of calibration-aware uncertainty,
general model diagnostics or coverage qualification. Nothing is committed,
pushed, merged, deployed or released at this checkpoint.

The adjacent-category RSM logit is theta_p + gamma_pb - X beta - delta_k.
Theta is N(0,1); independent gamma terms are N(0,v), shared only within a
Person/testlet group. Reusing a label across Persons does not share a local
effect. Fixed facets retain separate sum-zero roles. Free steps identify
overall location. Unit weights, additive fixed facets and one common variance
are supported. A known variance, including zero, can be specified explicitly.
Overlapping, heterogeneous/correlated or shared-rater local effects, PCM and
joint multidimensional abilities remain outside this route.

Unequal observed blocks are allowed. Fitting requires at least two Persons
with multiple observed testlets and at least two with within-testlet repeated
ratings, observed declared categories and fixed-facet levels, and full fixed
design rank. These are initial eligibility checks, not proof of estimability.
The fixed-normal population and independence from assignment remain model
assumptions. Assigned NA scores require explicit omission; absent assignment
rows are never added or imputed.

## Computation and independent evidence

Nested Gaussian integration first integrates each local effect conditional on
ability, multiplies block likelihoods, then integrates ability. Fixed-effect,
step and positive-variance gradients are analytic. At zero the one-sided
variance score uses half of (block residual sum squared minus block response
variance sum), averaged over the ability posterior. An exact zero submodel and
two positive starts are retained. Native convergence, search boundaries,
projected gradient, higher-order agreement and local information are checked
separately. A small gradient alone does not qualify a fit.

`inst/validation/testlet-api-checks-0.2.4.R` imports only retained independent
reference function definitions, without rerunning their experiments or TAM.
Across **25 fixed-point cases**, maximum absolute differences were:

| Quantity | Maximum difference |
| --- | ---: |
| Marginal log likelihood | 2.274e-13 |
| Transformed analytic gradient | 1.315e-13 |
| Person posterior mean/SD | 8.243e-13 |

Cases include variance from 1e-10 through 16 plus exact zero, large offsets and
steps, incomplete blocks, entire missing Persons, empty and extreme-score
patterns. Some patterns are eligible only for evaluating a fixed calibration,
not fitting; the comparison does not override fitting guards. Equal-order
agreement checks the implementation, not universal quadrature adequacy.

An independent four-dimensional tensor sum additionally verifies a **three-
testlet, four-category, unequal-block** likelihood. Its independently built
Gaussian rule and direct probabilities agree to 1e-11; finite differences check
every coordinate to 1e-7 and a Richardson one-sided derivative checks zero
variance to 1e-6. Label reuse across Persons and row permutation preserve the
likelihood. The retained 33-observation estimation fixture reproduces variance
0.98832920 and log likelihood -30.4046955 within declared tolerances.

A new 60-Person example uses three testlets, two criteria, four categories,
unassigned blocks and assigned missing scores. All numerical/information checks
pass. An independent `nlminb` optimization at 243 points, started away from the
API solution, agrees within 1.01e-5 per coordinate and 1e-7 in log likelihood.
Estimated local variance is 0.4071 (generating 0.49); criterion effects are
-0.2890/+0.2890 (generating -0.3/+0.3). This single example checks execution and
optimizer agreement, not general recovery or statistical accuracy. The first
alternative run with overly strict relative tolerances returned false
convergence; the recorded final comparison uses rel.tol=1e-10, x.tol=1e-8 and
retains native convergence and objective/parameter differences.

The default 31-point order was insufficient for the balanced zero-variance
fixture, and 61 points were insufficient for `example_core`. Their checks
correctly blocked scoring. The boundary test uses 61 points; the public example
uses 121. No tolerance was relaxed to accept those failures. Optimization uses
tighter stopping criteria so objective-scale stopping is less likely to leave
an unresolved gradient.

## Uncertainty, failure and reuse behavior

Calibration intervals use observed information and are withheld at estimated
zero variance. There is no regular variance interval. Conditional Person
scores integrate the continuous ability posterior and invert its continuous
CDF; they do not use grid-CDF endpoints. Both local quadrature orders must
agree. Independent tail-mass checks include a binary, no-fixed-facet model at
known zero variance, where the density reduces to a normal prior times four
Bernoulli likelihoods. Initial test failure in that check came from the
reference integral's default tolerance; tightening the independent integral
resolved it without changing production scoring or acceptance thresholds.

Scoring holds all fitted calibration values fixed, including an estimated
zero variance. It does not propagate calibration uncertainty. All supplied
rows are scored jointly without appending cached responses or using stored
local modes. New Person/testlet labels are allowed; fixed-facet levels must
already be calibrated. Entirely missing Persons return the N(0,1) prior with
`prior_only` status and an open plot symbol. Numerical failures retain labeled
`unavailable` rows and reasons. A mocked failure verifies row retention,
without treating that mock as numerical-accuracy evidence.

Reuse the existing 1,200-dataset two-rater/three-criterion study. At positive
local variance its conditional plug-in Person intervals lost 1.278 percentage
points of coverage versus oracle calibration at N=24, and 0.380 at N=120.
That study was not rerun, extended to arbitrary memberships, or recast as
calibration-aware interval evidence. Numerical agreement cannot settle that
remaining inferential requirement.

## Checks and user-facing integration

Focused checks: 64 testlet expectations, four namespace expectations, 67
interval-guide/visual-reporting checks and 79 existing ggplot conversion checks
pass without failures, warnings or errors. The new zero-variance, no-fixed-
facet and new-membership test is included. No full package suite, old numerical
experiment or hosted CI was repeated. A separate R session reproduces the
saved three-block scores exactly without loading RTMB.

`vignettes/mfrmr-testlets.Rmd` executes the complete example, including source
fit readiness, observed-rater feedback, conditional Person scores, partial and
complete assigned missingness, and saving. Three rendered plots were visually
reviewed: labels and interval meanings are in English, the prior-only Person
remains visible, and margins do not clip notes. Reference pages, README, NEWS,
the interval guide and both roadmaps distinguish implemented interfaces from
unfinished statistical qualification. Internal records stay excluded from
public package content.

Eleven affected local pages and 42 changed-topic links/assets were checked;
visible text contains no internal paths or development-record references. The
partial preview does not rebuild eight unrelated existing tutorials linked by
site navigation; their source articles remain present. This is not a full-site
link check. Reference examples share the executed tutorial workflow and were
not refitted a second time solely to decorate reference pages.

One source build completed without warnings. Fifteen selected API, help,
namespace, vignette and test files in the archive match the working sources
exactly. Internal records, validation output, local libraries and vignette
caches are excluded. Archive SHA-256:
`a5d79dd1e6f5d71f15e6982936f0a9201137b0a9e081a8b88c37058977c9ae76`.
The build used `--no-build-vignettes --no-manual`; tutorial execution and plot
review were separate. This is not an R CMD check or five-platform CI result.
Evidence and source hashes are retained under
`validation-results/testlet-api-20260923/`.

The initial next-step proposal was roadmap row 3c. The user's subsequent
2026-09-23 instruction defers multidimensional MFRM in favor of existing-API
integration. Dimension assignments, scales/loadings and covariance decisions
remain open. Existing unresolved inference requirements stay in rows 2, 3a and
3b; they are not silently marked complete.

## Same-day follow-up: connections to existing APIs

The user prioritized existing help and visualization over multidimensional
model decisions. `mfrmr_output_guide("models")` and the main workflow help now
distinguish fixed facets, shared random raters and Person-specific testlets,
especially the different meanings of `predict()`. The workflow help also
distinguishes latent testlet variance from observed-score G-study components.
The routine beginner route remains unchanged.

Testlet `plot()` payloads now retain titles, axis labels, captions and notes
alongside their original tables/settings. `plot_data()` and
`plot_data_components()` expose them directly. Dedicated `as_ggplot()`
conversion preserves interval endpoints, all requested labels, prior-only
symbols, and empty/unavailable rows, including all-unavailable displays.
Earlier saved plot payloads recover missing display metadata without fitting.
The tutorial demonstrates optional ggplot styling and export, CSV status/reason
retention and RDS saving. Its updated workflow ran successfully; the additional
rendered figure was visually checked. Twelve affected pages and 81 relevant
links/assets passed the local inspection without visible internal paths.

Ordinary diagnostics and comprehensive reporting remain unsupported for the
extended models. Their main entry points now explain this and direct users to
the model's own summary/plot/data methods; they do not silently refit or alter
classes. The existing report/export entry points continue to require an
`mfrm_results` object. No testlet Wright-map, Infit/Outfit, MI pooling or
portable-calibration support is claimed by the graphics integration.

43 new integration checks plus 79 ggplot, 316 output-guide, 67 interval/visual
guide and four namespace checks passed without failures, errors or warnings
(509 total). Comparing parsed definitions against the prior checked archive
confirmed that testlet estimation and scoring functions are unchanged; only
the forest payload's display metadata changed in those files. The numerical
studies and full suite were not repeated. The edited tutorial was executed
once to check the new user workflow; this is not a new numerical-accuracy
experiment. Evidence is under `validation-results/testlet-integration-20260923/`.
The earlier archive/hash above describe the earlier checkpoint, not this
updated source. No new archive build, hosted CI or publication was performed.


## Follow-up: stored-result reporting and export, 2026-09-23

This supersedes the preceding comprehensive-report restriction. Both separate
model classes now enter `mfrm_results()` -> `mfrm_report()` ->
`export_mfrm_results()`. The adapter collects calibration, settings, numerical
checks, assignment/omission counts, interval meanings, optional saved
predictions and random-rater bootstrap intervals. It never fits, scores,
computes diagnostics or resamples. Model adequacy remains unassessed even when
numerical checks pass. Ordinary diagnostics and APA templates are unavailable;
all report styles retain the same scoped evidence and limitations. The Shiny
viewer, Wright maps, MI pooling and portable calibration remain unsupported.

New predictions retain their calibration/column-role/level/basis/settings and
numerical-check identity, plus observed-rater conditional moments. Matching is
exact, not inferred from coefficients alone, and does not duplicate the
training rows. Older predictions need explicit regeneration from the saved
fit before attachment. Bootstrap results must carry their exact source fit.
RDS/replay restores results without fitting; requesting replay also writes its
RDS dependency. Tables retain prior-only/unavailable Persons, omitted rows,
every bootstrap trial and infinite endpoints. Export indexes use the actual
model-specific figures rather than requesting unavailable Wright maps.

Validation: 816 focused checks passed without failures, warnings, errors or
skips across extended reporting, existing results/report/export, output guide,
namespace and testlet display integration. The 94 extended checks were rerun
once after clarifying that ordinary APA templates remain unavailable; all
passed. Model-computation entry points were mocked to error in collection and
replay tests, so silent fitting/scoring/diagnostics would fail those tests.

Reused the saved 60-Person/three-block fit and six-rater fit with 99 saved
bootstrap refits. Both newly added tutorial report chunks executed without
refitting or resampling. Refreshing four prior Person predictions added source
metadata while leaving their numerical table identical. An additional saved
fit prediction checked prior-only reporting. Default bootstrap plots also
matched a stored 90% error-method interval, rather than silently using the
original settings' 95% studentized interval. Six local HTML pages and 16
relative links passed; no internal local paths were exposed in their text.
The exported Person and bootstrap figures were visually inspected.

Source build completed with `--no-build-vignettes --no-manual`. The final
filtered distribution was refreshed from local source before building; this
avoided copying the 6.8 GB of excluded validation evidence again. Distributed
files match current source (DESCRIPTION carries build metadata). Validation
records, caches and the optional local library are excluded. Final archive:
`validation-results/extended-reporting-20260923/source-build/mfrmr_0.2.4.tar.gz`;
SHA-256 `b76032e103eba619abefb9a77d6ea92679491719fa3d8ede4cd4227ece4c61e8`.
Evidence is under `validation-results/extended-reporting-20260923/`.

This is local stage-1/stage-4 interface integration. No full-suite repetition,
new coverage study, complete package check, CI, commit, push, main integration
or publication was performed. General interval accuracy, calibration-aware
Person intervals, model diagnostics and wider model/G-theory structures remain
unfinished; multidimensional MFRM remains deferred by the user.

<a id="estimated-ability-population-20260923"></a>

## Estimated ability population, 2026-09-23

**Question.** M2 identified that fixing both the Rasch slope and ability
variance at one imposes a substantive population restriction. Can testlet
fitting estimate that variance while preserving effect sharing, conditional
scoring, the earlier fixed-population reference and saved-result meanings?
This checkpoint implements that decided change; it is not a new coverage
study or completion of the whole model workflow.

**Implemented contract.** `fit_mfrm_testlet(..., person_sd = NULL)` estimates
normal ability variance by default. A positive known SD fixes the population;
`person_sd = 1` reproduces the earlier restriction. Mean zero, free step
location, unit slopes, additive fixed facets, one common local variance and
non-overlapping memberships are unchanged. `person_variance_max = 16` bounds
estimated variance (not SD); a fit at the cap requires review. There are no
new dependencies or substantive dimensions.

Ability variance is appended after local variance in new parameter vectors.
Likelihood evaluation scales the ability nodes; posterior moments use that
same scale. At positive ability variance w, the derivative integrates the
conditional ability score times theta/(2w). At w=0 it uses half of the
conditional likelihood's second derivative divided by its likelihood:
`0.5 * (total_theta_score^2 + total_theta_loglik_curvature)`. Each local
block first integrates its own effect; the total score includes cross-block
terms for the shared ability. It is not an independent ability per block.

The optimizer evaluates both variance faces and the joint-zero submodel,
retains all starts, and checks one-sided variance scores. Tiny negative
trial variances from L-BFGS-B floating-point arithmetic (observed about
`-4.94e-17`) are projected to zero only inside the optimizer adapter; values
below `-1e-12` error. This does not replace variance-boundary scores or relax
readiness tolerances. Interior covariance includes the estimated ability
variance as a nuisance parameter. Either estimated-zero boundary withholds
regular calibration intervals. Information checks at a boundary concern
only the remaining free coordinates, not regular variance inference.

Continuous Person scoring integrates in standard-normal coordinates and
transforms moments/quantiles using the fitted SD. It conditions on the fitted
ability and local variances; neither parameter-estimation uncertainty is
propagated. Entirely omitted Persons receive that population, labeled
`prior_only`. If ability variance is estimated at zero, all requested Person
rows remain `unavailable` with a reason, rather than reporting zero-width
ability intervals. Reports expose separate local/ability variance rows and
their fixed/estimated/boundary status. Plot and report source checks retain
the matching population. Earlier saved vectors without the appended
coordinate still mean N(0,1), not the new fitting default.

**Validation and results.**

| Check and purpose | Result |
| --- | --- |
| Independent tensor integration for three testlets/four categories, with ability variances .49 and 2.25, a local-zero face, an ability-zero face and the joint-zero corner | Likelihoods and all analytic derivatives agree with the separate tensor calculation and central/one-sided finite differences under the declared test tolerances. This checks sharing and the variance scores, not just optimizer convergence. |
| Known-zero local variance versus a separately fitted binary normal Rasch likelihood | Parameters, log likelihood and the full step/ability-variance covariance agree with adaptive integration plus `nlminb`/independent numerical curvature. This verifies the estimated-population zero reduction without depending on a native model's coding. |
| Known N(0,1) branch | Existing fitted variance/log-likelihood, continuous tails, labels and omission reference tests pass after explicitly setting `person_sd = 1`. The historical standalone reference script is also pinned to that restriction; its larger study was not rerun. |
| Nonunit population, source matching and failure behavior | Continuous equal-tail bounds agree with independent nested adaptive integration. Known SD .7, invalid SDs, estimated zero, upper search cap, prior-only rows, incompatible prediction attachment and save/reload checks pass. |
| Reuse the saved sparse 60-Person/three-block source | The new default fit estimates ability variance .7876332 and local variance .3494542; numerical and information checks pass. This is a deterministic execution/reference case, not a population recovery claim. |
| Execute the public tutorial with its new default | Ability variance .9649161 (SD .9823014), local variance .04001545; numerical and information checks pass. Person scoring, omission/prior-only handling, figures, common reports and export/reload execute. Four rendered figures retain English labels; the three base plots were inspected visually. |
| Fresh R session | Recomputed tutorial scores and variance reports match saved objects. A real earlier saved three-block fit still scores under N(0,1), with both requested Person rows available. |
| Changed help and source | Targeted Rd regeneration, parse/check and HTML generation pass. The isolated roxygen run's topic-discovery warnings are checked against actual local aliases. `git diff --check` passes. |

Focused tests cover `test-testlet.R`, `test-testlet-population.R`,
`test-testlet-integration.R` and `test-extended-results.R`. The first run
exposed two reporting-fixture assumptions: variance output now has two rows,
and scoring should use the prepared input design when reading a legacy
parameter layout. These were corrected; affected rechecks pass. An additional
independent covariance assertion was checked with the population test file.
No unchanged full suite or previous coverage simulation was repeated.

Evidence is `validation-results/testlet-population-20260923/`: focused logs,
test results, the saved sparse-source fit, executed tutorial HTML/RDS and
figures, changed help, fresh-session replay and changed-source identity.
The tutorial and README/package help describe actual current behavior;
internal milestone language is confined to the roadmap/evidence records.

**Remaining work.** Statistical qualification for the newly estimated
population is open. Previous fixed-population coverage evidence cannot be
relabelled for this estimator. Shared-rater still uses fixed N(0,1); its
population contract, proper Person scoring and interval issues remain.
The same-data ordinary-model comparison API, descriptive response diagnostics
and matching Wright/pathway displays are also outstanding. M3 and M5 are not
complete. No commit, push, hosted CI or publication was performed here.

## Task and rubric applications, 20260923

The user requested practical decisions specific to the testlet extension:
allocate tasks versus criteria, examine possible halo, compare task-specific
dependence, and handle unequal rubric lengths. The new public
`vignettes/mfrmr-testlet-applications.Rmd` addresses all four while separating
implemented calculations from unsupported interpretations. Existing testlet
help, scoring help, the workflow tutorial, output guide, README, NEWS and
roadmaps link or explain the same scope. This is M1/M4 application work; it
adds no model family and does not close estimated-population qualification.

### Executed example and its targets

One seeded synthetic calibration has 80 Persons, three tasks, five parallel
criteria and 1,200 assigned ordinal responses, all observed. True ability
variance is 1 and common Person/task variance .8. Criterion functioning is
deliberately identical to isolate grouping; substantive language/music/clinical
criteria are not declared interchangeable. Both fitted models estimate normal
ability variance. The testlet estimate is .6951 for local variance and 1.3341
for ability variance. The comparator fixes local variance to zero and thus
uses the independent RSM submodel through the same API. It does not isolate
all fitted calibration changes or certify ordinary-versus-extended superiority.

Three future plans each have four ratings: 1x4, 2x2 or 4x1 task-by-criterion
allocation. All 81 possible response vectors are scored with public
`predict()`. Their probabilities are calculated directly from the RSM and
normal integrals at orders 61/121; all are retained. There is no selective
response-pattern sampling or replacement. With calibration held fixed, the
example reports `E_Y[Var(theta|Y)]` and
`1-E_Y[Var(theta|Y)]/Var(theta)`. The latter is a model-implied marginal EAP
reliability, not G/Phi, frequentist coverage or a calibrated-error guarantee.

| Tasks x criteria | Testlet RMS posterior SD | Testlet model-implied reliability | Independent model-implied reliability |
| --- | ---: | ---: | ---: |
| 1 x 4 | .8340 | .4786 | .6424 |
| 2 x 2 | .7730 | .5521 | .6424 |
| 4 x 1 | .7319 | .5984 | .6424 |

The appropriate comparison is across allocations within each fitted model.
Parallel criteria and independent task effects are material assumptions;
content and cost can alter the practical choice. The one-task plan uses an
already available multi-task calibration, not a one-task variance fit.
The article's enumeration helper is example code, not an exported/general
planning solver. The figure uses a supported saved scoring-result plot.

For five-versus-two-criterion tasks, start with all seven scores equal to one
and add one point at one task or the other. The full roster is rescored once
per hypothetical profile. EAP changes are .1740 versus .2860 under the testlet
fit and .2186 in either position under the independent fit. These are
conditional response sensitivities, not estimated task weights or errors
against true ability. Likelihood-based dependence adjustment does not impose
policy weights or establish that every bias has been corrected.

### Explicit boundaries and literature reuse

A common variance cannot rank tasks by dependence. Adding a fixed Task facet
changes average difficulty, not the number of local variances. Separate
single-task fits confound normal ability and local variances; a heterogeneous
extension needs a joint linked-task model, variance-boundary handling and its
own comparison/uncertainty qualification. It remains outside the currently
agreed common-variance release scope, not silently implemented by relabeling.

A large local variance does not identify halo or criterion separability.
Task performance, omitted dimensions, common stimuli and rating processes
can share the same statistical signature. Independent ratings/process evidence
and a defensible comparison design are needed to investigate cause. The
single-membership API does not simultaneously separate crossed task and rater
local effects. Unequal observed assignments and omitted assigned scores also
remain distinct from intended policy weighting.

Reuse the complete prior page-by-page readings of Wang/Wilson's 2005 Rasch
testlet and random-effects facet papers. This follow-up rereads PDF pages
4, 5, 17 and 20 of the first, and 4, 5, 19 and 21 of the second. Equations,
Table 6 and Equation 35 were additionally checked as rendered pages. Their
separate local variances are explicitly distinguished from mfrmr's common
variance. Zotero was accessed read-only; source PDFs were not copied into
package content. A publisher abstract of Bechger et al. (2010) was also located,
but no library item was found and no halo detection method was adopted from
that abstract. The two fully read papers remain the tutorial's references.

### Verification and preserved numerical failure

- The first independent-submodel fit at Q61 failed higher-order checks
  (log-likelihood difference .0001073, gradient difference .0037344) despite
  optimizer code zero. It is retained as `independent-fit.rds` and in the
  preparation log. Q121 resolves this example without changing its data,
  seed, model or tolerances. The testlet Q61 fit passes its checks.
- The complete article executes and renders. Every one of its 486
  model/plan/pattern scores is available. Probability sums differ from one
  by less than 3e-14; maximum 61/121 probability difference is below 2e-12.
  Averaged posterior first/second moments reproduce the fitted prior's zero
  mean and variance within 1e-7 (observed discrepancies below 6e-14).
  These numerical identities do not validate the assessment assumptions.
- Known-zero grouping invariance is checked for all 81 patterns across all
  three plans. Unequal-block scoring is unchanged by row permutation and
  block relabeling. Report tables retain the exact matching scores.
- A fresh R session replays reports and base/ggplot scoring views with fit,
  prediction and numerical-kernel calls replaced by errors. The updated
  output-guide tests pass. Both changed Rd topics generate HTML; the article
  figure is visually checked for readable labels and correct conditioning.
- Parsed testlet fitting/scoring code is identical to the frozen pre-change
  implementation; edits in these R files are documentation only. No full
  test suite or previous stress/coverage study was rerun. The prototype and
  executable tutorial use the same example; their repeated execution is
  not counted as independent statistical evidence.
- A final prose sentence was added to the rendered preview without rerunning
  unchanged computations. Its local workflow link points to the existing
  rendered workflow article; package source keeps the normal sibling article
  link. This is a local preview, not a full-site build or publication.

Artifacts, original failures, rendered help/article, saved fits/scores,
verification logs and source/evidence SHA256 manifests are in
`validation-results/testlet-applications-20260923/`. The shared-rater integration
failures and remaining model/MI qualification in the active roadmap are still
open. M5 local completion and M6 publication remain unreached.


## Estimated-population comparison and numerical selection repair (2026-09-23)

The [480-dataset comparison](testlet-estimated-qualification-record-0.2.4.md)
now examines conditional source-Person scoring against matched ordinary RSM
and known calibration. All original failures remain; fourteen erroneous
failed-start selections are repaired under unchanged numerical checks.
The post-repair replay has complete panels in all four conditions, but only
the two larger balanced conditions meet the bounded primary rule. Small/sparse
coverage and regular calibration-interval qualification remain inconclusive.
EAP MSE increases in the two balanced positive-dependence conditions despite
improved coverage relative to ordinary RSM. Help, NEWS and both tutorials
retain that distinction. This completes the planned comparison and repair,
not M3/M5 or a general inferential guarantee.
