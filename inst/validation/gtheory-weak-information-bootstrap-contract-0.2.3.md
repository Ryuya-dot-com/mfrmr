# Draft.83d2b2b1b weak-information parametric-bootstrap mechanics contract

Status: repository-only source, computation, and execution contract,
2026-08-09.

This contract separates three tasks that must not be collapsed:

1. resolution-score feasibility for every registered outer dataset;
2. fitted-null parametric-bootstrap mechanics on the exact observed design;
3. outer-simulation operating characteristics for any eventual bootstrap test.

Only the second task receives a small viewed schema in this slice. No
bootstrap p-value from that schema is inferential or threshold eligible.

## Source and method boundary

The lme4 `bootMer()` contract states that a parametric bootstrap with
`use.u = FALSE` or `re.form = NA` generates new spherical random effects and
new independent errors. It also exposes bootstrap errors rather than requiring
their deletion:

<https://lme4.github.io/lme4/reference/bootMer.html>

The current glmmTMB simulation vignette states that `simulate.glmmTMB()`
resamples random effects from their fitted distribution and returns response
vectors with the original observation count:

<https://glmmtmb.github.io/glmmTMB/articles/sim.html>

The present procedure is a **plug-in parametric bootstrap** under the fitted
reduced model. “Exact-design” means that response row order, covariates, factor
levels, incidence, missingness pattern, fixed-effect design, and all non-target
random-effect terms are held exactly fixed. It does not mean an exact finite-
sample test: nuisance parameters and residual scale are estimated.

The target variance is on a boundary. In addition, an untested nuisance
variance can itself be on a boundary. Guedon, Baey, and Kuhn's shrinked
parametric-bootstrap work addresses this second nonregularity in a broader
mixed-effects setting:

<https://arxiv.org/abs/2306.10779>

The current plain bootstrap is not relabelled as that shrinked procedure and is
not assumed consistent merely because all refits return. Every observed and
bootstrap pair records nuisance-boundary state. Any future shrinkage sequence,
rate, or estimator requires a new mathematical and execution identity.

Stringer and Negrea (2026) propose an efficient parametric-bootstrap method for
linear combinations of multiple Gaussian variance components, including
crossed designs:

<https://arxiv.org/abs/2604.25744>

This recent preprint is a monitored future acceleration/comparison candidate,
not an implementation oracle or a 0.2.3 dependency.

## Null and simulation contract

For one observed dataset and one backend/likelihood route, fit

\[
  M_F: V_F(\psi,\sigma_r^2),\quad \sigma_r^2\geq0,
  \qquad
  M_0: V_0(\psi)=V_F(\psi,0),
\]

on identical rows and fixed effects. The observed statistic is

\[
  T_{obs}=2\{\ell(M_F)-\ell(M_0)\}.
\]

For bootstrap index \(b=1,\ldots,B\), generate a new response from the fitted
reduced model, including new random effects and residual errors, then refit
both models and compute

\[
  T_b=2\{\ell_b(M_F)-\ell_b(M_0)\}.
\]

ML and REML remain separate. Full and reduced REML fits retain the identical
fixed-effect design. lme4 and glmmTMB simulations are backend-native and are
not treated as paired random draws. Backend comparison therefore concerns
operating characteristics, not bootstrap-replicate equality.

Every generated response receives a deterministic parent, method, bootstrap-
index, seed, and data hash. A response cannot inherit the observed-data hash.
The raw statistic is never truncated to zero. A value below the frozen
negative numerical tolerance is an invalid refit result; a small negative
value inside tolerance remains available and is compared on its raw scale.

## Monte Carlo and failure accounting

For \(B\) planned bootstrap draws, let \(E\) be the number of available
statistics at least as large as \(T_{obs}\), and let \(F\) be the number of
failed or unavailable bootstrap pairs. Motivated by the nonzero Monte Carlo
p-value convention discussed by Phipson and Smyth (2010), the repository uses
the plus-one bounds

\[
  p_L={1+E\over B+1},\qquad
  p_U={1+E+F\over B+1}.
\]

Reference: <https://doi.org/10.2202/1544-6115.1585>.

When \(F=0\), the bounds coincide and a Monte Carlo point value is
computable. When \(F>0\), no single value is created: all failed draws count
in the denominator and the interval shows the full worst-case effect of their
unknown exceedance state. These are computational Monte Carlo bounds, not a
confidence interval for the scientific parameter and not proof that the
plug-in bootstrap has correct size.

The smallest possible nonzero value and numerical grid width are
\(1/(B+1)\). A schema with very small \(B\) can test only ordering, seeds,
hashes, simulation, refitting, ties, and failure accounting.

## Three execution layers

### A. Resolution-score feasibility

The eventual replacement for the historical feasibility manifest contains 30
scenario cells x 25 outer replicates x four methods = 3,000 diagnostic rows.
Each row needs one full and one reduced fit, or 6,000 backend fits before any
inner bootstrap. It evaluates target fractions, target/residual ratios, and raw
ML/RLRT score overlap. It neither reports a test p-value nor selects a final
threshold.

### B. Viewed bootstrap mechanics schema

The authorized schema uses the three already viewed baseline control datasets
at outer replicate 2, all four methods, and \(B=3\). It therefore contains 12
observed routes, 36 bootstrap pairs, and

\[
  2\times12\times(1+3)=96
\]

full/reduced backend fits. Its Monte Carlo grid is 0.25. It cannot estimate
size, power, a useful p-value cutoff, or the required production \(B\).

Schema bootstrap seeds occupy a separate deterministic namespace and do not
overlap outer generator seeds or any feasibility/calibration/confirmation
replicate band. Only this 12-route schema is execution-authorized.

### C. Outer operating-characteristic calibration

Any bootstrap test must be assessed under independently generated exact-zero,
near-zero, and positive outer datasets. Size, indeterminate rate, power,
failure, nuisance-boundary frequency, and Monte Carlo uncertainty remain
scenario x method outcomes. A point value that appears small on one observed
dataset is not calibration evidence.

A naive all-cell plan with 30 scenarios, 25 outer replicates, four methods,
and \(B=199\) would require

\[
  2\times30\times25\times4\times(199+1)=1{,}200{,}000
\]

backend fits. Consequently the production bootstrap \(B\), outer-cell subset,
stopping prohibition, batching, checkpoint format, and precision targets must
follow measured schema/runtime evidence. They are not frozen here.

## Gates and nonclaims

The mechanics schema passes only if:

- all 12 observed rows and all 36 planned bootstrap rows are present exactly
  once;
- generated response length, row order, factor levels, and design identity are
  preserved;
- every response and atomic result hash reproduces;
- full/reduced row count and likelihood-df identity are exact;
- each backend resamples random effects rather than conditioning on fitted
  BLUPs;
- failures remain in the planned denominator and p-value bounds obey the
  formulas above; and
- no mechanics result changes a resolution state or readiness flag.

`ResolutionFeasibilityAuthorized`, `BootstrapOperatingCharacteristicsReady`,
`FeasibilityEvidenceReady`, `CalibrationEvidenceReady`, `ThresholdFrozen`,
`ConfirmationAuthorized`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` remain false.
