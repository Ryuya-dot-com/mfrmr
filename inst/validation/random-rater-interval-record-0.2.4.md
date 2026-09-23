# Shared-rater prediction interval extension, 2026-09-23

## Question, existing evidence and method choice

Roadmap row 3a remains incomplete because ordinary individual-rater intervals
under-covered with six raters. Reusing all 80 positive-SD pilot fits (no new
fitting) separated common-location from centered-rater error. With six raters,
the interval for the average realized rater effect covered 80%, whereas
centered-effect intervals covered 98.3%; individual absolute-effect coverage
was 84.2%. The estimated average-effect variance was 0.0778 versus empirical
average-effect squared error 0.1128. This diagnoses the population-reference
uncertainty; centering changes the estimand and is NOT a correction for the
absolute-effect interval. The 24-rater common-location coverage was 87.5%.

The decomposition is descriptive, not proof of a fixed variance-underestimation
factor. Across the six-rater datasets, the generating variance of the mean true
severity is 0.7^2/6 = 0.08167, close to the mean reported variance 0.07775.
Its observed mean squared value is 0.11241 (MCSE 0.02093), so the discrepancy
from this particular set of 40 latent draws also has substantial Monte Carlo
variation. With 24 raters, the corresponding generating and mean reported
variances are 0.02042 and 0.02043. Estimated SD, realized group location and
studentized tails require a distributional comparison; the empirical MSE-to-
variance ratio is not a defensible universal inflation constant.

Use the original realized random-effect target. Generate new Person abilities,
one severity per observed rater (shared across persons), and ordinal responses
on the same analyzed assignment. Refit the SAME frequentist model at each draw.
The primary candidate is a parametric bootstrap-t prediction interval with root
(u_generated - u_estimated) / calibration-adjusted PredictionSE_refit. Source
endpoints add its PredictionSE times the type-1 empirical root quantiles.
An unstudentized error interval is retained as a comparison using exactly the
same refits. Original ordinary intervals also remain available; do not alter
point estimates or inflate a t critical value from one observed coverage rate.

Chatterjee, Lahiri & Li (2008), https://doi.org/10.1214/07-AOS512, motivates
studentized prediction-error bootstrap for Gaussian linear mixed models.
Its theorem does not transfer to this crossed ordinal RSM or six raters.
Hall & Maiti (2006), https://doi.org/10.1111/j.1467-9868.2006.00541.x,
examines bootstrap calibration in two-level prediction models; neither its
higher-order result nor independent-area assumptions certify this method.
We adopt the prediction-error construction, not an unsupported coverage claim.

## Boundary and failure policy, fixed before bootstrap outcomes

The source must have resolved numerical/information checks, positive rater
population SD and positive prediction SEs. An estimated zero-variance source
cannot support this studentization; keep its separate population-SD profile.
A bootstrap boundary retains its generated effect and fitted zero mode for
unscaled errors, but its studentized root is unresolved. Failed/information-
invalid refits leave both roots unresolved. No removal, replacement or success-
conditioned denominator is allowed. With B planned draws, substitute -Inf for
all unresolved roots when finding a lower-tail order statistic, and +Inf for
all unresolved roots when finding an upper-tail order statistic. This encloses
the empirical bootstrap interval for every completion of unresolved roots;
it may be unbounded. This completion bound is NOT a coverage theorem.

The caller's RNG state is restored; each draw has its recorded seed, generating
truth, fitted rater estimate/SE and fit/boundary/error/warning status. Saved roots
allow different confidence levels and the error comparison without refitting.
Omitted scores remain omitted; no missingness mechanism is generated.

## Bounded method comparison: protocol frozen before new outcomes

Use 24 new, independent outer datasets: 12 with six raters and 12 with 24,
all with true rater SD 0.7, 240 Persons, three criteria, two rotating adjacent
raters per Person, 1,440 scores on 0:2, beta (-0.3,0,0.3), steps (-0.6,0.6),
iid Person N(0,1), iid uncentered rater N(0,0.7^2). Assignment is independent.
Outer seeds are 9241000 + 100 * condition (1,2) + replicate (1:12).
Use B = 99 bootstrap datasets per outer source with seed 9248000 + outer index.
Fit at GH 61, higher-order check 123, maxit 300; reuse all current fitting
checks without tuning. Planned fitting is 24 outer fits and 2,376 bootstrap
refits. Bootstrap levels/methods reuse saved roots. Preflight seed 923799 and
old pilot trial 081 are excluded. No new fit of the old 160-dataset pilot.

Primary comparison: 95% pointwise individual-effect coverage, averaged within
each dataset, bootstrap-t minus ordinary paired coverage and Monte Carlo SE
across independent datasets. Also report width, finite/unbounded/unavailable
limits, refit errors and estimated boundaries, unscaled-error comparison and
runtime. Unbounded limits count as covering with infinite width, never as a
successful finite interval. Report coverage among all returned intervals and
among finite intervals separately, with their denominators. All planned outer
trials are retained; no fitting replacement after an outer failure/boundary.
Twelve outer draws per cell are a bounded development comparison, NOT precise
coverage qualification. A point estimate near 95% is not proof of nominal
coverage; intervals must be assessed together with width and availability.
Do not adopt the candidate as default or claim row 3a fully qualified from
this comparison alone. Future confirmation needs prespecified broader
conditions and adequate Monte Carlo precision.

Before any new outer-study outcomes, the planned bootstrap count was reduced
from 199 to 99 after the 19-draw execution preflight took 47.8 seconds. The
24 outer datasets and all conditions remain unchanged. This is a computational
screen of a method candidate, with only 2.475 expected draws per 95% tail;
Monte Carlo endpoint noise is substantial. It cannot qualify production 95%
coverage. The public default remains 499, and draws can be resummarized at
other levels. No comparison results were inspected to choose this count.

