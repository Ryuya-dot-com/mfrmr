# Residual model-bootstrap pilot, 2026-09-28

## Question and frozen design

This pilot asks whether the new RSM/PCM fitted-model PCA reference can supply
an interpretable residual-structure screen before considering GPCM admission.
It separates false flags under the generating null, sensitivity to departures,
and unavailable results. It does not qualify a 5% test or select a latent
dimension count. Existing TAM dimensionality runs concern external binary
models/integration and cannot answer this fitted-residual question.

The runner is `residual-model-bootstrap-20260928.R`. Before execution it writes
a fixed 96-dataset roster, source hashes and session information to
`validation-results/residual-model-bootstrap-20260928/protocol.rds`.
All 8 cells have 12 independent outer replicates and 39 planned bootstrap
refits per eligible dataset. Seeds are paired across cells, independent across
outer replicates. No wall-clock cutoff removes cells, and no failed dataset or
bootstrap draw is replaced. Checkpoints allow resumption without recomputation.

Each dataset has 80 Persons, four fixed raters, six criteria and categories
0, 1, 2. The fitted model uses MML, fixed N(0,1), 31-point fixed quadrature,
400 iterations and relative tolerance 1e-9. Step widths are .6 for RSM and
.35, .45, ..., .85 by criterion for PCM; facet locations are centered.

| Cell | Generating structure | Assignment |
| --- | --- | --- |
| rsm_null_dense | RSM, one N(0,1) ability, conditional independence | Fully crossed |
| pcm_null_dense | PCM, one N(0,1) ability, criterion-specific steps | Fully crossed |
| block_dense | Two three-criterion blocks, unit marginal variances, correlation .5 | Fully crossed |
| sd15_dense | One ability with SD 1.5, fitted SD held at 1 | Fully crossed |
| null_common / block_common | RSM null / block structure | Common-Person bridges |
| null_rotating / block_rotating | RSM null / block structure | Rotating rater pairs |

Dense data contain 1,920 ratings. Both sparse designs contain 960, with exactly
240 ratings per rater. For common-Person bridges, eight Persons receive all
four raters, 56 receive a two-rater panel (28 each in panels R1/R2 and R3/R4),
and 16 receive one rater (four per rater). Rotation assigns 20 Persons each to
R1/R2, R2/R3, R3/R4 and R4/R1. All Persons have every criterion. These are shared
observations, **not fixed parameter anchors**. Rater connectivity does not
imply that every rater pair shares Persons: the rotation has no R1/R3 or R2/R4
overlap. Missing residual correlations are not zero-filled or repaired.

The primary screen is the **first Criterion-aggregated residual eigenvalue**
above its .95 model-reference quantile. Secondary outcomes are any criterion
component above its own unadjusted cutoff, the first overall eigenvalue, and
scope availability. The any-component rule is explicitly not a 5% familywise
test. Different PCA aggregations do not measure the same target.

Rates retain the planned outer denominator. If an outcome is unavailable, the
record gives its possible rate interval (all unavailable outcomes negative
versus positive) and an exact-binomial Monte Carlo envelope. A conditional rate
among available datasets is labeled separately. Twelve outer datasets cannot
establish a 5% false-flag rate (even 0/12 has a two-sided exact 95% upper limit
of about 26.5%). Thirty-nine inner draws give a coarse tail reference. These
counts are a pilot to expose major availability/interpretation problems, not
a release threshold or a substitute for confirmation with prespecified precision.

## Why block dependence and two abilities are not independent conditions here

For independent standard-normal theta, u1 and u2, let
z_b = sqrt(.5) theta + sqrt(.5) u_b. Then Var(z_b)=1 and Cov(z1,z2)=.5.
Using z_b in the adjacent-category predictor can be described either as a
shared general component plus Person-by-block effects, or as two correlated
block traits with simple structure. The conditional response probabilities
are identical and so is their marginal distribution. The generator implements
this equality directly; a separate run with a different label would not test
whether the causes can be distinguished. This is a mathematical property of
these declared conditions, not a claim that every testlet and multidimensional
model is equivalent. It also preserves unit marginal SD, separating this block
departure from the SD=1.5 population-misspecification cell.

