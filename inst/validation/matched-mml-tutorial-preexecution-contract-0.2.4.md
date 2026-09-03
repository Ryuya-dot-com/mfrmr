# Matched MML tutorial comparison pre-execution contract for mfrmr 0.2.4

Status: protocol frozen on 2026-09-03; execution remains locked until the
complete `D5-SHARD-001`--`D5-SHARD-050` denominator has been unsealed and
adjudicated. This record authorizes no fit, release candidate, stress
simulation, or software-equivalence claim.

Contract ID: `MML-MATCH-PREEXEC-v1`.

## Purpose

The comparison asks whether matched RSM/PCM MML fits give materially similar
numerical results on one already-inspected public synthetic fixture. It does
not test whether the programs are interchangeable, whether any one algorithm
is correct, or whether a solution on the 140 x 80 x 10 observed design exists.

Because results from this tutorial fixture have already been inspected, this
is a descriptive calibration and future engineering regression baseline, not
a prospective scientific-equivalence test. No observed difference from this
fixture may be relabelled as an independent acceptance tolerance.

## Bound fixture

| Field | Frozen value |
| --- | --- |
| Fixture ID | `rmal_mfrm_tutorial_rsm_v1` |
| Data-specification SHA-256 | `79dc18e3b2b3a4c29378b14cd21bf733a1a734fc906920090628919ea9bdca45` |
| Long-data SHA-256 | `654461b6634bac2ecffeba27b73eaa45ec913c63c1dfb4bd584aebee4d1545e4` |
| Design | complete 80 Person x 6 Rater x 5 Criterion crossing |
| Rows | 2,400 |
| Categories | integers 0--4, all retained |
| Slopes | fixed at one |
| Person distribution | normal with estimated variance |

Execution must refuse a fixture whose identifiers, dimensions, category map,
row count, or hashes differ. A machine-local absolute path is not part of the
contract; the hashes identify any byte-identical copy.

## Frozen comparison denominator

| Lane | Model | Programs | Threshold structure | Evidence role |
| --- | --- | --- | --- | --- |
| `MM-RSM-ESTVAR` | RSM | mfrmr, TAM | four shared adjacent-category steps | matched descriptive calibration |
| `MM-PCM-ESTVAR-TAM` | PCM | mfrmr, TAM | four Criterion-specific steps | matched descriptive calibration |
| `MM-PCM-ESTVAR-SIRT` | PCM | mfrmr, sirt | four Criterion-specific steps | matched or near-matched calibration, conditional on the integration audit |

There is no sirt RSM lane. The default equal-discrimination
`sirt::rm.facets()` model has Criterion-specific thresholds and therefore
belongs only in the PCM denominator. Failed or unavailable lanes remain in the
denominator with their failure reason; they are not dropped before summaries
are calculated.

## Model and coordinate contract

- mfrmr uses `method = "MML"`, unit slopes, and
  `population_formula = ~ 1` so the Person variance is estimated.
- TAM uses `TAM::tam.mml.mfr()`, `est.variance = TRUE`, unit slopes, and
  `~ item + rater + step` for RSM or `~ item + rater + item:step` for PCM.
- sirt uses `sirt::rm.facets()` with `est.a.item = FALSE`,
  `est.a.rater = FALSE`, `rater_item_int = FALSE`, `est.mean = FALSE`, and
  estimated normal spread. Free-slope and interaction forms are different
  models and are excluded.
- Every result is transformed to one declared coordinate before differences
  are computed: Rater and Criterion locations sum to zero; RSM steps sum to
  zero; PCM thresholds are decomposed into a Criterion location and
  within-Criterion centered steps. The transform must reproduce each native
  engine's category probabilities before its parameter table is admitted.
- Population location, estimated variance, and every origin shift are retained
  explicitly. Raw native labels are never joined directly across engines.

The bound local package identities at protocol freeze are TAM `4.3.25`
(`TAM::tam.mml.mfr` function SHA-256
`93631641ee114fe0e46ae47b8a1c4788d394ec4e1ca74cfef2b5db4efdce07ca`)
and sirt `4.2.133` (`sirt::rm.facets` function SHA-256
`abb969b1e1ec429d6af7b4fa2e1ea0ef851bae78cc7d11ab2484ea28370ef47e`).
A version or loaded-function mismatch is reported as an identity failure, not
silently accepted.

## Integration and scoring contract

The primary sensitivity orders are 31 and 61 deterministic points. Each
engine must export or record its actual nodes and normalized weights. Equal
point counts or equal ranges do not establish equal quadrature.

Cross-engine comparison proceeds in this order:

1. record within-engine q31-to-q61 movement;
2. classify the native node and weight rules as exact, transformed, or
   unmatched;
3. compare fitted structural coordinates and native marginal objective values;
4. recompute probabilities, marginal objectives, and Person EAP summaries with
   the existing independent adjacent-category oracle on one common recorded
   grid; and
5. attribute remaining differences separately to fitted coordinates, native
   integration, or native scoring.

Person EAP and posterior SD are the primary score outputs. TAM's documented
`fit$person$EAP` is used, not `TAM::tam.wle()`. The existing supplementary
`alternative_locations.csv` route mixes TAM WLE with sirt EAP and is therefore
ineligible for this comparison. WLE may be retained only in a separately
labelled secondary table with no EAP--WLE correlation presented as software
agreement.

## Required output and failure semantics

For every lane, engine, and integration order, retain:

- package version, loaded-function hash, call, controls, elapsed time,
  warnings, messages, iterations, and native stopping rule;
- optimizer convergence, terminal objective movement, and finite-value status;
- mfrmr `InferenceReady` and its reason codes separately from optimizer
  convergence;
- native and common-coordinate parameter tables;
- log likelihood/deviance, estimated Person variance, Person EAP and posterior
  SD, and the actual integration nodes and weights; and
- pairwise origin-adjusted maximum absolute difference, RMSE, Pearson
  correlation, regression intercept and slope, plus within-engine q31/q61
  movement.

A finite estimate is not convergence, convergence is not inference readiness,
and a high correlation is not numerical equality. If any engine fails, the
record must distinguish input rejection, structural nonidentification,
optimizer failure, integration failure, and readiness review. No successful
subset may replace the frozen denominator.

## Explicit exclusions and next gate

This execution contains no sparse assignment, anchor manipulation, increased
Rater SD, endpoint avoidance, free-slope GPCM, DRF, interaction, or new
simulation. The 140 x 80 x 10 observed-data failures remain applicability
evidence only because no common MML solution exists there.

After D5 adjudication, reuse
`tam-mml-core-calibration-0.2.3.R` for the TAM coordinate and integration
machinery and `external-mml-algorithm-correlation-audit-0.2.3.R` for the
objective-versus-correlation separation. Add only the missing tutorial-fixture
binding and sirt PCM adapter. The resulting record may establish a reproducible
descriptive regression baseline; it cannot by itself authorize a broad
compatibility claim, a stress-test expansion, candidate v5, or CRAN submission.
