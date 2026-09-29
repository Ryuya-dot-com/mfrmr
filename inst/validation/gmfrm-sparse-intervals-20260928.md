# Two-family intervals under cost-matched sparse allocation

## Protocol fixed before sampling

**Question.** In the admitted fixed-N(0,1), unweighted two-family MML--EM
model, how do assignment overlap and weaker response information affect
component-slope bias, interval availability and nominal 95% coverage? This
is an initial finite-condition performance check, not release qualification
or a comparison with a different software/model.

**Design.** Each dataset has 240 independent Persons, three tasks, six fixed
raters and observed scores 0--2. All assigned raters score all three tasks for
their assigned Persons. Both rosters have 1,440 ratings and 80 Persons/240
ratings per rater. In `common_persons`, 48 Persons are scored by every rater,
and the remaining 192 by one rater each (32 per rater). In `rotating_pairs`,
each of six adjacent pairs on a ring scores 40 Persons. Persons are randomly
allocated independently of ability. This compares a concentrated overlap
design with a distributed overlap design at equal total cost; the per-Person
information distributions differ. It does not isolate an abstract graph effect.
Common Persons are links, not fixed parameter anchors. No score missingness
occurs within an assignment and no unassigned rating is imputed.

**Data and truth.** A literal product-slope adjacent-category equation generates
ratings independently conditional on ability. Task locations are (-.4,.1,.3),
task slopes exp(-.2,0,.2), rater locations equally spaced from -.3 to .3,
rater slopes equally spaced from .75 to 1.25, and rater steps are symmetric
pairs with half-widths .45 to .70. Ability is normal with mean zero and SD
either 1 or .5. The second condition reduces response information while keeping
the original rating coefficients fixed. For the fitted fixed-N(0,1) model,
task slopes retain their geometric mean one, rater slopes multiply by the
generating SD, and locations/steps divide by it. This is a correctly specified
scale transformation, not nonnormality or informative assignment.

Within each replicate, all four conditions share the same standardized latent
abilities and potential-rating uniforms; each design's roster is reused across
SD settings. Replicates have independent prespecified seeds. The two designated
summary targets are task t1 and rater r1; every other component is also saved
and summarized separately. Slopes or Persons within a dataset are not counted
as independent simulation repetitions.

**Methods.** Exactly the public `fit_mfrm()` and `confint()` routes are evaluated:
31-point fixed quadrature, up to 500 EM iterations, per-Person score tolerance
1e-6, model-based pointwise 95% log-Wald intervals. The existing 31-versus-61
information/score check and all other interval checks remain unchanged. No
retry, truth-based start, automatic quadrature escalation or post-hoc relaxation
is included. Fits and interval objects, warnings, failures, source hashes and
seeds are saved per case so subsequent diagnosis need not repeat fitting.

**Size and outputs.** There are 100 repetitions per condition, 400 fits in all.
At 95% coverage with every interval available, binomial Monte Carlo SE is about
2.18 percentage points; fewer available intervals increase uncertainty. This
can reveal large deficiencies but cannot resolve small departures from 95%.
The full fixed count is run without a wall-time truncation rule. Initial timing
runs use the first planned repetitions and remain in the final denominator.
Two computation workers are used; this is not agent delegation.

For each component/condition report attempted fits, convergence, interval
availability, conditional coverage, and the proportion both returned and
covering among all attempts. Availability and both coverage proportions have
exact binomial Monte Carlo intervals. Log-slope bias/RMSE are conditional on
numerically converged finite estimates; their denominator is shown. For returned
intervals compare empirical log-estimate SD with root mean squared log-SE and
report mean log width. Missing intervals count against delivery, not as observed
noncoverage in conditional coverage. Failure stages remain separate. No pooled
"overall coverage" across heterogeneous parameters or multiplicity claim is made.

**Decision.** A software inconsistency requires a targeted repair and separately
identified reevaluation. Numerical or sampling failures are retained and reported,
not automatically treated as software bugs. Adequate results only support these
specific designs. Lost bridges, smaller samples, nonnormal/informatively assigned
ability, more extreme slopes, slope products/curves, anchors and broader models
remain separate questions. This does not close G3, corrected JML or release checks.

The planning/reporting distinction follows Morris, White and Crowther (2019),
*Using simulation studies to evaluate statistical methods*, Statistics in
Medicine, 38, 2074--2102, <https://doi.org/10.1002/sim.8086>.

Reproduce from the package root:

```sh
Rscript inst/validation/gmfrm-sparse-intervals-20260928.R run validation-results/gmfrm-sparse-intervals-20260928 1 100 2
Rscript inst/validation/gmfrm-sparse-intervals-20260928.R summary validation-results/gmfrm-sparse-intervals-20260928
```

Existing case files are reused only when their seed/case identity and source
hash agree. The summary requires all 400 planned case files.

## Numerical review added during execution, before coverage summaries

