# FACETS/mfrmr divergence audit for mfrmr 0.2.3

Status: `0.2.3-draft.20` adversarial pilot diagnosis. This is not confirmation
evidence and does not authorize release.

## Purpose

This audit asks why paired FACETS 4.5.0 and mfrmr JML results differ before
classifying the difference as an mfrmr estimator defect. It reuses the
completed draft.19 pilots but introduces a fail-closed comparison contract:

1. are the response family, category map, retained step dimension, constraints,
   and parameter orientation genuinely common;
2. is the constrained main-effect design estimable;
3. is the reported quantity the same estimand, especially for extreme JML
   Person scores; and only then
4. what numerical discrepancy remains against truth and the external program.

The repository audit is
`facets-mfrmr-divergence-audit-0.2.3.R`. Raw FACETS output and generated audit
tables remain outside the candidate source tree.

## Classification framework

| Cause class | Meaning | 0.2.3 response |
| --- | --- | --- |
| Estimand or model-definition mismatch | The programs fit different category maps, retained steps, constraints, likelihoods, or parameters. | Refuse the parameter comparison; create a matched control or report the difference descriptively. |
| Exact nonidentification | A free direction remains after the declared constraints. | Fail statistical readiness before optimization; name the confounded direction where possible. |
| Weak information | The model is identified in principle but estimates depend heavily on a small bridge, rare category, or boundary. | Return review status with quantitative local-information evidence; validate recovery by design stratum. |
| Reporting convention | The same theoretical problem is displayed differently, such as FACETS' finite adjusted extreme score versus an unbounded JML measure. | Preserve typed status and compare only like with like; optional display adjustments must be named and separate. |
| Implementation defect | A difference remains after model, identification, and reporting contracts agree and is not explained by Monte Carlo or optimization error. | Correct code and add a reduction/regression test before rerunning pilot evidence. |
| Unsupported scope | FACETS fits a model that the current one-scale mfrmr contract does not claim. | Route to the later architecture; do not disguise it as a 0.2.3 numerical fix. |

This ordering is intentionally adversarial. Agreement is not accepted merely
because correlations are high, and disagreement is not blamed on the
estimator merely because an external package returns a different number.

## Finding 1: the severe PCM category comparison was not definition-matched

The severe PCM cell contained mfrmr scores `1;2;3;4` with counts
`0;2261;136;3`. Within Criterion, the observed category counts were:

| Criterion | Category 2 | Category 3 | Category 4 |
| --- | ---: | ---: | ---: |
| C01 | 451 | 29 | 0 |
| C02 | 446 | 33 | 1 |
| C03 | 459 | 21 | 0 |
| C04 | 445 | 34 | 1 |
| C05 | 460 | 19 | 1 |

The FACETS PCM control used `#` to assign a partial-credit scale to each
Criterion and did not request `K`. FACETS therefore retained only two
categories for C01 and C03 and three for C02, C04, and C05. mfrmr retained the
declared four-category map and estimated three steps for every Criterion.
Several unsupported mfrmr steps separated to magnitudes of roughly 30--71
logits, with Criterion locations compensating.

Consequently, the previously reported PCM Criterion MAE of 7.474 and Person
MAE of 10.021 do not compare a common step dimension. They remain useful as a
warning that the existing comparison normalizer and readiness state failed
closed too late, but they are not evidence by themselves of a faulty PCM
likelihood kernel. The row-level standardized residual correlation of 0.9988
is compatible with similar fitted response behavior under non-comparable
parameter decompositions; it does not rescue the parameter comparison.

The audit found one category-contract failure among the 18 extension rows:
`PCM/category_single_dominant`. In the 44-row expanded pilot, both RSM and PCM
`unused_middle_category` rows also failed the retained-category contract.

Required correction sequence:

- add per-step-facet observed-support, declared-category, retained-category,
  and estimable-step checks to readiness;
- make external normalization refuse element/Person tolerances whenever the
  category map or free step dimension differs;
- use a matched PCM core in which every declared category occurs within every
  step-facet level;
- retain separate edge controls for FACETS category dropping and explicit
  `K` behavior; and
