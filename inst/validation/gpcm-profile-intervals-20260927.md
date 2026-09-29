# One-relative-slope profile implementation — 2026-09-27

## Question and development disposition

Can one prespecified relative discrimination be profiled while retaining the
sum-zero log-slope constraint, reoptimizing the population and exposing failed
searches through the existing uncertainty/reporting APIs? The scoped numerical
implementation and output integration are complete in development. Retain it
as an **experimental, explicitly requested sensitivity analysis**. The finite
shared-owner comparison below found substantial nonavailability; routine
replacement of Wald and general coverage remain unqualified. This is not
completion of the stronger inference milestone or a
change to the frozen 0.2.4 candidate.

The route is `confint(fit, method = "profile", slope = "R01")`, using an exact
level of the fit's slope facet. No exported function or dependency was added.
The target is one relative slope in a native GPCM MML model with an estimated
intercept-only normal population, unit weights, and no anchors/interactions.
Both owner arrangements are supported. Standardized targets, contrasts,
JML, covariate populations and simultaneous profile intervals are excluded.
Default model/sandwich intervals are unchanged.

## Numerical method and failure meanings

Eliminate one free coordinate subject to the selected linear log-slope
constraint. This also handles the last dependent sum-zero slope. At each
candidate, reoptimize every nuisance coordinate, including population mean
and variance. Preserve the source integration method and use its order plus
a higher reference order. The likelihood is unchanged; no finite slope bound
or new statistical penalty is introduced.

Two deterministic starts (retained and neutral) use BFGS at tolerances 1e-10
and, if needed, 1e-13, with maxit 400 per stage. A converged but insufficiently
stationary result may receive the fitter's existing single curvature-polish
proposal. All stages are retained. That helper accepts only gradient
improvement without objective deterioration; its dimensional/numerical limits
are retained and a failed proposal does not waive acceptance.

Both starts must have code zero, nuisance maximum gradient at most 1e-4,
higher-order NLL change at most 1e-5, gradient change and reference gradient at
most 1e-4, and NLL agreement at most 1e-5. Positive joint source information is
checked separately; constrained stationarity and start agreement do not prove
global minimization. Root residuals in twice the likelihood loss must be at
most 1e-4 against the chi-square(1) cutoff.

The default outward search uses eight steps per side, initially 0.5 on the
log-slope scale and increasing by 1.5. These are configurable numerical search
controls, not model bounds. No crossing, failed numerical/start checks,
observed nonmonotonicity and root failures retain unresolved endpoint reasons.
A better source likelihood invalidates both bounds. No Wald substitution or
infinite confidence bound is inferred from a failed finite search. Finite
sampling cannot exclude other modes or disconnected regions. The usual
likelihood-ratio cutoff needs regular asymptotics, not just successful software.

