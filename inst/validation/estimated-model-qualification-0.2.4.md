# Estimated-population model qualification: prespecified decisions

Date: 2026-09-23. M2/M3, local expanded 0.2.4. This record fixes the questions
and decision rules before the new sampling outcomes. It does not close M2,
endorse intervals, or change release scope. No new model or public API is added.

## Evidence to reuse and the next decision

The fixed-population 160-dataset shared-rater pilot, its 24-dataset bootstrap
comparison, the fixed-population testlet study, independent tensor/adaptive
references, and saved map/comparison workflows remain applicable to their
original questions. They are not rerun. Both current extensions now estimate
normal ability variance; the earlier interval studies do not qualify that
change. Known shared-rater undercoverage cannot be dismissed by a warning.

The next blocking question is whether the shared-rater first-order intervals
retain their nominal interpretation with estimated ability variance, few
raters and weak linking. Compare ordinary fixed-rater estimates on the SAME
data to expose shrinkage/error consequences, not to rank likelihoods. The
ordinary estimated-population route does not currently admit regular
interval inference: compare its point estimates only, retain readiness,
and never manufacture ordinary comparison intervals.

The testlet question is distinct: when local dependence is absent or present,
does modeling it improve conditional scoring and preserve fixed-facet
precision under an estimated population? Its existing numerical references
are reusable; its statistical protocol must additionally distinguish
conditional posterior uncertainty from calibration-estimation uncertainty.
This shared-rater experiment does not qualify testlet, Person scoring,
response diagnostics, a rater-SD profile or bootstrap intervals. MI adequacy
remains a separate M1/M2 dependency. Do not expand this experiment to claim
those other outcomes or repeat display tests.

## Frozen shared-rater experiment

Four conditions: 6 or 24 raters crossed with rotating pairs or two weakly
linked panels. Each has 240 Persons, two raters per Person, three criteria
per rating and 1,440 assigned/observed responses. Categories are 0,1,2.
Person abilities are iid N(0,1.3^2); rater severities iid N(0,0.7^2), without
centering the realized sample. Fixed criterion effects are (-.3,0,.3),
adjacent steps (-.6,.6). Generate probabilities directly from the adjacent
logits, independently of package simulation helpers. No local effect,
missing assigned score, nonnormality, selection or ability-linked assignment
is introduced. Such cases cannot be claimed supported from these outcomes.

Rotating pairs cycle (1,2),...,(R,1). In the weak design, half the Persons
cycle within each half-panel. Swap the second rater of Persons 1 and 121,
forming exactly two bridging Persons without changing any rater's workload.
All criteria occur within every pair. Assignment is fixed independently of
latent draws. Rater count changes per-rater workload, so this is not a causal
isolation of rater count alone or an adequate-rater-count threshold study.

200 independent replicates per condition (800 datasets; two fits each).
Seeds are 92326000 + replicate. Generate 240 ability draws, 24 rater draws
and 1,440 uniform draws once per replicate and reuse them across conditions.
The six-rater condition uses the first six rater draws. Paired contrasts are
summarized within a rater count and across independent replicates. Reusing
draws does not create extra independent replications. The prior saved-data
cost probe is excluded and does not select favorable production data.

Fit both models with estimated normal ability variance, fixed unit slopes,
matching unit-weight rows/categories/facets, 61-point Person quadrature and
maxit=400. Shared-rater fitting retains its existing higher-order and boundary
checks. Ordinary MML uses population_formula=~1; its estimated mean is an
identification coordinate. No automatic likelihood preference, ordinary
interval extension, selective restart, replacement or tolerance relaxation.
Store full fits, source rows, truth, warnings/errors, all checks and timing.
Freeze source hashes and this protocol before outcomes. An interrupted worker
may skip only an already saved complete trial from the matching source.

## Targets and decision rules

1. Numerical and interval availability: all 200 planned datasets per cell
   remain in denominators. Report optimizer/information/integration failures,
   variance boundaries, errors and timing separately. A regular interval is
   eligible only with positive information, numerical readiness, neither
   estimated variance boundary, and finite endpoints. No numeric value in an
   ineligible fit establishes availability.
2. Shared-rater individual prediction intervals target realized, UNcentered
   rater effects. Average coverage, width and error within each dataset before
   averaging datasets; raters are correlated, not independent replications.
   Report conditional-on-availability coverage, jointly available-and-covered
   rate and all-trial lower/upper accounting bounds. Infinite/missing intervals
   cannot count as successful finite-interval evidence.
3. Fixed criterion targets are individual effects and the prespecified
   C3-minus-C1 contrast (truth .6). Use the full covariance through the fitted
   basis for the contrast. Preserve named targets; do not cancel biases by
   averaging signed effects. Population SD estimates retain their distinct
   ability/rater targets and estimated-zero outcomes.
4. For ordinary-versus-shared point comparisons, center both realized rater
   effects and estimated effects within the observed roster. Compare
   per-dataset squared error and absolute error, and C3-minus-C1 error. This
   differs from the uncentered individual prediction-interval target. Report
   paired error differences and paired availability; no difference CI for
   individual empirical-Bayes estimates is invented.
5. Monte Carlo precision: report SD of replicate summaries / sqrt(n), and
   pointwise 95% t Monte Carlo intervals for their means. Single-target binary
   coverage/availability uses exact binomial intervals. At n=200 the binary
   MCSE near .95 is .0154; a maximum .0354 occurs near .5. These intervals
   quantify simulation error, not inferential uncertainty in one assessment.
   No simultaneous or universal-coverage claim is made.
6. Prespecified material undercoverage floor: .925 for a nominal .95 interval.
   An upper 95% Monte Carlo bound below .925 is evidence against the retained
   nominal interpretation in that cell. Bounded positive evidence requires
   lower coverage bound >=.925, coverage estimate <=.975 and lower exact
   finite-availability bound >=.95. Other outcomes are inconclusive. Do not
   pool cells to erase a failed cell or grow n after seeing favorable results.
   This operational 2.5-point tolerance is not a theorem about nominal coverage.
7. Practical bias review: .10 logits for criterion targets, and 10% of the
   generating SD for population-SD bias. Report estimates and MC intervals;
   mark a clear adverse result when the whole bias interval lies outside the
   corresponding +/- tolerance. Passing this review alone does not qualify
   uncertainty, model superiority, sparse-design capacity or diagnostics.

## Consequence and stopping point

Complete the planned 800 datasets and report every cell. If a reproducible
implementation defect invalidates the generator, fit or accounting, preserve
the run, repair the defect and document the affected evidence before deciding
what needs rerunning. Outcome-based undercoverage is not an implementation
defect to remove by tuning seeds, estimands or thresholds.

Evidence against an interval requires an explicit repair or output-restriction
decision before release. Do not infer that 24 raters is a safe minimum, that
a bootstrap has solved the problem, or that hiding whiskers validates an
unchanged nominal interval. Any changed default must preserve point estimates,
declared uncertainty targets and useful outputs, and be documented/tested.
The next result is that decision and its implementation, not a new display.
