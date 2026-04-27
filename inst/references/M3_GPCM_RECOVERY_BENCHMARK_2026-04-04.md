# M3 GPCM Recovery Benchmark

Date: 2026-04-04  
Package baseline: `mfrmr` 0.1.5

## 1. Purpose

This note fixes one narrow, repeatable recovery benchmark for the first-release
`GPCM` branch.

Its role is intentionally limited:

- internal recovery-regression guard for slope, step, and criterion estimates;
- a source-backed validation artifact for the first-release `GPCM` contract;
- and a stable benchmark case for `reference_case_benchmark()`.

It is not intended as:

- an external benchmark against TAM, mirt, or ConQuest;
- a claim that all `GPCM` designs are equally well recovered;
- or a replacement for future broader simulation studies.

## 2. Benchmark contract

The current benchmark case is:

- item-only;
- unidimensional;
- ordered categories `0:3`;
- `MML` only;
- `step_facet = "Criterion"`;
- `slope_facet = "Criterion"`;
- four criterion levels;
- 600 persons under a standard-normal latent distribution.

Truth is generated with:

- centered criterion locations;
- row-centered step parameters for each criterion;
- positive criterion slopes normalized to geometric mean 1.

This matches the package's current first-release `GPCM` identification and
should therefore be interpreted as a package-native recovery check rather than
as a software-to-software parity benchmark.

## 3. Entrypoints

The benchmark is currently exercised through:

- `tests/testthat/test-parameter-recovery.R`
- `tests/testthat/test-reference-benchmark.R`
- `reference_case_benchmark(cases = "synthetic_gpcm", method = "MML", model = "GPCM")`

The synthetic data generator is `sample_mfrm_gpcm_benchmark_data()` in
`R/api-reference-benchmark.R`.

## 4. Current recovery thresholds

The internal benchmark currently scores recovery as:

- `GPCM:slopes`: Pass if correlation `>= 0.95` and MAE `<= 0.15`
- `GPCM:steps`: Pass if correlation `>= 0.98` and MAE `<= 0.20`
- `Criterion`: Pass if correlation `>= 0.98` and MAE `<= 0.15`

These are development thresholds, not external publication criteria.

## 5. Current snapshot

Current fixed-seed local snapshot on 2026-04-04:

- `GPCM:slopes`: correlation `0.977`, MAE `0.0861`
- `GPCM:steps`: correlation `0.994`, MAE `0.0907`
- `Criterion`: correlation `0.999`, MAE `0.0282`

These values are local-development reference points only.

## 6. Interpretation rules

- Treat failures here as contract regressions for the current first-release
  `GPCM` branch.
- Do not generalize these numbers to multi-facet planning scenarios, because
  those remain intentionally blocked for `GPCM`.
- Do not use this benchmark as evidence of external parity with other
  software, because it is calibrated to the package's current identification
  and benchmark generator.

## 7. Current role in the roadmap

This note satisfies the "synthetic recovery" gate for the current first-release
`GPCM` branch in the M3 execution queue, while leaving broader reporting and
planning generalization for later work.
