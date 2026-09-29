# Exact owner-total expectations: computational qualification

Question: can the same research correction and covariance be computed beyond
the response-enumeration guard, without an additional approximation or a change
of estimand? This does not select a correction order or qualify truth coverage.

## Model-specific derivation

The current scope has two fixed raters, two criteria, three categories,
whole-predictor positive slopes, and one shared slope/step owner. Within an
owner g all assigned responses share slope a_g. Their joint probability is
proportional to exp(a_g theta T_g) times a factor in cell category counts.
Conditional on owner total T_g, the theta factor cancels. Conditional count
moments therefore depend on structural beta and actual assigned exposure,
but not on the generating Person ability. This identity would need revisiting
for a different slope structure or dependent responses.

The profiled ability is determined by the two owner totals at each beta. At
fixed totals, the raw negative profile gradient is affine in the observed cell
category counts. Polynomial convolution gives exact total probabilities and
mass-weighted cell counts. Conditional moments then give Gbar_0(T), the mean
raw profile score at that total. Let K_beta be the transition on owner totals
generated at each total's fitted ability. Define H_0=0 and
H_(k+1) = H_k + K_beta (Gbar_0-H_k).
The score for an actual response y is U_k(y)=U_0(y)-H_k(T(y)). This matches
(I-P_beta)^k U_0 on the full response space. Only the expectation is compressed;
the actual sample score retains each Person's original cell responses. Thus
within-total response variation remains in the sandwich meat.

Retain exact zero extreme-pattern limits, actual zero exposures and the existing
centering constraints. Generate transition columns in blocks. An explicit
5,000-total-state guard remains; no unrestricted scalability claim is intended.
Underflow in a total probability is an error, not a silently discarded state.

## Checks fixed before execution

1. Against the frozen response enumeration, compare both owners, exposures
   (1,1,1,1), (2,2,2,2), (2,1,0,2), (2,1,0,1), at the previous true-coordinate
   benchmark and opposing coordinates. These are evaluation points only.
   Compare every response's scores at orders 0,1,2,4 (max error <1e-8), profile
   criteria (<1e-8), and generating-ability invariance of conditional raw scores
   by independent grouping at theta=-1,0,1 (<1e-8).
2. Reuse the complete/sparse/unequal reviewed sample roots. Compare the mean
   equation, finite-difference Jacobian at h=1e-4 and 5e-5, and matching
   fixed-roster covariance. Relative Jacobian/covariance tolerances 1e-5. Do not
   substitute conditional mean scores for actual Person contributions.
3. One computational extension: 400 Persons, exposure (8,8,8,8), Criterion
   ownership, same previous ability mixture solely for generating data, seed
   272001. Generate cell counts directly, not by enumerating responses. Fit
   explicit orders 1 and 4 from the same neutral/opposing starts. Reuse the
   smaller-step Newton policy if needed, retaining every attempt; no successful
   root or generating truth is a starting value. Require original residual,
   rank, Jacobian-step and two-start agreement thresholds. Verify observed-row
   profile gradient and influence linearization by perturbing empirical weights
   at h=1e-5,5e-6. This one sample tests computability, not bias/coverage.
4. Report state counts and local elapsed times. Compare the old exact and new
   exact expectation on the same small problem (three timings, median). Do not
   extrapolate a general time/memory limit or claim success from speed alone.

Previous scripts and evidence remain unchanged. This is repository-only method
work: no public JML estimator, API default, help/NEWS feature or interval claim
is added. If equivalence fails, preserve the discrepancy and repair it before
running the larger sample.

## Operator decomposition and prior art

Literature review, 2026-09-27: Dhaene & Weidner (2023), pp.390 and 404–407,
equations (17) and (23), already give iterated score correction, including the
MLE plug-in operator used here. Their Example 1B, p.383, already aggregates
outcomes into group totals; p.385, footnote 1, discusses aggregated moments and
their residuals for that example. Cai (2015), p.541, equation (13), gives the
polytomous score convolution. Huang & Cai (2021), pp.977–978, equations (9)–(11),
use score combinations for hierarchical IRT scoring. These are prior art, not
new principles introduced by this implementation. See the
[publication review](jml-publication-positioning-20260927.md) for source scope.

The following derivation establishes this implementation's equality to the
existing plug-in correction. It is not a claim of priority for the algebra.
Fix structural beta and an assigned roster d throughout. Suppress d in notation.
Let C_beta average a response function conditional on its owner totals T,
and let L lift a total-state function to the response space:

