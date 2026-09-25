# Current-source MML/GPCM inference confirmation protocol

Protocol ID: `mml-gpcm-confirmation-20260925-v1`.
Status: specified before generating confirmation outcomes; not executed.
This is a development validation protocol, excluded from the CRAN package by
`.Rbuildignore`. It does not change package defaults or claim release readiness.

## Questions and decisions

The user outcome is usable, correctly described uncertainty for a fitted rating
model, including comparisons and saved feedback. A numerically invertible
matrix is not evidence that an interval has its nominal coverage.

1. Do the new curvature-restart and information-refinement rules recover valid
   finite solutions without worsening ordinary solutions or admitting invalid
   ones? Compare paired fits, local objective/gradient checks, integration
   sensitivity, bias/RMSE, output availability and resources.
2. What sampling behavior do the retained relative/standardized slopes,
   prespecified contrasts, model/sandwich intervals, curves and matched PCM LRT
   exhibit? Evaluate distinct targets on the same datasets; do not count their
   correlated rows as independent replications.
3. Does the basic bootstrap retain honest uncertainty when fits fail, and what
   can a finite simulation budget establish about its interval/test behavior?
   Separate outer-dataset variability from inner-bootstrap Monte Carlo error.

These are confirmation questions for the frozen source below. Historical
counterexamples remain regression tests; they are not unseen confirmation
outcomes. A negative or inconclusive result stays visible and can require an
output restriction or repair. It cannot be relabeled as successful validation.

## Frozen source and comparator

The preparation record is
`validation-results/mml-gpcm-confirmation-20260925/`. It retains a byte-for-byte
copy of R/src, DESCRIPTION and NAMESPACE, SHA-256 manifests, deterministic plans
and this protocol. Compiled binaries are excluded: each arm must be compiled
from its recorded sources and run in a separate R process. Session/library,
compiler and BLAS details must be retained by the execution runner.

The current arm is the package source after the common-MML consumer repair.
The comparator is an **explicit three-rule ablation of that same source**:

- Disable the new post-code-zero negative-curvature rescaled restart block.
  Preserve the existing initial optimizer, gradient polishing and other
  fallbacks, starts, settings and iteration budgets.
- Disable weak-positive-information refinement. Use the existing initial
  inversion path and its regularized/unavailable-inference consequences.
- In basic slope bootstrapping, do not enable the singleton-only exception.
  Keep the same current source-identity, category, numerical and target checks.

Only those three guards differ; the preparation script asserts each edit occurs
once and writes a unified diff. This comparator isolates the recent decision
changes with common APIs. **It is not an exact historical package build** and
must never be labelled as the September 24 release or TAM/ConQuest. The stored
older fits remain useful historical comparisons, separately labelled. Comparison
of two software packages or adding a new estimator is not required here.

Dataset generation, target calculation and external numerical checks use one
fixed reference, independent of arm. Native starts are shared, not warm-started
from the winning arm. No refit selected after seeing truth replaces a primary
result. Additional Q101 evaluations/refits are recorded as diagnostics only.

## Estimator and output contract

Primary fits: ordinary one-dimensional MML; direct BFGS; unit weights; fixed
Q61 normal quadrature; `maxit = 400`, `reltol = 1e-10`; score ladder 1:3 with
`category_policy = "preserve"`; estimated intercept-only normal ability mean
and variance (`population_formula = ~1`). Fit PCM and GPCM under the same
population specification when comparing them. No response imputation is used.
Existing fixed-standard-normal RSM/PCM/MI numerical and reporting evidence is
reused where applicable; this study does not validate a new imputation model.

Relative slopes have geometric mean one. Standardized slopes are `a_j * sigma`;
with population covariates this would use residual SD, but those extra generating
conditions are outside this confirmation design. They retain their prior
formula-replay and derivative checks, not a new broad coverage claim.

In the current source, the additional curvature review applies only to fixed-grid
GPCM MML, 1–64 free coordinates, code zero and requested `reltol <= 1e-9`.
At most three scaled BFGS restarts are attempted, each under the requested
iteration budget. A candidate must not worsen the objective beyond the existing
floating-point slack, must pass the gradient/convergence review, and must no
longer have detected negative curvature. Failed recovery retains a review
status. Search-coordinate scaling is not covariance regularization.