- do not treat an unobserved boundary threshold as estimable until 0.2.4 can
  supply a typed threshold anchor or frozen calibration.

FACETS documents that `K` can preserve an unobserved intermediate category.
An unobserved extreme category has no data-based threshold estimate; retaining
it requires an anchor or another explicit assertion. mfrmr should preserve the
user's declared category semantics for reproducibility, but must not translate
that preservation into inference-ready estimated steps.

## Finding 2: graph connectivity was weaker than estimability

The audit constructed the current main-effect location design with Person
noncentered and Rater/Criteria sum-to-zero. This is a necessary audit for the
pilot parameterization, not yet a complete Fisher-information audit for every
model and interaction.

| Two-rater design | Rows | Free columns | Rank | Nullity | Condition number |
| --- | ---: | ---: | ---: | ---: | ---: |
| Complete | 600 | 65 | 65 | 0 | 7.75 |
| One rater per Person; no common Persons | 300 | 65 | 64 | 1 | 5.91e32 |
| Three common Persons | 315 | 65 | 65 | 0 | 26.09 |

The zero-common-Person design has an exact free direction: the rater contrast
is confounded with the locations of the two nested Person groups. Sharing all
Criteria does not identify that contrast. The existing connected-components
audit returned `pass_linked`, so this is a readiness implementation gap rather
than an FACETS-versus-mfrmr numerical race.

The same audit found rank deficiency in both RSM and PCM for
`small_n_sparse` (nullity 3), `disconnected_components` (nullity 2), and
`weak_single_bridge` (nullity 1) in the expanded pilot. A graph with one path
can therefore still be rank deficient under the actual parameterization.

Required correction sequence:

- construct the free-coordinate design implied by active parameters,
  constraints, anchors, and structural absences;
- check exact rank before fitting and expose aliased parameter directions;
- after exact identification, assess weak information using singular values
  or the observed/expected information in the fitted model rather than a
  universal condition-number cutoff;
- stratify two-rater results by common-Person count and assignment topology;
  and
- keep JML design identification separate from MML population-linking
  assumptions. An MML model may borrow a shared latent distribution across
  panels, but that is assumption-based linking and requires assignment and
  population-invariance evidence.

## Finding 3: large Person maxima were dominated by extreme-score convention

In the weak-overlap two-rater data, nonextreme Person estimates were close,
while raw maxima were driven by extreme totals:

| Model | Person class | n | MAE | Maximum absolute difference |
| --- | --- | ---: | ---: | ---: |
| RSM | nonextreme | 55 | 0.1465 | 0.1693 |
| RSM | extreme high | 5 | 16.2733 | 19.9870 |
| PCM | nonextreme | 58 | 0.1190 | 0.1381 |
| PCM | extreme low/high | 2 | 14.4417 | 14.7208 |

A pure JML extreme Person measure is unbounded. FACETS reports a finite
display measure using its documented default extreme-score adjustment, while
mfrmr's optimizer currently returns a large finite proxy. Those values are
not the same primary estimand and their difference is not a convergence
metric.

Required correction sequence:

- represent the primary JML extreme Person result as a typed unbounded status
  with `NA` or signed infinity, not an optimizer-dependent finite estimate;
- if a finite adjusted display measure is offered, name its adjustment,
  provenance, and non-estimation role explicitly;
- compare nonextreme Person measures numerically and compare extremes by
  low/high status plus a separately matched display convention; and
- exclude extreme display values from correlations, maxima, PCA inputs, and
  other summaries unless the summary explicitly targets that convention.

FACETS and mfrmr also use different convergence contracts. FACETS' default
UCON/JMLE criteria use score residual and measure-change rules, whereas
mfrmr's terminal free-coordinate gradient is an optimizer stationarity check.
A successful FACETS process and a small mfrmr gradient must both be retained,
but neither substitutes for a common score, likelihood, or prediction check.

## Finding 4: interaction, bias, and residual PCA need definition contracts

The draft.19 planted interaction and residual-dependence results remain useful
as generator and diagnostic calibration, but they do not yet establish a
FACETS-equivalent diagnostic:

- mfrmr's additive-model residual bias screen is not FACETS Table 14 `?B`;
- interaction centering, conditioning, standard errors, and multiplicity must
  be matched before numeric comparison;
