# Factor-structured TAM/immer/mfrmr JML stress contract for mfrmr 0.2.3

Status: repository-only Draft.76 feasibility contract, executed under the
Draft.77 checkpoint contract on 2026-08-09.

## Purpose

Draft.76 extends the Draft.75 common-estimand RSM/PCM comparison across sample,
exposure, assignment, endpoint, dependence, anchor, and missingness conditions.
It is a calibration design, not a package contest or a correction-selection
rule. Every result remains `EvidenceReady = FALSE`.

The complete Cartesian product is prohibited. Several requested quantities are
algebraically dependent, and a full product would devote most computation to
redundant or unidentified cells. The design instead has:

1. a deterministic 22-dataset feasibility smoke;
2. a guarded 290-dataset, five-replicate factor calibration; and
3. later targeted interactions and high-replication coverage/confirmation
   stages, with untouched seeds.

## Factor identity

The manifest separates controlled settings from realized diagnostics.

| Factor | Contract |
| --- | --- |
| Persons | Distinct generated Persons. |
| Observed responses per Person | Realized nonmissing responses. This is derived, not independently randomized. |
| Raters | Declared Rater facet levels. |
| Criteria | Declared Criterion facet levels. |
| Categories | Declared ordered score categories. |
| Assignment sparsity | Observed Person-Rater pairs divided by the complete panel. |
| Rater workload imbalance | Target sampling ratio plus realized workload Gini and max/min ratio. |
| Endpoint rates | Minimum/maximum response fractions and all-minimum/all-maximum Person fractions are recorded separately. |
| Local dependence | Gaussian-copula correlation within Person-Rater response clusters, preserving each response's marginal model probability. |
| Anchor rate | Fraction of Rater levels intended to be fixed at generating values. |
| Missing mechanism | None, MCAR, observed-Rater MAR, or score-dependent MNAR, with target and realized rates. |

For the current Person x Rater x Criterion design,

`responses per Person = assigned Raters per Person * Criteria * observed fraction`.

Consequently, responses per Person, total Raters, Criteria, assignment density,
and missingness cannot all be varied independently. All are retained in the
analysis table; effects are interpreted conditionally, not as five orthogonal
main effects.

## Data-generating boundaries

RSM and PCM are generated under their matched unidimensional additive kernels.
Assignment is applied at the Person-Rater block, so all Criterion ratings from
an assigned event remain together before response-level missingness.

Local dependence is a deliberate fitted-model violation. It uses correlated
normal variates converted to uniforms within Person-Rater clusters and samples
from the original category cumulative probabilities. Its bias, RMSE, and rank
metrics are robustness results, not correct-model recovery. Model-based
coverage under local dependence or MNAR is descriptive until a robust
uncertainty estimand is declared.

Forced endpoint Persons are split equally between all-minimum and all-maximum
scores. Natural extremes are recorded separately and may arise in any
low-exposure cell.

## Anchor guard

Anchor rows are generated and retain the exact truth-based Rater anchor table,
but fitting is currently blocked with
`common_anchor_basis_not_yet_verified`. mfrmr anchors facet levels directly;
TAM can fix basis coefficients; immer exposes fixed cumulative item-category
positions rather than the same named facet constraint. No anchor-rate
comparison is eligible until one reduced design plus offset representation is
proved to impose the same response-surface constraints in all three engines.

## Performance measures

Metrics are not pooled merely because they share a familiar label.

| Metric | Current definition and eligibility |
| --- | --- |
| Bias | Mean location-aligned error on the cumulative-difficulty surface and centered Rater/Criterion positions. |
| RMSE | Root mean squared error on the same scopes. |
| Rank recovery | Spearman correlation for at least three levels plus pairwise order accuracy for non-tied truth pairs. |
| Recovery separation | `SD(true facet positions) / RMSE`; this is a recovery signal-to-error ratio, not the reported Rasch/FACETS separation statistic. |
| 95% SE coverage | Withheld on the common surface until covariance can be transformed to that estimand. |
| Reported facet separation | Withheld until formula, orientation, measure set, and SE basis are definition-matched. |
| Fit returned / finite surface | Separate binary denominators retaining every attempted method row. |
| Numerical convergence | mfrmr optimizer code zero, mfrmr profile completeness, or an explicitly labelled external `iter < maxiter` proxy. These definitions are never pooled as one common convergence proof. |
| Evidence eligibility | Numerical availability and estimator/Person-boundary eligibility combined, separately from convergence. |

The loaded TAM and immer objects expose marginal basis-parameter SE vectors,
not a covariance matrix for the expanded cumulative-difficulty surface. The
smoke also confirms that their classical postscales change point estimates
while leaving the returned basis SE vector numerically unchanged. Therefore a
postscaled point estimate plus an untransformed SE cannot be silently treated
as a Wald interval for the corrected common estimand.

A later uncertainty lane may use either a proved native-basis truth mapping for
individual coefficients or a prespecified refit/bootstrap covariance for
common contrasts. The choice must be frozen before coverage is inspected.

## Smoke and pilot manifests

The smoke crosses RSM/PCM with 11 profiles: reference; low/high size-exposure;
sparse unequal workload; forced endpoints; local dependence; MCAR; Rater-MAR;
score-MNAR; guarded 25% anchors; and combined adversity.

The guarded pilot contains 29 profiles, both models, and five replicates
(`290` datasets). It varies low/high Persons, exposure, Raters, Criteria,
categories, density, workload, extreme rate, local dependence, anchor rate,
and three missing mechanisms, then adds two targeted interaction profiles.
Five replicates are feasibility calibration only. They cannot estimate 95%
coverage or rare failure rates with acceptable Monte Carlo precision.

Draft.77 executed this manifest after correcting every one-Rater-per-Person
profile to the expected structurally unidentified state. The final accounting
is 230 fitted datasets with 2,070 retained mode rows, 40 structural negative
controls, and 20 anchor guards. Dataset-level atomic checkpointing and the
completion marker are governed by
`tam-immer-jml-factor-checkpoint-contract-0.2.3.md`; descriptive results are in
`tam-immer-jml-factor-pilot-record-0.2.3.md`.

## Negative controls and prohibitions

- The low-information one-Rater-per-Person profile has no common Persons across
  Raters and is expected to be structurally unidentified.
- Anchor profiles are expected guarded non-attempts, not failed fits.
- Original raw JML eligibility is denied whenever observed Person scores are
  extreme, even if a finite numerical trace exists.
- Local dependence and MNAR rows are never pooled with correctly specified
  recovery rows.
- `RecoverySeparation` is never relabelled as reported facet separation.
- `iter < maxiter` is never called proof that the score equation converged.
- The five-replicate pilot freezes no tolerance, correction, ranking, sample-
  size recommendation, or release decision.