For positive information that would otherwise be regularized, the two Hessian
refinements use derivative steps 1e-4 and 1e-5 after the initial 1e-3 calculation.
The two Richardson results must permit unregularized Cholesky inversion; the
curvature-metric relative change must be <=1e-3, inverse residual <=1e-6 and
curvature-scaled gradient <=1e-4. A successful result retains its weak-information
caution. Failed refinement does not receive an accepted covariance. The default
256 MiB information-workspace budget applies to both the initial and extra
allocations; it is not a process-memory ceiling.

Numerical checks are necessary, not sufficient for every output:

| Output | Retained qualification / failure meaning |
| --- | --- |
| Local IC comparison | Common data/likelihood/parameter counting and current solution/integration checks. A successful comparison is not evidence of nominal interval coverage or a global maximum. |
| PCM–GPCM ordinary LRT | Matched nesting, scale/population and eligible solutions under the existing API; use the actual returned status and reason. Do not replace a failed LRT by zero or by the bootstrap p-value. |
| Model/Wald or sandwich intervals | Full constrained covariance and target Jacobian; sandwich also requires independent clusters and score rank. Persons are clusters here; `adjust = FALSE`. A model-based fallback must not replace an unavailable sandwich interval. |
| Basic bootstrap source/draws | All categories must be observed in each step scope; singleton-only weakness may warn under the current arm's fresh audit. Empty categories, failed numerical/information checks and incompatible targets remain unresolved. This exception does not authorize ordinary Wald/LRT output. |
| Basic bootstrap intervals | Type-1 reversed empirical error quantiles; log scale for positive slopes/ratios, identity scale for differences. Unresolved errors remain at both extremes; zero/infinite/unbounded limits are retained. |
| Bootstrap LRT | PCM-null generation; plus-one numerator and denominator. Unresolved trials retain p-value bounds, not a scalar p-value obtained by dropping them. |
| Display / saved results | Preserve method, target, caution, unavailable reason and source. A boundary diagnostic point must not appear as a qualified estimate or finite interval in another route. |

No manual boundary threshold, category collapse, selective successful-fit
replacement, eigenvalue floor for accepted information, or optimizer retuning
is introduced by this protocol. Follow-up probes cannot silently alter the
primary estimator. A change to these rules creates a new protocol/source ID.

## Generating model and independent truth

There are three fixed raters and three fixed criteria, with effects
`(-0.5, 0, 0.5)` and `(-0.4, 0, 0.4)` respectively. For the selected step/slope
owner, the three step pairs are `(-0.7, 0.7)`, `(-1.1, 1.1)` and `(-1.5, 1.5)`.
The selected owner is either Rater or Criterion; its two operations refer to the
same levels. Generate scores k=0,1,2 and return k+1. Independently calculate
adjacent logits as `a_owner * (theta - rater - criterion - step_owner,k)`;
normalize cumulative logits with log-sum-exp. Do not generate using the fitted
probability or derivative helper being checked.

Ability is N(0,1), independently drawn for each Person and shared across that
Person's ratings. All non-Person effects, steps and slopes above are fixed
across replications, not random facet samples. Unit slopes are `(1,1,1)`;
spread slopes are `exp(-0.4,0,0.4)`. The generated mean and SD are 0 and 1,
although estimation reestimates both.

Cross N=40/100, ratings by all three raters / a linked rotating pair, owner
Rater/Criterion, and unit/spread slopes: **16 cells, 500 datasets per cell**.
For rotating pairs, Person p receives raters `1+(p-1) mod 3` and `1+p mod 3`,
each rating all three criteria. Assignment is independent of ability and scores.
There is no additional nonresponse: unassigned ratings are structurally absent,
not random missing scores to be imputed. This full crossing separates sample
size from sparsity, unlike the original two-cell comparison.

The main plan has 8,000 independently seeded datasets. Both arms receive exactly
the same saved data for each ID. RNG is explicitly Mersenne-Twister/Inversion/
Rejection. Primary seeds are `1600000000 + ID`; bootstrap seeds are
`1700000000 + ID`. Reserved engineering preflight seeds start at 1599990001;
their outputs never enter confirmation summaries. Execution must audit the
planned seed IDs against archived plans before generation and save the RNG kind.

