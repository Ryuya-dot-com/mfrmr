# Draft.83d2b2b1a weak-information variance-component inference audit

Status: repository-only mathematical/source audit and superseding diagnostic
contract, 2026-08-09.

This audit precedes the 25-replicate weak-information feasibility run. It
distinguishes (i) estimating a nonnegative variance component, (ii) testing a
zero-variance null, (iii) quantifying uncertainty away from the boundary, and
(iv) declaring a component sufficiently resolved for a D-study. Those are
different claims and no one diagnostic establishes all four.

## Literature and software basis

The boundary result of Self and Liang (1987) establishes nonstandard
large-sample likelihood-ratio behavior when the true parameter lies on the
boundary. It does not supply a universal half-point-mass/half-chi-square law
for every finite, crossed mixed model with several nuisance variance
components. Crainiceanu and Ruppert (2004) derive finite-sample LRT and RLRT
laws for a linear mixed model with **one** variance component and show that
generic large-sample mixture approximations can be poor when their assumptions
do not hold. Greven et al. (2008) extend practical finite-sample approximation
work to testing one component in the presence of other random effects, again
without turning the ordinary one-degree chi-square reference into a general
solution.

The relevant sources are:

- Self, S. G., & Liang, K.-Y. (1987),
  <https://doi.org/10.1080/01621459.1987.10478472>;
- Crainiceanu, C. M., & Ruppert, D. (2004),
  <https://doi.org/10.1111/j.1467-9868.2004.00438.x>;
- Greven, S., Crainiceanu, C. M., Küchenhoff, H., & Peters, A. (2008),
  <https://doi.org/10.1198/106186008X386599>;
- Scheipl, F., Greven, S., & Küchenhoff, H. (2008),
  <https://doi.org/10.1016/j.csda.2007.10.022>;
- Bates et al. (2015), the lme4 computational account,
  <https://doi.org/10.18637/jss.v067.i01>;
- Brooks et al. (2017), the glmmTMB computational account,
  <https://doi.org/10.32614/RJ-2017-066>;
- the current lme4 likelihood-inference note,
  <https://lme4.github.io/lme4/reference/pvalues.html>;
- the current glmmTMB fitting and covariance documentation,
  <https://glmmtmb.github.io/glmmTMB/reference/glmmTMB.html> and
  <https://glmmtmb.github.io/glmmTMB/reference/vcov.glmmTMB.html>; and
- the RLRsim reference manual,
  <https://cran.r-universe.dev/RLRsim/doc/manual.html>.

The local Zotero library contains Jiang, Raymond, Shi, and DiStefano (2020),
"Using a linear mixed-effect model framework to estimate multivariate
generalizability theory parameters in R" (local keys `2BQX642B`, `VJJDXAFU`,
and `528TN57V`). It did not return the boundary-inference sources above under
variance-component, likelihood-ratio, RLRT, or bootstrap searches. No Zotero
record was added or changed by this audit.

## Mathematical contract

Let the full fitted covariance be

\[
  V_F(\psi,\sigma_r^2)=V_R(\psi)+\sigma_r^2 Z_rZ_r^\mathsf{T},
  \qquad \sigma_r^2\geq 0,
\]

where \(\psi\) contains the five other random-component variances and the
residual variance in the registered three-facet design. The reduced model fixes
\(\sigma_r^2=0\) and retains every other term. For likelihood identity \(q\),
the repository records

\[
  \Delta_q=2\{\ell_q(\widehat V_F)-\ell_q(\widehat V_R)\}.
\]

For ML, \(q\) is the ordinary Gaussian marginal likelihood. For REML, \(q\) is
the restricted likelihood and the fixed-effect design, response, and retained
rows must be identical between full and reduced fits. ML and REML scores are
separate diagnostics and are never pooled.

The raw \(\Delta_q\) is retained, including a small negative numerical value;
it is not silently truncated to zero. A materially negative value indicates a
fit/comparison problem because the reduced covariance space is nested in the
full space. No ordinary \(\chi^2_1\) p-value, universal 50:50 mixture p-value,
or confidence interval is attached.

`RLRsim::exactLRT()` and `exactRLRT()` target their documented one-random-
effect setting with a known correlation structure and independent errors.
Dropping Rater from the current six-random-component full model does not make
the five remaining nuisance components known. Therefore the current design is
outside that exact contract; RLRsim is not used as a nominally exact shortcut.

For a future test-like calibration, the primary route is a custom parametric
bootstrap under the fitted reduced model: simulate on the exact observed
incidence pattern, refit the same full/reduced backend pipeline, preserve ML or
REML identity, and include optimizer and boundary failures in the denominator.
That bootstrap still tests the zero-variance null; positive-control recovery,
bias, and D-study stability require separate evaluation.

## Backend coordinate contract

lme4 exposes a constrained `theta` vector in covariance-factor coordinates.
For the registered scalar random intercepts, the target coordinate is a
relative standard deviation and

\[
  \widehat\sigma_r^2=\widehat\sigma_e^2\widehat\theta_r^2.
\]

If \(H\) is the Hessian of lme4's profiled deviance/REML criterion, a local
quadratic scale in the profiled `theta` coordinate is

\[
  s_{\theta_r}=\{2(H^{-1})_{rr}\}^{1/2}.
\]

This follows because the criterion is on the \(-2\ell\) scale. It is recorded
only when the named coordinate map is exact and \(H\) is finite and positive
definite. It omits full residual-scale uncertainty and is **not** called a
variance-component standard error, Wald test, or interval.

glmmTMB exposes the registered scalar random-effect coordinates as log standard
deviations. Its joint top-level covariance can supply a local quadratic scale
for that finite log-SD coordinate. Zero variance corresponds to log-SD
\(-\infty\), so a finite-coordinate Wald approximation is nonregular at the
scientific boundary. The first-order quantity twice the log-SD local scale is
reported, when available, only as a delta relative-variance scale diagnostic.

The lme4 and glmmTMB local scales live in different coordinate systems. They
must not share a numerical threshold, be averaged, or be relabelled as a common
`target_relative_se_profiled` score.

## Superseding decision before feasibility

The Draft.83d2b2b0 score `target_relative_se_profiled` and the two rule
families that require it are withdrawn before feasibility data are generated.
This is a prospective mathematical correction, not a data-dependent rule
change. The b2b0 plan and its hashes remain as an immutable historical record,
but its authorized feasibility manifest must not be executed.

The following may be collected in a source-audited schema refit:

- the raw ML LRT or REML RLRT likelihood drop, separately by method;
- exact formula, row, observation-count, and likelihood-degree-of-freedom
  identity checks;
- lme4 profiled relative-SD local coordinate scale;
- glmmTMB joint log-SD local coordinate scale; and
- full/reduced optimizer, Hessian, singularity, boundary, and nuisance-failure
  states.

These remain validation diagnostics. The likelihood-drop architecture can
enter a later empirical feasibility/calibration contract only after its null
and positive-control behavior is evaluated separately. The custom null
bootstrap, confidence intervals, and user-facing inference remain beyond
Draft.83 and continue under Draft.84 ownership.

`FeasibilityEvidenceReady`, `CalibrationEvidenceReady`, `ThresholdFrozen`,
`ConfirmationAuthorized`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` remain false.
