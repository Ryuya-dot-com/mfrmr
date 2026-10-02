# JML structural inference: literature and implementation review

Date: 2026-09-27. Local development review; no new inferential API qualified.

**Current October 1 status:** the
[shared MML/JML roadmap](internal-roadmap-0.2.4.md#mml-and-jml-validation-plan)
governs further work. It includes ordinary and corrected JML across small and
larger samples, N versus per-Person exposure, facet count/levels, allocation
and output-specific inference. The N=400 studies remain substantive evidence.
The additional study remains paused at 113/3,000 fit records. The prior design
review held new fitting, generation and timing, with no automatic resumption.
The user subsequently requested small new numerical checks. The
[bounded normal-range pilot](#bounded-numerical-pilot-after-authorization)
below is the resulting exception: four new datasets, paired ordinary/orders-2/4
fits and targeted exact-expectation/derivative checks. It does not resume the
paused study or authorize either large confirmation proposal.
The October 2 deadline has been relaxed. Historical launch/deadline statements
below are superseded, and the separate 400-case MML replay has completed.
No current estimator, covariance rule or public interval scope changed in
this roadmap revision; the dated records retain their original source scope.
The current [JML uncertainty and candidate-evaluation specification](internal-roadmap-0.2.4.md#jml-uncertainty-and-candidate-evaluation-specification)
now fixes the next output decisions: ordinary-JML profile/centering work stays
separate from corrected-JML root inference; orders 2/4 enter the expanded
mapping with an explicitly labelled consistent-root research interval candidate.
Its structural contrasts and paired-order summaries reuse saved full covariance
and Person influences. No automatic order selector or public CI is supplied.
Truth inclusion can be evaluated against generating truth without a new
population-root calculation in every cell; root-target inclusion requires a
compatible retained independent root. The paused N=400 protocol remains intact.
The [expanded allocation](internal-roadmap-0.2.4.md#expanded-allocation-shared-controls-and-scheduling-priorities)
now assigns first-stage R=50 to admitted facet/robustness mapping conditions,
retaining ordinary JML and both correction orders where supported. Only the
proved impossible output receives zero calls; covariance exclusions do not
remove admitted point fits. This descriptive delivery allocation does not
qualify truth coverage or replace the historical N=400 studies. Comparisons
keep their controls and small/large-N scope at each scheduling priority.

The source review also confirms that the internal adjusted-problem order-0
evaluation still inherits owner-total enumeration and its cap. It must not be
used to restrict ordinary JML's supported scope or relabel a profile reference
as the actual public joint optimizer. For corrected fits, public `Converged`
includes unresolved-start local points; candidate intervals instead require
consistent roots. The status and target distinctions are part of the future
study aggregation, not changes to public fitting, scoring or RootSE rules.
The [ordinary-JML residual bridge](#october-1-ordinary-jml-residual-bridge)
below now gives an exact conditional identity linking a finite public iterate
to the extended-profile gradient. Its local error bound requires curvature
and a selected profile solution; those conditions have not been certified for
the current public fits. Numerical equivalence, sampling covariance and truth
centering remain distinct gates.
The [corrected-equation derivative/tail increment](#full-derivatives-and-normal-tail-transfer)
extends the fixed-design normal-tail bound to the full evaluation Jacobian
and covariance moments, and establishes integrability of the proposed leading
bias coefficient. Expanding-range central remainders and the corresponding
root/sampling limits remain unproved; no calculation or public rule changed.

## October 1: structural-inference gaps and a normal-tail bound

**Analytic/source review only; no numerical evaluation or new procedure.**
The immediate question is whether the retained compact-ability argument can
justify structural truth intervals in the planned normal-population, low-exposure
comparisons. It cannot yet do so. The argument below resolves a narrower issue:
unbounded true abilities need not make the *profile-score* moments undefined,
even though extreme-response Person estimates are infinite. This is a local
derivation for the declared response model, not a theorem imported from a
different panel model or a qualification of the public solver.

### Separate equation-root variation from structural centering

Let beta_0 be generating structural truth and beta*_{k,L} a regular local root
of the population order-k equation under the stated roster/ability law. For a
fixed contrast c, the exact decomposition is

    c'(beta_hat - beta_0)
      = c'(beta_hat - beta*_{k,L}) + c'(beta*_{k,L} - beta_0).

The implemented Person sandwich addresses the first term. It does not estimate
or remove the second. For fixed exposure, a nonzero second term can persist as
N grows. The retained order-2/order-4 reconciliation has nonzero displacements
in all 20 coordinate/condition/order combinations, and opposite signs of the
paired MSE difference in its two log-slope conditions. These are existing
results, not a new failure calculation or a universal impossibility claim.

As a diagnostic identity under an adequate root-centered normal approximation,
write delta=c'(beta*_{k,L}-beta_0)/s, where s is the actual contrast SD, and let
the reported SE divided by s tend to r. A symmetric interval then has approximate
truth inclusion `Phi(z*r-delta) - Phi(-z*r-delta)`, with z the nominal normal
quantile. Thus covariance scale and centering affect coverage separately;
wide intervals can mask displacement. This is not an observed-data bias
estimate, a proposed SE inflation rule or a new acceptance cutoff. Refusal
gates can change the distribution of the returned subset, so this expression
does not qualify conditional coverage after selection. The exact accounting
identity remains `P(return and cover) = P(return) * P(cover | return)`.

The actual source uses the finite-MLE plug-in transition, as declared in
`R/core-jml-adjustment.R`; it does not average over a posterior for Person
ability. The distinction is material: the primary paper's
[Section 8.1](https://arxiv.org/html/2301.13736v2) explicitly separates
that alternative operator from its posterior-based construction, and the
general high-order rate in Section 4.2 is a conjecture. Neither supplies the
missing general-GPCM inference theorem. The retained fixed-block derivation
must carry its own assumptions and proof obligations.

### A bound that does not require finite Person-estimate moments

Fix a finite roster, unit weights, K categories, conditionally independent
ratings and independently free Person coordinates. Let observed cell counts
be L*e_j, with fixed nonnegative integer
e_j and at least one positive e_j. Structural evaluation parameters stay in a
fixed compact neighborhood with slopes `0 < a_min <= a_j <= a_max` and bounded
location/step offsets and their first derivatives. K, facet dimension, the
roster and correction order k stay fixed. These conditions concern the local
mathematical model; the public numerical gates do not prove them globally.

For one rating in cell j, write

    p_j(y | theta,beta) proportional to exp(a_j*y*theta + h_jy(beta)),
    y=0,...,K-1, with h_j0=0.

Bounded h gives, uniformly in the structural neighborhood, a constant C with

    E(Y_j | theta,beta) <= C*exp(a_min*theta)                 for theta<=0,
    K-1-E(Y_j | theta,beta) <= C*exp(-a_min*theta)             for theta>=0.

The first bound uses the category-0 term in the denominator; the second
uses the category-(K-1) term. Sum with weights L*e_j*a_j. A nonextreme observed
weighted total T lies at least a_min away from both 0 and its maximum M_L.
At its finite profile solution, expected weighted total equals T. Consequently

    abs(theta_hat) <= C0 + C1*log(L),   L>=1,

for constants depending on the fixed model neighborhood and roster. This is
a bound over all nonextreme response patterns, not a truncation of generated
abilities or an instruction to cap fitted Person estimates. The all-low and
all-high patterns retain their exact extended limits; their structural
profile-score contribution is zero under these free-Person/positive-slope
conditions. Anchored or constraint-coupled extremes are not included.

The envelope score for locations/steps is bounded by a constant times L.
Log-slope derivatives additionally contain theta_hat, so the full raw
negative profile score satisfies

    sup_y ||U_0,L(y;beta)|| <= C*L*(1+log(L)).

This follows directly from bounded category residuals and the preceding
profile bound. Let P_beta,L be the plug-in response transition, with absorbing
extreme patterns. It is a stochastic operator, hence a contraction in sup
norm. For fixed k, the implemented equation therefore obeys

    sup_y ||U_k,L(y;beta)||
      = sup_y ||(I-P_beta,L)^k U_0,L(y;beta)||
      <= 2^k*C*L*(1+log(L)).

This loose bound does not rank correction orders or establish a small mean
score. It does show that at each fixed L these score moments are finite under
any proper generating ability law within this conditional response model;
finite moments of theta_hat itself are unnecessary. With the additional local
root, nonsingular derivative, independent-Person and sampling-law conditions,
root-centered M-estimation is a distinct question from truth centering. This
observation does not prove root existence/selection or covariance calibration
at small N. Ordinary RSM/PCM have a_j=1 for the raw-score bound; it does not
introduce a corrected RSM/PCM estimator.
For an algebraic counterexample, one binary rating per free Person gives
only extreme patterns and U_0=U_k=0: the bound holds while the structural
equation has no information. Also, its constants need not remain bounded as
slopes approach zero or dimensions grow. Neither counterexample adds a study
condition; both prevent interpreting this bound as an identification or
practical-adequacy certificate.

For the planned normal laws, choose a mathematical cutoff
`t_L = mu_max + sigma_max*sqrt(2*q*log(L))`, L>=2, with
`abs(mu)<=mu_max`, `sigma<=sigma_max` and fixed q>0. Then
`P(abs(theta)>t_L) <= 2*L^(-q)`. For each fixed moment order r>=1,

    E[ ||U_k,L/L||^r * 1{abs(theta)>t_L} ]
      <= C_{k,r}*(1+log(L))^r * L^(-q).

Thus this *score-moment tail contribution* can be made negligible at any fixed
polynomial rate by choosing q sufficiently large. This is an analytic split
of an expectation, not conditioning the study on bounded abilities, changing
the normal generator or evaluating a new integral. It proves neither the
interior bias expansion nor a uniform derivative bound on that expanding
interval. Normal tails alone do not transfer the compact-ability theorem.

### Full derivatives and normal-tail transfer

**Subsequent October 1 analytic/source increment; no numerical calculation.**
The score bound above can be extended to the *full evaluation-parameter
derivative* and to the covariance's second-moment term. This resolves a tail
integrability issue in the fixed-design model; it does not yet establish the
central-region expansion or qualify the public covariance. The following
bounds concern the exact mathematical finite-MLE plug-in equation. Finite
profile tolerances, floating-point underflow refusals and source-specific
solver/covariance gates still require their own numerical evidence.

Keep the preceding fixed roster, unit weights, independent repeated blocks,
finite K>=2, fixed structural dimension/order and compact structural domain.
For this derivative argument the location/step and log-slope maps have bounded
derivatives of each required fixed order on that domain, as the present affine
and exponential maps do. Ability remains independently free and unanchored.
Write ell_L=1+log(L), W_k,L=U_k,L/L, and Q_beta,L=I-P_beta,L. All operator
formulas act on functions of the **full response pattern**, whether the exact
implementation evaluates them through owner-total compression or directly.

#### Differentiate the transition as well as the raw score

For any fixed structural direction v, the product rule gives exactly

    D_v W_k = Q^k D_v W_0
      - sum_{j=0}^{k-1} Q^j (D_v P) Q^(k-1-j) W_0.               (C1)

The operators need not commute. Dropping the sum treats the plug-in transition
as fixed and differentiates a different equation. In a population evaluation,
the generating beta_0, roster law and ability law F_g stay fixed:

    D_v G_k,L(beta) = sum_g pi_g E_beta0,Fg[D_v W_k,L(Y;beta)].    (C2)

At fixed L this interchange is a finite sum over responses, followed by an
ability mixture of their probabilities. The uniform bounds below also justify
it directly for any proper F_g on this fixed structural domain. Differentiating
`E_beta,F[W_k(Y;beta)]` instead would additionally differentiate the generating
law and would not yield the Jacobian needed for the estimator's covariance.

`mfrm_jml_adjustment_covariance()` in `R/core-jml-adjustment.R` differentiates
`problem$mean_score(b, order)` as a whole. Each evaluation recomputes the
profiles, probabilities, within-total expectations and transition recursion.
It thus targets the complete derivative in (C1), including beta-dependent
weighted totals. Its two finite-difference step sizes test numerical stability;
they are not a proof of the present bounds or small-sample covariance accuracy.
The code also uses actual Person contributions for the covariance, not just
their conditional owner-total means. No missing-transition-derivative defect
was found by this source tracing.

#### A lower bound at every nonextreme fitted ability

For one Person let n_j=L*e_j, T=sum_j a_j sum_r y_jr, and
M_L=sum_j n_j*a_j*(K-1). At a nonextreme profile t_hat, the conditional
expected weighted total equals T and both T and M_L-T are at least a_min.
Bounded category offsets imply p_j0>=c when t_hat<=0, and p_j,K-1>=c when
t_hat>=0, uniformly over the structural domain. For integer categories,

    Var(Y_j) >= p_j0 E[Y_j^2] >= p_j0 E[Y_j],
    Var(Y_j) >= p_j,K-1 E[(K-1-Y_j)^2]
             >= p_j,K-1 E[K-1-Y_j].

The appropriate inequality in each half-line gives the total Person curvature

    H_tt = sum_j n_j*a_j^2 Var(Y_j)
      >= c*a_min*T           if t_hat<=0,
      >= c*a_min*(M_L-T)      if t_hat>=0,
      >= c*a_min^2 > 0        in either case.                   (C3)

The constant is independent of L and the nonextreme pattern, within this
fixed structural/design scope. This is total curvature **at the fitted
nonextreme ability**, not one-block information at an arbitrarily large true
ability. Dividing it by L gives only a c/L lower bound. Extreme profiles are
excluded from (C3); their extended score is zero and their transition row is
absorbing and independent of beta. This does not invert their zero curvature.

Together with |t_hat|<=C*ell_L, (C3) supplies conservative derivative envelopes.
At a fixed finite theta, derivatives of a rating's log probability in beta
grow at most polynomially in |theta|. In particular, the total cross derivative
|H_t,beta| is bounded by C*L*ell_L at t_hat. Implicit differentiation gives

    ||D_beta t_hat|| <= C*L*ell_L.

This intentionally loose bound avoids assuming that Person information grows
linearly with L for every possible response pattern. Differentiating W_0 at
the profile gives `||D_beta W_0|| <= C*L*ell_L^2`. For a transition row,
differentiate its conditional response probabilities, including D_beta t_hat.
The absolute log-probability derivative is bounded by C*L^2*ell_L, so the
sum of absolute derivatives in that row has the same bound. Consequently

    ||D_beta P||_(infinity -> infinity) <= C*L^2*ell_L,
    sup_y ||D_beta W_k,L(y;beta)|| <= C_k*L^2*ell_L^2.            (C4)

The second inequality uses (C1), ||Q||<=2 and ||W_0||<=C*ell_L. Fixed dimension
allows directional and matrix norms to differ by constants. None of (C3)--(C4)
claims that these worst-pattern bounds describe typical numerical accuracy.

For any other fixed derivative order, repeated implicit differentiation divides
by H_tt and combines finitely many likelihood derivatives and lower-order
profile derivatives. By (C3), induction gives some finite powers of L and
ell_L. Derivatives of transition probabilities have the same property because
they are a probability times a finite polynomial in log-probability derivatives;
summing probabilities avoids a factor equal to the number of response patterns.
Repeated product differentiation of Q^k then gives polynomial envelopes for
the required fixed-order derivatives of W_k. This argument does not assert
sharp powers, uniformity as k grows, or an O(1/L) weak-error expansion.

#### Tail bounds for the Jacobian and covariance

Retain the same cutoff t_L and bounded-mean/variance normal family as above.
Using (C4), uniformly over the fixed structural domain,

    ||E[D_beta W_k,L * 1{|theta|>t_L}]||
       <= C_k*L^(2-q)*ell_L^2.                                 (C5)

For the unnormalized score U_k,L, its second moment on the covariance scale
obeys

    ||E[(U_k,L U_k,L')/L * 1{|theta|>t_L}]||
       <= C_k*L^(1-q)*ell_L^2.                                 (C6)

The same order holds for the centered score outer product within each fixed
roster, since its mean norm is also bounded by C_k*L*ell_L. Thus q>2 suffices
to make both displayed tails vanish. Larger fixed q controls any specified
polynomial rate, or other fixed-order derivatives/moments after accounting
for their envelope powers. There is no truncation of generated abilities or
data-dependent selection here; t_L only splits an expectation in a proof.

These are the tail pieces of `A_L/L=E[D_beta W_k,L]` and `B_L/L`, respectively.
They do not establish that either converges to J: the central-region limits,
nonsingularity, chosen local root and sampling-law assumptions are still
needed. They also do not establish an empirical sandwich CLT or consistency
when N and L grow together, or justify conditional coverage after refusals.
At fixed L, all these response-score derivatives and moments are finite under
any proper ability mixture in this model, even if ability itself has no finite
moments. The large-L bias expansion is a different, stronger question.

#### The leading bias coefficient is integrable; the remainder is the gap

For the fixed one-block family, let I(theta)=psi_tt(theta). The finite category
probabilities and positive slopes imply

    I(theta) >= c*exp(-C*abs(theta)) > 0.

For example, one observed cell's adjacent-category probabilities provide this
lower bound on its variance; the block has fixed nonzero exposure. The block
cumulants and their fixed-order derivatives have at most polynomial growth
in |theta| before division by I. Therefore the previously derived coefficient

    c_k(theta) = (-D_1)^k b_1(theta),
    b_1 = C_moment/(2 I) - A_moment*kappa_3/(2 I^2),
    D_1 f = f''/(2 I) - kappa_3*f'/(2 I^2)

has a bound `||c_k(theta)|| <= C_k*(1+abs(theta))^d*exp(C_k*abs(theta))`
for some finite d at each fixed k. Here A_moment and C_moment are the block
covariances defined in the fixed-block derivation, not the equation Jacobian.
Repeated differentiation produces only finite sums/products and finite powers
of 1/I. A normal family with bounded mean and variance integrates this envelope
uniformly. Hence the candidate coefficient `c_bar_k=sum_g pi_g E_Fg[c_k]`
is well-defined. This does **not** justify exchanging the large-L expansion
with expectation. The coefficient is defined at generating/evaluation truth;
its derivative along that diagonal is not the off-truth Jacobian in (C2).

To state the remaining obligation precisely, write at truth

    m_k,L(theta) = E_beta0,theta[W_k,L(Y;beta_0)]
                = c_k(theta)/L^(k+1) + R_k,L(theta).

One sufficient transfer condition would be

    sup_{|theta|<=t_L} ||R_k,L(theta)||
      <= C*(1+t_L)^d*exp(C*t_L)/L^(k+2).                         (C7)

If (C7) is proved for the actual recursion, its central remainder is
`L^(-k-2+o(1))`, since t_L=O(sqrt(log L)). The score-tail bound above and the
coefficient envelope then imply, for q>k+2,

    G_k,L(beta_0) = c_bar_k/L^(k+1) + O(L^(-k-2+o(1))).          (C8)

For the coefficient-tail step, completing the square in the normal density
shows that its exponential-polynomial envelope integrated outside t_L is
bounded by `L^(-q+o(1))`; bounded mean/variance make this uniform over the declared family.
The coefficient term also carries L^(-k-1). The raw score tail is bounded by
`C*ell_L*L^(-q)`, so both are negligible at the displayed remainder scale.

This is a **conditional transfer lemma**, not a claim that (C7) has now been
proved. It specifies what the compact-domain argument must additionally
control: its cutoff neighborhoods, inverse-mean derivatives, Taylor remainders
and every fixed operator composition as the true-ability range expands.
Tracking the score alone or the coefficient alone is insufficient. Merely
knowing that each compact interval has a finite remainder constant also
does not suffice: if that constant grew like exp(C*t_L^2), choosing a larger
q could worsen the central rate while improving the tail. Such growth is a
warning about an unproved bound, not a finding that the present remainder
actually has it.

Full evaluation derivatives and second-moment central remainders need their
own expanding-range control. If those establish a regular local root,
`A_L/L -> J`, `B_L/L -> J` and the matching empirical limit, then (C8) would
recover the previous leading centering rate and its conditional
`N/L^(2k+1) -> 0` sufficient restriction. The tail bounds alone cannot license
that restriction. Growing facets, vanishing slopes, informative allocation,
missingness and dependence remain separate design-specific problems.

Finally, the public exact calculation's default 5,000 owner-total-state cap,
positive-probability checks and finite profile solver remain unchanged.
An L-to-infinity result for the mathematical equation does not mean that the
current API can execute an arbitrarily long sequence of such fits. No new
correction order, covariance choice, bias estimate or interval is introduced.

### Bounded numerical pilot after authorization

**October 1: completed after the user requested small new estimation,
simulation and numerical differentiation.** The question was whether the
derivative accounting agrees with the current implementation, and whether
wider abilities reveal finite-exposure or delivery problems before a larger
study. This pilot does not prove the expanding-range remainder bound above.

The [runner](jml-normal-range-pilot-20261001.R) reuses the saved Criterion-owned
GPCM design: two raters, two criteria, categories 0/1/2, centered locations/steps
and log slopes, truth (.3,-.4,-.6,-.9,.25), and two unequal rosters with
exposures (2,1,0,1) and (0,2,2,2), in proportions .6/.4. Repeats are generated
conditionally independently. The frozen scope was:

- Full response-pattern derivative witnesses for both rosters, at truth and
  one fixed off-truth vector; all five structural directions, central steps
  1e-4 and 5e-5, and correction orders 2/4. Generating distributions stay fixed
  during evaluation-parameter differentiation. The independent pattern
  reference uses scalar root solving; the current equation uses compressed
  totals and vector bisection.
- Exact conditional score means at abilities -6,-4,-2,0,2,4,6, exposures
  L=1,2,4,8 and orders 0/2/4, for both rosters and all five coordinates.
  These are 168 vector expectations (840 coordinate rows), not simulated
  datasets. The largest total-state space is 2,145; all states are retained.
- Four new datasets: N=40/120 crossed with normal SD=1/2, mean zero, one
  replicate per condition, original exposure L=1. Seeds 98100101--98100104
  differ from the paused study's declared seed family. Each dataset is shared
  by ordinary public JML and explicit orders 2/4. The public default starts,
  maxit=400 and method-specific tolerances remain unchanged. A 60-second
  per-call resource limit is recorded; no retained fit reached it.

#### Derivative and covariance agreement

The explicit product rule (C1) and the independent response-pattern derivative
were compared with finite differences of the current complete equation, over
80 direction/order/step witnesses. Maximum point discrepancy was 2.586292e-12.
Maximum derivative discrepancies, divided by max(1, maximum absolute complete
derivative in that witness), were 2.249613e-8 for the independent full reference
and 2.250534e-8 for the product rule. Halving the derivative step changed the
complete derivative by at most 2.979173e-8 on this scale. All pass the frozen
1e-8 point and 1e-6 derivative tolerances.

Freezing the transition while differentiating the raw score instead produced
scaled discrepancies .1339160--.9946845 across the same witnesses. These are
derivative differences, not estimated coverage loss or percentages of SE.
Thus including the transition derivative matters in these designs; the
current whole-equation implementation agrees with the complete calculation.

All eight returned corrected covariances were independently reconciled at
their retained roots using the total-expectation research implementation and
the original fixed-roster sampling law. Maximum discrepancies were
1.177921e-9 for the Jacobian scaled by max(1, its maximum absolute entry),
1.332268e-15 for the meat in absolute units, and 2.936638e-9 for covariance
relative to its maximum absolute entry. The saved influence cross-product
reproduced the public covariance exactly in these checks. This is agreement
between calculations of local-root uncertainty, not sampling calibration or
truth-centering evidence.

#### Finite-exposure and public-fit findings

At true ability +/-6 and L=8 (32 or 48 ratings per Person), extreme-pattern
probabilities across the two rosters and signs still range from .4290673 to
.8389072. At ability zero they are below 2.33e-17. The exact equations retain
all of that endpoint mass. The maximum absolute normalized score mean over
both rosters, all seven abilities and all coordinates is:

| L | Raw profile | Order 2 | Order 4 |
| --- | ---: | ---: | ---: |
| 1 | .251451 | .093250 | .066747 |
| 2 | .152324 | .060461 | .047588 |
| 4 | .096830 | .037086 | .024734 |
| 8 | .056698 | .018892 | .014922 |

These maxima decrease, but their L^(k+1)-scaled values have not stabilized
on this wide ability grid: for order 2 the maximum rises from .09325 to
9.67291, and for order 4 from .06675 to 488.958. Four exposure levels neither
refute an eventual asymptotic rate nor establish it. These are conditional
score means, not structural estimator bias; they do not integrate over either
normal distribution used in the new datasets. The result supports treating
the expanding-range central remainder as substantive work, rather than
declaring the compact-range approximation adequate for modest exposure.

| N | Generating SD | Extreme Persons | Ordinary JML numerical/readiness result | Corrected orders 2 and 4 |
| --- | ---: | ---: | --- | --- |
| 40 | 1 | 1 | Numerical pass; fit remains review | Both return a local point/covariance with unresolved alternate start |
| 120 | 1 | 10 | Numerical pass; fit remains review | Both starts agree for both orders; local covariance available |
| 40 | 2 | 7 | Iteration limit; fit blocked | Both starts agree for both orders; local covariance available |
| 120 | 2 | 32 | Numerical pass; fit remains review | Both starts agree for both orders; local covariance available |

For N=40/SD=1, unsuccessful corrected-start stages include owner-total
probability underflow; the last unsuccessful stages stop without solving the
equation (residuals 3.386879e-4 and 9.625520e-4 for orders 2/4). Small residuals
and available covariance at the returned branch do not resolve that missing
start confirmation. These two results fail the existing consistent-root
research-interval gate; they are not discarded from point-delivery results.
No second distinct accepted root was observed.

The ordinary N=40/SD=2 fit returns finite structural traces but is explicitly
blocked: fitted slopes are approximately .01736 and 57.5886, and the largest
absolute error among the five free structural coordinates is 38.1878. The
independent profile-reference evaluation underflows at that point and is
unavailable. It supplies no profile-error certificate. The three numerical-pass
ordinary cases have independent profile mean-score residuals at the unchanged
public structural point between 1.13e-7 and 3.90e-7; no structural reference
refit or neighborhood-curvature certificate was performed. In the machine
summary, ordinary `PointAvailable` only records finite returned structural
values; the separate readiness status determines whether they are usable.

All fits retain the expected duplicate-cell warning for this repeated-response
design. The failed ordinary fit additionally retains the iteration-limit
warning. Generated repeats are independent conditional on ability by design;
this does not validate dependence between real repeat ratings. One dataset
per condition supplies no bias estimate, empirical SD, coverage estimate,
failure-rate comparison or preferred order. The generic small-to-large-N and
facet/missingness/dependence roadmap is unchanged.

#### Execution accounting and decision

The initial pilot calls were rejected before estimation because the runner
passed correction-only sampling to ordinary JML and `reltol` to corrected JML.
Those 12 argument errors and their source are retained. The corrected runner
reuses the same four saved inputs. Its first pass saved six fits, then stopped
when the ordinary N=40/SD=2 reference evaluation underflowed outside the error
handler. Completion preserves that failure, reuses the six saved fits and
retains reference failures without aborting. The unretained ordinary fit was
repeated once on the same saved input. Thus there were 12 pre-estimation
rejections and 13 estimation calls for 12 unique method/dataset pairs, with no
additional data generation. A summary-field bug caused R's partial `$error`
lookup to match `$errors`; exact lookup and reconciliation corrected the
reported reference-error column without recomputing those fitted results.

The final evidence is
`validation-results/jml-normal-range-pilot-20261001/verified-summary.rds`,
with initial/refit/completion logs, all four inputs, source snapshots/hashes,
derivative arrays and step checks, exact means, and each fit's warnings,
attempts and covariance. The twelve retained fits used 87.405 seconds in their
recorded fit calls; this excludes reference calculations and failed/repeated
pilot work and is not a runtime benchmark. Source and input hashes were checked
after completion. No paused study, MML confirmation, public inference gate or
estimation default was changed.

This pilot provides concrete targets for further work: distinguish the
corrected-start transition-probability underflow from unresolved root behavior
using the saved attempts, retain the blocked ordinary fit as an adverse
boundary/numerical witness, and control the finite-exposure remainder before
claiming normal-population centering. Increasing replication before resolving
which procedure will be evaluated would not answer these numerical questions.

### Subsequent facet-structure witness

The [bounded C-design pilot](internal-roadmap-0.2.4.md#bounded-facet-structure-pilot-after-authorization)
adds N=20/240 comparisons with two or three non-Person facets, varying Rater
3/6 and Task 2/4 while retaining Criterion 2, categories 0/1/2 and eight
responses per Person. Ordinary JML and both corrected orders share each input;
estimated-population one-family MML supplies the matched marginal arm. The
full design, integration refinements and all censored calls are recorded there.

This witness makes the C-design covariance limitation concrete. At N=20,
six-rater and four-task allocations have within-roster score ranks 5 and 8
for nine structural coordinates. Returned corrected points therefore do not
imply estimable full covariance under the declared fixed-roster law. At N=240,
all ten corrected calls return consistent-start roots and covariance. Three
N=20 corrected calls reach the declared time budget; their root status is
unresolved, not established nonconvergence. Half-step covariance reconstruction
agrees for the fourteen available cases, using native score evaluation.
These are design-specific numerical witnesses. They establish neither the
ordinary estimator's structural sampling covariance nor corrected truth
centering, growing-facet asymptotics or protection against informative
assignment and dependent ratings.

### Remaining conditions tied to the actual roadmap

| Planned use | What this review establishes or reuses | Remaining condition for structural truth inference |
| --- | --- | --- |
| Ordinary public JML | The raw mathematical profile score has the stated bound. Retained finite-profile and extreme-profile fixtures distinguish ordinary optimizer output from a separately reoptimized extended-profile estimator. | Bridge the actual public structural point to a declared finite/extended-profile solution; derive its joint sampling covariance and address structural centering. A finite optimizer trace or the Schur inverse alone is insufficient. |
| A/B normal populations and fixed L=1/2 | Score, complete-Jacobian and covariance-moment tail contributions have bounds in the fixed-design model; the leading bias coefficient is normal-integrable. Independent data allow direct descriptive truth inclusion of the named corrected candidate. | Prove the expanding-range central remainders for the actual recursion, full evaluation derivatives and covariance; justify local-root/sandwich behavior and control displacement relative to SE. Two exposure values do not establish a growth theorem or a practical threshold. |
| C new facets, levels and categories | Each fixed supported design can have its own constants and parameter map. Existing cap/roster exclusions remain. | Bounds and identification are design-specific; no uniform claim across growing dimensions or arbitrarily weak links follows from fixed-dimension results. |
| E assignment, missingness and dependence | Random-roster centering is already a different sampling target; the existing controls separate mechanisms. | Informative allocation/missingness can alter conditional response/ability laws; dependence breaks the independent-block premise. A normal-tail bound and a sandwich do not remove these sources of displacement. |
| A public bias-adjusted or bias-bounded interval | Existing saved roots diagnose displacement for their own generating laws. | A usable observed-data bias correction needs its own target, uncertainty and validation. A bound needs a justified bound over a declared domain. Generating truth, saved oracle displacement or a difference between orders supplies neither. |

The next mathematical step is to track the compact expansion's constants and
its full evaluation-parameter derivative on the expanding normal range, or
to derive a directly integrated remainder bound. This is a proof obligation,
not a request for another exposure-root grid. The retained joint-growth
restriction `N/L^(2k+1) -> 0` cannot be reused unchanged until the transferred
rate, covariance and root assumptions are justified; no minimum-N or minimum-L
rule is chosen from it. Fixed-L descriptive mapping remains scientifically
useful without claiming such a theorem, and cannot itself supply a universal
truth-interval guarantee.

Keep the observed-data orders 2/4 and their research candidate gates unchanged.
The ordinary public/profile bridge and corrected centering argument are
separate outstanding tasks; neither requires a new estimator default, automatic
order selection or a new all-cell population-root calculation now. Full formal
JML inference remains unfinished within the agreed work. This review adds no
repetitions, numerical checks or public interval, and resumes no paused study.

## October 1 ordinary JML and matched comparison contract

This is a static source review and design decision, with no fitting, generation,
derivative evaluation, numerical pilot or restart. It supports the
[current baseline contracts](internal-roadmap-0.2.4.md#resolved-baseline-comparison-contracts).
Older repeated-sample and external-engine records retain their original
source/procedure identities; they are not evidence that all current public
ordinary-JML outputs share a qualified profile estimator or covariance.

| Question | Current source evidence | Consequence for the planned evaluation |
| --- | --- | --- |
| What is ordinary JML? | `fit_mfrm()` in `R/api-estimation.R` dispatches a non-NULL `jml_correction_order` to the distinct corrected route. Otherwise `mfrm_loglik_jml()` / the cached evaluator in `R/mfrm_core.R` and the direct optimizer fit free Person and structural coordinates jointly. | Retain the public unadjusted procedure as its own arm. The research extended-profile reference, external score adjustments and classical multiplicative corrections are different procedures. |
| Which scale is common? | `build_facet_constraint()` calls in `R/mfrm_core.R` leave Person uncentered and center non-Person facets under `noncenter_facet="Person"`; one-family log slopes and step constraints determine the remaining representation. `fit_mfrm()` requires this centering for estimated-population MML. | Match centered facet/step parameters and geometric-mean-one slopes in A/B, with explicit estimated-normal MML. A fitted normal mean/SD is not available under JML. Do not transform JML by its noisy empirical Person SD. |
| What happens to extreme Persons? | `audit_mfrm_person_boundary()` and `apply_mfrm_person_boundary()` in `R/core-jml-boundary.R` set independently free all-low/all-high primary estimates to -Inf/+Inf and display estimates to NA, retaining finite optimizer traces separately. Anchored extremes are fixed; constraint-coupled extremes require review. | Count endpoints and boundary statuses. Keep all original datasets/Persons; do not treat the finite trace as an MLE or infer that all structural contrasts are unidentified. |
| What do ordinary-JML SEs mean? | `calc_facet_se()` sums weighted observation-level information within each level. `build_measure_se_table()` uses these approximations for JML and labels their precision exploratory/screening-only. The full-curvature source check for GPCM scoring does not return a structural sampling covariance. | Do not create a joint contrast interval by combining marginal printed SEs, call the screening bands qualified truth intervals, or transfer research sandwich coverage to the public fields. |
| Can this calibration score new Persons? | `prediction_source_scoring_readiness()` and `prediction_jml_calibration_review()` in `R/api-prediction.R` reject known Person/additive/slope boundaries; the latter also checks finite unregularized joint curvature. `mfrmr_calibration_jml_source_review()` in `R/core-fixed-calibration.R` enforces source readiness for extraction. | Calibration-cohort Person endpoints and new-Person conditional EAP are different outputs. Report source acceptance and score delivery separately from calibration point recovery, including how those rates change with N. |
| Is corrected-JML scoring the same gate? | `mfrm_jml_scoring_components()` in `R/core-jml-adjustment-scoring.R` checks the adjusted equation, rank and remaining root step. Point availability is separate from covariance availability. | Do not apply ordinary-likelihood source rules to the adjusted estimator or discard an admitted point/scoring result merely because RootSE is unavailable. |

**Why the larger-N conditions matter for delivery as well as bias.** Under
independent Persons with fixed per-Person exposure and common extreme-response
probability p_ext, the probability of at least one extreme training Person is
`1 - (1-p_ext)^N`. With fixed roster counts N_g and roster-specific probabilities
p_ext,g, it is `1 - product_g[(1-p_ext,g)^N_g]`. These are probability identities
under the stated independence/sampling assumptions, not estimated frequencies.
For 0<p_ext<1 the common-design probability increases as Persons are added
without changing their individual designs. Therefore larger N need not increase the availability of
an ordinary-JML consumer requiring *all* training Persons to have finite
estimates. Absence of extremes only gives an upper bound on acceptance; other
checks can still fail. This does not establish that structural calibration
becomes less accurate or that MML/corrected JML will be preferable.

The old external-engine pilot includes an `extended_profile_limit_v1` arm.
Its `mfrmr_jml_profile_recovery_apply()` adapter lives in
`inst/validation/jml-extreme-profile-recovery-pilot-0.2.3.R` and replaces tables
with a separately computed profile-limit result. This is not the ordinary
public optimizer's automatic behavior. The retained GPCM raw-profile and
corrected research studies likewise cannot silently stand in for current
public-solver failure rates. A future numerical bridge is needed only for the
specific evidence transfer sought, after the computation hold is lifted; a
successful bridge would not make all resulting statistical claims universal.

**Decisions closed for the A/B baseline.** Use explicitly estimated-normal MML
and the centered-facet/relative-slope scale shared with ordinary/corrected JML;
retain fixed-N(0,1) fitting as a separate assumption/default-workflow comparison.
Do not impose a normal population fit on JML. Common-prior EAP uses a declared
N(0,1) scoring prior through the supported prediction route, separately from
native scoring. Preserve all data-dependent refusals in delivery denominators.
No structural interval consumer or boundary-profile extension is added by
this decision. Source classification is established. The shared roadmap now
specifies [A/B generating truths and assignments](internal-roadmap-0.2.4.md#ab-generating-truth-and-assignment-specification),
[facet/workload comparisons](internal-roadmap-0.2.4.md#c-facet-structure-with-explicit-workload-controls)
and [robustness mechanisms with matched controls](internal-roadmap-0.2.4.md#e-robustness-mechanisms-and-matched-controls).
The fixed-roster baseline and iid assignment/missingness experiments have
different sampling laws; corrected-JML covariance must target the declared
law, rather than switch options after a rank failure. Statistical performance,
missing interval consumers, extensions and final execution/replication settings
remain open. The shared
[inference decisions and evidence allocation](internal-roadmap-0.2.4.md#inference-decisions-and-evidence-allocation)
now assigns existing studies, broad comparisons and future confirmation their
separate roles. The retained compact-domain, independent-exposure growth
argument does not qualify the new normal/skewed/dependent designs. Orders 2/4
remain separate point-estimation comparisons, while ordinary-JML formal
structural uncertainty and corrected-JML truth centering remain open. This
does not restart or replace the paused order-2 research protocol.
The [F scoring/reuse specification](internal-roadmap-0.2.4.md#f-person-scoring-future-cohorts-and-saved-reuse)
keeps native Person profiles separate from post-hoc reference-prior EAP,
accounts for calibration-source and batch refusals, and evaluates held-out
Persons with calibration-replicate uncertainty. Missing RootSE alone does not
invalidate an adjusted calibration that passes its own scoring-source checks;
ordinary-JML boundary refusals are not bypassed by finite printed estimates.
The [numerical protocol](internal-roadmap-0.2.4.md#calibration-procedures-and-bounded-numerical-refinement)
now specifies ordinary-JML controls and the corrected public maxit=400 call
with its two deterministic starts and recorded root-solving stages. No external
start search, order switch or covariance-driven root refit is introduced.
[Source/RNG identity](internal-roadmap-0.2.4.md#source-identity-and-random-number-allocation)
and [replication allocation rules](internal-roadmap-0.2.4.md#condition-accounting-and-precision-decisions)
retain the original studies and their seeds; no new manifest or data was created.
The [static source audit](internal-roadmap-0.2.4.md#static-source-audit-and-reusable-units)
now separates the research studies' different starts/root-acceptance rules from
the public procedure. In contrast, the public pilot snapshot's three adjusted-
JML core files match current files, and its order-2/fixed-roster/maxit=400 call
matches the planned public settings. The paused study retains that identity
and its additional consistent-root requirement for candidate intervals; its
113 fit files and 57 input files were counted without evaluating their results.
No interim sampling summary or resumption was performed. The
[family allocation ledger](internal-roadmap-0.2.4.md#family-allocation-ledger-and-work-order)
selects the full A/B sample-size/SD/exposure mapping for a working R=100 delivery
assessment, while preserving N=400 evidence and separately budgeting precise
correction-effect or interval claims when their required planning inputs exist.

The workflow help's blanket statement that the public JML route was uncorrected
was corrected in both its roxygen source and Rd page. It now distinguishes the
default unadjusted call from explicit experimental GPCM correction and retains
the limits on RootSE. NEWS already made this distinction; no fitting default,
estimator or numerical threshold changed. Documentation was checked statically;
no R tests or help regeneration were run during the computation hold.

## October 1 ordinary JML residual bridge

**Static source tracing and analytic derivation; no new numerical evaluation.**
The question is whether covariance derived for a profile estimator can describe
the structural values actually returned by ordinary `fit_mfrm(method="JML")`.
An exact regular joint solution supplies a correspondence, but a finite
optimizer iterate and a successful termination status do not establish it.
The derivation here makes the discrepancy explicit before any covariance is
transferred. It is conditional mathematical work, not an empirical certificate
for all public RSM/PCM/GPCM fits.

### Which public point is being compared?

`make_mfrm_direct_evaluator()` in `R/core-optimizer.R` evaluates the negative
conditional log likelihood jointly in free Person and structural coordinates.
`run_mfrm_direct_optimization()` retains an `opt$par` and recomputes its joint
gradient. In `mfrm_estimate()` (`R/mfrm_core.R`), `expand_params(opt$par, ...)`
supplies the parameters used by `build_other_facet_table()`, `build_step_table()`
and `build_slope_table()`. `apply_mfrm_person_boundary()` only changes Person
table fields: setting an extreme Person's primary estimate to signed infinity
does not reoptimize or replace the retained structural coordinates. The bridge
therefore concerns those unshrunk structural estimates and their identified
free-coordinate representation, not the displayed infinite Person values or
post-hoc `ShrunkEstimate` columns.

`build_mfrm_optim_control()` uses objective-change controls and, for L-BFGS-B,
a projected-gradient control. `build_optimizer_diagnostics()` reviews the
terminal joint gradient against `max(1e-4, 10 * reltol)` in this route; this is
not a bound on structural parameter error. R documents `reltol` in terms of
objective reduction and convergence code zero as successful completion.
Neither is a guarantee of proximity to an identified profile minimum.
See the [R optim documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html).
The package's separate boundary/readiness checks remain in force; this review
does not replace them or change their numerical thresholds.

### Exact identity at a finite joint iterate

Use unit weights, a fixed finite observed response design with at least one
response per included Person, a finite category set of size at least two,
no interactions or shrinkage, and independently free, unanchored Person
coordinates. Work in identified free
structural coordinates beta, with the declared affine location/step constraints
and, for one-family GPCM, identified log-slope coordinates. Restrict beta to a
finite neighborhood where slopes have a positive lower bound. RSM/PCM have
unit slopes. This establishes a baseline, not a restriction on the package's
other supported point-estimation designs.

Write the negative log likelihood as

    Q(theta, beta) = sum_i q_i(theta_i, beta).

Partition Persons into nonextreme I and all-low/all-high E. For i in I,
q_i is strictly convex in its scalar theta_i: its second derivative is the
sum of positive slope-squared conditional response variances. The score has
opposite signs in the two tails, so a unique finite conditional minimizer
t_i(beta) exists. For i in E, the infimum is zero as theta_i tends to the
appropriate infinity. It is not attained at a finite theta_i. Thus the
extended-profile objective for this observed dataset is

    M(beta) = inf_theta Q(theta, beta)
            = sum_{i in I} q_i(t_i(beta), beta).

The zero terms from E are an exact likelihood limit, not deletion of failed
datasets or a change to recovery/delivery denominators. They say nothing yet
about existence, identification or uniqueness of a structural minimum of M.

At a finite public iterate (theta_tilde, beta_tilde), define the following
column vectors in the same free-coordinate representation:

    r_beta = partial_beta Q(theta_tilde, beta_tilde)
    r_I    = partial_theta_I Q(theta_tilde, beta_tilde)
    e_beta = sum_{i in E} partial_beta q_i(theta_tilde_i, beta_tilde).

Let d = theta_tilde_I - t_I(beta_tilde). Hold beta=beta_tilde and the extreme
traces fixed; integrate Hessian blocks along theta_I(s)=t_I+s*d, 0<=s<=1:

    Hbar_II    = integral_0^1 partial_theta_I,theta_I Q(theta_I(s), beta_tilde) ds
    Hbar_betaI = integral_0^1 partial_beta,theta_I Q(theta_I(s), beta_tilde) ds.

Hbar_II is positive diagonal. The fundamental theorem of calculus gives
r_I=Hbar_II*d and the difference between the nonextreme structural gradients
as Hbar_betaI*d. Using the envelope gradient at t_I therefore gives the exact
identity

    g_profile(beta_tilde) = grad M(beta_tilde)
      = r_beta - e_beta - Hbar_betaI Hbar_II^{-1} r_I.                 (1)

There is no omitted Taylor remainder: the bars denote integrated Hessians,
not blocks evaluated only at the terminal point. If I is empty, the last term
is absent and M is constant, so structural identification fails in this
baseline. Small r_I alone need not imply small ability error when Person
curvature is weak; the effect on beta depends on the cross-curvature term.

When E is empty and the finite joint score is exactly zero, (1) yields a zero
profile score. A positive Person block and positive profile Schur complement
give a strict local joint/profile minimum. This is a local statement; in
particular it does not select a global GPCM optimum. When E is nonempty there
is no finite joint optimum in the independently free extreme directions.
The finite public structural point may still approximate an extended-profile
minimum, but its approximation must account for all three terms in (1).

### From score discrepancy to structural error

Suppose a selected interior profile root beta_p exists, and the profile
Hessian has smallest eigenvalue at least lambda>0 throughout a convex
neighborhood containing beta_tilde and beta_p. Then integration of the
profile Hessian between these points, followed by Cauchy--Schwarz, gives

    ||beta_tilde - beta_p|| <= ||g_profile(beta_tilde)|| / lambda
      <= (||r_beta|| + ||e_beta||
          + ||Hbar_betaI Hbar_II^{-1} r_I||) / lambda.               (2)

This is a Euclidean bound in the stated coordinates. A positive Hessian at
one point does not certify the neighborhood, root existence or the lower
bound lambda. The first-order expression `S^{-1} g_profile`, with S the
profile Hessian, is a local displacement diagnostic, not a proved error bound,
bias correction or confidence interval.

Existence can instead be certified locally if a closed ball of radius rho
around beta_tilde lies inside the regular structural domain, the same lower
curvature bound holds throughout the ball, and `||g_profile|| < lambda*rho`.
On its boundary the outward radial derivative is at least
`rho*(lambda*rho - ||g_profile||)>0`. A minimum over the compact ball must
therefore be interior, and strict convexity makes that root unique within the
ball. This supplies a sufficient existence condition for (2), not global
uniqueness. Neither the ball nor its curvature bound has been numerically
certified here.

For fixed structural dimension p, let every component of the finite joint
gradient be bounded by epsilon and put
`kappa_i = ||Hbar_beta,i|| / Hbar_ii`. A sufficient bound from (1) is

    ||g_profile|| <= sqrt(p)*epsilon + ||e_beta||
                    + epsilon*sum_{i in I} kappa_i.                (3)

Consequently, even a joint-gradient check cannot be interpreted without
curvature and aggregation over Persons. As an illustrative conditional regime,
suppose lambda>=c*N, sum(kappa_i)<=C*N and the deterministic gradient bound
epsilon hold on events with probability tending to one, for constants c,C>0.
If a justified contrast has a nondegenerate sampling scale N^(-1/2),
`epsilon=o(N^(-1/2))` and `||e_beta||=o_p(sqrt(N))` then suffice to make
the bound in (2) negligible in probability at that scale. These are sufficient asymptotic conditions
for that bound, not necessary conditions for a particular fit or proposed
package cutoffs. A fixed review tolerance alone proves neither equivalence
nor failure as N changes. Sparse designs, increasing structural dimension or
weak curvature require their own rates.

For an extreme Person already in the correct tail, finite categories, bounded
structural offsets/derivatives and slopes bounded below by a_min>0 give

    ||partial_beta q_i(theta_i, beta)||
       <= C*n_i*(1+abs(theta_i))*exp(-a_min*abs(theta_i)).            (4)

Here n_i is observed exposure and C depends on the declared structural
neighborhood/design. To see the bound, each nonendpoint category probability
is at most a constant times exp(-a_min*abs(theta_i)); its utility derivative
is bounded for locations/steps and grows at most linearly in abs(theta_i)
for log slopes. Their finite sum gives (4). Summing over E bounds e_beta.
The same limit makes extreme-Person curvature tend to zero: substituting an
infinite estimate into an inverse finite-joint information matrix is invalid.
One must form the extended profile first. The constants are not uniform over
vanishing slopes, growing facet structure or unbounded structural sequences.

### What transfers to covariance, and what remains separate?

Under a declared sampling law, let beta_star denote the population target
of the selected profile branch, and beta_0 generating structural truth. The
exact accounting is

    beta_public - beta_0
      = (beta_public - beta_p)       [numerical/procedure discrepancy]
      + (beta_p - beta_star)         [sampling variation]
      + (beta_star - beta_0).        [structural target bias]

For a prespecified contrast, a profile sampling limit transfers to the public
point if its first term is negligible at that contrast's justified sampling
scale, with the same branch/selection and availability accounted for. Reusing
a covariance estimator additionally needs its consistency under that sampling
law and stability under this perturbation; closeness of points does not qualify
the public screening SEs.
Equations (1)--(4) address the first term conditionally. They do not supply the
sampling covariance or bound the last term. The candidate sandwich in
[Sampling covariance and its target](#sampling-covariance-and-its-target)
concerns the second term under its stated assumptions. The inverse Schur
complement alone is not that sandwich, and neither removes fixed-exposure
incidental-parameter bias. The number of Persons and information per Person
therefore retain different roles in the roadmap.

Anchored extreme Persons contribute their likelihood at the fixed ability;
their profile contribution is not zero. Coupled Person constraints require
profiling the constrained nuisance vector, not the scalar separation above.
Nonunit weights, interactions, structural boundaries and growing facet counts
need explicit extensions. Conditioning on an observed missing-response roster
can preserve this likelihood algebra while changing the sampling law or
target. It does not justify informative missingness, assignment or dependence;
those remain the separate C/E comparisons. No normal ability distribution was
assumed for the deterministic identity, but that does not establish the
corrected-JML uniform derivative/bias expansion for unbounded abilities.

### Evidence reuse and the next bounded check

The two saved finite GPCM examples in the existing profile-information record
check local envelope/Schur identities, with nonzero retained structural
gradients. They do not certify (2) for current public sources. The older
[90-dataset extreme-profile pilot](jml-extreme-profile-recovery-pilot-record-0.2.3.md)
found a maximum raw/profile aligned structural change of 5.935103e-6 under
its own source and forced-extreme design. That is evidence of closeness there,
not a universal tolerance, an SE-scale result or a current-source bridge;
the record already shows that the profile operation does not repair bias.

After authorization for numerical work, first reuse compatible saved fits
and source identities. At their unchanged structural coordinates, independently
profile the free nonextreme Persons, use exact extreme limits, and check the
profile objective/gradient and the residual decomposition. New nuisance solves
or derivative evaluations are calculations and remain held. Only if local
curvature/branch evidence is adequate can a displacement diagnostic be used;
a rigorous error certificate additionally needs the neighborhood bound in (2).
A separately optimized structural reference, if needed, must retain its own
procedure identity and must not overwrite the public point. No correction
enumeration engine, order-0 state cap, new automatic refinement or public
interval is introduced. The bounded bridge concerns numerical correspondence;
covariance accuracy, bias and robustness still require their own evidence.

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
are now checked for the two existing finite examples. Transfer to current
public points still requires the source/procedure and residual bridge above.
The **centering/bias treatment for the true relative-slope target** and
covariance/coverage checks under a declared sampling design remain open. The current
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
[internal roadmap](internal-roadmap-0.2.4.md#ordered-work-and-reviewable-exit-conditions).

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

## September 30: exact centering loses identification; a conditional growth route

**Question and decision.** Can a further correction remove the remaining
structural displacement, using the observed responses without the generating
ability distribution? Exact conditioning on the vector of slope-owner totals
does remove the score mean. It does **not** identify all five structural
coordinates in the retained designs. It is therefore rejected as a complete
replacement for corrected JML. A design-preserving exposure-growth route is
specified below as the next mathematical candidate. Its primitive bias
expansion and finite-sample performance remain to be established; formal
structural intervals are still an unfinished requirement.

### An exact candidate and the information it discards

Fix a Person's assigned roster g and let S_c be the score total for slope
owner c. Under the implemented conditionally independent GPCM,

    p_beta(y | theta, g)
      = h_beta,g(y) exp{theta * sum_c a_c S_c(y)} / D_beta,g(theta).

The numerator h includes the location/step terms and, for aggregated repeated
responses, the multinomial multiplicity. Conditioning on the **vector** S
eliminates theta even when slopes are unknown:

    p_beta(y | S=s, g) = h_beta,g(y) / sum_{z:S(z)=s} h_beta,g(z).

This distribution is computable from the existing finite response spaces.
Its negative score is the original profile score minus its conditional mean
given S. This is a different equation from the finite MLE-plug-in correction;
no assertion is made that infinitely iterating that correction converges to
this conditional score.

An owner-location term b_c contributes exp(-a_c b_c s_c) to h. This is constant
within each conditioning stratum and cancels. Consequently the conditional
likelihood cannot estimate that owner's location contrasts. Centering the
locations does not recover this information. This is an algebraic invariance,
not a numerical eigenvalue threshold or a property of a particular ability
mixture.

There is also a broader, explicitly qualified obstruction. Suppose the finite
set of feasible weighted totals a'S has distinct values, as is generic for
free unequal slopes. A moment u(y,beta) that is centered for **every** ability
must satisfy

    sum_s exp(theta * a's) H_beta,g(s) E_beta[u | S=s,g] = 0

for all theta. Linear independence of the distinct exponential functions and
positive H imply E_beta[u | S=s,g]=0 in every stratum. Along a smooth parameter
direction that leaves this conditional distribution unchanged, differentiating
that identity gives a zero column/direction in the population moment Jacobian.
Thus a smooth, uniformly ability-centered moment construction cannot supply
a full-rank regular estimating equation in those directions. This argument
is local to generic slopes and the stated nuisance-uniform moment class. It
does not prove that every estimator under every restriction on the ability
distribution is impossible; equal/colliding weighted totals, distributional
assumptions and nonregular inference require separate arguments.

The **existing** sparse/unequal rosters expose another loss for Rater-owned
slopes. Rater 1 never crosses Criteria within a Person: its Criterion is fixed
within each roster. Conditional data identify the Criterion-location product
with Rater 2's slope, but cannot separate all the remaining scale components.
Writing slopes as exp(alpha), exp(-alpha), the transformation

    alpha' = alpha + t,
    CriterionLocation' = exp(t) * CriterionLocation,
    Step1' = exp(-t) * Step1,
    Step2' = exp(t) * Step2

preserves the conditional distribution for these Rater-owned rosters. The
Rater-owned location is already absent. For either ownership, if the other
facet's location contrast is zero, changing alpha and inversely rescaling
the two owner steps also preserves the conditional distribution.

The new repository-only
[check](jml-centering-identification-20260930.R) evaluates these claims in
the four saved owner/design conditions. It generates no observations and
fits no roots. Ability mixtures and count-pattern multiplicities are retained.
The zero-other-location case is a declared algebraic counterexample, not a
new sampling condition or an estimate from the saved data.

| Slope/step owner | Saved design | Conditional information rank, out of 5 | Rank with zero other-facet location |
| --- | --- | ---: | ---: |
| Criterion | Sparse | 4 | 3 |
| Criterion | Unequal | 4 | 3 |
| Rater | Sparse | 3 | 3 |
| Rater | Unequal | 3 | 3 |

Conditional probabilities agree with the independent response model at
abilities -4,-2,0,2,4; conditional score means and the explicit invariant
paths agree to at most 3.67e-15. Finite differences of conditional log
probabilities agree with the analytic scores within 1e-8. The full derivative
of the mean equation agrees with conditional score information to 6.05e-10.
The first check stopped because an anticipated rank of four also for Rater
ownership was false. The actual roster structure explains rank three; the
failed assertion and initial source are retained, and the final check tests
the explicit invariance rather than relaxing its numerical threshold.

### A precise growth condition, with its unproved premises exposed

The alternative keeps the existing full adjusted equation. Let every Person's
base cell exposures e_g be multiplied by an integer L, holding facet levels,
parameter dimension, roster proportions and ability distributions fixed.
The repeated responses must be conditionally independent. This is not an
argument for duplicating observations, treating dependent repeat ratings as
independent, or increasing facet levels and nuisance dimension with L.

For fixed beta at truth define U_k,L=(I-P_beta,L)^k U_0,L and
m_k,L(theta)=E_theta[U_k,L/L]. If K_L f(theta) is the expectation of
f(theta_hat(Y)) under that same conditional response model, the exact identity

    m_(k+1),L = (I-K_L) m_k,L

follows from iterated expectation. All-low/all-high responses keep the
implemented extended limits; they are not removed. A **sufficient conditional
argument**, not yet a theorem verified for this package, is as follows:

1. The normalized raw profile-score mean is O(L^-1) uniformly with the needed
   ability derivatives (through at least order 2k+2 on the relevant compact
   sets).
2. The plug-in expectation operator obeys a uniform weak-error bound
   `||(I-K_L)f||_(C^s) <= C/L * ||f||_(C^(s+2))` for the function class used
   at each step, with tail contributions negligible at the required order.
3. The normalized full mean-equation Jacobian stays nonsingular near truth;
   a nearby root exists and its linearization remainder is controlled.

Induction then gives m_k,L=O(L^(-k-1)) and local structural root displacement
O(L^(-k-1)). The operator bound, uniform derivative control and root remainder
are substantive outstanding premises. A scalar MLE variance of order 1/L
alone does not establish them. In particular theta_hat has infinite values
on extreme patterns; a naive assertion that its unconditional moments are
finite is invalid. Under bounded true abilities/parameters, category
probabilities bounded away from zero and independent repeated ratings, the
extreme-pattern probability decreases exponentially with L. Turning that
fact into the required uniform operator/tail bounds still needs proof.

A matching root-centered CLT and consistent full covariance are additionally
required. If, for each retained contrast, SE is of order (N L)^(-1/2), then
a sufficient growth restriction for the stated bias bound to be negligible
relative to its SE is

    sqrt(N L) * L^(-k-1) -> 0, equivalently N / L^(2k+1) -> 0.

For example the conditional sufficient restriction is N/L^5 -> 0 for fixed order 2,
and N/L^9 -> 0 for fixed order 4. These are consequences of the stated premises,
not validated rating-count cutoffs or a reason to select order 4. They are not
necessary when a leading bias coefficient vanishes; the actual requirement is
displacement/SE -> 0 for the contrast at issue. If a contrast
has a different information rate, use its actual covariance instead. Growing
the Person count alone at fixed exposure cannot satisfy this centering condition.

To check that this route does not already fail at the information premise,
the check constructs the full per-Person Fisher information at the generating
parameters, removes the Person coordinate by its Schur complement, and averages
over the **saved** roster-specific ability mixtures. Under independent
replication of each cell, this information grows exactly by L. All four saved
conditions have rank five, with minimum eigenvalues .22824--.29834 per base
exposure unit. Independent finite differences of complete-pattern log
probabilities agree with the joint information within 7.95e-11. This checks
the candidate design's information at the specified truth; it is not the
finite-exposure adjusted-root covariance, a CLT or evidence of global uniqueness.

### Additional correction candidate and its admission criteria

Once a leading displacement expansion has been justified for a fixed order,
an additional **design-preserving split correction** is implementable using
observed responses and the existing solver. Suppose its full-design root is
beta_L*=beta_0+C/L^r+D/L^(r+1)+o(L^(-r-1)), and two half designs have the
same coefficients and parameter interpretation. With a split specified
independently of responses, define

    beta_SP = [2^r beta_full - (beta_half1 + beta_half2)/2] / (2^r - 1).

The leading C term cancels; the next coefficient becomes
`-2^r D/(2^r-1)`. Coefficient equality is essential. Selecting a power r from
the observed best coverage, or rounding each cell count independently, is not
this procedure. In particular `r=k+1` depends on the unproved expansion above.
The source paper's split-panel theory concerns specified fixed-effect models;
it does not directly qualify the current corrected GPCM equation.

Each half must retain the same Persons, facet levels, identification, category
scale, roster proportions and normalized cell exposure; each fit must pass its
existing full equation/rank review. The observed-data influence is the same
linear combination of the three **aligned Person influences**. Its covariance
must retain their cross terms, e.g. `crossprod(IF_SP)/N^2` with the declared
roster centering. Adding three separate variances or reusing the full fit's
covariance is not a justified finite-sample implementation. A failed half-fit
means an unavailable corrected result; keep all input datasets in accounting.

The current rosters are 2:1:0:2, 0:2:2:1, 2:1:0:1 and 0:2:2:2. Only the last
can be divided into two identical integer cell rosters. **Neither whole saved
design passes this proposed exact-split prerequisite.** This does not rule out
every generalized jackknife, but it prevents applying this candidate to the
existing 400 JML datasets by a convenience split. No such refits were run.

The next bounded gate is to establish the operator/expansion bounds for a
fixed-dimension exposure family, then check the predicted displacement rate
and full covariance under that exact family before any new coverage study.
Any split implementation must first demonstrate source/Person/design alignment,
equal-half eligibility, paired influence agreement under perturbation, and
unchanged failure accounting. Independent coverage evaluation must address
all promised coordinates, availability and Monte Carlo precision; a lower
population bias by itself is insufficient. No automatic order, new public
interval, scope withdrawal or independent large study is introduced here.

Primary-source checks were focused: Dhaene and Weidner's
[Sections 3, 4 and 8.1](https://arxiv.org/html/2301.13736v2) distinguish
informative nuisance-free moments, a conjectured higher-order rate and the
MLE-plug-in operator. Dhaene and Jochmans'
[profile-score manuscript, method and identification discussion](https://jochmans.github.io/preprints/score%20adjustments/Dhaene-Jochmans%20adjscore.pdf)
separates small moment means from information. Their
[split-panel paper, Sections 2, 3 and 5](https://jochmans.github.io/publications/spj/spj.pdf)
requires compatible subpanel expansions and discusses remaining bias terms.
The GPCM factorization, rank/invariance calculation, conditional growth lemma
and admission decisions above are this review's derivations, not claims that
those papers prove this package's inference.

Evidence is in `validation-results/jml-centering-identification-20260930-final/`:
all eight conditional-rank cases, four growth-information cases, split
eligibility, inputs/source hashes, source snapshots and session. The initial
failed check and follow-up logs remain in the sibling unsuffixed directory;
the intermediate successful conditional check retains its own source. No
package estimator, acceptance threshold or covariance was changed. The
separate frozen 400-case adaptive-MML process continues unaffected.

## September 30: fixed-block expansion and an exact expectation check

**Bounded execution specification, before the all-case calculation.** Reuse
the four saved owner/design settings and both rosters in each. Multiply every
cell exposure by L=1,2,4,8,16, keeping the five coordinates and the saved
roster-specific ability values/proportions fixed. Evaluate exact owner-total
score means at the generating parameters for correction orders 0,1,2 and
all five coordinates. No responses are generated, no population/sample roots
are solved and no sampling covariance or interval is inferred from conditional
mean scores. Compare L*m_0 with the derived raw-score coefficient b_1 and
L^2*m_1 with the derived one-step coefficient -D_1 b_1; retain the scaled
order-2 mean L^3*m_2 without a fitted coefficient or selected rate. Include
all extreme-state probability mass and every planned roster/ability.

The maximum state space is 8,385; the existing blocked transition computation
is used with an explicit 10,000-state ceiling and no pruning. A largest-roster
L=8 pilot with 2,145 states took .67 seconds. Quadratic state-count scaling
suggests roughly 1--2 minutes for the 40 expectation cases on one process;
this is a planning estimate, not a hard bound. The pilot exposed only a
data-frame row-name warning, corrected before the final run. Its source,
result and warning log remain separate. The reference expectation helper
adds the already-computed total-specific ability profiles, with infinite
extended endpoints, to its return value; existing calculations are unchanged
and will be compared against its saved previous source at L=1.

### Fixed-block argument and the first bias coefficient

The useful question is whether an explicit correction order can make the
remaining structural bias negligible relative to sampling uncertainty when
each Person supplies more information. It is not whether a smaller equation
residual certifies an interval. The following argument is for a **fixed** finite
roster with conditionally independent responses, fixed structural dimension,
positive slopes bounded away from zero, and structural parameters and generating
abilities in compact sets. It does not cover increasing facet dimension,
arbitrary within-Person dependence, or unbounded ability distributions.

For one base block X of the specified roster, write its probability as

    p_beta,theta(X) = exp{theta T_beta(X) + H_beta(X) - psi_beta(theta)}.

Here `T_beta = sum_j a_owner(j) Y_j`, and H contains the location/step terms.
L independent copies of the block multiply each cell exposure by L. At fixed
beta, put `mu=psi_theta`, `I=psi_theta,theta > 0` and
`kappa_3=psi_theta,theta,theta`. For an interior observed mean total, the profile
ability is `theta_hat=mu^{-1}(T_bar)`. The all-minimum and all-maximum patterns
have extended profiles minus/plus infinity. They have positive probability at
every finite L: **do not take an ordinary finite expectation of theta_hat**.
The profile score and its corrections are zero at those absorbing patterns.

For smooth functions with controlled endpoint growth, the plug-in operator
`K_L f(theta)=E_theta[f(theta_hat)]` has the local expansion

    K_L f = f + D_1 f/L + O(L^-2),
    D_1 f = f''/(2 I) - kappa_3 f'/(2 I^2).

This follows by expanding `f(mu^{-1}(T_bar))`, using
`Var(T_bar)=I/L`, `(mu^{-1})'=1/I` and
`(mu^{-1})''=-kappa_3/I^3`. Two exact identities, including the extended
endpoints, are `K_L mu=mu` and `K_L mu^2=mu^2+I/L`. The numerical check below
uses these identities and independently checks the interior profile equation.
These witnesses check signs and normalization; they alone do not prove the
operator expansion for an arbitrary function.

The leading score coefficient must also account for **beta-dependent T**;
omitting that dependence would give the wrong slope calculation. With all
quantities below evaluated at the generating beta and theta, define the
block logit derivative `D=partial_beta(theta T_beta+H_beta)`,
`A=Cov(T,D)`, and `C=E[(T-mu)^2 (D-E D)]`. Let U_0 be the **negative** profile
score, in the same sign convention as the research implementation. Then

    m_0,L(theta) = E_theta[U_0/L] = b_1(theta)/L + O(L^-2),
    b_1 = C/(2 I) - A kappa_3/(2 I^2).

For completeness, write the normalized score as
`psi_beta(theta_hat)-theta_hat T_bar,beta-H_bar,beta` and expand around theta.
The first-order profile displacement has mean `-kappa_3/(2 L I^2)` and
second moment `1/(L I)` on the central event. The covariance term from
`theta_hat T_bar,beta` is `Cov(T,T_beta)/(L I)`. Using

    psi_beta,theta - E T_beta = A,
    partial_beta I = 2 Cov(T,T_beta) + C

cancels that last term and yields b_1. This expansion concerns the score,
whose endpoint values are defined; it does not assume that the untruncated
profile displacement itself has finite moments. The implementation checks
the second identity by finite differences of I, separately from the cumulant
calculation of b_1.

There is a concrete way to control the expansion remainder for this restricted
family. The empirical block category frequencies are averages of bounded,
finite-support independent vectors. On a fixed neighborhood of their generating
means, the profile score divided by L and the inverse mean map are smooth,
with uniformly bounded derivatives of every required **fixed** order. Taylor
expansion there expresses expectations in central moments of sample means;
these moments are polynomials in 1/L, with smooth cumulant coefficients.
A smooth cutoff inside a larger neighborhood makes the expansion global
without changing the central calculation. Concentration gives exponentially
small probabilities for its complement, uniformly over the specified compact
parameter/ability set.

Endpoint control is essential in that argument. Any finite observed mean total
is at least `a_min/L` from an extreme total. The inverse exponential-family
mean map therefore has magnitude O(log L) there, uniformly on compact beta
sets. The normalized raw score is at most O(1+log L), and the Markov operator
bound gives `||U_k/L||_infinity <= 2^k ||U_0/L||_infinity` for fixed k.
Exponential tail probabilities dominate these bounds. A fixed number of
theta derivatives of an L-block probability introduces at most polynomial
factors in L. Taking the Taylor expansion to a sufficiently higher finite
order controls these derivatives too. This supplies the locally smooth
mean expansions needed below; it is not a uniform-in-k argument or the
earlier proposed sharp bound using only two additional derivatives. Nested
compact neighborhoods handle any fixed number of operator compositions.

For the implemented recursion `U_k=(I-P_beta,L)^k U_0`, iterated expectation
gives exactly `m_k+1,L=(I-K_L)m_k,L`. Applying the smooth expansions to this
identity yields, for fixed k in the stated family,

    m_k,L = (-D_1)^k b_1 / L^(k+1) + O(L^(-k-2)).

In particular, the one-step coefficient is `-D_1 b_1`; it is evaluated below
using two theta finite-difference spacings and Richardson refinement. The
order-2 numerical results retain `L^3 m_2` without claiming that its coefficient
was independently evaluated. The recursion and fixed-block expansion explain
the power for score **means**. They do not by themselves locate a structural
root, prove that the solver selects it, or establish a sampling covariance.

### Complete numerical result and the targeted slow-convergence check

The 40 planned cases completed in **31.418 seconds** of summed elapsed case
time, retaining 1,800 coordinate/ability/order means. All checks passed:

- All original-exposure values from full response-pattern enumeration agree
  with the total-state computation to the required 1e-10 tolerance for all
  eight owner/design/roster combinations and orders 0,1,2.
- At L=1, every old return field is identical to the saved previous helper
  for all those cases and orders. Only `total_theta` is added.
- The maximum independently checked profile-mean error is 1.21e-12; the
  b_1 derivative/cumulant identity differs by at most 2.24e-11. The maximum
  change in the one-step coefficient between theta spacings .002 and .001
  is 6.46e-8, below the fixed 2e-6 threshold.
- No total states were intentionally omitted, no correction order was
  selected from these results, and no root/covariance/coverage was fitted.
  These are finite floating-point sums with unpruned state spaces, not
  symbolic exact arithmetic or a certified bound on floating-point error.

Maximum absolute errors against the leading coefficients, across all 120
coordinate/ability/roster values at each L, are:

| Exposure multiplier L | `abs(L m_0 - b_1)` | `abs(L^2 m_1 + D_1 b_1)` |
| --- | ---: | ---: |
| 1 | .097085 | .246842 |
| 2 | .083979 | .301773 |
| 4 | .067686 | .159041 |
| 8 | .030443 | .028552 |
| 16 | .013227 | .030379 |

Convergence is visibly **not monotone**. The largest remaining one-step error
at L=16 is Criterion ownership, unequal design, roster 1, ability 2, log slope.
Before extending that case, its reason and two additional multipliers (32,64)
were recorded in a separate runner. All three saved abilities, five coordinates
and orders 0,1,2 for that roster were retained; none of the original cases was
replaced. The explicit ceiling became 50,000 states, with 49,665 at L=64.
The prospective timing comment used 1.05 seconds for L=16; the saved matched
case actually took .877 seconds. The conservative 15/250-second projections
are retained as written. Actual L=32/64 times were **6.719/70.095 seconds**.

For the coordinate that triggered the extension, the predicted one-step
coefficient is .14691115:

| L | `L^2 m_1` | Absolute coefficient error | Probability of either extreme pattern |
| --- | ---: | ---: | ---: |
| 16 | .17728989 | .03037874 | 5.34e-6 |
| 32 | .15942983 | .01251869 | 2.85e-11 |
| 64 | .15269200 | .00578085 | 8.10e-22 |

Those are also the largest one-step errors among all 15 retained coordinates
and abilities of that roster at each of the additional multipliers. Thus the
slow case approaches the coefficient when exposure increases, while the first
grid alone would not justify assuming an already accurate asymptotic regime.
This roster has four ratings per base block, so L=32/64 means 128/256 ratings
per Person, **not** a validated practical minimum. Order-2 scaled means in the
same coordinate change sign across the grid; they do not establish a uniformly
better finite-exposure order. Retain all of them rather than selecting a
favorable range. No larger grid is needed to make the present decision.

### What this closes, and the remaining structural-interval gate

This closes the explicit leading score-mean calculation and its bounded
numerical falsification check for the fixed-block family. It strengthens the
exposure-growth argument beyond borrowing a conjectured power from another
model. A near-truth population root additionally needs a uniformly regular
**two-argument** mean equation (evaluation beta versus generating beta) and
a nonsingular local Jacobian. Under those conditions the implicit-function
expansion transfers the score power to root displacement. The saved rank-five
Schur information is evidence for the limiting Jacobian at the specified truth;
it is not a check of the complete finite-L adjusted-equation Jacobian.

With independent Persons, a root-centered CLT and a consistent full Person
covariance of order 1/(N L), the sufficient centering restriction remains
`N/L^(2k+1) -> 0`. It is conditional on that covariance rate and the root
argument, not a required lower bound on the number of ratings in practice.
The actual contrast-specific displacement/SE is the relevant quantity, and
a vanishing leading coefficient can weaken the sufficient rate. A compact
ability assumption used here must not silently become a guarantee for the
package's arbitrary Person populations.

The next decision is therefore the local structural root and **full response**
covariance in this same family: derive their matching expansion, reuse the
saved original-exposure roots/covariances, and check displacement/SE and the
entire Jacobian before planning independent sampling validation of a fixed
procedure. The conditional means used here discard within-total response
variation and must not be inserted as sandwich contributions. Solver branch,
all-coordinate availability and failure accounting remain part of that later
validation. Neither formal intervals, automatic order selection, a split
implementation nor a withdrawal of the promised structural target is delivered
by this score-mean result. D1 remains open.

The derivation above is specific to this review's finite exponential-family
representation. The previously linked primary papers motivate the iterative
operator and the distinction between centering and information; their results
are not relabelled as a GPCM theorem. No package estimator or public API was
changed. The helper and new runner are research-only code.

Evidence: `validation-results/jml-exposure-expansion-20260930-verified/`
contains all 40 cases, input/source hashes, source snapshots, `means.csv`,
completion checks and the R session. The initial pilot, warning log, old helper,
full-run log and prospective follow-up runner remain in the unsuffixed sibling
directory. The `-followup/` directory contains the two additional cases and
their own manifest/source snapshots. After the 40-case run, the runner's
hard-coded 10,000 ceiling was made an optional argument with the same default
for the targeted extension. Its separate source identity is retained; do not
attribute the original run to that later source or overwrite either manifest.

Final artifact reconciliation verified the snapshot hashes, every case's
declared source identity and all 1,890 saved means. The only working-source
change relative to the 40-case manifest is the documented ceiling argument;
the follow-up manifest matches its working sources. Both research R files
parse and `git diff --check` passes. An initial broad log scan mistakenly
matched the printed column name `LeadingError`; inspecting that match and
restricting the scan to R diagnostic prefixes found no warnings/errors in
the final all-case log. No statistical calculation or result was changed
in response. No full package suite was rerun for these research-only changes.

## October 1: local population roots and full response covariance

**Prospective bounded calculation.** The next question is whether the fixed-block
score-mean result transfers to structural-root displacement and matching
uncertainty in the same saved designs. Reuse the eight original-exposure
population roots for both owners, both designs and orders 1 and 2. First
reproduce the full generating mean, Jacobian and fixed-roster covariance,
including comparisons away from the generating parameter. Then evaluate
L=2,4,8,16 with the same two saved starts, solver fallbacks and numerical
review thresholds. Keep all five coordinates and all failures. No new sampled
responses, coverage study, automatic order selection or public interval is
part of this calculation. N=400 is a reference for the bias/SE comparison;
the Person count is not used to choose a correction order.

Full response covariance requires within-total variation as well as variation
of the conditional score mean. The new research calculation carries first
and second moments of four cell totals and four middle-category counts through
the generating probability convolution. These generating moments stay fixed
when the evaluation parameter changes. The existing plug-in correction and
ability profiles are still recomputed at the evaluation parameter. No
conditional mean is passed off as an observed response pattern.

The maximum total-state space remains 8,385 with a 10,000-state ceiling.
The original-exposure reconciliation is the first gate. An L=8 Criterion /
unequal / order-2 pilot will measure the full two-start/root/covariance cost
before all 32 new cases run. The earlier expectation costs suggest minutes
rather than hours, but do not measure repeated root evaluations; the actual
pilot cost will determine the all-case estimate. Use one R process while the
separate frozen 400-dataset MML replay continues.

**Cost decision after the pilot, before the remaining roots.** All eight
original-exposure reconciliations passed. The complete L=8 pilot took 28.269
seconds with both starts reviewed and agreeing. Quadratic total-state scaling
would put an L=16 case near 7 minutes and the eight such cases near one hour,
before allowing for different solver iterations. Stage the calculation at
L<=8 first: 32 cases in total, including the eight reused original roots and
the completed pilot, with roughly 5--8 minutes estimated for the remaining
cases on one process. The eight originally listed L=16 cases remain explicitly
unexecuted pending the lower-grid decision; they are not successes or deleted
failures. This limits cost while directly testing the root/covariance question.
The stage runner and its source hash are retained separately from the unchanged
mathematical runner/manifest used by the preflight and pilot.

### Transfer from a small mean score to a nearby structural root

Separate the evaluation parameter beta from the generating parameter beta_0.
The roster-specific generating ability distributions F_g and roster proportions
pi_g remain fixed during evaluation. For one block and true ability theta,
let t_beta(theta) solve

    mu_beta(t_beta(theta)) = E_beta0,theta[T_beta(X)].

In a neighborhood of beta_0 this solution is smooth and remains in a compact
interior set under the previous section's conditions. It equals theta at
beta_0. The population limit of the normalized negative profile score is

    v_g(beta,theta) = [partial_beta psi_beta(t)
                      - E_beta0,theta D_beta(X;t)] at t=t_beta(theta).

The structural partial derivative holds t fixed. At beta_0, v_g is zero.
Differentiating the profiling equation shows that
the derivative of v_g there is the Schur information

    J_g(theta) = I_beta,beta - I_beta,theta I_theta,theta^-1 I_theta,beta.

All four blocks in this matrix refer to the joint, generating **one-block**
likelihood. The fixed design averages to
`J = sum_g pi_g integral J_g(theta) dF_g(theta)`. J must be positive definite;
the prior independent information calculation verifies this at each of the
four retained generating settings. Positive definiteness at these points is
not global identification of arbitrary sparse designs.

The same central-event Taylor argument used above applies smoothly in both
evaluation and generating parameters. The plug-in adjustment is O(1) before
normalization, together with its local evaluation-beta derivatives, for each
fixed correction order. Consequently the complete normalized mean equation

    G_k,L(beta) = sum_g pi_g E_beta0,Fg[U_k,L(Y;beta)/L]

converges locally, with its first derivative, to the averaged v_g. In
particular `G'_k,L(beta_0)=J+O(L^-1)`. At the generating beta, the preceding
score expansion gives

    G_k,L(beta_0) = c_bar_k/L^(k+1) + O(L^(-k-2)),
    c_bar_k = sum_g pi_g integral (-D_1,g)^k b_1,g(theta) dF_g(theta).

A nonsingular J and local smooth convergence give a unique root in a
sufficiently small neighborhood for all sufficiently large L, with

    beta*_k,L - beta_0 = -J^-1 c_bar_k/L^(k+1) + O(L^(-k-2)).

This is a **local** result in the fixed-block family. It does not say that
there are no distant roots, that a finite-L numerical solver reaches this
branch, or that a given number of ratings is sufficiently large. The two
declared starts and the complete nonsymmetric finite-L Jacobian are therefore
retained in the numerical check. The k=1 leading displacement vector is
computed independently from the previously derived `-D_1 b_1` and the saved J;
k=2 retains its scaled displacement without a separately evaluated coefficient.

### Matching covariance and the centering condition

At beta_0, the leading random part of a Person's adjusted score is the sum
over its L blocks of the efficient negative score

    xi_g(X,theta) = -(D_beta - E D_beta)
                    + I_beta,theta I_theta,theta^-1 (T - mu).

Its conditional mean is zero and its conditional covariance is J_g(theta).
The profile Taylor remainder and each fixed-order correction have bounded
second moments of order O(1) in the compact family. At the nearby population
root, the additional shift also has this order or smaller. Thus for the
unnormalized complete equation and fixed roster counts,

    A_L/L -> J,     B_L/L -> J,
    V_L = A_L^-1 B_L A_L^-T / N,
    N L V_L -> J^-1.

Here `B_L=sum_g pi_g Var_beta0,Fg(U_k,L | roster g)` includes both response
and ability-mixture variation. Fixed roster counts exclude only variation in
the proportions of the rosters. The equation's A_L is its full derivative,
not a symmetrized approximation or a Hessian of a convenient likelihood.
The population sandwich V_L is a root-centered asymptotic covariance; it is
not an exact finite-N sampling variance.

For independent Persons, fixed positive roster proportions with every roster
count tending to infinity, and a consistent local root, bounded higher moments
in this family give the triangular-array root-centered CLT and consistency of
the matching empirical Person sandwich. Both N and L must grow. Combining
this with the local root expansion gives the sufficient truth-centering
condition `N/L^(2k+1) -> 0` when a leading bias coefficient is nonzero.
For any named contrast, its actual displacement relative to its standard
error is the quantity to check; a vanishing leading coefficient can relax
that sufficient restriction. None of these arguments covers unspecified
dependence, growing facet dimension or arbitrary unbounded ability laws.

The finite-L covariance calculation implements the law of total variance,
with S the vector of owner totals:

    Var(U | g) = Var(E[U | S,g] | g) + E[Var(U | S,g) | g].

At evaluation beta, the plug-in correction is a function of S. The raw
negative profile score is affine in the eight cell-total/middle-count
statistics Z. Its log-slope coefficient also contains theta_hat times an
owner-total contrast; that term is constant conditional on S. Therefore
the within-S covariance is `D_0(beta)' Cov(Z | S,g) D_0(beta)`, where D_0
is the block-logit derivative's coefficient at ability zero. The generating
conditional covariance and means of Z are computed at beta_0. The conditional
mean at evaluation beta must likewise use those generating means, rather
than substitute the model's means at beta. This distinction is required for
the correct finite-L Jacobian and root as well as the meat.

The new implementation checks its count-moment law of total covariance
against direct multinomial moments at each exposure, including the saved
ability mixtures. At L=1 it also compares the full score mean and meat with
independent response-pattern enumeration at truth, the opposing parameter
vector and the saved root, then compares the entire Jacobian and saved
covariance. These checks target the two errors that would otherwise make a
mean-only extension misleading: differentiating the generating distribution
along with the evaluation parameter, and dropping within-total variation.

### Results and the next inference decision

All **32 cases through L=8** are complete: eight original-exposure roots
reused and reconciled, and 24 new two-start fits. Both starts passed the
unchanged equation/Jacobian/rank review and agreed in every case. Summed case
time was **300.186 seconds**, of which 297.893 seconds was for new roots.
Maximum start spread was 1.94e-10, maximum equation residual 9.46e-11 and
maximum Jacobian refinement discrepancy 3.54e-9. The independent original-
exposure mean/meat/Jacobian/covariance checks and direct count-moment checks
all passed; their maximum reported discrepancy was 1.86e-12. This is a
numerical root/covariance calculation, not 32 sampled datasets.

For N=400, the largest absolute structural displacement divided by the
matching full population-sandwich SE across all four settings and five
coordinates is:

| Exposure multiplier L | Order 1 | Order 2 |
| --- | ---: | ---: |
| 1 | .624882 | .185752 |
| 2 | .285345 | .097449 |
| 4 | .115859 | .052335 |
| 8 | .044887 | .012843 |

The all-coordinate table retains each signed displacement, root, SE and
scaled displacement, not just these maxima. The largest order-2 ratio at
L=8 is Criterion / unequal / log slope: displacement -.000239832 and
SE .01867358. Each saved roster originally contains four to six ratings,
so L=8 represents 32--48 ratings per Person. N=400 is a reference population
calculation, not evidence that a fitted sample sandwich is calibrated there.

A coordinate-only maximum can miss a less favorable linear combination.
The full-covariance diagnostic `sqrt(displacement' V^-1 displacement)` is
the maximum standardized displacement over all nonzero linear contrasts
within a case. Its maxima over the four cases are .835652/.306617/.139226/
.056199 for order 1 and .232856/.117212/.060271/.014702 for order 2, ordered
by L=1,2,4,8. This uses the known generating parameter **only for validation**;
it is not an observed-data selection rule or a proposed bias correction.

The independently predicted order-1 leading root vector is also approached:
the maximum absolute difference between `L^2 (beta*_1,L-beta_0)` and its
predicted coefficient falls from .084565 at L=1 to .047691/.016506/.010489
at L=2/4/8. The leading approximation still has finite-L error. Order 2's
scaled displacements are retained without fitting a power or selecting an
order from the results. The lower order-2 population ratios in these cases
do not override the previously retained sample-MSE tradeoff between orders
2 and 4.

For covariance, comparing individual diagonal entries is likewise insufficient.
The extreme eigenvalues of `J^(1/2) (N L V_L) J^(1/2)` give the variance ratio
to the limiting `J^-1/(N L)` over **all** linear contrasts. The smallest and
largest such ratios across the four settings are:

| L | Order-1 variance ratio range | Order-2 variance ratio range |
| --- | ---: | ---: |
| 1 | .966951--3.379910 | .971084--2.769584 |
| 2 | .978663--1.655046 | .991748--1.682710 |
| 4 | .993128--1.298874 | .999004--1.320351 |
| 8 | .998440--1.147679 | .999923--1.154585 |

The full covariance tends toward the information limit, but even at L=8 a
contrast can have about 15% more variance than that limit. Keep the complete
finite-L sandwich rather than replacing it with the limiting inverse
information. Dropping within-total variation is more damaging: across all
coordinates/orders/settings, the minimum resulting SE/full-SE ratio is
.421613/.330691/.287942/.268391 at L=1/2/4/8. These are deliberately incomplete
research calculations used to demonstrate the loss; the package's existing
Person sandwich already uses actual response contributions. This result is
not evidence of a new defect in that public implementation.

**Decision.** The local-root and matching-covariance argument is now concrete
for the declared fixed-block family, with the finite-L numerical bridge
checked through L=8. The eight L=16 cases remain unexecuted and recorded in
`stage-plan.rds` and `stage-completion.rds`. Solving them merely to improve
the population approximation is not required for the next decision: it
would not test the sample sandwich, branch selection on observed samples,
or actual truth coverage. No further exposure-root grid is launched here.

The next inference gate is to freeze a complete **observed-data** procedure,
reconcile its equation/Jacobian/Person covariance with this population
reference, and evaluate its availability, bias, covariance estimation and
all-coordinate truth coverage under independent sampling. Use the existing
explicit order rather than inventing an order selector, retain numerical
failures and all denominators, and state which rating/Person growth and ability
conditions are being evaluated. Record a measured cost and required Monte
Carlo precision before launching that study. Existing original-exposure
sample evidence remains relevant and adverse findings cannot be overwritten
by these more favorable population calculations. The October 2 decision
checkpoint remains in force; general-input scope and the agreed formal
structural-interval target remain open.

No public estimator, SE, interval or API was changed by this work. The new
`jml-exposure-roots-20261001.R` is a research reference, not a public inference
implementation. Evidence is in `validation-results/jml-exposure-roots-20261001/`:
the original manifest/source snapshots, all 32 case records, separate stage
plan/runner/log, 160 coordinate rows, full contrast-variance and contrast-bias
summaries, reconciliation source/results, and retained preflight/pilot logs.
Hashes verify each primary result against the unchanged mathematical source
and inputs; the staged orchestration has its own hash. The calculations use
unpruned floating-point sums, not certified arbitrary-precision arithmetic.
Final verification also checks the reconciliation source/result hashes, parses
the new research source and passes `git diff --check`; all four retained logs
have no R warning/error diagnostics. No full package suite was rerun because
this turn changes only research code and its decision records.

## October 1: observed-data procedure and independent evaluation protocol

The next decision is whether a fully specified observed-data interval candidate
has acceptable finite-sample behavior, rather than whether another population
root can be computed. The public corrected-JML route already supplies the
complete Person sandwich but does not expose structural confidence intervals.
Its default starts and handling of unresolved starts differ from the older
research solver, so old sampling results are not automatically evidence for
the complete present procedure.

### Procedure fixed before the cost pilot

Use `fit_mfrm()` with GPCM/JML, the declared shared step/slope owner,
`jml_correction_order=2`, `jml_correction_sampling="fixed_rosters"`,
`maxit=400`, a preserved declared category scale, observed unit-weight ratings,
and the public default neutral/perturbed starts. Keep the public three-stage
solver policy and all point/covariance checks unchanged. There is no
truth-based start, order search, covariance-driven refit, relaxed tolerance,
or added retry. Retain all returned points and their statuses.

For **this research candidate**, interval eligibility additionally requires
`point$status="consistent_roots"` and an available full Person covariance.
A point returned with unresolved starts remains a point result but supplies
no candidate interval. Each coordinate also needs a positive finite SE and
finite transformed bounds. Form 95% normal intervals on centered locations,
centered steps and log slopes; exponentiate log-slope endpoints for reported
positive slopes. The free-coordinate covariance is transformed with the full
sum-zero linear map, including off-diagonal terms. Evaluate every expanded
location, step and slope, including dependent final levels/steps, not only
the free coordinates. These are pointwise intervals, not simultaneous
intervals or Person-ability intervals. No public API eligibility is changed.

Freeze the whole package R source, compiled-binary identity, reference code,
inputs and this protocol. Reconstruct the first retained sample of each of
the two original order-study designs and compare the public result with the
saved order-2 root/covariance. Independently compare actual Person equations
at the fitted and opposing parameters, the full Jacobian, meat and influence
covariance with the research total-state calculation. Then run a separately
seeded cost pilot with one paired dataset for each design below, rechecking
the two prototype equations/covariances at increased exposure. All pilot data,
failures, warnings and source identities are retained; pilot outcomes will
not enter the independent study's coverage summaries.

### Questions, conditions and precision fixed before sampling

Hold N=400 independent Persons and the saved assignment proportions fixed.
Compare L=1 with L=4, using the same Persons' generated abilities and the
first base block of ratings within the four-block arm. Different replications
are independent; L arms within a replication are paired. This tests whether
the exposure increase that reduced population displacement also improves
the complete observed-data inference, including sample covariance estimation.

1. **Criterion-owned unequal design:** retain the four-/six-rating rosters,
   proportions .6/.4, five structural coordinates and the different saved
   three-point ability mixtures. This preserves informative assignment and
   the slow leading-coefficient case.
2. **Rater-owned sparse design:** retain both five-rating rosters, proportions
   .5/.5, the other owner convention and the saved different ability mixtures.
   This preserves the earlier correction-order MSE counterexample.
3. **Existing non-prototype design:** reuse the three-rater, two-criterion,
   four-category model and six-rating rosters from the general-input witness,
   with Criterion ownership, eight free coordinates and independent N(0,1)
   abilities in both rosters. This tests actual category/level generalization;
   its unbounded ability law is empirical evidence outside the compact-family
   proof, not an automatic extension of that proof.

No factorial expansion of unrelated designs is proposed. L=4 means 16--24
ratings per Person in these conditions. The largest state space is 1,225,
within the unchanged public 5,000-state ceiling. The pilot seeds are
100190001--100190003. If the bridge and measured cost permit execution,
the independent study uses **500 replications per design**, paired L=1/4
arms, for 1,500 new datasets with 3,000 public fits. Its separate seed formula
is `100100000 + 10000 * design_index + replicate`. Store each input before
fitting and each attempted arm atomically; failures count as attempted arms
and are not replaced. The study must not stop early after favorable coverage.

At full availability, a 95% coverage estimate based on 500 replications has
MCSE about .00975 (about .01 with 475 available intervals). This precision is
suited to the same **limited** practical margins used in the MML protocol:
for each coordinate/condition require availability >=.95 with exact 95%
binomial lower bound >=.90, and the exact 95% conditional-coverage Monte Carlo
interval entirely inside [.92,.98]. These are evaluation margins, not a
theorem or universal practical thresholds. Failure or an inconclusive result
leaves that claim unsupported; do not change margins or add replicates
automatically. Monte Carlo bounds are pointwise across the correlated,
constrained coordinates.

Report every coordinate's point/interval availability, failure stage, signed
bias/RMSE, empirical SD, root mean estimated variance, width, tail misses,
conditional truth coverage and delivery-with-truth-inclusion over all 500
attempts. Give exact binomial Monte Carlo bounds for availability, conditional
coverage and delivery. Compare L arms by replication, keeping failures in
paired availability/delivery differences and using common available pairs
only where a paired width/error calculation requires them. All expanded
coordinates and both exposure arms remain in the report even if one fails.
Existing original-exposure adverse findings remain visible; this study does
not establish general sparse-design, dependence, unbounded-population or
automatic-order guarantees.

The initial execution is only the two saved-data bridges and six pilot fits.
Retained root timings suggest seconds to minutes per pilot arm but do not
measure this public path. Measure its preparation/fit/verification cost, then
forecast the full independent study before launch. Use one study process
alongside the existing MML replay. If the interpretable result is projected
after October 2 at 18:00 JST, apply the existing user-consultation rule first.

### Bridge result, measured cost and launch decision

Both retained datasets reproduce the older order-2 root with maximum
coordinate difference 1.40e-10 and covariance-entry difference 5.15e-11.
Comparisons of the actual Person scores, complete Jacobian and sandwich
against the separate research implementation pass, including the opposing
parameter and increased-exposure pilot datasets; the largest recorded
relative covariance discrepancy is 4.07e-11. The pilot's expanded constrained
estimates and SEs also reproduce public tables for all 10/10/13 location,
step and slope coordinates in the three designs. This checks the complete
source-identified implementation; it does not transfer the old study's
failure rate to the new public solver policy.

All six pilot fits returned consistent roots and available covariances:

| Design | L=1 public fit seconds | L=4 public fit seconds |
| --- | ---: | ---: |
| Criterion / unequal | .964 | 6.393 |
| Rater / sparse | .994 | 7.324 |
| Three raters / four categories | 2.505 | 32.820 |

These are one dataset per arm, **not coverage or availability estimates**.
Total fit time is 51.000 seconds; multiplying by 500 gives **7.083 hours**
for 3,000 fits on one process at those times. Reproducing the saved pilot
inputs takes .026/.006/.007 seconds per design and verifies exact rating
counts and paired L=1 prefixes within L=4. Generation is small relative to
fitting. A planning range of **8--22 hours** allows preparation/reporting,
solver retries and approximately threefold variation from the pilot fit
projection; it is not a guaranteed upper bound. At the October 1 early-morning
launch this is before the October 2 18:00 JST decision checkpoint. Actual
times and failures remain recorded for revising that projection.

The independent runner will use the pilot's immutable package snapshot and
its own frozen orchestration/protocol/manifest. It runs serially alongside
the existing MML matched replay, saves generated inputs before any fit,
saves each arm atomically and resumes only matching-source records. It
builds coverage summaries only after all 3,000 attempts exist. In-process
numerical failures remain unavailable outcomes. An unexpected failure of
the validation code is saved and stops execution for investigation; it is
not silently classified as statistical noncoverage or bypassed on resume.

Before launch, a synthetic summary fixture verifies the distinction between
2/3 interval availability, 1/2 conditional inclusion and 1/3 delivery, plus
paired inclusion differences and all-unavailable cases. Separate checks
confirm that unresolved starts and unavailable covariance block only the
candidate intervals, and a failed fit retains all expected coordinate rows.
The pilot data never enter the study denominator. These checks introduce no
new fitted samples or public confidence-interval support.

The complete summary reader was also exercised on copies of the six pilot
records: it produced all 66 coordinate/condition summaries and 33 paired
summaries, with the pilot-only count of one per arm and no precision-margin
qualification. This is a file/denominator check, not a six-dataset coverage
study. The fixture is separate from the independent study directory's fits.

**Launched October 1 at 00:44:37 JST**, one process, PID 59186. The frozen
runner is `validation-results/jml-independent-inference-20261001/runner.R`;
its manifest references the immutable package snapshot in
`validation-results/jml-observed-inference-20261001/source/`. The launch
record, lock ownership, generated inputs and first completed arm records
confirm execution. Estimates and candidate intervals remain research results.
All independent attempts are pending final coverage review; early successful
fits are not a coverage conclusion. `summary.rds` and the full CSV summaries
are created automatically only when all 3,000 attempts have been saved.
The separate 400-dataset adaptive-MML matched replay is still running; no
independent MML coverage study has been launched by this JML action.

**Paused October 1 at 01:00:49 JST after priority review.** The additional
study was interrupted by SIGINT; PID 59186 exited and `RUNNING` was removed.
All 113 saved fit records and 57 generated inputs remain readable with
matching manifest/input hashes and seeds. Frozen runner/protocol hashes also
match. No temporary files or final summaries remain. The interrupted
`fit-3-019-L4.rds` has no saved fit record; its input is retained for a possible
same-procedure restart. It is not classified as a numerical failure.

This scheduling decision was not based on interim coverage. No partial
coverage analysis or qualification is made. `pause.json` preserves the
interruption and restart policy. Do not restart automatically or expand the
study: first specify which public inference/scope decision the remaining
calculation would resolve and reassess its priority against unfinished public
consumers. Formal corrected-JML structural inference remains open. The
separate 400-dataset MML matched replay remains running.
