# Shared random-rater RSM: bounded local qualification

## Protocol frozen before pilot outcomes, 2026-09-23

Roadmap row 3a asks whether a shared rater population can be estimated and
used for observed-rater feedback and replacement-rater predictions. This
frequentist approximate MML implementation integrates whole Person vectors
conditional on the SAME rater effects, then uses a joint rater Laplace integral.
It does not resume the earlier fully Bayesian prototype. The scale is Person
N(0,1), population rater mean zero, zero-sum fixed facets and free RSM steps.

The independent tiny likelihood/gradient/Laplace calculation reuses the
archived tensor-integral target (NLL 7.61845115123505); the implemented Laplace
NLL is approximately 7.622921. Agreement with an independent Laplace calculation
checks implementation; the remaining difference from exact integration is
approximation error and must not be erased by a tolerance adjustment.

The pilot has four conditions: 240 Persons, 6 or 24 raters, population rater SD
0 or 0.7, 40 independent replications each (160 fits). The same 1,440 ratings
per dataset comprise two rotating adjacent raters per Person and three fixed
criteria per rater, on categories 0:2. Assignment is independent of ability.
Person abilities are iid N(0,1); rater effects iid N(0, SD^2), without centering
the realized sample. Criterion effects are (-0.3, 0, 0.3), steps (-0.6, 0.6).
Seeds are 9236100 + 100 * condition index + replicate (1:40); no paired-data
claim across conditions. All assigned scores are observed. Seeds 92351 and
the deterministic boundary fixture were preflight only, excluded from outcomes.

Use 61 Person quadrature points, comparison order 123, maxit 300, the fixed
zero-variance candidate and starts SD 0.25 and 1. Numerical thresholds are
unchanged (gradient <1e-4, integration NLL difference <1e-5 and gradient
difference <1e-4). One guarded curvature correction is permitted by the
implementation; profile nuisance optimizations restart after that correction.
No outcome-driven tuning, replacements or selective reruns. Every planned
trial is retained with errors, warnings, checks and timing. Freeze source
hashes and session metadata in protocol.rds before execution.

Targets: population SD bias/RMSE and 95% profile-LR interval availability,
coverage/width; fixed criterion/step bias and regular interval availability
and coverage; realized-rater prediction interval coverage averaged WITHIN
replication before summarizing across independent replications. Estimated
boundaries withhold regular intervals. Profile-LR uses chi-square(1) cutoff,
allows zero, checks every profile evaluation at the higher quadrature order,
and retains failed profile checks. No log-Wald variance interval is substituted.
Report planned and available denominators separately, exact binomial Monte
Carlo intervals for population-SD coverage and Monte Carlo SE for means.
Forty replications per condition constitute a diagnostic pilot, not a precise
95% coverage qualification or a general sparse-design/performance guarantee.
No new missingness, selection, nonnormality, testlet or multidimensional claim
is tested. Prior coverage studies and full package tests are not repeated.

## Numerical defect and explicit protocol amendment

The first run was interrupted after 52 complete trials; all outcomes and the
executed source are preserved under `pilot/`. Trial 006 demonstrated that
`nlminb` could return false-convergence with gradient 8.0e-4 at the zero-SD
submodel. The existing curvature correction was restricted to optimizer code
zero, so it never tried to improve that candidate. An independent diagnostic
correction and restart retained the likelihood and reduced the maximum
gradient below 3e-10 with optimizer code zero. This is a numerical implementation
defect, not evidence against the zero-variance statistical model.

Before resumed outcomes, amend the implementation to attempt the SAME guarded
curvature correction on a nonzero optimizer code and then restart `nlminb`.
Do not relabel a failed optimizer as converged. Retain initial/final codes and
the zero-submodel optimization. Thresholds, data, 160-trial roster, seeds,
model and interval procedures are unchanged. Restart the full frozen roster
under `pilot-final/` so every reported primary result comes from one corrected
implementation; do not combine selected successes from the two sources.
This is a justified repeat after a demonstrated defect, not a repetition of
unchanged whole-package or previous model studies. New hashes and copies of
executed source, including the reused curvature helper, are frozen before
this corrected run. The first-run failures remain part of the audit record.

