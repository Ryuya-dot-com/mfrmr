# Draft.83d2b2b1c replacement resolution-feasibility and runtime contract

Status: repository-only planning, manifest, runtime, and authorization
contract, 2026-08-10.

This contract replaces the superseded Draft.83d2b2b0 feasibility execution
permission without changing or deleting its historical identities. It keeps
four tasks distinct:

1. generating a manifest without generating its reserved datasets;
2. measuring runtime only on already viewed replicate-1 datasets;
3. running descriptive resolution feasibility on untouched replicates
   101--125; and
4. later calibrating any bootstrap test and decision rule on separate data.

## Scientific purpose and nonpurpose

Resolution feasibility asks whether truth-blind, application-time observables
are computable and display useful ordering across registered generating
regions. It does not choose a cutpoint, compute a p-value, estimate the size or
power of a bootstrap test, validate an interval, or authorize a D-study
decision.

The retained per-route observables are:

- target variance divided by the sum of fitted variance components;
- target variance divided by fitted residual variance;
- the raw, untruncated full/reduced likelihood difference;
- target and nuisance boundary indicators;
- identical-row, likelihood-df, optimizer, Hessian, and availability states;
  and
- separately labelled ML/REML and lme4/glmmTMB identities.

The withdrawn common `target_relative_se_profiled` quantity does not return.
lme4 profiled relative-SD and glmmTMB joint log-SD local scales remain
backend-coordinate diagnostics and are excluded from common feasibility
scores.

No data-dependent early stopping is permitted. All 3,000 planned method rows
remain in the denominator, including refit errors, materially negative nested
likelihood differences, unavailable Hessians, singular fits, and boundary
fits. A successful fit is not relabelled as an identified or resolved target
component.

## Replacement manifest

The manifest contains:

\[
  5\ \text{designs}\times6\ \text{target-variance regions}
  \times25\ \text{outer replicates}\times4\ \text{methods}
  =3{,}000\ \text{rows}.
\]

There are 750 independent scenario-by-replicate datasets. The four methods
share each generated dataset, but their ML/REML and backend results remain
separate. Each method row requires one full and one target-reduced fit, giving
6,000 backend fits.

Replicates 101--125 retain the registered generator mapping
`SeedStart + Replicate - 1`. They were reserved but never generated or viewed
under the historical plan. The replacement manifest binds them to a new
contract and manifest hash. Constructing or validating the manifest must not
call the generator, pre-fit layer, or any backend.

The primary summaries remain scenario x method. Cross-design pooling cannot
hide a failed sparse, imbalanced, few-level, or high-information stratum.
Truth-region labels may be used only after fitting to assess operating
behavior; no fitting branch or application-time score may inspect them.

## Runtime schema

Runtime is measured only on the already viewed replicate-1 covering grid:

\[
  5\ \text{designs}\times6\ \text{variance regions}
  \times4\ \text{methods}=120\ \text{full/reduced pairs}=240\ \text{fits}.
\]

Every scenario's generation plus pre-fit elapsed time is measured once. Every
method's complete full/reduced diagnostic pair is measured separately using
the unchanged backend controls and serial outer-loop execution. Warm package
loading is outside the measured region. Timing order, R/platform identity,
backend versions, row count, design, method, likelihood, and boundary state
are retained.

Base R documents `system.time()` as two `proc.time()` calls around an
expression and warns that timings can vary considerably, including with
garbage collection:

<https://stat.ethz.ch/R-manual/R-devel/library/base/help/system.time.html>

The recorded elapsed values are therefore planning telemetry, not scientific
results, deterministic evidence, performance guarantees, or backend-quality
metrics. They are excluded from the replayable execution hash. The central
serial projection is

\[
  25\left(\sum_{30\ cells} t_{generation+prefit}
  +\sum_{120\ cell\times method\ routes}t_{pair}\right),
\]

with x2 and x4 sensitivity projections. One timing per route does not estimate
a sampling distribution or justify a hard runtime ceiling.

lme4 and glmmTMB retain their current default control identities. The lme4
control documentation makes optimizer and convergence controls part of the
fit contract:

<https://lme4.github.io/lme4/reference/lmerControl.html>

glmmTMB documents an experimental within-fit parallel option. It is not used
or credited in this serial projection:

<https://glmmtmb.github.io/glmmTMB/articles/parallel.html>

Future parallel scheduling must preserve one scientific result per manifest
row and must not silently alter backend controls or count parallel speedup as
statistical evidence.

## Checkpoint and resume contract

The smallest complete statistical comparison unit is one full/reduced method
pair. Each pair writes one atomic result or one typed failure before another
route begins. A scenario-by-replicate dataset receives a completion marker
only after all four method rows are present exactly once.

Resume reuse requires exact equality of:

- feasibility contract and manifest hashes;
- generator, pre-fit, runner, and diagnostic function hashes;
- package, R, backend-version, formula, target-component, tolerance, and
  default-control identities;
- scenario, replicate, seed, dataset, retained-data, method, likelihood, and
  row-count identities; and
- atomic result hash and completion state.

A missing, duplicate, partial, stale, mismatched, or unhashed route is
recomputed or rejected, never silently pooled. Summary files are derived from
the atomic ledger and cannot substitute for it. No result is dropped because
its fit failed or its runtime was long.

## Authorization gates

The untouched 3,000-row run can be authorized only after:

- the replacement manifest has exact 3,000-row, 750-dataset, and four-method
  accounting without generating reserved data;
- all 120 runtime-schema routes have an atomic result or typed failure;
- every attempted timing is finite and nonnegative;
- serial central/x2/x4 projections and the slowest observed route are reported;
- pair-level and dataset-level checkpoint identities are frozen; and
- rule selection, bootstrap inner loops, calibration, and confirmation remain
  disabled.

Authorization permits only descriptive resolution feasibility. It does not
mean `FeasibilityEvidenceReady`, `BootstrapOperatingCharacteristicsReady`,
`CalibrationEvidenceReady`, `ThresholdFrozen`, `ConfirmationAuthorized`,
`InferenceReady`, `CoefficientEligible`, or `DecisionReady`.