## Implementation and preservation checks

The local API is `mfrm_random_rater_intervals()`, with `confint()`, `summary()`,
`print()` and `plot()` methods. `plot_data()` retains exact infinite endpoints;
the plot uses arrows rather than turning them into finite limits. The interval
guide separates realized-rater prediction intervals from the population-SD
profile. Rater estimates and ordinary intervals from the source fit are not
overwritten. Source-boundary intervals, contrasts and familywise classification
remain outside this route.

Focused checks pass 65 interval expectations, 67 interval/reporting-guide
expectations, four namespace expectations and 79 existing ggplot-routing
expectations. Checks cover error direction, type-1 order statistics, every
planned draw, extreme completions of unresolved roots, fixed SD, full-model
refits, ordinal probabilities from independently constructed adjacent ratios,
fixed-facet effects, repeated Person/rater identities, category labels, saved
results, RNG restoration with and without a pre-existing seed, boundary/error
retention, unbounded plots and graphics-state restoration. The observed boundary
in outer dataset 7 also retained finite unscaled errors and unavailable
studentizers. These checks establish behavior, not interval coverage.

The source frozen for the running study preceded a caller-RNG preservation
fix and an early optional-RTMB dependency check. The preservation helper now
wraps the full calculation, because recording `RNGkind()` can initialize a
previously absent seed. Numerical functions, generators, refits, seed sampling
and endpoint calculations are unchanged, verified by parsed-code comparison;
two already saved draws also reproduce errors, studentized roots and trial
records exactly after the fix. The original executed source remains under the
frozen evidence directory, rather than being overwritten. No study is rerun
for this control-flow change. A fresh session without RTMB can re-summarize,
change level/method and draw a saved result; starting new bootstrap fitting
gives an explicit optional-dependency error.

## Completed comparison and decision

All 24 new outer sources were numerically/information ready with positive
estimated SD. All 2,376 planned refits were ready, with no captured errors or
warnings. Two six-rater refits (one in each of outer datasets 7 and 12) estimated
zero variance. Their unscaled errors remained available; their studentized
roots remained unresolved. With 99 planned draws these two separate one-root
cases still returned finite completion bounds. Every method returned all 72
six-rater and 288 twenty-four-rater intervals; none was unbounded or unavailable.

| Raters | Method | Covered / planned targets | Coverage | MCSE (pp) | Mean width (logits) |
| ---: | --- | ---: | ---: | ---: | ---: |
| 6 | Ordinary normal | 66/72 | 91.667% | 8.333 | 1.17698 |
| 6 | Studentized bootstrap | 72/72 | 100.000% | 0 observed | 1.64773 |
| 6 | Unscaled-error bootstrap | 65/72 | 90.278% | 8.323 | 1.22651 |
| 24 | Ordinary normal | 275/288 | 95.486% | 1.198 | 1.12247 |
| 24 | Studentized bootstrap | 274/288 | 95.139% | 1.764 | 1.14931 |
| 24 | Unscaled-error bootstrap | 270/288 | 93.750% | 1.739 | 1.12176 |

Coverage averages within datasets, then across the 12 independent datasets.
All-returned and finite-only coverage/width coincide here; both denominators
are still emitted in the saved summary. The zero empirical MCSE for six-rater
studentized coverage means all 12 observed dataset fractions equal one. It
does NOT imply zero Monte Carlo uncertainty or established nominal coverage.

Studentized-minus-ordinary paired coverage changes are +8.333 pp (MCSE 8.333)
with six raters and -0.347 pp (MCSE 1.083) with 24. The six-rater gain occurred
entirely in outer dataset 7, where ordinary intervals covered no raters. Mean
width increased 40.0%. The unscaled method changed coverage by -1.389 pp
(MCSE 1.389) and -1.736 pp (MCSE 1.198), respectively. It did not repair
coverage in these draws. These are paired comparisons on new data; do not
substitute the previous 40-dataset ordinary rate of 84.2% as their comparator.

The method remains an explicit model-based comparison. Do not replace the
ordinary default, claim a general remedy, or mark roadmap row 3a qualified.
Twelve outer datasets and only 2.475 expected draws per nominal tail are too
few for a precise performance decision. Prespecified broader qualification
with adequate outer and inner Monte Carlo precision remains separate. No
extra seeds, conditions or tuning are added in response to these outcomes.
Proceed to the next requested model workflow while retaining this unresolved
inference requirement in the roadmap.

Observed median source-plus-99-refit times were 253.2 seconds for six raters
and 326.2 seconds for 24, during four concurrent workers on this machine;
these are not general runtime guarantees. The summary rechecks all roster
identities, saved seed mappings, generated rater effects, error directions and
studentization identities without fitting. Full outer records, trial ledgers,
per-rater/per-dataset summaries and paired results remain under
`validation-results/random-rater-intervals-20260923/pilot/`. The frozen executed
sources and original protocol remain intact. No old pilot, full-package suite
or hosted CI was repeated, and nothing was published.

The updated tutorial was executed and its unbounded demonstration plot was
visually reviewed. Ten affected local pages and 25 topic links passed the
visible-text/link inspection, with no internal paths exposed. A saved 99-refit
study result also supports level/method changes and plot data in a fresh
session without RTMB. The first source build revealed a vignette calculation
cache in the archive, producing nonportable-path warnings. That generated
cache was moved to ignored validation output and `.Rbuildignore` now excludes
vignette cache directories. The corrected source build has no warnings; the
archive contains matching API/help/example/test sources and excludes caches,
local libraries and internal records. The archive build did not rebuild
vignettes or perform a full package check; tutorial execution was separate.
