# PCM/GPCM comparison ADEMP contract record for 0.2.3

Status: **prospective design fixed; execution not authorized**

Review date: 2026-08-13

Specification: `0.2.3-draft.2`

Contract: `mfrmr_pcm_gpcm_comparison_ademp_contract_v1`

## Aim

The planned simulation will compare paired PCM and aligned single-owner GPCM
fits without reducing the question to which model has the larger fitted
likelihood. It separates:

1. numerical return and inference readiness;
2. parameter recovery;
3. held-out prediction;
4. substantive Person and information-allocation consequences; and
5. model-selection behavior where the estimator and integration contract make
   selection eligible.

No fit was executed while preparing this contract. The retained six-pair JML
calibration remains feasibility evidence only and was not used to change an
outcome threshold.

## Data-generating truth

| Regime | Centered log-slope range | Exact kernel truth | Practical target | Selection scoring |
|---|---:|---|---|---|
| `unit_slopes` | 0 | PCM | PCM | score PCM support |
| `near_flat` | +/- `log(1.04)` | GPCM | indifference band | do not label either choice correct |
| `moderate` | +/- 0.25 | GPCM | GPCM | score GPCM support |
| `strong` | +/- 0.60 | GPCM | GPCM | score GPCM support |

The near-flat condition is essential. It prevents a mathematically non-unit
slope of negligible practical size from being counted automatically as a
PCM-selection error. It instead measures selection instability inside a
declared five-percent slope band.

## Estimator separation

| Lane | Person treatment | Model-selection role |
|---|---|---|
| JML | jointly fitted fixed Person coordinates | likelihood difference is descriptive; AIC, Person-BIC, SABIC, and ordinary PCM/GPCM LRT are structurally ineligible |
| MML | integrated random Person effect | AIC, Person-BIC, and SABIC are planned only after both fits are inference-ready and the q=61 fit/q=91 common-evaluation stability gate passes |

The planned MML route uses direct q=61 fitting and q=91 common evaluation.
The gate remains closed because the current integration evidence has not yet
frozen a PCM/GPCM comparison tolerance. JML and MML objectives, selection
rates, and recovery summaries will never be pooled.

FACETS is absent from this internal simulation. A later FACETS exercise may
compare the PCM/JML side directly, but cannot provide a jointly fitted
free-slope GPCM counterpart.

## Covering design

The 16 registered conditions cover:

- Criterion- and Rater-owned aligned slopes;
- all four slope regimes in both owners at the central `N=100` design;
- `N=40`, `N=100`, and `N=300`;
- four Raters, four Criteria, and four ordered categories;
- complete and weak-link sparse assignment;
- moderate rater-workload imbalance;
- rare endpoint-category support; and
- restricted ability range.

This is a deliberate covering design, not a full factorial. Slope owner always
equals step owner; simultaneous Criterion-by-Rater slopes remain outside the
current model.

## Performance measures

The 27 registered metrics include:

- pair return, PCM/GPCM readiness, joint readiness, and metric availability;
- descriptive GPCM-minus-PCM objective difference;
- gated MML AIC, Person-BIC, and Sclove SABIC truth support;
- centered log-slope bias/RMSE/rank recovery;
- Person ability bias/RMSE/rank recovery;
- rater severity, criterion difficulty, and threshold RMSE;
- held-out multicategory log loss, Brier score, and calibration error;
- PCM/GPCM Person-rank agreement;
- ability-cut decision flips and truth-classification errors; and
- criterion information-share RMSE.

All location recovery is evaluated after the declared scale alignment. Slope
rank correlation is undefined under constant unit-slope truth and is therefore
not assigned an artificial perfect or zero value.

Held-out prediction uses a prespecified within-Person response split. It is not
a new-Person marginal prediction claim. The split algorithm and minimum
retained support must be frozen in the later execution adapter before any fit.

## Fixed denominators and failure accounting

Each estimator lane has one planned pair for each dataset. A pair records PCM
and GPCM attempts separately and obeys this monotone sequence:

```text
planned
  -> generated
  -> support audit passed
  -> PCM/GPCM fit attempted
  -> PCM/GPCM fit returned
  -> PCM/GPCM inference ready
  -> paired comparison built
  -> MML IC comparable
  -> MML integration stability passed
  -> formal model selection available
```

Failure never disappears from a recovery or selection denominator. Return and
readiness rates use all planned pairs. Metric availability is reported before
conditional bias/RMSE. A missing result is `unrecorded`, not a fitted failure,
and makes exact accounting fail. Formal selection cannot be true unless the
lane is MML and both readiness, IC-comparability, and integration-stability
gates pass.

## Execution and precision plan

| Stage | Rows | Purpose | Current authority |
|---|---:|---|---|
| smoke | 8 paired estimator rows | schema, pairing, support, and failure-path checks | not authorized by this design artifact |
| feasibility pilot | 160 paired estimator rows | five replicates per condition to estimate runtime, failure structure, and metric dispersion | not authorized |
| confirmation | not frozen | operating characteristics under a separately approved precision plan | not authorized |

The future rate-metric confirmation rule targets Monte Carlo standard error at
most 0.025. Its worst-case binomial requirement is at least 400 eligible
replicates per reported rate, but the final count remains unset because metric
availability and continuous-metric dispersion must first be learned from the
feasibility pilot. This avoids pretending that five pilot replicates estimate
selection accuracy or power.

## Reproducibility identities

Registry SHA-256:

`34edcd06994663e7752e4a4259859d53eea40df88a618f496a9e75e1c145fc2d`

Contract runner SHA-256:

`c6bae1f256c47fff2f479f87bcf6245c0d348f025d71fc16a3f8b54dd1bcb82f`

Focused-test SHA-256:

`7e4bf2d884e246a3e82440308f96c9a3340ffde190e7f1dd9baae142b4efcadb`

## Authority state

`SimulationExecuted = FALSE`

`SmokeExecutionAuthorized = FALSE`

`FeasibilityPilotAuthorized = FALSE`

`BroadSimulationAuthorized = FALSE`

`ModelSelectionEvidenceReady = FALSE`

`ConfirmationAuthorized = FALSE`

`FACETSExternalFitsIncluded = FALSE`

The next implementation unit is the deterministic paired-data and held-out
split adapter plus a no-fit preflight validator. It must preserve this registry
identity and cannot silently convert the smoke or feasibility pilot into
model-selection evidence.

An adjacent PCM/JML-only Rater-anchor/sparsity calibration has since been
completed in `rater-anchor-sparse-stress-pilot-record-0.2.3.md`. It establishes
that direct-anchor percentage cannot repair disconnected assignment and that
ratings per Person must remain a separate stress axis. It does not execute or
promote this PCM/GPCM ADEMP registry.
