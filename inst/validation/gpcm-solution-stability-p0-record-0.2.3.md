# GPCM solution-stability P0 execution record for 0.2.3

Status: completed repository-only deterministic microcase, 2026-08-12.
Contract: `mfrmr_gpcm_solution_stability_p0_v1`.
Specification: `0.2.3-draft.1`.

This record closes the first instrumentation slice of P0. It does not freeze a
stationarity, objective, parameter, or decision tolerance; establish a unique
global maximum; adjudicate a boundary; authorize a selected production
solution; or promote any GPCM, DFF, fit, rank, separation, or interval claim.

## Frozen execution identity

- source-tree branch: `development/0.2.3`
- parent source commit: `0e303fb02817320ad8d9ccf98d2a5212423bf97a`
- source-tree package version: `0.2.3`
- runner:
  `gpcm-solution-stability-p0-0.2.3.R`
- runner SHA-256:
  `89b20f7185ca3eaf06920cd5468711d47429df9f6d6841f59ef7a425e5e51c6f`
- test:
  `test-gpcm-solution-stability-p0.R`
- test SHA-256:
  `1ea5edb478d781814f3bf246c36f3fc25e3618e98ccd80408055c8c26380c52f`
- canonical-score dependency:
  `numerical-stationarity-pilot-0.2.3.R`
- dependency SHA-256:
  `68df33bc1c114309f875a0cf8056ac720254740633fe55ca909535d032663344`
- fixture: `polytomous_fixed`, 60 Persons by 4 Items, 240 rows,
  categories 0--3
- fixture SHA-256:
  `383979d685be5719d2844476eeb1126dd586d070c7a1926199ac31f89867ae1e`
- model: item-owned-step, item-owned-slope `GPCM`
- estimator and identification: direct `MML`, `free_population`
- optimizer and integration: requested `L-BFGS-B`, 31-point
  Gauss--Hermite quadrature
- controls: `maxit = 1200`, `reltol = 1e-12`
- independent gradient: coordinate-scaled central difference at relative step
  `3e-5`
- runtime: R 4.6.1, aarch64 macOS, testthat 3.3.2, digest 0.6.39,
  reference BLAS/LAPACK

The start registry was fixed before the candidate fits. It contains the
package default, a retained-vector restart, an all-zero free vector, a
low/high expanded-slope start, low and high population-variance starts, and a
moderate free-coordinate perturbation under seed `20260812`. The registry
stores vector, fixture, and common-context fingerprints and rejects mutated,
duplicated, reordered, mixed-quadrature, or authorization-changing rows.

## Results

All seven declared starts returned finite vectors. Under the existing package
optimizer diagnostic, all seven had `ConvergenceSeverity = pass`. They are
therefore eligible to enter the descriptive P0 pairwise comparison. All seven
remain `P0StabilityEligible = FALSE`: neither an `InferenceReady` state nor a
frozen solution-stability rule follows from the comparison.

| Metric | Observed value |
| --- | ---: |
| Declared / returned / comparison-eligible P0 starts | 7 / 7 / 7 |
| P0 stability-eligible starts | 0 |
| Free dimension from returned vector | 16 |
| Free dimension from parameter sizes | 16 |
| Free dimension from canonical coordinate table | 16 |
| Free dimension from MML optimizer map | 16 |
| Free dimension from observed-pattern score audit | 16 |
| Maximum native/common objective difference | 0 |
| Range of canonical objectives | `1.1969518709520344e-9` |
| Maximum canonical analytic gradient norm | `7.7961401137931243e-5` |
| Maximum analytic/central-difference gradient difference | `6.3080489938561773e-9` |
| Maximum pairwise free-coordinate difference | `1.4622510804584987e-5` |
| Maximum pairwise expanded semantic-coordinate difference | `1.4622510804584987e-5` |

The common canonical objectives were:

| Start | Canonical objective | Maximum absolute analytic gradient |
| --- | ---: | ---: |
| `default` | `307.99138957386879` | `7.3486476534298154e-5` |
| `retained_restart` | `307.99138957382041` | `2.1706353102050751e-5` |
| `zero_null` | `307.99138957381240` | `4.1056810119101232e-5` |
| `slope_low_high` | `307.99138957385543` | `4.2568739737274924e-5` |
| `variance_low` | `307.99138957385190` | `7.7961401137931243e-5` |
| `variance_high` | `307.99138957500935` | `5.2602748878030072e-5` |
| `seeded_perturbation` | `307.99138957390022` | `4.6847421731664477e-5` |

Pairwise output retains separate additive-facet, step, expanded log-slope,
natural slope, population coefficient, log-variance, and natural-variance
classes. Each maximum is attached to a semantic key. Free and expanded
vectors are not compared by unlabelled position alone.

The runner reports `zero_null` as the diagnostic lowest objective in this
execution. That field is descriptive only. The objective range, gradient
magnitudes, and transformed differences cannot be turned into a selected
cluster until a prospective tolerance rule and the P1 boundary/integration
gates exist.

## Decision signature and fail-closed interpretation

Each candidate receives the same fixed signature schema. Optimizer return,
convergence, dimension identity, and common evaluation are populated. The
boundary, Hessian, interval, DFF, fit, Person rank, Rater rank, and facet-
separation states are explicitly `not_evaluated`. Consequently every candidate
has overall state `review`, and both `SelectionAuthorized` and
`ConfirmationAuthorized` remain `FALSE`.

All 21 candidate pairs have identical P0 signatures because their populated
numerical states agree and every later state is identically unevaluated. This
is a schema/replay observation, not evidence that DFF, fit, ranks, or
separation are decision-invariant. A mutation control changes one DFF state
and is detected as exactly one changed signature key; deleting a key is
rejected rather than compared on the intersection.

Failed optimizer candidates are retained as rows with failed common evaluation
and dimension identity, and with both comparison and stability eligibility
false. They cannot vanish from the denominator or authorize selection.

## Verification

The repository-mode focused test was run as:

```text
NOT_CRAN=true Rscript -e 'pkgload::load_all(quiet=TRUE); testthat::test_file(
  "tests/testthat/test-gpcm-solution-stability-p0.R", reporter="summary")'
```

Result: 78 expectations passed, zero failures, zero warnings, zero skips.

Positive tests cover exact registry identity, RNG preservation, canonical
objective/analytic/independent-gradient completion, five-way dimension
identity, semantic GPCM transformation, pairwise class-specific differences,
and fail-closed signature states. Negative tests cover start-vector mutation,
duplicate/reordered IDs, mixed quadrature, unauthorized selection, missing
signature keys, changed DFF classification, and a failed optimizer candidate.

## Next admissible work

1. Add a small deterministic endpoint/near-boundary cross to P0; do not widen
   this one benign fixture into a claim.
2. Implement P1 marginal-MML slope and variance profiles plus the bounded
   start-by-quadrature panel under the same semantic keys.
3. Freeze any solution-cluster tolerance only after independent review and a
   prospective calibration/confirmation split.
4. Admit candidates to P2 Hessian/interval checks only after P1 rules out a
   superior or equal nonattained boundary solution.
5. Populate DFF, fit, rank, and separation signatures only in P3; an explicit
   `not_evaluated` agreement supplies no downstream evidence.
