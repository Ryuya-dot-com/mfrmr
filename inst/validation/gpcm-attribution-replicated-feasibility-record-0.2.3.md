# GPCM replicated-attribution feasibility record for mfrmr 0.2.3

Status: repository-only draft.43 calibration record, 2026-08-05. This is not
confirmation evidence, a frozen numerical criterion, an external comparison,
or authorization to release.

## Identity

| Field | Value |
| --- | --- |
| Public package source | mfrmr 0.2.3 development commit `655f6bfd0cb8aaf37cc5a587f922cbdd6969d6e7` |
| Exact public tarball SHA-256 | `88EBD28817AD1924A9AE235F56301264D5EC47FD06A9416D6A4BA55C5C59DFA6` |
| Exact `R CMD check --as-cran` | `Status: OK`; log SHA-256 `B3956B95ABCB26BDE6D9CBD1A675ED9DE4C5365970B3F86FAEAA0B7FBDB8AA3D` |
| Validation source commit | `543b41db44bcd01496eb7eb41850f8c4e753ef6c` |
| Attribution runner | `gpcm-isolated-attribution-pilot-0.2.3.R`; SHA-256 `5B998FBD24641721D4E215115F7A362BAECF77F5F99DEF938FFC32353163C5FC` |
| Replicated-pilot runner | `gpcm-attribution-replicated-pilot-0.2.3.R`; SHA-256 `F3590B6DD4E3419F0E2E9D64B94688D719A9EE690D5977E3A316EBD1AD41C098` |
| R and platform | R 4.5.1 (2025-06-13 ucrt), Windows 11 x64 |
| Required validation capability | `lpSolve` 5.6.23 available for JML additive recession audits |
| Other key packages | `digest` 0.6.39; `psych` 2.6.5 |
| Tier and controls | feasibility; 10 arms; 2 replicates; 4 routes; `maxit = 120`; MML `quad_points = 7`; overall residual PCA enabled |
| Manifest hash | `07989badd83624129d3182c3a1bd118def23ad7159265047ffea6cedc475213c` |
| Output directory | workspace `mfrmr/archive/artifacts/validation-bundles-0.2.3/gpcm-attribution-replicated-feasibility-20260805-v4` |

Retained aggregate artifacts:

| Artifact | SHA-256 |
| --- | --- |
| `pilot-registry.csv` | `C8B260977264B8B9AACC25BB3989001A5047A0846655096269D1562945EC0248` |
| `scenario-manifest.csv` | `4A8678279F1560D82406BB44375EF4FF13D883A0771C33D3EDFED9C390664600` |
| `run-results.csv` | `A3FF87ADB29ACC09FA8D141A390D793D36528FB712AEC96755F43221E94E6BD9` |
| `paired-contrasts.csv` | `9EB676D581B64CFA568799BF64C1231BCD88690F9001E39C83486B333C20CC1E` |
| `summary.csv` | `AF0E2B7CD5AB8C7A8DD89273AB65C3D63BA4149DB86ACEB3BFDA699D2474AD37` |
| `rate-summary.csv` | `C6A06594E4FE277D250369AD27226155103218FDB6347B9BF53EC7BD25C3B6FE` |
| `metric-summary.csv` | `8609493F9280B57B3E29F92F131E55AE1192D54901173755B1DD21D4E8C09D65` |
| `contrast-metric-summary.csv` | `F59FE21FF4F6F4FCCE39CC2E7CF18E0B6AEE1065B9DAE5EA3327B9A318075AC3` |
| `completeness-ledger.csv` | `5220DB8E1040C1CF9D55DFCBCF96F87DC8593685E81A4AE96B9665E75D8A14BD` |
| `gpcm-attribution-replicated-pilot.rds` | `0E3F94A5BFA7EC2015C627630BC4DFCD1E5E19493E8E8BDD90C190CB2658929A` |

The public tarball contains 490 tar entries and zero paths matching the
repository-only validation directory, internal roadmaps, release protocol,
attribution runners, or temporary audit files.

## Prespecified feasibility tier

The tier selected the reference, unit/strong/near-zero-high slope regimes,
two raters, a weak bridge, an internal zero category after selection,
outcome-dependent row deletion, a Person-by-rater interaction, and planted
local dependence. The two pilot seeds were 440001 and 440002. Every retained
dataset was fitted through `GPCM_JML`, `GPCM_MML`, `PCM_JML`, and `PCM_MML`.

Top-line accounting:

- 80 of 80 analysis rows completed and all 20 data cells contained four
  routes;
- all 20 data cells had one valid retained-data identity, with zero pair-
  identity violations;
- zero fits failed, zero declared false-ready rows occurred, zero free-GPCM
  primary slope rows were comparison eligible, and zero external-numeric rows
  were eligible;
- thresholds remained `pilot_required_not_frozen`, the minimum replicate count
  for criterion freeze remained unset, and confirmation remained unauthorized;
- recorded fit time was 405.4 seconds in total (5.0675 seconds per route and
  20.27 seconds per data cell); wall time was approximately 1,072 seconds, so
  fit timing alone materially understates generation, diagnostics, PCA,
  serialization, and orchestration cost.