## Execution and interpretation

The corrected 160/160 fits passed numerical AND information checks, and all
160 population-SD profiles were returned. No errors, warnings, replacements
or selective successes entered the corrected summary. The interrupted first
run retains 52 completed trials separately. Execution was partitioned into
disjoint trial ranges without changing seeds or numerical operations; an
incomplete in-flight trial was restarted, never a completed outcome. Timing
reflects concurrent local processes and is not a capacity benchmark.

| Raters | True SD | Mean estimated SD | SD profile coverage | Individual-rater interval availability | Mean individual-rater coverage (MCSE) |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 6 | 0 | 0.0234 | 40/40 | 11/40 | 1.000 (0.000), conditional on availability |
| 24 | 0 | 0.0464 | 40/40 | 21/40 | 1.000 (0.000), conditional on availability |
| 6 | 0.7 | 0.6403 | 37/40 | 40/40 | 0.8417 (0.0462) |
| 24 | 0.7 | 0.6901 | 39/40 | 40/40 | 0.9438 (0.0104) |

The exact 95% Monte Carlo intervals for SD profile coverage are [0.9119, 1]
for each zero condition, [0.7961, 0.9843] for six raters/SD 0.7 and
[0.8684, 0.9994] for 24 raters/SD 0.7. Regular intervals were withheld at the
29 and 19 estimated boundaries in the true-zero cells. At positive SD, mean
fixed-target coverage was 0.895 with six raters and 0.970 with 24; each of the
two steps covered 34/40 (0.85) in the six-rater condition. The named targets
remain separate in `fixed-summary.csv`, rather than being hidden by a mean.

Answer: the shared-rater MML and profile route is computationally usable for
this bounded experiment, including true zero variance. Its six-rater regular
intervals are NOT sufficiently qualified as 95% intervals: individual-rater
coverage is only 84.2%, despite including first-order calibration uncertainty.
The pilot is small, but this adverse result must be visible in public help;
24 raters is not established as a generally adequate threshold. Rater count,
workload and cycle linking all change together at the fixed rating budget.
No simple t multiplier, ad hoc rater cutoff or untested bootstrap was added
after seeing the results. Row 3a remains partially complete, with few-rater
uncertainty unresolved before broad inferential qualification.

## Focused checks, public behavior and source identity

The direct joint likelihood/gradient and independent Laplace calculation pass.
An independent covariance reconstruction uses conditional Hzz^-1 and the
implicit derivative of the rater mode: V_u = V_cond + J V_cal J'. Maximum
matrix discrepancies were 2.33e-10 (conditional) and 7.84e-9 (adjusted).
The final focused checks passed 78 random-rater expectations, four namespace
expectations and 79 unchanged plotting-conversion expectations, with no failures
or unexpected warnings. A source build (without rebuilding all vignettes or
the PDF manual) succeeded; it includes the new API, help and tutorial and
excludes local dependencies and development records. Eight rendered pages and
22 new-topic links passed checks for missing links and visible internal paths.
The model-specific article and help examples executed, and the severity figure
was visually inspected. The regression suite covers boundary profiles, fixed zero, complete
separation, saved results, role identity, predictions and plotting. Binary
scores with no fixed facets also execute. Source data and the result can be
saved without native pointers; a fresh session without RTMB reproduced saved
point predictions and plots. RTMB is optional and installed only in the local
`.r-library` for this work; no machine-wide configuration was changed.

A deliberately separated fixed facet had a small gradient but singular
information. The final prediction/profile eligibility guard now also requires
positive information. Covariance matrices additionally carry rater IDs. These
post-pilot changes do not alter estimation or profile calculations: all 160
pilot fits pass the new guard, numerical function bodies are checked against
the archived source, and only eligibility and covariance labels differ.
The strict-guard/separation and labeled-covariance regression checks pass.
The known zero-variance case remains distinct from an estimated boundary.

