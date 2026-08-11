# Draft.83d2b2b1c replacement feasibility and runtime record

Date: 2026-08-10
Scope: untouched resolution-feasibility manifest, already viewed runtime
schema, and narrow execution authorization
Result: 3,000-row manifest and 240-fit runtime schema pass exact accounting;
descriptive feasibility execution is authorized, while all inferential and
threshold gates remain closed

## Outcome

Draft.83d2b2b1c replaces only the historical feasibility execution permission.
The Draft.83d2b2b0 plan remains an immutable historical record, but no longer
authorizes a run.

The new identities are:

- contract: `3a005d424d6121d0feda96ac4455e230cb7f4c93d0f152659b27f3ea647d406b`;
- untouched feasibility manifest:
  `bc14c65fb6ccc26c22d60487f4225493cd58735a48a44758d19cbaf739b17242`;
- viewed runtime manifest:
  `c65c8b2d8a5f4135266c50b0ef67a860c2002fc75027f83578ae66f60b2d27a9`;
- timing-excluded runtime execution:
  `9099eec3ae54485162b18e3fee14aae4b1d888fe32e2bc0b897fbb1d8105e7eb`;
- descriptive-feasibility authorization:
  `e36e82198763e7a785a840cbd9bc029b658b919f58e14377a24e6ced1ca64e1a`.

The execution and authorization hashes reproduced exactly in an independent
second run. Timing values changed slightly and are intentionally excluded from
those identities.

## Untouched feasibility manifest

The manifest contains five registered designs x six Rater-variance regions x
25 replicates x four methods:

| Quantity | Result |
| --- | ---: |
| planned method rows | 3,000 |
| independent scenario-replicate datasets | 750 |
| methods per dataset | 4 |
| full/reduced backend fits | 6,000 |
| replicates per scenario x method | 25 |
| replicate band | 101--125 |
| duplicate route IDs | 0 |
| datasets generated or viewed | 0 |
| rule selection or inner bootstrap enabled | no |

Manifest construction was tested after replacing the generator with an
intentional error. The manifest still completed, confirming that it hashes
metadata only and does not generate reserved data.

The generator continues to use `SeedStart + Replicate - 1`, so the four
methods share one scenario-replicate dataset. The new contract and manifest
hashes, rather than the superseded plan hash, govern any future execution.

## Viewed runtime schema

Runtime was measured on the previously viewed replicate-1 covering grid: all
30 design x variance cells and all four lme4/glmmTMB ML/REML routes. Each route
fits the full and Rater-reduced model, giving 120 pairs and 240 backend fits.

| Quantity | Result |
| --- | ---: |
| diagnostic pairs returned | 120 / 120 |
| typed route errors | 0 |
| common feasibility scores available | 111 / 120 |
| unavailable common score rows | 9 / 120 |
| materially negative raw likelihood drops below -1e-6 | 6 |
| available small negative raw drops retained | 18 |
| target-boundary rows | 22 |
| nuisance-boundary rows | 8 |

All eight nuisance-boundary rows occurred in the few-level complete design.
This does not prove that other designs have no nuisance-boundary risk; it is
one already viewed replicate per cell.

The nine unavailable score rows decompose as follows:

- four rows failed the full/reduced optimizer or likelihood-identity
  availability condition;
- six rows had a materially negative nested likelihood difference; and
- one row belongs to both groups, so the union is nine rather than ten.

The materially negative values were not truncated. They occurred in the high-
information numerical-near-zero cell for both glmmTMB likelihood routes, the
baseline small-0.01 lme4 ML route, and three of the four high-information
moderate-0.04 routes. The fourth moderate-0.04 route, lme4 REML, instead had an
unavailable reduced optimizer/Hessian condition. Consequently, larger sample
or design information does not by itself guarantee a numerically valid nested
comparison.

The runtime authorization therefore requires atomic accounting, not 120/120
available scientific scores. The coming feasibility study is designed to
estimate this availability behavior across 25 independent replicates.

## Serial runtime projection

One detailed run measured:

