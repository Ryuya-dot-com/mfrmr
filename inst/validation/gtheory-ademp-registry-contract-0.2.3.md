# Draft.83d1 G-theory ADEMP registry and denominator contract

Status: repository-only pre-simulation design contract, 2026-08-09.

Draft.83d1 freezes the design dimensions, target meanings, metric routing,
execution identities, and failure denominators required before G-theory
recovery simulation. It is an ADEMP registry in the sense that every cell has
an aim, data-generating stratum, estimand, method set, and performance-measure
route. It does not execute a Monte Carlo experiment, select a backend, freeze
pilot/confirmation replication counts, or make a recovery claim.

## Why the portfolio is split into lanes

The current reconstruction target is a Gaussian observed-score random-
intercept G-theory model. Several requested stress factors change more than
sample size or design density. Treating all of them as if they had the same
population variance truth would make the apparent bias depend on an unstated
change of estimand. Draft.83d1 therefore registers seven lanes:

| Lane | Target meaning | Permitted interpretation |
| --- | --- | --- |
| `gaussian_exact_recovery` | Generating Gaussian variance components | Ordinary component bias/RMSE after Draft.83d2 implements the generator and extraction. |
| `missingness_sensitivity` | Generating Gaussian components under an explicit omission process | Mechanism-stratified recovery sensitivity; never pooled with complete data. |
| `bounded_score_projection` | Variance components of the complete finite potential observed-score table after the declared category transformation | Projection-target bias/RMSE, not recovery of the latent Gaussian components. |
| `local_dependence_sensitivity` | Independence-model reference under a declared residual-dependence perturbation | Reference deviation only, not component-truth recovery. |
| `boundary_recovery` | Generating zero or near-zero component with an expected nonregular point gate | Boundary-stratified estimation and false-ready behavior. |
| `identification_negative_control` | No coefficient estimand | Failure accounting and false-ready rate only. |
| `anchor_nonapplicability` | No current G-study operation | Blocked registry route pending a separate calibration/linking estimand. |

The bounded-score target requires the complete potential observed-score table,
including rows later omitted by the assignment or missingness mechanism. Its
population projection must be calculated before sampling. Thresholding a
latent Gaussian score and then comparing the fitted observed-score variance to
the latent variance is explicitly invalid.

Local dependence changes the covariance structure outside the independent
random-intercept model. A deviation from the independence-model reference can
be informative as a misspecification stress result, but it is not relabelled
as unbiased or biased recovery of an unchanged component.

## Registered dimensions and covering strategy

The 24 scenarios cover:

- 30, 100, and 300 Persons;
- 4, 8, 12, 16, 32, and 64 registered observations per Person, with realized
  counts to be audited after assignment and missingness;
- 2, 4, 6, and 8 raters;
- 2, 4, and 8 criteria;
- continuous scores and 3, 5, and 7 categories;
- complete, 0.50, 0.25, and 0.125 assignment density;
- balanced, moderately unequal, and highly unequal rater workload;
- no, moderate, and high endpoint concentration;
- local-dependence correlations 0, 0.25, and 0.50;
- anchor rates 0, 0.25, and 0.50, with the nonzero cells blocked;
- none, MCAR, rater-load MAR, score-dependent MNAR, and unknown missingness;
- interior, near-zero, exact-zero, and aliased component states; and
- complete, connected-cycle, connected-hub, nested, disconnected, and
  saturated incidence topologies.

This is a deliberate covering registry, not a full factorial. A full cross of
all dimensions would be computationally large and would also combine
semantically incompatible factors. Pairwise or higher-order expansion can be
added only by creating new scenario identities before results are inspected.
The registry never treats a planned observation count as the realized count;
Draft.83a must audit the retained design in every generated replicate.

## Anchor-rate boundary

An anchor rate is meaningful for a calibrated/linked latent scale or a joint
GT-IRT model. It is not an estimation operation in the present Gaussian
random-intercept G-study. The two nonzero anchor cells therefore have:

```text
MethodSet           = none
ExecutionEligibility = blocked_anchor_not_gstudy_operation
TargetBasis          = none
```

They demonstrate coverage of the user's requested dimension without
pretending it is already supported. A later implementation must first define
what is anchored, which population/scale is transported, and how anchor
uncertainty enters G- and D-study quantities.

## Performance-measure routing

The registry distinguishes six performance families:

