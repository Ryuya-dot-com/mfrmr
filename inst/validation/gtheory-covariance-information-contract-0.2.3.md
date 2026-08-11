# Draft.83c1 G-theory covariance-design and expected-information contract

Status: repository-only estimator-diagnostics prototype contract, 2026-08-09.

Draft.83c1 follows the Draft.83a observed-incidence audit and Draft.83b
allocation operator. It asks whether the variance components in one typed
univariate Gaussian random-intercept design are distinguishable in the
observed covariance structure, whether ML and REML have local expected
information for them, and whether an `lme4` point fit is interior and
numerically acceptable. It does not validate recovery, form an interval, or
authorize a D-study coefficient.

## Model boundary

The fitted model is

\[
  y = X\beta + \sum_{c \ne e} Z_c u_c + e,
  \qquad
  u_c \sim N(0,\sigma_c^2 I),
  \qquad
  e \sim N(0,\sigma_e^2 I),
\]

with mutually independent component vectors. Draft.83c1 has one fixed
intercept, independent exchangeable random intercepts for every typed grouping
component, and one homogeneous residual variance. It does not cover random
slopes, correlated blocks, structured residual covariance, heteroscedastic
dispersion, generalized outcomes, or joint MFRM/G-theory likelihoods.

Every calculation uses exactly the rows retained and canonically hashed by the
bound Draft.83a audit. The typed design hash, declared-level hash, canonical
input hash, retained-data hash, omission-pattern hash, missingness declaration,
and incidence-audit hash must agree. Row order may change; values or omission
identity may not.

Nested child labels use the Draft.83a conditional identity. Thus a raw Rater
label reused across Sites creates separate `Site:Rater` groups and no false
bridge.

## Covariance derivative matrices

For component `c`, Draft.83c1 constructs

\[
  K_c = \frac{\partial V}{\partial\sigma_c^2}=Z_cZ_c^\top,
  \qquad K_e=I,
\]

so an entry is one exactly when two retained rows share the effective grouping
identity for that component. The structural covariance-design matrix is

\[
  D=\left[\operatorname{vech}(K_1),\ldots,
          \operatorname{vech}(K_C)\right].
\]

`StructuralRankFull` means only that the linear map from the declared variance
vector to `V` is injective for these retained rows. Rank loss produces a
component-labelled right null space. In an unreplicated saturated `p x i`
design, for example, `K_Person:Item = I = K_Residual`; the audit records their
opposite null-space loadings rather than relying only on a formula warning.

This covariance rank is not the fixed-effect-equivalent contrast rank from
Draft.83a. Neither subsumes the other. A disconnected incidence graph may have
full covariance rank, while still failing the linking screen needed for the
intended object comparison.

The implementation materializes dense `K_c` and `D` matrices only below a
declared matrix-cell ceiling. A capacity failure is a typed non-evaluation and
cannot pass an estimation or coefficient gate. Sparse algebra is required
before this prototype can scale to production data.

## ML and REML expected information

At an explicitly named nonnegative variance point,

\[
  V=\sum_c \sigma_c^2 K_c.
\]

`V` must be positive definite. For ML, the expected variance-component
information is

\[
  \mathcal I^{ML}_{cd}
    =\frac12\operatorname{tr}
      \left(V^{-1}K_cV^{-1}K_d\right).
\]

For REML,

\[
  P=V^{-1}-V^{-1}X(X^\top V^{-1}X)^{-1}X^\top V^{-1},
\]

and

\[
  \mathcal I^{REML}_{cd}
    =\frac12\operatorname{tr}(PK_cPK_d).
\]

Both matrices receive eigenvalue rank, condition-number, and component-labelled
null-space audits. The ML and REML ranks are retained separately. For example,
a one-level facet has `K=11'`: it can be structurally independent and locally
informative under the ML covariance expression, while `P11'P=0` makes its REML
information zero after removal of the fixed intercept.