The public tutorial includes the adverse coverage result, MC uncertainty,
observed-versus-replacement targets, assignment/missing-score handling and
save/load examples. Model-specific plot text is English. NEWS, README,
reference help and roadmap state the supported scope and remaining work.
No full package suite, earlier coverage study, hosted CI, commit, push, main
integration or publication was performed. Frozen outcomes, summaries and
source copies are under `validation-results/random-rater-20260923/`.
 Numerical success is separate from
Laplace accuracy, statistical coverage, rater-population representativeness,
and general model readiness. Public scope remains the stated RSM route.

## Estimated ability-population checkpoint, 2026-09-23

**Question and role in the roadmap.** M2 selected an estimated common normal
ability variance for both extensions: with a unit Rasch slope, fixing this
variance to one restricts the population rather than merely choosing units.
This M3 implementation connects that population to the existing shared-rater
workflow. It does not close M3's Person-scoring, ordinary-model comparison,
diagnostic-probability or statistical-qualification requirements.

`fit_mfrm_random_rater(person_sd = NULL)` now estimates normal ability SD,
keeping mean zero and free step location. A positive known SD retains the
restricted model; explicitly specifying one reproduces the previous N(0,1)
branch. `person_variance_max = 16` is a search bound, and a fit reaching it
fails numerical readiness. Both zero-variance faces and their intersection
are fitted explicitly. The rater variance score uses the matching ability
distribution; the ability variance score uses one-sided Richardson differences
of the full Laplace marginal objective, including its inner mode and determinant.
The SD derivative at zero is not used as evidence for a variance boundary.
Agreement of the two extrapolations is required to select that boundary;
positive interior fits do not require a precise zero-face slope when it is
clearly positive. Numerical and information tolerances were not relaxed.

First-order rater prediction covariance includes the estimated ability-SD
coordinate. At either estimated zero variance, regular calibration and rater
intervals remain unavailable. Rater-SD profiles re-estimate ability SD at
every candidate unless it was specified as known. They stop at an estimated
ability-variance boundary: the single-rater-variance reference is not qualified
for this additional nuisance boundary. No ability-SD interval is supplied.
Bootstrap generation uses the fitted ability SD, and each refit retains the
source's known/estimated choice and search bound. Trials retain ability SD
and its boundary status. Predictions at supplied abilities keep logit units;
those values are not multiplied by population SD. Reports list both variance
components, and source metadata prevents mixing incompatible predictions.
Older saved fits retain known N(0,1) for prediction, profile and bootstrap.

**Independent numerical evidence.** The focused tests compare nonunit-ability
binary likelihoods and all derivatives with independently computed adaptive
normal integrals. A separate optimizer and Hessian reconstruct the Laplace
objective and its zero-ability-variance derivative, including the determinant.
The zero-rater face is separately optimized using adaptive Person integration,
checking estimated ability SD, log likelihood and covariance. Joint-Hessian
implicit differentiation reconstructs generalized rater covariance including
the ability coordinate. Additional cases cover both estimated zero variances,
known nonunit SD, capped variance, saved metadata, re-estimated profile nuisance
SD and bootstrap regeneration/refitting. Existing ordinal likelihood references
remain on their explicit `person_sd = 1` branch. Focused checks passed for
random raters, bootstrap intervals, population extension and common extended
results; subsequent changes were checked only in affected population tests.
No full package suite or coverage simulation was repeated.

**Actual user workflow.** The example-core tutorial executed fit, profile,
19 planned bootstrap refits, observed/replacement predictions, two figures,
common report/export and reload. The source has 48 Persons, four raters and
four criteria. Estimated ability SD is 0.9686791 (variance 0.9383392); rater
SD is 0.2540316. At 121/243 points, log-likelihood difference is 5.894e-9,
gradient difference 1.950e-7 and optimization gradient 3.494e-5; information
is positive. The rater-SD profile endpoints are 0.1165953 and 0.6743442.
These are computational results for an example, not coverage evidence.