1. component bias/RMSE;
2. component interval coverage/width;
3. object rank recovery;
4. facet-level effect recovery;
5. G/Phi coefficient recovery; and
6. operating characteristics and exact failure accounting.

Bias and RMSE require both a declared truth and an available finite value.
Availability is reported separately, so conditioning on successful fits cannot
be hidden. G/Phi bias and RMSE additionally require a frozen allocation
operator and coefficient truth. No fitted G-study design may be selected from
the D-study scenario it later evaluates.

Standard-error coverage is not currently available. Draft.83c1/c2 supplies
point fits only, while Draft.84 must validate full-refit intervals. Draft.83d1
therefore routes component, G, and Phi coverage to
`no_interval_until_draft84`. A Wald standard error obtained from a backend is
not silently substituted for the missing interval contract.

## Rank recovery and facet separation

Person rank recovery is the within-replicate rank association between centered
generating and predicted Person effects. Facet recovery is split into:

- within-facet Spearman rank association;
- centered facet-level RMSE; and
- `gt_effect_recovery_ratio`, defined as the standard deviation of centered
  true facet effects divided by their centered prediction RMSE.

The last quantity is a G-theory simulation diagnostic. It is not the Rasch or
FACETS separation statistic and must not be displayed under the same name.
Conditional modes/predictions and their centering identities are deferred to
Draft.83d2; no rank or effect-recovery value exists in Draft.83d1.

## Execution manifest

`mfrmr_gtd_execution_manifest()` expands every executable smoke scenario by
its registered method set. It currently contains 89 point-fit units. Methods
applied to one scenario-replicate share a `DatasetId` and seed, preserving
paired comparisons. Every unit retains the registry hash. Blocked anchor cells
cannot enter the manifest.

`SmokeReplications=1` is only a software-schema check. `PilotReplications`,
`ConfirmationReplications`, and the Monte Carlo precision plan remain missing
and `not_frozen`. Replication counts may be selected only after a feasibility
pilot defines target MCSE or confidence-width criteria; confirmation remains
unauthorized.

## Frozen denominator ordering

Each planned fit unit must retain the following monotone stages:

```text
planned
  -> generated
  -> pre-fit eligible
  -> fit attempted
  -> fit returned
  -> optimizer converged
  -> finite component vector
  -> point-estimation gate passed
```

A later flag cannot be true when an earlier required flag is false. A recorded
unit has exactly one of:

- `FailureStage=none`, `FailureCode=none`, and a passed point gate; or
- a nonempty typed failure stage/code and a failed point gate.

An absent result is `unrecorded`, not a typed failure. Consequently it makes
`ExactAccountingPassed=FALSE` and cannot be absorbed into a convergence or
recovery denominator.

The rates use fixed denominators:

| Quantity | Denominator |
| --- | --- |
| Fit return | fit attempted |
| Optimizer convergence | fit attempted |
| Point-estimation gate | planned fit units |
| False ready | planned fit units in an expected-not-ready stratum |
| Metric availability | metric-eligible units |
| Bias/RMSE | truth-defined, metric-eligible units with an available finite value, alongside the availability count |
| Coverage | truth-defined units with a separately valid returned interval, beginning no earlier than Draft.84 |

For boundary, disconnected, and aliased controls, a numerically returned fit
is not a success unless the whole point-estimation gate passes. Their required
promotion result is zero false-ready units, not a favorable mean estimate.

## Reproducibility and mutation rules

The factor catalog, metric catalog, scenario table, and complete routing table
form one SHA-256 registry identity through the Draft.81 hash function. Result
rows must match this exact hash and the scenario/replicate/method, dataset,
seed, and backend identities of the manifest. Duplicate, extra, or mutated
rows fail before aggregation.

Any change to the generator, assignment algorithm, omission process, target
projection, fitting defaults, boundary tolerance, metric definition, or
denominator rule requires a new contract/registry identity. Results from
different identities cannot be pooled under one scenario label.

## Readiness boundary and next step

Every registry object remains:

```text
SimulationExecuted    = FALSE
RecoveryEvidenceReady = FALSE
InferenceReady        = FALSE
CoefficientEligible   = FALSE
DecisionReady          = FALSE
```

Draft.83d2 may now implement deterministic generators, topology/allocation
constructors, backend adapters, truth extraction, effect prediction, and
atomic result rows for the one-replicate smoke manifest. It must first pass
these schema/identity controls and cannot freeze pilot replication counts from
the smoke outcomes. Draft.84 remains the first possible interval-coverage
gate.
