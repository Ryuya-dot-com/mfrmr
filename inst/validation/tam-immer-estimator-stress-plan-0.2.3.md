# TAM/immer estimator stress plan for mfrmr 0.2.3

Status: repository-only planning contract, Draft.79 checkpointed matched-
topology structural smoke completed 2026-08-09.

This plan operationalizes the TAM and immer lanes in
`release-gate-spec-0.2.3.md`. Draft.75 adds an identity runner and reports a
deterministic four-dataset normalization smoke. Draft.76 adds a factor registry,
22-dataset feasibility smoke, and guarded 290-dataset calibration manifest.
Draft.77 executes that manifest with atomic checkpoints and deterministic
review; it does not authorize confirmation, add a package dependency, or
create a public mfrmr capability. Draft.78 repairs the low-exposure topology
with explicit bridge Persons and assigned/observed Rater-graph audits. All
performance grids and acceptance
thresholds remain `pilot_required`.

## Questions, not a software contest

The study answers four separate questions:

1. How do mfrmr's current MML structural estimates compare with a matched TAM
   1D MML likelihood and integration evaluation?
2. How do unadjusted, extreme-score-adjusted, and finite-item-bias-corrected JML
   conventions behave against common truth under balanced and adversarial
   many-facet designs?
3. What do immer CML/CCML results contribute for conditional Rasch-family
   structural estimands that are genuinely shared?
4. How do mfrmr's additive-model readiness and diagnostics behave when data are
   generated from an HRM-style latent-rating/local-dependence process?

No answer is decided by package vote, correlation, or closeness to FACETS.
Truth recovery, uncertainty, failure behavior, and between-program differences
are reported separately.

## Audited package strata

| Stratum | Intended role | Identity policy |
| --- | --- | --- |
| TAM CRAN 4.3-25 | Primary TAM MML/JML reference. | Record source repository, package digest, R/dependency versions, call/default arguments, and output hash. |
| immer CRAN 1.5-13 | Primary conditional/JML/HRM reference. | Apply the same identity record and freeze design-matrix construction. |
| TAM development 4.4-2 | Optional version sensitivity only. | Never pool with CRAN; rerun source/default audit first. |
| immer development 1.6-1 | Optional version sensitivity only. | Never pool with CRAN; rerun source/default audit first. |
| FACETS local 4.5.0 | Existing selected JML stress stratum. | Retain the separate executable/report/parser contract. |

The installed package is not assumed to equal the audited stratum. A runner
must fail closed or create a new labelled stratum when version, source digest,
function defaults, design construction, or dependency identity differs.

## Frozen method-mode names

| Scenario ID | Method-mode contract | Eligible role |
| --- | --- | --- |
| `EXT-TAM-MML-1D` | TAM 1D MML with matched population/design/constraints and common integration evaluation. | Structural parameters and comparable observed-data likelihood quantities only. |
| `EXT-TAM-JML-RAW` | `tam.jml()` with `adj = 0`, `bias = FALSE`. | Original unadjusted JML structural parameters only when no Person score is extreme; otherwise retain the failed/nonfinite row. |
| `EXT-TAM-JML-ADJ` | `tam.jml()` with documented `adj = .3` and `bias = FALSE`. | Adjustment-labelled structural and Person sensitivity; the adjusted Person values enter structural estimation. |
| `EXT-TAM-JML-BC` | `tam.jml()` with `adj = 0`, `bias = TRUE`. | Postscaled structural parameters, eligible only without extreme Persons; free item-basis coefficients are multiplied by `(I - 1) / I`. |
| `EXT-TAM-JML-BC-ADJ` | TAM `adj = .3`, followed by its documented bias reduction. | Combined adjustment and postscale sensitivity; never substituted for either factor alone. |
| `EXT-IMMER-JML-RAW` | `immer_jml()` with `est_method = "jml"`, `eps = .3`. | Original unadjusted JML only without extreme Persons; with extremes, epsilon changes those Person scores before structural estimation. |
| `EXT-IMMER-JML-EPS` | `immer_jml()` with `est_method = "eps_adj"`, `eps = .3`. | Distinct epsilon/fuzzy Person-and-item estimating equation, not merely an extreme-Person display. |
| `EXT-IMMER-JML-BC` | `immer_jml()` with `est_method = "jml_bc"`, `eps = .3`. | The `jml` extreme handling followed by item-basis postscaling by `(Ibar - 1) / Ibar`; never treated as raw JML. |
| `EXT-IMMER-CML` | `immer_cml()` on an eligible design-matrix Rasch-family case. | Structural parameters retained after conditioning. |
| `EXT-IMMER-CCML` | `immer_ccml()` on an eligible design-matrix Rasch-family case. | Structural parameters retained after conditioning. |
| `ALT-IMMER-HRM-LD` | `immer_hrm()`-compatible latent true-rating/local-dependence generator and fit. | Alternative-model diagnostic stress only. |

