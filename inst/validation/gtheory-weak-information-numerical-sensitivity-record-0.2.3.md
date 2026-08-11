# Draft.83d2b2b1e numerical-likelihood sensitivity execution record

Date: 2026-08-10
Scope: already viewed replicate-101--125 feasibility datasets, three frozen
optimizer profiles per backend route, atomic full/reduced refits, and exact
checkpoint resume
Result: all 9,000 profile pairs and 750 datasets are accounted for and the
scientific hash resumes exactly, but the prespecified default-replay gate
fails on seven non-finite-versus-non-finite rows; numerical-sensitivity,
calibration, inference, and D-study readiness therefore remain false

## Frozen identities

The audit used the immutable Draft.83d2b2b1d identities:

- feasibility runner contract:
  `c97b5d08c29e7a7537fe4669f938de9e978b4bb651596007af0b7ea7b9378df7`;
  and
- feasibility scientific execution:
  `04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b`.

The new identities are:

- numerical-sensitivity contract:
  `0538eb1a7636d4d784f06c10bb17f65aa958f4e677005462d6309827292083c6`;
- 9,000-row manifest:
  `53880242ed7441c93516defbd840c289df32bbc6d0677e4b441bc2543eda8d2f`;
  and
- timing-, execution-order-, worker-, and reuse-excluded scientific
  execution:
  `37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94`.

The immediate full resume reused all 9,000 route checkpoints, performed zero
new profile-pair computations, validated all 750 dataset markers, and
reproduced the scientific execution hash exactly. Independent execution used
disjoint dataset workers only to change order and elapsed time; every final
checkpoint was re-read through the single complete manifest.

## Exact accounting

| Quantity | Result |
| --- | ---: |
| planned and recorded profile pairs | 9,000 / 9,000 |
| independent scenario-replicate datasets | 750 / 750 |
| original matched method routes | 3,000 |
| profiles per original route | 3 |
| valid route checkpoints | 9,000 |
| valid dataset markers | 750 |
| planned full/reduced backend fits | 18,000 |
| returned profile pairs | 9,000 / 9,000 |
| typed route failures | 0 |
| finite raw likelihood differences | 8,655 |
| non-finite raw likelihood differences | 345 |
| optimizer/likelihood-available rows | 8,511 |
| available and within-tolerance comparisons | 7,876 |
| finite materially negative differences below -1e-6 | 653 |
| finite small negative differences retained | 1,879 |
| target-boundary rows | 2,640 |
| nuisance-boundary rows | 1,088 |

`PairReturned` means that both backend wrappers returned fit objects and the
pair schema completed. It is not a finite-likelihood or comparison-available
claim. The explicit finite `MaterialNegativeDrop` field prevents the 345
non-finite differences from being relabelled as negative values.

The summed elapsed time of independently scheduled profile checkpoints is not
reported as serial runtime: concurrent system load changes it and timing is
excluded from the scientific identity.

## Profile-specific results

| Backend profile | Finite / 1,500 | Likelihood available | Comparison available | Finite material negative | Target boundary | Nuisance boundary |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| lme4 default nloptwrap | 1,500 | 1,428 | 1,403 | 34 | 572 | 223 |
| lme4 strict nloptwrap | 1,500 | 1,428 | 1,403 | 34 | 572 | 223 |
| lme4 bobyqa | 1,500 | 1,500 | 1,500 | 0 | 595 | 226 |
| glmmTMB default nlminb | 1,493 | 1,493 | 1,401 | 92 | 341 | 158 |
| glmmTMB tight nlminb | 1,493 | 1,493 | 1,401 | 92 | 341 | 158 |
| glmmTMB optim BFGS | 1,169 | 1,169 | 768 | 401 | 219 | 100 |

The strict same-algorithm profiles reproduce the default full likelihood,
reduced likelihood, and raw difference exactly on all 1,500 routes for each
backend. Merely tightening the registered termination controls therefore does
not alter any solution in this audit.

The different-algorithm result is backend specific. lme4 bobyqa has finite,
comparison-available differences for all 1,500 routes and resolves all 34
finite material-negative default-lme4 routes to within tolerance. It attains
the highest recorded full and reduced objective on 1,495/1,500 routes, with
the remaining five tied with both nloptwrap profiles.

glmmTMB BFGS does not provide a parallel remedy. It produces 331 non-finite
differences and 401 finite material-negative differences. Among the 92
material-negative default-glmmTMB routes, BFGS moves 29 within tolerance,
leaves 30 material-negative, and makes 33 non-finite. It also turns 371 routes
whose default difference is within tolerance into material-negative routes.
BFGS nevertheless attains the highest recorded full objective on 343 routes
and the highest reduced objective on 625 routes. These facts together rule
out both “different optimizer is better” and “one optimizer should be chosen
by win count” as valid general conclusions.

## Matched route behavior

Across the 3,000 original routes, the finite-sign states are:

| Three-profile sign state | Routes |
| --- | ---: |
| all profiles within tolerance | 2,203 |
| optimizer-sensitive material versus within tolerance | 433 |
| incomplete because at least one profile is non-finite | 334 |
| all profiles materially negative | 30 |