| Component | Elapsed |
| --- | ---: |
| 30 generation plus pre-fit units | 4.594 s |
| 120 full/reduced pairs | 74.498 s |
| complete viewed schema | 79.092 s |
| central 3,000-pair projection | 1,977.3 s = 32.955 min |
| x2 sensitivity projection | 65.910 min |
| x4 sensitivity projection | 131.820 min = 2.197 h |

The independent repeat gave a central projection of 1,955.2 seconds, or about
32.59 minutes, while reproducing the timing-excluded execution hash. This
variation is expected and demonstrates why elapsed time is planning telemetry,
not deterministic evidence or a performance guarantee.

The first detailed method projection, excluding generation/pre-fit time, was:

| Method | Projected pair time over 25 replicates |
| --- | ---: |
| lme4 ML | 371.4 s |
| lme4 REML | 385.4 s |
| glmmTMB ML | 551.9 s |
| glmmTMB REML | 553.8 s |

The slowest observed pair was a high-information moderate-0.04 glmmTMB REML
route at approximately 2.85 seconds. These are local serial observations, not
backend accuracy rankings or portable service-level claims. No parallel
speedup is credited.

## Checkpoint and authorization state

All eight authorization gates pass:

1. exact 3,000-row/750-dataset/6,000-fit accounting;
2. no reserved data generated;
3. exact 120-route runtime atomic accounting;
4. complete finite nonnegative timing telemetry;
5. one full/reduced method pair as the atomic checkpoint unit;
6. rule selection disabled;
7. inner bootstrap disabled; and
8. confirmation use disabled.

`ResolutionFeasibilityAuthorized` is therefore true only in the separate
authorization record. The initial contract and runtime execution retain it as
false so that constructing either object cannot authorize its own downstream
run.

The authorized run is serial and checkpointed after every full/reduced method
pair. A dataset completion marker requires all four method rows. Resume reuse
requires the exact contract, manifest, generator, pre-fit, runner, backend,
formula, tolerance, dataset, and atomic-result identities. Partial or stale
routes are recomputed or rejected.

## Recorded environment

| Dependency | Version |
| --- | --- |
| R | 4.6.1 (2026-06-24) |
| testthat | 3.3.2 |
| digest | 0.6.39 |
| lme4 | 2.0.6 |
| glmmTMB | 1.1.14 |
| TMB | 1.9.23 |
| Matrix | 1.7.6 |
| reformulas | 0.4.4 |

## Test and artifact evidence

Seven focused tests and 88 expectations pass with the explicit runtime tier.
They cover the narrow contract, generator-free 3,000-row manifest, exact seed
and method pairing, all-cell viewed runtime manifest, runtime projection
arithmetic and nonclaim, raw observable identity, source boundaries, all 120
atomic runtime rows, and fail-closed authorization/readiness.

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-weak-information-feasibility-contract-0.2.3.md` | `6df9b976e412cb2ca0584a7c6baf2935feb415e280481e28e1be2f925acaaef2` |
| `gtheory-weak-information-feasibility-prototype-0.2.3.R` | `0526784366eb8a6221d64d1b20921bc51a95c451830391d0292221e055f6d296` |
| `test-gtheory-weak-information-feasibility-prototype.R` | `2814af8ae6f9df3da915f7582fdc33a909bf8d10e76d718cdf2755c9950fd8bd` |

The record's own hash is omitted because recording it would change the file.

## Readiness and next gate

The following distinctions are now essential:

- `ResolutionFeasibilityAuthorized = TRUE` permits the 3,000 descriptive rows;
- `FeasibilityEvidenceReady = FALSE` until all 3,000 atomic rows exist;
- `BootstrapOperatingCharacteristicsReady = FALSE` because no outer test
  calibration has run; and
- `ThresholdFrozen`, `ConfirmationAuthorized`, `InferenceReady`,
  `CoefficientEligible`, and `DecisionReady` remain false.

The next slice may execute only the frozen 3,000-row manifest with no inner
bootstrap, threshold, or data-dependent stopping. Its primary outputs are
scenario x method availability, raw score distributions, target/nuisance
boundary frequencies, materially negative nested-comparison frequency, and
exact failed-row accounting. Only after those results are complete may the
portfolio decide whether plain, shrinked, or another bootstrap deserves an
outer operating-characteristic calibration.