Of the 19 planned refits, 18 pass numerical/information checks; one of those
has zero estimated rater variance. Replicate 13 has positive information and
optimizer gradient 2.180e-5, but the 121/243-point gradient difference is
1.178e-4, above the unchanged 1e-4 limit. It correctly remains unresolved.
Thus two studentized roots per rater are unresolved; all planned trials stay
in the result and the 95% bootstrap limits are unbounded. Both English figures
were visually inspected; arrowheads preserve the infinite endpoints.

This reproduced integration failure showed that the previous public maximum
of 121 points prevented further accuracy refinement. The public maximum is
now 241 (higher-order check up to 483). A separately recorded fit of the
**same failed dataset** at 181/363 points passes: log-likelihood difference
8.369e-10, gradient difference 3.997e-7, positive information. This diagnostic
refit is not substituted into the original 19-draw experiment; no selective
replacement or new coverage claim is made. A higher integration setting should
be specified for a new complete analysis when needed, not applied only to
successful draws or used to change the original denominator. This is not a
universal quadrature sufficiency or capacity claim.

**Compatibility and documentation.** An actual saved fit from the earlier
fixed-population pilot (`pilot-final/trial-081.rds`) was refitted with known
ability SD one: rater estimates were identical, with matching likelihood and
covariance. Its profile and a bootstrap refit retain ability SD one. In a
fresh session without RTMB, the new saved fit reproduced predictions, variance
tables, bootstrap reports and plots. README, NEWS, model/interval/prediction
help, tutorial, interval guide and active roadmap were aligned. Changed Rd
pages parse/render and resolve their local topic links. Rendered pages contain
no internal workspace paths. The tutorial execution precedes only the small
public quadrature-range extension and its prose; the new 181-point route was
separately executed and checked. No full tutorial/bootstrap rerun was needed
for that range change.

Evidence: `validation-results/random-rater-population-20260923/`, including
`focused-tests.log`, `population-final.log`, `tutorial.rds`, rendered tutorial
and figures, `unresolved-refit-13.rds`, `refit-13-order181.rds`,
`legacy-replay.rds`, offline replay, source diff and hashes. Early replay
harness attempts selected a pre-API object and then a nonexistent old pilot
path; the final replay uses the actual public fit in `pilot-final`. No package
failure is inferred from those harness mistakes.

**Limits and next dependency.** Existing 160-dataset and 24-dataset interval
pilots both fixed ability SD as known at one; their scripts now say so
explicitly. Their outcomes do not qualify the estimated-population route or
repair few-rater undercoverage. Common normality and assignment independence
remain substantive assumptions. Next implement proper Person scoring that
integrates joint shared-rater uncertainty, followed by matched ordinary-model
comparisons and declared descriptive diagnostics. MI adequacy, retained
interval qualification and the frozen statistical protocol remain M2 work.
There was no commit, push, CI, main integration, archive freeze or publication;
the M5 local endpoint has not been reached.

## Joint conditional Person-scoring checkpoint, 2026-09-23

**Question and place in the roadmap.** M3 requires Person scoring under the
shared-rater model, rather than substituting estimated rater modes into an
ordinary Person scorer. The new local `score_mfrm_random_rater()` returns
EAP, posterior SD and continuous equal-tail intervals. This closes the initial
scoring implementation/connection dependency, not the remaining comparison,
diagnostic, approximation/interval qualification or M5 requirements.