## Targets and reuse of each fit

For each arm/dataset, save all estimates before interval eligibility filtering.
Evaluate the three relative slopes and three standardized slopes, with model
and Person-sandwich intervals. Prespecify the first-minus-second and
second-minus-third contrasts, both as log ratios and standardized-slope
differences. Use nominal 95% pointwise intervals and separate Bonferroni families
of three slopes or two contrasts. Report family coverage per dataset, not the
mean of marginal coverage indicators.

Evaluate category probabilities and per-rating information at theta=-1,0,1
for all nine Rater×Criterion contexts. These are native-scale fixed abilities;
truth comes from the independent generating model. A separate probability call
has 81 rows and a separate information call has 27 rows. Their Bonferroni
families are those finite rows, not a continuous band or Person-score interval.
Both covariance methods use the same fitted point. Do not add a fitted curve
model or refit for each target.

For unit-slope datasets, fit a matched PCM once per arm for the ordinary LRT,
record its nominal 5% rejection and IC quantities. Record IC ranking agreement
and parameter counts; do not treat selection of the generating model as a
mandatory success on every dataset or treat AIC/BIC as confidence levels.
Existing numerical slope/curve Jacobian, score aggregation, report/export and
RSM/PCM pooling checks are reused; they are not repeated as new coverage studies.

## Bootstrap phase and cost boundary

Nested bootstrap work starts only after generator/reference and source-pairing
checks and the main phase's source/output integrity checks pass. Adverse main
coverage does not automatically cancel bootstrap work: it answers a separate
question. A broken estimator or invalid target does stop dependent simulation.

Use the first 100 prespecified IDs in each Rater-owner cell with either
N40/rotating or N100/crossed, for both unit and spread slopes (400 outer datasets).
Spread cases use the slope bootstrap; unit cases use the matched PCM-null LRT.
Use **499 planned inner datasets** per outer case. Both arms use the same
bootstrap seed, but generate under their own fitted model; identical seed does
not imply identical simulated scores when fitted parameters differ. Save those
inner data/seed identities when comparing inner outcomes. Paired contrasts are
at the independent outer-dataset level.

These are up to 99,800 slope refits and 199,600 null/alternative refits per arm,
before refusals and source checks. This is materially more expensive than the
main phase. Before launch, use engineering timing (all selected preflight cases,
including failures) to forecast the complete cost. Do not quietly reduce B,
select easy outer cases, or replace the repeated-dataset question with the old
499-refit singleton pilot. If the forecast exceeds the resource envelope below,
record the bootstrap phase as **not launched / unresolved** and propose a
separately identified efficiency or budget revision before examining its new
outcomes. Its agreed API remains included; this is not a silent deferral.

At 500 independent datasets, MCSE near 95% coverage or 5% rejection is about
0.00975 (0.98 percentage points), before losses to availability. For 100 outer
bootstrap datasets it is about 0.0218; this smaller phase may remain inconclusive.
Inner B=499 gives p-value resolution .002 and about 12.5 expected draws per
unadjusted 2.5% tail, not 499 independent observations of coverage. Adjusted
families have fewer tail draws and must retain that warning.

## Numerical, statistical and performance decisions

Engineering integrity is a hard gate: independent reference probabilities within
1e-10, same-grid NLL within `1e-8 * max(1, abs(NLL))`, scaled derivative error
<=1e-5, exact row/scale/source identities, no lost trial, and no invalid result
presented as eligible. These tolerances are numerical tolerances, not statistical
coverage criteria. Existing independent reference code is reused where it
matches the stated 3×3 model; its scope must be checked before calling it an
oracle for additional targets.

Prespecify the first 10 replications in each main cell for Q101 refits/evaluations
and independent continuous-integral spot checks on replication 1. Also inspect
all newly admitted weak-information cases without replacing their primary
results. Report objective, estimate, interval and eligibility differences. A
Q61/Q101 agreement does not establish exact integration. A failed check stays in
coverage and is flagged as a numerical conflict; it is not removed to improve
coverage. Resolve conflicts before claiming supported inference for that case.