The first two repetitions revealed a mismatch between the fitter's mean-score
stopping rule and the interval helper's 1e-4 curvature-scaled score cutoff.
The observed scaled scores were roughly 0.0001--0.0003; several otherwise
numerically regular fits were excluded. These are local standardized Newton
displacements, not large parameter movements. The original 400-fit protocol
continues unchanged and its results are retained as the baseline.

A separate review uses replicate 1 of all four conditions at 61 quadrature
points and `em_score_tol = 1e-7`, with the same 500-iteration cap and neutral
start. All four original files and revised fits are retained. An initial
1e-8 attempt on the common-Person SD=.5 case stalled at a mean score of
1.71e-8 for 500 iterations and is also retained. At 1e-7, the rotating-pair
SD=.5 fit still reaches the iteration cap. Thus merely asking users to tighten
the tolerance is not a sufficient remedy: a flat EM auxiliary objective can
stall while the point estimates change negligibly.

Before inspecting coverage, the numerical policy to evaluate next is: retain
the 1e-4 standardized-score cutoff as a warning threshold; withhold intervals
above 0.01 instead. The original mean-score, information, inverse, local-rank
and quadrature checks remain unchanged. The 0.01 tolerance also matches the
existing integration-score displacement budget. In a local quadratic
approximation, sqrt(g' V g) bounds the Newton correction to any log-slope
component in its own SE units; it is not a global-maximum or coverage theorem.
Every newly admitted interval retains the additional warning and measured
displacement. This change is based on numerical error relative to uncertainty,
not on choosing a cutoff to maximize empirical coverage.

After baseline completion, reevaluate `confint()` on all 400 saved fits, keeping
the parameters, response data and integration settings unchanged. Preserve
both interval objects, source versions and denominators, and report this as
a revised-rule reanalysis, not an independent confirmatory sampling study.

## Completed results

All 400 planned fits completed and met the original EM stopping rule. The
baseline took 927.839 worker-seconds; requalifying the saved fits took 863.052
worker-seconds (two workers, not elapsed wall time). All 400 fit objects were
verified identical before and after reanalysis. The 95 originally admitted
cases retained exactly the same bounds. Another 215 cases now return the same
local approximation with the small-residual warning. No fitting or response
generation was repeated in this reanalysis.

Each row below has 100 attempts. Interval availability was identical across
the nine components within each fit in this study. Coverage columns concern
the two prespecified targets; the last columns keep all attempts in the denominator.

| Allocation | Ability SD | Old → revised available | Task t1 covered / available | Rater r1 covered / available | Task returned and covered / attempted | Rater returned and covered / attempted |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Common Persons | 1 | 5 → 11 | 10/11 | 11/11 | 10/100 | 11/100 |
| Rotating pairs | 1 | 90 → 100 | 93/100 | 95/100 | 93/100 | 95/100 |
| Common Persons | .5 | 0 → 100 | 97/100 | 95/100 | 97/100 | 95/100 |
| Rotating pairs | .5 | 0 → 99 | 90/99 | 95/99 | 90/100 | 95/100 |

For rotating pairs at SD=.5, t1 conditional coverage is 90.91%, with a 95%
exact Monte Carlo interval of 83.44--95.76%. Its empirical log-estimate SD is
0.17775 versus root mean log variance 0.15496, suggesting that the approximation
can understate sampling variability in this setting. Nominal 95% coverage is
not established by this imprecise result. For common Persons at SD=1, the
11/11 r1 result has a Monte Carlo interval of 71.51--100%; it is not strong
coverage evidence, especially with only 11/100 intervals delivered.

All nine components were reviewed, not just the designated examples. Their
conditional coverage ranges were 93--98% for rotating SD=1, 93--100% for common
SD=.5, and 90.91--95.96% for rotating SD=.5. The common SD=1 selected subset
ranged from 9/11 to 11/11 and is too sparse to support a design-level claim.
Observed log-slope bias also remains: common SD=.5 rater r3 had mean error
-0.11068 (Monte Carlo SE 0.03230); its conditional coverage was 99/100. High
coverage does not demonstrate absence of bias. These componentwise summaries
are descriptive; no multiplicity-adjusted test or pooled coverage is claimed.

**Failure attribution matters.** The remaining 89 common-Person SD=1 failures
are all quadrature-sensitivity failures. Every other numerical check passed.
This is not evidence that the assignment graph cannot identify the two families:
common Persons contribute 18 ratings each, whereas a rotating-panel Person
contributes six. Equal quadrature order does not establish equal integration
accuracy. A design-efficiency or statistical coverage comparison requires
resolving this numerical discrepancy first. The four-case denser-grid review
supports further investigation but does not qualify all 89 cases.

The remaining rotating SD=.5 failure is replicate 26: one rater slope is about
.00661, and the standardized Newton displacement is .06753 despite a mean
score below 1e-6. The larger-error refusal is retained. A near-zero finite
optimizer value and positive local curvature do not settle the boundary/global
maximum question.

Full per-component bias, RMSE, SE calibration, widths and exact Monte Carlo
intervals are in `validation-results/gmfrm-sparse-intervals-20260928-revised/summary.csv`;
`rows.csv` retains every component/attempt and `dispositions.csv` every fit's
failure stage. The baseline directory and every original interval object remain
available. Reanalysis is executable with:

```sh
Rscript inst/validation/gmfrm-sparse-reanalysis-20260928.R validation-results/gmfrm-sparse-intervals-20260928 validation-results/gmfrm-sparse-intervals-20260928-revised
```

The output directory must be new. Current-source reruns of the baseline script
use the revised interval rule; original-rule results are the preserved objects
with their original hashes and the explicit 1e-4 refusal rule above.

The regression tests in `test-gmfrm-slope-intervals.R` preserve both the small
residual and larger-displacement examples without repeating the simulation.
They also check unchanged estimates and warning propagation into plots and
reports. That file, `test-gmfrm-public-workflow.R` and
`test-gpcm-inference-reporting.R` pass. Rd/usage and whitespace checks pass;
the updated guide renders with simulation examples disabled. The default
warning plot was visually checked. No whole-suite test or external-software
run was added.

**Milestone decision:** this is a completed first sparse-design sampling check
and a numerical-availability repair, not completion of G3. Next resolve the
common-Person integration issue on the saved datasets before interpreting
between-design coverage/precision. Then revisit the observed log-slope bias
and SE underestimation with an explicitly fixed procedure. Broader distributions,
lost bridges, anchors, products/curve intervals and independent confirmation
remain open; corrected JML and integrated release milestones are not closed.

## 2026-09-28: matched quadrature follow-up

The remaining integration failure is reviewed using all 100 saved
common-Person, SD=1 datasets, including the 11 that already returned intervals.
No responses are regenerated and no failures are removed from the denominator.
The public `fit_mfrm()` call is replayed from its neutral start at 61 points;
the original `em_score_tol = 1e-6` and `maxit = 500` are retained. Each new
`confint()` also compares 61 versus 121 points at the saved new estimate,
without refitting at 121. This separates the integration change from the
earlier change to optimization-warning policy.

`gmfrm-sparse-quadrature-20260928.R` retains the old and new fits, intervals,
warnings, failed checks and source hashes. Summaries retain all attempts,
conditional coverage, returned-and-covered proportions, component log bias
and Monte Carlo uncertainty. These are same-data numerical follow-up results,
not an independent sampling confirmation or a guarantee that 61 points will
work for other rating designs. Review movement of estimates and information
as well as whether intervals are returned; increasing availability alone
does not establish their statistical accuracy.

**Completed:** `validation-results/gmfrm-sparse-intervals-20260928-q61/`
contains all 100 refits, `manifest.rds`, `rows.csv`, `summary.csv` and
`dispositions.csv`. All 100 converged and returned all nine component
intervals, versus 11/100 interval sets at 31 points under the same warning
rule. All passed the new 61-versus-121 checks. Total worker time was 527.085
seconds across two workers (not elapsed wall time).

| Prespecified component | Covered / available / attempted | Conditional coverage | Monte Carlo 95% interval | Log bias (MCSE) |
| --- | --- | ---: | --- | --- |
| Task t1 | 93 / 100 / 100 | .93 | .8611--.9714 | -.01489 (.01160) |
| Rater r1 | 98 / 100 / 100 | .98 | .9296--.9976 | -.01370 (.01929) |

Across all nine components, coverage ranged from .90 to .98. Task t3 had
90/100 coverage, MC interval .8238--.9510, empirical log SD .12981 and root
mean estimated variance .11034. Rater r3 retained log bias -.05808 (MCSE
.01632), despite 97/100 coverage. These are descriptive results on these
100 datasets, with no multiplicity-adjusted claim or general coverage
qualification. The .5-SD conditions and their earlier bias/SE discrepancy
were not rerun or reclassified.

**Numerical movement:** using the full unregularized joint information at
each saved estimate, the largest component log-slope change across the 100
datasets was .010617; the maximum component change divided by its 61-point
log SE was .058889. The largest relative log-SE change was .017887 (1.79%).
For the new 61-versus-121 fixed-parameter checks, the maximum standardized
score shift was .003236 and maximum covariance change .004837 (both below
.01). No threshold or EM stopping control was relaxed. Availability improved
greatly despite relatively small changes in component estimates and SEs;
this reinforces the distinction between interval delivery and coverage.
The full numerical comparisons are retained in `movement.csv`.

**Public workflow:** `mml_quadrature_sensitivity()` and its GPCM entry point
now replay two-family fixed-grid models through `fit_mfrm()`, preserving
owner order, category range, neutral start and EM controls. The result retains
full interval objects under `$intervals`, in addition to component tables and
probability changes. These use the existing `plot()` and `apa_table()` routes;
there is no new competing entry point. Overlapping owner-level labels are
matched within owners. Person-score comparisons remain explicitly missing,
and adaptive review is rejected for this scope. The original fit and global
readiness are unchanged. Public help and NEWS explain the distinction.

**Verification:** the two-family quadrature tests and existing one-family
GPCM / RSM / PCM quadrature tests pass. They cover same-data/model replay,
retained controls, overlapping names, joint-information SEs, probability
agreement, missing/available intervals, warnings, summaries, APA tables and
saved-object replay. No whole-suite rerun or additional response simulation
was needed.
The nonconverged-refit case also retains missing intervals and a reason.
Affected helper usage and Rd checks pass, and the scope guide renders with
its costly examples disabled. `git diff --check` is clean.

**Milestone decision:** the observed common-Person integration failure is
resolved within this saved sample. G3 remains open because sampling bias,
SE accuracy, boundary behavior and independent confirmation remain unresolved.
The next inferential decision must address these issues with a fixed procedure;
neither more quadrature points nor wider output support closes them. The
multivariate G-theory, corrected-JML and integrated release milestones retain
their separate acceptance requirements.

## 2026-09-29: separate sampling discrepancies from profile computation

The saved component rows were reviewed without refitting or generating data,
replacing only common-Person SD=1 rows by their already retained 61-node
follow-up. The common-Person SD=1 Task t3 Wald intervals miss below truth in
4/100 cases and above truth in 6/100; standardized log errors have mean
-0.0123 and SD 1.1511. This is not a purely one-sided bias problem. For
rotating-pair SD=.5 Task t1 the corresponding counts are 1/99 and 8/99
available intervals; the standardized errors have mean .1618 and SD 1.1504.
The remaining attempt remains unavailable. These are exploratory diagnostics
of the existing sample, not independent evidence or a reason to inflate all SEs.

Rater r3 also illustrates why bias, variance and coverage cannot be collapsed
into one success score: in common-Person SD=1 its log bias remains -0.05808,
while standardized error SD is .8063 and coverage is 97/100. Error and estimated
log SE are strongly negatively correlated (about -.8724). This motivates
examining likelihood shape and nuisance coupling, but it does not prove that
profiling or a sandwich covariance will improve coverage.

**Implementation decision.** Reuse the existing component-profile likelihood
search through `confint()` rather than change the default estimator, insert
empirical inflation constants, or start another broad sampling grid. The
two-family route now accepts one named owner/level, preserves the first-family
geometric-mean-one constraint and fixed N(0,1), and reoptimizes every other
slope, location and step. The result is a local connected chi-square(1)
approximation, not a boundary certificate. Profiling remains an explicitly
selected sensitivity analysis; no automatic Wald/profile selection is supplied.
The likelihood-profile versus curvature distinction follows the general
principle described by Bates et al. (2015),
<https://doi.org/10.18637/jss.v067.i01>; that mixed-model reference does not
validate coverage for this GMFRM. The existing profile help also cites Fischer
and Lewis (2021); the implementation does not adopt their RVM algorithm.

**Numerical example, not a sampling study.** The retained 240-Person,
three-task/three-rater dataset from `gmfrm-joint-information.rds` supplies a
dependent Task t3 and a free Rater r3 target. Earlier 61-node profiles each
had one unresolved endpoint. The Task failure exposed a shared optimization
omission: a low-grid nuisance gradient just below 1e-4 bypassed curvature
refinement although the higher-grid gradient was 1.00323e-4. The helper now
attempts its existing refinement for either grid's score failure. Recomputing
only that failed 61-node neutral-start point reduces the fitting-grid gradient
from 9.73655e-5 to 5.07257e-11 and the reference gradient from 1.00323e-4 to
1.36474e-5; it now passes without a grid change. The before/after point is
retained in `curvature-refinement.rds`. Tests retain the same thresholds and
confirm that substantive integration errors still fail.
The Rater failure was different: at an outward bracketing value its NLL and
gradient differences were .000452 and .004763, requiring explicit integration
refinement. No failure was relabelled as an unbounded interval.

With explicit 121-node refinement of the source (and 241-node profile checks),
both endpoints are available for both targets:

| Component | Profile 95% limits | Same-target Wald limits |
| --- | --- | --- |
| Task t3 | .898828, 1.227248 | .900647, 1.228492 |
| Rater r3 | 1.069859, 1.585058 | 1.074609, 1.590472 |

These close results do not establish an advantage. The complete searches took
133.683 and 127.729 seconds; they are not inexpensive substitutes for a Wald
calculation in this implementation. Source refinement was explicit, not an
automatic change inside `confint()`. The original 61-node failures and final
objects are preserved in `validation-results/gmfrm-profile-20260929/`; the
documented regression fixture preserves both completed targets and an actual
unresolved profile. Literal response probabilities and normal marginal
integration independently reproduce the baseline and endpoint likelihoods
within 1e-5 absolute NLL, and all endpoint LR cutoffs within 1e-4.

The output contract includes named/Unicode owners and overlapping level labels,
owner-aware curve axes, the same-target Wald comparison, unavailable endpoints,
source-matched reports, exports and replay without reoptimization. It does not
make a rejected weak/near-zero source eligible. Formal model comparisons,
calibration bias correction, general coverage, and independent confirmation
remain open. Before sampling, fix the target components, numerical grid/refit
policy, profile controls and method comparison; report every attempted fit,
endpoint availability, conditional coverage, returned-and-covered fraction and
computation cost. Choose repetitions for the intended precision and measured
cost, without stopping at a wall-time limit or selecting successful profiles.


**Checks for this increment:** the common profile regression tests, two-family
profile tests and existing two-family log-Wald tests pass. They retain the
ordinary one-family behavior and actual unresolved profiles. Usage and Rd
checks pass. Profile figures were rendered and inspected; their captions
identify the LR cutoff and Wald limits, while custom/removed captions remain
supported. No whole-suite rerun or independent sampling study was performed.

## 2026-09-29: profile computation and independent feasibility

Before expanding sampling, the profile calculation was matched against the
EM model's existing cell-aggregated marginal objective. This is the observed
marginal likelihood/score with newly computed Person posteriors at every
parameter vector, not a frozen-posterior Q function. The adapter restores
total-likelihood units from the EM helper's per-Person average. Its cache owns
the parameter snapshot and publishes it only after successful evaluation;
invalid trials retain the original direct evaluator's boundary behavior.
The one-family path and all profile tolerances remain unchanged.

Across 42 saved source, neutral and constrained parameter vectors, at both
121 and 241 nodes, the maximum absolute NLL discrepancy is 4.55e-13 and the
maximum score discrepancy is 1.78e-13. Paired objective/gradient evaluations
took 2.815 versus .177 seconds at 121 nodes and 5.097 versus .269 seconds at
241 nodes. Complete public searches on the retained example give:

| Target | Original search seconds | Aggregated search seconds | Public call seconds | Maximum endpoint difference |
| --- | ---: | ---: | ---: | ---: |
| Task t3 | 133.683 | 13.378 | 20.867 | 1.58e-14 |
| Rater r3 | 127.729 | 12.785 | 19.573 | 5.42e-14 |

These are local matched timing observations, not general capacity claims.
Source qualification still has a cost outside the endpoint search. The actual
61-node Rater upper endpoint remains unresolved after the change. Focused tests
cover binary/polytomous scores, absent crossings, owner order, Unicode names,
numerical derivatives, real optimizer callbacks, invalid-trial recovery,
existing one-family profiles and the shared two-family EM identities. The
existing literal endpoint checks, plots, saved results and replay also pass.
No new package dependency, export or whole-suite rerun was introduced.
Records are under `validation-results/gmfrm-profile-aggregation-20260929/`.

The [fixed independent protocol](gmfrm-profile-feasibility-20260929.md) uses
20 new datasets in each of four design/SD conditions, two prespecified targets,
neutral-start 121-node fits and unchanged profile controls. It addresses
availability, failure stages and cost before a larger coverage study. With
20 independent replicates, a 15% failure probability is observed at least once
with probability 96.1%; nominal .95 coverage still has MCSE about .049 even if
all intervals are available. This precision cannot qualify general coverage
or demonstrate a small method difference. Every planned case is retained,
with no time-based stopping, selective grid rescue or replacement by Wald.
The source/protocol hashes, matching source snapshot, session and complete
objects are retained with the results.

**Completed: all 80 planned fits and 160 planned component-profile calls.**
No dataset was omitted, no numerical setting was changed during the run and
no failed profile was replaced by a different method. Entries below are
**covered / available / attempted** for each prespecified component; the
denominator for conditional coverage is the middle number, not the last.

| Design | Ability SD | Component | Log-Wald | Profile |
| --- | ---: | --- | --- | --- |
| Common Persons | 1 | Task t3 | 18 / 20 / 20 | 17 / 18 / 20 |
| Common Persons | 1 | Rater r3 | 20 / 20 / 20 | 19 / 19 / 20 |
| Rotating pairs | 1 | Task t3 | 20 / 20 / 20 | 20 / 20 / 20 |
| Rotating pairs | 1 | Rater r3 | 19 / 20 / 20 | 20 / 20 / 20 |
| Common Persons | .5 | Task t3 | 11 / 12 / 20 | 1 / 1 / 20 |
| Common Persons | .5 | Rater r3 | 12 / 12 / 20 | 12 / 12 / 20 |
| Rotating pairs | .5 | Task t3 | 14 / 14 / 20 | 0 / 0 / 20 |
| Rotating pairs | .5 | Rater r3 | 14 / 14 / 20 | 14 / 14 / 20 |

For common-Person SD=1 Task t3, the conditional profile coverage 17/18 has
exact 95% MC limits .7271--.9986, while returned-and-covered is 17/20=.85.
Its Wald coverage 18/20 has limits .6830--.9877. For SD=.5 Task profiles,
1/1 coverage has limits .025--1, and 0 available intervals has **undefined**
conditional coverage. These results cannot demonstrate a coverage advantage.
All proportion intervals, paired availability counts and same-subset coverage
are in `summary.csv` and `paired.csv`. Do not pool the matched conditions as
80 independent replications of one condition.

**Failure attribution changes the next development decision.**

* All 40 SD=1 source fits converged. Three component profiles in two
  common-Person datasets failed upper-side integration checks; the retained
  and neutral starts agreed. All 20 rotating-pair datasets returned both
  component profiles.
* At SD=.5, eight common-Person and six rotating-pair fits reached the 500-EM
  iteration limit before meeting the fixed 1e-7 per-Person score tolerance.
  Their terminal scores range from 1.00749e-7 to 4.65632e-7, all below 1e-6.
  This is evidence about the stricter declared stopping procedure, not proof
  of mathematical nonidentification or the default procedure's failure rate.
  The original outcomes remain failures; they were not reclassified using a
  looser criterion or silently given more iterations.
* Among the 26 converged low-SD fits, all 26 Rater r3 profiles returned both
  bounds, but only one Task t3 profile did. All 25 unresolved Task profiles
  had substantial disagreement between retained and neutral starts: NLL
  differences 17.9783--83.5215. Eighteen also had a failed neutral optimization;
  seven had individually passing optimizer/gradient checks yet disagreed.
  None of these low-SD failures was an integration discrepancy, and no
  constrained search improved on the source likelihood beyond tolerance.
  A small raw gradient alone therefore does not settle the constrained fit.

For example, in common-Person SD=.5 replicate 4, the neutral start has
first-family free log slopes about 19.18 and -19.45 and second-family log
slopes about -24; its NLL is 83.52 worse than the retained-start solution.
Both report optimizer code zero and nuisance gradients below 1e-4. This
parameter escape must not be described as two verified local maxima or
solved by accepting the worse solution. It motivates reviewing scaling,
step control, constrained optimization and convergence geometry.

A separate **post hoc numerical diagnosis**, which does not replace any
study outcome, revisited the failed upper bracket in common-Person SD=1
replicate 5. Rater log-slope offsets .25 and .375 both pass the same checks
and have LR 1.8113 and 4.2841, bracketing the .95 cutoff; the original .5
offset fails integration. Thus an unresolved outward trial need not establish
that the requested endpoint is inaccessible. For Task t3, the same shorter
trial offsets still fail integration. Search-step refinement and integration
refinement are distinct remedies, and neither is yet an implemented automatic
rescue. The original failures remain in all denominators.

Summed per-call elapsed times are 213.731 seconds for the 80 source fits,
588.522 seconds for 80 all-component Wald calls and 2576.607 seconds for
160 profile calls. These are worker-call totals, not wall time; sources that
fail qualification incur little interval-search cost. The `cost.csv` table
separates target/method/condition and retains maximum as well as median time.
`failed-profile-points.csv`, `failed-starts.csv` and `source-convergence.csv`
retain the attribution above. The matching computing source was archived;
subsequent public help and failure wording changes do not alter these outcomes.

**Milestone decision:** the feasibility study is complete, G3 is not. Keep
profiles as explicit experimental sensitivity analyses. Before a larger
coverage comparison, address (1) EM finishing accuracy relative to the requested
score tolerance, (2) neutral-start escape and disagreement in constrained
profiles, and (3) failed outward brackets versus integration accuracy near the
actual endpoint. Reuse these saved cases for numerical development, retain
the failed original procedure, and evaluate a revised fixed procedure on
independent samples before claiming sampling qualification. More replications
of the current failed procedure are not the next priority. Component point
bias, broader model/assignment scope and the other release milestones remain
separate unfinished questions.

Public `confint()` help and the scope vignette now distinguish original EM
controls, constrained BFGS controls and quadrature refinement, and explain
the limited feasibility evidence. The user-facing origin-failure description
now says that profile checks at the fitted slope failed, avoiding confusion
with rejection of the original fit. NEWS and the active roadmap agree with
this scope. The two-family and one-family profile regression files pass after
these documentation/wording changes; helper usage, Rd, extracted vignette
syntax and whitespace checks also pass. The shared EM regression file passed
for the evaluator change. This increment did not run the full package suite,
CI, or publication checks; no statistical outcomes were rerun after wording
changes.

## 2026-09-30 numerical repairs on retained feasibility data

**Question:** do the three observed computational failures persist after
correcting search scale, M-step finishing accuracy and outward bracketing,
without changing the model, integration rule or acceptance requirements?
This is numerical development using known cases, not an independent coverage
study. The original 80-dataset results above remain unchanged.

The two-family constrained BFGS search now sets `fnscale` to the number of
Persons. Thus the internal search uses the mean objective, matching the EM
kernel's scale, while the reported NLL, nuisance gradients, quadrature checks
and likelihood-ratio cutoff retain total-likelihood units. This introduces no
new slope bound. Repeating all 25 previously disagreeing constrained points
from their original retained and neutral starts gives passing solutions in
25/25: maximum NLL disagreement is 9.36325e-10, compared with 17.9783--83.5215
before. This establishes recovery of these points, not global optimality or
complete interval availability.

The EM M step reuses the fitter's existing curvature proposal if BFGS reports
convergence but the auxiliary-objective score exceeds the requested tolerance.
The E-step counts stay fixed. The proposal must have usable positive curvature,
improve its score and not worsen the auxiliary objective; the existing
subsequent auxiliary and marginal likelihood ascent checks still apply.
The dense refinement helper is limited to 1--64 free parameters; unavailable
or unsuccessful refinement leaves the ordinary proposal and a recorded reason.
`mstep_score` records the proposal before any step halving, while `max_score`
records the accepted marginal score. This remains generalized EM and does not
replace the marginal-score stopping rule with change in likelihood.

All 14 earlier nonconverged sources, restarted from neutral parameters at the
same 121-node grid, 500-iteration ceiling and 1e-7 marginal-score tolerance,
now converge in 26--45 iterations. Recorded Q and marginal likelihood gains
are nonnegative; final NLL improvements are 2.27e-10--9.02e-8. This small
likelihood change explains why the former Q-based numerical stopping inside
the M step could miss the requested outer score accuracy. Point and source
records are under `validation-results/gmfrm-numerical-repair-20260929/`.

The profile search contracts between the last passing point and an inaccurate
outward trial within the original eight-trial budget. It keeps failed trials,
does not cross known failed interior evaluations and does not refine the grid
automatically. Analytic likelihood tests distinguish an endpoint inside the
accurate region from a genuinely inaccessible endpoint and from an inaccurate
interior point. A better constrained likelihood still invalidates the source.

The fixed matched replay in `gmfrm-numerical-repair-20260930.R` uses public
`fit_mfrm()` and `confint()` calls on all 40 low-SD datasets (Task t3), the
SD=1 common-Person failures (replicate 5, Task and Rater; replicate 9, Task),
and one previously successful SD=1 rotating-pair control (replicate 1, both
targets): **43 sources, 43 all-component Wald calls and 45 full profiles**.
No new data are generated. Original controls and data are retained, every
result/error is saved, and completed endpoints from both starts are checked
against the literal response formula at 241 nodes. Source/input hashes,
computing source snapshots and session information accompany the output in
`validation-results/gmfrm-numerical-repair-20260930/`. There is no elapsed-time
cutoff or replacement of missing intervals by another method.

**Completed matched replay:** all 43 sources converge, with accepted marginal
scores at most 9.95e-8 in 25--58 EM iterations. All 43 all-component log-Wald
calls return eligible intervals. Recorded marginal and Q gains remain
nonnegative. Complete profile intervals are available in **43/45** targeted
calls, with the following fixed denominators:

| Selected design/SD cases | Component | Original available | Revised available |
| --- | --- | ---: | ---: |
| All 20 common-Person, SD=.5 | Task t3 | 1/20 | 19/20 |
| All 20 rotating-pair, SD=.5 | Task t3 | 0/20 | 20/20 |
| Common-Person SD=1, replicates 5 and 9 | Task t3 | 0/2 | 1/2 |
| Common-Person SD=1, replicate 5 | Rater r3 | 0/1 | 1/1 |
| Rotating-pair SD=1, replicate 1 | Task t3 and Rater r3 | 2/2 | 2/2 |

The SD=1 rows are selected failure/control checks, not representative failure
rates. No sampling-coverage estimate is claimed for this development replay.
For all **88 computed endpoints**, both retained and neutral solutions were
independently evaluated at 241 nodes (176 endpoint/start checks). Maximum
NLL discrepancy is 1.38e-6, maximum LR cutoff residual 9.86e-6 and maximum
constraint error 1.11e-16, within the unchanged 1e-5, 1e-4 and 1e-6 criteria.
Two incomplete intervals keep their single computed endpoint and do not count
as complete. `rows.csv`, `source.csv` and `identities.csv` retain all cases.

Two failures remain under the frozen controls:

* **Common-Person SD=.5 replicate 11, Task lower endpoint:** the source now
  converges, but constrained BFGS reaches its 400-iteration stage limit. At
  an outward trial, a nuisance Rater r2 slope becomes about .04--.05 while
  its location/step coordinates grow. This is not proof of a boundary optimum
  or nonidentification. A separately recorded post hoc check at log-slope
  offset -.25 with `maxit=1600` gives two passing solutions (NLL disagreement
  5.48e-8), showing budget dependence at that point. It neither replaces the
  original missing endpoint nor establishes a complete recovered interval.
  The script and original/revised attempts are in `posthoc-budget-point.*`.
* **Common-Person SD=1 replicate 5, Task upper endpoint:** contraction reaches
  an integration discrepancy before the cutoff. At the closest failed trial,
  the 121-versus-241 gradient change is about 1.0383e-4, beyond the 1e-4
  requirement; both starts agree and report optimizer convergence. The
  algorithm correctly retains the missing endpoint. More BFGS iterations
  cannot substitute for checking integration accuracy.

Three complete intervals retain failed outward points: rotating-pair SD=.5
replicate 16 Task t3, and the two recovered SD=1 components. On the first,
the public plot retains both failed points as crosses, does not join them to
passing sections, and retains the computed bounds. ggplot conversion, tables,
report, export and replay preserve all results without recomputing inference.
The rendered default plot was inspected; it uses English text and distinguishes
failures by shape as well as the likelihood/Wald line styles. A saved regression
fixture covers this case. The output review is retained in `output-review.*`.

Focused tests pass for shared profile search, two-family profile intervals,
EM identities, public fitting, quadrature sensitivity, response diagnostics
and slope intervals. New tests also require the trial budget to include
contractions and a better outward likelihood to invalidate both bounds.
Help, NEWS, the scope vignette and ROADMAP distinguish these repairs from
statistical qualification. No whole-suite rerun, CI or release action is
part of this increment. **G3 remains open:** resolve the remaining weak-slope
and approximation handling before freezing an independent bias/SE/coverage
comparison; computational recovery on these reused cases cannot close it.

## 2026-09-30 control sensitivity, weak-slope search and user documentation

The two remaining cases above were followed separately using existing public
controls, as fixed in `gmfrm-profile-controls-20260930.R`. The original 43/45
record remains unchanged. Increasing the constrained stage limit from 400 to
1600 did **not** return the common-Person SD=.5 replicate 11 lower endpoint
(full profile call: 165.808 seconds). Passing one post hoc point in the earlier
check did not imply a complete recoverable interval at that budget.

For common-Person SD=1 replicate 5, `mml_quadrature_sensitivity()` preserved
the data/model/EM settings and refitted at 181 nodes. An explicit profile call
on `review$fits$q181`, with the default profile controls, returns Task t3
limits [1.051922, 1.652009]. All constrained solutions are checked at 361 nodes.
An independent literal 361-node likelihood confirms both starts at both
endpoints (maximum NLL difference 2.97e-8 and LR residual 5.63e-6). This
illustrates explicit numerical refinement, not that 181 nodes always suffice.
The `review$intervals` outputs are model/Wald intervals, not repeated profiles.
The current positive-double Gauss-Hermite rule supports the 181/361 comparison;
481-node weights are not all representable, so a 241/481 route was not used.
Complete results and the original warnings are retained under
`validation-results/gmfrm-profile-controls-20260930/`.

The weak-slope case exposed poor nuisance-coordinate scaling, not a demonstrated
boundary optimum. At a lower profile trial, both iterates have a small Rater r2
slope and large compensating location/step magnitudes. Their constrained Hessian
eigenvalues span approximately .003 to 122. A fixed invertible transformation
from the existing curvature-scaling calculation allows BFGS to move efficiently
in that geometry. The two-family profile search now attempts this additional
stage only after both original stages fail to converge. It retains the linear
component constraint, total marginal likelihood, original gradient/integration
checks, stage records and per-stage `maxit` limit. The transform scales the total
objective, so this stage does not divide it again by Person count. Invalid
trials retain the existing rejection behavior. Unavailable scaling (including
the existing 64-coordinate size limit) preserves the earlier failure. The
one-family search is unchanged.

Matched full public searches with default controls now give:

| Previously affected profile | Revised lower | Revised upper | Public call seconds |
| --- | ---: | ---: | ---: |
| Common-Person SD=.5 replicate 11, Task t3 | 0.8210783 | 1.6032306 | 61.254 |
| Rotating-pair SD=.5 replicate 16, Task t3 | 0.9434804 | 1.8242809 | 58.896 |

The first had a missing lower endpoint; the second had complete endpoints but
failed outward trials. These are the two profiles with unresolved optimization
in the preceding matched replay. Both now return both endpoints under the
original 400-iteration stage limit. All eight endpoint/start checks pass the
independent 241-node likelihood comparison (maximum NLL difference 2.28e-13,
LR residual 2.44e-6, constraint error 2.78e-17). The runner and complete outcomes
are under `validation-results/gmfrm-profile-scaled-20260930/`, with a repository
runner `gmfrm-profile-scaling-20260930.R`. No all-case sampling result is
reclassified, and these timings are not general capacity claims.

Regression tests cover this real weak-slope trial, both starting values, the
unchanged constraint and likelihood, retention of unsuccessful original stages,
unavailable curvature scaling and a deliberately inaccurate reference integral.
The latter must still prevent an interval. Existing one-family and two-family
profile/output tests remain in place.

The public-language audit found development-history and implementation wording
in NEWS and help (including “existing curvature helper”, “development replay”
and “promote readiness”). These were replaced by explanations of user-visible
behavior, control choices and statistical limits. Related calibration,
quadrature, plausible-value, random-rater and report/export help was checked
as well. The scope vignette now explains troubleshooting instead of narrating
these development runs. Detailed computing history stays in this validation
record and ROADMAP; experimental status, unsupported uses and uncertainty
limitations remain visible in user documentation. No documented field or
argument name was renamed by this wording change.