For fixed calibration and the complete scoring roster, let
`L_j(u) = integral p(y_j | theta_j, u) phi_p(theta_j) d theta_j`.
The marginal posterior target for Person p is proportional to
`phi_p(t) integral phi_r(u) p(y_p | t, u) product_{j != p} L_j(u) du`.
Other Persons are integrated by normal quadrature. For every focal ability t,
the complete rater vector is integrated by conditional Laplace, recomputing
its conditional mode and determinant at that t. The resulting univariate
approximate density is normalized continuously. This is not independent
integration of marginal raters, and a fitted rater mode is not treated as known.
It is an explicit approximation to the joint latent posterior; pointwise
Laplace followed by normalization must not be described as exact posterior
integration or assigned the fitted marginal likelihood as its normalizer.
The normal population/effect-sharing model and Laplace framework remain those
mapped in the existing literature review; no new paper was claimed to validate
this scoring implementation.

**Data and uncertainty contract.** `persons` selects returned rows while
retaining all roster responses in the likelihood. `newdata` replaces the
entire scoring roster, rather than automatically appending calibration data.
New Person/rater IDs are allowed under the specified populations; all fixed
facet levels must be known. Scoring never recalibrates fixed effects, steps
or population variances. Missing assigned scores require explicit omission;
all-missing Persons retain prior-only rows. Zero ability variance and failed
numerical calculations retain unavailable rows and reasons. Source fits now
retain their assigned roster; older fits with omitted rows must be given that
roster explicitly because lost IDs cannot be reconstructed. Older fits without
ability-population fields keep known N(0,1). The scored intervals exclude
calibration/population estimation uncertainty, Person contrasts, simultaneous
decisions and general frequentist coverage claims.

**Numerical implementation and independent checks.** The existing shared-rater
likelihood gained a focal-ability coordinate; its ordinary fitting path is
unchanged. The testlet continuous moment/CDF integrator is reused. Density
knots around the mode refine from 65 through at most 1025, caching exact
conditional-Laplace evaluations and retaining true likelihood evaluations in
the tails. Refinement gates moments, endpoints and normalizer, followed by the
existing higher-order Person-quadrature comparison. Ordinary CDF evaluations
reuse their mass at the mode instead of repeating expensive infinite-tail
integrals. Very small requested tails retain direct integration to avoid
cancellation. The integrator uses relative tolerance 1e-9 and absolute tolerance
1e-12 for peak-scaled density; endpoint checks remain explicit. This does not
relax the scoring acceptance tolerances or establish Laplace accuracy.

The independent references check:

- The focal joint likelihood against direct ordinal probabilities and adaptive
  normal integration; conditional Laplace values against a separate rater-mode
  optimizer and Hessian at several focal abilities.
- Interpolated scores against continuous integration of the original,
  uninterpolated conditional-Laplace density.
- Known-zero-rater scores against independently integrated means, SDs and tail
  probabilities under a nonunit normal population.
- Shared evidence: output selection agrees with full-roster scoring; changing
  only other Persons' responses changes the focal score, whereas relabeling
  shared raters does not. Subsetting the input roster differs from selecting
  output IDs. An explicit replacement roster does not double-count responses.
- Missing/prior-only, zero-population, forced-failure and legacy cases, together
  with source guards, plotting, report tables and simultaneous attachment of
  Person scores and response-probability predictions.

A separate exact tensor reference integrates two shared raters and the other
Persons in a three-Person, two-rater ordinal design, with fixed ability SD 1.2,
rater SD 0.7 and steps (-0.6, 0.6). Increasing tensor order from 31 to 51 changes
all four summaries by less than 1e-7. For Person A:

| Calculation | EAP | Posterior SD | Lower 95% | Upper 95% |
| --- | ---: | ---: | ---: | ---: |
| Exact tensor reference | -0.6545036 | 0.8518224 | -2.360898 | 0.9880214 |
| Conditional joint-rater Laplace | -0.6565082 | 0.8525697 | -2.363209 | 0.9883966 |
| Rater-mode plug-in | -0.6415549 | 0.8109085 | -2.284996 | 0.9096256 |