With only two attempts per arm-route cell, Wilson 95% intervals are necessarily
wide: 0/2 gives `[0, 0.658]`, 1/2 gives approximately `[0.095, 0.906]`, and 2/2
gives approximately `[0.342, 1]`. A zero observed failure count is therefore a
feasibility observation, not stability evidence.

## EAP Person-order defect found and corrected

The first analysis of these same retained data exposed implausible MML-only
residual-PCA values in the `category_internal_zero` and `missing_outcome`
arms. Direct audit showed that `rowsum(..., reorder = FALSE)` retained Person
posterior rows in first-observed order after filtering, while
`build_person_table()` attached `prep$levels$Person` in internal index order.
The marginal likelihood and structural estimates were unaffected, but EAP
estimates and posterior SDs could be paired with the wrong Person labels.
Every downstream EAP-based expected score, residual, fit, bias, and residual-
PCA diagnostic then inherited the mismatch.

Commit `655f6bf` aligns EAP and posterior-SD vectors explicitly by the Person
indices returned by the posterior bundle. A public regression test now
reverses retained observation order and requires identical Person-indexed EAP
and posterior-SD vectors.

The corrected v4 run used the same manifest and retained-data hashes as the
pre-fix v2 run. Excluding runtime, exactly eight rows changed numerical output:
the two filtered arms, two replicates, and two MML routes. Only Person RMSE,
MAE, correlation, maximum absolute error, and the first residual-PCA
eigenvalue changed. Structural Rater, Criterion, step, finite optimizer-slope,
objective, support, readiness, boundary, and reason-code values were unchanged.

| Arm | Route | Corrected Person correlation, two seeds | Corrected PC1 range | Pre-fix signal |
| --- | --- | --- | --- | --- |
| internal zero category | GPCM-MML | 0.948, 0.949 | 2.10--2.38 | Person correlation -0.056/0.068; PC1 about 15.8--16.2 |
| internal zero category | PCM-MML | 0.946, 0.948 | 2.14--2.53 | Person correlation near zero; PC1 about 15.9--16.3 |
| outcome-dependent deletion | GPCM-MML | 0.927, 0.932 | 2.41--2.56 | Person correlation 0.013/0.131; PC1 about 12.9--13.1 |
| outcome-dependent deletion | PCM-MML | 0.930, 0.927 | 2.45--2.60 | Person correlation 0.021/0.135; PC1 about 12.8--13.0 |

The pre-fix v2 MML Person and EAP-derived diagnostic rows are invalidated. The
intermediate v3 rerun confirmed the code correction but lacked `lpSolve`; its
PCM-JML boundary state correctly failed closed as `not_evaluated`. It is not
used as the authoritative feasibility record. Installing `lpSolve` restored
the prespecified JML boundary capability, and v4 reproduced every v2
readiness, boundary, and reason string while retaining only the intended EAP
corrections.

## Remaining signals, not criteria

The weak-bridge arm remains the most severe numerical challenge. Both
GPCM-JML fits were blocked after iteration limits/extreme-Person review, with
Person RMSE about 5.05--5.17 and optimizer log-slope RMSE about 3.16--3.24.
GPCM-MML remained review-only with Person RMSE about 0.53--0.58 and optimizer
log-slope RMSE about 0.20--0.24. PCM-JML was ready with exclusions, and PCM-MML
was ready. This pattern implicates weak linkage, JML extreme-Person behavior,
and free-slope geometry jointly; it is not evidence of one universal GPCM
failure mechanism.

The planted local-dependence arm increased mean PC1 over the reference by
about 0.48--0.56 across the four routes. Numerical readiness did not uniformly
detect the omitted dependence. With two seeds and no calibrated residual-
matrix contract or null distribution, this is only a diagnostic signal.

Internal-zero category selection and outcome-dependent deletion increased
step RMSE for both GPCM and PCM routes. That common lower-model movement is
not attributable to free slopes. Optimizer log-slope RMSE remains a numerical
trace because no free-GPCM primary slope row is eligible.

## Gate consequences and next execution

No tolerance, diagnostic cutoff, replication count, external normalizer,
candidate identity, support-envelope promotion, or confirmation decision is
frozen by this run.

Before the core tier starts:

1. add scenario-level atomic checkpoint/resume with manifest, package,
   runner, and capability hashes and reject partial or incompatible reuse;
2. make row permutation, filtered-then-permuted rows, nonlexical Person labels,
   retained factor levels, and weighted/zero-weight patterns explicit
   metamorphic controls across RSM, PCM, and GPCM MML;
3. record PCA input dimensions, observed-pair counts, raw minimum eigenvalue,
   positive-definite smoothing change, residual SD, and EAP identity rather
   than gating on PC1 alone;
4. freeze a validation capability manifest, including the distinction between
   an optional dependency being unavailable and a statistical audit failing;
5. expand beyond two replicates using an MCSE/precision design chosen before
   inspecting confirmation seeds; and
6. complete metric-specific FACETS/TAM/immer normalizers before any external
   difference enters a numeric acceptance aggregate.

Linear scaling of this run places the current 600-row core tier near 2.2 hours
of wall time and the 800-row expanded tier near 3.0 hours on this machine,
before tail or contention allowance. Those are scheduling estimates, not
performance guarantees. Core and expanded execution remain guarded and
confirmation remains prohibited.
