# TAM/immer estimator stress plan for mfrmr 0.2.3

Status: repository-only planning contract, draft 2026-08-03.

This plan operationalizes the TAM and immer lanes in
`release-gate-spec-0.2.3.md`. It does not report a pilot, authorize
confirmation, add a package dependency, or create a public mfrmr capability.
All numeric grids and acceptance thresholds remain `pilot_required`.

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
| `EXT-TAM-JML-RAW` | `tam.jml()` with `adj = 0`, `bias = FALSE`. | Unadjusted JML structural parameters and nonextreme Persons. |
| `EXT-TAM-JML-ADJ` | `tam.jml()` with documented extreme-score adjustment and `bias = FALSE`. | Structural parameters plus adjustment-labelled Person display sensitivity. |
| `EXT-TAM-JML-BC` | `tam.jml()` with `adj = 0`, `bias = TRUE`. | Finite-item-bias-reduced structural parameters and nonextreme Persons. |
| `EXT-TAM-JML-BC-ADJ` | TAM documented default bias reduction plus extreme-score adjustment. | Combined-mode sensitivity; never substituted for either factor alone. |
| `EXT-IMMER-JML-RAW` | `immer_jml()` with `est_method = "jml"`. | Unadjusted JML structural parameters and nonextreme Persons. |
| `EXT-IMMER-JML-EPS` | `immer_jml()` with `est_method = "eps_adj"`. | Extreme-adjusted JML sensitivity with adjusted Persons labelled. |
| `EXT-IMMER-JML-BC` | `immer_jml()` with `est_method = "jml_bc"`. | Bias-corrected JML structural-parameter sensitivity. |
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

At this draft, step 1 is incomplete and no TAM/immer result is release evidence.
