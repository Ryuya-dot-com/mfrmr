# Generalized-MFRM model ladder and evidence dependencies

Status: adopted as the model-family dependency map in `0.2.3-draft.63`;
first owner-specific execution slice added in `0.2.3-draft.64`; corrected
execution/precision contract and calibration record completed in
`0.2.3-draft.66`; not release authorization

Review date: 2026-08-08

Scope: the current bounded-GPCM claim in 0.2.3 and the research boundary for
broader generalized many-facet models

This note refines, but does not replace, the repository-root `ROADMAP.md`, the
0.2.3 internal roadmap, release-gate specification, or evidence checklist.
Draft.63 adopts its claim-relevant strata and the machine-readable
`gpcm-model-identity-contract-0.2.3.csv`. No criterion is frozen here and no
support status changes merely because a model appears in this ladder.
Draft.64 adds an identity-stamped criterion/rater smoke runner. Draft.65 adds
full-manifest execution identity, deterministic sharding, atomic row
checkpoints, planned-row denominators, Monte Carlo uncertainty, and a hashed
completion contract. Draft.66 corrects declared internal-category retention
and completes the 120-row pilot. The primary pilot uses `maxit = 400` and
q=31, while a later MML integration-sensitivity lane remains separately
identified. Its five-replicate signals are calibration evidence, not frozen
recovery, coverage, or confirmation evidence.

## Decision

The 0.2.3 release continues to validate the existing model portfolio. It does
not expand `GPCM` into a Uto--Ueno generalized MFRM, a multidimensional model,
or a new rater-process family.

Within that boundary, the present `GPCM` label needs a more exact identity.
For observation `o`, slope/step owner `g(o)`, linear predictor `eta_o`, and
adjacent step `tau_gk`, the implemented response kernel is

\[
  \log\frac{P(Y_o=k)}{P(Y_o=k-1)}
    = \alpha_{g(o)}\{\eta_o-\tau_{g(o),k}\},
  \qquad \prod_g\alpha_g=1.
\]

Exactly one facet owns both the slope and step blocks:
`slope_facet == step_facet`. Consequently, the current family is named here
the **aligned single-owner relative-slope GPCM**. Selecting `Criterion` and
selecting `Rater` are distinct evidence strata even though the same code path
can represent both. Neither stratum contains simultaneous criterion and rater
slopes.

For default MML, 0.2.3 now estimates an intercept-only population distribution
while retaining geometric-mean-one relative slopes. Population SD carries the
common discrimination scale, so the conventional fixed-latent-variance GPCM
degree of freedom is retained. The former standard-normal plus
geometric-mean-one likelihood is still available as the explicit
`fixed_standard_normal` legacy restriction. For JML, geometric-mean-one is a
genuine identification constraint because person coordinates are estimated
jointly. These estimator-specific meanings must not be pooled.

The sealed v3/v4 score-calibration lineage predates this default and remains
bound to the fixed-standard-normal likelihood. It is historical compatibility
evidence, not numerical validation of the added population-intercept and
log-variance coordinates.

## Four-axis model identity

Every GPCM fit, simulation cell, replay manifest, support-envelope row, and
external comparison should eventually record the following fields explicitly:

| Identity field | Required values for current 0.2.3 route | Why it is necessary |
| --- | --- | --- |
| `SlopeOwner` | the selected facet, such as `Criterion` or `Rater` | A criterion-indexed slope and a rater-indexed slope have different estimands and support requirements. |
| `StepOwner` | identical to `SlopeOwner` | This is the current aligned restriction; a different owner is a different, unsupported likelihood. |
| `SlopeComposition` | `single_owner_relative_gm1` | It rules out additive, multiplicative `alpha_i * alpha_r`, and unrestricted cell-specific slopes. |
| `LatentDimensionCount` | `1` | A free slope must not silently absorb multidimensional structure and then be reported as a validated unidimensional explanation. |

