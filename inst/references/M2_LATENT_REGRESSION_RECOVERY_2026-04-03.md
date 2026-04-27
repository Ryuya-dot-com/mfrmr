# M2 Latent Regression Recovery Baseline

Date: 2026-04-03  
Script: `analysis/latent_regression_recovery_study.R`

## Purpose

This note fixes one package-native recovery-study entrypoint for the first
latent-regression branch.

Its role is narrower than a final publication-grade simulation study:

- it is a local regression guard for development,
- it checks that `beta`, `sigma2`, fitted person summaries, and posterior
  scoring move in the expected direction,
- and it keeps the release checklist anchored to one repeatable script.

The study is not intended as a cross-machine benchmark or as a claim of full
ConQuest parity.

## Evidence Base

This baseline follows the validation requirements frozen in:

- `inst/references/M2_LATENT_REGRESSION_STATISTICAL_SPEC_2026-04-03.md`
- `inst/references/M2_LATENT_REGRESSION_MASTER_PLAN_2026-04-03.md`

The simulation-study framing follows the reporting logic already adopted in the
package planning notes:

- Morris, White, and Crowther (2019)
- Siepe et al. (2024)

The estimation and posterior-scoring interpretation remain tied to:

- Bock and Aitkin (1981)
- Mislevy (1991)

## How to run

From the package root:

```sh
Rscript analysis/latent_regression_recovery_study.R
```

Optional flags:

```sh
Rscript analysis/latent_regression_recovery_study.R --reps=8 --pv-draws=80
```

The default settings are deliberately lightweight for development smoke checks.
For release-facing review, increase `--reps`.

## Covered cases

The script covers the minimum first-wave cases that matter for the current
implementation:

- `rsm_continuous`: `RSM` with one centered continuous covariate
- `rsm_dummy`: `RSM` with one dummy-coded numeric covariate
- `pcm_continuous`: `PCM` with one centered continuous covariate
- `rsm_mean_only`: mean-only latent regression `~ 1`
- `rsm_null_effect`: continuous-covariate branch with true slope `0`

This matches the current M2 requirement that recovery work should cover:

- one continuous covariate,
- one dummy-coded categorical covariate,
- one `RSM` case,
- one `PCM` case,
- one mean-only case,
- and one null-effect predictor case.

## Output tables

The script prints two tables.

### `case overview`

One row per case with:

- convergence rate,
- bias / RMSE of `sigma2`,
- mean correlation between fitted person summaries and true `theta`,
- posterior-shift checks from `predict_mfrm_units()`,
- and plausible-value-versus-EAP gap summaries from
  `sample_mfrm_plausible_values()`.

### `coefficient overview`

One row per case-term with:

- true coefficient value,
- mean estimated coefficient,
- coefficient bias,
- coefficient RMSE.

## Interpretation rules

- Compare runs only within the same machine or a clearly similar environment.
- Treat this as a development regression guard, not as a final Monte Carlo
  study for publication.
- A clean smoke-check run should show:
  - positive convergence rates close to `1`,
  - sensible `beta` direction in non-null cases,
  - small slope estimates in the null-effect case,
  - positive finite `sigma2` estimates,
  - and posterior shifts that agree with the fitted population model.
- If the null-effect case starts showing consistently large slopes, or if the
  posterior-shift checks disagree with the fitted population model, stop and
  audit before extending the API further.

## Current role in the roadmap

This script is the package-native recovery baseline for the remaining M2
validation work. It satisfies the "recovery studies and regression-specific
tests" track at the development level, while stronger release-facing runs can
increase `--reps` without changing the study design.
