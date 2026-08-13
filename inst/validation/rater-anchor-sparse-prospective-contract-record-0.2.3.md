# Prospective Rater-anchor by sparse-design stress contract for 0.2.3

Status: **structurally ready; execution and percentage selection withheld**

Specification: `0.2.3-draft.1`

Contract: `mfrmr_rater_anchor_sparse_prospective_contract_v1`

## Purpose and boundary

The preceding three-seed PCM/JML calibration advanced 25% exact,
range-spanning Rater anchors as a feasibility candidate. It did not establish
an operational percentage. This prospective contract freezes the next study
before any expanded fit is run, so that the candidate cannot be favored by
changing sparse designs, anchor-error conditions, denominators, or decision
rules after observing results.

This remains the direct FACETS-adjacent lane:

- PCM response model;
- unpenalized mfrmr JML;
- 160 Persons, 16 Raters, four Criteria, and four ordered categories;
- no FACETS executable;
- no GPCM slope;
- no MML model selection; and
- no public default or readiness-rule change.

Sixteen Raters make the registered 0%, 12.5%, 25%, and 50% rates exactly 0,
2, 4, and 8 fixed Rater coordinates. The earlier 75% arm is not carried
forward: with eight Raters it left only two free coordinates and rewarded the
condition mechanically for supplying rather than estimating the target.

## Anchor registry

The eight configurations are:

| Configuration | Rate | Count | Selection | External-value mechanism | Role |
|---|---:|---:|---|---|---|
| none | 0% | 0 | none | none | reference |
| exact 12.5 span | 12.5% | 2 | range-spanning | oracle exact | low-rate comparison |
| exact 25 span | 25% | 4 | range-spanning | oracle exact | primary candidate |
| exact 50 span | 50% | 8 | range-spanning | oracle exact | high-rate sensitivity |
| normal SD 0.10, 25 span | 25% | 4 | range-spanning | independent normal error | mild transport error |
| normal SD 0.25, 25 span | 25% | 4 | range-spanning | independent normal error | material transport error |
| shifted +0.25, 25 span | 25% | 4 | range-spanning | systematic shift | directional transport error |
| exact 25 central | 25% | 4 | central cluster | oracle exact | composition control |

Every positive-rate selection is made from an external calibration estimate
with declared standard error 0.10, not from the target response data. The same
external selection seed is shared by all positive-rate configurations within a
replicate, permitting nested range-spanning sets instead of selecting favorable
Raters separately for each rate. Oracle-exact value arms are positive controls,
not operational claims. Normal value-error seeds are disjoint from response-
data and selection seeds. Within a replicate and anchor configuration, the same
external anchor set is transported to every assignment design. This prevents
design-specific resampling of favorable selection or value errors.

Only `none`, `exact_12_5_span`, `exact_25_span`, and `exact_50_span` are
eligible to compare percentages. The other four conditions assess value or
composition robustness and cannot vote for a rate.

## Sparse-design registry and resource accounting

Direct Rater anchors, universal linking Persons, and repeated ratings remain
different resources.

| Design | Ordinary Raters/Person | Universal links | Rating assignments | Added above one-Rater baseline | Density |
|---|---:|---:|---:|---:|---:|
| complete | 16 | 160 | 2,560 | 2,400 | 1.000 |
| single-Rater, no link | 1 | 0 | 160 | 0 | 0.0625 |
| single-Rater, 5% range link | 1 | 8 | 280 | 120 | 0.1094 |
| single-Rater, 12.5% range link | 1 | 20 | 460 | 300 | 0.1797 |
| single-Rater, 12.5% central link | 1 | 20 | 460 | 300 | 0.1797 |
| two-Rater cycle, no universal link | 2 | 0 | 320 | 160 | 0.1250 |
| two-Rater cycle, 5% range link | 2 | 8 | 432 | 272 | 0.1688 |

The single-Rater/no-link design is retained as a structural negative control.
The two-Rater cycle is connected even though many Rater pairs have no direct
common Person. The range-versus-central link comparison isolates composition
at the same 12.5% link-Person rate and identical rating cost.