Additional evidence identity must retain the estimator, ability-distribution
contract, logistic scaling constant, category map, parameter constraints,
facet role, and the exact data/link topology. A model-family name alone is not
sufficient identity.

## Model-family ladder

The levels below are a dependency map, not a claim that every later model is
preferable or must be implemented. Alternative response-style and local-
dependence branches are not nested upgrades of GPCM.

| Level | Model contract | Relationship to literature | mfrmr status |
| --- | --- | --- | --- |
| `L0` | RSM/PCM many-facet reference; every slope equals one | Masters PCM and additive MFRM | Current core; evidence remains estimator- and design-specific. |
| `L1-C` | Aligned criterion-owned relative slopes and criterion-owned steps | Restricted Muraki/Wang--Liu item-slope facets overlap, without claiming the full generalized multilevel model | Current bounded route; 0.2.3 claim candidate only after criterion-role evidence passes. |
| `L1-R` | Aligned rater-owned relative slopes and rater-owned steps | Rater-indexed conditional discrimination plus rater-specific category use | Code-representable, but the construct label `rater consistency` is not earned without role-specific recovery and attribution evidence. |
| `L2` | One slope family whose owner may differ from the step owner | Separates criterion discrimination from rater category use, or conversely | Unsupported; earliest separate post-core proposal. Must reduce exactly to `L1` when owners coincide. |
| `L3` | Multiplicative task/criterion and rater slopes `alpha_i * alpha_r`, with an explicit step owner | Usami (2010) and Uto--Ueno (2020) lineages | Unsupported. Requires two slope blocks, factor-separation constraints, covariance, sparse-crossing evidence, and three unit-factor reductions. |
| `L4-I` | Rater-by-item/criterion severity interaction and multiple step blocks | Uto et al. (2024) adds `beta_ir` and item-specific steps; this is a location/step extension, not a cell-slope extension | Alternative generalized-MFRM research branch, not an `L3` synonym. |
| `L4-D` | Group-specific severity and/or slope/centrality effects | Uniform and nonuniform DFF/DRF models | Current output is location-like screening only. Joint moderated slope/centrality inference is unsupported. |
| `L5` | Multidimensional generalized MFRM with rubric loadings and rater consistency | Uto (2021) | External/generator challenge only in 0.2.3; native fitting and dimension scores are post-core research. |
| `A1` | Centrality/extremity parameterized as threshold spacing/weight | Jin--Wang response-style family | Competing model branch; do not treat a GPCM slope as an interchangeable centrality parameter. |
| `A2` | Latent ideal rating or repeated-rating local dependence | Hierarchical Rater Model and Rater Bundle Model | Competing model branch and possible generator-only stress challenge; not another estimator for the current likelihood. |
| `X` | Unrestricted cell-specific slope `alpha_ir` | Mathematically possible high-dimensional interaction | Icebox. It follows neither from current code nor from evidence for multiplicative slopes. |

The literature labels are not interchangeable. Wang and Liu (2007) directly
supports a multilevel two-parameter facets/GPCM extension with level-2
predictors, but is not by itself the source for Uto's rater-slope product.
Usami (2010) is a direct earlier source for multiplicative item/rater
discrimination and rater-related threshold spread. Uto and Ueno (2020) is a
foundational direct GMFRM source rather than the final word as of 2026.

## Source and equation corrections carried into the roadmap

1. The supplied memorandum's first link, DOI `10.1007/BF02296272`, is Masters
   (1982), not Muraki (1992). Muraki's journal article is DOI
   `10.1177/014662169201600206`. Both are needed because they establish
   different levels of the ladder.
2. Uto and Ueno (2020), equation 9, uses `D = 1`; its task and rater slopes
   enter multiplicatively, its steps are rater-specific, and its published
   identification includes `prod_i(alpha_i) = 1`, `sum_i(beta_i) = 0`, the
   rater-specific step constraints, and a specified ability distribution.