The nonzero EAP difference of -0.0020046 and SD difference of 0.0007473 are
Laplace approximation errors in this example, not implementation discrepancies
to hide by changing a tolerance. The mode plug-in has different uncertainty.
This single reference does not establish approximation accuracy, bias or
coverage across designs, sparse panels, few raters or misspecified populations.

**Executed user workflow and cost.** The existing example-core fit, rater-SD
profile and 19-draw bootstrap were reused, preserving their original unresolved
trials. The updated article executed new Person scoring, probability predictions,
figures, combined report/export and reload; it did not repeat calibration or the
bootstrap. All 768 observed rows from 48 Persons remain in the scoring likelihood
when returning P001 and P002. Their conditional EAPs/SDs are 0.5958329/0.3131345
and 1.4094427/0.3543709; intervals are [-0.0101255, 1.2183163] and
[0.7364870, 2.126690]. Both rows pass 121/243-point checks (maximum reported
integration differences 4.137e-9 and 4.415e-9). The new article execution took
88.3 seconds locally, including scoring two Persons, other new chunks and
render/export. This is a recorded workload, not a throughput benchmark or
capacity guarantee; whole-cohort and larger-design computational qualification
remain open. The initial direct continuous implementation took 61.1 seconds
for one Person at the lower order alone, motivating the checked reuse above;
these timings have different scopes and do not define a speedup factor.

Base and ggplot scoring figures and an actual prior-only figure were visually
inspected. English captions retain conditional calibration, rater Laplace and
prior-only meanings; unavailable rows are not discarded. `mfrm_results()` now
accepts `scores` alongside response `predictions` and rater `intervals`.
Scoring settings, full roster, omitted rows, statuses and model metadata survive
CSV/HTML/RDS export and fresh-session replay without RTMB. No refitting or
rescoring is done by plotting/reporting/export. The shared testlet moment/CDF
path and the unfocalized random-rater likelihood passed affected regression
checks; the complete package suite and old coverage experiments were not rerun.

The first focused run exposed overflow in the independent reference's naive
`exp(eta)` probabilities at infinite-integrator tail nodes. Stabilizing that
reference on the log scale fixed it; the package likelihood already used
stable log calculations. The final affected scoring, reporting, namespace,
testlet-population/integration and existing testlet/random-rater tests passed.
The initial fixed-width interpolation grid also failed its accuracy gate;
its refinement and curvature-scaled knot span were resolved before the
executed article. An early example invocation used an absent Person ID and
was correctly refused. These are development/harness findings, not excluded
statistical replications.

Evidence is under `validation-results/random-rater-scoring-20260923/`:
`affected-tests.log`, `shared-kernel-regression.log`, `exact-comparison.rds`,
`workflow.rds`, the rendered article and figures, offline combined-export/replay,
changed help pages, per-turn source diff and hashes. Help, NEWS, README, output/
interval guides and active roadmap distinguish this conditional scoring route
from response prediction, statistical qualification and remaining diagnostics.
The last mathematical help paragraph and small documentation edits were rendered
separately; no repeated bootstrap/article calculation was needed for prose.

Next M3 dependency: matched-data ordinary-MFRM comparisons and descriptive
probability/fit summaries, retaining population and response-event definitions.
M2's MI adequacy, retained interval qualification and bounded statistical
protocol remain open. Neither numerical convergence nor this scoring API
closes the known few-rater undercoverage concern. No commit, push, main merge,
CI, source-archive freeze or publication was performed; M5 is not complete.


## Estimate-view and accessibility checkpoint, 2026-09-23

**Question and scope.** The user requested useful alternatives to forest plots,
accessible presentation and control over titles/annotations. This is M4 output
integration for the existing saved estimates, not implementation of M3 model
comparisons, predictive diagnostics or Wright/pathway displays. The common
renderer now supports interval, estimate-versus-interval-width, and empirical
cumulative-distribution views for shared-rater severity, conditional Person
scores from both extensions, and testlet fixed-facet calibration. The bootstrap
comparison keeps its interval view; it now also converts to ggplot while
retaining infinite ends as arrows and ordinary intervals as a dashed comparison.