One direct anchor unit is not assigned an invented exchange rate against one
additional rating assignment. Both are reported separately. Any later scalar
cost function requires externally supplied calibration and scoring costs.

## Paired manifest

The smoke manifest contains 12 declared PCM/JML fits:

- one replicate;
- three designs (`complete`, `sparse_link05_range`, and
  `sparse_pair_cycle`); and
- four anchor conditions (`none`, exact 25%, normal-SD-0.25 25%, and shifted
  25%).

The feasibility manifest contains **560 declared feasibility fits**:

- 10 independent response-data seeds;
- seven assignment designs; and
- eight anchor configurations.

It contains 70 unique designed datasets, 10 external selection calibrations,
and 80 unique external anchor sets. Each dataset is reused by all eight anchor
configurations. Each external calibration is shared by all positive-rate arms
within its replicate, and each external anchor set is reused by all seven
assignment designs. Fit execution order cannot change any identity.

## Measures and denominators

Every planned run remains in the fit-return, inference-readiness, structural-
failure, and metric-availability denominators. Failed and unavailable runs
cannot disappear from recovery summaries.

Primary scientific measures are:

- inference-ready rate and structural-failure rate;
- free-Rater absolute RMSE, excluding every supplied Rater coordinate;
- Person absolute RMSE and Person rank correlation;
- paired free-Rater and Person RMSE changes from the no-anchor arm;
- Person RMSE change from exact 25% under each 25% error arm; and
- direct-anchor units and added rating-assignment units.

Centered recovery, bias, Rater rank, Criterion recovery, fit-return, and metric
availability remain diagnostic measures. Fixed anchors never receive recovery
credit for reproducing their supplied values.

## Prospective decision rules

1. Anchor rates are ranked within an assignment design; results are never
   pooled across networks to choose a percentage.
2. Contrasts are paired by response-data seed and designed response identity.
3. Error and central-selection arms assess robustness but do not select a rate.
4. The analysis reports the strict Pareto set over readiness, recovery, direct
   anchors, and added ratings. Direct anchors and ratings are not scalarized.
5. The 10-replicate feasibility stage estimates runtime, failure modes, and
   dispersion only. It cannot select a percentage.
6. Before confirmation, a separate freeze must set enough replications for a
   worst-case binary-rate Monte Carlo standard error no greater than 0.025.
   This gives a mathematical minimum of 400 independent replications, while
   the final count remains unset until metric-specific precision rules for
   continuous recovery outcomes are also frozen.
7. An operational percentage additionally requires external anchor-versus-
   rating costs. Confirmation alone is insufficient without that decision
   context.

Thus 25% remains the primary candidate under test, not the presumed winner.
No universal percentage is encoded in this contract.

## Deterministic identities

Registry SHA-256:

`3a58566aa7e9ae6943fad15449cb11852f929cb156030bb425076c543f605c09`

Smoke-manifest SHA-256:

`7ff2334303b5a581b057b0323b23512f27e644c9c7623b6f507cc87adf204cc3`

Feasibility-manifest SHA-256:

`00b2c963456589e01c63ca234a8049c960d44206d4c382828e78ae0732820d9c`

Contract-file SHA-256:

`c446b6eab06d8e2442de5ed3765f6accfdd3880cd385ebd318c7b71f316856db`

Focused-test SHA-256:

`669bfb33a7a86caa45155056a4742c9b51fd924b8cba061f3ec77307bb19354d`

## Authority state

`SimulationExecuted = FALSE`

`SmokeExecutionAuthorized = FALSE`

`FeasibilityExecutionAuthorized = FALSE`

`BroadSimulationAuthorized = FALSE`

`AppropriateAnchorRateSelected = FALSE`

`ConfirmationAuthorized = FALSE`

`FACETSExternalFitsIncluded = FALSE`

`GPCMIncluded = FALSE`

The contract changes no public default, readiness threshold, FACETS comparison
claim, GPCM conclusion, or release gate.
