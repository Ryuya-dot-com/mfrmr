# JML structural inference: literature and implementation review

Date: 2026-09-27. Local development review; no new inferential API qualified.

Current September 30 target review is recorded at the end of this file; older
research/public-API status descriptions below retain their historical scope.

## Question and decision

Can the joint-curvature check added for portable GPCM JML justify formal
structural intervals? No. Three distinct requirements remain: identified
finite estimation, a sampling covariance appropriate to the stated target
and asymptotic regime, and adequate centering of the interval on the true
parameter. A local Hessian check addresses only part of the first requirement.
Fixed-calibration agreement with TAM/ConQuest cannot establish the other two.

This increment corrects a public help formula and makes those distinctions
explicit. It does not change estimation, standard-error calculations,
numerical cutoffs or scoring eligibility. Formal JML slope intervals remain
unavailable. The corresponding ordered completion criteria are in ROADMAP's
JML structural-inference milestone.

## Primary source and reading scope

Haberman, S. J. (2004). *Joint and conditional maximum likelihood estimation
for the Rasch model for binary responses*. ETS Research Report RR-04-20.
[Publisher record](https://www.ets.org/research/policy_research_reports/publications/report/2004/hytm.html),
[DOI](https://doi.org/10.1002/j.2333-8504.2004.tb01947.x),
[full report](https://files.eric.ed.gov/fulltext/EJ1110899.pdf).

All 69 PDF pages were read in page order through page-delimited text,
including front matter, printed pages 1-58, references 59-61 and appendix
62-63. Printed pages 26-29 were additionally rendered and visually checked
for the normal-approximation statements and covariance formulas. This is a
source review, not an independent proof verification; some proofs are omitted
in the report itself. No copy of the report is added to the package. Download
SHA-256: `66b13a8aef09ede41cac95e4151b2a36370f490d36a0c02bbc30d0e9ba93ae12`.

| Printed pages | Finding used here |
| --- | --- |
| 3-4 | Assumptions include complete binary Rasch responses, bounded parameters and independent Persons. |
| 7-13 | Extreme Persons obstruct a finite full JML vector; extended estimates require a separate interpretation. This does not make every structural parameter inestimable. |
| 13-24 | With fixed test length, structural JML may approach a biased limit as the Person count grows. |
| 25-29 | Normal approximation can be centered on that limit. Its covariance is not generally the ordinary inverse information; increasing test length introduces additional conditions. |
| 29-35 | Person asymptotics, residuals and misspecification have distinct requirements. |
| 35-54 | Rasch CML conditions out Person parameters; this does not provide a CML algorithm for the present free-slope GPCM. |
| 54-58 | Latent-distribution identification and the interpretation of JML/CML require care. |

These binary-model results do not qualify sparse many-facet GPCM. The
report's growth-rate conditions are not finite-sample package cutoffs. It
supplies no universal item-count correction for this free-slope implementation.

## Implementation audit and user-facing correction

`compute_response_probability_bundle()` in `R/core-likelihood.R` computes information
for the additive predictor as squared slope times conditional score variance.
`calc_facet_se()` in `R/mfrm_core.R` sums this information with observation
weights within each facet level. Thus its location approximation is

    SE_g = 1 / sqrt(sum_{r in g} w_r * a_r^2 * Var(X_r | fitted predictor))

with slope one in RSM/PCM. The previous `fit_mfrm()` help omitted weights and
squared slopes and used the overly broad label "SEs reported under JML".
It now identifies these as facet/location approximations conditional on other
fitted parameters, not slope SEs or a joint nuisance-adjusted covariance.
The existing `PrecisionTier`, `SupportsFormalInference` and `CIUse` safeguards
already label this output exploratory/screening-only; no duplicate warning
system or new API is needed.

The source check for portable GPCM JML evaluates the full local joint Hessian
but returns no inferential covariance. If Person parameters are denoted P
and structural parameters S, the candidate profile curvature is
`H_SS - H_SP solve(H_PP, H_PS)` where the required blocks are invertible on
the identified parameter space. This algebra does not establish that its
inverse is the sampling covariance for growing nuisance dimension, nor that
intervals cover true parameters. Regularization or fit-based SE inflation
cannot by itself resolve that centering problem.

## Evidence reused and remaining work

- [Portable JML qualification](portable-gpcm-jml-20260927.md) already checks
  independent joint likelihood, off-optimum gradients and mixed-direction
  curvature for two shared owners. Those checks were not repeated here.
- [External fixed scoring](gpcm-jml-external-scoring-20260927.md) uses actual
  JML calibrations in TAM/local ConQuest but holds the calibration fixed.
- [TAM/immer factor pilot](tam-immer-jml-factor-pilot-record-0.2.3.md) retains
  290 design cells with five replicates per condition, including failed and
  unidentified cases. Its unequal-exposure correction differences are a
  reason to define the estimator carefully, not a slope-coverage result.
- [Paired PCM/GPCM record](pcm-gpcm-jml-paired-calibration-record-0.2.3.md)
  contains six descriptive pairs, not a coverage study.

The next implementation gate is a derivation of covariance and bias treatment
for the existing shared-owner scope. Then evaluate Person count and exposure
separately, retaining failure denominators and Monte Carlo uncertainty. Merely
inverting the newly available Hessian would bypass this gate. A new large
simulation was not launched before defining its inferential target.

## Profile-information derivation and numerical check

A subsequent check makes the covariance work concrete without promoting it to
public inference. The [runner](jml-profile-information-20260927.R) reuses the
two saved shared-owner GPCM fits; it does not recalibrate structural parameters.
Their Person coordinates are unconstrained and unanchored, so profiling can
be done separately for each Person. This separation must not be assumed for
coupled Person constraints.

Let beta denote the identified free structural coordinates and let
`q_i(beta, theta_i)` be Person i's negative log likelihood. Define
`m_i(beta) = inf_theta q_i(beta, theta)` (allowing extended Person limits).
At a finite interior conditional
minimum with positive Person curvature, implicit differentiation gives

    d theta_hat_i / d beta = - H_ii^{-1} H_iS
    grad m_i = grad_S q_i
    Hess m_i = H_SS,i - H_Si H_ii^{-1} H_iS
    S = sum_i Hess m_i = H_SS - H_SP H_PP^{-1} H_PS.

The runner forms adjacent-category log probabilities independently, solves
each Person score equation by bracketing and a scalar root, and compares the
resulting profiled likelihood with this Schur complement. Package parameter
expansion is reused to preserve the exact identification. Four structural
directions at two step sizes check curvature; independent finite differences
of the per-Person profile contributions check the envelope gradient.

| Saved owner | Objective discrepancy | Envelope-gradient discrepancy | Maximum directional relative discrepancy | Inverse-block discrepancy |
| --- | ---: | ---: | ---: | ---: |
| Criterion | 0 | 1.16e-9 | 1.34e-7 | 1.67e-16 |
| Rater | 5.69e-14 | 1.69e-9 | 1.01e-7 | 1.95e-16 |

The inverse-block check verifies `solve(S) == solve(H)[S,S]`. All declared
checks pass. Person score residuals are below 2.2e-11; structural gradients
remain those of the retained near-stationary sources (at most 5.83e-5), not a
new exact structural optimum. These checks establish local differentiation
and parameter bookkeeping, not a global solution or sampling performance.

After mapping all four relative log slopes through their sum-zero Jacobian,
`sqrt(diag(J solve(S) J')) / sqrt(diag(J solve(H_SS) J'))` ranges from
1.090-1.305 for Criterion ownership and 1.100-1.288 for Rater ownership.
Both denominators account for other structural coordinates; the difference
is whether Person coordinates are treated as known. These are **inverse-
curvature scales**, not qualified SEs or a comparison with the package's
observation-table facet SEs. No slope confidence bounds are generated.

### Sampling covariance and its target

For an iid Person sampling regime with a fixed common response design, let
`psi_i(beta) = grad m_i(beta)` and let `beta_star` be the minimizer of the
expected profiled criterion. Under the differentiability, finite-moment,
identification and interior-solution conditions for a fixed-dimensional
M-estimator, a candidate covariance about `beta_star` is

    A = E[Hess m_i(beta_star)]
    B = Var[psi_i(beta_star)]
    Cov(beta_hat) approximately A^{-1} B A^{-T} / N.

Using total observed curvature S and centered profile gradients G gives the
empirical form `solve(S) crossprod(G) solve(S)'`. Equality to `solve(S)`
requires an information identity not supplied just by profiling. Centering
or sandwich scaling cannot replace `beta_star` by the true structural
parameter. This is a derivation of a candidate under stated assumptions,
not a new GPCM consistency or bias-correction theorem.

Both saved fits have N=14 Persons and 17 free structural coordinates. Their
centered profile-gradient matrices have rank 13, the maximum N-1 allows.
Thus they cannot qualify a nonsingular full 17-dimensional empirical
sandwich. Some contrasts can still have nonzero estimated variance; rank
failure alone is not proof that every contrast is inestimable. Increasing
N beyond 17 would remove this arithmetic obstruction only, not establish
adequate precision, independence, bias control or coverage. No arbitrary
minimum-N inference rule is introduced.

Fixed heterogeneous Persons, different assignment patterns and dependent
ratings need their own sampling design and covariance argument. In
particular, raw cross-products can include between-design mean-score
variation if the expected profile score differs across designs. A Person-
cluster label is not by itself a proof of robustness to selective assignment.

The finite profile runner refuses all-minimum/all-maximum Persons. For fixed
finite structural parameters and positive slopes, their extended profile
negative log likelihood has infimum zero as ability tends to the appropriate
infinity. That local fact does not resolve possible structural boundaries or
qualify the existing portable workflow to accept an infinite full JML vector.

### Consequence for the next implementation gate

Local nuisance-adjusted curvature and its identified log-slope transformation
are now checked for the two existing finite examples. The remaining gate is
the **centering/bias treatment for the true relative-slope target**, followed
by covariance/coverage checks under a declared sampling design. The current
runner is retained as a regression oracle for that work, not added to the
public API or the CRAN test suite.

TAM's current [`tam.jml()` help](https://alexanderrobitzsch.github.io/TAM/reference/tam.jml.html)
describes B as supplied category loadings and `errorP` as item-intercept SEs;
it does not document a corresponding estimated relative-slope covariance.
Consequently, those SE columns are not a direct reference for this proposed
JML slope route. Existing TAM/ConQuest fixed-score comparisons retain their
original scope; neither engine was rerun here.

Evidence is under `validation-results/jml-profile-information-20260927-final/`:
source hashes, runner hash, full curvature/profile-gradient matrices, identified
slope transformations, summaries and session information. The earlier sibling
directory retains the first calculation, whose slope summary used only free
coordinates; the final version includes the constrained fourth slope too.
No source fit, numerical tolerance or statistical eligibility was changed.

## Exact centering check and correction decision

The [exact-response runner](jml-profile-bias-exact-20260927.R) asks whether
profiling Person ability leaves an unbiased structural estimating equation
at the known truth, and whether substituting estimated ability into a single
score-centering correction fixes it. This addresses the remaining centering
gate directly, without running a large recovery study or fitting a correction
whose target is not yet established.

### Design and accounting

There are two Raters, two Criteria and three ordered categories (0, 1, 2).
Rater locations are (.3, -.3), Criterion locations (-.4, .4), and the two
step-owner threshold vectors are (-.6, .6) and (-.9, .9). Relative slopes are
(exp(.25), exp(-.25)); ownership is either Criterion or Rater. The whole
adjacent-category predictor is multiplied by the slope, as in the package.

One or two conditionally independent ratings per Rater-Criterion cell gives
4 or 8 ratings per Person while holding the structural dimension at five.
The second condition is a mathematical repeated-response design, not evidence
that repeated ratings in practice are independent. Each case is evaluated at
fixed true abilities -1, 0 and 1; no normal ability distribution is assumed
or fitted. Sparse designs and ability-dependent allocation are not studied.

All response sequences are retained. Four ratings have 81 patterns. Eight
ratings have 6,561 ordered patterns, represented exactly by 1,296 within-cell
category-count patterns with their multinomial multiplicities. Both all-low
and all-high patterns contribute their probability mass and their exact
extended profile limit (zero negative log likelihood and structural gradient).
They are not deleted or replaced by artificial finite abilities. Profile
ability depends on category totals by slope owner, so only the distinct
conditional roots need solving.

The analytical negative-profile-log-likelihood gradient is checked against
central differences for every aggregated pattern. Its maximum discrepancy
is 7.77e-10; Person-root residuals are below 8.31e-13. Independent probabilities
match the package GPCM kernel within 2.23e-16. Total response probability is
one within 1e-12 in every case. With true ability held fixed, the expected
structural score is zero within 1.12e-15. These checks separate the profiling
effect from a probability, derivative or response-accounting error.

### Result and what the numbers mean

Write `g(y; beta)` for the negative profile-likelihood gradient and
`b(beta, theta) = E_{beta,theta}[g(Y; beta)]`. The one-step candidate uses
`g1(y; beta) = g(y; beta) - b(beta, theta_hat(y; beta))`. Both expectation
layers are finite sums here, including the extreme-ability limits. All
quantities below are evaluated at the true beta; no corrected estimator
has been fitted.

For the relative log-slope coordinate alpha, with slopes `(exp(alpha),
exp(-alpha))`, the fixed-ability-zero results are:

| Slope/step owner | Ratings per Person | E[g_alpha] | E[g1_alpha] |
| --- | ---: | ---: | ---: |
| Criterion | 4 | -.133343 | .012302 |
| Criterion | 8 | -.109085 | .006417 |
| Rater | 4 | -.138495 | .013429 |
| Rater | 8 | -.115976 | .005474 |

Across all 12 owner/exposure/ability cases, the raw log-slope score expectation
is negative, ranging from -.173556 to -.109085. It varies with ability.
The one-step adjustment reduces its absolute value in all checked cases but
leaves values from -.013204 to .014555, including sign reversals. Thus the
true beta is not a stationary point of the expected raw criterion, and the
one-step adjusted equation is not exactly centered either. The negative raw
component locally favors increasing alpha while other coordinates are held
at truth; this is not a determination of the jointly fitted limit.

These are estimating-equation means, **not parameter bias, standard errors,
RMSE or coverage**. Score size also depends on exposure and parameterization;
comparing unnormalized scores across lengths is not a bias-rate estimate.
Neither a unique pseudo-true limit nor a corrected root is established here.

A common positive multiplier c is separately ruled out as a relative-slope
correction: `(c*a_j) / geometric_mean(c*a) = a_j` under the package's
geometric-mean-one convention. Multiplying log slopes instead would change
ratios and is a different estimator with no validation supplied by the
classical item-intercept correction. The public help now states this distinction.

### Literature and implementation implications

Dhaene, G., & Jochmans, K. (2017). *Profile-score adjustments for incidental-
parameter problems*, working paper, version September 12, 2017.
[Author manuscript hosted by Yale](https://economics.yale.edu/sites/default/files/dhaene-jochmans.pdf).
All 20 pages, including examples, simulations, appendix and references, were
read in order using extracted page text; method pages 3-5 were additionally
rendered and inspected. PDF SHA-256:
`a8b43169bfa84a53e16b233da1fb78a9b4758d2fdc5ecebcc2b461afa89584b9`.

Pages 2-4 distinguish zero profile-score bias, bias independent of nuisance
parameters, and nuisance-dependent bias. The one-step subtraction examined
here corresponds to the latter case (with the sign reversed for negative
log likelihood). Pages 4-5 qualify the iterative argument and base uncertainty
on the adjusted score; pages 9-12 include extended binary limits and examples
where identification prevents exact correction. Pages 13-16 provide examples
and simulation qualifications, not a many-facet GPCM guarantee. No universal
convergence, bias-order or coverage claim is transferred to mfrmr.

The candidate to investigate next is model/design-specific profile-score
recentering, with the exact calculation retained as its oracle. It is not yet
selected for the public estimator. Before adoption, resolve adjusted roots,
identification and remaining parameter bias; evaluate the derivative of the
**adjusted** equation for sandwich covariance. An adjustment need not be a
likelihood gradient, so raw-JML Hessians, profile likelihood intervals, IC
rankings and ordinary likelihood-ratio tests cannot be inherited automatically.
Higher-order iterations require their own convergence and information checks;
vanishing estimating equations alone would not establish valid estimation.

Final evidence is in `validation-results/jml-profile-bias-exact-20260927-plugin/`,
with the first raw-centering calculation retained in the sibling directory
without `-plugin`. All conditions and adverse residuals remain in the tables.
No Monte Carlo sampling, free calibration, external engine run or change to
public estimation/interval eligibility occurred in this increment.
The count-pattern multiplicities were also checked to reconstruct all ordered
responses. Updated estimation help was regenerated, parsed, checked and rendered;
NEWS and ROADMAP were synchronized, and `git diff --check` passed. No whole-
package test suite was rerun.

## Population roots of the candidate correction

The [root runner](jml-profile-bias-roots-20260927.R) reuses the response space
above. A shared factory was extracted from the original exact-response
runner; all 12 retained raw/adjusted expectations reproduced within 1e-12.
Generating response probabilities are fixed at the original true structural
parameters, with true ability -1, 0, 1 having probabilities .25, .5, .25.
This distribution is a declared benchmark, not a population model estimated
by JML. The correction's inner expectations use each response pattern's
profiled ability at the candidate structural parameters, not the true ability.

For each owner/exposure design we solve the **five-dimensional** expected raw
or one-step-adjusted equation. Every structural coordinate is free under the
existing centering and geometric-mean conventions. These are population
estimating-equation roots: candidate large-N limits when a sample estimator
converges to the corresponding branch. They are not finite-sample estimates,
Monte Carlo bias estimates or proof of a unique/global probability limit.
All extreme response probabilities remain in the expectation.

### Solver accounting and numerical qualification

Three starts were fixed in advance: truth, neutral `(0,0,-.8,-.8,0)` and
opposing `(-.3,.4,-.3,-1.1,-.25)`. Newton/double-dogleg solves used function
tolerance 1e-9, parameter tolerance 1e-10 and at most 100 iterations. Of 24
initial attempts, 16 passed the separate residual/Jacobian review. The eight
unresolved attempts were all six four-rating raw-JML attempts, neutral-start
four-rating Criterion correction, and neutral-start eight-rating Criterion
raw JML. They are retained, not relabelled as successes or inestimable models.

For the seven raw failures, BFGS minimized the expected negative profile log
likelihood (500-iteration ceiling, relative tolerance 1e-12), followed by
Newton root refinement. The adjusted failure used Broyden with cubic line
search (150-iteration ceiling). All eight follow-ups passed. Across all
resolved attempts, the three starts agree within 2.75e-9 in every structural
coordinate. This demonstrates agreement under the tested combined workflow;
it does not make the original direct-Newton procedure initialization-robust.

Review requires score sup norm below 1e-7, Jacobian minimum singular value
above 1e-6, and agreement of central-difference Jacobians at step sizes 1e-4
and 5e-5 within relative 1e-5. Raw likelihood minima additionally have positive
curvature; failed raw roots were checked against independent finite differences
of the objective. These are numerical criteria for this benchmark, not a
statistical coverage rule. No parameter bound was treated as an estimated
infinite endpoint.

The first follow-up harness attempted a scalar-objective gradient using a
vector-valued Jacobian output size. It stopped with a length mismatch before
saving a follow-up result. The helper now uses the actual function output
length. That failure log is retained; completed initial attempts were reused.

### Point-estimation result

The first relative slope has true value exp(.25) = 1.284025; the other slope
is its reciprocal. All structural parameters are jointly solved here:

| Slope/step owner | Ratings | Raw root: first slope | Adjusted root: first slope | Largest absolute coordinate displacement, raw / adjusted |
| --- | ---: | ---: | ---: | ---: |
| Criterion | 4 | 4.739506 | 1.288533 | 2.354141 / .056878 |
| Rater | 4 | 3.336691 | 1.289889 | 1.355291 / .056389 |
| Criterion | 8 | 1.501156 | 1.269916 | .233662 / .017707 |
| Rater | 8 | 1.485156 | 1.271156 | .222214 / .016955 |

The last column compares the same five coordinates (Rater, Criterion, two
steps and log slope); it is a descriptive sup norm, not a standardized error
measure or RMSE. The full coordinate table and all initial/follow-up values
are saved. The candidate substantially reduces the displacement in these four
settings, but does not eliminate it. In particular, the eight-rating relative
slope remains slightly below truth. A nonzero limit displacement still matters
for coverage as intervals narrow with increasing sample size.

The maximum absolute antisymmetric Jacobian entry is .127-.162 for adjusted
roots, versus at most 1.50e-8 for the raw roots. Thus the adjusted equation is
not locally the gradient of a scalar objective in these coordinates. Its
sampling covariance needs the adjusted Jacobian and adjusted Person scores,
including the transpose of the inverse Jacobian; it cannot reuse the raw-JML
Hessian or claim ordinary profile-likelihood/LRT semantics. Numerical root
agreement is not qualification of this covariance.

### Disposition

This completes the intended small-design **root preflight**, including its
adverse numerical results. It supports further work on the candidate, not
adoption as a default, a bias-free estimator or a formally qualified JML
interval route. Finite-sample recovery, uncertainty, sparse/unequal assignment,
other populations, larger facet structures and scalable approximation of
expectations remain untested. Three starts do not prove global uniqueness.
The next gate is a sample-level solver/covariance implementation checked
against this oracle; further variations of this tiny benchmark alone would
not close that gate.

Evidence: `validation-results/jml-profile-bias-roots-20260927/` contains the
24 initial checkpoints, eight separate follow-ups, resolved coordinates,
start agreement, source hashes and session information. Only local validation
code and the roadmap/review record changed in this increment. No new exported
function, dependency in DESCRIPTION, production estimate, help promise or
NEWS feature claim is introduced.

## Initial help-only verification

The displayed formula was checked against observation tables from the saved
Criterion-owner JML fit, first with its unit weights and then with deliberately
unequal table weights. Both maximum SE discrepancies were zero. Neither calculation refits a model
or validates a weighted estimator. Source and capability help were regenerated, parsed,
checked and rendered as HTML. Logs are retained in the ignored directory
`validation-results/jml-inference-review-20260927/`. Whole-package tests and
external estimators were not rerun for this documentation-only change.

## Sample estimator and matching covariance (2026-09-27)

The [sample runner](jml-profile-bias-sample-20260927.R) now solves the candidate
one-step-adjusted equation on observed response frequencies. This advances the
methodology alongside the package integration review; it does not introduce
an exported estimator or change `fit_mfrm()` results. The retained exact-response
factory supplies Person contributions, and reproduces the previous raw and
adjusted per-pattern arrays within 1e-12. No new package dependency is added.

### Target, equation and sampling unit

Let `u_i(beta)` be the negative-profile-log-likelihood gradient for Person i,
including profiling their ability at each candidate structural parameter beta.
For the same rating design, the candidate contribution is

```
psi_i(beta) = u_i(beta) - E_beta,theta_hat_i(beta)[u_Y(beta)]
mean_i psi_i(beta_hat) = 0
A = derivative_beta mean_i psi_i(beta_hat)
B = mean_i (psi_i - mean(psi)) (psi_i - mean(psi))^T
V = inverse(A) B inverse(A)^T / N
```

The expectation covers **all** response patterns, with their multiplicities;
abilities are profiled anew for the generated patterns. Its generating ability
is the observed Person's fitted ability, not their simulated true ability.
Both that fitted ability and the expectation vary with beta in the numerical
Jacobian. Extreme all-low/all-high Persons contribute their exact zero limits;
they remain in the sample and the denominator. Observation rows are not
independent sampling units here. No ridge, symmetrization of A, pseudoinverse
or raw-JML information substitution is used to make covariance available.

This check samples independent Persons from the explicitly declared ability
mixture (-1, 0, 1 with probabilities .25, .5, .25). It studies the sampling law
of the estimating equation under that iid mixture, not inference conditional
on a fixed collection of heterogeneous Person abilities. The mixture is used
only to generate test data. It is not fitted or supplied to the estimator.
The sandwich targets variation around the candidate's population root under
regularity; it does **not** remove the residual displacement of that root from
the true parameter. Consequently these calculations do not qualify confidence
intervals for the truth. Exact enumeration introduces no Monte Carlo error in
the inner correction; scalable approximate expectations remain separate work.

The method motivation remains the reviewed 2017 Dhaene/Jochmans manuscript
([alternative university-hosted copy](https://www.princeton.edu/~erp/erp%20seminar%20pdfs/dhaene-jochmans.pdf)).
Its profile-score adjustment is a starting point, not a GPCM validity result.
The formula above and its implementation are assessed for this particular
estimating equation and declared sampling unit.

### Prespecified engineering cases and failures

The four existing owner/exposure designs are reused, with **one** 400-Person
sample per design (seeds 20260928–20260931 as integer RNG seeds, not dates),
2 raters, 2 criteria and 3 categories. Each Person has 4 or 8 ratings.
Raw and adjusted calculations use the same observed responses and two fixed
starts, neutral and opposing; no truth start or population-root warm start
is used. CSV response rows, empirical pattern frequencies and all attempts
are retained. This is an implementation check, not a four-cell coverage study.

Raw equations use BFGS likelihood minimization then Newton refinement; adjusted
equations initially use Broyden with line search. Initial sample roots pass
both-start review for 7/8 method/design combinations (15/16 individual starts).
The eight-rating Rater adjustment fails from the opposing start after 150
iterations (score norm .06825). Newton/double-dogleg from that **same** start
resolves the failure and agrees with the successful neutral start within
9.11e-11. This supports the tested fallback, not the original solver's robustness
or global uniqueness. Initial failed attempts and the nonzero initial exit
status remain in their original evidence files.

For the four-rating Criterion raw JML, the Jacobian is ill-conditioned
(`kappa(A)` about 36,810) and the estimated log-slope SE is 1.765. Empirical
frequency perturbations of 1e-4 and 5e-5 have influence-linearization errors
.01459 and .00355, exceeding the prespecified .001 relative tolerance.
Refitting at 1e-5 and 5e-6 reduces those errors below the **unchanged** tolerance
(maximum .000143). The covariance arithmetic is locally consistent, but this
large uncertainty and nonlinear response remain warnings about the example;
passing a smaller-step derivative check does not make its inference useful.

### Results and independent calculation checks

The first relative slope has true value 1.284025. Entries below describe these
single samples, not bias, RMSE or average correction benefit.

| Owner | Ratings per Person | Raw first slope | Adjusted first slope | Adjusted log-slope SE |
| --- | ---: | ---: | ---: | ---: |
| Criterion | 4 | 4.973086 | 1.243343 | .124339 |
| Rater | 4 | 3.329804 | 1.416967 | .110687 |
| Criterion | 8 | 1.322236 | 1.187053 | .054246 |
| Rater | 8 | 1.524772 | 1.297716 | .057497 |

In the eight-rating Criterion sample, adjustment moves the first slope
**farther** from truth. The reduction in the largest error across all five
coordinates does not negate that adverse slope result. These data do not
justify claiming uniformly improved estimation, smaller MSE or correct coverage.

After the two targeted follow-ups, all eight method/design cases pass:
expanded-Person versus frequency-aggregated scores and meat; covariance versus
independently expanded influence contributions; symmetry/positive definiteness;
zero extreme contributions; inverse-N scaling at fixed empirical frequencies;
refusal of rank-one empirical covariance; and actual perturbed-data root
refits at two step sizes. Both-start coordinate disagreement is at most 2.10e-9.
Adjusted Jacobians remain nonsymmetric (.114–.172 maximum antisymmetric entry).
Two Jacobian step sizes agree within the original relative 1e-5 tolerance.
The 1/N scaling check is an algebra check, not permission to treat duplicated
Persons as independent observations. Neither numerical agreement nor rank
review is coverage qualification.

### Integration disposition and next gate

The sample-level equation and matching covariance are now implemented and
numerically checked for this exact small response space. The stage is
**engineering evidence complete after targeted follow-ups; statistical
qualification open**. Before public adoption, specify the intended sampling
interpretation, residual-bias treatment, solver/failure policy and feasible
expectation calculation for longer/sparse/unequal designs. A repeated-sampling
comparison must evaluate failure-aware bias, empirical variation versus SE,
interval availability/width and true-value coverage with Monte Carlo precision.
Do not proceed directly from this sandwich to ordinary likelihood tests or
public formal JML intervals.

In parallel, the current-source portable-calibration public-API test file
passed, with its check-installed fresh-process test skipped in this source-load
run. The capability matrix, README, capability help, portable/GPCM tutorials
and NEWS agree on scoped JML EAP support and unavailable formal JML inference.
This is focused integration evidence, not whole-package completion; the final
installed archive and corresponding platform checks remain open. No runtime
estimator, public inference promise or NEWS feature is added by this research.

Evidence is in `validation-results/jml-profile-bias-sample-20260927/`: original
responses, starts, summary and results, the preserved original runner, separate
follow-up results/resolved summary, source hashes and session information. The
initial failures are not overwritten. The targeted public-API log is retained
there as `public-api-integration.log`.

## Paired repeated-sample decision (2026-09-27)

The [prespecified protocol](jml-sample-comparison-20260927.md) and
[runner](jml-sample-comparison-20260927.R) evaluate the adverse single-sample
Criterion-owner case above: 2 raters, 2 criteria, 3 categories, 8 ratings per
Person, 400 independently sampled Persons and the same three-point ability
mixture. There are 200 new, paired datasets; neither the earlier engineering
samples nor truth/root starting values enter the evaluation. This is a
one-design method-development comparison, not release qualification.

Both methods supply reviewed estimates and covariance in all 200 datasets.
The adjusted equation required its prespecified Newton fallback from one
original start in replicates 33 and 42; the original Broyden attempts are
retained. No fallback, tolerance or replication count was changed after the
run began, and no planned dataset was omitted. Two reviewed starts must agree.
These remain local numerical checks, not global-optimum certificates.

The primary target is relative **log slope**, with true value .25. The raw
reference and adjustment both use their own Person-level sandwich in this
research calculation. These are not the public package's existing exploratory
SEs, and the table does not describe a released formal JML interval API.

| Primary log-slope outcome | Raw profile JML | One-step adjustment |
| --- | ---: | ---: |
| Bias (MCSE) | .154730 (.005933) | -.012427 (.003805) |
| RMSE | .175912 | .055090 |
| Empirical SD | .083899 | .053804 |
| Root mean estimated variance (SE scale) | .090879 | .058318 |
| Mean 95% interval width | .354204 | .227814 |
| Truth inclusion | 124/200 = 62.0% | 193/200 = 96.5% |
| Wilson 95% MC interval for truth inclusion | 55.1–68.4% | 93.0–98.3% |
| Method-specific population-root inclusion | 191/200 = 95.5% | 193/200 = 96.5% |
| Interval availability | 200/200 | 200/200 |

The paired squared-error difference (adjusted minus raw) is -.027910, MCSE
.001992, with normal 95% MC bounds [-.031815, -.024005]. It satisfies the
prespecified criterion for reduced log-slope MSE **in this design**. All five
coordinate summaries and paired comparisons are retained; the other coordinates
are secondary, not additional prespecified primary tests. The earlier adverse
single-sample slope result is not removed or contradicted by an average benefit.

The raw truth-coverage upper MC bound is below .925, failing the declared
95%-inference criterion for this reference calculation. Its approximately
nominal population-root coverage, together with the previously measured
nonzero root displacement, supports bias as the main explanation in this
case rather than a broken sandwich implementation. This is not proof that
variance approximation never matters. The root-mean estimated variance, expressed on the SE scale, is about 8%
larger than empirical SD in both methods. Adjusted
truth coverage is compatible with 95% at this Monte Carlo precision; it does
not demonstrate exact calibration or universal coverage. Its residual bias
and population-root displacement persist and can matter as N increases.

### Decision and remaining scope

Retain the adjustment as a promising research candidate and its separate
sandwich as the matching variance implementation. Do not replace the public
JML estimator, publish formal JML intervals or extrapolate to sparse/unequal
exposure, other populations, many facet levels, anchors, weights or separate
slope/step owners. This result answers the declared finite question; no automatic
replication extension or new factorial grid follows it. The next method gate
is a justified residual-bias/sampling-target policy and tractable expectation
calculation for relevant larger/incomplete designs, with independent evaluation
of any changed procedure. Package integration continues separately.

All checkpoints, initial/fallback attempts, source/protocol hashes, sessions,
per-coordinate estimates/intervals, dispositions and paired summaries are in
`validation-results/jml-sample-comparison-20260927/`. Hashes stayed unchanged
through both workers and summary generation. Summed worker time was 947.301
seconds; workers ran concurrently, so this is not elapsed wall time. An
independent Python recomputation of bias, RMSE, truth/root inclusion and paired
MSE/MCSE from all exported rows agrees within 1e-12. No fitted case was rerun
for that aggregation check. Public help and NEWS continue to state that formal
JML slope inference is unavailable; this research creates no public feature claim.

## Method decisions before broader JML inference

The 200-dataset result does not make the one-step equation a consistent
estimator of the generating truth when ratings per Person stay fixed. The
existing exact roots already show nonzero displacement. If estimates
concentrate around that displaced root while interval widths decrease with N,
truth coverage can deteriorate even with a correctly implemented sandwich.
Increasing N or simulation replication does not remove this methodological
problem. Do not subtract the benchmark's known root displacement from user
estimates: that would use unavailable generating parameters/population information.

The next method work must settle these contracts before another broad study:

| Decision | Retained starting point | Required extension or rejection condition |
| --- | --- | --- |
| Sampling target | Current evidence samples independent Persons with one common complete rating design and fixed structural truth. The estimator is not given their generating mixture. | Define whether new incomplete rosters are fixed/stratified or sampled with Persons. Conditional means and between-roster variation must not be conflated in the meat matrix. Ability-dependent assignment is a different question; connectivity alone does not establish identification or accuracy. |
| Residual bias | One-step score recentering improves the examined finite-sample MSE but leaves a displaced population root. | Before general truth intervals, justify a bias treatment or a defensible restricted inferential scope. Further score-recentering is only a candidate: show that reducing mean score does not destroy rank/information or produce nearly zero equations everywhere. A narrower scope is not proof that bias vanishes. |
| Unequal/sparse assignments | Existing exact calculations enumerate one small common response space; a Person is the sampling unit. | Contributions and correction expectations must use each Person's actual assigned rows, shared parameter constraints and extreme-response limits. An unassigned rating must not be imputed to make enumeration convenient. Distinguish underidentified samples from failed numerical searches. |
| Scalable expectations and covariance | The present correction and its derivative use exact finite sums; no inner Monte Carlo noise is present. | An approximate correction must control value and derivative error, retain numerical randomness/settings, and address the extra approximation uncertainty. It cannot inherit the exact-sum covariance qualification merely by increasing the number of draws. |

The next implementation question is therefore a design-aware adjustment with
a justified bias/information tradeoff, rather than exposing the current small-
design solver through `fit_mfrm()`. The existing exact and repeated-sample
records remain reference evidence for any changed procedure; fitting cases
used to choose a new method are not its independent validation. This research
can progress alongside integration but does not delay fixes to admitted public
scoring/reporting workflows or make a general JML inference claim part of the
current release by implication.

## Design-aware iterations, sparse rosters and numerical approximation

The [method-development contract](jml-design-adjustment-20260927.md) and
[design-aware implementation](jml-design-adjustment-20260927.R) now extend the
sample equation to actual four-cell exposure vectors, including zeros for
unassigned cells. The previous exact/sample/comparison sources are unchanged.
This is excluded research code, not a new public estimator or formal interval.
The motivation is the previously reviewed Dhaene/Jochmans iterative adjustment.
The [author manuscript](https://jochmans.github.io/preprints/score%20adjustments/Dhaene-Jochmans%20adjscore.pdf)
also explicitly cautions that convergence of iteration does not guarantee
fixed-stratum-length consistency: an unbiased limit must retain information.
No general theorem from that paper is asserted for this GPCM.

### Residual bias: improvement is not monotone or complete

For a fixed roster, U_k = (I - P_beta)^k U_0 uses that roster's generated
responses and each generated response's reprofiled Person ability. The sample
fit never receives generating abilities, population mixture weights or true
structural coordinates. The population reference uses the earlier declared
mixture only to measure remaining displacement. Both are five-parameter roots,
with no structural coordinates held at truth.

| Design | Raw log-slope displacement | Order 1 | Order 2 | Order 4 |
| --- | ---: | ---: | ---: | ---: |
| Complete, eight ratings per Person | +.156235 | -.011049 | -.005072 | +.000760 |
| Sparse, two fixed five-rating rosters | +.611867 | -.013540 | -.019553 | -.005396 |

These are population estimating-equation displacements from true log slope
.25, not finite-sample bias or coverage estimates. In the sparse case order 2
has **worse parameter displacement** than order 1 even though its expected-score
sup norm is smaller. Reduced score norm cannot select correction order. At
order 4 the largest displacement across all five coordinates is .000760 in the
complete case and .006068 in the sparse case (order 1: .017707 and .038860).
Residual bias remains, particularly relevant as N increases at fixed exposure.

The minimum Jacobian singular value divided by score RMS is .15439/.14853
for complete order 1/4 and .12109/.11510 for sparse order 1/4. Thus these
examined roots do not show collapse of local information as the fourth
adjustment improves displacement. This is neither a proof for higher orders
nor a global-uniqueness certificate. All 16 planned population/sample/order
cases agree across two reviewed starts within 1.99e-10. Six original sparse
opposing-start attempts fail; their prespecified Newton fallback resolves them.
Both attempts remain in the evidence.

The 400-Person sparse sample also illustrates the limit of population results:
its first/fourth adjusted log slopes are .041711/.045680 (truth .25), with
matching fixed-roster SEs .099983/.105267. An improved population limit does not
make every realized estimate close to truth. These single samples are not
coverage replications, and no order is adopted on their basis. All five
coordinates, SEs and true-reference differences are exported in parameters.csv.

### Sparse and unequal allocation: matching covariance

The complete and sparse factories reproduce the earlier complete-roster
calculation for both slope owners, two exposure lengths and two parameter
points. Sparse rosters (2,1,0,2) and (0,2,2,1) use only assigned cells, with fixed
200/200 Person counts. No unassigned response is imputed. The derivative
includes the fitted Person abilities and the full iterated correction.

Independent Persons drawn within fixed roster strata use within-roster score
centering in the sandwich meat. Random roster sampling adds the between-roster
mean-score covariance. The implementation verifies this decomposition and
expanded Person influence covariance. These assumptions do not cover a design
conditional on a fixed, nonrandom vector of Person abilities, outcome-dependent
missingness, or shared random-rater dependence. Connectivity alone is not a
sufficient inferential condition. An isolated-cell design is correctly refused
for deficient covariance rank without a ridge or pseudoinverse.

An additional engineering sample uses four versus six ratings per Person,
with 240/160 Persons and exposures (2,1,0,1)/(0,2,2,2). Actual response rows
and Person counts are saved. Both orders initially fail the two-start gate:
neutral starts converge, whereas opposing starts and their first Newton
fallbacks drift to small slopes and reach the iteration limit. A
[targeted follow-up](jml-design-unequal-followup-20260927.R), declared after this
failure, retries the **original opposing start** with stepmax .25 instead of 1.
The iteration limit and acceptance tolerances are unchanged; no truth or
successful-root initialization is used. Both orders then agree with their
neutral roots within 4.25e-11. Initial failed attempts and their nonzero process
exit are retained in unequal.rds/log, separately from the follow-up.

In that unequal sample the order-1/order-4 log slopes are .251853/.247794 and
SEs .077863/.077852. Expanded influence covariance and analytic-gradient checks
pass. Actual within-roster frequency perturbations followed by refitting at
two step sizes agree with the derivative prediction within 1.20e-9 relative
error; the five-rating sparse case agrees within 1.21e-8. This supports the
local covariance calculation and the targeted solver repair, not broad
coverage or universal convergence. A generally adopted solver policy remains
an open decision; the original policy is not relabelled robust.

### Approximation: bounds for scores, derivatives and covariance

The expectation implementation generates probability columns in blocks and
uses count-pattern multiplicities. It avoids storing a full transition matrix.
It still enumerates the response count space and explicitly refuses more than
50,000 count patterns; this is **not** a scalable solution for arbitrary large
rosters or many facet levels. Block size 1 versus 16 produces matching scores,
and multiplicities reconstruct the full ordered response space.

The [approximation audit](jml-design-approximation-20260927.R) implements
unnormalised probability pruning with an omitted-mass bound propagated through
each iteration. The bound also propagates to centered finite differences at
the chosen step size. Finite-difference discretization is checked separately;
these are bounds on deterministic truncation, not Monte Carlo SEs. All examined
score/Jacobian discrepancies lie within the derived bounds (with the declared
floating-point allowance).

At the exact sample roots for orders 1 and 4 in both designs, omitted-mass
budgets 1e-3 and 1e-6 fail the declared derivative-error certification, while
1e-10 and 1e-14 pass. Passing same-root covariance discrepancies are at most
3.34e-8 relative to the exact calculation. **Failure to certify is not proof
of large actual error**: some rejected cases have small observed error but
bounds too loose for the tolerance. At very small budgets a sparse case drops
no mass at all; successful agreement is not evidence of useful acceleration.

The audit evaluates approximate covariance at exact roots, not approximate
estimator convergence or formal coverage. It adds no stochastic approximation,
measures no general speed gain, and does not transfer exact-space qualification
to a future Monte Carlo implementation. Before approximate fitting, retain a
smooth/reproducible expectation calculation, error control at the candidate
root and its Jacobian, and a policy for any added simulation uncertainty.

### Decision and remaining work

The three requested issues now have a connected research implementation:
iterated correction, actual-roster contributions and design-specific sandwich,
and controlled deterministic approximation checks. Engineering evidence passes
after the separately recorded unequal-roster solver repair. Residual-bias
elimination, a generally justified order/solver policy and scalable expectations
are **not resolved**. The next decision is how to select or restrict the
correction without using generating truth, with independently evaluated
performance and a declared exposure/population scope. Simply choosing order 4
or increasing sample size would not answer that question.

All results, failed/successful attempts, observed responses, source hashes,
parameter tables and checks are in
validation-results/jml-design-adjustment-20260927/. An independent Python
aggregation checks exported displacements and approximation bounds. No broad
simulation grid, whole-package test rerun, runtime API/default change, NEWS
feature, commit/push or publication is included. The previously frozen public
archive remains unchanged; this research does not inherit or alter its checks.

## Order sensitivity without generating truth

The [comparison implementation](jml-order-sensitivity-20260927.R) and
[method contract](jml-order-sensitivity-20260927.md) address the next decision:
can observed stability select a correction order without known truth? They
reuse the three saved sample datasets and reviewed roots from the preceding
increment. No new sampling simulation or population-root calculation is run.

### Paired comparison, not independent estimates

For orders k and l fitted to the same Persons, the difference's influence is
IF_l - IF_k. Its local covariance is the sum of those outer products divided
by N squared. The implementation retains within-roster centering for the fixed
allocation target, and verifies the equivalent expression
V_k + V_l - C_kl - C_lk. Adding the two marginal variances would omit the
substantial positive covariance in these samples. The calculation describes
variation about each method's estimating-equation root; it is not a validated
interval/test for the generating parameters or evidence that either root is
unbiased.

The research comparison requires aligned Person identities, strata, parameter
names and sampling targets, plus reviewed roots. It returns every coordinate
comparison and `selected_order = NA`, with no p-value, cutoff or automatic
stopping recommendation. Same-influence comparisons explicitly return zero
difference variance and an undefined standardized ratio. Invalid alignment,
mixed fixed/random targets and unreviewed roots are rejected.

| Design, order 1 to 4 | Log-slope change | Later estimate's SE | Paired difference SE | SE if incorrectly treated as independent |
| --- | ---: | ---: | ---: | ---: |
| Complete | +.008556 | .057407 | .002718 | .079742 |
| Sparse | +.003969 | .105267 | .005708 | .145182 |
| Unequal lengths | -.004059 | .077852 | .005326 | .110107 |

For the complete sample, this change is .149 times the later estimator's SE
but 3.148 times the paired difference SE. These are different comparisons,
not contradictory results. They are descriptive ratios, **not z-tests** with
an asserted normal calibration. Smallness relative to the estimator's SE alone
does not identify a negligible order effect or justify stopping. Nor does a
large paired ratio establish practical importance or prove a method's bias.

Log slope is not the only relevant coordinate. Across the retained pairs,
maximum change relative to the later estimator's SE is .354/.302/.510 for the
complete/sparse/unequal samples. The largest paired ratios are 9.581 for Step1
(complete, 1 to 2), 8.868 for Criterion (sparse, 1 to 2) and 8.470 for Step1
(unequal, 1 to 4). All five coordinates are retained; these maxima are not
multiplicity-adjusted significance results or independent hypotheses.

### Verification and method decision

Expanded Person influences reproduce each stored covariance. Difference
covariance agrees with the separate covariance/cross-covariance identity and
is positive semidefinite within numerical precision. Perturbing the same
sparse empirical frequencies for both orders 1 and 4, then refitting both,
reproduces the predicted change in their difference at two step sizes; maximum
relative discrepancy is 6.09e-8. Eight targeted refits replace a new simulation
study. Input/source hashes, saved comparisons and independent Python checks of
exported differences/ratios are retained under
validation-results/jml-order-sensitivity-20260927/. Previous research sources
and results are unchanged.

Adding the same coordinate displacement to all candidate estimates leaves
these difference-based summaries unchanged. This algebraic check is not a
new generated model or a sampling experiment; it shows why these summaries
alone cannot identify a common bias component. Agreement across examined
orders also gives no bound on unexamined orders or their limiting root. The
previously reviewed original paper's warning about fixed-length consistency
therefore still applies.

The resulting method decision is to **retain explicit research orders and
paired sensitivity reporting, without automatic order selection**. Do not
convert a small change, a nonsignificant test, a smaller equation residual,
or a stable Jacobian into a claim of bias elimination. An eventual adaptive
rule must name the target and loss/exposure scope, assess the whole selection
procedure independently, and account for selection in uncertainty evaluation;
it cannot inherit one fixed order's covariance as if selection had not occurred.
The present comparison does not solve that qualification problem. No public
runtime, help/NEWS feature, automatic stopping default, formal JML interval or
release claim is introduced by this increment.

## Exact expectations on owner totals

The next computational step changes the calculation, **not the correction
order or estimating equation**. The [derivation and check contract](jml-total-expectation-20260927.md)
and [implementation](jml-total-expectation-20260927.R) replace full response
count-pattern enumeration by a transition on the two slope-owner score totals.

Within an owner, the common ability factor cancels when conditioning on its
total score. Polynomial convolution computes total probabilities and conditional
cell-category counts. At a fixed pair of totals, the profiled ability is fixed
and the raw structural score is affine in the cell counts. Consequently its
conditional expectation can be calculated exactly in this smaller state space.
A recursion on these states reproduces each iterated correction. This is a
model-specific algebraic identity, not a Monte Carlo approximation or a generic
claim for every GPCM structure.

Crucially, the actual observed response score is retained for each Person;
only its correction expectation is compressed. Replacing observed responses
by conditional averages would remove within-total response variation and
change the sandwich meat. The implementation does not make that substitution.
Assigned exposure, zero/unassigned cells, extreme-score limits and the matching
fixed-roster covariance remain as in the previous implementation.

### Equivalence and larger-sample engineering check

Both owner conventions, four complete/sparse/unequal exposure patterns, two
parameter points and orders 0/1/2/4 were compared against the frozen response
enumeration. Every response score agrees within 3.68e-12. Independently grouping
full response masses at generating abilities -1, 0 and 1 verifies conditional
expectation invariance within the same tolerance. At the six retained sample
roots (three designs, orders 1/4), the maximum relative Jacobian discrepancy
is 2.62e-10 and covariance discrepancy 1.20e-9. This reuses the prior fitted
samples; it does not rerun their population or sampling studies.

A separately declared computational example uses 400 Persons and exposure
(8,8,8,8), giving 32 ratings per Person. Cell responses are drawn directly;
neither their generating abilities nor truth is passed to fitting. The old
factory refuses this 4,100,625-count-pattern space under its existing resource
guard. The total-state calculation uses 1,089 states and blocks transition
probabilities without constructing all response patterns.

| Explicit adjustment order | Reviewed starts | Log-slope estimate | Matching local SE | Two-start fitting seconds |
| --- | ---: | ---: | ---: | ---: |
| 1 | 2/2 | .246107 | .023962 | 10.683 |
| 4 | 2/2 | .246759 | .024042 | 15.238 |

The two-start differences are at most 1.34e-12. All initial attempts pass;
no fallback is needed in this sample. Independent central differences of the
profile criterion match its analytic gradient within 7.88e-10. Expanded Person
influence covariance and exact extreme limits pass. Actual empirical-weight
perturbations followed by refitting at two step sizes agree with the influence
prediction within 2.48e-9 relative error. Both fits and every structural
coordinate/SE are retained. These are engineering results from one sample,
not estimates of bias, RMSE, coverage or a new capacity guarantee.

On the same small eight-rating problem, three local evaluations of order 4
have median elapsed time .021 seconds for enumeration and .012 seconds for
total states. These short timings are environment-dependent, exclude setup,
and are not a general speed benchmark. The larger-sample timings above include
two starts and their Jacobian review, but exclude later perturbation checks.
They describe the tested initial implementation; the final cleanup does not
inherit a newly measured timing claim.

A subsequent single-Person input check reproduced an array-dimension defect:
R simplified its two totals to a vector. An explicit matrix shape repairs it.
One-Person extreme/non-extreme comparisons pass within 3.42e-13; invalid counts,
state-limit overflow and an unsupported pruning request are rejected. Removing
an unused variance calculation is the only other final cleanup. The initial
source is preserved, and focused comparisons produce identical outputs before
and after those repairs on the multi-Person complete/sparse/unequal and larger
inputs. Original run hashes and final source hashes are separately retained.

### Method decision and remaining boundary

Use exact owner-total expectations as the candidate computational route for
this research scope, rather than introducing stochastic expectations solely
to bypass response enumeration. No extra Monte Carlo variance term is needed
for this exact reformulation; numerical root/derivative accuracy still needs
its own checks. The earlier probability-pruning results remain separate
approximation evidence and are not silently used here.

The tested scope remains two fixed raters, two criteria, three categories,
shared step/slope ownership and conditionally independent responses. There is
a 5,000-total-state guard and explicit refusal of numerical mass underflow.
The total-state space can itself grow quickly with more slope owners; larger
facet counts, dependent/testlet responses and arbitrary designs are not qualified.
The single 32-rating sample does not qualify a statistical exposure range.

This resolves a concrete computational obstacle for the tested structure.
It **does not remove the remaining statistical bias, choose an order or qualify
formal JML intervals**. The active method gate is now statistical scope and a
prespecified fixed-order procedure (including its solver), evaluated independently
of method-development examples. Broader scalability should be reopened for a
specified roster/model need, not by automatically adding more timing cases.
No public runtime/default, NEWS feature, full package test or publication is
included. Evidence is in validation-results/jml-total-expectation-20260927/.

### General-input follow-up (2026-09-28)

The [general-input implementation check](jml-general-inputs-20260928.md) extends
the internal equation and covariance beyond this reference's fixed coordinates.
It includes arbitrary column/level labels, independent full-response checks
with three judges and four categories, and a two-roster observed sample with
matching roots and Person covariance. The subsequent internal runtime solver
retains explicit order, attempts and separate point/covariance outcomes, and
an internal adapter reuses native parameter tables. The public fit/output
contract remains unfinished. This computational extension
does not change the residual-bias findings, choose an order or establish wider
coverage. The earlier scope and timings above refer to their recorded source.

## September 30: structural target before computational optimization

The user requested that mathematical/statistical adequacy take priority over
further CRAN runtime work. The current public explicit-order fitting/output
route is documented in the general-input record; formal structural confidence
intervals and an automatic order rule remain unfinished. This review does not
withdraw that agreed work or present a local root covariance as its completion.

The [reconciliation script](jml-inferential-target-audit-20260930.R) joins the
saved exact population roots with the completed order study. All 400 datasets,
both orders and all five free coordinates are retained. Bias, empirical SD,
root-mean estimated variance, truth coverage and population-root coverage were
independently recomputed from exported per-replicate rows and agree with the
saved summaries within 1e-12. Original input hashes are unchanged. No response
generation, fitting, quadrature change or new inference test was performed.

The distinction that governs further work is beta_k* versus beta_0: the root
of the expected order-k equation versus generating structural truth. With
mean-equation derivative A and design-appropriate score variance B, the current
covariance has the form A^{-1} B A^{-T}/N. The implementation retains the full
nonsymmetric derivative and uses the transpose on the right; the actual Person
scores and within-roster centering match the fixed-allocation target. Its
mathematical target remains variation around beta_k*. It cannot remove the
displacement beta_k* - beta_0. Under a valid root-centered normal approximation,
nonzero fixed displacement and shrinking intervals cause truth coverage to
tend to zero at fixed per-Person exposure. This deduction is conditional on
those assumptions, not a newly observed finite-sample failure.

| Retained condition | Order | Log-slope root displacement | Displacement / local SE at N=400 | Observed truth coverage |
| --- | ---: | ---: | ---: | ---: |
| Criterion / unequal | 2 | +0.007734 | 0.1061 | 94.5% |
| Criterion / unequal | 4 | +0.001083 | 0.0151 | 93.5% |
| Rater / sparse | 2 | -0.010706 | 0.1157 | 94.5% |
| Rater / sparse | 4 | -0.007277 | 0.0769 | 94.5% |

All 20 coordinate/condition/order combinations have nonzero retained root
displacements. Their absolute displacement/local-SE ratios at N=400 range
from 0.0015 to 0.1858. These are oracle diagnostics for the saved generating
conditions, not statistics available to an analyst or proof of poor coverage
at N=400. The earlier N=1600 population calculation halves SE and doubles these
ratios; this is algebraic scaling, not 1,600-Person simulation evidence.
Observed truth coverage across the 20 combinations is 93–98%, with only 200
independent replicates per condition. It cannot certify a general coverage claim.

The retained paired log-slope MSE difference (order 4 minus order 2) is
-0.0001833 in Criterion/unequal (95% Monte Carlo interval
[-0.0003182, -0.00004835]) and +0.0005310 in Rater/sparse
([+0.0002449, +0.0008171]). Thus smaller population displacement does not give a
uniform finite-sample MSE improvement. Other coordinates remain in the audit;
these are retained paired comparisons, not newly selected superiority tests.
More iterations, a stable equation or selecting the smallest reported SE
cannot provide a justified default order from these findings.

Sections 1.2–1.3 of the previously reviewed
[Dhaene–Jochmans manuscript](https://jochmans.github.io/preprints/score%20adjustments/Dhaene-Jochmans%20adjscore.pdf)
were rechecked: their finite-order large-stratum argument is distinct from
fixed-stratum-length consistency and an informative limiting equation.
No theorem for this GPCM is imported by analogy. The current scope decision
therefore still needs a justified bias treatment or declared growth regime,
followed by evaluation of that exact procedure. Existing finite-condition
success does not justify silently changing the default or exposing formal CIs.

Audit outputs are under `validation-results/jml-inferential-target-audit-20260930/`:
all-coordinate table, retained paired MSEs, input hashes and session. The
authoritative order of remaining work is in the
[internal roadmap](internal-roadmap-0.2.4.md#next-work-one-ordered-queue).

## September 30: covariance sampling target and finite-roster centering

Question: does the current covariance describe new independent Persons, or
new responses from the same Persons with their abilities fixed? This matters
because JML's absence of a parametric ability distribution does not identify
the repeated-sampling target of a sandwich covariance.

At a saved adjusted-equation population root, let U be one Person's actual
score vector, g the assignment pattern and a the generating ability. Write
m_g(a) = E[U | g,a], mu_g = E[U | g], and pi_g for the pattern proportion.
The law of total covariance gives three distinct population meats:

* Fixed abilities and assignment composition:
  B_response = sum_g pi_g E_a[Var(U | g,a)].
* New independent Persons, fixed assignment counts:
  B_fixed = B_response + sum_g pi_g Var_a(m_g(a)).
* New independent Persons and random assignment patterns:
  B_random = B_fixed + Var_g(mu_g).

All are evaluated at the same root and transformed by the same full,
nonsymmetric Jacobian: V = A^(-1) B A^(-T)/N. For the first comparison,
the fixed ability frequencies match the saved population masses, so the
limiting equation and derivative are the same. Arbitrary fixed abilities
could change both. The last two added matrices are positive semidefinite.
Neither is a bias correction, and neither is shared-rater random-effect
uncertainty. Random assignment here means joint sampling of Persons and
patterns; it does not impose independence between assignment and ability.

The current sample implementation centers within observed assignment patterns
for `fixed_rosters` and globally for `random_rosters`, matching the second
and third targets. The repeated-sample study drew full response patterns
from each roster's ability mixture, not from a fixed list of individual
abilities. The interpretation is therefore internally consistent. Section 2
of [Dhaene and Weidner (2023)](https://arxiv.org/html/2301.13736v2#S2) also
separates a specified conditional response model from an unrestricted
distribution of latent effects conditional on covariates. Their MLE plug-in
connection is in section 8.1; neither point makes its general inference
claims automatic for this GPCM. This is a targeted source recheck.

The existing `jml-inferential-target-audit-20260930.R` now reconstructs exact
response probabilities at the three generating abilities per roster and
uses the saved score vectors, roots and Jacobians. It reuses all 12 reviewed
corrected cases (both owners, both designs, orders 1/2/4), without simulation,
refitting or changing the original evidence. At every case, probability
normalization, ability-mixture reconstruction, total-covariance decomposition,
positive-semidefinite added components and stored covariance agree to 1e-12
absolute tolerance. Input/source hashes are retained alongside the output.

| Order | Ability-composition share of fixed-roster variance, range across 20 coordinates |
| --- | ---: |
| 1 | 0.00197%–0.09962% |
| 2 | 0.00103%–0.05336% |
| 4 | 0.0000871%–0.02675% |

These small shares in the retained conditions are not a bound for other
ability distributions or designs. The new CSV `sampling-decomposition.csv`
retains all 60 coordinate results, including response-only, ability and
assignment-composition terms; no coordinate was selected for a favorable
conclusion. These are population linearizations, not new finite-sample
coverage results.

There is a separate finite-roster normalization issue. With n_g iid Persons
in roster g, at a known fixed root and Sigma_g = Var(U | g), the implemented
sample-centered meat has expectation

    E[Bhat] = (1/N) sum_g (n_g - 1) Sigma_g,
    B_fixed = (1/N) sum_g n_g Sigma_g.

Multiplying each roster's centered cross-product by n_g/(n_g-1) would remove
this particular finite-sample deficit at a known root. It would not make a
fitted nonlinear sandwich unbiased, remove structural displacement or
establish confidence-interval coverage. The current asymptotic meat is
consistent with a fixed number of sufficiently populated rosters under the
usual independent-Person moment and regular-root conditions. With many tiny
rosters that argument cannot simply be reused. For example, n_g=2 halves
the expected within-roster centered cross-product relative to its population
target; the API's two-Person minimum is numerical, not statistical permission.

For the saved N=400 designs, applying the same saved Jacobian to E[Bhat]
gives coordinate variance ratios 0.994544–0.995227 relative to B_fixed.
This calculation is explicitly at the population root; it is not the
expectation of the fitted variance estimator in the 400 datasets. A divisor
change would address only this small normalization effect in those designs.
It cannot be used to close the residual-bias decision or explain all observed
SE/coverage differences. No numeric estimator or covariance change is made.

Public output now makes the repeated-sampling basis explicit in summary,
report and saved-result tables, and help explains the ability-population and
small-roster assumptions. Existing estimates and covariances are retained.
The remaining D1 task is structural-bias treatment or a justified exposure-
growth regime, followed by evaluation of the specified procedure. In
particular, the T^(-k-1) bias rate stated as Conjecture 1 in Dhaene and Weidner
is not a GPCM theorem; it cannot alone authorize formal structural intervals.

Verification of this change: the existing `jml-adjustment` and
`jml-public-workflow` test files pass without failures or warnings, including
the saved numerical reference, full-Jacobian covariance and report/export/
reopen checks. The updated Rd file parses and agrees with roxygen generation.
No whole-package check, simulation, Windows run or timing claim is added.
