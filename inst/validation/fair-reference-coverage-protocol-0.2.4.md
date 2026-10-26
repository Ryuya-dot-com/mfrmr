# Common-plan estimated-anchor delta coverage: fixed-Person protocol

**Fresh consistent-estimator pilot, fixed before generating outcomes.** Use
matched weak/strong cells 13--24, both RSM/PCM, with 20 independent datasets
per N20 cell, 6 per N60 cell and 3 per N240 cell (116 datasets total). This is
a finite-sample diagnostic/cost pilot, not confirmation or a completion of
the broad 30,600-record program. Seeds start at 625100000 + 10000*paired_cell
+ replication, distinct from previous ordinary preflight/confirmation and
refit seeds. Retain the existing degree-matched assignments, common uniforms
within each weak/strong pair, exogenous missingness, unrounded anchor and
independent generating truth. No failed dataset is replaced or extended.

Compare complete ordinary and Jeffreys calibration/anchor/scoring/union chains
on each dataset, with declared preserved categories and unchanged numerical
gates. Public delta calls jointly return the two Person scores/covariance;
derive the paired difference by the already checked linear contrast identity
instead of repeating expensive covariance calculation. A direct response-based
Hoeffding reference is computed independently of fitting, so a failed fit does
not hide an otherwise defined bound. When a scoring fit is available, check
its bounds against the public bounded method. Do not present the independent
reference as a new fitted-model estimator or as public fit availability.

Report unconditional point/interval availability, covered-and-available rate,
coverage among available intervals with exact binomial Monte Carlo intervals,
point bias and its MCSE on all finite points and the available subset, RMSE,
empirical SD versus RMS SE, interval width, failure stage/reason and timing.
Keep targets/methods/designs paired: paired error/coverage differences use
their common complete subset with its denominator, not independent-sample SEs.
These subset differences do not replace unconditional method summaries.

At nominal coverage .95, MCSE with all intervals available is .0487, .0890 and
.1258 for 20, 6 and 3 draws (worst-case .1118, .2041, .2887). Even complete
success cannot establish .95 availability with these counts. The pilot cannot
promote CIEligible, demonstrate equivalence or rank small differences. A Monte
Carlo interval wholly outside the existing [.93,.97] coverage band triggers
cause/scope review; overlap stays unresolved. This diagnostic screen has no
familywise qualification claim. Do not grow the sample until it passes.
Existing stored fitting plus new covariance costs suggest roughly 20 minutes
for this allocation; this is a budget estimate, not a timing promise. Save
every completed dataset and bind source/settings/environment before launch.

**Consistent-estimator amendment.** The opt-in public Jeffreys RSM/PCM route
now defines original calibration, estimated anchors, scoring and replicate
fits with one canonical penalized objective. It requires a distinct study
epoch from ordinary points with a penalized generator; the stored ordinary
pilot cannot be relabelled as evidence for the new estimator. Local stationarity,
declared support and information rank are checked; failed trials remain in
assigned denominators. Original-data point shifts on saved inputs are not bias
estimates. Qualification needs fresh outer responses, the independent true
common-plan targets, fixed estimator choices and explicit precision allocation
for both coverage and availability. Inner endpoint precision must also be
adequate. The old 2,000-per-cell allocation is not automatically adopted for
the nested penalized procedure. No broad allocation has started. Retain the
original ordinary-JML and bounded-response comparators, medium/large-sample
controls and paired weak/strong designs; the 30,600-record program remains a
separate unfinished obligation.

The consistent penalized estimator now also has an analytic two-stage delta
route. Its score Jacobian and mixed anchor derivative include the information
penalty, while response-event covariance retains overlap across stages.
Neither ordinary inverse information nor inverse penalized curvature is used
as sampling covariance. Closed-form and numerical-derivative checks qualify
this local calculation, not bias or normal coverage. The next allocation must
distinguish this deterministic interval from whole-pipeline refit intervals:
inner simulation precision applies only to the latter. Preserve conditioning
failures as unavailable; do not pool the previous ordinary-delta outcomes with
this estimator or treat selected saved-input controls as new outer replications.

Date: 2026-10-24. Implementation/preflight phase. The original 18-cell source
and results are retained; the subsequent matched-control amendment below is
specified before generating its new outcomes.
This addresses the current internal roadmap's common-plan inference item.
The analytic covariance is implemented and independently checked; this study
tests its statistical performance. It does not repeat or replace the earlier
30,600-record broad model map or the completed MML bias confirmation.

