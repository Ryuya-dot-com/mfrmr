# GPCM MML Person-marginal slope-path contract for mfrmr 0.2.3

Status: Draft.72 corrective mathematical contract and analytic-oracle
prototype; no half-line certificate, production propagation, finite-MLE claim,
confirmation, or release use yet

## Why Draft.69 is insufficient

Draft.71 showed that the individual-response all-node condition can certify a
q=5 direction yet become silent at q=31/61/91 even when direct path values
continue to rise. The condition forces every conditional-node derivative to
have the desired sign before posterior averaging. It is sufficient, but it
discards the defining marginal-likelihood mechanism: conditionally adverse
nodes can lose posterior mass along the path.

This contract moves the proof target from individual responses to the exact
finite-q Person marginal. It first requires an analytic value/derivative/
curvature oracle. A later version may turn that oracle into a certified
half-line procedure, but sampled derivatives or a selected path grid are not a
certificate.

## Exact finite-q derivatives

For effective observation (i), node (q), observed category (y_i), and
fixed unscaled cumulative utilities (u_{iqk}), let its owner slope follow

\[
s_i(t)=a_{g(i)}\exp\{r_{g(i)}t\},\qquad r_g\in\{-1,0,1\}.
\]

For the current ordered pair, one expanded owner level has (r=1), one has
(r=-1), and all other levels have zero loading. With row weight (v_i),

\[
d_{iq}(t)=v_i r_i s_i(t)
\{u_{iqy_i}-\mu_{iq}(t)\},
\]

where (mu_{iq}(t)) and (V_{iq}(t)) are the category-utility mean and
variance under the current softmax. Its derivative is

\[
d'_{iq}(t)=v_i r_i^2
\left[s_i(t)\{u_{iqy_i}-\mu_{iq}(t)\}
-s_i(t)^2V_{iq}(t)\right].
\]

Summing within Person and node gives (D_{pq}=\sum_{i\in p}d_{iq}) and
(D'_{pq}=\sum_{i\in p}d'_{iq}). If

\[
\pi_{pq}(t)=
\frac{w_{pq}\exp\{\ell_{pq}(t)\}}
{\sum_h w_{ph}\exp\{\ell_{ph}(t)\}},
\]

then the exact implemented finite-q objective (F(t)=\sum_p\log L_p(t))
satisfies

\[
F'(t)=\sum_p\sum_q\pi_{pq}(t)D_{pq}(t),
\]

and

\[
F''(t)=\sum_p\left[
\sum_q\pi_{pq}(t)D'_{pq}(t)
+\operatorname{Var}_{\pi_p(t)}\{D_{pq}(t)\}
\right].
\]

The prototype must reconstruct (F) independently from observation
log-probabilities, agree with the optimizer likelihood at (t=0), and match
central finite differences for (F') and (F'') over signed directions,
owners, q values, and nonzero t. It must retain negative conditional-node and
negative Person-marginal derivative counts rather than silently average them
away.

## Boundary limit and tail sign

For a positive-loading level, call node q compatible for Person p only if all
of that Person's positive-loading effective responses attain their category-
utility maximum at q. Positive-incompatible node likelihoods vanish as
(t\to\infty). A finite nonzero Person boundary marginal requires at least one
positive-weight compatible node for every retained Person. At compatible
nodes, positive-level probabilities converge to the reciprocal of the number
of maximizing ties; negative-level probabilities converge to the uniform
category probability; zero-loading probabilities remain fitted.

This produces an exact finite-q boundary likelihood without requiring every
node to be compatible. The boundary posterior is normalized only over
surviving compatible nodes. When positive-compatible utility gaps are strict,
their derivative corrections vanish faster than any multiple of
(\exp(-t)). The first negative-slope tail coefficient is then

\[
A=\sum_p\sum_{q\in Q_p^*}\pi_{pq}^{\infty}
\sum_{i\in p:r_i=-1}v_i a_{g(i)}
\{\bar u_{iq}-u_{iqy_i}\},
\]

where (ar u_{iq}) is the unweighted category-utility mean and
(Q_p^*) is the surviving node set. If (A>0) with a certified remainder
bound, (F'(t)>0) eventually; if (A<0) with such a bound, the direction is
eventually decreasing and cannot be a nondecreasing recession ray. (A=0) is
inconclusive and requires higher-order terms. Merely computing A in floating
point is not yet a tail certificate.

## Compact interval requirement

A complete half-line result must join the tail proof to a certified result on
([0,T]). The analytic curvature supplies a possible conservative route. For
utility range (R_{iq}) and a local upper slope bound (s_i^*),

\[
|d_{iq}|\le v_i s_i^*R_{iq},\qquad
|d'_{iq}|\le v_i\{s_i^*R_{iq}+(s_i^*)^2R_{iq}^2/4\}.
\]

These yield a valid but potentially loose bound on (|F''|), allowing a
derivative mesh only when every interval's signed margin exceeds the complete
curvature and numerical-error allowance. Adaptive subdivision must be driven
by a frozen deterministic rule and end in one of `certified`,
`counterexample`, or typed `not_evaluated` states. A sampled nonnegative grid,
an optimizer trace, or agreement to ordinary double precision is exploratory
evidence only.

Production certification requires outward-rounded interval arithmetic or an
equivalent documented error bound for softmax, posterior normalization,
derivatives, boundary likelihood, tail coefficient, and interval joins.
Overflow, underflow, tie ambiguity, zero boundary marginal, insufficient tail
margin, subdivision budget exhaustion, and invalid coordinates must fail
closed.

## Draft.72 prototype and non-claims

The Draft.72 prototype is limited to exact-formula verification and exploratory
path diagnosis. It may show that adverse conditional nodes coexist with a
positive Person-marginal derivative on selected points; it may not label the
complete half-line certified. It has no effect on stored fit objects, slope
status, primary estimates, uncertainty, fit, DFF, comparison eligibility, or
readiness.

Before production consideration, the next challenge must include:

- q=5/31/61/91 forward and reverse controls for both owners;
- adverse outer-node cases whose full Person marginal is independently proven
  monotone;
- a genuine derivative-sign counterexample;
- tie, zero-weight, `1e-8` weight, row-order, category-count, and limit cases;
- analytic-versus-finite-difference value, first-derivative, and curvature
  checks; and
- complete half-line, tail, interval-budget, and floating-error failure states.

Continuous-normal integration, paths with moving additive/population
coordinates, statistical operating characteristics, recovery/coverage,
sample-size rules, fit, DFF, candidate freeze, and confirmation remain separate
contracts.
