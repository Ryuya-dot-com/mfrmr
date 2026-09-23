# Shared-rater scoring approximation: result and disposition

2026-09-23. Local M2/M3 follow-through. This addresses the numerical accuracy
of the retained conditional Person-scoring target; it does not requalify the
original 800-dataset interval study or re-estimate any calibration.

The [presampling protocol](shared-rater-scoring-reference-0.2.4.md) fixes
twelve rosters, four requested Persons per roster, an independent joint
posterior reference, Monte Carlo precision and practical error tolerances.
Source/data snapshots and full results are kept under
`validation-results/shared-rater-scoring-reference-20260923/`.

## Preparation record

The initial independent Stan program used `offset`, a reserved identifier.
Compilation refused it before any sampling began. Renaming the data field to
`facet_offset` corrected the source. The next compilation still read the
old copied Stan file because the initialization copy did not overwrite an
existing destination. Initialization now explicitly overwrites that derived
file and asserts successful copying; execution verifies its hash against
the frozen source before compiling. Both precompilation plans, snapshots
and failure logs are retained as `precompile-*` and `precompile2-*`.
No chains were generated under either failed preparation. The final frozen
plan keeps the same data, calibration, selections, seeds, sampling budget
and comparison criteria. No production package code was changed.

## Completed comparison

All twelve rosters and 48 requested Person scores completed. All 48 chains
returned successfully, providing 384,000 retained joint draws. Every latent
coordinate met the frozen Rhat/ESS criteria; there were no divergences or
maximum-tree-depth hits, and all chains met the E-BFMI criterion. Across
rosters the largest Rhat was 1.001028, minimum bulk ESS 10,157 and minimum
tail ESS 16,725. All production scores were `available_conditional` with
the unchanged 121/243-point and interpolation checks. No fit was re-estimated,
no source flag was changed, and no chain or case was replaced.

| Roster | Selected scores | Largest raw-reference EAP difference | Largest raw-reference SD difference |
| --- | ---: | ---: | ---: |
| Full: 240 Persons, 1,440 responses | 32 | .012534 logits | .015023 logits |
| Reduced: 48 Persons, 96 responses | 16 | .008544 logits | .008319 logits |

All **48 EAPs and 48 posterior SDs** meet the .05-logit criterion after adding
four chain-aware MCSEs. Maximum error allowances are .033288 logits for EAP
and .040989 for SD. These discrepancies include reference simulation error;
they are not exact measurements of the production approximation error.

For the raw sample quantiles, **72/96 endpoints** meet the original criterion.
Nineteen fail the .02-logit MCSE cap, and another five have uncertainty
allowances crossing the .10-logit tolerance. None meets the material-discrepancy
rule. The largest raw quantile difference is .070549 logits and its overall
largest MCSE is .025599 logits. Preserve all 24 unresolved original decisions;
do not report them as a numerical failure of the production scorer or as
successful raw-quantile qualification.

## Conditional-CDF reference refinement

The [follow-through protocol](shared-rater-scoring-tail-reference-0.2.4.md)
was fixed after detecting reference imprecision in the first three completed
rosters and before any conditional-CDF results. It uses every fourth saved
iteration from all four chains, retaining 8,000 paired joint rater draws per
roster. No new sampling occurred. It applies to all 48 selected Persons,
not only the initially unresolved endpoints. The original raw-quantile
comparison remains a separate result.

Given the shared raters and fixed calibration, a Person's conditional ability
distribution depends on that Person's own ratings. Averaging its CDF over the
full-roster posterior rater draws preserves the original joint-posterior
target and all within-Person uncertainty. The resulting smooth probabilities
reduce the reference noise. This is a different summary of the same posterior
sample, not independent replication or a replacement scoring method.

For **all 96 endpoints**, the CDF upper allowance at endpoint-minus-.10 is
below the target probability, and its lower allowance at endpoint-plus-.10
is above it. Hence every endpoint meets the unchanged .10-logit practical
bracket under the recorded numerical/MC criteria. The four-MCSE allowance is
not a simultaneous confidence guarantee. There are no material discrepancies
or unresolved refined endpoint checks in these selected cases.

- Maximum CDF MCSE: .000403962, below the .0005 cap. Maximum functional
  Rhat: 1.000718; minimum bulk/tail ESS: 5,531/6,584.