## Estimand and procedure

Persons, their abilities, rating assignment, facets and common plan are fixed.
New independent categorical responses are generated once per union event and
shared across calibration and scoring. Each draw refits ordinary JML calibration,
extracts its unrounded R1 anchor, fits scoring under that anchor and, for partial
overlap, fits the union generator. Public `confint(method = "delta")` supplies
the actual experimental intervals. All three fits use the declared original
categories, BFGS, maxit 1000, reltol 1e-12 and the existing 1e-4 gradient gate;
No looser gates or study-specific retries are used. The current public fitter
adds bounded exact-information finishing after its ordinary optimization ladder
stalls. That source change requires a separate epoch; its checks do not change
the likelihood, parameter constraints or gradient criterion.

Targets are the two named Persons' common-plan expected averages and their
paired difference. The independent generating polynomial supplies truth;
fitted generating scores are not substituted for true expected scores.
The common plan weights Raters by their index and Criteria by 1:2:1, so sparse
assignment and fairness adjustment do not collapse to an observed-mean identity.
The second method is explicitly conditional on the *estimated* fixed anchors.
Its intervals are compared diagnostically against the same unconditional target;
they are not claimed to propagate anchor uncertainty. It also uses its scoring
model as generator, as required by that public API. This is a whole-procedure
comparison, not an isolated cross-term deletion.

## Fixed design and allocation

The original allocation crosses RSM/PCM, N=20/60/240 and three designs (18 cells):

- Dense same-sample calibration/scoring: three Raters, three Criteria, nine
  responses per Person. The union and calibration fit are the same source.
- Sparse partial overlap: cyclic two-of-three Rater pairs, six responses per
  Person. Calibration uses the first 75%, scoring the last 75%; 50% are shared.
- Weak-link partial overlap: six Raters in two groups, six responses per Person,
  one cross-group pair in each ten-Person cycle. Retain the same 75%/75% maps.

**Matched connectivity amendment.** Append six `strong_overlap` cells (19--24),
paired with `weak_overlap` cells 13--18. Rewire the two-Rater pairs within each
five-Person block. The same six Raters, all latent values, common plan, target
truth, Person response counts and Rater-by-Criterion counts are preserved in
calibration, scoring and the union. The 75%/75% event maps are also unchanged.
The normalized Rater co-rating graph's spectral gap increases in all three
stages; this is a design diagnostic, not an information or coverage guarantee.
Moving assignments still changes which abilities meet which Raters, as part of
the design intervention. The original three- versus six-Rater comparison cannot
isolate connectivity and is retained only as a comparison of complete designs.

Each strong/weak pair uses the same uniforms on corresponding Person/row
positions, then applies its own category probabilities. This creates paired
Monte Carlo results without changing either marginal response law. These are
not identical observed response events across designs. Replications within a
cell are independent, while methods, targets and paired designs are dependent.
All earlier 18-cell seeds and design definitions remain unchanged.

The runner fixes all parameters and assignments; focal abilities are -.5 and .5,
the remaining fixed abilities span [-1.2,1.2]. Nonuniform PCM profiles are centered.
Missingness by assignment is fixed/exogenous. Dependent responses, nonignorable
missingness, corrected JML, GPCM and future-population sampling remain separate
obligations; these 18 cells cannot qualify those cases. Keeping N=240 alongside
small samples prevents a small-sample-only assessment.

Original preflight: two draws per cell, 36 total, with full fits/input retained for
numerical/availability diagnosis and runtime pricing. Its seeds are separate
from confirmation; no precision/coverage claim can be based on two draws.
Run `Rscript --vanilla inst/validation/fair-reference-coverage-0.2.4.R check`,
then `... preflight`. All current package R sources, DLL, this protocol and
runner plus R/Matrix versions are bound to the manifest; changed epochs refuse
reuse. Completed records are read back and failures are never replaced.
An optional third command argument selects a new output root for a separately
reviewed source epoch; it must not be used to overwrite the old evidence.

The completed initial preflight is retained under the default output root.
Its original runner/protocol are in `preflight/source-binding/`. It exposed
both stationarity refusals and an inherent loss of availability from requiring
all generating Persons to be finite; the current internal roadmap records the
exact calculation and decision. A subsequent diagnostic-return repair preserves
finite selected points when an unselected generator Person is extreme. It does
not make the interval available or change the initial preflight's statistics.
The original source manifest deliberately refuses reuse under this newer source.