Methodological context: [Fischer and Lewis (2021)](https://doi.org/10.1007/s11222-021-10012-y)
discuss numerical difficulties and asymptotic limitations. This implementation
uses constrained BFGS and root finding, not their RVM algorithm, and does not
claim profile intervals are necessarily faster or better covered than Wald.

## Existing native cases and independent endpoints

The first slope in each of the two existing representative fits was selected
before its search: shared Rater owners (`refit-788.rds`, 40 synthetic Persons,
orders 61/121), and Criterion slopes/Rater steps (the retained conditional-
scoring fixture, 120 synthetic Persons, orders 31/61). No new simulation or
unconstrained source fit was run.

| Source and target | Estimate | Profile 95% limits | Wald 95% limits |
| --- | ---: | --- | --- |
| Shared Rater R01 | 0.475065 | 0.119656–0.864049 | 0.235729–0.957399 |
| Separate Criterion C1 | 0.740015 | 0.606667–0.902106 | 0.607727–0.901099 |

The first case reveals asymmetry that the local Wald approximation does not
capture. The second is close to Wald. Neither case measures repeated-sampling
coverage or establishes a preferred interval procedure.

The shared profile returned 17 evaluated points in an 8.376-second complete
call on this machine. The separate initial call used 274.045 seconds and left
the lower endpoint unresolved. One neutral-start BFGS result had gradient
1.5591e-4 despite NLL agreement with the retained start within 9e-11. The
existing curvature polish reduced that gradient to 6.84e-11; the reference
order's nuisance gradient was 4.01e-8. No tolerance was relaxed.

Validation then reused 25 unchanged passing attempts and computed 13 failed/new
attempts, taking a further 150.441 seconds. The resulting 19-point profile has
both endpoints. Original stages and the original failed result remain separate.
This reused computation is valid for unchanged calls (the new conditional
polish branch cannot execute on them), but its resumed elapsed time is **not**
a clean from-scratch runtime benchmark for the final procedure. The two-source
cost difference also confounds sample size, design, parameters and ownership.
There was no total elapsed-time cutoff or omitted planned endpoint.

The [independent reference runner](gpcm-profile-intervals-20260927.R) evaluates
baseline and both endpoint vectors for each fit without optimization. Its
separate scalar category recursion and continuous integration are reused from
the existing reference, with local ranges 32/64, refinement below 1e-8,
relative integration error below 1e-9 and log-concavity tail mass below 1e-12.
All six comparisons pass. The largest native/independent NLL discrepancy is
9.95e-8; the largest independent endpoint LR residual is 2.31e-7. Existing
unit-slope PCM objective/nuisance-gradient reduction tests passed 12 checks.
The generic constraint/endpoint tests also recover a coupled quadratic's
analytically known profile interval, including a dependent last slope.

## User workflow and regression evidence

The result remains `mfrm_slope_intervals`, preserving existing source identity
checks. The `profile` attribute holds all points, attempts/stages, parameter
vectors, endpoint statuses and elapsed time; `wald` holds the matched model
interval. New saved profile results default to a likelihood curve; explicit
`type = "interval"` selects their bounds. Existing Wald/bootstrap plotting
defaults are unchanged. Log axes, line types and point shapes distinguish
cutoffs, Wald limits and unresolved evaluations without relying on colour.
Default and suppressed-text plots were rendered and inspected; caption wrapping
was corrected. Both ggplot and saved plot-data replay work without refitting.

`apa_table()`, `mfrm_results(intervals = ...)`, `mfrm_report()` and
`export_mfrm_results()` preserve profile, endpoint, check and Wald tables.
The complete export path was exercised with CSV tables, the profile PNG,
report and replay archive, then reopened with exact saved inference identity.
Structured statuses remain available; printed failure explanations use readable
phrasing. Source fits and their global audit states are not promoted or mutated.

The dedicated suite passed 51 checks before extending the export test; the
changed final export group then passed 17 checks (one extra PNG assertion),
so the current suite's 52 checks are covered. Existing GPCM inference/reporting
regressions passed 91 checks. No full package suite or large simulation was
repeated. Help topics and vignette code parse, and `git diff --check` passes.
Help, scope guide, NEWS, vignette and roadmap describe the experimental scope.
Installed-package, platform and release checks remain pending.

Evidence, original failures, run scripts, selected source snapshots and hashes
are under `validation-results/gpcm-profile-intervals-20260927/`. The synthetic
saved-result fixture has its own provenance in `tests/testthat/fixtures/`.
To reproduce from scratch with the current procedure, load the package source,
read either documented source fit, and call the explicit `confint()` route
above with its first slope label; then run `review_gpcm_profile_endpoints()` on
the saved shared/separate results. Historical resumption is not necessary for
a fresh analysis.

## Finite post-fit comparison and stopping decision

The [protocol](gpcm-profile-comparison-20260927.md) was fixed before running
the 100-case comparison, together with its [runner](gpcm-profile-comparison-20260927.R).
It reuses **every** saved September 25 refit in the shared-Rater-owner,
spread-slope, N=40 rotating-assignment cell: indices 404,408,...,800.
R01, with truth exp(-0.4), is the only target. All 100 source/truth pairs and
the original 800-case scale audit were checked. No source refits, new data,
selected rescues, cached profile endpoints or tolerances changed this comparison.
The previously examined case 788 remains included. This is a retrospective
diagnostic reanalysis on saved estimates, not unseen confirmation of today's
estimator. Randomly generated nuisance facet effects vary across datasets.

| Measure | Model/log-Wald | Profile |
| --- | ---: | ---: |
| Assigned / attempted | 100 / 100 | 100 / 100 |
| Both finite limits available | 98/100 | 53/100 |
| Exact 95% MC interval for availability | .9296–.9976 | .4276–.6306 |
| Covered among available | 89/98 (.9082) | 53/53 (1.0000) |
| Exact 95% MC interval for conditional coverage | .8328–.9571 | .9328–1.0000 |
| Available and covered among assigned | 89/100 | 53/100 |
| Empirical unresolved-case coverage bounds | .89–.91 | .53–1.00 |
| Median full-call time | .3845 seconds | 8.7950 seconds |
| 90th percentile full-call time | .3983 seconds | 22.2663 seconds |

The unresolved-case bounds allow unavailable intervals to be misses or covers;
they are descriptive bounds for these 100 outcomes, not confidence intervals or
a declaration that missing intervals are statistical misses. Exact Monte Carlo
intervals are per-measure, not simultaneous. Successful profiles form a selected
subset, so 53/53 is not a guarantee for all datasets. Under the declared .90
availability review margin, profile availability is a clear concern. Wald
conditional coverage is inconclusive against the .925 margin. Neither finding
justifies routine profile replacement or general Wald adequacy.

On the common 53 datasets, Wald covered 49 and profile covered 53 (paired
difference .0755, MCSE .0366). Mean widths were 1.0647 and 1.1144; median
widths 1.0104 and 1.0348. Thus these data show four recovered covers on the
common subset, accompanied by much lower overall delivery. Across all assigned
datasets, availability changes by -.45 (paired MCSE .05), and the probability
of both delivery and covering changes by -.36 (MCSE .0560). The latter is a
delivery outcome, not coverage with unavailable intervals relabelled as misses.
Wald's full available-sample mean width is dominated by an interval with upper
limit about 4.88e7 (case 460); its extreme width and the eight cases with truth
below the interval / one with truth above remain visible. Availability alone
does not make Wald useful.

### Failure attribution without refitting

Eleven profile calls failed before constrained searching: nine source-integration
checks, one regularized/near-singular information case and one input/category
support case. The latter two also lacked Wald intervals. Thirty-six profile
objects retain unresolved search endpoints: 20 have only an upper endpoint,
12 only a lower endpoint, and four neither. No complete interval is counted
from a single computed bound.

Saved attempts contain 2,352 constrained starting-value evaluations. Sixty-two
failed their numerical check in 35 datasets. Within those 35, 22 datasets have
an excessive gradient at the fitted integration order, eight have excessive
higher-order NLL change, 11 have excessive gradient change, and five have a
nonzero optimizer code; all 35 have an excessive higher-order nuisance gradient.
These categories overlap. Two datasets (700 and 756) also contain separately
passing starts that disagree in NLL by 2.4072 and .2373 respectively; one of
them overlaps the 35 numerical-failure datasets. These are unresolved numerical
searches, not proof of nonexistent intervals or proof that all missing limits
would improve with a particular higher quadrature order. Do not weaken the
checks or select the more favourable limits to improve these results.

Full method-call elapsed time summed over the workers was 35.773 seconds for
Wald and 1,074.061 for profile; recorded self CPU totals were 35.703 and
1,071.994 seconds. The complete two-worker run took 564.225 wall-clock seconds.
Times include fresh method checks and all failures, exclude original source
fitting, and are not isolated single-worker benchmarks. No planned case was
omitted and no elapsed-time limit stopped the run.

### Disposition and verification

Retain the explicitly requested profile route as **experimental sensitivity
analysis**, without routine-replacement, superior-coverage or probability-
interval claims. The finite diagnostic/method decision is complete with an
adverse availability result. General operational inference qualification remains
open; no automatic additional grid is warranted. A future numerical improvement
would need a source-identified paired comparison that preserves these failures,
rather than accumulating selected successful examples. Proceed with the
combined workflow/release-scope review; portable scoring is independent.

The [summary script](gpcm-profile-comparison-summary-20260927.R) checks paired
outcomes, availability, widths and time with asymmetric injected failures.
Separate checks cover unattempted rows and zero available intervals. These
checks passed. Source/data/protocol hashes stayed unchanged during computation;
frozen sources, every returned object/error, plan, manifest, rows, paired and
Monte Carlo summaries, timings and numerical attempts are retained under
`validation-results/gpcm-profile-comparison-20260927/`. Public help, vignette,
NEWS and roadmap retain the adverse finding. No estimator change, full package
test suite or external comparison was rerun for this post-fit analysis.