The general relationship between constrained testlet, bifactor and second-order
models is established in [Rijmen (2010), Journal of Educational Measurement,
47, 361–372](https://doi.org/10.1111/j.1745-3984.2010.00118.x), also summarized
in [ETS RR-09-37](https://www.ets.org/research/policy_research_reports/publications/report/2009/hycg.html).
The simple normal-covariance calculation above is the derivation used for this
pilot, not a reproduction of the paper's empirical analysis.

## Decision rules for the next development step

- Poor availability must be traced to source fitting, refitting, undefined
  pairs or indefinite correlation matrices; do not call it low false-flag risk.
- A gross false-flag excess under the matched null blocks stronger claims and
  triggers estimator/reference review before increasing simulation counts.
- Similar flags under block and population departures cannot identify a
  substantive dimension. The UI/help must retain this distinction.
- Stable informative criterion summaries alongside unavailable overall PCA
  support purpose-specific diagnostics, not automatic fallback to another
  aggregation or automatic matrix completion.
- Subsequent confirmation must freeze effect sizes, independent-unit/design
  assumptions, multiplicity, numerical sensitivity and Monte Carlo precision.
  This pilot alone does not admit GPCM, JML or dependent-effect refits.

## Execution result

All **96/96 datasets and 3,744/3,744 bootstrap refits completed**. Every source
fit and bootstrap refit passed numerical readiness; there were no source-fit
errors or captured bootstrap warnings. PCA availability failures remained and
are not described as successful statistical checks. Raw per-dataset RDS files
retain the draws, trial records, source readiness and warnings. `outcomes.csv`,
`summary.csv` and `bootstrap-trials.csv` retain the complete roster and counts.

| Condition | First Criterion component flagged / 12 | Any Criterion component flagged / 12 | Overall reference available / 12 |
| --- | ---: | ---: | ---: |
| RSM null, dense | 1 | 3 | 12 |
| PCM null, dense | 1 | 3 | 12 |
| Block structure, dense | 12 | 12 | 12 |
| Ability SD 1.5, dense | 1 | 12 | 12 |
| RSM null, common Persons | 1 | 3 | 0 |
| RSM null, rotating pairs | 0 | 5 | 0 |
| Block structure, common Persons | 11 | 12 | 0 |
| Block structure, rotating pairs | 12 | 12 | 0 |

Criterion references were available for all 96 datasets. Rater references,
like overall references, were available for all 48 dense datasets and none
of the 48 sparse datasets. Rotation lacked pairwise overlaps. Common-Person
bridges supplied overlaps but their pairwise residual correlations were not
consistently positive semidefinite. This was an observation/correlation
problem, not an optimizer failure. No correlations were completed or smoothed.

**Answers to the questions.** The first Criterion eigenvalue detected the
specified block departure in 11–12 of 12 datasets, while matched-null flags
were 0–1 of 12. This shows sensitivity in these conditions, not accurate cause
identification or a general 5% test. Exact 95% Monte Carlo intervals are
0–26.5% for 0/12, 0.2–38.5% for 1/12, 61.5–99.8% for 11/12 and 73.5–100% for
12/12. Do not pool conditions as independent trials: their seeds are paired.

Scanning all six component cutoffs flagged 3–5 of 12 correctly specified
null datasets (25–42%). This directly illustrates why the componentwise .95
reference cannot be advertised as a .05 familywise rule. No post-hoc component
selection or inferred dimension count is added. With ability SD 1.5, the first
Criterion component flagged only 1/12, although some component flagged in all
12 datasets. A quiet first component therefore did not establish adequacy of
the population assumption. Overall-first flags in this cell were 0/12.

**Development consequences.** Retain the exploratory scope. State the
componentwise/multiple-scan distinction in summaries and both plotting
backends, and distinguish unavailable observed PCA from failed refits in the
status message. Give users purpose-specific aggregation guidance; do not
automatically switch to Criterion aggregation or repair a matrix when overall
PCA fails. Precision confirmation and GPCM admission remain separate decisions;
this pilot neither qualifies an omnibus test nor justifies a larger arbitrary
factorial study. A stronger release claim would require a prespecified joint
screen, its numerical sensitivity and adequately precise error-rate assessment.

## Computation and output review

Profiling found that unused marginal-fit/pairwise tables dominated the PCA
workflow. `analyze_residual_pca(fit)` now requests the existing observation-
residual diagnostic route without those marginal tables. In a local two-refit
comparison, elapsed time fell from 14.85 to 4.85 seconds. The observed residual
matrix, all three scopes' first two stored replicate eigenvalue vectors and
trial records were **identical**. This timing is a local diagnostic measurement,
not a cross-machine performance guarantee.

Eight completed datasets from the original path were retained. The remaining
88 were executed with the equivalent optimized path and ten processes (the
machine reports ten performance cores and 36 GiB memory). Four active,
uncheckpointed datasets were administratively interrupted during the restart
and regenerated with their original seeds; no data-dependent replacement or
roster change occurred. `execution-amendment.rds` records the changed source
hash, retained IDs and equality check; `completion.rds` verifies the final
roster and source. The original protocol remains unchanged. Later display-only
changes do not alter the stored draws or the reported rates.

Visual review also caught an unrelated but consequential renderer defect:
residual PCA had fallen through to generic tabular ggplot conversion, which
summed component indices by the method-name column. A dedicated conversion now
retains the actual eigenvalues, reference means/cutoffs, excesses and signed
loadings. Tests compare built plot coordinates and encodings to the saved data,
including replay and monochrome style, rather than merely checking the ggplot
class. Base plots now show the reference legend and the multiple-scan note;
internal method codes are not used as plotted variable labels.