```text
(C_beta v)(t) = E_beta[v(Y) | T(Y)=t],
(L h)(y) = h(T(y)).
```

The conditional response distribution is independent of Person ability because
its exponential tilt cancels at fixed totals. The owner partition and statistic
T must themselves remain fixed as beta varies. Here the ability profile is
a function theta_hat_beta(t) of these totals. Define

```text
(K_beta h)(t) = E_beta,theta_hat_beta(t)[h(T(Y'))],
(P_beta v)(y) = E_beta,theta_hat_beta(T(y))[v(Y')].
```

By conditioning on T(Y'), `P_beta = L K_beta C_beta`, `C_beta L = I`, and
`P_beta L = L K_beta`. With `Gbar_0 = C_beta U_0` and
`R_beta = U_0 - L Gbar_0`, we have `C_beta R_beta = 0`, hence
`P_beta R_beta = 0`. For every finite integer k >= 0, induction therefore gives

```text
(I-P_beta)^k U_0 = R_beta + L (I-K_beta)^k Gbar_0.
```

Equivalently, `H_k = Gbar_0 - (I-K_beta)^k Gbar_0` satisfies
`H_0=0` and `H_(k+1)=H_k+K_beta(Gbar_0-H_k)`, as implemented.
The argument does not require a spectral convergence claim or k tending to
infinity. At all-minimum/all-maximum responses, use the established exact
profile limits. Mathematically these total states are absorbing. The code
omits their transition evaluation because every function to which the
transition is applied in this recurrence is zero there; its zero rows should
not be described as a general-purpose stochastic kernel on arbitrary functions.

Implementation correspondence:

| Mathematical object | Existing research code |
| --- | --- |
| Conditional cell-count moments in C_beta U_0 | `conditional()` carries probability and mass-weighted counts; `raw(expected_counts, ...)` forms `raw_group`. |
| K_beta acting on a total-state function | `apply_transition()` evaluates normalized total probabilities at the profiled ability, in blocks. |
| H_k | The `adjustment` recurrence. |
| U_k(y) | `actual$value - adjustment[group, ]`, retaining original counts in `actual`. |
| Full derivative with respect to beta | Existing Jacobian checks reevaluate profiling, conditional moments and transition probabilities; none is frozen at the fitted beta. |

Under the correctly specified model and the same roster, the law of total
variance gives, at fixed beta,

```text
Var_beta(U_k) = E_beta[Var_beta(U_0 | T)]
               + Var_beta((I-K_beta)^k Gbar_0(T)).
```

Replacing actual observations by conditional mean scores would omit the first
term and generally change the sample estimating equation as well. This identity
explains the implementation choice; it does not assert that model-conditional
moments equal empirical moments under misspecification. The existing empirical
sandwich uses actual Person contributions and centers within each fixed roster
stratum. Equality of differentiable score functions in a neighborhood preserves
their full Jacobians and that empirical sandwich, subject to the same root,
rank and regularity conditions. Equality only at one fitted point would not
establish derivative equivalence.

One further interpretation follows from
`log f_beta,theta(y) = log f_beta(y | T=t) + log f_beta,theta(T=t)`.
At the profiled ability the total-likelihood derivative depends only on t.
The conditional likelihood score has conditional mean zero. Consequently,
`R_beta` is the *negative* conditional likelihood score (our U_0 uses negative
profile gradients). This does not establish identification of all structural
coordinates: with Criterion ownership, for example, the owner-specific
location factor `exp(-a_g b_g T_g)` also cancels upon conditioning. The
conditional component alone cannot estimate that location contrast. Do not
replace the finite-order method with conditional maximum likelihood on this
argument alone.

### Conditional count moments are coefficient derivatives

This is a direct derivation for the existing code, not a new derivative method.
The full-text comparison below distinguishes the source algorithms. For owner g,
let n_j be the assigned exposure in cell j and w_jc the positive category
weights at ability zero. Introduce log markers v_jc and a formal variable z:

```text
F_g(z,v) = product_{j in g} (sum_{c=0}^2 w_jc exp(v_jc) z^c)^n_j,
Z_g(t,v) = [z^t] F_g(z,v),
E_beta[N_jc | T_g=t] = (partial Z_g(t,v)/partial v_jc)|_{v=0} / Z_g(t,0).
```

The multinomial multiplicities for repeated ratings arise automatically from
the powers n_j. Each marker derivative multiplies an outcome's weight by its
cell category count. The code's `probability` and `moment` arrays carry these
coefficients and first derivatives through ordinary convolution and the product
rule. Normalizing each cell's weights before convolution multiplies both
numerator and denominator by the same factor, so the conditional count means
are unchanged. For marker differentiation, those weights are held fixed.
The ability tilt exp(a_g theta t) likewise cancels at a fixed total.

The Hessian of log Z_g(t,v) with respect to these markers at zero is the
conditional count covariance. This identity is not an implementation of a
structural-parameter Hessian: beta changes the weights, profiling and transition
operator as well. The current code propagates first count moments and uses the
already checked full estimating-equation Jacobian. No new covariance routine
or faster derivative algorithm is claimed here. Cai's score convolution is
already established prior art.

Full-text review of Andersen (1972) now confirms prior art for polytomous
normalizer recursions (equation 16), polynomial coefficients (p.47), scaling
(equations 26–28), conditional means (equation 29) and second derivatives for
CML information (equations 33–35). His conditioning statistic is a vector of
category frequencies, not our vector of owner score totals. For our statistic,
the analogous leave-one-rating identity follows directly from the product:

```text
f_j(z) = sum_c w_jc z^c,
E[N_jc | T_g=t] = n_j w_jc [z^(t-c)]
                  (f_j(z)^(n_j-1) product_{l in g, l != j} f_l(z)^n_l)
                  / Z_g(t,0),                         for n_j > 0.
```

For n_j=0 the count is zero; do not evaluate a negative polynomial power.
This is a coefficient identity explaining the existing forward propagation,
not a second implementation. Andersen's CML information inverse is not the
covariance of our adjusted JML equations.

Liou (1994), equations (3)–(15), distinguishes positive sum recursions from
subtractive recursions for higher derivatives of binary-item symmetric
functions. Our count propagation belongs to the former computational pattern;
it does not implement her extended difference algorithm. Her derivatives with
respect to transformed item parameters are not log-marker derivatives or full
beta derivatives without the relevant chain rule. Her Table 4 and p.61 show
that accuracy depends on parameter spread, not merely test length. The printed
union formula's summation range also needs care for unequal group sizes; see
the [source review](jml-publication-positioning-20260927.md).

Retain the current positive convolution and the existing enumeration checks.
Neither the historical speed comparisons nor avoidance of subtraction warrants
an unrestricted precision claim. The existing underflow refusal remains
necessary, and any expansion to extreme weights requires an independent
high-precision comparison before acceptance. No new broad stress grid or
production algorithm replacement follows from this literature review alone.

### Valid moments and identification are separate requirements

Bonhomme's *Functional Differencing*, October 2011 author manuscript underlying
the 2012 article, makes this distinction explicitly in Proposition 1 (printed
p.15) and Theorems 2–4 (pp.19,27–29). The exact projection restrictions and their
rank/regularity conditions do not automatically apply to a finite iteration of
our fitted-ability transition. In particular, our L is a lift from totals,
whereas Bonhomme's L is a likelihood operator; identical letters do not identify
the methods.

For the Criterion-owner example above, the conditional density is independent
of the Criterion location contrast throughout the parameter domain. Thus that
component of R_beta is identically zero, and all conditional moments derived
only from this conditional density lack information about that contrast.
The corresponding finite-order equation obtains its information from
`L (I-K_beta)^k Gbar_0`, whose expectation need not vanish at the generating
truth. If this entire term were to vanish in a limiting correction, the limit
R_beta would lose that coordinate's identification. This is a conditional
statement, not a proof that the current iteration converges or that every
finite-order root becomes singular. Nor does it establish non-identification
from the full data or from other estimating equations.

Consequently, choosing an order must consider the full Jacobian and statistical
precision as well as bias. A sample Jacobian with full rank establishes neither
truth identification nor negligible residual bias. Before a larger sampling
study, the method decision must specify which coordinates remain targets, the
fixed correction/solver policy, and the treatment of displacement from truth.
Keep the existing finite-order and fixed-roster checks as evidence; do not
replace them with Bonhomme's exact-projection consistency or efficiency claims.

Finally, Dhaene & Weidner equation (22) describes variability around the
population moment root, not automatically around the generating truth.
Their Lemma 2 and its posterior-predictive proof do not transfer to our MLE
plug-in operator without a separate argument. Their large-T high-order bias
statement is explicitly a conjecture. Neither exact compression nor the
matching sandwich resolves residual-bias treatment or truth coverage.