3. Uto (2021), equation 6, includes the constant `1.7`; omitting it is a
   rescaling, not a verbatim transcription. Its multidimensional
   identification puts the geometric-mean-one constraint on the rater-slope
   block, not on the 2020 task-slope block, and uses evaluation-item-specific
   steps.
4. `rater consistency` is a model-conditional slope interpretation, not direct
   evidence of repeatability, rater competence, or absence of local
   dependence. Range restriction, multidimensionality, interactions, and
   local dependence can confound or destabilize it; their effect need not
   always be a lower slope.
5. Wu (2017) is useful for separating severity, centrality, and conditional
   discrimination, but its rater-as-item analysis is not an implementation
   template for a joint generalized MFRM.
6. The Japanese and English abstracts of Usami (2010) report different initial
   examinee counts. That paper's small empirical example and the small designs
   in later HMC studies are feasibility evidence, not universal sample-size
   rules.

Primary sources used for these corrections are Masters (1982),
<https://doi.org/10.1007/BF02296272>; Muraki (1992),
<https://doi.org/10.1177/014662169201600206>; Wang and Liu (2007),
<https://doi.org/10.1177/0013164406296974>; Usami (2010),
<https://doi.org/10.5926/jjep.58.163>; Uto and Ueno (2020),
<https://doi.org/10.1007/s41237-020-00115-7>; Uto (2021),
<https://doi.org/10.1007/s41237-021-00144-w>; and Uto et al. (2024),
<https://doi.org/10.1371/journal.pone.0309887>.

## Evidence dependency graph

The 0.2.3 GPCM claim advances only from left to right. Later evidence cannot
repair a failed earlier contract.

```text
source/estimand lock
        |
        v
kernel + reductions + parameter transformation
        |
        v
identification + boundary + fail-closed negative controls
        |
        v
role-specific recovery + uncertainty + Monte Carlo error
        |
        +------------------+
        |                  |
        v                  v
sparse network/support   estimator/integration sensitivity
        |                  |
        +---------+--------+
                  v
     fit and diagnostic operating characteristics
                  |
                  v
       uniform DFF screen calibration
                  |
                  v
 nonuniform/centrality negative-control specificity
                  |
                  v
       matched external overlap, where possible
                  |
                  v
      public capability and release claim review
```

Optimizer completion is an input to this graph, not an exit node. Likewise,
better AIC, BIC, WAIC, or residual fit does not by itself establish recovery,
fairness, construct validity, or a superior scoring policy.

## Draft.63 0.2.3 work-package strata

These identifiers are registered by Draft.63. Registration makes them valid
evidence keys, not completed gates or authorization to run confirmation.