**Contract.** Sorting affects presentation only; the original table, missing
and infinite bounds, statuses, settings and calibration checks remain intact.
Precision requires finite interval width and records excluded rows/reasons.
The empirical CDF excludes prior-only/unavailable scores, retains tied values
with their empirical mass, and represents selected point estimates rather than
a latent population or posterior density. No density is fabricated from
interval endpoints. Complete source tables, display inclusion/reasons,
interpretation notes and an alternative description remain available through
plot-data accessors. Titles/captions may be replaced or hidden; labels,
reference lines, text/point size and a monochrome palette are configurable.
Shapes supplement colour, and line types distinguish bootstrap from ordinary
intervals. ggplot carries an alt description; the new tutorial figures have
explicit HTML alt/aria labels. This is not an accessibility-conformance audit;
image exports still need their text/table alternatives supplied by the author.

**Verification.** Focused display contracts, existing testlet integration and
bootstrap interval algebra/display checks pass. They check tied CDF values,
missing/prior-only/all-unavailable rows, unbounded arrows, colour-independent
symbols/lines, hidden/custom text, legacy payload conversion, serialization and
graphics-state restoration. RTMB was deliberately absent from this run; the
existing bootstrap generation/refit test was skipped and was not rerun for a
presentation-only change. Saved actual fits, Person scores, full report routes
and the existing 19-draw bootstrap were replayed in a fresh session without
RTMB, fitting, scoring or resampling. The new tutorial chunks executed at their
specified dimensions, and six changed Rd topics parsed and rendered. Base and
ggplot figures were visually reviewed. Two all-unavailable rendering errors
and overlapping multiline base captions were found and corrected during this
work. Final figures show readable labels and separate captions.

Evidence: `validation-results/extended-plot-views-20260923/` contains focused
logs, saved view payloads, actual tutorial-chunk rendering, example PNGs,
rendered help, replay code and per-turn source hashes/diff. Source interval
accuracy is unchanged; the earlier shared-rater undercoverage and conditional
scoring limitations remain. M3 comparison/diagnostic implementation, M2
qualification/protocol and M5 integration remain open. No full suite, new
simulation, commit, push, CI, main integration or publication was performed.


## Matched-event facet comparison checkpoint, 2026-09-23

**Question and scope.** How do the fitted rater and other fixed-facet effects
change when the same observed ratings are fitted with an ordinary RSM and
either extension? `compare_mfrm()` now supplies a distinct descriptive
`mfrm_extended_comparison` for one ordinary RSM MML fit and one extension.
This completes the facet-effect part of M3 comparison, not Person-score,
predictive-performance or inferential model selection.

**Comparability contract.** The comparison verifies observed event identities,
scores and repeated-event multiplicities, category mapping, unit weights,
additive severity facets, lack of anchors/shrinkage, and the common-normal
population assumption. Estimated-SD extensions require the ordinary
intercept-only estimated population; known N(0,1) remains a separate matched
route. It records their different population/step location conventions.
Effects are centered at the unweighted mean over the same complete set of
levels in each facet, preserving within-facet contrasts. Raw estimates and
the subtracted means remain available. Fixed coefficients and conditional
random-rater modes have separate labels; shrinkage is not evidence of
improved accuracy. Failed numerical checks, blocked ordinary readiness and
excluded parameter statuses withhold affected comparisons. Wider ordinary
inference readiness remains explicit when descriptive point estimates are
available. No difference SE/CI, preferred model, AIC weight, Person-count BIC
or ordinary chi-squared variance-component LRT is supplied.

The ordinary preparation object now retains only its excluded rows and input
row indices before filtering. Observed-data filtering is unchanged. With
missing scores, both saved fits must retain identical omitted-event identities;
equal omitted counts alone are insufficient. Missing IDs, excluded weights and
population-data omissions are refused. Older ordinary fits with omissions but
without this provenance require refitting from the assigned-score roster.
The extension's testlet membership is retained when checking report attachment.