mfrmr uncorrected JML and the selected FACETS convention are included in the
same replicate registry but keep their existing identities. There is no
generic `external_jml` label in result data.

## Comparison contract

Before numeric normalization, each parameter/statistic must pass all applicable
checks:

- response family and category map are identical;
- observations, weights, missing rows, and active facets are identical;
- design-matrix columns and hashes are mapped explicitly;
- declared, observed, retained, free, fixed, and unsupported step dimensions
  agree for the parameter being compared;
- anchors, centering constraints, free-coordinate basis, signs, and scale
  origin are transformed to a documented common coordinate system;
- estimator, bias correction, extreme-score adjustment, person treatment,
  integration rule, and software stratum are exact identities;
- the constrained design is estimable and the parameter is not hidden by a
  boundary, conditioning, or category-support failure; and
- expected, eligible, rejected-by-reason, missing, and failed denominators are
  retained for every aggregate.

A row that fails one check may still inform definition or failure behavior, but
cannot enter a parameter-agreement statistic.

## Stress-factor registry

Exact factor levels and replication counts are frozen only after feasibility
pilots. The final grid must cross enough factors to expose interactions rather
than varying one condition at a time.

| Axis | Mandatory states | Primary risk challenged |
| --- | --- | --- |
| Response structure | RSM; current rectangular PCM; binary reduction controls. | Family/design translation and step dimension. |
| Person information | Balanced; low fixed observations per Person; highly unequal exposure. | Incidental-parameter bias and ambiguous effective item count. |
| Person-count sequence | Increasing Persons while observations per Person stay fixed; increasing both separately. | JML asymptotics versus ordinary information growth. |
| Rater panel | Two-rater complete; two-rater sparse with shared Persons; zero-common-Person negative control; larger crossed panel. | Minimal identification and correction transport. |
| Topology | Robustly connected; weak bridge; articulation; disconnected. | False readiness and unstable contrasts. |
| Missingness | Planned incomplete design; MCAR deletion; covariate-dependent deletion; outcome/severity-related sensitivity. | Conditioning and unequal information. |
| Workload | Balanced; uneven rater workload; one locally dominant rater. | Effective exposure and severity recovery. |
| Category support | Balanced; skewed; dominant middle/single category; rare/unused category; floor/ceiling. | Threshold estimability and extreme handling. |
| Targeting/severity | Well targeted; shifted population; severe/lenient rater; combined mistargeting. | Separation, finite displays, and bias. |
| Anchors | None; current matched element/group anchors where externally expressible; conflicting/unmatched negative controls. | Identification and invalid comparison rejection. |
| Structural misspecification | Additive null; planted rater-by-criterion interaction; residual local dependence; HRM-generated latent rating. | Bias-screen, PCAR attribution, and model-family boundary. |
| Replication structure | Unique cells; repeated observations only with an explicit Occasion/Event facet; unlabelled duplicate negative control. | Within-cell dependence and pseudo-replication. |

Every cell records an ADEMP specification, generator hash, seed role, expected
fit count, timeout, and failed-run policy. Pilot and confirmation seeds are
disjoint.

## Estimands and performance measures

Structural estimands are transformed facet contrasts and supported step
coordinates. Person estimands enter only matched JML modes and are partitioned
into nonextreme, low-unbounded, high-unbounded, and explicitly adjusted display
states. MML EAP Persons are never compared with JML Persons. CML/CCML Persons
are ineligible.

For every eligible model/parameter/design/method cell, retain:

- signed bias, absolute bias, RMSE, empirical SD, and convergence/readiness
  rate against generating truth;
- SE availability, mean model SE, empirical SD, interval width, and coverage
  only where the method defines the interval;
- false-ready, false-blocked, boundary, warning, timeout, singular, and hard-
  failure rates;
