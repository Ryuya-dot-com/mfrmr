# Draft.83c2 matched glmmTMB/lme4 G-theory parity contract

Status: repository-only matched-backend point-estimation contract, 2026-08-09.

Draft.83c2 adds a separately identified glmmTMB route after Draft.83c1. It does
not treat two mixed-model backends as interchangeable in general. Comparison is
allowed only for an exact univariate Gaussian random-intercept overlap with the
same typed design, Draft.83a retained rows, covariance derivatives, fixed
intercept, ML/REML criterion, and semantic variance components.

## Exact overlap

The comparison model is

\[
 y=X\beta+\sum_c Z_cu_c+e,
 \quad u_c\sim N(0,\sigma_c^2I),
 \quad e\sim N(0,\sigma_e^2I),
\]

with:

- identity-link Gaussian response;
- intercept-only fixed effects;
- mutually independent scalar random-intercept blocks;
- homogeneous residual dispersion `~1`;
- no zero-inflation (`~0`);
- the same typed canonical grouping formula;
- the same ML or REML criterion; and
- exactly the Draft.83a retained and sorted rows.

Structured covariance, random slopes, correlated blocks, heterogeneous
dispersion, zero inflation, non-Gaussian families, penalization, priors, and
different missing-data treatment are outside the overlap. A fit outside this
contract cannot be labelled a failed or successful parity comparison.

The local glmmTMB 1.1.14 help states that Gaussian `REML=TRUE` behavior matches
`lme4::lmer`. It also documents `dispformula=~1` as the standard dispersion
model, `ziformula=~0` as no zero inflation, and `sigma()` as the Gaussian
residual standard deviation. Draft.83c2 verifies that narrow documented
overlap; it does not extrapolate it to other glmmTMB families or structures.

## glmmTMB component extraction

Every conditional `VarCorr.glmmTMB` block must be scalar. Backend grouping
labels are split and returned to the Draft.81 declared order, so a backend label
such as `Rater:Site` maps to semantic `Site:Rater`. The residual component is
`sigma(fit)^2`. The resulting named vector must match every typed component
exactly and cannot contain duplicate or extra identities.

The fitted variance vector is evaluated by the same Draft.83c1 covariance and
ML/REML expected-information functions. This binds backend extraction to the
same mathematical component map rather than comparing printed summaries.

## Backend-specific diagnostics

Draft.83c2 records:

- optimizer convergence code, message, and objective;
- `sdr$pdHess`;
- maximum available fixed-parameter gradient;
- an approximate minimum fixed-parameter Hessian eigenvalue derived from
  `cov.fixed` when available;
- warnings and messages;
- component values at an explicit backend boundary tolerance; and
- the selected ML/REML expected-information rank and regularity state.

`pdHess=TRUE` and an optimizer code of zero are not singularity tests. glmmTMB
optimizes random-effect standard deviations on a log scale and may approach,
but not numerically equal, zero. Draft.83c2 therefore declares and hashes a
backend boundary tolerance, defaulting to `1e-8` in this prototype. A component
at or below that tolerance is `near_zero_at_declared_backend_tolerance`, even
when `pdHess=TRUE`.

The glmmTMB point-estimation gate requires all of:

1. Draft.83a incidence pass;
2. full Draft.83c1 covariance-design rank;
3. full expected-information rank for the selected ML/REML criterion;
4. every fitted variance above the declared boundary tolerance;
5. optimizer code zero and a finite objective; and
6. `pdHess=TRUE`.

This gate is backend-specific. It does not replace lme4 `isSingular()` or claim
that lme4's optimizer Hessian and glmmTMB's TMB Hessian use the same coordinates.

## Reproducible backend identity

Each glmmTMB fit hashes or records:

- glmmTMB and TMB versions;
- formula, family, link, ML/REML, zero-inflation, and dispersion identities;
- the default `glmmTMBControl()` optimizer, optimizer-control and arguments,
  profile/collect/parallel settings, eigenvalue and convergence checks,
  rank handling, zero-dispersion value, and starting method;
- body/formal identities for `glmmTMB`, `VarCorr.glmmTMB`, `sigma.glmmTMB`,
  `fixef.glmmTMB`, `logLik.glmmTMB`, and `glmmTMBControl`; and
- component, likelihood, covariance-design, information, audit, and retained-
  row identities.

No backend default is inferred from its package version alone.

## Numerical parity object

`mfrmr_gtm_compare()` first requires exact equality of design, incidence-audit,
retained-row, covariance-design, formula, response, random-effect, fixed-effect,
family/link, zero-inflation, dispersion, and ML/REML identities. It then reports
separately:

- component-wise absolute and relative differences;
- fixed-intercept difference;
- full backend-reported Gaussian log-likelihood difference;
- log-likelihood degrees-of-freedom and observation-count equality;
- backend boundary classifications;
- numerical parity; and
- whether both backend point-estimation gates pass.

The prototype smoke tolerances are absolute `5e-5`, relative `5e-5`, logLik
`1e-6`, and intercept `1e-5`. They are stored in every result. These values are
regression tolerances for deterministic fixtures, not accuracy claims,
equivalence margins, recovery criteria, or release thresholds.

`MatchedOverlapPassed` requires both numerical parity and both backend point-
estimation gates. Numerical agreement alone cannot qualify a disconnected,
rank-deficient, or boundary fit. Conversely, a backend disagreement is retained
as evidence rather than averaged away.

## Boundary negative control

The Draft.82 negative-component fixture is a deliberate adversarial case. Both
backends detect a near-zero Item component at their declared tolerances. lme4
returns a singular constrained boundary; glmmTMB returns optimizer code zero
and `pdHess=TRUE`, but remains `boundary_nonregular`.

The two fitted points and full Gaussian REML log-likelihoods differ materially
in this boundary case. Draft.83c2 therefore sets numerical and matched-overlap
parity false. It does not choose a backend, average estimates, or interpret a
positive Hessian as evidence against the boundary.

## Readiness boundary

All Draft.83c2 fit and parity objects retain:

```text
InferenceReady     = FALSE
CoefficientEligible = FALSE
DecisionReady       = FALSE
```

An interior matched-backend result establishes only deterministic
point-estimation overlap for the frozen design. It does not establish bias,
RMSE, coverage, ranking, facet separation, convergence probability, missingness
robustness, or D-study denominator recovery.

## Frozen controls and next gate

The tests cover p x i ML/REML, complete p x r x i, nested Site/Rater with
backend label reordering, the boundary disagreement, backend/control identity,
zero-tolerance parity failure, mismatched criterion and retained-row identity,
row-order replay, capacity, negative tolerance, and malformed object calls.

Draft.83d must now run a registered ADEMP recovery and false-ready program over
person count, observations per person, facet and category counts, sparsity,
workload imbalance, endpoint concentration, local dependence, anchor rate, and
missingness. Draft.83c2 supplies the backend and diagnostic identities for that
program; it does not predetermine which estimator, if any, will qualify.
