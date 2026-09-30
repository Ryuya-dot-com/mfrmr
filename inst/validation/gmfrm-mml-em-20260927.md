# Joint task/rater slopes: numerical MML--EM verification

Date: 2026-09-27. Internal implementation; not a public API availability claim.

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
