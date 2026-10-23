# Population-model identification review

Date: 2026-09-10. Status: bounded diagnostic review complete. Production code
and inference restrictions are unchanged; ordinary estimated-population
inference and the broader 0.2.4 release remain unapproved.

The September 10 numerical record below retains its original source and scope.
The [October 2 analytic extension](#october-2-gpcm-identification-and-target-specific-invariance)
adds current-source constraint/alias arguments for one-/two-family GPCM and
latent regression. It adds no fits or numerical derivatives and does not
requalify the September 10 numerical examples. The subsequent
[PCM certificate](#october-2-exact-normal-pcm-certificate-and-saved-design-application)
derives continuous-model identification and applies its assumptions to the
four saved October 2 PCM regression designs, without refitting them. The
[repeated-slope-owner extension](#october-2-gpcm-certificate-from-repeated-slope-owners)
then covers the four corresponding one-family GPCM designs using their
within-Person pairs, with a separate treatment of sample-boundary existence. The
[boundary follow-through](#october-2-population-boundaries-and-retained-response-support)
uses their realized category/order support to narrow escaping parameter paths
and derives the natural-variance boundary score. The
[boundary-information extension](#october-2-zero-variance-information-and-inference)
separates finite boundary identification, efficient variance information and
the constrained sampling law; it does not qualify an observed boundary fit. The
[PCM numerical follow-through](#october-2-pcm-zero-variance-numerical-qualification)
then qualifies the four saved PCM boundary candidates and compares them with
the retained interior vectors using continuous-normal integration. The
[interior information follow-through](#october-2-pcm-continuous-score-information-and-local-refinement)
then separates fixed-grid error from nonstationarity and qualifies four local
corrections using independent continuous scores and observed information. The
[public-fit follow-through](#october-3-coherent-pcm-public-outputs-and-a-gpcm-zero-loading-bound)
now constructs four coherent public PCM fits and excludes the entire GPCM
all-zero-scaled-loading boundary by a convex relaxation. Surviving-loading
faces and sampling inference retain their separate obligations. The October 4
output extensions below add experimental structural and population intervals
for qualified RSM/PCM regression fits, preserving the historical records and
the distinction between numerical agreement and sampling qualification. The
[current roadmap](internal-roadmap-0.2.4.md#mathematical-review-before-numerical-efficiency)
owns sequencing and current output decisions.

## Question and why these checks answer it

Why do RSM/PCM models estimating a conditional-normal Person population retain
`design_rank_not_evaluated`, despite the independent information agreement in
the [use-condition audit](mml-use-condition-audit-record-0.2.4.md)? Is local
identification actually missing, or is a broader readiness requirement pending?

Trace the pre-fit additive design, post-fit nonlinear score classification,
and shared readiness record. Reuse both retained 80-Person, six-rating,
three-category latent-regression examples at q31/q61/q121. Independently
differentiate their continuous-normal marginal probabilities to check whether
the fixed-quadrature local rank is a numerical artifact. Then use binary
intercept-only negative/paired controls to separate a real identification
failure from merely incomplete readiness instrumentation. Finally inspect a
small positive variance to distinguish local rank from precision.

This is a numerical/mathematical diagnostic, not a new parameter-recovery,
coverage, or full-model GPCM study. The six stored parameter vectors represent
two datasets, not six replications. Two additional datasets are deterministic
design controls. Two current-source population refits and two control fits
check actual readiness behavior.

## Source finding

`audit_mfrm_estimability()` audits population regression coefficients in the
linear predictor but excludes `log_sigma2`. Its `complete` flag is false
whenever a nonlinear optimizer block is present. The pre-fit additive ranks
are 6/6 (RSM) and 7/7 (PCM); the full models have 7 and 8 free coordinates.
Subsequent observed-pattern score audits already give full local rank in all
six stored fits. Their [existing local classifier](gpcm-nonlinear-local-estimability-p1u-record-0.2.3.md)
deliberately has no readiness effect. The shared fit record therefore retains
`EstimabilityState = not_evaluated` and `InferenceReady = FALSE`.

Exhaustive enumeration would involve 80 distinct covariate/design rows times
729 response patterns, or 58,320 evaluations, exceeding the existing 5,000
limit. This is not an absence of local evidence: full observed-pattern score
span is already a sufficient subset-of-support condition for positive
fixed-quadrature expected information. Raising the enumeration cap alone
would not settle global identification, boundary behavior or precision.

## Independent continuous-integral result

The [runner](population-identifiability-review-0.2.4.R) reuses the independent
RSM/PCM category-probability implementation, not the package's response kernel.
For each Person it integrates over the whole real line with adaptive normal
integration (`rel.tol = 1e-11`, `abs.tol = 1e-13`), then differences the log
marginal in every free coordinate at steps 1e-4 and 5e-5. It aligns Person rows
and optimizer coordinates before comparison. Unscaled score-matrix SVD uses
relative rank tolerances 1e-12, 1e-10 and 1e-8.

| Model | Continuous score rank, all three grids | Smallest singular value | Condition number | Maximum q61/q121 score discrepancy |
| --- | ---: | ---: | ---: | ---: |
| RSM | 7/7 | 3.23574 | 4.49540 | 2.132e-10 |
| PCM | 8/8 | 2.67843 | 6.30603 | 2.786e-10 |

The derivative-step discrepancy is at most 8.305e-10. These results support
local full rank at the retained parameter vectors under independent continuous
integration; they are not a symbolic/global identification proof or a uniform
guarantee over other data and parameter values.

The [numeric summary](population-identifiability-review-summary-0.2.4.csv)
retains one comparison miss: RSM q31 has a maximum Person-score difference of
1.871e-7, exceeding this audit's 1e-7 numerical comparison bound. PCM q31 is
9.561e-8. Their objective differences are only 4.372e-8 and 2.288e-8, both
within the 1e-6 objective bound. The rank conclusions are unchanged and the
q61/q121 differences are much smaller. This small q31 derivative discrepancy
is not evidence of materially incorrect SEs or a new universal grid rule.

The initial runner stopped at that first mismatch. The complete execution
keeps the original bounds and failed comparison, and continues the remaining
grids. Its initial source/log and inspected result are archived separately;
the criterion was not relaxed to obtain a pass.

## An exact variance/difficulty ambiguity and a paired control

Consider a binary RSM, centered Rater difficulties `(b, -b)`, population mean
zero, and variance `v > 0`. If every Person receives only one rating, then

```text
p1(v,b) = integral logistic(sqrt(v)*z - b) phi(z) dz
p2(v,b) = 1 - p1(v,b).
```

For any positive `v`, `p1` is continuous and strictly decreasing in `b`, with
limits 1 and 0. Hence a unique `b(v)` gives `p1 = 0.3` and `p2 = 0.7`. Distinct
variance/difficulty pairs have exactly the same observed response distribution.
This is an actual identification ridge, not just an inconclusive first-order
rank deficiency. Increasing the number of independent singly rated Persons
cannot distinguish these points in this intercept-only design. The mean-zero
curve lies inside the fitted model with a free population intercept.

The deterministic negative fixture has 100 Persons, 50 per Rater, and those
two observed rates. Its additive rank is 2/2 while full local rank is 2/3.
The package correctly declines inference. Its separate disconnected-design
and common-population-link warnings are retained; the ridge argument does
not rely solely on those warnings.

For the paired fixture, the same 100 Persons each receive both ratings, with
joint counts `(00, 01, 10, 11) = (25, 45, 5, 25)`. The marginal rates remain
0.3/0.7, but the probability of two positive ratings supplies additional
information. The [control results](population-identifiability-review-controls-0.2.4.csv)
evaluate the same marginal-probability curve:

| Population variance | Rater difficulty b | Both-positive probability with paired ratings | Unpaired rank | Paired rank |
| --- | ---: | ---: | ---: | ---: |
| 0.000001 | 0.847298 | 0.21000004 | 2/3 | 3/3 |
| 0.1 | 0.866898 | 0.21420184 | 2/3 | 3/3 |
| 1 | 1.018401 | 0.23999444 | 2/3 | 3/3 |
| 4 | 1.384226 | 0.27321541 | 2/3 | 3/3 |

This paired control establishes local information at the evaluated points;
it does not prove global identification for every repeated-rating design.
Independent whole-line all-pattern information agrees with the package's
q121 information within 3.319e-9 per entry. Tiny signed eigenvalues near
1e-15 in the unpaired case are roundoff around its zero eigenvalue.

Full column-scaled rank also does not certify precision. For 100 paired
Persons, information for log variance after adjusting for the two nuisance
coordinates decreases from 1.17127 at `v = 1` to 4.410e-12 at `v = 1e-6`,
even though scaled rank remains 3/3. These are information calculations at
specified points, not estimated sampling SEs, coverage results, or a newly
chosen variance cutoff. The small positive point is not the zero-variance
boundary itself.

## Verification, disposition and next work

The complete diagnostic execution took 39.412 seconds. Current-source RSM/PCM
refits retain full local rank but refuse formal inference and equivalence.
There are no execution errors in the complete run. The negative control
retains five warnings: three Matrix transpose notices and the two design/link
warnings described above. Other fresh/control fits have no warnings.
The [focused tests](population-identifiability-review-tests-0.2.4.csv) pass
455 expectations in the estimability, nonlinear-classification and readiness
files, with zero failures, errors, warnings or skips.

The [archive](population-identifiability-review-evidence-0.2.4.rds) retains
independent and package scores/information, singular values, all control
probabilities, current fits, warning text, test results, source snapshots and
source/input identities. The [execution log](population-identifiability-review-execution-0.2.4.log)
includes the initial stopped comparison and complete execution. Reproduce
from the package root with `Rscript inst/validation/population-identifiability-review-0.2.4.R`.
Preserve the dated archive before replaying a later source revision.

The supported answer is narrower than changing the readiness flag: these two
latent-regression examples have strong local numerical identification evidence,
but that does not justify general population-model inference. Keep the
restriction, and next examine residual-variance boundaries and bounded nuisance
profiles for RSM/PCM, including the zero-variance limiting model and high-variance
sensitivity. Reuse existing profiling machinery where applicable, distinguish
local finite-grid minima from global profiles, and retain the negative/paired
controls. Only then select any missing recovery/coverage study and its precise
inference scope. Full GPCM, JML and Person/joint-decision calibration remain
separate work.

No production functions, thresholds, prior statistical archives, or historical
decisions were changed by this review. A full package/OS release check was
not repeated.

## October 2 GPCM identification and target-specific invariance

**Question.** After the public scale/location constraints, which changes of
parameters still leave the observable response distribution unchanged? This
precedes covariance and truth-inference claims. Algebraic equivalence of
conditional curves, identification of a marginal distribution, finite-sample
existence and a successful optimizer return are different properties.
Assume additive unanchored models with the usual negative difficulty signs,
observed unit-weight ratings, fixed category labels 0,...,K-1,
finite parameters, positive slopes and assignment noninformative conditional
on supplied covariates. The derivations do not cover informative missingness
by default.

### One-family scale and location: the intercept also matters

For context j and transition k write the one-family adjacent logit as

    L_jk(theta) = a_g(j) * [theta - sum_f b_f,j(f) - tau_h(j),k],

with each non-Person facet centered, each step ladder centered, and
`sum_g log(a_g)=0`. For unanchored parameters before those constraints, the
positive affine transformation

    theta' = s*theta+t, a'_g=a_g/s,
    b'_f,l=s*b_f,l+c_f, tau'_h,k=s*tau_h,k, sum_f c_f=t

preserves every conditional response probability. Under a normal population,
`mu'=s*mu+t` and `sigma'=s*sigma`; for regression the intercept absorbs t
when it is in the specified design space. Centering every facet forces each
c_f=0, hence t=0 within this family of transformations. The geometric slope
mean forces s=1. Fixed unit RSM/PCM slopes already force s=1. This removes
these common affine aliases, not every alias caused by an observed design.
Positive slopes also exclude the usual latent-axis reflection with negative
loadings; response labels are held fixed.

For intercept-only normal ability, theta=mu+sigma*z gives exactly

    L_jk = (sigma*a_g) *
           [z - sum_f b_f,j(f)/sigma - tau_h,k/sigma + mu/sigma].

Thus conversion to fixed N(0,1) requires both the absolute slopes sigma*a_g
and a place for the common response offset mu/sigma. In the item-only case,
standardized difficulty is `(b_j-mu)/sigma`, whose mean is -mu/sigma.
Under the default **all-centered** non-Person convention, fixing N(0,1) and
the geometric slope mean to one restricts both population location and common
scale; it is not a coordinate change for arbitrary mu,sigma. A deliberately
uncentered facet can absorb a common location, but changes that constraint
contract. With covariates, the x-dependent population mean must be retained
as regression effects; the legacy fixed-normal branch does not supply them.

Source agreement: `R/api-estimation.R` distinguishes free-population and legacy
fixed-normal GPCM, requires `noncenter_facet="Person"` for an active population
model, and retains an explicitly supplied population formula. PCM `~1`
estimates mu and sigma jointly rather than using an arbitrary rescaling of
unit-slope PCM. These constraints alone do not prove identification of sigma.
The existing single-rating variance/difficulty ridge above already proves why.

At a **fixed known ability coordinate**, equality of full conditional curves
on every observed context determines a_g by comparing the coefficient of
theta. Averaging equal transition offsets over k, using centered steps,
then determines each context's total location; subtracting that total
determines its owner's steps. Individual facet locations are consequently
unique when their constrained context-design matrix has full column rank.
Every retained owner must occur in a context. This argument applies to shared
or separate step/slope ownership, but it is not a marginal-MML identification
theorem: the ability coordinate is latent in the observed experiment.

### Two families: exact role of the facet-crossing graph

The public two-family model uses

    L_frk(theta) = exp(alpha_f+nu_r) * (theta-b_f-c_r-tau_rk),
    sum_f alpha_f=0, sum_f b_f=0, sum_k tau_rk=0, theta~N(0,1),

with nu_r and c_r free. The first/second roles are ordered arguments, not
intrinsic meanings of Task, Rater or Criterion. This product response form is
the model reference in [Uto and Ueno (2020), Section 6](https://link.springer.com/article/10.1007/s41237-020-00115-7);
the identification results here are derived for the package's actual model,
not borrowed from that paper's Bayesian estimation or recovery results.

Build the bipartite graph with the two facets as vertex classes and observed
facet crossings as edges. All retained levels occur on an edge. Let its C
connected components have n_f,h first-facet vertices in component h. On each
component make the simultaneous changes

    alpha'_f=alpha_f+t_h, nu'_r=nu_r-t_h,
    b'_f=b_f+s_h,         c'_r=c_r-s_h.

Every observed slope product and location sum is unchanged. The declared
constraints require only

    sum_h n_f,h*t_h=0,    sum_h n_f,h*s_h=0.

There are C-1 independent slope shifts and C-1 independent location shifts.
Hence C>1 gives at least **2(C-1) exact unidentifiable directions**, preserving
even the fixed-population likelihood. A Person observed on edges from several
components does not remove them: every conditional probability at every theta
was already unchanged. A Person-connectivity graph is not this facet graph.

For the full conditional-curve decomposition these are precisely the aliases.
Equal curves first imply equal products by their theta coefficients; the
log-product differences solve `delta_alpha_f+delta_nu_r=0` on each edge.
Propagation along paths makes each component's shift constant. Centering the
step ladders similarly reduces equal offsets to
`delta_b_f+delta_c_r=0`; each observed owner's steps are fixed. Thus the
constrained product and location incidence matrices each have nullity C-1.
Connectedness is necessary and sufficient for **this decomposition of known
curves**, not for identification of those curves from marginal observations.

This explains existing guards rather than discovering an unchecked code path:
`build_gpcm_product_slope_spec()` in `R/core-gpcm-product-slopes.R` requires
full rank of the constrained log-product design, and `mfrm_gmfrm_problem()`
in `R/core-gmfrm-em.R` checks the analogous location matrix Z. Both reject
deficient crossings. Repeated Persons on the same edges increase counts but
do not alter these exact null spaces. A cross-component edge can remove an
alias; the amount of information it supplies remains a different question.

Observed-edge products/sums, within-component location/log-slope contrasts
and within-component slope ratios are invariant to these shifts. Raw slope
differences generally are not. Absolute components and cross-component contrasts
need not be; a new crossing between components generally changes both its
slope product and offset. Invariant quantities are mathematical candidates
for a reduced model, not outputs currently supplied by the rejected public
two-family fit. No automatic component-wise fit or scoring route is introduced.

### A connected design can still fail marginal slope identification

Use **two non-Person facets, two levels each**, with all four crossings
represented in the cohort, binary responses, and exactly one rating per
Person. Set all locations and binary steps to zero; retain arbitrary positive
component slopes and the public first-family geometric-mean-one constraint.
The facet graph and both constrained incidence matrices are full rank. Yet
for every observed edge with effective slope a,

    P(Y=1 | edge) = integral logistic(a*z)*phi(z) dz = 1/2,

because `logistic(a*z)+logistic(-a*z)=1` and the population is symmetric.
All three free slope coordinates may vary without changing any Person's
observable distribution. This is an exact within-model ambiguity at the
specified centered locations, not a numerical rank threshold or merely too
few simulated Persons. Increasing the number of singly rated Persons on
those same edges cannot resolve it. It disproves sufficiency of connected
crossings plus fixed N(0,1) for general two-family MML identification.

Nor does an unchanged observed probability identify the conditional Person
score. After a positive response on that edge,

    E(theta | Y=1, a) = 2*E[Z*logistic(a*Z)],
    d/da E(theta | Y=1,a) = 2*E[Z^2*logistic'(a*Z)] > 0.

The integral and derivative exist under the normal law. Distinct finite
positive slopes give different EAPs despite identical observed distributions.
A finite proper posterior is therefore insufficient to establish an
identified scoring target. This is an identification control with finite
locations and strictly positive slopes; no optimizer boundary is needed.
No dataset, fit or extra R=50 condition was generated or allocated.
Repeated within-Person observations can supply joint-response information,
but their sufficiency must be established for the particular design/model.

### Latent regression: joint rank, not just covariate rank

With `theta_i=x_i'gamma+sigma*z`, keep slopes, steps and sigma fixed. Let A
be the constrained rating-level facet-location design, and X_rep repeat each
Person's covariate row at their observed ratings. Any nonzero pair satisfying

    X_rep*delta_gamma - A*delta_beta = 0

preserves every conditional integrand and hence the exact marginal likelihood.
This is an exact location alias, including for PCM and one-family GPCM.
Full rank of X alone does not exclude it; the joint design is required.

For a concrete allocation take Rater=2 and Criterion=2, both centered, and
four response categories with centered criterion steps. Persons in groups
x=-1/+1 each receive both criteria, but group determines their sole rater.
Write that rater's severity as d*x, and the population mean as gamma0+gamma1*x.
Every response predictor contains `(gamma1-d)*x`. Replacing
`gamma1 -> gamma1+t` and `d -> d+t` preserves the entire distribution.
X has two independent columns when both groups are present; every rater scores
both criteria, so the rater/criterion graph is connected. Nevertheless the
group association and rater-severity contrast cannot be separated. More
Persons or criteria with this same confounding does not remove the alias.
Assignment overlap that breaks this equation, or a substantively justified
external restriction, is needed; correlation short of exact confounding is
not automatically nonidentification.

The source already distinguishes these layers: `prepare_mfrm_population_scaffold()`
checks X, while `mfrmr_estimability_eta_design()` in `R/core-estimability.R`
also includes the constrained facet blocks and aligned population rows.
This turn checks the algebra/source structure, not a new end-to-end refusal
fixture. Removing missing-X Persons or missing ratings can change the joint
rank even if the originally planned assignment was adequate; inspect the
actual included design. JML has no population-regression coefficient in this
API; a free theta_i plus an unrestricted gamma decomposition would itself
be invariant and does not create a comparable JML regression estimator.

### Matching reduced models requires a response-preserving map

In the two-family model, set the first-family slopes to one but leave the
second-family slopes v_r free. Let g=geometric_mean(v_r)>0 and
m=mean(c_r). The equivalent all-centered one-family representation is

    a_r=v_r/g, b'_f=g*b_f, c'_r=g*(c_r-m), tau'_rk=g*tau_rk,
    theta'=g*theta-g*m ~ N(-g*m,g^2).

Substitution gives identical adjacent logits for every category and context.
The reverse map uses g=sigma, m=-mu/sigma, so this is a bijection on this
declared reduced model. The corresponding one-family comparator estimates
its population; a fixed-N(0,1), geometric-mean-one one-family fit cannot in
general stand in for it. PCM additionally requires all relative slopes to
be one. This supports the roadmap's existing normalization of reduced D
truths and adds the population-mean term explicitly. It qualifies a model
mapping, not a public two-family LRT or a sampling distribution for one.

### Information and covariance: what can now be concluded

For the exact marginal model let p_i(y;psi)>0 be the probability of every
response pattern for Person i's covariates/roster. Set
J_i(y)=partial p_i(y;psi)/partial psi'. Then the expected information is

    I_N(psi) = sum_i sum_y J_i(y)'*J_i(y)/p_i(y;psi).

It is positive definite exactly when these complete probability derivatives
span the free coordinates. Full derivative rank supplies local injectivity
by selecting a square nonsingular submap and applying the inverse function
theorem. This gives neither global uniqueness nor weak-information precision;
first-order rank deficiency alone is not proof of an exact alias without
additional regularity or an explicit invariant path.

An observed-pattern score span is a sufficient subset condition for positive
information; a deficient subset is inconclusive. Repeated independent Persons
with the same design increase information but do not increase the derivative
span of that design's complete probability support. Conversely N<p does not
by itself prove model nonidentification: an expected-information sum includes
all possible patterns, whereas an empirical N-row score matrix has rank at
most N. Existing observed-score gates and capacity limits retain their
implementation-specific meaning. Fixed-quadrature score rank describes that
approximation until its relation to the continuous integral is established.

For an exact equivalent-parameter path psi(t), a target h is identified only
if it is constant along every such path. Locally, `Dh(psi)*psi'(0)=0` is a
necessary first-order condition. A generalized inverse of a singular matrix
does not manufacture information about noninvariant components. For regular
identified MML coordinates use full joint information (or a sampling-law-matched
sandwich under misspecification); ordinary/corrected JML instead need the
covariance of their actual profile/adjusted equation and a separate centering
argument. An adjusted root cannot resolve ambiguity of structural truth in
the same observational experiment without additional assumptions. Two-family
JML and two-family latent regression remain outside current public scope.

**Verification and remaining decision.** Exact symbolic checks verified the
affine/normal maps, component transformations, the reduced-model map and
logistic symmetry. The constrained two-by-two diagonal-edge matrix has rank
2 of 3 and nullity one; adding one connecting edge gives rank 3. The group/
rater example has covariate rank 2 but joint location rank 3 of 4, with exact
null vector `(0,1,1,0)` in `(gamma0,gamma1,d,criterion)` coordinates. These are
symbolic design identities, not stochastic datasets. No fitting, quadrature,
numerical differentiation, code/default change or new stream allocation was
performed. The general graph and marginal-information arguments are analytic
proofs with their stated domains, not automated global-identification checks.

The algebra justifies the existing structural guards and identifies targets
that must not be promoted by them. It does not classify every A-D saved fit,
prove global identification of their nonlinear marginal models, establish
finite-sample MLE existence or qualify structural/scoring intervals. Keep
those output-specific obligations in the current roadmap and reuse the
existing continuous-integral and saved-fit evidence within its actual scope.

## October 2 exact-normal PCM certificate and saved-design application

**Decision.** For the four saved PCM D-LR designs, identification of the
continuous-normal model can be established analytically, including residual
variance. The N=240 observed-score execution cap therefore need not be removed
to answer this mathematical question. The certificate does not establish the
accuracy of their q31 calculations, finite-sample MLE existence, interval
coverage or GPCM identification. Those obligations remain separate.

### Model and the precise rank condition

Consider independent Persons with fixed covariates and a fixed or
noninformatively assigned observed roster. Within a Person, ratings are
conditionally independent given ability. Every rating j has categories
0,...,m_ij with m_ij>=1, finite adjacent thresholds d_ijk, and **fixed unit
slopes**:

    P(Y_ij=k | theta) = exp(k*theta - D_ij,k) / Z_ij(theta),
    D_ij,k = sum_{h=1}^k d_ijh, D_ij,0=0,
    theta_i ~ N(mu_i, v), mu_i=x_i'gamma, 0<v<infinity.

Write the thresholds as an affine function of free structural coordinates
beta, after the declared constraints. Form B from the derivatives of every
`mu_i-d_ijk` with respect to `(beta,gamma)`, one row per observed rating and
possible transition. This is the joint adjacent-logit design; X alone and
the facet-crossing graph alone are insufficient. Intercept-only PCM is the
case x_i=1. RSM is a restricted shared-step member of this same argument.

If **every included Person has at least two ratings**, full column rank of B
is necessary and sufficient for global identification of these finite
coordinates and v, and for positive definite exact expected information at
every finite interior parameter value. The proof is below. More generally,
any subset of Persons with at least two ratings and a full-rank B is a
sufficient certificate for the full experiment: other Persons can add
information but cannot undo identification. Failure of this subset condition
is inconclusive for an experiment that also has singleton Persons. This is
not a general instruction to discard them.

This concerns the support of the specified probability model, including
patterns absent from the realized dataset. Consecutive category support is
required; an unused observed category is not automatically a structural zero.
Arbitrary case weights, response-dependent selection, residual dependence,
free slopes and an unrestricted mixing distribution are outside this proof.
In particular, conditioning on a realized MAR mask is not automatically the
noninformative-roster experiment stipulated here.

### Why conditional pattern ratios identify threshold contrasts

Let S_i=sum_j Y_ij and Z_i(theta)=prod_j Z_ij(theta). The marginal pattern law is

    p_i(y) = exp(-sum_j D_ij,y_j) * F_i,S_i,
    F_i,s = integral exp(s*theta)/Z_i(theta) * phi(theta;mu_i,v) dtheta.

For two distinct ratings j,l, compare patterns with responses `(k,t-1)` and
`(k-1,t)` there, and the same responses everywhere else. Both totals are
k+t-1 plus the other scores, so

    p_i(k,t-1,...) / p_i(k-1,t,...) = exp(-d_ijk+d_ilt).

All factors are strictly positive. If two parameter sets give the same
entire marginal law, these ratios give `Delta d_ijk=Delta d_ilt` for every
transition k,t. With at least two ratings, this also connects transitions
within each rating. Thus all thresholds in Person i's roster differ by a
single constant c_i. The separation property is consistent with the PCM
model introduced by [Masters (1982)](https://www.cambridge.org/core/journals/psychometrika/article/abs/rasch-model-for-partial-credit-scoring/D7202CB6D2D1593889B1318DD6297E01).
The specific normal-mixture and rank conclusions here are derived below;
they are not attributed to the accessible abstract of that paper.

### Why three total-score probabilities identify normal location and variance

First hold all thresholds fixed. Write

    P(S_i=s) = C_i,s * integral exp(s*theta)/Z_i(theta)
                                  * phi(theta;mu_i,v) dtheta,
    C_i,s = sum_{y: sum y=s} exp(-sum_j D_ij,y_j) > 0.

The roster has maximum total T_i=sum_j m_ij>=2, so s=0,1,2 are possible.
Suppose two normal densities f and f_tilde give identical total-score
probabilities. Their difference g=f-f_tilde is then orthogonal to
`1, exp(theta), exp(2*theta)` under the positive weight 1/Z_i(theta).
For distinct normals, log(f/f_tilde) is a nonzero polynomial of degree at
most two; therefore g has at most two sign changes. At its sign-change
locations r_1,...,r_m, m<=2, choose the overall sign of

    Q(theta) = +/- prod_{h=1}^m (exp(theta)-exp(r_h))

so that Q*g is nonnegative everywhere and strictly positive on an interval.
For m=0 use a constant of the appropriate sign. Q is a linear combination
of the three functions above, so orthogonality says its weighted integral
against g is zero, while its sign says the integral is positive: a
contradiction. The integrals exist because s<=T_i and the normal tails are
integrable. Hence the two normal densities, means and variances are equal.
This argument uses the normal family's limited sign changes; finite score
probabilities do not similarly identify an arbitrary mixing distribution.

Return to the common threshold displacement c_i. Subtract c_i from the
second model's latent variable; this restores the first thresholds and
changes its normal mean to `mu_tilde_i-c_i`, leaving its variance unchanged.
The result above gives

    v_tilde=v, mu_tilde_i-mu_i=c_i=Delta d_ijk,
    B * (Delta beta, Delta gamma) = 0.

Full rank of B makes every free-coordinate difference zero. Conversely a
nonzero null vector of B preserves every `mu_i-d_ijk`; shifting the normal
location with the thresholds then preserves every pattern probability
exactly at fixed v. This proves the stated global rank criterion.

### Why the same condition also gives nonsingular exact information

Global injectivity by itself is not enough to assert first-order information.
Here a separate tangent argument supplies that step. If a parameter direction
annihilates all pattern derivatives, differentiate the equal-total log ratios:
its threshold changes are again a common c_i within each roster. After
absorbing this shift, set u_i=dot(mu_i)-c_i and w=dot(v). The remaining normal
density derivative is the density times

    P_i(theta) = u_i*(theta-mu_i)/v
                 + w*((theta-mu_i)^2-v)/(2*v^2).

Zero derivatives of the total probabilities s=0,1,2 make this derivative
orthogonal to the same three exponentials with positive weight 1/Z_i.
A nonzero quadratic P_i has at most two sign changes, so the preceding
sign argument forces P_i identically zero, hence u_i=w=0. Full rank of B
then forces the whole direction to zero. Finite categorical support,
positive pattern probabilities and differentiability under the normal
integral give finite, positive definite exact expected information. The
smooth transformation v<->log(v) preserves this conclusion for the
implementation's variance coordinate.

This proves neither a uniform eigenvalue lower bound nor existence of an
interior maximum for a particular dataset. Weak information, variance
boundaries, multiple sample-likelihood stationary points, numerical
integration error and small-sample inference still require their own review.

### Applying the certificate to the saved four PCM designs

Read only `manifest.rds` and each PCM `fit.rds` in
`validation-results/mfrm-wide-map-lr-witness-20261002/`. These are two parent
cohorts with two linked covariate views each, not four independent datasets.

| Saved designs | Persons | Counts for rater pairs 1+2 / 1+3 / 2+3 | Ratings per Person | Rater-by-Criterion crossings | Distinct included X values | Stored B rank |
| --- | ---: | --- | ---: | ---: | ---: | --- |
| N20-rho0-PCM; N20-rho0.5-PCM | 20 each | 7 / 6 / 7 | 6 | 9 | 20 each | 12 / 12 |
| N240-rho0-PCM; N240-rho0.5-PCM | 240 each | 80 / 80 / 80 | 6 | 9 | 240 each | 12 / 12 |

Each Person has two raters, all three criteria, categories 0--3 and unit
weights. Rater and Criterion locations and each criterion's three steps
are centered; the population formula is `~ X`. There are four free location
coordinates, six free steps, two regression coefficients and one residual
log variance: 13 in total. All saved coordinates are finite and residual
variances strictly positive. The retained rating values/labels/row order
match the manifest after undoing preparatory factor conversion; no response
rows or Persons were omitted. The A/B generator assigns rater pairs in a
separate random stream independently of ability/responses, and the D-LR
generator supplies the declared joint-normal X/ability law.

The rank conclusion is also available without a floating-point rank threshold.
For a null direction of B, comparing transitions within a criterion makes
all its step changes equal; their sum-zero constraint makes them zero.
Comparing all three criteria within a Person makes their location changes
equal, and centering makes them zero. Comparing that Person's two raters
makes their changes equal; the connected co-rater graph and centering make
all rater changes zero. Finally, `dot(gamma0)+X_i*dot(gamma1)=0` at two
distinct X values forces both regression changes to zero. This checks the
actual allocation, not merely the presence of all facet levels.

Source agreement: `loglik_pcm()` in `R/core-likelihood.R` has the unit-slope
kernel above; `mfrmr_estimability_adjacent_design()` in
`R/core-estimability.R` stacks the constrained facet/population design and
negative transition-step block to form B. Those two files and
`R/api-estimation.R` are byte-identical to the archived witness source.
The stored 12/12 ranks agree with the exact design argument; no score
derivatives, quadrature, Hessians or ranks were recomputed in this review.
No fitting, simulated data, package tests or readiness-field changes occurred.
Exact symbolic checks separately passed all nine transition-swap identities
for two four-category ratings, all four common-shift category kernels, the
normal density's directional derivative formula and the quadratic normal
log-density ratio. These verify the algebra used in the proof; they are not
a numerical identification experiment or an automated proof of all its
conditions. Markdown links/fences and `git diff --check` also passed.

**Resulting next work.** All four PCM designs satisfy this continuous-model
identification certificate. An exhaustive 4^6-pattern calculation or a larger
observed-score cap is unnecessary solely to establish their identification.
Reuse the saved coordinates for the still-required numerical comparison of
the objective, joint score and joint information at more accurate integration,
including population and structural nuisance coordinates. The certificate
does not supply that matrix or a public covariance/CI API. Retain extreme
Persons in MML: their marginal total probabilities contribute even though
the within-total conditional distribution is degenerate at the extremes.

The four GPCM fits have two additional free criterion log slopes. Their
unknown slope-weighted ability term does not cancel in the same cross-rating
raw-total ratios, so this certificate does not transfer even if a fitted
slope is near one. The additional repeated-owner argument below resolves
identification for those four designs; boundary obligations remain open.
The conditional-normal argument also supplies no JML bias or
covariance result. For changed/missing rosters, examine the actual included
design and observation law; a complete rectangular dataset is not required,
but neither a planned rank nor the normal-tail argument substitutes for those
checks. The larger-N and general-design roadmap allocations are unchanged.

## October 2 GPCM certificate from repeated slope owners

**Decision.** The four saved one-family GPCM D-LR designs also identify the
exact continuous-normal model globally, with positive definite expected
information throughout its finite interior. Their two extra free log slopes
raise the identified dimension from 13 to 15. This uses repeated ratings
within each slope owner, in addition to the earlier PCM argument. It does
not follow from a positive Hessian or from assuming slopes nearly equal one.
The larger-N observed-score cap need not be removed solely to establish
identification in these four designs. Boundary and numerical qualification
are still required; no saved readiness or public slope status is changed.

### Marginalize to equal-slope blocks, then use the PCM lemma

Use the one-family kernel

    log[P(Y_ij=k | theta)/P(Y_ij=k-1 | theta)]
      = a_g(j) * (theta-d_ijk),
    theta_i ~ N(mu_i,v), mu_i=x_i'gamma,
    a_g>0, sum_{g=1}^G log(a_g)=0, 0<v<infinity.

The varying-slope PCM extension is the model reference in
[Muraki (1992)](https://www.ets.org/research/policy_research_reports/publications/report/1992/ihkr.html).
The identification certificate below is derived here for the package's
normal population and ownership structure; the accessible report abstract
does not establish it. Retain the preceding PCM assumptions: independent
Persons, noninformative rosters, conditional independence, unit weights,
consecutive categories and finite affine structural thresholds after their
constraints.

Choose blocks of at least two ratings of the **same Person and same slope
owner g**. Ratings may have different locations and step owners. Marginalize
over every other response in that Person's roster. Each discarded response's
conditional probabilities sum to one, so the block retains the same normal
mixing law. This is marginalization, not conditioning on the other observed
scores; the latter would generally change the normal mixing distribution.

For this block define

    xi_ig = a_g*theta_i,
    m_ig = a_g*mu_i, w_g = a_g^2*v,
    t_ijk = a_g*d_ijk.

Its response model is exactly unit-slope PCM in xi_ig, with normal mean m_ig,
variance w_g and thresholds t_ijk. The unconstrained part of the previous
PCM proof applies before any full-rank assumption: equal block probability
laws imply

    w_tilde_g = w_g,
    m_tilde_ig-m_ig = t_tilde_ijk-t_ijk = h_ig

for every transition in the block, where h_ig is its common location shift.
Equal-total ratios establish that shift, and the three-total-probability
sign-change argument identifies w_g. A block need not identify its absolute
location to identify this variance.

If every declared slope level appears in a selected block, all w_g are
identified. The package's **unweighted** geometric-mean-one constraint gives

    log(v) = (1/G)*sum_g log(w_g),
    log(a_g) = [log(w_g)-log(v)]/2.

Thus v and all a_g are uniquely determined. These w_g are variances of the
rescaled latent normal variables, not empirical score variances or variances
of estimated EAPs. The identities are an identification proof, not a proposed
two-stage estimation method.

With the slopes now fixed by the probability law, the remaining block
equalities give `Delta mu_i=Delta d_ijk`. Form B from the derivatives of
`mu_i-d_ijk` on all selected block rows/transitions, using the constrained
structural and population coordinates. If B has full column rank, all beta
and gamma coordinates are identified as well. Additional observed responses
can remain in the fitted likelihood; they cannot undo identification supplied
by these marginals. A missing block or deficient B fails this sufficient
certificate, but does not by itself prove that the entire GPCM is unidentified.
Cross-owner joint responses may supply information beyond this certificate.
Conversely, a very small qualifying subset can give identification with weak
information; the certificate supplies no uniform eigenvalue bound or guarantee
that information about every coordinate grows proportionally to N.

### Separate first-order proof and the unit-slope null

If a direction annihilates derivatives of every full response-pattern
probability, it also annihilates derivatives of every selected marginal.
The PCM block tangent argument therefore gives

    dot(w_g)=0,
    dot(m_ig)-dot(t_ijk)=0.

Write alpha_g=log(a_g), ell=log(v). The first set requires

    2*dot(alpha_g)+dot(ell)=0 for all g,
    sum_g dot(alpha_g)=0.

Summing forces dot(ell)=0 and then every dot(alpha_g)=0. The second set now
reduces to B times the remaining direction equalling zero, so full rank
forces that direction to vanish. Normal moments justify differentiation at
finite interior coordinates. Finite positive pattern probabilities then
give finite, positive definite exact expected information.

The argument includes a_1=...=a_G=1 and equal rater locations. It requires
neither distinct true slopes nor a nonzero rater-severity contrast. Therefore
the A/B PCM-truth setting is not a singular slope-null point merely because
it is embedded in GPCM. This resolves that identification issue only; a
small-sample chi-square comparison still needs its other asymptotic,
optimization and integration conditions, followed by sampling evaluation.

Selected blocks from the same Person share ability and are dependent.
The proof does not replace the full likelihood by a product of independent
block likelihoods, count blocks as independent Persons, or justify a
block-diagonal covariance. The inferential target still uses the full joint
population/structural information under the actual Person sampling law.

### Fixed-standard-normal and two-family scope

For a fixed N(0,1) one-family model, a qualifying block directly identifies
`a_g=sqrt(w_g)`. Its mean m_ig is fixed at zero, so the common threshold
shift is zero as well; full rank of the remaining structural design then
identifies its coordinates. The package's additional geometric-mean-one
constraint restricts this model; it does not convert arbitrary free-normal
fits to fixed N(0,1). No fixed-normal fit is newly evaluated here.

There is also a sufficient two-family corollary under fixed N(0,1): if
within-Person repeated observations on facet crossings supply a connected
crossing graph covering all levels, the same argument identifies the
positive slope product and every adjacent threshold on those crossings.
The earlier connected-graph decomposition and declared centering constraints
then identify the component slopes, locations and steps. The tangent argument
likewise gives nonsingular information. Here the repeats must be distinct,
conditionally independent response observations, not copied rows or a single
rating assigned weight two. No historical two-family design has been newly
classified by this corollary. Single observations on crossings, or merely
repeating the same crossing across different Persons, do not meet it.

### Applying the result to the four retained GPCM designs

Read the same saved `manifest.rds` and GPCM `fit.rds` files used for the PCM
review. For each corresponding PCM/GPCM pair, the retained prepared data,
included population design and facet constraints are identical. Criterion
owns both slopes and steps, with three retained slope levels and two free
log-slope coordinates. Every Person has exactly two ratings per criterion.

| Saved GPCM design | Persons | Within-Person criterion blocks | Ratings in each block | Stored B rank | Total free coordinates | Saved optimizer slope range | Saved residual variance |
| --- | ---: | ---: | ---: | --- | ---: | --- | ---: |
| N20-rho0-GPCM | 20 | 60 | 2 | 12/12 | 15 | 0.744203--1.443333 | 1.135065 |
| N20-rho0.5-GPCM | 20 | 60 | 2 | 12/12 | 15 | 0.788317--1.360911 | 0.965247 |
| N240-rho0-GPCM | 240 | 720 | 2 | 12/12 | 15 | 0.868767--1.165214 | 1.198452 |
| N240-rho0.5-GPCM | 240 | 720 | 2 | 12/12 | 15 | 0.877251--1.122343 | 0.763597 |

These are the same two parent cohorts and linked covariate views, not four
independent studies. All parameters are finite, all weights are one, and no
response rows or Persons were omitted. Every slope level has the required
blocks. The exact co-rater/criterion/step/variable-X argument in the PCM
section proves full rank of the remaining B. Consequently all 15 coordinates
are identified for these specified experiments, not just at the saved points.

Source agreement: `build_gpcm_slope_spec()` and `expand_gpcm_log_slopes()` in
`R/mfrm_core.R` supply the relative-slope constraint;
`R/core-likelihood.R` and `R/core-category-probabilities.R` implement the
complete scaled adjacent-logit kernel; the additive transition design is in
`R/core-estimability.R`. These files and `R/api-estimation.R` match the
archived witness source byte-for-byte. The saved slopes retain
`ParameterStatus="not_evaluated"`, unavailable primary estimates and false
SE/CI eligibility because their boundary review is incomplete. This
mathematical record does not rewrite those fields or qualify public intervals.

Read-only assertions verified the block counts, identical PCM/GPCM prepared
data and included population matrices, unit weights, positive finite saved
coordinates, relative-slope configuration and archived source matches. Exact
symbolic checks verified all four category-kernel rescalings and common-location
shifts, the G=3 log-variance inverse, and its tangent Jacobian determinant 12
in `(alpha1,alpha2,ell)` coordinates. The analytic proof gives the general-G
result; these checks verify its actual three-level algebra, not sampling
performance. Markdown links/fences and `git diff --check` passed. No fit,
quadrature, numerical differentiation, simulated data or package test was run.

### Identification still does not guarantee a finite sample maximum

Use these same rosters and free-intercept model, but consider the possible
sample pattern in which every response is in the highest category. Hold all
finite thresholds, positive slopes, v and other regression coefficients fixed,
and increase gamma0 by h. Each highest-category conditional probability is
strictly increasing in theta and approaches one as theta tends to infinity.
For any fixed standard-normal z, theta=gamma0+h+x_other'gamma_other+sqrt(v)*z
tends to infinity. Dominated convergence therefore gives every Person's
marginal pattern probability tending to one and the total log likelihood
tending to its upper bound zero. At finite parameters each probability is
strictly less than one. The supremum is not attained at any finite parameter.

This is an exact sample-existence counterexample within an identified design,
not a new dataset or a claim that it occurred in the saved samples. An
isolated extreme Person does not imply the same conclusion or authorize
deleting extreme responses from MML. Other variance and joint slope/location
boundary paths need their own arguments. The existing fixed-quadrature
constant-slope-ray audit is explicitly limited to its fixed additive/population
coordinates and finite node rule; absence of one of its certificates is not
a continuous-model finite-MLE proof.

**Resulting next work.** The continuous-model identification obligation is
resolved for all eight named PCM/GPCM D-LR designs under these assumptions.
Retained-point integration, full joint score/information accuracy, relevant
sample-boundary conditions, and output-specific covariance/coverage remain
open. Refit only after a named numerical failure under the retained procedure;
do not enumerate every pattern or raise the observed-score cap simply to
re-establish this identification result. Changed ownership, missing rosters,
informative selection, dependence, nonnormal residuals and the broader
two-family designs retain their separate obligations. Ordinary and corrected
JML covariance and structural-truth centering do not follow from this proof.

## October 2 population boundaries and retained response support

**Decision.** For these saved PCM samples, the likelihood attains a finite
maximum in the **closed model allowing v=0**. This does not prove that its
maximum has positive variance, that the full maximum is unique, or that a
returned q31 fit attains it. At v=0 the PCM nuisance problem has a finite,
unique solution. For the corresponding GPCM samples, every parameter-escaping
branch of a likelihood-maximizing sequence must approach v=0; the remaining concern
includes simultaneous slope/location divergence there. An ordinary finite-slope
zero-variance evaluation does not cover all those joint limits.

These conclusions use the observed responses, not just the design's expected
information. All arguments concern the exact continuous-normal likelihood,
independent Persons, conditionally independent unit-weight ratings, the
declared centered Rater/Criterion/step coordinates and `~ X`. Criterion owns
both steps and GPCM slopes in the saved examples. Responses and covariates
are treated as fixed when studying the sample likelihood. No new fit or
numerical derivative is used to establish these statements.

### What the actual samples contain

Reuse the saved manifest and prepared data. PCM and GPCM have identical
responses and population matrices within each corresponding job pair.

| Parent cohort | All-low / all-high / nonextreme Persons | Distinct nonextreme X values, rho0 / rho0.5 | Rater-Criterion contexts with all four categories | Contexts with both increasing and decreasing score/X pairs, in each covariate view |
| --- | --- | --- | --- | --- |
| N=20 | 0 / 0 / 20 | 20 / 20 | 8 of 9 | 9 of 9 |
| N=240 | 2 / 10 / 228 | 228 / 228 | 9 of 9 | 9 of 9 |

At N=20 only Rater 3/Criterion 3 lacks an observed category 3; the other
eight contexts still connect all three raters and all three criteria.
Preserved category support remains 0--3. This empty observed category does
not require collapsing the scale or discarding the context. Each covariate
view also contains score pairs in both directions within every context:
at a larger X, one Person can have either a larger or a smaller score.
The two covariate views are linked observations of each parent cohort.

There are also **within-Person** order reversals between raters. The single
rater pair 1+2 already supplies the following witnesses for every criterion:

| Parent cohort | Criterion | Persons with Y_1>Y_2 | Persons with Y_1<Y_2 |
| --- | --- | ---: | ---: |
| N=20 | 1 | 4 | 2 |
| N=20 | 2 | 1 | 2 |
| N=20 | 3 | 3 | 1 |
| N=240 | 1 | 26 | 14 |
| N=240 | 2 | 20 | 20 |
| N=240 | 3 | 23 | 21 |

These counts are unchanged by covariate view or fitted model. They are
observed support witnesses, not new independent statistical replications.

### Population-only rays and joint additive separation

First hold thresholds, positive slopes and 0<v<infinity fixed. Along a
regression ray gamma+t*h, the mean displacement is z_i=x_i'h. A nonextreme
Person's marginal pattern probability tends to zero when z_i is nonzero.
An all-high Person instead has probability increasing to one if z_i>0,
and an all-low Person does so if z_i<0. Opposite signs drive their
probabilities to zero. Thus the following conditions define an improving
population-only separation ray, provided one extreme inequality is strict:

    X_nonextreme*h=0,
    X_all_high*h>=0, X_all_low*h<=0.

If a direction violates any of these conditions, some Person's probability
tends to zero and the total log likelihood tends to minus infinity. If all
displacements vanish the ray is flat. For `~ X`, two distinct nonextreme X
values suffice to rule out every nonzero h. All four included population
designs satisfy this directly; the 12 extreme Persons at N=240 do not create
population-only separation and remain in the likelihood.

A stronger check includes locations and steps. Write eta for all 12 free
additive/population coordinates, with slopes and v fixed for now. Along
eta+t*h, the slope of category k's log utility in context (r,c) at X is,
apart from its positive factor a_c,

    Q_rc,k(X;h) = k*(h_gamma0+X*h_gamma1-h_b,r-h_d,c)
                   - sum_{l=1}^k h_tau,c,l, Q_rc,0=0.

Let C be the cone of h for which every observed category maximizes Q over
all possible categories in its row. Membership is a set of linear
inequalities. For h in C, every conditional observed-response probability
is nondecreasing along the ray, at every normal latent node. If at least
one row has a strict utility difference the marginal likelihood is strictly
increasing; an all-tied direction is flat. If h is outside C, at least one
observed category loses to another at order t, so its Person's marginal
probability tends to zero by dominated convergence. This is a continuous-model
argument; it does not test only the retained quadrature nodes.

The saved data establish **C={0}** without a numerical linear program:

1. In a fixed context, an increasing score/X pair requires h_gamma1>=0
   for both observed categories to maximize Q. A decreasing pair requires
   h_gamma1<=0. Both occur, forcing h_gamma1=0. Subtracting the two category
   comparisons gives `(k-l)*h_gamma1*(X_2-X_1)` and establishes these signs.
2. Q is now constant across Persons in each context. Where all four categories
   occur, every category must maximize Q, so Q_rc,k=0 for all k. Adjacent
   differences give `h_gamma0-h_b,r-h_d,c-h_tau,c,k=0`.
3. Step centering makes every h_tau,c,k zero and gives
   `h_b,r+h_d,c=h_gamma0` on those contexts. Their connected bipartite graph
   makes the rater changes constant and the criterion changes constant.
   Centering both facets forces those constants and h_gamma0 to zero.

This also rules out nonlinear additive escapes when v stays bounded above
and the slopes remain in a compact positive range. Otherwise, from an
unbounded eta sequence take a convergent subsequence of normalized directions,
slopes and v. Its nonzero limiting direction is outside C, so a fixed row's
observed category loses at diverging order, while the normal perturbation
sqrt(v)*z remains bounded for each fixed z. Dominated convergence makes
that Person's marginal vanish. The same argument includes v=0.
Consequently the likelihood tends to zero as eta escapes under these bounds.

### Rater-order reversals bound scaled latent variances even on joint paths

The remaining upper-variance question must allow thresholds and regression
to move as well. The same-step, same-slope rater pairs supply a uniform bound.
For any Person with criterion c, marginalize to raters 1 and 2. For k!=l,

    P_i(Y_1=k,Y_2=l)/P_i(Y_1=l,Y_2=k)
      = exp[a_c*(k-l)*(b_2-b_1)].

Shared criterion steps cancel and the weighted totals are equal, so this
identity holds at any mean and variance. Consider any nonempty likelihood
superlevel set `log L>=-M`, M>0. Since all Person probabilities are at most
one, every observed Person probability is at least epsilon=exp(-M); its
observed pair marginal is at least epsilon as well. A positive and a negative
observed rater order imply

    |a_c*(b_2-b_1)| <= M.

The two orders can occur in different Persons with different X values:
each inequality uses its own unobserved swapped-pattern probability, which
is at most one. No empirical frequency ratio or equal-mean assumption is used.

To bound the chance of a discordant pair, let q_k(t)=P(Y>=k | t) for the
common criterion ladder before subtracting rater severity. For k=1,...,m,

    q'_k(t) = a_c*Cov_t(Y,1[Y>=k]) >= a_c*q_k(t)*(1-q_k(t)).

The inequality follows because the conditional means above and below the
cut differ by at least one category. Each q_k rises from zero to one. Given
ability theta, the probability of disagreement between the two threshold
indicators is at most

    2*q_k(theta-b_1)*(1-q_k(theta-b_1))
      + |q_k(theta-b_2)-q_k(theta-b_1)|.

Integrating over theta gives at most `2/a_c+|b_2-b_1|`: use the derivative
bound for the first term and monotonicity/Fubini for the shifted-tail
difference. If the categorical scores disagree, at least one threshold
indicator disagrees. Sum over m thresholds, then bound the normal density
by 1/sqrt(2*pi*v), to obtain

    P_i(Y_1!=Y_2)
      <= m*(2/a_c+|b_2-b_1|)/sqrt(2*pi*v)
      <= m*(2+M)/sqrt(2*pi*w_c), w_c=a_c^2*v.

An observed discordant pair has marginal probability at least epsilon on
the superlevel set. Hence

    w_c <= [m*(2+M)/(epsilon*sqrt(2*pi))]^2.

All three criteria have both orders in the saved data, so all three w_c
are bounded above even if slopes, means, locations and steps move jointly.
For PCM, a_c=1 and this bounds v directly. For GPCM, the geometric-mean-one
constraint gives `v=geometric_mean(w_c)` and again bounds v. This is an
existence bound, deliberately loose, not a proposed numerical variance cap;
M is an exact-likelihood level, not an unqualified q31 objective substituted
into a computation. It rules out escape to infinity, not competitive finite
variance values or the need to evaluate finite candidates accurately.

### What is now proved about existence, and what remains

For PCM the preceding bound keeps v bounded above on a likelihood superlevel
set. Unit slopes are fixed, and C={0} keeps eta bounded even as v tends to
zero. The extended likelihood is continuous at v=0, where it equals the
conditional likelihood at theta_i=x_i'gamma. A nonempty superlevel set is
therefore compact in `(eta,v>=0)`, and a finite global maximum exists there.
This is a sample-specific existence proof in the closed model. The public
log-variance coordinate covers v>0: if all maximizing points have v=0, that
open model has a supremum but no finite log-variance maximizer.

At v=0, for fixed slopes, the nuisance log likelihood is a sum of categorical
log-softmax terms with affine predictors. Its Hessian is negative definite
when B has full column rank: every nonzero direction changes a within-row
category contrast somewhere, whose categorical variance is strictly positive.
Together with C={0}, this proves a finite **unique PCM boundary nuisance
maximum** for each saved design. It does not prove uniqueness of the joint
positive-variance maximum. No boundary nuisance estimates have been computed
for these eight D-LR jobs in this review.

For GPCM, restrict temporarily to v>=delta>0. Bounded w_c gives an upper
bound on every slope. The geometric-mean-one constraint then bounds each
slope away from zero. C={0} makes eta bounded, so this restricted superlevel
set is compact as well. Thus every escaping GPCM maximizing sequence must
have a subsequence approaching **v=0**. Finite-slope zero-variance points
and joint v-to-zero/slope-divergence paths require separate treatment.
In the latter, `a_c*sqrt(v)` can remain positive for some criteria: residual
variation in those scaled logits survives even though v tends to zero.
Replacing all such limits by one-node, deterministic-ability calculations
would drop that variation. The ordinary zero-variance helper covers only
the fixed-finite-nuisance limit, as its existing contract states.

### The boundary score must use natural variance, with its nuisance conditions

For fixed finite nuisance coordinates write f_i(theta) for the conditional
pattern likelihood and u_i=partial_theta log(f_i), j_i=-partial_theta^2 log(f_i).
The finite-category kernel has bounded derivatives of each fixed order at
fixed finite slopes. Taylor expansion and standard-normal moments give

    E[f_i(mu_i+sqrt(v)*Z)] = f_i(mu_i) + v*f_i''(mu_i)/2 + O(v^2),
    S_v(0+) = partial_v log L |_(0+)
             = (1/2)*sum_i [u_i(mu_i)^2-j_i(mu_i)],
    u_i(theta) = sum_j a_g(j)*(y_ij-E_theta Y_ij),
    j_i(theta) = sum_j a_g(j)^2*Var_theta(Y_ij).

These are derivatives of the **log likelihood**; the package's negative
log-likelihood derivative has the opposite sign. Positive S_v rejects a
given boundary point as a local maximum even with nuisance coordinates held
fixed. Nonpositive S_v is only a necessary one-sided condition; it does not
establish a global maximum, and zero needs higher-order review. At a regular
interior nuisance maximum the envelope theorem transfers this derivative to
its differentiable local profile. Nonstationary nuisance traces or several
competing/nonsmooth branches require separate treatment.

For lambda=log(v), `partial_lambda log L=v*partial_v log L`, which tends
to zero as v tends to zero at fixed finite nuisance coordinates regardless
of the sign of a finite S_v(0+). A small log-variance gradient therefore
does not by itself establish a valid variance-boundary solution. Current
`expand_params()` in `R/mfrm_core.R` uses exp(log_sigma2) and requires it
to be positive. This observation motivates a natural-coordinate boundary
check; it is not a finding that any saved D-LR fit has this numerical defect.

The historical [RSM/PCM zero-variance profiles](population-variance-profile-record-0.2.4.md)
already recorded negative NLL one-sided quotients near -129.19/-133.10 at
their selected N=80 boundary vectors, supporting movement into positive
variance there. Those are reused within their historical scope. They neither
evaluate S_v for these N=20/240 samples nor provide a reason to rerun the
216 historical optimizations. The [GPCM P1c record](gpcm-zero-variance-boundary-p1c-record-0.2.3.md)
also correctly withheld boundary-profile claims for nonstationary nuisance
traces, despite the exact fixed-nuisance zero limit.

### Zero variance can change nuisance identification

The repeated-owner interior certificate assumed v>0. At v=0, consider its
same two-facet, criterion-owned GPCM submodel with all rater locations zero
and a constant population mean mu (zero nonintercept regression effects).
Let c_g be centered criterion locations and tau_gk centered steps. For
positive multipliers lambda_g with product one set

    a'_g = a_g*lambda_g, tau'_gk=tau_gk/lambda_g,
    mu' = mean_g[(mu-c_g)/lambda_g],
    c'_g = mu'-(mu-c_g)/lambda_g, b'_r=0, v'=0.

All constraints are preserved, and every adjacent logit remains exactly
`a_g*(mu-c_g-tau_gk)`. Thus an exact nuisance alias is possible on this
boundary even in a design identified throughout its positive-variance
interior. This is not an assertion that the retained boundary optimum has
zero rater effects. It prevents a universal regular-nuisance assumption at
v=0. A boundary chi-square or mixture reference needs its own conditions;
[Self and Liang (1987)](https://doi.org/10.1080/01621459.1987.10478472) also
explicitly give a nuisance-boundary example without a chi-square-mixture
limit. No reference distribution or interval rule is adopted here.

**Verification.** Read-only assertions passed for all eight retained fits:
prepared rows match the manifest, weights equal one, the nonextreme X values
are distinct, the complete-category context graph is connected, every context
contains both score/X order directions, and the rater 1+2 counts above hold
for all three criteria. No estimator or package likelihood function was invoked.
Exact symbolic checks passed the swapped-pair odds, the two tail-indicator
identities, categorical curvature and log-likelihood derivative identity,
and all nine transition logits plus constraints in the three-criterion
zero-variance alias. These verify the supporting algebra; the compactness
and limiting arguments are the analytic proofs above. Markdown links/fences
and `git diff --check` passed. No numerical derivative, integration, new data,
fit or package test was run, and the R=50 allocation is unchanged.

**Resulting next work.** PCM now has a well-defined finite boundary nuisance
problem and existence of a maximum in the closed variance model for these
samples. GPCM review can concentrate on finite and joint limits at v=0,
retaining scaled variances when slopes diverge. Quantifying candidate values,
natural-variance scores, exact-integral/full-information agreement and
sampling uncertainty remains numerical work, not completed by this proof.
No new cutoff, readiness promotion, response deletion, fitting allocation or
JML bias/covariance claim follows. Other response/ownership/missingness designs
must meet their own support and observation-law conditions.

## October 2 zero-variance information and inference

**Question.** Does a zero population variance destroy all information about
that variance, and can a positive information matrix justify ordinary normal
intervals there? The answers are no and no. The following derivation resolves
the finite-parameter boundary for fixed slopes, then identifies exactly where
the saved GPCM design has regular nuisance coordinates. It concerns the exact
normal-mixture model, unit weights, independent Persons, ignorable rosters
and conditional independence. It supplies no new fitted boundary value,
coverage result or readiness promotion.

### Repeated ratings supply variance information at zero

At v=0, theta_i=mu_i=x_i'gamma. Conditional on the included design, all ratings
are independent, including within a Person. At finite thresholds and finite
positive slopes define

    e_ij = Y_ij-E(Y_ij), s_ij^2=Var(Y_ij)>0,
    s_vi = (1/2)*[(sum_j a_j*e_ij)^2-sum_j a_j^2*s_ij^2]
         = Q_i+R_i,
    Q_i = sum_(j<l) a_j*a_l*e_ij*e_il,
    R_i = (1/2)*sum_j a_j^2*(e_ij^2-s_ij^2).

The preceding boundary derivative gives s_vi as the Person natural-variance
score. Every finite-dimensional nuisance score at v=0 is a sum of centered
single-rating functions, including structural, regression and finite-slope
scores. Q_i is orthogonal in expectation to every such function: a product
with a function of one rating retains at least one independent centered
residual. Distinct pair products are mutually orthogonal, even if they share
one rating. Therefore

    E(Q_i)=0,
    Var(Q_i)=sum_(j<l) a_j^2*a_l^2*s_ij^2*s_il^2.

Let S_eta be the total nuisance score, A_N=Var(S_eta),
c_N=Cov(S_eta,S_v), d_N=Var(S_v), and suppose A_N is nonsingular. Projection
onto the nuisance score span gives the exact efficient information

    J_N = d_N-c_N' A_N^-1 c_N
        = sum_i Var(Q_i)
          + Var[sum_i R_i-c_N' A_N^-1 S_eta]
        >= sum_i sum_(j<l) a_j^2*a_l^2*s_ij^2*s_il^2 > 0

whenever at least one Person has two ratings. These are expected information
identities at a finite boundary parameter, not empirical score ranks or
observed Hessians. This sufficient condition does not assert that singletons
can never supply variance information under other restrictions.

For PCM, A_N is positive definite when the joint adjacent-logit design B has
full rank. Consequently, all four retained PCM designs have positive definite
joint expected information in the 12 nuisance coordinates and **natural v**
at every finite v=0 point. This is compatible with a one-sided parameter
space. It gives neither a uniform lower eigenvalue bound nor a Gaussian
distribution for an estimator constrained to v>=0.

The information can also be expressed without enumerating Person response
patterns. Write t_ij(Y_ij) for each centered nuisance-score vector and
m4_ij=E(e_ij^4). Independence gives

    A_N = sum_ij E[t_ij*t_ij'],
    c_N = (1/2)*sum_ij a_j^2*E[t_ij*e_ij^2],
    d_N = (1/4)*sum_ij a_j^4*[m4_ij-(s_ij^2)^2]
          + sum_i sum_(j<l) a_j^2*a_l^2*s_ij^2*s_il^2.

Each expectation in these formulas is a finite category sum at the proposed
boundary parameter. Their derivation establishes what a subsequent boundary
information calculation must compute; no such calculation at a fitted
candidate was run here. They cannot be substituted for positive-variance
joint marginal information.

### Exact finite-boundary qualification for the saved GPCM design

The saved design represents every Rater/Criterion context, with at least two
distinct X values in each context. There are three centered rater locations
b_r, three centered criterion locations c_g, centered criterion step ladders
tau_gk, and three positive slopes a_g with product one. At v=0 the adjacent
logits are

    a_g*(gamma_0+gamma_1*X-b_r-c_g-tau_gk).

For this design, finite boundary nuisance identification holds **if and only
if gamma_1 is nonzero or the centered rater vector b is nonzero**.

To prove global identification in the stated finite boundary submodel, let
two parameter vectors give the same response law and put
lambda_g=a'_g/a_g>0. Equality of marginal category probabilities gives equal
adjacent logits. Comparing two X values in a fixed context yields
`gamma'_1=gamma_1/lambda_g`. If gamma_1 is nonzero, all lambda_g coincide;
their product-one constraint makes them all one. If gamma_1=0 but some rater
contrast is nonzero, comparison across raters instead gives
`b'_r-b'_s=(b_r-b_s)/lambda_g`, with the same consequence. With equal slopes,
full-rank B identifies the remaining coordinates. If both signals vanish,
the exact two-dimensional alias in the preceding section preserves every
probability and shows nonidentification.

A separate derivative argument establishes information rank, rather than
inferring it from global injectivity. Put t_g=dot(log a_g), sum_g t_g=0.
A null derivative of every adjacent logit requires

    dot(gamma_0)+X*dot(gamma_1)-dot(b_r)-dot(c_g)-dot(tau_gk)
      +t_g*(gamma_0+gamma_1*X-b_r-c_g-tau_gk)=0.

Within-context X differences give dot(gamma_1)+t_g*gamma_1=0. Rater
differences give dot(b_r)-dot(b_s)+t_g*(b_r-b_s)=0. Either nonzero signal
forces all t_g equal and hence zero; B then forces every other derivative
to zero. When both signals vanish, the two independent alias derivatives
exhaust the null space: fixing t leaves a unique additive derivative through
B. Thus nuisance information has rank 14/14 in the regular case and 12/14
in the aliased case. The orthogonal pair-score component above adds one rank
in natural v: joint information has rank 15/15 or 13/15, respectively.

These are statements about parameter values and the observed design, not
estimates of those values. The positive-variance fits do not identify which
case a separately optimized boundary candidate occupies. A small rater or
regression signal can also give weak information despite formal full rank.
No arbitrary signal threshold is introduced. Other ownership patterns,
covariates and partially connected contexts require their own argument.

### One boundary coordinate changes joint sampling uncertainty

Assume a correctly specified sequence of experiments with independent Persons,
fixed parameter dimension, a finite true nuisance vector eta_0 and true v=0.
For the following result, require a valid uniform local quadratic likelihood
expansion, a score central limit theorem and I_N/N -> I positive definite,
plus selection of a consistent constrained maximizer in this finite chart.
Bounded rosters and covariates with a nondegenerate limiting design are one
sufficient setting for the smoothness/moment conditions. Unbounded covariates
need appropriate moment and domination checks. Finite-sample full rank alone
does not establish a nondegenerate limiting design. Numerical approximations
must be negligible on this local likelihood/score scale.

The primary reference is [Self and Liang (1987)](https://doi.org/10.1080/01621459.1987.10478472),
pp. 605-608, especially Theorem 2/Case 2 and Theorem 3/Case 5. Their
boundary result uses a Gaussian projection with the information metric under
regularity and identification conditions. The explicit block calculation
below applies that geometry after stating the design-sequence requirements;
the citation does not itself qualify the retained heterogeneous rosters.

Partition the limiting per-Person information and score as

    I = [ A   c ],    Delta=(Delta_eta,Delta_v) ~ N(0,I),
        [ c'  d ]
    k=A^-1*c, J=d-c'*A^-1*c>0,
    U=A^-1*Delta_eta,
    V=(Delta_v-c'*A^-1*Delta_eta)/J.

U and V are independent, with covariance A^-1 and variance 1/J. Maximizing
the local quadratic over h_v>=0 first gives h_eta=U-k*h_v and the profiled
quadratic, apart from a constant, is `J*V*h_v-J*h_v^2/2`. Therefore

    sqrt(N)*v_hat                  -> H_v=max(0,V),
    sqrt(N)*(eta_hat-eta_0)         -> H_eta=U-k*max(0,V).

The variance boundary can change structural and regression uncertainty as
well as uncertainty for v. Ordinary joint I^-1/N is not the covariance rule
for this constrained limit. In particular, the moments of the **limit law**
are

    E(H_v)=1/sqrt(2*pi*J),
    E(H_eta)=-k/sqrt(2*pi*J),
    c_plus=(pi-1)/(2*pi*J),
    Var(H_v)=c_plus,
    Cov(H_eta,H_v)=-k*c_plus,
    Var(H_eta)=A^-1+k*k'*c_plus.

Weak convergence alone does not establish convergence of estimator moments;
using these as bias/variance approximations additionally needs suitable
moment control. Even with that control, covariance alone does not make the
non-Gaussian limit suitable for symmetric normal intervals. A particular
structural contrast with l'*k=0 retains a centered Gaussian limit; this
orthogonality must be established for that target, not assumed for every
facet or regression coefficient. Treating v as known zero gives A^-1, a
different estimation procedure from estimating v subject to its boundary.

For the single test H0:v=0 against v>0, define the likelihood-ratio statistic
as `T_N=2*[ell_N(eta_hat,v_hat)-ell_N(eta_hat_0,0)]`. The same profiled
quadratic gives `T_N -> J*max(0,V)^2`: one-half point mass at zero and
one-half chi-square with one degree of freedom, agreeing with the reference's
Case 5. This is
a null asymptotic law under the conditions above, not an exact N=20 rule,
a general profile-interval recipe, or a reference for several variance
components. Close positive variances on the N^-1/2 scale also need this
local-boundary treatment; pointwise interior normality is not uniform there.

With sigma=sqrt(v), N^(1/4)*sigma_hat has limit sqrt(max(0,V)), not a
root-N normal limit. With log(v), zero is outside the coordinate chart.
For v>0 its expected information blocks satisfy I_eta,logv=v*I_eta,v
and I_logv,logv=v^2*I_vv, with efficient information v^2*J(v), where all
blocks and the Schur complement J(v) are evaluated at that positive v. Their
collapse as v decreases can therefore be a coordinate singularity while natural-v
information stays positive. These are expected-information transformation
rules; an observed Hessian away from stationarity has additional score terms.
They do not diagnose an actual numerical defect in any saved fit.

### Why this is not a universal GPCM reference law

At an aliased finite GPCM boundary, the conditional probabilities are
unchanged along the slope transformations above, but the natural-variance
score contains a_j*a_l and generally changes. The variance alternative is
then indexed by nuisance slopes that the null cannot identify. The positive
pair-score information at a chosen representation does not restore an
invertible joint I or license the one-boundary Gaussian projection. It is
not enough to count one estimated variance parameter and choose a 50:50 law.

At a regular finite GPCM boundary, the local calculation can apply if its
other asymptotic conditions hold. The competing joint limits found in the
sample-boundary analysis still require separate likelihood/selection review.
Writing r_g=a_g*sqrt(v), their boundedness and product constraint imply
`product_g r_g=v^(G/2) -> 0`; some r_g can nevertheless have positive limits.
The corresponding standardized latent term r_g*Z survives. Such limits are
not finite-nuisance v=0 points in the chart used for the projection theorem.
The historical [ordered-ratio boundary record](gpcm-ordered-ratio-boundary-p1j-record-0.2.3.md)
already distinguishes surviving coefficient directions and nested endpoints;
its different fixtures and partial profile qualifications are retained without
rerunning or transporting their conclusions to these D-LR samples.

**Output/source consequence.** Current `R/core-native-location-inference.R`
checks full joint information and numerical agreement for explicitly
experimental normal intervals, and its source contract excludes nonintercept
latent regression. That positive-variance route is not an implementation of
the constrained boundary law derived here. No interval rule or eligibility
flag has been changed. Boundary uncertainty needs a qualified finite candidate,
its actual nuisance rank and target-specific reference; GPCM additionally
needs the competing joint-limit decision. Informative missingness, dependence,
estimated observation models and JML equations are outside this derivation.

**Verification and next decision.** Exact symbolic checks passed the score
decomposition, pair-product variance and orthogonality to all centered
single-rating polynomials through degree three (a basis for four-category
functions), and the category-moment information identity. Exact contrast
Jacobians at representative parameter values had the predicted GPCM nuisance
ranks 12, 14 and 14 for no signal, rater signal and regression signal. These
are algebraic checks, not generated response datasets or proofs replacing
the general arguments. The Schur-complement profiling identity and positive
Gaussian first/second moments also passed. The cited original pages were
read directly. Local links/anchors, Markdown fences and `git diff --check`
passed. No new fit, numerical differentiation/integration, simulation or
package test was run. The four current PCM boundary nuisance problems now
have defined uniqueness, score, information and inferential contracts for
subsequent numerical qualification; their candidate values and finite-sample
coverage remain uncomputed. R=50 allocation and all public restrictions are
unchanged.

## October 2 PCM zero-variance numerical qualification

**Question and scope.** Does the zero-variance boundary compete with the
retained positive-variance PCM solutions for the four actual D-LR inputs?
The preceding proofs establish a unique finite nuisance optimum at v=0
and existence of a maximum in the closed v>=0 model for these samples.
This bounded calculation now evaluates that boundary and compares exact-model
likelihood values. It uses the same four N=20/240, rho=0/.5 covariate views
of **two parent response cohorts**, with all retained Persons and ratings.
They are not four independent replications or an R=50 performance result.
There is no new data generation, positive-variance refitting or GPCM fitting.

The [runner](mfrm-wide-map-lr-pcm-boundary-20261002.R) and
[numeric summary](mfrm-wide-map-lr-pcm-boundary-summary-20261002.csv) reproduce
the result. Full phase evidence is under
`validation-results/mfrm-wide-map-lr-pcm-boundary-20261002/`, including
`verified.rds` and separate initial fit, initial check and refinement records
for every job. From the package root:

```r
source('inst/validation/mfrm-wide-map-lr-pcm-boundary-20261002.R')
dlr_pcm_boundary_run('validation-results/mfrm-wide-map-lr-pcm-boundary-20261002')
```

Completed phases replay without fitting or integration. Their bindings include
input identity, relevant function bodies and the current numerical runtime;
the initial witness fit files remain unchanged. A first preflight stopped
before estimation because an overbroad source-equality assertion included
five later publication changes. Their inspected diffs concern plotting,
two-family GPCM replay checks and the Matrix import, not this PCM likelihood
route. The runner records those differences and accepts only their reviewed
hashes; the other archived R/C++ source hashes must still match.

### Calculation and numerical qualification

The independent boundary objective builds the 12 free-coordinate category
predictors directly from centered rater/criterion contrasts, centered steps
and the retained `~ X` population design. It uses log-softmax probabilities,
analytic gradient and analytic Hessian; it calls neither the package response
kernel nor a data generator. `stats::nlm` supplies the optimization algorithm,
starting once from each retained nuisance vector. Strict convexity makes
unrelated multistart searches unnecessary for this boundary problem.

Three runs met the stationarity criteria after five iterations. The
N240-rho0.5 run returned code 3 after eight iterations, with unscaled gradient
sup norm 7.98e-6. Its failed line search was consistent with objective roundoff
before the stricter score criterion, rather than a demonstrated statistical
boundary failure. One analytic Newton correction at that
retained vector reduced the gradient to 9.81e-14. The original optimizer code,
iterate and failed checks remain saved. Only that changed boundary vector
needed its boundary calculations repeated; the other three fitted vectors
were reused. No optimizer success code was fabricated or tolerance relaxed.

The convex objective also admits a useful independent accuracy check. Let
D_jk be the category-predictor design, p_jk its fitted probabilities,
t_jk=D_jk-E_p(D_jY), and let g and A be the total NLL gradient and Hessian.
The correction

    q_jk = p_jk * [1-t_jk' A^-1 g]

has unit row sums and exactly reproduces the observed total design vector
in exact arithmetic. At these candidates every q_jk is positive. Its entropy
is a dual lower bound for the convex NLL minimum, and the primal-dual gap
is NLL+sum(q*log(q)). The largest absolute computed gap is 4.32e-12,
moment residual 3.69e-14 and row-mass residual 4.44e-16. Tiny negative gaps
are retained as floating roundoff, not clipped into a claimed exact bound.
This is a numerical dual-feasibility check, not an interval-arithmetic proof.

The remaining checks use the contracts derived in the preceding section:

- The q=1 package evaluator agrees with the independent boundary NLL within
  4.55e-13 and nuisance gradient within 3.20e-14. Changing its unused finite
  log-variance placeholder between -32, 0 and 32 leaves the degenerate
  likelihood unchanged.
- Central differences at steps 1e-4 and 5e-5 check the analytic nuisance
  gradient and Hessian. The largest fine-step gradient difference is
  6.71e-7 in the total NLL, and Hessian difference 2.79e-6; the declared
  per-Person gradient and relative Hessian tolerances pass.
- The full expected information in 12 nuisance coordinates plus natural v
  is computed from finite category moments. An independent enumeration of
  all 4^6=4,096 patterns for one retained Person per job checks the full
  13-by-13 contribution, its total mass and zero mean score. Maximum matrix
  disagreement is 4.98e-14. This is a check of the formula, not a claim that
  every Person's patterns were separately enumerated.
- Continuous-normal integration checks the natural-variance score by
  second-order one-sided NLL differences. The initial coarse checks did not
  meet the declared 1e-6-per-Person tolerance. One additional variance value,
  1.25e-5, allowed checks at step sizes 2.5e-5 and 1.25e-5 using stored larger
  values. Both pass in every case; errors decrease approximately fourfold
  on halving the step, as expected for this second-order formula. The largest
  finest-step error is 4.62e-5 in the total derivative. Coarse failures remain
  recorded; the threshold is unchanged.

Adaptive integration spans the entire normal line with relative tolerance
1e-11 and absolute tolerance 1e-13. Each integrand is scaled by the Person's
conditional pattern probability at its mean before taking logs, preventing
tiny pattern probabilities from making an absolute integration tolerance
misleading. All integrator statuses are successful. The largest sum of its
relative error estimates is 1.18e-9 on the near-zero paths and 9.35e-10 at
the retained positive-variance points. These are quadrature error estimates,
not rigorous enclosures of the real-valued integral.

### Results and what they resolve

S_v is the log-likelihood derivative towards increasing **natural variance**;
its sign is opposite to the NLL derivative. J_v is total efficient expected
variance information after projecting out the 12 nuisance scores. The
likelihood gain is log L at the retained positive-variance vector minus the
numerically qualified maximum log L at v=0, using the continuous-normal
likelihood for the former.

| Job | Boundary NLL | S_v(0+) | J_v | Retained variance | Interior log-likelihood gain |
| --- | ---: | ---: | ---: | ---: | ---: |
| N20-rho0-PCM | 152.830895 | 120.362008 | 282.540315 | 1.057968 | 14.547020 |
| N20-rho0.5-PCM | 148.809966 | 105.852828 | 247.925722 | 0.874540 | 12.217359 |
| N240-rho0-PCM | 1943.805217 | 1948.270624 | 5390.692077 | 1.183409 | 205.729400 |
| N240-rho0.5-PCM | 1819.503888 | 1259.866454 | 3865.152492 | 0.751278 | 125.297608 |

All final numerical checks pass. The maximum nuisance gradient sup norm is
2.68e-10. The smallest eigenvalues of the four joint natural-coordinate
information matrices range from 3.470015 to 33.511065; their efficient
variance information exceeds the analytic pair-product lower bound in every
case. These are information calculations at fitted boundary candidates,
not interval coverage results or a lower eigenvalue bound for every parameter.

Every boundary score is positive, so the unique boundary nuisance optimum
admits a locally improving variance direction. Independently, every retained
positive-variance candidate has a substantially larger continuous log
likelihood. The differences are far larger than the recorded numerical
residuals. Thus the zero boundary is excluded at the stated numerical
qualification. Combined with the preceding sample-specific compactness
proof, this supports a **finite positive-variance global maximum** for each
of these four PCM inputs. It does not establish that the retained q31 vector
is that global maximum, uniqueness of the full interior maximum, or a valid
standard error. No mixture-test p-values are inferred from this comparison.

### A separate retained-point integration finding

The original q31 NLL and the independently integrated continuous NLL differ
at the same unchanged retained parameter vector:

| Job | q31 NLL minus continuous NLL |
| --- | ---: |
| N20-rho0-PCM | 0.0001030985 |
| N20-rho0.5-PCM | 0.0000081636 |
| N240-rho0-PCM | 0.0109916042 |
| N240-rho0.5-PCM | -0.0000089448 |

In particular, N240-rho0 has a discrepancy of about .011. This does not
change its roughly 206-unit advantage over the zero boundary, but a small
q31 optimizer gradient is a gradient of an approximate objective. These
value differences neither measure parameter error nor qualify continuous
gradients or inverse information. The next PCM numerical work is therefore
retained-point score/information agreement and any refinement justified by
that result. A blanket refit of every case or a universal quadrature-order
increase is not justified by this table alone.

**Saved replay and retained scope.** In a fresh R process, `stats::nlm` and
`stats::integrate` were traced to stop if called. All four jobs reproduced
the identical summary from saved phases; all phase-file and original
witness-fit hashes stayed unchanged. Static R usage checks, local Markdown
links and `git diff --check` passed. This is repository-only validation,
excluded from package builds. No production source, help, NEWS, public
eligibility flag or interval API changed. GPCM finite/joint zero limits,
JML centering/covariance and the full R=50 repeated-sampling comparisons
remain separate tasks; the 253,400 initial-fit allocation is unchanged.

## October 2 PCM continuous score, information and local refinement

**Question.** Do the retained PCM solutions satisfy the continuous-normal
likelihood equations, and does the package compute their full joint observed
information accurately? The preceding value-only comparison cannot answer
either question. This follow-through reuses exactly those four saved
covariate views of two response cohorts. It checks 13 coordinates: four free
facet locations, six free steps, the population intercept and X coefficient,
and log residual variance. No nuisance block is held fixed in the inverse.

### Independent derivatives and the comparison contract

The reference differentiates the complete-data likelihood at **fixed theta**,
then integrates its moments under the posterior for each Person. For the
10 structural coordinates b, let D_jk be the category-predictor design.
Write r_i=theta_i-x_i'gamma, v=exp(lambda), and p_jk for the conditional
category probabilities. The complete-data log-likelihood score is

    s_b = sum_j [D_j,y_j-sum_k p_jk*D_jk],
    s_gamma = x_i*r_i/v,
    s_lambda = (r_i^2/v-1)/2.

Its negative Hessian has structural block sum_j Cov_p(D_jY), population
blocks `I_gamma,gamma=x_i*x_i'/v`, `I_gamma,lambda=x_i*r_i/v` and
`I_lambda,lambda=r_i^2/(2*v)`, and zero structural/population cross blocks.
Differentiating the marginal integral therefore gives

    grad NLL = -sum_i E[s_i | observed responses],
    H_NLL = sum_i { E[I_complete,i | responses]
                    - Cov[s_i | responses] }.

The second expression is the observed information, not the expected
information over all response patterns used in the preceding boundary proof.
The posterior score covariance supplies cross-block terms even though the
complete-data Hessian is block diagonal. This is the missing-information
identity associated with [Louis (1982)](https://doi.org/10.1111/j.2517-6161.1982.tb01203.x).
Here it also follows directly from the first two derivatives of the marginal
integral. Finite category support and a finite positive-variance parameter
neighborhood bound the structural derivatives; polynomial normal-density
derivatives give an integrable envelope. Standardizing theta to mu+sqrt(v)*z
is used to integrate, without changing the fixed-theta differentiation above.

The [Python reference](mfrm-wide-map-lr-pcm-information-20261002.py) independently
constructs the constrained category predictors from the saved row indices
and covariates. It does not call the package response kernel. The installed
SciPy `quad_vec` integrates the probability, 13 score components and all
169 second-derivative components together over the whole normal line.
It uses max-norm error control, epsabs=1e-13 and epsrel=1e-12, scaling by
the conditional pattern probability at the Person mean. The numerical
runtime is Python 3.14.3, NumPy 2.4.2 and SciPy 1.17.1; no package dependency
is added. All integral statuses are successful. The largest sum of relative
vector-integral error estimates is 1.45e-10. These are numerical error
estimates, not rigorous interval enclosures or sampling errors.

For each original vector, the included Person with largest absolute X is
used to check all 13 analytic derivatives by central differences at 1e-4 and
5e-5. The largest fine-step score and information discrepancies are 3.05e-9
and 3.25e-9. These four local derivative checks do not replace the full-data
comparison: all Persons enter the continuous reference and the package
information evaluations. The new reference also reproduces the preceding
independent R scalar integrals to within 1.37e-12 in total NLL.

The [R runner](mfrm-wide-map-lr-pcm-information-20261002.R) compares each same
parameter vector first at its retained q31. Only a failed integration
comparison triggers the next order, 2*q-1. The unchanged diagnostic bounds
from the earlier full-information audit are NLL difference <=1e-6, score
difference <=1e-7, full continuous score norm <=1e-4, and scaled Hessian,
covariance and expanded-SD differences <=1e-5. Covariance comparisons require
positive definite raw matrices and no regularization; their inverse residual
must be <=1e-6. The expanded map includes all free coordinates, the dependent
last facet/step levels and natural variance. These curvature-derived SDs are
diagnostic scales; their calculation alone does not qualify confidence intervals.

### Retained vectors: integration agreement is not stationarity

All four original vectors fail the continuous score-norm criterion. Their
q31 information comparisons also fail the stated strict bound. Smaller
intermediate-order misses are retained, rather than omitted from the
[initial summary](mfrm-wide-map-lr-pcm-information-initial-summary-20261002.csv).

| Job | Continuous score sup norm at original vector | Largest q31 expanded-SD discrepancy | First tested order passing value, score and information comparisons |
| --- | ---: | ---: | ---: |
| N20-rho0-PCM | 0.001034850 | 0.070806% | 121 |
| N20-rho0.5-PCM | 0.000190651 | 0.011082% | 61 |
| N240-rho0-PCM | 0.065718363 | 0.382873% | 121 |
| N240-rho0.5-PCM | 0.000779044 | 0.003901% | 121 |

The largest q31 scaled covariance-entry discrepancy is 0.0076721. At q61,
N20-rho0 still misses the 1e-7 score bound (3.50e-7) even though its
information comparison passes. N240-rho0 misses both score and information;
N240-rho0.5 misses the score bound. N20-rho0.5 meets all three same-vector
integration/information comparisons at q61. Thus one common new default
order is not selected. Passing at q61 or q121 evaluates a given vector
accurately; it does not make that original vector stationary.

### Four evidence-triggered local corrections

Because all four independent full gradients exceeded 1e-4, each received
one local Newton correction `par_new=par-H_continuous^-1*g_continuous`.
The already computed full reference information supplies H. The proposed
changes were below .01 coordinate units and .01 diagnostic SD units, the
scope guard for this local correction; these are not model parameter bounds.
The corrected vectors were independently integrated again and compared with
package scores/information at their individually qualified orders. No
simulation, new initializations or public `fit_mfrm()` refits were run.

| Job | Comparison order | Corrected continuous score sup norm | Largest coordinate movement in corrected-reference SD units | Corrected variance |
| --- | ---: | ---: | ---: | ---: |
| N20-rho0-PCM | 121 | 1.02063e-7 | 0.000405957 | 1.058186554 |
| N20-rho0.5-PCM | 61 | 1.11536e-9 | 0.000048142 | 0.874544350 |
| N240-rho0-PCM | 121 | 6.28988e-6 | 0.008748175 | 1.184971724 |
| N240-rho0.5-PCM | 121 | 2.91796e-9 | 0.000044127 | 0.751273887 |

All corrected vectors meet stationarity and same-vector numerical comparison
bounds, recorded in the [refinement summary](mfrm-wide-map-lr-pcm-information-refinement-summary-20261002.csv).
NLL improves in every case, by 1.65e-9 to 4.05e-5. The largest remaining
curvature-scaled gradient is 8.85e-7. There is no evidence-based reason to
repeat correction steps after these criteria pass.

At the corrected vectors, the largest package/reference NLL and score
differences are 4.81e-10 and 5.85e-8. The largest scaled Hessian and covariance
differences are 1.28e-7 and 1.23e-7. The largest relative expanded-SD difference
is 6.13e-8 (about 0.0000062%). Reference minimum eigenvalues range from
2.214208 to 28.009348; no eigenvalue floor or regularized inverse is used.
All matrices invert with package residuals below 3.94e-14.

The point movements are small compared with the diagnostic curvature scales.
For example, the largest variance adjustment is 1.183409310 to 1.184971724
at N240-rho0. The strict q31 failures must nevertheless be retained: a small
parameter change and an inaccurate score calculation are different findings.
Likewise, numerical agreement of the SDs does not establish their small-sample
sampling interpretation or the coverage of a normal interval.

### Reuse, output status and the remaining work

The calculation establishes locally stationary, positive-observed-curvature
research vectors and numerically accurate full joint information for these
four PCM views. It does not show uniqueness/global optimality among interior
solutions, estimate repeated-sampling bias/coverage, or resolve GPCM joint
boundaries. The two independent response cohorts do not become eight
replications through original/corrected evaluations. JML covariance/centering
and the broader model/ownership/missingness designs retain their own work.

Original `mfrm_fit` objects remain unchanged. Corrected vectors and full
matrices are retained as research evidence, without manufacturing a public
fit whose parameter tables, population fields or readiness metadata disagree.
The current native-location interval source contract still excludes
nonintercept latent regression. Connecting these qualified calculations to
coherent public fit/output objects and the agreed comparisons is the next
implementation decision; public population intervals are not newly enabled.

Full evidence is in `validation-results/mfrm-wide-map-lr-pcm-information-20261002/`.
Initial and corrected continuous references and package grid evaluations are
separately bound and saved. Each final evidence object includes both runner
sources and numerical runtime records. Reproduction from the package root:

```r
source('inst/validation/mfrm-wide-map-lr-pcm-information-20261002.R')
out <- 'validation-results/mfrm-wide-map-lr-pcm-information-20261002'
dlr_pcm_information_run(out)
dlr_pcm_information_refine(out)
```

A fresh-process replay with `system2` (Python invocation) and `optimHess`
traced to stop reproduced both summaries without integration or Hessian
recomputation. All numerical phase hashes and original witness-fit hashes
were unchanged. Python syntax, R static usage, local links and
`git diff --check` pass. No production source, public help/NEWS, CI workload
or R=50 initial-fit allocation changes; these research files are excluded
from package builds.

## October 3 coherent PCM public outputs and a GPCM zero-loading bound

### PCM: connect the verified calculation to intact public fit objects

The previous local Newton vectors were research evaluations. Substituting
them into `opt$par` alone would leave population fields, parameter tables,
Person scores and numerical metadata out of agreement. The public one-family
direct-MML path has no warm-start/finalization entry point. Four public
`fit_mfrm()` calls therefore reconstruct complete fit objects using the same
saved data, individually qualified orders 121/61/121/121 and `reltol=1e-12`.
This stricter objective tolerance is followed by independent score checks;
it is not itself taken as proof of stationarity. No new response data, starts
from truth or repeated-sampling conditions are introduced.

The [public-output runner](mfrm-wide-map-lr-pcm-public-output-20261002.R)
checks parameter expansion against both population representations, all
structural tables and the public summary. It independently integrates the
continuous score and observed information at each **new** vector, then
compares the package's full joint information at the selected order. The
previously stated numerical criteria all pass.

| Job | Public fitting seconds | Continuous score sup norm | Largest distance from the research Newton vector, in reference-SD units |
| --- | ---: | ---: | ---: |
| N20-rho0-PCM | 1.785 | 9.41291e-7 | 8.34801e-8 |
| N20-rho0.5-PCM | 1.621 | 6.21961e-7 | 1.92118e-7 |
| N240-rho0-PCM | 5.007 | 3.93742e-6 | 5.36450e-7 |
| N240-rho0.5-PCM | 5.025 | 2.71692e-6 | 8.16246e-8 |

These times cover the public fitting calls, not independent integration or
the entire study. All 13 free coordinates have named estimates and a complete
research covariance matrix. The full-matrix inverse, rather than an isolated
regression block, supplies the population diagnostic SDs. The maximum
package/reference expanded-SD relative difference is 6.13e-8. Original q31
fits and the separate Newton evidence remain unchanged. Saved public summaries
replay identically. This closes the fit/table consistency problem for these
four PCM examples; population `vcov()`/formal intervals and repeated-sampling
coverage are not added by this research runner.

### October 4: public structural intervals with regression nuisance parameters

`mfrm_facet_intervals()` now admits full-rank conditional-normal RSM/PCM
regressions through its experimental native-scale model-information route.
It preserves the existing source, category, local-solution, full-information
and finer-integration checks. GPCM latent regression remains outside this
extension. The full covariance includes every regression coefficient and log
residual variance before the structural contrast transformation; no nuisance
block is held fixed. The retained population table labels coefficients and
residual variance explicitly, rather than presenting coefficients as marginal
population means. This adds structural uncertainty, not a population `vcov()`
or population-coefficient/variance confidence-interval API.

The four coherent public fits above were reused without optimization or new
data. Each returns Rater location intervals from 13-coordinate joint
information. Relative differences from their retained independently integrated
continuous-reference covariance are 6.18e-8, 6.09e-8, 1.03e-7 and 9.51e-8
for N20/rho0, N20/rho.5, N240/rho0 and N240/rho.5 respectively. The ordinary
native-location regressions and the new source/rank/cross-information checks
pass. A saved N20 fixture retains that independent covariance, so the new
test does not use a second call to the package Hessian as its reference.
The existing RSM-61 regression fit from the full-information archive also
passes; its structural covariance differs from its continuous reference by
8.84e-8 relatively, without refitting.

Fresh R 4.6.0 and 4.6.1 sessions, both with Matrix 1.7-6, replay all four
results while fitting and covariance calculation are disabled. Result/report
tables, export/reopen, actual 7-by-5-inch rendering and redraw agree. The
English public plot was visually checked. Evidence and exact qualification/
replay scripts are in
`validation-results/mfrm-wide-map-lr-pcm-location-intervals-20261004/`.
This closes a structural-output gap; it does not establish repeated-sample
coverage. Population intervals, the declared new-Person scoring follow-through
and Gaussian R50 performance evaluation remain required.

### October 4: separate public population intervals and saved replay

`mfrm_population_intervals()` now reports the conditional-normal RSM/PCM
population coefficients and residual variance. It uses normal coefficient
intervals and exponentiates the normal log-variance interval. `vcov()` retains
coefficient/log-variance coordinates. The covariance comes from the inverse
of full joint information; it is not an inverse of an isolated population
block. A qualified saved native-location result can supply this covariance
without repeating differentiation. Direct-fit calls use the same source,
support, local-solution and finer-integration checks. Failed checks retain
points and reasons with unavailable uncertainty. GPCM regression, a
zero-variance boundary and misspecified/dependent populations remain outside
this experimental interior procedure.

All twelve population targets from the same four PCM fits are available.
Relative discrepancies against the saved independent continuous-reference
covariance are 1.22e-7, 8.41e-8, 9.16e-8 and 1.01e-7 for N20/rho0,
N20/rho.5, N240/rho0 and N240/rho.5. This required zero fits, zero new
information calculations and zero new datasets. The focused population tests
pass 45 expectations; the existing regression structural/result tests also
pass. Finite log-scale bounds remain explicit if exponentiation exceeds
floating-point range, distinguished from unavailable intervals.

Fresh R 4.6.0/4.6.1 sessions with Matrix 1.7-6 reproduce all four saved
results, report tables, CSV bounds/scales/status, and RDS reopen while fitting
and information calculation are disabled. Mixed structural/population
attachments preserve their separate tables and qualifications. Evidence,
source snapshots and exact scripts are retained in
`validation-results/mfrm-wide-map-lr-population-intervals-20261004/`.
The ordinary population summary remains point-only. This completes the
population output implementation and bounded numerical/replay checks, not
its repeated-sample qualification. The subsequent scoring bridge below closes
the bounded Gaussian future-output check. Freezing of the boundary/interval
procedure and Gaussian R50 evaluation remain required.

### October 4: conditional regression scoring and future-output bridge

The existing fitted-object scorer now applies its local calibration and
integration checks to full-rank RSM/PCM regressions. It additionally checks the
same consistent native source/constraints as the population interval route.
Neither the retained global readiness record nor the statistical interpretation
is promoted: these EAPs and continuous posterior intervals condition on fitted
calibration/population points. GPCM regression remains review-only. The public
regression/source tests pass, alongside the existing conditional-scoring and
F-accounting tests. The retained RSM-61 fit also passes an actual scoring call,
with no new RSM calibration.

The Gaussian future generator reuses A/B's independent M=60 population cohort
and its paired L1/L2 events, adding X from the previously reserved D-LR future
substream. X follows the same joint-normal law as training, shares its normal
primitive between rho=0/.5 and exposure views, and preserves global RNG state.
Only observed X and responses enter scoring. All four saved PCM fits pass the
source checks. All eight default-31 batches fail the stated EAP/SD integration
criterion; the planned q61/q121 retries deliver all 480 scoring targets and
their conditional intervals, at q61 for L1 and q121 for L2. These targets share
two calibration and two future cohorts; they are not 480 independent trials.
No calibration was refitted, no failed batch was subdivided and no source
tolerance was relaxed.

Both fresh R 4.6.0 and 4.6.1 sessions reproduce summaries, saved objects,
prior parameters, numerical eligibility, unrounded CSV exports and HTML
reports for all eight batches, with fitting/scoring/source review disabled.
Existing export diagnostics were generated once per source and reused. CSV
comparisons preserve explicit Person alignment while ignoring vector-name
attributes, which CSV does not store; discrepancies are at ordinary text
rounding scale. The original A/B panel checksum is R-version-specific because
its serialization fingerprint includes the writer version. Its R4.6.0
preflight refusal was retained, and the actual scoring run used the original
R4.6.1 runtime; no saved checksum was rewritten to bypass that check.

The source-bound generator/run/replay records and one inspectable export per
runtime are in `validation-results/mfrm-wide-map-lr-scoring-20261004/`.
These results qualify the bounded source/output path. The subsequent frozen
PCM procedure below starts the development R50 evaluation. Independent
confirmation, boundary-attaining inference, other regression models, missing-X
and predictor/shape/transfer extensions retain their separate obligations.

### October 4: frozen PCM interior selection and first R50 condition

`mfrm-wide-map-lr-pcm-stages-20261004.R` freezes `PCM-LR-interior-v1`
for the existing Gaussian PCM allocation. Each public fit uses direct fixed-grid
MML, BFGS, maxit 400 and reltol 1e-12. Orders are 31, 61 and 121;
scoring-source and interval selection retain their separate first acceptable
orders and the existing finite integration-only retry rules. A generic error,
weak category information or regularized comparison information is not
silently converted to an integration retry. The population table reuses the
structural interval's full joint covariance. Criterion locations, the 1-minus-2
contrast, population coefficients and log residual variance remain in both
default and refinement records, including unavailable outcomes and reasons.
Truth is joined only after selection.

The zero-variance categorical nuisance problem starts at zero, independent of
the positive-variance fit. Its analytic score/information, positive dual
probabilities, moment/mass residuals and entropy gap are checked. One Newton
correction smaller than 1e-5 may resolve nlm's objective-roundoff code 3, only
with the same final score and dual checks; the original code is retained.
Continuous normal integration at the unchanged public interior point must
beat the qualified boundary likelihood by more than 1e-6 plus its summed
relative integration error. This is numerical boundary exclusion, not a
global-maximum proof or a boundary confidence interval. An unresolved boundary
keeps the public point but prevents selection of its interior inference/source.
The analytic likelihood now accepts the allocated higher exposures; every new
sample receives its own qualification, without borrowing the earlier
four-sample existence proof.

The neutral-start boundary check reproduces the four earlier boundary optima
and interior gains (14.5470, 12.2174, 205.7294, 125.2976), without any interior
refit or new data. The two N240 auxiliary solutions require corrections of
6.10e-8 and 1.14e-8; all final maximum gradients are below 2e-13. Exact source
snapshots matching that check's original hashes are retained in
`validation-results/mfrm-wide-map-lr-pcm-procedure-20261004/boundary-check-source/`.
The 23 focused orchestration expectations cover split source selection,
boundary refusal, completed failures, complete denominators and replay.
Fresh R4.6.1 replay of actual q31/q61/q121 jobs reproduces selected outputs
and records exactly with fitting, boundary likelihood evaluation, information,
interval generation and source review disabled.

The first N20/rho0/SD1/paired-L1 condition is complete. Of 50 datasets, the
default order delivers 13 scoring sources and 31 interval sets; refinement
delivers 47 and 48 respectively. One sample has weak category information;
another lacks qualifying comparison information, and two source reviews
remain outside their integration tolerance at q121. All 50 remain counted.
The Criterion 1-minus-2 interval covers truth in 46/48 delivered intervals
(46/50 planned); the population intercept, X coefficient and log variance
cover in 44, 46 and 47 of the 48 delivered sets. These are development results
including one prior development witness, not independent coverage qualification.
The first frozen procedure retains the initial q31 settings and selection
history; the earlier four higher-order public fits remain separate development
evidence, not silently substituted for this algorithm's initial calls.

`mfrm-wide-map-lr-pcm-r50-20261004.R` preserves all 72 allocated PCM conditions
and 3,600 jobs, with N20--480, SD .5/1 and their original full/paired exposure
views. The continuing serial worker uses a separate frozen source, R4.6.1,
the retained dependency library and one numerical thread. It next processes
N20/rho.5 and the two N240/SD1/paired-L1 cells before the remaining allocation.
Completed phases replay without fitting. Source-bound manifests, per-job
default/refinement records, the first condition summary, replay and resumption
records are in `validation-results/mfrm-wide-map-lr-pcm-r50-20261004/`.
This is the PCM calibration/interval unit; future-person scoring, RSM/GPCM
regression, boundary-attaining uncertainty and final independent confirmation
are not counted as completed by these jobs.

**L2 dispatcher correction.** Inspection across the exposure conditions found
that the D-LR argument builder, originally used only for L1 witnesses, had not
carried A/B's explicit `repeated_ratings='independent'` declaration into L2.
Consequently the first two completed L2 conditions each had 50 input-review
refusals. These are superseded execution outputs, not evidence of statistical
failure under the intended independent-event law. The dedicated worker was
identified and interrupted with SIGINT; its saved phases and source archive
were preserved. The L1-only continuation uses the original frozen source.

The corrected L2 builder verifies the allocated Event IDs, unique
Person/Rater/Criterion/Event keys, twelve events per Person and exact response
rows before declaring conditional independence. It preserves Event in the
saved call, and the stage validator now rejects repeated cells without that
declaration before any fit. Numerical orders, optimizer, likelihood, boundary
qualification and interval rules are unchanged. The first actual L2 rerun has
bit-identical optimizer parameters, objective and prepared observations to its
original q31 fit; all fourteen selected outputs are available. Fresh R4.6.1
replay with estimation/inference/boundary computations disabled is exact. The
focused execution checks, including the missing-declaration regression, pass.

The repaired `PCM-LR-interior-v1-events` L2 calls use their own frozen source
and results under `mfrm-wide-map-lr-pcm-r50-events-20261004/`. The original
root's `event-epoch-map.rds`/CSV assigns every condition to exactly one of the
original L1 or corrected L2 epochs, retaining 72 conditions and 3,600 jobs.
Old L2 attempts remain inspectable but must not be mixed into availability or
coverage denominators for the repaired method. No response dataset or
independent statistical replicate was added by this correction.

The first four repaired N20/L2 conditions have now completed all 50 jobs
each. The epoch-mapped read verifies each saved record checksum and excludes
superseded attempts; its script/output are retained as `lr-epoch-progress.R`
and `.log` in the corrected L2 root. The following are refined outputs and
truth-inclusion counts, all with planned denominator 50 per condition:

| SD | rho | Sources available | Interval sets available | Criterion 1-2 covered | Intercept covered | X covered | Log variance covered |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 0.5 | 0 | 49 | 49 | 46 | 43 | 45 | 49 |
| 0.5 | 0.5 | 49 | 49 | 46 | 44 | 47 | 49 |
| 1 | 0 | 45 | 49 | 45 | 45 | 47 | 46 |
| 1 | 0.5 | 48 | 50 | 46 | 44 | 49 | 46 |

At SD0.5, replicate 2 retains an unresolved zero-variance comparison and
information/score failure in both rho conditions; this is unavailable
interior inference, not a proven boundary maximum. At SD1/rho0, replicate 21
has regularized comparison information. The remaining source refusals at
SD1 are final-grid integration failures, while their interval selection can
still succeed under its separate rule. These results expose actual inferential
limits after repairing admission. They do not qualify nominal coverage,
remove failed cohorts from the planned denominator, or supply independent
confirmation. The original shared-input relationships across conditions
remain unchanged, and the medium/large-N and other exposure work continues.

**L1 runtime recovery.** The original L1 continuation stopped at
N60/SD0.5/full-L1/rho0 replicate 5 because `wide_mml_runtime()` refused an
NA file hash before the next stage. That process did not retain the specific
unreadable path; its cause is not inferred. A fresh R4.6.1 process in the
same frozen L1 source verifies the manifest, every frozen numerical-source
hash, the runtime and loaded-DLL digest, and all 1,304 completed records
(28 rows per job). It resumes only the 1,496 incomplete L1 jobs, reusing any
matching saved phases. The numerical guard, statistical algorithm, failure
rules and condition allocation are unchanged. The original audit/log remain;
`resumption-l1-runtime-20261004.rds`, `lr-pcm-resume-l1-runtime.R` and
`run-l1-runtime-20261004.log` record the recovery in the original results root.
The same guard later refuses a hash before N120/SD1/full-L1/rho0 replicate 1.
A fresh process again verifies the frozen source/runtime/DLL and all 1,900
completed L1 records, then resumes the 900 incomplete jobs. Its diagnostic
observer records any NA digest's exact path at `tools::md5sum()` return,
without bypassing the guard, changing the frozen files or retrying a failed
statistical procedure. `resumption-l1-diagnostic-20261004.rds` and the matching
script/log retain this recovery. The cause remains unresolved until a failed
path is captured; the 41-condition assessment below is its earlier snapshot.
The observer subsequently captures the failed path: a `pkgload` temporary
`mfrmr.so` no longer exists at the final runtime guard for N120/SD1/paired-L1/
rho0.5 replicate 1. In a separate no-fit reproduction, two `load_all()` calls
leave two same-name DLL entries; global name lookup selects the older path,
whereas the current namespace refers to the newer copy. Both copies have the
unchanged digest 65bc36d69ba885e935d19f7f3e2cd3d9. The short reproduction does
not itself delete the old file; the observed failure and `pkgload`'s namespace
finalizer, which unlinks its temporary DLL, identify the relevant lifecycle
hazard without treating it as a statistical failure.

The retained frozen scripts now resume through one fresh R process per
condition, with exactly one package load. A preflight verifies the identical
source/runtime and all 2,050 completed L1 records, then queues the 750
incomplete jobs. Each child keeps the original guards and manifests and
checks that its sole global DLL entry matches the current namespace and
original digest. Saved phases remain reusable. The diagnosis, reproduction,
`resumption-l1-process-isolation-20261005.rds`, queue and launcher/child scripts
are retained in the existing results root; no frozen numerical file or
failure policy is changed.
The first isolated condition completes all 50 jobs and passes its final
single-DLL/namespace/runtime checks before a new process starts N240.
The interrupted replicate's nine q31/q61 phase files retain their pre-failure
timestamps; only its final selection and record files are newly completed.
`isolated-condition-runtime-20261005/` binds the successful child to the
queue, script and unchanged loaded-DLL digest.

**Completed-condition assessment.** A subsequent epoch-mapped snapshot has
2,090 of 3,600 job records and 41 of 72 complete R50 conditions. The summary
verifies both source archives/manifests and every included record checksum;
all 28 rows of the earlier N20/rho0/SD1/paired-L1 summary reproduce its saved
common fields. Partial conditions remain in the progress denominator but
are not mixed into complete-condition coverage. Default and refined outputs,
source versus interval availability, bias, empirical SD, mean SE/width and
both inclusion denominators are retained in `summary-completed-20261004`
RDS/CSV, with the summary script, log and refusal table in the original root.

The completed cells already identify limits that a high overall delivery
rate would obscure. At N20/SD0.5/paired-L1, intervals are available for
43/50 (rho0) and 40/50 (rho0.5), versus 49/50 in both corresponding L2 cells.
The L1 refusals include category support and unresolved boundary/information
checks; they are not removed from the denominator. At N240/SD0.5/paired-L2,
rho0 has two optimizer-convergence refusals, while rho0.5 returns all 50
interval sets. These are distinct from the small-cohort admission limits.

For the X coefficient at N40/SD0.5/rho0, all 50 intervals are available but
truth inclusion is 41/50 for full-L1 and 42/50 for paired-L1. The corresponding
mean SE/empirical-SD ratios are 0.741 and 0.773. These adverse development
results remain visible; no empirical SE multiplier or selected interval rule
is introduced. Each condition has only 50 cohorts (the returned-and-covered
MCSE at 41/50 is 0.054), and conditions share input streams. They cannot be
pooled as independent evidence or qualify nominal coverage. Remaining
conditions, output-specific interpretation and frozen-procedure independent
confirmation still determine the supported inference claim.

The October 5 snapshot in `summary-completed-20261005` has 53 complete
conditions and 2,668/3,600 job records. It reuses all 41 earlier complete
condition summaries exactly after verifying their input hashes, and reads
only the newly complete conditions for additional estimates. The relevant
new comparison is beta:X at N120/SD0.5: both full-L1 and paired-L1 deliver
50/50 intervals, including truth in 48/50 at rho0 and 49/50 at rho0.5.
Mean-SE/empirical-SD ratios are respectively 1.036/1.058 and 1.088/1.077;
returned-and-covered MCSEs are 0.028 and 0.020. These larger-cohort cells
contrast with the retained N40 under-inclusion; they do not identify a
universal N cutoff, erase adverse cells or qualify independent coverage.
The procedure and denominator remain fixed. The new summary script, source
bindings, previous-summary identity and log are retained in the same root.

The subsequent N240/SD0.5 comparison is complete for both rho values and
all three exposure views (`summary-completed-20261005-n240`). Its snapshot
contains 60 complete conditions and 3,021/3,600 records; the previous 53
complete-condition summaries are reused exactly after hash checks. For
beta:X, full-L1/paired-L1/paired-L2 return 47/49/48 intervals at rho0 and
47/48/50 at rho0.5. Returned-and-covered counts, retaining all 50 attempts,
are respectively 45/47/44 and 45/44/46. Mean-SE/empirical-SD ratios range
from 0.911 to 1.067, and returned-and-covered MCSEs from 0.034 to 0.046.
The N240/SD0.5/full-L1/rho0.5 replicate-19 record, for example, clears the
zero-variance comparison but fails the public numerical convergence check;
its unavailable outputs remain in the denominator. These results do not
establish monotone improvement with N or independent nominal coverage.
No source, fit, selection rule or numerical acceptance threshold changed.

The matched N240/SD1 comparison (`summary-completed-20261005-n240-sd1`)
now completes both rho values and all three exposure views. The snapshot
contains 65 complete conditions and 3,289/3,600 records, with all 60 earlier
complete-condition summaries reused identically after source/input hash
checks. For beta:X, full-L1/paired-L1/paired-L2 return 48/50/50 intervals
at rho0 and 49/50/47 at rho0.5; returned-and-covered counts are 44/45/46
and 44/44/43. Mean-SE/empirical-SD ratios range from 0.872 to 1.001,
and returned-and-covered MCSEs from 0.038 to 0.049. These cells retain
the same denominator, failures and experimental interval rule as the SD0.5
controls. They establish neither a monotone N effect nor nominal coverage;
no success-only selection or empirical SE inflation is applied. The summary
script and log are retained alongside the source/input-bound result files.

The N480/SD1/rho0 comparison now includes all three exposure views
(`summary-completed-20261005-n480-rho0`). The snapshot contains 70 complete
conditions and 3,503/3,600 records; all 65 preceding complete-condition
summaries are reused identically after source/input hash checks. For beta:X,
full-L1/paired-L1/paired-L2 return 48/49/47 intervals and return-and-cover
45/46/42 of the 50 planned attempts. The corresponding mean-SE/empirical-SD
ratios are 0.957/0.914/0.947, with returned-and-covered MCSEs 0.042/0.038/0.052.
All six unavailable interval cases pass the zero-variance comparison but fail
the public optimizer's numerical convergence checks. The paired-L2 result
therefore retains both three unavailable cases and five returned intervals
missing truth. Increasing cohort size or exposure has not made the
all-attempt result uniformly better. These are descriptive development
comparisons; they neither qualify nominal coverage nor justify a new cutoff,
failure rule or empirical SE inflation. At that snapshot the two remaining
rho0.5 L1 conditions were still running under the same frozen procedure.

**October 5 completed PCM allocation.** All 72 conditions and 3,600 planned
records now complete the frozen calibration/interval procedure. The final
single-load runtime/DLL checks pass. `summary-completed-20261005-final`
reuses all 70 earlier complete-condition summaries identically after source
and input hash checks; no earlier fit or summary is recomputed. The final
N480/SD1/rho0.5 comparison is:

| View | Beta:X intervals returned / 50 | Returned and covered / 50 | Mean SE / empirical SD | Returned-and-covered MCSE |
| --- | ---: | ---: | ---: | ---: |
| full-L1 | 49 | 47 | 1.0514 | 0.03359 |
| paired-L1 | 48 | 46 | 0.9695 | 0.03837 |
| paired-L2 | 46 | 45 | 1.0583 | 0.04243 |

The newly completed full-L1 replicate 27 and paired-L1 replicates 9/25 clear
the zero-variance comparison but fail optimizer convergence for interval
delivery. Point-source counts are separately 46/47/42: the prescribed point
and interval source/order selections are distinct, so these denominators
must not be interchanged. Across all 72 cells, beta:X interval delivery ranges
from 40 to 50 and returned-and-covered counts from 37 to 50. The lowest
all-attempt count, N20/SD0.5/rho0.5/paired-L1, is 37/50 with 40 intervals
returned; its MCSE is 0.0620. This preserves both numerical refusals and
conditional misses. Completed development execution does not establish a
sample-size cutoff, nominal coverage, boundary-attaining inference, other
regression-model support or independent confirmation. Those decisions and
the other population/scoring obligations remain open.

The completed comparison now adds pointwise exact binomial Monte Carlo
intervals for delivery, returned-and-covered frequency and conditional
coverage, plus bias/width MCSE and a delta-method RMSE MCSE. All original
summary values are preserved exactly. `comparison-completed-20261005`
also compares refinement with default and both full-L1 and paired-L2 with
paired-L1. Every paired row verifies all 50 shared Parent IDs and the two
input hashes against the frozen registry and saved record bindings. Its
binary-difference MCSE uses the paired discordant counts; no cross-N/SD
pairing or pooling across targets is introduced.

For the refined beta:X interval, the independent-repeat comparison
(paired-L2 minus paired-L1) answers the exposure question as follows:

| N / SD / rho | Delivery difference (MCSE) | Returned-and-covered difference (MCSE) | Both returned | MSE difference on that common-return subset (MCSE) |
| --- | ---: | ---: | ---: | ---: |
| 20 / .5 / 0 | .12 (.0464) | .12 (.0545) | 43 | -.006452 (.004091) |
| 20 / .5 / .5 | .18 (.0549) | .20 (.0639) | 40 | -.008183 (.003726) |
| 480 / 1 / 0 | -.04 (.0400) | -.08 (.0481) | 46 | -.000442 (.000278) |
| 480 / 1 / .5 | -.04 (.0492) | -.02 (.0451) | 44 | -.000677 (.000247) |

The full paired table retains every allocated comparison and all seven
targets. More repeated ratings can improve conditional estimation error
without uniformly improving this numerical procedure's all-attempt delivery
or truth inclusion. These observed differences do not establish a general
ranking; common-return MSE conditions on selection, and the comparisons are
not independent confirmations or simultaneous statements. For example, the
N20/SD.5/rho.5 paired-L1 beta:X delivery rate 40/50 has exact 95% MC limits
[.6628,.8997], while 37/50 returned-and-covered has [.5966,.8537]. Its 37/40
conditional coverage has [.7961,.9843]; that latter interval must not replace
the all-attempt result. The new records add no fits, random draws or changes
to source/interval eligibility.

### GPCM: one bound covers finite zero variance and all-zero-loading limits

Let `r_g=a_g*sqrt(v)`. The earlier compactness argument bounds every r_g on
a relevant likelihood superlevel set. It leaves boundaries where all r_g
vanish and boundaries where a proper nonempty subset survives. The first
class can be bounded **without locating every nuisance maximum or selecting
a representation at an aliased boundary**.

For any finite original parameters, write the adjacent logits at the Person
mean as

    d_gk - h_gr + t_g*X_i,
    d_gk=a_g*(gamma_0-c_g-tau_gk),
    h_gr=a_g*b_r, t_g=a_g*gamma_1.

The latent part adds `r_g*Z`, with Z standard normal. Relax the shared slope
relations: allow three unrestricted adjacent intercepts, two centered rater
effects and one X effect **independently for each of the three criteria**.
This gives an 18-coordinate ordinary categorical regression at zero loading.
Every finite-slope v=0 GPCM is contained in it. Its negative log likelihood
is convex because every category utility is affine in these coordinates.

The same upper likelihood bound covers even divergent nuisance sequences
when **all** r_g tend to zero. For a category probability under an additive
ability shift t, `p_y'(t)=p_y*(y-EY)`. With scores 0,...,K, its absolute value
is at most K/4: condition on Y differing from y and use
`p_y*(1-p_y)<=1/4`. Telescoping the product over a Person's ratings therefore
gives the uniform bound

    |E_Z prod_j p_j,y_j(offset_j+r_g(j)*Z)
             - prod_j p_j,y_j(offset_j)|
      <= sqrt(2/pi)*(K/4)*sum_j r_g(j).

This bound is uniform in all offsets, including offsets that diverge. For
the fixed observed sample it tends to zero as all loadings vanish. The
zero-loading product belongs to the relaxed family at each finite point of
the sequence. Thus every such limiting joint likelihood is at most the
supremum of that relaxed model. This argument does not require finite limits
of the original slopes, locations or regression coefficients.

The [zero-loading runner](mfrm-wide-map-lr-gpcm-zero-bound-20261002.R)
solves the four convex relaxations and constructs a feasible categorical
probability dual. Write D_jk for the utility designs and s for the observed
design total. Feasible probabilities q obey row sums one and `sum q_jk D_jk=s`.
The log-sum-exp variational identity gives

    NLL(eta) >= -sum_jk q_jk*log(q_jk).

At a fitted point, let g and H be its gradient and Hessian. The correction
`q_jk=p_jk*[1-(D_jk-E_p D_jY)'H^-1*g]` preserves row sums and cancels the
design residual algebraically. Positivity, constraint residuals and the
primal/dual gap are checked numerically. The largest absolute dual gap is
4.10e-12, the largest design residual is 2.49e-14, and all probabilities are
positive. These are floating-point feasibility checks, not interval-arithmetic
enclosures. Independent continuous-normal integration evaluates the retained
interior GPCM vectors; none is refitted for this comparison.

| Job | Relaxed zero-loading NLL bound | Retained continuous interior NLL | Interior log-likelihood advantage over the boundary bound |
| --- | ---: | ---: | ---: |
| N20-rho0-GPCM | 152.0730 | 137.4792 | 14.5939 |
| N20-rho0.5-GPCM | 148.1520 | 136.0379 | 12.1141 |
| N240-rho0-GPCM | 1942.453 | 1736.643 | 205.8101 |
| N240-rho0.5-GPCM | 1818.240 | 1693.103 | 125.1376 |

An additional native-kernel check evaluates the matching finite-variance-zero
model at a one-node fixed-mean rule and compares its utility with the relaxed
categorical design. The four differences are 8.53e-14, zero, 4.55e-13 and
6.83e-13, respectively (`native-kernel-check.rds` in the bound evidence).
This checks the parameter/design mapping; the one-node calculation alone
would not bound limits with a surviving scaled loading.

All four retained interior values exceed this global relaxed-boundary upper
likelihood bound by substantial numerical margins. Consequently finite v=0
points, their aliases, and all-zero-loading divergent paths are excluded as
global maximizing limits for these samples at the stated numerical precision.
This is stronger than comparison with one locally optimized finite boundary.

### What the GPCM bound deliberately does not settle

If some r_g have positive limits, their shared latent term survives and the
independent categorical relaxation is not an upper likelihood bound. For
three owners there are six proper nonempty surviving subsets. Their nested
limits and any nuisance escape must remain in a further boundary comparison;
one-node evaluation or the positive natural-variance score from PCM cannot
replace it. The current result does not establish a global interior GPCM
maximum, select one interior solution or qualify its full joint covariance.
Other ownership and response-support designs also need their own bound.

A saved-data screen additionally relaxes each surviving owner to a free
Person/owner offset. Empirical category frequencies within roster-and-score-total
strata give exactly feasible rational active-owner duals: row sums, individual
score totals and all six categorical-regression coordinates cancel exactly.
Combining these with the existing numerical inactive-owner duals gives a cheap
candidate bound for each of the six subsets. The four retained samples yield
24 negative differences between the dual NLL bound and retained interior NLL,
from -25.6 to -506.3; this witness is too loose to exclude any face. No fit,
integration or new response is generated, and no readiness decision changes.
The inactive dual and interior likelihood retain their earlier numerical
qualification; the exact active dual alone is not a complete boundary
certificate. Stronger treatment of the surviving dependence remains required.
The export, rational checks and inconclusive screen are retained in
`validation-results/mfrm-wide-map-lr-gpcm-surviving-bound-20261005/`.
The stronger existing conditional-entropy optimizer and its independent raw
balance checker were then applied to the same inputs. Ten owner witnesses
have exactly feasible rational projections and duality gaps below 3.59e-14;
the owner-2 N20 cases retain a weaker feasible swap witness with gap 8.295.
The resulting 24 subset margins are still negative (-4.65 to -437.65).
Thus optimizing this free-Person relaxation has not resolved the boundary
question (`optimized-owner-bounds/`); it does not justify another unchanged
original fit or treating a local boundary candidate as a global bound.

For a single surviving owner, an auxiliary PCM latent-regression fit gives a
feasible boundary candidate. If its latent SD is sigma and t tends to zero,
set the active GPCM slope to sigma/t and each inactive slope to sqrt(t/sigma).
Their product is one. Centered Criterion/step coordinates can reproduce the
active PCM logits while the inactive owners tend to their empirical categorical
distributions; the original Rater and X effects scale by the active slope.
Two mapping cases (N20/rho0/owner1 and N240/rho.5/owner3) match the independent
q31 utility within 1e-8, and continuous-normal integration has maximum reported
relative error 9.74e-12. Their log-likelihoods are respectively 16.98 and 199.43
below the retained interior values. Positive finite embeddings satisfy the
original centering and product constraints, and a fresh saved-result replay
passes with fitting and integration disabled. These are feasible candidates,
not supremum bounds for the faces. The other singleton cases, all two-owner
faces and their escaping nuisance limits remain open. Evidence is retained in
`singleton-candidates/`; neither public readiness nor the simulation allocation
changes.

The next calculation retains the normal regression structure at each of those
two saved loading values. For fixed loading, the integrand is jointly
log-concave in the six linear nuisance coordinates and latent variable;
marginalization therefore gives a concave log likelihood. This is the present
model's application of the marginalization property used in
[Ekvall and Bottai, Supplement, Lemma B.1](https://koekvall.github.io/files/finite_regr_suppl.pdf),
not a qualification of this model by that paper. Observed-category probability
bounds inside a normal truncation interval give a finite nuisance superlevel
polytope. Twelve nonnegative rational LP duals per case bound its coordinate
directions; a fresh checker rebuilds every raw inequality from adjacent logits
and verifies the dual identities exactly. Continuous values reproduce the
previous independent R calculation, and the six N20 score coordinates match
central differences within 6.49e-9. The value/score integration and resulting
supporting-plane comparisons remain numerical, not interval certificates.

The existing powered-discordance bound at power one also bounds large
singleton loadings, uniformly in the regression means. At small loading r,
the two-rating score bound gives a likelihood-ratio factor no larger than
`E exp(6*r*abs(Z)) <= exp(18*r^2)*(1+6*r*sqrt(2/pi))` per Person. Combining these
with the retained inactive-owner bounds leaves finite loading intervals
(1/16,16) for N20/rho0/owner1 and (1/32,32) for N240/rho.5/owner3. The inactive
dual and interior comparison still have their original numerical qualification.
Only one loading value inside each interval has been evaluated with the
nuisance supporting plane; uniform treatment of the middle intervals is still
required, along with the other singleton and two-owner cases. Evidence is in
`singleton-candidates/fixed-sigma/`. Those initial numerical calculations alone
do not close a boundary face; the subsequent enclosed calculation below does
close one named singleton face.

### Enclosed zero-loading and singleton comparisons, October 5

The inactive categorical duals now have positive rational probabilities with
exact row sums and sufficient-statistic balances for all twelve owner/sample
combinations. A separate checker reconstructs the adjacent-logit constraints
and encloses their entropy independently. The retained full-GPCM vectors also
now supply rigorous feasible-interior likelihood lower bounds: interval
exponentiation enforces the centered log slopes, and concavity of each
Person's log joint density permits exact integration of lower log chords.
Omitted normal tails contribute nonnegative probability. Fresh reconstruction
checks the logits, all chord endpoints and their integrals. These computations
reuse the saved fits; they do not prove interior global optimality.

Combining these bounds excludes the all-zero-loading boundary with guaranteed
log-likelihood margins 14.0763, 11.6638, 198.5097 and 120.0423 for
N20/rho0, N20/rho.5, N240/rho0 and N240/rho.5 respectively. Unlike the earlier
numerical comparison, this result does not use a floating-point feasibility
residual or a numerical integration error estimate as a certificate.

For a fixed singleton loading, interval value and score integration now bounds
the supporting plane over the exact nuisance superlevel polytope. Independent
raw two-rating checks verify the integration geometry, LP duals and tangent
bound. Normal-density domination transfers each bound to smaller loadings;
the four-category temperature inequality transfers it to larger loadings while
rescaling all six nuisance coordinates. These are uniform nuisance bounds,
not interpolation between fitted likelihoods. Small-loading concavity/MGF and
large-loading powered-discordance bounds supply the two remaining tails.
Those tail bounds now cover all twelve singleton cases. An independent checker
rebuilds every raw response-pair count and score coefficient, checks the exact
conditional-entropy witnesses and recomputes each separation at higher
precision. The two previously evaluated tail results reproduce exactly;
no middle interval is counted as covered by this extension.

For **N20/rho0/owner1**, four checked loading anchors (.294, .678719, 2.6 and
6.45) and those tails cover every positive loading. A fresh checker verifies
the transfer inequalities and complete interval coverage independently. Thus
this named singleton face is excluded, including its escaping linear nuisance
sequences. **N20/rho0/owner2** now also closes with five independently checked
anchors (.318, .75, 1.68, 5.12 and 14.7) and the same uniform tail argument.
Its separate complete-cover checker verifies all nine elementary intervals.
The subsequent covers close N20/rho0/owner3 and all three N20/rho.5 singleton
faces as well. Every one of these six N20 faces has a separate complete-cover
check. The stronger inactive-factor argument below also closes
N240/rho.5/owner3 using three existing anchors. The other five N240 singleton
faces, complete coverage of the two-owner faces, interior solution selection
and full joint inference remain open; neither this result nor the all-zero
comparison qualifies the GPCM public inference gate.

Evidence is in `inactive-exact/`, `interior-lower/`,
`enclosed-boundary-comparison.json`, `all-singleton-tail-enclosures.json`
with its independent `-check.json`, and
`singleton-candidates/fixed-sigma/N20-rho0-GPCM-owner1-cover/` under the
surviving-bound root above. The complete-face record is
`coverage-89ef5a067f75b6b7e031.json` with its separate `-check.json`; source and
input identities bind every reused component.
The second complete-face record is
`singleton-candidates/additional-fixed-sigma/N20-rho0-GPCM-owner2-cover/coverage-ab029884051a99b78a14.json`
with its independent `-check.json`.
The additional N20 complete-cover identities, in owner-3/rho0 then
owner-1/2/3/rho.5 order, are `d4946fb4729d77cdb706`,
`78bdc31bf7784b6fa206`, `d89cc6184a09ac839614` and
`ece7cf5a099599f7dcc7`. Each names `coverage-<identity>.json` and its independent
`-check.json` in the corresponding additional-fixed-sigma case's cover folder.

### Proper-face inactive factors and the first two-owner region

When at least one scaled loading stays bounded away from zero, the original
model imposes a stronger restriction on inactive owners than the earlier
categorical-regression relaxation. Write `t=sqrt(v)`, `r_g=a_g*t`, and let
`u` denote the centered Rater coordinates divided by t and beta:X divided by t.
A full-model likelihood above the retained feasible interior lower implies
the same lower threshold for each active-owner marginal likelihood. Exact
superlevel LP duals then give `sign(r*u_j) <= c0+c1*r` for both signs of the
two free Raters and X coefficient. For `r >= epsilon > 0`, these shared
coordinates are bounded by `max(c0/epsilon+c1)`, including as r tends to
infinity. The third Rater is bounded by centering.

An inactive loading tending to zero therefore also loses its Rater and X
effects. Its normal latent contribution vanishes in integrated probability;
the categorical probability's uniform Lipschitz bound in the common adjacent
shift permits owner intercepts and steps to escape. Its limiting factor is
bounded by the unstratified multinomial entropy. This argument requires a
surviving loading bounded away from zero: it does **not** replace the separate
all-zero-loading comparison. All twelve sample/owner coordinate certificates
and entropy bounds pass independent raw checks. Evidence is in
`proper-face-inactive.json` and `proper-face-inactive-check.json` under the
surviving-bound root.

Reusing this stronger inactive bound narrows all twelve singleton middle
intervals without repeating any likelihood integration. The producer and
independent checker are `proper-singleton-tail-enclosures.json` and its
`-check.json`. For N240/rho.5/owner3, the existing .322, .787105 and 4.03
anchors now cover the entire remaining interval; `coverage-d4cf8944bd7ad9a27354.json`
and its independent check in the original fixed-sigma cover folder close the
whole named face. Its unfinished 10.5-loading integration is stopped as
unnecessary, retaining the numerical candidate and all earlier evidence.
The subsequent N240/rho0/owner1 cover also closes independently, using the
.308, .75, 1.51, 4.1 and 10.4 anchors. Its complete cover is
`additional-fixed-sigma/N240-rho0-GPCM-owner1-cover/coverage-74c9a7cd1b0e29a4274a.json`
and the corresponding independent check under `singleton-candidates/`.
N240/rho0/owner2 also closes from independently checked .313, .75, 1.54,
4.18 and 10.6 anchors. Its complete cover and check are
`additional-fixed-sigma/N240-rho0-GPCM-owner2-cover/coverage-f165b61cf5f0ea8bd7f3.json`
and the corresponding `-check.json`. N240/rho0/owner3 subsequently closes
using .308, .75, 3.93 and 10.0, with its independent check in
`additional-fixed-sigma/N240-rho0-GPCM-owner3-cover/coverage-39ff961ad683a9dab0eb.json`
and the corresponding `-check.json`. N240/rho.5/owner1 also closes using
.301, .75 and 3.57, with independent coverage check
`additional-fixed-sigma/N240-rho0.5-GPCM-owner1-cover/coverage-6bb1113fb6d872ee1044-check.json`.
N240/rho.5/owner2 closes from .306, .75, 3.66 and 8.77, with independent check
`additional-fixed-sigma/N240-rho0.5-GPCM-owner2-cover/coverage-e44e5b1be2efb76afbc0-check.json`.
All twelve named singleton cases are now complete. Original data and outward
likelihood checks are unchanged; two-owner face interiors remain open.

`two-owner-small-strips-completion.json` transfers these completed singleton
bounds to the ten previously missing N240 small-loading strips.
`two-owner-small-strips-completion-check.json` checks their raw response and
shared-coordinate bounds independently and reuses the fourteen existing
strip checks. The resulting 24 strips place all twelve two-owner faces
inside finite rectangles with strictly positive lower loading bounds. No
fit or integration is repeated. These containing rectangles do not exclude
their interiors or establish an interior global maximum.

The earlier `two-owner-retained-entropy-screen.json` shows a limitation of
combining one Gaussian singleton bound with the retained free-Person entropy
of another owner and the original inactive regression bound at the inspected
N20/rho0 anchors. It does not show that a boundary beats the interior or rule
out gains from the stronger proper-face inactive bound. The joint calculation
retains both owners' shared normal
variable and shared scaled Rater/X effects. At fixed loadings it has nine
linear nuisance coordinates: two Raters, four centered steps, two owner
intercepts and one X coefficient. Both singleton reductions, raw logits and
all nine numerical score directions pass, followed by interval integration,
eighteen exact superlevel directions and an independent four-response check.

For N20/rho0 owners 1 and 2 at loadings (.75, 1.25), the global nuisance
log-likelihood upper is -97.54708387197118. Combining it with inactive-owner-3
entropy and the feasible interior lower gives guaranteed separation 11.0470.
A checked normal-density and owner-specific temperature transfer extends this
to the rectangle `[.69,.81] x [1.15,1.35]`, with guaranteed separation 1.6507.
Shared Rater/X coordinates rescale together, while owner steps/intercepts
rescale separately; this bounds all nuisance values throughout the rectangle.
Evidence is in `two-owner-fixed-loadings/N20-rho0-GPCM-owners1-2-anchor01/`,
including `enclosed-check.json` and `neighborhood-check.json`.
This is the first covered two-owner region, not a complete two-owner face,
an interior global-maximum proof or public covariance qualification.
An ensuing joint numerical proposal varies both loadings and the nine
nuisance coordinates, after fixed-model reduction and loading-score checks.
It returns loadings about (.71806,1.04182), with log likelihood -97.47323;
this numerical search does not certify a maximum. The existing (.75,1.25)
anchor can nevertheless cover this point without another likelihood
integration. Split its normal-density transfer into the three branches
`L=1`, `L=a1/r1`, and `L=a2/r2`. In either nonconstant branch, the active
owner's temperature factor is identically one. Monotonicity of the remaining
factors puts each branch maximum at its corresponding rectangle corner.
This avoids combining worst factors from incompatible target loadings.
The enlarged rectangle `[.68,.82] x [1.03,1.40]` has guaranteed separation
.38387, contains the previous rectangle and the joint numerical proposal,
and passes 12,800 independent raw rescaling identities plus temperature-root
and likelihood comparisons. Evidence is in the same anchor folder's
`corner-neighborhood.json` and `corner-neighborhood-check.json`;
the proposal is retained in `two-owner-fixed-loadings/N20-rho0-GPCM-owners1-2-joint-proposal/`.
Further calculation points are selected only where the saved corner/strip,
joint-neighborhood and fixed-anchor transfer bounds remain insufficient.
For the same N20/rho0 owners 1/2 face, the second anchor is approximately
(.0293951610,3.9208819746). Its independently checked nuisance upper is
-104.64453681125036; a density/temperature transfer excludes
[.02491699195,.03387333007] x [3.32356011124,4.51820383787] with guaranteed
separation .10466845. The third anchor is approximately
(1.6019121254,3.9208819746), with checked upper -103.78575674474277 and
excluded rectangle [1.36940803395,1.83441621683] x
[3.35179888523,4.48996506388], separation .11369280.
The exact rational endpoints, raw geometry checks and all-nine-coordinate
rescaling checks are in `two-owner-fixed-loadings/` under the corresponding
`N20-rho0-GPCM-owners1-2-anchor02/` and `anchor03/` directories, in
`enclosed-check.json` and `neighborhood-check.json`. The third anchor's
initial output-path guard refusal is retained in `preflight-output-guard/`;
it occurred before fitting and did not modify the second anchor. A successor
script corrects only that output path. These two new nuisance calculations
retain the existing integration and independent checking formulas; original
calibrations and datasets are unchanged.

An exact partial two-dimensional partition retains all four leaves after
three splits; its independent check records zero new exclusions. At one
leaf center, (1.6019121254,34.2854923719), none of the three retained
fixed-anchor point bounds is sufficient. The fourth anchor therefore targets
this missing calculation. Its checked global nuisance upper is
-127.47529602122499; the independently checked rectangle
[1.06396531668,2.13985893410] x [22.77189501896,45.79908972477]
has guaranteed separation .10866503 and 8,640 raw rescaling checks.
Evidence is in `N20-rho0-GPCM-owners1-2-cover01/check.json` and
`N20-rho0-GPCM-owners1-2-anchor04/{enclosed-check,neighborhood-check}.json`
under `two-owner-fixed-loadings/`. The partial partition check does not
qualify its unused whole-box transfer code: actual new exclusions need their
own replay.

The fifth anchor, selected from the next preserved pending rectangle, is
approximately (11.8255163087,101.3849990313). Its checked nuisance upper is
-152.96151763237287; independent raw rescaling checks cover
[5.91420169880,17.73683091852] x [50.70487561417,152.06512244846]
with separation 3.43788994. Combining the five retained anchors now excludes
30 boxes in the exact finite-domain partition: `N20-rho0-GPCM-owners1-2-cover03/check.json` verifies
all 30 complete rectangle bounds, 384,000 raw rescaling identities, and the
39-split partition with ten remaining leaves. Its independent checker
reconstructs the temperature bounds, all nuisance-coordinate transfers and
likelihood margins. No original calibration or saved integral is repeated.
The next center (77.0442434878,36.6892933906) initially remains beyond
those bounds. Its sixth fixed-loading certificate gives upper
-163.15973696603095, and independently covers
[38.53152655880,115.55696041687] x [18.34912536880,55.02946141237]
with separation 13.63610927. `N20-rho0-GPCM-owners1-2-cover04/check.json`
then verifies fourteen further exclusions while reusing the thirty earlier
proofs unchanged: twelve new transfer boxes require 153,600 raw rescaling
identities, and two boxes lie inside retained checked exclusions. The
50-split partition has 44 excluded and seven pending leaves. Its next
unresolved center, (2.6404870652,174.3433379502), gives the seventh checked
nuisance upper -151.10247851023394. Its checked rectangle is
[1.32056585768,3.96040827270] x [87.19295112082,261.49372477949], with
separation 1.57885082. The fifth partial cover independently verifies 36
additional exclusions (35 transfer boxes, 448,000 raw rescaling identities),
retaining all 44 preceding proofs; 80 boxes are excluded and 15 remain.

The next apparent obstruction, (86.6184085917,5.5254526785), is already
handled by the existing analytic discordance tail when evaluated inside its
saved cutoff. No eighth nuisance fit is made there. Reusing the same formula
with separation reserve .1 gives independently checked loading thresholds
82.5225176824 and 278.1409449830, uniform in the other loading. Raw
orientation counts and the closed-form bounds are independently reconstructed
in `N20-rho0-GPCM-owners1-2-extended-large-strips/check.json`. The sixth cover
adds ten verified exclusions, retaining 90 with eleven pending leaves.
The seventh cover evaluates that same analytic bound directly at each box's
lower loading, requiring a strictly positive exact separation rather than
using a stored cutoff. It adds one independently checked analytic exclusion,
for 91 excluded and eleven pending leaves in a 101-split partition. All
preceding box proofs are reused unchanged. The actual next point is
(79.4887247946,5.3188050886), where both analytic tails and all seven joint
anchor bounds are insufficient. These are computational bound refinements;
they do not change the model, likelihood comparison or statistical level.
The eighth anchor at (79.4887247946,5.3188050886) subsequently gives checked
upper -160.29371500252344. Its independently checked rectangle
[39.75406561078,119.22338397844] x [2.66005181251,7.97755836472]
has separation 10.77008731. The eighth partial cover reuses all 91 earlier
proofs and independently checks 25 new exclusions, including eighteen new
transfer boxes (230,400 raw rescaling identities). The 120-split partition
retains 116 excluded and five pending leaves. A ninth actual pending center,
(4.3524059971,6.7424141410), has checked nuisance upper -115.4383942405296
and rectangle [3.30521456398,5.39959743028] x
[5.12018534803,8.36464293394], separation .10852278. The ninth partial
cover then independently checks 42 additional exclusions (34 new transfer
boxes, 435,200 raw rescaling identities), retaining all 116 preceding proofs.
The 167-split partition has 158 excluded and ten pending leaves; the next
actual center is (2.5592853440,8.9926665850). The tenth anchor at that
center gives checked nuisance upper -113.42498291985174 and rectangle
[1.98507068793,3.13349999999] x [6.97502483896,11.01030833094],
with guaranteed separation .10346504. The tenth partial cover independently
checks 21 new exclusions, including sixteen transfer boxes and 204,800 raw
rescaling identities, while reusing all 158 preceding proofs. Its 182-split
partition retains 179 excluded and four pending leaves. The next actual
center is (.2169987669,34.2854923719). The eleventh fixed-loading anchor at
that point passes the raw nuisance-bound and neighborhood checks, with
global upper -126.14715323203151 and rectangle
[.14635231779,.28764521610] x [23.12345524348,45.44752950026],
separation .10038331. Its partial cover reuses all 179 earlier proofs and
independently checks sixteen new exclusions, including thirteen transfer
boxes (166,400 raw rescaling identities). The 205-split partition retains
195 excluded and eleven pending leaves. The next actual center is
(.6275938033,270.8280087422); the face remains open.
The same source-bound stages now continue serially at actual pending centers:
verify that all retained point bounds fail, choose the closest checked seed
on the log-loading scale, enclose and independently check the new nuisance
upper, then extend and independently check the partition. Any failed stage
stops this continuation with its records retained; it changes no mathematical
source, acceptance rule, original calibration or completed integral.
The twelfth anchor at (.6275938033,270.8280087422) has checked global
upper -152.48232328865842; its neighborhood has separation 2.95869560.
The next cover independently checks eighteen additional exclusions (fifteen
transfer boxes, 192,000 raw rescaling identities), preserving all 195 earlier
proofs. The thirteenth anchor targets the actual remaining center
(.0798668498,174.3433379502), with global upper -147.5096762745719 and
neighborhood separation .11165317. Its cover independently checks 46 new
exclusions (42 transfer boxes, 537,600 raw identities), reusing all 213
preceding proofs. The 263-split partition retains 259 excluded and five
pending leaves.

The next-point verifier stops before preparing another anchor because two
algebraically equal upper-bound expressions, both evaluated at 100 digits,
differ upward by 1.42873424e-101 for anchor 5 at temperature 1.33387108.
`point-verification-rounding-review/` retains the failure and independently
verifies all fourteen nontrivial unchanged producer constants at 120 digits.
The successor keeps the producer at 100 digits and uses 120 digits for the
alternative-expression check, with no added tolerance. Exact reverse editing
recovers the original point-selection source. Existing covers already use an
80-digit producer and 120-digit independent checker and remain unchanged.
Continuation resumes only the five pending leaves from cover 13; the actual
next center is (.5895871063,6.7424141410). No original fit, prior integral or
completed exclusion is repeated.
The fourteenth anchor at that center has checked upper -106.13541524098184
and rectangle [.49249811630,.68667609639] x [5.63212157797,7.85270670399],
with separation .10588365. The next independently checked cover preserves
all 259 earlier exclusions and adds 21 (twenty transfer boxes, 256,000 raw
identities). Its 285-split partition contains 280 excluded and six pending
leaves; the next actual center is (.9718367839,5.1416155117).
The unchanged serial protocol subsequently reaches twenty-three anchors.
Its latest independently checked partition has 759 excluded and three
pending leaves after 761 splits. The last increment retains all 705 prior
exclusions and checks 54 new transfer boxes against 691,200 raw rescaling
identities. The next actual uncovered point is (1.6019121254,.4483912697).
Two further checked anchors extend the partition to 790 excluded and five
pending leaves. Their independent checks add nineteen then twelve exclusions
while retaining all previous proofs, with 230,400 then 128,000 raw rescaling
identities. The next actual uncovered point is (4.3524059971,1.3259295785).
Continuation through the fifty-seventh checked anchor preserves 3,087 excluded
and eight pending leaves. The last two anchors add no exclusions; their
checks retain the partition and verify failure of all retained bounds at
the next actual point. Source hashes for every intervening cover and
next-point check agree. The next uncovered point is
(1.2477167660,1.0111244942); the same checked protocol continues there.
The full N20/rho0 owner-1/2 face and the other two-owner faces remain open.
The separate model with two slope families is unaffected by this one-family
latent-regression boundary calculation.

The later continuation preserves 8,544 independently checked exclusions and
six pending leaves through anchor 138. At a very small loading, numerical LP
support selection fails an exact coordinate-direction check; at anchor 139,
the LP itself refuses that direction. Both numerical centers were already
saved and are reused. Previously qualified supports, reconstructed with
rational arithmetic at the new loadings, supply nonnegative exact directions
without weakening the equality gate. The unchanged raw-geometry, supporting-
plane and neighborhood checkers verify anchor 138; continuation from the
saved anchor-139 center retains the original failures. Only support proposal
and recovery change. No original fit or completed integral is repeated, and
neither the whole face nor the two-family problem is thereby resolved.

The two-owner domain is now reduced before further joint integration.
For all twelve sample/owner pairs, the existing categorical duals and a
normal moment bound exclude a both-small-loading corner. The sum of the two
conditional entropy bounds, split with the checked powered-discordance
inequality, excludes sufficiently large values of either loading. These
twenty-four large strips are uniform in the other loading. Combining saved
singleton anchors with the other owner's conditional entropy and the stronger
inactive bound also excludes eleven intermediate strips. Fresh raw-data
checks rebuild score extrema and discordant pairs, evaluate the tail formula
at 120 interval digits, and check every retained temperature root. Evidence:
`two-owner-domain.json` and `two-owner-domain-check.json`.

Completed singleton covers further control a loading tending to zero while
the other remains positive. The exact shared Rater/X bounds control the
deterministic shift; Holder's inequality and
`E exp(t |Z|) <= 2 exp(t^2/2)` control the latent shift. The resulting upper
uses the completed singleton marginal upper and the two inactive categorical
entropies. Below the required active-loading cutoff, the both-small corner
already applies. Fourteen such strips pass an independent reconstruction of
the likelihood comparison and 46,080 raw score/coordinate-vertex checks.
For all six N20 two-owner faces, the remaining domain is therefore inside
a finite rectangle with strictly positive lower loading bounds. Two strips
are also available for N240/rho.5 from its completed owner-3 singleton cover;
the other N240 singleton work remains necessary. Evidence is in
`two-owner-small-strips.json` and `two-owner-small-strips-check.json`.
These reductions reuse existing fits and integrals. The remaining rectangle
interiors are not certified, so no whole two-owner face or public inference
gate is marked complete.

The four evidence sets from the earlier PCM output/initial GPCM follow-through
and contemporaneous JML and comparison-output work replay in a fresh R process with fitting, scoring,
profiling, optimization, numerical integration, Python invocation and Hessian
calculation traced to stop. Every numerical phase hash stays unchanged.
The PCM public-output evidence is in
`validation-results/mfrm-wide-map-lr-pcm-public-output-20261002/`; the GPCM
bound is in `validation-results/mfrm-wide-map-lr-gpcm-zero-bound-20261002/`.
No production source, public inference gate or simulation allocation changes.
