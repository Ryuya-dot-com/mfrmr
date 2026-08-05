# GPCM isolated-attribution smoke record for mfrmr 0.2.3

Status: repository-only draft.42 calibration record, 2026-08-05. This is not
confirmation evidence, an external comparison, a causal attribution result, or
a frozen numerical criterion.

## Identity

| Field | Value |
| --- | --- |
| Package | mfrmr 0.2.3 development tarball from source commit `bf0b5e4` |
| Package tarball SHA-256 | `81EEE06825C6949B1EEB9054892913ED7DB9DDEEEFC98EDF90CCC23B1124F916` |
| Runner | `gpcm-isolated-attribution-pilot-0.2.3.R` |
| Runner SHA-256 | `9D3A839EA51673FD2CC6EEDF2F1CBA714831C49E0106C74D819644A83823521E` |
| R | 4.5.1 (2025-06-13 ucrt), Windows 11 x64 |
| Key packages | mfrmr 0.2.3; digest 0.6.39; psych 2.6.5 |
| Fit controls | `maxit = 60`; MML `quad_points = 7` |
| Full smoke-manifest hash | `3c5114b2657866f8874fa4ffd5fb82324b620e5c88e6540ba4d51c9e03e63b86` |
| Full pilot-manifest hash | `be1cfd7fb96df97ea6b24dbf142faaaadc021e3eb60ed62a3d27e7ccb652d60f` |
| Output directory | workspace `mfrmr/gpcm-attribution-smoke-20260805-v4` |

Retained aggregate artifacts:

| Artifact | SHA-256 |
| --- | --- |
| `scenario-manifest.csv` | `3DF1B6FBEFBA20A39C6667EEE176F94EC768F1588E874606FCC9A0B03DCA071C` |
| `manifest-audit.csv` | `7B97D157D8973C2393DCEF6E1DADF36C042653BD679CE3F1658D1CB1B0858D3E` |
| `run-results.csv` | `7385F466765B089533020D153AAE1E03941FFF3F760D6895E978C13CA2C5DF3C` |
| `paired-contrasts.csv` | `26629808506A32EFE4225283203E6C604766956ACC83ACCEEAC3CAEB61DC889B` |
| `summary.csv` | `43D5D24A7722E478EFDEA115D7F27EC8D45A322E1C50F94086D3BFCF4FFF66AB` |
| `gpcm-isolated-attribution-pilot.rds` | `FA1DEE579F0BCF366FD2F17E529BE2918F14FD8B3D0B7D6E1F6485F35F981735` |

## Structural manifest result

The fixed reference is a four-slope-level, mildly heterogeneous, five-
category GPCM with six raters, complete assignment, balanced category use, no
post-generation missingness, unique cells, no planted interaction or
diagnostic signal, and 120 planned Persons. Each challenge changes exactly one
of 11 data-generating or design axes. Forty arms include the reference, 38
executable one-axis challenges, and the genuine one-slope-level generator gap.

Every data cell is sent to four separately labelled routes: `GPCM_JML`,
`GPCM_MML`, `PCM_JML`, and `PCM_MML`. The five-replicate pilot manifest
therefore has 800 analysis rows. Within a data cell all routes use the same
seed and must reproduce one retained-data hash. Pilot seeds begin at 440001;
the reserved confirmation range begins at 940001. Confirmation remains
unauthorized. An unfiltered 800-row pilot cannot start unless its resource-
significant full execution is explicitly authorized.

The runner records centered truth recovery separately for Person, Rater,
Criterion, and step contrasts. JML and MML Person rows retain different
estimand labels. PCM is an exact generating-model reduction only in the unit-
slope arm; elsewhere it is a deliberately misspecified lower-model reference.
Free-GPCM slope error is computed only from finite optimizer values and is
labelled an optimizer log-slope diagnostic. It is not a primary recovery
metric unless parameter-level comparison eligibility is independently
established.

## Smoke outcomes

The smoke selected six data cells and all four routes, for 24 analysis rows:
the reference, two raters, one empty internal category after selection, zero
shared Persons between raters, a Person-by-rater interaction, and planted local
dependence. Smoke execution uses 24 Persons as an explicit plumbing-scale
override.

Top-line accounting:

- all 24 rows generated the intended retained data;
- 22 fits returned fitted objects and two JML zero-shared-Person rows failed
  closed before a fitted result;
- all six four-route data cells had one retained-data hash, with zero pair-
  identity violations;
- zero rows met the declared false-ready condition;
- zero free-GPCM rows had a primary slope metric eligible for recovery;
- zero rows were external-numeric eligible;
- thresholds remained `pilot_required_not_frozen`; and
- confirmation remained unauthorized.

The reference and two-rater PCM routes were inference-ready, while their GPCM
routes remained review-only because free-slope primary readiness is not
established. All four internal-zero-category routes remained review-only. In
the zero-shared-Person cell, both JML routes failed closed, GPCM-MML was
blocked, and PCM-MML remained review-only; none became inference-ready.

The planted Person-by-rater and local-dependence cells illustrate a different
boundary. Their PCM fits can be numerically and structurally ready even though
the additive fitted model omits the generating dependence. `InferenceReady`
is not a model-adequacy certificate. Interaction, bias, residual, and
consequence operating characteristics must be calibrated separately.

Residual PCA was executable on every fitted row. The first eigenvalue in the
local-dependence cell was 4.492 for GPCM-JML, 4.253 for GPCM-MML, 4.470 for
PCM-JML, and 4.220 for PCM-MML, compared with 3.510, 3.385, 3.566, and 3.487
on the matched reference seed. This one-seed increase is descriptive. It has
no null distribution, Monte Carlo uncertainty, frozen decision rule, or
multiplicity interpretation.

## Adversarial interpretation and next use

This smoke validates attribution plumbing, not statistical performance.

- Common seeds induce a paired perturbation but do not prove causal
  attribution: changing dimension or simulation structure may also change the
  random-number stream after the shared upstream draws.
- A baseline-to-challenge delta is reported only with parameter-class
  coordinate flags. Changing raters, slope levels, categories, or Persons
  invalidates the corresponding direct coordinate comparison.
- A ready lower-model row cannot validate a free-GPCM slope, rescue an
  unsupported topology, or become evidence of FACETS, TAM, or immer agreement.
- FACETS 4.5.0 is eligible only for a later exactly normalized JML RSM/PCM or
  unit-slope reduction lane. Its Table 7 discrimination output is not a free-
  GPCM slope target.
- The first replicated pilot should start with the reference, unit/strong/
  near-boundary slope regimes, two raters, weak bridge, category support,
  outcome-dependent missingness, interaction, and local-dependence arms. It
  must estimate Monte Carlo error and runtime before selecting a larger grid.

No tolerance, replication count, external normalizer, support envelope,
candidate identity, or confirmation decision is frozen by this record.