| Proposed ID | Existing portfolio mapping | Required evidence before a claim can advance | Current disposition |
| --- | --- | --- | --- |
| `NUM-GPCM-ALIGN-CRITERION` | Split of `NUM-GPCM-BOUND`; G1/G2 | Exact kernel, GM1 transformation/Jacobian, PCM and binary reductions, JML/MML boundary behavior, role-specific recovery/coverage, sparse designs, and downstream identity | Structural mathematics exists; role-specific empirical gate open. |
| `NUM-GPCM-ALIGN-RATER` | Split of `NUM-GPCM-BOUND`; G1/G2 | Recover rater severity, rater-indexed slope, and rater step profile separately; retain common-Person links and per-rater category support; evaluate attribution under unequal workload and ability range | Code path exists; interpretation and empirical claim open. |
| `DES-GPCM-RATER-CATEGORY` | `DES-CATEGORY-IMBALANCE`, `DES-SPARSE-LINKED`, `DES-WEAK-BRIDGE` | Cross centrality/extremity, rare/internal-empty categories, targeting, ability-range restriction, workload imbalance, and link topology; report slope/step misattribution and false-ready rates | Open. |
| `DIM-GPCM-SLOPE-ABSORB` | G4 dimensionality challenge | Compare true 1D, true multidimensional, interaction-only, local-dependence, and confounded generators; quantify when criterion slopes absorb omitted structure; produce no native subscores | External/generator-only sensitivity; open. |
| `DIAG-GPCM-FIT-NULL` | `DIAG-PCAR-NULL`, marginal/fit portfolio | Design-stratified null reference for residual and infit/outfit-like quantities; prespecified bootstrap or replicated-simulation calibration; no universal cutoff | Open. |
| `DIAG-GPCM-FIT-NONNULL` | `DIAG-PCAR-LOCAL`, planted interaction portfolio | Separate slope misspecification, step misspecification, local dependence, multidimensionality, and interaction alternatives; report attribution, not only detection | Open. |
| `DFF-GPCM-UNIFORM` | `DIAG-BIAS-NULL/NONNULL`, `EXT-FACETS-DFF` | Null Type-I error, planted severity shifts, group imbalance, multiplicity, link uncertainty, and practical impact under exact refit identity | Refit replay sub-gate closed; inference/operating-characteristic gates open. |
| `DFF-GPCM-NONUNIFORM-NEG` | New specificity row adjacent to DFF portfolio | Generate group-specific slope or centrality effects. Current location-like screens must not receive credit for detecting an estimand they do not fit; false interpretation must remain zero | Open negative-control gate. |
| `ALT-RATER-STYLE` | G5 sensitivity | Centrality/extremity generator with severity, step use, and slope attribution reported separately | Research sensitivity only. |
| `ALT-RATER-BUNDLE-LD` | Adjacent to `ALT-IMMER-HRM-LD` | Repeated-rating/local-dependence generator; inspect slope, fit, Q3/PCAR, and DFF behavior without engine-equivalence claims | Research sensitivity only. |
| `FUT-GPCM-MULTIPLICATIVE` | G6 public-scope guard | Verify only that current APIs and reports do not claim `alpha_i * alpha_r`; no 0.2.3 numerical promotion row | Unsupported/roadmap guard. |

Before M2 freeze, the criterion-owned and rater-owned strata must receive
separate eligible evidence, or the affected public surface must remain
caveated/unsupported. A single pooled `NUM-GPCM-BOUND` result cannot promote
either owner-specific interpretation after Draft.63.

## ADEMP grid and sample-size policy

There is no defensible universal minimum `N` for this portfolio. Every retained
simulation cell must identify at least:

- Persons and effective observations;
- slope-owner and step-owner level counts;
- categories and support per owner-by-category cell;
- ratings per Person and workload per rater;
- common-Person/link size, bridge location, and articulation structure;
- ability targeting/range and slope dispersion;
- planned or outcome-related missingness;
- null or planted effect and its estimand;
- JML or MML, MML engine, quadrature, and latent-distribution contract; and
- recovery, coverage, failure, false-ready, detection, and Monte Carlo-error
  measures appropriate to that cell.

`min_obs` remains a computability guard. Values such as 30 Persons in a
published HMC simulation or one empirical application establish only that a
particular model/estimator/design was studied. They do not transfer to current
JML/MML, DFF, sparse-network, or fit-calibration claims.

## Fit and DFF interpretation contract

- Severity DFF/DRF is location-like and analogous to a uniform effect.
- Rater centrality or group-specific discrimination is nonuniform in the
  expected-score relationship and needs an explicit slope/threshold model.
- General residual fit, infit/outfit-like summaries, and a screen-positive DFF
  row answer different questions. None substitutes for another.
- The residual DFF method holds baseline slopes fixed. The refit method can
  re-estimate bounded slopes but currently reports an additive location
  contrast, not a group-by-slope effect.
- Refit uncertainty does not yet include every calibration/linking covariance
  component and remains ineligible for formal inference.
- Fit and DFF thresholds must be calibrated by design under null and planted
  alternatives. Fixed universal cutoffs and universal per-group sample sizes
  are prohibited.