For every target/cell/method report assigned, attempted, fit-returned,
solution-eligible, interval-returned, finite-interval and covered counts.
Coverage among returned intervals, covered-and-returned per assigned dataset,
and coverage among finite intervals are distinct. An interval spanning the
whole support can cover but is not finite or informative. Failed estimates are
not zero, and unattempted work is not an estimator failure.

Report bias/RMSE on all finite returned estimates and on each clearly identified
eligible subset. Include paired common-available differences, but never present
that subset alone. Report median/90th/99th-percentile width, mean width with
infinity retained, and weak-refinement, restart, singleton, empty-category,
boundary, rank, numerical and resource failure frequencies.

Use exact binomial 95% Monte Carlo intervals for proportions. Preserve
dataset-level dependence for paired differences and family events; do not
use the number of categories, targets or bootstrap draws as replication count.
For paired means use the empirical SE of within-dataset differences; for
unpaired reported means use the appropriate dataset-level MCSE.

The following are **prospective review criteria**, not universal guarantees or
new public admission rules:

- Calibration concern: nominal-95% coverage upper MC bound below .925, or a
  nominal-5% null-rejection lower MC bound above .075. Support against that
  material discrepancy requires the opposite bound to clear the same margin;
  overlapping bounds mean inconclusive, not pass. Coverage above .975 prompts
  width/conservatism review; it does not indicate dangerous undercoverage.
- Availability concern: upper MC bound below .90; support against this concern
  requires lower bound >=.90. Zero/unbounded limits never count as finite
  availability. Availability is not coverage.
- Regression review: absolute paired availability change >.02, paired covered-
  and-returned change >.02, or >10% RMSE/width change, interpreted with paired
  Monte Carlo uncertainty and all failure counts. A numerical recovery need
  not improve every statistical metric; tradeoffs must be reported explicitly.
- Resource review: median time >2× or 90th-percentile time >3× the ablation arm,
  or measured peak RSS >2×, prompts investigation of what benefit pays for it.
  Missing RSS is reported as missing, never zero. Time/memory comparison uses
  matched data and controlled concurrency, excludes compile time and includes
  any automatic restart/refinement cost.

No criterion is relaxed after seeing results. A concerning result requires a
bounded repair/re-evaluation or justified output qualification. An inconclusive
result is not made positive by adding simulations until it passes. Any new
replication plan is versioned with its rationale before its new outcomes.
These per-target review bounds are not simultaneous confidence statements about
all cells, and do not turn a limited design into a general precision guarantee.

## Execution, resource stops and milestones

Use at most two fit workers and one native math thread per worker. Keep complete
per-ID results/checkpoints and resume only if source, protocol, data and settings
hashes match. No mixed-arm namespace in one R process. Verify the compiled
native symbol paths before the first fit. An old checkpoint is historical
material, not a valid cache hit for a changed source.

Initial envelopes: main phase 24 wall-clock hours; nested phase 48 wall-clock
hours, measured separately and including failures. These are administrative
stop limits, not expected runtimes or statistical stopping rules. Engineering
preflight is at most 30 minutes, with no confirmation outcomes used to choose
methods or seeds. Record OS-reported peak RSS; do not claim a RAM guarantee
from the covariance workspace estimate. At a limit, save completed work and
mark incomplete; do not count the phase as validated or launch an automatic
continuation with a new budget. No unrelated stress grid is appended.

Before execution, finish and check the data/reference/summary runner against
small deterministic and injected-failure cases, and record its own hash. The
source and planned estimands/rules are frozen now; runner readiness and resource
feasibility remain explicit preflight gates. Checking this document or building
a plan is not evidence that the statistical study was run.

M2's source/decision protocol is specified here. M2 still needs the engineering
preflight and any unresolved boundary-output contract checks. M3 needs actual
source-matched evaluation and disposition of adverse/inconclusive results. M4
needs the current-source assessment-to-feedback walkthrough. M5/M6 need a new
checked archive and its matching platform/publication evidence. None closes
merely because this plan exists, and no feature is silently removed from 0.2.4.

## Methodological basis

The separation of aims, generating mechanisms, estimands, methods and performance
measures, with explicit Monte Carlo uncertainty, follows
[Morris, White and Crowther (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6492164/).
The concrete margins, source comparison and resource limits above are project
choices; that paper does not prescribe or validate them.