- signed and absolute transformed between-program differences with correlation
  descriptive only;
- expected, eligible, rejected, missing, failed, and completed replicate counts;
  and
- Monte Carlo SE or a prespecified conservative bound for every blocking
  operating characteristic.

The incidental-parameter sequence reports bias trends by Person count and fixed
per-Person information. A pooled mean across that sequence is prohibited.

## JML correction decision gate

0.2.3 may characterize corrections but does not add one. A later native mfrmr
proposal is admissible only if pilot and confirmation evidence show all of:

1. the effective exposure count is mathematically defined for arbitrary facets,
   missingness, unequal workload, anchors, and pseudoitem construction;
2. the proposal reduces exactly to the established balanced finite-item case;
3. identification, scale origin, element/group anchors, and step coordinates
   are preserved;
4. prespecified structural bias/RMSE improves across core and adversarial cells,
   rather than only agreement with one package;
5. coverage, extreme/boundary behavior, and failed/false-ready rates do not
   worsen beyond frozen limits; and
6. the corrected estimand, uncertainty, object schema, and migration behavior
   can be explained without silently changing existing JML results.

Failure of any item leaves JML uncorrected and its limitation explicit. It does
not block the whole 0.2.3 release if the affected support-envelope rows are
appropriately reduced or caveated under the frozen release rules.

## CML/CCML architecture decision gate

External CML/CCML evidence precedes architecture. After confirmation, an ADR
may choose one of three outcomes: a maintained adapter, native implementation,
or external-reference-only status. The ADR must compare accuracy, eligible
families and missingness patterns, category/facet limits, computation, required
dependencies, API coherence, long-term maintenance, and demonstrated user need.
No native CML/CCML milestone is placed on the public roadmap before that ADR.

## HRM boundary and naming rule

HRM is not an estimator mode for the current additive likelihood. Its evidence
asks whether current readiness, bias, and residual diagnostics respond usefully
to a distinct latent-rating/local-dependence process. A future implementation
requires a separate family/API or companion package and its own identification,
prior, MCMC, recovery, posterior-checking, and compatibility contracts.

`GMFRM` is not an acceptable feature name by itself. Any proposal must state
whether it means generalized response discrimination, rater-consistency
parameters, a latent rater process, or local dependence. Reduction cases cannot
bridge these meanings by terminology alone.

## Execution order

1. Complete WP1 constrained-estimability, WP2 category/step support, WP3 JML
   boundary states, and WP4 readiness propagation.
2. Implement identity-only runners and deterministic accepted/rejected
   comparison fixtures; do not inspect stochastic performance to choose modes.
3. Complete WP5 metric eligibility and denominator accounting.
4. Run new-seed feasibility pilots and freeze `EXT-JML-MODE-GRID`,
   `EXT-JML-TOL`, `EXT-JML-RECOVERY`, `EXT-JML-COVERAGE`, `EXT-CML-TOL`, and
   `EXT-EST-MCSE`.
5. Review and issue a later `0.2.3-frozen.*` specification before candidate
   confirmation is authorized.
6. Run all locked lanes against one candidate and retain every expected result,
   rejection, and failure.

## Draft.75 source audit and normalization smoke

`tam-immer-jml-mode-comparison-0.2.3.R` now freezes the loaded TAM 4.3-25 and
immer 1.5-13 function identities, exact mode arguments, a common expanded
cumulative-difficulty estimand, an authorization-guarded 60-dataset pilot, and
a deterministic RSM/PCM smoke. The smoke retained all 36 planned mode rows:
32 produced finite surfaces and the four TAM `adj = 0` rows with forced
extremes failed and remained ineligible as expected. All 864 successful
structural coordinates were retained.

After removing only the common latent-location direction, mfrmr raw versus
TAM raw differed by at most `3.88e-6` and TAM raw versus immer `jml` by at most
`1.25e-5` on no-extreme data. TAM `adj = .3` versus immer `jml, eps = .3`
differed by at most `8.06e-8` with forced extremes. Every classical factor
identity reproduced to `8.88e-16`; with nine complete pseudoitems it was
`8/9`. These are deterministic software/definition checks, not empirical
agreement thresholds.

The source audit also makes the missing-data problem sharper: TAM's classical
factor uses the pseudoitem column count `I`, whereas immer 1.5-13 uses mean
observed row exposure `Ibar`. The two corrections can therefore diverge even
when they coincide on the balanced complete smoke.

