# Joint task/rater slopes: numerical MML--EM verification

Date: 2026-09-27. Internal implementation; not a public API availability claim.

**Latest execution status (October 1):** all new computation is held for the
[full sample-size and facet-structure review](#october-1-small-cohort-and-facet-structure-review).
The user relaxed the October 2 18:00 deadline but explicitly requested design
review before further calculation. This supersedes earlier launch/deadline
instructions in this chronological record; frozen evidence remains unchanged.
The [shared MML/JML roadmap](internal-roadmap-0.2.4.md#mml-and-jml-validation-plan)
owns the current cross-estimator scope and execution sequence. The detailed
MML proposals below feed that plan; they are not a separate MML-first queue.
The shared [facet comparisons](internal-roadmap-0.2.4.md#c-facet-structure-with-explicit-workload-controls)
and [robustness controls](internal-roadmap-0.2.4.md#e-robustness-mechanisms-and-matched-controls)
now specify workload, population-shape, missingness and dependence contrasts
for the common model families. They do not qualify the two-family MML route
or replace its interval qualification. The subsequent
[D specification](internal-roadmap-0.2.4.md#d-mml-scale-slope-families-and-output-decisions)
fixes the matched normal-scale mapping, slope-family/null comparisons and
small-N integer allocations. The current interval rank gate remains a reference
procedure; changing it still requires justification and validation. The missing
estimated-population/one-family location-contrast consumer is now an explicit
implementation priority, not an available output. The shared
[inference and evidence allocation](internal-roadmap-0.2.4.md#inference-decisions-and-evidence-allocation)
supersedes older provisional comparison directions below; no computation resumed.
The [F scoring/reuse specification](internal-roadmap-0.2.4.md#f-person-scoring-future-cohorts-and-saved-reuse)
now fixes held-out panels, prior/scale comparisons, scoring-node retries and
calibration-replicate Monte Carlo accounting. Two-family scoring remains
conditional on fixed point calibration and N(0,1); a structural interval
refusal alone does not determine its separate source-scoring result.
The [calibration/refinement specification](internal-roadmap-0.2.4.md#calibration-procedures-and-bounded-numerical-refinement)
now separates initial, source-reviewed point/scoring and interval-stage results.
It is a prospective workflow, not a relabelling of the 400-case interval-driven
replay below. The [source/RNG rules](internal-roadmap-0.2.4.md#source-identity-and-random-number-allocation)
and [precision allocation](internal-roadmap-0.2.4.md#condition-accounting-and-precision-decisions)
are specified; actual registries, source bridges and preflight remain pending.
The [static source audit](internal-roadmap-0.2.4.md#static-source-audit-and-reusable-units)
finds unchanged reviewed fitting code/binary and component-slope calculations
relative to the matched replay; it does not call for a blanket 400-case refit.
New location/scoring consumers and the prospective stopping policy still need
their own evidence. The 800 prepared core inputs and eight saved jobs remain
separate from new small-N or rubric conditions. The
[family allocation ledger](internal-roadmap-0.2.4.md#family-allocation-ledger-and-work-order)
now records the common A/B and expanded C/D/E working R=100 allocations.
The [expanded workload account](internal-roadmap-0.2.4.md#expanded-allocation-shared-controls-and-scheduling-priorities)
deduplicates D's A/B inputs and identical MML fits, retains saved historical
inputs/stages as source-specific reuse candidates, and includes the additional
A/B fixed-population fits. Priorities preserve complete small/large-N contrasts;
the full count is a planning burden, not an approved compute budget or precise
confirmation. Neither the old core runner nor a fresh confirmation is launched.
The [native location-interval specification](internal-roadmap-0.2.4.md#native-mml-location-interval-extension-specification)
now identifies the existing full-covariance/contrast machinery, missing public
admission and result dispatch, and the proposed local/finer-grid checks for
estimated-population RSM/PCM and one-family GPCM. Its first added scope is
experimental native model intervals. The ordinary analytic Person-score helper
does not include the new population/slope coordinates; sandwich support needs
the complete-score path and a sampling-law decision. Standardized contrast
intervals additionally need fitted-SD uncertainty and cross-covariances.
Retained independent information/constraint fixtures are assigned to numerical
verification, separately from sampling qualification. No code, public help,
NEWS claim or two-family interval rule changed during this specification work.

## Model and sources

For score k=0,...,K, the adjacent predictor is
`a_i * c_r * (theta_p - b_i - s_r - tau_rk)`. This is Uto and Ueno
(2020), equation 9, with D=1 and rater-owned steps. With a fixed standard-normal
population, sum(b_i)=0, sum(log(a_i))=0, and sum_k(tau_rk)=0 identify the
parameterization; c_r remain free positive parameters. Crossing/support and
sample boundaries still need separate assessment.

Sources reviewed: the supplied two derivations, the Uto--Ueno article's
response equation, the official Muraki publication record, the official
sirt help, and the installed sirt 4.2.133 functions `rm.facets`,
`rm_facets_est_a_item`, `rm_facets_est_a_rater`, and `rm_facets_calcprobs`.
This record does not assert a new page-by-page reading of Muraki's PDF.

- Muraki (1992), *A generalized partial credit model: Application of an EM
  algorithm*, Applied Psychological Measurement, 16, 159--176.
  <https://doi.org/10.1177/014662169201600206>
- Uto and Ueno (2020), *A generalized many-facet Rasch model and its Bayesian
  estimation using Hamiltonian Monte Carlo*.
  <https://doi.org/10.1007/s41237-020-00115-7>
- sirt `rm.facets` official documentation:
  <https://alexanderrobitzsch.github.io/sirt/reference/rm.facets.html>

sirt's model has category logit `a_i*a_r*k*theta - k*b_r - tau_ik`:
slopes scale ability, not every location/step term. Its default two GM1 slope
constraints accompany estimated population SD. The local implementation
updates slopes numerically and clips increments/ranges. These are useful
algorithm references, not an interchangeable response model, proof of global
optimization or joint observed-data uncertainty. No sirt source was copied.

## Implementation and checks

`R/core-gmfrm-em.R` adds two non-exported functions. They accept observed
Person/Task/Rater/Score rows, arbitrary numbers of task/rater levels >=2,
and a common contiguous score scale 0:K. Missing/unassigned rows are omitted
by the caller; supplied missing scores and repeated triples are rejected.
No anchors, weights, estimated population or dependent-response model is
implemented. Task-rater rank failure is rejected, but a full rank check is
not a complete global/boundary qualification. There is no finite slope box;
floating-point slope underflow/overflow is rejected, not interpreted as a fit.

The E-step uses all observed ratings of the same Person. Expected counts are
aggregated by task/rater cell, category and fixed quadrature node. The M-step
uses analytical gradients in unconstrained contrast/log-slope coordinates.
Numerical generalized-EM steps must increase Q and the same quadrature-based
marginal likelihood (roundoff allowance 1e-12 per Person). Stopping requires
a maximum marginal score <=1e-6 per Person. Every iteration records likelihood,
Q improvement, score, numerical M-step status and step halving. Standard
`optim()` and the existing package Gaussian quadrature are reused.

Focused tests independently check the literal adjacent-category equation,
finite-difference marginal and complete-data scores, Person-level integration,
row reordering, binary and five-category responses, all three unit-factor
reductions against existing PCM/GPCM likelihood kernels, invalid crossings,
floating-point slope limits, and iteration-limit semantics. Frozen-Q and
observed-data Hessians differ numerically; frozen-Q curvature is not an SE.

## Executed algorithm comparison

Seed 20260927: 240 standard-normal Persons, 3 tasks, 3 raters, scores 0:2,
fully crossed 2,160 observations. Both slope blocks are non-unit in generation.
For each quadrature, direct BFGS uses two independent starts, neither taken
from the EM solution. Both methods share the verified probability and score
kernel, so this is an optimization comparison, not independent software
estimator replication. Likelihoods were monotone throughout EM.

| Nodes | EM iterations | Max mean marginal score | Largest EM/direct parameter difference | Largest log-likelihood difference | Smallest observed-information eigenvalue |
| --- | --- | --- | --- | --- | --- |
| 31 | 43 | 9.87e-7 | 3.78e-6 | 1.13e-9 | 51.661 |
| 61 | 43 | 9.88e-7 | 3.79e-6 | 1.14e-9 | 51.671 |

31-to-61-node parameter change: 8.84e-5. This is reported separately from
optimizer agreement; sharing the quadrature does not verify integration.
The actual sirt probability kernel agrees to 2.00e-15 in the explicitly
matched zero-location/zero-step submodel with both slope families non-unit.
No free-estimator equivalence with sirt, TAM or ConQuest is claimed.

Reproduce from the package root:

```r
pkgload::load_all(compile = FALSE)
testthat::test_file("tests/testthat/test-gmfrm-em.R")
source("inst/validation/gmfrm-mml-em-20260927.R")
run_gmfrm_em_validation(tempfile("gmfrm-em-"))
```

The runner saves data, optimization traces, estimates, observed information
and summaries; when sirt is available, its version and overlap check are also
saved. The initial local result directory was `/tmp/mfrmr-gmfrm-em-20260927`.
This single generated example is not a sampling recovery, sparse-design,
coverage, performance-capacity or global maximum study. Public fit/output
integration, boundary qualification and inference remain roadmap milestones
G2--G4. The existing single-owner GPCM and corrected-JML development are unchanged.

## Literature refinement requested after the initial implementation

Primary sources:

- Wang, W.-C., & Liu, C.-Y. (2007). *Formulation and Application of the
  Generalized Multilevel Facets Model*. Educational and Psychological
  Measurement, 67(4), 583--605. <https://doi.org/10.1177/0013164406296974>
- Wang, Y.-G., Wu, J., & Qiu, X. (2025). *A Differential Index Measuring
  Rater's Capability in Educational Assessment*. arXiv:2502.09099v1.
  <https://arxiv.org/abs/2502.09099v1>. Treat the reviewed version as a preprint.

The 2007 local PDF was located at Zotero storage AD3BDJY2 (a duplicate of the
previously catalogued work). Text review covered model/estimation pp. 583--590,
applications/discussion pp. 594--599 and appendix pp. 599--602. Printed pages
585, 599, 600 and 602 were also visually inspected individually, including
the response equation and executable SAS settings. The 2025 PDF and HTML were
used for definition/model/estimation/simulation/limitations and appendices;
PDF pp. 5, 9, 10 and 18 were individually inspected visually. This is targeted
implementation review, not a claim of visual inspection of every page.

### Model and estimation implications

Wang--Liu equations 3, 5 and 6 use item slopes multiplying the whole adjacent
predictor, item-owned steps and conditional-normal latent regression. The
empirical objects are household appliances, illustrating why facet roles
must be explicit and domain-independent. Their appendix fixes the first slope
to one while estimating residual SD; it uses `METHOD=GAUSS`, `NOAD`,
`QPoints=25`, `TECHNIQUE=NEWRAP`. The general prose discusses adaptive
quadrature, but the printed example is explicitly nonadaptive. Neither a
25-point setting nor the appendix's probability cutoff is a universal accuracy
rule to copy. Current `population_formula`/`person_data` already support the
single-owner conditional-normal MML route. The new two-slope EM core does not.
Reuse that interface when extending the population rather than introducing a
second latent-regression API or treating estimated EAPs as error-free outcomes.

Their simulations use 50 binary and only 10 polytomous replications with
1,000 persons, not sparse-link qualification. The binary variance estimate is
reported as 1.851 versus truth 2.25; broad recovery language is not assurance
of negligible bias for all targets. Their Q3/PCA discussion is a useful
diagnostic direction, not a ready-made general acceptance threshold.

Wang--Wu--Qiu equation 12 instead has `rho_r*sigma*theta - delta_i - eta_r`
for binary ratings: no task slope block, no polytomous steps, and unscaled
location terms. This differs from both the 2007 and current Uto--Ueno kernels.
Its first simulation is fully crossed; its second includes incomplete and
unbalanced assignment. The authors themselves identify manipulated linkage
sets as remaining work. Their empirical four-category scores are dichotomized.
None of these results qualify a polytomous two-slope estimator or all sparse
designs. No author-code execution or SAS replication was performed here.

The Laplace log likelihood in equation 21 approximates the same marginal
integral and includes posterior-mode curvature. It is not ordinary JML and
does not justify replacing posterior integration by an EAP or mode alone.
For candidate structural parameters, the mode and curvature must be recomputed;
their dependence matters when differentiating the approximate objective.
The printed iteration uses mode SD and rescales rho to maximum one. A scale
re-expression that preserves effective slopes needs both
`rho_new = rho/max(rho)` and `sigma_new = sigma*max(rho)`; the printed Step 4
does not explicitly specify the latter. The paper's algorithm is not adopted
without a source-level/objective audit. No claim is made that unreviewed author
code necessarily omits that compensation. Bounding rho above by one does not
bound ratios when another rho approaches zero, or identify rho and sigma
without an additional scale convention.

### Feedback estimand and mathematical checks

The useful contribution is a curve describing response sensitivity at each
ability, optionally averaged over a stated target population. This is not
external criterion accuracy. For the package's category kernel and effective
slope A, direct differentiation gives

```
d P_k / d theta = A * (k - E[Y]) * P_k
d E[Y] / d theta = A * Var(Y)
I(theta) = sum_k (d P_k / d theta)^2 / P_k = A^2 * Var(Y)
```

Three added tests compare these identities with independent centered
probability differences in the actual two-slope kernel. Score sensitivity is
not information; the binary paper's proportionality factor also depends on
the response probability. Feedback should preserve the task/context and
reference population. If tasks are averaged, require an explicit common
weighting rule; if capability is normalized, define a common admissible
parameter set, denominator and score scale. Joint uncertainty must propagate
all parameters that enter the curve and normalization, including population
and both slope blocks, not only the rater's isolated variance.

Independent numerical checks identify points requiring correction before
reusing the preprint's formulas:

1. Appendix A writes `T'(z) = -z*T(z)` after dropping the x-weighted term.
   That term is generally nonzero away from z=0. At z=1, numerical integration
   of the full derivative and a central difference both give -0.05262143;
   the printed simplification gives -0.17794338. The claimed maximum at zero
   can still be established by symmetry/unimodality; this flags the displayed
   derivation, not a disproof of that maximum.
2. Appendix B's z derivative additionally needs the chain-rule factor:
   the full integrand multiplier is `-(x+z)/(rho*sigma)^2`. Its analogous
   dropped x-term is not zero either. Do not copy the displayed simplification.
3. The approximate GMF denominator is not exact normalization. For sigma=1,
   numerical integration gives Delta=0.20662096, versus 0.20412415 from the
   approximation. Dividing the exact numerator of the reference-best rater by
   the approximate denominator gives 1.012232; at sigma=3 it gives 1.077275.
   This mixed exact/approximate calculation diagnoses denominator error, not
   the output of the author's entirely approximate algorithm. At each ability,
   even the exact TFM kappa curve can reach 1.209945: its normalization concerns
   a population average, not a pointwise 0--1 bound. Do not clip such curves.
4. Printed equation 25 centers at the mean estimate, which defines dispersion
   rather than RMSE about truth. Tables contain values consistent with bias
   contributions, so the displayed formula alone does not establish a coding
   error. Recovery comparisons must recalculate RMSE from truth and raw runs.

Minimal reproduction of the first and third checks (executed locally):

```r
f <- function(x) plogis(x) * plogis(-x)
T <- function(z) integrate(function(x) f(x) * dnorm(x + z),
                          -Inf, Inf, rel.tol = 1e-12)$value
integrate(function(x) -(x + 1) * f(x) * dnorm(x + 1),
          -Inf, Inf, rel.tol = 1e-12)$value
(T(1 + 1e-5) - T(1 - 1e-5)) / 2e-5
-T(1)
T(0) / (.25 * sqrt(2 / 3))
.25 / T(0)
```

These findings refine roadmap G2/G3: reuse existing latent regression and
curve/report interfaces, verify a polytomous feedback definition before adding
a normalized index, and compare Laplace with the quadrature reference before
making it an available estimator option. No new public model/index or default
was introduced, and no sampling study or full package test was rerun.

## Shared probability kernel and conditional prediction integration

The next G2 increment removes the internal EM core's separate softmax
implementation. It now uses `mfrm_jml_probability_bundle()`, whose historical
name refers to a conditional response calculation, not an estimator choice.
That kernel retains full log probabilities on request as well as observed-category
log probabilities. Existing caches do not retain an extra full log-probability
matrix by default. `category_prob_gpcm()` also delegates to it, connecting existing
GPCM predictions and probability-based diagnostics to the same calculation.
R and compiled marginal evaluators remain separate verified integrations;
this change does not claim every likelihood backend is a single implementation.

The internal problem object gains a conditional-response evaluator for supplied
`Theta`, `Task` and `Rater` rows. It returns category probabilities/log
probabilities plus expected score, score variance, expected-score sensitivity
and information. Task slopes, rater slopes and their product are separately
labelled. `ObservedContext` identifies whether a task-rater crossing appeared
in training. New combinations of known levels are allowed under the additive
product-slope model and labelled unobserved; unknown levels are rejected.
This flag is not a precision or validity assessment. Ability is supplied,
not estimated by this evaluator. Score variance is response variation, not a
parameter SE; no interval or normalized capability index is produced.

Checks include equality between estimation/prediction at quadrature nodes,
an independent scalar calculation for a held-out task-rater crossing, row
order, owner labels, unknown/missing inputs and extreme conditional scores.
Finite log probabilities of -1000 survive probability underflow, and positive
binary information at theta=+/-40 agrees with an independent stable formula.
The focused GMFRM file passes 74 assertions. Existing separated-owner kernel
checks pass 4; after delegating public category probabilities, estimation-core
checks pass 295, category-variance checks 19 and separated-owner public
inference/curve/save workflow checks 43, with no failures or warnings.

Reusing the saved 240-Person data and estimates from the original algorithm
comparison gives exactly zero reported likelihood change at both 31 and 61
nodes. One 61-node EM refit checks the changed execution path: it converges in
43 iterations, differs by 2.84e-8 in parameters and 7.73e-12 in log likelihood.
No new data were generated and no full suite or repeated sampling study was
run. The initial independent equation/gradient tests remain in place, so
kernel sharing does not turn all comparisons into implementation self-checks.

Public `fit_mfrm()` still accepts one slope family. This completes the shared
conditional calculation and internal prediction part of G2, not public model
integration. Remaining work is the free-parameter/owner representation in the
common fit, readiness/inference decisions and result consumers, followed by
the corresponding prediction, plotting, reporting and persistence acceptance.

## G2: common parameter representation

The next increment connects the internal EM and conditional-response calculation
to `expand_params()` and adds a two-owner specification for the existing MML
evaluator. Separate component tables retain Task/Rater level labels and log
slopes; the likelihood consumes their effective product for each observed
crossing. Only task log slopes sum to zero. A sparse design stores observed
crossings rather than enumerating all possible task-rater combinations.
This does not qualify large-scale memory use or sparse-design inference.

Gradient projection uses the transpose of that design; parameter collapse uses
sparse QR and rejects effective slopes that cannot be represented by the fitted
product structure. Crossing indices require the original facet-level ordering
and an explicit specification. The internal prediction evaluator can still
combine known component levels in an unobserved crossing, labelled as before.
Single-owner parameters retain their existing expansion and projection.

The common fixed-quadrature likelihood and analytical gradients agree with
the EM expected-count calculation for binary, three-category and five-category
examples, including a missing task-rater crossing and permuted rows/factor
levels. Finite differences independently check the common gradients. Adaptive
integration now uses the same slope design and passes its own derivative check.
Its likelihood agrees with independent `integrate()` calculations of the
literal equation. On this small fixture, fixed 61-node integration differs by
about 1.6e-5 in total negative log likelihood; it is not treated as an exact
reference. Agreement at one fixed grid does not establish integration accuracy.

Reproduction, reusing the previously saved validation output:

```r
pkgload::load_all(compile = FALSE)
source("inst/validation/gmfrm-mml-em-20260927.R")
run_gmfrm_common_validation("/tmp/mfrmr-gmfrm-em-20260927/results.rds")
```

At saved 31/61-node estimates, common likelihood differences are zero, mean
score differences are at most 4.69e-16, and expand/collapse discrepancies are
at most 5.56e-17. One 61-node common direct fit from zero converges with maximum
mean score 5.98e-8, maximum parameter difference 3.80e-6 from saved EM, and
log-likelihood difference 1.14e-9. No new data or sampling study was generated.

Targeted checks pass: GMFRM 120 assertions, separated-owner kernels 4,
estimation core 295, and the separated-owner public fit/inference/curve/save
workflow 43. Code-usage checks pass. These establish numerical integration into
common parameter management, not completion of G2. Public `fit_mfrm()` still
rejects multiple slope owners. Public result consumers, readiness/identification
audits, joint uncertainty targets and save/replay must be adapted before that
restriction can be removed; no new public fitting option is added to NEWS/help.

## G2: owner-aware parameter maps and marginal diagnostics

The common optimizer parameter map now carries both slope owners, level names,
reference levels, constraints and optimizer positions. Task slope coordinates
use a sum-zero log constraint; every rater slope coordinate remains free. The
internal EM result retains this map and the nonlinear transformation audit.
The audit verifies the crossing-product Jacobian and its finite differences,
uses only the task-family invariant, and remains explicitly parameterization
only. It does not mark a converged EM result as identified or inference-ready.
Natural-coordinate derivatives scale rows directly, avoiding a square dense
diagonal matrix indexed by every observed task-rater crossing.

This map also enables the existing observed-Person score and exhaustive
response-pattern information diagnostics, and their existing local-rank
classifier, for the two-owner model. Exhaustive pattern enumeration is not
automatically added to the EM fitting loop; its existing execution limits and
fixed-quadrature scope remain. Observed-score deficiency alone remains
inconclusive, whereas full-pattern information can classify first-order
deficiency. No conditional-JML Jacobian is substituted for MML information.

A deterministic counterexample holds 16 task/rater rows fixed: two tasks by
two raters, with four repetitions of each crossing and binary scores. Only
Person assignment changes. At the same interior six-coordinate vector
`seq(-0.3, 0.4, length.out = 6)`, using 31 normal quadrature nodes:

| Assignment | Persons | Ratings per Person | Additive preflight rank | Full-pattern marginal score rank |
| --- | ---: | ---: | ---: | ---: |
| A different Person for every row | 16 | 1 | 3/3 | 4/6 |
| Each Person appears in all four crossings | 4 | 4 | 3/3 | 6/6 |

Both slope-factor designs have rank 3/3. Thus neither that rank nor the
additive preflight can stand in for the marginal-model check. In the first
assignment the binary likelihood depends on only four success probabilities,
so more independent Persons in the same single-rating design cannot identify
six free parameters. In the second assignment joint patterns supply additional
information. Local full rank at one vector under fixed quadrature is not
global identification, continuous-integral certification, sufficient finite-
sample precision or evidence of an interior optimum for the observed scores.

Pattern probability sums differ from one by at most 2.23e-16 in this check;
selected score finite differences agree within 2.61e-10. Tests additionally
check zero expected scores, observed-score reconstruction of the full gradient,
and the classifier's explicit limits. Wide rank-audit matrices are transposed
explicitly before QR, preserving the existing rank calculation without leaking
Matrix's internal transpose warning to users.

Reproduce through `tests/testthat/test-gmfrm-em.R`; the relevant existing
regressions are `test-estimability-audit.R` and
`test-nonlinear-local-estimability-classification.R`. They pass, along with
code-usage and whitespace checks. No new sampling experiment or full-suite run
was used. The user guide/NEWS explain the assignment issue without exposing
internal helper names. Public multi-owner fitting, joint uncertainty, result
consumers, plotting and portable calibration remain open. The common data
preparation currently requires at least 10 observed rows; that software minimum
does not qualify a design or its estimates.


## G2/G3: shared observed covariance and slope-product targets

The common `compute_mml_parameter_covariance()` and numerical Person-score
paths now pass the two-owner product specification to `build_indices()`.
Internal component and effective-product targets retain both owner labels and
full free-coordinate Jacobians, so all estimated nuisance parameters enter
through the inverse full observed marginal information. They do not use the
curvature of a frozen EM Q function. On the log scale,

`Var(log(a_task*a_rater)) = Var(log(a_task)) + Var(log(a_rater)) + 2*Cov(log(a_task),log(a_rater))`.

The new deterministic target test retains a nonzero cross-owner term and checks
both Jacobians against finite differences. A separate check compares the shared
Hessian against differentiated marginal scores and reconstructs their gradient
from Person scores. The full focused GMFRM file passes 192 assertions. Existing
single-owner/separated-step-owner inference, curves, results and save/replay
regressions pass 43 assertions. Code-usage, Rd and whitespace checks pass.

Reusing `/tmp/mfrmr-gmfrm-em-20260927/results.rds`, without refitting or generating
a new sample, the saved 61-node, 240-Person example gives:

| Check | Result |
| --- | ---: |
| Shared covariance status | ok, unregularized |
| Observed information rank | 13/13 |
| Maximum Hessian difference from saved marginal-score differentiation | 4.444978e-11 |
| Twice the task/rater log-slope cross-covariance across crossings | -0.0008043166 to 0.0012474725 |
| Effective log-slope marginal variance across crossings | 0.01547135 to 0.01840537 |
| Maximum error in the variance identity above | 2.656295e-18 |

The checked routes are reproducible in `test-gmfrm-em.R` and
`test-gpcm-separated-owner-workflow.R`. The saved-example calculation uses
`mfrm_gmfrm_problem(saved$data, 2L, gauss_hermite_normal(61L))`, its common
configuration with `estimation_control = list(quad_points=61L,
mml_integration="fixed")`, and `saved$fits[["61"]]$em$par`. The latter is passed
to the shared covariance helper and `mfrm_gpcm_product_slope_targets()`.
Multiplying each target Jacobian around the joint covariance gives the reported
log-scale covariances. The saved reference is `saved$fits[["61"]]$information`.

These checks establish a covariance calculation and internal target mapping,
not inference eligibility, sampling coverage, global identification or a public
multi-owner interval API. The targets currently require fixed-standard-normal
MML; public multi-owner fitting, interval qualification and consumers remain
open. In particular, the sampling covariance of estimated slopes is not a
multivariate G-study covariance component.

## Relationship to multivariate G theory: implementation and primary sources

Inspected the public `mfrm_multivariate_gstudy()`, `mfrm_multivariate_d_study()`
and `mfrm_multivariate_d_compare()` implementations and help. They operate on
observed numeric score components, not latent GPCM parameters. The first two
support one/two common random facets and the declared nested structures;
paired normal-theory plan-difference intervals support two crossed facets.
Incomplete-design MINQUE(0) does not repair informative missingness, and the
future D-study design must satisfy its separate balanced-design contract.
The `mfrm_generalizability(fit)` main-effects convenience route reuses ratings,
not latent parameter estimates. Neither is a joint GMFRM/G-theory estimator.

The existing mGENOVA Table 12 data (60 rows, V/W scores, 10 Persons, 6 tasks)
were reused for a public G-study followed by 3/6/12-task D-studies with the
prespecified difference W-V. All nine score/composite rows were available.
At six tasks the difference-score G/Phi were 0.3000000/0.2411605; the underlying
fixture and reference comparisons already live in
`tests/testthat/test-multivariate-gtheory.R`. This was a workflow smoke check,
not another sampling experiment or a full-suite rerun.

Primary literature review:

- Hirai, A., & Koizumi, R. (2013). *Validation of Empirically Derived Rating
  Scales for a Story Retelling Speaking Test*. Language Assessment Quarterly,
  10(4), 398-422. <https://doi.org/10.1080/15434303.2013.824973>.
  Local Zotero item H7P2ZUPE, PDF ALGRXKAR: inspected methods/results pp. 404-408,
  including the page image for p. 405. mGENOVA supplies **multivariate**
  criterion-level G/D analyses over stories; Facets supplies MFRM analyses.
  Raters are excluded from the G-study, double ratings are averaged for that
  analysis, and negative variance estimates are replaced by zero. Those
  choices must not be silently transferred to mfrmr or described as evidence
  for generalization to new raters. The paper establishes complementary use,
  not a joint two-slope GMFRM estimator.
- Jiang, Z., Raymond, M., Shi, D., & DiStefano, C. (2020). *Using a linear
  mixed-effect model framework to estimate multivariate generalizability
  theory parameters in R*. Behavior Research Methods, 52, 2383-2393.
  <https://doi.org/10.3758/s13428-020-01399-z>. Local PDF SM7KLBUJ: read the
  11-page text and rendered appendix code pages 2390-2391. Its score-component
  covariance framework helps distinguish mGT from multiple discrimination
  parameters. Its estimation framework/examples are not a validation of the
  package's distinct MINQUE(0) implementation, selective-missingness correction
  or automatic GPCM conversion.
- Briggs, D. C., & Wilson, M. (2007). *Generalizability in Item Response
  Modeling*. Journal of Educational Measurement, 44(2), 131-155.
  <https://doi.org/10.1111/j.1745-3984.2007.00031.x>. Read the introduction and
  theoretical setup from the author-institution full text, not the entire
  article. GIRM makes facet distribution assumptions and uses a distribution
  of expected-response matrices for a GT analysis; the illustrated design is
  binary with one measurement facet. This is precedent for integration,
  not direct qualification of the present polytomous, two-slope model.

The user guide and workflow help now distinguish these uses, preserve
score-weight versus slope and score-covariance versus sampling-covariance
meanings, and link the primary sources. ROADMAP orders immediate complementary
use before a future model-based planning or joint latent/random-facet model.
No generalization guarantee, new public model, or automatic filling of
unassigned ratings is introduced.


## Normal-population scale identity before SD stress qualification

The September 27 release-coherence review separates normal scale conversion
from population misspecification. Added a deterministic test with ability SD
0.5, 1 and 2 and means -0.6 and 0.4. For the original equation evaluated at
`theta = mu + sigma*z`, task slopes stay fixed, all free rater slopes multiply
by sigma, task locations and rater steps divide by sigma, and rater locations
become `(s_rater-mu)/sigma`. This preserves task GM1 and all sum-zero constraints.

An independent literal category recursion on the original scale agrees with
the common standardized kernel, and independent quadrature of complete Person
response patterns agrees with the marginal objective (tolerance 1e-12). The
focused GMFRM test file now passes 216 assertions, including 24 for these six
transformations. No estimator was refitted and no sampling data were generated
for this identity check. It qualifies neither estimated-population fitting nor
anchor support in the internal two-owner model.

ROADMAP now puts source/output coherence before new broad experiments. It
specifies sparse-link placement, fixed versus uncertain anchors, SD/shape/group
variation, dependence, covariance components, numerical stability and sampling
performance as distinct questions. The historical 147-fit PCM/JML anchor pilot
and 80-dataset separate-owner single-slope MML pilot are relevant but do not
qualify two-owner GMFRM. Planned stress conditions are not reported as executed.
The third proposed release pillar is actionable rater feedback and assessment
planning; the current RSM/PCM-only feedback-sheet restriction is an explicit
integration gap, not an implemented GPCM feature.


## G2: self-contained internal results and fresh-process replay

Internal EM results now retain plain model inputs (the four observed-rating
columns and their labels, category maximum, exact quadrature nodes/weights)
and solver controls including the start and marginal-score tolerance. They do
not serialize the problem's evaluation closures or caches. Posterior rows name
Persons, and columns name node indices corresponding to the retained rule.
This closes a source-of-replay ambiguity: coefficients and an EM trace alone
do not identify the observations or the numerical integration objective.

The fresh-process test saves a two-iteration result from seven-node quadrature,
with reordered rows/factor levels and one task-rater crossing absent. It loads
the result in a separate R process, reconstructs the problem using
`do.call(mfrm_gmfrm_problem, result$specification)`, and recomputes the saved
likelihood, posterior, marginal-score norm, parameters, parameter map, response
probabilities and component/product slope targets. Both fitting entry points
are mocked to fail if called. Every comparison passes, as does reconstruction
of a prediction for the known but unobserved crossing. Its `ObservedContext`
remains FALSE. The source's `converged = FALSE` and `iteration_limit` reason
remain unchanged; successful plotting/prediction reconstruction is not a
qualification of that fit.

The focused GMFRM test file passes 237 assertions, including 21 for this replay.
Code-usage and whitespace checks pass. No broad sampling or whole-package test
was added. New internal results carry the specification; older saved research
results are not retroactively assigned missing provenance. This is not the
public portable-calibration schema, a public two-owner fit, a new-Person scorer
or a new confidence-interval contract. The public single-owner restrictions
remain. The next G2 consumer work must preserve owner/level identity and the
different task-GM1 versus free-rater scale interpretation before exposing
existing one-owner reporting/inference routes to the new model.


## G2: common slope tables and owner-aware qualification mapping (2026-09-28)

The common `build_slope_table()` now represents product-model components as
separate rows identified by `SlopeOwner` and `SlopeFacet`. Existing single-owner
output columns remain unchanged. Product rows retain `ScaleReference` and
`Identification`, derived from the same metadata as the covariance targets:
the first family has geometric mean one; the second is free given that family
constraint and the fixed-standard-normal ability distribution. Effective
crossing slopes remain distinct targets rather than mislabeled component rows.

The common slope-readiness table, its application to estimates, and the update
from output-specific interval fields now match within each owner. They no
longer select a row solely by a potentially shared level name or borrow the
first owner's name for all rows. Matching avoids concatenated-key ambiguity;
duplicated levels within one owner and malformed readiness identities are
refused. Legacy single-owner slope tables without `SlopeOwner` remain supported.
A multi-owner table without owner labels is rejected rather than guessed.

Internal EM results retain the common slope table and slope-readiness rows.
Their numerical estimates remain available, but a certificate from the earlier
single-family boundary calculation cannot promote either product component.
Primary/interval qualification remains unevaluated. This plumbing change is
not a claim that product-slope intervals or public multi-owner fitting exist.
The result-class, curve, feedback and inference-consumer contracts remain open.

Tests deliberately give Task and Rater identical level labels containing a
colon, reorder result and qualification rows, distinguish their numerical
estimates, and verify that interval fields map to the correct owner while a
location row remains unchanged. They check duplicate/omitted owner information,
malformed identities, refusal to reuse a single-family certificate, and
preservation/reconstruction of the new tables through the saved-result path.

Focused checks: GMFRM 265, separated-owner single-family workflow 43,
GPCM uncertainty/readiness 88, and JML GPCM boundary 98 assertions pass, with
zero failures, warnings or skips. Code-usage and whitespace checks pass.
No whole-suite or sampling-study rerun was required. The guide/NEWS explain
why a free rater slope of one is not the average rater or a competence cutoff;
they do not advertise the internal table extension as a released fitting API.


## G2: configurable facet/person/score names (2026-09-28)

Removed hard-coded Task/Rater access from the two-owner EM problem, common
configuration, parameter unpacking and response calculation. Internal arguments
`slope_facets`, `person` and `score` now bind actual data columns. The first of
the two slope facets supplies centered locations and geometric-mean-one slopes;
the second supplies free locations/slopes and the centered category-step sets.
All effects still enter subtractively inside the product-slope predictor and
the population remains fixed N(0,1). Roles do not depend on domain words or
physical column order. Merely swapping the step owner is not claimed to be
an equivalent statistical model.

Structured parameter output uses `locations` and `slopes` lists keyed by the
original owners, plus `step_facet`. Response summaries retain original context
columns and explicitly identify the owners of `Slope1` and `Slope2`.
The common crossing specification and target metadata preserve non-syntactic
column names instead of silently applying `make.names()`. Required columns
must be distinct/nonempty; names reserved by common data or response columns
are explicitly refused. The exact column-role specification is saved alongside
the data and integration rule. Historical internal role-specific parameter
fields are not a public stable schema; the local verification runner and tests
now use the structured representation.

Focused equivalence tests use two levels for the first facet and three for the
second, with person/score columns renamed and physical column order reversed.
They cover Criterion/Assessor and Unicode/space/hyphen names (観点 名/Judge-ID).
Conditional predictions, marginal likelihood, analytical gradients, common
direct-MML evaluation and two numerical EM updates agree with the original
role-equivalent problem to 1e-12. Metadata and saved input mappings retain the
original names. A reversed Rater/Task declaration separately checks that
constraints and step ownership follow the declared roles and agrees with an
independent literal probability recursion; it is not compared as the same
model as the original Task/Rater declaration.

The fresh-process RDS test now also uses renamed, non-syntactic columns and a
missing crossing, preserving original owners and the unobserved-context flag
without fitting. Wrong arity, duplicate/empty/missing role names, reserved
facet names and overlapping person/score selections are rejected.

GMFRM checks pass 328 assertions; the unchanged public single-slope,
separate-step-owner workflow passes 43. Both have zero warnings, failures or
skips; code-usage and whitespace checks pass. No new broad simulation was
needed. The guide/NEWS distinguish names from model roles and continue to say
that public `fit_mfrm()` accepts only one slope family. This is internal
flexibility for two modeled measurement facets, not support for arbitrarily
many facets, a third step owner, or a released two-slope API.


## G2: shared conditional responses and curve uncertainty (2026-09-28)

The internal two-owner response and public one-owner curve interval API now
use the same conditional evaluator, retaining the common free-parameter
coordinates, facet signs, interactions, steps and stable log probabilities.
Prediction combines fitted component slopes at the requested levels; it does
not insert unobserved crossings into the estimation design or relax its rank
checks. Unknown levels remain errors. Known levels not observed together are
labelled separately from observed contexts, with integer-level keys to avoid
collisions between user labels. Context identity describes the retained design,
not local/global identification or confidence-interval reliability.

Focused tests compare full-coordinate probability/information derivatives
against an independent literal adjacent-category recursion, including an
unobserved crossing and non-syntactic Japanese facet names. A positive-definite
test covariance with cross-family entries verifies propagation of the full
joint covariance and demonstrates the difference from discarding its
cross-family entries. This is an algebraic propagation check, not an estimated
sampling covariance or a new coverage experiment. Existing likelihood-response
equivalence, extreme-ability stability and fresh-process replay checks pass.

Public curve results now save `contexts` (InputRow, ObservedContext) separately
from user facet columns, avoiding a new reserved facet name. Reports include
the context table; printing and default captions identify unobserved
combinations. Explicit caption=NULL still suppresses text; old saved objects
without the new component remain accepted. The unavailable-interval and
unobserved-context notes can coexist. Help and NEWS document these behaviors.

Targeted GMFRM, separate-owner workflow, inference-extension and reporting
checks pass; no full-suite or broad simulation rerun was needed. G2 remains
in progress: public two-owner dispatch, interval eligibility and remaining
consumers are not implemented by this refactor. G3 still requires statistical
qualification of separation, sparse designs and interval performance. A shared
curve evaluator must not be interpreted as a released two-owner interval API.


## G2: shared summaries and printed scale meanings (2026-09-28)

The common summary path previously pooled slope rows under the first owner's
name and described all GPCM slopes as geometric-mean-one relative slopes. It
now aggregates separately by the declared owners, using the existing
owner-plus-level matcher and metadata. The first family's within-facet
geometric reference remains distinct from the free second family on the fixed
standard-normal ability scale. Missing, duplicate or ownerless component rows
are refused rather than silently reassigned. Settings retain both owners.

The common scale contract and model identity now represent the product model.
Both print paths explain its different scale references in ordinary language;
internal identification codes are not printed. Shared summary follow-up text
does not suggest single-family intervals or plots for this model. Numerical
traces, primary estimates and interval eligibility remain separate. No
likelihood, optimizer, default or inferential admission rule was changed.

The internal EM result saves the shared slope overview and scale contract.
It remains an unclassed list. Tests exercise common consumers with an explicit
test payload; they do not demonstrate a public fitted two-family object.
Public dispatch, expanded summary profiles, prediction/diagnostic/plot/report
consumers and portable calibration still require their own integration. In
particular, summary-profile recommendations must be audited before public
dispatch is admitted. Public `fit_mfrm()` still accepts one slope family.

Focused checks use three levels in the first family and two in the second,
with known geometric means of one and four. They verify independent counts
and readiness, overlapping level labels with delimiters, Unicode facet names,
row reordering, missing identity refusal, unavailable inference, nonconvergence,
printed meanings and RDS restoration. An actual saved public single-family
fit produces an entire common summary identical to the pre-change function.

`test-gpcm-owner-summaries.R`, `test-gmfrm-em.R`, `test-output-stability.R` and
`test-gpcm-mml-identification.R` pass with no failures, warnings or skips.
The existing GMFRM checks include fresh-process reconstruction. No full-suite
or sampling-study rerun was needed; these checks establish output consistency,
not sampling coverage or general identification. Public summary help explains
the primary/optimizer distinction without advertising the internal extension
as a new fitting feature.


## G2: assembling actual EM results in the shared fit structure (2026-09-28)

The internal `mfrm_gmfrm_fit_result()` adapter now builds the existing
`mfrm_fit` tables and current readiness record from an actual EM result.
It uses shared preparation, design/category review, person-boundary handling,
slope qualification and summary builders. It checks the saved specification,
retained marginal likelihood and score-based convergence flag before assembly.
The total log likelihood and parameter count retain their meanings; EM's
average negative-log-likelihood objective is not mistaken for the total.
Posterior moments use the exact retained standard-normal Gauss-Hermite rule.
The adapter refuses other rules instead of mislabelling them as that method.

The numerical record identifies generalized EM, ascent-checked BFGS M steps,
completed EM iterations and the actual marginal-score tolerance per Person.
Unknown function/gradient evaluation counts remain missing. It does not reuse
the relative-likelihood stopping label from the RSM/PCM EM implementation.
The existing optimizer diagnostics support this explicit score criterion;
their previous default and relative-likelihood behavior are unchanged.

Passing the score criterion does not admit statistical inference. The two-owner
boundary reason is distinct from the one-owner reason, so the common decision
text no longer suggests one-owner `confint()` or PCM/GPCM comparison. The common
IC contract explicitly marks the product structure unsupported for ranking and
withholds its IC panel. Lightweight summaries are available; expanded diagnostic
and reporting profiles stop explicitly, and their unqualified Wright/Pathway
recommendations are not advertised as available or required.

Tests compare EAP and posterior SD with direct moments of the retained E-step,
check total likelihood/counts, owner names, real nonconvergence, saved trace,
current readiness and likelihood/specification mismatches. A deliberately loose
stopping tolerance tests that numerical convergence alone still grants neither
primary slopes nor inference/IC eligibility; it is not a successful estimation
example. The existing fresh-process test now also restores the assembled fit,
its summary and conditional responses without either fitter running, including
Unicode names and a known but unobserved crossing.

The owner-summary, GMFRM EM, output-stability and information-criterion test
files pass without failures, warnings or skips. After extending saved-fit
coverage, the fresh-process case was rerun on its own and passed; the existing
optimizer-diagnostic case also passed (including the old relative-likelihood
route). No broad sampling study or whole-suite rerun was needed.

This is an internal fit adapter, not a released two-owner constructor.
`fit_mfrm()` still refuses multiple slope facets. Opening that dispatch requires
explicit input/default validation and the remaining prediction, diagnostic,
plot/report, interval and portable-calibration consumers to be adapted or
specifically refused. The adapter's class is not evidence that those consumers
support the model. Public help/NEWS describe numerical-summary fields without
advertising a two-family fitting option.

## 2026-09-28: scoped public fitting, curves and saved reporting

`fit_mfrm()` now admits exactly two ordered slope owners under explicit
fixed-N(0,1) MML--EM, with the second owner supplying free locations/slopes
and centered steps. Its first owner retains centered locations and GM1 slopes.
The existing one-family defaults and fallback behavior remain unchanged.
`em_score_tol` controls the per-Person marginal-score criterion; unsupported
arguments are rejected instead of silently ignored. Missing scored rows,
duplicate person/context rows and inappropriate category recoding are refused.
Preserving an absent internal category reaches the existing category-support
error before fitting, rather than changing the response scale.

The public route returns the existing fit class. Summary, conditional
probability/information curves, existing ggplot methods, minimal saved results,
reports and export are connected. Literal product-equation checks verify the
curve probabilities and slope-squared conditional variance for information.
Tests retain Unicode/non-syntactic owners, shared labels, original column
roles, nonconvergence, exact public-call replay, known unobserved crossings,
missing intervals and report/export source values. Scope errors guard ordinary
diagnostics, parameter intervals, scoring, calibration, model comparison and
unadapted figures, including routes that read fit tables directly.

Reports use provisional-model guidance instead of recommending unavailable
ordinary diagnostics or a required Wright map. The reader-facing report starts
with model settings and fitted slopes; full numerical metadata remain saved.
Plots retain non-color line styles, removable text and unavailable-interval
markers. The exported curve PNG was visually inspected. A fresh R process
loaded the exported RDS via its replay script and reproduced curve values
exactly without fitting. This is saved-analysis replay, not portable scoring.

Targeted test files passed: `test-gmfrm-public-workflow.R`, `test-gmfrm-em.R`,
`test-gpcm-owner-summaries.R`, `test-gpcm-separated-owner-workflow.R`,
`test-gpcm-inference-reporting.R`, `test-output-stability.R`, and
`test-gpcm-capability-matrix.R`. The capability file retains three existing
CRAN-skipped report/design/screening cases; they were not run in this check.
The other listed files completed without warnings or skips. Focused tests were
rerun when report/export changes were made. New helper usage checks and
`git diff --check` passed. The six affected Rd topics were checked and the
scope vignette rendered with examples disabled; its new data-dependent example
is explicitly `eval=FALSE`. Public end-to-end behavior was exercised separately
by the targeted tests. No whole-suite check, broad simulation or external
software run was repeated.

This closes the minimal public fit/curve/report connection, not all of G2.
Joint-slope interval eligibility, global/boundary identification, sampling
qualification, ordinary diagnostics, model ranking, new-person scoring,
portable calibration and individual feedback remain unfinished. G3/G4,
corrected-JML milestones and integrated release checks remain open. Nothing
was committed, pushed or released by this local integration step.

## G2/G3: experimental component-slope intervals (2026-09-28)

The public two-family fit now supports `ci <- confint(fit)` for an explicitly
experimental log-Wald approximation to each component slope. No new exported
function was added. The default scale for this model is `standardized`, since
the ability SD is fixed at one; the first family retains geometric mean one
and the second is free. Explicit relative-scale, profile, sandwich and contrast
requests are rejected. Bonferroni can adjust across all requested component
slopes; no individual unit-slope p-values are provided. The two families have
different reference meanings, retained in the table, print output and default
plot caption. This does not add intervals for slope products, locations or
response curves.

For component log slopes with full-coordinate Jacobian J, the covariance is
`J solve(H) t(J)`, where H is the observed marginal information for all free
coordinates. It includes nuisance-parameter uncertainty and cross-family
covariance. It is neither the inverse slope block nor frozen-Q curvature. The
first family's sum-zero constraint gives an expected singularity in the
expanded target covariance, without making the free-coordinate information
singular.

Qualification reevaluates model/source identity, score-category support,
convergence, unregularized joint information and the retained likelihood.
Observed Person-score derivatives must have stable full column rank across
three relative SVD tolerances and two finite-difference steps. In a smooth,
positive-probability model, full rank of these selected outcome-probability
derivatives is sufficient evidence for local separation at the fitted point.
The check concerns the quadrature model. It does not establish global
identification; failure of this sufficient subset check alone does not prove
structural nonidentifiability. Fresh per-Person and curvature-scaled gradients
and the inverse residual are checked separately. Higher-order integration
reevaluates scores and information at the retained parameters, without refitting.

The original 240-Person dataset and 31-node solution were retained in
`tests/testthat/fixtures/gmfrm-joint-information.rds`, with an independently
differentiated marginal-information reference. The focused test constructs
the 6-by-13 component Jacobian independently and verifies the full covariance,
log-Wald bounds and cross-family term. Both families' names survive arbitrary
facet labels and overlapping level labels. Original primary estimates and
global inference/IC readiness remain unchanged.

| Numerical check on the retained 31-node solution | Result |
| --- | ---: |
| Free-coordinate observed score rank | 13/13 |
| Maximum mean marginal score | 9.87e-7 |
| Curvature-scaled gradient length | 4.75e-5 |
| Infinity-norm inverse residual | 1.83e-14 |
| Score displacement, 31 versus 61 nodes, standardized by original covariance | 0.001375 |
| Spectral covariance change, standardized by original information | 0.001276 |
| Available component-slope intervals | 6/6 |

The two quadrature-change tolerances are 0.01. These are documented numerical
safeguards, not thresholds calibrated for statistical coverage. Two focused
public-entry refits of this same dataset test the convergence/integration
distinction: the five-node fit converges, but its five-versus-nine-node score
displacement is 1.700458 and covariance change is 0.605363. It retains all
estimates but no bounds, with the failed check recorded. The 31-node public
fit passes. These examples do not establish that a fixed grid size always
suffices. A third focused refit with `em_score_tol = 1e-3` meets its requested
EM stopping rule but fails the fresh stationarity check for intervals. Its
measured score and curvature diagnostics remain available, while unperformed
quadrature checks stay missing. Nonconvergence, source mutation, likelihood
mismatch and insufficient information-workspace budget also have explicit
failure tests.

The existing print/plot/ggplot, plot-data, APA-table, results/report and export
routes reuse the saved result. They preserve owner/level identity, scale,
experimental cautions, check tables and unavailable outcomes. Saved plotting
and reporting were checked in a fresh R process with fitting and covariance
recomputation disabled. The default plot was inspected at 9 by 6 inches; names,
uncertainty, warnings and both scale references are readable. Users can still
remove titles, subtitles and captions explicitly.

Targeted files passed: `test-gmfrm-slope-intervals.R`,
`test-gmfrm-public-workflow.R`, `test-gpcm-owner-summaries.R`,
`test-gpcm-inference-reporting.R`, `test-gpcm-inference-extensions.R` and
`test-gpcm-capability-matrix.R`. The capability file's three pre-existing
CRAN-skipped cases were not run. Subsequent plot-metadata/caption changes were
checked with the two affected interval/reporting files. Help topics were
regenerated and checked, the scope guide rendered with examples disabled,
and the data-dependent workflow was exercised by tests. No full-suite run,
new sampling study or external-software comparison was performed.

G2 has gained an experimental uncertainty/output route; G3 statistical
qualification remains open. Local information, numerical stability and one
retained example do not establish bias, boundary behavior or interval coverage
across assignment designs. G4 and integrated release checks are also open.
This local work does not commit, push or release the package.

### Subsequent sparse-design check and numerical-warning repair

The [400-case sparse-allocation study](gmfrm-sparse-intervals-20260928.md)
now evaluates common-Person versus rotating-pair allocation at normal ability
SD 1/.5 with scale-transformed truths. It identified an overly strict 1e-4
standardized-score refusal. The current helper retains a warning above 1e-4
and refuses above 0.01, preserving all other checks and all parameter estimates.
The original study and revised-rule interval reanalysis are stored separately.

Revised availability is 11/100 for common SD=1, 100/100 for rotating SD=1,
100/100 for common SD=.5 and 99/100 for rotating SD=.5. The common SD=1 failures
are integration-sensitivity failures, not a demonstrated identification defect.
The study also finds residual log-slope bias and a 90/99 task-interval coverage
case with possible SE underestimation. These findings replace any inference
that the earlier one-example numerical check qualified sparse-design coverage.
See the linked record for denominators, Monte Carlo uncertainty, all components,
source preservation, regression tests and the next G3 decision.

The subsequent [matched quadrature follow-up](gmfrm-sparse-intervals-20260928.md#2026-09-28-matched-quadrature-follow-up)
replays all 100 common-Person SD=1 datasets at 61 points with unchanged EM
controls. All return intervals and pass their 61-versus-121 checks. The
existing quadrature-sensitivity API now retains these two-family comparisons
and interval objects. Sampling bias/SE discrepancies remain, including t3
coverage 90/100, so this resolves numerical availability without closing G3.

### Same-data posterior response diagnostics (2026-09-29)

The G2 output contract now admits `mfrm_response_diagnostics()` for the
converged, fixed-N(0,1), two-family MML--EM model. It uses the shared conditional
response evaluator and integrates over each Person's posterior given every
observed rating, with calibration fixed. Returned rows preserve the observed
assignment; selecting rows changes only display and aggregation. The variance
is that of the posterior predictive mixture, including variation of conditional
means. These descriptive Infit/Outfit summaries have no established
expectation-one reference, formal fit test or rater-quality threshold.

Verification reuses the retained 240-Person numerical fixture and a sparse
common-Person fixture. There was no new sampling study or repeated full package
check. Independently coded literal logits and continuous normal integrals agree
with probabilities and moments to a test tolerance of 1e-8. The checks
distinguish posterior integration from an EAP plug-in and mixture variance from
the mean conditional variance. They also cover ordered row subsets, arbitrary
Unicode owner names and overlapping level labels, incomplete assignments,
insufficient quadrature, stale calibration and nonconvergence. Failed rows stay
in group denominators with missing summaries; slope-interval unavailability
does not remove a valid point calculation.

The new test file `test-gmfrm-response-diagnostics.R` passes 84 assertions.
Related two-family public workflow, ordinary/extended response diagnostics and
comparisons, corrected-JML diagnostics, capability and plot-guide checks pass;
three pre-existing CRAN-gated capability tests were not run. Saved paired/scatter
plots, ggplot conversion, reports and CSV/RDS export/replay are checked with
fitting and probability integration disabled; a separate R process reopens the
saved report. Rendered paired/scatter figures were inspected. Help, NEWS,
vignette and roadmap now distinguish this target from ordinary fit diagnostics.

Response quadrature checks do not refit the calibration or repair its bias.
The existing quadrature-sensitivity route still addresses calibration grid
sensitivity. Formal fit diagnostics, Q3/PCA for this model, model comparison,
Wright/Pathway maps, later-Person scoring and portable calibration remain
separate unfinished output contracts. This increment does not close G2/G3.

## September 30: empirical practitioner workflow

**Question and purpose.** Can a practitioner take an actual writing-rating
table through assignment review, the two-family fit, numerical sensitivity,
descriptive diagnostics and a saved report without treating unavailable
outputs as usable rater feedback? The purpose is applied problem discovery
and end-to-end interpretation. Real data have no known generating truth and
cannot supply parameter recovery or confidence-interval coverage.

**Provenance.** `sirt::data.ratings1`, installed sirt 4.2.133, is documented as
a 2009 Austrian grade-8 German writing survey. All 274 supplied Person/rater
rows and all five criterion columns were converted to 1,370 long-form scores,
without deletion, imputation or invented criterion labels. The complete
original table, source/package versions, input hashes and session are retained
under `validation-results/gmfrm-practitioner-20260930/`. Data remain external
to the mfrmr distribution; no new dependency is required for package use.
The installed author help is the provenance source, also available in the
[author's package manual](https://alexanderrobitzsch.r-universe.dev/sirt/doc/manual.html#data.ratings).

All nine bundled mfrmr score datasets are synthetic. In particular, the legacy
`ej2021_*` datasets reflect published dimensions, not actual TestDaF responses,
and their unknown generation mechanism does not establish a recovery truth.
The existing generic task/assessor example and common-Person/rotating-pair
simulation had not completed this empirical practitioner check.

**Observed design.** There are 135 Persons, seven observed raters, five criteria
and scores 0–3. The rater factor contains nine additional unused levels; those
were retained in the source archive but not invented as observed raters.
Observed rater counts per Person are:

| Raters per Person | Persons | Observed criterion ratings |
| ---: | ---: | ---: |
| 1 | 89 | 445 |
| 2 | 27 | 270 |
| 6 | 2 | 60 |
| 7 | 17 | 595 |

Each rater sees 37–41 Persons. All rater pairs share 17–21 Persons; the
Person/rater network is connected. There are 29 observed roster patterns,
13 occurring for only one Person. All rater-level categories occur, but five
rater/criterion/category cells are empty. The 17 commonly rated Persons
contribute 595/1,370 ratings, about 43.4%. Equal-ish rater workloads therefore
do not mean equal information per Person or broadly distributed links.

The source table contains no NA scores, but the intended assignment roster is
not supplied. `describe_mfrm_data()` correctly retains `not_declared` for
structural missingness: 1,370 of 4,725 possible cells is not an estimated
missing-at-random rate. No absent combination is assigned a zero or a
missing-score mechanism. Common Persons are links, not fixed parameter anchors.

**Fixed procedure and result.** The runner
`gmfrm-practitioner-20260930.R` used the whole table: Criterion then Rater
slopes, rater-owned steps/free location, first-family GM1 constraint,
N(0,1), observed categories 0–3, unit weights, generalized EM, 500 outer
iterations and mean-score tolerance 1e-7. A 61-node fit and a single explicit
121-node sensitivity refit were declared before execution. Both converged;
the first used 180 outer iterations. Local elapsed times were 16.222 seconds
for the initial fit and 44.883 seconds for the complete quadrature review,
not a general speed claim. Fitting code was the local `4ba94470` checkpoint.

The 61-node NLL was 1177.111; the 121-node refit changed NLL per Person by
.0007644152, the largest slope coordinate by .2546042, and a fitted category
probability by .1697842 over the common [-4,4] grid. A saved-fit review confirms
the same maximum within [-2,2]; the finding is not confined to extreme tails.
It compares conditional fitted curves at chosen abilities, not out-of-sample
accuracy. Both returned interval objects retain all 12 components as
ineligible with missing bounds. An existing result object is not equivalent
to an available confidence interval. Neither fit is an empirical truth.

At the 61-node calibration, `mfrm_response_diagnostics(..., quad_points=121)`
checks response probabilities against 243 nodes. Results by observed exposure:

| Raters per Person | Attempted rows | Available rows | Largest probability integration discrepancy |
| ---: | ---: | ---: | ---: |
| 1 | 445 | 283 | .004415534 |
| 2 | 270 | 35 | .002956452 |
| 6 | 60 | 0 | .007247950 |
| 7 | 595 | 0 | .040124097 |

The unchanged tolerance is 1e-7. Total availability is 318/1,370, and every
criterion/rater group has incomplete rows, so all grouped Infit/Outfit values
remain missing. These are approximation failures at a retained calibration,
not observed evidence that those Persons or raters misfit. Concentrated
within-Person ratings plausibly challenge a fixed prior grid, but this
association does not establish a cause or rule out changed local solutions.
The full calibration, fixed-parameter integral and refitting effects must
be separated before changing an integration algorithm or recommended setting.

`mfrm_results()` and `mfrm_report()` retain fitted curves, missing component
intervals and all descriptive-diagnostic failures. The results/report RDS and
Markdown report were saved; reopening preserves every table and the exact
response-diagnostics attachment. No individual feedback sheet, competence
ranking, automatic model-selection decision or unsupported Person score was
manufactured. There was no broad simulation, full-package check or CI run.
The empirical example and explanation are now in the GPCM vignette/help/NEWS.

The executed runner is archived as `executed-runner.R`. Subsequent cleanup
moves its existing-file guard before any writes, and the reporting block was
executed separately from saved fits without re-estimation. Initial numerical
results and hashes are unchanged. The central-grid comparison and exposure
breakdown also reuse saved fits/diagnostics, and are retained in their CSVs.

**Second domain and evidence limits.** Zotero read-only search confirmed
Uto--Ueno (2020), key `IR3LFDRM`, and Uto (2021), key `38TX837G`.
The OSCE title search found no matching local item. The primary
[Uto et al. (2024) article](https://doi.org/10.1371/journal.pone.0309887) and
[Dryad description](https://doi.org/10.5061/dryad.tmpg4f56q) describe a small
medical-interview design with two common raters plus three subgroup raters.
Its item-specific steps and rater/item location interactions distinguish it
from the native two-family kernel. This was a targeted data/method-description
review, not a fresh full-PDF review or empirical replication. The public CSV
download returned HTTP 403, so its scores, coding and missingness were not
inspected and no OSCE fit was performed.

**Decision.** This empirical case adds a concrete integration/output obstacle
to D1/D2; passing the earlier synthetic recovery checks does not close it.
It does not establish that GMFRM is unsuitable for writing assessment or that
an equal-slope model is better. The authoritative roadmap now requires
question-led real-design simulation contrasts, matched simpler-model targets,
and explicit decision/output availability in addition to recovery/coverage.
Resolve this numerical obstacle and specify the retained practitioner claim
before a new independent coverage study; do not expand a full factor grid or
repeatedly increase quadrature until the output appears satisfactory.

The published data-preparation chunk was executed and its result is identical
to all 1,370 rows used for fitting. The guide renders to HTML; the generated
Rd parses and matches its roxygen source. The runner's early existing-case
guard was exercised: it refuses a duplicate run before writes, preserving
hashes of all retained files. These checks add no refit or simulation.

## September 30: consequential ranking in judged sport

**Question.** The user asks specifically about a decision as consequential as
selecting a sports champion. Before adding winner inference, determine what
the recorded scores and outcome represent and whether the current model and
uncertainty consumers can answer that question. This bounded audit addresses
that scope decision; it is not a latent re-ranking of named competitors.

**Primary data.** The [ISU Olympic 2026 women's event](https://results.isu.org/results/season2526/owg2026/)
links the short/free score PDFs, their separate judge rosters and final result.
`gmfrm-sport-decision-20260930.R` parses locally saved copies, preserves source
URLs/hashes and fails on unaccounted records or aggregation discrepancies.
Inputs and resulting `audit.rds`, component-mark CSV, final-total CSV and
session information are under `validation-results/gmfrm-sport-20260930/`.
These are external empirical records, not a new bundled package dataset.

There are 29 short-program and 24 free-skating performances, three component
marks per judge, and nine judges in each segment: 1,431 component marks in
total. Named panels contain 13 different judges and five shared judges; only
one slot keeps the same judge. Local `J1`--`J9` labels cannot be joined across
segments as identities. Five short-program participants do not reach the
final: their absent free-skating records are not uncollected assigned ratings.
The HTML roster labels all judges ISU, so it does not independently supply
judge nationalities for any national-bias analysis.

**Executed arithmetic checks.** All 159 component trimmed means, 53 factored
PCS totals, 53 segment totals and 24 final totals agree with the published
figures to floating-point tolerance (1e-10). The audit uses integer
quarter-points/hundredths for mean and per-component half-up rounding before
adding factored components. The first draft correctly failed: rounding only
after summation, or R's ties-to-even convention, misses some PCS totals.
The parser also had to preserve negative signed deductions. These were audit
implementation errors, not defects in mfrmr's estimator or the official data.
Published technical-element totals are retained; element-specific GOE/base
value conversion, tie resolution and the complete technical rule engine were
not independently reconstructed. The first page of each score PDF was
visually checked; all numeric records were parsed and reconciled. This is not
a claim of visually reading every page of the full Olympic results book.

Across the two segments, the first finisher's TES/PCS are 119.08/107.71 and
the second finisher's 112.91/111.99, both with zero deductions. Totals are
226.79 and 224.90, a difference of 1.89. PCS ordering differs from total
ordering because their targets differ. Neither ordering establishes a latent
truth or gives a calibrated probability of a different future outcome.

**Mathematical/API consequence.** Athlete, segment, component and actual
judge are distinct roles. Integer PCS coding preserves 40 categories; it
does not remove empty cells, selected-population assumptions or within-
performance dependence. Pooling those marks with GOE and difficulty points,
dropping the segment, or treating repeated performances as independent
athletes would change the model. The two-family route admits exactly two
non-Person facets and supplies neither Person scoring nor athlete-rank
inference. Component-slope intervals are not athlete intervals. Existing
one-family EAP conditions on calibration; its marginal intervals do not
account for selecting the highest estimate among many. Linear observed-score
G/D composites do not reproduce trimming, and G is not a winner probability.

**Literature review limits.** Looney (1997), *Objective measurement of figure
skating performance*, Journal of Outcome Measurement 1(2), 143--163,
[PMID 9661718](https://pubmed.ncbi.nlm.nih.gov/9661718/), was checked through its
primary abstract: it analyzes the 1994 event and its historical median-rank
system, not today's scoring or this implementation. Mercier and Heiniger's
[2019 v3 paper](https://arxiv.org/abs/1807.10021) was reviewed selectively in
Sections III, VI and VIII (rank-method pages 9--10 also visually inspected).
It treats performance-dependent judging variability, imperfect control-score
proxies and limitations of rank-based judge assessment. It is neither a
GMFRM-equivalence study nor grounds to equate podium sensitivity with judge
incompetence. No fresh full-paper or Zotero-library audit is claimed.

**Disposition.** Public GPCM guidance now distinguishes official, latent and
future-performance targets with the empirical example. GPCM and multivariate
D-study help state the missing rank-inference scope. The internal roadmap
requires explicit selection loss, false confident decisions, candidate-set
coverage/size, unavailable outcomes, gap/tie contrasts and the appropriate
repeated competition unit before admitting a winner claim. No new model,
winner-probability API, simulation grid or estimator refit was introduced.
The empirical writing integration issue and corrected-JML centering issue
remain the mathematical priorities; this sport audit does not close them.

**Verification.** The final runner also passed in an isolated copy of the
five source files; its parsed ratings, checks and totals are identical to the
retained audit. A repeated call in the original directory refuses to overwrite
the saved result, with unchanged hashes. Both updated Rd pages parse, the
vignette renders to HTML, and the new section/table is present. Parsed R
expressions in the two edited package source files match HEAD: changes there
are documentation only. No full test suite, estimator simulation or refit was
needed for these changes.

## September 30: general-purpose fixed-calibration integration review

The user clarified that general APIs take priority over domain-specific
operational workflows. The empirical case therefore supplies a numerical
counterexample, not a requirement for another writing/sport product. Reuse
the existing integration machinery to separate integration error from fitted
parameter differences, without running another calibration or simulation.

**Mathematics.** At fixed positive component slopes, let `a_j` be their
product for an observed crossing. With the existing whole-predictor GPCM,
unit weights and N(0,1) ability distribution, the conditional log-posterior
score is `sum_j a_j * (y_ij - E[Y_ij | theta]) - theta`. Its negative second
derivative is `1 + sum_j a_j^2 * Var(Y_ij | theta)`, which is strictly positive.
Thus the existing scalar mode/curvature kernel applies directly to two
families once indices refer to their observed crossings. Under
`theta = mode + scale*z`, the GH sum retains the original normal density
through its density ratio and Jacobian; changing the integration coordinates
does not replace the prior with a fitted posterior. A unique conditional
posterior mode is not a unique marginal-likelihood calibration optimum.

**Executed independent check.** `gmfrm-fixed-integration-20260930.R` reuses
the original `quadrature-review.rds` containing the 61- and 121-node writing
fits. It compares fixed and adaptive 15/31/61-node integrals at unchanged
parameters, then independently evaluates literal category logits using
`stats::integrate()` over the real line for every one of the 135 Persons.
Density rescaling avoids underflow; mode and local scale only change the
continuous integral's coordinates. The reference uses neither the package
probability kernel nor its GH rules. All integration calls report `OK`.

| Saved calibration | Original fixed-grid NLL | Continuous-integral NLL | Maximum fixed log-integral error per Person | Maximum adaptive-61 log-integral error | Maximum adaptive-61 mean / SD error |
| --- | ---: | ---: | ---: | ---: | ---: |
| 61 nodes | 1177.111430 | 1178.139807 | .3893272 | 1.425e-8 | 2.336e-8 / 2.301e-8 |
| 121 nodes | 1177.214627 | 1177.662750 | .0921765 | 1.656e-8 | 5.599e-8 / 7.503e-8 |

The ordering of the two calibrations by NLL reverses under common accurate
integration. Maximum fixed-grid mean/SD errors are .072652/.084100 at the
61-node calibration and .026744/.034384 at the 121-node calibration. Neither
comparison reoptimizes parameters. These findings establish a numerical
approximation problem in this case; they do not identify the accurate
optimum, rule out local solutions or qualify interval coverage. Adaptive
31-to-61 log-integral changes reach 8.45e-6, so order agreement itself should
remain reported rather than interpreted as an exact-error certificate.
This complete diagnostic took 9.386 seconds locally; no runtime or accuracy
guarantee follows for arbitrary datasets.

**Public integration.** The existing `mml_quadrature_sensitivity()` and GPCM
alias now pass `gpcm_spec` to `build_indices()` for the optional adaptive
review instead of rejecting two families. The same kernel, existing output
class, summary/print and RDS path are retained. No new public function or
estimation algorithm is introduced. `summary` still has unavailable
two-family Person-score comparisons; posterior moments in the separately
labelled `quadrature_review` are fixed-calibration diagnostics. Fixed-grid
EM, reported estimates, component-interval checks and readiness are unchanged.
The actual capability table, help, NEWS and guide describe this distinction.

The next numerical decision concerns calibration against accurately
integrated likelihood, including the optimization/derivative contract. This
change does not silently turn the fixed-node generalized EM into an adaptive
EM, certify Person scoring, or close the corrected-JML centering question.

**Verification.** The scoped GMFRM quadrature tests and existing RSM/PCM
quadrature tests pass. The GMFRM tests include literal continuous integrals,
arbitrary owner labels with overlapping level names, an absent facet crossing,
unchanged source likelihoods, saved review tables and continuing rejection of
adaptive EM/Person scoring. Help generation and Rd parsing succeed, the actual
capability table contains the new scope, and the guide renders to HTML. The
initial test failures concerned expected console/error wording and were
corrected before the passing run; numerical-reference assertions passed.
No whole-package test or independent coverage simulation was repeated.

## September 30: adaptive two-family calibration

**Question and scope.** Can the existing adaptive likelihood and gradient
estimate the same two-family model accurately, after the fixed-grid error
identified above? The user prioritized a general-purpose API, not additional
domain-specific features. The response equation, two ordered slope owners,
fixed N(0,1), unit weights and absence of anchors remain unchanged. This is
MML with direct optimization; it is not a moving-node EM algorithm.

**Derivative and fitting procedure.** The shared evaluator differentiates the
finite adaptive GH sum, including posterior-mode, local-width and Jacobian
derivatives. Independent Richardson differences of the diagnostic objective
agree within 1e-6 for binary and four-category responses, incomplete crossings,
non-default owner labels and orders 1/3/15. Low-order checks expose omitted
moving-node terms. No alternate derivative or likelihood kernel was added.

`gmfrm-adaptive-calibration-20260930.R` uses the retained 135-Person,
1,370-rating empirical data. Two adaptive-order-31 fits start from the saved
fixed-order-61/121 EM fits. A third fit uses the public API's neutral start
and adaptive order 61. All use the existing BFGS direct optimizer, maxit 500,
reltol 1e-10 and its existing gradient checks/polishing. There is no wall-time
cap, newly simulated dataset or exclusion of unsuccessful runs. The two
initial scripts, their hashes, completed fit objects, independent integration
results and session information are retained in
`validation-results/gmfrm-adaptive-calibration-20260930/`; reruns load completed
fits rather than overwrite/refit them.

| Starting values | Adaptive fitting order | Fitted NLL | Literal continuous NLL | Maximum free-coordinate difference from neutral-start fit | Fitting seconds |
| --- | ---: | ---: | ---: | ---: | ---: |
| Saved 61-node EM | 31 | 1177.482530 | 1177.482535 | 2.54e-6 | 35.234 |
| Saved 121-node EM | 31 | 1177.482530 | 1177.482535 | 3.65e-6 | 51.155 |
| Public neutral start | 61 | 1177.482535 | 1177.482535 | 0 | 77.597 |

At every retained solution, all 135 continuous integrations return `OK`.
The reference uses literal category logits and `stats::integrate()` over the
real line, independently of the package probability kernel and GH rules.
Maximum per-Person log-integral discrepancies across the three solutions are
8.37e-6 (adaptive 31), 2.31e-8 (61), and 1.52e-11 (121). The total-gradient
61-to-121 difference is at most 6.95e-7. The public fit's largest per-Person
score at order 121 is 5.34e-7. Its local full marginal Hessian at order 61 has
eigenvalues 7.846 to 830.402 and curvature-scaled gradient length 2.47e-5.
These support a numerically stable local solution in this case; they establish
neither a unique global solution, absence of boundaries, sampling coverage nor
correctness of the empirical response model. Timing is descriptive only.

**API and output integration.** `fit_mfrm()` accepts the explicit combination
`mml_engine = "direct", mml_integration = "adaptive"` for the same two-family
model. It reuses the direct optimizer and common fit assembly; fixed-grid EM
is unchanged. Adaptive direct MML uses `reltol`, and fixed-grid EM uses
`em_score_tol`; supplying the other engine's tolerance is rejected. Saved
metadata, replay, `summary()`/`print()`, conditional curves, result reports and
quadrature-order refits retain the actual engine and integration method.
Reports no longer describe a direct fit as EM or claim numerical success on
optimizer code alone. The shared fit class and public function names remain.

Adaptive two-family Wald bounds remain unavailable with a specific reason;
profile requests and posterior residual diagnostics reject this unsupported
scope. No fixed-grid covariance is relabelled as adaptive. New-Person scoring,
model ranking and ordinary fit/bias outputs remain unsupported. The next
mathematical decision is adaptive observed-information/integration qualification
and corresponding interval/residual contracts, before replaying the existing
coverage/design scenarios. Corrected-JML centering is a separate open issue.

**Verification.** The two new adaptive gradient/workflow files and existing
GMFRM public workflow, EM, quadrature-sensitivity, component-interval and GPCM
capability files pass. The capability file retains three `On CRAN` skips for
unrelated one-family reporting/design/signal-detection scenarios; those were
not rerun. New checks include saved-data likelihood identity, distinct fixed
and adaptive integrals, arbitrary owner names, unavailable profile/residual/
Person-scoring routes, conditional ggplot objects, output wording, tolerance
validation, RDS/replay and integration-preserving refits. Initial failures
were outdated error-message expectations and an expectation of missing profile
bounds where the existing profile contract correctly raises an error; no
numerical-reference assertion failed. Help generation, five changed Rd parses
and HTML guide rendering succeed. No whole-package suite, CRAN check or fresh
coverage simulation was run.

## September 30: adaptive observed information and component intervals

**Question and decision.** Can the adaptive two-family calibration use the
existing full-information log-Wald procedure without substituting fixed-node
curvature? The answer is yes for the explicitly experimental local calculation,
subject to the source-specific numerical checks below. Sampling coverage is
still unqualified; no new response sample was generated and no model was refit.
Adaptive constrained profiles and posterior residuals remain unavailable.

**Mathematical target.** Let U_i(theta) be the complete-response score in all
free calibration coordinates, and J_i(theta) its negative derivative. The
continuous observed information for Person i is
E[J_i(theta) | y_i] - Var[U_i(theta) | y_i]. This missing-information identity
is the method described by [Louis (1982)](https://doi.org/10.1111/j.2517-6161.1982.tb01203.x).
The independent reference assembles literal category logits, their first and
second derivatives, and these conditional moments. It calls no package response,
parameter-expansion, score or Hessian kernel. It includes the mixed derivatives
between locations/steps and log slopes, and the second derivatives of the
exponential slopes. Omitting these terms or treating nuisance calibration as
known would change the information target.

The production covariance reuses `compute_mml_parameter_covariance()` and the
existing moving-node gradient. It differentiates the finite adaptive likelihood,
including mode, scale and Jacobian changes. The independent Louis oracle at
high order approximates the continuous information. These need not coincide at
low order; the low-order moving-node gradient has its separate Richardson
checks. The oracle uses the shared integration coordinates/rule, so it is an
independent response/derivative/information implementation, not a wholly
independent quadrature algorithm. The previous all-Person continuous integral
checks remain the independent integration evidence.

**Fixed numerical procedure.** No fitting defaults, automatic retries or
acceptance thresholds change. Adaptive direct fits must pass their optimizer
and gradient convergence checks, and then the existing category, source-identity,
unregularized full-information and two-step Person-score rank checks. The fresh
maximum mean score is at most 1e-6; standardized Newton displacement is at most
.01 (with the existing caution above 1e-4); inverse residual is at most 1e-6.
At unchanged parameters, the fitted adaptive order q is compared with 2q-1.
Standardized score displacement and covariance change must each be at most .01.
Failures retain point estimates, missing bounds and reasons. The fixed-grid EM
route and its min(em_score_tol, 1e-6) requirement remain unchanged. Neither
method switches integration or refits automatically during `confint()`.

**Retained-data result.** `gmfrm-adaptive-information-20260930.R` reuses the
public adaptive-61 fit from the preceding section: 135 Persons, 1,370 ratings,
36 free coordinates and 12 component slopes. The prespecified oracle discrepancy
limits were 1e-4 for standardized information/covariance, 1e-5 for individual
scores and 1e-6 for total NLL. All were met:

| Quantity | Result |
| --- | ---: |
| Smallest independent observed-information eigenvalue | 7.845930 |
| Standardized information discrepancy, adaptive 61 / 121 | 2.9325e-6 / 2.9298e-6 |
| Standardized covariance discrepancy, adaptive 61 | 2.9325e-6 |
| Maximum Person-score discrepancy | 9.4680e-10 |
| Adaptive-61 versus reference total NLL difference | 2.0008e-8 |
| Local score rank / free dimension | 36 / 36 |
| Standardized Newton displacement | 2.4722e-5 |
| Adaptive 61-to-121 standardized score displacement | 8.3116e-8 |
| Adaptive 61-to-121 standardized covariance change | 3.1574e-7 |
| Available experimental component intervals | 12 / 12 |

The audit took 149.302 seconds in the recorded local environment. Its script,
input/source hashes, independent matrices, scores, numerical checks, result
object and session information are retained in
`validation-results/gmfrm-adaptive-information-20260930/`. Every requested
component is reported. This empirical result does not establish sampling bias,
coverage, a unique global solution or suitability for rater feedback.

**Output and scope.** `confint(fit)` and integration-order refits now retain
adaptive log-Wald intervals, owner/level identity and engine/integration metadata
through tables, plots, reports and saved exports. Round-trip intervals and
report text are identical. The profile entry point explicitly refuses adaptive
two-family fits before entering the fixed-grid constrained evaluator. Curves
remain without intervals, and ordinary diagnostics, model ranking and portable
two-family scoring are unchanged. README, capability/help, guide, NEWS and the
active plans describe the same scope.

**Verification.** The seven targeted files (adaptive gradient/workflow, existing
GMFRM public workflow, quadrature sensitivity, slope intervals, capability matrix
and fixed-grid joint profiles) pass 585 assertions without failures or skips.
They include binary/four-category information references, renamed/overlapping
owner levels, nonconvergence, mismatched likelihood rejection, a converged
adaptive-3 fit rejected by the quadrature check, cross-family covariance and
plot/export/reopen identity. The initial run had one test-only failure: it
assumed the shared label sorted first in both renamed facets. The corrected
assertion matches the owner and level rather than their row positions.
No production calculation or tolerance was changed to pass that assertion.
The logs and per-file results are retained beside the audit.

`devtools::document()` completed; the six changed Rd files parse and the GPCM
guide renders to HTML in CRAN mode. This rendering is not fresh execution of
its long statistical examples. `git diff --check` passes. Unaffected G/D, MI,
feedback and JML studies were read and reused, not rerun. No full package check,
independent coverage study, remote CI, commit or publication was performed.

## September 30: adaptive posterior residuals

**Question and implemented target.** Can a saved adaptive two-family fit
describe its observed ratings without reverting to fixed-grid integration or
an EAP plug-in? `mfrm_response_diagnostics()` now integrates a replicate rating's
category probability over the Person's complete same-data ability posterior,
with calibration fixed. The response equation, both slope owners, original
N(0,1) population and observed assignment are retained. Selecting output rows
changes the displayed/summarized set, not the conditioning record or posterior
grid. It neither adds unassigned ratings nor supplies held-out predictions.

**Procedure and failures.** Source reconstruction checks the original roster,
categories, facet/step/slope point estimates, model roles and integration
settings. Adaptive source likelihood and gradient are freshly evaluated using
the fitting objective and checked against the saved optimizer tolerance;
stored convergence flags alone cannot admit a stale source. This check does
not require a covariance or slope interval. Saved-result attachment validates
identity without repeating the source likelihood or any posterior integral.

The existing adaptive basis supplies mode/curvature nodes with prior density
ratio and Jacobian weights. The existing response evaluator supplies both
slope components. For q requested points, compare each category probability
with 2q+1 points, retain the higher-order result, and require maximum absolute
change at most 1e-7. The existing normalization, positive-variance and missing
result checks remain unchanged. Mixture variance includes both expected
conditional rating variance and variance of conditional means. A group with
an unavailable observed row retains its full denominator and missing indices.
No threshold was relaxed and no automatic order escalation/refit was added.

**Independent all-row check.** `gmfrm-adaptive-residuals-20260930.R` reused
`public-adaptive61.rds` from the calibration review: 135 Persons, 1,370 ratings
and four categories. The prespecified orders were 7, 61 and 121; no data were
simulated and no calibration was refit. The generalized continuous reference
in `helper-gmfrm-response.R` constructs literal logits from labelled saved
estimates, independently solves for the posterior mode/scale, and integrates
over the real line with `stats::integrate()`. It calls no package probability,
mode, parameter-expansion or GH function. All 135 Person references and all
1,370 rows were retained, including those failing the public order check.

| Requested / check order | Available ratings / 1,370 | Complete criterion/rater groups / 12 | Maximum probability error among returned rows | Maximum mean / mixture-variance error among returned rows |
| --- | ---: | ---: | ---: | ---: |
| Adaptive 7 / 15 | 205 | 0 | 4.2742e-9 | 4.2702e-9 / 4.0079e-9 |
| Adaptive 61 / 123 | 1,369 | 10 | 2.9824e-11 | 2.9790e-11 / 2.7205e-11 |
| Adaptive 121 / 243 | 1,370 | 12 | 9.8603e-14 | 2.9555e-13 / 4.1262e-13 |

Every returned-row error meets the prespecified 1e-8 reference criterion.
The 61-point unresolved row has an integration difference 2.6653e-7 and remains
unavailable; it was not silently repaired in that saved output. The maximum
121-to-243 difference is 1.3146e-10. At the finest order all rows are returned,
so its reported maximum includes the entire requested roster. These are
numerical checks on a retained case, not a universal integration-error bound.

**Separate integration from calibration.** At exactly the same adaptive-fit
parameters, a numerical fixed-grid 121/243 comparison passes only 251/1,370
rows. The 243-point probabilities differ from the continuous reference by as
much as .003544; the largest 121-to-243 change is .047080. The numerical input
selects a fixed grid for this comparison; no fitted object is relabelled or
admitted through a different public source check. The earlier 318/1,370 result
used a different, fixed-EM calibration and remains separate evidence.

| Raters per Person | Ratings | Adaptive 61 available | Adaptive 121 available | Fixed 121/243 passing, same calibration |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 445 | 445 | 445 | 237 |
| 2 | 270 | 269 | 270 | 14 |
| 6 | 60 | 60 | 60 | 0 |
| 7 | 595 | 595 | 595 | 0 |

This addresses the retained concentrated-posterior integration failure, while
preserving the low-order limitation. It does not test conditional independence,
population assumptions, rater competence, interval coverage or the effect of
giving feedback. These remain descriptive same-data residuals without an
expectation-one reference, fit cutoffs, p-values or calibration uncertainty.

**Workflow verification.** Adaptive workflow, fixed-grid GMFRM response,
corrected-JML response and ordinary/extended response regression files pass
(315 successful expectations). The public two-family workflow and capability
matrix files also pass (328 successful expectations): 643 across six files.
The two shared-rater RTMB tests skip because RTMB is unavailable in this R
library; their unchanged numerical branches are not newly qualified here.
Checks cover owner names with shared labels, exact source identity, altered
likelihood/parameters/gradient tolerance, selected-row invariance, independent
mixture moments, incomplete availability, both plot styles, ggplot conversion
and exported saved results. In a fresh R process, both the partial 61-point
and complete 121-point empirical results reconstruct their original rows,
groups, settings, plots and reports with fitting/gradient/integration functions
replaced by errors. No numerical recomputation occurs during replay.

`devtools::document()` completed, the seven cumulatively changed Rd files parse,
and the updated GPCM guide renders to HTML in CRAN mode. This does not rerun
its long statistical examples. `git diff --check` passes. The final test logs
and reviewed-source hashes accompany the numerical evidence.

The all-row audit took 129.306 seconds locally. Evidence, all Person references,
source/input hashes, exact executed R-source snapshots, partial/complete
diagnostics, saved results and fresh-process checks are in
`validation-results/gmfrm-adaptive-residuals-20260930/`. Later help-only edits
are distinguished from the hash-matched executed source. Existing evidence
was reused; no whole-package check, new sampling study or publication occurred.

## September 30: adaptive interval procedure feasibility

**Decision addressed.** Is the public neutral-start adaptive procedure ready
for a matched all-case replay and then independent coverage evaluation?
No: the bounded check found a poor flat solution which is not explained by
quadrature error. The current plan specifies the targets, all numerical gates,
starting values, existing optimizer polishing, conditional 31/61/121 refits,
failure denominators, Monte Carlo precision and consumer boundaries. That
protocol was saved before this run. No new response data were generated.

`gmfrm-adaptive-procedure-20260930.R` used the first two retained replicates in
each of the four September 28 design/SD conditions and the prespecified
near-zero-slope rotating-pair SD=.5 replicate 26. All calls used the public
neutral-start BFGS adaptive fit at order 31, maxit 500 per optimizer stage,
reltol 1e-10, and all-component model-based 95% intervals. Only a sole
quadrature-sensitivity failure could trigger the next order; no such failure
occurred. Numerical checks and public defaults were not changed to admit cases.

| Retained condition | Cases | Converged by raw-gradient check | Cases returning all nine intervals | Final refusal |
| --- | ---: | ---: | ---: | --- |
| Common Persons, SD=1 | 2 | 2 | 2 | None |
| Rotating pairs, SD=1 | 2 | 2 | 2 | None |
| Common Persons, SD=.5 | 2 | 2 | 2 | None |
| Rotating pairs, SD=.5, first two replicates | 2 | 2 | 1 | Replicate 1: joint information |
| Rotating pairs, SD=.5, prespecified replicate 26 | 1 | 1 | 0 | Joint information |

All seven returned sets pass the unchanged rank, stationarity, information and
31-versus-61 gates. Maximum standardized Newton displacement is 2.58e-5,
maximum quadrature score shift 7.42e-9 and covariance change 2.56e-8.
The two refused fits needed regularized near-singular information and retained
missing intervals. Every point, warning, optimizer stage and failure remains
saved; no case is replaced. Seven of nine is a feasibility disposition, not
an estimate of population availability from a representative random sample.

**Counterexample to the neutral-only procedure.** Replicate 1's adaptive
solution has component slopes from 3.14e-11 to 7.47e7. Compare the two saved
parameter vectors using the *same* adaptive objective and a literal continuous
integral over each complete Person record:

| Saved point | Continuous NLL | Adaptive-61 NLL | Maximum per-Person log-integral error |
| --- | ---: | ---: | ---: |
| Adaptive neutral start | 1558.971231708 | 1558.971231708 | 1.78e-15 |
| Retained fixed-grid EM parameters | 1471.593412080 | 1471.593412080 | 1.78e-15 |

The gap is 87.37782 NLL units in favor of a feasible retained point. The latter
row evaluates its parameters with accurate integration; it does not compare
two unmatched saved quadrature likelihoods or establish a global optimum.
The continuous-integral function is reused from the September 30 calibration
audit, calling no package likelihood/probability kernel. Both 31 and 61 nodes
give the same conclusion. More quadrature is not a remedy for this example.

**Separate starting-value diagnosis.** After completing the frozen nine-case
run, use the retained EM parameters as the start of the same adaptive BFGS
optimizer, with the same data, 31 points, 500 iterations and 1e-10 tolerance.
It reaches NLL 1471.593412033 and passes all nine component-interval checks.
Maximum log-slope change from the EM parameters is .0001719. This calculation
took 27.967 seconds for fitting and 57.541 for inference. It is an internal
diagnostic, not an available public initialization option or a new evaluated
retry rule. Its object explicitly has no neutral-start replay call, and its
starting vector/source are recorded. It does not overwrite the original failure
or add a success to the seven-of-nine count. Replicate 26's boundary/global
status remains unresolved; the refusal alone cannot classify it.

**Cost and decision.** The nine-case procedure took 552.207 elapsed seconds
with two computation workers; summed fitting and inference times were 531.235
and 528.869 seconds (CPU total 1,057.265 seconds). The eight ordinary cases
averaged 129.978 elapsed seconds each, range 114.825--186.385. At two workers,
simple extrapolation yields about 7.2 hours for 400 matched cases and 36.1 hours
for 2,000 independent cases. Using the observed minimum/maximum yields
6.4--10.4 and 31.9--51.8 hours respectively, not predictive intervals or hard
upper bounds. A small concurrent fixed-parameter comparison and ordinary
workstation activity were not isolated; these are planning measurements.
Actual grid retries, tails and a changed initialization rule can change cost.

Do not spend that budget on the neutral-only candidate. First fix and test a
data-based starting-value/solution-selection rule through the public route;
then refreeze the full procedure and re-estimate cost before either larger
study. The existing October 2 consultation checkpoint remains applicable.
The planned 500 independent datasets per condition would target roughly
one-percentage-point coverage MCSE if at least 475 intervals are returned;
it is not a completed study or evidence that earlier bias/undercoverage vanished.

**Verification and identity.** The runner checks pass/refinement/terminal/mixed
failure decisions. A mocked full-flow check additionally verifies actual call
controls, order progression and retention of a point when inference errors.
The first fresh-process cache check exposed a bookkeeping issue: pkgload
copies an identical compiled library to a different temporary path. The
current runner hashes that library under a stable label while retaining its
content hash. This changes no fitting or inference function. A two-process
cache test uses the retained objects as fixtures and requires replay without
fitting or changes to saved RDS files/timing. It is a cache test, not another
numerical run. Original numerical evidence and exact executed source remain
unchanged; future runs use the corrected runner and a new output directory.

Evidence is under `validation-results/gmfrm-adaptive-procedure-20260930/`:
the pre-execution protocol, input/source hashes and snapshots, nine saved
stage records, dispositions/timing, independent objective comparison and
separate starting-value diagnostic with scripts. No package estimator/API was
changed, no full package check or new coverage simulation was run, and no
commit or publication was performed. D1/D2 remain open.

## September 30: public adaptive initialization revision

**Problem and implementation.** A small terminal gradient did not distinguish
the earlier poor flat solution from a better likelihood solution. Public
two-family adaptive direct MML now optimizes from both the neutral vector and
a same-data fixed-grid EM vector. Every candidate uses the same requested
adaptive objective, optimizer and stopping controls. Select the lowest finite
terminal adaptive NLL; keep a better unfinished candidate's numerical status
instead of substituting a worse converged point. Exact ties retain neutral.
A known starting objective lower than every terminal point beyond roundoff
marks the selected result unresolved. This comparison is independent of truth,
interval outcomes and fixed-grid likelihood values, and does not establish a
global maximum.

`gpcm_mml_start=NULL` resolves to `"neutral_em"` only for this route;
`"neutral"` reproduces the previous public initialization. The EM seed uses
the requested quadrature, maxit outer iterations, 100 iterations per M-step
and per-Person score tolerance 1e-6. A finite unfinished EM vector can supply
a start. Each direct candidate separately retains its requested maxit/reltol
and existing gradient-polishing sequence. There is no new optimizer, changed
likelihood, automatic quadrature escalation or relaxed inference threshold.

`fit$opt$mml_initialization` retains every starting vector, adaptive starting
objective, optimizer result/stage history, error, warning, seed trace and cost.
Alternative failures are disclosed; an all-start failure condition carries
the same record. Summaries record the effective choice and selected start;
results/reports include the comparison table. The report also now correctly
labels adaptive direct fitting and its total gradient, rather than EM and
a per-Person score. Saved calls pin the effective policy, and quadrature
refits of older objects without the field retain neutral initialization.

**Fixed matched check.** Before executing the revised algorithm, the roadmap
recorded these rules and retained the same nine datasets, initial order 31,
maxit 500, reltol 1e-10, all-component 95% model intervals and conditional
31/61/121 quadrature rule. The runner additionally preserves the full error
condition if fitting fails. The original neutral-only evidence is unchanged;
the new run has a separate manifest, complete source snapshots and protocol.

**Outcome.** All nine cases completed at order 31; no conditional quadrature
retry occurred. All nine neutral candidates reproduce the previous saved
parameter vectors exactly (maximum absolute difference zero). The revised
selection retains neutral in four cases and the EM-derived candidate in five.
In seven ordinary cases the selected NLL is unchanged up to 7.60e-11 and all
nine component intervals remain available. The other two cases change as follows:

| Rotating-pair SD=.5 case | Previous neutral NLL | Revised selected NLL | Current numerical result | Component intervals |
| --- | ---: | ---: | --- | ---: |
| Replicate 1 | 1558.971231708 | 1471.593412040 | Total-gradient review fails | 0 / 9 |
| Prespecified replicate 26 | 1582.001695682 | 1484.228252536 | Joint information fails | 0 / 9 |

The literal continuous likelihood independently reproduces both new NLLs;
maximum per-Person log-integral error is 1.78e-15 at both 31 and 61 adaptive
nodes. Thus both improvements are improvements to the same accurately
integrated likelihood. They do not establish global optimality or coverage.
Every optimizer returns code zero, but only eight selected solutions pass
the gradient review. The runner's `Converged` column reflects the optimizer
flag; `matched-review.csv` separately records `GradientCheck` and the actual
gradient. Code zero alone is not the numerical convergence decision.

Replicate 1's selected slopes now range from .21247 to 1.28777. Its total
gradient is 1.5142e-4 against the unchanged 1e-4 threshold after all five
optimizer stages. The selected estimate is retained with a warning and
missing intervals; the full-information checks are not reached. The earlier
separate warm-start diagnostic had a different starting vector and passed;
it does not qualify this new public procedure's stopping result. Replicate 26
has slopes from .00135593 to 1.48323 and total gradient 7.29e-6, but its
unregularized full-information check fails. Its boundary/global-solution
status is still unresolved. Neither refusal was dropped, replaced by the
worse neutral solution, or repaired by changing thresholds. Interval
availability remains seven of nine, a bounded feasibility result rather than
a representative estimate of availability or sampling coverage.

**Cost and next decision.** The run took 1,016.773 elapsed seconds (16.95
minutes) on two workers, with 1,182.309 summed fitting seconds and 539.670
inference seconds; CPU total was 1,720.131 seconds. The eight ordinary cases
averaged 165.914 seconds, range 132.350--204.260. Replicate 26 took 394.665
seconds, including 343.334 for fitting, so the ordinary range is not an upper
bound on difficult cases. Small source/reporting checks and normal workstation
activity were not isolated from the run.

Simple ordinary-case two-worker projections are 9.2 hours for 400 matched
datasets and 46.1 hours for 2,000 independent datasets; minimum/maximum
ordinary-case scenarios are 7.4--11.3 and 36.8--56.7 hours. These omit the
frequency of difficult cases and unobserved quadrature retries and are not
predictive intervals. The combined mean projection is about 55.3 hours,
beyond the October 2 18:00 JST checkpoint if started at this review. Neither
large study was launched. The observable initialization repair is implemented;
the retained stationarity failure and weak-information case must inform the
next numerical/interval decision before spending the coverage-study budget.
The existing consultation rule continues to apply.

**Verification.** Selection tests retain a lower unfinished point, neutral
ties, seed/optimizer failures, all-start failure records and a starting point
better than all returned candidates. Four targeted test files account for
309 successful expectations after correction of one obsolete test assumption:
a short-run fixed/adaptive integral discrepancy is now checked on the explicit
neutral fit, because the new selected EM-derived point happens to agree.
The exact adaptive-likelihood equality and independent full-covariance and
response-moment checks remain unchanged. The corrected first workflow block
and selection tests were rerun; the other successful blocks were reused.
Both the initial failure log and successful correction log are preserved.

All nine saved fits reconstruct initialization tables, available/unavailable
intervals and reports in a fresh R process with fitting and adaptive-integration
functions replaced by errors. RDS round trips preserve the complete candidate
history and report text. A separate fresh-process runner-cache replay preserves
all nine result files and their original timing hashes. `devtools::document()`
completed, the three changed Rd files parse, and the updated GPCM guide renders
in CRAN mode without rerunning its long numerical examples. `git diff --check`
passes. No full package check or coverage qualification is claimed.

Evidence and executable checks are in
`validation-results/gmfrm-adaptive-start-20260930/`, including source/input
identity, the pre-execution protocol, all candidate/failure records, matched
comparison, literal-integral check, measured costs and test/replay logs.
The work changes the development source, not a published 0.2.4 artifact;
no commit or publication was performed. D1/D2 remain open.

## September 30: adaptive stationarity and weak-information review

**Decision addressed.** Separate a stalled numerical optimizer from an
unreliable information calculation before changing an interval threshold or
spending the matched-replay budget. Reuse the two refused fits from the
initialization review. The independent literal Louis implementation evaluates
all location, step and slope derivatives at both 31 and 61 adaptive nodes;
the package's moving-node gradient and existing guarded curvature proposal
are evaluated at the same saved points. No response data are generated.

| Saved rotating-pair SD=.5 point | Raw total gradient | Largest discrepancy from independent gradient | Smallest / largest independent curvature | Standardized Newton displacement |
| --- | ---: | ---: | ---: | ---: |
| Replicate 1 | 1.51422e-4 | 1.32e-14 | .985254 / 256.060 | .000115916 |
| Replicate 26 | 7.28836e-6 | 1.05e-14 | 6.81342e-8 / 218.112 | .0279766 |

At both points the literal marginal likelihood agrees within 2.28e-13 and
the maximum entrywise 31-to-61 information change is 5.69e-14. Replicate 1
has well-conditioned positive information (reciprocal condition .002104).
Its derivative is correct but has not met the package's raw-gradient rule.
This is consistent with the relative-objective stopping rule of
[`stats::optim()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html)
preceding the required gradient accuracy. Reusing the existing guarded Newton
proposal lowers NLL from 1471.593412039654 to 1471.59341203293 and the gradient
to 2.06e-8, without changing the objective or tolerance. This diagnosis supplies
a reason to extend an existing repair, rather than just relaxing acceptance.

Replicate 26 is different. Its independently positive information is extremely
weak (reciprocal condition 2.17e-10). The weakest direction is dominated by
rater r4's step and location coordinates, coupled to its .00135593 slope;
the fitted step coordinate is -222.839. The package's Richardson refinement
passes relative curvature change (5.998e-6 versus 1e-3) and inverse residual
(1.026e-10 versus 1e-6), but standardized displacement .0279765 exceeds the
unchanged 1e-4 weak-information threshold. The guarded proposal is rejected.
A small raw gradient therefore does not justify this point's local Wald
covariance. The refusal is supported by independently stable weak curvature
and inadequate stationarity in that metric, not demonstrated quadrature or
derivative error. A global optimum or a true boundary has still not been proved.
The two-point numerical diagnosis took 70.631 seconds on two workers.

**Public repair and frozen replay.** Extend the existing single curvature
restart to adaptive GPCM with a fixed population and at most 64 free
parameters, after the ordinary polish ladder still ends with
`code_zero_large_gradient`. This includes the one-family and two-family
adaptive direct routes. Other existing routes keep their previous behavior.
The same optimizer and iteration ceiling follow the proposal; positive
well-conditioned curvature, gradient improvement and no objective increase
beyond roundoff remain required. Failed proposals and every stage remain
visible. No new optimizer, dependency, user control, likelihood, information
matrix or acceptance threshold is introduced.

Weak-information refusals now report the actual curvature-change, inverse
residual and standardized-displacement values with their unchanged limits.
This makes the reason reviewable in interval checks and saved reports.
`gpcm_mml_start="neutral"` still selects neutral-only initialization; exact
historical optimizer behavior requires its source version, because numerical
repairs also apply to that starting policy.

The pre-execution protocol selects three refits from saved optimizer states:
001-common_persons-1, 001-rotating_pairs-0.5 and 002-common_persons-1. Each has
an EM-derived adaptive candidate that can enter the added branch. Refitting
uses both original starts and the unchanged public 31/61/121 interval procedure,
maxit 500 and reltol 1e-10. None of the other six saved cases has a candidate
meeting the added branch condition; they retain their original fits and source
identity as reused evidence. Only replicate 26's interval calculation is
refreshed to verify the expanded refusal detail. This avoids repeating
unchanged optimization and does not silently relabel old runs as new executions.

**Repaired public result.** All three full public refits pass at order 31 and
return all nine component intervals. Both ordinary cases retain their NLLs
within 4.40e-11 while improving their selected total gradients to 2.90e-8
and 3.49e-8. Replicate 1's recorded sixth stage, `curvature_restart`, changes
its NLL from 1471.593412039654 to 1471.593412032933 and its total gradient
from 1.51422e-4 to 1.81924e-7. This is the actual post-restart optimizer result,
distinct from the preceding diagnostic proposal. All 22 score directions and
the full unregularized information checks pass. Standardized displacement is
2.13e-8; the 31/61 score shift and covariance change are 3.73e-10 and 1.24e-12.
No quadrature retry, information regularization or threshold change occurs.

At this repaired point the independent Louis calculation reproduces the
gradient (1.81924e-7) and marginal likelihood. Its full nuisance-adjusted
log-slope covariance agrees with the public covariance to relative matrix
error 6.46e-7; the largest component log-SE difference is 1.99e-7. The
reference uses a literal constrained three-by-six log-slope Jacobian, retaining
all nuisance coordinates, rather than inverting a slope-only block.

Combined with the six explicitly reused fits, the disposition is now eight
of nine cases returning all component intervals, versus seven previously.
The refreshed replicate 26 still returns no intervals and now states the
three measured refinement/inversion/displacement values and limits. Its
original fit and optimizer history are preserved. This is a bounded numerical
repair and refusal check; eight of nine is not a representative availability
estimate, a coverage result or proof that all finite solutions have been found.

**Verification and cost.** The curvature, weak-information, ordinary adaptive,
two-family adaptive and start-selection test files pass (330 unique successful
expectations across the two targeted runs). Tests cover the new successful
restart, rejected indefinite proposals, excluded estimated-population/JML/
looser-control routes, existing raw-gradient checks, independent covariance,
arbitrary owner names, export and reopening. All nine current saved-output
paths preserve interval checks, candidate histories and report text in a fresh
R process with fitting, covariance and adaptive-integration functions replaced
by errors. The weak refusal's numeric explanation survives that round trip.

Three refits plus their interval calculations took 439.392 elapsed seconds
on two workers; the separate weak-information interval refresh took 48.038
seconds. Affected cases cost 208.005, 225.634 and 230.629 seconds respectively.
The tests and small documentation checks ran concurrently; these are planning
measurements, not isolated performance benchmarks. Combining their updated
costs with the five unchanged ordinary-case records gives a mean of 184.478
seconds and range 133.827--230.629. The separately retained difficult case
took 394.665 seconds and is not bounded by that ordinary range.

On that mixed timing basis, simple two-worker scenarios are 10.2 hours for
the 400-case matched replay and 51.2 hours for 2,000 independent cases;
ordinary minimum/maximum scenarios are 7.4--12.8 and 37.2--64.1 hours. These
are not predictive intervals and omit the frequency of difficult cases and
quadrature retries. No large study has started. The now-fixed numerical
procedure can proceed to the prespecified all-case matched comparison, retaining
all failures and paired denominators, before deciding whether independent
coverage work is warranted. Apply the October 2 consultation rule to the
actual launch time and workload; the combined mean scenario is about 61.5 hours.

`devtools::document()` and Rd parsing pass; the GPCM guide renders in CRAN
mode, without executing its long statistical examples. `git diff --check`
passes. The compiled library matches the earlier archived binary. Evidence
is in `validation-results/gmfrm-adaptive-stationarity-20260930/`: pre-change
diagnosis/source, the frozen replay protocol, post-change source/input hashes,
three new fit/interval records, explicit reuse identities, refreshed refusal,
independent verification and test/replay logs. No full package check, new
sampling study, release or commit is claimed. D1/D2 remain open.

## September 30 matched adaptive replay launch

The next prespecified comparison is now running on all 400 retained September
28 datasets. It started at **21:42:49 JST on September 30**, using two workers
and the frozen `neutral_em` procedure, with the existing 31/61/121 retry rule
and unchanged inference gates. Nine verified records are reused with their
actual source identities; the remaining 391 datasets are refitted. No new
observations, seeds, acceptance thresholds or optimizer choices were introduced.

The principal comparator is the saved revised fixed-grid EM procedure. Before
launch all 400 pairs were checked for identical observations, truth, seeds and
fixed-grid fits; the original strict and revised saved interval outputs gave
95/400 and 310/400 available datasets respectively. Both historical arms remain
in the comparison, under separate names. The adaptive arm is not summarized
until all 400 records are complete. Dataset-level failures remain observations;
they do not trigger replacement data or a change in the procedure.

The repository-only runner is
`inst/validation/gmfrm-adaptive-matched-20260930.R`. It snapshots the package
source, compiled library, procedure and aggregation code; hashes both historical
input sets and all prior reused evidence; and saves each result atomically.
Each record retains all quadrature attempts, both start histories, errors,
warnings and original timings. Resume checks the manifest and frozen inputs;
a process lock prevents duplicate runs. Computation runs as a detached local
process, with an idle-sleep assertion only for its lifetime. This is execution
of the present study, not a scheduled future review or reminder.

The frozen protocol specifies log-scale bias/RMSE/empirical SD separately among
all numerically qualified finite points and among interval-returned points.
It also specifies estimated variance, interval width, interval availability,
conditional coverage, and returned-and-covered frequency for each of nine
components in each condition. Unavailable intervals have missing conditional
coverage. Exact binomial Monte Carlo intervals are provided per arm; paired
differences use the dataset as the unit, with a paired delta-method MCSE for
conditional ratios with differing denominators. A separate both-available
contrast is labelled explicitly. The four conditions share random numbers
within each replicate and are not pooled as independent evidence.

Preflight checks exercised missing intervals, finite unfinished estimates,
zero-return denominators, the analytic paired-ratio MCSE example, source and
resume mismatches, and atomic saved-record handling. A temporary 400-record
accounting fixture using the same saved procedure in both comparison arms
reproduced both historical totals and returned exactly zero paired differences
and MCSEs; aggregation refused an incomplete 399-record fixture. Those fixture
files were deleted and are not adaptive study results. No package algorithm
changed in this execution step, so the preceding targeted numerical tests are
reused rather than rerunning the full suite.

Evidence and live results are in
`validation-results/gmfrm-adaptive-matched-20260930/`: `manifest.rds`, `source/`,
`protocol-before-execution.md`, `check-aggregation.R`, `preflight.log`, the nine
explicitly reused records, `launch.json` and `execution.log`. The frozen runner
will write `rows.csv`, `stages.csv`, `summaries.csv`, `paired.csv` and
`summary.rds` after all 400 records exist. At launch the remaining workload is
about 10 hours, with ordinary-case scenarios about 7--13 hours; difficult fits
and quadrature retries can extend it. This is before the October 2 18:00 JST
consultation checkpoint on current evidence. The matched replay is informed
by development on retained examples and cannot supply independent qualification
of nominal coverage. The 2,000-case independent study has not started; D1/D2
remain open pending evidence and review.

By 21:46:08 JST the first two new jobs (replicate 3, common Persons and
rotating pairs at SD=1) had both completed and been saved, in 198.334 and
153.291 seconds. Both ended at order 31 with all nine intervals. Including
the nine reused records, 11/400 records were complete at that startup check.
This verifies execution and persistence, not overall availability or coverage;
the remaining jobs continue under the same frozen procedure.

## October 1 completed matched replay and independent-study decision

The completed results in this section stand. Its subsequent 4 x 500 launch
proposal is now held; the [revised scenario design](#october-1-revised-scenario-design)
below records the current recommendation after the user's scope review.

All 400 retained datasets completed at **11:43:25 JST on October 1**; the
summary was saved at 11:43:30. The frozen source, 818 input hashes, manifest
identity and 400 saved result hashes were verified. A separate read-only
recalculation from `rows.csv` reproduced all 108 condition/component/arm
summaries, including both point-estimate denominators, exact binomial bounds,
estimated log variance and interval width. No additional fitting or seed
generation was needed for this assessment. Evidence remains in
`validation-results/gmfrm-adaptive-matched-20260930/`, with the review script
and verification output saved alongside the original summaries.

**Question answered:** did the frozen numerical procedure recover intervals
lost by fixed-grid EM, and is there a remaining reason to revise it before
independent evaluation? The principal comparison is adaptive minus revised
fixed-grid EM on identical observations, rather than a new interval formula.
All nine intervals were returned for 95/400 historical strict-EM datasets,
310/400 revised-EM datasets and **399/400 adaptive datasets**. All 400 adaptive
point estimates met the specified numerical qualification rules. All final
fits used order 31; the prescribed source/information/integration checks still
applied. No outer fit-order retry was requested.

The 89 additional returned datasets are all in the common-Person, SD=1
condition (11/100 to 100/100). Its paired availability difference is .89,
MCSE .03145. Availability is unchanged for the other three conditions. Among
datasets with intervals from both procedures, every component's coverage
indicator is unchanged; the largest absolute log-estimate difference is
.0022303 and the largest relative log-SE change is .0042879. Across all 399
adaptive interval-returning datasets, the largest absolute log-estimate
change from revised EM is .0104607. This supports recovery of numerical
availability, not a claim that the Wald approximation's coverage improved.

**Remaining statistical evidence:** the table shows ranges over nine distinct
components within each condition, not pooled independent replications. Bias
and RMSE use all 100 numerically qualified points. The SE ratio is
`sqrt(mean(LogSE^2)) / sd(LogEstimate)` on the same interval-returned subset;
width is the mean width on the log-slope scale. Each coverage denominator is
100, except rotating pairs at SD=.5, where it is 99.

| Design; ability SD | Returned datasets | Log bias | Log RMSE | RMS model SE / empirical SD | Mean log width | Conditional coverage |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Common Persons; 1 | 100/100 | -.0581 to .0169 | .1164–.1997 | .850–1.158 | .432–.793 | .90–.98 |
| Rotating pairs; 1 | 100/100 | -.0300 to .0108 | .1056–.2187 | .890–1.111 | .459–.835 | .93–.98 |
| Common Persons; .5 | 100/100 | -.1107 to .0200 | .1310–.3399 | .968–1.094 | .523–1.285 | .93–1.00 |
| Rotating pairs; .5 | 99/100 | -.1001 to .0169 | .1517–.6701 | .872–1.070 | .566–1.456 | .9091–.9596 |

Three observations constrain the next decision:

* Common Persons, SD=1, Task t3 has negligible mean log bias (-.00206),
  empirical SD .12982 versus RMS model SE .11034, and 90/100 coverage.
  Six intervals lie above truth and four below. Its exact 95% Monte Carlo
  coverage interval is [.8238, .9510]. Mean bias alone does not explain this
  result; local variance calibration or tail shape warrants independent
  evaluation. The observed .850 SE ratio is not a proven population constant.
* Rotating pairs, SD=.5, Task t1 has bias .01694, SE ratio .8718 and 90/99
  coverage; eight intervals lie above truth and one below. Conversely, common
  Persons at SD=.5, Rater r3 has bias -.11071 (MCSE .03230) but 99/100
  coverage. Thus neither near-zero mean bias nor apparent nominal coverage
  alone establishes adequate inference. No empirical bias correction or
  SE multiplier is estimated from these diagnostic findings.
* `026-rotating_pairs-0.5.rds` remains the single joint-information refusal.
  Its Rater r4 slope is about .001356, versus truth .525. For that component,
  all-point empirical SD/RMSE are .6659/.6701, while the returned subset has
  .3069/.3081. Its bias changes from -.1001 to -.0409 when conditioning on
  interval return. The missing interval is preserved, and the unstable point
  remains in the all-point summary. Counting only returned intervals would
  conceal this instability; forcing a covariance would not repair it.

**Decision:** retain the unchanged adaptive fitting/information/log-Wald
procedure as the candidate for independent evaluation, with experimental
status and the current refusal policy. The matched evidence does not isolate
a new calculation error or justify a particular bias/tail correction. It
does identify finite-sample concerns that an independent evaluation may
confirm or fail to resolve. The proposed evaluation is the already specified
four correctly specified conditions, 500 new datasets per condition, seed
family `93020000 + replicate`. The nine components and shared-random-number
conditions are not extra replications. No location, curve, simultaneous,
new-Person or population-transport claim follows from component coverage.

The original practical margins remain unchanged: availability >=.95 and its
exact 95% lower bound >=.90; the exact 95% conditional-coverage interval must
be contained in [.92,.98] for each proposed limited claim. Failure or an
inconclusive result does not trigger automatic extra replications, a changed
threshold, or a switch to a different interval method. Report adverse bias,
widths, SE calibration and failed fits alongside any margin decision.

**Revised compute decision:** the 391 new fits took 14.010 elapsed hours on
two workers. All 400 records contain 28.475 worker-hours of measured fit and
inference time. Extrapolating those measurements gives **71.2–71.7 elapsed
hours** for 2,000 new fits at two workers (about 142.4 worker-hours); this is
a planning estimate, not a runtime confidence interval. Difficult new fits,
additional quadrature orders, other workloads and suspension can extend it.
It supersedes the earlier 36–51-hour projections from selected examples.
The interpretable result would fall after October 2 at 18:00 JST, so the
existing user consultation rule applies before launch.

The repository-only `gmfrm-adaptive-independent-20261001.R` runner prepares
new inputs and copies the matched replay's frozen package/procedure exactly.
It reuses the existing generator, capture, numerical gates, atomic records
and summary formulas. It records every fit/inference stage, guards resume by
source/input/manifest identity, and refuses aggregation before all 2,000
records exist. Its preflight uses retained results and accounting fixtures;
no new fitting is required for readiness checks. The initial preparation
stopped because the original generator script's recorded whole-file hash
differed from the current file. The original script was not archived, so the
exact textual change cannot be established. The complete generation plan and
all 400 historical observations/truth tables/seeds were then reproduced
exactly before freezing the current generator; both file hashes and that
verification are retained in the new manifest. No fitting or inference
threshold changed. Preparation does not launch
the study. **Historical launch status:** this proposal was initially held for
a compute/deadline decision. The later October 1 instruction below supersedes
that rationale: the deadline is relaxed, but all new computation is held for
scientific redesign. Corrected-JML sampling remains paused and D1 remains open.

## October 1 revised scenario design

**Historical proposal, now held:** the later
[small-cohort review](#october-1-small-cohort-and-facet-structure-review)
supersedes this section's recommendation to execute the 24-condition design.
Its completed evidence and frozen inputs remain intact.

**Decision at preparation:** hold the unexecuted 4 x 500 confirmation proposal.
Its four N=240 cells can support only a narrow conditional claim. Repeating
them more precisely cannot establish how performance changes with sample size,
ratings per rater or rating allocation. Retain the unchanged adaptive/log-Wald
procedure as the candidate, but first examine its domain through the staged
design below. This supersedes the preceding launch recommendation, not the
completed matched evidence or the prepared proposal's immutable files.

**Main question:** under a correctly specified two-family GPCM, when does the
current procedure supply usable and appropriately calibrated slope intervals,
and which practical designs reveal failures? In particular, does the Task-SE
shortfall at N=240 diminish as information increases, and do weak slopes or
concentrated ratings produce point estimates whose instability is hidden by
conditioning on interval return? Accurate numerical integration is necessary
but does not answer these sampling questions.

### Conditions and their roles

The core is a complete 3 x 2 x 2 design: **N=120, 240, 480; ability SD=.5, 1;
common-Person and rotating-pair rosters**. This permits sample-size trends and
their interaction with ability spread and roster to be inspected, instead of
treating one-factor changes as proof of general robustness. All core cells
have three tasks, six raters and scores 0:2. The common-Person roster assigns
20% of Persons to all six raters and the rest to one rater, equally distributed;
the rotating roster assigns each Person to an adjacent pair on a six-rater
ring. Both have 2N Person-rater pairs, 6N scores, and N/3 Persons per rater.
The original N=240 four cells contribute their existing 100 records each.

Twelve further conditions probe specific limits. Except as stated, they use
N=240, SD=1, three tasks, six raters and scores 0:2. Their number is a scoped
set of questions, not a claim that 24 conditions exhaust the model's domain.

| Added conditions | Exact change and comparator | Question / interpretation limit |
| --- | --- | --- |
| 2 small-sample | N=60 under both existing rosters; compare the same roster at N=120/240/480 and SD=1. | Where do availability and point stability deteriorate? N=60 x SD=.5 is not covered. |
| 2 wider-population | SD=1.5 under both existing rosters at N=240; compare SD=.5/1. | Does increasing ability spread change SE calibration or tails? This is not a nonnormal-population condition. |
| 1 more tasks | Six tasks, rotating pairs; duplicate the original three task parameter settings as three additional levels. | Does more information per Person help? Scores double from 1,440 to 2,880; this is not cost matched. |
| 1 more raters | Twelve raters, rotating pairs; duplicate the original six rater parameter settings. | What happens with more estimated rater levels and 40 rather than 80 Persons per rater, at the same 1,440 scores? The ring topology changes too. |
| 1 unequal exposure | Adjacent pair group sizes 70/50/40/30/20/30 instead of 40 each. Rater Person counts become 100/120/90/70/50/50. | How does unequal information affect individual raters when every Person still has two raters and the total cost is unchanged? |
| 1 weak bridge | Six Persons rated by all six raters; within each of two three-rater groups, 105 Persons get pairs and 12 get one rater. | With 80 Persons per rater and 1,440 scores preserved, what happens when only six Persons connect the groups? Person exposure also changes; do not call this an isolated graph effect or assume graph disconnection alone proves MML nonidentification. |
| 1 weak slope | Rater r4's generating slope is .2 rather than 1.05; rotating roster. | Is near-zero estimated slope behavior confined to chance extremes, or systematic under weak discrimination? No replacement of failed draws. |
| 1 rare top category | Add +2.5 to all rater locations; retain the full 0:2 ladder and rotating roster. | How does poor targeting / sparse upper-category support affect output? The shift is fixed before draws; do not condition generation on achieving a chosen observed category count. |
| 2 writing-roster templates | 135 Persons, five tasks, seven observed raters, scores 0:3, 274 Person-rater pairs / 1,370 scores. Original exposure versus redistribution preserving exact per-rater counts. | Does concentrating repeated ratings on a few Persons matter? Original Person degrees are 89 x 1, 27 x 2, 2 x 6 and 17 x 7; control degrees are 131 x 2 and 4 x 3. This is a synthetic experiment on an empirical roster, not validation of the empirical responses. |

The writing template is the retained `sirt-data.ratings1.rds`, hash
`45cdfdc65f8ab0c5c86878fa043bdf0b`; observed rater counts are
41/37/37/41/38/41/39. Only its Person-rater incidence is used. The original
absent cells are not asserted to be known planned nonassignment. Five-task
locations span [-.4,.4], log slopes [-.2,.2]; seven-rater locations span
[-.3,.3], slopes [.75,1.25], and centered step vectors are (-h,0,h), with
h spanning [.45,.7]. These are declared synthetic parameters, not empirical
estimates treated as truth. The redistributed roster is a fixed allocation
algorithm preserving column totals, not a random sample from every feasible
roster or an asserted optimal allocation.
It changes Person exposure and pairwise overlap together; interpret it as a
comparison of allocation designs, not an isolated effect of one concentration
index.

All other parameters retain the original baseline values. The data generator
uses the literal adjacent-category recursion. Persons have theta=SD*z,
z~N(0,1), with allocation independent of z and conditionally independent
responses. On the fitted fixed-N(0,1) scale, task slopes are unchanged,
rater slopes are multiplied by SD, and locations/steps are divided by SD.
Thus different SDs do not imply identical identified slope truths. Centered
task locations, geometric-mean-one task slopes and centered rater steps are
preserved, including the larger facet/category conditions. Task and rater
parameters are fixed across repetitions within a condition; only Persons,
responses and the specified ability-independent allocation are randomized.
The ability-SD contrasts do not vary the distribution of rater severity or
task difficulty. The study therefore does not estimate performance averaged
over a population of randomly sampled tasks or raters.

Nonnormal populations, ability-associated allocation, score-dependent missing
ratings, Person-by-performance dependence, category compression and method
selection are **outside this first screen**. They remain relevant scope limits;
under misspecification a matching estimand must be specified before labeling
an interval as covering a parameter. The targeted contrasts above do not test
all interactions among adverse conditions. No slope-coverage result qualifies
location, curve, new-Person, simultaneous or consequential feedback claims.

### Replication, accounting and decisions

Use two separately budgeted screening blocks, not 500 repetitions in every
cell. **Core:** 100 per condition, reusing 400 saved N=240 records and adding
800 at N=120/480. **Targeted:** 100 in each of the 12 declared conditions,
adding 1,200. Completing both would therefore use 2,400 records, of which
2,000 are new. The equality with the old proposal's new-fit count is incidental:
these have a different scientific purpose, allocation and compute cost.
The retained four cells were used during development; the mixed screen must
not be described as independent confirmation. No new baseline rerun is needed
merely to make all records share the same provenance label.

At coverage .95, 100 returned intervals have MCSE .02179; 95/100 has exact
95% Monte Carlo bounds [.8872,.9836]. This can reveal large problems and
patterns, but cannot settle a 3-percentage-point equivalence margin. There is
no screen-level "coverage qualified" flag, and no absence-of-significance
claim of acceptable calibration. Interpret the size and precision of bias,
RMSE, empirical/model SE differences, width and failures jointly. New cells
are not guaranteed to reveal an effect at this replication count.

Preserve every attempted draw, warning, fit/inference error, check refusal,
quadrature retry and stage time. Report each task/rater component separately
(the component count varies with the scenario). Bias/RMSE and tail summaries
use all numerically qualified points, with the interval-returned subset shown
separately. Compare empirical SD to RMS model SE on the same returned subset.
Report conditional coverage and above/below-truth misses among returned
intervals, as well as availability and returned-and-covered probability over
all attempts; a withheld interval is not observed conditional noncoverage.
Keep category frequencies, rater exposure and overlap with failures rather
than pooling them into a single success rate. No pooling of components or
conditions creates more independent replications.

New screen seeds are `93100000 + 1000 * SeedGroup + replicate`, with fixed
scenario IDs in `gmfrm_design_plan()`. New conditions use independent streams,
except the two writing templates, which share latent Persons and potential
responses and require paired comparisons. The four historical N=240 cells
also retain their original shared random numbers; use paired accounting
within those cells and independent accounting against new cells. Replicates
are independent within each cell. The original 92810000 and held 93020000
seed families remain separate.

If a numerical defect calls for a procedure change, retain all results and
identify the change; do not patch the method halfway through a fixed study or
silently replace failed datasets. Choose any eventual confirmatory domain
from the intended user claim, keeping adverse screen evidence visible; do not
select only favorable cells and generalize to the omitted conditions. Freeze
the domain, method, seeds, margins and sample size before independent
confirmation. The number and scope of confirmation cells are intentionally
not predetermined by the exploratory screen's 24-cell count.

The held confirmation rule itself also needs a realistic power discussion.
With every interval returned and true coverage .95, the existing requirement
that the exact 95% binomial interval lie within [.92,.98] has the following
operating characteristics. These are exact binomial calculations, not a
simulation of fitted models or joint assurance over all components.

| Returned intervals | MCSE at .95 | Covered-count values satisfying the margin | Probability of satisfying it at true .95 |
| ---: | ---: | --- | ---: |
| 100 | .02179 | None | 0 |
| 250 | .01378 | 239 | .1106 |
| 500 | .00975 | 472–482 | .7124 |
| 1,000 | .00689 | 937–970 | .9709 |

Unavailable intervals reduce these denominators, and the separate availability
rule can also fail. Even 1,000 does not ensure every correlated component
passes; do not multiply pointwise probabilities as if components were
independent. This is a reason to match confirmation size to a concrete claim
and decision risk, not an instruction to double all runs or relax a failed
margin. Planning follows the question/design/estimand/performance/Monte Carlo
precision distinction in
[Morris, White and Crowther (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6492164/);
the exact intervals use [R's binom.test](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/binom.test.html).

### Execution boundary

`gmfrm-design-screen-20261001.R` generates the 24 scenarios and performs a
no-fit preflight: roster counts, response ladder, seed reproduction, parameter
constraints, old three-category equation, identification-scale equivalence,
and agreement with the package probability kernel. The writing pair is checked
for identical latent values/truth, preserved per-rater totals and identical
potential responses on shared cells. It has no fitting command. This makes
the proposed generating design reviewable; it does not make a full sampling
runner ready or establish coverage.

A bounded timing pilot uses the **eight new core cells, one draw each**, before
any long-run compute decision. It uses the matched replay's frozen package,
binary and exact procedure (31/61/121 quadrature rule, neutral-EM start,
maxit=500, reltol=1e-10, information checks, .95 model log-Wald intervals).
No new threshold or estimator is tuned. Keep these first draws as screen
replicate 1 if the same screen is subsequently launched, retaining failures
as well as successes. Their timing is a rough planning input, not a coverage
result, runtime confidence interval or proof of successful recovery.

Before a complete core block, freeze its new inputs and runner and report
remaining cost using pilot and historical stage times, with a broad sensitivity
range for one-draw timing and tails. The repository-only
`gmfrm-core-screen-20261001.R` provides that core-only preparation and execution:
it generates 800 fixed inputs, retains the 400 existing adaptive row sets,
reuses all eight pilot results as replicate 1, and leaves 792 new fits. It
references the already frozen matched package/binary by checked hashes, copies
its own runner/generator, and checks source/input/manifest identities on load
and resume. It refuses a complete summary before every planned case exists.
Accounting fixtures exercise separation of the three sample sizes, the
retained refusal, entirely unavailable intervals and incomplete-run refusal;
they create no sampling evidence or coverage-qualification flag.

Before the targeted block, separately
verify the greater facet counts and four-category procedure: the old frozen
wrapper explicitly hardcodes `rating_max=2` and cannot be applied unchanged to
the writing cases. Preserve all other algorithm settings when parameterizing
the score ladder. Do not extend the old fixed-nine-component, four-condition
summary assertions to the expanded design without checking the denominators.
The old 71–72-hour estimate applies only to the old 4 x 500 mixture.

If the expected interpretable result is after **October 2 at 18:00 JST**,
consult the user before launching the long run, as required by the roadmap.
Neither a time cutoff nor partial results authorize reducing the declared
replication count. The two blocks can be scheduled separately for compute
reasons; report a block not run as unstudied, never as passed. Corrected-JML
sampling remains paused, and D1/D2 are still open.

**No-fit preflight and core timing completed October 1:** all 24 generating
conditions passed the roster, ladder, parameter-constraint, reproducibility
and scale checks using two seeds per condition. Maximum probability-kernel
discrepancy was 4.44e-16 and identification-scale discrepancy 3.33e-16. The
eight fixed core timing cases finished at **13:39:34 JST**, using the matched
replay's 446 frozen package/procedure files and checked loaded binary. All
eight returned numerically qualified points and all nine component intervals,
with final fitting order 31 and no outer fit-order retries. This establishes
execution for these examples, not their coverage. Source/input/result and
manifest identities were checked. Evidence is in
`validation-results/gmfrm-design-screen-20261001/`, including the preflight,
binomial planning calculation and the eight `core-pilot/` records.

| Core timing condition | N=120 fit + inference seconds | N=480 fit + inference seconds |
| --- | ---: | ---: |
| Common Persons, SD=.5 | 139.890 | 685.864 |
| Common Persons, SD=1 | 215.786 | 1,013.719 |
| Rotating pairs, SD=.5 | 75.116 | 417.509 |
| Rotating pairs, SD=1 | 158.067 | 797.975 |

The pilot took 35.623 elapsed minutes and .9733 worker-hours. For the remaining
99 repetitions in each of eight cells (**792 fits**), extrapolating measured
stage times at two busy workers gives **48.18 hours**. Applying time strictly
proportional to N to the older 400-case measurements instead gives **35.24
hours**. These are different planning assumptions, not confidence limits.
Half/double the new measured per-case times give 24.09/96.36 hours as explicit
sensitivity scenarios, not probability bounds. One draw per cell cannot
estimate its runtime distribution; the old N=240 study itself had a median
181 seconds and maximum 1,941 seconds per case. Additional difficult fits,
retries, suspension or other workloads may extend the run. Multiplying the
small pilot's elapsed time by 99 would also preserve its unusually large
end-of-run load imbalance; the stage-time estimate assumes both workers stay
busy across the full block, apart from the final jobs.

Both central planning assumptions put interpretable completion after the
original October 2 18:00 checkpoint. The user subsequently allowed completion
beyond that time and explicitly requested **no further computation while the
scientific design is reconsidered**. Keep the remaining core computation on
hold for that reason. Preserve the eight pilot cases; reuse them if their exact
conditions/procedure remain relevant, rather than rerunning or replacing them
based on their successful interval output.
The held 2,000-fit confirmation proposal and the targeted 1,200-fit block
have not been launched. No public estimator, CI threshold, help claim or
release qualification changed in this redesign.

The core-only proposal is now prepared in
`validation-results/gmfrm-core-screen-20261001/`: 800 frozen input files, the
checked 400-case baseline table, eight reused pilot records, frozen runner and
generator, bound execution protocol, and `readiness.rds` / `readiness.log`.
A fresh R process loaded the frozen package/binary and correctly refused a
complete summary with only 8/800 new-case records. The initial preparation was
replaced before any new fitting to include the protocol itself in the source
identity check; all 800 input hashes stayed identical, and the initial copy is
preserved at `/tmp/mfrmr-core-preparation-before-protocol-hash-20261001`.
There is no active core-study run. Its archived entry point remains
`validation-results/gmfrm-core-screen-20261001/source/runner.R` in the development
root. **It is not the next launch recommendation.** The deadline relaxation
does not authorize this proposal, another timing pilot, or generation of a new
input batch. Preserve the immutable preparation; do not overwrite its protocol
with the revised scientific scope below.

## October 1 small-cohort and facet-structure review

**Current instruction and status:** mfrmr is a general-purpose R package.
Prioritize substantive adequacy over the October 2 18:00 JST checkpoint. The
user requires both the previously studied larger samples and the neglected
20–60-Person range, with explicit consideration of facet count and levels per
facet. Small-cohort priority expands the evaluation; it does not replace the
medium/large-sample scope. Do not run new estimation, simulation, timing or data-generation
work during this design review. The prepared 2,000-case confirmation and
800-input core proposal are held; 792 core cases remain unrun. This review
uses source inspection, retained evidence and literature only. No estimator,
public capability, inference threshold or release qualification changes here.

### Correct the question before choosing conditions

The preceding design was anchored to the existing N=240, Task-by-Rater study
and its slope-interval defect. Making N=120/240/480 the core and N=60 a targeted
stress condition did not address the user's intended small-cohort workflows.
The empirical/practitioner anchors already included small cohorts; they should
have influenced the main design. Numerical improvement on the 400 retained
datasets is useful evidence, but does not establish small-cohort usability.
The subsequent revision overcorrected by treating larger samples merely as
context. The user's latest correction restores them as substantive parts of
the main evaluation, not an optional appendix or evidence to discard.

The primary question is: **across small, medium and large samples and the
supported facet structures, which model and rating design deliver estimates
and uncertainty adequate for the intended interpretation, and where do outputs
need to be withheld or qualified?** N=20–60 receives the missing attention
without becoming the definition of the package's intended audience.
Rater severity/contrasts and Person scoring belong alongside discrimination,
not downstream of an automatic two-family slope-coverage qualification.
Separate exploratory rubric/rater review from individual consequential
decisions; a single generic acceptable-coverage rule cannot establish both.

The user's account establishes a development priority, not an independently
measured proportion of mfrmr users. A relevant published example is the
[Uto et al. (2024) OSCE study](https://doi.org/10.1371/journal.pone.0309887):
30 examinees, five raters, 30 rubric items and four score categories; two raters
assessed everyone and three assessed disjoint groups of ten. This anchors a
small-N, many-item, unequal-exposure design. Its richer response model uses
Bayesian EAP estimation with NUTS and declared priors; it does not validate
mfrmr's current two-family MML or its Wald intervals.
Published Rasch sample-size heuristics likewise cannot supply a universal
minimum N for this different model and inference procedure.

### Design dimensions and provisional applied settings

Count **non-Person facets** explicitly below; conventional descriptions may
count Person as an additional facet. For example, Person x Task x Rater has
two non-Person facets, while Person x Task x Criterion x Rater has three.
Criterion levels are rubric dimensions/items, not the ordered score categories.
The number of facets, levels, slope-owning facets and latent ability dimensions
are four different quantities.

| Dimension | Candidate scope, not a frozen simulation grid | Question it answers |
| --- | --- | --- |
| Independent Persons | N=20, 30, 40, 60, 120, 240, 480 in the main sample-size scope. Reuse the completed N=240 evidence and compatible N=120/480 pilot records. | Where do estimation and uncertainty improve, remain biased, or fail across the range? Neither small-N nor large-N results substitute for the other; N=480 alone does not prove asymptotic behavior. |
| Non-Person facet count | One-facet reduced reference; Task x Rater or Criterion x Rater; Task x Criterion x Rater; add Occasion only for a concrete repeated-assessment question. | Can distinct sources of variation be represented and separated? More facets are not automatically more ability dimensions. |
| Levels within facets | Initial candidates: 2/3/6 raters, 2/4 tasks, 3/5 criteria; retain a separate many-item OSCE anchor. Larger rater panels are relevant to training/shared-performance designs. | How do calibration burden and exposure per estimated level change? Values are proposed design contrasts, not measured usage frequencies. |
| Assignment and workload | Fully crossed small panels; two raters per performance; common-rater/common-Person links; unequal exposure and weak links. Specify Persons and performances per rater as well as total scored cells. | What can be separated using the observed crossings, and what precision is gained by a feasible allocation? |
| Ordered categories and steps | Three/four/five categories; common versus owner-specific steps; central versus poorly targeted scores. Declare which facet owns steps. | Does a richer rubric help measurement or leave individual step parameters unsupported? Changing step ownership changes the model. |
| Population and effect variation | Ability SD .5/1/1.5, then targeting/location shifts and selected nonnormal populations; separately change rater severity, task difficulty and log-slope variation. | Which source of heterogeneity causes the change? An ability-SD contrast does not test rater-severity SD. |

The main evaluation has two complementary sample-size comparisons. First,
hold facet levels, response equation, population and assignment rule fixed
while varying N; this isolates sample-size trends as far as discrete roster
constraints allow. Second, increase facet levels/model burden or change the
assignment together with N to represent larger operational assessments. A
large overall N can still leave each rater or task with sparse exposure.
Neither comparison can replace the other, and a fully crossed large-N design
alone does not qualify a large sparse assessment.

Retain an explicit connection to the historical four conditions: three Tasks,
six Raters, three categories, ability SD .5/1, and common-Person/rotating-pair
rosters, with rater-owned steps. Their N=240 records remain substantive
sampling evidence. Extend matching design definitions across the declared N
range where feasible, documenting small-N integer allocation differences
rather than silently changing the population or model. Criterion-owned rubric
models below are an additional comparison, not replacements for these cases.

Evidence status must remain visible: N=240 has 100 retained datasets in each
of those four cells; N=120 and N=480 have one timing case per corresponding
cell, not completed coverage evaluations. Compatible prepared inputs and pilot
records may be reused once the design is settled, but their existence neither
authorizes execution nor establishes performance. If the inference procedure
changes, label and evaluate the new procedure on retained data as appropriate;
do not pool old/new procedures as one arm or call reused development data
independent confirmation.

Selected misspecification and exposure contrasts must include larger samples
as well as small ones: increasing N does not remove a wrong-model target or
an assignment bias. Runtime/memory under larger facet counts is also a package
usability question, evaluated separately from statistical accuracy. The upper
sample size for a specific large-scale use case can be extended with a stated
purpose; 480 is the present main grid endpoint, not a universal package limit.
This is the MML validation strand of mfrmr, not a redefinition of the broader
package or a qualification of its separate G/D, MI and reporting capabilities.

Use cases give these dimensions a purpose. A small classroom with a few tasks
and two or three common raters differs from rater training where many raters
score a small set of shared performances. A rubric assessment with Task,
Criterion and Rater differs from both, even at the same N. The published OSCE
is a fourth, many-item example. Occasion requires an explicit stable-ability
or change estimand; a main-effect time column alone does not model individual
growth. These are design families to resolve, not additional automatic cells.

Two workload contrasts are necessary. If every existing Person receives ratings
from added raters/tasks, both cost and information increase. At a fixed number
of rating occasions, adding raters spreads observations across more estimated
rater effects and changes overlap. Likewise, more rubric marks on the same
performance are not equivalent to collecting new Persons or new performances.
Report rater-performance encounters separately from scored rubric cells; equal
cell counts need not imply equal human workload. When exact exposure/cost/
connectivity matching is impossible, state what changes instead of claiming an
isolated facet-level effect. Small N also makes exact balance and linking
constraints discrete; retain valid unequal allocations rather than silently
changing N to fit an old six-rater roster.

N counts independent Persons. Repeated scores can inform a Person's ability
and shared parameters, but do not create independent Persons. Start with
conditional independence as a declared baseline; examine a Person-by-performance
term for rubric scores on the same performance in the robustness block. Do not
silently manufacture independence by treating each criterion rating or each
occasion as a new Person. Also distinguish inference on the observed fixed
raters/tasks from generalization to populations of raters/tasks; more levels
alone do not turn fixed effects into a random-facet model.

### Model comparison and current implementation boundary

Compare supported **RSM, PCM, one-family GPCM and two-family GPCM using MML**
where they address the same applied question. Include generating cases with
equal slopes, only the Task/Criterion family varying, only the Rater family
varying, and both varying. Common and owner-specific category steps must be
distinguished too: RSM and PCM differ in that restriction, not just slope
complexity. Compare methods on the same generated observations. This permits
the possible variance cost of extra parameters to be weighed against bias
from restrictions, without presuming either model complexity is preferable.
Existing corrected-JML work remains paused; it is not restarted simply to
multiply comparison arms. If small-cohort MML proves inadequate for a needed
output, compare simplifying the model or improving allocation with a justified
regularized/Bayesian or externally calibrated alternative. Those alternatives
require their own estimand, prior/anchor sensitivity and uncertainty evaluation;
they are not automatic remedies or an instruction to build another engine now.
Likewise, a bootstrap cannot be assumed to repair structural nonidentification.
A rule that chooses a simpler model after a fit fails would itself need
procedure-level evaluation. Do not select the best-looking model/interval after
each draw and report its coverage as that of a fixed prespecified method.

Static source inspection establishes these boundaries:

- `R/core-gmfrm-em.R::mfrm_fit_product_slopes()` requires exactly two non-Person
  facets, both slope owners, with at least two observed levels each. The second
  owner has free locations/slopes and owns centered category steps. The ability
  population is fixed standard normal. Third/fourth additive facets, anchors,
  interactions and shrinkage are not supported by this route. Repeated rows for
  the same Person and both facets are also rejected.
- The ordinary route accepts one or more facets and constructs additive blocks
  per facet. Existing RSM/PCM MML backend fixtures explicitly include Rater,
  Task and Criterion (`tests/testthat/test-mml-cpp11-backend.R`). This is source
  evidence of a broader implementation scope, not a new small-N performance
  result or validation of every consumer/model combination.
- `extract_mfrm_sim_spec()` rejects product slopes and currently requires
  exactly two non-Person facets even for ordinary fits. The old scenario
  generator is similarly not a ready solution for this broader study.

Thus increasing Task or Rater levels within two facets cannot answer the facet-
count question. A three-facet ordinary-model study is conceptually distinct
from extending the two-family engine to additional location-only facets.
Resolve the latter's scientific need, identification, category ownership and
output contract before implementation. Do not concatenate Task and Criterion
to imply their separate effects were estimated, silently remove a requested
facet, or count a documented unsupported model as numerical nonconvergence.

Parameter burden should be explicit. For the current unanchored two-family
model with A first-owner levels, B second-owner levels and K score categories,
the source constraints give `(A-1)+B` locations, the same number of slopes, and
`B*(K-2)` centered step coordinates: **2(A-1)+BK** calibration parameters.
For example, the old 3-Task/6-Rater/3-category baseline already has 22.
Person abilities are integrated, not N additional freely estimated MML
parameters. This count exposes why rater levels and categories matter, but
neither N divided by parameter count nor total score count is a universal
identification or sample-size criterion.

Distinguish the Person-rating assignment graph, the rank of the facet-crossing
design, category support, local information curvature, and numerical convergence.
None alone certifies precise inference. Under a common fixed population model,
absence of shared Persons is not by itself a proof of MML nonidentification;
apparent comparability can depend strongly on the common-population assumption.
Conversely, connected data can remain weak or structurally confounded. Nesting
Rater within Task, for example, must be assessed for the actual estimable
contrasts and model, not handled as ordinary random missingness.

### Targets, scale and failure accounting

For interpretable location/slope parameters, report bias/RMSE, tails, empirical
versus estimated SE, interval availability, width and conditional coverage.
For rater review, prioritize prespecified severity contrasts and their
uncertainty over ranks alone. If flagging is proposed, specify a practically
meaningful difference, false-positive/missed-difference costs and multiplicity
policy first; componentwise coverage does not validate a feedback rule.

For Person scoring, distinguish calibration-cohort and new-Person performance,
central and extreme abilities, and the ability scale/estimand. Posterior SD or
fixed-calibration EAP uncertainty does not include calibration uncertainty.
Evaluate the uncertainty the public method actually supplies; do not label an
unavailable unconditional interval as covered or quietly substitute a research
oracle. Known-calibration scoring can later be an explicitly labeled diagnostic
comparator to separate limited Person responses from calibration error.

Use category probabilities/expected scores for shared response targets when
model parameters are not commensurate, with prespecified contexts and weights;
do not claim coverage of a nonexistent component in a simpler/misspecified
model. Raw locations/slopes from different identification conventions cannot
be compared directly. In particular, the two-family fixed-N(0,1) transformation
and one-family geometric-mean-one/free-population convention must be reconciled
before comparing truth. For RSM/PCM, changing ability SD while fitting a fixed
unit-SD population may add population misspecification, not merely information
variation. Choose and document population estimation or the appropriate
restriction explicitly. Fixed-effect severity remains conditional on the model;
an apparent rater difference is not automatically a causal training deficit.

Retain all planned attempts, including unsupported category draws, extreme
estimates and interval refusals. Report preparation/structural refusal,
optimization failure, integration sensitivity and inference refusal separately.
Show point performance for all qualified estimates and the interval-returned
subset; conditional coverage, availability and returned-and-covered frequency
answer different questions. Keep the original score ladder; no redraw until
every category appears. Report exposure and category support alongside failures.
Pointwise intervals are not simultaneous coverage, and many correlated
parameters within a dataset are not independent simulation replications.

### Follow-up: decisions that can be made without fitting

The continuation of this review remains a source/evidence/algebra review.
No numerical script, random generation, new derivative evaluation or timing
pilot has been run. The following findings narrow the study before replication
counts are chosen; they do not modify the frozen estimator or its checks.

**Observed-score rank is a binding output restriction at small N.**
`mfrm_gpcm_product_inference()` obtains an N-by-p matrix of observed Person
marginal-likelihood scores and requires column rank p at both derivative step
sizes (`R/core-gpcm-product-slopes.R`, the `Local score rank` check).
Consequently N < p cannot pass this check, irrespective of quadrature order,
optimizer tolerance or the number of ratings within each Person. This applies
to the current model-based component log-Wald and facet-location normal
interval paths sharing this check; it is not a claim about every possible
interval construction or about point-estimation feasibility.

The dimension consequences below follow algebraically from the source
constraints, not from simulated datasets. A and B are the first and second
slope owners; B also owns category steps. All levels are assumed observed.

| Candidate two-family design | Free calibration dimension p=2(A-1)+BK | Consequence at N=20 under the current check |
| --- | ---: | --- |
| Historical Task=3, Rater=6, K=3; rater-owned steps | 22 | Cannot return the model-based intervals through this check. |
| Rater=3, Criterion=3, K=4; criterion-owned steps | 16 | Not excluded by N < p alone; all other numerical and statistical issues remain. |
| Rater=6, Criterion=3, K=4; criterion-owned steps | 22 | Cannot return the model-based intervals through this check. |
| Rater=3, Criterion=5, K=4; criterion-owned steps | 24 | Cannot return the model-based intervals through this check. |

At an exact interior stationary point, the Person-score rows sum to zero,
so their rank is also at most N-1. Approximate numerical stationarity and
rank tolerances complicate the boundary N=p; a nominal full-rank result near
that boundary must not be made easier by a less accurate optimizer. Neither
N>p nor passing the check implies adequate precision or coverage.

This is **not a proof of structural nonidentification** when N<p. The retained
earlier two-owner example in this record already distinguishes the objects:
four Persons each observed at all four binary crossings had full-pattern
marginal score rank 6/6 at the stated interior vector, despite only four
observed Person-score rows. That result is first-order model information at
one vector, not an observed-data MLE or a coverage result. It is sufficient to
show why observed-score rank cannot be substituted for population/full-pattern
information. An observed-information Hessian and an outer product of observed
score rows are different finite-sample matrices.

For a full-parameter sandwich covariance, deficient empirical score rank is
a real limitation of that covariance construction. Requiring the same rank
as an additional condition for model-Hessian Wald intervals is a conservative
procedure choice whose role now needs explicit review. **Do not remove the
check merely to get intervals at N=20.** First determine whether it is an
essential requirement of the claimed procedure, a diagnostic that has become
an unnecessarily broad veto, or evidence that the public small-N claim needs
restriction. Any changed rule is a new inference procedure requiring its own
retained-case checks and sampling evaluation. Until then, record its known
small-N exclusions without spending repeated fits to discover them, while
retaining relevant point-estimation/scoring questions in those designs.

**The public output matrix is narrower than the fitting matrix.** The table
describes current source contracts, not small-sample qualification. Category,
identification and numerical prerequisites still apply to every admitted path.

| Fit specification | Non-Person facet structure | Public location/contrast interval helper | Relevant comparison restriction |
| --- | --- | --- | --- |
| RSM/PCM MML, fixed N(0,1), fixed quadrature, unit weights | Ordinary additive facets, including three-facet implementation fixtures | `mfrm_facet_intervals()` supports model and Person/cluster sandwich methods | The population mean/SD are assumed known, not estimated from 20–60 Persons. |
| RSM/PCM MML with `population_formula=~1` | Ordinary additive facets; all non-Person locations centered | The helper rejects active population estimation | Population mean/variance and facet points exist; this does not supply the proposed contrast-CI comparison. |
| One-family GPCM MML, default free population | Ordinary additive facets, one slope owner; step owner may differ | The helper rejects this model; `confint()` covers slopes only | Public slope intervals and one-family curve intervals do not replace severity-contrast intervals. |
| Two-family GPCM MML | Exactly two facets, both slope owners; second owns steps | Experimental model-based location/contrast intervals | Subject to the observed-score rank restriction above; no sandwich, and curve calibration intervals remain unavailable. |

Source anchors are `R/api-facet-intervals.R::mfrm_facet_intervals()`,
`R/api-gpcm-intervals.R::confint.mfrm_fit()`, the population dispatch in
`R/api-estimation.R`, and `R/api-gpcm-curve-intervals.R`. Do not substitute
independently combined printed SEs or internal covariance extraction and call
that a validated public contrast consumer. An internal research calculation
would have to be named and verified separately. Also, `facet_shrinkage` is
post-hoc empirical-Bayes shrinkage; its `laplace` alias does not turn the
estimation into penalized MML or repair a failed likelihood fit.

**Separate a matched scientific comparison from default-workflow behavior.**
RSM/PCM defaults fix N(0,1); one-family GPCM defaults estimate a normal mean
and variance with geometric-mean-one slopes. Two-family GPCM fixes N(0,1),
leaves second-owner locations/slopes free and thereby uses a different
location/scale representation. Comparing defaults is useful as a user-workflow
question, but its differences cannot be attributed only to adding slopes.

For the scientific comparison, explicitly specify the ordinary/one-family
population and reconcile each model's scale with the two-family representation.
The preferred planning direction is estimated-normal ordinary comparators,
with `population_formula=~1`, the required Person ID table and centered facets;
the fixed-population ordinary route is a separately labelled assumption/output
comparison, not a way to conceal the missing interval consumer. This leaves
a concrete pre-execution decision about extending that consumer or limiting
the matched block to currently supported point/scoring/response targets.

One common response target can be defined at population-standardized ability
z: evaluate an estimated-normal fit at Theta=mu+sigma*z, and the fixed-N(0,1)
two-family fit at Theta=z, in identical declared rating contexts. This defines
a percentile-relative response curve, not a prediction at a known absolute
ability. Corresponding location differences divide by sigma and effective
slopes multiply by sigma under this transformation. The means, scale and
nuisance covariance must be propagated if intervals on such transformed targets
are later proposed; supplying estimated mu+sigma*z as a fixed `Theta` to the
existing curve helper does not perform that propagation. Use the declared
generating distribution for truth; do not recenter/rescale every simulated
cohort to force its realized mean and SD to the population values.

**Proposed applied blocks and the decisions they support.** These specify
roster/model comparisons, not a frozen Cartesian grid or an authorization to
generate data. These applied blocks ensure coverage of N=20/30/40/60 and add
prespecified medium/large-N comparisons where the use case is meaningful.
They supplement the full-range historical-design extension above. A rater-
training block need not be inflated artificially to represent a large test;
large incomplete assessment belongs explicitly in the multi-task/roster work.

| Block | Concrete baseline and controlled comparisons | Main question and supported scope |
| --- | --- | --- |
| Single-performance rubric assessment | Three Criterion levels, three Raters, four categories. Compare every Person rated by all three with two raters per Person, the same pair scoring all criteria. Then compare three versus six raters at two raters per Person. | How much do rater severity contrasts and Person scores change with overlap and rater exposure? The all-three comparison changes workload; the three-versus-six comparison preserves rating encounters but changes overlap and rater-level burden. This is the two-facet model-comparison block. |
| Multiple tasks scored with a rubric | Task x Criterion x Rater, initially two Tasks, three Criteria, three Raters and four categories, with two raters per Person-task. Compare two versus four Tasks; compare three versus five Criteria. | How are task difficulty, criterion difficulty and rater severity separated in small cohorts? Ordinary RSM/PCM and the additive one-family route are the fitting candidates; the current two-family route is excluded by capability, not counted as a failed fit. More tasks and more criteria have different workload/dependence implications. |
| Rater training on common performances | The same small set of Persons/performances scored by all three or all six raters, with three criteria and four categories. | Does shared evidence allow useful comparisons among the observed raters? Every rater still sees N independent Persons. This is a separate full-panel/workload contrast; do not infer generalization to a population of replacement raters. |

For two-rater assignments, a prespecified balanced-pair schedule should keep
per-rater Person counts within one where feasible and deliberately preserve
overlap. For three raters use the three distinct pairs; for six, cycle complete
round-robin matchings before repeating. Fix the schedule before scores and
randomize Person labels independently of ability. In the multi-task block,
the baseline changes partners across tasks where feasible; retaining the same
pair across all tasks is a separate allocation contrast. Specify pairwise and
task-specific exposure as well as overall rater totals. Do not assume these
rosters isolate a graph effect or that randomized labels imply MNAR robustness.

Use **criterion-owned steps** as a primary hypothesis within the rubric block, with
explicit `step_facet="Criterion"`. For the two-family route this means
`slope_facet=c("Rater","Criterion")` and
`noncenter_facet="Criterion"`; the rater slopes then have geometric mean one.
This is a block-specific modeling choice, not a package-wide preference or a
claim that category use cannot vary by rater. Retain rater-owned steps in the
historical-design core and a matched ownership comparison; switching the owner
is not merely relabelling, and
the old Task/Rater results cannot validate it. The multi-task rubric has a
third facet even when the same criterion is used on every task; do not combine
Task and Criterion IDs to pretend their effects were separated.

The primary questions are severity **contrasts** and Person scoring; component
slopes and shared response probabilities explain where restrictions help or
hurt. Prespecify contrasts by design role, not by which fitted rater looks most
extreme. For scoring, compare calibration-cohort and held-out Persons, reporting
conditional bias across true ability and uncertainty on its actual public
definition. Do not manufacture normal confidence intervals from `PosteriorSD`.
Probability/expected-score recovery is a common point target when component
parameters differ; rankings alone are not the primary success criterion.

Evaluate equal slopes, one varying family in each direction, and both varying
within the compatible two-facet block, with a separately stated step structure.
The three-facet block also needs a genuinely nonzero Task effect so that it does
not merely demonstrate fitting an unnecessary column. N x rater exposure and
N x category/criterion burden are core interactions. Ability-associated
assignment, within-performance dependence and sparse category support then
receive targeted contrasts and selected combined adverse cases. The OSCE
example remains a separate many-item/unequal-exposure design anchor; adapting
its assignment is not replication of its Bayesian interaction model.

Nominal 95% intervals remain a reporting target, not an automatic acceptance
rule. Practical adequacy additionally depends on the width/error acceptable
for the actual use; do not invent a universal logit or ranking tolerance.
Report effect magnitudes and Monte Carlo uncertainty until an application-
specific decision margin is justified. A later qualification decision must
freeze that margin and the treatment of unreturned estimates before its
confirmation sample. The existing 3-percentage-point coverage margin is not
silently inherited by this broader comparison.

### Staging decisions before any new calculation

1. Resolve the observed-Person-score rank policy and the population/contrast-
   consumer mismatch for the affected outputs before freezing their sampling
   comparisons. Keep current checks in place during review. These issues do
   not erase the distinct questions addressed by larger samples. Use both the
   historical-design core and the applied blocks to fix primary outputs and
   matched methods. Three-facet work starts from existing additive models;
   any two-family extension needs a separate necessity/identification decision.
2. Specify a correctly modeled core across N=20/30/40/60/120/240/480 with
   matched design definitions and selected complexity/exposure comparisons.
   Test N x rater exposure and N x category/parameter burden at multiple sample
   sizes; single-factor departures alone cannot establish them. Separately
   examine increasing N with increasing facet levels. Preserve all relevant
   completed larger-sample evidence and two-family development failures.
3. Add targeted robustness contrasts for restricted/nonnormal ability,
   task/rater targeting, ability-associated assignment, assigned-rating
   missingness, and within-performance dependence. Separate planned
   nonassignment from missing assigned scores. Use selected combined adverse
   settings as checks; do not claim robustness from testing each in isolation.
4. Select primary performance tolerances and replications from their Monte
   Carlo precision and decision consequences. Keep method comparisons paired
   by dataset, specify any shared randomness across designs, and reserve fresh
   data for any later confirmation of a method tuned during exploration.
   Neither 2,000 total fits nor 100/500 repetitions per cell is a new constraint.
   Independent new draws are not independent implementation validation.
5. Only after the design is settled and the current no-computation instruction
   is lifted, freeze inputs/procedure, perform the necessary execution checks,
   and launch an appropriately scoped study. The old elapsed-time estimates
   do not price the new small-cohort/multifacet comparison. Do not start with a
   timing pilot while scientific choices are still open.

This approach follows the separation of aims, generating mechanisms, estimands,
methods and performance in
[Morris, White and Crowther (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6492164/).
It supplies a planning framework, not a completed small-sample validation.
The proposed primary outputs, full-range core and applied blocks are specified above.
Open choices are the observed-score eligibility policy, matched population/
output contracts, application-specific tolerances, final parameter values and
allocation schedules, any justified consumer/model extension, and the resulting
condition/replication allocation. D1/D2 remain open.