**User output.** Paired-effect and mean-versus-difference views provide facet
selection, labels, accessible/monochrome palettes, text/point sizes, custom or
hidden titles/captions, base and ggplot rendering, and source tables/text
alternatives. Lines indicate equality or zero, not decision thresholds.
`mfrm_results(extended_fit, comparison = comparison)` connects the saved object
to reports, CSV/HTML/RDS export and replay, without fitting or resampling.
Both tutorials now show a matched ordinary reference with the appropriate
population setting and explain the interpretation limits. Help, NEWS, README
and the active roadmap/claim inventory are aligned; obsolete tutorial claims
that these comparisons are wholly unavailable were corrected.

**Verification and limits.** Reused the existing 768-rating educational example
and both saved extension fits, fitting one matching ordinary reference. The
maximum absolute centered rater change was 0.038629 logits for shared raters;
the testlet comparison's largest absolute fixed-facet change was 0.007466
logits. These are descriptive differences in this example, not accuracy or
preference claims. Native numerical checks passed; its broader inference
readiness remained `review` (design rank not evaluated).

A separate known-zero testlet-variance fit checked the ordinary reduction,
with the same estimated ability population and 121-point quadrature. Before
running, absolute tolerances were set to 1e-5 for log likelihood/category
probabilities and 1e-4 for facets, steps and ability SD. Maximum discrepancies
were respectively 4.44e-9, 3.89e-7, 1.69e-7, 1.17e-6 and 1.33e-6; all passed.
Steps were aligned by the ordinary population intercept. Category probabilities
were independently reconstructed from cumulative adjacent logits at abilities
-2, 0 and 2 over all 16 facet profiles. This checks numerical reduction and
location alignment, not interval coverage or general software equivalence.

Reused the existing incomplete-design testlet fit and its assigned roster:
320 assigned events, 306 observed events and 14 omitted scores. A matching
ordinary reference verified all omitted identities and retained them in the
saved comparison/report. No new incomplete-design simulation was generated.
Focused tests for extended comparison, extended results, namespace registration
and existing missing-code integration all passed. They include event
multiplicity, mismatched inputs, unavailable/blocked outputs, complete-level
centering, graphics-state restoration and serialization. The ordinary-only
comparison result was identical to the pre-change implementation on saved fits.

Both actual workflows exported with zero plot errors. Fresh-session execution
of the generated replay scripts recovered identical effect tables, reports and
both plot views without RTMB, fitting, scoring or resampling. New tutorial
comparison chunks ran using the saved matching ordinary fit; their fitting
chunk was displayed but not rerun. Six changed help topics parsed and rendered;
the temporary unresolved new-topic link on first generation disappeared after
the new topic existed. Base/ggplot figures were visually reviewed, clipping was
corrected, and tutorial images retain nonempty `alt` and `aria-label` text.
This is not an accessibility-conformance audit.

During validation, an incorrectly ordered private fixture call and missing
expected S3 registrations in the namespace test were fixed. The export
overwrite safeguard correctly refused an initial rerun. A tutorial-section
extraction pattern selected too many headings and attempted an unavailable
RTMB route before fitting; exact-heading extraction corrected the harness.
These initial logs are retained with the successful final runs.

Evidence: `validation-results/extended-comparison-20260923/` contains saved
fits/comparisons, the independent zero-variance reference, incomplete-design
check, focused logs, tutorial/help rendering, plot exports, offline replay and
source hashes/diff. The next M3 implementation dependency is matching posterior
response moments and descriptive Infit/Outfit, followed by their model-aware
figures and broader comparisons. M2 interval qualification, MI adequacy and
the fixed statistical protocol remain open. M5 is not complete. No full suite,
broad simulation, commit, push, CI, main integration or publication was run.