The default profile has 2,993 finite differences and 126 finite material-
negative differences. A different-algorithm profile moves 63/126 within
tolerance: all 34 lme4 cases and 29/92 glmmTMB cases. Conversely, 371 routes
that are not material-negative under the default become material-negative
under the different-algorithm profile. The strict same-algorithm profiles
move none of the 126 default material-negative routes.

Even the diagnostic envelope
`2 * (max_profile full logLik - max_profile reduced logLik)` is below -1e-6
on 69/3,000 routes. Because the full and reduced maxima can come from
different profiles, this is not a likelihood-ratio statistic. It shows that
the registered profile set has not established a portable nested optimum.

Raw objective spreads are not compressed to a selected equivalence rule:

| Deviance-scale reporting tolerance | Full within / finite | Reduced within / finite |
| ---: | ---: | ---: |
| 1e-8 | 884 / 2,997 | 1,172 / 2,999 |
| 1e-6 | 2,221 / 2,997 | 2,590 / 2,999 |
| 1e-4 | 2,709 / 2,997 | 2,849 / 2,999 |
| 1e-2 | 2,959 / 2,997 | 2,979 / 2,999 |

The median full and reduced spreads are only about 5.67e-8 and 2.32e-8, but
their maxima are about 97.99 and 129.86. Target-variance estimate spread has
median 1.28e-6, 95th percentile 0.0136, 99th percentile 0.0684, and maximum
0.279. The small medians cannot hide the extreme route-specific failures.
No practical-equivalence threshold is selected.

## Default replay gate

All 2,993 finite default-profile raw differences reproduce the b1d value
exactly; their absolute replay difference is zero. The other seven b1d raw
differences and their b1e default replays are both non-finite, and their
likelihood-unavailable comparison states agree. However, the frozen b1e rule
defines replay only through a finite absolute difference no greater than
1e-10. It did not prospectively define same-non-finite-state replay.

The rule is not relaxed after viewing the result. Consequently:

- `DefaultReplayPassed = FALSE`;
- `NumericalSensitivityEvidenceReady = FALSE`;
- `CalibrationEvidenceReady = FALSE`;
- `BootstrapOperatingCharacteristicsReady = FALSE`;
- `ThresholdFrozen = FALSE`;
- `ConfirmationAuthorized = FALSE`;
- `InferenceReady = FALSE`;
- `CoefficientEligible = FALSE`; and
- `DecisionReady = FALSE`.

This is a contract-definition failure on seven already non-evaluable rows,
not evidence that their non-finite values are numerically close. `NA - NA`
has no absolute difference and must not be treated as zero.

## Mathematical interpretation and next gate

This audit supports five narrow conclusions.

1. Exact checkpoint accounting and no-refit resume work for all 9,000 pairs.
2. Finite material-negative and non-finite states must remain distinct; this
   also corrects the legacy b1d count from 133 false tolerance flags to 126
   finite material-negative plus seven non-finite rows.
3. Tightening the same optimizer controls changes neither backend result here.
4. Cross-optimizer behavior is not transportable across backends: bobyqa is a
   strong lme4 diagnostic in these data, whereas BFGS is an adverse glmmTMB
   route despite winning some individual objectives.
5. A universal likelihood-drop rule, optimizer winner, or D-study readiness
   decision is not justified.

Before calibration replicates 201--300 are generated, a successor contract
must be frozen with two separate tasks:

1. define replay as finite-within-tolerance, identical typed non-finite state,
   or mismatch before re-adjudicating this immutable ledger; and
2. add a backend-specific glmmTMB stabilization lane on viewed data, with
   prespecified restart/start identities and objective/gradient/Hessian
   accounting rather than assuming that BFGS is an adequate alternative.

Only after that numerical eligibility contract is closed should the separate
plain-versus-nuisance-boundary bootstrap operating-characteristic contract be
frozen. Size, power, Monte Carlo uncertainty, positive-component bias/RMSE/
coverage, and D-study stability remain scenario-by-method tasks on untouched
data. The few-level stratum cannot be pooled away.

## Source, test, and artifact evidence

The profile rationale follows the current official lme4 convergence,
`allFit()`, and `lmerControl()` references and the current official glmmTMB
troubleshooting and `glmmTMBControl()` references. Those sources recommend
stricter tolerances and alternative optimizers as diagnostics; they do not
provide a universal practical-equivalence threshold or license a successful-
only optimizer selection.

Five focused tests and 83 expectations pass in the explicit full tier. They
cover profile/control identity, exact 9,000-row manifest accounting,
checkpoint/marker corruption, the finite/within/non-finite sign split,
threshold-free summaries, all 18,000 backend fits, all 750 markers, the seven
strict replay failures, and zero-computation full resume.

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-weak-information-numerical-sensitivity-contract-0.2.3.md` | `e6844feb2ef7f027347b635b64bc9f673beceb84e41897d1bd007d5c8663c326` |
| `gtheory-weak-information-numerical-sensitivity-0.2.3.R` | `c5c2ff4193d832191eca4298c0e6b767419051d025d65eac1e31db44c421db26` |
| `test-gtheory-weak-information-numerical-sensitivity.R` | `09c946aa36adc93d8cd92b1bc9d9c3c02e947cd17a214c14b573b35d7566ee88` |

The record's own hash is omitted because recording it would change the file.
