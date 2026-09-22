# Draft.83d2b2b1g3 glmmTMB numerical adjudication contract

Status: prospective repository-only no-refit adjudication of the exact b1g2
covering-smoke ledger, 2026-08-10. Full-manifest execution, calibration,
threshold selection, inference, and D-study decisions remain unauthorized.

## Source and implementation basis

The contract distinguishes backend return, optimizer termination, raw
objective computability, reported log likelihood, gradient availability,
curvature, and nested-model ordering. This follows the current
[glmmTMB troubleshooting guidance](https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html),
which treats small gradients, positive-definite curvature, restarts, and
alternative optimizers as separate checks and generally excludes models with
non-positive-definite Hessians from further consideration. The current
[`diagnose()` reference](https://glmmtmb.github.io/glmmTMB/reference/diagnose.html)
labels the helper experimental and exposes heuristic eigenvalue/eigenvector
and coefficient cutoffs; those defaults are not adopted as mfrmr release
thresholds. R's current [`optim()` documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/optim.html)
defines code zero as successful completion, but that code alone does not prove
stationarity, positive curvature, or a global optimum.

Installed glmmTMB 1.1.14 `logLik.glmmTMB()` returns
`-fit$fit$objective` only when `sdr$pdHess` is true and otherwise returns
`NA`. The installed function body/formals hash is
`c3f49676ea6fd8b6e2f4f70e775fd62387b808fd6a93388e17b280c45c4efbfd`;
the corresponding upstream source is
[`R/methods.R`](https://github.com/glmmTMB/glmmTMB/blob/master/glmmTMB/R/methods.R).
Consequently, a finite raw objective and an `NA` reported log likelihood are
not the same failure and must not share one state.

## Mathematical nested-model boundary

The full target-variance model uses a finite log-standard-deviation coordinate,
so its fitted variance is strictly positive. The reduced model fixes that
variance at zero. The reduced parameter point is therefore in the closure of
the full variance parameter space, not at any finite full-model coordinate.
For the likelihood extended to the closed space, nesting implies

\[
  \sup_{\sigma \geq 0}\ell_F(\sigma,\eta)
  \geq \max_{\eta}\ell_R(0,\eta).
\]

A finite full-model optimizer trace can nevertheless lie below the reduced
maximum while approaching the boundary. A negative finite trace difference
therefore establishes neither a valid likelihood-ratio statistic nor, by
itself, an optimizer defect. It records non-attainment or insufficient
observed maximization relative to the closed nested comparison. ML and REML
remain separate strata; REML comparisons here retain identical fixed-effects
structures and observation rows.

The inherited `1e-6` negative-difference value is retained only to reproduce
the previously frozen descriptive `small_negative` versus
`material_negative` partition. It is not a stationarity tolerance, practical-
equivalence rule, inferential cutoff, or pass criterion.

## Independent pair axes

Every one of the exact 120 b1g2 rows receives all of the following axes with no
precedence rule:

1. full/reduced return and same-row/one-df structural identity;
2. optimizer termination-code state;
3. raw objective finiteness;
4. reported log-likelihood availability and whether nonavailability is exactly
   explained by the installed `pdHess` mask;
5. exact `reported logLik == -objective` identity wherever reported;
6. sdreport/Richardson curvature agreement and full/reduced PD state;
7. outer/sdreport gradient availability and hash agreement;
8. unscaled observed gradient magnitudes, with stationarity explicitly
   `not_calibrated`; and
9. objective-based signed nested trace difference and its descriptive sign
   partition.

No aggregate pass is formed. In particular, an earlier higher-precedence state
cannot hide a nonzero optimizer code, a curvature failure, or a gradient-
surface disagreement.

## Six-profile observed envelopes

For each of the 20 base routes, the adjudicator independently selects the
smallest observed full and reduced objective among all six frozen profiles.
Ties use frozen profile order. It also constructs the corresponding envelope
using only fits for which sdreport and Richardson both report PD curvature.
Source profiles, same-profile status, all objective hashes, and signed envelope
differences are retained.

These are `best_observed_six_profile` envelopes. They do not establish global
maxima, do not choose an optimizer, and cannot be used as likelihood-ratio
statistics or calibration evidence.

## Prohibitions and successor requirement

The adjudicator reads stored scalar/hash ledgers only. It must not access fit
objects, regenerate data, refit, reconstruct raw gradients, select a gradient
scale or threshold, change the inherited negative-difference partition, or
promote a profile.

Before full execution can be reconsidered, a successor contract must
prospectively define scale-aware stationarity observables from retained raw
gradient and parameter vectors, establish their cross-optimizer behavior, and
state how a necessary PD-curvature condition interacts with boundary targets.
It must also keep raw-objective evidence separate from package-masked reported
likelihood and from any later boundary-bootstrap inference.
