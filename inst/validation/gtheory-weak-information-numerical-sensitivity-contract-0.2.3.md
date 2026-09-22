# Draft.83d2b2b1e numerical-likelihood sensitivity contract

Status: repository-only, already-viewed feasibility-data numerical audit,
2026-08-10.

This contract investigates the optimizer and objective-function instability
exposed by Draft.83d2b2b1d. It uses only the already viewed replicate-101--125
feasibility data. It does not generate calibration replicates 201--300,
select a component-resolution threshold, estimate size or power, choose a
bootstrap procedure, or authorize inference or a D-study decision.

## Source and software basis

The current lme4 convergence guide says that comparison across available
optimizers is the practical gold standard for diagnosing convergence warnings
and that practically equivalent solutions support treating warnings as false
positives. It also recommends reducing the default `nloptwrap` absolute
parameter and deviance tolerances from 1e-6 to 1e-8 as a first step:

<https://lme4.github.io/lme4/reference/convergence.html>

The current `lmerControl()` reference identifies `nloptwrap` as the `lmer`
default and makes optimizer, restart, boundary, derivative, checking, and
`optCtrl` values part of the fit identity:

<https://lme4.github.io/lme4/reference/lmerControl.html>

The current `allFit()` reference notes that optimizer comparison can be slow,
that control arguments differ by optimizer, and that update-based refitting
can be fragile when data are captured indirectly. This runner therefore uses
direct formula/data calls and a small frozen optimizer set rather than an
unversioned `allFit()` method table:

<https://lme4.github.io/lme4/reference/allFit.html>

The current glmmTMB troubleshooting guide says that `nlminb` false convergence
is difficult to interpret and recommends checking gradients/Hessian,
restarting, and trying another optimizer. It explicitly gives
`optim(method="BFGS")` as an alternative and recommends excluding
non-positive-definite-Hessian fits from further consideration:

<https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html>

The current `glmmTMBControl()` reference identifies `nlminb` as the default,
documents default `iter.max=300` and `eval.max=400`, allows increased limits,
passes `optArgs` such as `method="BFGS"`, and discourages skipping convergence
checks:

<https://glmmtmb.github.io/glmmTMB/reference/glmmTMBControl.html>

Base R documents the `nlminb` controls and their meanings. The sensitivity
profile changes only registered iteration/evaluation and x-tolerance values;
it does not reinterpret a convergence code:

<https://stat.ethz.ch/R-manual/R-devel/library/stats/html/nlminb.html>

## Frozen optimizer profiles

Every one of the 3,000 original method routes is re-fitted under three
profiles for its backend. Each profile performs a full and target-reduced fit.
The audit therefore contains 9,000 full/reduced pairs and 18,000 planned
backend fits over the same 750 generated datasets.

The lme4 profiles are:

1. `lme4_default_nloptwrap`: unchanged `lmerControl()`;
2. `lme4_strict_nloptwrap`: `optimizer="nloptwrap"` with
   `xtol_abs=1e-8`, `ftol_abs=1e-8`, and `maxeval=100000`; and
3. `lme4_bobyqa`: `optimizer="bobyqa"`, `rhoend=1e-8`, and
   `maxfun=100000`.

The glmmTMB profiles are:

1. `glmmTMB_default_nlminb`: unchanged `glmmTMBControl()`;
2. `glmmTMB_tight_nlminb`: `iter.max=2000`, `eval.max=2000`,
   `rel.tol=1e-10`, and `x.tol=1e-10`; and
3. `glmmTMB_optim_bfgs`: `optimizer=stats::optim`,
   `method="BFGS"`, `maxit=2000`, and `reltol=1e-10`.

Default convergence and Hessian checks remain enabled. Likelihood identity,
REML/ML identity, formula, rows, target component, boundary tolerance, and the
existing -1e-6 nested-drop tolerance are unchanged. No profile rescales the
data, simplifies the model, changes the likelihood, changes starting values,
or uses another profile's fitted values.

## Atomic identity and resume

The atomic unit is one original route x optimizer profile full/reduced pair.
Each atomic result binds the Draft.83d2b2b1d execution hash, original route,
profile/control hash, generator, retained-data, formula, likelihood, package,
R, optimizer, diagnostic, and result identities. One scenario-replicate
marker requires all 12 expected method-profile rows.

Checkpoint writes use same-directory temporary serialization followed by an
atomic rename. Missing, corrupt, stale, duplicate, or mismatched profile rows
are recomputed or rejected. A returned pair with a warning, boundary,
non-positive Hessian, optimizer failure, or materially negative drop remains
an observed row. Successful-only pooling is prohibited.

Scientific execution hashes exclude timing, checkpoint location, progress
frequency, order, and computed-versus-reused state. All 9,000 result or typed-
failure rows remain in the denominator. No data-dependent early stopping is
permitted.

## Prespecified descriptive comparisons

The default-profile raw drop is compared with the Draft.83d2b2b1d raw drop.
The absolute difference is retained, with 1e-10 used only as a deterministic
same-software replay diagnostic. Failure of that diagnostic invalidates the
sensitivity execution identity; it does not authorize replacing the original
result.

For each original route, the audit records separately for full and reduced
models:

- all profile log likelihoods and convergence/Hessian states;
- the maximum, minimum, and raw log-likelihood spread;
- which profile attained the maximum;
- target estimates and boundary states;
- each raw untruncated nested likelihood difference;
- whether all three, at least two, one, or no profiles are comparison-
  available;
- whether materially negative versus within-tolerance signs are stable or
  optimizer-sensitive; and
- the envelope difference
  `2 * (max full logLik - max reduced logLik)`.

The envelope uses separately attained numerical maxima and is a diagnostic of
optimization adequacy, not a likelihood-ratio statistic with a reference
distribution. Full and reduced maxima may come from different profiles.

The sign ledger is explicitly three-state. `materially negative` requires a
finite raw difference below -1e-6; `within tolerance` requires a finite raw
difference at least -1e-6; a non-finite difference is `not evaluable` and is
never relabelled as materially negative. Optimizer/Hessian eligibility remains
a separate dimension, so a finite materially negative value can overlap an
ineligible fit without merging the two diagnoses.

No practical-equivalence cutoff is selected. Full/reduced deviance-scale
objective spreads are counted on the fixed reporting grid
`1e-8, 1e-6, 1e-4, 1e-2`; the raw spreads and empirical quantiles remain
primary. Sign-stability and availability are reported by design, variance,
method, likelihood, and profile. Cross-design or cross-backend pooling cannot
convert a failed stratum to an eligible one.

## Claim boundary and next gate

This audit may determine whether materially negative differences reproduce,
disappear under another optimizer, or reflect unequal full/reduced numerical
optimization. It cannot determine which optimizer is statistically superior,
whether a component is resolved, or whether a bootstrap test has correct
size.

`NumericalSensitivityEvidenceReady` means exact completion of this already-
viewed descriptive audit only. `CalibrationEvidenceReady`,
`BootstrapOperatingCharacteristicsReady`, `ThresholdFrozen`,
`ConfirmationAuthorized`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` remain false. A later, prospectively frozen contract must
decide which numerical states are eligible before generating calibration
replicates 201--300.