- residual PCA depends on residual standardization, matrix construction,
  missing-pair handling, smoothing, retention, and permutation rules; and
- a large residual component may diagnose category-map failure or sparse
  topology rather than a missing latent dimension.

The corrected comparison hierarchy is: matched row predictions/residuals,
then a frozen residual-matrix construction, then eigenvalue and loading
comparison, followed by an independently fitted structural alternative and a
practical score/consequence assessment. PCAR remains exploratory.

## Long-term architecture without local optimization

The current matched-core failures must be repaired before adding broad FACETS
scope. They do, however, clarify the future object model. Two independent keys
are required:

- `ScaleId`: category values and labels, response-scale structure, threshold
  namespace, anchors, transforms, and version; and
- `ObservationModelId`: response family, `ScaleId`, active facets, signs,
  weights, offsets, and permitted interactions for a row.

Using one identifier for both would make a mixed-format API ambiguous. A
structurally inactive facet must also be distinct from an observed missing
value. The safe staged sequence is:

1. 0.2.3: estimability, category-information readiness, typed extremes, and
   fail-closed external comparison for the existing one-scale models;
2. 0.2.4: versioned single-scale calibration with element and threshold
   anchors, integrity hash, constraint/category schema, unknown-level policy,
   compatibility policy, and frozen new-Person scoring;
3. 0.2.5a: multiple ordinal `ScaleId` values within a common response family,
   with exact reduction to the current one-scale fit;
4. 0.2.5b: per-scale dichotomous/RSM/PCM routing after cross-scale linking and
   identification tests; and
5. later promotion: Poisson/count families and general observation-specific
   active-facet routing after each family passes reduction, recovery, sparse
   topology, and calibration-compatibility gates.

Accepting repeated rows is not equivalent to modelling within-cell
dependence. mfrmr should retain its duplicate warning, add an explicit
`ObservationId`/`ReplicateId`, distinguish accidental duplication from an
intended Event/Occasion facet, and only later claim clustered or random-effect
dependence after a separate estimand and validation program. FACETS accepting
multiple observations per cell does not prove those observations are
conditionally independent or that dependence is modelled.

Similarly, a headline missingness percentage is not a support envelope.
FACETS states that very sparse data still need sufficient overlap/rotation to
locate parameters. mfrmr should validate topology, rank, information, recovery,
and assignment assumptions instead of competing on a maximum missing-rate
number.

## Immediate 0.2.3 decision

Do not add `ScaleId`, count models, or a general active-facet dispatcher as a
reaction to the current pilot discrepancies. They would expand the state
space before the existing comparison and readiness contracts can reject
known invalid rows. Draft.20 instead adds four prerequisites to the M2 freeze:

1. constrained estimability audit;
2. category-map/retained-step contract;
3. typed extreme-score comparison policy; and
4. definition-specific interaction/bias/PCAR contracts.

After these are implemented, the existing paired simulations must be rerun on
new pilot seeds. Only common-estimand, full-rank, nonextreme rows may calibrate
numerical tolerances; rejected edge rows calibrate failure behavior.

## Official FACETS references

- Product capabilities and sparse-design qualification:
  <https://www.winsteps.com/facets.htm>
- Multiple models and partial-credit `#` routing:
  <https://www.winsteps.com/facetman/models.htm>
- Rating scales and `K`:
  <https://www.winsteps.com/facetman/ratingscale.htm>
- Unobserved categories:
  <https://www.winsteps.com/facetman/unobserved.htm>
- Extreme scores:
  <https://www.winsteps.com/facetman/xtremescore.htm>
- JMLE convergence criteria:
  <https://www.winsteps.com/facetman64/convergencecriteria.htm>
- Element/scale anchor output:
  <https://www.winsteps.com/facetman/anchorfile.htm>
- Structurally inactive facet element zero:
  <https://www.winsteps.com/facfman/1_2_1.htm>
- Multiple observations per cell:
  <https://www.winsteps.com/facetman/data.htm>

These references define FACETS behavior and advertised scope. They do not make
FACETS ground truth and do not replace truth-first simulation or matched
estimand checks.
