# New-Person intervals after estimating calibration

2026-09-14 JST. Fixed before new simulation outcomes. Repository-only study;
this is not an extension of production eligibility or a release criterion.

## Question and design

When a finite calibration sample estimates Rater, Criterion and step effects,
how much do new-Person intervals change in coverage, width and estimation error
relative to using the known generating calibration? Keeping the correct N(0,1)
prior fixed isolates calibration estimation from prior misspecification and
estimated-population uncertainty. The existing estimated-population parameter
coverage protocol answers a different question and remains separate.

Reuse `mml_information_fixture()` unchanged: three Raters with effects
(0.3,-0.1,-0.2), two Criteria (0.4,-0.4), categories 0--2, RSM steps
(-0.6,0.6), PCM Criterion ladders (-0.7,0.7)/(-0.2,0.2), and unit weights.
Eight cells cross RSM/PCM, calibration N=80/320 and 3/6 ratings per Person.
The three-rating design alternates complementary assignments and is connected;
the six-rating design is fully crossed. No response-dependent exclusions,
anchors, estimated slopes or interactions are introduced.

Each calibration dataset has a separate, independent new-Person cohort. Generate
512 new Persons with six ratings, then also score the complementary three-rating
subset on those same Persons. Calibration and scoring IDs are disjoint. Each
new Person's actual generating ability is recovered from the unchanged
generator's retained closure and archived with their responses; never redraw
abilities for evaluation. Calibration size and exposure vary independently of
new-Person exposure. Paired method/exposure comparisons are not additional Persons.

## Methods and numerical checks

Fit direct fixed-grid MML at Q61, maxit=200 and reltol=1e-10, estimating all facet
and step parameters with the ordinary initialization. Score through the public
`predict_mfrm_units()` route at Q61 and 95% continuous equal-tail intervals.
The reported uncertainty is conditional on the fitted point calibration and
excludes calibration-parameter uncertainty; this study measures the consequence,
without relabeling the interval as including that uncertainty.

For these unit-slope, fixed-assignment RSM/PCM posteriors, assignment and response
total are sufficient for Person scoring. Score all 27 assignment/total profiles
(two three-rating assignments with totals 0--6; one six-rating assignment with
totals 0--12) through the public API and map them to new Persons. Independently
integrated known-calibration posteriors supply the paired reference. Verify this
lookup against direct public scoring of 48 actual new Persons at both exposures
in the first preflight replicate of each cell; error <=1e-8 for EAP, SD and both
endpoints. The lookup is study-specific, not a new package scoring shortcut.

For every fit, evaluate the Q121 objective and full gradient at the same vector:
absolute objective change <=1e-6 and both maximum gradients <=1e-4. In preflight,
compare Q61/Q121 scoring moments (maximum error <=1e-6), independently integrated
fitted-posterior endpoint CDFs (tail error <=1e-6), and reference EAP/SD (error
<=1e-6). First replicates also compare the independent continuous fitting
objective (error <=1e-6). All computable results stay in the outcome tables even
if a numerical check fails. A numerical conflict requires investigation before
a main run or a positive numerical conclusion.

First preflight replicates exercise public quadrature refitting, calibration
extraction/validation/freezing/save/load and scoring. Compare the stored artifact
to its own highest-order source fit, not to a different calibration. Preserve
source-fit readiness, Person review flags, warnings and rejection reasons.
Default public scoring rejection makes the primary estimated-calibration
interval unavailable; do not override it with a review-only calculation.
Retain all attempts, finite fitted coordinates and failures, without replacement
seeds or best-of-retry selection.

## Replications, summaries and interpretation

Preflight uses five calibration datasets per cell (40 total), excluded from main
estimates. Main study size is fixed at 256 calibrations per cell (2,048 total),
each with 512 independent new Persons: 1,048,576 distinct new Persons. The unit
for Monte Carlo uncertainty is the calibration dataset. For each replicate,
compute coverage, paired coverage difference (estimated minus known), mean
width, bias and MSE. Average these replicate summaries with MCSE=SD/sqrt(B) and
a two-sided t interval with B-1 df. Report RMSE as sqrt(mean MSE), with delta
MCSE from the replicate MSE; do not average replicate RMSEs. Method comparisons
use paired replicate differences. No binomial interval treating all new Persons
as independent is used. With between-calibration coverage SD=0.02, B=256 gives
MCSE=0.00125 (planning assumption, not guaranteed precision).

Primary summaries use available estimated-calibration results and their paired
known-calibration results on exactly the same replicate subset. Also report
known-calibration results over all attempts, availability, all-attempt
available-and-covered rates, and numerical conflicts. A main-cell descriptive
coverage conclusion is supported only if its MC interval is inside [.93,.97],
the exact 95% availability lower bound is >=.98, all assigned replicates finished,
and there are no numerical conflicts. Disjoint coverage intervals are concern;
overlap/incomplete results are review. These are study-specific practical
margins, not guarantees of exact nominal coverage. Preflight is always labeled
`preflight_only`, never supported regardless of its numbers. Do not increase
the main replication count until a result passes.

Retain true-ability strata (-Inf,-2,-1,0,1,2,Inf) descriptively, using
calibration-cluster ratio MCSEs for pooled stratum summaries and paired contrasts;
also retain all-lower/all-upper-response frequencies. Marginal posterior
coverage under the correct prior does not imply 95% coverage at each fixed
ability. This does not test prior misspecification, estimated-prior prediction,
GPCM, weak/disconnected identification, linking transport, or intervals that
propagate calibration uncertainty.

Seeds: preflight calibration = 94000000 + 10000*cell + replicate; new cohort =
calibration seed + 2000. Main uses base 104000000 with the same offsets. All
planned IDs are checked unique and disjoint. Save source hashes, inputs,
truths, fits, profile scores, summaries, timings and conditions per replicate.
Resume only matching source/stage/cell/count payloads; one process owns each
cell. At most three local R processes may own disjoint cells. Resource stops
remain incomplete; failures are retained, not replaced. Review preflight
implementation and timing before starting the fixed-size main run.

Measure direct public scoring on one retained RSM fit at 48, 192 and 768 Persons
with three timed runs per size. Check outputs against the verified profile
lookup. Report observed timing rather than extrapolated throughput. Optimize
production only if profiling identifies a specific change that preserves the
independent numerical checks; no cache or approximation is prespecified.

The separation of aims, sampling units, performance and Monte Carlo uncertainty
follows [Morris, White and Crowther (2019)](https://doi.org/10.1002/sim.8086).
The prior-predictive interpretation follows the
[Stan explanation](https://mc-stan.org/docs/stan-users-guide/simulation-based-calibration.html),
without an SBC rank-test claim. All design sizes and margins above are study choices.