After the source repair, rerun cells 5/6 (including the three actual stopping
failures and one successful control) and the complete matched cells 13--24,
two draws each: 28 executions, including 12 new strong-design datasets. Other
original conditions are not automatically refitted. Old and new receipts are
kept separately. This allocation checks the implementation and failure causes;
it cannot estimate coverage, rank methods or qualify bias.

For a subsequent frozen confirmation, 2,000 independent datasets per selected
cell give coverage MCSE .00487 at p=.95 (approximately .00955 95% half-width).
This is a conditional-on-availability precision calculation: fewer available
intervals worsen precision. At worst-case p=.5, MCSE is .01118. These values,
not the old 30,000-record total, determine the new replication count. Running
all original 18 cells would require 36,000 new datasets (48,000 including the
new controls); this is an unlaunched precision calculation,
not completion or an instruction to start all cells after preflight. Price the
complete paired comparisons and resolve numerical/method failures first. Select
the same model/design's three N cells as a unit; do not select favorable cells.
`... run CELL_IDS` requires explicit IDs; it never defaults to a broad run.

## Accounting and decisions

Every assigned replication retains source failures, finite points, unavailable
interval reasons, warning messages, extreme-Person counts and elapsed time.
Do not delete an extreme Person or redraw a sparse/weakly connected dataset.
Report assigned, finite-point, available and covered denominators separately,
coverage among available intervals and exact binomial MC intervals, availability
with its own exact interval, and available-and-covered/assigned as a distinct
joint delivery rate. Bias of all finite points and available-only bias, empirical
SD, RMS reported SE and interval width retain their own subsets. Persons/targets
and two methods within a dataset are paired, not independent replications.

The initial performance question is whether nominal .95 coverage is consistent
with a prespecified [.93,.97] practical band and availability at least .95.
A coverage MC interval entirely inside the band and an availability lower bound
above .95 supports only that target/design/procedure; intervals overlapping a
boundary are unresolved. Bounds wholly outside the band, or an availability
upper bound below .95, require a method/scope review. This is a research decision
margin, not a universal operational tolerance or automatic `CIEligible` change.
Diagnose bias, SE scale, boundary loss and stage/generator mismatch separately.
The current boundary refusal remains: an all-endpoint Person has no finite
primary JML estimate. Replacing that estimate by a large finite value or by
Xtreme would define a different generator. Using the limiting point mass would
make that Person's generated responses deterministic; it cannot identify
uncertainty about their finite true response probabilities from these data.
Zeroing their information or deleting their events therefore does not repair
the current general coverage claim. A separately specified boundary procedure
must retain its actual assumptions and undergo new performance qualification.
Local covariance correctness alone cannot justify an incidental-bias correction.
Do not add draws until a result passes, or use an inspected preflight/confirmation
as independent evidence for a repaired procedure.

## Conservative bounded-response alternative

The public `method = "bounded"` is a separate inference procedure for the same
true expected-score target, not another fitted-generator setting in the delta
experiment above. Its signed event weights use the scoring data and the fixed
reference plan. Unobserved plan means retain their full score range; the
Hoeffding sampling radius requires independent bounded responses and stable
within-cell means, with exogenous assignment/plan/contrast. Estimated anchors
do not enter these bounds. Original JML points and complete-plan design-weighted
means have separate columns; no design point is supplied for missing cells.
Both rating limits must be declared from the rubric, and the full identity
score map must be retained. Observed or partly inferred limits and data-dependent
category collapse are refused, including legacy objects without provenance.
The original replay datasets declare their 0--3 rubric; their numeric results
remain comparable under this guard. Declaring observed extrema after inspecting
the sample does not establish fixed known support.

Finite-pattern enumeration, independent cell-weight/radius checks and the
inequality establish the scoped basis. Replaying the existing 28 datasets
checks public availability, unchanged JML points, widths, metadata and saved
consumers. It is not fresh coverage confirmation. `Informative` only means
narrower than the entire target range; sparse-design widths can still be nearly
the full range and unsuitable for a decision.

