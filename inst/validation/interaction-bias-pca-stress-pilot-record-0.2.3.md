# Interaction, bias-screening, and residual-PCA stress-pilot record

Status: `0.2.3-draft.19` one-seed calibration record. This is not
confirmation, does not freeze a tolerance, and does not establish false-positive
or power performance.

Interpretive addendum: the later draft.20 divergence audit supersedes any
reading of the raw severe-PCM or extreme-Person differences below as direct
evidence of an estimator-kernel defect. FACETS dropped unsupported PCM
categories by Criterion while mfrmr retained the declared step dimension, and
FACETS finite adjusted extreme displays were compared with theoretically
unbounded JML Person measures. The original numbers remain historical pilot
observations; only definition-matched, full-rank, nonextreme strata may
calibrate future numeric tolerances. See
`facets-mfrmr-divergence-audit-record-0.2.3.md`.

## Purpose

This pilot challenges three distinct diagnostic claims under two-rater,
category-imbalance, interaction, and residual-dependence conditions:

1. `facet_interactions = "Rater:Criterion"` estimates a prespecified fixed
   interaction surface;
2. `estimate_bias()` screens residual cell departures from an additive fit;
3. `analyze_residual_pca()` generates exploratory residual-structure
   hypotheses.

These are not interchangeable. A fitted interaction is not a formal bias
test, a bias-screen flag is not a power-calibrated DIF/DFF decision, and a
residual eigenvalue is not evidence of a named latent dimension.

## Execution and accounting

The 2026-08-03 extension reused the exact generated observations and seeds of
the paired FACETS driver. It covered balanced data plus two-rater complete,
one-rater-per-person, weak-overlap, middle-category-dominant,
single-category-dominant, skewed-person, weak/strong checkerboard interaction,
and residual-local-dependence scenarios for RSM and PCM.

- FACETS 4.5.0 produced all 18 expected extension reports, all with a 4.5.0
  header. A successful report is process evidence, not statistical readiness.
- The diagnostic pilot completed all 20 additive and interaction fits: 18
  rows used seeds recovered from the FACETS manifest and two balanced rows
  were diagnostic-only controls.
- The first diagnostic attempt used a different seed mapping and was
  invalidated. Only the corrected run with manifest-derived seeds is used
  below.
- Residual parallel analysis used 50 permutations. This is adequate for
  runner calibration only, not a frozen cutoff.
- The most severe category thresholds were revised from a noncentered pilot
  setting to the identified zero-sum vector `(-8, 3, 5)`, and both FACETS and
  diagnostic batches were rerun from new directories. Only this centered run
  is reported; the superseded noncentered run is not evidence.

## Adversarial findings

### Two-rater designs

The present binary connectivity audit classified every two-rater scenario as
`pass_linked`, including the one-rater-per-person design with no common
Persons. That is a false-readiness risk. In the no-common-Person cell,
mfrmr--FACETS rater MAE was 1.020 for PCM and 0.599 for RSM; maximum Person
differences were 14.27 and 13.60 logits. With only three link Persons, maximum
Person differences remained 14.72 for PCM and 19.99 for RSM.

The release gate therefore needs a minimum-rater-panel classification and a
Person-sharing graph with common-Person counts, bridge strength, articulation,
and local information. Merely having two rater labels or a connected
observation graph is not enough.

### Category imbalance

In the most severe centered PCM cell, category counts were `0;2261;136;3`:
one category held 94.2% of observations and one was unused. The current data
audit still returned `pass`. PCM mfrmr--FACETS criterion MAE was 7.474 and
Person MAE was 10.021, whereas the analogous RSM Person MAE was 0.276. The
same additive data produced a fitted-interaction RMSE of 14.981 for PCM and
0.574 for RSM; the PCM target-cell estimate was -5.248 even though the true
interaction was zero.

This is model-specific evidence against a generic category-support pass, but
the draft.20 decomposition shows that the raw FACETS parameter gap is not a
common-estimand comparison. The gate must record minimum category count,
maximum category proportion, entropy, local retained category maps,
threshold-specific information, and model family. Empty support and extreme
imbalance need separate fail-closed or review states, and an external
normalizer must reject different free step dimensions before reporting MAE.

### Interaction estimation and bias screening

For a zero-marginal checkerboard interaction of 0.4 logits, the target bias
screen detected PCM (`estimate = 0.440`, `t = 2.45`, `p = 0.017`) but missed
RSM (`estimate = 0.415`, `t = 1.59`, `p = 0.117`). For a 1.0-logit interaction,
both model screens were positive. Interaction-fit target errors were -0.031
and 0.027 logits for weak RSM/PCM and 0.048 and 0.106 for strong RSM/PCM.

Non-target screen rates within these single runs reached 0.103, and several
interaction fits required numerical review. These figures are neither a null
false-positive rate nor statistical power. Multi-seed null and non-null
calibration, multiplicity policy, estimand mapping, minimum cell information,
and readiness conditioning are required before any decision rule is promoted.
Definition-matched FACETS Table 14 bias analysis remains a separate lane: the
current batch controls fit main-effects models and do not request `?B` bias
terms.

### Residual PCA

The induced local-dependence cells were detected in both models: mfrmr PC1 was
5.503 versus a permutation cutoff of 3.319 for PCM, and 3.997 versus 3.261 for
RSM. FACETS raw-residual PC1 was 5.505 and 4.000 respectively. Standardized
row-residual correlations between programs ranged from 0.9722 to nearly 1.0
over all matched extension rows; the minimum occurred under severe category
imbalance.

High row-level agreement did not guarantee identical PCA. In weak-overlap
data, mfrmr and FACETS raw PC1 differed by 1.228 for PCM and 0.724 for RSM.
Five of 20 mfrmr rows exceeded their 50-permutation cutoff: both planted local-
dependence rows, both severely imbalanced-category rows, and one balanced RSM
diagnostic-only row. This is not a calibrated false-positive count.
Residual construction, pairwise-complete correlation, smoothing, component
retention, and permutation design must therefore remain implementation-
specific and prespecified. PCAR is exploratory hypothesis generation; a
flagged component needs an independently fitted structural alternative and a
practical-consequence analysis.

## Required next pilot

- Freeze a factorially economical, multi-seed grid for 2, 3, and larger rater
  panels; vary common-Person counts and graph topology independently.
- Calibrate category-support states by model using balanced, skewed, rare,
  locally absent, globally unused, floor, and ceiling patterns.
- Estimate conditional null false-positive rates and non-null detection for
  the bias screen and interaction fit across effect size, cell information,
  multiplicity method, and numerical-readiness state.
- Calibrate residual-PCA null behavior and local-dependence sensitivity across
  missingness/topology patterns, with a frozen residual definition and enough
  permutations for its intended quantile precision.
- Add a separate FACETS 4.5.0 Table 14 control/parser only after the bias
  estimand, centering, standard error, and multiplicity conventions are
  explicitly matched. Do not pool it with mfrmr's residual-recalibration
  screen by name alone.

## Reproduction boundary

The repository runner is `interaction-bias-pca-stress-pilot-0.2.3.R`; it
reuses generators from `facets-4.5.0-stress-pilot-0.2.3.R`. Raw FACETS and
per-replicate pilot outputs remain outside the package repository. A
candidate-linked run on disjoint frozen seeds remains required.
