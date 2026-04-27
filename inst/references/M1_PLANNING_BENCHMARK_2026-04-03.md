# M1 Planning Benchmark

Date: 2026-04-03  
Script: `analysis/benchmark_planning_helpers.R`

## Purpose

This note fixes one lightweight, repeatable benchmark entrypoint for the M1
planning layer. The benchmark is not intended as a cross-machine performance
claim. It is a regression check for local development when simulation and
planning helpers are refactored.

## How to run

From the package root:

```sh
Rscript analysis/benchmark_planning_helpers.R
```

## Covered paths

- plain `PCM` simulation with scalar arguments,
- `evaluate_mfrm_design()` on one moderate design condition,
- `evaluate_mfrm_signal_detection()` on one moderate design condition,
- `resampled` empirical assignment generation,
- `skeleton` empirical assignment generation.

## Interpretation rules

- Compare timings only against runs from the same machine or a clearly similar
  environment.
- Treat large relative changes within the same machine as useful signals.
- Do not use these numbers as package-level marketing claims.
- The repeated-estimation paths are expected to be dominated by `fit_mfrm()`
  and `diagnose_mfrm()`, not by the raw simulation kernel.
- The empirical assignment paths are intended to catch regressions in
  `resampled` and `skeleton` template handling after internal refactors.

## Current role in the roadmap

This benchmark satisfies the M1-Q3 requirement from
`MFRMR_EXECUTION_PROTOCOL_2026-04-03.md`: one lightweight, reproducible
benchmark harness for the planning helpers with explicit interpretation
limits.
