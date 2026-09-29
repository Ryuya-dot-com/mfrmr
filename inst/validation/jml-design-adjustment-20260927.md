# Design-aware JML adjustments: method-development contract

This is excluded research code, not a public estimator or interval API. The
question is whether repeated score recentering reduces the known residual
population-root displacement without collapsing information, and whether the
same calculation can respect actual unequal/sparse assignments and its own
covariance. No repeated-sampling coverage claim is planned in this increment.
The previous 200-dataset study and its frozen sources remain unchanged.

## Method and sampling target

For each actual roster d, enumerate only its assigned categorical responses.
Use the existing two-rater/two-criterion, three-category, whole-predictor GPCM
with shared Criterion slope/step ownership and the same five centered
coordinates. Let U_0 be the negative profile score and P_beta the expectation
operator that generates responses at that pattern's profiled Person ability,
then refits Person ability for every generated response. Compute
U_k = (I - P_beta)^k U_0. Extreme patterns have exact zero limiting scores at
every order. This is the iterative candidate from the previously reviewed
Dhaene/Jochmans paper, not a theorem for this GPCM.

Person samples are independent within prespecified fixed roster counts. For
roster fractions pi_d, A differentiates sum_d pi_d mean(U_d), including all
profile/correction dependence. Fixed-roster meat is sum_d pi_d Var_d(U_d).
Random-roster meat additionally includes between-roster mean-score variation.
These targets must be explicit; pooling scores with a global mean is not the
fixed-allocation formula. The sandwich is A^-1 B A^-T / N, not the raw likelihood
Hessian. No ridge, pseudoinverse or symmetrization of A repairs deficient rank.

## Declared checks before execution

- First reproduce the frozen exact calculation for both owners and 4/8 ratings,
  at truth and an opposing parameter point (scores within 1e-11, masses 1e-12).
- Two actual designs: complete exposure (2,2,2,2), and equal fixed fractions of
  (2,1,0,2) and (0,2,2,1). Cells follow Rater-fast expand.grid order. Zero means
  unassigned, not a missing score to impute. Both sparse rosters contain five
  assigned ratings and their pooled cells cover all four rater/criterion pairs.
- For each design, population weights use the previous three-point ability
  mixture (-1,0,1), (.25,.5,.25), solely as a reference. A 400-Person sample uses
  seeds 271901/271902. Fitting receives only observed pattern frequencies.
- Orders 0,1,2,4 are fixed in advance for both population and sample. Two starts
  (neutral and opposing) use the earlier root/Jacobian review and its Newton
  fallback. Retain every attempt; agreement tolerance 1e-6. No truth starts.
- Report displacement, covariance, Jacobian singular values and singular value
  relative to score RMS. Reduced mean score alone cannot qualify a method.
- Verify fixed/random meat difference against between-roster score covariance,
  and sample covariance against expanded Person influence contributions.
  Reject an isolated-cell design rather than manufacture covariance.

## Computation and approximation

Generate expectation columns in blocks, not a dense pattern-by-pattern kernel.
Count-pattern aggregation respects multinomial multiplicity and unequal exposure.
Fail explicitly above 50,000 enumerated count patterns; this is an engineering
resource guard, not general large-design support.

Optional unnormalised probability pruning drops at most epsilon mass per
expectation column. If e_k bounds the current score error coordinatewise, then
 e_(k+1) <= 2 e_k + epsilon_k max_abs(U_k_approx).
This is a deterministic truncation bound, not a Monte Carlo standard error.
For a centered finite-difference Jacobian, (e_plus + e_minus)/(2h) bounds the
additional truncation error relative to the exact finite difference at that h.
It does not bound finite-difference discretization error, which is checked with
h=1e-4 and 5e-5 separately. Approximation must be checked on scores, derivatives
and resulting covariance, not accepted on omitted mass alone. No stochastic
approximation or general scalable covariance qualification is implied.

Population roots and these samples are method-development cases, not independent
validation of a chosen correction order. Successful checks will determine the
next method decision; they will not automatically add a public API or another
simulation grid.

Approximation review is fixed before its execution: use the sample roots at
orders 1 and 4 in both designs, epsilon in {1e-3,1e-6,1e-10,1e-14}, and blocks
of 1 versus 16 for exact equality. At each fixed exact root compare score and
Jacobian errors to their derived bounds (with 1e-10 floating-point allowance),
and covariance to the same-root exact covariance. Numerical eligibility requires
max row sum(abs(A^-1) D_A) < .01, propagated score-bound/SE < .01, and relative
covariance discrepancy < .01. These are engineering tolerances, not statistical
coverage criteria. Also compare both finite-difference steps. Approximate
covariance evaluated at an exact root is not evidence that an approximate solver
has converged. No automatic approximation replaces the exact sample fits.

## Targeted unequal-length check

The initial sparse comparison keeps five ratings per Person. Before claiming
that the factory handles unequal Person exposure, add one engineering check:
240 Persons on (2,1,0,1), 160 on (0,2,2,2), hence four versus six assigned ratings,
seed 271903. Use the same declared ability mixture solely for generation, then
fit orders 1 and 4 from the two existing starts using only sample frequencies.
Check actual per-Person response counts, profile-gradient finite differences,
expanded fixed-roster influence covariance and within-roster perturbation/refits.
This is not an added bias/coverage study, and the sample cannot select an order.

The unequal-length two-start gate failed initially for both orders: neutral
starts converge, but opposing starts and their Newton fallbacks move toward
very small slopes and hit 150 iterations. The retained follow-up retries the
same original opposing start with Newton/double-dogleg stepmax=.25 instead of
1; all original tolerances and iteration limits remain. It compares with the
neutral root and performs the originally planned covariance/perturbation checks.
This is a targeted solver experiment, not a retrospectively successful original
protocol or proof of global uniqueness. Failed attempts remain in unequal.rds.
