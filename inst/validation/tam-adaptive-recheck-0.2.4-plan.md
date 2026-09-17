# Adaptive MML recheck of the retained TAM stress conditions

Frozen before new comparison results: 2026-09-14. This is a bounded engineering
follow-up, not a replacement of the historical failed contracts or a scientific
equivalence/coverage study.

Runtime addendum, before Linux numerical results: its TAM 4.3.25 serialized
function hashes differ from the macOS installation. Full formals/body text
comparison shows exactly one difference in each function: the initial
`deviance.min` sentinel is `1e100` on Linux versus
`1.0000000000000002e100` on macOS. No other text differs. The runner binds the
reviewed Linux hashes separately and retains both identities; it does not
normalize away arbitrary differences or claim byte-identical installations.

Question: does the public adaptive fitter remove the integration sensitivity
seen in the retained RSM/PCM datasets, while agreeing with an independently
stable TAM calculation and a separately expressed continuous integral?

Reuse all 21 RSM and 15 PCM dataset/population-mode identities from
`tam-mml-release-stress-0.2.4.R` and
`tam-pcm-mml-conditional-stress-0.2.4.R`. Match the recorded input hashes before
fitting. Five profiles (baseline, sparse rater assignment, MCAR 20%, forced
extremes, weak exposure), three replications and the existing six estimated-
population RSM cases are retained. No data or failed run is removed.

For each of the 36 cases:

- Public mfrmr fixed Q31/Q61 and adaptive Q15/Q31/Q61, direct optimization,
  `maxit=1000`, `reltol=1e-12`, otherwise the historical model/constraints.
- TAM Q31/Q61 at the historical range (RSM [-6,6], PCM [-8,8]), plus Q181/Q301
  at [-8,8] for both models. Reuse the support-only design construction and
  zero-weight support rows; retain raw deviance and its original row-count
  normalization. Match normal-prior mean/variance treatment in both engines.
- Compare complete cumulative-difficulty surfaces, deviance, EAP, posterior
  SD, and population mean/variance. Confirm TAM Q181/Q301 stability before
  treating Q301 as a reference; the same number of nodes in different rules
  does not imply the same approximation.
- At adaptive Q61 and TAM Q301, evaluate every Person with the existing
  independently expressed continuous-integral reference. Retain numerical
  error/tail bounds and compare likelihood and moments. This also checks the
  TAM zero-weight deviance scaling separately from parameter agreement.
- Re-optimize the adaptive-Q31 objective from the fixed-Q31 parameters and
  from adaptive-Q61 parameters plus `0.3*sin(coordinate)`. These are standalone
  optimizer probes, not fabricated public fit objects. Use BFGS, maxit=200,
  reltol=1e-12; one reltol=1e-14 polish if the gradient exceeds 1e-4. Retain both
  stages and failures. Compare their final objective/parameters with the
  public adaptive-Q31 fit.
- Retain adaptive Q31/Q61 observed-information covariance diagonals as numerical
  diagnostics for order sensitivity. Their stability does not establish
  standard-error equivalence, calibration uncertainty or interval coverage.

The primary new comparisons are adaptive Q31/Q61 against stable TAM Q301:
72 pairs. Reuse the historical 1e-4 absolute engineering bound for each of
deviance, surface, EAP, posterior SD, prior mean and variance, and the 1e-3
order-movement review bound. Require finite results, a public terminal gradient
below 1e-4 and TAM completion below its 1,000-iteration ceiling. Fixed Q31/Q61
and adaptive Q15 remain diagnostic rows, not reasons to relax the primary
bound. Independently integrated total log likelihood and posterior moments
should agree within 1e-7, with reference relative integration error below 1e-9
and omitted-mass bound below 1e-12. Failure to meet a bound is recorded for
investigation, not silently converted into an execution error or discarded.

There are 324 planned fitted-engine runs and 72 restart probes on macOS.
For a platform check, Linux repeats the first replication of the ten fixed-
prior model/profile combinations (90 fits and 20 restart probes), selected
before results. Use the existing checked 0.2.4.9000 code and TAM 4.3.25; retain
function/source identities. Existing historical result files remain unchanged.

This lane does not validate GPCM identification/boundary certificates,
estimated-population formal inference, anchor transport, disconnected-design
repair, ConQuest equivalence or interval coverage. Those questions require
their own designs. In particular, forced-extreme modifications are a stress
test and must not be interpreted as correctly specified recovery replicates.

Post-hoc diagnostic addendum (declared after observing standalone BFGS gradient
failures, before executing the follow-up): select **every** restart with an
execution error, nonzero convergence code, nonfinite gradient, or gradient at
least 1e-4. Retry from its original initial vector with the existing public
`run_mfrm_direct_optimization()` policy, `optimizer="auto"`, maxit=200 and
reltol=1e-12. Retain all bounded polish stages and final discrepancies from the
public adaptive-Q31 solution. This examines the optimizer stopping rule; it
does not replace the original restart rows or convert their failures to passes.
