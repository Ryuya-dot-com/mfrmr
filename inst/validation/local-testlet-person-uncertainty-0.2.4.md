# Person scoring: calibration sensitivity and uncertainty targets

2026-09-17. The following plan precedes the new computations. It uses the
three saved fitted points and covariance matrices in
`local-testlet-information-0.2.4-evidence.rds`. No population parameters will
be re-estimated and no new recovery experiment is included.

## Question and inferential target

When a small set of responses calibrates rater severity, criterion difficulty,
thresholds and local dependence, treating those estimates as exactly known
can miss uncertainty in a person's ability estimate. Comparing two people
also requires the covariance caused by using the same calibration. The
question here is what calculations are needed to represent these effects,
and whether they can be implemented consistently with the qualified model.

Let psi=(alpha,beta1,beta2,rater1,tau1,v), with the same fixed N(0,1) ability
prior and person-by-rater local effects as before. For the observed response
vector y_p define m_p(psi)=E(theta_p|y_p,psi) and
V_p(psi)=Var(theta_p|y_p,psi). The current ThetaSD is sqrt(V_p(psi_hat)). It
integrates uncertainty in theta and the person's local effects while holding
psi at its estimate. It is not the sampling SD of an EAP across datasets.

[Skrondal & Rabe-Hesketh (2009)](https://doi.org/10.1111/j.1467-985X.2009.00587.x),
sections 4.1--4.2 and 5.1, distinguish empirical posterior uncertainty from
prediction-error uncertainty and discuss corrections for estimated model
parameters. For repeated-sampling prediction errors, they describe simulating
latent effects and responses and refitting model parameters. Their discussion
does not validate a plug-in correction for this ordinal local-testlet model.
This follow-up reread printed pp.664--670 in text, with PDF pp.10--12
(printed pp.668--670) visually checked. Local Zotero item E2JA7NDA, attachment
2NFRLZEY; the earlier 29-page audit is in `measurement-model-extension-pdf-audit-0.2.4.csv`.
These pages are a focused reread, not an additional fully read paper in the
eight-paper September 17 collection. [Author-hosted PDF](http://www.gllamm.org/JRSSApredict_09.pdf).

## A diagnostic before a corrected standard error

At an interior point, calculate the person-by-parameter Jacobian J of m and
reuse the full saved curvature covariance C=H^-1. The matrix K=J C J' measures
local propagation of calibration variation into the posterior means. Its
diagonal is a **calibration sensitivity variance**, not a validated correction
to a person's MSE or posterior variance. Retain all off-diagonal entries of C
and K. For a pair p,q, the corresponding quantity is
K_pp+K_qq-2K_pq=(J_p-J_q) C (J_p-J_q)'. Compare it with the calculation that
incorrectly drops K_pq; do not assume the covariance is always positive.

For any explicitly specified mixing distribution Q over psi, total variance
gives Var_Q(theta_p|y)=E_Q[V_p(psi)]+Var_Q[m_p(psi)]. Using just
V_p(psi_hat)+K_pp freezes the first term and linearizes the second. It is not
this exact mixture variance. In a fully Bayesian analysis Q would need to be
the parameter posterior from specified priors and the full data. Here C is
an observed-curvature candidate from only six people, not an established
posterior covariance. Normal perturbations can also assign mass to v<0.
Same-sample frequentist prediction MSE requires its own sampling argument and
refitting scheme; this sensitivity calculation supplies neither.

At v=0, calculate only sensitivity within the v=0 fixed submodel using the
saved five-dimensional covariance. Full-model calibration variance is NA,
not zero. Do not produce confidence/credible intervals, corrected SEs, or
new eligibility flags from any of these computations.

## Prespecified numerical checks

- Compute mean Jacobians by central differences with h=.001 and .0005 at
  GH121 and GH181 for the three saved points. Require maximum absolute
  differences <=1e-6. No negative variance evaluations at the boundary.
- For every person, verify d m/d alpha = V-1 within 1e-7. This identity follows
  directly from integration by parts with the fixed N(0,1) ability prior:
  the likelihood depends on alpha and theta through their sum. It is an
  independent analytic check of the mean derivative, not a result imported
  from the cited paper.
- Require K to be symmetric and positive semidefinite within 1e-10, without
  repairing eigenvalues. Check all 15 pair contrast identities within 1e-10.
  Recompute J with log(v) coordinates at positive variance; transforming C
  by diag(1,1,1,1,1,1/v) must preserve K within 1e-6.
- Add one wholly missing person to the original fixture. At GH121/h=.0005,
  require mean=0, variance=1, J=0 and K_pp=0 within 1e-9. The other six means
  and derivatives must be unchanged within 1e-9. This is possible because
  the ability distribution is fixed, not estimated.
- For each saved C=L L', use a declared artificial distribution with equal
  weights on the 2d points psi_hat +/- rho*sqrt(d)*L[,j], for rho=.01,.005.
  In the boundary example perturb only the five structural coordinates.
  Its covariance is exactly rho^2 C. Require every point to be in the
  parameter domain; do not clip or redraw. This is a deterministic probe,
  not posterior draws, a bootstrap, or a calibration-sample simulation.
- Evaluate all support points at GH181. Verify the exact within/between
  total-variance decomposition within 1e-10. Require the between-mean
  covariance divided by rho^2 to agree with K within 1e-4. Report changes in
  the average conditional variance as well; no requirement that they vanish
  or are positive. Check their rho-scaled change between the two radii within
  1e-4. Record all failures before considering a narrower follow-up.
- For positive cases, report P(v<0) under the *hypothetical* untruncated
  N(v_hat,C_vv), as a warning about that approximation's support. Do not draw
  from or use it for inference. Show K/20 for a hypothetical twentyfold
  calibration-information increase; this is algebra, not new N=120 evidence.

Existing source code, optimizer solutions, TAM checks, FairZ, full-package
tests, and earlier numerical qualifications are reused. Checks, raw values,
source/input hashes and errors/warnings will be retained with the results.

## Results and what they answer

**All 53 checks passed**, with no captured errors or warnings. The maximum
Jacobian difference over steps/orders was 1.11e-8; the independent alpha
derivative identity differed by 5.39e-10. Changing variance coordinates to
log(v) changed K by at most 3.97e-9. The missing person's posterior remained
the fixed N(0,1) prior and its calibration sensitivity was zero within
9.08e-16. No original model, solver, or quadrature source was changed.

The resulting K is material relative to V in these small examples, but the
ratios below are **not SE increases** and do not demonstrate undercoverage.

| Saved case | Variance | Range of K_pp / V_p | Scope |
|---|---:|---:|---|
| Original, 33 observations | .988329 | 11.5%--34.9% | All six parameter coordinates |
| Clustered, 36 observations | 2.559202 | 8.7%--17.4% | All six parameter coordinates |
| Balanced boundary | 0 | 58.8% | Only five coordinates, with v fixed at zero |

For the same original six-person fixture, shared calibration can almost
cancel in one comparison and amplify another. All entries below are local
calibration sensitivity variances/covariances, in squared ability units.

| Pair | Sum of individual calibration variances | Calibration covariance K_pq | Calibration variance of the difference |
|---|---:|---:|---:|
| P1 minus P2 | .207054 | .103432 | .000190 |
| P4 minus P5 | .389283 | -.069839 | .528962 |

The first pair has nearly the same mean response level; the second consists
of all-low and all-high response rows. Ignoring calibration covariance would
overstate the first sensitivity and understate the second. This is a concrete
reason to distinguish precision of an absolute ability estimate from
precision of an ability contrast when evaluating rating designs. It does not
establish the sampling performance of either comparison.

In the balanced boundary fixture all six posterior means have the same
sensitivity within the fixed-v=0 submodel. Its calibration contribution to a
pair difference is numerically zero, while the conditional difference variance
remains .441825. This does not make the ability difference known exactly;
full-model variance-boundary uncertainty is still unavailable.

The finite artificial mixtures satisfy total variance to 1.38e-15. The
between-mean covariance divided by rho^2 agrees with K within 1.94e-5 at
rho=.01 and 4.84e-6 at rho=.005. The change in the average conditional variance
is also of order rho^2 and does not disappear relative to that between term.
For example, at rho=.005 in the original fixture:

| Person | Mean-propagation coefficient K_pp | (E_Q[V_p]-V_p)/rho^2 | (Total mixture variance-V_p)/rho^2 |
|---|---:|---:|---:|
| P1 | .107782 | -.122747 | -.014964 |
| P4 | .201669 | -.106428 | .095246 |

These signs are properties of the explicitly chosen local probe Q. They are
not evidence that a fitted Bayesian model or a frequentist correction would
reduce or increase a particular person's uncertainty by these amounts. They
show why calling sqrt(V_p+K_pp) a fully corrected SE would be premature.

An untruncated normal approximation using the original saved estimate and C
would assign **27.6%** probability to negative v; the clustered example would
assign **13.5%**. This is only a support diagnostic, not a fitted posterior
probability. Transforming to log(v) preserves the infinitesimal sensitivity
calculation, but does not thereby validate a lognormal posterior or bootstrap.

## Consequence for the next study

The initial research target remains the realized ability of an observed
person, and contrasts between two observed people on the declared ability
scale. They must be scored using the same fitted calibration. A study of new
raters is a separate model and target.

Before interpreting any calibration-aware interval, the conditional posterior
itself needs a checked quantile calculation: six ordinal observations do not
establish the normal approximation implicit in mean +/- 1.96 SD. For a
repeated-sampling study, draw theta and person-by-rater gamma independently
from the stated populations, generate the responses, refit psi, and score
using that fit. Compare the known-psi oracle with the fitted-psi scoring path
on the same data; retain boundary/failed fits and report their denominators.
Assess individual abilities and paired differences separately, and distinguish
coverage averaged over theta and responses from coverage within ability bands.
The former cannot certify coverage for every fixed ability.

A Bayesian calibration-aware path additionally needs explicit parameter
priors and integration over the resulting posterior. A frequentist MSEP or
bootstrap path needs an explicit conditional or marginal target and a refit
scheme, including the handling of zero variance. This experiment selects
neither by silently treating C as a posterior. It supplies the sensitivity
calculations and covariance checks that such a later method will need.

## Records and reproduction

- [Code](local-testlet-person-uncertainty-0.2.4.R),
  [checks](local-testlet-person-uncertainty-0.2.4-checks.csv),
  [18 person rows](local-testlet-person-uncertainty-0.2.4-persons.csv),
  [45 pair rows](local-testlet-person-uncertainty-0.2.4-pairs.csv),
  [summary](local-testlet-person-uncertainty-0.2.4-summary.csv), and
  [portable evidence](local-testlet-person-uncertainty-0.2.4-evidence.rds).
- The portable evidence includes the prespecified plan, saved fits and
  covariances, Jacobians at both steps/orders, complete K matrices, exact probe
  supports and results, source/input hashes, and captured conditions.
- Raw checkpoints are in
  `validation-results/local-testlet-person-uncertainty-20260917/`.
- Parent commit `5e9ac68`. R 4.6.1. Runner MD5
  `c6c93ef3eea1decac980cca60e500ebf`; the estimation/stress/reference MD5s remain
  `e599de0ca8fed081da0b3f519505d690`, `812999e7da7ecbbdbb654974529058aa`, and
  `6bacb70c9d4c0fba27bef70a508f0f88`, respectively. Input identity was unchanged.
- Local reference PDF SHA256
  `da8343d8d2032b3a8dc1da1da8549eb629559346ac466f6ee43196c7e04f1ca4`, matching
  the earlier PDF audit. No new paper was imported into Zotero.
- Run from `development/` with
  `Rscript inst/validation/local-testlet-person-uncertainty-0.2.4.R`.
  Inputs are already tracked; Zotero and a new TAM run are not required for
  this computation. No public API or interval eligibility changed.