- Maximum per-draw 128/256-point CDF difference: 2.593310e-9; maximum relative
  normalizer difference: 2.711050e-9. The omitted normal-tail bound divided
  by the smallest normalizer is at most 1.840757e-29.
- Independent whole-line `stats::integrate` checks at the designated draw for
  each Person agree in CDF and relative normalizer within 1.93e-14.
- Raw posterior mass between the production endpoints ranges .944313--.953125.
  This is a sampled fixed-data posterior probability, not repeated-sampling
  coverage of generating ability. The endpoint bracket does not prove exact
  .95 mass or qualify calibration-estimation uncertainty.

## Validation-reader correction and evidence preservation

The final joint-density audit initially stopped before generating the main
summary. With the posterior namespace loaded, subsetting `draws_array`
retains its three dimensions by default. The validation runner treated a
one-iteration slice as a named vector; character indexing returned missing
values for the latent coordinates. Consequently the original case archives
contain 40 missing `log_joint_difference` values each. The gate correctly
refused them; missing checks were not interpreted as passing.

The shared validation helper now explicitly removes the S3 class before
base-array slicing. Future saved draws use that plain array too; the corrected
summary independently recomputes the joint-density check from the existing
draws and frozen Stan data. All **480 evaluations** agree within **6.822e-12**
in log density, against the unchanged 1e-8 limit. The original case archives,
their missing audit values and the failed `summary.log` remain unchanged.
`summary-repaired.log`, the summary source hash, and the frozen execution
source distinguish the reader repair from the original sampling/scoring.
No model probability, prior, calibration, draw, numerical score or acceptance
tolerance was modified. Chain/iteration axes are now explicit matrices for
all mean/SD/quantile MCSEs. The conditional-CDF reader already flattened each
selected rater variable explicitly and was unaffected; its saved input hashes
still match the original case files.

## Cost, output and roadmap disposition

Recorded sampling/audit/scoring phases total **3,448.133 seconds (57.47 min)**.
The eight full rosters take 301.873--494.653 seconds each for the independent
reference plus four production scores; reduced rosters take 37.862--71.513
seconds. The additional conditional-CDF calculations total 80.008 seconds,
using existing draws. Main sampling finished within its 60-minute/3-GiB
execution budget; the retained artifact directory is about 2.57 GiB before
documentation integration. These are local workload measurements, not a
general capacity limit or an isolated scoring-speed benchmark. Help now
recommends requesting a few Person outputs first while retaining all intended
scoring responses. Returning every Person is potentially expensive.

The bounded conditional-scoring comparison is complete. Keep the original
raw-quantile limitations and the subsequent reference refinement distinct.
Public scoring help, the tutorial, NEWS and active roadmaps describe the
tested three-category model/design/calibration scope and the distinction
between numerical convergence, approximation error and interval coverage.
No estimator, exported API or package numerical code was changed.

This advances M2/M3's required conditional Person workflow. The separate
calibration-likelihood Laplace approximation, retained regular/variance
interval decisions and final integrated source/help/output checks remain.
The saved joint draws can support a suitably specified further calibration
check without repeating sampling or scoring. This is not a general accuracy
or coverage guarantee, a rater-classification qualification, or completion
of M3/M5. No commit, push, main integration or publication occurred.

## Documentation and saved-result verification

The scoring Rd was regenerated in an isolated staging package; only its
matching topic was copied back. `tools::checkRd` passed and the topic rendered
to HTML. The changed tutorial section rendered with its comparison table,
and all R chunks in the source tutorial parsed. The full tutorial was not
executed again. Public roadmap summaries now consistently distinguish the
completed conditional-scoring comparison from the remaining calibration and
interval decisions; superseded internal records retain their historical scope.

A fresh R process verified all frozen input/source hashes and confirmed that
the production R expressions are unchanged (only scoring documentation changed).
All twelve saved score objects reproduced their Person table, complete scoring
roster and plot data through `mfrm_results()`; static reports retained the
conditional/Laplace interpretation. Estimation and scoring entry points were
replaced with failing stubs during replay to rule out silent recomputation.
The original and refined reference summaries retain their distinct decisions;
the final integrity check covers both source snapshots and saved-case hashes.
Evidence is in `check-integration.log`, `integration.rds` and
`final-integrity.log` beside the reference results. No whole-package suite,
unchanged simulation, calibration fit or Person score was rerun for this
documentation/integration check.