## Estimator separation

| Estimator lane | 0.2.3 interpretation |
| --- | --- |
| Direct MML | Current bounded-GPCM engine; default MML estimates intercept and population variance with relative-GM1 slopes, while the named legacy mode retains fixed-standard-normal MML. Conclusions remain conditional on the chosen population distribution and quadrature. |
| EM/hybrid input for GPCM | Currently falls back to direct optimization; it is not independent engine-parity evidence. |
| JML | Separate fixed-Person estimand with incidental-parameter, extreme-score, and nonlinear-boundary risks; convergence cannot promote it. |
| Bayesian HMC/NUTS | Important external model-family and regularization sensitivity, but not a guarantee for the package's MML/JML likelihood or uncertainty. |
| Variational/external MML | Separate estimator/prior/approximation stratum; compare only after model identity and constraints match. |

## Later-family entry and exit conditions

### Decoupled single slope and step owners (`L2`)

- prove constrained full-rank identification when `SlopeOwner != StepOwner`;
- reduce exactly to the current likelihood when the owners coincide;
- reduce to PCM when all slopes equal one; and
- close fitting, covariance, scoring, information, diagnostics, replay,
  export, simulation, and guard propagation under the same likelihood.

### Multiplicative task/criterion-by-rater slopes (`L3`)

- identify both positive slope blocks and document which block receives each
  constraint under every estimator/ability-scale contract;
- prove Jacobian rank and retain covariance between the blocks;
- pass `alpha_r = 1`, `alpha_i = 1`, and both-unit reduction cases;
- recover severity, both slope blocks, and the selected step profile under
  sparse crossing, workload imbalance, range restriction, and rare categories;
- establish zero false-ready results for insufficient task-by-rater support;
  and
- name model-conditional rater slope without equating it to competence or
  repeatability.

### Interaction and response-style branches (`L4-I`, `L4-D`, `A1`)

- separate location interaction, threshold spacing/weight, and slope effects;
- compare attribution and consequences under data generated from each branch;
- prohibit a favorable information criterion from overriding unsupported
  parameter recovery or failed identification; and
- give DFF/DRF effects their own null, non-null, multiplicity, and linking
  contracts.

### Multidimensional generalized MFRM (`L5`)

- freeze the Q/loading design, dimension count, latent covariance, and
  dimension-permutation/sign/rotation constraints;
- pass one-dimensional, unit-slope, and single-owner reductions;
- provide dimension-specific information, uncertainty, scoring, and schema
  identities; and
- gate good global fit separately from useful, stable, externally defensible
  subscores.

### Local-dependence and rater-process alternatives (`A2`)

- define the latent-rating or repeated-rating estimand independently of the
  current additive response kernel;
- use truth recovery, predictive consequences, and diagnostic attribution
  rather than unmatched parameter correlation; and
- never present HRM, Rater Bundle, or another process family as a switch of
  optimizer for current `fit_mfrm()`.

## Release sequence

1. **0.2.3:** finish the current aligned single-owner evidence by owner,
   estimator, topology, and diagnostic claim; retain broader families as
   negative public-scope guards.
2. **0.2.4:** typed one-scale calibration and threshold/step anchors; no slope
   family is broadened merely to support calibration.
3. **0.2.5:** explicit multiple observed scales and ragged step blocks; preserve
   the single-scale reductions.
4. **0.3.0:** consolidate schemas, model/evidence identity, compatibility, and
   independent review.
5. **Post-core research:** propose `L2`, then `L3`, and only then a native
   multidimensional generalized route. Competing response-style and local-
   dependence families proceed through independent proposals rather than this
   linear feature ladder.

The strategic invariant is conservative: broaden the evidence keys now, not
the public model claim. This preserves the wide 0.2.3 claim portfolio while
preventing one successful bounded-GPCM cell from being generalized to a
different slope owner, discrimination composition, latent dimensionality, or
rater-process interpretation.