At Draft.75, the identity-only part of execution step 2 had begun, while step
1 remained incomplete and no TAM/immer result was release evidence. Draft.76
retains that status and replaces the narrow next-pilot proposal with the
factor-structured manifest below. No correction, tolerance, or preferred
estimator was selected.

## Draft.76 factor structure and feasibility result

`tam-immer-jml-factor-stress-contract-0.2.3.md` supersedes the earlier idea
that exposure, facet counts, sparsity, and missingness can be crossed as
independent scalars. Observed responses per Person are derived from assigned
Raters per Person, Criteria, and missingness; total Raters additionally defines
assignment density. The analysis therefore retains every quantity but uses
factor blocks and targeted interactions rather than a full Cartesian product.

The 22-dataset RSM/PCM smoke covers Persons, exposure, Rater and Criterion
counts, 3--6 categories, density, workload imbalance, forced and natural
endpoint Persons, Gaussian-copula local dependence, MCAR/Rater-MAR/score-MNAR,
a guarded 25% anchor row, and combined adversity. All datasets generated. Two
anchor rows stopped at the common-basis guard, and the two one-Rater-per-Person
low-information rows failed the expected rank test because no common Persons
linked Raters. The remaining 18 datasets retained all 162 planned mode rows,
including 22 TAM `adj = 0` failures caused by observed extreme Persons.

Sparse and missing designs demonstrate why method identity cannot be reduced
to a correction label. In the sparse 8-Rater x 4-Criterion panel with two
Raters per Person, TAM uses `31/32` while immer uses `7/8`. Across fitted smoke
cells their factors range `0.9375--0.97917` and `0.84027--0.95833`,
respectively. TAM and immer also leave their returned marginal basis SE vectors
unchanged when the classical point-estimate postscale is applied. Common-
surface coverage is therefore withheld until a covariance transformation or
prespecified refit/bootstrap route is proved.

Bias, RMSE, Spearman rank recovery, pairwise order recovery, a separately named
truth-SD/RMSE recovery-separation ratio, fit return, finite surface, numerical
convergence, and estimand eligibility are now distinct metrics. Engine-reported
facet separation and common-surface SE coverage remain ineligible. Local-
dependence and MNAR rows are misspecification robustness strata, not correctly
specified recovery rows.

The guarded next manifest contains 29 profiles x RSM/PCM x five replicates,
or 290 datasets. Five replicates remain feasibility calibration, not coverage
or rare-failure evidence. Before high-replication uncertainty work, the anchor
mapping, covariance estimand, reported-separation definition, and external
convergence proxy must be closed. No correction, tolerance, sample-size rule,
or preferred estimator has been selected.

## Draft.77 checkpointed factor-pilot result

The guarded 290-dataset manifest has now completed under
`tam-immer-jml-factor-checkpoint-contract-0.2.3.md`. The execution retained 230
datasets with all nine attempted method identities (2,070 mode rows), 40
one-Rater-per-Person structural negative controls, 20 guarded anchor cells, and
39,406 metric rows. A separate process reconstructed the result from all 290
cell checkpoints without refitting and matched the result and completion-marker
hashes.

The pilot exposes two important design revisions. First, low exposure cannot be
represented by one Rater per Person without a bridge or anchor: four profile
families become structurally unidentified. Second, some nominal main effects
are aliased. For example, the high-density cell also has only two Raters, and
the high-Rater cell increases Raters per Person. The next calibration must use
connected bridge-fraction profiles and separate total Raters, degree, density,
and realized exposure as far as the graph constraints allow.

The descriptive result is directionally consistent with finite-item scale
contraction: on common original-raw-eligible rows TAM and immer classical
corrections reduced cumulative-surface RMSE in about 95% and 94% of cells,
respectively. This does not make the corrected value the original JML
maximizer, validate its unchanged returned SE, or select a correction. Persons
high reduced RMSE while fixed exposure remained eight responses per Person,
but five replicates cannot determine whether incidental-parameter bias tends to
zero or a nonzero limit.

Score-MNAR, local dependence, high workload imbalance, and sparse-load-MAR
showed the largest adverse surface or Rater recovery signals. Ordering metrics
did not always deteriorate with location RMSE, so rank recovery, location
recovery, and recovery separation remain separate. Common-surface coverage and
definition-matched reported facet separation still have zero eligible rows.

