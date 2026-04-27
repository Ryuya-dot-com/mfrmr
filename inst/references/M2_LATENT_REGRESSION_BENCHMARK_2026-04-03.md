# M2 Latent Regression Benchmark

Date: 2026-04-03  
Script: `analysis/benchmark_latent_regression.R`

## Purpose

This note fixes one lightweight, repeatable benchmark entrypoint for the M2
latent-regression layer.

Its role is intentionally narrow:

- local performance-regression guard for development,
- timing snapshot for the new latent-regression fit / scoring / planning paths,
- and one stable benchmark script referenced by the M2 execution checklist.

It is not intended as:

- a cross-machine performance claim,
- a release-marketing number,
- or an external benchmark against ConQuest.

## How to run

From the package root:

```sh
Rscript analysis/benchmark_latent_regression.R
```

## Covered paths

- `fit_latent_rsm`: active latent-regression `MML` fit under `RSM`
- `fit_latent_pcm`: active latent-regression `MML` fit under `PCM`
- `score_units_latent`: `predict_mfrm_units()` under the fitted
  population-model posterior
- `plausible_values_latent`: `sample_mfrm_plausible_values()` under the
  fitted population-model posterior
- `design_eval_latent`: `evaluate_mfrm_design()` with an active
  latent-regression simulation specification
- `forecast_latent`: `predict_mfrm_population()` with the same active
  latent-regression simulation specification

## Interpretation rules

- Compare timings only within the same machine or a clearly similar
  environment.
- Treat large relative slowdowns on the same machine as useful development
  signals.
- Expect repeated-estimation paths to be dominated by `fit_mfrm()`, not by the
  raw simulation kernel.
- Do not interpret the benchmark as evidence of ConQuest parity or as proof of
  asymptotic scalability.

## Current snapshot

Current local snapshot on 2026-04-03:

- `fit_latent_rsm`: `0.170s`
- `fit_latent_pcm`: `0.199s`
- `score_units_latent`: `0.003s`
- `plausible_values_latent`: `0.081s`
- `design_eval_latent`: `0.730s`
- `forecast_latent`: `0.939s`

These values are local-development reference points only.

## Current role in the roadmap

This script satisfies the "Run internal benchmarks" checkpoint in
`inst/references/M2_LATENT_REGRESSION_MASTER_PLAN_2026-04-03.md` for the
first latent-regression implementation wave.