The probability inequality is unconditional over the fixed response experiment.
It is not nominal coverage conditional on successful fits, extremes or other
response-selected subgroups. Since this API consumes an existing common-plan
result, failures to create that object remain in an end-to-end denominator.
The default refit route and delta restrictions stay unchanged. Do not pool the
new method's returned bounds or theoretical qualification with the earlier
fitted-model interval counts or relabel it as corrected-JML inference.

## Explicit Jeffreys generating-model candidate

The refit-only `generator_method = "jeffreys"` uses the penalized canonical
union fit for simulation probabilities and the true-target reference inside
the plug-in bootstrap. The observed and replicate calibration/anchor/scoring
estimator stays ordinary JML. It is not a changed delta procedure and must not
be pooled with the earlier delta confirmation allocation. Selected endpoint
limits are retained; failed source calibration, infinite propagated anchors
and unresolved refits keep their existing accounting.

The penalty is half the log determinant of the full expected information in
the actual affine free coordinates. Independent derivative, binomial closed-form,
affine-coordinate and rank checks establish implementation evidence. Saved
dense and weak RSM/PCM inputs at N20/60/240 price and check the generator, and
small shared/overlapping-event refits check the public estimator chain. These
are development inputs and tiny execution checks, not independent coverage
confirmation. Inspect the retained ordinary and penalized gradients separately.

This is a finite-parameter generating procedure, not a general fixed-short-test
JML bias correction. The fixed-dimensional canonical bias argument does not
qualify nonlinear expected-score bias or this two-stage interval's coverage.
For Bin(n,p), the induced probability estimate (S+.5)/(n+1) has bias
(.5-p)/(n+1). Independent qualification must therefore measure the actual
reported ordinary-JML point, interval width, availability and unconditional
coverage under the original fixed-Person truth; do not substitute generating
truth for that external truth. The broad study remains a separate obligation.

## Inner replication precision before outer allocation

Refit results now expose a separate `mc_level` and binomial rank enclosures
for both basic endpoints. For p in {(1-level)/2, (1+level)/2}, set
a=(1-mc_level)/4, l=qbinom(a,B,p), u=qbinom(1-a,B,p)+1. The lower/upper
error-quantile enclosure uses order statistics l/u, with ranks zero and B+1
at infinities. Subtract in reverse order from the original point. For a
possibly discrete distribution F and its left p-quantile q, F(q-) <= p <= F(q);
binomial stochastic ordering bounds each noncoverage tail by a. A union bound
controls the four tails for both endpoints of one target. Ties therefore do
not require jitter or normal-density assumptions.

Retain failed roots as unknown -Inf/+Inf to enclose every completion, without
assuming failures are random. This does not define an estimator on structurally
unidentified outcomes. Monte Carlo precision is conditional on a fixed generator
and iid refits; it neither establishes original-data coverage nor permits
repeated inspection/stopping at a favorable result. Available, MCFinite and
CIEligible remain separate. At level=mc_level=.95 at least 174 fully resolved
draws are necessary for finite rank enclosures; finiteness is not adequate
score-unit precision. The planned pilot uses fixed counts and preserves the
N20/60/240 matched connectivity comparisons. Its saved development inputs are
not new independent outer replications. Use failed-refit causes, observed
endpoint-enclosure widths and total costs to choose the next allocation.

The fixed six-input PCM feasibility pilot used 199 inner draws at each of
N20/60/240 under matched weak/strong assignments. Frozen unresolved counts
were 43/33, 1/0 and 6/1, respectively. These are conditional plug-in refits of
six development inputs, not independent outer replications. The seven N240
failures were numerical and were repaired and replayed separately, keeping
the original results. The N20 failures were structural. Exact category-presence
probabilities for the studied free PCM ladders give failure lower bounds
.109072/.125651 under the two N20 generating fits; more inner draws cannot
remove that mass. Different fitted generators also prevent attributing the
conditional weak/strong difference solely to connectivity. The fully resolved
N60 strong contrast still had endpoint MC enclosure widths .52870/1.12937.

Do not promote the old delta allocation to nested refit confirmation. Establish
a consistent estimator at every original/refit stage before selecting an
independent outer bias/coverage allocation. A new penalized replicate estimator
alone cannot stand in for the sampling law of the original ordinary-JML point.
Maintain ordinary defaults and explicit unavailable states while considering
an opt-in alternative, with separate evaluation against the known external
truth. Bounded-response intervals retain their distinct assumptions and scope.