`tam-immer-jml-factor-pilot-record-0.2.3.md` is the authoritative descriptive
record. Draft.77 freezes no threshold, sample-size recommendation, correction,
default, or confirmation decision.

## Draft.78 connected-assignment structural result

Draft.78 implements the first repair in
`tam-immer-jml-connected-design-0.2.3.R`. Eighteen profiles crossed with
RSM/PCM produce 36 datasets: six disconnected negative controls stop at the
structural-rank screen and 30 connected cells retain all 270 planned mode rows.
Both assigned and post-missingness Rater graphs retain components, absolute
bridge count, Person degree, assignment density, workload imbalance,
shared-Person edge weights, and weighted algebraic connectivity.

The smoke separates bridge rate from bridge information. Six bridge Persons
leave the eight-Rater construction in two components whether they are 5% of
120 Persons or 10% of 60 Persons. Twelve bridge Persons connect the planned
cyclic construction at 2.5%, 10%, or 20% depending on total Persons, and all
three have the same weighted algebraic connectivity because additional single-
Rater Persons do not thicken cross-Rater links. This is a construction-specific
feasibility result, not a 12-Person recommendation.

Rater count, degree, and density remain algebraically dependent. The fixed-
degree and fixed-density slices are therefore named conditional contrasts and
cannot identify three independent main effects. Natural extreme Persons occur
in 20/30 connected cells, while common-surface coverage and definition-matched
reported separation retain zero eligible rows. Most TAM adjusted fits reach
the smoke iteration ceiling; return and the external convergence proxy remain
separate.

`tam-immer-jml-connected-design-record-0.2.3.md` is authoritative for the
execution. The next topology calibration must compare chain, cycle, balanced,
and concentrated/hub allocations at matched bridge counts, add Draft.77-style
checkpoints and graph-vulnerability fields, and freeze Monte Carlo precision
before performance inspection. Common anchors, covariance/coverage, separation
identity, stronger convergence extraction, and high-replication planning then
remain open. Draft.78 freezes no bridge cutoff, threshold, sample-size
recommendation, correction, default, or confirmation decision.

## Draft.79 matched-topology and pilot-blocker result

Draft.79 holds bridge-Person count at 8, 12, or 24 while comparing path,
cycle, distributed, and hub allocations. It adds articulation-Rater, cut-edge,
single-link-Person failure, cycle-rank, edge-weight, and removal-robustness
fields to both assigned and observed graph audits. The paired 12-bridge
`DROP1` profiles remove the outcome-independent bridge link that maximizes
structural damage.

The 36-dataset RSM/PCM smoke completes with 30 connected nine-mode cells and
six observed-disconnected structural stops. One intentional interruption
publishes the first atomic checkpoint; the initial process resumes the other
35 cells, and a second process resumes all 36 without refitting while exactly
matching the aggregate and completion-marker hashes.

Topology is not reducible to algebraic connectivity. At 12 bridges the hub's
weighted algebraic connectivity is 1.0, larger than cycle 0.7511 and path
0.2561, but the hub retains one articulation Rater and seven cut edges. Losing
one targeted link disconnects path and hub; cycle and distributed remain
connected but acquire path/cut vulnerability. A separate 24-bridge negative
control remains in five components because all common-Person links are spent
inside one four-Rater cluster.

Every one of the 30 connected cells contains at least one natural extreme
Person. mfrmr raw and immer `jml` therefore have 0/30 original-raw-eligible
rows, and TAM raw/classical return on 0/30. TAM adjusted/combined return on all
30 but only 10 terminate before the raised 800-iteration smoke ceiling. Common
coverage and reported facet separation again have zero eligible rows.

This is a blocking calibration result for the declared but unexecuted
180-dataset pilot. The next revision must separate an operational sparse-
topology/extreme lane from a raw-JML-eligible high-information lane and a
stronger native convergence lane. The high-information lane must reduce
natural-extreme probability through prespecified information design, not by
post hoc deletion or conditioning on observed scores. Monte Carlo precision
and checkpoint identity must then be refrozen before pilot execution.

`tam-immer-jml-topology-calibration-record-0.2.3.md` is authoritative.
Draft.79 freezes no bridge minimum, graph cutoff, topology preference,
correction, sample size, convergence rule, coverage criterion, method ranking,
default, or confirmation decision.
