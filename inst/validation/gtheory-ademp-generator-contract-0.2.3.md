# Draft.83d2a deterministic G-theory ADEMP generator contract

Status: repository-only generation contract, 2026-08-09.

Draft.83d2a turns every Draft.83d1 scenario identity into a deterministic
data-generation result or an explicit semantic block. It freezes the
generator, assignment, missingness, finite-table truth, and replay identities
before any backend is fitted. It does not fit an analysis table, treat the
finite-table MoM projection as sampling recovery, predict a fitted random
effect, evaluate recovery, select a backend, freeze Monte Carlo replication
counts, or supply interval evidence.

## Three-table data identity

Every executable scenario produces three distinct tables from one draw:

1. `FullPotentialData` contains the complete declared Person-by-facet design,
   the latent continuous score, and the observed score before assignment or
   omission.
2. `AssignedData` selects the frozen assignment rows and contains no missing
   observed score.
3. `AnalysisData` preserves the assigned row identity and replaces omitted
   observed scores with `NA` under the declared mechanism.

Random component effects are drawn once on the full table. All methods later
attached to the same scenario/replicate must receive the same analysis table;
a backend may not regenerate, reassign, or independently omit rows. The three
table hashes are therefore separate parts of the generator identity.

## Generating component family

The ordinary crossed continuous generator uses:

```text
Score ~ Person + Rater + Criterion +
        Person:Rater + Person:Criterion + Rater:Criterion + Residual
```

with independent centered Gaussian draws and nominal variances frozen in the
prototype. `Residual` is the unrepresented highest-order
Person-by-Rater-by-Criterion variation. The saturated alias negative control
adds that highest interaction as a fitted semantic component without within-
cell replication, so it must fail the observed-design screen rather than
return a coefficient.

The nested scenario deliberately uses the narrower currently auditable model:

```text
Score ~ Person + Site + Site:Rater + Criterion + Residual
```

Raw Rater labels are reused within two Sites, while effective Rater identities
remain conditional on Site. Interaction-rich nested decomposition is not
silently treated as supported: the present fixed-effect-equivalent rank audit
does not establish those richer variance components. Such a model requires a
later covariance-information/operator gate and a new scenario identity.

## Assignment mechanisms

Assignment is performed after the full score draw and before missingness:

- `complete`, `nested`, and `saturated` retain the full potential table;
- `connected_cycle` assigns an exact number of cells per Person through a
  deterministic rotating sequence and preserves a connected design;
- `connected_hub` samples without replacement using a frozen first-Rater
  weight, with distinct moderate and high imbalance weights; and
- `disconnected` partitions Persons and Raters into two islands as an
  identification negative control.

Every generated replicate records potential and assigned row counts, minimum
and maximum observations per Person, realized assignment density, Rater-load
coefficient of variation, and zero-load Raters. Registered assignment density
and observations per Person must be realized exactly. A workload label is not
accepted as evidence; the realized load distribution is hashed and tested.

## Bounded observed-score projection

Three bounded-score scenarios deterministically rank the latent full-table
score into 3, 5, or 7 declared categories. The exact requested proportions
are assigned to the two endpoints, split as evenly as the finite row count
permits. With endpoint rate zero, endpoint categories are deliberately unused;
the seven-category scenario therefore observes the five internal categories.
This is a support stress condition, not evidence of threshold estimation.

The comparison target is calculated by applying the Draft.82 balanced MoM
projection to `FullPotentialData` after categorization and before assignment
or omission. It is a complete finite-potential-table observed-score
projection, not the latent Gaussian generating variance and not an estimated
population expectation. Both nominal latent and projection identities are
retained, but the Draft.83d1 metric routing alone determines which target may
be evaluated.

## Missingness mechanisms

Exactly the registered finite-table omission count is selected by ranking one
frozen risk score:

- `MCAR`: an independent uniform draw;
- `MAR_rater_load`: observed assigned Rater workload plus a uniform tie-break;
- `MNAR_score`: standardized observed score plus a uniform tie-break; and
- `unknown`: a frozen nonlinear Rater/score mixture plus a uniform tie-break.

`MAR_rater_load` is MAR only relative to the fully observed design/load
covariate. `MNAR_score` explicitly uses the score that will be omitted.
`unknown` is a sensitivity label, not a claim that an unknown empirical
mechanism has been identified. Exact finite-sample omission rates verify the
algorithm, but they do not justify ignorability, causal interpretation, or a
particular backend's missing-data likelihood.

## Local dependence and boundaries

The local-dependence lane replaces independent residuals with a Gaussian AR(1)
residual sequence within each Person, using the canonical full-potential
Rater-by-Criterion row order. This order is part of the hashed generator
identity. Correlations 0.25 and 0.50 are misspecification perturbations; their
nominal independent-model component vectors cannot be relabelled as exact
recovery truth.

Boundary scenarios set the Rater variance to `1e-10` or exactly zero. Exact
zero generates an all-zero Rater effect vector; near zero remains a genuine
small random draw. Both are registered as `must_fail_ready_gate`: numerical
return or optimizer convergence alone cannot make them ready.

The disconnected and saturated-alias scenarios have no coefficient estimand.
The two nonzero-anchor scenarios return a typed
`blocked_not_current_gstudy_operation` result with no data. Anchor percentage
still lacks a defined calibration/linking operation in this observed-score
G-study and is not manufactured as a variance factor.

## Replay and mutation policy

The seed is `SeedStart + Replicate - 1`. Generation saves and restores the
caller's global RNG state. The generator identity binds:

- contract version, registry hash, scenario row, replicate, and seed;
- typed design hash;
- full, assigned, and analysis data hashes;
- nominal and, where defined, finite-table projection truth hashes;
- assignment, missingness, and score-audit hashes; and
- formals/body hashes for eleven generator-defining functions.

Changing the component variances, factor order, assignment weight, row order,
category mapping, missingness risk, boundary value, target projection, audit,
or generator function requires a different identity. Reordering results or
mixing identities across methods is forbidden.

## Readiness boundary and next gate

An executable result may set only:

```text
GenerationEvidenceReady = TRUE
EstimationReady         = FALSE
InferenceReady          = FALSE
CoefficientEligible     = FALSE
DecisionReady            = FALSE
```

Draft.83d2b must run the Draft.83a observed-design gate on every analysis
table, bind one atomic fit/failure row to every unit in the 89-unit smoke
manifest, implement exactly matched lme4/glmmTMB/balanced-MoM adapters where
eligible, and extract component and centered conditional-effect identities.
It must demonstrate zero false readiness in the disconnected, aliased, and
boundary strata. Smoke results remain software feasibility evidence only;
replication counts and precision criteria require a separate pilot, and
Draft.84 remains the first possible interval-coverage gate.