This is expected information at one declared point, not the observed optimizer
Hessian, a global identifiability proof, finite-sample recovery evidence, or a
standard-error guarantee. A full rank at a boundary point does not restore
regular likelihood asymptotics. `RegularInterior` therefore requires every
variance coordinate to exceed the separately recorded boundary tolerance.

## lme4 point-fit binding

`mfrmr_gtc_lme4()` calls the locally installed `lme4::lmer()` with the typed
canonical formula, exact Draft.83a retained rows, an intercept-only fixed part,
and `REML=TRUE` or `FALSE`. It records:

- `lme4` version, ML/REML identity, formula, constraints, and row contract;
- optimizer, edge-restart, boundary, derivative, pre-fit, convergence-check,
  and optimizer-control identity from the actual `lmerControl()` object, plus
  body/formal hashes for `lmer`, `VarCorr.merMod`, `isSingular`, and
  `lmerControl`;
- semantic component identities recovered from `VarCorr()`, rather than its
  backend display order;
- every constrained variance point estimate and boundary state;
- optimizer code, captured warnings/messages, lme4 convergence messages,
  maximum available gradient, and minimum available optimizer-Hessian
  eigenvalue;
- `isSingular()` at an explicit tolerance; and
- structural covariance and expected-information result hashes.

The installed `lme4` 2.0.6 help describes `lmer()` as ML/REML LMM fitting,
`VarCorr()` as returning variance/covariance components plus residual variance,
and `isSingular()` as a boundary/rank diagnostic. Its `lmerControl()` help also
distinguishes a zero optimizer convergence code from singularity, gradient, and
Hessian checks. Draft.83c1 preserves those distinctions.

A finite fit and optimizer code zero are not enough. The point-estimation gate
passes only when all of the following hold:

1. the Draft.83a incidence screen passes;
2. the covariance derivative design has full structural rank;
3. the selected ML or REML expected-information matrix has full rank;
4. every fitted variance is interior at the declared tolerance; and
5. the lme4 diagnostic state is `identified`, with no optimizer warning or
   singular state.

A fit at zero variance remains a valid constrained likelihood point estimate,
but is labelled `boundary_nonregular`. It is not silently interpreted as an
interior component estimate or a perfect-reliability result.

## Readiness boundary

The three objects have deliberately different meanings:

| Object | What can pass | What remains false |
| --- | --- | --- |
| covariance design | structural covariance screen | coefficient and decision readiness |
| expected information | local ML/REML information and interior screens | inference, coefficient, and decision readiness |
| lme4 fit | finite point estimate and narrow estimation qualification | inference, coefficient, and decision readiness |

Even `point_estimation_gate_passed` does not set `CoefficientEligible`. Draft.83b
can algebraically transform a supplied component vector, but Draft.83c1 does
not yet certify that fitted unbalanced or nested components have acceptable
bias, RMSE, coverage, rank recovery, facet separation, or failure behavior.
Those are Draft.83d responsibilities.

## Frozen negative and positive controls

The Draft.83c1 tests freeze:

- full structural and ML/REML information rank for balanced `p x r x i`;
- exact highest-order/residual covariance aliasing;
- REML-specific intercept-information loss for a one-level facet;
- a sparse connected and a disconnected `p x i` design with the same full
  covariance/information rank but different Draft.83a connectivity status;
- conditional `Site:Rater` covariance identities;
- lme4 REML agreement with the Draft.82 balanced fixture on identical retained
  rows;
- a finite optimizer-code-zero boundary/singular fit that remains nonregular;
  and
- row-order replay, mismatched data, mismatched missingness, capacity, malformed
  variance maps, and negative variance controls.

## Deferred work

Draft.83c2 must implement a separately identified `glmmTMB` route and compare
only genuinely matched Gaussian ML/REML likelihoods and variance structures.
Draft.83d must run ADEMP recovery and zero-false-ready studies across person
count, observations per person, rater and criterion counts, category/endpoint
profiles, sparsity, workload imbalance, local dependence, anchor rate, and
missingness. Interval calibration, replicate-error allocation, object-nested
superpopulation semantics, structured covariance, multivariate G-theory, and
public API promotion remain later gates.
